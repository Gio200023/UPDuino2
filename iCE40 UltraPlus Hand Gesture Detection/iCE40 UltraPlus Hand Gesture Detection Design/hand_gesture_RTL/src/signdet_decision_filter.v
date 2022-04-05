module signdet_decision_filter (
input            clk       , // 
input     [4:0]  i_max_idx , // 
input     [15:0] i_diff    , //
input            i_validp  , //
output reg[3:0]  o_det_idx , // Detected index
output reg       o_det_vld , // LED filtered detection valid

input            resetn
);

parameter C_TH          = 8'h10; // threshold of time window filter

reg			r_det;
wire			w_det_vld;
reg		[7:0]	diff_lat0;
reg		[7:0]	diff_lat1;
reg		[7:0]	diff_lat2;
reg		[3:0]	idx_lat0;
reg		[3:0]	idx_lat1;
reg		[3:0]	idx_lat2;

reg		[7:0]	diff_lat;
reg		[3:0]	idx_lat;

reg			check_req;

wire		max0;
wire		max1;

assign max0 = (diff_lat0 >  diff_lat1) && (diff_lat0 > diff_lat2);
assign max1 = (diff_lat1 >= diff_lat0) && (diff_lat1 > diff_lat2);

always @(posedge clk)
begin
    if(i_validp) begin
	idx_lat0 <= i_max_idx;
	idx_lat1 <= idx_lat0;
	idx_lat2 <= idx_lat1;

	diff_lat0 <= (i_max_idx != 4'd9) ? i_diff[15:8] : 8'd0;
	diff_lat1 <= diff_lat0;
	diff_lat2 <= diff_lat1;
    end
end

always @(posedge clk)
begin
    if(i_validp && (idx_lat1 != 4'd9) && (w_det_vld == 1'b0) && (diff_lat1 >= C_TH))
	check_req <= 1'b1;
    else 
	check_req <= 1'b0;
end

always @(posedge clk)
begin
    if(check_req == 1'b1) begin
	r_det    <= 1'b1;
	diff_lat <= max0 ? diff_lat0 : max1 ? diff_lat1 : diff_lat2;
	idx_lat  <= max0 ? idx_lat0  : max1 ? idx_lat1  : idx_lat2;
    end else begin
	r_det <= 1'b0;
    end
end

always @(posedge clk)
begin
    o_det_vld <= w_det_vld;
end

always @(posedge clk)
begin
    if({o_det_vld, w_det_vld} == 2'b01)
	o_det_idx <= idx_lat;
    else if(w_det_vld == 1'b0)
	o_det_idx <= 4'd9;
end

lsc_led_con #(.CLK_FREQ(24000 ), 
	      .ON_TIME (500   ), 
	      .OFF_TIME(10    )) u_lsc_led_con (
    .clk     (clk    ),
    .resetn  (resetn ),
    .i_enable(1'b1   ),
    .i_fire  (r_det  ),
    .o_on    (w_det_vld  )
);


endmodule
