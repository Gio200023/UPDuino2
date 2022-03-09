
`timescale 1 ns / 100 ps

module lsc_i2cs_signdet(
input           clk        ,     // 
input           resetn     ,     // 

output reg[7:0] o_config_00,
input     [7:0] i_status_00,
input     [7:0] i_status_01,

input           i_scl      ,     // 
input           i_sda      ,     // 
output          o_sda            // 
);

wire	[6:0]	w_dev_addr;
wire	[7:0]	w_reg_addr;
reg	[7:0]	r_rdata   ;
wire	[7:0]	w_wdata   ;
wire		w_wr      ;
wire		w_rd      ;

wire	[31:0]	rdata;
    
lsc_i2cs u_lsc_i2cs(
    .clk       (clk       ),     // 
    .resetn    (resetn    ),     // 
                          
    .i_dev_addr(7'b0110000),     // 'h60
    .i_dev_mask(7'b1110000),
    .o_dev_addr(w_dev_addr),
                          
    .o_reg_addr(w_reg_addr),
    .i_rdata   (r_rdata   ),
    .o_wdata   (w_wdata   ),
    .o_wr      (w_wr      ),
    .o_rd      (w_rd      ),
                          
    .i_sda     (i_sda     ),     // 
    .i_scl     (i_scl     ),     // 
    .o_sda     (o_sda     )      // 
);

// Register files
//
always @(posedge clk or negedge resetn)
begin
    if(resetn == 1'b0)
	r_rdata <= 8'h0;
    else if(w_rd) 
	case({w_dev_addr[3:0], w_reg_addr})
	    12'he_00  : r_rdata <= o_config_00;

	    12'he_10  : r_rdata <= i_status_00;
	    12'he_11  : r_rdata <= i_status_01;
	    default: r_rdata <= 8'b0;
	endcase
end

always @(posedge clk or negedge resetn)
begin
    if(resetn == 1'b0) begin
	o_config_00 <= 8'h00;
    end else if(w_wr)
	case({w_dev_addr[3:0], w_reg_addr})
	    12'he_00  : o_config_00 <= w_wdata;
	endcase
end


endmodule
