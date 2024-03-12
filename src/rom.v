`timescale 1ns / 1ps
module rom(
    output  [7:0]   data,
    input   [7:0]   addr,
    input           read,
    input           ena
);

reg [7:0] memory[255:0];

// note: Decimal number in the bracket
initial begin
    memory[0]  = 8'b000_00000;	//NOP
    // [ins] [target_reg_addr] [from_rom_addr]
    memory[1]  = 8'b0001_0001;	//LDO s1    LDO is long instruct
    memory[2]  = 8'b01000001;   //rom(65)	REG[1]<- ROM[65]
    memory[3]  = 8'b0001_0010;	//LDO s2    LDO is long instruct
    memory[4]  = 8'b01000010;   //rom(66)   REG[2]<- ROM[66]
    memory[5]  = 8'b0001_0011;	//LDO s3    LDO is long instruct
    memory[6]  = 8'b01000011;   //rom(67)   REG[3]<- ROM[67]
    
    // Put the first number into the ACC register    
    memory[7]  = 8'b0100_0001;	//PRE s1    ACCUM <- REG[1]
    memory[8]  = 8'b0110_0010;	//ADD s2    ACCUM <- REG[2]+ACCUM 
    memory[9]  = 8'b0011_0001;	//LDR s1    REG[1]<- ACCUM
    //REG[1]=num1+num2, REG[2]=num2, REG[3]=num3. 

    memory[10] = 8'b0101_0001;	//STO s1    STO is long instruct
    memory[11] = 8'b0000_0001;  //ram(1)    RAM[1]<-REG[1]
    memory[12] = 8'b0010_0010;	//LDA s2    LDA is long instruct
    memory[13] = 8'b0000_0001;  //ram(1)    REG[2]<-RAM[1]
    //REG[1]=num1+num2, REG[2]=num1+num2, REG[3]=num3. 
    //RAM[1]=num1+num2.

    memory[14] = 8'b0100_0011;	//PRE s3    ACCUM<-REG[3]
    memory[15] = 8'b0110_0010;	//ADD s2    ACCUM <- REG[2]+ACCUM
    memory[16] = 8'b0011_0011;	//LDR s3    REG[3]<- ACCUM
    //REG[1]=num1+num2, REG[2]=num1+num2, REG[3]=num1+num2+num3. 

    memory[17] = 8'b0101_0011;	//STO s3    STo is long instruct
    memory[18] = 8'b0000_0010;  //ram(2)    RAM[2]<-REG[3]
    //RAM[2]=num1+num2+num3
//    memory[19] = 8'b1111_0000;	//HLT

    memory[19] = 8'b1110_0000;  //JMP        JMP is long instruct
    memory[20] = 8'b00100001 ;  //jump to 33 PC = 33
    memory[21] = 8'b1111_0000;	//HLT

    memory[33] = 8'b0100_0001;	//PRE s1    ACCUM <-REG[1]
    memory[34] = 8'b1011_0010;	//AND s2    ACCUM <-REG[2]&ACCUM
    memory[35] = 8'b0011_0100;	//LDR s4    REG[4]<- ACCUM
    //REG[4]=(num1+num2)&(num1+num2+num3)
//    memory[?] = 8'b0101_00xx;	//STO sx    STo is long instruct
//    memory[?] = 8'b0000_00xx;  //ram(x)    RAM[x]<-REG[x]
    memory[36] = 8'b0101_0100;	//STO s4    STo is long instruct
    memory[37] = 8'b0000_0011;  //ram(3)    RAM[3]<-REG[4]
    //RAM[3]=(num1+num2)&(num1+num2+num3)


    memory[38] = 8'b0100_0100;	//PRE s4    ACCUM <-REG[4]
    memory[39] = 8'b1011_0011;	//AND s3    ACCUM <-REG[3]&ACCUM
    memory[40] = 8'b0011_0101;	//LDR s5    REG[5]<- ACCUM
    //REG[5]=(num1+num2)&(num1+num2+num3)&(num1+num2+num3)

    memory[41] = 8'b0100_0101;	//PRE s5    ACCUM <-REG[5]
    memory[42] = 8'b1100_0010;	//OR  s2    ACCUM <-REG[2] | ACCUM
    memory[43] = 8'b0011_0110;	//LDR s6    REG[6]<-ACCUM
    //REG[6]=(num1+num2)&(num1+num2+num3)|(num1+num2)

    memory[44] = 8'b0100_0110;	//PRE s6    ACCUM <-REG[6]
    memory[45] = 8'b1101_0100;	//XOR s4    ACCUM<-REG[4]^ACCUM
    memory[46] = 8'b0011_0111;	//LDR s7    REG[7]<-ACCUM
    //REG[7]=(num1+num2)&(num1+num2+num3) ^ ((num1+num2)&(num1+num2+num3)|(num1+num2))

    memory[47] = 8'b0100_0111;	//PRE s7    ACCUM <-REG[7]
    memory[48] = 8'b1101_0011;	//XOR s3    ACCUM <-REG[3]^ACCUM
    memory[49] = 8'b0011_1000;	//LDR s8    REG[8]<-ACCUM
    //REG[8]={((num1+num2+num3)|(num1*3+num2*3+num3)) ^ (num1*2+num2*2)} ^ (num1+num2+num3)

    memory[50] = 8'b1010_0001;  //INV s1    ACCUM<-~REG[1]
    memory[51] = 8'b0011_1001;  //LDR s9    REG[9]<-ACCUM
    //REG[9]=~(num1+num2)
    memory[52] = 8'b0111_0001;  //SHL s1    ACCUM<-REG[1]<<1
    memory[53] = 8'b1000_0001;  //SHR s1    ACCUM<-REG[1]>>1
    memory[54] = 8'b1001_1001;  //SAR s9    ACCUM<-{REG[9][7],REG[9][7:1]}

    memory[55] = 8'b1110_0000;  //JMP       JMP is long instruct
    memory[56] = 8'b00010101 ;  //jump to 21 PC = 21
    
	memory[65] = 8'b00100101;	// ROM[65]=37
	memory[66] = 8'b01011001;	// ROM[66]=89
	memory[67] = 8'b00110101;	// ROM[67]=53
//    memory[68] = 8'b00010100;	// ROM[68]=20
//    memory[69] = 8'b01000010;	// ROM[69]=66
end

assign data = (read&&ena)? memory[addr]:8'hzz;	//output

endmodule
