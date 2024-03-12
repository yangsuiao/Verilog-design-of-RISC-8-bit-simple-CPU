`timescale 1ns / 1ps
//PC, program counter
module counter(
    output reg [7:0]    pc_addr,
    input               clock  ,
    input               rst    ,
    input               en     ,
    input               chg_en ,  // Modify PC counter value enable
    input      [7:0]    chg_addr  // Modify PC counter value
);

initial begin
    pc_addr = 0;
end

always @(posedge clock or negedge rst) begin
	if(!rst) begin
		pc_addr <= 8'd0;
	end
	else if(en) begin
        if(chg_en)  
            pc_addr <= chg_addr;
        else
            pc_addr <= pc_addr+8'd1;
	end
    else
        pc_addr <= pc_addr;
end

endmodule
