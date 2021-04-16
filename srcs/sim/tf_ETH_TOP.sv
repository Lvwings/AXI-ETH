`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/13 09:58:07
// Design Name: 
// Module Name: tf_ETH_TOP
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
module tb_ETH_TOP (); /* this is automatically generated */

	// clock
	logic sys_clk;
	initial begin
		sys_clk = '0;
		forever #(4) sys_clk = ~sys_clk;
	end

	// synchronous reset
	logic sys_rst;
	initial begin
		sys_rst <= '1;
		#20
		repeat (100) @(posedge sys_clk)
		sys_rst <= '0;
	end

	// (*NOTE*) replace reset, clock, others

	parameter             FPGA_MAC = 48'h00D0_0800_0002;
	parameter              FPGA_IP = 32'hC0A8_006E;
	parameter              FPGA_DP = 16'd8080;
	parameter              FPGA_SP = 16'd8080;
	parameter       C_AXI_ID_WIDTH = 4;
	parameter     C_AXI_ADDR_WIDTH = 32;
	parameter     C_AXI_DATA_WIDTH = 64;
	parameter C_AXI_NBURST_SUPPORT = 1'b0;
	parameter     C_AXI_BURST_TYPE = 2'b00;
	parameter      WATCH_DOG_WIDTH = 12;
	parameter           FLAG_MOTOR = 32'hE1EC_0C0D;
	parameter              FLAG_AD = 32'hAD86_86DA;
	parameter     C_ADDR_SUMOFFSET = 32'h0000_1000;
	parameter     C_ADDR_MOTOR2ETH = 32'h0000_0000;
	parameter        C_ADDR_AD2ETH = 32'h1000_0000;
	parameter     C_ADDR_ETH2MOTOR = 32'hE000_0000;
	parameter        C_ADDR_ETH2AD = 32'hF000_0000;

	logic                          m_axi_wready;
	logic     [C_AXI_ID_WIDTH-1:0] m_axi_wid;
	logic   [C_AXI_ADDR_WIDTH-1:0] m_axi_waddr;
	logic                    [7:0] m_axi_wlen;
	logic                    [2:0] m_axi_wsize;
	logic                    [1:0] m_axi_wburst;
	logic                    [1:0] m_axi_wlock;
	logic                    [3:0] m_axi_wcache;
	logic                    [2:0] m_axi_wprot;
	logic                          m_axi_wvalid;
	logic                    [3:0] m_axi_wqos;
	logic                          m_axi_wd_wready;
	logic   [C_AXI_DATA_WIDTH-1:0] m_axi_wd_wdata;
	logic [C_AXI_DATA_WIDTH/8-1:0] m_axi_wd_wstrb;
	logic                          m_axi_wd_wlast;
	logic                          m_axi_wd_wvalid;
	logic     [C_AXI_ID_WIDTH-1:0] m_axi_wb_bid;
	logic                    [1:0] m_axi_wb_bresp;
	logic                          m_axi_wb_bvalid;
	logic                          m_axi_wb_bready;
	logic                          m_axi_rready;
	logic     [C_AXI_ID_WIDTH-1:0] m_axi_rid;
	logic   [C_AXI_ADDR_WIDTH-1:0] m_axi_raddr;
	logic                    [7:0] m_axi_rlen;
	logic                    [2:0] m_axi_rsize;
	logic                    [1:0] m_axi_rburst;
	logic                    [1:0] m_axi_rlock;
	logic                    [3:0] m_axi_rcache;
	logic                    [2:0] m_axi_rprot;
	logic                          m_axi_rvalid;
	logic                    [3:0] m_axi_rqos;
	logic     [C_AXI_ID_WIDTH-1:0] m_axi_rd_bid;
	logic                    [1:0] m_axi_rd_rresp;
	logic                          m_axi_rd_rvalid;
	logic   [C_AXI_DATA_WIDTH-1:0] m_axi_rd_rdata;
	logic                          m_axi_rd_rlast;
	logic                          m_axi_rd_rready;
	logic                          s_axi_wready;
	logic     [C_AXI_ID_WIDTH-1:0] s_axi_wid;
	logic   [C_AXI_ADDR_WIDTH-1:0] s_axi_waddr;
	logic                    [7:0] s_axi_wlen;
	logic                    [2:0] s_axi_wsize;
	logic                    [1:0] s_axi_wburst;
	logic                    [1:0] s_axi_wlock;
	logic                    [3:0] s_axi_wcache;
	logic                    [2:0] s_axi_wprot;
	logic                          s_axi_wvalid;
	logic                    [3:0] s_axi_wqos;
	logic                          s_axi_wd_wready;
	logic   [C_AXI_DATA_WIDTH-1:0] s_axi_wd_wdata;
	logic [C_AXI_DATA_WIDTH/8-1:0] s_axi_wd_wstrb;
	logic                          s_axi_wd_wlast;
	logic                          s_axi_wd_wvalid;
	logic     [C_AXI_ID_WIDTH-1:0] s_axi_wb_bid;
	logic                    [1:0] s_axi_wb_bresp;
	logic                          s_axi_wb_bvalid;
	logic                          s_axi_wb_bready;
	logic                          s_axi_rready;
	logic     [C_AXI_ID_WIDTH-1:0] s_axi_rid;
	logic   [C_AXI_ADDR_WIDTH-1:0] s_axi_raddr;
	logic                    [7:0] s_axi_rlen;
	logic                    [2:0] s_axi_rsize;
	logic                    [1:0] s_axi_rburst;
	logic                    [1:0] s_axi_rlock;
	logic                    [3:0] s_axi_rcache;
	logic                    [2:0] s_axi_rprot;
	logic                          s_axi_rvalid;
	logic                    [3:0] s_axi_rqos;
	logic     [C_AXI_ID_WIDTH-1:0] s_axi_rd_bid;
	logic                    [1:0] s_axi_rd_rresp;
	logic                          s_axi_rd_rvalid;
	logic   [C_AXI_DATA_WIDTH-1:0] s_axi_rd_rdata;
	logic                          s_axi_rd_rlast;
	logic                          s_axi_rd_rready;
	logic                    [7:0] rgmii_rx_data;
	logic                          rgmii_rx_valid;
	logic                          rgmii_rx_last;
	logic                          rgmii_rx_user;
	logic                          rgmii_rx_ready;
	logic                    [7:0] rgmii_tx_data;
	logic                          rgmii_tx_valid;
	logic                          rgmii_tx_last;
	logic                          rgmii_tx_user;
	logic                          rgmii_tx_ready;

	ETH_TOP #(
			.FPGA_MAC(FPGA_MAC),
			.FPGA_IP(FPGA_IP),
			.FPGA_DP(FPGA_DP),
			.FPGA_SP(FPGA_SP),
			.C_AXI_ID_WIDTH(C_AXI_ID_WIDTH),
			.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
			.C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
			.C_AXI_NBURST_SUPPORT(C_AXI_NBURST_SUPPORT),
			.C_AXI_BURST_TYPE(C_AXI_BURST_TYPE),
			.WATCH_DOG_WIDTH(WATCH_DOG_WIDTH),
			.FLAG_MOTOR(FLAG_MOTOR),
			.FLAG_AD(FLAG_AD),
			.C_ADDR_SUMOFFSET(C_ADDR_SUMOFFSET),
			.C_ADDR_MOTOR2ETH(C_ADDR_MOTOR2ETH),
			.C_ADDR_AD2ETH(C_ADDR_AD2ETH),
			.C_ADDR_ETH2MOTOR(C_ADDR_ETH2MOTOR),
			.C_ADDR_ETH2AD(C_ADDR_ETH2AD)
		) inst_ETH_TOP (
			.sys_clk         (sys_clk),
			.sys_rst         (sys_rst),
			.m_axi_wready    (m_axi_wready),
			.m_axi_wid       (m_axi_wid),
			.m_axi_waddr     (m_axi_waddr),
			.m_axi_wlen      (m_axi_wlen),
			.m_axi_wsize     (m_axi_wsize),
			.m_axi_wburst    (m_axi_wburst),
			.m_axi_wlock     (m_axi_wlock),
			.m_axi_wcache    (m_axi_wcache),
			.m_axi_wprot     (m_axi_wprot),
			.m_axi_wvalid    (m_axi_wvalid),
			.m_axi_wqos      (m_axi_wqos),
			.m_axi_wd_wready (m_axi_wd_wready),
			.m_axi_wd_wdata  (m_axi_wd_wdata),
			.m_axi_wd_wstrb  (m_axi_wd_wstrb),
			.m_axi_wd_wlast  (m_axi_wd_wlast),
			.m_axi_wd_wvalid (m_axi_wd_wvalid),
			.m_axi_wb_bid    (m_axi_wb_bid),
			.m_axi_wb_bresp  (m_axi_wb_bresp),
			.m_axi_wb_bvalid (m_axi_wb_bvalid),
			.m_axi_wb_bready (m_axi_wb_bready),
			.m_axi_rready    (m_axi_rready),
			.m_axi_rid       (m_axi_rid),
			.m_axi_raddr     (m_axi_raddr),
			.m_axi_rlen      (m_axi_rlen),
			.m_axi_rsize     (m_axi_rsize),
			.m_axi_rburst    (m_axi_rburst),
			.m_axi_rlock     (m_axi_rlock),
			.m_axi_rcache    (m_axi_rcache),
			.m_axi_rprot     (m_axi_rprot),
			.m_axi_rvalid    (m_axi_rvalid),
			.m_axi_rqos      (m_axi_rqos),
			.m_axi_rd_bid    (m_axi_rd_bid),
			.m_axi_rd_rresp  (m_axi_rd_rresp),
			.m_axi_rd_rvalid (m_axi_rd_rvalid),
			.m_axi_rd_rdata  (m_axi_rd_rdata),
			.m_axi_rd_rlast  (m_axi_rd_rlast),
			.m_axi_rd_rready (m_axi_rd_rready),
			.s_axi_wready    (s_axi_wready),
			.s_axi_wid       (s_axi_wid),
			.s_axi_waddr     (s_axi_waddr),
			.s_axi_wlen      (s_axi_wlen),
			.s_axi_wsize     (s_axi_wsize),
			.s_axi_wburst    (s_axi_wburst),
			.s_axi_wlock     (s_axi_wlock),
			.s_axi_wcache    (s_axi_wcache),
			.s_axi_wprot     (s_axi_wprot),
			.s_axi_wvalid    (s_axi_wvalid),
			.s_axi_wqos      (s_axi_wqos),
			.s_axi_wd_wready (s_axi_wd_wready),
			.s_axi_wd_wdata  (s_axi_wd_wdata),
			.s_axi_wd_wstrb  (s_axi_wd_wstrb),
			.s_axi_wd_wlast  (s_axi_wd_wlast),
			.s_axi_wd_wvalid (s_axi_wd_wvalid),
			.s_axi_wb_bid    (s_axi_wb_bid),
			.s_axi_wb_bresp  (s_axi_wb_bresp),
			.s_axi_wb_bvalid (s_axi_wb_bvalid),
			.s_axi_wb_bready (s_axi_wb_bready),
			.s_axi_rready    (s_axi_rready),
			.s_axi_rid       (s_axi_rid),
			.s_axi_raddr     (s_axi_raddr),
			.s_axi_rlen      (s_axi_rlen),
			.s_axi_rsize     (s_axi_rsize),
			.s_axi_rburst    (s_axi_rburst),
			.s_axi_rlock     (s_axi_rlock),
			.s_axi_rcache    (s_axi_rcache),
			.s_axi_rprot     (s_axi_rprot),
			.s_axi_rvalid    (s_axi_rvalid),
			.s_axi_rqos      (s_axi_rqos),
			.s_axi_rd_bid    (s_axi_rd_bid),
			.s_axi_rd_rresp  (s_axi_rd_rresp),
			.s_axi_rd_rvalid (s_axi_rd_rvalid),
			.s_axi_rd_rdata  (s_axi_rd_rdata),
			.s_axi_rd_rlast  (s_axi_rd_rlast),
			.s_axi_rd_rready (s_axi_rd_rready),
			.rgmii_rx_data   (rgmii_rx_data),
			.rgmii_rx_valid  (rgmii_rx_valid),
			.rgmii_rx_last   (rgmii_rx_last),
			.rgmii_rx_user   (rgmii_rx_user),
			.rgmii_rx_ready  (rgmii_rx_ready),
			.rgmii_tx_data   (rgmii_tx_data),
			.rgmii_tx_valid  (rgmii_tx_valid),
			.rgmii_tx_last   (rgmii_tx_last),
			.rgmii_tx_user   (rgmii_tx_user),
			.rgmii_tx_ready  (rgmii_tx_ready)
		);

	task init();
		m_axi_wready    <= '0;
		m_axi_wd_wready <= '0;
		m_axi_wb_bid    <= '0;
		m_axi_wb_bresp  <= '0;
		m_axi_wb_bvalid <= '0;
		m_axi_rready    <= '0;
		m_axi_rd_bid    <= '0;
		m_axi_rd_rresp  <= '0;
		m_axi_rd_rvalid <= '0;
		m_axi_rd_rdata  <= '0;
		m_axi_rd_rlast  <= '0;
		rgmii_rx_data   <= '0;
		rgmii_rx_valid  <= '0;
		rgmii_rx_last   <= '0;
		rgmii_rx_user   <= '0;
		s_axi_wid       <= '0;
		s_axi_waddr     <= '0;
		s_axi_wlen      <= '0;
		s_axi_wsize     <= '0;
		s_axi_wburst    <= '0;
		s_axi_wlock     <= '0;
		s_axi_wcache    <= '0;
		s_axi_wprot     <= '0;
		s_axi_wvalid    <= '0;
		s_axi_wd_wdata  <= '0;
		s_axi_wd_wstrb  <= '0;
		s_axi_wd_wlast  <= '0;
		s_axi_wd_wvalid <= '0;
		s_axi_wb_bready <= '0;
		s_axi_rid       <= '0;
		s_axi_raddr     <= '0;
		s_axi_rlen      <= '0;
		s_axi_rsize     <= '0;
		s_axi_rburst    <= '0;
		s_axi_rlock     <= '0;
		s_axi_rcache    <= '0;
		s_axi_rprot     <= '0;
		s_axi_rvalid    <= '0;
		s_axi_rd_rready <= '0;
		rgmii_tx_ready  <= '0;
	endtask

	task drive(int iter);
		for(int it = 0; it < iter; it++) begin
			m_axi_wready    <= '0;
			m_axi_wd_wready <= '0;
			m_axi_wb_bid    <= '0;
			m_axi_wb_bresp  <= '0;
			m_axi_wb_bvalid <= '0;
			m_axi_rready    <= '0;
			m_axi_rd_bid    <= '0;
			m_axi_rd_rresp  <= '0;
			m_axi_rd_rvalid <= '0;
			m_axi_rd_rdata  <= '0;
			m_axi_rd_rlast  <= '0;
			rgmii_rx_data   <= '0;
			rgmii_rx_valid  <= '0;
			rgmii_rx_last   <= '0;
			rgmii_rx_user   <= '0;
			s_axi_wid       <= '0;
			s_axi_waddr     <= '0;
			s_axi_wlen      <= '0;
			s_axi_wsize     <= '0;
			s_axi_wburst    <= '0;
			s_axi_wlock     <= '0;
			s_axi_wcache    <= '0;
			s_axi_wprot     <= '0;
			s_axi_wvalid    <= '0;
			s_axi_wd_wdata  <= '0;
			s_axi_wd_wstrb  <= '0;
			s_axi_wd_wlast  <= '0;
			s_axi_wd_wvalid <= '0;
			s_axi_wb_bready <= '0;
			s_axi_rid       <= '0;
			s_axi_raddr     <= '0;
			s_axi_rlen      <= '0;
			s_axi_rsize     <= '0;
			s_axi_rburst    <= '0;
			s_axi_rlock     <= '0;
			s_axi_rcache    <= '0;
			s_axi_rprot     <= '0;
			s_axi_rvalid    <= '0;
			s_axi_rd_rready <= '0;
			rgmii_tx_ready  <= '0;
			@(posedge sys_clk);
		end
	endtask

	initial begin
		// do something
		init();
		m_axi_wready     <= '1;
		m_axi_wb_bid     <= '0;
		m_axi_wb_bresp   <= '0;
		m_axi_wb_bvalid  <= '1;			
	end

parameter   PREAMBLE_REG    =   64'h5555_5555_5555_55d5,    //  前导码
            PREAMBLE_WORD   =   5'd8,
            //------------以太网首部-----------------
            ETH_DA_MAC      =   48'h00D0_0800_0002,         //  目的MAC地址，FPGA板的MAC
            ETH_SA_MAC      =   48'h0024_7EDF_CA5E,         //  源MAC地址，上位机MAC
            ETH_TYPE        =   16'h0800,                   //  帧类型
            ARP_TYPE		=	16'h0806, 
            //-------------IP首部----------------------
            IP_VS_LEN_TOS   =   16'h4500,                   //  IP版本(4)+首部长度(20)+服务类型
            IP_FLAG_OFFSET  =   16'h4000,                   //  IP标志+帧偏移
            IP_TTL_PROTO    =   16'h8011,                   //  IP帧生存时间+协议
            IP_SUM          =   16'h0000,
            IP_DA           =   {8'd192,8'd168,8'd0,8'd110},              //  目的IP地址
            IP_SA           =   {8'd192,8'd168,8'd0,8'd119},              //  源IP地址

            //-------------UDP首部---------------------
			UDP_DP   		= 	16'd8080,
			UDP_SP   		= 	16'd8080,
            UDP_LEN         =   16'd0028,                   //  UDP长度8字节
            UDP_SUM         =   16'h0000,                   //  UDP校验和

            //-------------数据---------------------
            DATA_FLAG       =   32'hEEBA_EEBA,              //  固定字节，用于数据标识
            DATA_RX         =   128'h1234_5611_1134_5678_1234_5678_AABB_CCDD,
            DATA_WORD       =   5'd20,
			//-------------ARP---------------------
			ARP_DA_MAC		=	48'hFFFF_FFFF_FFFF,
			ARP_SA_MAC		=	48'h0024_7EDF_CA5E, 
 
			ARP_HEAD		=	64'h0001_0800_0604_0001,
			ARP_Z			=	144'h0,
			ARP_CRC			=	32'h59FB_0258,
			//-------------ICMP---------------------
			ICMP_DATA		=	256'h6162_6364_6566_6768_696a_6b6c_6d6e_6f70_7172_7374_7576_7761_6263_6465_6667_6869,
            ICMP_TYPECODE	=	16'h0800,
			ICMP_CKS		=	16'h4d56,
			ICMP_IDF		=	16'h0001,
			ICMP_SEQ		=	16'h0005,
			ICMP_CRC		=	32'hC034_2A1A,
			//-------------CRC---------------------
            CRC_WORD        =   5'd4,
            CRC_RX          =   32'hCFD9_3530;

    reg [527:0] DATA_OUT   =   0,
                DATA_OUT_D  =   0;
	reg [511:0] ARP_OUT		=	0,
				ARP_OUT_D	=	0;
	reg [623:0] ICMP_OUT	=	0,
				ICMP_OUT_D	=	0;
    reg [15:0]  DATA_CNT    =   0;
 	
	reg	[7:0]	FRAME_ARP_CNT	=	0,
				FRAME_ICMP_CNT	=	0,
				FRAME_UDP_CNT	=	0;

	reg	IS_ARP	=	0,
		IS_ICMP	=	0,
		IS_UDP	=	0;
	reg	[3:0]	rgmii_tx_cnt=	0;


//-----------ETH FARME ------------------- 
always  @ (posedge sys_clk) begin
    if (sys_rst) begin      
        DATA_OUT  	<=  {ETH_DA_MAC,ETH_SA_MAC,ETH_TYPE,IP_VS_LEN_TOS,(UDP_LEN+16'd20),16'h0012,IP_FLAG_OFFSET,IP_TTL_PROTO,IP_SUM,IP_SA,IP_DA,UDP_SP,UDP_DP,UDP_LEN,UDP_SUM,DATA_FLAG,DATA_RX,CRC_RX};
		ARP_OUT		<=	{ARP_DA_MAC,ARP_SA_MAC,ARP_TYPE,ARP_HEAD,ARP_SA_MAC,IP_SA,48'h0,IP_DA,ARP_Z,ARP_CRC};
		ICMP_OUT	<=	{ETH_DA_MAC,ETH_SA_MAC,ETH_TYPE,IP_VS_LEN_TOS,16'h003c,16'h71A0,16'h0000,16'h8001,16'h0000,IP_SA,IP_DA,ICMP_TYPECODE,ICMP_CKS,ICMP_IDF,ICMP_SEQ,ICMP_DATA,ICMP_CRC};
	end
    else begin
		if (FRAME_UDP_CNT == 0 && !IS_ARP && !IS_ICMP && !IS_UDP) begin	// GO ICMP
			IS_ARP	<=	0;
			IS_ICMP	<=	0;
			IS_UDP	<=	1;			
		end		
		else if (FRAME_ARP_CNT == 5) begin	// GO ICMP
			FRAME_ARP_CNT	<=	0;
			IS_ARP	<=	0;
			IS_ICMP	<=	1;
			IS_UDP	<=	0;			
		end
		else if (FRAME_ICMP_CNT == 5) begin	// GO UDP
			FRAME_ICMP_CNT	<=	0;
			IS_ARP	<=	0;
			IS_ICMP	<=	0;
			IS_UDP	<=	1;	
		end	
		else if (FRAME_UDP_CNT == 5) begin	//	GO ARP
			FRAME_UDP_CNT	<=	0;
			IS_ARP	<=	1;
			IS_ICMP	<=	0;
			IS_UDP	<=	0;	
		end
		else begin
			IS_ARP	<=	IS_ARP;
			IS_ICMP	<=	IS_ICMP;
			IS_UDP	<=	IS_UDP;	
		end			
//----------------------ARP------------------------ 
		if (IS_ARP) begin
			if (DATA_CNT == 200) begin
				DATA_CNT      <= 0;
				ARP_OUT_D     <=  ARP_OUT;
				FRAME_ARP_CNT <=  FRAME_ARP_CNT + 1;
			end
			else if (DATA_CNT >= 63) begin
				DATA_CNT       <=   DATA_CNT + 1;
				rgmii_rx_last  <=  DATA_CNT == 63;
				rgmii_rx_valid <=  	0;
			end
			else begin      
				
				rgmii_rx_valid <=  1;
				
				
				if (rgmii_rx_valid && rgmii_rx_ready) begin   
					DATA_CNT      <= DATA_CNT + 1;
					if (DATA_CNT == 1) begin 
						ARP_OUT_D     <= ARP_OUT_D << 16;
						rgmii_rx_data <= ARP_OUT_D[503:496];						
					end
					else begin 
						ARP_OUT_D     <= ARP_OUT_D << 8;
						rgmii_rx_data <= ARP_OUT_D[511:504];
					end
				end			
				else if (DATA_CNT == 0) begin 
					DATA_CNT      <= 1;
					rgmii_rx_data <= ARP_OUT_D[511:504];
				end
				else begin
					DATA_CNT      <= DATA_CNT;
					ARP_OUT_D     <= ARP_OUT_D;
					rgmii_rx_data <= rgmii_rx_data;
				end
			end  
		end	
//----------------------ICMP------------------------ 
		else if (IS_ICMP) begin
			if (DATA_CNT == 200) begin
				DATA_CNT       <= 0;
				ICMP_OUT_D     <=  ICMP_OUT;
				FRAME_ICMP_CNT <=  FRAME_ICMP_CNT + 1;
			end
			else if (DATA_CNT >= 77) begin
				DATA_CNT       <=   DATA_CNT + 1;
				rgmii_rx_last  <=  DATA_CNT == 77;
				rgmii_rx_valid <=  0;
			end
			else begin
				
				rgmii_rx_valid <=  1;
				
				   
				if (rgmii_rx_valid && rgmii_rx_ready) begin   
					DATA_CNT      <= DATA_CNT + 1;
					if (DATA_CNT == 1) begin 
						ICMP_OUT_D     <= ICMP_OUT_D << 16;
						rgmii_rx_data  <=  ICMP_OUT_D[615:608];
					end						
					else begin 
						ICMP_OUT_D     <= ICMP_OUT_D << 8;
						rgmii_rx_data  <=  ICMP_OUT_D[623:616];						
					end
				end
				else if (DATA_CNT == 0) begin 
					DATA_CNT      <= 1;
					rgmii_rx_data <= ICMP_OUT_D[623:616];
				end				
				else begin
					DATA_CNT      <= DATA_CNT;
					ICMP_OUT_D     <= ICMP_OUT_D;
					rgmii_rx_data <= rgmii_rx_data;
				end
			end 
		end	
//----------------------UDP------------------------ 
		else if (IS_UDP) begin
			 if (DATA_CNT == 200) begin
				DATA_CNT       <= 0;
				DATA_OUT_D     <=  DATA_OUT;               
				FRAME_UDP_CNT  <=  FRAME_UDP_CNT + 1;                
			end
			else if (DATA_CNT >= 68 ) begin
				rgmii_rx_valid <=  0;
				rgmii_rx_last  <=  DATA_CNT == 68; 
				DATA_CNT       <=   DATA_CNT + 1;
			end
			else begin
			
					rgmii_rx_valid <=  1;
					             

				if (rgmii_rx_valid && rgmii_rx_ready) begin   
					DATA_CNT      <= DATA_CNT + 1;
					if (DATA_CNT == 1) begin 
						DATA_OUT_D     <= DATA_OUT_D << 16;
						rgmii_rx_data  <=  DATA_OUT_D[519:512];
					end						
					else begin 
						DATA_OUT_D     <= DATA_OUT_D << 8;
						rgmii_rx_data  <=  DATA_OUT_D[527:520];					
					end
				end
				else if (DATA_CNT == 0) begin 
					DATA_CNT      <= 1;
					rgmii_rx_data <= DATA_OUT_D[527:520];
				end				
				else begin
					DATA_CNT      <= DATA_CNT;
					DATA_OUT_D     <= DATA_OUT_D;
					rgmii_rx_data <= rgmii_rx_data;
				end				
			end
		end		
    end
end	


	assign	rgmii_tx_ready = rgmii_tx_valid;

	localparam	W_IDLE	=	4'd0,
				W_ADDR	=	4'd1,
				W_DATA 	=	4'd2,
				W_RESP 	=	4'd3;

	reg [3:0]	write_state	=	0,
				write_next 	=	0;

	always @(posedge sys_clk) begin
		if(sys_rst) begin
			write_state <= 1;
		end else begin
			write_state	<= write_next;
		end
	end

	always @(*) begin 
		write_next = 0;
		case (1)
			write_state[W_IDLE]	:	begin 
				write_next[W_ADDR]	=	1;
			end

			write_state[W_ADDR]	:	begin 
				if (s_axi_wvalid && s_axi_wready)
					write_next[W_DATA]	=	1;
				else
					write_next[W_ADDR]	=	1;
			end

			write_state[W_DATA]	:	begin 
				if (s_axi_wd_wvalid && s_axi_wd_wready && s_axi_wd_wlast)
					write_next[W_RESP]	=	1;
				else
					write_next[W_DATA]	=	1;
			end

			write_state[W_RESP]	:	begin 
				if (s_axi_wb_bready && s_axi_wb_bvalid)
					write_next[W_IDLE]	=	1;
				else
					write_next[W_RESP]	=	1;
			end
			default : /* default */;
		endcase
	end				

	reg	flag_sum	=	1'b0;
	always_ff @(posedge sys_clk) begin
		if(sys_rst) begin
			s_axi_waddr  <= '0;
			s_axi_wlen   <= '0;
			s_axi_wvalid <= '0;
			flag_sum   <=  0;
		end else begin
			if (write_state[W_ADDR] && !s_axi_wready) begin
				s_axi_waddr	<=	flag_sum ? C_ADDR_AD2ETH : C_ADDR_AD2ETH + C_ADDR_SUMOFFSET;
				s_axi_wlen	<=	flag_sum ? 0 : 32-1;
				s_axi_wvalid	<=	1;
			end
			else begin 
				s_axi_waddr      <= '0;
				s_axi_wlen       <= s_axi_wlen;
				s_axi_wvalid     <= '0;
			end

			if (write_state[W_IDLE] && write_next[W_ADDR])
				flag_sum	<=	~flag_sum;
			else
				flag_sum	<=	flag_sum;
		end
	end

	localparam	DATASUM	=	32'h0006_B975;
	reg	[7:0]	data_cnt	=	0;
	always_ff @(posedge sys_clk) begin
		if(sys_rst) begin
			s_axi_wd_wdata   <= '0;
			s_axi_wd_wstrb   <= '0;
			s_axi_wd_wlast   <= '0;
			s_axi_wd_wvalid  <= '0;
			data_cnt	<=	0;
		end else begin
			if (write_state[W_DATA]) begin 
				if (flag_sum) begin 
					if (!s_axi_wd_wready) begin 
						s_axi_wd_wdata	<=	DATASUM;
						data_cnt	<=	1;
					end						
					else if (s_axi_wd_wvalid && s_axi_wd_wready) begin
						if (C_AXI_DATA_WIDTH < 32)
							s_axi_wd_wdata	<=	DATASUM[31 - data_cnt*C_AXI_DATA_WIDTH -: C_AXI_DATA_WIDTH];
						else
							s_axi_wd_wdata	<=	DATASUM;
						data_cnt	<=	data_cnt + 1;
					end						
					else
						data_cnt	<=	data_cnt;
					
					if (C_AXI_DATA_WIDTH < 32) begin 
						s_axi_wd_wvalid	<=	data_cnt <= s_axi_wlen;
						s_axi_wd_wlast	<=	(data_cnt == s_axi_wlen) && s_axi_wd_wvalid && s_axi_wd_wready;						
					end
					else begin 
						s_axi_wd_wvalid	<=	(data_cnt == 1) && !s_axi_wd_wready;
						s_axi_wd_wlast	<=	(data_cnt == 1) && !s_axi_wd_wready;						
					end					
				end
				else begin 
					if (s_axi_wd_wvalid && s_axi_wd_wready)
						data_cnt	<=	data_cnt + 1;
					else
						data_cnt	<=	data_cnt;

					s_axi_wd_wdata	<=	data_cnt;
					s_axi_wd_wvalid	<=	1;
					s_axi_wd_wlast	<=	(data_cnt == s_axi_wlen);										
				end
			end
			else begin 
				s_axi_wd_wdata   <= '0;
				s_axi_wd_wstrb   <= '0;
				s_axi_wd_wlast   <= '0;
				s_axi_wd_wvalid  <= '0;
				data_cnt	<=	0;
			end
		end
	end

	always_ff @(posedge sys_clk) begin
			if(sys_rst) begin
				 s_axi_wb_bready  <= '0;
			end else begin
				 if (write_state[W_RESP])
				 	s_axi_wb_bready	<=	s_axi_wb_bvalid;
				 else
				 	s_axi_wb_bready	<=	0;
			end
		end	

	always_ff @(posedge sys_clk) begin
			if(sys_rst) begin
				m_axi_wd_wready  <= '0;
			end else begin
				m_axi_wd_wready	 <= m_axi_wd_wvalid;
			end
		end			
endmodule

