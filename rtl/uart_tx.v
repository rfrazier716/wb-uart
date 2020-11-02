`default_nettype none //flags an error if you haven't defined a wire

module uart_tx#(  
    parameter CLOCK_RATE = 50000000, // System Clock frequency
    parameter BAUD_RATE = 9600, // the Baud Rate of the system
    parameter DATA_BITS = 8,  // How many data bits there are per cycle 
    parameter CYCLES_PER_BIT = (CLOCK_RATE / BAUD_RATE) -1// How many clock ticks in before each data bit
)
(
    input wire i_clk, //System Clock
    input wire [DATA_BITS-1:0] i_data, // the data that will be latched and transmitted
    input wire i_write, //input signal to request a data write out 
    output wire o_busy, //signal that gets asserted when the state machine is running
    output reg o_tx_w
);
    reg[DATA_BITS-1:0] data_r; // data register to be transmitted
    reg[DATA_BITS-1:0] data_mask_r; //a mask that controls which data bit is transmitted 
    initial data_r = 0; // initialize the data register to be zero
    initial data_mask_r = 8'h01; //transmit the LSB first

    //State machine registers and paramters
    parameter ST_IDLE =4'b0000; //The system is idling and not driving any data
    parameter ST_INIT = 4'b0001; //setup for transmition, Drive the line low
    parameter ST_TRANSMIT = 4'b0010; //Transmit data, this state is used for all 8 bits
    parameter ST_PARITY = 4'b0011; //Parity bit, is an XOR of the data register for even parity
    parameter ST_END = 4'b0100; // End Transmissin, turn clock high

    reg [3:0] system_state_r;
    reg [3:0] next_state_r;
    wire state_transition_w; //register to signal a state transition, goes high when counter == CYCLES_PER_BIT -1 for once clock
    initial system_state_r = ST_IDLE;
    initial next_state_r = ST_IDLE;



    reg [7:0] baud_counter_r; //counter to trigger state machine 
    initial baud_counter_r = 0;

    //State Machine to drive the UART transmitter
    always@(posedge i_clk) begin

        //If we get a write request and are not currently processing a request, kick off state machine
        if((i_write == 1'b1) && !o_busy) begin
            data_r<=i_data; //Latch the input data wire to the internal data wire
            system_state_r <= ST_INIT; //advance to the next state
        end

        case(system_state_r)
            ST_IDLE: begin
                o_tx_w <= 1; // When idling the output line should be driven high
                next_state_r <= ST_IDLE; //
            end
            ST_INIT: begin
                o_tx_w <= 0; //During initialization drive the output low
                data_mask_r <= 8'h01;
                next_state_r <= ST_TRANSMIT;
            end
            ST_TRANSMIT: begin
                o_tx_w <= |(data_r & data_mask_r); // 
                next_state_r <= ST_PARITY;
            end
            ST_PARITY:  begin
                o_tx_w <= ^data_r; //Transmit even parity
                next_state_r <= ST_END;
            end
            ST_END: begin
                o_tx_w <= 1;
                next_state_r <= ST_IDLE;
            end
            default: o_tx_w <= 1; //Default case should drive the tx wire high
        endcase
    end


    // Timing generation for state machine
    always@(posedge i_clk) begin
        if(system_state_r == ST_IDLE)
            baud_counter_r <= 0; //Increment the counter
        else begin
            if(baud_counter_r != CYCLES_PER_BIT[7:0])
                baud_counter_r <= baud_counter_r + 1; //Increment the counter
            else
                baud_counter_r <= 0; // reset the counter on when the necessary clock cycles have passed
        end
    end

    assign o_busy = system_state_r == ST_IDLE? 0:1; //the busy wire should be driven high whenever we're not in the idle state
    assign state_transition_w = baud_counter_r == CYCLES_PER_BIT[7:0] ? 1:0; // wire for triggering state transition
    assign o_tx_w = 1; // Remove this when you actually assign it

endmodule