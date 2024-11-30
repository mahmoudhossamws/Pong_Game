`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2024 01:22:07 PM
// Design Name: 
// Module Name: clock_divider
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

module clock_divider #(parameter n = 50000000)
(input clk, reset, output reg clk_out);
    
     wire [31:0] count;    
     binarycounter #(32,n) counterMod (.clk(clk), .reset(reset), .en(1), .count(count));
    
    always @ (posedge clk, posedge reset) begin
        if (reset)
            clk_out <= 0;
        else if (count == n-1)
            clk_out <= (~clk_out);
    end
endmodule

