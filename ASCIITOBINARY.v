module ascii_to_binary(
    input [7:0] ascii_code,
    output reg [2:0] binary 
);

    always @(*) begin
        case (ascii_code)
            8'h41: binary = 3'b000; // 'A'
            8'h54: binary = 3'b011; // 'T'
            8'h43: binary = 3'b001; // 'C'
            8'h47: binary = 3'b010; // 'G'
            8'h4E: binary = 3'b100; // 'N'
            default: binary = 3'b100;
        endcase
    end

endmodule
