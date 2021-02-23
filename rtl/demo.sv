module top(
input logic clk,
input logic reset_n,

input logic sdo,

output logic spc,
output logic sdi,
output logic cs,

output logic [6:0] d0,
output logic [6:0] d1,
output logic [6:0] d2,
output logic [6:0] d3,
output logic sign
);

wire accel_clk;
logic pll_rst;

logic signed [15:0] x;
logic signed [15:0] y;
logic signed [15:0] z;

logic [3:0] ones;
logic [3:0] tenths;
logic [3:0] hundredths;
logic [3:0] thousandths;

logic [15:0] out;
logic [9:0] num;



assign sign = ~x[15];

always_comb begin
	if(x[15])
		num = ((~x[15:6]) + 1);
	else
		num = x[15:6];
	out = num*4;
	ones = (out/1000) % 10;
	tenths = (out/100) % 10;
	hundredths = (out/10) % 10;
	thousandths = out % 10;
end

SEG_HEX hex0( 
		.iDIG(thousandths),							
		.oHEX_D(d0)		
	);
SEG_HEX hex1( 
		.iDIG(hundredths),							
		.oHEX_D(d1)		
	);
SEG_HEX hex2( 
		.iDIG(tenths),							
		.oHEX_D(d2)		
	);
SEG_HEX hex3( 
		.iDIG(ones),							
		.oHEX_D(d3)		
	);
	

	/*
SEG_HEX hex0( 
		.iDIG(x[3:0]),							
		.oHEX_D(d0)		
	);
SEG_HEX hex1( 
		.iDIG(x[7:4]),							
		.oHEX_D(d1)		
	);
SEG_HEX hex2( 
		.iDIG(x[11:8]),
		.oHEX_D(d2)		
	);
SEG_HEX hex3( 
		.iDIG(x[15:12]),							
		.oHEX_D(d3)		
	);
	*/	
	
assign pll_rst = ~reset_n;

pll pll0(
		.refclk(clk),   //  refclk.clk
		.rst(pll_rst),      //   reset.reset
		.outclk_0(accel_clk), // outclk0.clk
		.locked()    //  locked.export
);


accelerometer accelerometer0(
	.clk(accel_clk),
	.reset_n(reset_n),
	.sdo(sdo),
	.x(x),
	.y(y),
	.z(z),
	.cs(cs),
	.spc(spc),
	.sdi(sdi)

);


endmodule