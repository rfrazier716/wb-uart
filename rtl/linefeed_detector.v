///Module that looks for a linefeed character ``\r\n`` in uart data stream and asserts a flag for a clock cycle 

`default_nettype none //flags an error if you haven't defined a wire

module linefeed_detector(
    input wire i_clk, //Clock line
    input wire i_data_latch, //wire that when high, tells the shift register to latch the data
    input wire[7:0] i_data, //line for data
    output wire o_linefeed, //line that is high when the two bytes in the fifo are a linefeed
    output wire o_linefeed_rising //linefeed clock that goes high for one clock cycle when a linefeed is latched
);
parameter CARRIAGE = 8'h0D; //Carriage Return ascii code
parameter LINEFEED = 8'h0A; //Linefeed Ascii Code

reg [7:0] data_sr[1:0]; //shift register that holds incoming data

always@(posedge i_clk) begin
    // if the data latch flag is high, shift the data into the SR and throw out the most recent byte
    if(i_data_latch) begin
        data_sr[1] <= data_sr[0];
        data_sr[0] <= i_data; 
    end
end


//Connect up an edge detector module so that the output of o_linefeed_rising is only high for one clock cycle

assign o_linefeed = (data_sr[1] == CARRIAGE) && (data_sr[0] == LINEFEED);

/* verilator lint_off PINMISSING */
edge_detector linefeed_edge_detector(
    .i_clk(i_clk),
    .i_signal(o_linefeed),
    .o_rising_w(o_linefeed_rising)
    );
/* verilator lint_on PINMISSING */

endmodule;