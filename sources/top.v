`timescale 1ns / 1ps

module top(
    input clk_100MHz,       // from Basys 3
    input reset,            // btnR
    input up,               // btnU
    input down,
    input up1,
    input down1,             // btnD
    output hsync,           // to VGA port
    output vsync,           // to VGA port
    output [11:0] rgb,       // to DAC, to VGA port
    output [6:0] seg,
    output [3:0] av   
    );
    
    wire w_reset, w_up, w_down, w_up1, w_down1, w_vid_on, w_p_tick;
    wire [9:0] w_x, w_y;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    wire [2:0] score1, score2;
    reg [2:0] scoreIn;
    reg [1:0] mySel;
    wire myClk;
    
    vga_controller vga(.clk_100MHz(clk_100MHz), .reset(w_reset), .video_on(w_vid_on),
                       .hsync(hsync), .vsync(vsync), .p_tick(w_p_tick), .x(w_x), .y(w_y));
    pixel_gen pg(.clk(clk_100MHz), .reset(w_reset), .up(w_up), .down(w_down), .up1(w_up1), .down1(w_down1),
                 .video_on(w_vid_on), .x(w_x), .y(w_y), .rgb(rgb_next), .score1(score1), .score2(score2));
    debounce dbR(.clk(clk_100MHz), .btn_in(reset), .btn_out(w_reset));
    debounce dbU(.clk(clk_100MHz), .btn_in(up), .btn_out(w_up));
    debounce dbD(.clk(clk_100MHz), .btn_in(down), .btn_out(w_down));
   
    debounce dbU1(.clk(clk_100MHz), .btn_in(up1), .btn_out(w_up1));
    debounce dbD1(.clk(clk_100MHz), .btn_in(down1), .btn_out(w_down1));
    bcd_experiment1 bcd(1, scoreIn, mySel, seg, av);
//    bcd_experiment1 bcd(1, mySel, 2'b00, seg, av);

    clock_divider #(250000) cd(.clk(clk_100MHz), .reset(reset), .clk_out(myClk));
    
    
    always @ (posedge myClk) begin
        if(reset) mySel <= 2'b00;
        else mySel <= (mySel + 1);
    end

    // rgb buffer
    always @(posedge clk_100MHz) begin
        
        if(w_p_tick) begin
            rgb_reg <= rgb_next;      
        end     
    end     
             
            
    always @ (*) begin
        case(mySel)
                2'b11: scoreIn = score1;
                2'b00: scoreIn = score2;
                default: scoreIn = 0;
        endcase    
    end
         
        
    assign rgb = rgb_reg;
    
endmodule