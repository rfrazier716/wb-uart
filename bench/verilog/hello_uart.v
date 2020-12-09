/*
an example character that transmits a single character once per second over the UART
*/

`default_nettype none //flags an error if you haven't defined a wire


module hello_uart#(
    parameter COUNTER_VALUE = 50000000,
    parameter CYCLES_PER_BIT = 108
)(
    input wire i_clk, //top level clock for the module

    //wires for the UART buts
    input wire i_rx_w,
    output wire o_tx_w,
    output wire led_tx_busy, 
    output wire led_rx_busy
);

parameter TX_BYTE = 32'h41; // the byte that we'll transmit

reg [31:0] idle_counter_r; // a counter that triggers a write at zero
initial idle_counter_r = COUNTER_VALUE[31:0]; //initialize to the counter

reg [31:0] wb_data_out_r,   // wishbone data out register
    wb_address_out_r;       // wishbone address out register

wire wb_write_enable_out;    //wire to assert a write enable
reg wb_strobe_out;          //wire to select which device to talk to

/* verilator lint_off PINMISSING*/
wb_uart#(8, CYCLES_PER_BIT) uart(
    //wishbone signals
    .i_clk(i_clk),
    .wb_data_in(wb_data_out_r),
    .wb_addr_in(wb_address_out_r),
    .wb_write_enable_in(wb_write_enable_out),
    .wb_strobe_in(wb_strobe_out),

    //uart signals
    .i_rx_w(i_rx_w),
    .o_tx_w(o_tx_w),
    .led_tx_busy(led_tx_busy),
    .led_rx_busy(led_rx_busy)
);
/* verilator lint_on PINMISSING*/

always@(posedge i_clk) begin
    wb_strobe_out <= 0; //don't assert the strobe unless it's an underflow
    if(idle_counter_r == 0) begin
        wb_data_out_r <= TX_BYTE; //put the byte on the address bus
        wb_address_out_r <= 32'h12; //The address to write to
        wb_strobe_out <= 1'b1; //put the strobe signal high
    end
end

// Timing generation for state machine
always@(posedge i_clk) begin
    if(idle_counter_r != 0)
        idle_counter_r <= idle_counter_r - 1; //Decrement the counter
    else
        idle_counter_r <= COUNTER_VALUE[31:0]-1; // reset the counter on when the necessary clock cycles have passed
end

assign wb_write_enable_out = 1'b1; // always drive write enable high for this example

endmodule


