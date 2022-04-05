
`timescale 1 ns / 100 ps

module lsc_i2cs(
input           clk       ,     // 
input           resetn    ,     // 

input  [6:0]	i_dev_addr,
input  [6:0]	i_dev_mask,
output [6:0]	o_dev_addr,

output [7:0]	o_reg_addr,
input  [7:0]	i_rdata   ,
output [7:0]    o_wdata   ,
output          o_wr      ,
output          o_rd      ,
output          o_stop    ,

input           i_sda     ,     // 
input           i_scl     ,     // 
output          o_sda           // 
);
    
    //========================================================================
    // Internal siganls
    //========================================================================
    wire         scl_in_clk;
    wire         sda_in_clk;
    wire         we, re;
    wire         i2c_filter;
    reg          scl_pd;
    wire	 posedge_scl;

    //========================================================================
    // SDA/SCL synchronization
    //========================================================================
    double_sync2 
    double_sync_u0(.ck(clk), .rst_n(resetn), .d(i_scl), .q(scl_in_clk), .f(i2c_filter));
    double_sync2 
    double_sync_u1(.ck(clk), .rst_n(resetn), .d(i_sda), .q(sda_in_clk), .f(i2c_filter));

    assign i2c_filter = 1'b1; // Filter ON

    always @(posedge clk or negedge resetn)
        if(!resetn) scl_pd <= 1'b1;
        else        scl_pd <= scl_in_clk;

    assign posedge_scl = ~scl_pd & scl_in_clk;

    //========================================================================
    // Slave FSM
    //========================================================================
    lsc_i2cs_fsm
    u_lsc_i2cs_fsm (
	.clk        (clk       ), // input
	.rst_n      (resetn    ), // input
	.sda_in_clk (sda_in_clk), // input
	.scl_in_clk (scl_in_clk), // input
	.i2cid      (i_dev_addr), // input (7)
	.i2cmask    (i_dev_mask), // input (7)
	.i2cdevaddr (o_dev_addr), // output (7)
	.dre        (i_rdata   ), // input  ( 8)
	.sda_out    (o_sda     ), // output
	.we         (we        ), // output
	.re         (re        ), // output
	.stop       (o_stop    ), // output
	.dwe        (o_wdata   ), // output ( 8)
	.abus       (o_reg_addr)  // output ( 8)
    );

    assign o_wr = we;
    assign o_rd = re & posedge_scl;

endmodule

//============================================================================
module double_sync2(
    ck,    // input
    rst_n, // input
    d,     // input
    q,     // output
    f      // input
);
    input  ck;
    input  rst_n;
    input  d;
    output q;
    input  f; // 1 - filter on, 0 - filter off

    reg  [4 : 0] ds_ffs;
    reg          state;
    wire         all_and, all_or;
    wire         all1, all0;

    always @(posedge ck or negedge rst_n)
        if(!rst_n) ds_ffs <= #0.1 5'b11111;
        else       ds_ffs <= #0.1 {ds_ffs[3 : 0], d};

    assign all_and = &ds_ffs[4 : 1];
    assign all_or  = |ds_ffs[4 : 1];
    assign all1    =  all_and;
    assign all0    = ~all_or;

    always @(posedge ck or negedge rst_n)
        if     (!rst_n      ) state <= #0.1 1'b1;
	else if(all1 || all0) state <= #0.1 all1;

    assign q = f ? (state ? all_or : all_and) : ds_ffs[1];

endmodule
