// ECE 4/530 Fall 2012
//
// David Poole 01-Nov-2012
//
// KBD Interface Test Bench
//

`timescale 1 ns / 10 ps

`include "keycodes.vh"

module kbd_if
    ( input clk256,
      input reset,
      input shift,

      inout PS2C,
      inout PS2D,

      output reg [31:0] key_buffer,
      output reg [7:0] key,
      output reg set_alarm, // (ignored) handled in AL_Controller
      output reg set_time   // (ignored) handled in AL_Controller
    );

    wire [7:0] int_key_code;
    reg [31:0] int_key_buffer;

    reg [7:0 ] last_key_pressed;

    PS2_Keyboard ps2kbd
        (.ck(clk256),
         .PS2C(PS2C),
         .PS2D(PS2D),
         .key_code_out(int_key_code) );

    always @(posedge clk256,posedge reset)
    begin
        if( reset ) 
        begin
            key <= 0;
            key_buffer <= 0;
            set_time <= 0;
            set_alarm <= 0;

            int_key_buffer <= 0;
        end
        else if( shift == 1) 
        begin
            // shift a new value into the LSB of the key buffer
            key_buffer <= {int_key_buffer[23:0],key};
            int_key_buffer <= {int_key_buffer[23:0],key};
        end
        else 
        begin
            // filter incoming codes; only pass the value
            case( int_key_code )
                `KP_0 : key <= `KP_0;   
                `KP_1 : key <= `KP_1;
                `KP_2 : key <= `KP_2;
                `KP_3 : key <= `KP_3;
                `KP_4 : key <= `KP_4;
                `KP_5 : key <= `KP_5;
                `KP_6 : key <= `KP_6;
                `KP_7 : key <= `KP_7;
                `KP_8 : key <= `KP_8;
                `KP_9 : key <= `KP_9;
                `KP_STAR : key <= `KP_STAR;
                `KP_MINUS : key <= `KP_MINUS;
                `KP_KEY_RELEASED : key <= `KP_KEY_RELEASED;
                default : key <= `KP_INVALID;
            endcase
        end
    end

endmodule

