`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date:    20:11:40 10/21/2015 
// Module Name:    seg7_drive 
//////////////////////////////////////////////////////////////////////////////////
module seg7_drive(
	input wire  clk0,
	input wire[1:0] sw, //�J�E���^�X�g�b�v�p�̃X�C�b�`
	input wire[1:0] sw2, //�J�E���^���Z�b�g�p�̃X�C�b�`
	output wire [7:0] seg7,
	output wire [3:0] line,
	output wire [6:0] led
);
	assign line = 4'b0001<<ab; //���点��7�Z�O��1����I��
	assign led = { 1'b0, count6, count10 };
	assign seg7 = { 1'b0, disp };

	// �\��
	reg[6:0] disp=7'b0;
	reg[3:0] x;
	reg[1:0] ab=2'b0;
	always @( posedge clk0 )begin	
		if(c[17:0] == 0)begin
			if(ab == 2'b00)begin
				x <= count_10min; //3����
			end
			else if(ab == 2'b01)begin
				x <= count_1hour; //4����
			end
			else if(ab == 2'b10)begin
				x <= count10; //2����
			end
			else begin
				x <= count_1min; //1����
			end
			
			ab <= ab+1'b1; //ab���C���N�������g

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

	// 1�b���� NEW
 	reg[26:0] c=27'b0;
 	reg sec_enable=1'b0;
 	always @( posedge clk0 )begin
 		c <= ( c==27'd999999 )?1'b0:(c+1'b1);
 		sec_enable <= ( c==27'd999999 )?1'b1:1'b0;
 	end 
	
	// 10�i�J�E���^ 0~9�b
	reg[3:0] count10 = 4'b0;
	reg sec10_enable = 1'b0;
	always @(posedge clk0) begin
		if(sec_enable)begin
			if(flug == 2'b0)begin //���Ē�~�X�C�b�`��������Ă��Ȃ��Ȃ綳��
				count10 <= (count10==4'd9) ? 1'b0 : (count10+1'b1);
			end
			else begin //�J�E���g��~�X�C�b�`�������ꂽ��J�E���g��~
				count10 <= (count10==4'd9) ? 1'b0 : (count10+1'b0);
			end
			sec10_enable <= (count10==4'd9)? 1'b1 : 1'b0;
		end
		else begin
			sec10_enable <= 1'b0;
		end

		//7�Z�O�����g1���ڃJ�E���g���Z�b�g
		if(sw_value2==2'b01)begin
			count10 <= 1'b0;
			sec10_enable <= 1'b0;
		end
		
	end

	// 6�i�J�E���^
 	reg[2:0] count6=3'b0;
 	always @( posedge clk0 ) begin
 		if( sec10_enable )begin
			count6 <= (count6==3'd5)?1'b0:(count6+1'b1);
		end
		
		if(sw_value2==2'b01)begin
			count6 <= 1'b0;
		end
	end
	
	// 1���J�E���^ 
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
		
		//7�Z�O�����g2���ڃJ�E���g���Z�b�g
		if(sw_value2==2'b01)begin
			count_1min <= 1'b0;
			min_enable <= 1'b0;
		end
	end
	
	// 10���J�E���^
	reg[3:0] count_10min = 4'b0;
	reg ten_min_enable = 1'b0;
	always @(posedge clk0) begin
		if(min_enable)begin
			//count_top��0�C1��������count_10hour��0�`9�܂ł�10�i�J�E���^
			if(count_1hour != 4'd2)begin
				count_10min <= (count_10min==4'd9) ? 1'b0 : (count_10min + 1'b1);
				ten_min_enable <= (count_10min==4'd9) ? 1'b1 : 1'b0;
			end
			//count_top��2��������count_10hour��0�`3�܂ł�4�i�J�E���^
			else begin
				count_10min <= (count_10min==4'd3) ? 1'b0 : (count_10min + 1'b1);
				ten_min_enable <= (count_10min==4'd3) ? 1'b1 : 1'b0;
			end
		end
		else begin
			ten_min_enable <= 1'b0;
		end
	
		//7�Z�O�����g��3���ڃJ�E���g���Z�b�g
		if(sw_value2==2'b01)begin
			count_10min <= 1'b0;
			ten_min_enable <= 1'b0;
		end
		
	end
	
	// 10������6�i�J�E���^ -> 1���Ԃ��쐬
	reg[2:0] count_1hour = 3'b0;
	//reg hour_enable = 1'b0;
	always @(posedge clk0) begin
		if(ten_min_enable)begin
			count_1hour <= (count_1hour==4'd2) ? 1'b0 : (count_1hour+1'b1);
			//hour_enable <= (count_1hour==4'd5) ? 1'b1 : 1'b0;
		end
		
		//7�Z�O�����g��4���ڃJ�E���g���Z�b�g
		if(sw_value2==2'b01)begin
			count_1hour <= 1'b0;
			//hour_enable <= 1'b0;
		end
		
	end

	//�X�C�b�`�̃`�F�b�N�p�̃��[�v
	reg[1:0] sw_value = 2'b0;
	reg[1:0] sw_value2 = 2'b0;
	reg[1:0] sw_value_old = 2'b0;
	reg flug = 1'b0;
	always @(posedge clk0) begin
		sw_value <= sw[1:0]; //�J�E���g��~�X�C�b�`�ǂݍ���
		sw_value2 <= sw2[1:0]; //�J�E���g���Z�b�g�X�C�b�`�ǂݍ���
		
		if(sw_value2 == 2'b01)begin
			//���Z�b�g�X�C�b�`�������ꂽ��J�E���g��~
			flug <= 1'b1;
		end

		if(sw_value==2'b01 && sw_value_old==2'b0) begin
			//�J�E���g��~�X�C�b�`��������C���O��̒l��0�Ȃ��flug�𔽓]
			flug <= ~flug; //OFF->ON->OFF���J��Ԃ����
		end

		//�V�����J�E���g��~�X�C�b�`�̏���sw_value_old�ɑ��
		sw_value_old <= sw_value;
	end
endmodule
