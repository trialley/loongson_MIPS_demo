`timescale 1ns / 1ps
//*************************************************************************
//   > 文件名: exe.v
//   > 描述  :五级流水CPU的执行模块
//   > 作者  : LOONGSON
//   > 日期  : 2016-04-14
//*************************************************************************
module exe(                         // 执行级
    input              EXE_valid,   // 执行级有效信号
    input      [166:0] ID_EXE_bus_r,// ID->EXE总线
    output             EXE_over,    // EXE模块执行完成
    output     [153:0] EXE_MEM_bus, // EXE->MEM总线
    
     //5级流水新增
     input             clk,       // 时钟
     output     [  4:0] EXE_wdest,   // EXE级要写回寄存器堆的目标地址号
 
    //展示PC
    output     [ 31:0] EXE_pc
);
//-----{ID->EXE总线}begin
    //EXE需要用到的信息
    wire multiply;            //乘法
    wire mthi;             //MTHI
    wire mtlo;             //MTLO
    wire [11:0] alu_control;
    wire [31:0] alu_operand1;
    wire [31:0] alu_operand2;

    //访存需要用到的load/store信息
    wire [3:0] mem_control;  //MEM需要使用的控制信号
    wire [31:0] store_data;  //store操作的存的数据
                          
    //写回需要用到的信息
    wire mfhi;
    wire mflo;
    wire mtc0;
    wire mfc0;
    wire [7 :0] cp0r_addr;
    wire       syscall;   //syscall和eret在写回级有特殊的操作 
    wire       eret;
    wire       rf_wen;    //写回的寄存器写使能
    wire [4:0] rf_wdest;  //写回的目的寄存器
    
    //pc
    wire [31:0] pc;
    assign {multiply,
            mthi,
            mtlo,
            alu_control,
            alu_operand1,
            alu_operand2,
            mem_control,
            store_data,
            mfhi,
            mflo,
            mtc0,
            mfc0,
            cp0r_addr,
            syscall,
            eret,
            rf_wen,
            rf_wdest,
            pc          } = ID_EXE_bus_r;
//-----{ID->EXE总线}end

//-----{ALU}begin
    wire [31:0] alu_result;

    alu alu_module(
        .alu_control  (alu_control ),  // I, 12, ALU控制信号
        .alu_src1     (alu_operand1),  // I, 32, ALU操作数1
        .alu_src2     (alu_operand2),  // I, 32, ALU操作数2
        .alu_result   (alu_result  )   // O, 32, ALU结果
    );
//-----{ALU}end

//-----{乘法器}begin
    wire        mult_begin; 
    wire [63:0] product; 
    wire        mult_end;
    
    assign mult_begin = multiply & EXE_valid;
    multiply multiply_module (
        .clk       (clk       ),
        .mult_begin(mult_begin  ),
        .mult_op1  (alu_operand1), 
        .mult_op2  (alu_operand2),
        .product   (product   ),
        .mult_end  (mult_end  )
    );
//-----{乘法器}end

//-----{EXE执行完成}begin
    //对于ALU操作，都是1拍可完成，
    //但对于乘法操作，需要多拍完成
    assign EXE_over = EXE_valid & (~multiply | mult_end);
//-----{EXE执行完成}end

//-----{EXE模块的dest值}begin
   //只有在EXE模块有效时，其写回目的寄存器号才有意义
    assign EXE_wdest = rf_wdest & {5{EXE_valid}};
//-----{EXE模块的dest值}end

//-----{EXE->MEM总线}begin
    wire [31:0] exe_result;   //在exe级能确定的最终写回结果
    wire [31:0] lo_result;
    wire        hi_write;
    wire        lo_write;
    //要写入HI的值放在exe_result里，包括MULT和MTHI指令,
    //要写入LO的值放在lo_result里，包括MULT和MTLO指令,
    assign exe_result = mthi     ? alu_operand1 :
                        mtc0     ? alu_operand2 : 
                        multiply ? product[63:32] : alu_result;
    assign lo_result  = mtlo ? alu_operand1 : product[31:0];
    assign hi_write   = multiply | mthi;
    assign lo_write   = multiply | mtlo;
    
    assign EXE_MEM_bus = {mem_control,store_data,          //load/store信息和store数据
                          exe_result,                      //exe运算结果
                          lo_result,                       //乘法低32位结果，新增
                          hi_write,lo_write,               //HI/LO写使能，新增
                          mfhi,mflo,                       //WB需用的信号,新增
                          mtc0,mfc0,cp0r_addr,syscall,eret,//WB需用的信号,新增
                          rf_wen,rf_wdest,                 //WB需用的信号
                          pc};                             //PC
//-----{EXE->MEM总线}end

//-----{展示EXE模块的PC值}begin
    assign EXE_pc = pc;
//-----{展示EXE模块的PC值}end
endmodule
