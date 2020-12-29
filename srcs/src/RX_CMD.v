`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/08/31 16:34:40
// Design Name: 
// Module Name: RX_CMD
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


module RX_CMD#(
	// FPGA firmware information
	parameter FPGA_MAC =   48'h00D0_0800_0002,	
	parameter FPGA_IP  =   32'hC0A8_006E,
	parameter FPGA_DP  =   16'd8008
   )(
    input   CLK_125M,
    input   SYS_RST,  // Asynchronous reset active high
    output	TRIG_TX_CMD,
    output	TRIG_PACK_RST,
	// AXIS RX RGMII
    input   [7:0]   RGMII_RX_DATA,
    input   RGMII_RX_VALID,
    input   RGMII_RX_LAST,
	input	RGMII_RX_USER,
	output	RGMII_RX_READY,
	//	ARP
	input	TRIG_TX_ARP,
	input	[47:0]	PC_MAC,
	input	[31:0]	PC_IP,
	// AXIS DATA TRANSFER
	output  ETH_CMD_TVALID,
	input   ETH_CMD_TREADY,
	output	ETH_CMD_TLAST,
	output  [7:0]  ETH_CMD_TDATA,
	output	[31:0] ETH_CMD_TUSER
    );

`include "ETH_RX.vh"
//--------- state machine ------------
localparam  IDLE          =   3'd0,
			RX_ETH_HEADER =   3'd1,
			RX_IP_HEADER  =   3'd2,
			RX_UDP_HEADER =	  3'd3,
			CMD           =   3'd4;
reg [2:0]	cmd_current_state	=	0,
			cmd_next_state		=	0;

//---------- ports -----------

reg 		o_trig_tx_cmd   =   1'b0;
reg [7:0]  	o_rx_data 		=   0;
reg [31:0] 	o_rx_user   	=   0;
reg 		o_rx_valid      =   1'b0;
reg 		o_rx_last       =   1'b0;

reg	[7:0]	rgmii_rx_data_d	=	0;
//--------- counter ------------------
reg	[7:0]	cmd_word_cnt	=	0;
//--------- flags --------------------
reg	flag_eth_header_over	=	1'b0,
	flag_ip_header_over		=	1'b0,
	flag_udp_header_over	=	1'b0,
	flag_cmd_over			=	1'b0,
	flag_frame_err			=	1'b0;

reg trig_package_rst		=	1'b0;

//--------- registers -----------------
	//	eth header
reg [15:0]	rx_eth_type		=	0;  	//  收到的帧类型
reg [47:0]	rx_eth_da_mac	=	0,
			rx_eth_sa_mac	=	0;
	//	ip header
reg [15:0]  rx_ip_idf    =   16'h0;                              //    16位标识
reg [7:0]   rx_ip_vision =   8'h0,
            rx_ip_ttl    =   8'h0,
            rx_ip_proto  =   8'h0;          
reg [31:0]  rx_da_ip     =   0,
			rx_sa_ip     =   0;
	//	udp header
reg [15:0]  rx_udp_dp     =   16'h0,  
            rx_udp_sp     =   16'h0,  
            rx_udp_len    =   16'h0;
reg [31:0]  udp_data_flag =   0;	

//--------- output ------------------
assign	ETH_CMD_TVALID	=	o_rx_valid;
assign	ETH_CMD_TDATA	=	o_rx_data;
assign	ETH_CMD_TLAST	=	o_rx_last;
assign	ETH_CMD_TUSER	=	o_rx_user;
assign	TRIG_TX_CMD		=	o_trig_tx_cmd;
assign	TRIG_PACK_RST	=	trig_package_rst;
//--------- assign ------------------
always @(posedge CLK_125M) begin : proc_assign
	if(SYS_RST) begin
		cmd_current_state <= IDLE;
	end else begin
		cmd_current_state <= cmd_next_state;
	end
end		

