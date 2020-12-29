`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/02 10:30:44
// Design Name: 
// Module Name: GET_CKS
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


module GET_CKS#(
	// FPGA firmware information
	parameter FPGA_MAC	=	48'h00D0_0800_0002,
	parameter FPGA_IP	=	32'hC0A8_006E,
    parameter FPGA_DP    =   16'd8008,                   //  UDP脛驴碌脛露脣驴脷潞脜8080
    parameter FPGA_SP    =   16'd8008                   //  UDP脭麓露脣驴脷潞脜8080		
	)(
    input   CLK_125M,
	input	SYS_RST,
    input   TRIG_UDP_CKS,
	input	TRIG_ICMP_CKS,
	input	[31:0]	PC_IP,
	input	[15:0]  IP_IDENTIF, 
    input   [31:0]  UDP_DATA_SUM,
    input   [15:0]  UDP_DATA_LEN,
	input	[31:0]	ICMP_DATA_SUM,
    output  reg [15:0]  IP_CKS,
	output	reg [15:0]	ICMP_CKS,
    output  reg [15:0]  UDP_CKS,
    output  TRIG_TX_CKS
    );

`include "ETH_TX.vh"

reg [159:0] ip_header_bf    =   0;
reg [159:0] udp_header_bf  =   0;
reg	[31:0]	icmp_header_bf	=	0;
    
reg [31:0]  ip_sum   =   0,
            udp_sum  =   0,
			icmp_sum = 	 0,
			ip_suma  =   0,
            udp_suma =   0,
			icmp_suma=	 0;
			
reg [7:0]   ip_cnt   =   0,
            udp_cnt  =   0,
			icmp_cnt =	 0;
			
reg [31:0]  udp_data_sum_bf   =   0,
			icmp_data_sum_bf  =	  0;
			
reg         udp_cks_en_d1  =   1'b0,
			udp_cks_en_d2  =   1'b0,
			udp_cks_en_d3  =   1'b0,
			icmp_cks_en_d1 =   1'b0,
			icmp_cks_en_d2 =   1'b0,
			icmp_cks_en_d3 =   1'b0,
			ip_cks_ok      =   1'b0,
			udp_cks_ok     =   1'b0,
			icmp_cks_ok    =   1'b0, 
			udp_cks_busy   =   1'b0,
			icmp_cks_busy  =   1'b0;
			
reg [15:0]  udp_data_len_bf     =   0;

assign TRIG_TX_CKS = (ip_cks_ok && udp_cks_ok) || (ip_cks_ok && icmp_cks_ok);
//----------------露脕脢媒戮脻潞脥-------------------------
always @( posedge CLK_125M) begin
	if ( SYS_RST ) begin
		udp_data_sum_bf  <=  0;
		udp_data_len_bf  <=  0;  
		icmp_data_sum_bf <=  0;
		udp_cks_busy     <=  0;
		icmp_cks_busy    <=  0;

		udp_cks_en_d1    <=  0;
		udp_cks_en_d2    <=  0;
		udp_cks_en_d3    <=  0;

		icmp_cks_en_d1   <=  0;
		icmp_cks_en_d2   <=  0;
		icmp_cks_en_d3   <=  0;              
	end	
	else begin
		udp_cks_en_d1	<=	TRIG_UDP_CKS;
		udp_cks_en_d2	<=	udp_cks_en_d1;
		udp_cks_en_d3	<=	udp_cks_en_d2;

		icmp_cks_en_d1	<=	TRIG_ICMP_CKS;
		icmp_cks_en_d2	<=	icmp_cks_en_d1; 
		icmp_cks_en_d3	<=	icmp_cks_en_d2;
		
		// UDP 脢媒戮脻潞脥 + 脢媒戮脻鲁陇露脠
		if (!udp_cks_en_d2 && udp_cks_en_d1) begin	// 脢媒戮脻驴脡脛脺脭脷TRIG_UDP_CKS脫脨脨搂潞贸虏脜赂眉脨脗拢卢脣霉脪脭脩脫脢卤脪禄赂枚脢卤脰脫露脕脢媒
			udp_data_sum_bf     <=  UDP_DATA_SUM;
			udp_data_len_bf 	<=  UDP_DATA_LEN;			
			udp_cks_busy		<=	1'b1;
		end
		else if (ip_cks_ok && udp_cks_ok ) begin
			udp_cks_busy		<=	0;
			udp_data_sum_bf     <=  0;
			udp_data_len_bf		<=	0;			
		end
		else begin
			udp_data_sum_bf     <=  udp_data_sum_bf;
			udp_data_len_bf		<=	udp_data_len_bf;
			udp_cks_busy		<=	udp_cks_busy;
		end	
		
		// ICMP 脢媒戮脻潞脥
		if (!icmp_cks_en_d2 && icmp_cks_en_d1) begin  //
			icmp_data_sum_bf	<=	ICMP_DATA_SUM;			
			icmp_cks_busy		<=	1'b1;
		end	
		else if (ip_cks_ok && icmp_cks_ok) begin 
			icmp_cks_busy		<=	0;		//TRIG_TX_CKS 赂麓脦禄
			icmp_data_sum_bf	<=	0;
		end
		else begin
			icmp_data_sum_bf	<=	icmp_data_sum_bf;
			icmp_cks_busy		<=	icmp_cks_busy;	
		end		
	end	
