`timescale 1ns / 1ps
module accum(
    input       [7:0]   in ,
    output reg  [7:0]   out,
    input               ena,
    input               clk,
    input               rst
); // a register, to storage result after computing

always @(posedge clk or negedge rst) begin	
	if(!rst) out <= 8'd0;
	else begin
		if(ena)	out <= in;
		else	out <= out;
	end
end

endmodule
