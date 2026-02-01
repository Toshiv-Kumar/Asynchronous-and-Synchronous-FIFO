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
	input valid_input,
	input rst,
	input [7:0]from_user,
	
	input w_clk,
	input full,
	output reg wen,
	output reg [7:0]wdata,
	output reg wr_valid
	
	);
	
	
	
	always @(posedge w_clk) begin
		if (rst == 1'b1) begin
			wen <= #2 1'b0;
			wdata <= #2 8'b00000000;
			wr_valid <= #2 1'b0;
		end
		else if ( full == 1'b0 ) begin
			
			wen <= #2 1'b1;
			
			if (valid_input == 1'b1) begin
				wdata <= #2 from_user;
				wr_valid <= #2 1'b1;
				end
			else begin wdata <= #2 8'b00000000;  wr_valid <= #2 1'b0; end
			
		end
		else begin
			wr_valid <= #2 valid_input;
			wen <= #2 1'b0;
			wdata <= #2 8'b00000000;
		end
	
	end
// the data from_user takes 2 clocks to be written to fifo
endmodule
// rptr value and the final output of destination module will differ by 2 values.
module destination_output( // slower read rates - every 3 clocks, even though it uses same clock domain.
	input rst,
	input r_clk,
	input empty,
	input [7:0]rdata,
	output [7:0]to_the_user,
	output reg ren
	
	);
	assign to_the_user = rdata;
	// After improvement the previous pointer value is from where the current data shwon in the output was picked from
	
	// 3 clock cycles starting from where ren=1 do we read the actual correct data.
	// We need to fix this issue and make them run on the same clock difference or in same time so that one is not slower than the other.
	
	always @(posedge r_clk) begin
		if (rst == 1'b1) begin
			ren <= #2 1'b0;
		end
		else if (empty == 1'b0)begin
			ren <= #2 1'b1;
		end
		else begin
			ren <= #2 1'b0;
		end
	end
	

endmodule

module wptr_and_full_logic( //wptr_and_full_logic wptr1(rst, clk_single_domain, wen, rptr, full, wptr);
	input wr_valid,
	input rst,
	input w_clk,
	input wen,
	input [3:0]rptr_sync,
	output full,
	output reg [3:0]wptr,
	output almost_full
	);
	assign full = {~wptr[3], wptr[2:0]} == rptr_sync[3:0];
	assign almost_full = (wptr+1 == {~rptr_sync[3], rptr_sync[2:0]}); // to tell the source to stop the operations it is performing and wait.
	always @(posedge w_clk) begin
	if (rst == 1'b1) begin
		wptr <= #2 4'b0000;
	
	end
	else begin
		if((wen == 1'b1) && (full != 1'b1) && (wr_valid == 1'b1))begin // Big mistake here of not gating it beforehand. Even if wen is 1'b1, the full may be 1 i.e. wen wasn't updatated yet.
			wptr <= #2 (wptr + 1);
		
		end
	end
	end
endmodule

module rptr_and_empty_logic( //rptr_and_empty_logic rptr1(rst, clk_single_domain, ren, wptr, empty, rptr);
	input rst,
	input r_clk,
	input ren,
	input [3:0]wptr_sync,
	output empty,
	output reg [3:0]rptr
	
	);
	assign empty = (wptr_sync[3:0] == rptr[3:0]);
	
	always @(posedge r_clk) begin
		if (rst == 1'b1) begin
			rptr <= #2 4'b0000;
		end
		else if((ren == 1'b1) && (empty != 1'b1)) begin // Made mistake of not gating it here.
			rptr <= #2 (rptr+1);
		end
	
	end
	


endmodule


module Async_FIFO(
	input wr_valid,
	input w_clk,
	input r_clk,
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
    
    always @(posedge r_clk) begin // Read data as output logic block
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

    always @(posedge w_clk) begin // Block to write data into this fifo.
    	if(rst == 1'b1)begin
    		// We don't reset the Memory.
    	end
    	else begin
    		if (wr_en_gated == 1'b1 && wr_valid == 1'b1) begin
    			Mem[wptr[2:0]] <= #2 wdata;
    			
    			end
    		
    		end
    end
    

endmodule

module b2g(
	input [3:0]ptr,
	output [3:0]grey_encoded
	);
	assign grey_encoded = {ptr[3], ptr[3]^ptr[2], ptr[2]^ptr[1], ptr[1]^ptr[0]};
	
	
	endmodule

module g2b(
	input [3:0]ptr,
	output [3:0]sync_value
	);
	
	assign sync_value = {ptr[3], 
	                     ptr[3]^ptr[2], 
	                     (ptr[3]^ptr[2])^ptr[1], 
	                     ((ptr[3]^ptr[2])^ptr[1])^ptr[0]};
	endmodule

module D_FF( // This will automatically be 3 FF in parallel
	input rst,
	input [3:0]D,
	input clk,
	output reg [3:0]q
	);
	
	always @(posedge clk) begin
		if ( rst == 1'b1) begin
			q <= #2 4'b0000;
			
		end
		else begin
			q <= #2 D;
		end
	end
	
endmodule

module double_synchronizer(
		input rst,
		input clk,
		input [3:0]ptr, 
		output [3:0]sync // Mistake: forgot to make it 4 bits
	);
		wire [3:0]temp;
		D_FF f1(rst, ptr, clk, temp); // Single D ff takes 1 bit so we need 4 DFF in parallel
		D_FF f2(rst, temp, clk, sync);
	endmodule

module top_black_box(
	input valid_input,
	input w_clk,
	input r_clk,
	input rst,
	input [7:0]from_user,
	output [7:0]to_the_user,
	output rvalid,
	output almost_full
	);
	wire wr_valid;
	wire wen, full, empty, ren;
	wire [7:0]wdata;
	wire [7:0]rdata;
	wire [3:0] rptr;
	wire [3:0] rptr_grey;
	wire [3:0] rptr_befsync;
	
	wire [3:0] wptr;
	wire [3:0] rptr_sync;
	wire [3:0] wptr_sync;
	wire [3:0] wptr_grey;
	wire [3:0] wptr_befsync;
	
	source_input souse(valid_input, rst, from_user, w_clk, full, wen, wdata, wr_valid);
	destination_output dest(rst, r_clk, empty, rdata, to_the_user, ren);
	wptr_and_full_logic wptr1(wr_valid, rst, w_clk, wen, rptr_sync, full, wptr, almost_full);
	b2g wp(wptr, wptr_grey);
	double_synchronizer wps(rst, r_clk, wptr_grey, wptr_befsync);
	g2b wpes(wptr_befsync, wptr_sync);
	rptr_and_empty_logic rptr1(rst, r_clk, ren, wptr_sync, empty, rptr);
	b2g rp(rptr, rptr_grey);
	double_synchronizer rps(rst, w_clk, rptr_grey, rptr_befsync);
	g2b rpes(rptr_befsync, rptr_sync);
	Async_FIFO fifo(wr_valid, w_clk, r_clk, rst, wen, full, ren, empty, wdata, wptr, rptr, rdata, rvalid);

endmodule
