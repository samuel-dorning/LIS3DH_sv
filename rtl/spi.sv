module spi(
	input logic clk, //10MHz clk
	input logic reset_n,

	input logic [23:0] data_tx, //data to transmit to LIS3DH
	input logic data_tx_valid,	//data in data_tx is valid

	input logic sdo,	//data from LIS3DH

	output logic done,	//Rx/Tx is complete
	output logic [15:0] data_rx, //Data received from LIS3DH
	output logic cs,	//Active low chip enable
	output logic spc,	//10MHz SPI clk
	output logic sdi	//data to LIS3DH
);

logic clk_en;
logic [4:0] i;
logic [4:0] j;
logic [23:0] data;

enum logic [2:0]{
	INIT		= 3'b000,
	START		= 3'b001,
	SEND_DATA	= 3'b010,
	WAIT		= 3'b011
} ps, ns;

enum logic [2:0]{
	READ_INIT	= 3'b000,
	READ_START	= 3'b001,
	READ_WAIT	= 3'b010,
	RCV_DATA	= 3'b011
} rps, rns;

//WRITE DATA LOGIC:

always_ff @ (negedge clk) begin
	if(ps == INIT) begin
		clk_en <= 0;
		cs <= 1;
		sdi <= 1;
		i <= 23;
		done <= 0;
	end
	else if(ps == START) begin
		cs <= 0;
		data <= data_tx;
	end
	else if(ps == SEND_DATA) begin
		clk_en <= 1;
		sdi <= data[i];
		i <= i - 1;
	end
	else if(ps == WAIT) begin
		clk_en <= 0;
		done <= 1;
	end
end


assign spc = ~(~clk & clk_en);

always_comb begin
	case(ps)
		INIT: 
			if(data_tx_valid)
				ns = START;
			else
				ns = INIT;
		START:
			ns = SEND_DATA;
		SEND_DATA:
			if((data[22] && i == 0) || (!data[22] && i == 8)) 
				ns = WAIT;
			else
				ns = SEND_DATA;
		WAIT:
			ns = INIT;
	endcase
end


always_ff @ (negedge clk, negedge reset_n) begin
	if(!reset_n)
		ps <= INIT;
	else
		ps <= ns;
end






//RECEIVE DATA LOGIC:






always_ff @ (posedge clk) begin
	if(rps == READ_WAIT) begin
		j <= 15;
	end
	else if(rps == RCV_DATA) begin
		data_rx[j] <= sdo;
		j <= j - 1;
	end
end



always_comb begin
	case(rps)
		READ_INIT:
			if(data_tx_valid)
				rns = READ_START;
			else
				rns = READ_INIT;
		READ_START:
			if(data[22])
				rns = READ_WAIT;
			else
				rns = READ_INIT;
		READ_WAIT:
			if(i == 15)
				rns = RCV_DATA;
			else
				rns = READ_WAIT;
		RCV_DATA:
			if(j == 0)
				rns = READ_INIT;
			else
				rns = RCV_DATA;
	endcase
end








always_ff @ (posedge clk, negedge reset_n) begin
	if(!reset_n)
		rps <= READ_INIT;
	else
		rps <= rns;
end







endmodule