//---------- jump -------------------
always @(*) begin : proc_jump
	case (cmd_current_state)
		IDLE	:			cmd_next_state	=	(RGMII_RX_VALID && !RGMII_RX_LAST)	?	RX_ETH_HEADER : IDLE;
		
		RX_ETH_HEADER	:	if (flag_frame_err || RGMII_RX_LAST)
								cmd_next_state	=	IDLE;
							else if (flag_eth_header_over)
								cmd_next_state	=	RX_IP_HEADER;
							else
								cmd_next_state	=	RX_ETH_HEADER;

		RX_IP_HEADER	:	if (flag_frame_err)
								cmd_next_state	=	IDLE;
							else if (flag_ip_header_over)
								cmd_next_state	=	RX_UDP_HEADER;
							else
								cmd_next_state	=	RX_IP_HEADER;		

		RX_UDP_HEADER	:	if (flag_frame_err)
								cmd_next_state	=	IDLE;
							else if (flag_udp_header_over)
								cmd_next_state	=	CMD;
							else
								cmd_next_state	=	RX_UDP_HEADER;

		CMD	:				if (flag_frame_err)
								cmd_next_state	=	IDLE;
							else if (o_trig_tx_cmd)
								cmd_next_state	=	IDLE;
							else
								cmd_next_state	=	CMD;

		default : 			cmd_next_state	=	IDLE;
	endcase
end	

