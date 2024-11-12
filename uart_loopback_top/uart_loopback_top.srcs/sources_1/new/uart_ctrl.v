`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/10 14:32:38
// Design Name: 
// Module Name: uart_ctrl
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


module uart_ctrl(
    input	         sys_clk,                   //系统时钟
    input            sys_rst_n,                 //系统复位，低电平有效

    input       [3:0]   key,                     //按键输入
     
    input            recv_done,                 //接收一帧数据完成标志
    input      [7:0] recv_data,                 //接收的数据
     
    input            tx_busy,                   //发送忙状态标志      
    output reg       send_en,                   //发送使能信号
    output reg [7:0] send_data                  //待发送数据
);

//reg define
reg recv_done_d0;
reg recv_done_d1;
reg tx_ready;
reg [7:0] money_input;

//wire define
wire recv_done_flag;

//*****************************************************
//**                    main code
//*****************************************************

//捕获recv_done上升沿，得到一个时钟周期的脉冲信号
assign recv_done_flag = (~recv_done_d1) & recv_done_d0;
                                                 
//对发送使能信号recv_done延迟两个时钟周期
always @(posedge sys_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) begin
        recv_done_d0 <= 1'b0;                                  
        recv_done_d1 <= 1'b0;
    end                                                      
    else begin                                               
        recv_done_d0 <= recv_done;                               
        recv_done_d1 <= recv_done_d0;                            
    end
end

// //判断接收完成信号，并在串口发送模块空闲时给出发送使能信号
// always @(posedge sys_clk or negedge sys_rst_n) begin         
//     if (!sys_rst_n) begin
//         tx_ready  <= 1'b0; 
//         send_en   <= 1'b0;
//         send_data <= 8'd0;
//     end                                                      
//     else begin                                               
//         if(recv_done_flag)begin                 //检测串口接收到数据
//             tx_ready  <= 1'b1;                  //准备启动发送过程
//             send_en   <= 1'b0;
//             send_data <= recv_data;             //寄存串口接收的数据
//         end
//         else if(tx_ready && (~tx_busy)) begin   //检测串口发送模块空闲
//             tx_ready <= 1'b0;                   //准备过程结束
//             send_en  <= 1'b1;                   //拉高发送使能信号
//         end
//     end
// end

localparam  STA_IDLE = 0,
            STA_UART_RECEIVE = 1,
            STA_KEY_RECEIVE = 2,
            STA_UART_SEND = 3;

reg     [1:0]   STA_NOW;
reg     [1:0]   STA_NEXT;


always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        STA_NOW <= STA_IDLE;
    end
    else begin
        STA_NOW <= STA_NEXT;
    end
end

always@(*) begin
    case(STA_NOW)
        STA_IDLE: begin
            if(recv_done_flag) begin
                STA_NEXT    =   STA_UART_RECEIVE;
            end
            else begin
                STA_NEXT    =   STA_IDLE;
            end
        end
        STA_UART_RECEIVE: begin
            if(key != 4'b1111) begin
                STA_NEXT    =   STA_KEY_RECEIVE;
            end
            else begin
                STA_NEXT    =   STA_UART_RECEIVE;
            end
        end
        STA_KEY_RECEIVE: begin
            STA_NEXT    =   STA_UART_SEND;
        end
        STA_UART_SEND: begin
            STA_NEXT    =   STA_IDLE;
        end
        default: begin
            STA_NEXT    =   STA_IDLE;
        end
    endcase
end

always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        money_input <= 8'd0;
    end
    else begin
        case(key)
            4'b1110: begin
                money_input <= 8'd4;
            end
            4'b1101: begin
                money_input <= 8'd6;
            end
            4'b1011: begin
                money_input <= 8'd8;
            end
            4'b0111: begin
                money_input <= 8'd10;
            end
        endcase
    end
end

always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        send_en <= 1'b0;
        send_data <= 8'd0;
    end
    else begin
        case(STA_NOW)
            STA_KEY_RECEIVE: begin
                send_en <= 1'b1;
                send_data <= money_input - recv_data;
            end
            default: begin
                send_en <= 1'b0;
            end
        endcase
    end
end

endmodule 
