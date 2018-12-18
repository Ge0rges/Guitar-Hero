

module pattern(input clock, input [3:0] state,
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

module patterndatapath(input [2:0] load_A, input [2:0] load_B, input [2:0] load_C, input [2:0] load_D,
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
