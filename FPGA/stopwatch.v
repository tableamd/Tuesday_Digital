`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date:    20:11:40 10/21/2015 
// Module Name:    seg7_drive 
//////////////////////////////////////////////////////////////////////////////////
module stopwatch(
	input wire  clk0,
	input wire[1:0] sw,
	output wire [7:0] seg7,
	output wire [3:0] line,
	output wire [6:0] led
);
	assign line = 4'b0001<<ab;
	assign led = { 1'b0, count6, count10 };
	assign seg7 = { 1'b0, disp };

	// 表示
	reg[6:0] disp=7'b0;
	reg[3:0] x;
	reg[1:0] ab=2'b0;

	always @( posedge clk0 )begin	
		if(c[17:0] == 0)begin
			if(ab == 2'b00)begin
				x <= count_10hour;
			end
			else if(ab == 2'b01)begin
				x <= count_top;
			end
			else if(ab == 2'b10)begin
				x <= count_10min;
			end
			else begin
				x <= count_1hour;
			end
			
			ab <= ab+1'b1;
	
			case(x)
				4'b0000 : disp <= 7'b0111111; //0
				4'b0001 : disp <= 7'b0000110; //1
				4'b0010 : disp <= 7'b1011011; //2
				4'b0011 : disp <= 7'b1001111; //3
				4'b0100 : disp <= 7'b1100110; //4
				4'b0101 : disp <= 7'b1101101; //5
				4'b0110 : disp <= 7'b1111101; //6
				4'b0111 : disp <= 7'b0100111; //7
				4'b1000 : disp <= 7'b1111111; //8
				4'b1001 : disp <= 7'b1101111; //9
				default : disp <= 7'b0000000;
			endcase
		end
	end
	 
	
	// 1秒生成 NEW
 	reg[26:0] c=27'b0;
 	reg sec_enable=1'b0;
 	always @( posedge clk0 )begin
 		if(flug == 2'b0) begin
 			c <= ( c==27'd49999 )?1'b0:(c+1'b1);
 			sec_enable <= ( c==27'd49999 )?1'b1:1'b0;
 		end
 		else begin
  			c <= c+1'b0;
 			//sec_enable <= ( c==27'd49999 )?1'b1:1'b0;
 		end
 	end 
	
	// 10進カウンタ 0~9秒
	reg[3:0] count10 = 4'b0;
	reg sec10_enable = 1'b0;
	always @(posedge clk0) begin
		if(sec_enable)begin
			count10 <= (count10==4'd9) ? 1'b0 : (count10+1'b1);
			sec10_enable <= (count10==4'd9)? 1'b1 : 1'b0;
		end
		else begin
			sec10_enable <= 1'b0;
		end
	end

	// 6進カウンタ
 	reg[2:0] count6=3'b0;
 	always @( posedge clk0 )
 		if( sec10_enable ) count6<=(count6==3'd5)?1'b0:(count6+1'b1);
	
	// 1分カウンタ 
	reg[2:0] count_1min = 3'b0;
	reg min_enable = 1'b0;
	always @(posedge clk0) begin
		if(sec10_enable)begin
			count_1min <= (count_1min==4'd5) ? 1'b0 : (count_1min+1'b1);
			min_enable <= (count_1min==4'd5) ? 1'b1 : 1'b0;
		end
		else begin
			min_enable <= 1'b0;
		end
	end
	
	// 10分カウンタ
	reg[3:0] count_10min = 4'b0;
	reg ten_min_enable = 1'b0;
	always @(posedge clk0) begin
		if(min_enable)begin
			count_10min <= (count_10min==4'd9) ? 1'b0 : (count_10min+1'b1);
			ten_min_enable <= (count_10min==4'd9) ? 1'b1 : 1'b0;
		end
		else begin
			ten_min_enable <= 1'b0;
		end
	end
	
	// 10分毎の6進カウンタ -> 1時間を作成
	reg[2:0] count_1hour = 3'b0;
	reg hour_enable = 1'b0;
	always @(posedge clk0) begin
		if(ten_min_enable)begin
			count_1hour <= (count_1hour==4'd5) ? 1'b0 : (count_1hour+1'b1);
			hour_enable <= (count_1hour==4'd5) ? 1'b1 : 1'b0;
		end
		else begin
			hour_enable <= 1'b0;
		end
	end
	
	// 時間用10進カウンタ -> 0~9時間
	reg[3:0] count_10hour = 4'b0;
	reg ten_hour_enable = 1'b0;
	always @(posedge clk0) begin
		if(hour_enable)begin
			if(count_top != 4'd2)begin
				count_10hour <= (count_10hour==4'd9) ? 1'b0 : (count_10hour+1'b1);
				ten_hour_enable <= (count_10hour==4'd9) ? 1'b1 : 1'b0;
			end
			else begin
				count_10hour <= (count_10hour==4'd3) ? 1'b0 : (count_10hour+1'b1);
				ten_hour_enable <= (count_10hour==4'd3) ? 1'b1 : 1'b0;
			end
		end
		else begin
			ten_hour_enable <= 1'b0;
		end
	end
	
	//最終桁のカウンタ -> 0x, 1x, 2x時間
	reg[1:0] count_top = 2'b0;
	always @(posedge clk0) begin
		if(ten_hour_enable)begin
			count_top <= (count_top==4'd2) ? 1'b0 : (count_top+1'b1);
		end
	end

	//スイッチのチェック用のループ
	reg[1:0] sw_value = 2'b0;
	reg[1:0] sw_value_old = 2'b0;
	reg flug = 1'b0;
	always @(posedge clk0) begin
		sw_value = sw[1:0]; //入力読み込み(ノンブロッキング代入が良いかも？)

		if(sw_value==2'b01 && sw_value_old==2'b0) begin
			flug <= ~flug;
		end

		sw_value_old <= sw_value;
	end

endmodule