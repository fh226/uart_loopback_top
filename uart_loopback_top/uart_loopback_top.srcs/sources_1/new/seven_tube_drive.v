`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/10 15:47:27
// Design Name: 
// Module Name: seven_tube_drive
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module seven_tube_drive(

  input   wire                    clk,// 时钟信号 ： 50MHz
  input   wire                    rst_n,// 复位信号 ： 低电平有效
  
  input   wire        [23:0]      data, // 显示数据
  
  output  reg         [5:0]       sel,// 数码管位选信号
  output  reg         [7:0]       seg // 数码管段选信号
);

  parameter           T       =   50_000; // 1ms计时周期数
  
  reg                 [25:0]      cnt; // 1ms计时器
  reg                 [3:0]       show_data; // 动态显示时，需要显示的数据
  reg                 [5:0]       sel_state; // 位选的中间状态

// 1ms计时器  
  always @ (posedge clk) begin
    if (rst_n == 1'b0)
      cnt <= 26'd0;
    else
      if (cnt < T - 1'b1)
        cnt <= cnt + 1'b1;
      else
        cnt <= 26'd0;
  end
//1ms进行移位，只选择一只管子  
 initial sel_state = 6'b111_110;
  always @ (posedge clk) begin
    if (rst_n == 1'b0)
      sel_state <= 6'b111_110;
    else
      if (cnt == T - 1'b1)
        sel_state <= {sel_state[4:0], sel_state[5]};
      else
        sel_state <= sel_state;
  end

// 打拍输出，对齐时序  
  always @ (posedge clk) sel <= sel_state;

// 根据选择的管子，选择出对应想要的数据  

  always @ * begin
      case (sel_state)
        6'b111_110        :   show_data = data[3:0];
        6'b111_101        :   show_data = data[7:4];
        6'b111_011        :   show_data = 4'd8;     //中间两个数码管永远显示为8
        6'b110_111        :   show_data = 4'd8;     //中间两个数码管永远显示为8
        6'b101_111        :   show_data = data[19:16];
        6'b011_111        :   show_data = data[23:20];
        default           :   show_data = 4'd0;
      endcase
  end

// 将想要显示的数据，变为段选信号  
  always @ (posedge clk) begin
    if (rst_n == 1'b0)
      seg <= 8'hff;
    else
        case (show_data[3:0])
          4'd0      :   seg <= 8'b1100_0000;
          4'd1      :   seg <= 8'b1111_1001;
          4'd2      :   seg <= 8'b1010_0100;
          4'd3      :   seg <= 8'b1011_0000;
          4'd4      :   seg <= 8'b1001_1001;
          4'd5      :   seg <= 8'b1001_0010;
          4'd6      :   seg <= 8'b1000_0010;
          4'd7      :   seg <= 8'b1111_1000;
          4'd8      :   seg <= 8'b1000_0000;
          4'd9      :   seg <= 8'b1001_0000;
          default   :   seg <= 8'b1111_1111;
        endcase
  end
  
endmodule 