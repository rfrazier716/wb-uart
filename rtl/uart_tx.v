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
    output wire o_tx_w
);
    reg[DATA_BITS-1:0] data_r; // data register to be transmitted
    initial data_r = 0; // initialize the data register to be zero

    //State machine registers and paramters
    parameter ST_IDLE =3'b000; //The system is idling and not driving any data
    parameter ST_INIT = 3'b001;
    parameter ST_TRANSMIT = 3'b010;

    reg [2:0] system_state_r;
    wire state_transition_w; //register to signal a state transition, goes high when counter == CYCLES_PER_BIT -1 for once clock
    initial system_state_r = ST_IDLE;


    reg [7:0] baud_counter_r; //counter to trigger state machine 
    initial baud_counter_r = 0;

    //State Machine to drive the UART transmitter
    always@(posedge i_clk) begin
        if((i_write == 1'b1) && !o_busy) begin
            //If we get a write request and are not currently processing a request, kick off state machine
            data_r<=i_data; //Latch the input data wire to the internal data wire
            system_state_r <= ST_INIT; //advance to the next state
        end

        // All states but idle can only transition on 
        // unless we're idling, only advance states when the state_transition wire is driven high
        case(system_state_r)
        
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