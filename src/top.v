module top (
    input clk,
    input resetn,
    input startn,

    output lcd_resetn,
	output lcd_clk,
	output lcd_cs,
	output lcd_rs,
	output lcd_data
);

localparam RESET = 3'b000;
localparam FETCH = 3'b001;
localparam DECODE = 3'b010;
localparam EXECUTE = 3'b011;
localparam HALT = 3'b101;

localparam LDA = 3'b000;
localparam STV = 3'b001;
localparam ADD = 3'b010;
localparam NAN = 3'b011;
localparam JMP = 3'b100;
localparam JMN = 3'b101;
localparam NOT = 3'b110;
localparam HLT = 3'b111;

monitor monitor (.clk(clk), .resetn(resetn), .lcd_resetn(lcd_resetn), .lcd_clk(lcd_clk), .lcd_cs(lcd_cs), .lcd_rs(lcd_rs), .lcd_data(lcd_data), .in_0(akku), .in_2(pc), .in_3(ir));

reg [2:0]state;
reg sys_clk;
reg [31:0]ctr;
bit running;

initial begin
    $readmemb("program.txt", ram);
    state <= RESET;
    sys_clk <= 0;
    running = 0;
end

always @(posedge clk) begin
    if (ctr < 1500000) ctr <= ctr + 1;
    else begin
        sys_clk <= ~sys_clk;
        ctr <= 0;
    end
    if (!startn && !running) running <= 1;
end

reg [7:0]ram[0:31];
reg [4:0]pc;
reg [7:0]akku;
reg [4:0]param;
reg [7:0]ir;

always @(posedge sys_clk) begin
    case (state)
        RESET: 
        begin
            pc <= 0;
            akku <= 0;
            param <= 0;
            ir <= 0;
            if (running) state <= FETCH;
        end

        FETCH: 
        begin 
            ir <= ram[pc];
            state <= DECODE;
        end

        DECODE: 
        begin
            pc <= pc + 1;
            param <= ir[4:0];
            state <= EXECUTE;
        end

        EXECUTE:
        begin
            case (ir[7:5])
                LDA:
                begin
                    akku <= ram[param];
                    state <= FETCH;
                end 

                STV:
                begin
                    ram[param] <= akku;
                    state <= FETCH;
                end

                ADD:
                begin
                    akku <= akku + ram[param];
                    state <= FETCH;
                end

                NAN:
                begin
                    akku <= ~(akku & ram[param]);
                    state <= FETCH;
                end

                JMP:
                begin
                    pc <= param;
                    state <= FETCH;
                end

                JMN:
                begin
                    if (akku[7]) pc <= param;
                    state <= FETCH;
                end

                NOT:
                begin
                    akku <= ~akku;
                    state <= FETCH;
                end

                HLT:
                begin
                    state <= HALT;
                end

                default: state <= HALT;
            endcase
        end

        HALT:
        begin

        end

        default: state <= HALT;
    endcase
end
    
endmodule