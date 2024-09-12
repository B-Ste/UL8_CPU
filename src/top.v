module top (
    input clk,
    input resetn,
    input startn
);

localparam RESET = 3'b000;
localparam FETCH = 3'b001;
localparam DECODE = 3'b010;
localparam EXECUTE = 3'b011;
localparam WRITEBACK = 3'b100;
localparam HALT = 3'b101;

reg state;
reg sys_clk;
reg [31:0]ctr;

initial begin
    state <= RESET;
    sys_clk <= 0;
end

always @(posedge clk) begin
    if (ctr < 2500000) ctr <= ctr + 1;
    else begin
        sys_clk <= ~sys_clk;
        ctr <= 0;
    end
    if (!startn) state <= FETCH;
end

reg [7:0]ram[0:31];
reg [7:0]pc;
reg [7:0]akku;
reg [7:0]param;
reg [7:0]ir;

always @(posedge sys_clk) begin
    case (state)
        RESET: 
        begin
            pc <= 0;
            akku <= 0;
            param <= 0;
            ir <= 0;
        end

        FETCH: 
        begin 
            ir <= ram[pc[4:0]];
            state <= DECODE;
        end

        DECODE: 
        begin
            pc <= pc + 1;
            param <= {3'b000, ir[4:0]};
            state <= EXECUTE;
        end
        default: 
    endcase
end
    
endmodule