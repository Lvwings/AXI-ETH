`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/11 10:09:31
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
   	output                            	axi_wready, // Indicates slave is ready to accept a 
   	input [C_AXI_ID_WIDTH-1:0]        	axi_wid,    // Write ID
   	input [C_AXI_ADDR_WIDTH-1:0]      	axi_waddr,  // Write address
   	input [7:0]                       	axi_wlen,   // Write Burst Length
   	input [2:0]                       	axi_wsize,  // Write Burst size
   	input [1:0]                       	axi_wburst, // Write Burst type
   	input [1:0]                       	axi_wlock,  // Write lock type
   	input [3:0]                       	axi_wcache, // Write Cache type
   	input [2:0]                       	axi_wprot,  // Write Protection type
   	input                             	axi_wvalid, // Write address valid
  
// AXI write data channel signals
   	output                            	axi_wd_wready,  // Write data ready
   	input [C_AXI_DATA_WIDTH-1:0]      	axi_wd_wdata,    // Write data
   	input [C_AXI_DATA_WIDTH/8-1:0]    	axi_wd_wstrb,    // Write strobes
   	input                             	axi_wd_wlast,    // Last write transaction   
   	input                             	axi_wd_wvalid,   // Write valid
  
// AXI write response channel signals
   	output  [C_AXI_ID_WIDTH-1:0]      	axi_wb_bid,     // Response ID
   	output  [1:0]                     	axi_wb_bresp,   // Write response
   	output                            	axi_wb_bvalid,  // Write reponse valid
   	input                             	axi_wb_bready,  // Response ready
  
// AXI read address channel signals
   	output                            	axi_rready,     // Read address ready
   	input [C_AXI_ID_WIDTH-1:0]        	axi_rid,        // Read ID
   	input [C_AXI_ADDR_WIDTH-1:0]      	axi_raddr,      // Read address
   	input [7:0]                       	axi_rlen,       // Read Burst Length
   	input [2:0]                       	axi_rsize,      // Read Burst size
   	input [1:0]                       	axi_rburst,     // Read Burst type
   	input [1:0]                       	axi_rlock,      // Read lock type
   	input [3:0]                       	axi_rcache,     // Read Cache type
   	input [2:0]                       	axi_rprot,      // Read Protection type
   	input                             	axi_rvalid,     // Read address valid
  
// AXI read data channel signals   
   	output  [C_AXI_ID_WIDTH-1:0]       	axi_rd_bid,     // Response ID
   	output  [1:0]                      	axi_rd_rresp,   // Read response
   	output                             	axi_rd_rvalid,  // Read reponse valid
   	output  [C_AXI_DATA_WIDTH-1:0]     	axi_rd_rdata,   // Read data
   	output                             	axi_rd_rlast,   // Read last
   	input                              	axi_rd_rready,   // Read Response ready

	// AXIS TX RGMII
    output   [7:0]   					rgmii_tx_data,
    output   							rgmii_tx_valid,
    output   							rgmii_tx_last,
	output								rgmii_tx_user,
	input								rgmii_tx_ready, 

	//	ARP
	input	[47:0]						pc_mac,
	input	[31:0]						pc_ip,

	input								trig_package_rst,
	input								trig_arp	
    );


//*****************************************************************************
// AXI Internal register and wire declarations
//*****************************************************************************

// AXI write address channel signals

	reg [C_AXI_ID_WIDTH-1:0]        wr_wid 		=	0;
	reg [C_AXI_ADDR_WIDTH-1:0]      wr_waddr	=	0;
	reg [7:0]                       wr_wlen		=	0;
	reg [1:0]                       wr_wburst	=	0;
	reg                             wr_wready	=	1'b0;

// AXI write data channel signals

	reg [C_AXI_DATA_WIDTH-1:0]      wd_wdata	=	0;
	reg [C_AXI_DATA_WIDTH/8-1:0]    wd_wstrb	=	0;
	reg                             wd_wready	=	1'b0;

// AXI write response channel signals
	
	reg								wb_bvalid 	=	1'b0;
	reg	[C_AXI_ID_WIDTH-1:0]      	wb_bid		=	0;
	reg [1:0]                     	wb_bresp	=	0;

// AXI read address channel signals

	reg [C_AXI_ID_WIDTH-1:0]        rr_rid 		=	0;
	reg [C_AXI_ADDR_WIDTH-1:0]      rr_raddr	=	0;
	reg [7:0]                       rr_rlen		=	0;
	reg [2:0]                       rr_rsize	=	0;
	reg [1:0]                       rr_rburst	=	0;
	reg                             rr_rready	=	1'b0;

// AXI read data channel signals
	
	reg [C_AXI_ID_WIDTH-1:0]        rd_rid 		=	0;
	reg [1:0]                       rd_rresp	=	0;
	reg								rd_rvalid	=	1'b0;
	reg [C_AXI_DATA_WIDTH-1:0]     	rd_rdata	=	0;  
	reg 							rd_rlast	=	1'b0;
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

	localparam	[2:0]	SUM_SIZE	=	clogb2(32/C_AXI_DATA_WIDTH-1);
//*****************************************************************************
// write Internal parameter declarations
//*****************************************************************************							
	localparam  [3:0]               WRITE_IDLE     = 4'd0, 
									WRITE_ADDR     = 4'd1,
									TX_WAIT		   = 4'd2,
									TX_ETH_HEADER  = 4'd3,
									TX_IP_HEADER   = 4'd4,								
									TX_UDP_HEADER  = 4'd5,
									WRITE_DATA     = 4'd6,										
									WRITE_RESPONSE = 4'd7,
									WRITE_TIME_OUT = 4'd8,
									TX_ARP         = 4'd9;									
	//	use one-hot encode								
   	reg [9:0]                       write_state      =   0,
									write_next       =   0;

	reg [WATCH_DOG_WIDTH : 0]       wt_watch_dog_cnt=   0;          
	reg                             trig_udp_start 	=   1'b0,
									trig_arp_start	=	1'b0;

	//	data sum will be transfered before data
 	reg [2:0]						flag_data_sum	 =	 0;

   	reg [7:0]                       write_data_cnt   =   0;

    //	tx_wd_cnt : the counter of rgmii_rx_data make up single axi_wd_wdata, begin with 0   
  	reg	[AXI_SIZE-1 : 0]				tx_wd_cnt	=	0;

//*****************************************************************************
// RGMII Internal register and wire declarations
//*****************************************************************************
	localparam  //------------以太网首部-----------------  //  000a_3501_fec0_ffff_ffff_ffff_0800
	            IP_TYPE     	= 16'h0800,                   //  IP帧
	            ARP_TYPE    	= 16'h0806,                   //    ARP帧
	            ETH_WORD    	= 8'd14,
	            //-------------IP首部---------------------//  4500_0014_0000_4000_8011_c0a8_0003_c0a8_0002
	            IP_VISION   	= 8'h45,
	            IP_FLAG_OFFSET	= 16'h4000,
	            UDP_PROTO   	= 8'h11,                      // UDP协议
	            ICMP_PROTO  	= 8'h01,                      // ICMP协议
	            IP_TTL          = 8'h80,
	            IP_WORD     	= 8'd20,
	            //-------------UDP首部--------------------//  1F90_1F90_0010_3F30
	            UDP_WORD    	= 8'd8, 
	            FLAG_WORD   	= 8'd4,	                      
	            //-------------ARP---------------------
	            ARP_HEAD       	= 64'h0001_0800_0604_0002,      //硬件类型+协议类型+硬件地址长度+协议地址长度+操作字段
	            ARP_WORD    	= 8'd28,                  	  //    28 + 18 18 位00填充
	            ARP_REQUEST 	= 16'h0001,
	            //-------------ICMP---------------------
	            PING_REQ    	= 8'h08,
	            ICMP_WORD   	= 8'd40;

	//--------- flags --------------------
	reg			flag_eth_header_over	=	1'b0,
				flag_ip_header_over		=	1'b0,
				flag_udp_header_over	=	1'b0,
				flag_arp_over			=	1'b0,
				flag_addr_over			=	1'b0,
				flag_wait_over			=	1'b0,
				flag_data_over			=	1'b0;

	reg 		trig_udp_cks 	=	1'b0;
	reg			trig_udp_cks_d	=	1'b0;

	//--------- registers -----------------
		//	eth header
	reg [111:0] eth_temp	=   0;
		//	ip header
	reg [159:0] ip_temp		=   0; 
	reg [15:0]  ip_identif	=   0; 
	wire[15:0]	ip_cks;
		//	udp header
	reg [63:0]	udp_temp	=   {FPGA_SP,FPGA_DP,32'h0};
	wire[15:0]	udp_cks;
	reg [31:0]	udp_sum		=   0;
	reg [15:0]	udp_len		=   0;
	reg [31:0]	udp_flag	=	0;
	reg [31:0]	data_sum 	=	0;
		//	arp
	reg [223:0] arp_temp       =   0;	
		//	counter
	reg	[15:0]	tx_word_cnt    =	0;
		// ports
	reg [7:0]	o_rgmii_data	=	0;	
	reg 		o_rgmii_valid	=	1'b0;
	reg 		o_rgmii_last	=	1'b0;
	
	reg [31:0]	package_cnt	=	0;

	//--------- ip udp cks -----------------
	reg [31:0]	ipcks_sum;
	reg [31:0] 	udpcks_sum;	
	reg 		ipcks_over;
	reg			udpcks_over;


	assign	rgmii_tx_data	=	o_rgmii_data;
	assign	rgmii_tx_valid	=	o_rgmii_valid;
	assign	rgmii_tx_last	=	o_rgmii_last;
//*****************************************************************************
// cks signals
//*****************************************************************************	
	always @(posedge sys_clk) begin
		if (sys_rst  || rgmii_tx_last) begin
			ipcks_sum  <= 0;
			ipcks_over <= 0;
		end
		else begin 
			if (!trig_udp_cks_d && trig_udp_cks) begin
				ipcks_sum	<=	{IP_VISION,8'h0} + (IP_WORD + UDP_WORD + udp_len) + ip_identif + IP_FLAG_OFFSET + {IP_TTL,UDP_PROTO}
								+ FPGA_IP[31:16] + FPGA_IP[15:0] + pc_ip[31:16] + pc_ip[15:0];
			end
			else if (trig_udp_cks && !ipcks_over) begin
				if (ipcks_sum > 32'h0000_FFFF) begin
					ipcks_sum	<=	ipcks_sum[31:16] + ipcks_sum[15:0];
					ipcks_over	<=	0;						
				end
				else begin 
					ipcks_sum[15:0]	<=	~ipcks_sum[15:0];
					ipcks_over	<=	1;
				end
			end
			else begin 
				ipcks_sum  <= ipcks_sum;
				ipcks_over <= ipcks_over;				
			end			
		end		
	end	

	always @(posedge sys_clk) begin
		if (sys_rst  || rgmii_tx_last) begin
			udpcks_sum	<=	0;
			udpcks_over	<=	0;
		end
		else begin 
			if (!trig_udp_cks_d && trig_udp_cks) begin
				udpcks_sum	<=	FPGA_IP[31:16] + FPGA_IP[15:0] + pc_ip[31:16] + pc_ip[15:0]	+ {8'h00,8'h11} + (UDP_WORD + udp_len)
								+ FPGA_SP + FPGA_DP + (UDP_WORD + udp_len) + udp_sum[31:16] + udp_sum[15:0];
			end
			else if (trig_udp_cks && !udpcks_over) begin					
				if (udpcks_sum > 32'h0000_ffff) begin
					udpcks_sum	<=	udpcks_sum[31:16] + udpcks_sum[15:0];
					udpcks_over	<=	0;						
				end
				else begin 
					udpcks_sum[15:0]	<=	~udpcks_sum[15:0];
					udpcks_over	<=	1;
				end			
			end
			else begin 
				udpcks_sum	<=	udpcks_sum;
				udpcks_over	<=	udpcks_over;				
			end			
		end		
	end		
//*****************************************************************************
// Write channel control signals
//*****************************************************************************	
	always @(posedge sys_clk) begin
		if(sys_rst) begin
			trig_udp_start <= 0;
		end else begin
			trig_udp_start <= axi_wvalid;
		end
	end

	always @(posedge sys_clk) begin
		if (trig_arp)
			trig_arp_start	<=	1;
		else if (write_next[WRITE_IDLE])
			trig_arp_start	<=	0;
		else
			trig_arp_start	<=	trig_arp_start;
	end	
//*****************************************************************************
// Write data state machine
//*****************************************************************************
	always @(posedge sys_clk) begin
		if(sys_rst) begin
			write_state <= 1;
		end else begin
			write_state	<= write_next;
		end
	end

	always @(*) begin
		write_next	=	0;		//	next state reset
		case (1)
			write_state[WRITE_IDLE]	:	begin 
				if (trig_udp_start)
					write_next[WRITE_ADDR]		=	1;
				else if (trig_arp_start)
					write_next[TX_WAIT]			=	1;
				else
					write_next[WRITE_IDLE]		=	1;
			end

			write_state[WRITE_ADDR]	:	begin 
				if (!flag_data_sum[2] && flag_addr_over)	
					write_next[WRITE_DATA]		=	1;
				else if (flag_addr_over)
					write_next[TX_WAIT]			=	1;
				else
					write_next[WRITE_ADDR]		=	1;
			end

			write_state[TX_WAIT]	:	begin 
				if (flag_wait_over)
					write_next[TX_ETH_HEADER]	=	1;			
				else
					write_next[TX_WAIT]			=	1;
			end

			write_state[TX_ETH_HEADER]	:	begin 
				if (flag_eth_header_over && trig_arp_start)
					write_next[TX_ARP]			=	1;							
				else if (flag_eth_header_over)
					write_next[TX_IP_HEADER]	=	1;			
				else
					write_next[TX_ETH_HEADER]	=	1;
			end

			write_state[TX_IP_HEADER]	:	begin 
				if (flag_ip_header_over)
					write_next[TX_UDP_HEADER]	=	1;
				else
					write_next[TX_IP_HEADER]	=	1;				
			end				

			write_state[TX_UDP_HEADER]	:	begin 
				if (flag_udp_header_over)
					write_next[WRITE_DATA]		=	1;
				else
					write_next[TX_UDP_HEADER]	=	1;					
			end

			write_state[WRITE_DATA] :	begin 
				if (flag_data_over)
					write_next[WRITE_RESPONSE]	=	1;
				else
					write_next[WRITE_DATA]		=	1;
			end

			write_state[WRITE_RESPONSE]	:	begin 
				if (axi_wb_bvalid && axi_wb_bready)
					write_next[WRITE_IDLE]		=	1;
				else
					write_next[WRITE_RESPONSE]	=	1;			
			end

			write_state[WRITE_TIME_OUT] :	begin 
					write_next[WRITE_IDLE]		=	1;
			end
			
			write_state[TX_ARP]	:	begin 
				if (flag_arp_over)
					write_next[WRITE_IDLE]		=	1;
				else
					write_next[TX_ARP]			=	1;	
			end											
			default : write_next[WRITE_IDLE]		=	1;
		endcase
	end	
//*****************************************************************************
// IP protocol signals
//*****************************************************************************		
	always @(posedge sys_clk) begin
		if(sys_rst || trig_package_rst) begin
			package_cnt <= 0;
		end else begin
			if (write_state[WRITE_RESPONSE] && write_next[WRITE_IDLE] && flag_data_sum[0])
				package_cnt <= package_cnt + 1;
			else
				package_cnt <= package_cnt;
		end
	end

	always @(posedge sys_clk) begin
		if(sys_rst) begin
			ip_identif <= 0;
		end else begin
			if (rgmii_tx_last)
				ip_identif <= ip_identif + 1;
			else
				ip_identif <= ip_identif;
		end
	end	
//*****************************************************************************
// RGMII TX signals
//*****************************************************************************	
	always @(posedge sys_clk) begin
		if(sys_rst) begin
			flag_data_sum        <= 0;
			trig_udp_cks_d       <= 0;
			data_sum			 <=	0;
		end else begin
			trig_udp_cks_d	<=	trig_udp_cks;
			case (1)
				write_next[WRITE_IDLE]	:	begin 
					flag_data_sum        <= flag_data_sum;
					flag_eth_header_over <= 0;
					flag_ip_header_over  <= 0;
					flag_udp_header_over <= 0;
					flag_arp_over        <= 0;
					flag_addr_over       <= 0;
					flag_wait_over       <= 0;
					flag_data_over       <= 0;
					trig_udp_cks		 <=	0;

					eth_temp             <= 0;
					ip_temp              <= 0; 
					udp_temp[31:00]		 <= 0;
					data_sum			 <=	data_sum;
					udp_sum              <= 0;
					udp_len              <= 0;
					udp_flag             <= 0;
					tx_word_cnt          <= 0;

					o_rgmii_data         <= 0;	
					o_rgmii_valid        <= 1'b0;
					o_rgmii_last         <= 1'b0;
				end

				write_next[WRITE_ADDR]	:	begin 
					if (axi_wvalid && axi_wready) begin
						flag_addr_over       <= 1;
					 	case (axi_waddr)
					 	 	C_ADDR_AD2ETH		:	flag_data_sum[0]	<=	1;
					 	 	C_ADDR_MOTOR2ETH	:	flag_data_sum[1]	<=	1;
					 	 	default : flag_data_sum[2]	<=	1;	//	receive data
					 	 endcase 			 	
					 end
					 else begin 
				 		flag_data_sum <= flag_data_sum;
				 		flag_addr_over<= 0;
					 end								
				end

				write_next[TX_WAIT]	:	begin 
					
					case (1)
						flag_data_sum[0] : begin
										 		udp_sum	<=	data_sum + FLAG_AD[31:16] + FLAG_AD[15:00] + package_cnt[31:16] + (package_cnt[15:00]);
										 		udp_len	<=	wr_wlen*AXI_ADDR_INC + FLAG_WORD + 4;
										 		udp_flag<=	FLAG_AD;	trig_udp_cks	<=	1;
										 	end
						flag_data_sum[1] : begin	
										 		udp_sum	<=	data_sum + FLAG_MOTOR[31:16] + FLAG_MOTOR[15:00];
										 		udp_len	<=	wr_wlen*AXI_ADDR_INC + FLAG_WORD; 
										 		udp_flag<=	FLAG_MOTOR;	trig_udp_cks	<=	1;
										 	end												 
						default : begin 
									udp_sum	<=	udp_sum;
									udp_len	<=	udp_len;
									udp_flag<=	udp_flag;
						end
					endcase

					if (ipcks_over && udpcks_over) begin 
						eth_temp       	<=	{pc_mac,FPGA_MAC,IP_TYPE};
						ip_temp			<=	{{IP_VISION,8'h00},(IP_WORD + UDP_WORD + udp_len),ip_identif,IP_FLAG_OFFSET,{IP_TTL,UDP_PROTO},ipcks_sum[15:0],FPGA_IP,pc_ip};
						udp_temp[31:0]  <=	{(UDP_WORD + udp_len),udpcks_sum[15:0]};
						flag_wait_over 	<=	1;
					end
					else if (trig_arp_start) begin 
						eth_temp       	<=	{pc_mac,FPGA_MAC,ARP_TYPE};
						arp_temp		<=	{ARP_HEAD,FPGA_MAC,FPGA_IP,pc_mac,pc_ip};
						flag_wait_over 	<=	1;
					end
					else begin 
						eth_temp	<=	eth_temp;
						udp_temp	<=	udp_temp;
						ip_temp		<=	ip_temp	;
						arp_temp	<=	arp_temp;	
					end
				end

				write_next[TX_ETH_HEADER]	:	begin
					trig_udp_cks	<=	0;
					if (tx_word_cnt == ETH_WORD) begin
						o_rgmii_valid        <= 1;
						if (trig_arp_start)
							o_rgmii_data	<=	arp_temp[223:216];
						else
							o_rgmii_data         <= ip_temp[159:152];
						flag_eth_header_over <= 1;
						tx_word_cnt         <= 1;
					end
					else begin
						if (!rgmii_tx_valid) begin 
							o_rgmii_valid   <=	1;
							o_rgmii_data	<=	eth_temp[((ETH_WORD - 1)-tx_word_cnt)*8 +: 8];
							tx_word_cnt	<=	1;
						end
						else if (rgmii_tx_valid && rgmii_tx_ready) begin
						 	o_rgmii_valid   <=	1;							
							o_rgmii_data	<=	eth_temp[((ETH_WORD - 1)-tx_word_cnt)*8 +: 8];
							tx_word_cnt	<=	tx_word_cnt + 1;							
						end
						else begin
							o_rgmii_valid	<=	1;
							o_rgmii_data	<=	o_rgmii_data; 
							tx_word_cnt	<=	tx_word_cnt;
						end							
					end
				end

				write_next[TX_IP_HEADER]	:	begin
					if (tx_word_cnt == IP_WORD) begin
						o_rgmii_valid       <= 1;
						o_rgmii_data        <= udp_temp[63:56];
						flag_ip_header_over <= 1;
						tx_word_cnt         <= 1;
					end
					else begin
						if (rgmii_tx_valid && rgmii_tx_ready) begin
						 	o_rgmii_valid   <=	1;							
							o_rgmii_data	<=	ip_temp[((IP_WORD - 1)-tx_word_cnt)*8 +: 8];
							tx_word_cnt	<=	tx_word_cnt + 1;							
						end
						else begin
							o_rgmii_valid	<=	1;
							o_rgmii_data	<=	o_rgmii_data; 
							tx_word_cnt	<=	tx_word_cnt;
						end							
					end
				end				

				write_next[TX_UDP_HEADER]	:	begin
					if (tx_word_cnt == UDP_WORD) begin
						o_rgmii_valid        <= 1;
						o_rgmii_data         <= udp_flag[31:24];
						flag_udp_header_over <= 1;
						tx_word_cnt         <= 1;
					end
					else begin
						if (rgmii_tx_valid && rgmii_tx_ready) begin
						 	o_rgmii_valid   <=	1;							
							o_rgmii_data	<=	udp_temp[((UDP_WORD - 1)-tx_word_cnt)*8 +: 8];
							tx_word_cnt	<=	tx_word_cnt + 1;							
						end
						else begin
							o_rgmii_valid	<=	1;
							o_rgmii_data	<=	o_rgmii_data; 
							tx_word_cnt	<=	tx_word_cnt;
						end							
					end
				end	

				write_next[WRITE_DATA]	:	begin
					//	receive	data sum 
					if (!flag_data_sum[2]) begin 		
						if (AXI_ADDR_INC >= 4 ) begin				// 	C_AXI_DATA_WIDTH >= 32
							if (axi_wd_wvalid && axi_wd_wready) begin 
								data_sum		<=	axi_wd_wdata[31:0];
								flag_data_over	<=	1;								
							end
							else begin 
								data_sum		<=	data_sum;
								flag_data_over	<=	0;									
							end
						end
						else begin 
							if (axi_wd_wvalid && axi_wd_wready)
								tx_word_cnt	<=	tx_word_cnt + 1;
							else
								tx_word_cnt	<=	tx_word_cnt;

							if (tx_word_cnt <= {SUM_SIZE{1'b1}})  
								data_sum[31-tx_word_cnt*C_AXI_DATA_WIDTH -: C_AXI_DATA_WIDTH]		<=	axi_wd_wdata;																
							else  								
								data_sum	<=	data_sum;

							flag_data_over	<=	(tx_word_cnt == {SUM_SIZE{1'b1}});					
						end
					end
					//	transfer data
					else begin
						if (tx_word_cnt == udp_len) begin
							flag_data_over	<=	1;
							o_rgmii_valid	<=	0;
							o_rgmii_last	<=	0;
							o_rgmii_data	<=	0; 
							tx_word_cnt		<=	0;	
							flag_data_sum   <=  0;						
						end
						else begin 
							if (rgmii_tx_valid && rgmii_tx_ready) begin
							 	o_rgmii_valid   <=	1;

							 	//	transfer data	:	AD
							 	if (flag_data_sum[0]) begin 	
									if (tx_word_cnt < 4)
										o_rgmii_data	<=	udp_flag[((4-tx_word_cnt)*8 - 1) -: 8];
									else if (tx_word_cnt < 8)
										o_rgmii_data	<=	package_cnt[((8-tx_word_cnt)*8 - 1)-: 8];
									// exchange high 8-bit and low 8-bit
									else begin 
										o_rgmii_data	<=	wd_wdata[((C_AXI_DATA_WIDTH/8 - tx_wd_cnt)*8 - 1) -: 8];	
									end
										
							 	end
							 	//	transger state	:	MOTOR	DDR
							 	else begin 
									if (tx_word_cnt < 4)
										o_rgmii_data	<=	udp_flag[((4-tx_word_cnt)*8 - 1) -: 8];
									else 
										o_rgmii_data	<=	wd_wdata[((C_AXI_DATA_WIDTH/8 - tx_wd_cnt)*8 - 1) -: 8];							 		
							 	end							

								tx_word_cnt		<=	tx_word_cnt + 1;	
								o_rgmii_last	<=	(tx_word_cnt == udp_len - 1);	
							end
							else begin
								o_rgmii_valid	<=	1;
								o_rgmii_last	<=	0;
								o_rgmii_data	<=	o_rgmii_data; 
								tx_word_cnt		<=	tx_word_cnt;
							end
						end
					end
				end

				write_next[TX_ARP]	:	begin 
					if (tx_word_cnt == ARP_WORD) begin
						o_rgmii_valid       <= 0;
						o_rgmii_data        <= o_rgmii_data;
						flag_arp_over 		<= 1;
						tx_word_cnt         <= 0;
					end
					else begin
						if (rgmii_tx_valid && rgmii_tx_ready) begin
						 	o_rgmii_valid   <=	1;							
							o_rgmii_data	<=	arp_temp[((ARP_WORD - 1)-tx_word_cnt)*8 +: 8];
							tx_word_cnt		<=	tx_word_cnt + 1;	
							o_rgmii_last	<=	(tx_word_cnt == ARP_WORD - 1);						
						end
						else begin
							o_rgmii_valid	<=	1;
							o_rgmii_last	<=	0;
							o_rgmii_data	<=	o_rgmii_data; 
							tx_word_cnt		<=	tx_word_cnt;
						end							
					end
				end

				write_next[WRITE_TIME_OUT]	:	begin 
					o_rgmii_last	<= 1;
				end
				default : /* default */;
			endcase
		end
	end	

	always @(*) begin 
		if (write_state[WRITE_DATA] && AXI_SIZE > 0) 
			if (flag_data_sum[0])
				tx_wd_cnt = tx_word_cnt[AXI_SIZE-1:0];
			else if (flag_data_sum[1])
				tx_wd_cnt = tx_word_cnt[AXI_SIZE-1:0] - 4;
			else
				tx_wd_cnt = 0;
		else
			tx_wd_cnt = 0;	
	end
//*****************************************************************************
// Watch dog signals
//*****************************************************************************	
	always @(posedge sys_clk) begin
		if(sys_rst) begin
			 wt_watch_dog_cnt	<=	0;
		end else begin
			 if (write_state != write_next)
			 	wt_watch_dog_cnt	<=	0;
			 else
			 	wt_watch_dog_cnt	<=	wt_watch_dog_cnt + 1; 
		end
	end

//*****************************************************************************
// Write channel address signals
//*****************************************************************************	
	//	wr_wready
	always @(posedge sys_clk) begin
		if (write_state[WRITE_IDLE] && write_next[WRITE_ADDR])
			wr_wready	<=	1;
		else
			wr_wready	<=	0;
	end

	//	wr_wid
	always @(posedge sys_clk) begin
		if(sys_rst) begin
			 wr_wid	<=	0;
		end else begin
			 if (axi_wvalid && axi_wready)
			 	wr_wid	<=	axi_wid;
			 else
			 	wr_wid	<=	wr_wid;
		end
	end

	//	wr_wlen	:	INCR bursts
	always @(posedge sys_clk) begin
		if(sys_rst) begin
			 wr_wlen	<=	0;
		end else begin
			 if (axi_wvalid && axi_wready)
			 	wr_wlen	<=	axi_wlen + 1;
			 else
			 	wr_wlen	<=	wr_wlen;
		end
	end	

	//	wr_wburst	
	//	C_EN_WRAP_TRANS :0 INCR bursts :support burst_len max to 256 (default) 	
	//	C_EN_WRAP_TRANS :1 WRAP bursts :support burst_len 2,4,8,16 				
	always @(posedge sys_clk) begin
		if(sys_rst) begin
			wr_wburst	<=	0;
		end else begin
			wr_wburst	<=	axi_wburst;	
		end
	end	

	//	output
	assign	axi_wready	=	wr_wready;
//*****************************************************************************
// Write channel data signals
//*****************************************************************************	
	//	data count
	always @(posedge sys_clk) begin
		if (write_next[WRITE_IDLE])
			write_data_cnt	<=	0;
		else if (write_state[WRITE_ADDR] && (write_next[WRITE_DATA] || write_next[TX_WAIT]))
			write_data_cnt	<=	axi_wlen;
		else if (axi_wd_wvalid && axi_wd_wready)
			write_data_cnt	<=	write_data_cnt - 1;
		else
			write_data_cnt	<=	write_data_cnt;
	end

	//	wd_wready
	always @(posedge sys_clk) begin
		if (write_state[WRITE_DATA] && (tx_wd_cnt == ({AXI_SIZE{1'b1}}-1)))
			wd_wready	<=	axi_wd_wvalid;		
		else if (write_state[WRITE_DATA] && !flag_data_sum[2] && (tx_word_cnt == 0))
			wd_wready	<=	axi_wd_wvalid;
		else
			wd_wready	<=	0;
	end	

	//	wd_wdata
	always @(posedge sys_clk) begin
		if(sys_rst) begin
			 wd_wdata     <= 0;			 
		end else begin
			if (axi_wd_wready && axi_wd_wvalid)
				wd_wdata	<=	axi_wd_wdata;
			else
				wd_wdata	<=	wd_wdata;
		end
	end
	//	output
	assign	axi_wd_wready	=	wd_wready;
//*****************************************************************************
// Write channel response signals
//*****************************************************************************	
	always @(posedge sys_clk) begin
		if (write_next[WRITE_RESPONSE])
			wb_bvalid <= 1;
		else
			wb_bvalid <= 0;
	end

	assign	axi_wb_bvalid	=	wb_bvalid;
	assign	axi_wb_bid		=	wb_bid;
	assign	axi_wb_bresp	=	wb_bresp;

endmodule
