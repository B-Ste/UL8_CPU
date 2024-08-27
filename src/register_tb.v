`include "src\register.v"
`timescale  1ns / 1ps

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: %h != %h at t = %t", signal, value, $time); \
        end else $display("Test passed in %m: signal == value at t = %t", $time);

module tb_register;

// register Parameters
parameter PERIOD  = 10;


// register Inputs
reg   [7:0]  data_in                       = 0 ;
reg   clk                                  = 0 ;
reg   load                                 = 0 ;
reg   rst_n                               = 0 ;

// register Outputs
wire  [7:0]  data_out                      ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

register  u_register (
    .data_in                 ( data_in   [7:0] ),
    .clk                     ( clk             ),
    .load                    ( load            ),
    .resetn                  ( rst_n          ),

    .data_out                ( data_out  [7:0] )
);

initial
begin
    #(PERIOD*3);

    $display("Begin Test at t = %t\n", $time);

    data_in <= 8'hff;
    `assert(data_out, 8'h00);

    load <= 1;
    #PERIOD;
    load <= 0;
    `assert(data_out, 8'hff);

    load <= 1;
    #(PERIOD/2);
    data_in <= 8'hab;
    `assert(data_out, 8'hff);
    #(PERIOD/2);

    data_in <= 8'hab;
    #(PERIOD/2);
    data_in <= 8'hba;
    #(PERIOD/2);
    `assert(data_out, 8'hab);

    #1;
    rst_n <= 0;
    #1;
    `assert(data_out, 8'h0);

    $finish;
end

endmodule