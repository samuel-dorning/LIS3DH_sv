module spi(
	input logic clk,
	input logic reset_n,

	input logic rd,
	input logic wr,

	input logic [5:0] addr,
	input logic [7:0] data_tx,

	input logic sdo,
	
	output logic [15:0] data_rx,
	output logic cs,
	output logic spc,
	output logic sdi
);

logic clk_en;
logic [2:0] i;
logic [3:0] j;
logic [4:0] k;
logic mode;

enum logic [2:0]{
	INIT		= 3'b000,
	START		= 3'b001,
	SEND_ADDR	= 3'b010,
	SEND_DATA	= 3'b011,
	RCV_DATA	= 3'b100,
	INC			= 3'b101,
	CS_INIT		= 3'b110
} ps, ns;


always_ff @ (posedge clk) begin
	if(ps == INIT) begin
		cs <= 1;
		clk_en <= 0;
		i <= 5;
		j <= 7;
		k <= 16;
		if(wr)
			mode <= 1;
		else
			mode <= 0;
	end
	else if(ps == CS_INIT) begin
		cs <= 0;
	end
	else if(ps == START) begin
		clk_en <= 1;
		if(mode) 
			sdi <= 0;
		else
			sdi <= 1;
	end
	else if(ps == INC) begin
		if(mode)
			sdi <= 0;
		else
			sdi <= 1;
	end
	else if(ps == SEND_ADDR) begin
		sdi <= addr[i];
		i <= i - 1;
	end
	else if(ps == SEND_DATA) begin
		sdi <= data_tx[j];
		j <= j - 1;
	end
	else if(ps == RCV_DATA) begin
		data_rx[k] <= sdo;
		k <= k - 1;
		if(k == 0) begin
			cs <= 1;
			clk_en <= 0;
		end
	end
end


always_comb begin
	if(clk_en)
		spc = clk;
	else
		spc = 1;
end

always_comb begin
	case(ps)
		INIT:
			if(rd | wr)
				ns = CS_INIT;
			else
				ns = INIT;
		CS_INIT:
			ns = START;
		START:
			ns = INC;
		INC:
			ns = SEND_ADDR;
		SEND_ADDR:
			if(!mode && i == 0)
				ns = RCV_DATA;
			else if(mode && i == 0)
				ns = SEND_DATA;
			else
				ns = SEND_ADDR;
		SEND_DATA:
			if(j > 0)
				ns = SEND_DATA;
			else
				ns = INIT;
		RCV_DATA:
			if(k > 0)
				ns = RCV_DATA;
			else 
				ns = INIT;
	endcase
end


always_ff @ (posedge clk, negedge reset_n) begin
	if(!reset_n)
		ps <= INIT;
	else
		ps <= ns;
end

endmodule
