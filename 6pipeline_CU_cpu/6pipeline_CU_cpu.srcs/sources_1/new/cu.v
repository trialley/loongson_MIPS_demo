`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SDU CS
// Engineer: TriAlley
// 
// Create Date: 2019/05/01 08:51:29
// Design Name: CU
// Module Name: cu
// Project Name: pipline_cpu
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 将原demo的杂乱布线整合到CU模块中，实现demo的完全模块化
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module cu(
    //包含 来自各流水级的输入线，向各流水级的输出线，各流水级之间寄存器的控制线
    input clk,           // 时钟
    input resetn,        // 复位信号，低电平有效
    
    //输入线
    input IF_over,
    input ID_over,
    input EXE_over,
    input MEM_over,
    input WB_over,
    input cancel, 


    //级间寄存器控制
    output IFTOID,
    output IDTOEX,
    output EXTOMEM,
    output MEMTOWB,
    output MEM_allow_in,
    
    
    //流水级控制线
    //5模块的valid信号
    output reg IF_valid,
    output reg ID_valid,
    output reg EXE_valid,
    output reg MEM_valid,
    output reg WB_valid,
    output next_fetch,
    
    //向显示模块显示各流水级运行状态
    output[31:0]cpu_5_valid
    );

    
//-------------------------{5级流水各信号间的逻辑}start--------------------------//
    //从原来的逻辑中移植过来的，是线路冗余，计划把这些线去掉
    //当然这些冗余线路也使得某些地方的代码边精简了
    wire IF_allow_in;
    wire ID_allow_in;
    wire EXE_allow_in;
    wire WB_allow_in;

    //IF允许进入时，即锁存PC值，取下一条指令
    assign next_fetch = IF_allow_in;
    
    //各级允许进入信号！准许进入后还要考虑上一级工作是否完成
    assign IF_allow_in  = (IF_over & ID_allow_in) | cancel;
    assign ID_allow_in  = ~ID_valid  | (ID_over  & EXE_allow_in);
    assign EXE_allow_in = ~EXE_valid | (EXE_over & MEM_allow_in);
    assign MEM_allow_in = ~MEM_valid | (MEM_over & WB_allow_in );
    assign WB_allow_in  = ~WB_valid  | WB_over;
//-------------------------{5级流水各信号间的逻辑}end--------------------------//
   
//-------------------------{5级流水控制信号}start--------------------------//
   always @(posedge clk)
    begin
        if (!resetn) IF_valid <= 1'b0;
        else IF_valid <= 1'b1;

        if (!resetn || cancel)ID_valid <= 1'b0;
        else if (ID_allow_in) ID_valid <= IF_over;

        if (!resetn || cancel) EXE_valid <= 1'b0;
        else if (EXE_allow_in) EXE_valid <= ID_over;

        if (!resetn || cancel) MEM_valid <= 1'b0;
        else if (MEM_allow_in) MEM_valid <= EXE_over;

        if (!resetn || cancel)WB_valid <= 1'b0;
        else if (WB_allow_in) WB_valid <= MEM_over;
    end
    
    //展示5级的valid信号
    assign cpu_5_valid = {12'd0         ,{4{IF_valid }},{4{ID_valid}},
                          {4{EXE_valid}},{4{MEM_valid}},{4{WB_valid}}};
//-------------------------{5级流水控制信号}end--------------------------//

//--------------------------{5级间的寄存器控制}begin---------------------------//
//下一级允许接受，上一级工作完成，则将上一级的输出放行到下一级输入
    assign IFTOID = IF_over && ID_allow_in;
    assign IDTOEX=ID_over && EXE_allow_in;
    assign EXTOMEM=EXE_over && MEM_allow_in;
    assign MEMTOWB=MEM_over && WB_allow_in;
//---------------------------{5级间间的寄存器控制}end----------------------------//
endmodule
