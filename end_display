`timescale 1ns/1ps

module end_display(
    input wire vga_clk,
    input wire sys_rst_n,
    input wire [9:0] pix_x,
    input wire [9:0] pix_y,
    output reg [15:0] pix_data
);

    parameter H_DISPLAY = 640;
    parameter V_DISPLAY = 480;
    parameter CHAR_WIDTH = 60; 
    parameter CHAR_HEIGHT = 80;
    parameter CHAR_SPACING = 40;
    
    parameter TEXT_START_X = (H_DISPLAY - (3*CHAR_WIDTH + 2*CHAR_SPACING)) / 2;
    parameter TEXT_START_Y = (V_DISPLAY - CHAR_HEIGHT) / 2;
    
    parameter E_START_X = TEXT_START_X;
    parameter N_START_X = TEXT_START_X + CHAR_WIDTH + CHAR_SPACING;
    parameter D_START_X = TEXT_START_X + 2*CHAR_WIDTH + 2*CHAR_SPACING;
    
   
    wire in_E = (pix_x >= E_START_X) && (pix_x < E_START_X + CHAR_WIDTH) && 
                (pix_y >= TEXT_START_Y) && (pix_y < TEXT_START_Y + CHAR_HEIGHT);
    wire in_N = (pix_x >= N_START_X) && (pix_x < N_START_X + CHAR_WIDTH) && 
                (pix_y >= TEXT_START_Y) && (pix_y < TEXT_START_Y + CHAR_HEIGHT);
    wire in_D = (pix_x >= D_START_X) && (pix_x < D_START_X + CHAR_WIDTH) && 
                (pix_y >= TEXT_START_Y) && (pix_y < TEXT_START_Y + CHAR_HEIGHT);
    
   
    wire [9:0] rel_x_E = pix_x - E_START_X;
    wire [9:0] rel_y_E = pix_y - TEXT_START_Y;
    wire [9:0] rel_x_N = pix_x - N_START_X;
    wire [9:0] rel_y_N = pix_y - TEXT_START_Y;
    wire [9:0] rel_x_D = pix_x - D_START_X;
    wire [9:0] rel_y_D = pix_y - TEXT_START_Y;
    

    wire E_pixel = (rel_x_E < 8) ||                       
                   (rel_y_E < 8) ||                         
                   (rel_y_E >= CHAR_HEIGHT - 8) ||          
                   (rel_y_E >= CHAR_HEIGHT/2 - 4 && rel_y_E < CHAR_HEIGHT/2 + 4); 

    wire N_pixel = (rel_x_N < 8) ||                           
                   (rel_x_N >= CHAR_WIDTH - 8) ||            
                   (rel_x_N >= (rel_y_N * (CHAR_WIDTH - 16)) / CHAR_HEIGHT + 6 && 
                    rel_x_N <= (rel_y_N * (CHAR_WIDTH - 16)) / CHAR_HEIGHT + 10); 

    wire D_pixel = (rel_x_D < 8) ||                      
                   (rel_y_D < 8) ||                         
                   (rel_y_D >= CHAR_HEIGHT - 8) ||           
                   (rel_x_D >= CHAR_WIDTH - 8 && rel_y_D >= 8 && rel_y_D < CHAR_HEIGHT - 8); 

    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            pix_data <= 16'h0000;
        end else begin
            if (in_E && E_pixel)
                pix_data <= 16'hFFFF;
            else if (in_N && N_pixel)
                pix_data <= 16'hFFFF;
            else if (in_D && D_pixel)
                pix_data <= 16'hFFFF;
            else
                pix_data <= 16'h0000;
        end
    end

endmodule
