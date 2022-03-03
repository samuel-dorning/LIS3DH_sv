`timescale 1ns/1ns
module tb();

logic signed [15:0] x;

logic [15:0] out;
logic [9:0] num;
logic [3:0] ones;
logic [3:0] tenths;
logic [3:0] hundredths;
logic [3:0] thousandths;


initial begin
	x = 16'hFFFF;
	#(100);
	$stop;
end


always_comb begin
	num = ((~x[15:6]) + 1);
	out = num*4;
	ones = (out/1000) % 10;
	tenths = (out/100) % 10;
	hundredths = (out/10) % 10;
	thousandths = out % 10;
end



endmodule
