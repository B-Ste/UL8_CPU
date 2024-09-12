module monitor (
    input clk,
	input resetn,

    input [7:0]in_0,
    input [7:0]in_1,
    input [7:0]in_2,
    input [7:0]in_3,
    input [7:0]in_4,
    input [7:0]in_5,
    input [7:0]in_6,
    input [7:0]in_7,

	output lcd_resetn,
	output lcd_clk,
	output lcd_cs,
	output lcd_rs,
	output lcd_data
);

localparam BLOCKWIDTH = 16;

localparam [15:0]ROWCOLS[0:7] = '{16'hf800, 16'hfd20, 16'hff40, 16'h3fe0, 16'h07fd, 16'h069f, 16'h029f, 16'hd81f};

reg [7:0]buffer[7:0];

reg [15:0]pixel;
wire [7:0]row;
wire [7:0]column;

lcd114 lcd(clk, resetn, lcd_resetn, lcd_clk, lcd_cs, lcd_rs, lcd_data, pixel, row, column);

integer i;

always @(posedge clk) begin
    if (!resetn) begin
        for (i = 0; i < 8; i = i + 1) begin
            buffer[i] <= 0;
        end 
    end else begin
        buffer[0] <= in_0;
        buffer[1] <= in_1;
        buffer[2] <= in_2;
        buffer[3] <= in_3;
        buffer[4] <= in_4;
        buffer[5] <= in_5;
        buffer[6] <= in_6;
        buffer[7] <= in_7;
    end
end

integer k;

always @(row, column) begin
    if (column < BLOCKWIDTH) begin
        // draw colored (index) squares at beginning of row
		if (row < (BLOCKWIDTH*8 - 1)) pixel <= ROWCOLS[row[6:4]];
		else pixel <= 0;
	end else if (column < (BLOCKWIDTH * 9) && row < (BLOCKWIDTH * 8)) begin
		//draw value in buffer register on corresponding place at lcd
        if ((column % BLOCKWIDTH) == 0 || (row % BLOCKWIDTH) == 0) pixel <= 16'b1111100000000000;
		else if (buffer[row[6:4]][8 - column[6:4]] == 1) pixel <= 16'hffff;
		else pixel <= 0;
    end else pixel <= 0;
end
    
endmodule

module lcd114(
	input clk, // 27M
	input resetn,

	output lcd_resetn,
	output lcd_clk,
	output lcd_cs,
	output lcd_rs,
	output lcd_data,

    input [15:0]pixel_in,
    output reg [7:0]row,
    output reg [7:0]column
);

localparam MAX_CMDS = 69;

wire [8:0] init_cmd[MAX_CMDS:0];

// Memory Data Access Control
assign init_cmd[ 0] = 9'h036;
assign init_cmd[ 1] = 9'h170;

// Interace Pixel Format
assign init_cmd[ 2] = 9'h03A;
assign init_cmd[ 3] = 9'h105;

// Porch Setting
assign init_cmd[ 4] = 9'h0B2;
assign init_cmd[ 5] = 9'h10C;
assign init_cmd[ 6] = 9'h10C;
assign init_cmd[ 7] = 9'h100;
assign init_cmd[ 8] = 9'h133;
assign init_cmd[ 9] = 9'h133;

// Gate Control
assign init_cmd[10] = 9'h0B7;
assign init_cmd[11] = 9'h135;

// VCMOS Setting
assign init_cmd[12] = 9'h0BB;
assign init_cmd[13] = 9'h119;

// LCM Control
assign init_cmd[14] = 9'h0C0;
assign init_cmd[15] = 9'h12C;

// VDV and VRH Command Enable
assign init_cmd[16] = 9'h0C2;
assign init_cmd[17] = 9'h101;

// VRH set
assign init_cmd[18] = 9'h0C3;
assign init_cmd[19] = 9'h112;

// VDV Set
assign init_cmd[20] = 9'h0C4;
assign init_cmd[21] = 9'h120;

// Frame Rate Control in Normal Mode
assign init_cmd[22] = 9'h0C6;
assign init_cmd[23] = 9'h10F;

// Power Control 1
assign init_cmd[24] = 9'h0D0;
assign init_cmd[25] = 9'h1A4;
assign init_cmd[26] = 9'h1A1;

// Positive Voltage Gamma Control
assign init_cmd[27] = 9'h0E0;
assign init_cmd[28] = 9'h1D0;
assign init_cmd[29] = 9'h104;
assign init_cmd[30] = 9'h10D;
assign init_cmd[31] = 9'h111;
assign init_cmd[32] = 9'h113;
assign init_cmd[33] = 9'h12B;
assign init_cmd[34] = 9'h13F;
assign init_cmd[35] = 9'h154;
assign init_cmd[36] = 9'h14C;
assign init_cmd[37] = 9'h118;
assign init_cmd[38] = 9'h10D;
assign init_cmd[39] = 9'h10B;
assign init_cmd[40] = 9'h11F;
assign init_cmd[41] = 9'h123;

// Negative Voltage Gamma Control
assign init_cmd[42] = 9'h0E1;
assign init_cmd[43] = 9'h1D0;
assign init_cmd[44] = 9'h104;
assign init_cmd[45] = 9'h10C;
assign init_cmd[46] = 9'h111;
assign init_cmd[47] = 9'h113;
assign init_cmd[48] = 9'h12C;
assign init_cmd[49] = 9'h13F;
assign init_cmd[50] = 9'h144;
assign init_cmd[51] = 9'h151;
assign init_cmd[52] = 9'h12F;
assign init_cmd[53] = 9'h11F;
assign init_cmd[54] = 9'h11F;
assign init_cmd[55] = 9'h120;
assign init_cmd[56] = 9'h123;

// Display Inversion On
assign init_cmd[57] = 9'h021;

