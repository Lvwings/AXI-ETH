`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/07 16:45:12
// Design Name: 
// Module Name: RX_UDP
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



module RX_UDP#(
	// FPGA firmware information
	parameter FPGA_MAC         = 48'h00D0_0800_0002,
	parameter FPGA_IP          = 32'hC0A8_006E,
    parameter FPGA_DP          = 16'd8080,                   //  UDP目的端口号8080
    parameter FPGA_SP          = 16'd8080,
	// AXI parameters
    parameter C_AXI_ID_WIDTH       = 4,        // The AXI id width used for read and write // This is an integer between 1-16
    parameter C_AXI_ADDR_WIDTH     = 32,       // This is AXI address width for all        // SI and MI slots
    parameter C_AXI_DATA_WIDTH     = 64,       // Width of the AXI write and read data
    parameter C_AXI_NBURST_SUPPORT = 1'b0,     // Support for narrow burst transfers       // 1-supported, 0-not supported 
    parameter C_AXI_BURST_TYPE     = 2'b00,    // 00:FIXED 01:INCR 10:WRAP
    parameter WATCH_DOG_WIDTH      = 12,   		// Start address of the address map
    // DATA FLAG
    parameter FLAG_MOTOR           =   32'hE1EC_0C0D,
    parameter FLAG_AD              =   32'hAD86_86DA,
    // ETH receive channel setting
    parameter C_ADDR_SUMOFFSET     =   32'h0000_1000,
    parameter C_ADDR_MOTOR2ETH     =   32'h0000_0000,
    parameter C_ADDR_AD2ETH        =   32'h1000_0000,
     // ETH send channel setting
    parameter C_ADDR_ETH2MOTOR     =   32'hE000_0000,
    parameter C_ADDR_ETH2AD        =   32'hF000_0000           
    )
(
    input   sys_clk,
    input   sys_rst,  // synchronous reset active high

// AXI write address channel signals
   	input                               axi_wready, // Indicates slave is ready to accept a 
   	output [C_AXI_ID_WIDTH-1:0]         axi_wid,    // Write ID
   	output [C_AXI_ADDR_WIDTH-1:0]       axi_waddr,  // Write address
   	output [7:0]                        axi_wlen,   // Write Burst Length
   	output [2:0]                        axi_wsize,  // Write Burst size
   	output [1:0]                        axi_wburst, // Write Burst type
   	output [1:0]                        axi_wlock,  // Write lock type
   	output [3:0]                        axi_wcache, // Write Cache type
   	output [2:0]                        axi_wprot,  // Write Protection type
   	output                              axi_wvalid, // Write address valid
  
// AXI write data channel signals
   	input                               axi_wd_wready,  // Write data ready
   	output [C_AXI_DATA_WIDTH-1:0]       axi_wd_wdata,    // Write data
   	output [C_AXI_DATA_WIDTH/8-1:0]     axi_wd_wstrb,    // Write strobes
   	output                              axi_wd_wlast,    // Last write transaction   
   	output                              axi_wd_wvalid,   // Write valid
  
// AXI write response channel signals
   	input  [C_AXI_ID_WIDTH-1:0]         axi_wb_bid,     // Response ID
   	input  [1:0]                        axi_wb_bresp,   // Write response
   	input                               axi_wb_bvalid,  // Write reponse valid
   	output                              axi_wb_bready,  // Response ready
  
// AXI read address channel signals
   	input                               axi_rready,     // Read address ready
   	output [C_AXI_ID_WIDTH-1:0]         axi_rid,        // Read ID
   	output [C_AXI_ADDR_WIDTH-1:0]       axi_raddr,      // Read address
   	output [7:0]                        axi_rlen,       // Read Burst Length
   	output [2:0]                        axi_rsize,      // Read Burst size
   	output [1:0]                        axi_rburst,     // Read Burst type
   	output [1:0]                        axi_rlock,      // Read lock type
   	output [3:0]                        axi_rcache,     // Read Cache type
   	output [2:0]                        axi_rprot,      // Read Protection type
   	output                              axi_rvalid,     // Read address valid
  
// AXI read data channel signals   
   	input  [C_AXI_ID_WIDTH-1:0]         axi_rd_bid,     // Response ID
   	input  [1:0]                        axi_rd_rresp,   // Read response
   	input                               axi_rd_rvalid,  // Read reponse valid
   	input  [C_AXI_DATA_WIDTH-1:0]       axi_rd_rdata,   // Read data
   	input                               axi_rd_rlast,   // Read last
   	output                              axi_rd_rready,   // Read Response ready

	// AXIS RX RGMII
    input   [7:0]   					rgmii_rx_data,
    input   							rgmii_rx_valid,
    input   							rgmii_rx_last,
	input								rgmii_rx_user,
	output								rgmii_rx_ready,

	//	ARP
	output	[47:0]						pc_mac,
	output	[31:0]						pc_ip,

	output								trig_package_rst,
	output								trig_arp	

);
//*****************************************************************************
// AXI Internal register and wire declarations
//*****************************************************************************

// AXI write address channel signals

	reg [C_AXI_ID_WIDTH-1:0]         wr_wid 	=	0;
	reg [C_AXI_ADDR_WIDTH-1:0]       wr_waddr	=	0;
	reg [7:0]                        wr_wlen	=	0;
	reg [1:0]                        wr_wburst	=	0;
	reg                              wr_wvalid	=	1'b0;

// AXI write data channel signals

	reg [C_AXI_DATA_WIDTH-1:0]       wd_wdata	=	0;
	reg [C_AXI_DATA_WIDTH/8-1:0]     wd_wstrb	=	0;
	reg                              wd_wlast	=	1'b0;
	reg                              wd_wvalid	=	1'b0;

// AXI write response channel signals
	
	reg								wb_bready 	=	1'b0;

// AXI read address channel signals

	reg [C_AXI_ID_WIDTH-1:0]         rr_rid 	=	0;
	reg [C_AXI_ADDR_WIDTH-1:0]       rr_raddr	=	0;
	reg [7:0]                        rr_rlen	=	0;
	reg [2:0]                        rr_rsize	=	0;
	reg [1:0]                        rr_rburst	=	0;
	reg                              rr_rvalid	=	1'b0;

// AXI read data channel signals
	
	reg								rd_rready	=	1'b0;	
//*****************************************************************************
// AXI support signals
//*****************************************************************************	
	// function called clogb2 that returns an integer which has the 
	// value of the ceiling of the log base 2.                      
	function integer clogb2 (input integer bit_depth);              
	begin                                                           
	for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
	  bit_depth = bit_depth >> 1;                                 
	end                                                           
	endfunction 

	//	AXI_SIZE : the data bytes of each burst
	localparam	[2:0]	AXI_SIZE	=	clogb2(C_AXI_DATA_WIDTH/8-1);

	//	AXI_ADDR_INC : axi address increment associate with data width
	localparam 	[7:0]	AXI_ADDR_INC	=	C_AXI_DATA_WIDTH/8;
//*****************************************************************************
// write Internal parameter declarations
//*****************************************************************************							
	localparam  [3:0]               WRITE_IDLE     = 4'd0, 
									RX_ETH_HEADER  = 4'd1,
									RX_IP_HEADER   = 4'd2,
									RX_UDP_HEADER  = 4'd3,
									RX_ARP         = 4'd4,
									WRITE_ADDR     = 4'd5,
									WRITE_DATA     = 4'd6,
									WRITE_RESPONSE = 4'd7,
									WRITE_TIME_OUT = 4'd8;
	//	use one-hot encode								
   	reg [8:0]                       m_write_state      =   0,
									m_write_next       =   0;

	reg [WATCH_DOG_WIDTH : 0]       wt_watch_dog_cnt =   0;          
	reg                             trig_write_start =   1'b0;

   	reg [7:0]                       write_data_cnt   =   0;

   //	rx_wd_wdata : combine rgmii_rx_data into axi_wd_wdata according to C_AXI_DATA_WIDTH
   reg 	[C_AXI_DATA_WIDTH-1:0]      rx_wd_wdata	=	0;  

    //	rx_wd_cnt : the counter of rgmii_rx_data make up single axi_wd_wdata, begin with 0   
    wire	[AXI_SIZE : 0]				rx_wd_cnt;
//*****************************************************************************
// RGMII Internal register and wire declarations
//*****************************************************************************
	localparam  //------------以太网首部-----------------  //  000a_3501_fec0_ffff_ffff_ffff_0800
	            IP_TYPE     = 16'h0800,                   //  IP帧
	            ARP_TYPE    = 16'h0806,                   //    ARP帧
	            ETH_WORD    = 8'd14,
	            //-------------IP首部---------------------//  4500_0014_0000_4000_8011_c0a8_0003_c0a8_0002
	            IP_VISION   = 8'h45,
	            UDP_PROTO   = 8'h11,                      // UDP协议
	            ICMP_PROTO  = 8'h01,                      // ICMP协议
	            IP_WORD     = 8'd20,
	            //-------------UDP首部--------------------//  1F90_1F90_0010_3F30
	            UDP_WORD    = 8'd8, 
	            FLAG_WORD   = 8'd4,	                       
	            //-------------ARP---------------------
	            ARP_WORD    = 8'd28,                  		//    28 + 18 18 位00填充
	            ARP_REQUEST = 16'h0001,
	            //-------------ICMP---------------------
	            PING_REQ    = 8'h08,
	            ICMP_WORD   = 8'd40;

	//--------- flags --------------------
	reg	flag_eth_header_over	=	1'b0,
		flag_ip_header_over		=	1'b0,
		flag_udp_header_over	=	1'b0,
		flag_arp				=	1'b0,
		flag_arp_over			=	1'b0,
		flag_frame_err			=	1'b0;

	reg trig_package_reset		=	1'b0;

	//--------- registers -----------------
		//	eth header
	reg	[15:0]	rx_eth_type		=	0;  	//  收到的帧类型
	reg	[47:0]	rx_eth_da_mac	=	0,
				rx_eth_sa_mac	=	0;
		//	ip header
	reg	[15:0]	rx_ip_idf    	=   16'h0;     //    16位标识
	reg	[7:0]	rx_ip_vision 	=   8'h0,
	            rx_ip_ttl    	=   8'h0,
	            rx_ip_proto  	=   8'h0;          
	reg	[31:0]	rx_da_ip     	=   0,
				rx_sa_ip     	=   0;
		//	udp header
	reg	[15:0]	rx_udp_dp     	=	16'h0,  
	            rx_udp_sp       =	16'h0,  
	            rx_udp_len      =	16'h0;
	reg	[31:0]	udp_data_flag   =	0;
    //	arp
	reg [47:0]  arp_sa_mac		=   0;     	
	reg [31:0]  arp_sa_ip		=   0,
				arp_da_ip		=	0;     	  
	reg [15:0]  arp_opcode    	=   0;

	reg	[7:0]	rgmii_rx_data_d =	0;
		//	counter
	reg	[7:0]	udp_word_cnt    =	0;
	reg 		o_rgmii_rx_ready=	1'b0;	
	reg [47:0]	o_pc_mac	=	0;
	reg	[31:0]	o_pc_ip		=	0;
	wire[7:0]	rx_cmd_len;	
	reg			rgmii_rx_valid_d=	1'b0;

	assign	rgmii_rx_ready 		= 	o_rgmii_rx_ready;	
	assign	trig_package_rst	=	trig_package_reset;
	assign	trig_arp			=	flag_arp_over;
//*****************************************************************************
// Write channel control signals
//*****************************************************************************	
	always @(posedge sys_clk) begin
		if(sys_rst) begin
			trig_write_start <= 0;
			rgmii_rx_valid_d <=	0;
		end else begin
			rgmii_rx_valid_d <=	rgmii_rx_valid;	
			trig_write_start <= rgmii_rx_valid;
		end
	end
//*****************************************************************************
// Write data state machine
//*****************************************************************************
	always @(posedge sys_clk) begin
		if(sys_rst) begin
			m_write_state <= 1;
		end else begin
			m_write_state	<= m_write_next;
		end
	end

	always @(*) begin
		m_write_next	=	0;		//	next state reset
		case (1)
			m_write_state[WRITE_IDLE]	:	begin 
				if (trig_write_start)
					m_write_next[RX_ETH_HEADER]	=	1;
				else
					m_write_next[WRITE_IDLE]		=	1;
			end

			m_write_state[RX_ETH_HEADER]	:	begin 
				if (flag_frame_err)
					m_write_next[WRITE_IDLE]		=	1;
				else if (flag_arp)
					m_write_next[RX_ARP]			=	1;					
				else if (flag_eth_header_over)
					m_write_next[RX_IP_HEADER]	=	1;			
				else
					m_write_next[RX_ETH_HEADER]	=	1;
			end

			m_write_state[RX_IP_HEADER]	:	begin 
				if (flag_frame_err)
					m_write_next[WRITE_IDLE]	=	1;
				else if (flag_ip_header_over)
					m_write_next[RX_UDP_HEADER]	=	1;
				else
					m_write_next[RX_IP_HEADER]	=	1;				
			end	

			m_write_state[RX_UDP_HEADER]	:	begin 
				if (flag_frame_err)
					m_write_next[WRITE_IDLE]		=	1;
				else if (flag_udp_header_over)
					m_write_next[WRITE_ADDR]		=	1;
				else
					m_write_next[RX_UDP_HEADER]	=	1;					
			end			

			m_write_state[RX_ARP]	:	begin 
				if (flag_frame_err)
					m_write_next[WRITE_IDLE]		=	1;
				else if (flag_arp_over)
					m_write_next[WRITE_IDLE]		=	1;
				else
					m_write_next[RX_ARP]			=	1;	
			end

			m_write_state[WRITE_ADDR]	:	begin 
				if (axi_wvalid && axi_wready)
					m_write_next[WRITE_DATA]		=	1;
				else
					m_write_next[WRITE_ADDR]		=	1;
			end

			m_write_state[WRITE_DATA] :	begin 
				if (axi_wd_wvalid && axi_wd_wready && axi_wd_wlast)
					m_write_next[WRITE_RESPONSE]	=	1;
				else
					m_write_next[WRITE_DATA]		=	1;
			end

			m_write_state[WRITE_RESPONSE]	:	begin 
				if (axi_wb_bvalid && axi_wb_bready)
					m_write_next[WRITE_IDLE]		=	1;
				else
					m_write_next[WRITE_RESPONSE]	=	1;			
			end

			m_write_state[WRITE_TIME_OUT] :	begin 
					m_write_next[WRITE_IDLE]		=	1;
			end
			default : m_write_next[WRITE_IDLE]		=	1;
		endcase
	end
//*****************************************************************************
// RGMII RX signals
//*****************************************************************************	
	always @(posedge sys_clk) begin
		if(sys_rst) begin
			rgmii_rx_data_d      <= 0;
		end else begin
			rgmii_rx_data_d	<=	rgmii_rx_data;

			case (1)
				m_write_next[WRITE_IDLE] : begin 
					rx_eth_type          <= 0;
					rx_eth_da_mac        <= 0;
					rx_eth_sa_mac        <= 0;
					rx_ip_vision         <= 0;
					rx_sa_ip             <= 0;
					rx_da_ip             <= 0;
					rx_ip_idf            <= 0;
					rx_ip_proto          <= 0;
					rx_ip_ttl            <= 0;
					rx_udp_dp            <= 0;
					rx_udp_sp            <= 0;
					rx_udp_len           <= 0;

					flag_frame_err       <= 0;
					flag_eth_header_over <= 0;
					flag_udp_header_over <= 0;
					flag_ip_header_over  <= 0;
					flag_arp             <= 0;
					flag_arp_over        <= 0;
					trig_package_reset   <= 0;

					udp_word_cnt         <= 0;
					o_rgmii_rx_ready     <= 0;
					rx_wd_wdata          <= 0;					
				end

				m_write_next[RX_ETH_HEADER]	:	begin 
		            if (udp_word_cnt == ETH_WORD) begin		            	              	
						if ((rx_eth_type ==  IP_TYPE) && {rx_eth_da_mac,rx_eth_sa_mac} == {FPGA_MAC,pc_mac}) begin	// FPGA_MAC,pc_mac							
							flag_eth_header_over <=  1;
							flag_frame_err       <=  0;
						end
						else if (rx_eth_type ==  ARP_TYPE) begin 
							flag_eth_header_over <=  1;
							flag_arp             <=  1;
							flag_frame_err       <=  0;							
						end
	                    else begin
							flag_eth_header_over <=  0;
							flag_frame_err       <=  1;                      
						end						 
						udp_word_cnt     <= 0;
		            end
					else begin
	 					o_rgmii_rx_ready	<=	rgmii_rx_valid;
						if (rgmii_rx_valid && rgmii_rx_ready)		
							udp_word_cnt    <=  udp_word_cnt + 1;
						else
							udp_word_cnt    <=  udp_word_cnt;

						case (udp_word_cnt) 
							 // 接收以太网目的地址
							 8'd00: begin rx_eth_da_mac[47:40] <= rgmii_rx_data; end
							 8'd01: begin rx_eth_da_mac[39:32] <= rgmii_rx_data; end
							 8'd02: begin rx_eth_da_mac[31:24] <= rgmii_rx_data; end
							 8'd03: begin rx_eth_da_mac[23:16] <= rgmii_rx_data; end
							 8'd04: begin rx_eth_da_mac[15:08] <= rgmii_rx_data; end
							 8'd05: begin rx_eth_da_mac[07:00] <= rgmii_rx_data; end
							// 接收以太网源地址                                
							 8'd06: begin rx_eth_sa_mac[47:40] <= rgmii_rx_data; end
							 8'd07: begin rx_eth_sa_mac[39:32] <= rgmii_rx_data; end
							 8'd08: begin rx_eth_sa_mac[31:24] <= rgmii_rx_data; end
							 8'd09: begin rx_eth_sa_mac[23:16] <= rgmii_rx_data; end
							 8'd10: begin rx_eth_sa_mac[15:08] <= rgmii_rx_data; end
							 8'd11: begin rx_eth_sa_mac[07:00] <= rgmii_rx_data; end
							 // 帧类型 08
							 8'd12: begin rx_eth_type[15:08] <= rgmii_rx_data; end
							 8'd13: begin rx_eth_type[07:00] <= rgmii_rx_data; o_rgmii_rx_ready <= 0;end
							 ETH_WORD: begin end
							 default : begin  end
						endcase
					end												
				end

				m_write_next[RX_IP_HEADER]	:	begin 
			        if (udp_word_cnt == IP_WORD) begin			        	
						if (rx_ip_vision == IP_VISION && rx_ip_proto == UDP_PROTO && {rx_sa_ip,rx_da_ip} ==  {pc_ip,FPGA_IP}) begin	// CMD帧 01
								flag_frame_err      <=  0;      
								flag_ip_header_over <=  1;
						end
		                else begin
		                    flag_frame_err          <=  1;
							flag_ip_header_over     <=  0;
		                end
		                o_rgmii_rx_ready	<=	0;
		                udp_word_cnt <= 0;
		            end
					else begin 
	 					o_rgmii_rx_ready	<=	rgmii_rx_valid;
						if (rgmii_rx_valid && rgmii_rx_ready)		
							udp_word_cnt    <=  udp_word_cnt + 1;
						else
							udp_word_cnt    <=  udp_word_cnt;

						case (udp_word_cnt)
							 8'd00: begin rx_ip_vision	<=	rgmii_rx_data; end
							 // 8位服务类型
							 8'd01: begin end
							 // 16位IP总长度 = 20字节IP帧头 + 8字节UDP帧头 + 数据
							 8'd02: begin end	
							 8'd03: begin end
							 // 16位标识 用于CMD返回
							 8'd04: begin rx_ip_idf[15:08] <= rgmii_rx_data; end
							 8'd05: begin rx_ip_idf[07:00] <= rgmii_rx_data; end		// 不清零
							 // 16位标志+偏移                                
							 8'd06: begin end
							 8'd07: begin end
							 // 8位 TTL	用于CMD返回
							 8'd08: begin rx_ip_ttl[07:00]   <= rgmii_rx_data; end        // 不清零
							 // 8位协议
							 8'd09: begin rx_ip_proto[07:00] <= rgmii_rx_data; end
							 // 16位首部校验和
							 8'd10: begin end
							 8'd11: begin end
							 // 32位源IP地址
							 8'd12: begin rx_sa_ip[31:24] <= rgmii_rx_data; end
							 8'd13: begin rx_sa_ip[23:16] <= rgmii_rx_data; end
							 8'd14: begin rx_sa_ip[15:08] <= rgmii_rx_data; end
							 8'd15: begin rx_sa_ip[07:00] <= rgmii_rx_data; end
							 // 32位目的IP地址
							 8'd16: begin rx_da_ip[31:24] <= rgmii_rx_data; end
							 8'd17: begin rx_da_ip[23:16] <= rgmii_rx_data; end
							 8'd18: begin rx_da_ip[15:08] <= rgmii_rx_data; end
							 8'd19: begin rx_da_ip[07:00] <= rgmii_rx_data; o_rgmii_rx_ready <= 0;end				 
							 IP_WORD: begin  end
							 default : begin end					
						endcase					
					end						
				end
				m_write_next[RX_UDP_HEADER]	:	begin 
		            if (udp_word_cnt == UDP_WORD + FLAG_WORD) begin
	            		if (rx_udp_dp == FPGA_DP && (udp_data_flag == FLAG_AD || udp_data_flag == FLAG_MOTOR)) begin
	                        flag_frame_err        <=  0;
	                        flag_udp_header_over  <=  1; 
	            		end
	            		else begin 
	                        flag_frame_err        <=  1;
	                        flag_udp_header_over  <=  0;                    
	            		end    	            		        				                
		                udp_word_cnt <= 0;
		            end
					else begin 
	 					o_rgmii_rx_ready	<=	rgmii_rx_valid;
						if (rgmii_rx_valid && rgmii_rx_ready)		
							udp_word_cnt    <=  udp_word_cnt + 1;
						else
							udp_word_cnt    <=  udp_word_cnt;	

						case (udp_word_cnt) 
							 // 16位源端口号
							 8'd00: begin rx_udp_sp[15:08] <= rgmii_rx_data; end
							 8'd01: begin rx_udp_sp[07:00] <= rgmii_rx_data; end
							 // 16位目的端口号
							 8'd02: begin rx_udp_dp[15:08] <= rgmii_rx_data; end
							 8'd03: begin rx_udp_dp[07:00] <= rgmii_rx_data; end
							 // 16位UDP长度
							 8'd04: begin rx_udp_len[15:08] <= rgmii_rx_data; end
							 8'd05: begin rx_udp_len[07:00] <= rgmii_rx_data; end
							 // 16位UDP校验和                             
							 8'd06: begin end
							 8'd07: begin end
							 //	数据标识
							 8'd08: begin udp_data_flag[31:24] <= rgmii_rx_data; end
							 8'd09: begin udp_data_flag[23:16] <= rgmii_rx_data; end
							 8'd10: begin udp_data_flag[15:08] <= rgmii_rx_data; end
							 8'd11: begin udp_data_flag[07:00] <= rgmii_rx_data; o_rgmii_rx_ready	<=	0;end						 						 
							 UDP_WORD + FLAG_WORD: begin end
							 default : begin  end
						endcase	
					end											
				end	

				m_write_next[RX_ARP]	: begin 
					if (udp_word_cnt == ARP_WORD) begin
						if (arp_opcode == ARP_REQUEST && arp_da_ip == FPGA_IP) begin // ARP 请求 + 目的IP匹配
							o_pc_mac       <= arp_sa_mac;
							o_pc_ip        <= arp_sa_ip;
							flag_frame_err <= 0;
							flag_arp_over  <= 1;
						end
						else begin					
							o_pc_mac       <= o_pc_mac;
							o_pc_ip        <= o_pc_ip;
							flag_frame_err <= 1;
							flag_arp_over  <= 0;
						end
						udp_word_cnt <= 0;
					end
					else begin
	 					o_rgmii_rx_ready	<=	rgmii_rx_valid;
						if (rgmii_rx_valid && rgmii_rx_ready)		
							udp_word_cnt    <=  udp_word_cnt + 1;
						else
							udp_word_cnt    <=  udp_word_cnt;

						case (udp_word_cnt) 
							 //	ARP操作字段		16’h0001 : request
							 8'd06: begin arp_opcode[15:08] <= rgmii_rx_data; end
							 8'd07: begin arp_opcode[07:00] <= rgmii_rx_data; end				 
							 // ARP发送端MAC地址
							 8'd08: begin arp_sa_mac[47:40] <= rgmii_rx_data; end
							 8'd09: begin arp_sa_mac[39:32] <= rgmii_rx_data; end
							 8'd10: begin arp_sa_mac[31:24] <= rgmii_rx_data; end
							 8'd11: begin arp_sa_mac[23:16] <= rgmii_rx_data; end
							 8'd12: begin arp_sa_mac[15:08] <= rgmii_rx_data; end
							 8'd13: begin arp_sa_mac[07:00] <= rgmii_rx_data; end				 
							 // ARP发送端IP地址                               
							 8'd14: begin arp_sa_ip[31:24] <= rgmii_rx_data; end
							 8'd15: begin arp_sa_ip[23:16] <= rgmii_rx_data; end
							 8'd16: begin arp_sa_ip[15:08] <= rgmii_rx_data; end
							 8'd17: begin arp_sa_ip[07:00] <= rgmii_rx_data; end
							 // 目的IP地址
							 8'd24: begin arp_da_ip[31:24] <= rgmii_rx_data; end
							 8'd25: begin arp_da_ip[23:16] <= rgmii_rx_data; end
							 8'd26: begin arp_da_ip[15:08] <= rgmii_rx_data; end
							 8'd27: begin arp_da_ip[07:00] <= rgmii_rx_data; o_rgmii_rx_ready	<=	0;end				 
							 ARP_WORD: begin  end
							 default : begin  end
						endcase									
					end								
				end

				m_write_next[WRITE_DATA]	: begin 

 					o_rgmii_rx_ready	<=	rgmii_rx_valid;
 					
 					if (udp_word_cnt <= rx_cmd_len) begin 
 						if (rgmii_rx_valid && rgmii_rx_ready) begin 
							rx_wd_wdata[((C_AXI_DATA_WIDTH/8 - rx_wd_cnt)*8 - 1) -: 8]	<=	rgmii_rx_data;
							udp_word_cnt    <=  udp_word_cnt + 1;
						end									
						else
							udp_word_cnt    <=  udp_word_cnt;						
 					end
 					else begin 
 						udp_word_cnt    <=  udp_word_cnt;
 					end	
 					trig_package_reset	 <=	 ({rgmii_rx_data_d,rgmii_rx_data} == 16'hEDED || {rgmii_rx_data_d,rgmii_rx_data} == 16'hEAEA);
				end
				default : /* default */;
			endcase
		end
	end
	//	when C_AXI_DATA_WIDTH = 8,cause AXI_SIZE = 0. 
	assign	rx_wd_cnt = (AXI_SIZE > 0) ? udp_word_cnt[AXI_SIZE-1:0] : 0;
	assign	rx_cmd_len=	(rx_udp_len > 0) ? (rx_udp_len - UDP_WORD - FLAG_WORD) : 0;
	assign	pc_mac    = o_pc_mac;
	assign	pc_ip     = o_pc_ip;
//*****************************************************************************
// Watch dog signals
//*****************************************************************************	
	always @(posedge sys_clk) begin
		if(sys_rst) begin
			 wt_watch_dog_cnt	<=	0;
		end else begin
			 if (m_write_state != m_write_next)
			 	wt_watch_dog_cnt	<=	0;
			 else
			 	wt_watch_dog_cnt	<=	wt_watch_dog_cnt + 1; 
		end
	end
//*****************************************************************************
// Write channel address signals
//*****************************************************************************	
	//	wr_waddr	wr_wvalid
	always @(posedge sys_clk) begin
		if (m_write_state[WRITE_ADDR] && m_write_next[WRITE_ADDR]) begin
			case (udp_data_flag)
			 	FLAG_AD		:	wr_waddr	<=	C_ADDR_ETH2AD;
			 	FLAG_MOTOR	:	wr_waddr	<=	C_ADDR_ETH2MOTOR;
			 	default : wr_waddr	<=	0;
			 endcase 			 	
			wr_wvalid	<=	1;
		end
		else begin 
			wr_waddr	<=	wr_waddr;
			wr_wvalid	<=	0;			 	
		end
	end

	//	wr_wid
	always @(posedge sys_clk) begin
		 if (m_write_state[RX_UDP_HEADER] && m_write_next[WRITE_ADDR])
		 	case (udp_data_flag)
		 	 	FLAG_AD		:	wr_wid	<=	1;
		 	 	FLAG_MOTOR	:	wr_wid	<=	2;
		 	 	default : wr_wid	<=	0;
		 	 endcase 
		 else
		 	wr_wid	<=	wr_wid;
	end

	//	wr_wlen	:	INCR bursts
	always @(posedge sys_clk) begin
		if(sys_rst) begin
			 wr_wlen	<=	1;
		end else begin
			 if (m_write_state[RX_UDP_HEADER] && m_write_next[WRITE_ADDR])
			 		wr_wlen	<=	rx_cmd_len/AXI_ADDR_INC - 1;
			 else
			 	wr_wlen	<=	wr_wlen;
		end
	end	

	assign	axi_wid		=	wr_wid;
	assign	axi_waddr	=	wr_waddr;
	assign	axi_wlen	=	wr_wlen;
	assign	axi_wsize	=	AXI_SIZE;
	assign	axi_wburst	=	C_AXI_BURST_TYPE;
	assign	axi_wvalid	=	wr_wvalid;

	// Not supported and hence assigned zeros
	assign	axi_wlock	=	2'b0;
	assign	axi_wcache	=	4'b0;
	assign	axi_wprot	=	3'b0;
//*****************************************************************************
// Write channel data signals
//*****************************************************************************	
	//	data count
	always @(posedge sys_clk) begin
		if (m_write_state[WRITE_IDLE])
			write_data_cnt	<=	0;
		else if (m_write_state[WRITE_ADDR] && m_write_next[WRITE_DATA])
			write_data_cnt	<=	axi_wlen;
		else if (axi_wd_wvalid && axi_wd_wready)
			write_data_cnt	<=	write_data_cnt - 1;
		else
			write_data_cnt	<=	write_data_cnt;
	end


	//	wd_wdata
	always @(posedge sys_clk) begin
		if (m_write_state[WRITE_IDLE]) begin 
			wd_wdata	<=	0;				 	
		end
		else if (m_write_state[WRITE_ADDR] && m_write_next[WRITE_DATA]) begin 
			wd_wdata	<=	rx_wd_wdata;
		end
		else if (m_write_state[WRITE_DATA] && m_write_next[WRITE_DATA] && (rx_wd_cnt == 0) && udp_word_cnt >= AXI_ADDR_INC) begin 	//	add (udp_word_cnt == AXI_ADDR_INC)
			wd_wdata	<=	rx_wd_wdata;		 	
		end
		else begin 
			wd_wdata	<=	wd_wdata;				 	
		end
	end

	//	wd_wvalid
	always @(posedge sys_clk) begin
		if (m_write_state[WRITE_DATA] && m_write_next[WRITE_DATA]) begin 
		 	if ((rx_wd_cnt == 0) && udp_word_cnt >= AXI_ADDR_INC)
		 		wd_wvalid	<=	1;			
		 	else if (axi_wd_wready)
		 		wd_wvalid	<=	0;	
		 	else
		 		wd_wvalid	<=	wd_wvalid;	
		 end 	
		 else begin 
		 	wd_wvalid	<=	0;				 	
		 end

	end
	//	m_wd_wlast
	always @(posedge sys_clk) begin		 
		 if (m_write_state[WRITE_DATA] && m_write_next[WRITE_DATA]) begin 
		 	wd_wlast	<=	(write_data_cnt == 1);	 				//	user setting
		 end 
		 else begin 
		 	wd_wlast	<=	0;				 	
		 end		
	end

	//	wd_wstrb
	//	used in narrow transfer, data bytes mask, wstrb = 4'b0001 -> only last byte valid
	always @(posedge sys_clk) begin
		if (m_write_state[WRITE_DATA] && m_write_next[WRITE_DATA])
			wd_wstrb	<=	{(C_AXI_DATA_WIDTH/8){1'b1}};
		else
			wd_wstrb	<=	0;
	end

	assign	axi_wd_wdata	=	wd_wdata;
	assign	axi_wd_wstrb	=	wd_wstrb;
	assign	axi_wd_wlast	=	wd_wlast;
	assign	axi_wd_wvalid	=	wd_wvalid;
//*****************************************************************************
// Write channel response signals
//*****************************************************************************	
	always @(posedge sys_clk) begin
		if (m_write_state[WRITE_RESPONSE])
			wb_bready <= axi_wb_bvalid;
		else
			wb_bready <= 0;
	end

	assign	axi_wb_bready	=	wb_bready;
//*****************************************************************************
// Read Internal parameter declarations
//*****************************************************************************							
	localparam  [3:0]               READ_IDLE        =   4'd0,       
									READ_ADDR        =   4'd1,
									READ_DATA        =   4'd2,
									READ_TIME_OUT    =   4'd3;
	//	use one-hot encode								
    reg [3:0]                       read_state       =   0,
									read_next        =   0;

	reg [WATCH_DOG_WIDTH : 0]       rd_watch_dog_cnt =   0; 
	reg                             trig_read_start  =   1'b0;                   
//*****************************************************************************
// Read data state machine
//*****************************************************************************
	always @(posedge sys_clk) begin
		if(sys_rst) begin
			read_state <= 1;
		end else begin
			read_state	<= read_next;
		end
	end	

	always @(*) begin
		read_next	=	0;		//	next state reset
		case (1)
			read_state[READ_IDLE]	:	begin 
				if (trig_read_start)
					read_next[READ_ADDR]		=	1;
				else
					read_next[READ_IDLE]		=	1;
			end

			read_state[READ_ADDR]	:	begin 
				if (axi_rvalid && axi_rready)
					read_next[READ_DATA]		=	1;
				else
					read_next[READ_ADDR]		=	1;
			end

			read_state[READ_DATA] :	begin 
				if (axi_rd_rvalid && axi_rd_rready && axi_rd_rlast)
					read_next[READ_IDLE]		=	1;
				else
					read_next[READ_DATA]		=	1;
			end

			read_state[READ_TIME_OUT] :	begin 
					read_next[READ_IDLE]		=	1;
			end
			default : read_next[READ_IDLE]		=	1;
		endcase
	end									
//*****************************************************************************
// Read channel control signals
//*****************************************************************************	
	always @(posedge sys_clk) begin
		if(sys_rst) begin
			trig_read_start <= 0;
		end else begin
			trig_read_start <= 0;
		end
	end
//*****************************************************************************
// Read dog signals
//*****************************************************************************	
	always @(posedge sys_clk) begin
		 if (read_state != read_next)
		 	rd_watch_dog_cnt	<=	0;
		 else
		 	rd_watch_dog_cnt	<=	rd_watch_dog_cnt + 1; 
	end
//*****************************************************************************
// Read channel address signals
//*****************************************************************************	
	//	rr_raddr	rr_rvalid
	always @(posedge sys_clk) begin
		 if (axi_rd_rlast && axi_rd_rvalid && axi_rd_rready) begin
		 	rr_raddr	<=	rr_raddr	+	AXI_ADDR_INC;
		 	rr_rvalid	<=	0;
		 end
		 else if (read_next[READ_ADDR]) begin 
		 	rr_raddr	<=	rr_raddr;
		 	rr_rvalid	<=	axi_rready;
		 end
		 else begin 
		 	rr_raddr	<=	rr_raddr;
		 	rr_rvalid	<=	0;			 	
		 end
	end

	//	rr_rid
	always @(posedge sys_clk) begin
		if(sys_rst) begin
			 rr_rid	<=	0;
		end else begin
			 if (read_state[READ_IDLE] && read_next[READ_ADDR])
			 	rr_rid	<=	rr_rid + 1;
			 else
			 	rr_rid	<=	rr_rid;
		end
	end

	//	rr_rlen	:	INCR bursts
	always @(posedge sys_clk) begin
		if(sys_rst) begin
			 rr_rlen	<=	1;
		end else begin
			 if (read_state[READ_IDLE] && read_next[READ_ADDR])
			 	if (rr_rlen == 0)
			 		rr_rlen	<=	1;
			 	else
			 		rr_rlen	<=	rr_rlen + 1;
			 else
			 	rr_rlen	<=	rr_rlen;
		end
	end	

	//	rr_rburst	
	//	C_EN_WRAP_TRANS :0 INCR bursts :support burst_len max to 256 (default) 	
	//	C_EN_WRAP_TRANS :1 WRAP bursts :support burst_len 2,4,8,16 				
	//always @(posedge sys_clk) begin
	//	if(sys_rst) begin
	//		 rr_rburst	<=	{1'b0,1'b0} + 2'b01;
	//	end else begin
	//		rr_rburst	<=	{1'b0,C_EN_WRAP_TRANS} + 2'b01;	
	//	end
	//end	

	assign	axi_rid		=	rr_rid;
	assign	axi_raddr	=	rr_raddr;
	assign	axi_rlen	=	rr_rlen;
	assign	axi_rsize	=	AXI_SIZE;
	assign	axi_rburst	=	C_AXI_BURST_TYPE;
	assign	axi_rvalid	=	rr_rvalid;

	// Not supported and hence assigned zeros
	assign	axi_rlock	=	2'b0;
	assign	axi_rcache	=	4'b0;
	assign	axi_rprot	=	3'b0;	
//*****************************************************************************
// Read channel data signals
//*****************************************************************************
	always @(posedge sys_clk) begin
		if (read_next[READ_DATA])
			rd_rready <= axi_rd_rvalid;
		else
			rd_rready <= 0;
	end

	assign	axi_rd_rready	=	rd_rready;	
endmodule : RX_UDP
