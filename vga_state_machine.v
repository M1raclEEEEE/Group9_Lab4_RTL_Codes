`timescale 1ns/1ps

module vga_state_machine(
    input wire sys_clk,
    input wire sys_rst_n,
    input wire button_press,      
    output wire hsync,
    output wire vsync,
    output wire [15:0] rgb,
    output reg [2:0] state_leds   
);

   
    parameter STATE_COLOR_BAR = 2'b00;
    parameter STATE_MUST      = 2'b01;
    parameter STATE_END       = 2'b10;
    
    reg [1:0] current_state;
    reg [1:0] next_state;
    
    
    wire vga_clk;
    wire [9:0] pix_x;
    wire [9:0] pix_y;
    wire [15:0] colorbar_data;
    wire [15:0] must_data;
    wire [15:0] end_data;
    
  
    reg button_prev;
    wire button_rising;
  
    pll pll_inst (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .vga_clk(vga_clk)
    );
    
   
    vga_ctrl vga_ctrl_inst (
        .vga_clk(vga_clk),
        .sys_rst_n(sys_rst_n),
        .pix_data(rgb),
        .pix_x(pix_x),
        .pix_y(pix_y),
        .hsync(hsync),
        .vsync(vsync),
        .rgb(rgb)
    );
    
   
    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            button_prev <= 1'b0;
        end else begin
            button_prev <= button_press;
        end
    end
    
    assign button_rising = (button_press == 1'b1) && (button_prev == 1'b0);
    
  
    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            current_state <= STATE_COLOR_BAR;
        end else begin
            current_state <= next_state;
        end
    end
    
   
    always @(*) begin
        next_state = current_state; 
        
        if (button_rising) begin
            case (current_state)
                STATE_COLOR_BAR: next_state = STATE_MUST;
                STATE_MUST:      next_state = STATE_END;
                STATE_END:       next_state = STATE_COLOR_BAR;
                default:         next_state = STATE_COLOR_BAR;
            endcase
        end
    end
    
   
    assign colorbar_data = (pix_x < 160) ? 16'hF800 :    
                          (pix_x < 320) ? 16'h07E0 :   
                          (pix_x < 480) ? 16'h001F :    
                          (pix_x < 640) ? 16'hFFFF :   
                          16'h0000;                    
    
   
    must_display must_inst (
        .vga_clk(vga_clk),
        .sys_rst_n(sys_rst_n),
        .pix_x(pix_x),
        .pix_y(pix_y),
        .pix_data(must_data)
    );
    
   
    end_display end_inst (
        .vga_clk(vga_clk),
        .sys_rst_n(sys_rst_n),
        .pix_x(pix_x),
        .pix_y(pix_y),
        .pix_data(end_data)
    );
    
  
    assign rgb = (current_state == STATE_COLOR_BAR) ? colorbar_data :
                (current_state == STATE_MUST) ? must_data :
                (current_state == STATE_END) ? end_data :
                16'h0000;
    

    always @(*) begin
        case (current_state)
            STATE_COLOR_BAR: state_leds = 3'b001;
            STATE_MUST:      state_leds = 3'b010;
            STATE_END:       state_leds = 3'b100;
            default:         state_leds = 3'b001;
        endcase
    end

endmodule