// Display On
assign init_cmd[58] = 9'h029;


assign init_cmd[59] = 9'h02A; // column
assign init_cmd[60] = 9'h100;
assign init_cmd[61] = 9'h128;
assign init_cmd[62] = 9'h101;
assign init_cmd[63] = 9'h117;
assign init_cmd[64] = 9'h02B; // row
assign init_cmd[65] = 9'h100;
assign init_cmd[66] = 9'h135;
assign init_cmd[67] = 9'h100;
assign init_cmd[68] = 9'h1BB;
assign init_cmd[69] = 9'h02C; // start

localparam INIT_RESET   = 4'b0000; // delay 100ms while reset
localparam INIT_PREPARE = 4'b0001; // delay 200ms after reset
localparam INIT_WAKEUP  = 4'b0010; // write cmd 0x11 MIPI_DCS_EXIT_SLEEP_MODE
localparam INIT_SNOOZE  = 4'b0011; // delay 120ms after wakeup
localparam INIT_WORKING = 4'b0100; // write command & data
localparam INIT_DONE    = 4'b0101; // all done

`ifdef MODELTECH

localparam CNT_100MS = 32'd2700000;
localparam CNT_120MS = 32'd3240000;
localparam CNT_200MS = 32'd5400000;

`else

// speedup for simulation
localparam CNT_100MS = 32'd27;
localparam CNT_120MS = 32'd32;
localparam CNT_200MS = 32'd54;

`endif


reg [ 3:0] init_state;
reg [ 6:0] cmd_index;
reg [31:0] clk_cnt;
reg [ 4:0] bit_loop;

reg lcd_cs_r;
reg lcd_rs_r;
reg lcd_reset_r;

reg [15:0] pixel_buf;

reg [15:0] pixel;
reg [7:0] spi_data;

assign lcd_resetn = lcd_reset_r;
assign lcd_clk    = ~clk;
assign lcd_cs     = lcd_cs_r;
assign lcd_rs     = lcd_rs_r;
assign lcd_data   = spi_data[7]; // MSB

always@(posedge clk or negedge resetn) begin
	if (~resetn) begin
		clk_cnt <= 0;
		cmd_index <= 0;
		init_state <= INIT_RESET;

		lcd_cs_r <= 1;
		lcd_rs_r <= 1;
		lcd_reset_r <= 0;
		spi_data <= 8'hFF;
		bit_loop <= 0;
        row <= 0;
        column <= 1;

	end else begin

		case (init_state)

			INIT_RESET : begin
				if (clk_cnt == CNT_100MS) begin
					clk_cnt <= 0;
					init_state <= INIT_PREPARE;
					lcd_reset_r <= 1;
				end else begin
					clk_cnt <= clk_cnt + 1;
				end
			end

			INIT_PREPARE : begin
				if (clk_cnt == CNT_200MS) begin
					clk_cnt <= 0;
					init_state <= INIT_WAKEUP;
				end else begin
					clk_cnt <= clk_cnt + 1;
				end
			end

			INIT_WAKEUP : begin
				if (bit_loop == 0) begin
					// start
					lcd_cs_r <= 0;
					lcd_rs_r <= 0;
					spi_data <= 8'h11; // exit sleep
					bit_loop <= bit_loop + 1;
				end else if (bit_loop == 8) begin
					// end
					lcd_cs_r <= 1;
					lcd_rs_r <= 1;
					bit_loop <= 0;
					init_state <= INIT_SNOOZE;
				end else begin
					// loop
					spi_data <= { spi_data[6:0], 1'b1 };
					bit_loop <= bit_loop + 1;
				end
			end

			INIT_SNOOZE : begin
				if (clk_cnt == CNT_120MS) begin
					clk_cnt <= 0;
					init_state <= INIT_WORKING;
				end else begin
					clk_cnt <= clk_cnt + 1;
				end
			end

			INIT_WORKING : begin
				if (cmd_index == MAX_CMDS + 1) begin
					init_state <= INIT_DONE;
				end else begin
					if (bit_loop == 0) begin
						// start
						lcd_cs_r <= 0;
						lcd_rs_r <= init_cmd[cmd_index][8];
						spi_data <= init_cmd[cmd_index][7:0];
						bit_loop <= bit_loop + 1;
					end else if (bit_loop == 8) begin
						// end
						lcd_cs_r <= 1;
						lcd_rs_r <= 1;
						bit_loop <= 0;
						cmd_index <= cmd_index + 1; // next command
					end else begin
						// loop
						spi_data <= { spi_data[6:0], 1'b1 };
						bit_loop <= bit_loop + 1;
					end
				end
			end

			INIT_DONE : begin
                if (bit_loop == 0) begin
                    // start
                    lcd_cs_r <= 0;
                    lcd_rs_r <= 1;
//						spi_data <= 8'hF8; // RED
                    spi_data <= pixel[15:8];
                    bit_loop <= bit_loop + 1;
                end else if (bit_loop == 8) begin
                    // next byte
//						spi_data <= 8'h00; // RED
                    spi_data <= pixel[7:0];
                    bit_loop <= bit_loop + 1;
                end else if (bit_loop == 16) begin
                    // end
                    lcd_cs_r <= 1;
                    lcd_rs_r <= 1;
                    bit_loop <= 0; // next pixel
                    pixel <= pixel_buf;
                    if (column == 239) begin
                        if (row == 134) row <= 0;
                        else row <= row +1;
                        column <= 0;
                    end else column <= column + 1;
                end else begin
                    // loop
                    spi_data <= { spi_data[6:0], 1'b1 };
                    bit_loop <= bit_loop + 1;
                end
            end

		endcase

	end
end

always @(pixel_in) pixel_buf <= pixel_in;

endmodule
