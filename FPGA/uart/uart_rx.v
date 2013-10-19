module uart_rx(clk, reset, data, rx_d);

parameter IDLE=0;
parameter RXING=1;

input clk, reset;
input rx_d;

output [7:0] data;

reg shift;
reg [1:0] state, nextstate;
reg [3:0] bitcounter;
reg [3:0] samplecounter;
reg [12:0] counter;
reg [10:0] rxshiftreg;
reg clear_bitcounter,inc_bitcounter,inc_samplecounter,clear_samplecounter;

assign data = rxshiftreg[8:1];

always @(posedge clk) begin
	if (reset) begin
		state <= IDLE;
		bitcounter <= 0; counter <= 0;
		samplecounter <= 0;
	end

	else begin
		counter <= counter + 1;
		if (counter >= 145) begin
			counter <= 0;
			state <= nextstate;
			if (shift) rxshiftreg <= {rx_d,rxshiftreg[10:1]};
			if (clear_samplecounter) samplecounter <= 0;
			else if (inc_samplecounter) samplecounter <= samplecounter + 1;
			if (clear_bitcounter)bitcounter<=0;
			if (inc_bitcounter)bitcounter<=bitcounter+1;
		end
	end
end

always @(state or rx_d or bitcounter or samplecounter) begin
	shift = 0;
	clear_samplecounter=0;
	inc_samplecounter=0;
	clear_bitcounter=0;
	inc_bitcounter=0;

	case (state)

		IDLE: begin
			if (rx_d)
				nextstate=IDLE;
			else begin
				nextstate=RXING;
				clear_bitcounter=1;
				clear_samplecounter=1;
			end
		end
		RXING: begin
			if (samplecounter==1)shift=1;
			if (samplecounter==3) begin
				if (bitcounter==10) begin
					nextstate=IDLE;
				end
				inc_bitcounter=1;
				clear_samplecounter=1;
			end
			else inc_samplecounter=1;
		end
	endcase
end

endmodule
