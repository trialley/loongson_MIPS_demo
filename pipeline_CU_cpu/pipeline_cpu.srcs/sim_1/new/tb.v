`timescale 1ns / 1ps
//*************************************************************************
//   > 文件名: tb.v
//   > 描述  :五级流水CPU的testbench
//   > 作者  : trialley
//   > 日期  : 2019-05-03
//*************************************************************************
module tb(//仿真界面将显示该模块的端口

    input  [ 4:0] rf_addr,
    input  [31:0] mem_addr,
    
    output [31:0] rf_data,
    output [31:0] mem_data,
    output [31:0] IF_pc,//取指地址
    output [31:0] IF_inst,//取到的指令
    output [31:0] ID_pc,//
    output [31:0] EXE_pc,
    output [31:0] MEM_pc,
    output [31:0] WB_pc,
    
    //5级流水新增
    output [31:0] cpu_5_valid,
    output [31:0] HI_data,
    output [31:0] LO_data
    );
	
	//实例化CPU
	reg resetn;
    reg clk;
	pipeline_cpu cpu(
		.clk     (clk ),
		.resetn  (resetn  ),

		.rf_addr (rf_addr ),
		.mem_addr(mem_addr),
		.rf_data (rf_data ),
		.mem_data(mem_data),
		.IF_pc   (IF_pc   ),
		.IF_inst (IF_inst ),
		.ID_pc   (ID_pc   ),
		.EXE_pc  (EXE_pc  ),
		.MEM_pc  (MEM_pc  ),
		.WB_pc   (WB_pc   ),
		.cpu_5_valid (cpu_5_valid),
		  .HI_data (HI_data ),
		  .LO_data (LO_data )
	);

	//仿真开始
	initial begin
		clk = 0;
		#10000 resetn=0;
		#20000 resetn=1;
		
		forever #5000 clk = ~clk;
	end
	
endmodule

