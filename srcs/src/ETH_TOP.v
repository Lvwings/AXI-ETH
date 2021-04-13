`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/12 16:49:14
// Design Name: 
// Module Name: ETH_TOP
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


module ETH_TOP#(
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
	   	input                               m_axi_wready, // Indicates slave is ready to accept a 
	   	output [C_AXI_ID_WIDTH-1:0]         m_axi_wid,    // Write ID
	   	output [C_AXI_ADDR_WIDTH-1:0]       m_axi_waddr,  // Write address
	   	output [7:0]                        m_axi_wlen,   // Write Burst Length
	   	output [2:0]                        m_axi_wsize,  // Write Burst size
	   	output [1:0]                        m_axi_wburst, // Write Burst type
	   	output [1:0]                        m_axi_wlock,  // Write lock type
	   	output [3:0]                        m_axi_wcache, // Write Cache type
	   	output [2:0]                        m_axi_wprot,  // Write Protection type
	   	output                              m_axi_wvalid, // Write address valid
	   	output [3:0]						m_axi_wqos,
	  
	// AXI write data channel signals
	   	input                               m_axi_wd_wready,  // Write data ready
	   	output [C_AXI_DATA_WIDTH-1:0]       m_axi_wd_wdata,    // Write data
	   	output [C_AXI_DATA_WIDTH/8-1:0]     m_axi_wd_wstrb,    // Write strobes
	   	output                              m_axi_wd_wlast,    // Last write transaction   
	   	output                              m_axi_wd_wvalid,   // Write valid
	  
	// AXI write response channel signals
	   	input  [C_AXI_ID_WIDTH-1:0]         m_axi_wb_bid,     // Response ID
	   	input  [1:0]                        m_axi_wb_bresp,   // Write response
	   	input                               m_axi_wb_bvalid,  // Write reponse valid
	   	output                              m_axi_wb_bready,  // Response ready
	  
	// AXI read address channel signals
	   	input                               m_axi_rready,     // Read address ready
	   	output [C_AXI_ID_WIDTH-1:0]         m_axi_rid,        // Read ID
	   	output [C_AXI_ADDR_WIDTH-1:0]       m_axi_raddr,      // Read address
	   	output [7:0]                        m_axi_rlen,       // Read Burst Length
	   	output [2:0]                        m_axi_rsize,      // Read Burst size
	   	output [1:0]                        m_axi_rburst,     // Read Burst type
	   	output [1:0]                        m_axi_rlock,      // Read lock type
	   	output [3:0]                        m_axi_rcache,     // Read Cache type
	   	output [2:0]                        m_axi_rprot,      // Read Protection type
	   	output                              m_axi_rvalid,     // Read address valid
	    output [3:0]						m_axi_rqos,

	// AXI read data channel signals   
	   	input  [C_AXI_ID_WIDTH-1:0]         m_axi_rd_bid,     // Response ID
	   	input  [1:0]                        m_axi_rd_rresp,   // Read response
	   	input                               m_axi_rd_rvalid,  // Read reponse valid
	   	input  [C_AXI_DATA_WIDTH-1:0]       m_axi_rd_rdata,   // Read data
	   	input                               m_axi_rd_rlast,   // Read last
	   	output                              m_axi_rd_rready,  // Read Response ready

	// AXI write address channel signals
	   	output                            	s_axi_wready, // Indicates slave is ready to accept a 
	   	input [C_AXI_ID_WIDTH-1:0]        	s_axi_wid,    // Write ID
	   	input [C_AXI_ADDR_WIDTH-1:0]      	s_axi_waddr,  // Write address
	   	input [7:0]                       	s_axi_wlen,   // Write Burst Length
	   	input [2:0]                       	s_axi_wsize,  // Write Burst size
	   	input [1:0]                       	s_axi_wburst, // Write Burst type
	   	input [1:0]                       	s_axi_wlock,  // Write lock type
	   	input [3:0]                       	s_axi_wcache, // Write Cache type
	   	input [2:0]                       	s_axi_wprot,  // Write Protection type
	   	input                             	s_axi_wvalid, // Write address valid
	  	input [3:0]							s_axi_wqos,
	// AXI write data channel signals
	   	output                            	s_axi_wd_wready,  // Write data ready
	   	input [C_AXI_DATA_WIDTH-1:0]      	s_axi_wd_wdata,    // Write data
	   	input [C_AXI_DATA_WIDTH/8-1:0]    	s_axi_wd_wstrb,    // Write strobes
	   	input                             	s_axi_wd_wlast,    // Last write transaction   
	   	input                             	s_axi_wd_wvalid,   // Write valid
	  
	// AXI write response channel signals
	   	output  [C_AXI_ID_WIDTH-1:0]      	s_axi_wb_bid,     // Response ID
	   	output  [1:0]                     	s_axi_wb_bresp,   // Write response
	   	output                            	s_axi_wb_bvalid,  // Write reponse valid
	   	input                             	s_axi_wb_bready,  // Response ready
	  
	// AXI read address channel signals
	   	output                            	s_axi_rready,     // Read address ready
	   	input [C_AXI_ID_WIDTH-1:0]        	s_axi_rid,        // Read ID
	   	input [C_AXI_ADDR_WIDTH-1:0]      	s_axi_raddr,      // Read address
	   	input [7:0]                       	s_axi_rlen,       // Read Burst Length
	   	input [2:0]                       	s_axi_rsize,      // Read Burst size
	   	input [1:0]                       	s_axi_rburst,     // Read Burst type
	   	input [1:0]                       	s_axi_rlock,      // Read lock type
	   	input [3:0]                       	s_axi_rcache,     // Read Cache type
	   	input [2:0]                       	s_axi_rprot,      // Read Protection type
	   	input                             	s_axi_rvalid,     // Read address valid
	  	input [3:0]							s_axi_rqos,
	// AXI read data channel signals   
	   	output  [C_AXI_ID_WIDTH-1:0]       	s_axi_rd_bid,     // Response ID
	   	output  [1:0]                      	s_axi_rd_rresp,   // Read response
	   	output                             	s_axi_rd_rvalid,  // Read reponse valid
	   	output  [C_AXI_DATA_WIDTH-1:0]     	s_axi_rd_rdata,   // Read data
	   	output                             	s_axi_rd_rlast,   // Read last
	   	input                              	s_axi_rd_rready,   // Read Response ready

		// AXIS RX RGMII
	    input   [7:0]   					rgmii_rx_data,
	    input   							rgmii_rx_valid,
	    input   							rgmii_rx_last,
		input								rgmii_rx_user,
		output								rgmii_rx_ready,
		// AXIS TX RGMII
	    output   [7:0]   					rgmii_tx_data,
	    output   							rgmii_tx_valid,
	    output   							rgmii_tx_last,
		output								rgmii_tx_user,
		input								rgmii_tx_ready	
    );

	wire [47:0]	pc_mac;
	wire [31:0] pc_ip;
	wire		trig_package_rst;
	wire		trig_arp;


	assign	m_axi_wqos	=	0;
	assign	m_axi_rqos	=	0;

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
			.sys_clk          (sys_clk),
			.sys_rst          (sys_rst),
			.axi_wready       (m_axi_wready),
			.axi_wid          (m_axi_wid),
			.axi_waddr        (m_axi_waddr),
			.axi_wlen         (m_axi_wlen),
			.axi_wsize        (m_axi_wsize),
			.axi_wburst       (m_axi_wburst),
			.axi_wlock        (m_axi_wlock),
			.axi_wcache       (m_axi_wcache),
			.axi_wprot        (m_axi_wprot),
			.axi_wvalid       (m_axi_wvalid),
			.axi_wd_wready    (m_axi_wd_wready),
			.axi_wd_wdata     (m_axi_wd_wdata),
			.axi_wd_wstrb     (m_axi_wd_wstrb),
			.axi_wd_wlast     (m_axi_wd_wlast),
			.axi_wd_wvalid    (m_axi_wd_wvalid),
			.axi_wb_bid       (m_axi_wb_bid),
			.axi_wb_bresp     (m_axi_wb_bresp),
			.axi_wb_bvalid    (m_axi_wb_bvalid),
			.axi_wb_bready    (m_axi_wb_bready),
			.axi_rready       (m_axi_rready),
			.axi_rid          (m_axi_rid),
			.axi_raddr        (m_axi_raddr),
			.axi_rlen         (m_axi_rlen),
			.axi_rsize        (m_axi_rsize),
			.axi_rburst       (m_axi_rburst),
			.axi_rlock        (m_axi_rlock),
			.axi_rcache       (m_axi_rcache),
			.axi_rprot        (m_axi_rprot),
			.axi_rvalid       (m_axi_rvalid),
			.axi_rd_bid       (m_axi_rd_bid),
			.axi_rd_rresp     (m_axi_rd_rresp),
			.axi_rd_rvalid    (m_axi_rd_rvalid),
			.axi_rd_rdata     (m_axi_rd_rdata),
			.axi_rd_rlast     (m_axi_rd_rlast),
			.axi_rd_rready    (m_axi_rd_rready),
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

	TX_UDP #(
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
		) inst_TX_UDP (
			.sys_clk          (sys_clk),
			.sys_rst          (sys_rst),
			.axi_wready       (s_axi_wready),
			.axi_wid          (s_axi_wid),
			.axi_waddr        (s_axi_waddr),
			.axi_wlen         (s_axi_wlen),
			.axi_wsize        (s_axi_wsize),
			.axi_wburst       (s_axi_wburst),
			.axi_wlock        (s_axi_wlock),
			.axi_wcache       (s_axi_wcache),
			.axi_wprot        (s_axi_wprot),
			.axi_wvalid       (s_axi_wvalid),
			.axi_wd_wready    (s_axi_wd_wready),
			.axi_wd_wdata     (s_axi_wd_wdata),
			.axi_wd_wstrb     (s_axi_wd_wstrb),
			.axi_wd_wlast     (s_axi_wd_wlast),
			.axi_wd_wvalid    (s_axi_wd_wvalid),
			.axi_wb_bid       (s_axi_wb_bid),
			.axi_wb_bresp     (s_axi_wb_bresp),
			.axi_wb_bvalid    (s_axi_wb_bvalid),
			.axi_wb_bready    (s_axi_wb_bready),
			.axi_rready       (s_axi_rready),
			.axi_rid          (s_axi_rid),
			.axi_raddr        (s_axi_raddr),
			.axi_rlen         (s_axi_rlen),
			.axi_rsize        (s_axi_rsize),
			.axi_rburst       (s_axi_rburst),
			.axi_rlock        (s_axi_rlock),
			.axi_rcache       (s_axi_rcache),
			.axi_rprot        (s_axi_rprot),
			.axi_rvalid       (s_axi_rvalid),
			.axi_rd_bid       (s_axi_rd_bid),
			.axi_rd_rresp     (s_axi_rd_rresp),
			.axi_rd_rvalid    (s_axi_rd_rvalid),
			.axi_rd_rdata     (s_axi_rd_rdata),
			.axi_rd_rlast     (s_axi_rd_rlast),
			.axi_rd_rready    (s_axi_rd_rready),
			.rgmii_tx_data    (rgmii_tx_data),
			.rgmii_tx_valid   (rgmii_tx_valid),
			.rgmii_tx_last    (rgmii_tx_last),
			.rgmii_tx_user    (rgmii_tx_user),
			.rgmii_tx_ready   (rgmii_tx_ready),
			.pc_mac           (pc_mac),
			.pc_ip            (pc_ip),
			.trig_package_rst (trig_package_rst),
			.trig_arp         (trig_arp)
		);


endmodule
