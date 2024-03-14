module core(
    input         clk      ,
    input         rst      ,
    output        rom_ena  ,
    output        rom_read ,
    output        ram_ena  ,
    output        ram_read ,
    output        ram_write,
    output [7:0]  data     ,
    output [7:0]  addr
);// Top-level entity(except core-tb)

wire write_r, read_r, PC_en, ac_ena, pc_chg_en, ad_sel;
wire [1:0]  fetch;
wire [7:0]  accum_out,
            alu_out;
wire [7:0]  ir_ad,
            pc_ad;
wire [3:0]  reg_ad;
wire [3:0]  ins;


ram RAM1(
    .data   (data     ), 
    .addr   (addr     ), 
    .ena    (ram_ena  ), 
    .read   (ram_read ), 
    .write  (ram_write)
);

rom ROM1(
    .data   (data    ), 
    .addr   (addr    ), 
    .ena    (rom_ena ), 
    .read   (rom_read)
);

addr_mux MUX1(
    .addr   (addr  ), 
    .sel    (ad_sel), 
    .ir_ad  (ir_ad ), 
    .pc_ad  (pc_ad )
);

counter PC1(
    .pc_addr    (pc_ad    ), 
    .clock      (clk      ), 
    .rst        (rst      ), 
    .en         (PC_en    ),
    .chg_en     (pc_chg_en),
    .chg_addr   (data     )
);

accum ACCUM1(
    .out    (accum_out), 
    .in     (alu_out  ), 
    .ena    (ac_ena   ), 
    .clk    (clk      ), 
    .rst    (rst      )
);

alu ALU1(
    .alu_out(alu_out  ), 
    .alu_in (data     ), 
    .accum  (accum_out), 
    .op     (ins      )
);

reg_32 REG1(
    .in     (alu_out     ), 
    .data   (data        ), 
    .write  (write_r     ), 
    .read   (read_r      ), 
    .addr   ({ins,reg_ad}), 
    .clk    (clk         )
);

ins_reg IR1(
    .data   (data  ), 
    .fetch  (fetch ), 
    .clk    (clk   ), 
    .rst    (rst   ), 
    .ins    (ins   ), 
    .ad1    (reg_ad), 
    .ad2    (ir_ad )
);


controller CONTROLLER1(
    .ins        (ins      ), 
    .clk        (clk      ), 
    .rst        (rst      ), 
    .write_r    (write_r  ), 
    .read_r     (read_r   ), 
    .PC_en      (PC_en    ),
    .pc_chg_en  (pc_chg_en),
    .fetch      (fetch    ), 
    .ac_ena     (ac_ena   ), 
    .ram_ena    (ram_ena  ), 
    .rom_ena    (rom_ena  ),
    .ram_write  (ram_write), 
    .ram_read   (ram_read ), 
    .rom_read   (rom_read ), 
    .ad_sel     (ad_sel   )
);
					
endmodule
