`timescale 1ns/1ns
module tb_accelerometer();

parameter CYCLE = 100;

logic clk;
logic reset_n;
logic sdo;
logic cs;
logic spc;
logic sdi;

logic [15:0] x;
logic [15:0] y;
logic [15:0] z;

logic [5:0] address;
logic rw;
logic ms;
logic [7:0] write_val;
logic [15:0] example_data;

initial begin
	clk = 1;
	forever #(CYCLE/2) clk = ~clk;
end

//SDO Control (Accelerometer sim)
initial begin
	reset_n <= 1;
	rw <= 0;
	example_data <= 16'habcd;
	#(CYCLE);
	reset_n <= 0;
	#(CYCLE);
	reset_n <= 1;
	#(CYCLE);

	for(int j = 0; j < 7; j++) begin
		while(cs == 1) begin
			#(CYCLE);
		end
		#(CYCLE);
		if(sdi == 0)
			rw <= 0; //write
		else
			rw <= 1; //read
		#(CYCLE);
		ms <= sdi;
		#(CYCLE);
		for(int i = 5; i >= 0; i--) begin
			address[i] <= sdi;
			if(!rw || (rw && i > 0))
				#(CYCLE);
		end
		//Write
		if(rw == 0) begin
			for(int i = 7; i >= 0; i--) begin
				write_val[i] <= sdi;
				#(CYCLE);
			end
			$display("%t: Wrote %h to address %h", $time, write_val, address);
		end
		//Read
		else begin
			while(!accelerometer0.done) begin
				#(CYCLE);
			end
			#(2*CYCLE);
			if((j-1)%3 == 0) begin
				example_data <= 16'h0001;
				$display("%t: Read %h from address %h into x", $time, x, address);
			end
			else if((j-1)%3 == 1) begin
				example_data <= 16'hFFFF;
				$display("%t: Read %h from address %h into y", $time, y, address);
			end
			else begin
				example_data <= 16'hAAAA;
				$display("%t: Read %h from address %h into z", $time, z, address);
			end
		end
		while(!cs) begin
			#(CYCLE);
		end
	end
	$stop;
end

initial begin
	#(5*CYCLE+0.5*CYCLE);
	while(1) begin
		while(cs) begin
			#(CYCLE);
		end
		#(CYCLE);
		if(rw) begin
			#(7*CYCLE);
			for(int x = 15; x >= 0; x--) begin
				sdo <= example_data[x];
				#(CYCLE);	
			end
			while(!cs) begin
				#(CYCLE);
			end
		end
			#(CYCLE);
	end
end

accelerometer accelerometer0(
	.clk(clk),
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
