//-- Turning the RGB LED into Green
//-- Board: iCE40-UP5K
module rgb_test (
        input clk,

        output led_blue, 
        output led_green,
        output led_red);

    //reset button && counter && max counter
    reg div_clk;
    reg [31:0] count;
    localparam [31:0] max_count = 6000;
    localparam led_red = 1;
    assign led_green=1;
    assign led_blue = 1;


    //count up on clock rising edge 
    always @ (posedge div_clk) begin
        led_red = ~led_red; 
    end

    always @ (posedge clk) begin
      if(count == max_count) begin
            count <= 32'b0;
            div_clk = ~div_clk;
        end else begin
            count <= count + 1;
        end
    end

endmodule
