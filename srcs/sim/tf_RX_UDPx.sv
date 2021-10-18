`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/07 16:50:05
// Design Name: 
// Module Name: tf_RX_UDPx
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


module tb_RX_UDP (); /* this is automatically generated */

	// clock
	logic clk;
	initial begin
		clk = '0;
		forever #(4) clk = ~clk;
	end

	// reset
	logic rstb;
	logic srst;	
	initial begin
		rstb <= '0;
		srst <= '0;
		#20
		rstb <= '1;
		repeat (5) @(posedge clk);
		srst <= '1;
		repeat (1) @(posedge clk);
		srst <= '0;
	end

	// (*NOTE*) replace reset, clock, others
	// (*NOTE*) replace reset, clock, others

	parameter              FPGA_MAC = 48'h00D0_0800_0002;
	parameter               FPGA_IP = 32'hC0A8_006E;
	parameter               FPGA_DP = 16'd8080;
	parameter               FPGA_SP = 16'd8080;
	parameter        C_AXI_ID_WIDTH = 4;
	parameter      C_AXI_ADDR_WIDTH = 32;
	parameter      C_AXI_DATA_WIDTH = 64;
	parameter  C_AXI_NBURST_SUPPORT = 1'b0;
	parameter      C_AXI_BURST_TYPE = 2'b00;
	parameter       WATCH_DOG_WIDTH = 12;
	parameter            FLAG_MOTOR = 32'hE1EC_0C0D;
	parameter               FLAG_AD = 32'hAD86_86DA;
	parameter      C_ADDR_SUMOFFSET = 32'h0000_1000;
	parameter      C_ADDR_MOTOR2ETH = 32'h0000_0000;
	parameter         C_ADDR_AD2ETH = 32'h1000_0000;
	parameter      C_ADDR_ETH2MOTOR = 32'hE000_0000;
	parameter         C_ADDR_ETH2AD = 32'hF000_0000;
	localparam       [2:0] AXI_SIZE = clogb2(C_AXI_DATA_WIDTH/8-1);
	localparam   [7:0] AXI_ADDR_INC = C_AXI_DATA_WIDTH/8;
	localparam     [3:0] WRITE_IDLE = 4'd0;
	localparam  [3:0] RX_ETH_HEADER = 4'd1;
	localparam   [3:0] RX_IP_HEADER = 4'd2;
	localparam  [3:0] RX_UDP_HEADER = 4'd3;
	localparam         [3:0] RX_ARP = 4'd4;
	localparam     [3:0] WRITE_ADDR = 4'd5;
	localparam     [3:0] WRITE_DATA = 4'd6;
	localparam [3:0] WRITE_RESPONSE = 4'd7;
	localparam [3:0] WRITE_TIME_OUT = 4'd8;
	localparam              IP_TYPE = 16'h0800;
	localparam             ARP_TYPE = 16'h0806;
	localparam             ETH_WORD = 8'd14;
	localparam            IP_VISION = 8'h45;
	localparam            UDP_PROTO = 8'h11;
	localparam           ICMP_PROTO = 8'h01;
	localparam              IP_WORD = 8'd20;
	localparam             UDP_WORD = 8'd8;
	localparam            FLAG_WORD = 8'd4;
	localparam             ARP_WORD = 8'd28;
	localparam          ARP_REQUEST = 16'h0001;
	localparam             PING_REQ = 8'h08;
	localparam            ICMP_WORD = 8'd40;
	localparam      [3:0] READ_IDLE = 4'd0;
	localparam      [3:0] READ_ADDR = 4'd1;
	localparam      [3:0] READ_DATA = 4'd2;
	localparam  [3:0] READ_TIME_OUT = 4'd3;

	logic                          sys_rst;
	logic                          axi_wready;
	logic     [C_AXI_ID_WIDTH-1:0] axi_wid;
	logic   [C_AXI_ADDR_WIDTH-1:0] axi_waddr;
	logic                    [7:0] axi_wlen;
	logic                    [2:0] axi_wsize;
	logic                    [1:0] axi_wburst;
	logic                    [1:0] axi_wlock;
	logic                    [3:0] axi_wcache;
	logic                    [2:0] axi_wprot;
	logic                          axi_wvalid;
	logic                          axi_wd_wready;
	logic   [C_AXI_DATA_WIDTH-1:0] axi_wd_wdata;
	logic [C_AXI_DATA_WIDTH/8-1:0] axi_wd_wstrb;
	logic                          axi_wd_wlast;
	logic                          axi_wd_wvalid;
	logic     [C_AXI_ID_WIDTH-1:0] axi_wb_bid;
	logic                    [1:0] axi_wb_bresp;
	logic                          axi_wb_bvalid;
	logic                          axi_wb_bready;
	logic                          axi_rready;
	logic     [C_AXI_ID_WIDTH-1:0] axi_rid;
	logic   [C_AXI_ADDR_WIDTH-1:0] axi_raddr;
	logic                    [7:0] axi_rlen;
	logic                    [2:0] axi_rsize;
	logic                    [1:0] axi_rburst;
	logic                    [1:0] axi_rlock;
	logic                    [3:0] axi_rcache;
	logic                    [2:0] axi_rprot;
	logic                          axi_rvalid;
	logic     [C_AXI_ID_WIDTH-1:0] axi_rd_bid;
	logic                    [1:0] axi_rd_rresp;
	logic                          axi_rd_rvalid;
	logic   [C_AXI_DATA_WIDTH-1:0] axi_rd_rdata;
	logic                          axi_rd_rlast;
	logic                          axi_rd_rready;
	logic                    [7:0] rgmii_rx_data;
	logic                          rgmii_rx_valid;
	logic                          rgmii_rx_last;
	logic                          rgmii_rx_user;
	logic                          rgmii_rx_ready;
	logic                   [47:0] pc_mac;
	logic                   [31:0] pc_ip;
	logic                          trig_package_rst;
	logic                          trig_arp;

	RX_UDP #(
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
		) inst_RX_UDP (
			.sys_clk          (clk),
			.sys_rst          (sys_rst),
			.axi_wready       (axi_wready),
			.axi_wid          (axi_wid),
			.axi_waddr        (axi_waddr),
			.axi_wlen         (axi_wlen),
			.axi_wsize        (axi_wsize),
			.axi_wburst       (axi_wburst),
			.axi_wlock        (axi_wlock),
			.axi_wcache       (axi_wcache),
			.axi_wprot        (axi_wprot),
			.axi_wvalid       (axi_wvalid),
			.axi_wd_wready    (axi_wd_wready),
			.axi_wd_wdata     (axi_wd_wdata),
			.axi_wd_wstrb     (axi_wd_wstrb),
			.axi_wd_wlast     (axi_wd_wlast),
			.axi_wd_wvalid    (axi_wd_wvalid),
			.axi_wb_bid       (axi_wb_bid),
			.axi_wb_bresp     (axi_wb_bresp),
			.axi_wb_bvalid    (axi_wb_bvalid),
			.axi_wb_bready    (axi_wb_bready),
			.axi_rready       (axi_rready),
			.axi_rid          (axi_rid),
			.axi_raddr        (axi_raddr),
			.axi_rlen         (axi_rlen),
			.axi_rsize        (axi_rsize),
			.axi_rburst       (axi_rburst),
			.axi_rlock        (axi_rlock),
			.axi_rcache       (axi_rcache),
			.axi_rprot        (axi_rprot),
			.axi_rvalid       (axi_rvalid),
			.axi_rd_bid       (axi_rd_bid),
			.axi_rd_rresp     (axi_rd_rresp),
			.axi_rd_rvalid    (axi_rd_rvalid),
			.axi_rd_rdata     (axi_rd_rdata),
			.axi_rd_rlast     (axi_rd_rlast),
			.axi_rd_rready    (axi_rd_rready),
			.rgmii_rx_data    (rgmii_rx_data),
			.rgmii_rx_valid   (rgmii_rx_valid),
			.rgmii_rx_last    (rgmii_rx_last),
			.rgmii_rx_user    (rgmii_rx_user),
			.rgmii_rx_ready   (rgmii_rx_ready),
			.pc_mac           (pc_mac),
			.pc_ip            (pc_ip),
			.trig_package_rst (trig_package_rst),
			.trig_arp         (trig_arp)
		);

	task init();
		axi_wready     <= '0;
		axi_wd_wready  <= '0;
		axi_wb_bid     <= '0;
		axi_wb_bresp   <= '0;
		axi_wb_bvalid  <= '0;
		axi_rready     <= '0;
		axi_rd_bid     <= '0;
		axi_rd_rresp   <= '0;
		axi_rd_rvalid  <= '0;
		axi_rd_rdata   <= '0;
		axi_rd_rlast   <= '0;
		rgmii_rx_data  <= '0;
		rgmii_rx_valid <= '0;
		rgmii_rx_last  <= '0;
		rgmii_rx_user  <= '0;
	endtask

	initial begin
		// do something
		init();
		axi_wready     <= '1;
		axi_wd_wready  <= '1;
		axi_wb_bid     <= '0;
		axi_wb_bresp   <= '0;
		axi_wb_bvalid  <= '1;				
	end

parameter   PREAMBLE_REG    =   64'h5555_5555_5555_55d5,    //  前导码
            PREAMBLE_WORD   =   5'd8,
            //------------以太网首部-----------------
            ETH_DA_MAC      =   48'h00D0_0800_0002,         //  目的MAC地址，FPGA板的MAC
            ETH_SA_MAC      =   48'h0024_7EDF_CA5E,         //  源MAC地址，上位机MAC
            ETH_TYPE        =   16'h0800,                   //  帧类型

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
            DATA_FLAG       =   32'hE1EC_0C0D,              //  固定字节，用于数据标识
            DATA_RX         =   128'h1234_5611_1134_5678_1234_5678_AABB_CCDD,
            DATA_WORD       =   5'd16,
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
always  @ (posedge clk) begin
    if (srst) begin      
        DATA_OUT  	<=  {ETH_DA_MAC,ETH_SA_MAC,ETH_TYPE,IP_VS_LEN_TOS,16'h002C,16'h0012,IP_FLAG_OFFSET,IP_TTL_PROTO,IP_SUM,IP_SA,IP_DA,UDP_SP,UDP_DP,UDP_LEN,UDP_SUM,DATA_FLAG,DATA_RX,CRC_RX};
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


endmodule
