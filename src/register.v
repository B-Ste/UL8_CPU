/*
This is a positive-edge driven general purpose register featuring an asynchronous reset.

Signals:

data_in     : 8-bit input
data_out    : 8-bit output
clk         : clock-input
load        : load values at data-lines into register
resetn      : asynchronous active-low reset; resets register to all 0's
*/
module register (
    input [7:0]data_in,
    output reg [7:0]data_out,
    input clk,
    input load,
    input resetn
);

always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        data_out <= 8'b0;
    end else begin 
        if (load) data_out <= data_in;
    end
end
    
endmodule