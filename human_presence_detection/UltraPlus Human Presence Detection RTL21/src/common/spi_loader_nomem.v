
`timescale 1ns/10ps

module spi_loader_nomem (
input		resetn      , // 
input           clk         , // Clock (= RISC-V clock)
input           i_init      ,

// Filter Bank weight interfafe
output          o_init_addr ,
output          o_wgt_wr    ,
output [15:0]   o_wgt_out   ,

output reg      SPI_CSS     , // SPI I/F for flash access
output reg      SPI_CLK     , // 
input           SPI_MISO    , // 
output reg      SPI_MOSI    , // 

output reg      o_load_done
);
    //================================================================================
    // Parameters
    //================================================================================
    parameter DUMMY_CYCLE = 9'd7;
    parameter IDLE         =  3'd0,         // SPI access FSM
              PREP         =  3'd1,         //
              CMD          =  3'd2,         //
	      SADDR        =  3'd3,         //
	      DUMMY        =  3'd4,         //
	      RDBYTE       =  3'd5,         //
	      WAIT         =  3'd6,         //
	      WAIT10       =  3'd7;         // 10us wait for wake up from power down
    parameter NO_SCK       =  1'b1,         // OR mask for SCK
              ON_SCK       =  1'b0;         //
    parameter FAST_RD      =  8'h0b,        // Fast read flash command
              RLS_DPD      =  8'hab;        // Release from deep power-down
    parameter ST_ADDR      = 24'h020000;    // Starting address of ROM in flash

    reg        r_init;
    reg        prom_wr_en; // - IROM (PROM) write strobe
    reg [15:0] rom_data;   // 

    wire [16:0]   wd_size;

    //================================================================================
    // Internal signals
    //================================================================================
    reg  [2  : 0] cst, nst;
    reg  [8 : 0] cnt;
    reg           sck_msk, sck_msk_pe;
    reg  [3  : 0] bit_cnt;  // Accumulate 16b of data
    reg	 [16 : 0] wd_cnt;
    reg           en;
    reg           phase;

    reg	[2:0]	cst_d;
    reg	[2:0]	nst_d;

    always @(posedge clk or negedge resetn)
        if(!resetn) 
	    r_init <= 1'b0;
	else
	    r_init <= i_init;

    //================================================================================
    // Toggling "en" to make two cycle per state FSM
    // - FSM moves to next state if "en=1"
    //================================================================================
    always @(posedge clk or negedge resetn)
        if(!resetn) 
	    en <= 1'b0;
	else
	    en <= ~en;

    //================================================================================
    // Flash access FSM
    // - 9 cycles of dummy (not 8) for fast reading
    //================================================================================
    always @(posedge clk or negedge resetn)
        if     (!resetn      ) phase <= 1'b0; // Wake up phase
	else if(cst == WAIT10) phase <= 1'b1; // Read    phase

    always @(posedge clk or negedge resetn)
        if     (!resetn) 
	    cst <= IDLE;
	else if(en)
	    cst <= nst;

    always @(*)
        case(cst)
	IDLE   : nst = r_init ? PREP : IDLE;
	PREP   : nst =           CMD;
	CMD    : nst =  |cnt   ? CMD    : 
	                 phase ? SADDR  : WAIT10;
	SADDR  : nst = ~|cnt   ? DUMMY  : SADDR;
	DUMMY  : nst = ~|cnt   ? RDBYTE : DUMMY;
	RDBYTE : nst = (wd_cnt == wd_size) ? WAIT : RDBYTE;
	WAIT   : nst = r_init  ? WAIT : IDLE;
	WAIT10 : nst =  |cnt   ? WAIT10 : IDLE   ;
	default: nst =           PREP;
	endcase

    always @(posedge clk) // or negedge resetn)
//        if(!resetn) cnt <= 20'b0;
//	else 
	if(en)
	    case(cst)
	    IDLE   : cnt <=                  9'd00;         //  
	    PREP   : cnt <=                  9'd07;         //  8 bits  of CMD
	    CMD    : cnt <= |cnt   ? cnt - 9'd1 : 
	                     phase ? 9'd23  :               // 24 bits  of Start Address
			             9'd500  ;               // 10us+ delay after power up    
	    SADDR  : cnt <= |cnt   ? cnt - 9'd1 : DUMMY_CYCLE;  //  m bits  of DUMMY
	    DUMMY  : cnt <= |cnt   ? cnt - 9'd1 : 9'd0;  //  n bytes of data
	    RDBYTE : cnt <=                    9'd0;
	    WAIT   : cnt <=                    9'd0;
	    default: cnt <= |cnt   ? cnt - 9'd1 : 9'd0;
	    endcase

    //================================================================================
    // SPI signal generation 
    // - SPI_CSS is the CS_B
    //================================================================================
    always @(posedge clk or negedge resetn)
        if(!resetn) {SPI_CSS, SPI_MOSI} <= {1'b1, 1'b1};
	else if(en )
	    case(cst)
	    IDLE   : begin
		    SPI_CSS  <= 1'b0; 
		    SPI_MOSI  <= 1'b1;
		end
	    PREP   : begin
		    SPI_CSS  <= 1'b0;
		    SPI_MOSI  <= phase ? FAST_RD[7] : RLS_DPD[7];
		end
	    CMD    : if(|cnt) begin // Command
		    SPI_CSS  <= 1'b0; 
		    SPI_MOSI  <= phase ? FAST_RD[cnt-1] : RLS_DPD[cnt-1];
		end else begin      // S-Addr
		    SPI_CSS  <= phase ? 1'b0        : 1'b1; 
		    SPI_MOSI  <= phase ? ST_ADDR[23] : 1'b1;
		end
	    SADDR  : if(|cnt) begin // S-Addr
		    SPI_CSS  <= 1'b0;
		    SPI_MOSI  <= ST_ADDR[cnt-1];
		end else begin      // Dummy
		    SPI_CSS  <= 1'b0; 
		    SPI_MOSI  <= 1'b1; // Dummy
		end
	    DUMMY  : if(|cnt) begin // Dummy
		    SPI_CSS  <= 1'b0;
		    SPI_MOSI  <= 1'b1;
		end else begin      // Read byte
		    SPI_CSS  <= 1'b0; 
		    SPI_MOSI  <= 1'b1; // Don't care
		end
	    RDBYTE : if(r_init) begin // Read byte
		    SPI_CSS  <= 1'b0;
		    SPI_MOSI  <= 1'b1;
		end else begin   
		    SPI_CSS  <= 1'b1;
		    SPI_MOSI  <= 1'b1;
		end
	    WAIT   : {SPI_CSS, SPI_MOSI} <= {1'b1, 1'b1};
	    default: {SPI_CSS, SPI_MOSI} <= {1'b1, 1'b1};
	    endcase

    always @(posedge clk)// or negedge resetn)
        //if(!resetn) SPI_CLK <= 1'b1;
	//else 
	    case(cst)
		PREP, SADDR, DUMMY  : SPI_CLK <= ~en;
		CMD                 : SPI_CLK <= phase || |cnt ? ~en : 1'b1;
		RDBYTE              : SPI_CLK <= (r_init) ? ~en : 1'b1;
		default             : SPI_CLK <= 1'b1;
		endcase

    //================================================================================
    // SPSRAM access (write) FSM
    // - Direct access using rom_acc, prom_wr_en, and rom_data (16b)
    // - If rom_acc & prom_wr_en, rom_data is written to SPSRAM at every cycle w/
    //   auto increased address
    //================================================================================
    always @(posedge clk or negedge resetn)
        if(!resetn) begin
	    bit_cnt    <= 4'd15;
	    prom_wr_en <=  1'b0;
	    rom_data   <= 16'b0;
	end else if(cst == RDBYTE && !en) begin
	    bit_cnt    <= bit_cnt - 4'd1;
	    prom_wr_en <= (~|bit_cnt); 
	    rom_data   <= {rom_data[14 : 0], SPI_MISO};
	end else begin
	    prom_wr_en <=  1'b0;
	end

    always @(posedge clk or negedge resetn)
        if(!resetn)
	    wd_cnt  <= 17'b0;
	else if(!r_init)
	    wd_cnt  <= 17'b0;
	else if(prom_wr_en)
	    wd_cnt  <= wd_cnt + 17'd1;

    always @(posedge clk or negedge resetn)
        if(!resetn)
	    o_load_done <= 1'b0;
	else if(!r_init)
	    o_load_done <= 1'b0;
	else
	    o_load_done <= (cst == WAIT);

assign o_init_addr  = (cst == IDLE);

assign o_wgt_wr = prom_wr_en;
assign o_wgt_out = {rom_data[7:0], rom_data[15:8]};


assign wd_size = 17'd128 + 17'd65536;


endmodule
//================================================================================
// End of file
//================================================================================

// vim: ts=8 sw=4