//---------- output -------------------
always @(posedge CLK_125M) begin : proc_output
	if(SYS_RST) begin
		o_rx_data            <=  0;
		o_rx_valid           <=  0;
		o_rx_last            <=  0;
		o_trig_tx_cmd        <=  0;

		rx_eth_type          <=  0;
		rx_eth_da_mac        <=  0;
		rx_eth_sa_mac        <=  0;
		rx_ip_vision         <=  0;
		rx_sa_ip             <=  0;
		rx_da_ip             <=  0;
		rx_ip_idf            <=  0;
		rx_ip_proto          <=  0;
		rx_ip_ttl            <=  0;
		rx_udp_dp            <=  0;
		rx_udp_sp            <=  0;
		rx_udp_len           <=  0;

		flag_frame_err       <=  0;
		flag_eth_header_over <=  0;
		flag_udp_header_over <=  0;
		flag_ip_header_over  <=  0;
		trig_package_rst	 <=	 0;

		cmd_word_cnt         <=  0;
		rgmii_rx_data_d		 <=	 0;
	end else begin
		rgmii_rx_data_d	<=	RGMII_RX_DATA;
		case (cmd_next_state)
			IDLE	:	begin 
				o_rx_data            <=  0;
				o_rx_valid           <=  0;
				o_rx_last            <=  0;
				o_trig_tx_cmd        <=  0;

				rx_eth_type          <=  0;
				rx_eth_da_mac        <=  0;
				rx_eth_sa_mac        <=  0;
				rx_ip_vision         <=  0;
				rx_sa_ip             <=  0;
				rx_da_ip             <=  0;
				rx_ip_idf            <=  0;
				rx_ip_proto          <=  0;
				rx_ip_ttl            <=  0;
				rx_udp_dp            <=  0;
				rx_udp_sp            <=  0;
				rx_udp_len           <=  0;

				flag_frame_err       <=  0;
				flag_eth_header_over <=  0;
				flag_udp_header_over <=  0;
				flag_ip_header_over  <=  0;
				trig_package_rst	 <=	 0;

				cmd_word_cnt         <=  0;
			end
			RX_ETH_HEADER	:	begin 
	            if (cmd_word_cnt == ETH_WORD) begin               	
					if ((rx_eth_type ==  IP_TYPE) && {rx_eth_da_mac,rx_eth_sa_mac} == {FPGA_MAC,PC_MAC}) begin	// FPGA_MAC,pc_mac							
						flag_eth_header_over <=  1;
						flag_frame_err       <=  0;
						rx_ip_vision         <= RGMII_RX_DATA;  
					end
                    else begin
						flag_eth_header_over <=  0;
						flag_frame_err       <=  1;
						rx_ip_vision         <=  0;                         
					end
	            end
				else begin 
					if (RGMII_RX_VALID)		
						cmd_word_cnt    <=  cmd_word_cnt + 1;
					else
						cmd_word_cnt    <=  cmd_word_cnt;			
				end		
					
				case (cmd_word_cnt) 
					 // 接收以太网目的地址
					 8'd00: begin rx_eth_da_mac[47:40] <= RGMII_RX_DATA; end
					 8'd01: begin rx_eth_da_mac[39:32] <= RGMII_RX_DATA; end
					 8'd02: begin rx_eth_da_mac[31:24] <= RGMII_RX_DATA; end
					 8'd03: begin rx_eth_da_mac[23:16] <= RGMII_RX_DATA; end
					 8'd04: begin rx_eth_da_mac[15:08] <= RGMII_RX_DATA; end
					 8'd05: begin rx_eth_da_mac[07:00] <= RGMII_RX_DATA; end
					// 接收以太网源地址                                
					 8'd06: begin rx_eth_sa_mac[47:40] <= RGMII_RX_DATA; end
					 8'd07: begin rx_eth_sa_mac[39:32] <= RGMII_RX_DATA; end
					 8'd08: begin rx_eth_sa_mac[31:24] <= RGMII_RX_DATA; end
					 8'd09: begin rx_eth_sa_mac[23:16] <= RGMII_RX_DATA; end
					 8'd10: begin rx_eth_sa_mac[15:08] <= RGMII_RX_DATA; end
					 8'd11: begin rx_eth_sa_mac[07:00] <= RGMII_RX_DATA; end
					 // 帧类型 08
					 8'd12: begin rx_eth_type[15:08] <= RGMII_RX_DATA; end
					 8'd13: begin rx_eth_type[07:00] <= RGMII_RX_DATA; end
					 ETH_WORD: begin cmd_word_cnt <= 1;end
					 default : begin  end
				endcase				
			end
			RX_IP_HEADER	:	begin 
		        if (cmd_word_cnt == IP_WORD) begin
					if (rx_ip_vision != 8'h45) begin // 版本+首部长度 
						flag_frame_err          <=  1;
						flag_ip_header_over     <=  0;
					end 			
					else if (rx_ip_proto == UDP_PROTO && {rx_sa_ip,rx_da_ip} ==  {PC_IP,FPGA_IP}) begin	// CMD帧 01
							flag_frame_err      <=  0;      
							flag_ip_header_over <=  1;
							rx_udp_sp[15:08]    <=  RGMII_RX_DATA;
					end
	                else begin
	                    flag_frame_err          <=  1;
						flag_ip_header_over     <=  0;
	                end
	                cmd_word_cnt <= 1;
	            end
				else begin 
					if (RGMII_RX_VALID)		
						cmd_word_cnt    <=  cmd_word_cnt + 1;
					else
						cmd_word_cnt    <=  cmd_word_cnt;			
				end	
					
				case (cmd_word_cnt) 
					 // 8位服务类型
					 8'd01: begin end
					 // 16位IP总长度 = 20字节IP帧头 + 8字节UDP帧头 + 数据
					 8'd02: begin end	
					 8'd03: begin end
					 // 16位标识 用于CMD返回
					 8'd04: begin rx_ip_idf[15:08] <= RGMII_RX_DATA; end
					 8'd05: begin rx_ip_idf[07:00] <= RGMII_RX_DATA; end		// 不清零
					 // 16位标志+偏移                                
					 8'd06: begin end
					 8'd07: begin end
					 // 8位 TTL	用于CMD返回
					 8'd08: begin rx_ip_ttl[07:00]   <= RGMII_RX_DATA; end        // 不清零
					 // 8位协议
					 8'd09: begin rx_ip_proto[07:00] <= RGMII_RX_DATA; end
					 // 16位首部校验和
					 8'd10: begin end
					 8'd11: begin end
					 // 32位源IP地址
					 8'd12: begin rx_sa_ip[31:24] <= RGMII_RX_DATA; end
					 8'd13: begin rx_sa_ip[23:16] <= RGMII_RX_DATA; end
					 8'd14: begin rx_sa_ip[15:08] <= RGMII_RX_DATA; end
					 8'd15: begin rx_sa_ip[07:00] <= RGMII_RX_DATA; end
					 // 32位目的IP地址
					 8'd16: begin rx_da_ip[31:24] <= RGMII_RX_DATA; end
					 8'd17: begin rx_da_ip[23:16] <= RGMII_RX_DATA; end
					 8'd18: begin rx_da_ip[15:08] <= RGMII_RX_DATA; end
					 8'd19: begin rx_da_ip[07:00] <= RGMII_RX_DATA; end				 
					 IP_WORD: begin  end
					 default : begin end
				endcase				
			end
	        RX_UDP_HEADER : begin
	            if (cmd_word_cnt == UDP_WORD) begin
            		if (rx_udp_dp == FPGA_DP) begin
                        flag_frame_err        <=  0;
                        flag_udp_header_over  <=  1; 
                        udp_data_flag[31:24] <= RGMII_RX_DATA;
            		end
            		else begin 
                        flag_frame_err        <=  1;
                        flag_udp_header_over  <=  0;                    
            		end
            		cmd_word_cnt <= 1;
	            end
				else begin 
					if (RGMII_RX_VALID)		
						cmd_word_cnt    <=  cmd_word_cnt + 1;
					else
						cmd_word_cnt    <=  cmd_word_cnt;			
				end	
					
				case (cmd_word_cnt) 
					 // 16位源端口号
					 8'd01: begin rx_udp_sp[07:00] <= RGMII_RX_DATA; end
					 // 16位目的端口号
					 8'd02: begin rx_udp_dp[15:08] <= RGMII_RX_DATA; end
					 8'd03: begin rx_udp_dp[07:00] <= RGMII_RX_DATA; end
					 // 16位UDP长度
					 8'd04: begin rx_udp_len[15:08] <= RGMII_RX_DATA; end
					 8'd05: begin rx_udp_len[07:00] <= RGMII_RX_DATA; end
					 // 16位UDP校验和                             
					 8'd06: begin end
					 8'd07: begin end
					 UDP_WORD: begin end
					 default : begin  end
				endcase			
	        end			
			CMD : begin 
            if (cmd_word_cnt ==  4) begin       //  固定字校验
                cmd_word_cnt    <=  cmd_word_cnt + 1;
				if (udp_data_flag == FLAG_MOTOR) begin            // 有一个32位数据标志，用于标识数据开始
                    flag_frame_err  <=  0;
                end                               
                else begin
                    flag_frame_err  <=  1;
                end
            end	        				
				if (RGMII_RX_LAST) begin
					o_trig_tx_cmd    <= 1;
		            o_rx_data        <=  RGMII_RX_DATA;
		            o_rx_valid       <=  RGMII_RX_VALID;                 
					o_rx_last        <= 1;
					cmd_word_cnt     <= 1;
				end
				else begin
					o_trig_tx_cmd    <= 0;
					o_rx_last        <= 0;
					if (RGMII_RX_VALID)		//	数据不足时，是否不满足？
						cmd_word_cnt <=  cmd_word_cnt + 1;
					else
						cmd_word_cnt <=  cmd_word_cnt;

					casex (cmd_word_cnt) 
						 // DATA_FLAG
						 8'd01: begin udp_data_flag[23:16] <= RGMII_RX_DATA; end
						 8'd02: begin udp_data_flag[15:08] <= RGMII_RX_DATA; end	
						 8'd03: begin udp_data_flag[07:00] <= RGMII_RX_DATA; end
						 // 40字节数据
						 8'b0000_01xx,8'b0000_1xxx,8'b0001_xxxx,8'b0010_0xxx,8'b0010_10xx : begin 
						 			  o_rx_data		<=	RGMII_RX_DATA;
						 			  o_rx_valid	<=	RGMII_RX_VALID;
						 			  trig_package_rst	 <=	 ({o_rx_data,RGMII_RX_DATA} == 16'hEDED || {o_rx_data,RGMII_RX_DATA} == 16'hEAEA);
						 end
						 DATA_WORD: begin  end	// crc END
						 default : begin 
							o_rx_data            <=  0;
							o_rx_valid           <=  0;	
							trig_package_rst	 <=	 0;				 	
						 end
					endcase					
				end											
			end
			default : begin 
				o_rx_data            <=  0;
				o_rx_valid           <=  0;
				o_rx_last            <=  0;
				o_trig_tx_cmd        <=  0;

				rx_eth_type          <=  0;
				rx_eth_da_mac        <=  0;
				rx_eth_sa_mac        <=  0;
				rx_ip_vision         <=  0;
				rx_sa_ip             <=  0;
				rx_da_ip             <=  0;
				rx_ip_idf            <=  0;
				rx_ip_proto          <=  0;
				rx_ip_ttl            <=  0;
				rx_udp_dp            <=  0;
				rx_udp_sp            <=  0;
				rx_udp_len           <=  0;

				flag_frame_err       <=  0;
				flag_eth_header_over <=  0;
				flag_udp_header_over <=  0;
				flag_ip_header_over  <=  0;

				cmd_word_cnt         <=  0;
			end
		endcase
	end
end
endmodule
