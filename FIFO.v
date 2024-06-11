module fifo #(
    parameter DATA_WIDTH = 8,    
    parameter FIFO_DEPTH = 16   
)(
    input clk,                 
    input rst,              
    input wr_en,               
    input rd_en,                 
    input [DATA_WIDTH-1:0] data_in, 
    output reg [DATA_WIDTH-1:0] data_out, 
    output full,                 
    output empty                 
);

    reg [DATA_WIDTH-1:0] fifo_mem [FIFO_DEPTH-1:0];
    reg [4:0] wr_ptr;  
    reg [4:0] rd_ptr; 
    reg [4:0] fifo_count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            fifo_count <= 0;
        end else if (wr_en && !full) begin
            fifo_mem[wr_ptr] <= data_in;
            wr_ptr <= wr_ptr + 1;
            fifo_count <= fifo_count + 1;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_ptr <= 0;
            data_out <= 0;
            fifo_count <= 0;
        end else if (rd_en && !empty) begin
            data_out <= fifo_mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
            fifo_count <= fifo_count - 1;
        end
    end

    assign full = (fifo_count == FIFO_DEPTH);
    assign empty = (fifo_count == 0);

endmodule
