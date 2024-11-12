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
    input	         sys_clk,                   //ϵͳʱ��
    input            sys_rst_n,                 //ϵͳ��λ���͵�ƽ��Ч

    input       [3:0]   key,                     //��������
     
    input            recv_done,                 //����һ֡������ɱ�־
    input      [7:0] recv_data,                 //���յ�����
     
    input            tx_busy,                   //����æ״̬��־      
    output reg       send_en,                   //����ʹ���ź�
    output reg [7:0] send_data                  //����������
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

//����recv_done�����أ��õ�һ��ʱ�����ڵ������ź�
assign recv_done_flag = (~recv_done_d1) & recv_done_d0;
                                                 
//�Է���ʹ���ź�recv_done�ӳ�����ʱ������
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

// //�жϽ�������źţ����ڴ��ڷ���ģ�����ʱ��������ʹ���ź�
// always @(posedge sys_clk or negedge sys_rst_n) begin         
//     if (!sys_rst_n) begin
//         tx_ready  <= 1'b0; 
//         send_en   <= 1'b0;
//         send_data <= 8'd0;
//     end                                                      
//     else begin                                               
//         if(recv_done_flag)begin                 //��⴮�ڽ��յ�����
//             tx_ready  <= 1'b1;                  //׼���������͹���
//             send_en   <= 1'b0;
//             send_data <= recv_data;             //�Ĵ洮�ڽ��յ�����
//         end
//         else if(tx_ready && (~tx_busy)) begin   //��⴮�ڷ���ģ�����
//             tx_ready <= 1'b0;                   //׼�����̽���
//             send_en  <= 1'b1;                   //���߷���ʹ���ź�
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
