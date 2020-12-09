`default_nettype none //flags an error if you haven't defined a wire

module uart_rx#(  
    parameter DATA_BITS = 8,  // How many data bits there are per cycle 
    parameter CYCLES_PER_BIT = 108// How many clock ticks in before each data bit -- translates to 460.8kBaud on 50Mhz clock
)
(
    input wire i_clk, //System Clock
    input wire i_rx_w, // the data that will be latched and transmitted
    output wire o_busy, //signal that's asserted when the state machine is not in idle
    output reg o_data_ready_w, //signal that's asserted when new data has been latched to the data register (only one for one clock cycle)
    output wire[DATA_BITS-1:0] o_data_w //the most recently recieved complete data byte
);
    reg[DATA_BITS-1:0] data_r; // Data that was recieved
    reg[DATA_BITS-1:0] rx_data_r; //Register that gets written to as data comes in
    initial {data_r,rx_data_r} = 0; // initialize the data register to be zero

    //State machine registers and paramters
    parameter ST_RECIEVE_B0 = 4'b0000; //Receive data, bit 0
    parameter ST_RECIEVE_B1 = 4'b0001; //Receive data, bit 1
    parameter ST_RECIEVE_B2 = 4'b0010; //Receive data, bit 2
    parameter ST_RECIEVE_B3 = 4'b0011; //Receive data, bit 3
    parameter ST_RECIEVE_B4 = 4'b0100; //Receive data, bit 4
    parameter ST_RECIEVE_B5 = 4'b0101; //Receive data, bit 5
    parameter ST_RECIEVE_B6 = 4'b0110; //Receive data, bit 6
    parameter ST_RECIEVE_B7 = 4'b0111; //Receive data, bit 7
    parameter ST_LATCH = 4'b1001;
    parameter ST_IDLE = 4'b1010;
    parameter ST_INIT = 4'b1011;

    reg [3:0] system_state_r;
    reg [3:0] next_state_r;
    initial system_state_r = ST_IDLE;
    initial next_state_r = ST_IDLE;

    reg [7:0] baud_counter_r; //counter to trigger state machine 
    //initialize baud counter to the idle value
    initial baud_counter_r =  CYCLES_PER_BIT[7:0]+(CYCLES_PER_BIT[7:0]>>1)-1'b1;

    //State Machine to drive the UART transmitter
    always@(posedge i_clk) begin
        o_data_ready_w <= 0; // By default data ready should be low, and only high for one clock cycle

        //If the counter has zero'd out, increment to the next state
        //Because of how the counter is initialized at first, these transitions should happen
        //in the middle of a data clock 
        if(baud_counter_r == 0) begin
            system_state_r <= next_state_r;
            //If we're in a state that requires sampling latch the data into the register
            if(!next_state_r[3])
                rx_data_r[next_state_r[2:0]]<=i_rx_w;
        end

        //If the rx line goes low and we're not processing a request, kick off state machine
        if((i_rx_w == 1'b0) && !o_busy) begin
            system_state_r <= ST_INIT; //advance to the next state
        end

        //Case statement that controls the next state based on current state
        case(system_state_r)
            ST_IDLE: next_state_r <= ST_IDLE;
            ST_INIT: next_state_r <= ST_RECIEVE_B0;
            ST_RECIEVE_B7: next_state_r <= ST_LATCH;
            ST_LATCH: begin
                data_r<=rx_data_r; //latch the completed data into the data register
                system_state_r<=ST_IDLE; // force a transition to idle
                o_data_ready_w<=1'b1; // Drive the data ready wire high so we know to pull data
            end
            default: next_state_r <= system_state_r + 1; 
        endcase
    end

    // Timing generation for state machine
    always@(posedge i_clk) begin
        if(system_state_r == ST_IDLE)
            // The first time we cycle the counter we want it to be 1.5x the baud counter so that we trigger state transistions 
            // in the middle of the data bit
            baud_counter_r <= CYCLES_PER_BIT[7:0]+(CYCLES_PER_BIT[7:0]>>1)-1; //Don't increment counter when idling
        else begin
            if(baud_counter_r != 0)
                baud_counter_r <= baud_counter_r - 1; //Decrement the counter
            else
                baud_counter_r <= CYCLES_PER_BIT[7:0]-1; // reset the counter on when the necessary clock cycles have passed
        end
    end

    assign o_data_w = data_r; // connect the data wire output to the data register
    assign o_busy = system_state_r == ST_IDLE? 0:1; //the busy wire should be driven high whenever we're not in the idle state
    
endmodule