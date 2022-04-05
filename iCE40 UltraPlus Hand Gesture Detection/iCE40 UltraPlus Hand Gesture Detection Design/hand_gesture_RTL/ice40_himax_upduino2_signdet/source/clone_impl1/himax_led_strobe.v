
module himax_led_strobe (
input		clk         ,

input           i_vs        ,
input           i_strobe_req,
input           i_search    , // search mode. Use input parameter

output reg   	o_strobe    ,

input		resetn     
);

parameter DELAY_FULL      = 8'd160;
parameter DURATION_FULL   = 8'd160;
parameter DELAY_SEARCH    = 8'd85;
parameter DURATION_SEARCH = 8'd24;

wire	[23:0]	delay;
wire	[23:0]	duration;

reg	[7:0]	r_delay;
reg	[7:0]	r_duration;

reg	[23:0]	period_cnt;
reg	[23:0]	period_lat;
reg	[23:0]	duration_cnt;

reg	[2:0]	vs_d;
wire		w_vs_edge;

assign w_vs_edge = (vs_d[2:1] == 2'b10);

always @(posedge clk)
begin
    vs_d <= {vs_d[1:0], i_vs};
end

always @(posedge clk)
begin
    if(w_vs_edge) begin
	r_delay    <= i_search ? DELAY_SEARCH    : DELAY_FULL;
	r_duration <= i_search ? DURATION_SEARCH : DURATION_FULL;
    end
end

assign delay    = (24'd24576 + {5'b0, r_delay, 11'b0});
assign duration = {5'b0, r_duration, 11'b0};

always @(posedge clk)
begin
    if(w_vs_edge)
	period_cnt <= 24'd0;
    else
	period_cnt <= period_cnt + 24'd1;
end

always @(posedge clk)
begin
    if(w_vs_edge)
	period_lat <= period_cnt;
end

always @(posedge clk or negedge resetn)
begin
    if(resetn == 1'b0)
	o_strobe <= 1'b0;
    else if((period_cnt == (period_lat - delay)) && (i_strobe_req == 1'b1))
	o_strobe <= 1'b1;
    else if(duration_cnt == duration)
	o_strobe <= 1'b0;
end

always @(posedge clk)
begin
    if(o_strobe)
	duration_cnt <= duration_cnt + 24'd1;
    else
	duration_cnt <= 24'd0;
end

endmodule
