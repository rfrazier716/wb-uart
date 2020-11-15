`default_nettype none //flags an error if you haven't defined a wire


module fifo#(
    parameter FIFO_WIDTH = 8, // how many bits wide the FIFO is
    parameter FIFO_DEPTH = 8 // the memory of the FIFO, the memory allocated will be 2^FIFO_DEPTH
)(
    input wire i_clk, //System clock
    input wire[FIFO_WIDTH-1:0] i_data_w, //input data wire
    output wire[FIFO_WIDTH-1:0] o_data_w, //output data wire

    input wire i_read_w, //wire to trigger a read command
    input wire i_write_w, //wire to trigger a write command
    input wire i_reset_w, //wire to trigger a reset

    output wire o_full_w, //wire raised when FIFO is full
    output wire o_empty_w //wire raised when FIFO is empty
);
    // Register that holds the most recently read fifo value
    reg[FIFO_WIDTH-1:0] o_data_r;
    initial o_data_r = 0;
    // FIFO memory
    reg [FIFO_WIDTH-1:0] fifo_buffer_r [(2**FIFO_DEPTH)-1:0];

    //setup the read and write heads
    reg[FIFO_DEPTH-1:0] read_head_r, write_head_r; // The index of the last read bit and the last written bit
    // The read head should default to 0 and the write head to 1
    initial read_head_r = 0;
    initial write_head_r = 0;

    always@(posedge i_clk) begin
        //TODO: Handle the special cases where we read and write on an underflow
        //TODO: handle case where we read and write on an overflow

        // if there's a reset signal initialize the read and write heads 
        if(i_reset_w) begin
            read_head_r <= 0;
            write_head_r <= 0;
        end
        
        else begin
            if (i_write_w && i_read_w)
            // if there's a write event, latch the data, and advance the write head if the buffer isn't full
            if(i_write_w && !o_full_w) begin  
                fifo_buffer_r[write_head_r] <= i_data_w; //latch data into buffer
                write_head_r <= write_head_r + {{(FIFO_DEPTH-1){1'b0}},1'b1}; //Increment the write head
            end
            // If there's a read event, put the furthest bythe on the output data wire
            if(i_read_w && !o_empty_w) begin 
                o_data_r <= fifo_buffer_r[read_head_r];
                read_head_r <= read_head_r + {{(FIFO_DEPTH-1){1'b0}},1'b1}; 
            end 
        end
    end

    assign o_data_w = o_data_r; // The output data wire connects to the output data register
    assign o_empty_w = (write_head_r == read_head_r) ? 1'b1:0; // if the read head equals the write head the FIFO is full
    assign o_full_w = (write_head_r+ 1 == read_head_r) ? 1'b1:0; //if the write head is only ahead of the Fifo by one it's empty

endmodule
