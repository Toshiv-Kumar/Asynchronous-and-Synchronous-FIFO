`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.01.2026 16:50:56
// Design Name: 
// Module Name: FIFO_Synchronous
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

module source_input(
	input rst,
	input [7:0]from_user,
	input clk_single_domain,
	input full,
	output reg wen,
	output reg [7:0]wdata
	);
	
	
	
	always @(posedge clk_single_domain) begin
		if (rst == 1'b1) begin
			wen <= #2 1'b0;
			wdata <= #2 8'b00000000;
		end
		else if ( full == 1'b0) begin
			
			wen <= #2 1'b1;
			wdata <= #2 from_user;
		
		end
		else if (full == 1'b1) begin
			wen <= #2 1'b0;
			wdata <= #2 8'b00000000;
		end
	
	end
// the data from_user takes 2 clocks to be written to fifo
endmodule
// rptr value and the final output of destination module will differ by 2 values.
module destination_output( // slower read rates - every 3 clocks, even though it uses same clock domain.
	input rst,
	input clk_single_domain,
	input empty,
	input [7:0]rdata,
	output [7:0]to_the_user,
	output reg ren
	
	);
	parameter idle = 0, s1 = 1, data_read = 2;
	reg [1:0]ps;
	reg [1:0]ns;
	
	assign to_the_user = rdata;
	// After improvement the previous pointer value is from where the current data shwon in the output was picked from
	
	// 3 clock cycles starting from where ren=1 do we read the actual correct data.
	// We need to fix this issue and make them run on the same clock difference or in same time so that one is not slower than the other.
	
	always @(posedge clk_single_domain) begin
		if(rst == 1'b1) begin
			ps <= #2 idle;
		end
		else begin
			ps <= #2 ns;
		end
	end
	
	always @(*) begin
		case(ps)
			idle: begin ns = s1; ren = 1'b0; end
			
			s1: begin ns = data_read; ren = 1'b0; end
		
			data_read: begin ns = idle; if (empty == 1'b0) begin ren = 1'b1; end end
			
			default: begin ns = idle; ren = 1'b0; end
		endcase
	end
	

endmodule

module wptr_and_full_logic( //wptr_and_full_logic wptr1(rst, clk_single_domain, wen, rptr, full, wptr);
	input rst,
	input clk_single_domain,
	input wen,
	input [3:0]rptr,
	output full,
	output reg [3:0]wptr
	);
	assign full = ( ({~wptr[3], wptr[2:0]} +1 )== {rptr[3:0]});
	always @(posedge clk_single_domain) begin
	if (rst == 1'b1) begin
		wptr <= #2 4'b0000;
	
	end
	else begin
		if((wen == 1'b1) && (full != 1'b1))begin // Big mistake here of not gating it beforehand. Even if wen is 1'b1, the full may be 1 i.e. wen wasn't updatated yet.
			wptr <= #2 (wptr + 1);
		
		end
	end
	end
endmodule

module rptr_and_empty_logic( //rptr_and_empty_logic rptr1(rst, clk_single_domain, ren, wptr, empty, rptr);
	input rst,
	input clk_single_domain,
	input ren,
	input [3:0]wptr,
	output empty,
	output reg [3:0]rptr
	
	);
	assign empty = (wptr[3:0] == rptr[3:0]);
	
	always @(posedge clk_single_domain) begin
		if (rst == 1'b1) begin
			rptr <= #2 4'b0000;
		end
		else if((ren == 1'b1) && (empty != 1'b1)) begin // Made mistake of not gating it here.
			rptr <= #2 (rptr+1);
		end
	
	end
	


endmodule


module FIFO_Synchronous(
	input clk_single_domain,
	input rst,
	input wen,
	input full,
	input ren,
	input empty,
	input [7:0]wdata,
	input [3:0]wptr, // This is simply address variable
	
	input [3:0]rptr,
	output reg [7:0]rdata,
	output reg rvalid
    );
    wire wr_en_gated, re_en_gated;
    assign wr_en_gated = (wen) & (~full); // This means(bitwise &) that we directly connected an AND gate compared to logiccal expression of &&
    assign re_en_gated = (ren) & (~empty);
    
    // Memory declaration:
    reg [7:0]Mem[0:7]; // 8*8 size
    
    // To keep track of correct vs incorrect data
    
    always @(posedge clk_single_domain) begin // Read data as output logic block
    	if(rst == 1'b1) begin
    		rdata <= #2 8'b00000000;
    		rvalid <= #2 1'b0;
    	end
    	
    	else begin
    		if(re_en_gated == 1'b1) begin
    			rvalid <= #2 1'b1;
    			rdata <= #2 Mem[rptr[2:0]];
    		end
    		else begin
    			rvalid <= #2 1'b0;
    			rdata <= #2 8'b00000000;
    		end
    		
    	end
    
    end
    
    always @(posedge clk_single_domain) begin // Block to write data into this fifo.
    	if(rst == 1'b1)begin
    		// We don't reset the Memory.
    	end
    	else begin
    		if (wr_en_gated == 1'b1) begin
    			Mem[wptr[2:0]] <= #2 wdata;
    			
    			end
    		
    		end
    end
    

endmodule

module top_black_box(
	input clk_single_domain,
	input rst,
	input [7:0]from_user,
	output [7:0]to_the_user,
	output rvalid
	);
	wire wen, full, empty, ren;
	wire [7:0]wdata;
	wire [7:0]rdata;
	wire [3:0] rptr;
	wire [3:0] wptr;
	source_input souse(rst, from_user, clk_single_domain, full, wen, wdata);
	destination_output dest(rst, clk_single_domain, empty, rdata, to_the_user, ren);
	wptr_and_full_logic wptr1(rst, clk_single_domain, wen, rptr, full, wptr);
	rptr_and_empty_logic rptr1(rst, clk_single_domain, ren, wptr, empty, rptr);
	FIFO_Synchronous fifo(clk_single_domain, rst, wen, full, ren, empty, wdata, wptr, rptr, rdata, rvalid);

endmodule
