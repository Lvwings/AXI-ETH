`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/11 16:55:13
// Design Name: 
// Module Name: tf_tx_udp
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

module tb_TX_UDP (); /* this is automatically generated */

	// clock
	logic clk;
	initial begin
		clk = '0;
		forever #(5) clk = ~clk;
	end

	// synchronous reset
	logic srstb;
	initial begin
		srstb <= '1;
		repeat(10)@(posedge clk)
		srstb <= '0;
	end

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
	localparam       [2:0] SUM_SIZE = clogb2(32/C_AXI_DATA_WIDTH-1);
	localparam     [3:0] WRITE_IDLE = 4'd0;
	localparam     [3:0] WRITE_ADDR = 4'd1;
	localparam        [3:0] TX_WAIT = 4'd2;
	localparam  [3:0] TX_ETH_HEADER = 4'd3;
	localparam   [3:0] TX_IP_HEADER = 4'd4;
	localparam  [3:0] TX_UDP_HEADER = 4'd5;
	localparam     [3:0] WRITE_DATA = 4'd6;
	localparam [3:0] WRITE_RESPONSE = 4'd7;
	localparam [3:0] WRITE_TIME_OUT = 4'd8;
	localparam         [3:0] TX_ARP = 4'd9;
	localparam              IP_TYPE = 16'h0800;
	localparam             ARP_TYPE = 16'h0806;
	localparam             ETH_WORD = 8'd14;
	localparam            IP_VISION = 8'h45;
	localparam       IP_FLAG_OFFSET = 16'h4000;
	localparam            UDP_PROTO = 8'h11;
	localparam           ICMP_PROTO = 8'h01;
	localparam               IP_TTL = 8'h80;
	localparam              IP_WORD = 8'd20;
	localparam             UDP_WORD = 8'd8;
	localparam            FLAG_WORD = 8'd4;
	localparam             ARP_HEAD = 64'h0001_0800_0604_0002;
	localparam             ARP_WORD = 8'd28;
	localparam          ARP_REQUEST = 16'h0001;
	localparam             PING_REQ = 8'h08;
	localparam            ICMP_WORD = 8'd40;

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
	logic                    [7:0] rgmii_tx_data;
	logic                          rgmii_tx_valid;
	logic                          rgmii_tx_last;
	logic                          rgmii_tx_user;
	logic                          rgmii_tx_ready;
	logic                   [47:0] pc_mac;
	logic                   [31:0] pc_ip;
	logic                          trig_package_rst;
	logic                          trig_arp;

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


	task init();
		axi_wid        <= '0;
		axi_waddr      <= '0;
		axi_wlen       <= '0;
		axi_wsize      <= '0;
		axi_wburst     <= '0;
		axi_wlock      <= '0;
		axi_wcache     <= '0;
		axi_wprot      <= '0;
		axi_wvalid     <= '0;
		axi_wd_wdata   <= '0;
		axi_wd_wstrb   <= '0;
		axi_wd_wlast   <= '0;
		axi_wd_wvalid  <= '0;
		axi_wb_bready  <= '0;
		axi_rid        <= '0;
		axi_raddr      <= '0;
		axi_rlen       <= '0;
		axi_rsize      <= '0;
		axi_rburst     <= '0;
		axi_rlock      <= '0;
		axi_rcache     <= '0;
		axi_rprot      <= '0;
		axi_rvalid     <= '0;
		axi_rd_rready  <= '0;
		rgmii_tx_ready <= '0;
		pc_mac         <= '0;
		pc_ip          <= '0;
		trig_pack_rst  <= '0;
		trig_arp  		<= '0;
	endtask

	task drive(int iter);
		for(int it = 0; it < iter; it++) begin
			axi_wid        <= '0;
			axi_waddr      <= '0;
			axi_wlen       <= '0;
			axi_wsize      <= '0;
			axi_wburst     <= '0;
			axi_wlock      <= '0;
			axi_wcache     <= '0;
			axi_wprot      <= '0;
			axi_wvalid     <= '0;
			axi_wd_wdata   <= '0;
			axi_wd_wstrb   <= '0;
			axi_wd_wlast   <= '0;
			axi_wd_wvalid  <= '0;
			axi_wb_bready  <= '0;
			axi_rid        <= '0;
			axi_raddr      <= '0;
			axi_rlen       <= '0;
			axi_rsize      <= '0;
			axi_rburst     <= '0;
			axi_rlock      <= '0;
			axi_rcache     <= '0;
			axi_rprot      <= '0;
			axi_rvalid     <= '0;
			axi_rd_rready  <= '0;
			rgmii_tx_ready <= '0;
			pc_mac         <= '0;
			pc_ip          <= '0;
			trig_pack_rst  <= '0;
			@(posedge clk);
		end
	endtask

	initial begin
		// do something

		init();
	end

	assign	rgmii_tx_ready = rgmii_tx_valid;

	always_ff @(posedge clk) begin
		if(srstb) begin
			pc_mac         <= '0;
			pc_ip          <= '0;
		end else begin
			pc_mac         <= 48'h0024_7EDF_CA5E;
			pc_ip          <= {8'd192,8'd168,8'd0,8'd119};
		end
	end

	localparam	W_IDLE	=	4'd0,
				W_ADDR	=	4'd1,
				W_DATA 	=	4'd2,
				W_RESP 	=	4'd3,
				W_ARP	=	4'd4;

	reg [4:0]	write_state	=	0,
				write_next 	=	0;

	always @(posedge clk) begin
		if(srstb) begin
			write_state <= 1;
		end else begin
			write_state	<= write_next;
		end
	end

	always @(*) begin 
		write_next = 0;
		case (1)
			write_state[W_IDLE]	:	begin
				if (arp_over) 
					write_next[W_ADDR]	=	1;
				else
					write_next[W_ARP]	=	1;
			end

			write_state[W_ADDR]	:	begin 
				if (axi_wvalid && axi_wready)
					write_next[W_DATA]	=	1;
				else
					write_next[W_ADDR]	=	1;
			end

			write_state[W_DATA]	:	begin 
				if (axi_wd_wvalid && axi_wd_wready && axi_wd_wlast)
					write_next[W_RESP]	=	1;
				else
					write_next[W_DATA]	=	1;
			end

			write_state[W_RESP]	:	begin 
				if (axi_wb_bready && axi_wb_bvalid)
					write_next[W_IDLE]	=	1;
				else
					write_next[W_RESP]	=	1;
			end

			write_state[W_ARP]	:	begin 
				if(rgmii_tx_last)
					write_next[W_IDLE]	=	1;
				else
					write_next[W_ARP]	=	1;
			end
			default : /* default */;
		endcase
	end				

	reg arp_over	=	1'b0;
	always @(posedge clk) begin
		if(srstb) begin
			trig_arp <= 1;
			arp_over	<=	0;
		end else begin
			if (write_state[WRITE_IDLE] && write_next[W_ARP])
				trig_arp	<=	1;
			else
				trig_arp	<=	0;

			if (write_state[W_ARP] && write_next[W_IDLE])
				arp_over	<=	1;
			else
				arp_over	<=	0;
		end
	end

	reg	flag_sum	=	1'b0;
	always_ff @(posedge clk) begin
		if(srstb) begin
			axi_waddr  <= '0;
			axi_wlen   <= '0;
			axi_wvalid <= '0;
			flag_sum   <=  1;
		end else begin
			if (write_state[W_ADDR] && !axi_wready) begin
				axi_waddr	<=	flag_sum ? BASE_ADDR_AD : BASE_ADDR_AD + SUM_ADDR_OFFSET;
				axi_wlen	<=	flag_sum ? 16-1 : 32/C_AXI_DATA_WIDTH-1;
				axi_wvalid	<=	1;
			end
			else begin 
				axi_waddr      <= '0;
				axi_wlen       <= axi_wlen;
				axi_wvalid     <= '0;
			end

			if (write_state[W_IDLE] && write_next[W_ADDR])
				flag_sum	<=	~flag_sum;
			else
				flag_sum	<=	flag_sum;
		end
	end

	localparam	DATASUM	=	32'h1234_5678;
	reg	[7:0]	data_cnt	=	0;
	always_ff @(posedge clk) begin
		if(srstb) begin
			axi_wd_wdata   <= '0;
			axi_wd_wstrb   <= '0;
			axi_wd_wlast   <= '0;
			axi_wd_wvalid  <= '0;
			data_cnt	<=	0;
		end else begin
			if (write_state[W_DATA]) begin 
				if (!flag_sum) begin 
					if (!axi_wd_wready) begin 
						axi_wd_wdata	<=	DATASUM[31 -: C_AXI_DATA_WIDTH];
						data_cnt	<=	1;
					end						
					else if (axi_wd_wvalid && axi_wd_wready) begin
						if (C_AXI_DATA_WIDTH < 32)
							axi_wd_wdata	<=	DATASUM[31 - data_cnt*C_AXI_DATA_WIDTH -: C_AXI_DATA_WIDTH];
						else
							axi_wd_wdata	<=	DATASUM;
						data_cnt	<=	data_cnt + 1;
					end						
					else
						data_cnt	<=	data_cnt;
					
					if (C_AXI_DATA_WIDTH < 32) begin 
						axi_wd_wvalid	<=	data_cnt <= axi_wlen;
						axi_wd_wlast	<=	(data_cnt == axi_wlen) && axi_wd_wvalid && axi_wd_wready;						
					end
					else begin 
						axi_wd_wvalid	<=	(data_cnt == 1) && !axi_wd_wready;
						axi_wd_wlast	<=	(data_cnt == 1) && !axi_wd_wready;						
					end					
				end
				else begin 
					if (axi_wd_wvalid && axi_wd_wready)
						data_cnt	<=	data_cnt + 1;
					else
						data_cnt	<=	data_cnt;

					axi_wd_wdata	<=	data_cnt;
					axi_wd_wvalid	<=	1;
					axi_wd_wlast	<=	(data_cnt == axi_wlen);										
				end
			end
			else begin 
				axi_wd_wdata   <= '0;
				axi_wd_wstrb   <= '0;
				axi_wd_wlast   <= '0;
				axi_wd_wvalid  <= '0;
				data_cnt	<=	0;
			end
		end
	end

	always_ff @(posedge clk) begin
			if(srstb) begin
				 axi_wb_bready  <= '0;
			end else begin
				 if (write_state[W_RESP])
				 	axi_wb_bready	<=	axi_wb_bvalid;
				 else
				 	axi_wb_bready	<=	0;
			end
		end	
endmodule

