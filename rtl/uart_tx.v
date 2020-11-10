`default_nettype none //flags an error if you haven't defined a wire

module uart_tx#(  
    parameter CLOCK_RATE = 50000000, // System Clock frequency
    parameter BAUD_RATE = 9600, // the Baud Rate of the system
    parameter DATA_BITS = 8,  // How many data bits there are per cycle 
    parameter CYCLES_PER_BIT = (CLOCK_RATE / BAUD_RATE)// How many clock ticks in before each data bit
)
(
    input wire i_clk, //System Clock
    input wire [DATA_BITS-1:0] i_data, // the data that will be latched and transmitted
    input wire i_write, //input signal to request a data write out 
    output wire o_busy, //signal that gets asserted when the state machine is running
    output reg o_tx_w
);
    reg[DATA_BITS-1:0] data_r; // data register to be transmitted
    initial data_r = 0; // initialize the data register to be zero

    //State machine registers and paramters
    parameter ST_TRANSMIT_B0 = 4'b0000; //Transmit data, bit 0
    parameter ST_TRANSMIT_B1 = 4'b0001; //Transmit data, bit 1
    parameter ST_TRANSMIT_B2 = 4'b0010; //Transmit data, bit 2
    parameter ST_TRANSMIT_B3 = 4'b0011; //Transmit data, bit 3
    parameter ST_TRANSMIT_B4 = 4'b0100; //Transmit data, bit 4
    parameter ST_TRANSMIT_B5 = 4'b0101; //Transmit data, bit 5
    parameter ST_TRANSMIT_B6 = 4'b0110; //Transmit data, bit 6
    parameter ST_TRANSMIT_B7 = 4'b0111; //Transmit data, bit 7
    parameter ST_DEADZONE = 4'b1000; // This state should never be touched, is used for formal verification
    parameter ST_PARITY = 4'b1001; //Parity bit, is an XOR of the data register for even parity
    parameter ST_STOP = 4'b 1010;
    parameter ST_IDLE = 4'b1011;
    parameter ST_INIT = 4'b1100;

    reg [3:0] system_state_r;
    reg [3:0] next_state_r;
    wire state_transition_w; //register to signal a state transition, goes high when counter == CYCLES_PER_BIT -1 for once clock
    initial system_state_r = ST_IDLE;
    initial next_state_r = ST_IDLE;
    initial o_tx_w = 1; //By default initialize wire to high



    reg [7:0] baud_counter_r; //counter to trigger state machine 
    initial baud_counter_r = 0;

    //State Machine to drive the UART transmitter
    always@(posedge i_clk) begin

        //If the state transition wire is high, switch to the next state
        if(state_transition_w)
            system_state_r <= next_state_r;

        //If we get a write request and are not currently processing a request, kick off state machine
        if((i_write == 1'b1) && !o_busy) begin
            data_r<=i_data; //Latch the input data wire to the internal data wire
            system_state_r <= ST_INIT; //advance to the next state
        end

        case(system_state_r)
            // Whenever the part is not driving data it should be in the idle state, which drives the line high
            ST_IDLE: begin
                o_tx_w <= 1;
                next_state_r <= ST_IDLE;
            end

            //Initialization state - Drive the output low
            ST_INIT: begin
                o_tx_w <= 0;
                next_state_r <= ST_TRANSMIT_B0;
            end

            //When Transmitting the 7th bit, the next transmission should be to the stop bit
            ST_TRANSMIT_B7: begin
                o_tx_w <= data_r[system_state_r[2:0]];
                next_state_r <= ST_STOP;
            end

            // Parity bit is being skipped right now
            ST_PARITY:  begin
                o_tx_w <= ^data_r; //Transmit even parity
                next_state_r <= ST_STOP;
            end

            // Stop bit should hold the data line high for one clock cycle -- we might be able to skip this? 
            ST_STOP: begin
                o_tx_w <= 1; 
                next_state_r <= ST_IDLE;
            end

            // The default case is any of the transmitting states, in which case the respective data bit is transmitted
            default: begin
                //in the default case we're transmitting data
                o_tx_w <= data_r[system_state_r[2:0]];
                next_state_r <= system_state_r+1;
            end
        endcase
    end


    // Timing generation for state machine
    always@(posedge i_clk) begin
        if(system_state_r == ST_IDLE)
            baud_counter_r <= CYCLES_PER_BIT[7:0]-1; //Don't increment counter when idling
        else begin
            if(baud_counter_r != 0)
                baud_counter_r <= baud_counter_r - 1; //Decrement the counter
            else
                baud_counter_r <= CYCLES_PER_BIT[7:0]-1; // reset the counter on when the necessary clock cycles have passed
        end
    end

    assign o_busy = system_state_r == ST_IDLE? 0:1; //the busy wire should be driven high whenever we're not in the idle state
    assign state_transition_w = baud_counter_r == 0 ? 1:0; // wire for triggering state transition


// Formal Verification Block -- maybe delete? 
`ifdef FORMAL
    always@(*)
        assume(reset!=0)
    always@(*) 
        assert(o_busy != (system_state_r==ST_IDLE)); //We should never be busy while idling
    
    //Verifying invalid states are never accessed
    always@(*) begin
        assert(system_state_r <= ST_IDLE); //Idle is the highest state, and the state register should never exceed it
        assert(system_state_r != ST_DEADZONE); //This makes sure that the state incrementer

        // when transmiting data the states should always increment by one
        if(system_state_r >ST_TRANSMIT_B0 && system_state_r <= ST_TRANSMIT_B7)
            assert(system_state_r == $past(system_state_r,1)+1)
    end
`endif

endmodule