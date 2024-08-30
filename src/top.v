/*
Because this project is made to represent the 8-Bit CPU i am building out of actual 74LS-Chips,
this design may be unnecessaryly complicated and/or convoluted.
*/

/*
This is the top-module of the UL8-CPU, which connects the different components with each other.

Signals:
clk     : clock-input
*/
module top (
    input clk,
    input rst_n
);

// Data wires
wire [7:0]bus_out;

wire [7:0]bus_in_0;
wire [7:0]bus_in_1;
wire [7:0]bus_in_2;
wire [7:0]bus_in_3;
wire [7:0]bus_in_4;
wire [7:0]bus_in_5;
wire [7:0]bus_in_6;
wire [7:0]bus_in_7;

wire [7:0]x_reg;
wire [7:0]y_reg;

// Control wires
wire [2:0] bus_sel;

wire akku_load;
wire pc_load;
wire x_load;
wire y_load;
wire ar_load;
wire ir_load;

wire [1:0]alu_op;

wire [4:0]address;

// Components
bus_mux bus_mux(bus_sel, 
                bus_in_0, bus_in_1, bus_in_2, bus_in_3, bus_in_4, bus_in_5, bus_in_6, bus_in_7,
                rst_n,
                bus_out);

register akku(bus_out, bus_in_0, clk, akku_load, rst_n);
register pc(bus_out, bus_in_1, clk, pc_load, rst_n);
register x(bus_out, x_reg, clk, x_load, rst_n);
register y(bus_out, y_reg, clk, y_load, rst_n);
register ar(bus_out, address, clk, ar_load, rst_n);
register ir(bus_out, bus_in_5, clk, ir_load, rst_n);

alu alu(x_reg, y_reg, alu_op, rst_n, clk, bus_in_6);

    
endmodule