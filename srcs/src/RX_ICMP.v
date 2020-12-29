`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/08/31 18:42:17
// Design Name: 
// Module Name: RX_ICMP
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


module RX_ICMP#(
	// FPGA firmware information
	parameter FPGA_MAC =   48'h00D0_0800_0002,	
	parameter FPGA_IP  =   32'hC0A8_006E
   )(
    input   CLK_125M,
    input   SYS_RST,  // Asynchronous reset active high
    output	TRIG_TX_ICMP,
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
	output  ETH_ICMP_TVALID,
	input   ETH_ICMP_TREADY,
	output	ETH_ICMP_TLAST,
	output  [7:0]  ETH_ICMP_TDATA,
	output	[31:0] ETH_ICMP_TUSER
	);

`include "ETH_RX.vh"
//--------- state machine ------------
localparam  IDLE          =   3'd0,
			RX_ETH_HEADER =   3'd1,
			RX_IP_HEADER  =   3'd2,
			ICMP          =   3'd3,
			AXIS          =   3'd4;
(* dont_touch = "TRUE" *) reg [2:0]	icmp_current_state	=	0,
			icmp_next_state		=	0;

//---------- ports -----------
(* dont_touch = "TRUE" *)reg o_trig_tx_icmp   =   1'b0;
(* dont_touch = "TRUE" *)reg [7:0]  o_rx_data =   0;
(* dont_touch = "TRUE" *)reg [31:0] o_rx_user =   0;
(* dont_touch = "TRUE" *)reg o_rx_valid       =   1'b0;
(* dont_touch = "TRUE" *)reg o_rx_last        =   1'b0;

//--------- counter ------------------
(* dont_touch = "TRUE" *)reg	[7:0]	icmp_word_cnt	=	0;
//--------- flags --------------------
reg	flag_eth_header_over	=	1'b0,
	flag_ip_header_over		=	1'b0,
	flag_icmp_over			=	1'b0,
	flag_frame_err			=	1'b0;

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
	//	icmp
reg [7:0]   icmp_type     =    8'h0,
            icmp_code     =    8'h0;
reg [31:0]  icmp_data_sum =    32'h0;                                                   
reg	[7:0]	rgmii_rx_data_d	=	0;  

//---------- output -----------
assign	TRIG_TX_ICMP	=	o_trig_tx_icmp;
assign	ETH_ICMP_TDATA	=	o_rx_data;
assign	ETH_ICMP_TVALID	=	o_rx_valid;
assign	ETH_ICMP_TLAST	=	o_rx_last;
assign	ETH_ICMP_TUSER	=	o_rx_user;

//--------- assign ------------------
always @(posedge CLK_125M) begin : proc_assign
	if(SYS_RST) begin
		icmp_current_state <= IDLE;
	end else begin
		icmp_current_state <= icmp_next_state;
	end
end

//---------- jump -------------------
always @(*) begin : proc_jump
	case (icmp_current_state)
		IDLE	:			icmp_next_state	=	(RGMII_RX_VALID && !RGMII_RX_LAST)	?	RX_ETH_HEADER : IDLE;
		
		RX_ETH_HEADER	:	if (flag_frame_err || RGMII_RX_LAST)
								icmp_next_state	=	IDLE;
							else if (flag_eth_header_over)
								icmp_next_state	=	RX_IP_HEADER;
							else
								icmp_next_state	=	RX_ETH_HEADER;

		RX_IP_HEADER	:	if (flag_frame_err)
								icmp_next_state	=	IDLE;
							else if (flag_ip_header_over)
								icmp_next_state	=	ICMP;
							else
								icmp_next_state	=	RX_IP_HEADER;		

		ICMP	:			if (flag_frame_err)
								icmp_next_state	=	IDLE;
							else if (flag_icmp_over)
								icmp_next_state	=	AXIS;
							else
								icmp_next_state	=	ICMP;

		AXIS	:			if (o_trig_tx_icmp)
								icmp_next_state	=	IDLE;
							else
								icmp_next_state =	AXIS;

		default : 			icmp_next_state	=	IDLE;
	endcase
end

