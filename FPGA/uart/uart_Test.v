module uart_Test (
input CLOCK_50,
input UART_RXD,
input [0:9]SW,
output UART_TXD,
output [0:7]LEDG,
output [0:9]LEDR

);

wire clk;
wire rst;
wire [0:7]rx_byte;
wire [0:7]tx_byte;
wire transmit;
wire is_rx;
wire is_tx;
wire RxD_data_ready;
wire done_rx;

reg [0:7] send = 0;
reg [0:7] recv = 0;
reg tx_now;
reg reset;
reg [0:1] counter = 0;

assign transmit = tx_now;
assign clk = CLOCK_50;
assign rst = reset;
assign LEDR[1] = is_tx;
assign tx_byte = send;


async_transmitter uart_tx(
	clk,
	transmit,  // assert for one clock to transmit TxD_data[]
	tx_byte,  // we latch the TxD_data[] when "TxD_start" is asserte
          	// so that TxD_data[] doesn't have to stay valid while it is being transmitted
	UART_TXD,
	is_tx
);

async_receiver uart_rx(
	clk,
	UART_RXD,
	RxD_data_ready,
	rx_byte,  // data received, valid only (for one clock cycle) when RxD_data_ready is asserted

	// We also detect if a gap occurs in the received stream of characters
	// That can be useful if multiple characters are sent in burst
	//  so that multiple characters can be treated as a "packet"
	is_rx,  // asserted when no data has been received for a while
	done_rx  // asserted for one clock cycle when a packet has been detected (i.e. RxD_idle is going high)
);

always @(posedge CLOCK_50) begin

	case (counter)
	
		0: begin
				if (RxD_data_ready) begin
					send <= rx_byte;
					tx_now <= 1;
					counter <= counter + 1;
				end
		end
		
		1: begin
			if (is_tx) begin
				tx_now <= 0;
				counter <= counter + 1;
			end
		end
		
		2: begin
			counter <= 0;
		end
		
		default: begin
			counter <= 0;
		end
	endcase

end
endmodule
