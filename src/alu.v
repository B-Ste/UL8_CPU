/*
ALU supporting addition, bitwise NAND and negation (and 0-output).

Signals:
x_in    : 8-bit x-input
y_in    : 8-bit y-input
op_in   : 2-bit opcode
z_out   : 8-bit result output

Opcode:
1       : x_in + y_in
2       : x_in NAND y_in
3       : NOT x_in
4       : 0
*/
module alu (
    input [7:0] x_in,
    input [7:0] y_in,
    input [1:0] op_in,
    input rst_n,
    output reg [7:0] z_out
);

always @(x_in, y_in, op_in or negedge rst_n) begin
    if (!rst_n) begin
        z_out <= 8'b0;
    end else begin
        case (op_in)
            2'b00: z_out <= x_in + y_in;
            2'b01: z_out <= ~(x_in & y_in);
            2'b10: z_out <= ~x_in;
            2'b11: z_out <= 8'b0;
            default: z_out <= 8'b0;
        endcase
    end
end
    
endmodule