/*
    Credit goes to all of us
*/

`timescale 1ns / 1ps

module pong_text(
    input clk,
    input [3:0] score1, score2,
    input [9:0] x, y,
    output [3:0] text_on,
    output reg [11:0] text_rgb
    );
    
    // signal declaration
    wire [10:0] rom_addr;
    reg [6:0] char_addr, char_addr_o, char_addr_l;
    wire [6:0] char_addr_s, char_addr_s1;
    reg [3:0] row_addr;
    wire [3:0] row_addr_s, row_addr_s1, row_addr_o, row_addr_l;
    reg [2:0] bit_addr;
    wire [2:0] bit_addr_s, bit_addr_s1, bit_addr_o, bit_addr_l;
    wire [7:0] ascii_word;
    wire ascii_bit, score_on, score_on1, over_on, logo_on;
    wire [7:0] rule_rom_addr;
    
   // instantiate ascii rom
   ascii_rom ascii_unit(.clk(clk), .addr(rom_addr), .data(ascii_word));
   
    // game over region
    // - display "GAME OVER" at center
    // - scale to 32 by 64 text size
    // --------------------------------------------------------------------------
    assign score_on = (x <= 285 && x > 255) && (y >= 5 && y < 69);
    assign row_addr_s = y[5:2];
    assign bit_addr_s = x[4:2];
    assign char_addr_s = {3'b011, score1};
    
    assign score_on1 = (x >= 352 && x < 382) && (y >= 5 && y < 69);
    assign row_addr_s1 = y[5:2];
    assign bit_addr_s1 = x[4:2];
    assign char_addr_s1 = {3'b011, score2};
    
    assign over_on = (y[9:6] == 3) && (5 <= x[9:5]) && (x[9:5] <= 13);
    assign row_addr_o = y[5:2];
    assign bit_addr_o = x[4:2];
    always @*
        case(x[8:5])
            4'h5 : char_addr_o = 7'h47;     // G
            4'h6 : char_addr_o = 7'h41;     // A
            4'h7 : char_addr_o = 7'h4D;     // M
            4'h8 : char_addr_o = 7'h45;     // E
            4'h9 : char_addr_o = 7'h00;     //
            4'hA : char_addr_o = 7'h4F;     // O
            4'hB : char_addr_o = 7'h56;     // V
            4'hC : char_addr_o = 7'h45;     // E
            default : char_addr_o = 7'h52;  // R
        endcase

    assign logo_on = (y[9:7] == 2) && (3 <= x[9:6]) && (x[9:6] <= 6);
    assign row_addr_l = y[6:3];
    assign bit_addr_l = x[5:3];
    always @*
        case(x[8:6])
            3'o3 :    char_addr_l = 7'h50; // P
            3'o4 :    char_addr_l = 7'h4F; // O
            3'o5 :    char_addr_l = 7'h4E; // N
            default : char_addr_l = 7'h47; // G
        endcase

//    assign over_on = (y[9:6] == 3) && (5 <= x[9:5]) && (x[9:5] <= 13);
//    assign row_addr_o = y[5:2];
//    assign bit_addr_o = x[4:2];
//    always @*
//        case(x[8:5])
//            4'h5 : char_addr_o = 7'h47;     // G
//            4'h6 : char_addr_o = 7'h41;     // A
//            4'h7 : char_addr_o = 7'h4D;     // M
//            4'h8 : char_addr_o = 7'h45;     // E
//            4'h9 : char_addr_o = 7'h00;     //
//            4'hA : char_addr_o = 7'h4F;     // O
//            4'hB : char_addr_o = 7'h56;     // V
//            4'hC : char_addr_o = 7'h45;     // E
//            default : char_addr_o = 7'h52;  // R
//        endcase
    
    // mux for ascii ROM addresses and rgb
    always @* begin
        text_rgb = 12'h0FF;     // aqua background
        
        if(score_on) begin
            char_addr = char_addr_s;
            row_addr = row_addr_s;
            bit_addr = bit_addr_s;
            if(ascii_bit)
                text_rgb = 12'h00F; // red
        end
        else if(score_on1) begin
            char_addr = char_addr_s1;
            row_addr = row_addr_s1;
            bit_addr = bit_addr_s1;
            if(ascii_bit)
                text_rgb = 12'h00F; // red
        end
        
        else if(over_on) begin
            char_addr = char_addr_o;
            row_addr = row_addr_o;
            bit_addr = bit_addr_o;
            if(ascii_bit)
                text_rgb = 12'h00F; // red
        end
        
        else if(logo_on) begin
            char_addr = char_addr_l;
            row_addr = row_addr_l;
            bit_addr = bit_addr_l;
            if(ascii_bit)
                text_rgb = 12'h000; // black
        end
               
    end
    
    assign text_on = {logo_on, score_on, score_on1, over_on};
    
    // ascii ROM interface
    assign rom_addr = {char_addr, row_addr};
    assign ascii_bit = ascii_word[~bit_addr];
      
endmodule
