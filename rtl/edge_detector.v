`default_nettype none //flags an error if you haven't defined a wire


module edge_detector(
    input wire i_clk, //System clock
    input wire i_signal,
    output wire o_rising_w,
    output wire o_falling_w);

    reg r_z1_input; // the input delayed by one clock cycle
    reg r_z2_input; // the input delayed by two clock cycles
    initial {r_z1_input,r_z2_input} = 0;

    //very simple design is two flipflops in series
    always@(posedge i_clk) begin
        r_z1_input <= i_signal; //Latch the z1 input
        r_z2_input <= r_z1_input; //latch the z2 input from the z1 input
    end

    assign o_rising_w = r_z1_input & !r_z2_input; //rising input if the single delayed input is high but two cycles ago was low
    assign o_falling_w = r_z2_input & !r_z1_input; //falling input if single delayed input is low but two cycles ago was high
    
endmodule
