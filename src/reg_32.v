`timescale 1ns / 1ps
module reg_32(
    input   [7:0]   in   ,
    output  [7:0]   data ,
    input           write,
    input           read ,
    input   [7:0]   addr ,
    input           clk
);

//!Warning: addr should be reduced to 4 bits width, not 8 bits width.

reg [7:0] R[31:0]; //32Byte
wire [3:0] r_addr;

assign r_addr = addr[3:0];
assign data = (read)? R[r_addr] : 8'hzz;	//read enable

always @(posedge clk) begin				//write, clk posedge
	if(write)	R[r_addr] <= in; 
end

endmodule
