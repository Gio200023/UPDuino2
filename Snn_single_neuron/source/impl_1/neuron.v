// neuron with 3 input that can be called from top level module 
module neuron(
	
	input clk,         //clock
	input resetn,	   //reset
	input neuron_in1,  //1 neuron input (incoming spike) 
	input neuron_in2,  //2
	input neuron_in3,  //3
	
	output neuron_out //output

);

reg [4:0] V_rest    =6; 		//Neuron voltage at rest
reg [4:0] V_i       =6;   	//Neuron voltage Level
reg [4:0] V_thresh  =14;     //Neuron voltage Threshold
reg [3:0] V_leak    =1;		 //Neuron voltage Leak
reg neuron_i_reg     =0;
reg K_syn  			=1; 	 //synaptuc weight parameter


always @ (posedge clk) begin
	neuron_i_reg = 0;
	V_i = V_i + K_syn * (neuron_in1 + neuron_in2 + neuron_in3) - V_leak;
	if(V_i >= V_thresh) begin
		V_i = V_rest;
		neuron_i_reg = 1;
	end
	if(V_i < V_rest) begin
		V_i = V_rest;
	end
end

assign neuron_out = neuron_i_reg;

endmodule

module spike_network(

	input clk,
	input resetn,
	input neuron_in1,
	input neuron_in2,
	input neuron_in3,
	output neuron_out7,
	output neuron_out8

);

//neurons to called in the middle layer
wire neuron_4;
wire neuron_5;
wire neuron_6;

neuron neuron4(
	.clk(clk),
	.resetn(resetn),
	.neuron_in1(neuron_in1),
	.neuron_in2(neuron_in2),
	.neuron_in3(neuron_in3),
	.neuron_out(neuron_4)
);

neuron neuron5(
	.clk(clk),
	.resetn(resetn),
	.neuron_in1(neuron_in1),
	.neuron_in2(neuron_in2),
	.neuron_in3(neuron_in3),
	.neuron_out(neuron_5)
);

neuron neuron6(
	.clk(clk),
	.resetn(resetn),
	.neuron_in1(neuron_in1),
	.neuron_in2(neuron_in2),
	.neuron_in3(neuron_in3),
	.neuron_out(neuron_6)
);

neuron neuron7(
	.clk(clk),
	.resetn(resetn),
	.neuron_in1(neuron_4),
	.neuron_in2(neuron_5),
	.neuron_in3(neuron_6),
	.neuron_out(neuron_7)
);

neuron neuron8(
	.clk(clk),
	.resetn(resetn),
	.neuron_in1(neuron_4),
	.neuron_in2(neuron_5),
	.neuron_in3(neuron_6),
	.neuron_out(neuron_8)
);

endmodule