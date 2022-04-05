//========================================================================
// Project : Superman (InstaView - Fast Switching)
//                                                                        
// File    : lsi2c_fsm.v                                                  
// Document: DDC slave FSM to access HDCP registers
//           Slave address is fixed to 0x74 per HDCP spec
// Language: Verilog                                                      
// Author  : Hoon Choi                                                    
// Date    : Mar. 12, 2008                                                
//========================================================================
// History :                                                              
//
// Mar. 12, 2008 - Started from the one used in MIPI emulation
//                 Below is the history
//------------------------------------------------------------------------
// July  1, 2005 - FPGA emulation discovered one bug in the consecutive read/
//                 write of I2C registers. Simulation verifed one bug in abus 
//                 update part.
//                 Original: assign abus = sldaddrl ? rsr : addr;
//                 Fixed   : assign abus = sldaddrl ? rsr : addr + (sst == STACKD);
// June  2, 2005 - Started from the si2c_fsm.v designed for the sTx(Digimon)
//                 project. Below is the history of the original design.
//------------------------------------------------------------------------
// Feb. 25, 2003 - Started from the i2c_slave.v used for 1162.             
//========================================================================
// Note    :
//========================================================================

`timescale 1 ns / 100 ps
 
module lsc_i2cs_fsm(
    clk,        // input
    rst_n,      // input
    sda_in_clk, // input
    scl_in_clk, // input
    i2cid,      // input (7)
    i2cmask,    // input (7)
    i2cdevaddr, // output (7)
    dre,        // input  ( 8)
    sda_out  /* synthesis syn_useioff = 0 */ ,    // output
    we,         // output
    re,         // output
    stop,       // output
    dwe,        // output ( 8)
    abus        // output ( 8)
);
    //========================================================================
    // Ports
    //========================================================================
    input          clk;        // Oscillator clock
    input          rst_n;      // Gloabl reset synchronized to ock
    input          sda_in_clk; // SDA from a master synchronized to ock(clk)
    input          scl_in_clk; // SCL from a master synchronized to ock(clk)
    input  [6 : 0] i2cid;
    input  [6 : 0] i2cmask;
    output [6 : 0] i2cdevaddr;
    input  [7 : 0] dre;        // Data bus from RF
    output         sda_out;    // SDA to a master. This should be 1 when not driving.
    output         we;         // Write strobe to RF
    output         re;         // Read  strobe to RF
    output         stop;       // stop
    output [7 : 0] dwe;        // Data bus to RF
    output [7 : 0] abus;       // Addr bus to RF

    //========================================================================
    // Internal signals
    //========================================================================
    reg          sda_out   /* synthesis syn_useioff = 0 */ ;
    reg  [6 : 0] i2cdevaddr;
    reg          sda_in_nd, sda_in_pd;
    reg          bitclk_nd, bitclk_pd;
    wire         ne_sda_in, pe_sda_in;
    wire         ne_bitclk, pe_bitclk;
    reg  [2 : 0] bitcnt;
    wire         stxing, srxing;
    reg          start_s, stop_s;
    reg          start_sd;
    wire         cnt8;
    reg  [3 : 0] sst, nsst;
    wire         checkaddr, sldaddrl, ssda_en;
    wire         srd_reg, we;
    reg          addrmatch;
    reg          re;
    reg  [7 : 0] addr;
    reg          sda_out_pd;
    reg  [7 : 0] tsr;
    reg          sda_in_d;
    wire         re_en;
    wire         reload;
    wire         scl_in_clk, sda_in_clk;
    reg  [7 : 0] rsr;
    wire         inc;

    //========================================================================
    // Parameters
    //========================================================================
    parameter CHIPID = 4'b0111; // MS 4 bits of device address (0x7.)

    // FSM states
    //
    parameter SIDLE  = 4'b0000,
	      SADR   = 4'b0001, 
	      SACK   = 4'b0010,
	      SOFSL  = 4'b0011,
	      SACKL  = 4'b0100,
	      SRDATA = 4'b0101,
	      SRACKD = 4'b0110, 
	      STDATA = 4'b0111, 
	      STACKD = 4'b1000;

    //========================================================================
    // Slave address
    // - 0x74 (HDCP primary slave address)
    //========================================================================
   // assign i2cid = {CHIPID, 3'b010};

    //========================================================================
    // Edge generation logic                                                  
    //========================================================================
    always @(posedge clk or negedge rst_n)
        if(!rst_n) begin
	    sda_in_nd <= #0.1 1'b0;
	    sda_in_pd <= #0.1 1'b1;
	    bitclk_nd <= #0.1 1'b0;   
	    bitclk_pd <= #0.1 1'b1;
	end else begin
	    sda_in_nd <= #0.1 sda_in_clk;
	    sda_in_pd <= #0.1 sda_in_clk;
	    bitclk_nd <= #0.1 scl_in_clk; 
	    bitclk_pd <= #0.1 scl_in_clk;
	end

    assign ne_sda_in =  sda_in_nd & ~sda_in_clk;
    assign pe_sda_in = ~sda_in_pd &  sda_in_clk;
    assign ne_bitclk =  bitclk_nd & ~scl_in_clk;
    assign pe_bitclk = ~bitclk_pd &  scl_in_clk;

    //========================================================================
    // Bit counter
    //========================================================================
    always @(posedge clk or negedge rst_n)
	if     (!rst_n   ) bitcnt <= #0.1 3'b0;
	else if(ne_bitclk) bitcnt <= #0.1 start_s && !start_sd ? 3'b0          :
	                                  stxing  || srxing    ? bitcnt + 1'b1 : 
					                         3'b0;
    assign cnt8 = &bitcnt;

    //========================================================================
    // Start detection
    //========================================================================
    always @(posedge clk or negedge rst_n)
	if     (!rst_n                 ) start_s <= #0.1 1'b0;
	else if(start_sd               ) start_s <= #0.1 1'b0;
	else if(ne_sda_in && scl_in_clk) start_s <= #0.1 1'b1;

    always @(posedge clk or negedge rst_n)
	if     (!rst_n   ) start_sd <= #0.1 1'b0;
	else if(pe_bitclk) start_sd <= #0.1 start_s;

    //========================================================================
    // Stop detection
    //========================================================================
    always @(posedge clk or negedge rst_n)
	if     (!rst_n                 ) stop_s <= #0.1 1'b0;
	else if(stop_s && ne_bitclk    ) stop_s <= #0.1 1'b0;
	else if(pe_sda_in && scl_in_clk) stop_s <= #0.1 1'b1;
    assign stop = stop_s;

    //========================================================================
    //========================================================================
    // Main FSM
    //========================================================================
    //========================================================================

    //========================================================================
    // State change
    //========================================================================
    always @(posedge clk or negedge rst_n)
	if     (!rst_n   ) sst <= #0.1 SIDLE;
	else if(ne_bitclk) sst <= #0.1 start_s ? SADR : nsst;

    always @(sst or cnt8 or addrmatch or re or sda_in_d)
	case(sst)
        SADR   : nsst = cnt8      ? SACK                  : SADR;
        SACK   : nsst = addrmatch ? (re ? STDATA : SOFSL) : SIDLE;
        SOFSL  : nsst = cnt8      ? SACKL                 : SOFSL;
        SACKL  : nsst = SRDATA;
        SRDATA : nsst = cnt8      ? SRACKD                : SRDATA;
        SRACKD : nsst = SRDATA;
                 // Get next data until being stopped and then
                 // stay here since SCL does not change.     
        STDATA : nsst = cnt8      ? STACKD                : STDATA;
	STACKD : nsst = !sda_in_d ? STDATA                : SIDLE;
		 // Send next data until being stopped or NACK from master.
	default: nsst = SIDLE; // SIDLE case
	endcase

    //========================================================================
    // Output generation                                                      
    //========================================================================
    assign checkaddr = sst == SADR   && cnt8;
    assign sldaddrl  = sst == SOFSL  && cnt8;
    assign stxing    = sst == STDATA;
    assign srxing    = sst == SADR   || sst == SOFSL || sst == SRDATA;
    assign srd_reg   = sst == STACKD;
    assign reload    = sst == SACK   && addrmatch && re;
    assign re_en     = sst == STDATA && cnt8;
    assign we        = sst == SRACKD;
    assign ssda_en   = ~(sst == SACK && addrmatch || sst == SACKL || sst == SRACKD);

    //========================================================================
    // Incoming I2C data                                                      
    //========================================================================
    always @(posedge clk)
	if(srxing && pe_bitclk) rsr <= #0.1 {rsr[6 : 0], sda_in_clk};

    //========================================================================
    // SDA latch @ posedge                                                    
    //========================================================================
    always @(posedge clk)
	if(pe_bitclk) sda_in_d <= #0.1 sda_in_clk;

    //========================================================================
    // re: 1 - red, 0 - write
    //========================================================================
    always @(posedge clk or negedge rst_n)
	if     (!rst_n   ) re <= #0.1 1'b0;
	else if(ne_bitclk) re <= #0.1 checkaddr ? sda_in_d : re_en;
           
    //========================================================================
    // Addrmatch computation 
    //========================================================================
    always @(posedge clk or negedge rst_n)
	if     (!rst_n                ) addrmatch <= #0.1 1'b0;
	else if(ne_bitclk && checkaddr) addrmatch <= #0.1 (rsr[7 : 1] & i2cmask) == (i2cid & i2cmask);

    always @(posedge clk or negedge rst_n)
	if     (!rst_n                ) i2cdevaddr <= 7'b0;
	else if(ne_bitclk && checkaddr) i2cdevaddr <= rsr[7 : 1];

    //========================================================================
    // Addr bus and data bus
    //========================================================================
    assign inc = sst == SRACKD || sst == STACKD;

    always @(posedge clk or negedge rst_n)
	if     (!rst_n             ) addr <= #0.1 8'h00;
        else if(ne_bitclk          ) addr <= #0.1 sldaddrl ? rsr : addr + inc;

    assign abus = sldaddrl ? rsr : addr + (sst == STACKD);
    assign dwe  = rsr;

    //========================================================================
    // Tx
    //========================================================================
    always @(posedge clk)
        if(ne_bitclk) begin
	    if     (srd_reg | reload) tsr <= #0.1 dre;
	    else if(stxing          ) tsr <= #0.1 {tsr[6 : 0], 1'b1};
	end
   
    // To give enough hold time
    //
    always @(posedge clk) begin
	sda_out_pd <= #0.1 stxing ? tsr[7] : ssda_en;
	sda_out    <= #0.1 sda_out_pd;
    end

endmodule
