`timescale 1ns/1ns
module tb_spi();

parameter CYCLE = 100;

logic clk;
logic reset_n;
logic [15:0] data_rx;
logic [23:0] data_tx;
logic data_tx_valid;
logic sdo;
logic cs;
logic spc;
logic sdi;
logic done;
logic [15:0] test_read_data;

initial begin
	clk = 1;
	forever #(CYCLE/2) clk = ~clk;
end


initial begin
	data_tx_valid <= 0;
	reset_n <= 1;
	#(CYCLE);
	reset_n <= 0;
	#(CYCLE);
	reset_n <= 1;

	//WRITE
	data_tx <= {2'b00,6'h20,8'b10010111,8'h0000};
	data_tx_valid <= 1;
	#(CYCLE);
	data_tx_valid <= 0;

	while(!done) begin
		#(CYCLE);
	end
	#(5*CYCLE);

	//READ
	data_tx <= {2'b11,6'h28,16'hFFFF};
	data_tx_valid <= 1;
	#(CYCLE);
	data_tx_valid <= 0;

	while(!done) begin
		#(CYCLE);
	end
	

	$stop;
end


initial begin
	#(3*CYCLE);
	test_read_data <= 16'haaaa; 
	while(!data_tx[22]) begin
		#(CYCLE);
	end
	#(9*CYCLE + 0.5*CYCLE);
	for(int x = 15; x >= 0; x--) begin
		sdo <= test_read_data[x];
		#(CYCLE);	
	end

end





spi u0(
	.clk(clk),
	.reset_n(reset_n),
	.data_tx(data_tx),
	.data_tx_valid(data_tx_valid),
	.done(done),
	.data_rx(data_rx),
	.sdo(sdo),
	.cs(cs),
	.spc(spc),
	.sdi(sdi)
);



endmodule
