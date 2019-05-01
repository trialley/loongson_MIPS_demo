`timescale 1ns / 1ps
//*************************************************************************
//   > 文件名: fetch.v
//   > 描述  :五级流水CPU的取指模块
//   > 作者  : LOONGSON
//   > 日期  : 2016-04-14
//*************************************************************************
`define STARTADDR 32'H00000034   // 程序起始地址为34H
module fetch(                    // 取指级
    input             clk,       // 时钟
    input             resetn,    // 复位信号，低电平有效
    input             IF_valid,  // 取指级有效信号
    input             next_fetch,// 取下一条指令，用来锁存PC值
    input      [31:0] inst,      // inst_rom取出的指令
    input      [32:0] jbr_bus,   // 跳转总线
    output     [31:0] inst_addr, // 发往inst_rom的取指地址
    output reg        IF_over,   // IF模块执行完成
    output     [63:0] IF_ID_bus, // IF->ID总线
    
    //5级流水新增接口
    input      [32:0] exc_bus,   // Exception pc总线
        
    //展示PC和取出的指令
    output     [31:0] IF_pc,
    output     [31:0] IF_inst
);

//-----{程序计数器PC}begin
    wire [31:0] next_pc;
    wire [31:0] seq_pc;
    reg  [31:0] pc;
    
    //跳转pc
    wire        jbr_taken;
    wire [31:0] jbr_target;
    assign {jbr_taken, jbr_target} = jbr_bus;  // 跳转总线传是否跳转和目标地址
    
    //Exception PC
    wire        exc_valid;
    wire [31:0] exc_pc;
    assign {exc_valid,exc_pc} = exc_bus;
    
    //pc+4
    assign seq_pc[31:2]    = pc[31:2] + 1'b1;  // 下一指令地址：PC=PC+4
    assign seq_pc[1:0]     = pc[1:0];

    // 新指令：若有Exception,则PC为Exceptio入口地址
    //         若指令跳转，则PC为跳转地址；否则为pc+4
    assign next_pc = exc_valid ? exc_pc : 
                     jbr_taken ? jbr_target : seq_pc;
    always @(posedge clk)    // PC程序计数器
    begin
        if (!resetn)
        begin
            pc <= `STARTADDR; // 复位，取程序起始地址
        end
        else if (next_fetch)
        begin
            pc <= next_pc;    // 不复位，取新指令
        end
    end
//-----{程序计数器PC}end

//-----{发往inst_rom的取指地址}begin
    assign inst_addr = pc;
//-----{发往inst_rom的取指地址}end

//-----{IF执行完成}begin
    //由于指令rom为同步读写的,
    //取数据时，有一拍延时
    //即发地址的下一拍时钟才能得到对应的指令
    //故取指模块需要两拍时间
    //故每次PC刷新，IF_over都要置0
    //然后将IF_valid锁存一拍即是IF_over信号
    always @(posedge clk)
    begin
        if (!resetn || next_fetch)
        begin
            IF_over <= 1'b0;
        end
        else
        begin
            IF_over <= IF_valid;
        end
    end
    //如果指令rom为异步读的，则IF_valid即是IF_over信号，
    //即取指一拍完成
//-----{IF执行完成}end

//-----{IF->ID总线}begin
    assign IF_ID_bus = {pc, inst};  // 取指级有效时，锁存PC和指令
//-----{IF->ID总线}end

//-----{展示IF模块的PC值和指令}begin
    assign IF_pc   = pc;
    assign IF_inst = inst;
//-----{展示IF模块的PC值和指令}end
endmodule