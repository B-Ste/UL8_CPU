/*
This module mutliplexes 8 8-Bit inputs onto one output.

Signals:
sel     :select output sel
in_i    : input i
out     : multiplexed output
*/
module bus_mux (
    input [2:0]sel,
    input [7:0] in_0, in_1, in_2, in_3, in_4, in_5, in_6, in_7,
    input rst_n,
    output reg [7:0] out
);

always @* begin
    if (!rst_n) begin
        out <= 8'b0;
    end else begin
        case (sel)
            3'b000: out <= in_0;
            3'b001: out <= in_1;
            3'b010: out <= in_2;
            3'b011: out <= in_3;
            3'b100: out <= in_4;
            3'b101: out <= in_5;
            3'b110: out <= in_6;
            3'b111: out <= in_7;
            default: out <= 8'b00000000;
        endcase
    end
end

endmodule