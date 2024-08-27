`include "src/alu.v"
`timescale  1ns / 1ps
`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: %h != %h at t = %t", signal, value, $time); \
        end else $display("Test passed in %m: signal == value at t = %t", $time);

module tb_alu;

// alu Parameters
parameter PERIOD  = 10;


// alu Inputs
reg   [7:0]  x_in                          = 0 ;
reg   [7:0]  y_in                          = 0 ;
reg   [1:0]  op_in                         = 0 ;

// alu Outputs
wire  [7:0]  z_out                         ;    

reg clk;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

alu  u_alu (
    .x_in                    ( x_in   [7:0] ),
    .y_in                    ( y_in   [7:0] ),
    .op_in                   ( op_in  [1:0] ),

    .z_out                   ( z_out  [7:0] )
);

initial
begin
    $display("Begin Test\n");

    x_in <= 8'b00100000;
    y_in <= 8'b00001101;
    op_in <= 2'b00;
    #1;
    `assert(z_out, 8'b101101);

    op_in <= 2'b01;
    #1;
    `assert(z_out, 8'b11111111);

    op_in <= 2'b10;
    #1;
    `assert(z_out, 8'b11011111);

    op_in <= 2'b11;
    #1;
    `assert(z_out, 8'b0);

    $finish;
end

endmodule