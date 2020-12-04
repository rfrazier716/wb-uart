`default_nettype none //flags an error if you haven't defined a wire


module fifo#(
    parameter FIFO_WIDTH = 8, // how many bits wide the FIFO is
    parameter FIFO_DEPTH = 8 // the memory of the FIFO, the memory allocated will be 2^FIFO_DEPTH
)(
    input wire i_clk, //System clock
    input wire[FIFO_WIDTH-1:0] i_data_w, //input data wire
    output wire[FIFO_WIDTH-1:0] o_data_w, //output data wire

    input wire i_read_w, //wire that advances the read head 1 step
    input wire i_write_w, //wire that latches data and advances the write head 1 step
    input wire i_reset_w, //wire to trigger a reset

    output wire o_full_w, //wire raised when FIFO is full
    output wire o_empty_w, //wire raised when FIFO is empty
    output wire[FIFO_DEPTH-1:0] o_fill_bytes_w //wire that holds how many bytes are currently saved in the FIFO
);
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
            // if there's a write event, latch the data, and advance the write head if the buffer isn't full
            // Will also execute if there is a read event concurrently
            if(i_write_w && (!o_full_w || i_read_w)) begin  
                fifo_buffer_r[write_head_r] <= i_data_w; //latch data into buffer
                write_head_r <= write_head_r + {{(FIFO_DEPTH-1){1'b0}},1'b1}; //Increment the write head
            end

            // If there's a read head advance request, output the current readhead data and advance the read head
            if(i_read_w && !o_empty_w) begin 
                read_head_r <= read_head_r + {{(FIFO_DEPTH-1){1'b0}},1'b1}; 
            end 
        end
    end
    //TODO: What about when you initialize the code? what is this value?
    assign o_data_w = fifo_buffer_r[read_head_r]; // The output data wire connects to the previously read value
    assign o_empty_w = (write_head_r == read_head_r) ? 1'b1:0; // if the read head equals the write head the FIFO is full
    assign o_full_w = ((write_head_r + {{(FIFO_DEPTH-1){1'b0}},1'b1}) == read_head_r) ? 1'b1:0; //if the write head is only ahead of the Fifo by one it's empty
    assign o_fill_bytes_w = (write_head_r - read_head_r); //The number of bytes currently in the FIFO

endmodule
