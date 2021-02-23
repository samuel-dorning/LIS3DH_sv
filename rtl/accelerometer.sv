module accelerometer(
	input logic clk,
	input logic reset_n,
	input logic sdo,

	output logic [15:0] x,
	output logic [15:0] y,
	output logic [15:0] z,
	output logic cs,
	output logic spc,
	output logic sdi

);

logic [23:0] data_tx;
logic [4:0] counter;

logic data_tx_valid;
logic done;
logic [15:0] data_rx;

enum logic [3:0]{
	INIT	= 4'b0000,	
	RD_X	= 4'b0001,
	STO_X 	= 4'b0010,
	RD_Y	= 4'b0011,
	STO_Y 	= 4'b0100,
	RD_Z	= 4'b0101,
	STO_Z 	= 4'b0110,
	WRITE	= 4'b0111,
	WAIT	= 4'b1000
} ps, ns;

always_ff @ (posedge clk) begin
	if(ps == INIT)
		counter <= 0;
	else if(ps == WRITE) begin
		data_tx <= {2'b00,6'h20,8'b10010111,8'hFFFF};
		if(counter == 0)
			data_tx_valid <= 1;
		else
			data_tx_valid <= 0;
		counter <= counter + 1;
	end
	else if(ps == WAIT) begin
		counter <= 0;
	end
	else if(ps == RD_X) begin
		if(counter == 0)
			data_tx_valid <= 1;
		else
			data_tx_valid <= 0;
		data_tx <= {2'b11,6'h28,16'hFFFF};
		counter <= counter + 1;
	end
	else if(ps == STO_X) begin
		x <= {data_rx[7:0],data_rx[15:8]};
		counter <= 0;
	end
	else if(ps == RD_Y) begin
		if(counter == 0)
			data_tx_valid <= 1;
		else
			data_tx_valid <= 0;
		data_tx <= {2'b11,6'h2A,16'hFFFF};
		counter <= counter + 1;
	end
	else if(ps == STO_Y) begin
		y <= {data_rx[7:0],data_rx[15:8]};
		counter <= 0;
	end
	else if(ps == RD_Z) begin
		if(counter == 0)
			data_tx_valid <= 1;
		else
			data_tx_valid <= 0;
		data_tx <= {2'b11,6'h2C,16'hFFFF};
		counter <= counter + 1;
	end
	else if(ps == STO_Z) begin
		z <= {data_rx[7:0],data_rx[15:8]};
		counter <= 0;
	end
end

always_comb begin
	case(ps)
		INIT:
			ns = WRITE;
		WRITE:	
			if(done)
				ns = WAIT;
			else
				ns = WRITE;
		WAIT:
			if(cs)	
				ns = RD_X;
			else
				ns = WAIT;
        RD_X:	
			if(done)
				ns = STO_X;
			else
				ns = RD_X;
        STO_X: 
			ns = RD_Y;
        RD_Y:	
			if(done)
				ns = STO_Y;
			else
				ns = RD_Y;
        STO_Y: 
			ns = RD_Z;
        RD_Z:	
			if(done)
				ns = STO_Z;
			else
				ns = RD_Z;
        STO_Z: 
			ns = RD_X;
	endcase
end

always_ff @ (posedge clk, negedge reset_n) begin
	if(!reset_n)
		ps <= INIT;
	else
		ps <= ns;
end

spi spi0(
	.clk(clk),
	.reset_n(reset_n),
	.data_rx(data_rx),
	.data_tx(data_tx),
	.data_tx_valid(data_tx_valid),
	.done(done),
	.sdo(sdo),
	.cs(cs),
	.spc(spc),
	.sdi(sdi)
);



endmodule
