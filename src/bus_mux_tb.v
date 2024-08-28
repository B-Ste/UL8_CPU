`include "src/bus_mux.v"
`timescale  1ns / 1ps

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: %h != %h at t = %t", signal, value, $time); \
        end else $display("Test passed in %m: signal == value at t = %t", $time);

module tb_bus_mux;

// bus_mux Parameters
parameter PERIOD  = 10;


// bus_mux Inputs
reg   [2:0]  sel                           = 0 ;
reg   [7:0]  in_0                          = 0 ;
reg   [7:0]  in_1                          = 0 ;
reg   [7:0]  in_2                          = 0 ;
reg   [7:0]  in_3                          = 0 ;
reg   [7:0]  in_4                          = 0 ;
reg   [7:0]  in_5                          = 0 ;
reg   [7:0]  in_6                          = 0 ;
reg   [7:0]  in_7                          = 0 ;

// bus_mux Outputs
wire  [7:0]  out                           ;    

reg clk = 0;

initial
begin
    forever #(PERIOD/2)  clk=~clk;
end


bus_mux  u_bus_mux (
    .sel                     ( sel   [2:0] ),
    .in_0                    ( in_0  [7:0] ),
    .in_1                    ( in_1  [7:0] ),
    .in_2                    ( in_2  [7:0] ),
    .in_3                    ( in_3  [7:0] ),
    .in_4                    ( in_4  [7:0] ),
    .in_5                    ( in_5  [7:0] ),
    .in_6                    ( in_6  [7:0] ),
    .in_7                    ( in_7  [7:0] ),

    .out                     ( out   [7:0] )
);

initial
begin
    in_0 <= 8'b00000001;
    in_1 <= 8'b00000010;
    in_2 <= 8'b00000100;
    in_3 <= 8'b00001000;
    in_4 <= 8'b00010000;
    in_5 <= 8'b00100000;
    in_6 <= 8'b01000000;
    in_7 <= 8'b10000000;

    sel <= 3'b000;
    #1 `assert(out, 8'b00000001);

    sel <= 3'b001;
    #1 `assert(out, 8'b00000010);

    sel <= 3'b010;
    #1 `assert(out, 8'b00000100);

    sel <= 3'b011;
    #1 `assert(out, 8'b00001000);
    
    sel <= 3'b100;
    #1 `assert(out, 8'b00010000);

    sel <= 3'b101;
    #1 `assert(out, 8'b00100000);

    sel <= 3'b110;
    #1 `assert(out, 8'b01000000);

    sel <= 3'b111;
    #1 `assert(out, 8'b10000000);

    $finish;
end

endmodule