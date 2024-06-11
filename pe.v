module pe(
    input clk,
    input rst,

    input [15:0] matchpoint,
    input [15:0] gap_e,
    input [15:0] gap_o,

    input [2:0] Q,
    input [2:0] R,
    input en,

    input signed [32:0] H_up,
    input signed [32:0] D_up,

    output reg signed [32:0] curr_H,
    output reg signed [32:0] curr_I,
    output reg signed [32:0] curr_D,

    output reg [3:0] ptr,

);
    reg signed [32:0] H_diag;
    reg signed [32:0] D_out;
    reg signed [32:0] H_out;
    reg signed [32:0] I_out;

    wire [15:0] matchin;
    assign matchin = (Q==R) ? matchpoint :16'd0;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            H_diag <= 33'd0;
        end else begin
            H_diag <= H_up;
        end
        
    end

    ALU pe_alu(
        .clk(clk), 
        .rst(rst), 
        .H_up(H_up),
        .D_up(D_up),
        .H_diag(H_diag),
        .H_left(curr_H),
        .I_left(curr_I),
        .gap_o(gap_o),
        .gap_e(gap_e),
        .matchpoint(matchin),

        .H_out(H_out),
        .D_out(D_out),
        .I_out(I_out),
        .ptr(ptr)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            H_out <= 33'd0;
            I_out <= 33'd0;
            D_out <= 33'd0;
            curr_H <= 33'd0;
            curr_D <= 33'd0;
            curr_I <= 33'd0;
        end else begin
            curr_H <= H_out;
            curr_D <= D_out;
            curr_I <= I_out;
        end
    end




endmodule

module ALU(
    input clk,
    input rst,

    input signed [32:0] H_up,
    input signed [32:0] D_up,
    input signed [32:0] H_diag,
    input signed [32:0] H_left,
    input signed [32:0] I_left,
    input [15:0] gap_o,
    input [15:0] gap_e,
    input [15:0] matchpoint,

    output signed [32:0] H_out,
    output signed [32:0] D_out,
    output signed [32:0] I_out,
    output reg [3:0] ptr // ptr now covers 4 bits: 2 bits for H selection, 1 bit for I, and 1 bit for D
);
    reg signed [32:0] H_out_reg;
    reg signed [32:0] D_out_reg;
    reg signed [32:0] I_out_reg;

    wire signed [32:0] I1;
    wire signed [32:0] I2;
    wire signed [32:0] D1;
    wire signed [32:0] D2;
    wire signed [32:0] H1;
    wire signed [32:0] H2;
    wire signed [32:0] H3;
    wire signed [32:0] H4;

    assign I1 = H_left - gap_o;
    assign I2 = I_left - gap_e;
    assign D1 = H_up - gap_o;
    assign D2 = D_up - gap_e;
    assign H1 = 33'd0;
    assign H2 = I_out_reg;
    assign H3 = D_out_reg;
    assign H4 = H_diag + matchpoint;

    assign I_out = I_out_reg; 
    assign D_out = D_out_reg;
    assign H_out = H_out_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            I_out_reg <= 33'd0; 
            D_out_reg <= 33'd0; 
            H_out_reg <= 33'd0; 
            ptr <= 4'd0; 
        end else begin
            if (I1 >= I2) begin
                I_out_reg <= I1;
                ptr[3] <= 1'b0;
            end else begin
                I_out_reg <= I2;
                ptr[3] <= 1'b1;
            end

            if (D1 >= D2) begin
                D_out_reg <= D1;
                ptr[2] <= 1'b0;
            end else begin
                D_out_reg <= D2;
                ptr[2] <= 1'b1;
            end

            if (H1 >= H2 && H1 >= H3 && H1 >= H4) begin 
                H_out_reg <= H1;
                ptr[1:0] <= 2'd0;
            end else if (H2 >= H3 && H2 >= H4) begin
                H_out_reg <= H2;
                ptr[1:0] <= 2'd1;
            end else if (H3 >= H4) begin 
                H_out_reg <= H3;
                ptr[1:0] <= 2'd2;
            end else begin
                H_out_reg <= H4;
                ptr[1:0] <= 2'd3;
            end
        end
    end
endmodule



