module controller(
    input       [3:0]   ins      ,  // instructions, 3 bits, 8 types
    input               clk      ,  // clock
    input               rst      ,  // reset
    // Enable signals            
    output reg          write_r  ,
    output reg          read_r   ,
    output reg          PC_en    ,
    output reg          pc_chg_en,
    output reg  [1:0]   fetch    ,	// 01: to fetch from RAM/ROM; 10: to fetch from REG
    output reg          ac_ena   ,
    output reg          ram_ena  ,
    output reg          rom_ena  ,
    // ROM: where instructions are storaged. Read only.
    // RAM: where data is storaged, readable and writable.
    output reg          ram_write,
    output reg          ram_read ,
    output reg          rom_read ,
    output reg          ad_sel
);

parameter   NOP = 4'b0000,  // short  empty instruction       空指令     
            LDO = 4'b0001,  // long   Get data from ROM       从ROM取数据
            LDA = 4'b0010,  // long   Get data from RAM       从RAM取数据
            LDR = 4'b0011,  // short  Get data from ACC       从ACC取数据
            PRE = 4'b0100,  // short  Get data from REG       从REG取数据
            STO = 4'b0101,  // long   Write data to RAM       向RAM写数据
            ADD = 4'b0110,  // short  Add operands            操作数相加 
            SHL = 4'b0111,  // short  Logical shift left      逻辑左移   
            SHR = 4'b1000,  // short  Logical right shift     逻辑右移   
            SAR = 4'b1001,  // short  Arithmetic right shift  算数右移   
            INV = 4'b1010,  // short  Bitwise negation        按位取反   
            AND = 4'b1011,  // short  Bitwise AND             按位与     
            OR  = 4'b1100,  // short  Bitwise OR              按位或     
            XOR = 4'b1101,  // short  Bitwise XOR             按位异或   
            JMP = 4'b1110,  // long   jump instruction        跳转       
            HLT = 4'b1111;  // short  shutdown command        停机指令   


// state code			 
parameter   IDLE   = 4'hf,  //初始状态
            S0     = 4'h0,  //取指0
            S1     = 4'h1,  //译码 PC+1
            S2     = 4'h2,  //HLT停机
            S3     = 4'h3,  //Long0 取指1 RAM/ROM寻址地址
            S4     = 4'h4,  //Long1 PC+1
            S5     = 4'h5,  //Long2 LDO/LDA访存取数
            S6     = 4'h6,  //Long2 STO_0读REG
            S7     = 4'h7,  //Long3 STO_1写RAM
            S8     = 4'h8,  //Short0 PRE/ADD读REG
            S9     = 4'h9,  //Short0 LDR_0 ACC写REG
            S10    = 4'ha;

// State code(current state)
reg [3:0] state      = IDLE;	// current state
reg [3:0] next_state = IDLE; 	// next state
             
//PART A: D flip latch; State register
always @(posedge clk or negedge rst) begin
	if(!rst) state<=IDLE;
		//current_state <= IDLE;
	else state<=next_state;
		//current_state <= next_state;	
end

//PART B: Next-state combinational logic
always @* begin
    case(state)
    S1:	begin
            if(ins == NOP)   next_state = S0;
            else if(ins == HLT) next_state = S2;
            // else if((ins == PRE)|(ins == ADD)|(ins == AND)|(ins == OR)|(ins == XOR)|(ins == INV)|(ins == SHL)|(ins == SHR)|(ins == SAR))nstate = S8;
            else if(ins==LDR) next_state = S9;
            else if((ins == LDO)|(ins == LDA)|(ins == STO)|(ins == JMP)) next_state = S3;
            else next_state = S8;
        end

    S3:	begin
            if (ins==LDA | ins==LDO) next_state = S4;
            else if(ins == JMP) next_state = S10;
            //else if (ins==STO) next_state=S7; 
            else next_state = S6; // ---Note: there are only 3 long instrucions. So, all the cases included. if (counter_A==2*b11)
        end
    IDLE:	next_state = S0;
    S0:		next_state = S1;
    S2:	    next_state = S2;
    S4:		next_state = S5;
    S5:		next_state = S0;
    S6:		next_state = S7;
    S7:		next_state = S0;
    S8:		next_state = S0;
    S9:		next_state = S0;
    S10:	next_state = S0;
    default:next_state = IDLE;
    endcase
end