end
//-----------------IP_CKS脢盲鲁枚-------------------------
always @ (posedge CLK_125M) begin
	if ( SYS_RST ) begin
		ip_sum  		<=  0;
		ip_cnt  		<=  0;
		IP_CKS  		<=  0;
		ip_cks_ok   	<=  0;
		ip_suma     	<=  0;
		ip_header_bf	<=	0;
	end	
    else if (!udp_cks_en_d3 && udp_cks_en_d2) begin
		ip_sum  		<=  0;
		ip_cnt  		<=  0;
		IP_CKS  		<=  0;
		ip_cks_ok   	<=  0;
		ip_suma     	<=  0;
				      //掳忙卤戮+脢脳虏驴鲁陇露脠+路镁脦帽 / 					IP鲁陇露脠				/	卤锚脢露	/  卤锚脰戮+脝芦脪脝   /  TTL+脨颅脪茅  / CKS / 脭麓IP / 脛驴碌脛IP		
        ip_header_bf    <=  {IP_VS_LEN_TOS,(IP_WORD + UDP_WORD + udp_data_len_bf),IP_IDENTIF,IP_FLAG_OFFSET,{IP_TTL,UDP_PROTO},16'h0,FPGA_IP,PC_IP};    
    end
    else if (!icmp_cks_en_d3 && icmp_cks_en_d2) begin
		ip_sum  		<=  0;
		ip_cnt  		<=  0;
		IP_CKS  		<=  0;
		ip_cks_ok   	<=  0;
		ip_suma     	<=  0;
				      //掳忙卤戮+脢脳虏驴鲁陇露脠+路镁脦帽 / 					IP鲁陇露脠				/卤锚脢露/  卤锚脰戮+脝芦脪脝   /  TTL+脨颅脪茅  / CKS / 脭麓IP / 脛驴碌脛IP		
        ip_header_bf    <=  {IP_VS_LEN_TOS,(IP_WORD + ICMP_WORD + 16'h0),IP_IDENTIF,16'h0,(IP_TTL),ICMP_PROTO,16'h0,FPGA_IP,PC_IP};    
    end	
	else if (udp_cks_busy || icmp_cks_busy) begin 
	//	IP 脨拢脩茅潞脥 = IP脢脳虏驴	
			if (ip_cnt <= 9) begin      // ip_header_bf 鲁陇露脠10赂枚脣芦脳脰陆脷
				ip_sum  <=  ip_sum + ip_header_bf[15:0];
				ip_header_bf <= ip_header_bf >> 16;         
				ip_cnt  <=  ip_cnt + 1;
			end
			else  if (ip_cnt == 10) begin
				ip_suma <=  ip_sum[31:16] + ip_sum[15:0];
				ip_cnt  <=  ip_cnt + 1;
			end
			else begin
				if (!ip_cks_ok) begin
					 if (ip_suma > 32'h0000_ffff) begin
						ip_suma <= ip_suma[31:16] + ip_suma[15:0];
						ip_cks_ok <=  0;
					 end
					 else begin  
						IP_CKS <= ~ip_suma[15:0];
						ip_cks_ok <=  1;
					end
				end
				else
					IP_CKS  <=  IP_CKS;
			end
	end		
	else begin
		IP_CKS  <=  IP_CKS;
	end
end 			
//-----------------UDP_CKS脢盲鲁枚------------------------
always @ (posedge CLK_125M) begin
	if ( SYS_RST ) begin
		udp_sum 		<=  0;
		udp_cnt 		<=  0;
		UDP_CKS 		<=  0;
		udp_cks_ok  	<=  0;
		udp_suma    	<=  0;
		udp_header_bf	<=	0;
	end	
    else if (!udp_cks_en_d3 && udp_cks_en_d2) begin
		udp_sum 		<=  0;
		udp_cnt 		<=  0;
		UDP_CKS 		<=  0;
		udp_cks_ok  	<=  0;
		udp_suma    	<=  0;						
						//	脭麓IP / 脛驴碌脛IP /   UDP脨颅脪茅    /       	UDP鲁陇露脠 	   		   /脭麓露脣驴脷/脛驴碌脛露脣驴脷/       	UDP鲁陇露脠 	   		         / CKS/ 脢媒戮脻... 	
        udp_header_bf   <=  {FPGA_IP,PC_IP,{8'h00,8'h11},(udp_data_len_bf + UDP_WORD),FPGA_SP,FPGA_DP,(udp_data_len_bf + UDP_WORD),16'h0};   // UDP_LEN = UPD掳眉脥路拢篓8脳脰陆脷拢漏 + 脠芦虏驴脢媒戮脻鲁陇露脠拢篓4脳脰陆脷卤锚脢露 + 脢媒戮脻鲁陇露脠拢漏     
       
	end
    else if (udp_cks_busy) begin 
// UDP 脨拢脩茅潞脥 = 脦卤脢脳虏驴拢篓 脭麓IP + 脛驴碌脛IP + 脨颅脪茅 + UDP鲁陇露脠拢漏 + UDP脢脳虏驴 + UDP脢媒戮脻 // 碌卤脳卯潞贸脢媒戮脻虏禄脳茫16脦禄拢卢虏鹿0麓娄脌铆        
        if (udp_cnt <= 9) begin    // udp_header_bf 鲁陇露脠10赂枚脣芦脳脰陆脷
            udp_sum  <=  udp_sum + udp_header_bf[15:0];
            udp_header_bf <= udp_header_bf >> 16;
            udp_cnt  <=  udp_cnt + 1;
        end
        else if (udp_cnt == 10) begin  
            udp_sum    <=  udp_sum + udp_data_sum_bf;
            udp_cnt     <=  udp_cnt + 1;
        end        
        else if (udp_cnt == 11) begin
            udp_suma    <=  udp_sum[31:16] + udp_sum[15:0];
            udp_cnt     <=  udp_cnt + 1;
        end
        else begin
            if (!udp_cks_ok) begin
                 if (udp_suma > 32'h0000_ffff) begin
                    udp_suma <= udp_suma[31:16] + udp_suma[15:0];
                    udp_cks_ok <=  0; 
                 end
                 else begin  
                    UDP_CKS <= ~udp_suma[15:0];
                    udp_cks_ok <=  1; 
                end    
            end
            else
                UDP_CKS <=  UDP_CKS; 
        end      
    end
	else begin
		UDP_CKS <=  UDP_CKS; 
		udp_cks_ok	<=	0;
	end
end
//-----------------ICMP_CKS脢盲鲁枚------------------------
always @ (posedge CLK_125M) begin
	if ( SYS_RST ) begin
		icmp_sum  		<=  0;
		icmp_cnt  		<=  0;
		ICMP_CKS  		<=  0;
		icmp_cks_ok   	<=  0;
		icmp_suma     	<=  0;
		icmp_header_bf	<=	0;
	end	
    else if (!icmp_cks_en_d3 && icmp_cks_en_d2) begin
		icmp_sum  		<=  0;
		icmp_cnt  		<=  0;
		ICMP_CKS  		<=  0;
		icmp_cks_ok   	<=  0;
		icmp_suma     	<=  0;
								//    脌脿脨脥+麓煤脗毛     /  CKS  
        icmp_header_bf    <=  {{ICMP_TYPE,ICMP_CODE},16'h00};    
    end	
	else if (icmp_cks_busy) begin 
	//	ICMP 脨拢脩茅潞脥 = ICMP脢脳虏驴	
			if (icmp_cnt <= 1) begin      // icmp_header_bf 鲁陇露脠4赂枚脣芦脳脰陆脷
				icmp_sum  <=  icmp_sum + icmp_header_bf[15:0];
				icmp_header_bf <= icmp_header_bf >> 16;         
				icmp_cnt  <=  icmp_cnt + 1;
			end
			else  if (icmp_cnt == 2) begin
				icmp_sum <=  icmp_sum + icmp_data_sum_bf;
				icmp_cnt  <=  icmp_cnt + 1;
			end			
			else  if (icmp_cnt == 3) begin
				icmp_suma <=  icmp_sum[31:16] + icmp_sum[15:0];
				icmp_cnt  <=  icmp_cnt + 1;
			end
			else begin
				if (!icmp_cks_ok) begin
					 if (icmp_suma > 32'h0000_ffff) begin
						icmp_suma <= icmp_suma[31:16] + icmp_suma[15:0];
						icmp_cks_ok <=  0;
					 end
					 else begin  
						ICMP_CKS <= ~icmp_suma[15:0];
						icmp_cks_ok <=  1;
					end
				end
				else
					ICMP_CKS  <=  ICMP_CKS;
			end
	end		
	else begin
		ICMP_CKS  <=  ICMP_CKS;
		icmp_cks_ok <=  0;
	end
end           

endmodule
