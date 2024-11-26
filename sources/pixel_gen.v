`timescale 1ns / 1ps

module pixel_gen(
    input clk,  
    input reset,    
    input up,
    input down,
    input video_on,
    input [9:0] x,
    input [9:0] y,
    output reg [11:0] rgb,
    output reg [1:0] score1, score2
    );
    
    // maximum x, y values in display area
    parameter X_MAX = 639 + 100;
    parameter Y_MAX = 479;
    
    // create 60Hz refresh tick
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0; // start of vsync (vertical retrace)
    

    
    // paddle horizontal boundaries
    parameter X_PAD_L = 600;
    parameter X_PAD_R = 603;    // 4 pixels wide

    // paddle vertical boundaries
    wire [9:0] y_pad_t, y_pad_b;
    parameter PAD_HEIGHT = 72; 
    reg [9:0] y_pad_reg, y_pad_next;
    parameter PAD_VELOCITY = 3;
    

    // Register Control
    always @(posedge clk or posedge reset)
        if(reset) begin
            y_pad_reg <= 0;
        end
        else begin
            y_pad_reg <= y_pad_next;
        end

    wire pad_on;
    wire [11:0] pad_rgb, bg_rgb;
    
    assign pad_rgb = 12'hAAA;       // gray
    assign bg_rgb = 12'h0FF;        // yellow background
    
    // paddle 
    assign y_pad_t = y_pad_reg;                             // paddle top position
    assign y_pad_b = y_pad_t + PAD_HEIGHT - 1;              // paddle bottom position
    assign pad_on = (X_PAD_L <= x) && (x <= X_PAD_R) &&     // pixel within paddle boundaries
                    (y_pad_t <= y) && (y <= y_pad_b);
    
                    
    // Paddle Control
    always @* begin
        y_pad_next = y_pad_reg;
        if(refresh_tick) begin
            if(up & (y_pad_t > PAD_VELOCITY))
                y_pad_next = y_pad_reg - PAD_VELOCITY;  // move up
            else if(down & (y_pad_b < (Y_MAX - PAD_VELOCITY)))
                y_pad_next = y_pad_reg + PAD_VELOCITY;  // move down
        end
    end
    
    // rgb multiplexing
    always @*
        if(~video_on)
            rgb = 12'h000;      // no value, blank
        else
            if(pad_on)
                rgb = pad_rgb;      // paddle color
            else
                rgb = bg_rgb;       // background color
       
endmodule
