/*
This is a positive-edge driven general purpose register featuring an asynchronous reset.

Signals:

data_in     : 8-bit input
data_out    : 8-bit output
clk         : clock-input
load        : load values at data-lines into register
write       : drive data-lines with stored value
resetn      : asynchronous active-low reset; resets register to all 0's

On load = high and write = high, the register will output high ohmage.
*/
module register (
    input [7:0]data_in,
    output reg [7:0] data_out,
    input clk,
    input load,
    input write,
    input resetn
);

reg [7:0]value = 8'b0;

always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        value <= 8'b0;
    end else begin 
        if (load && write) data_out <= 8'bz;
        else if (load) value <= data_in;
        else if (write) data_out <= value;
        else data_out <= 8'bz;
    end
end
    
endmodule