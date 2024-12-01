/*
    Credit goes to all of us
*/

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
    reg [11:0] rgb_next;
    wire [3:0] score1, score2;
    reg [3:0] scoreIn;
    reg [1:0] mySel;
    wire myClk;
    wire isGameOver;
    wire [11:0] text_rgb, graph_rgb;
    wire [3:0] text_on;
    wire graph_on;
    reg start;
    
    vga_controller vga(.clk_100MHz(clk_100MHz), .reset(w_reset), .video_on(w_vid_on),
                       .hsync(hsync), .vsync(vsync), .p_tick(w_p_tick), .x(w_x), .y(w_y));
    pixel_gen pg(.clk(clk_100MHz), .reset(w_reset), .up(w_up), .down(w_down), .up1(w_up1), .down1(w_down1),
                 .video_on(w_vid_on), .x(w_x), .y(w_y), .graph_on(graph_on), .rgb(graph_rgb), .score1(score1),
                  .score2(score2), .isGameOver(isGameOver), .start(start));
    debounce dbR(.clk(clk_100MHz), .btn_in(reset), .btn_out(w_reset));
    debounce dbU(.clk(clk_100MHz), .btn_in(up), .btn_out(w_up));
    debounce dbD(.clk(clk_100MHz), .btn_in(down), .btn_out(w_down));
   
    debounce dbU1(.clk(clk_100MHz), .btn_in(up1), .btn_out(w_up1));
    debounce dbD1(.clk(clk_100MHz), .btn_in(down1), .btn_out(w_down1));
    bcd_experiment1 bcd(1, scoreIn, mySel, seg, av);
//    bcd_experiment1 bcd(1, mySel, 2'b00, seg, av);

    clock_divider #(250000) cd(.clk(clk_100MHz), .reset(reset), .clk_out(myClk));
    
    pong_text textUnit(clk_100MHz, score1, score2, w_x, w_y, text_on, text_rgb);
    
    always @(posedge clk_100MHz or posedge reset) begin
    if (reset) 
        start <= 0;  // Reset condition, set start to 0
    else 
        start <= (start != 1) ? (w_down || w_down1 || w_up || w_up1) : 1;
    end
    
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
        if(~w_vid_on)
            rgb_next = 12'h000; // blank
        else begin
            if(text_on[3] && !start) rgb_next = text_rgb;
            else if(isGameOver && text_on[0]) rgb_next = text_rgb;
            else if(graph_on) rgb_next = graph_rgb;
            else if(text_on[2] || text_on[1]) rgb_next = text_rgb;
            else rgb_next = 12'h0FF;
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
