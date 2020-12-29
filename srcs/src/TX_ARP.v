`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/02 09:03:23
// Design Name: 
// Module Name: TX_ARP
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


module TX_ARP#(
	// FPGA firmware information
	parameter FPGA_MAC	=	48'h00D0_0800_0002,
	parameter FPGA_IP	=	32'hC0A8_006E
    )(
    input   CLK_125M,
    input   SYS_RST,  // Asynchronous reset active high 
 	// RGMII TX ARP
	input	ARP_READY,
	output	[7:0]	ARP_DATA,
	output	ARP_LAST,
	output	ARP_VALID,     	
 	//	ARP
	input	TRIG_TX_ARP,
	input	[47:0]	PC_MAC,
	input	[31:0]	PC_IP   
    );

    `include "ETH_TX.vh"

//--------- state machine ----------
localparam  IDLE          =   2'd0,
			PREWORK       =   2'd1,
			TX_ETH_HEADER =   2'd2,
			TX_ARP_HEADER =   2'd3;

reg [1:0]	arp_current_state	=	0,
			arp_next_state		=	0;

//--------- ports -------------------
reg [7:0]	o_arp_data	=	0;
reg			o_arp_valid	=	1'b0,
			o_arp_last	=	1'b0;

//--------- counter ------------------
reg	[7:0]	arp_word_cnt	=	0;

//--------- flags --------------------
reg			flag_eth_header_over	=	1'b0,
			flag_arp_header_over	=	1'b0;

//--------- registers --------------------
reg [111:0] eth_temp       =   0;
reg [223:0] arp_temp       =   0;

//--------- output --------------------
assign		ARP_DATA	=	o_arp_data;
assign		ARP_VALID	=	o_arp_valid;
assign		ARP_LAST	=	o_arp_last;

//--------- assign ------------------
always @(posedge CLK_125M) begin : proc_assign
	if(SYS_RST) begin
		arp_current_state <= IDLE;
	end else begin
		arp_current_state <= arp_next_state;
	end
end

//---------- jump -------------------
always @(*) begin : proc_jump
	case (arp_current_state)
		IDLE	:			arp_next_state	=	TRIG_TX_ARP	?	PREWORK : IDLE;
		
		PREWORK	:			arp_next_state	=	TX_ETH_HEADER;

		TX_ETH_HEADER	:	arp_next_state	=	flag_eth_header_over ? TX_ARP_HEADER : TX_ETH_HEADER;

		TX_ARP_HEADER	:	arp_next_state	=	flag_arp_header_over ? IDLE : TX_ARP_HEADER;
				
		default : 			arp_next_state	=	IDLE;
	endcase
end

//---------- output -------------------
always @(posedge CLK_125M) begin : proc_output
	if(SYS_RST) begin
		eth_temp             <=  0;
		arp_temp             <=  0;

		o_arp_data           <=  0;
		o_arp_valid          <=  0;
		o_arp_last           <=  0;

		arp_word_cnt         <=  0;
		flag_eth_header_over <=  0;
		flag_arp_header_over <=  0;
	end else begin
		case (arp_next_state)
			IDLE	:	begin
				eth_temp             <=  0;
				arp_temp             <=  0;

				o_arp_data           <=  0;
				o_arp_valid          <=  0;
				o_arp_last           <=  0;

				arp_word_cnt         <=  0;
				flag_eth_header_over <=  0;
				flag_arp_header_over <=  0;				
			end
			PREWORK	:	begin 
				eth_temp       	<=  {PC_MAC,FPGA_MAC,ARP_TYPE}; 	//	以太网首部	
				arp_temp		<=	{ARP_HEAD,FPGA_MAC,FPGA_IP,PC_MAC,PC_IP};				
			end
			TX_ETH_HEADER	:	begin 
				o_arp_valid              <=  1;  
				if (arp_word_cnt == ETH_WORD - 1) begin 
					arp_word_cnt         <=  0;
					o_arp_data           <=  eth_temp[((ETH_WORD - 1)-arp_word_cnt)*8 +: 8];
					flag_eth_header_over <=  1;
				end
				else if (arp_word_cnt == 0 || ARP_READY) begin
					if (ARP_VALID)
						arp_word_cnt     <=  arp_word_cnt + 1;
					else
						arp_word_cnt     <=  arp_word_cnt;
					o_arp_data           <=  eth_temp[((ETH_WORD - 1)-arp_word_cnt)*8 +: 8];             
				end
				else begin 
					arp_word_cnt         <=  arp_word_cnt;
					o_arp_data           <=  o_arp_data;
				end
			end
			TX_ARP_HEADER	:	begin 
				if (arp_word_cnt	==	ARP_WORD - 1) begin
					arp_word_cnt	<=	0;
					o_arp_data		<=	8'hFF;
					o_arp_last		<=	1;
					flag_arp_header_over	<=	1; 
				end
				else if (arp_word_cnt == 0 || ARP_READY) begin
					if (ARP_VALID)
						arp_word_cnt     <=  arp_word_cnt + 1;
					else
						arp_word_cnt     <=  arp_word_cnt;
					o_arp_data      <=  (arp_word_cnt < 28) ? arp_temp[((ARP_WORD - 1 - 20)-arp_word_cnt)*8 +: 8] : 8'hFF; 
				end
				else begin 
					arp_word_cnt	<=	arp_word_cnt;
					o_arp_data		<=	o_arp_data;
				end
			end
			default : begin 
				eth_temp             <=  0;
				arp_temp             <=  0;

				o_arp_data           <=  0;
				o_arp_valid          <=  0;
				o_arp_last           <=  0;

				arp_word_cnt         <=  0;
				flag_eth_header_over <=  0;
				flag_arp_header_over <=  0;					
			end
		endcase
	end
end
endmodule
