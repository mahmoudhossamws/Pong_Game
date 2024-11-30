`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2024 01:24:26 PM
// Design Name: 
// Module Name: binarycounter
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


module binarycounter #(parameter x = 3, n = 6)
(input clk, reset, en, output [x-1:0] count);
    reg [x-1:0] count;
    always @(posedge clk, posedge reset) begin
        if (reset == 1)
            count <= 0; // non-blocking assignment
        // initialize flip flop here
        else if (en) begin
            if(count == n-1)
                count <= 0; // non-blocking assignment
            // reach count end and get back to zero
            else count <= count + 1; // non-blocking assignment
            // normal operation
        end
    end
endmodule
