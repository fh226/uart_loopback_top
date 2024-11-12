module uart_loopback_top(
    input           sys_clk,            //�ⲿ50Mʱ��
    input           sys_rst_n,          //�ⲿ��λ�źţ�����Ч

    input   [3:0]   key,                //��������

    input           uart_rxd,           //UART���ն˿�
    output          uart_txd ,           //UART���Ͷ˿�
    output[5:0]        seg_sel,
    output[7:0]          seg_led
);

//parameter define
parameter  CLK_FREQ = 50000000;         //����ϵͳʱ��Ƶ��
parameter  UART_BPS = 115200;           //���崮�ڲ�����
    
//wire define   
wire       uart_recv_done;              //UART�������
wire [7:0] uart_recv_data;              //UART��������
wire       uart_send_en;                //UART����ʹ��
wire [7:0] uart_send_data;              //UART��������
wire       uart_tx_busy;                //UART����æ״̬��־

//*****************************************************
//**                    main code
//*****************************************************

//���ڽ���ģ��     
uart_recv #(                          
    .CLK_FREQ       (CLK_FREQ),         //����ϵͳʱ��Ƶ��
    .UART_BPS       (UART_BPS)          //���ô��ڽ��ղ�����
)u_uart_recv(                 
    .sys_clk        (sys_clk), 
    .sys_rst_n      (sys_rst_n),
    
    .uart_rxd       (uart_rxd),
    .uart_done      (uart_recv_done),
    .uart_data      (uart_recv_data)
);

//���ڷ���ģ��    
uart_send #(                          
    .CLK_FREQ       (CLK_FREQ),         //����ϵͳʱ��Ƶ��
    .UART_BPS       (UART_BPS)          //���ô��ڷ��Ͳ�����
)u_uart_send(                 
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
     
    .uart_en        (uart_send_en),
    .uart_din       (uart_send_data),
    .uart_tx_busy   (uart_tx_busy),
    .uart_txd       (uart_txd)
);

//���ڿ���ģ��    
uart_ctrl u_uart_ctrl(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),

    .key            (key),
   
    .recv_done      (uart_recv_done),   //����һ֡������ɱ�־�ź�
    .recv_data      (uart_recv_data),   //���յ�����
   
    .tx_busy        (uart_tx_busy),     //����æ״̬��־      
    .send_en        (uart_send_en),     //����ʹ���ź�
    .send_data      (uart_send_data)    //����������
);

//��ʾģ��
seven_tube_drive seven_tube_drive_t1(
    .clk            (sys_clk),
    .rst_n          (sys_rst_n),
    .data           ({uart_recv_data,8'b0,uart_send_data}),
    .sel            (seg_sel),   
    .seg            (seg_led)
);



endmodule