//---------- output -------------------
always @(posedge CLK_125M) begin : proc_output
	if(SYS_RST) begin
		o_rx_data            <=  0;
		o_rx_valid           <=  0;
		o_rx_last            <=  0;
		o_trig_tx_icmp		 <=	 0;

		rx_eth_type          <=  0;
		rx_eth_da_mac        <=  0;
		rx_eth_sa_mac        <=  0;
		rx_ip_vision         <=  0;
		rx_sa_ip             <=  0;
		rx_da_ip             <=  0;
		rx_ip_idf            <=  0;
		rx_ip_proto          <=  0;
		rx_ip_ttl            <=  0;
		icmp_type            <=  0;
		icmp_code            <=  0;
		icmp_data_sum        <=  0;

		flag_frame_err       <=  0;
		flag_icmp_over       <=  0;
		flag_eth_header_over <=  0;
		flag_ip_header_over  <=  0;

		icmp_word_cnt        <=  0;
		rgmii_rx_data_d		 <=	 0;
	end else begin
		rgmii_rx_data_d	<=	RGMII_RX_DATA;
		case (icmp_next_state)
			IDLE	:	begin 
				o_rx_data            <=  0;
				o_rx_valid           <=  0;
				o_rx_last            <=  0;
				o_trig_tx_icmp		 <=	 0;

				rx_eth_type          <=  0;
				rx_eth_da_mac        <=  0;
				rx_eth_sa_mac        <=  0;
				rx_ip_vision         <=  0;
				rx_sa_ip             <=  0;
				rx_da_ip             <=  0;
				rx_ip_idf            <=  0;
				rx_ip_proto          <=  0;
				rx_ip_ttl            <=  0;
				icmp_type            <=  0;
				icmp_code            <=  0;
				icmp_data_sum        <=  0;

				flag_frame_err       <=  0;
				flag_icmp_over       <=  0;
				flag_eth_header_over <=  0;
				flag_ip_header_over  <=  0;

				icmp_word_cnt        <=  0;
			end
			RX_ETH_HEADER	:	begin 
	            if (icmp_word_cnt == ETH_WORD) begin               	
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
						icmp_word_cnt    <=  icmp_word_cnt + 1;
					else
						icmp_word_cnt    <=  icmp_word_cnt;			
				end		
					
				case (icmp_word_cnt) 
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
					 ETH_WORD: begin icmp_word_cnt <= 1;end
					 default : begin  end
				endcase				
			end
			RX_IP_HEADER	:	begin 
		        if (icmp_word_cnt == IP_WORD) begin
					if (rx_ip_vision != 8'h45) begin // 版本+首部长度 
						flag_frame_err          <=  1;
						flag_ip_header_over     <=  0;
					end 			
					else if (rx_ip_proto == ICMP_PROTO && {rx_sa_ip,rx_da_ip} ==  {PC_IP,FPGA_IP}) begin	// ICMP帧 01
							flag_frame_err      <=  0;      
							flag_ip_header_over <=  1;
							icmp_type           <=  RGMII_RX_DATA;
					end
	                else begin
	                    flag_frame_err          <=  1;
						flag_ip_header_over     <=  0;
	                end
	                icmp_word_cnt <= 1;
	            end
				else begin 
					if (RGMII_RX_VALID)		
						icmp_word_cnt    <=  icmp_word_cnt + 1;
					else
						icmp_word_cnt    <=  icmp_word_cnt;			
				end	
					
				case (icmp_word_cnt) 
					 // 8位服务类型
					 8'd01: begin end
					 // 16位IP总长度 = 20字节IP帧头 + 8字节UDP帧头 + 数据
					 8'd02: begin end	
					 8'd03: begin end
					 // 16位标识 用于ICMP返回
					 8'd04: begin rx_ip_idf[15:08] <= RGMII_RX_DATA; end
					 8'd05: begin rx_ip_idf[07:00] <= RGMII_RX_DATA; end		// 不清零
					 // 16位标志+偏移                                
					 8'd06: begin end
					 8'd07: begin end
					 // 8位 TTL	用于ICMP返回
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
			ICMP : begin 
				if (icmp_word_cnt == ICMP_WORD) begin
					if (icmp_type == PING_REQ) begin
						flag_frame_err <=  0;
						flag_icmp_over <=  1;
					end
					else begin
						flag_frame_err <=  1;
						flag_icmp_over <=  0;
					end
					icmp_word_cnt <= 1;				
				end
				else begin
					if (RGMII_RX_VALID)
						icmp_word_cnt <=  icmp_word_cnt + 1;
					else
						icmp_word_cnt <=  icmp_word_cnt;
				end
					
				casex (icmp_word_cnt) 
					 // 8 CODE
					 8'd01: begin icmp_code[07:00] <= RGMII_RX_DATA; o_rx_valid<= 1;o_rx_data	<=	rx_ip_idf[15:8];end
					 // 16 CKS
					 8'd02: begin o_rx_valid<= 1;o_rx_data	<=	rx_ip_idf[7:0];end
					 8'd03: begin o_rx_valid<= 1;o_rx_data	<=	rx_ip_ttl;end	
					 // DATA
					 8'b0000_01xx,8'b0000_1xxx,8'b0001_xxxx,8'b0010_0xxx : begin 
					              o_rx_data       <= RGMII_RX_DATA;
					              o_rx_valid      <= RGMII_RX_VALID;
					 			  if (icmp_word_cnt[0] && RGMII_RX_VALID) 
					                icmp_data_sum <=  icmp_data_sum + {rgmii_rx_data_d,RGMII_RX_DATA};
					 			  else
					                icmp_data_sum <=  icmp_data_sum;  
					            o_rx_last         <=  RGMII_RX_LAST;
					 end	
					 ICMP_WORD:begin o_rx_data	<=	0;o_rx_valid<= 0;end
					 default : begin o_rx_data	<=	0;o_rx_valid<= 0;end
				endcase				
			end
			AXIS	:	begin 
				o_rx_data      <= 0;
				o_rx_valid     <= 0;
				o_rx_last      <= 0;
				o_rx_user      <=  icmp_data_sum;
				o_trig_tx_icmp <= 1;
			end
			default : begin 
				o_rx_data            <=  0;
				o_rx_valid           <=  0;
				o_rx_last            <=  0;
				o_trig_tx_icmp		 <=	 0;

				rx_eth_type          <=  0;
				rx_eth_da_mac        <=  0;
				rx_eth_sa_mac        <=  0;
				rx_ip_vision         <=  0;
				rx_sa_ip             <=  0;
				rx_da_ip             <=  0;
				rx_ip_idf            <=  0;
				rx_ip_proto          <=  0;
				rx_ip_ttl            <=  0;
				icmp_type            <=  0;
				icmp_code            <=  0;
				icmp_data_sum        <=  0;

				flag_frame_err       <=  0;
				flag_icmp_over       <=  0;
				flag_eth_header_over <=  0;
				flag_ip_header_over  <=  0;

				icmp_word_cnt        <=  0;
			end
		endcase
	end
end
endmodule
