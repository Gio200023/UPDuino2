
module strobe_ctl (
input		pclk          ,
input		clk           ,

input           i_obj_det     ,
input           i_obj_det_trig,
output reg      o_search_mode ,
output		o_en_strobe   ,
output reg      o_en_engine   ,

input		resetn     
);

parameter EN_SEQ = 1'b0;

reg	[3:0]	det_cnt;
reg	[3:0]	undet_cnt;
reg	[3:0]	skip_cnt;

reg		r_en_engine;

assign o_en_strobe = (skip_cnt == 4'b0) | (!o_search_mode);

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	o_search_mode <= 1'b1;
    else if(det_cnt == 4'd4)
	o_search_mode <= 1'b0;
    else if(undet_cnt == 4'hf)
	o_search_mode <= 1'b1;
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	r_en_engine <= 1'b0;
    else if(det_cnt == (EN_SEQ ? 4'd8 : 4'd4))
	r_en_engine <= 1'b1;
    else if(undet_cnt == 4'hf)
	r_en_engine <= 1'b0;
end

always @(posedge clk)
begin
    o_en_engine <= r_en_engine;
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	skip_cnt <= 4'b0;
    else if(i_obj_det_trig)
	skip_cnt <= i_obj_det ? 4'b0 : (skip_cnt == 4'b0) ? 4'd10 : (skip_cnt - 4'd1);
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	det_cnt <= 4'b0;
    else if(i_obj_det_trig)
	det_cnt <= (!i_obj_det) ? 4'h0 : (det_cnt + {3'b0, (det_cnt != 4'hf)});
end

always @(posedge pclk or negedge resetn)
begin
    if(resetn == 1'b0)
	undet_cnt <= 4'b0;
    else if(i_obj_det_trig)
	undet_cnt <= i_obj_det ? 4'h0 : (undet_cnt + {3'b0, (undet_cnt != 4'hf)});
end

endmodule
