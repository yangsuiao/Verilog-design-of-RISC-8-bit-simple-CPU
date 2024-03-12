`timescale 1ns / 1ps
module ram(
    inout [7:0] data ,
    input [7:0] addr ,
    input       ena  ,
    input       read ,
    input       write
);

reg [7:0] ram[255:0];

assign data = (read&&ena)? ram[addr]:8'hzz;	// read data from RAM

always @(posedge write) begin	// write data to RAM
	ram[addr] <= data;
end

endmodule
