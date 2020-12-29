`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/02 09:03:23
// Design Name: 
// Module Name: TX_ICMP
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


module TX_ICMP#(
	// FPGA firmware information
	parameter FPGA_MAC	=	48'h00D0_0800_0002,
	parameter FPGA_IP	=	32'hC0A8_006E,
    parameter FPGA_DP    =   16'd8008,                   //  UDP目的端口号8080
    parameter FPGA_SP    =   16'd8008  
    )(
    input   CLK_125M,
    input   SYS_RST,  // synchronous reset active high
    input	TRIG_TX_ICMP,
  	// RGMII TX ICMP
	output	[7:0]	ICMP_DATA,  	
	input	ICMP_READY,
	output	ICMP_LAST,
	output	ICMP_VALID,
	//	ARP
	input	TRIG_TX_ARP,
	input	[47:0]	PC_MAC,
	input	[31:0]	PC_IP,
	// AXIS DATA TRANSFER
	input  	RX_ICMP_TVALID,
	output  RX_ICMP_TREADY,
	input	RX_ICMP_TLAST,
	input  	[7:0]  RX_ICMP_TDATA,
	input	[31:0]  RX_ICMP_TUSER	    
    );
      `include "ETH_TX.vh"
 //--------- state machine ----------
localparam  IDLE          =   3'd0,
			PREWORK       =   3'd1,
			TX_ETH_HEADER =   3'd2,
			TX_IP_HEADER  =   3'd3,
			TX_ICMP_HEADER =   3'd4,
			TX_DATA       =   3'd5;

(* dont_touch = "TRUE" *)reg [2:0]	icmp_current_state	=	0,
			icmp_next_state		=	0; 
//--------- ports -------------------
(* dont_touch = "TRUE" *)reg [7:0]	o_icmp_data		=	0;
(* dont_touch = "TRUE" *)reg			o_icmp_valid	=	1'b0,
			o_icmp_last		=	1'b0;
(* dont_touch = "TRUE" *)reg			o_icmp_ready	=	1'b0;
//--------- counter ------------------
(* dont_touch = "TRUE" *)reg	[7:0]	icmp_word_cnt	=	0;

//--------- flags --------------------
reg			flag_prework_over		=	1'b0,
			flag_eth_header_over	=	1'b0,
			flag_icmp_header_over	=	1'b0,
			flag_ip_header_over		=	1'b0,
			flag_data_over			=	1'b0;

reg 		trig_icmp_cks 	=	1'b0;
wire		trig_tx_cks;
//--------- registers --------------------
reg [111:0] eth_temp	=   0;

reg [159:0] ip_temp		=   0; 
reg [15:0]  ip_identif	=   0; 
reg	[7:0]	ip_ttl 		=	0;
wire[15:0]	ip_cks;

reg [63:0]  icmp_temp 	=   0;
wire[15:0]	icmp_cks;
reg [31:0]  icmp_sum	=   0;
reg [15:0]	icmp_identif=	0,
			icmp_sequ	=	0;

//--------- output --------------------
assign  ICMP_DATA      =   o_icmp_data;
assign  ICMP_VALID     =   o_icmp_valid;
assign  ICMP_LAST      =   o_icmp_last;
assign  RX_ICMP_TREADY =   o_icmp_ready;

	GET_CKS #(
			.FPGA_MAC(FPGA_MAC),
			.FPGA_IP(FPGA_IP),
			.FPGA_DP(FPGA_DP),
			.FPGA_SP(FPGA_SP)
		) inst_GET_CKS (
			.CLK_125M      (CLK_125M),
			.SYS_RST       (SYS_RST || ICMP_LAST),
			.TRIG_UDP_CKS  (0),
			.TRIG_ICMP_CKS (trig_icmp_cks),
			.PC_IP         (PC_IP),
			.IP_IDENTIF    (ip_identif),
			.UDP_DATA_SUM  (0),
			.UDP_DATA_LEN  (0),
			.ICMP_DATA_SUM (icmp_sum),
			.IP_CKS        (ip_cks),
			.ICMP_CKS      (icmp_cks),
			.UDP_CKS       (),
			.TRIG_TX_CKS   (trig_tx_cks)
		);

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
		IDLE			:	icmp_next_state	=	TRIG_TX_ICMP			?	PREWORK			:	IDLE;
		PREWORK			:	icmp_next_state	=	flag_prework_over		?	TX_ETH_HEADER	:	PREWORK;
		TX_ETH_HEADER	:	icmp_next_state	=	flag_eth_header_over	?	TX_IP_HEADER	:	TX_ETH_HEADER;	
		TX_IP_HEADER	:	icmp_next_state	=	flag_ip_header_over		?	TX_ICMP_HEADER	:	TX_IP_HEADER;
		TX_ICMP_HEADER	:	icmp_next_state	=	flag_icmp_header_over	?	TX_DATA			:	TX_ICMP_HEADER;
		TX_DATA			:	icmp_next_state	=	flag_data_over			?	IDLE			:	TX_DATA;
		default 		:	icmp_next_state	=	IDLE;
	endcase
