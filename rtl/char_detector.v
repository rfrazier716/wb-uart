/*@Module
A Synchronous core to sample values on an arbitrary width data bus. The bus
width is set by ``BUS_WIDTH``. Bus data is latched on rising edges when
``i_data_latch`` is high. If the latched data matches ``SEARCH_KEY``, 
``o_char_in_buffer`` is driven high. 

:parameter BUS_WIDTH: Sets the width of the data bus. The width of 
    ``SEARCH_KEY`` must match the width of data bus. 
:parameter SEARCH_KEY: The character to search for. ``o_char_in_buffer`` goes 
    high when the most recently latched data is equal to ``SEARCH_KEY``. 

:input i_clk: Master clock for the system
:input i_reset: Synchronous Reset Signa. Sets the data buffer to 0x00
:input i_data_latch: When high, data on the data bus will be latched into an
    internal register

:output o_char_in_buffer: Driven high when the most recently latched data
    matches search key. 
:output o_char_rising: The rising edge of ``o_char_in_buffer`` 

*/

`default_nettype none //flags an error if you haven't defined a wire

module char_detector#(
    parameter BUS_WIDTH = 8,
    parameter[BUS_WIDTH-1:0] SEARCH_KEY = 8'h0D //The key being searched for
    )(
    input wire i_clk, //Clock line
    input wire i_reset, // Reset Signal
    input wire[BUS_WIDTH-1:0] i_data, //line for data
    input wire i_data_latch, //wire that when high, tells the shift register to latch the data
    output wire o_char_in_buffer, //line that is high when the two bytes in the fifo are a linefeed
    output wire o_char_rising //linefeed clock that goes high for one clock cycle when a linefeed is latched
);

reg [BUS_WIDTH-1:0] data_buffer; //single buffer that holds the most recently latched byte
initial data_buffer = 0; //initially the data_buffer is zero

always@(posedge i_clk) begin
    // clear the buffer on a reset
    if(i_reset)
        data_buffer <= 8'h00; 

    // if the data latch flag is high, shift the data into the SR and throw out the most recent byte
    else if(i_data_latch)
        data_buffer <= i_data; 
end

//Connect up an edge detector module so that the output of o_linefeed_rising is only high for one clock cycle
assign o_char_in_buffer = (data_buffer == SEARCH_KEY[BUS_WIDTH-1:0]); // char is in the buffer if the search key 

/* verilator lint_off PINMISSING */
edge_detector char_edge_detector(
    .i_clk(i_clk),
    .i_signal(o_char_in_buffer),
    .o_rising_w(o_char_rising)
    );
/* verilator lint_on PINMISSING */

endmodule