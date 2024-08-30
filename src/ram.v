module ram (
    input [4:0]address,
    input [7:0]value_in,
    input write,
    input clk,
    input rst_n,
    output reg [7:0]value_out
    );

    reg [7:0]value[31:0];

    initial begin
        value[0] = 8'h00;
        value[1] = 8'h00;
        value[2] = 8'h00;
        value[3] = 8'h00;
        value[4] = 8'h00;
        value[5] = 8'h00;
        value[6] = 8'h00;
        value[7] = 8'h00;
        value[8] = 8'h00;
        value[9] = 8'h00;
        value[10] = 8'h00;
        value[11] = 8'h00;
        value[12] = 8'h00;
        value[13] = 8'h00;
        value[14] = 8'h00;
        value[15] = 8'h00;
        value[16] = 8'h00;
        value[17] = 8'h00;
        value[18] = 8'h00;
        value[19] = 8'h00;
        value[20] = 8'h00;
        value[21] = 8'h00;
        value[22] = 8'h00;
        value[23] = 8'h00;
        value[24] = 8'h00;
        value[25] = 8'h00;
        value[26] = 8'h00;
        value[27] = 8'h00;
        value[28] = 8'h00;
        value[29] = 8'h00;
        value[30] = 8'h00;
        value[31] = 8'h00;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            int i;
            for (i = 0; i <= 31; i = i + 1) begin
                value[i] <= 8'b0;
            end
        end else begin
            if (write) begin
                value[address] <= value_in;
                value_out <= value_in;
            end else begin
                value_out <= value[address];
            end
        end
    end
    
endmodule