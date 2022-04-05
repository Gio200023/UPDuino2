// 8 bit counter with asynchronous reset
module count(	c,
				clk,
				rst
			);

  input clk,rst; 
  output [7:0]c;
  reg [7:0]c;

  always @(posedge clk or posedge rst)
	begin
       if (rst)
        c <= 8'b0;
       else
		c <= c + 1'b1;
	end
  endmodule

