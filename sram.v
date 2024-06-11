module sram (
    input wire clk,            
    input wire we,             
    input wire en,             
    input wire [3:0] addr,     
    input wire [7:0] din,      
    output reg [7:0] dout     
);
    reg [7:0] mem [0:15];

    always @(posedge clk) begin
        if (en) begin
            if (we) begin
                mem[addr] <= din;
            end else begin
                dout <= mem[addr];
            end
        end
    end
endmodule
