/*
an example core that echos any byte received on the RX bus and retransmits
*/

`default_nettype none //flags an error if you haven't defined a wire

module uart_echo#(
    parameter CYCLES_PER_BIT = 108
)(
    input wire i_clk, //top level clock for the module

    //wires for the UART buts
    input wire i_rx_w,
    output wire o_tx_w,
    output wire led_tx_busy, 
    output wire led_rx_busy
);

//wire that acts as an interrupt for when to read the UART
wire rx_fifo_byte_available;
wire rx_linefeed_availabile;

//State machine parameters for receiving a byte
localparam ST_RXREQUEST = 8'h0; //sending a read request to the UART
localparam ST_RXWAIT = 8'h1; // latching the reply
localparam ST_LATCHTX = 8'h2; //transmitting the latched data
localparam ST_IDLE = 8'h3; //idle state (default)

reg[7:0] system_state_r;
initial system_state_r = ST_IDLE;



//internal register settings for managing wishbone bus
reg[31:0] wb_data_out_r,
    wb_address_out_r;
	 
wire[31:0] wb_data_in_r;

reg wb_write_enable_out;
wire wb_strobe_out;

initial {wb_data_out_r,wb_address_out_r, wb_write_enable_out} = 0;


// State machine to read data off the UART and echo it back to the transmitter
always@(posedge i_clk) begin
    case(system_state_r)
        //send a read request to the uart core for register 11 
        ST_RXREQUEST: begin
            wb_address_out_r <= 32'h11; //send a read request of register 11
            wb_write_enable_out <= 0; //drive write enable low for a read
            system_state_r <= ST_RXWAIT; //next state is waiting for the reply to be available
        end
        //wait a cycle to get the read data
        ST_RXWAIT: begin
            system_state_r <= ST_LATCHTX;
        end
        //Latch and retransmit the data on the same clock
        ST_LATCHTX: begin
            wb_address_out_r <= 32'h12; //send a write request to the TX FIFO
            wb_data_out_r <= wb_data_in_r; //put the rx'd data onto the tx fifo
            wb_write_enable_out <= 1;
            // next state is either a read request or idle depending if there's still data
            // to read
            system_state_r <= (rx_fifo_byte_available) ? ST_RXREQUEST : ST_IDLE;
        end
        //if idle, stay in idle unless the interrupt wire is asserted, then read all the data off the fifo
        ST_IDLE: system_state_r <= (rx_fifo_byte_available) ? ST_RXREQUEST : ST_IDLE;
        default: begin end
    endcase
end

assign wb_strobe_out = (system_state_r == ST_IDLE) ? 0: 1'b1; //assert strobe whenever we're not idling



/* verilator lint_off PINMISSING*/
wb_uart#(8, CYCLES_PER_BIT) uart(
    //wishbone signals
    .i_clk(i_clk),
    .wb_data_in(wb_data_out_r), // remember to cross the TX/RX
    .wb_data_out(wb_data_in_r),
    .wb_addr_in(wb_address_out_r),
    .wb_write_enable_in(wb_write_enable_out),
    .wb_strobe_in(wb_strobe_out),

    //uart signals
    .i_rx_w(i_rx_w),
    .o_tx_w(o_tx_w),
    .led_tx_busy(led_tx_busy),
    .led_rx_busy(led_rx_busy),

    //Interrupt Signals
    .rx_fifo_byte_available(rx_fifo_byte_available),
    .rx_linefeed_available(rx_linefeed_availabile)

);
/* verilator lint_on PINMISSING*/



endmodule

