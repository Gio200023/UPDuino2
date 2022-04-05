// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2011 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised by
// a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement from
// Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation        TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                            408-826-6000 (other locations)
// Hillsboro, OR 97124                     web  : http://www.latticesemi.com/
// U.S.A                                   email: techsupport@lscc.com
// =============================================================================

`timescale 1 ns / 100 ps

module ice40_himax_video_process_128_32_seq_wide_br (
input		clk           , 
input		pclk          , 
input		resetn        , 

// Camera interface
input           i_cam_de      ,
input           i_cam_vsync   ,
input  [3:0]    i_cam_data    ,

// strobe request
output          o_strobe_req  ,
output reg      o_obj_det     ,
output reg      o_obj_det_trg ,

output reg[7:0]	o_width       ,
output reg[7:0]	o_height      ,

// video out for debugging (clk domain)
input           i_frame_req   ,
output          o_subpix_vld  ,
output    [7:0] o_subpix_out  ,

// video out for LCD
input           i_detect      ,
input           i_lcd_running ,
output reg      o_lcd_mode    ,
output          o_pix_we      ,
output   [15:0] o_pix         ,

// ML engine interface
input           i_rd_rdy      ,
output reg      o_rd_req      ,
output reg      o_rd_done     ,

output reg	o_we          ,
output reg[15:0]o_waddr       ,
output reg[15:0]o_dout        
);

parameter SUBPIX    = "NONE";
parameter USE_OSD   = 0;
parameter BYTE_MODE = "DISABLE";
parameter LCD_TYPE  = "LCD";
parameter BLUE_GAIN = "1";
parameter ROTATE    = 0;
parameter OBJ_TH    = 8'd30;

// parameter {{{
parameter [9:0]	lcd_sb_l = 10'd71;
parameter [9:0]	lcd_sb_r = 10'd583;
parameter [8:0]	lcd_vb_u = 9'd32;
parameter [8:0]	lcd_vb_b = 9'd288;
// parameter }}}

// dynamic parameter {{{
parameter [9:0]	sb_l = 10'd3;
parameter [9:0]	sb_r = 10'd643;
parameter [8:0]	vb_u = 9'd2; 
parameter [8:0]	vb_b = 9'd322;

// dynamic parameter }}}

// counters & masks {{{
reg		de_d;
reg	[3:0]	vsync_d;

reg	[9:0]	pcnt; // bit[0] indicate upper/lower nibble (0: upper nibble, 1: lower nibble) (max: 324 * 2 = 648)
reg	[8:0]	lcnt; // line counter (max: 324)

reg	[3:0]	bpcnt; // block pixel counter
reg	[3:0]	blcnt; // block line counter

reg	[7:0]	rbcnt; // read block counter (block index)
wire	[7:0]	wbcnt; // write block counter (block index)

reg		hmask;
reg		vmask;

reg	     	bpcnt_lcd; // block pixel counter
wire	     	blcnt_lcd; // block line counter

reg	[7:0]	rbcnt_lcd; // read block counter (block index)
wire	[7:0]	wbcnt_lcd; // write block counter (block index)

reg		hmask_lcd;
reg		vmask_lcd;

reg	[3:0]	cam_data_d;

wire	[7:0]	raw_l; // latch gray value

wire	[7:0]	r_l; // masked value of raw_l during red time
wire	[7:0]	g_l; // masked value of raw_l during green time
wire	[7:0]	b_l; // masked value of raw_l during blue time

reg	[9:0]	ro_waddr;
reg	[2:0]	frame_num_pclk;
reg	[1:0]	frame_num_clk;

reg		reading; // clk
reg		rd_done_pclk;
reg		rd_rdy_pclk;

always @(posedge pclk)
begin
    de_d         <= i_cam_de;
    vsync_d      <= {vsync_d[2:0], !i_cam_vsync};
    cam_data_d   <= i_cam_data;
    rd_done_pclk <= o_rd_done;
    rd_rdy_pclk  <= i_rd_rdy;
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	o_rd_req <= 1'b0;
    else if(rd_done_pclk)
	o_rd_req <= 1'b0;
    else if((lcnt == 9'd304) && rd_rdy_pclk)
	o_rd_req <= 1'b1;
end

always @(posedge pclk)
begin
    if(i_cam_de)
	pcnt <= pcnt + 10'd1;
    else 
	pcnt <= 10'd0;
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	hmask <= 1'b0;
    else if(pcnt == sb_l)
	hmask <= 1'b1;
    else if(pcnt == sb_r)
	hmask <= 1'b0;
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	vmask <= 1'b0;
    else if(lcnt == vb_u)
	vmask <= 1'b1;
    else if(lcnt == vb_b)
	vmask <= 1'b0;
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	hmask_lcd <= 1'b0;
    else if(pcnt == lcd_sb_l)
	hmask_lcd <= 1'b1;
    else if(pcnt == lcd_sb_r)
	hmask_lcd <= 1'b0;
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	vmask_lcd <= 1'b0;
    else if(lcnt == lcd_vb_u)
	vmask_lcd <= 1'b1;
    else if(lcnt == lcd_vb_b)
	vmask_lcd <= 1'b0;
end

always @(posedge pclk)
begin
    if({de_d, i_cam_de} == 2'b10)
	o_width <= pcnt[7:0];
end

always @(posedge pclk)
begin
    if({de_d, i_cam_de} == 2'b10)
	lcnt <= lcnt + 9'd1;
    else if(vsync_d[3])
	lcnt <= 9'b0;
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	frame_num_pclk <= 3'b0;
    else if(vsync_d[3:2] == 2'b01)
	frame_num_pclk <= frame_num_pclk + 3'd1;
end

assign o_strobe_req = frame_num_pclk[0];

always @(posedge pclk)
begin
    if(vsync_d[3:2] == 2'b01)
	o_height <= lcnt[7:0];
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	bpcnt <= 4'd0;
    else if(vsync_d[3] || (!hmask) || (!vmask))
	bpcnt <= 4'd0;
    else if(pcnt[0])
	bpcnt <= (bpcnt == 4'd9) ? 4'd0 : bpcnt + 4'd1;
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	rbcnt <= 8'b0;
    else if((!hmask) || (!vmask) || vsync_d[3])
	rbcnt <= 8'b0;
    else if((bpcnt == 4'd0) && pcnt[0])
	rbcnt <= rbcnt + 8'd1;
end

assign wbcnt = rbcnt - 8'd1;

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	blcnt <= 4'b0;
    else if((!vmask))
	blcnt <= 4'b0;
    else if({de_d, i_cam_de} == 2'b10)
	blcnt <= (blcnt == 4'd9) ? 4'd0 : blcnt + 4'd1;
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	bpcnt_lcd <= 1'd0;
    else if(vsync_d[3] || (!hmask_lcd) || (!vmask_lcd))
	bpcnt_lcd <= 1'd0;
    else if(pcnt[0])
	bpcnt_lcd <= !bpcnt_lcd;
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	rbcnt_lcd <= 8'b0;
    else if((!hmask_lcd) || (!vmask_lcd) || vsync_d[3])
	rbcnt_lcd <= 8'b0;
    else if(bpcnt_lcd == 1'd0 && pcnt[0])
	rbcnt_lcd <= rbcnt_lcd + 8'd1;
end

assign wbcnt_lcd = rbcnt_lcd - 8'd1;

assign blcnt_lcd = lcnt[0];

// counters & masks }}}

// downscale {{{

wire		c_we ;

wire	[15:0]	rdata;
reg	[15:0]	accu;

// accumulator buffer
dpram256x16 u_ram256x16_accu (
    .wr_clk_i   (pclk          ),
    .rd_clk_i   (pclk          ),
    .wr_clk_en_i(1'b1          ),
    .rd_en_i    (1'b1          ),
    .rd_clk_en_i(1'b1          ),
    .wr_en_i    (c_we          ),
    .wr_data_i  (accu          ), 
    .wr_addr_i  (wbcnt         ),
    .rd_addr_i  (rbcnt         ),
    .rd_data_o  (rdata         )
);

wire		c_we_lcd ;

wire	[9:0]	r_rdata_lcd;
reg	[9:0]	r_accu_lcd; 

wire	[10:0]	g_rdata_lcd;
reg	[10:0]	g_accu_lcd; 

wire	[9:0]	b_rdata_lcd;
reg	[9:0]	b_accu_lcd;

wire	[7:0]	r_mod_lcd;
wire	[7:0]	g_mod_lcd;
wire	[7:0]	b_mod_lcd;

wire	[31:0]	rdata_lcd;
wire	[31:0]	wdata_lcd;

assign wdata_lcd = {1'b0, r_accu_lcd[9:0], g_accu_lcd[10:0], b_accu_lcd[9:0]};

assign r_rdata_lcd = rdata_lcd[30:21];
assign g_rdata_lcd = rdata_lcd[20:10];
assign b_rdata_lcd = rdata_lcd[ 9: 0];

// accumulator buffer for lcd
dpram256x32 u_ram256x32_accu0_lcd (
    .wr_clk_i   (pclk         ),
    .rd_clk_i   (pclk         ),
    .wr_clk_en_i(1'b1         ),
    .rd_en_i    (1'b1         ),
    .rd_clk_en_i(1'b1         ),
    .wr_en_i    (c_we_lcd     ),
    .wr_data_i  (wdata_lcd    ), 
    .wr_addr_i  (wbcnt_lcd    ),
    .rd_addr_i  (rbcnt_lcd    ),
    .rd_data_o  (rdata_lcd    )
);

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	accu <= 16'b0;
    else if(hmask && vmask && (bpcnt == 3'd0) && (!pcnt[0])) // first horizontal pixel
	accu <= ((blcnt == 4'd0) ? 16'b0 : rdata);
    else if(pcnt[0] && hmask && vmask)
	accu <= accu + {8'b0, raw_l};
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0) begin
	r_accu_lcd <= 10'b0;
	g_accu_lcd <= 11'b0;
	b_accu_lcd <= 10'b0;
    end else if(hmask_lcd && vmask_lcd && (bpcnt_lcd == 1'd0) && (!pcnt[0])) begin // first horizontal pixel
	r_accu_lcd <= ((blcnt_lcd == 1'd0) ? 10'b0 : r_rdata_lcd);
	g_accu_lcd <= ((blcnt_lcd == 1'd0) ? 11'b0 : g_rdata_lcd);
	b_accu_lcd <= ((blcnt_lcd == 1'd0) ? 10'b0 : b_rdata_lcd);
    end else if(pcnt[0] && hmask_lcd && vmask_lcd) begin
	r_accu_lcd <= r_accu_lcd + {2'b0, r_l};
	g_accu_lcd <= g_accu_lcd + {3'b0, g_l};
	b_accu_lcd <= b_accu_lcd + ((BLUE_GAIN == "2"   ) ?  {1'b0, b_l, 1'b0} : 
	                    (BLUE_GAIN == "1.5" ) ? ({2'b0, b_l} + {3'b0, b_l[7:1]}) :
	                    (BLUE_GAIN == "1.25") ? ({2'b0, b_l} + {4'b0, b_l[7:2]}) : {2'b0, b_l});
    end
end

assign raw_l = {cam_data_d, i_cam_data};

assign r_l = ({pcnt[1],lcnt[0]} == 2'b11) ? raw_l : 8'b0;
assign g_l = (({pcnt[1],lcnt[0]} == 2'b10) || ({pcnt[1],lcnt[0]} == 2'b01)) ? raw_l : 8'b0;
assign b_l = ({pcnt[1],lcnt[0]} == 2'b00) ? raw_l : 8'b0;

wire	pix_wr;
wire	pix_wr_lcd;

assign c_we = (wbcnt != 8'hff) && (bpcnt == 4'd0) && (!pcnt[0]);
assign pix_wr = (blcnt == 4'd9) && c_we;

assign c_we_lcd = (wbcnt_lcd != 8'hff) && (bpcnt_lcd == 1'd0) && (!pcnt[0]);
assign pix_wr_lcd = blcnt_lcd && c_we_lcd;

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	ro_waddr <= 10'd0;
    else if(vsync_d[3:2] == 2'b01)
	ro_waddr <= 10'd0;
    else if(pix_wr && (ro_waddr != 10'h3ff))
	ro_waddr <= ro_waddr + 10'd1;
end

assign r_mod_lcd = r_accu_lcd[7:0];
assign g_mod_lcd = g_accu_lcd[8:1];
assign b_mod_lcd = (b_accu_lcd[8] ? 8'hff : b_accu_lcd[7:0]);

reg		frame_en;
reg	[1:0]	lcd_running_d;
reg		lcd_cmd_wr;
reg	[13:0]	pix_idx;

reg	[3:0]	pix_wr_d;
reg	[15:0]	pix_d;
reg	[15:0]	pix_d1;
reg	[15:0]	pix_d2;
wire		w_on;

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	pix_idx <= 14'b0;
    else if(vsync_d[3])
	pix_idx <= 14'b0;
    else if(pix_wr_lcd)
	pix_idx <= pix_idx + 14'd1;
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	pix_wr_d <= 4'b0;
    else
	pix_wr_d <= {pix_wr_d[2:0], pix_wr_lcd};
end

always @(posedge pclk)
begin
    pix_d  <= {r_mod_lcd[7:3], g_mod_lcd[7:2], b_mod_lcd[7:3]};
    pix_d1 <= pix_d;
    pix_d2 <= pix_d1;
end

generate if(USE_OSD)
begin
    ice40_osd_text u_ice40_osd_text(
	.clk      (clk    ),
	.pclk     (pclk   ),
	.resetn   (resetn ),
	.i_pix_idx(pix_idx),
	.i_addr   (8'b0   ),
	.i_wr     (1'b0   ),
	.i_data   (8'b0   ),
	.o_on     (w_on   )
    );
end
else begin
    reg 	r_on;
    reg [1:0]	r_on_d;

    always @(posedge pclk)
    begin
	r_on <= i_detect & ((pix_idx[ 6: 0] == 7'h0 ) | (pix_idx[ 6: 0] == 7'h1 ) | // left line
	                    (pix_idx[ 6: 0] == 7'h7e) | (pix_idx[ 6: 0] == 7'h7f) | // right line
	                    (pix_idx[13: 7] == 7'h0 ) | (pix_idx[13: 7] == 7'h1 ) | // top line
	                    (pix_idx[13: 7] == 7'h7e) | (pix_idx[13: 7] == 7'h7f)); // bottom line
	r_on_d <= {r_on_d[0], r_on};
    end

    assign w_on = r_on_d[1];
end
endgenerate

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	lcd_running_d <= 2'b0;
    else 
	lcd_running_d <= {lcd_running_d[0], i_lcd_running};
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	frame_en <= 1'b0;
    else if(vsync_d[3:2] == 2'b01)
	frame_en <= (~i_lcd_running) & (!frame_num_pclk[0]);
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	o_lcd_mode <= 1'b0;
    else if((vsync_d[3:2] == 2'b01) && (i_lcd_running == 1'b0))
	o_lcd_mode <= 1'b0;
    else if(lcd_running_d == 2'b10)
	o_lcd_mode <= 1'b1;
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	lcd_cmd_wr <= 1'b0;
    else if((vsync_d[3:2] == 2'b01) && (i_lcd_running == 1'b0))
	lcd_cmd_wr <= 1'b1;
    else
	lcd_cmd_wr <= 1'b0;
end

assign o_pix_we = (pix_wr_d[2] & frame_en) | lcd_cmd_wr;
assign o_pix    = lcd_cmd_wr ? ((LCD_TYPE == "OLED") ? 16'h5c00 : 16'h2c00) : w_on ? 16'h07e0 : pix_d2;

// downscale }}}

// readout {{{
wire	[7:0]	rd_pixel;
reg	[11:0]	rd_addr; // use bit[11:10] as channel index
wire	[9:0]	w_rd_addr_m; // modified frame read address per rotate parameter
wire	[1:0]	frame_num_p1_clk;

assign frame_num_p1_clk = rd_addr[11:10] + frame_num_clk + 2'd1;

assign w_rd_addr_m = (ROTATE == 270) ? { rd_addr[4:0], ~rd_addr[9:5]} : 
                     (ROTATE == 90 ) ? {~rd_addr[4:0],  rd_addr[9:5]} :
                     (ROTATE == 180) ? {~rd_addr} :
		     rd_addr[9:0]; // 0

reg		rd_rdy_clk;
reg		safe_zone_clk;

reg	[1:0]	do_d;

wire	[7:0]	accu_mod;
wire	[7:0]	accu_mod_br;
wire	[7:0]	rd_pixel_bg;
reg		r_obj_flag;
reg		obj_det_update;

assign accu_mod    = accu[14:7] + {2'b0, accu[14:9]};
assign accu_mod_br = (accu_mod <= rd_pixel_bg) ? 8'b0 : (accu_mod - rd_pixel_bg);

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	r_obj_flag <= 1'b0;
    else if(vsync_d[3:2] == 2'b01)
	r_obj_flag <= 1'b0;
    else if(pix_wr && frame_num_pclk[0] && (accu_mod_br >= OBJ_TH))
	r_obj_flag <= 1'b1;
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	obj_det_update <= 1'b0;
    else
	obj_det_update <= (pix_wr && frame_num_pclk[0] && (ro_waddr == 10'h3ff));
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	o_obj_det <= 1'b0;
    else if(obj_det_update)
	o_obj_det <= r_obj_flag;
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	o_obj_det_trg <= 1'b0;
    else
	o_obj_det_trg <= obj_det_update;
end

// buffer for sequence image
dpram4096x8 u_ram4096x8 (
    .wr_clk_i   (pclk        ),
    .rd_clk_i   (clk         ),
    .wr_clk_en_i(1'b1        ),
    .rd_en_i    (1'b1        ),
    .rd_clk_en_i(1'b1        ),
    .wr_en_i    (pix_wr & frame_num_pclk[0]),
    .wr_data_i  (accu_mod_br ),
    .wr_addr_i  ({frame_num_pclk[2:1], ro_waddr}),
    .rd_addr_i  ({frame_num_p1_clk, w_rd_addr_m}),
    .rd_data_o  (rd_pixel    )
);

// buffer for background (without strobe)
dpram1024x8 u_ram1024x8 (
    .wr_clk_i   (pclk        ),
    .rd_clk_i   (pclk        ),
    .wr_clk_en_i(1'b1        ),
    .rd_en_i    (1'b1        ),
    .rd_clk_en_i(1'b1        ),
    .wr_en_i    (pix_wr & (!frame_num_pclk[0])),
    .wr_data_i  (accu_mod    ),
    .wr_addr_i  (ro_waddr    ),
    .rd_addr_i  (ro_waddr    ),
    .rd_data_o  (rd_pixel_bg )
);

always @(posedge clk or negedge resetn)
begin
    if(resetn == 1'b0) begin
	rd_rdy_clk    <= 1'b0;
	safe_zone_clk <= 1'b0;
    end else begin
	rd_rdy_clk    <= i_rd_rdy;
	safe_zone_clk <= o_rd_req;
    end
end

always @(posedge clk or negedge resetn)
begin
    if(resetn == 1'b0)
	do_d <= 2'b0;
    else 
	do_d <= {do_d[0], (rd_rdy_clk & safe_zone_clk)};
end

always @(posedge clk or negedge resetn)
begin
    if(resetn == 1'b0)
	reading <= 1'b0;
    else if(do_d == 2'b01)
	reading <= 1'b1;
    else if(rd_addr == 12'hbff)
	reading <= 1'b0;
end

always @(posedge clk)
begin
    if(do_d == 2'b01)
	frame_num_clk <= frame_num_pclk[2:1];
end


always @(posedge clk or negedge resetn)
begin
    if(resetn == 1'b0)
	o_we <= 1'b0;
    else if(rd_addr == 12'h001) // read latency
	o_we <= 1'b1;
    else if(o_waddr == 16'hbff)
	o_we <= 1'b0;
end

always @(posedge clk or negedge resetn)
begin
    if(resetn == 1'b0)
	rd_addr <= 12'b0;
    else if(reading)
	rd_addr <= rd_addr + 12'd1;
    else
	rd_addr <= 12'b0;
end

always @(posedge clk or negedge resetn)
begin
    if(resetn == 1'b0)
	o_waddr <= 16'b0;
    else if(o_we)
	o_waddr <= o_waddr + 16'd1;
    else
	o_waddr <= 16'b0;
end

always @(posedge clk or negedge resetn)
begin
    if(resetn == 1'b0)
	o_dout <= 16'b0;
    else 
	o_dout <= (BYTE_MODE == "DISABLE") ? {6'b0, rd_pixel, 2'b0} - 16'h0200  : {8'b0, rd_pixel};
end

always @(posedge clk or negedge resetn)
begin
    if(resetn == 1'b0)
	o_rd_done <= 1'b0;
    else if(o_waddr == 16'hbff)
	o_rd_done <= 1'b1;
    else if(!rd_rdy_clk)
	o_rd_done <= 1'b0;
end

// readout }}}

// frame out {{{

// sub pixel is not valid
assign o_subpix_vld = 1'b0;
assign o_subpix_out = 8'b0;

// frame out }}}

endmodule

// vim:foldmethod=marker:
//
