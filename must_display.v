`timescale 1ns/1ps

module must_display(
    input wire vga_clk,
    input wire sys_rst_n,
    input wire [9:0] pix_x,
    input wire [9:0] pix_y,
    output reg [15:0] pix_data
);

parameter H_VALID = 10'd640;
parameter V_VALID = 10'd480;
parameter WHITE = 16'hFFFF;
parameter BLACK = 16'h0000;


parameter CHAR_WIDTH = 64;
parameter CHAR_HEIGHT = 64;  
parameter CHAR_SPACING = 32;
parameter LINE_WIDTH = 8;     


parameter M_START_X = (H_VALID - (4*CHAR_WIDTH + 3*CHAR_SPACING)) / 2;
parameter U_START_X = M_START_X + CHAR_WIDTH + CHAR_SPACING;
parameter S_START_X = U_START_X + CHAR_WIDTH + CHAR_SPACING;  
parameter T_START_X = S_START_X + CHAR_WIDTH + CHAR_SPACING;
parameter CHAR_START_Y = (V_VALID - CHAR_HEIGHT) / 2;


wire in_M = (pix_x >= M_START_X) && (pix_x < M_START_X + CHAR_WIDTH) && 
            (pix_y >= CHAR_START_Y) && (pix_y < CHAR_START_Y + CHAR_HEIGHT);
wire in_U = (pix_x >= U_START_X) && (pix_x < U_START_X + CHAR_WIDTH) && 
            (pix_y >= CHAR_START_Y) && (pix_y < CHAR_START_Y + CHAR_HEIGHT);
wire in_S = (pix_x >= S_START_X) && (pix_x < S_START_X + CHAR_WIDTH) && 
            (pix_y >= CHAR_START_Y) && (pix_y < CHAR_START_Y + CHAR_HEIGHT);
wire in_T = (pix_x >= T_START_X) && (pix_x < T_START_X + CHAR_WIDTH) && 
            (pix_y >= CHAR_START_Y) && (pix_y < CHAR_START_Y + CHAR_HEIGHT);


wire [5:0] char_x_M = pix_x - M_START_X;
wire [5:0] char_y_M = pix_y - CHAR_START_Y;
wire [5:0] char_x_U = pix_x - U_START_X;
wire [5:0] char_y_U = pix_y - CHAR_START_Y;
wire [5:0] char_x_S = pix_x - S_START_X;
wire [5:0] char_y_S = pix_y - CHAR_START_Y;
wire [5:0] char_x_T = pix_x - T_START_X;
wire [5:0] char_y_T = pix_y - CHAR_START_Y;


wire M_pixel = (char_x_M < LINE_WIDTH) ||                      
               (char_x_M >= CHAR_WIDTH - LINE_WIDTH) ||         
               ((char_y_M >= char_x_M * (CHAR_HEIGHT/2) / (CHAR_WIDTH/2) - 2 && 
                 char_y_M <= char_x_M * (CHAR_HEIGHT/2) / (CHAR_WIDTH/2) + 2) && char_x_M < CHAR_WIDTH/2) || 
               ((char_y_M >= (CHAR_WIDTH - char_x_M) * (CHAR_HEIGHT/2) / (CHAR_WIDTH/2) - 2 && 
                 char_y_M <= (CHAR_WIDTH - char_x_M) * (CHAR_HEIGHT/2) / (CHAR_WIDTH/2) + 2) && char_x_M >= CHAR_WIDTH/2); 

wire U_pixel = (char_x_U < LINE_WIDTH) ||                          
               (char_x_U >= CHAR_WIDTH - LINE_WIDTH) ||             
               (char_y_U >= CHAR_HEIGHT - LINE_WIDTH);            

wire S_pixel = (char_x_S < LINE_WIDTH && char_y_S < CHAR_HEIGHT/2) || 
               (char_x_S >= CHAR_WIDTH - LINE_WIDTH && char_y_S >= CHAR_HEIGHT/2) || 
               (char_y_S < LINE_WIDTH) ||                           
               (char_y_S >= CHAR_HEIGHT - LINE_WIDTH) ||          
               (char_y_S >= CHAR_HEIGHT/2 - LINE_WIDTH/2 && char_y_S < CHAR_HEIGHT/2 + LINE_WIDTH/2); 

wire T_pixel = (char_x_T >= CHAR_WIDTH/2 - LINE_WIDTH/2 && char_x_T < CHAR_WIDTH/2 + LINE_WIDTH/2) || 
               (char_y_T < LINE_WIDTH);                            

wire char_pixel = (in_M && M_pixel) || (in_U && U_pixel) || 
                  (in_S && S_pixel) || (in_T && T_pixel);

always @(posedge vga_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        pix_data <= BLACK;
    end else begin
        if (char_pixel)
            pix_data <= WHITE;
        else
            pix_data <= BLACK;
    end
end

endmodule
