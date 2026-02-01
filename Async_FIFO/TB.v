`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.01.2026 12:11:26
// Design Name: 
// Module Name: TB
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


module TB();
reg valid_input;
reg r_clk;
reg w_clk;
reg rst;
reg [7:0] from_user;
wire almost_full;
wire [7:0]to_the_user;
wire rvalid;

top_black_box dut(
	valid_input,
	w_clk,
	r_clk,
	rst,
	from_user,
	to_the_user,
	rvalid,
	almost_full
	);
	
	initial begin
		$monitor($time, "w_clk: %d, r_clk: %d, rst: %d, from_user: %d, to_the_user: %d, rvalid: %d",w_clk,r_clk, rst, from_user, to_the_user, rvalid );
	end
	initial begin
		valid_input = 1'b0;
		from_user = 8'b00000001;
		r_clk = 1'b0;
		w_clk = 1'b0;
		rst = 1'b1;
		#13 rst = 1'b0;
		
	end

always #5 w_clk = ~w_clk;
always #12 r_clk = ~r_clk;
 
task write();
begin

repeat(50) begin
@(negedge w_clk) begin
	if((dut.wen == 1'b1) && (dut.full == 1'b0) &&(almost_full == 1'b0)) begin
	
		valid_input = 1'b1;
		from_user = $urandom();
		
	end
	else begin
		valid_input = 1'b0;
	end
end
end

end
endtask

	initial begin
		write();
		@(negedge w_clk) begin
			valid_input = 1'b0;
		end
		#500 $finish;
	end
endmodule
