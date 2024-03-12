`timescale 1ns / 1ps
// arithmetic logic unit to perform arithmetic and logic operations.
module alu(
    output reg  [7:0] alu_out,
    input       [7:0] alu_in ,
    input       [7:0] accum  ,
    input       [3:0] op     ,
    output      [3:0] flags
);

parameter   NOP = 4'b0000,   // short  empty instruction       空指令     
            LDO = 4'b0001,   // long   Get data from ROM       从ROM取数据
            LDA = 4'b0010,   // long   Get data from RAM       从RAM取数据
            LDR = 4'b0011,   // short  Get data from ACC       从ACC取数据
            PRE = 4'b0100,   // short  Get data from REG       从REG取数据
            STO = 4'b0101,   // long   Write data to RAM       向RAM写数据
            ADD = 4'b0110,   // short  Add operands            操作数相加 
            SHL = 4'b0111,   // short  Logical shift left      逻辑左移   
            SHR = 4'b1000,   // short  Logical right shift     逻辑右移   
            SAR = 4'b1001,   // short  Arithmetic right shift  算数右移   
            INV = 4'b1010,   // short  Bitwise negation        按位取反   
            AND = 4'b1011,   // short  Bitwise AND             按位与     
            OR  = 4'b1100,   // short  Bitwise OR              按位或     
            XOR = 4'b1101,   // short  Bitwise XOR             按位异或   
            JMP = 4'b1110,   // long   jump instruction        跳转       
            HLT = 4'b1111;   // short  shutdown command        停机指令   

wire    OF, ZF, PF, SF;//溢出、零、奇偶、符号位标志位
assign  OF = ((~alu_in[7])&(~accum[7])&alu_out[7])|(alu_in[7]&accum[7]&(~alu_out[7]));
assign  ZF = ~(|alu_out);//1为零 0非零
assign  PF = ^alu_out;   //1奇数 0偶数
assign  SF = alu_out[7]; //1负数 0正数(补码运算)
assign  flags = {OF, ZF, SF, PF};
            
always @(*) begin
    case(op)       
        NOP:    alu_out = accum;                     // No operation
        LDO:    alu_out = alu_in;                    // REG[reg_addr]<-ROM[ROM_addr]
        LDA:    alu_out = alu_in;                    // REG[reg_addr]<-RAM[RAM_addr]
        LDR:    alu_out = accum;                     // REG[reg_addr]<-ACC
        PRE:    alu_out = alu_in;                    // ACC<-REG[reg_addr]
        STO:    alu_out = accum;                     // RAM[addr]<-REG[reg_addr]
        ADD:    alu_out = accum + alu_in;            // ACC<-REG[reg_addr]+ACC
        SHL:    alu_out = alu_in<<1;                 // ACC<-REG[reg_addr]<<1
        SHR:    alu_out = alu_in>>1;                 // ACC<-REG[reg_addr]>>1
        SAR:    alu_out = {alu_in[7],alu_in[7:1]};   // ACC<-{REG[reg_addr][7],REG[reg_addr][7:1]}
        INV:    alu_out = ~alu_in;                   // ACC<-~REG[reg_addr]
        AND:    alu_out = accum & alu_in;            // ACC<-REG[reg_addr]&ACC
        OR :    alu_out = accum | alu_in;            // ACC<-REG[reg_addr] | ACC
        XOR:    alu_out = accum ^ alu_in;            // ACC<-REG[reg_addr]^ACC
        JMP:    alu_out = alu_in;                    // PC = Immediate number
        HLT:    alu_out = accum;                     // shutdown command
    default:	alu_out = 8'bzzzz_zzzz;             
    endcase
end
			 
			
endmodule
