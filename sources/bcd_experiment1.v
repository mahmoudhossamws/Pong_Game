/*
    Credit goes to all of us
*/

`timescale 1ns / 1ps

module bcd_experiment1(
        input en, input [2:0] num, input [1:0] sel, output reg [6:0] seg, output reg [3:0] av
    );
    
    always @ * begin
        if(en) begin
            case(sel)
               0: av = 4'b1110;
               1: av = 4'b1111;
               2: av = 4'b1111;
               3: av = 4'b0111;
            endcase
            case(num)
                0: seg = 7'b0000001;
                1: seg = 7'b1001111;
                2: seg = 7'b0010010;
                3: seg = 7'b0000110;
//                4: seg = 7'b1001100;
//                5: seg = 7'b0100100;
//                6: seg = 7'b0100000;
//                7: seg = 7'b0001111;
//                8: seg = 7'b0000000;
//                9: seg = 7'b0000100;
//                10: seg = 7'b0001000;
//                11: seg = 7'b1100000;
//                12: seg = 7'b0110001;
//                13: seg = 7'b1000010;
//                14: seg = 7'b0110000;
//                15: seg = 7'b0111000;
            endcase
        end 
        else
            av = 4'b1111;
    end

    
endmodule
