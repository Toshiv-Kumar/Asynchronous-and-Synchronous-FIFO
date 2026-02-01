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
reg clk_single_domain;
reg rst;
reg [7:0] from_user;
wire [7:0]to_the_user;
wire rvalid;

top_black_box dut(
	clk_single_domain,
	rst,
	from_user,
	to_the_user,
	rvalid
	);
	
	initial begin
		$monitor($time, "clk: %d, rst: %d, from_user: %d, to_the_user: %d, rvalid: %d",clk_single_domain, rst, from_user, to_the_user, rvalid );
	end
	initial begin
		clk_single_domain = 1'b0;
		rst = 1'b1;
		#6 rst = 1'b0;
		
	end

always #5 clk_single_domain = ~clk_single_domain;

task write();
begin

repeat(50) begin
@(negedge clk_single_domain) begin
	if((dut.wen == 1'b1) && (dut.full == 1'b0)) begin
		from_user = $urandom();
	end
end
end

end
endtask

	initial begin
		write();
			
		#40 $finish;
	end
endmodule
