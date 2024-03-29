`timescale 1ns / 1ps
module ins_reg(
    input   [7:0]   data ,
    input   [1:0]   fetch,
    input           clk  , 
    input           rst  ,
    output  [3:0]   ins  ,
    output  [3:0]   ad1  ,
    output  [7:0]   ad2
); // instruction register


reg [7:0] ins_p1, ins_p2;
//reg [2:0] state;

assign ins = ins_p1[7:4]; //hign 4 bits, instructions
assign ad1 = ins_p1[3:0]; //low 4 bits, register address
assign ad2 = ins_p2;

always @(posedge clk or negedge rst) begin
	if(!rst) begin
		ins_p1 <= 8'd0;
		ins_p2 <= 8'd0;
	end
	else begin
		if(fetch == 2'b01) begin		//fetch==2'b01 operation1, to fetch data from REG
			ins_p1 <= data;
			ins_p2 <= ins_p2;
		end
		else if(fetch == 2'b10) begin	//fetch==2'b10 operation2, to fetch data from RAM/ROM
			ins_p1 <= ins_p1;
			ins_p2 <= data;
		end
		else begin
			ins_p1 <= ins_p1;
			ins_p2 <= ins_p2;
		end
	end
end


endmodule
