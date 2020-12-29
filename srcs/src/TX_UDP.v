`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/02 09:03:23
// Design Name: 
// Module Name: TX_UDP
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


module TX_UDP#(
	// FPGA firmware information
	parameter FPGA_MAC	=	48'h00D0_0800_0002,
	parameter FPGA_IP	=	32'hC0A8_006E,
    parameter FPGA_DP    =   16'd8008,                   //  UDP目的端口号8080
    parameter FPGA_SP    =   16'd8008  
    )(
    input   CLK_125M,
    input   SYS_RST,  // synchronous reset active high
    input	TRIG_ETH_TX,
    input	TRIG_MOTOR_STATE,
    input	TRIG_PACK_RST,
  	// RGMII TX UDP
	output	[7:0]	UDP_DATA,  	
	input	UDP_READY,
	output	UDP_LAST,
	output	UDP_VALID,
	//	ARP
	input	TRIG_TX_ARP,
	input	[47:0]	PC_MAC,
	input	[31:0]	PC_IP,	
	// AXIS DATA TRANSFER
	input  	AD_TVALID,
	output  AD_TREADY,
	input	AD_TLAST,
	input  	[15:0]  AD_TDATA,
	input	[31:0]  AD_TUSER,
	// MOTOR STATE TRANSFER
	input  	MOTOR_STATE_TVALID,
	output  MOTOR_STATE_TREADY,
	input	MOTOR_STATE_TLAST,
	input  	[15:0]  MOTOR_STATE_TDATA,
	input	[31:0]  MOTOR_STATE_TUSER		 
    );

     `include "ETH_TX.vh"
 //--------- state machine ----------
localparam  IDLE          =   3'd0,
			PREWORK       =   3'd1,
			TX_ETH_HEADER =   3'd2,
			TX_IP_HEADER  =   3'd3,
			TX_UDP_HEADER =   3'd4,
			TX_DATA       =   3'd5,
			TX_STATE	  =	  3'd6;

(* dont_touch = "TRUE" *)reg [2:0]	udp_current_state	=	0,
			udp_next_state		=	0;

//--------- ports -------------------
(* dont_touch = "TRUE" *)reg [7:0]	o_udp_data	=	0;
(* dont_touch = "TRUE" *)reg			o_udp_valid	=	1'b0,
			o_udp_last	=	1'b0;
(* dont_touch = "TRUE" *)reg			o_ad_ready	=	1'b0;
reg	o_state_ready	=	1'b0;
//--------- counter ------------------
(* dont_touch = "TRUE" *)reg	[7:0]	udp_word_cnt	=	0;

//--------- flags --------------------
reg			flag_eth_header_over	=	1'b0,
			flag_udp_header_over	=	1'b0,
			flag_ip_header_over		=	1'b0,
			flag_data_over			=	1'b0;

reg 		trig_udp_cks 	=	1'b0;
wire		trig_tx_cks;

reg			state_ad		=	1'b0,
			state_motor		=	1'b0;
//--------- registers --------------------
reg [111:0] eth_temp	=   0;

reg [159:0] ip_temp		=   0; 
reg [15:0]  ip_identif	=   0; 
wire[15:0]	ip_cks;

(* dont_touch = "TRUE" *)reg [63:0]  udp_temp	=   0;
(* dont_touch = "TRUE" *)wire[15:0]	udp_cks;
(* dont_touch = "TRUE" *)reg	[31:0]	udp_sum		=   0;
(* dont_touch = "TRUE" *)reg	[15:0]	udp_len		=   0;

reg [31:0]	package_cnt	=	0;

