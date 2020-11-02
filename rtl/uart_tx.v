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
    //State machine registers and paramters
    parameter ST_IDLE =3'b000; //The system is idling and not driving any data
    parameter ST_INIT = 3'b001;
    parameter ST_TRANSMIT = 3'b010;

    reg [2:0] r_system_state;
    reg r_state_transition; //register to signal a state transition, goes high when counter == CYCLES_PER_BIT -1 for once clock
    initial r_system_state = ST_IDLE;


    reg [7:0] r_baud_counter; //counter to trigger state machine 
    reg [7:0] r_cycles_per_bit = CYCLES_PER_BIT[7:0]; //putting the cycles per bit parameter into a register for comparisons
    initial r_baud_counter = 0;


    // Timing generation for state machine
    always@(posedge i_clk) begin
        if(r_system_state == ST_IDLE)
            r_baud_counter <= 0; //Increment the counter
        else begin
            if(r_baud_counter != CYCLES_PER_BIT[7:0])
                r_baud_counter <= r_baud_counter + 1; //Increment the counter
            else
                r_baud_counter <= 0; // reset the counter on when the necessary clock cycles have passed
        end
    end

    assign o_tx_w = 1; // Remove this when you actually assign it
    
endmodule