`default_nettype none //flags an error if you haven't defined a wire


module wb_uart#(
    parameter DATA_BITS = 8,
    parameter CYCLES_PER_BIT = 108 //Gives a 460.8kBaud on a 50Mhz clock
)
(
    input wire i_clk,

    input wire i_rx_w,
    output wire o_tx_w, //UART bus output wire
    output wire led_tx_busy, led_rx_busy, //pins to tie to LEDs that get asserted when the UARTs are busy
    output wire rx_fifo_full, rx_fifo_byte_available
);

parameter FIFO_DEPTH = 8;



/*
Transmission Block
*/

wire tx_fifo_empty;
wire tx_fifo_full;
wire [DATA_BITS-1:0] tx_fifo_data_in_w, tx_fifo_data_out_w;
wire tx_fifo_write_w, tx_fifo_read_w;
wire uart_tx_write_w; //wire that drives when the UART should enter a write cycle


wire uart_tx_busy_w;
wire tx_busy_edge_w;

/* verilator lint_off PINMISSING */
edge_detector tx_busy_edge(
    .i_clk(i_clk),
    .i_signal(uart_tx_busy_w),
    .o_rising_w(tx_busy_edge_w)
);
/* verilator lint_on PINMISSING */

uart_tx#(DATA_BITS,CYCLES_PER_BIT) tx(
    .i_clk(i_clk),
    .i_data(tx_fifo_data_out_w),
    .i_write(uart_tx_write_w),
    .o_busy(uart_tx_busy_w),
    .o_tx_w(o_tx_w)
);

/* verilator lint_off PINMISSING */
fifo #(DATA_BITS, FIFO_DEPTH) tx_fifo(
    .i_clk(i_clk),
    .o_full_w(tx_fifo_full),
    .o_empty_w(tx_fifo_empty),
    .i_data_w(tx_fifo_data_in_w),
    .o_data_w(tx_fifo_data_out_w),
    .i_write_w(tx_fifo_write_w),
    .i_read_w(tx_busy_edge_w) //the read head is advanced whenever the fifo enters the busy state
);
/* verilator lint_on PINMISSING */

assign uart_tx_write_w = !tx_fifo_empty; //if the tx fifo is not empty the UART should be transmitting data
assign tx_fifo_data_in_w = 8'hA5;

/*
Receive Block 
*/
wire rx_fifo_full;
wire rx_fifo_empty;

wire uart_rx_busy_w;
wire rx_data_ready_w;
wire [DATA_BITS-1:0] rx_fifo_data_in_w, rx_fifo_data_out_w;

/* verilator lint_off PINMISSING */
fifo #(DATA_BITS, FIFO_DEPTH) rx_fifo(
    .i_clk(i_clk),
    .o_full_w(rx_fifo_full),
    .o_empty_w(rx_fifo_empty),
    .i_data_w(rx_fifo_data_in_w),
    .o_data_w(rx_fifo_data_out_w),
    .i_write_w(rx_data_ready_w),
    .i_read_w(tx_busy_edge_w) //the read head is advanced whenever the fifo enters the busy state
);


uart_rx #(DATA_BITS, FIFO_DEPTH) rx(
    .i_clk(i_clk),
    .i_rx_w(i_rx_w),
    .o_busy(uart_rx_busy_w),
    .o_data_ready_w(rx_data_ready_w),
    .o_data_w(rx_fifo_data_in_w)
);
/* verilator lint_on PINMISSING */


//Miscellaneous connections
assign led_tx_busy = uart_tx_busy_w;
assign led_rx_busy = uart_rx_busy_w;

endmodule;