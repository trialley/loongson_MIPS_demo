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
module cu(//需要包含级输入，级输出，级间输出
    input clk,           // 时钟
    input resetn,        // 复位信号，低电平有效

    //级输入
    input IF_over,
    input ID_over,
    input EXE_over,
    input MEM_over,
    input WB_over,
    input cancel, 


    //级间输出
    output IFTOID,
    output IDTOEX,
    output EXTOMEM,
    output MEMTOWB,
    output MEM_allow_in,
    
    
    //级输出
    output next_fetch,
    //5模块的valid信号
    output reg IF_valid,
    output reg ID_valid,
    output reg EXE_valid,
    output reg MEM_valid,
    output reg WB_valid,
    
    
    output[4:0] cpu_5_valid
    );

    
    
    
    wire IF_allow_in;
    wire ID_allow_in;
    wire EXE_allow_in;
    //wire MEM_allow_in;
    wire WB_allow_in;
    
        
    //IF允许进入时，即锁存PC值，取下一条指令
    assign next_fetch = IF_allow_in;
    //各级允许进入信号:本级无效，或本级执行完成且下级允许进入
    assign IF_allow_in  = (IF_over & ID_allow_in) | cancel;
    assign ID_allow_in  = ~ID_valid  | (ID_over  & EXE_allow_in);
    assign EXE_allow_in = ~EXE_valid | (EXE_over & MEM_allow_in);
    assign MEM_allow_in = ~MEM_valid | (MEM_over & WB_allow_in );
    assign WB_allow_in  = ~WB_valid  | WB_over;
   
    //IF_valid，在复位按下后，一直有效
   always @(posedge clk)
    begin
        if (!resetn)
        begin
            IF_valid <= 1'b0;
        end
        else
        begin
            IF_valid <= 1'b1;
        end
    end
    
    //ID_valid
    always @(posedge clk)
    begin
        if (!resetn || cancel)
        begin
            ID_valid <= 1'b0;
        end
        else if (ID_allow_in)
        begin
            ID_valid <= IF_over;
        end
    end
    
    //EXE_valid
    always @(posedge clk)
    begin
        if (!resetn || cancel)
        begin
            EXE_valid <= 1'b0;
        end
        else if (EXE_allow_in)
        begin
            EXE_valid <= ID_over;
        end
    end
    
    //MEM_valid
    always @(posedge clk)
    begin
        if (!resetn || cancel)
        begin
            MEM_valid <= 1'b0;
        end
        else if (MEM_allow_in)
        begin
            MEM_valid <= EXE_over;
        end
    end
    
    //WB_valid
    always @(posedge clk)
    begin
        if (!resetn || cancel)
        begin
            WB_valid <= 1'b0;
        end
        else if (WB_allow_in)
        begin
            WB_valid <= MEM_over;
        end
    end
    
    //展示5级的valid信号
    assign cpu_5_valid = {12'd0         ,{4{IF_valid }},{4{ID_valid}},
                          {4{EXE_valid}},{4{MEM_valid}},{4{WB_valid}}};
//-------------------------{5级流水控制信号}end--------------------------//

//--------------------------{5级间的总线控制}begin---------------------------//
    assign IFTOID = IF_over && ID_allow_in;
    assign IDTOEX=ID_over && EXE_allow_in;
    assign EXTOMEM=EXE_over && MEM_allow_in;
    assign MEMTOWB=MEM_over && WB_allow_in;
//---------------------------{5级间的总线}end----------------------------//
endmodule
