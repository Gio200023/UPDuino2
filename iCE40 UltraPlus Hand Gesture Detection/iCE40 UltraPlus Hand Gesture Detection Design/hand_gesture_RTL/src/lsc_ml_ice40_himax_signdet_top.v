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

`define USE_LCD

module lsc_ml_ice40_himax_signdet_top (
// Camera interface
input		cam_pclk      ,
input           cam_hsync     ,
input           cam_vsync     ,
input  [3:0]    cam_data      ,
output          cam_trig      ,

output          cam_mclk      ,

inout           cam_scl       ,
inout           cam_sda       ,

inout           debug_scl     ,
inout           debug_sda     ,

output          standby       ,
output          strobe        , // IR LED strobe

// SPI
output    	spi_css       ,
inout    	spi_clk       ,
inout     	spi_miso      ,
output    	spi_mosi      ,

// LCD
`ifdef USE_LCD
output          lcd_spi_gpo   ,
output          lcd_spi_clk   ,
output          lcd_spi_css   ,
output          lcd_spi_mosi  ,
output          lcd_resetn    ,
`endif

output  [5:0]   oled          ,
output          REDn          ,
output          GRNn          ,
output          BLUn    
);

// Parameters {{{
parameter USE_ML        = 1'b0; // instantate ML engine or not
parameter BYTE_MODE     = "DISABLE"; // DISABLE
                                      // SIGNED
				      // UNSIGNED
parameter EN_I2CS       = 1'b0; // 1: instantiate i2c slave for control & debugging
parameter EN_UART       = 1'b1; // 1: instantiate UART for video output. EN_CLKMASK must be 0 in order to enable EN_UART
parameter EN_DUAL_UART  = 1'b1; // 1: wired AND connection for uart signal
parameter EN_SEQ        = 1'b0; // 1: sequence mode
parameter EN_STROBE_CTL = 1'b1; // 1: enable strobe control for reduce power
parameter EN_FILTER     = 1'b1;
parameter EN_ONEHOT     = 1'b0; // 1: use one hot code for LED, 0: 4 bit binary
parameter CODE_MEM      ="TRI_SPRAM"; //it use ebram in just different ways
                                // EBRAM
				// SINGLE_SPRAM
				// DUAL_SPRAM
				// TRI_SPRAM
parameter LCD_TYPE      = "OLED"; // LCD
				  //OLED
parameter C_TH          = 8'h0a; // threshold of time window filter ---old: 8'h0a
parameter ROTATE        = 0; // 0, 90, 180, 270
// Parameters }}}

// platform signals {{{
// Clocks
wire		clk;		// core clock
wire		oclk_in;	// internal oscillator clock input
wire		oclk;		// internal oscillator clock (global)
wire		pclk_in;
wire		pclk;		// pixel clock
wire		clk_init;	// initialize clock (based on oclk)
wire		resetn;
wire		w_init;
wire		w_init_done;

// SPI loader
wire		w_fill      ;
wire		w_fifo_empty;
wire		w_fifo_low  ;
wire		w_fifo_rd   ;
wire	[31:0]	w_fifo_dout ;
wire		w_load_done ;

wire		w_rd_rdy;
wire		w_rd_rdy_con;
reg		r_rd_rdy_con;
reg	[1:0]	r_rd_rdy_d;
wire		w_rd_req;
wire		w_rd_done;
wire		w_we;
wire	[15:0]	w_waddr;
wire	[15:0]	w_dout;

wire	        w_running;
wire	[7:0]	ml_status;

wire	[31:0]	w_cycles;
wire	[31:0]	w_commands;
wire	[31:0]	w_fc_cycles;

wire		w_result_en;
reg	[1:0]	r_result_en_d;
wire	[15:0]	w_result;

reg	[15:0]	result1;
reg	[15:0]	result2;
reg	[15:0]	result3;

wire	[3:0]	w_max;

reg	[3:0]	r_max_lat;
reg	[3:0]	r_max_filter;
reg	[3:0]	r_idx_lat;

reg	[3:0]	r_stable_cnt;

wire	[15:0]	w_diff;
wire	[3:0]	w_max_idx;
wire		w_validp;
reg	[3:0]	r_validp_d;
wire		w_det_vld;

// video related signals
wire	[3:0]	cam_data_p;
wire		cam_de_p;
wire		cam_vsync_p;
wire	[3:0]	cam_data_n;
wire		cam_de_n;
wire		cam_vsync_n;

// camera configuration
wire		w_scl_out;
wire		w_sda_out;

// IR LED strobe
wire		w_strobe_req;
wire		w_strobe;
wire		w_obj_det;
wire		w_obj_det_trig;
wire		w_obj_search;
wire		w_en_strobe;
wire            w_en_engine;

// internal UART & SPI
wire		w_uart_txd;
wire		w_uart_rxd;

wire		w_spi_clk;
wire		w_spi_mosi;

wire		w_lcd_init_done;
wire		w_lcd_running;
wire		w_lcd_mode   ;
wire		w_pix_we     ;
wire	[15:0]	w_pix        ;

// platform signals }}}

// I/O cell instantation {{{

assign pclk_in = cam_pclk;

IOL_B
#(
  .LATCHIN ("NONE_DDR"),
  .DDROUT  ("NO")
) u_io_cam_data[3:0] (
  .PADDI  (cam_data[3:0]),  // I
  .DO1    (1'b0),  // I
  .DO0    (1'b0),  // I
  .CE     (1'b1),  // I - clock enabled
  .IOLTO  (1'b1),  // I - tristate enabled
  .HOLD   (1'b0),  // I - hold disabled
  .INCLK  (pclk),  // I
  .OUTCLK (pclk),  // I
  .PADDO  (),  // O
  .PADDT  (),  // O
  .DI1    (cam_data_n[3:0]),  // O
  .DI0    (cam_data_p[3:0])   // O
);

/*
IOL_B
#(
  .LATCHIN ("NONE_REG"),
  .DDROUT  ("NO")
) u_io_cam_vsync (
  .PADDI  (cam_vsync),  // I
  .DO1    (1'b0),  // I
  .DO0    (1'b0),  // I
  .CE     (1'b1),  // I - clock enabled
  .IOLTO  (1'b1),  // I - tristate enabled
  .HOLD   (1'b0),  // I - hold disabled
  .INCLK  (pclk),  // I
  .OUTCLK (pclk),  // I
  .PADDO  (),  // O
  .PADDT  (),  // O
  .DI1    (cam_vsync_n),  // O
  .DI0    (cam_vsync_p)   // O
);
*/
assign cam_vsync_p = cam_vsync;

IOL_B
#(
  .LATCHIN ("NONE_DDR"),
  .DDROUT  ("NO")
) u_io_cam_de (
  .PADDI  (cam_hsync),  // I
  .DO1    (1'b0),  // I
  .DO0    (1'b0),  // I
  .CE     (1'b1),  // I - clock enabled
  .IOLTO  (1'b1),  // I - tristate enabled
  .HOLD   (1'b0),  // I - hold disabled
  .INCLK  (pclk),  // I
  .OUTCLK (pclk),  // I
  .PADDO  (),  // O
  .PADDT  (),  // O
  .DI1    (cam_de_n),  // O
  .DI0    (cam_de_p)   // O
);

// I/O cell instantation }}}

// debug signals {{{

wire	[7:0]	w_config_00;
wire	[7:0]	w_status_00;
wire	[7:0]	w_status_01;
wire		debug_o_sda;

wire		w_we2;
wire	[7:0]	w_waddr2;
wire	[31:0]	w_wdata2;

wire		w_frame_req ;
wire		w_subpix_vld;
wire	[7:0]	w_subpix_out;

wire		w_uart_empty;
wire	      	w_debug_vld;

// debug signals }}}

// Platform block {{{

HSOSC # (.CLKHF_DIV("0b01")) u_hfosc (
    .CLKHFEN   (1'b1 ),
    .CLKHFPU   (1'b1 ),
    .CLKHF     (oclk_in )
);
    

ice40_himax_signdet_clkgen #(.EN_CLKMASK(1'b0), .EN_SINGLE_CLK(1'b0)) u_ice40_sigdet_clkgen (
    .i_oclk_in   (oclk_in     ),
    .i_pclk_in   (pclk_in     ),

    .i_init_done (w_init_done ),
    .i_cam_vsync (cam_vsync_p ),
    .i_load_done (w_load_done ),
    .i_ml_rdy    (r_rd_rdy_con),
    .i_vid_rdy   (w_rd_done   ),
    .i_rd_req    (w_rd_req    ),

    .o_init      (w_init      ),
    .o_oclk      (oclk        ), // oscillator clock (always live)
    .o_clk       (clk         ), // core clock
    .o_pclk      (pclk        ), // video clock
    .o_clk_init  (clk_init    ),

    .resetn      (resetn      )
);

ice40_resetn u_resetn(
    .clk    (oclk  ),
    .resetn (resetn)
);

assign cam_mclk = w_init_done ? 1'b0 : oclk;

lsc_i2cm_himax #(.EN_ALT(0), .CONF_SEL("324x324_20fps_ir")) u_lsc_i2cm_himax(
    .clk      (clk_init   ),
    .init     (w_init     ),
    .init_done(w_init_done),
    .scl_in   (cam_scl    ),
    .sda_in   (cam_sda    ),
    .scl_out  (w_scl_out  ),
    .sda_out  (w_sda_out  ),
    .resetn   (resetn     )
);

assign cam_scl = w_scl_out ? 1'bz : 1'b0;
assign cam_sda = w_sda_out ? 1'bz : 1'b0;


generate if(EN_STROBE_CTL == 1'b1)
begin: g_on_en_strobe_ctl
    strobe_ctl #(.EN_SEQ(EN_SEQ)) u_strobe_ctl (
	.pclk          (pclk          ),
	.clk           (clk           ),

	.i_obj_det     (w_obj_det     ),
	.i_obj_det_trig(w_obj_det_trig),

	.o_search_mode (w_obj_search  ),
	.o_en_strobe   (w_en_strobe   ),
	.o_en_engine   (w_en_engine   ), // clk

	.resetn        (resetn        )
    );
end
else begin
    assign w_obj_search = 1'b0;
    assign w_en_strobe  = 1'b1;
    assign w_en_engine  = 1'b1;
end
endgenerate

himax_led_strobe u_himax_led_strobe (
    .          (pclk        ),
    .i_vs        (cam_vsync_p ),
    .i_strobe_req(w_strobe_req & w_en_strobe),
    .i_search    (w_obj_search),
    .o_strobe    (w_strobe    ),
    .resetn      (resetn      )
);

assign strobe = !w_strobe;

// Platform block }}}

// Debug block {{{
generate if(EN_I2CS)
begin: g_on_en_i2cs
    lsc_i2cs_signdet u_lsc_i2cs_local (
	.clk        (clk        ),     // 
	.resetn     (resetn     ),     // 

	.o_config_00(w_config_00),

	.i_status_00(w_status_00),
	.i_status_01(w_status_01),
	
	.i_scl      (debug_scl  ),     // 
	.i_sda      (debug_sda  ),     // 
	.o_sda      (debug_o_sda)      // 
    );

    assign debug_sda  = debug_o_sda ? 1'bz : 1'b0;
end
else
begin
    assign debug_scl  = 1'bz;  // pin 46 (UART_RX)
    assign debug_sda  = EN_DUAL_UART ? w_uart_txd : 1'bz;  // pin 47 (UART_TX)
end
endgenerate

generate if(EN_UART)
begin: g_on_en_uart
    wire	[7:0]	w_uart_dout;
    reg         [7:0]	r_uart_din;
    wire		w_uart_empty_actual;
    reg 	r_uart_vld; 

    reg		frame_req_lat;
    reg		frame_reading;
    reg	[2:0]	frame_req_sel;

    reg		result_reading;
    reg	[15:0]	result1_lat;
    reg	[15:0]	result2_lat;
    reg	[15:0]	result3_lat;
    reg	[3:0]	result_reading_seq;

    reg		cmp_result_req;
    reg		cmp_result_post_req;

    always @(posedge clk or negedge resetn)
    begin
	if(resetn == 1'b0)
	    frame_req_lat <= 1'b0;
	else if(w_uart_dout_vld && ((w_uart_dout[2:0] == 3'h0) || (w_uart_dout[2:0] == 3'h3))) // character 'h'(0x68) & 'k'
	    frame_req_lat <= 1'b1;
	else if(w_rd_done)
	    frame_req_lat <= 1'b0;
    end

    assign w_frame_req = (w_uart_dout_vld && (w_uart_dout[2:0] == 3'h0)); // character 'h'(0x68)

    always @(posedge clk or negedge resetn)
    begin
	if(resetn == 1'b0)
	    result_reading <= 1'b0;
	else if(w_uart_dout_vld && (w_uart_dout[2:0] == 3'h1)) // character 'i'(0x69)
	    result_reading <= 1'b1;
	else if(result_reading_seq == 4'd5)
	    result_reading <= 1'b0;
    end

    always @(posedge clk)
    begin
	if(w_uart_dout_vld && (w_uart_dout[2:0] == 3'h1)) begin // character 'i'(0x69)
	    result1_lat <= result1;
	    result2_lat <= result2;
	    result3_lat <= result3;
	end
    end

    always @(posedge clk or negedge resetn)
    begin
	if(resetn == 1'b0)
	    result_reading_seq <= 4'd0;
	else if(result_reading == 1'b1)
	    result_reading_seq <= result_reading_seq + 4'd1;
	else
	    result_reading_seq <= 4'd0;
    end

    always @(posedge clk or negedge resetn)
    begin
	if(resetn == 1'b0)
	    cmp_result_req <= 1'b0;
	else if(w_uart_dout_vld && (w_uart_dout[2:0] == 3'h2)) // character 'j'(0x6A) & 'k'
	    cmp_result_req <= 1'b1;
	else 
	    cmp_result_req <= 1'b0;
    end

    always @(posedge clk or negedge resetn)
    begin
	if(resetn == 1'b0)
	    cmp_result_post_req <= 1'b0;
	else if(w_uart_dout_vld && (w_uart_dout[2:0] == 3'h3)) // character 'k'(0x6B)'
	    cmp_result_post_req <= 1'b1;
	else if(r_validp_d[2])
	    cmp_result_post_req <= 1'b0;
    end

    always @(posedge clk or negedge resetn)
    begin
	if(resetn == 1'b0)
	    frame_reading <= 1'b0;
	else if(frame_req_lat  && w_rd_done)
	    frame_reading <= 1'b1;
	else if(r_validp_d[3])
	    frame_reading <= 1'b0;
    end

    always @(posedge clk or negedge resetn)
    begin
	if(resetn == 1'b0)
	    r_uart_vld <= 1'b0;
	else
	    r_uart_vld <=  (w_debug_vld & frame_reading ) | 
			   (cmp_result_req) | (result_reading_seq != 4'd0) | 
	                   (cmp_result_post_req & r_validp_d[2] & frame_reading);
    end

    always @(posedge clk)
    begin
	if(cmp_result_req == 1'b1)
	    r_uart_din <= {4'h3, w_max }; // digit value '0' ~ '8'
	else if(cmp_result_post_req & frame_reading & r_validp_d[2])
	    r_uart_din <= {4'h3, r_max_lat}; // digit value '0' ~ '8'
	else if(frame_reading == 1'b1)
	    r_uart_din <= w_result[10:3];
	else if(result_reading_seq != 4'd0)
	    case(result_reading_seq)
		4'd1:    r_uart_din <= result1[7: 0];
		4'd2:    r_uart_din <= result1[15:8];
		4'd3:    r_uart_din <= result2[7: 0];
		4'd4:    r_uart_din <= result2[15:8];
		4'd5:    r_uart_din <= result3[7: 0];
		4'd6:    r_uart_din <= result3[15:8];
		default: r_uart_din <= 8'd0;
	    endcase 
    end

	
    lsc_uart #(.PERIOD(16'd103), .BUFFER_SIZE("1K")) u_lsc_uart( // baud: 230400
    //lsc_uart #(.PERIOD(16'd207), .BUFFER_SIZE("1K")) u_lsc_uart( // baud: 115200
    //lsc_uart #(.PERIOD(16'd2499), .BUFFER_SIZE("1K")) u_lsc_uart( // baud: 9600
	.ref_clk(clk         ),
	.clk    (clk         ),
	.i_din  (r_uart_din  ),
	.i_valid(r_uart_vld  ),

	.o_dout (w_uart_dout ),
	.o_valid(w_uart_dout_vld ),
	.o_empty(w_uart_empty_actual ),
	.i_rxd  (w_uart_rxd  ), 
	.o_txd  (w_uart_txd  ),
	.resetn (resetn      )
    );
	
    assign w_uart_empty = w_uart_empty_actual;
end
else
begin
    assign w_uart_empty = 1'b1;

end
endgenerate

assign standby  = 1'b1; // power on

// Debug block }}}

// Code memory {{{
spi_loader_wrap #(.MEM_TYPE(CODE_MEM)) u_spi_loader(
    .clk          (clk          ),
    .resetn       (resetn       ),

    .o_load_done  (w_load_done  ),

    .i_fill       (w_fill       ),
    .i_init       (w_init       ),
    .o_fifo_empty (w_fifo_empty ),
    .o_fifo_low   (w_fifo_low   ),
    .i_fifo_rd    (w_fifo_rd    ),
    .o_fifo_dout  (w_fifo_dout  ),

    .SPI_CLK      (w_spi_clk    ),
    .SPI_CSS      (spi_css      ),
    .SPI_MISO     (spi_miso     ),
    .SPI_MOSI     (w_spi_mosi   )
);

assign spi_clk = w_load_done ? 1'bz : w_spi_clk;
assign w_uart_rxd = (spi_clk & w_load_done) & ((EN_DUAL_UART == 1'b0) | debug_scl);
assign spi_mosi = w_load_done ? w_uart_txd : w_spi_mosi;
assign spi_miso = w_load_done ? w_uart_txd : 1'bz;

// Code memory }}}

// Video processing {{{

reg		r_lcd_running;

generate if(EN_SEQ == 1)
begin: g_on_seq_wide
    ice40_himax_video_process_128_32_seq_wide_br #(.SUBPIX("NONE"), .BYTE_MODE(BYTE_MODE), .BLUE_GAIN("1"), .LCD_TYPE(LCD_TYPE), .ROTATE(ROTATE)) u_ice40_himax_video_process_128_32_seq_wide (
	.clk         (clk         ),
	.pclk        (pclk        ),
	.resetn      (resetn      ),
		     
	.i_cam_de    (cam_de_p    ),
	.i_cam_vsync (cam_vsync_p ),
	.i_cam_data  (cam_data_p  ),

	.o_strobe_req(w_strobe_req),
	.o_obj_det   (w_obj_det   ),
	.o_obj_det_trg(w_obj_det_trig),

	.o_width     (),
	.o_height    (),

	.i_frame_req (w_frame_req ),
	.o_subpix_vld(w_subpix_vld),
	.o_subpix_out(w_subpix_out),

	.i_rd_rdy    (w_rd_rdy_con),
	.o_rd_req    (w_rd_req    ),
	.o_rd_done   (w_rd_done   ),

	.i_detect    (1'b0       ),
	.i_lcd_running(r_lcd_running),
	.o_lcd_mode  (w_lcd_mode  ),
	.o_pix_we    (w_pix_we    ),
	.o_pix       (w_pix       ),
		     
	.o_we        (w_we        ),
	.o_waddr     (w_waddr     ),
	.o_dout      (w_dout      )
    );
end
else 
begin: g_on_wide_br
    ice40_himax_video_process_128_32_wide_br #(.SUBPIX("NONE"), .BYTE_MODE(BYTE_MODE), .BLUE_GAIN("1"), .LCD_TYPE(LCD_TYPE), .ROTATE(ROTATE)) u_ice40_himax_video_process_128_32_wide (
	.clk         (clk         ),
	.pclk        (pclk        ),
	.resetn      (resetn      ),
		     
	.i_cam_de    (cam_de_p    ),
	.i_cam_vsync (cam_vsync_p ),
	.i_cam_data  (cam_data_p  ),

	.o_strobe_req(w_strobe_req),
	.o_obj_det   (w_obj_det   ),
	.o_obj_det_trg(w_obj_det_trig),

	.o_width     (),
	.o_height    (),

	.i_frame_req (w_frame_req ),
	.o_subpix_vld(w_subpix_vld),
	.o_subpix_out(w_subpix_out),

	.i_rd_rdy    (w_rd_rdy_con),
	.o_rd_req    (w_rd_req    ),
	.o_rd_done   (w_rd_done   ),

	.i_detect    (1'b0       ),
	.i_lcd_running(r_lcd_running),
	.o_lcd_mode  (w_lcd_mode  ),
	.o_pix_we    (w_pix_we    ),
	.o_pix       (w_pix       ),
		     
	.o_we        (w_we        ),
	.o_waddr     (w_waddr     ),
	.o_dout      (w_dout      )
    );
end
endgenerate

assign cam_trig = 1'b1;

// Video processing }}}

// Result handling {{{
reg	[3:0]	result_cnt;

always @(posedge clk)
begin
    if(w_result_en)
	result_cnt <= result_cnt + 4'd1;
    else 
	result_cnt <= 4'b0;
end

// latch result just for uart_display_gesture software
always @(posedge clk)
begin
    if(result_cnt == 4'd1) result1 <= w_result;
    if(result_cnt == 4'd2) result2 <= w_result;
    if(result_cnt == 4'd3) result3 <= w_result;
end

signdet_post u_signdet_post(
    .clk       (clk         ),
    .i_init    (w_rd_done   ),
    .i_we      (w_result_en ),
    .i_dout    (w_result    ),
    .o_diff    (w_diff      ),
    .o_max_idx (w_max_idx   ),
    .o_validp  (w_validp    ),
    
    .resetn    (resetn      )
);

always @(posedge clk or negedge resetn)
begin
    if(resetn == 1'b0)
	r_validp_d <= 4'd0;
    else
	r_validp_d <= {r_validp_d[2:0], w_validp};
end

always @(posedge clk or negedge resetn)
begin
    if(resetn == 1'b0)
	r_max_lat <= 4'b0;
    else if(w_validp == 1'b1) 
	r_max_lat <= w_max_idx;
end

always @(posedge clk or negedge resetn)
begin
    if(resetn == 1'b0)
	r_stable_cnt <= 4'b0;
    else if(w_validp == 1'b1) 
	r_stable_cnt <= (w_max_idx != r_max_lat) ? 4'd0 : (r_stable_cnt + ((r_stable_cnt != 4'hf) ? 4'd1 : 4'd0));
end

always @(posedge clk or negedge resetn)
begin
    if(resetn == 1'b0)
	r_max_filter <= 4'b0;
    else if((r_stable_cnt == 4'd3) || (r_stable_cnt == 4'd2))
	r_max_filter <= r_max_lat;
end

generate if(EN_SEQ == 1'b1)
begin: g_on_seq_det
    signdet_decision_filter #(.C_TH(C_TH)) u_signdet_decision_filter (
	.clk       (clk      ), // 
	.i_max_idx (w_max_idx), // 
	.i_diff    (w_diff   ), //
	.i_validp  (w_validp ), //
	.o_det_idx (w_max    ), // Detected index
	.o_det_vld (w_det_vld), // LED filtered detection valid

	.resetn    (resetn   )
    );
end
else
begin
    assign w_max = EN_FILTER ? r_max_filter : r_max_lat;
end
endgenerate

assign w_status_00 = {4'b0, r_max_lat}; // current result
assign w_status_01 = {4'b0, w_max};	// filtered result

// Result handling }}}

// NN block {{{

generate if(USE_ML == 1'b1)
begin: g_use_ml_on
    cnn_accel u_lsc_ml (
	.clk         (clk         ),
	.resetn      (resetn      ),
				  
	.o_rd_rdy    (w_rd_rdy    ),
	.i_start     (w_rd_done   ),

	.o_cycles    (w_cycles    ),
	.o_commands  (w_commands  ),
	.o_fc_cycles (w_fc_cycles ),
				  
	.i_we        (w_we        ),
	.i_waddr     (w_waddr     ),
	.i_din       (w_dout      ),

	.o_we        (w_result_en ),
	.o_dout      (w_result    ),
	
	.i_debug_rdy (w_uart_empty),
	.o_debug_vld (w_debug_vld ),

	.o_fill      (w_fill      ),
	.i_fifo_empty(w_fifo_empty),
	.i_fifo_low  (w_fifo_low  ),
	.o_fifo_rd   (w_fifo_rd   ),
	.i_fifo_dout (w_fifo_dout ),

	.o_status    (ml_status   )
    );

    assign w_rd_rdy_con = w_rd_rdy & (!w_config_00[0]) & w_en_engine;

    always @(posedge clk or negedge resetn)
    begin
	if(resetn == 1'b0)
	    r_rd_rdy_d <= 2'b0;
	else
	    r_rd_rdy_d <= {r_rd_rdy_d[0], w_rd_rdy};
    end

    always @(posedge clk or negedge resetn)
    begin
	if(resetn == 1'b0)
	    r_rd_rdy_con <= 1'b1;
	else if(r_rd_rdy_d == 2'b01)
	    r_rd_rdy_con <= 1'b1;
	else if(w_rd_rdy == 1'b0)
	    r_rd_rdy_con <= 1'b0;
    end

end
else
begin
    assign w_rd_rdy_con = (!w_config_00[0]);
    assign w_result_en = 1'b0;
    assign w_debug_vld = 1'b0;
    assign w_fifo_rd   = 1'b0;
end
endgenerate

// NN block }}}

// LEDs {{{
generate if(EN_ONEHOT == 1'b1)
begin: g_on_onehot
    assign oled[0] = (w_max == 4'h0) ? 1'bz : 1'b0; 
    assign oled[1] = (w_max == 4'h1) ? 1'bz : 1'b0; 
    assign oled[2] = (w_max == 4'h2) ? 1'bz : 1'b0; 
    assign oled[3] = (w_max == 4'h3) ? 1'bz : 1'b0; 
    assign oled[4] = (w_max == 4'h4) ? 1'bz : 1'b0; 
    assign oled[5] = (w_max == 4'h5) ? 1'bz : 1'b0; 
end 
else begin
    assign oled[0] = w_max[0] ? 1'bz : 1'b0; 
    assign oled[1] = w_max[1] ? 1'bz : 1'b0;
    assign oled[2] = w_max[2] ? 1'bz : 1'b0;
    assign oled[3] = w_max[3] ? 1'bz : 1'b0;
    assign oled[4] = w_en_engine ? 1'bz : 1'b0;
    assign oled[5] = w_obj_det ? 1'bz : 1'b0;
end
endgenerate

reg	[3:0]	pwm_cnt;

always @(posedge oclk)
begin
    pwm_cnt <= pwm_cnt + 4'd1;
end

wire	w_red;
wire	w_green;
wire	w_blue;

assign w_green = w_max[1] & (pwm_cnt[3:0] == 4'd0);
assign w_blue  = w_max[2] & (pwm_cnt[3:0] == 4'd0);
assign w_red   = w_max[3] & (pwm_cnt[3:0] == 4'd0);

RGB RGB_DRIVER ( 
    .RGBLEDEN (1'b1    ),
    .RGB0PWM  (w_green ), // Green
    .RGB1PWM  (w_blue  ), 
    .RGB2PWM  (w_red   ),
    .CURREN   (1'b1    ), 
    .RGB0     (REDn    ),
    .RGB1     (GRNn    ),
    .RGB2     (BLUn    )
);
defparam RGB_DRIVER.RGB0_CURRENT = "0b000001";
defparam RGB_DRIVER.RGB1_CURRENT = "0b000001";
defparam RGB_DRIVER.RGB2_CURRENT = "0b000001";


// LEDs }}}

// TFT LCD out {{{

`ifdef USE_LCD

always @(posedge clk)
begin
    r_lcd_running <= (w_lcd_running | (!w_lcd_init_done));
end

spi_lcd_tx #(.TYPE(LCD_TYPE)) u_spi_lcd_tx (
    .clk        (clk         ),
    .wclk       (pclk        ),
    .resetn     (resetn      ),

    .i_en       (w_load_done ),
                             
    .i_we       (w_pix_we    ),
    .i_mode     (w_lcd_mode  ),
    .i_data     (w_pix       ),

    .o_init_done(w_lcd_init_done),
    .o_running  (w_lcd_running),

    .SPI_GPO    (lcd_spi_gpo ),
    .SPI_CLK    (lcd_spi_clk ),
    .SPI_CSS    (lcd_spi_css ),
    .SPI_MOSI   (lcd_spi_mosi)
);

assign lcd_resetn = resetn;
`endif


// TFT LCD out }}}

endmodule

// vim:foldmethod=marker:
//