//--------- output --------------------
assign	UDP_DATA	=	o_udp_data;
assign	UDP_VALID	=	o_udp_valid;
assign	UDP_LAST	=	o_udp_last;
assign	AD_TREADY	=	o_ad_ready;
assign	MOTOR_STATE_TREADY	=	o_state_ready;

	GET_CKS #(
			.FPGA_MAC(FPGA_MAC),
			.FPGA_IP(FPGA_IP),
			.FPGA_DP(16'd8080),
			.FPGA_SP(16'd8080)
		) inst_GET_CKS (
			.CLK_125M      (CLK_125M),
			.SYS_RST       (SYS_RST || UDP_LAST),
			.TRIG_UDP_CKS  (trig_udp_cks),
			.TRIG_ICMP_CKS (0),
			.PC_IP         (PC_IP),
			.IP_IDENTIF    (ip_identif),
			.UDP_DATA_SUM  (udp_sum),
			.UDP_DATA_LEN  (udp_len),
			.ICMP_DATA_SUM (0),
			.IP_CKS        (ip_cks),
			.ICMP_CKS      (),
			.UDP_CKS       (udp_cks),
			.TRIG_TX_CKS   (trig_tx_cks)
		);
 //--------------------udp_sum------------------------
always @(posedge CLK_125M) begin : proc_cks
	if(SYS_RST) begin
		udp_sum      <=  0;
		udp_len      <=  0;
		trig_udp_cks <=  0;
	end else begin
		if (TRIG_ETH_TX) begin 
			udp_sum      <=  AD_TUSER + FLAG_AD[31:16] + FLAG_AD[15:00] + package_cnt[31:16] + (package_cnt[15:00] + 1);
			udp_len      <=  AD_WORD + FLAG_WORD + 4;	//	4 序号长度
			trig_udp_cks <=  1;
		end
		else if (TRIG_MOTOR_STATE) begin 
			udp_sum      <=  MOTOR_STATE_TUSER + FLAG_MOTOR[31:16] + FLAG_MOTOR[15:00];
			udp_len      <=  MOTOR_WORD + FLAG_WORD;
			trig_udp_cks <=  1;			
		end
		else begin 
			udp_sum      <=  udp_sum;
			udp_len      <=  udp_len;
			trig_udp_cks <=  0;
		end
	end
end
 //--------------------state------------------------
always @(posedge CLK_125M) begin : proc_state
	if(SYS_RST) begin
		state_ad <= 0;
		state_motor	<=	0;
	end else begin
		if (TRIG_ETH_TX) begin
			state_ad	<=	1;
			state_motor	<=	0;
		end
		else if (TRIG_MOTOR_STATE) begin 
			state_ad	<=	0;
			state_motor	<=	1;
		end
		else if (UDP_LAST) begin 
			state_ad	<=	0;
			state_motor	<=	0;
		end
		else begin 
			state_ad	<=	state_ad;
			state_motor	<=	state_motor;
		end
	end
end
 //--------------------package------------------------
 always @(posedge CLK_125M) begin : proc_package
 	if(SYS_RST || TRIG_PACK_RST) begin
 		package_cnt <= 0;
 	end else begin
 		if (TRIG_ETH_TX)
 			package_cnt	<=	package_cnt + 1;
 		else
 			package_cnt	<=	package_cnt;
 	end
 end
 //--------------------ip_identif------------------------
 always @(posedge CLK_125M) begin : proc_identif
 	if(SYS_RST) begin
 		ip_identif <= 0;
 	end else begin
 		if (UDP_LAST)
 			ip_identif	<=	ip_identif + 1;
 		else
 			ip_identif	<=	ip_identif;
 	end
 end

//--------- assign ------------------
always @(posedge CLK_125M) begin : proc_assign
	if(SYS_RST) begin
		udp_current_state <= IDLE;
	end else begin
		udp_current_state <= udp_next_state;
	end
end	

//---------- jump -------------------
always @(*) begin : proc_jump
	case (udp_current_state)
		IDLE			:	udp_next_state	=	trig_tx_cks				?	PREWORK			:	IDLE;
		PREWORK			:	udp_next_state	=	TX_ETH_HEADER;
		TX_ETH_HEADER	:	udp_next_state	=	flag_eth_header_over	?	TX_IP_HEADER	:	TX_ETH_HEADER;	
		TX_IP_HEADER	:	udp_next_state	=	flag_ip_header_over		?	TX_UDP_HEADER	:	TX_IP_HEADER;
		TX_UDP_HEADER	:	if (flag_udp_header_over && state_ad)
								udp_next_state	=	TX_DATA;
							else if (flag_udp_header_over && state_motor )
								udp_next_state	=	TX_STATE;
							else
								udp_next_state	=	TX_UDP_HEADER;
		TX_DATA			:	udp_next_state	=	flag_data_over			?	IDLE			:	TX_DATA;
		TX_STATE		:	udp_next_state	=	flag_data_over			?	IDLE			:	TX_STATE;
		default 		:	udp_next_state	=	IDLE;
	endcase
end

//---------- output -------------------
always @(posedge CLK_125M) begin : proc_output
	if(SYS_RST) begin
		o_udp_data           <=  0;
		o_udp_valid          <=  0;
		o_udp_last           <=  0;
		o_ad_ready           <=  0;
		o_state_ready		 <=	 0;

		eth_temp             <=  0;
		ip_temp              <=  0;
		udp_temp[63:48]      <=  FPGA_SP;
		udp_temp[47:32]      <=  FPGA_DP;
		udp_temp[31:00]		 <=  0;

		flag_eth_header_over <=  0;
		flag_ip_header_over  <=  0;
		flag_udp_header_over <=  0;
		flag_data_over       <=  0;

		udp_word_cnt         <=  0;
	end else begin
		case (udp_next_state)
			IDLE	:	begin 
				o_udp_data           <=  0;
				o_udp_valid          <=  0;
				o_udp_last           <=  0;
				o_ad_ready           <=  0;
				o_state_ready		 <=	 0;

				eth_temp             <=  0;
				ip_temp              <=  0;
				udp_temp[63:48]      <=  FPGA_SP;
				udp_temp[47:32]      <=  FPGA_DP;
				udp_temp[31:00]		 <=  0;

				flag_eth_header_over <=  0;
				flag_ip_header_over  <=  0;
				flag_udp_header_over <=  0;
				flag_data_over       <=  0;

				udp_word_cnt         <=  0;
			end

			PREWORK	:	begin 
				udp_temp[31:00] <=  {(UDP_WORD + udp_len),udp_cks};								
				eth_temp       	<=  {PC_MAC,FPGA_MAC,IP_TYPE}; 	//	以太网首部		
				ip_temp         <=  {IP_VS_LEN_TOS,(IP_WORD + UDP_WORD + udp_len),ip_identif,IP_FLAG_OFFSET,{IP_TTL,UDP_PROTO},ip_cks,FPGA_IP,PC_IP};
 	        	
			end

			TX_ETH_HEADER	:	begin 
				o_udp_valid              <=  1;  
				if (udp_word_cnt == ETH_WORD - 1) begin 
					udp_word_cnt         <=  0;
					o_udp_data           <=  eth_temp[((ETH_WORD - 1)-udp_word_cnt)*8 +: 8];
					flag_eth_header_over <=  1;
				end
				else if (udp_word_cnt == 0 || UDP_READY) begin 
					if (UDP_VALID)
						udp_word_cnt     <=  udp_word_cnt + 1;
					else
						udp_word_cnt     <=  udp_word_cnt;
					o_udp_data           <=  eth_temp[((ETH_WORD - 1)-udp_word_cnt)*8 +: 8];             
				end
				else begin 
					udp_word_cnt         <=  udp_word_cnt;
					o_udp_data           <=  o_udp_data;
				end				
			end

			TX_IP_HEADER	:	begin 
				o_udp_valid              <=  1;  
				if (udp_word_cnt == IP_WORD - 1) begin 
					udp_word_cnt         <=  0;
					o_udp_data           <=  ip_temp[((IP_WORD - 1)-udp_word_cnt)*8 +: 8];
					flag_ip_header_over <=  1;
				end
				else if (udp_word_cnt == 0 || UDP_READY) begin 
					if (UDP_VALID)
						udp_word_cnt     <=  udp_word_cnt + 1;
					else
						udp_word_cnt     <=  udp_word_cnt;
					o_udp_data           <=  ip_temp[((IP_WORD - 1)-udp_word_cnt)*8 +: 8];             
				end
				else begin 
					udp_word_cnt         <=  udp_word_cnt;
					o_udp_data           <=  o_udp_data;
				end					
			end

			TX_UDP_HEADER	:	begin 
				o_udp_valid              <=  1;  
				if (udp_word_cnt == UDP_WORD - 1) begin 
					udp_word_cnt         <=  0;
					o_udp_data           <=  udp_temp[((UDP_WORD - 1)-udp_word_cnt)*8 +: 8];
					flag_udp_header_over <=  1;
				end
				else if (udp_word_cnt == 0 || UDP_READY) begin 
					if (UDP_VALID)
						udp_word_cnt     <=  udp_word_cnt + 1;
					else
						udp_word_cnt     <=  udp_word_cnt;
					o_udp_data           <=  udp_temp[((UDP_WORD - 1)-udp_word_cnt)*8 +: 8];             
				end
				else begin 
					udp_word_cnt         <=  udp_word_cnt;
					o_udp_data           <=  o_udp_data;
				end					
			end

			TX_DATA	:	begin 
				o_udp_valid          <=  1;  
				if (udp_word_cnt == udp_len - 1) begin 
					udp_word_cnt     <=  0;
					o_udp_data       <=  AD_TDATA[7:0];
					o_udp_last       <=  1;
					o_ad_ready       <=  0;
					flag_data_over   <=  1;
				end
				else if (udp_word_cnt == 0 || UDP_READY) begin 
					if (UDP_VALID)
						udp_word_cnt <=  udp_word_cnt + 1;
					else
						udp_word_cnt <=  udp_word_cnt;
//					o_udp_data       <=  (udp_word_cnt < 4) ? FLAG_MOTOR[(3-udp_word_cnt)*8 +: 8] : (udp_word_cnt[0] ? AD_TDATA[7:0] : AD_TDATA[15:8]);             
					if (udp_word_cnt < 4) begin 
						o_udp_data	 <=	FLAG_AD[(3-udp_word_cnt)*8 +: 8];
					end
					else if (udp_word_cnt == 4)
						o_udp_data	<=	package_cnt[31:24];
					else if (udp_word_cnt == 5)
						o_udp_data	<=	package_cnt[23:16];
					else if (udp_word_cnt == 6)
						o_udp_data	<=	package_cnt[15:08];
					else if (udp_word_cnt == 7)
						o_udp_data	<=	package_cnt[07:00];					
					else
						o_udp_data	<=	udp_word_cnt[0] ? AD_TDATA[7:0] : AD_TDATA[15:8];
					o_ad_ready       <=  (udp_word_cnt < 8) ? 0 : !udp_word_cnt[0];
				end
				else begin 
					udp_word_cnt     <=  udp_word_cnt;
					o_udp_data       <=  o_udp_data;
					o_ad_ready		 <=	 o_ad_ready;
				end								
			end
			TX_STATE	:	begin 
				o_udp_valid          <=  1;  
				if (udp_word_cnt == udp_len - 1) begin 
					udp_word_cnt     <=  0;
					o_udp_data       <=  MOTOR_STATE_TDATA[7:0];
					o_udp_last       <=  1;
					o_state_ready    <=  0;
					flag_data_over   <=  1;
				end
				else if (udp_word_cnt == 0 || UDP_READY) begin 
					if (UDP_VALID)
						udp_word_cnt <=  udp_word_cnt + 1;
					else
						udp_word_cnt <=  udp_word_cnt;
//                    o_udp_data     <=  (udp_word_cnt < 4) ? FLAG_MOTOR[(3-udp_word_cnt)*8 +: 8] : (udp_word_cnt[0] ? AD_TDATA[7:0] : AD_TDATA[15:8]);             
					if (udp_word_cnt < 4) begin 
						o_udp_data   <= FLAG_MOTOR[(3-udp_word_cnt)*8 +: 8];
					end
					else
						o_udp_data   <=  udp_word_cnt[0] ? MOTOR_STATE_TDATA[7:0] : MOTOR_STATE_TDATA[15:8];
					o_state_ready    <=  (udp_word_cnt < 4) ? 0 : !udp_word_cnt[0];
				end
				else begin 
					udp_word_cnt     <=  udp_word_cnt;
					o_udp_data       <=  o_udp_data;
					o_state_ready    <=  o_state_ready;
				end								
			end			
			default : begin 
				o_udp_data           <=  0;
				o_udp_valid          <=  0;
				o_udp_last           <=  0;
				o_ad_ready           <=  0;
				o_state_ready		 <=	 0;

				eth_temp             <=  0;
				ip_temp              <=  0;
				udp_temp             <=  0;

				flag_eth_header_over <=  0;
				flag_ip_header_over  <=  0;
				flag_udp_header_over <=  0;
				flag_data_over       <=  0;

				udp_word_cnt         <=  0;				
			end
		endcase
	end
end
endmodule
