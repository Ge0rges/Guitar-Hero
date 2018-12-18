module GuitarHero(LEDR, CLOCK_50, PS2_CLK, PS2_DAT, HEX0, HEX1, HEX2, KEY, SW,
// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
		);
	
	// VGA declarations
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	// Physical Inputs/Outputs declarations
	input [3:0] KEY;
	input [9:0] SW;
	
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [6:0] HEX2;
	output [3:0] LEDR;
	
	// Clock declarations
	input CLOCK_50;
	wire game_state_clock;
	wire pattern_clock;
	
	// Game State
	reg [29:0] c1Curr;
	reg [29:0] c2Curr;
	reg [29:0] c3Curr;
	reg [29:0] c4Curr;
	
	wire [29:0] c1CurrWire;
	wire [29:0] c2CurrWire;
	wire [29:0] c3CurrWire;
	wire [29:0] c4CurrWire;
	
	wire [3:0] score_p1;
	wire [3:0] score_p2;
	
	// Pattern 
	wire [2:0] load_A;
	wire [2:0] load_B;
	wire [2:0] load_C;
	wire [2:0] load_D;
	
	wire [9:0] c1Pattern;
	wire [9:0] c2Pattern;
	wire [9:0] c3Pattern;
	wire [9:0] c4Pattern;

	// Random Number
	wire [3:0] randomNumber;
	
	// Keyboard declarations
	input PS2_DAT, PS2_CLK;
	wire [7:0] scan_code;
	wire read, scan_ready;
	reg [7:0] scan_history [1:2];
	
	// Scan keyboard
	always @(posedge scan_ready)
		begin
		scan_history [2] <= scan_history [1];
		scan_history [1] <= scan_code;
	end
	
	// Create the keyboard modules
	keyboard kb(.keyboard_clk(PS2_CLK), .keyboard_data(PS2_DAT), .clock50(CLOCK_50), .reset(0), .read(read), .scan_ready(scan_ready), .scan_code(scan_code));
	oneshot pulse(.pulse_out(read), .trigger_in(scan_ready), .clk(CLOCK_50));
	
	// Get the required keys.
	wire a_key = ((scan_history[1] == 'h1c) && (scan_history[2][7:4] != 'hF)); // Key for W
	wire s_key = ((scan_history[1] == 'h1b) && (scan_history[2][7:4] != 'hF)); // Key for S
	wire l_key = ((scan_history[1] == 'h4b) && (scan_history[2][7:4] != 'hF)); // Key for L
	wire sc_key = ((scan_history[1] == 'h4c) && (scan_history[2][7:4] != 'hF)); // Key for ;
	
	// Light up the test LEDs
	assign LEDR[3] = a_key;
	assign LEDR[2] = s_key;
	assign LEDR[1] = l_key;
	assign LEDR[0] = sc_key;
	
	// 1/s Clock
	slow_clock c0(CLOCK_50, game_state_clock, 36'd15_000_000);
	slow_clock c1(CLOCK_50, pattern_clock, 36'd150_000_000);

	// Hook up the game
	RandomNumberGenerator rng0(.clock(game_state_clock), .seed(32'b00001111001110000100000101000001), .number(randomNumber[3:0]));
	
	PatternFSM pFSM0(pattern_clock, randomNumber[3:0], load_A[2:0], load_B[2:0], load_C[2:0], load_D[2:0]);
	PatternDatapath pd0(load_A[2:0], load_B[2:0], load_C[2:0], load_D[2:0], c1Pattern[9:0], c2Pattern[9:0], c3Pattern[9:0], c4Pattern[9:0]);
	GameStateManager gsm0(.p1_key1(a_key), .p1_key2(s_key), .p2_key1(l_key), .p2_key2(sc_key), 
								 .c1Curr(c1Curr[29:0]), .c2Curr(c2Curr[29:0]), .c3Curr(c3Curr[29:0]), .c4Curr(c4Curr[29:0]), 
								 .c1Pattern(c1Pattern[9:0]), .c2Pattern(c2Pattern[9:0]), .c3Pattern(c3Pattern[9:0]), .c4Pattern(c4Pattern[9:0]), 
								 .clock(game_state_clock), .reset(SW[0]), 
								 .score_p1(score_p1[3:0]), .score_p2(score_p2[3:0]), 
								 .c1Draw(c1CurrWire[29:0]), .c2Draw(c2CurrWire[29:0]), .c3Draw(c3CurrWire[29:0]), .c4Draw(c4CurrWire[29:0]));
	
	// Hoook up c_Curr to c_CurrWire
	always @ (*) begin
		c1Curr [29:0] <= c1CurrWire[29:0];
		c2Curr [29:0] <= c2CurrWire[29:0];
		c3Curr [29:0] <= c3CurrWire[29:0];
		c4Curr [29:0] <= c4CurrWire[29:0];

	end
	
	// Show scores on hex
	hex_decoder hex0(score_p1[3:0], HEX0[6:0]);
	hex_decoder hex1(score_p2[3:0], HEX1[6:0]);
	hex_decoder hex2(randomNumber[3:0], HEX2[6:0]);

	// VGA
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(KEY[1]),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(1),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	VGAPlotter p0(.clock(CLOCK_50), .reset(KEY[1]), .c1(c1Curr[29:0]), .c2(c2Curr[29:0]), .c3(c3Curr[29:0]), .c4(c4Curr[29:0]), 
						.Y_out(y[6:0]), .X_out(x[7:0]), .colour_out(colour[2:0]), .draw(writeEn) );
						
endmodule

module VGAPlotter(input clock, input reset, input [29:0] c1, input [29:0] c2, input [29:0] c3, input [29:0] c4,
						output [7:0] X_out, output [6:0] Y_out, output [2:0] colour_out, output draw);
	
	reg [1:0] column = 0;
	reg [5:0] x_counter = 0;
	reg [6:0] y_counter = 0;
	reg [2:0] colour = 3'b000;
	wire [4:0] y_block_counter;
	
	assign X_out[7:0] = x_counter[5:0] + column[1:0]*6'b101000;
	assign y_block_counter[4:0] = y_counter[6:2] ;
	assign colour_out[2:0] = colour[2:0];
	assign Y_out[6:0]	= y_counter[6:0];
	
	always @(posedge clock) begin
		if(reset) begin
			column <= 0;
			x_counter <= 0;
			y_counter <= 0;
			draw <= 0;
		end
		
		if(x_counter <  6'b101000) begin
				x_counter <= x_counter + 1;
				draw <= 1;
		end
		else if(x_counter >= 6'd101000 & y_counter < 7'b1111000) begin
				y_counter <= y_counter + 1;
				x_counter <= 0;
				draw <= 1;
		end
		else begin
				y_counter <= 0;
				x_counter <= 0;
				column <= column + 1;
				draw <= 1;
		end
		
		if(column == 0) begin
			if(c1[y_block_counter[4:0]] == 0)
				colour <= 3'b000;
			else 
				colour <= 3'b111;
		end
		else if(column == 1) begin
			if(c2[y_block_counter[4:0]] == 0)
				colour <= 3'b000;
			else 
				colour <= 3'b100;
		end
		else if(column == 2) begin
			if(c3[y_block_counter[4:0]] == 0)
				colour <= 3'b000;
			else 
				colour <= 3'b010;
		end
		else if(column == 3) begin
			if(c4[y_block_counter[4:0]] == 0)
				colour <= 3'b000;
			else 
				colour <= 3'b001;
		end
		else begin
			column <= 0;
		end
	end

endmodule

module GameStateManager (input p1_key1, input p1_key2, input p2_key1, input p2_key2, 
							input [29:0] c1Curr, input [29:0] c2Curr, input [29:0] c3Curr, input [29:0] c4Curr,
							input [9:0] c1Pattern, input [9:0] c2Pattern, input [9:0] c3Pattern, input [9:0] c4Pattern,
							input clock, input reset,
							output reg [3:0] score_p1, output reg [3:0] score_p2, 
							output reg [29:0] c1Draw, output reg [29:0] c2Draw, output reg [29:0] c3Draw, output reg [29:0] c4Draw);
		
	// Sticky key mechanism
	reg p1k1Reg, p1k2Reg, p2k1Reg, p2k2Reg;
	reg resetKeysReg;
	reg resetKeysRegCheck;
	reg counter = 0; 
	always @ (*) begin 
		if (p1_key1)
			p1k1Reg <= 1;
		
		if (p1_key2)
			p1k2Reg <= 1;
			
		if (p2_key1)
			p2k1Reg <= 1;
		
		if (p2_key2)
			p2k2Reg <= 1;
		
		if (resetKeysReg) begin
			p1k1Reg <= 0;
			p1k2Reg <= 0;
			p2k1Reg <= 0;
			p2k2Reg <= 0;
			
		end
	end
	
	// Check if player has losed
	reg loss;
	always @(negedge clock) begin
		if (reset) begin
			loss <= 0;
			resetKeysReg <= 1;
		end
		else if ((p1k1Reg != c1Curr[29]) || (p1k2Reg != c2Curr[29]) || (p2k1Reg != c3Curr[29]) || (p2k2Reg != c4Curr[29])) begin
			loss <= 1;
		end
		
		if(resetKeysRegCheck & !reset) begin
			resetKeysReg <= 0;
		end
		else if (counter <= 9 & ~loss) begin
			resetKeysReg <= 1;
		end

	end
	
	// Scorer
	wire increment_score_p1_1;
	wire increment_score_p1_2;
	wire increment_score_p2_1;
	wire increment_score_p2_2;
	
	assign increment_score_p1_1 = ~loss && (p1k1Reg == c1Curr[29] && c1Curr[29]);
	assign increment_score_p1_2 = ~loss && (p1k2Reg == c2Curr[29] && c2Curr[29]);
	assign increment_score_p2_1 = ~loss && (p2k1Reg == c3Curr[29] && c3Curr[29]); 
	assign increment_score_p2_2 = ~loss && (p2k2Reg == c4Curr[29] && c4Curr[29]);

	// Shifter// Goes from 0 to # of bits in pattern -1
	always @(posedge clock) begin
		if (resetKeysReg) begin
			resetKeysRegCheck <= 1;
		end
		else if(resetKeysRegCheck & !resetKeysReg) begin
			resetKeysRegCheck <= 0;
		end
		
		if (reset) begin
			c1Draw <= 30'b111111111111111111111111111111;
			c2Draw <= 30'b111111111111111111111111111111;
			c3Draw <= 30'b111111111111111111111111111111;
			c4Draw <= 30'b111111111111111111111111111111;
			
			counter <= 0;
			score_p1 <= 0;
			score_p2 <= 0;
			
		end
		else if (counter <= 9 & ~loss) begin
			
			c1Draw <= {c1Curr[28:0], c1Pattern[counter]};
			c2Draw <= {c2Curr[28:0], c2Pattern[counter]};
			c3Draw <= {c3Curr[28:0], c3Pattern[counter]};
			c4Draw <= {c4Curr[28:0], c4Pattern[counter]};
			
		end
		else if (loss) begin
			c1Draw <= 0;
			c2Draw <= 0;
			c3Draw <= 0;
			c4Draw <= 0;
			
		end
		
		counter <= counter + 1;
		
		if (increment_score_p1_1& ~reset) begin
			score_p1 <= score_p1 + 1;
		end
		
		if (increment_score_p2_1& ~reset) begin
			score_p2 <= score_p2 + 1;
		end
		
		if (increment_score_p1_2& ~reset) begin
			score_p2 <= score_p2 + 1;
		end
		
		if (increment_score_p2_2& ~reset) begin
			score_p2 <= score_p2 + 1;
		end
		
		if (counter > 9) begin
			counter <= 0;
		end
	end
	
endmodule

module PatternFSM(input clock, input [3:0] state,
					  output reg [2:0] load_A,
					  output reg [2:0] load_B,
					  output reg [2:0] load_C,
					  output reg [2:0] load_D);
	
	always @(posedge clock) begin
	  if(state == 1) begin
			load_A <= 1;
			load_B <= 2;
			load_C <= 3;
			load_D <= 4;
		end
		else if(state == 2) begin
			load_A <= 2;
			load_B <= 3;
			load_C <= 4;
			load_D <= 5;
		end
		else if(state == 3) begin
			load_A <= 3;
			load_B <= 4;
			load_C <= 5;
			load_D <= 6;
		end
		else if(state == 4) begin
			load_A <= 4;
			load_B <= 5;
			load_C <= 6;
			load_D <= 1;
		end
		else if(state == 5) begin
			load_A <= 5;
			load_B <= 6;
			load_C <= 1;
			load_D <= 2;
		end
		else if(state == 6) begin
			load_A <= 6;
			load_B <= 1;
			load_C <= 2;
			load_D <= 3;
		end
		else if(state == 7) begin
			load_A <= 5;
			load_B <= 2;
			load_C <= 3;
			load_D <= 2;
		end
		else if(state == 8) begin
			load_A <= 4;
			load_B <= 3;
			load_C <= 4;
			load_D <= 1;
		end
		else if(state == 9) begin
			load_A <= 3;
			load_B <= 4;
			load_C <= 5;
			load_D <= 6;
		end
		else if(state == 10) begin
			load_A <= 2;
			load_B <= 5;
			load_C <= 6;
			load_D <= 5;
		end
		else if(state == 11) begin
			load_A <= 1;
			load_B <= 6;
			load_C <= 1;
			load_D <= 4;
		end
		else if(state == 12) begin
			load_A <= 2;
			load_B <= 5;
			load_C <= 2;
			load_D <= 3;
		end
		else if(state == 13) begin
			load_A <= 3;
			load_B <= 4;
			load_C <= 3;
			load_D <= 2;
		end
		else if(state == 14) begin
			load_A <= 4;
			load_B <= 3;
			load_C <= 2;
			load_D <= 1;
		end
		else if(state == 15) begin
			load_A <= 5;
			load_B <= 2;
			load_C <= 5;
			load_D <= 2;
		end
		else if(state == 16) begin
			load_A <= 6;
			load_B <= 1;
			load_C <= 6;
			load_D <= 3;
		end
	
	end


endmodule

module PatternDatapath(input [2:0] load_A, input [2:0] load_B, input [2:0] load_C, input [2:0] load_D,
							  output reg [9:0] columnA,
							  output reg [9:0] columnB,
							  output reg [9:0] columnC,
							  output reg [9:0] columnD);
	reg [9:0] pattern0 = 10'b0000000000;
	reg [9:0] pattern1 = 10'b0000000010;
	reg [9:0] pattern2 = 10'b1000000000;
	reg [9:0] pattern3 = 10'b1100000000;
	reg [9:0] pattern4 = 10'b1110000000;
	reg [9:0] pattern5 = 10'b1101000000;
	reg [9:0] pattern6 = 10'b1111000000;
	
	always @(*) begin
	   if(load_A == 1)
			columnA <= pattern1;
		else if(load_A == 2)
			columnA <= pattern2;
		else if(load_A == 3)
			columnA <= pattern3;
		else if(load_A == 4)
			columnA <= pattern4;
		else if(load_A == 5)
			columnA <= pattern5;
		else if(load_A == 6)
			columnA <= pattern6;
		else 
			columnA <= pattern0;
	end
	always @(*) begin
		if(load_B == 1)
			columnB <= pattern1;
		else if(load_B == 2)
			columnB <= pattern2;
		else if(load_B == 3)
			columnB <= pattern3;
		else if(load_B == 4)
			columnB <= pattern4;
		else if(load_B == 5)
			columnB <= pattern5;
		else if(load_B == 6)
			columnB <= pattern6;
		else 
			columnB <= pattern0;
	end
	always @(*) begin
		if(load_C == 1)
			columnC<= pattern1;
		else if(load_C == 2)
			columnC <= pattern2;
		else if(load_C == 3)
			columnC <= pattern3;
		else if(load_C== 4)
			columnC <= pattern4;
		else if(load_C == 5)
			columnC <= pattern5;
		else if(load_D == 6)
			columnC <= pattern6;
		else 
			columnC <= pattern0;
	end
	always @(*) begin
		if(load_D == 1)
			columnD <= pattern1;
		else if(load_D == 2)
			columnD <= pattern2;
		else if(load_D == 3)
			columnD <= pattern3;
		else if(load_D == 4)
			columnD <= pattern4;
		else if(load_D == 5)
			columnD <= pattern5;
		else if(load_D == 6)
			columnD <= pattern6;
		else 
			columnD <= pattern0;
	end
	
endmodule

module RandomNumberGenerator(input clock, input [31:0] seed, output reg [3:0] number);
	
	reg [31:0] generator;
	reg reseted;
	
	initial reseted = 0;
	
	initial generator = seed;
	
	always @(posedge clock)
	begin 
		if(~reseted) begin
			generator[31:0] <= seed[31:0];
			reseted <= 1;
			end
		else 
		begin
			generator[31:4] <= generator[27:0];
			generator[3] <= {generator[22] ^ generator[15]};
			generator[2] <= {generator[11] ^ generator[2]};
			generator[1] <= {generator[19] ^ generator[0]};
			generator[0] <= {generator[26] ^ generator[6]};
		end
	end
	always @(*) begin
		number[3] <= generator[25];
		number[2] <= generator[13];
		number[1] <= generator[3];
		number[0] <= generator[1];
	end
endmodule

module slow_clock(input CLOCK_50, output reg slow_clock, input [35:0] frequency);
	reg [35:0] counter;
	
	initial counter = 0;
	initial slow_clock = 0;
	
	always @(posedge CLOCK_50) begin
		if (counter >= frequency[35:0]) begin
			counter <= 0;
			slow_clock <= ~ slow_clock;
		end
		else
			counter <= counter + 1;
	end
endmodule

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule