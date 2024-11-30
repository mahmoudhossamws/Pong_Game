`timescale 1ns / 1ps

module pixel_gen(
    input clk,  
    input reset,    
    input up,
    input down,
    input up1,
    input down1,
    input video_on,
    input [9:0] x,
    input [9:0] y,
    output reg [11:0] rgb,
    output reg [1:0] score1, score2
    );


    wire w1, w2;
    wire en1, en2;
    rising_edge s1(clk, reset, w1, en1);
    rising_edge s2(clk, reset, w2, en2);

//    x_ball_l > 740 || x_ball_r < 90
     assign w1 = (x_ball_l > 639 && x_ball_r > 630) ? 1 : 0;
     assign w2 = (x_ball_r < 30) ? 1 : 0;
    

        
    // maximum x, y values in display area
    parameter X_MAX = 639;
    parameter Y_MAX = 479;
    
    // create 60Hz refresh tick
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0; // start of vsync(vertical retrace)
    
    // WALL
    // wall boundaries
//    parameter X_WALL_L = 32 + 100;    
//    parameter X_WALL_R = 39 + 100;    // 8 pixels wide
    
    
    // PADDLE
    parameter x_ball_initial = 376;
    parameter y_ball_initial = 239;
    
    // paddle horizontal boundaries
    parameter X_PAD_L = 600;
    parameter X_PAD_R = 603;    // 4 pixels wide
   
   // paddle 2
    parameter X_PAD_L1 = 37;
    parameter X_PAD_R1 = 40;    // 4 pixels wide
    
    // paddle vertical boundary signals
    wire [9:0] y_pad_t, y_pad_b, y_pad_t1, y_pad_b1;
    parameter PAD_HEIGHT = 72;  // 72 pixels high
    // register to track top boundary and buffer
    reg [9:0] y_pad_reg, y_pad_next, y_pad_reg1, y_pad_next1;
    // paddle moving velocity when a button is pressed
    parameter PAD_VELOCITY = 3;     // change to speed up or slow down paddle movement
    
    // BALL
    // square rom boundaries
    parameter BALL_SIZE = 8;
    // ball horizontal boundary signals
    wire [9:0] x_ball_l, x_ball_r;
    // ball vertical boundary signals
    wire [9:0] y_ball_t, y_ball_b;
    // register to track top left position
    reg [9:0] y_ball_reg, x_ball_reg;
    // signals for register buffer
    wire [9:0] y_ball_next, x_ball_next;
    // registers to track ball speed and buffers
    reg [9:0] x_delta_reg, x_delta_next;
    reg [9:0] y_delta_reg, y_delta_next;
    // positive or negative ball velocity
    parameter BALL_VELOCITY_POS = 1;
    parameter BALL_VELOCITY_NEG = -1;
    // round ball from square image
    wire [2:0] rom_addr, rom_col;   // 3-bit rom address and rom column
    reg [7:0] rom_data;             // data at current rom address
    wire rom_bit;                   // signify when rom data is 1 or 0 for ball rgb control
    
    // Register Control
    always @(posedge clk or posedge reset)
        if(reset) begin
            score1 <= 0;
            score2 <= 0;
            y_pad_reg <= 0;
            y_pad_reg1 <= 0;
            x_ball_reg <= x_ball_initial;
            y_ball_reg <= y_ball_initial;
            x_delta_reg <= 10'h002;
            y_delta_reg <= 10'h002;
        end
        else begin
            y_pad_reg <= y_pad_next;
            y_pad_reg1 <= y_pad_next1;
            x_ball_reg <= x_ball_next;
            y_ball_reg <= y_ball_next;
            x_delta_reg <= x_delta_next;
            y_delta_reg <= y_delta_next;
            if(en1) score1 <= score1 + 1;
            if(en2) score2 <= score2 + 1;
        end
    
    // ball rom
    always @*
        case(rom_addr)
            3'b000 :    rom_data = 8'b00111100; //   ****  
            3'b001 :    rom_data = 8'b01111110; //  ******
            3'b010 :    rom_data = 8'b11111111; // ********
            3'b011 :    rom_data = 8'b11111111; // ********
            3'b100 :    rom_data = 8'b11111111; // ********
            3'b101 :    rom_data = 8'b11111111; // ********
            3'b110 :    rom_data = 8'b01111110; //  ******
            3'b111 :    rom_data = 8'b00111100; //   ****
        endcase
    
    // OBJECT STATUS SIGNALS
//    wire wall_on;
    wire pad_on, pad_on1, sq_ball_on, ball_on;
//    wire [11:0] wall_rgb;
    wire [11:0] pad_rgb, ball_rgb, bg_rgb;
    
    // pixel within wall boundaries
//    assign wall_on = ((X_WALL_L <= x) && (x <= X_WALL_R)) ? 1 : 0;
    
    // assign object colors
//    assign wall_rgb = 12'hAAA;      // gray wall
    assign pad_rgb = 12'hAAA;       // gray paddle
    assign ball_rgb = 12'hF00;      
    assign bg_rgb = 12'h0FF;       // close to black background
    
    // paddle 
    assign y_pad_t = y_pad_reg;                             // paddle top position
    assign y_pad_b = y_pad_t + PAD_HEIGHT - 1;              // paddle bottom position
    assign pad_on = (X_PAD_L <= x) && (x <= X_PAD_R) &&     // pixel within paddle boundaries
                    (y_pad_t <= y) && (y <= y_pad_b);
    
    
    // paddle 1
    assign y_pad_t1 = y_pad_reg1;                             // paddle top position
    assign y_pad_b1 = y_pad_t1 + PAD_HEIGHT - 1;              // paddle bottom position
    assign pad_on1 = (X_PAD_L1 <= x) && (x <= X_PAD_R1) &&     // pixel within paddle boundaries
                    (y_pad_t1 <= y) && (y <= y_pad_b1);
    
    
                    
    // Paddle Control
    always @* begin
        y_pad_next = y_pad_reg;     // no move
        y_pad_next1 = y_pad_reg1;     // no move
        if(refresh_tick) begin
            if(up & (y_pad_t > PAD_VELOCITY))
                y_pad_next = y_pad_reg - PAD_VELOCITY;  // move up
            else if(down & (y_pad_b < (Y_MAX - PAD_VELOCITY)))
                y_pad_next = y_pad_reg + PAD_VELOCITY;  // move down
            if(up1 & (y_pad_t1 > PAD_VELOCITY))
                y_pad_next1 = y_pad_reg1 - PAD_VELOCITY;  // move up
            else if(down1 & (y_pad_b1 < (Y_MAX - PAD_VELOCITY)))
                y_pad_next1 = y_pad_reg1 + PAD_VELOCITY;  // move down
        end
    end
    
    // rom data square boundaries
    assign x_ball_l = x_ball_reg;
    assign y_ball_t = y_ball_reg;
    assign x_ball_r = x_ball_l + BALL_SIZE - 1;
    assign y_ball_b = y_ball_t + BALL_SIZE - 1;
    // pixel within rom square boundaries
    assign sq_ball_on = (x_ball_l <= x) && (x <= x_ball_r) &&
                        (y_ball_t <= y) && (y <= y_ball_b);
    // map current pixel location to rom addr/col
    assign rom_addr = y[2:0] - y_ball_t[2:0];   // 3-bit address
    assign rom_col = x[2:0] - x_ball_l[2:0];    // 3-bit column index
    assign rom_bit = rom_data[rom_col];         // 1-bit signal rom data by column
    // pixel within round ball
    assign ball_on = sq_ball_on & rom_bit;      // within square boundaries AND rom data bit == 1
    // new ball position
    assign x_ball_next = (!refresh_tick) ?  x_ball_reg : (x_ball_l > X_MAX || x_ball_r < 1) ?  x_ball_initial : x_ball_reg + x_delta_reg;
    assign y_ball_next = (!refresh_tick) ?  y_ball_reg : (x_ball_l > X_MAX || x_ball_r < 1) ?  y_ball_initial : y_ball_reg + y_delta_reg;
    
    // change ball direction after collision
    always @* begin
        x_delta_next = x_delta_reg;
        y_delta_next = y_delta_reg;
        if(y_ball_t < 1)                                            // collide with top
            y_delta_next = BALL_VELOCITY_POS;                       // move down
        else if(y_ball_b > Y_MAX)                                   // collide with bottom
            y_delta_next = BALL_VELOCITY_NEG;                       // move up
//        else if(x_ball_l <= X_WALL_R)                               // collide with wall
//            x_delta_next = BALL_VELOCITY_POS;                       // move right
        else if((X_PAD_L <= x_ball_r) && (x_ball_r <= X_PAD_R) &&
                (y_pad_t <= y_ball_b) && (y_ball_t <= y_pad_b))     // collide with paddle
            x_delta_next = BALL_VELOCITY_NEG;                       // move left
        else if((X_PAD_R1 >= x_ball_l) && (x_ball_l >= X_PAD_L1) &&
            (y_pad_t1 <= y_ball_b) && (y_ball_t <= y_pad_b1))     // collide with paddle
        x_delta_next = BALL_VELOCITY_POS;                  
    end                    
    
    
    // rgb multiplexing circuit
    always @*
        if(~video_on)
            rgb = 12'h000;      // no value, blank
        else
//            if(wall_on)
//                rgb = wall_rgb;     // wall color
            if(pad_on || pad_on1)
                rgb = pad_rgb;      // paddle color
            else if(ball_on)
                rgb = ball_rgb;     // ball color
            else
                rgb = bg_rgb;       // background
       
endmodule