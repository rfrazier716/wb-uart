`default_nettype none //flags an error if you haven't defined a wire


module wb_uart#(
    parameter DATA_BITS = 8,
    parameter CYCLES_PER_BIT = 108 //Gives a 460.8kBaud on a 50Mhz clock
)
(
    input wire i_clk,
    
    //Wishbone Bus interface
    input wire[31:0] wb_addr_in,
    input wire[31:0] wb_data_in,
    output wire[31:0] wb_data_out,
    input wire wb_write_enable_in,
        wb_strobe_in,
    output reg wb_acknowledge_out,


    //UART interface 
    input wire i_rx_w,
    output wire o_tx_w, //UART bus output wire
    output wire led_tx_busy, led_rx_busy, //pins to tie to LEDs that get asserted when the UARTs are busy
    output wire rx_fifo_full, rx_fifo_byte_available
);

parameter FIFO_DEPTH = 8;

///////////////////////////////////////////////////////
// Wishbone Block
///////////////////////////////////////////////////////

/*
Wishbone bus should have the following commands
READ COMMANDS
---------------
- Read the next available byte off the RX FIFO
- Read the number of bytes currently stored in the FIFO (read only)

WRITE COMMANDS
---------------
- Write a byte to the TX FIFO - should have same address as read byte
- Reset the system

ADDRESSES
----------
0x0000 -- Reserved, will be used to configure UART in future
0x0001 -- RX Fifo Status, how many bytes are currently on the read fifo
0x0002 -- TX Fifo Status, how many bytes are currently on the write fifo
0x0011 -- Read data -- Reads a byte off the fifo and advances the read head
0x0012 -- Write data -- write only register that pushes data onto the TX Fifo
*/

reg[31:0] wb_data_out_r; //register for holding data to be put on the data bus

//state machine for the wishbone system
always@(posedge i_clk) begin
    //TODO: Modify this to work with Block reads where the device can be busy
    wb_acknowledge_out <= wb_strobe_in; // for now the acknowledge bit is just a single cycle delay of strobe
    tx_fifo_write_r <= 0; // By default drive this register to zero
    rx_fifo_read_r <= 0;

    //Handling Write requests
    if(wb_strobe_in && wb_write_enable_in) begin
        case(wb_addr_in)
            32'h0: begin end
            // case to handle a byte write to the FIFO
            32'h12: begin
                tx_fifo_data_in_r <= wb_data_in[DATA_BITS-1:0]; //put data onto the data_in register
                tx_fifo_write_r <= 1; // put the write head high for one cycle
            end
            default: begin end // default case is do nothing
        endcase
    end

    //Handling Read Requests
    if(wb_strobe_in && !wb_write_enable_in) begin
        case(wb_addr_in)
            32'h0: begin end // placeholder for when you can configure bus
            32'h1: wb_data_out_r <= {{(32-FIFO_DEPTH){1'b0}}, rx_fifo_fill_w};
            32'h2: wb_data_out_r <= {{(32-FIFO_DEPTH){1'b0}}, tx_fifo_fill_w};
            // when reading pop a byte off the rx fifo and advance the read head
            32'h11: begin
                wb_data_out_r <= {{(32-DATA_BITS){1'b0}}, rx_fifo_data_out_w};
                rx_fifo_read_r <= 1; // advance the rx fifo read head
            end
            32'h12: wb_data_out_r <= 32'b0; //if trying to read from the TX register return zero
        endcase
    end
end


//TODO: Fix this so multiple items can be on the bus
assign wb_data_out = wb_data_out_r; 


///////////////////////////////////////////////////////
// Transmission Block
///////////////////////////////////////////////////////

wire tx_fifo_empty;
wire tx_fifo_full;
reg [DATA_BITS-1:0] tx_fifo_data_in_r;
wire [DATA_BITS-1:0] tx_fifo_data_out_w;
reg tx_fifo_write_r;
wire tx_fifo_read_w;
wire uart_tx_write_w; //wire that drives when the UART should enter a write cycle
wire [FIFO_DEPTH-1:0] tx_fifo_fill_w; // how many bytes on the fifo hold data


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
    .i_data_w(tx_fifo_data_in_r),
    .o_data_w(tx_fifo_data_out_w),
    .i_write_w(tx_fifo_write_r),
    .i_read_w(tx_busy_edge_w), //the read head is advanced whenever the fifo enters the busy state
    .o_fill_bytes_w(tx_fifo_fill_w)
);
/* verilator lint_on PINMISSING */

assign uart_tx_write_w = !tx_fifo_empty; //if the tx fifo is not empty the UART should be transmitting data

///////////////////////////////////////////////////////
// Recieve Block
///////////////////////////////////////////////////////

wire rx_fifo_empty;
reg rx_fifo_read_r;

wire uart_rx_busy_w;
wire rx_data_ready_w;
wire [DATA_BITS-1:0] rx_fifo_data_in_w, rx_fifo_data_out_w;
wire [FIFO_DEPTH-1:0] rx_fifo_fill_w; // how many bytes on the fifo hold data

/* verilator lint_off PINMISSING */
fifo #(DATA_BITS, FIFO_DEPTH) rx_fifo(
    .i_clk(i_clk),
    .o_full_w(rx_fifo_full),
    .o_empty_w(rx_fifo_empty),
    .i_data_w(rx_fifo_data_in_w),
    .o_data_w(rx_fifo_data_out_w),
    .i_write_w(rx_data_ready_w),
    .i_read_w(rx_fifo_read_r),
    .o_fill_bytes_w(rx_fifo_fill_w)
);
/* verilator lint_on PINMISSING */

/* verilator lint_off PINMISSING */
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
assign rx_fifo_byte_available = !rx_fifo_empty; //If the fifo is not empty there's a byte available to be read

endmodule;