end

//---------- output -------------------
always @(posedge CLK_125M) begin : proc_output
	if(SYS_RST) begin
		o_icmp_ready          <=  0;
		o_icmp_data           <=  0;
		o_icmp_valid          <=  0;
		o_icmp_last           <=  0;

		eth_temp              <=  0;
		ip_temp               <=  0;
		icmp_temp             <=  0;

		ip_identif            <=  0;
		ip_ttl                <=  0;

		icmp_sum              <=  0;
		icmp_identif          <=  0;
		icmp_sequ             <=  0;

		trig_icmp_cks         <=  0;
		flag_prework_over     <=  0;
		flag_eth_header_over  <=  0;
		flag_ip_header_over   <=  0;
		flag_icmp_header_over <=  0;
		flag_data_over        <=  0;
	end else begin
		case (icmp_next_state)
			IDLE	:	begin 
				o_icmp_ready          <=  0;
				o_icmp_data           <=  0;
				o_icmp_valid          <=  0;
				o_icmp_last           <=  0;

				eth_temp              <=  0;
				ip_temp               <=  0;
				icmp_temp             <=  0;

				ip_identif            <=  0;
				ip_ttl                <=  0;

				icmp_sum              <=  0;
				icmp_identif          <=  0;
				icmp_sequ             <=  0;

				trig_icmp_cks         <=  0;
				flag_prework_over     <=  0;
				flag_eth_header_over  <=  0;
				flag_ip_header_over   <=  0;
				flag_icmp_header_over <=  0;
				flag_data_over        <=  0;
			end
			PREWORK	:	begin 
				icmp_sum	<=	RX_ICMP_TUSER;

				if (trig_tx_cks) begin
					eth_temp		  <=  {PC_MAC,FPGA_MAC,IP_TYPE};
					ip_temp           <=  {IP_VS_LEN_TOS,(16'h0 + IP_WORD + ICMP_WORD),ip_identif,16'h0,{ip_ttl,ICMP_PROTO},ip_cks,FPGA_IP,PC_IP};
					icmp_temp         <=  {ICMP_TYPE,ICMP_CODE,icmp_cks,icmp_identif,icmp_sequ};                 
					icmp_word_cnt     <=  0;
					trig_icmp_cks     <=  0;
					flag_prework_over <=  1;
				end				
				else if (icmp_word_cnt	== 6) begin 
					icmp_word_cnt     <=  icmp_word_cnt;
					trig_icmp_cks     <=  1;
					o_icmp_ready      <= 0;
				end
				else begin
					if (RX_ICMP_TREADY && RX_ICMP_TVALID)
						icmp_word_cnt <=  icmp_word_cnt + 1;
					else
						icmp_word_cnt <=  icmp_word_cnt;
					o_icmp_ready      <= 1;
					ip_temp           <= 0;
					icmp_temp         <= 0;                 
				end

				if (RX_ICMP_TREADY) begin
					case (icmp_word_cnt)
						8'd0	:	begin	ip_identif[15:8] 	<= RX_ICMP_TDATA;	end
						8'd1	:	begin 	ip_identif[07:0] 	<= RX_ICMP_TDATA;	end
						8'd2	:	begin 	ip_ttl 				<= RX_ICMP_TDATA;	end
						8'd3	:	begin 	icmp_identif[15:8] 	<= RX_ICMP_TDATA;	end	
						8'd4	:	begin 	icmp_identif[07:0] 	<= RX_ICMP_TDATA;	end	
						8'd5	:	begin 	icmp_sequ[15:8] 		<= RX_ICMP_TDATA;	end	
						8'd6	:	begin 	icmp_sequ[07:0] 		<= RX_ICMP_TDATA;	end	
						default : 	begin 	end
					endcase
				end
				else begin 
					ip_identif	<=	ip_identif;
					ip_ttl		<=	ip_ttl;
					icmp_identif<=	icmp_identif;
					icmp_sequ	<=	icmp_sequ;
				end
			end

			TX_ETH_HEADER	:	begin 
				o_icmp_valid              <=  1;  
				if (icmp_word_cnt == ETH_WORD - 1) begin 
					icmp_word_cnt         <=  0;
					o_icmp_data           <=  eth_temp[((ETH_WORD - 1)-icmp_word_cnt)*8 +: 8];
					flag_eth_header_over <=  1;
				end
				else if (icmp_word_cnt == 0 || ICMP_READY) begin 
					if (ICMP_VALID)
						icmp_word_cnt     <=  icmp_word_cnt + 1;
					else
						icmp_word_cnt     <=  icmp_word_cnt;
					o_icmp_data           <=  eth_temp[((ETH_WORD - 1)-icmp_word_cnt)*8 +: 8];             
				end
				else begin 
					icmp_word_cnt         <=  icmp_word_cnt;
					o_icmp_data           <=  o_icmp_data;
				end				
			end
			TX_IP_HEADER	:	begin 
				o_icmp_valid              <=  1;  
				if (icmp_word_cnt == IP_WORD - 1) begin 
					icmp_word_cnt         <=  0;
					o_icmp_data           <=  ip_temp[((IP_WORD - 1)-icmp_word_cnt)*8 +: 8];
					flag_ip_header_over <=  1;
				end
				else if (icmp_word_cnt == 0 || ICMP_READY) begin 
					if (ICMP_VALID)
						icmp_word_cnt     <=  icmp_word_cnt + 1;
					else
						icmp_word_cnt     <=  icmp_word_cnt;
					o_icmp_data           <=  ip_temp[((IP_WORD - 1)-icmp_word_cnt)*8 +: 8];             
				end
				else begin 
					icmp_word_cnt         <=  icmp_word_cnt;
					o_icmp_data           <=  o_icmp_data;
				end					
			end	
			TX_ICMP_HEADER	:	begin 
				o_icmp_valid              <=  1;  
				if (icmp_word_cnt == ICMP_WORD - 32 - 1) begin 
					icmp_word_cnt         <=  0;
					o_icmp_data           <=  icmp_temp[((ICMP_WORD - 32- 1)-icmp_word_cnt)*8 +: 8];
					o_icmp_ready      	  <=  1;
					flag_icmp_header_over <=  1;
				end
				else if (icmp_word_cnt == 0 || ICMP_READY) begin 
					if (ICMP_VALID)
						icmp_word_cnt     <=  icmp_word_cnt + 1;
					else
						icmp_word_cnt     <=  icmp_word_cnt;
					o_icmp_data           <=  icmp_temp[((ICMP_WORD - 32- 1)-icmp_word_cnt)*8 +: 8];             
				end
				else begin 
					icmp_word_cnt         <=  icmp_word_cnt;
					o_icmp_data           <=  o_icmp_data;
				end					
			end	
			TX_DATA	:	begin 
				o_icmp_valid              <=  1;  
				if (icmp_word_cnt == ICMP_WORD - 8 - 1) begin 
					icmp_word_cnt     <=  0;
					o_icmp_data       <=  RX_ICMP_TDATA;
					o_icmp_ready      <=  0;
					o_icmp_last       <=  1;
					flag_data_over    <=  1;
				end
				else if (icmp_word_cnt == 0 || ICMP_READY) begin 
					if (ICMP_VALID)
						icmp_word_cnt <=  icmp_word_cnt + 1;
					else
						icmp_word_cnt <=  icmp_word_cnt;
					o_icmp_data       <=  RX_ICMP_TDATA;		             
				end
				else begin 
					icmp_word_cnt     <=  icmp_word_cnt;
					o_icmp_data       <=  o_icmp_data;
				end					
			end											
			default : begin 
				o_icmp_ready          <=  0;
				o_icmp_data           <=  0;
				o_icmp_valid          <=  0;
				o_icmp_last           <=  0;

				eth_temp              <=  0;
				ip_temp               <=  0;
				icmp_temp             <=  0;

				ip_identif            <=  0;
				ip_ttl                <=  0;

				icmp_sum              <=  0;
				icmp_identif          <=  0;
				icmp_sequ             <=  0;

				trig_icmp_cks         <=  0;
				flag_prework_over     <=  0;
				flag_eth_header_over  <=  0;
				flag_ip_header_over   <=  0;
				flag_icmp_header_over <=  0;
				flag_data_over        <=  0;				
			end
		endcase
	end
end
endmodule
