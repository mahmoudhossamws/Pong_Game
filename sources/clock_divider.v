/*
    Credit goes to all of us
*/

`timescale 1ns / 1ps

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

