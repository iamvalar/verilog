`timescale 1 ns / 10 ps

`define PERIOD 10
`define HALF_PERIOD 5

`include "keycodes.vh"

module test_al_controller;

    reg MCLK=0;
    reg t_reset=1;
    reg t_one_second=0;

    /* This is the test clock */
    always
    begin
        #`HALF_PERIOD MCLK = ~MCLK;
    end
    
    /*
     *  256 Hz
     */
    wire t_clk256;

    localparam clock_div = 1;  /* counts 0,1,0,1,0,1,0,1,... */
    FREQ_DIV #(clock_div) run_freq_div
        (.clk(MCLK),
         .reset(t_reset),
         .clk256(t_clk256) );

    /*
     *  Keyboard
     */

    wire ps2c;
    wire ps2d;

    wire [7:0] t_key_in;
    wire [15:0] int_key_buffer;

    wire wire_set_alarm;
    wire wire_set_time;

    kbd_if run_kbd_if 
        ( .clk(MCLK),
          .reset(t_reset),

          .PS2C(ps2c),
          .PS2D(ps2d),

          /* outputs */
          .key(t_key_in)
        );

    /*
     *  AL Controller
     */
    wire t_load_alarm;
    wire t_show_alarm;
    wire t_load_new_time;
    wire t_show_keyboard;

    AL_Controller run_al_clk_counter
        ( .clk(MCLK),
          .reset(t_reset),
          .one_second(t_one_second),
          .key(t_key_in),
//          .set_alarm(0), // on the spec but not used; a key (*) used for set alarm
//          .set_time(0),  // on the spec but not used; a key (-) used for set time
          
          /* outputs */
          .out_key_buffer(int_key_buffer),
          .load_alarm(t_load_alarm),
          .show_alarm(t_show_alarm),
          .load_new_time(t_load_new_time),
          .out_show_keyboard(t_show_keyboard)
       );

    initial
    begin

        $display("Hello, world");
        $dumpfile("test_al_controller.vcd");
        $dumpvars(0,test_al_controller);

        $monitor( "%d load_alarm=%d show_alarm=%d load_new_time=%d disp=%x", 
                $time, t_load_alarm, t_show_alarm, t_load_new_time,
                int_key_buffer );

        # `PERIOD;
        @(negedge MCLK);
        t_reset = ~t_reset;
        # `PERIOD;

        # 4000;
        $finish;
    end

endmodule


