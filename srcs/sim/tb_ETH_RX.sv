
`timescale 1ns/1ps

module tb_ETH_TOP (); /* this is automatically generated */

	logic rstb;
	logic srst;
	logic clk;

	// clock
	initial begin
		clk = '0;
		forever #(4) clk = ~clk;
	end

	// reset
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

	parameter FPGA_MAC = 48'h00D0_0800_0002;
	parameter FPGA_IP  = 32'hC0A8_006E;
	parameter FPGA_DP  = 16'd8008;
	parameter FPGA_SP  = 16'd8008;

	logic        CLK_125M;
	logic        SYS_RST;
	logic        TRIG_ETH_TX;
	logic        TRIG_MOTOR_STATE;
	logic  [7:0] RGMII_RX_DATA;
	logic        RGMII_RX_VALID;
	logic        RGMII_RX_LAST;
	logic        RGMII_RX_USER;
	logic        RGMII_RX_READY;
	logic  [7:0] RGMII_TX_DATA;
	logic        RGMII_TX_READY;
	logic        RGMII_TX_LAST;
	logic        RGMII_TX_VALID;
	logic        RGMII_TX_USER;
	logic        ETH_MOTOR_TVALID;
	logic        ETH_MOTOR_TREADY;
	logic        ETH_MOTOR_TLAST;
	logic  [7:0] ETH_MOTOR_TDATA;
	logic [31:0] ETH_MOTOR_TUSER;
	logic        AD_TVALID;
	logic        AD_TREADY;
	logic        AD_TLAST;
	logic [15:0] AD_TDATA;
	logic [31:0] AD_TUSER;
	logic        MOTOR_STATE_TVALID;
	logic        MOTOR_STATE_TREADY;
	logic        MOTOR_STATE_TLAST;
	logic [15:0] MOTOR_STATE_TDATA;
	logic [31:0] MOTOR_STATE_TUSER;
	logic        TRIG_TX_CMD;

	ETH_TOP #(
			.FPGA_MAC(FPGA_MAC),
			.FPGA_IP(FPGA_IP),
			.FPGA_DP(FPGA_DP),
			.FPGA_SP(FPGA_SP)
		) inst_ETH_TOP (
			.CLK_125M           (CLK_125M),
			.SYS_RST            (SYS_RST),
			.TRIG_ETH_TX        (TRIG_ETH_TX),
			.TRIG_MOTOR_STATE   (TRIG_MOTOR_STATE),
			.RGMII_RX_DATA      (RGMII_RX_DATA),
			.RGMII_RX_VALID     (RGMII_RX_VALID),
			.RGMII_RX_LAST      (RGMII_RX_LAST),
			.RGMII_RX_USER      (RGMII_RX_USER),
			.RGMII_RX_READY     (RGMII_RX_READY),
			.RGMII_TX_DATA      (RGMII_TX_DATA),
			.RGMII_TX_READY     (RGMII_TX_READY),
			.RGMII_TX_LAST      (RGMII_TX_LAST),
			.RGMII_TX_VALID     (RGMII_TX_VALID),
			.RGMII_TX_USER      (RGMII_TX_USER),
			.ETH_MOTOR_TVALID   (ETH_MOTOR_TVALID),
			.ETH_MOTOR_TREADY   (ETH_MOTOR_TREADY),
			.ETH_MOTOR_TLAST    (ETH_MOTOR_TLAST),
			.ETH_MOTOR_TDATA    (ETH_MOTOR_TDATA),
			.ETH_MOTOR_TUSER    (ETH_MOTOR_TUSER),
			.AD_TVALID          (AD_TVALID),
			.AD_TREADY          (AD_TREADY),
			.AD_TLAST           (AD_TLAST),
			.AD_TDATA           (AD_TDATA),
			.AD_TUSER           (AD_TUSER),
			.MOTOR_STATE_TVALID (MOTOR_STATE_TVALID),
			.MOTOR_STATE_TREADY (MOTOR_STATE_TREADY),
			.MOTOR_STATE_TLAST  (MOTOR_STATE_TLAST),
			.MOTOR_STATE_TDATA  (MOTOR_STATE_TDATA),
			.MOTOR_STATE_TUSER  (MOTOR_STATE_TUSER),
			.TRIG_TX_CMD        (TRIG_TX_CMD)
		);

assign	CLK_125M	=	clk;
assign	SYS_RST		=	srst;
	initial begin
		// do something
		RGMII_RX_VALID	=	0;
		RGMII_RX_LAST	=	0;
		RGMII_RX_USER	=	0;
		RGMII_RX_DATA	=	0;	
		AD_TVALID	=	0;
		AD_TLAST	=	0;
		AD_TUSER	=	0;
		RGMII_TX_READY	=	0;

	end
parameter   PREAMBLE_REG    =   64'h5555_5555_5555_55d5,    //  前导码
            PREAMBLE_WORD   =   5'd8,
            //------------以太网首部-----------------
            ETH_DA_MAC      =   48'h00D0_0800_0002,         //  目的MAC地址，FPGA板的MAC
            ETH_SA_MAC      =   48'h0024_7EDF_CA5E,         //  源MAC地址，上位机MAC
            ETH_TYPE        =   16'h0800,                   //  帧类型
            ETH_WORD        =   5'd14,
            //-------------IP首部----------------------
            IP_VS_LEN_TOS   =   16'h4500,                   //  IP版本(4)+首部长度(20)+服务类型
            IP_FLAG_OFFSET  =   16'h4000,                   //  IP标志+帧偏移
            IP_TTL_PROTO    =   16'h8011,                   //  IP帧生存时间+协议
            IP_SUM          =   16'h0000,
            IP_DA           =   {8'd192,8'd168,8'd0,8'd110},              //  目的IP地址
            IP_SA           =   {8'd192,8'd168,8'd0,8'd119},              //  源IP地址
            IP_WORD         =   5'd20,
            //-------------UDP首部---------------------
			UDP_DP   		= 	16'd8008,
			UDP_SP   		= 	16'd8008,
            UDP_LEN         =   16'd0026,                   //  UDP长度8字节
            UDP_SUM         =   16'h0000,                   //  UDP校验和
            UDP_WORD        =   5'd8,
            //-------------数据---------------------
            DATA_FLAG       =   32'hE1EC_0C0D,              //  固定字节，用于数据标识
            DATA_RX         =   112'h0000_0011_1134_5678_1234_5678_AABB,
            DATA_WORD       =   5'd14,
			//-------------ARP---------------------
			ARP_DA_MAC		=	48'hFFFF_FFFF_FFFF,
			ARP_SA_MAC		=	48'h0024_7EDF_CA5E, 
			ARP_TYPE		=	16'h0806,  
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
			
    reg [511:0] DATA_OUT   =   0,
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

	reg	read	=	1'b0;
	reg	[7:0]	ad_data_cnt	=	0;
	reg [15:0]	o_ad_data	=	0;
	reg [31:0]	o_ad_sum	=	0;
	reg [15:0]	eth_tx_cnt	=	0;
	reg	[3:0]	rgmii_tx_cnt=	0;
assign	AD_TDATA	=	o_ad_data;
//-------------RGMII_TX_READY ---------------------
always  @ (posedge CLK_125M) begin
	if (RGMII_TX_VALID) begin
		if (RGMII_TX_LAST)
			rgmii_tx_cnt	<=	0;
		else if (rgmii_tx_cnt == 15) 
			rgmii_tx_cnt	<=	rgmii_tx_cnt;			
		else 
			rgmii_tx_cnt	<=	rgmii_tx_cnt + 1;

		if (rgmii_tx_cnt == 14 || RGMII_TX_LAST)  
			RGMII_TX_READY	<=	0;
		else
			RGMII_TX_READY	<=	RGMII_TX_VALID;
	end
end
//-------------AD DATA ---------------------
always  @ (posedge CLK_125M) begin

		TRIG_ETH_TX	<=	TRIG_TX_CMD;

end
//-------------AD DATA ---------------------
always  @ (posedge CLK_125M) begin
	if (AD_TREADY) begin
		if (ad_data_cnt == 128) begin 
			ad_data_cnt	<=	1;
		end
		else
			ad_data_cnt	<=	ad_data_cnt + 1;
			o_ad_data	<=	ad_data_cnt[7:4] + {4'd0,ad_data_cnt[3:0],4'd0,4'd1};
			AD_TLAST	<=	(ad_data_cnt == 127);
	end
	else begin
		ad_data_cnt	<=	ad_data_cnt;
	end
	if (ad_data_cnt == 128) begin 
		AD_TUSER	<=	o_ad_sum;
		o_ad_sum	<=	0;		
	end
	else begin 
		o_ad_sum	<=	o_ad_sum + o_ad_data;
		AD_TUSER	<=	AD_TUSER;
	end
	AD_TVALID	<=	1;

end
//-----------ETH_MOTOR_TREADY -------------------
always  @ (posedge CLK_125M) begin
	if (TRIG_TX_CMD)
		read	<=	1;
	else if (ETH_MOTOR_TLAST)
		read	<=	0;
	else
		read	<= read;

	if (read)
		ETH_MOTOR_TREADY	<=	ETH_MOTOR_TVALID;
	else
		ETH_MOTOR_TREADY	<=	0;
end      
//-----------ETH FARME ------------------- 
always  @ (posedge CLK_125M) begin
    if (SYS_RST) begin      
        DATA_OUT  	<=  {ETH_DA_MAC,ETH_SA_MAC,ETH_TYPE,IP_VS_LEN_TOS,16'h002C,16'h0012,IP_FLAG_OFFSET,IP_TTL_PROTO,IP_SUM,IP_SA,IP_DA,UDP_SP,UDP_DP,UDP_LEN,UDP_SUM,DATA_FLAG,DATA_RX,CRC_RX};
		ARP_OUT		<=	{ARP_DA_MAC,ARP_SA_MAC,ARP_TYPE,ARP_HEAD,ARP_SA_MAC,IP_SA,48'h0,IP_DA,ARP_Z,ARP_CRC};
		ICMP_OUT	<=	{ETH_DA_MAC,ETH_SA_MAC,ETH_TYPE,IP_VS_LEN_TOS,16'h003c,16'h71A0,16'h0000,16'h8001,16'h0000,IP_SA,IP_DA,ICMP_TYPECODE,ICMP_CKS,ICMP_IDF,ICMP_SEQ,ICMP_DATA,ICMP_CRC};
	end
    else begin
		if (FRAME_ARP_CNT == 0 && !IS_ARP && !IS_ICMP && !IS_UDP) begin	// GO ICMP
			IS_ARP	<=	1;
			IS_ICMP	<=	0;
			IS_UDP	<=	0;			
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
			else if (DATA_CNT >= 64) begin
				DATA_CNT       <=   DATA_CNT + 1;
				RGMII_RX_LAST  <=	0;
				RGMII_RX_VALID <=  	0;
			end
			else begin      
				RGMII_RX_DATA  <=  ARP_OUT_D[511:504];
				RGMII_RX_VALID <=  1;
				RGMII_RX_LAST  <=  DATA_CNT == 63;
				ARP_OUT_D      <=  ARP_OUT_D << 8;    
				DATA_CNT       <=  DATA_CNT + 1;
			end  
		end	
//----------------------ICMP------------------------ 
		else if (IS_ICMP) begin
			if (DATA_CNT == 200) begin
				DATA_CNT       <= 0;
				ICMP_OUT_D     <=  ICMP_OUT;
				FRAME_ICMP_CNT <=  FRAME_ICMP_CNT + 1;
			end
			else if (DATA_CNT >= 78) begin
				DATA_CNT       <=   DATA_CNT + 1;
				RGMII_RX_LAST  <=	0;
				RGMII_RX_VALID <=  0;
			end
			else begin
				RGMII_RX_DATA  <=  ICMP_OUT_D[623:616];
				RGMII_RX_VALID <=  1;
				RGMII_RX_LAST  <=  DATA_CNT == 77;
				ICMP_OUT_D     <=  ICMP_OUT_D << 8;    
				DATA_CNT       <=  DATA_CNT + 1;
			end 
		end	
//----------------------UDP------------------------ 
		else if (IS_UDP) begin
			 if (DATA_CNT == 200) begin
				DATA_CNT       <= 0;
				DATA_OUT_D     <=  DATA_OUT;               
				FRAME_UDP_CNT  <=  FRAME_UDP_CNT + 1;                
			end
			else if (DATA_CNT >= 67) begin
				RGMII_RX_VALID <=  0;
				RGMII_RX_LAST  <=	0;
				DATA_CNT       <=   DATA_CNT + 1;
			end
			else begin
				if (DATA_CNT == 63 || DATA_CNT == 64 || DATA_CNT == 65) begin 
					RGMII_RX_VALID <=  0;
				end
				else begin 
					RGMII_RX_DATA  <=  DATA_OUT_D[511:504];
					RGMII_RX_VALID <=  1;
					RGMII_RX_LAST  <=  DATA_CNT == 66;              
					DATA_OUT_D     <=  DATA_OUT_D << 8; 
				end  
				DATA_CNT       <=  DATA_CNT + 1;
			end
		end		
    end
end		
	// dump wave
/*	initial begin
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_ETH_TOP.fsdb");
			$fsdbDumpvars(0, "tb_ETH_TOP", "+mda", "+functions");
		end
	end*/

endmodule
