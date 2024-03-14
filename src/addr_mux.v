`timescale 1ns / 1ps
// Address multiplexer
// to choose address of instruction register or address of program counter
module addr_mux(
    output  [7:0]   addr ,
    input           sel  ,
    input   [7:0]   ir_ad,
    input   [7:0]   pc_ad
); 

assign addr = (sel)? ir_ad : pc_ad;

endmodule