// another style
//PART C: Output combinational logic
always @* begin 
    case(state)
    // --Note: for each statement, we concentrate on the current state, not next_state
    // because it is combinational logic.
    IDLE:begin
            write_r   = 1'b0 ;
            read_r    = 1'b0 ;
            PC_en     = 1'b0 ;
            pc_chg_en = 1'b0 ;
            ac_ena    = 1'b0 ;
            rom_ena   = 1'b0 ;
            rom_read  = 1'b0 ;
            ram_ena   = 1'b0 ;
            ram_write = 1'b0 ;
            ram_read  = 1'b0 ;
            ad_sel    = 1'b0 ;
            fetch     = 2'b00;
            end
    S0: begin // load IR 取指0
            write_r   = 1'b0 ;
            read_r    = 1'b0 ;
            PC_en     = 1'b0 ;
            pc_chg_en = 1'b0 ;
            ac_ena    = 1'b0 ;
            rom_ena   = 1'b1 ;
            rom_read  = 1'b1 ;
            ram_ena   = 1'b0 ;
            ram_write = 1'b0 ;
            ram_read  = 1'b0 ;
            ad_sel    = 1'b0 ;
            fetch     = 2'b01;
            end
    S1: begin   //译码 PC+1
            write_r   = 1'b0 ;
            read_r    = 1'b0 ;
            PC_en     = 1'b1 ; 
            pc_chg_en = 1'b0 ;
            ac_ena    = 1'b0 ;
            rom_ena   = 1'b1 ;
            rom_read  = 1'b1 ;
            ram_ena   = 1'b0 ;
            ram_write = 1'b0 ;
            ram_read  = 1'b0 ;
            ad_sel    = 1'b0 ;
            fetch     = 2'b00;
            end
    S2: begin   //HLT停机
            write_r   = 1'b0 ;
            read_r    = 1'b0 ;
            PC_en     = 1'b0 ;
            pc_chg_en = 1'b0 ;
            ac_ena    = 1'b0 ;
            rom_ena   = 1'b0 ;
            rom_read  = 1'b0 ;
            ram_ena   = 1'b0 ;
            ram_write = 1'b0 ;
            ram_read  = 1'b0 ;
            ad_sel    = 1'b0 ;
            fetch     = 2'b00;
        end
    S3: begin   //Long0 取指1
            write_r   = 1'b0 ;
            read_r    = 1'b0 ;
            PC_en     = 1'b0 ;
            pc_chg_en = 1'b0 ;
            ac_ena    = 1'b0 ; 
            rom_ena   = 1'b1 ;
            rom_read  = 1'b1 ;
            ram_ena   = 1'b0 ;
            ram_write = 1'b0 ;
            ram_read  = 1'b0 ;
            ad_sel    = 1'b0 ;
            fetch     = 2'b10; 
        end
    S4: begin//Long1 PC+1
            if(ins == LDO)begin
                write_r   = 1'b1 ;
                read_r    = 1'b0 ;
                PC_en     = 1'b0 ;
                pc_chg_en = 1'b0 ;
                ac_ena    = 1'b0 ;
                rom_ena   = 1'b1 ; 
                rom_read  = 1'b1 ;
                ram_ena   = 1'b0 ;
                ram_write = 1'b0 ;
                ram_read  = 1'b0 ;
                ad_sel    = 1'b1 ;
                fetch     = 2'b00; 
            end
            else begin   //LDA
                write_r   = 1'b1 ;
                read_r    = 1'b0 ;
                PC_en     = 1'b0 ;
                pc_chg_en = 1'b0 ;
                ac_ena    = 1'b0 ;
                rom_ena   = 1'b0 ; 
                rom_read  = 1'b0 ;
                ram_ena   = 1'b1 ;
                ram_write = 1'b0 ;
                ram_read  = 1'b1 ;
                ad_sel    = 1'b1 ;
                fetch     = 2'b00; 
            end
        end
    S5: begin
            if (ins == LDO) begin
                write_r   = 1'b1 ;
                read_r    = 1'b0 ;
                PC_en     = 1'b1 ;
                pc_chg_en = 1'b0 ;
                ac_ena    = 1'b0 ;
                rom_ena   = 1'b1 ;
                rom_read  = 1'b1 ;
                ram_ena   = 1'b0 ;
                ram_write = 1'b0 ;
                ram_read  = 1'b0 ;
                ad_sel    = 1'b1 ;
                fetch     = 2'b00; 		 
            end
            else  begin //LDA
                write_r   = 1'b1;
                read_r    = 1'b0;
                PC_en     = 1'b1;
                pc_chg_en = 1'b0;
                ac_ena    = 1'b0;
                rom_ena   = 1'b0;
                rom_read  = 1'b0;
                ram_ena   = 1'b1;
                ram_write = 1'b0;
                ram_read  = 1'b1;
                ad_sel    = 1'b1;
                fetch     = 2'b00;
            end	 
        end
    S6: begin   //Long2 STO_0读REG
            write_r   = 1'b0 ;
            read_r    = 1'b1 ;
            PC_en     = 1'b0 ; //** not so sure, log: change 1 to 0
            pc_chg_en = 1'b1 ;
            ac_ena    = 1'b0 ;
            rom_ena   = 1'b0 ;
            rom_read  = 1'b0 ;
            ram_ena   = 1'b0 ;
            ram_write = 1'b0 ;
            ram_read  = 1'b0 ;
            ad_sel    = 1'b0 ;
            fetch     = 2'b00;
        end

    S7: begin   //Long3 STO_1写RAM
            write_r   = 1'b0 ;
            read_r    = 1'b1 ;
            PC_en     = 1'b0 ;
            pc_chg_en = 1'b0 ;
            ac_ena    = 1'b0 ;
            rom_ena   = 1'b0 ;
            rom_read  = 1'b0 ;
            ram_ena   = 1'b1 ;
            ram_write = 1'b1 ;
            ram_read  = 1'b0 ;
            ad_sel    = 1'b1 ;
            fetch     = 2'b00;
        end
    S8: begin //Short0 PRE读REG
        if(ins == PRE)begin
            write_r   = 1'b0 ;
            read_r    = 1'b1 ;
            PC_en     = 1'b0 ;
            pc_chg_en = 1'b0 ;
            ac_ena    = 1'b1 ;
            rom_ena   = 1'b0 ;
            rom_read  = 1'b0 ;
            ram_ena   = 1'b0 ;
            ram_write = 1'b0 ;
            ram_read  = 1'b0 ;
            ad_sel    = 1'b0 ;
            fetch     = 2'b00; //fetch=2'b10, ram_ena=1, ram_write=1, ad_sel=1;
        end
        else begin  //ADD读REG
            write_r   = 1'b0 ;
            read_r    = 1'b1 ;
            PC_en     = 1'b0 ;
            pc_chg_en = 1'b0 ;
            ac_ena    = 1'b1 ;
            rom_ena   = 1'b0 ;
            rom_read  = 1'b0 ;
            ram_ena   = 1'b0 ;
            ram_write = 1'b0 ;
            ram_read  = 1'b0 ;
            ad_sel    = 1'b0 ;
            fetch     = 2'b00;
        end
        end
    S9: begin   //Short0 LDR_0 ACC写寄存器
            write_r   = 1'b1 ;
            read_r    = 1'b0 ;
            PC_en     = 1'b0 ;
            pc_chg_en = 1'b0 ;
            ac_ena    = 1'b1 ;
            rom_ena   = 1'b0 ;
            rom_read  = 1'b0 ;
            ram_ena   = 1'b0 ;
            ram_write = 1'b0 ;
            ram_read  = 1'b0 ;
            ad_sel    = 1'b0 ;
            fetch     = 2'b00;
        end
    S10: begin  //JMP 修改PC
            write_r   = 1'b0 ;
            read_r    = 1'b0 ;
            PC_en     = 1'b1 ;
            pc_chg_en = 1'b1 ;
            ac_ena    = 1'b0 ;
            rom_ena   = 1'b1 ;
            rom_read  = 1'b1 ;
            ram_ena   = 1'b0 ;
            ram_write = 1'b0 ;
            ram_read  = 1'b0 ;
            ad_sel    = 1'b0 ;
            fetch     = 2'b10;
        end
    default: begin
            write_r   = 1'b0 ;
            read_r    = 1'b0 ;
            PC_en     = 1'b0 ;
            pc_chg_en = 1'b0 ;
            ac_ena    = 1'b0 ;
            rom_ena   = 1'b0 ;
            rom_read  = 1'b0 ;
            ram_ena   = 1'b0 ;
            ram_write = 1'b0 ;
            ram_read  = 1'b0 ;
            ad_sel    = 1'b0 ;
            fetch     = 2'b00;		 
            end
    endcase
end
endmodule
