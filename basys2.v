`timescale 1 ns / 10 ps
`define PERIOD 10
`define HALF_PERIOD 5

`include "mux_sel.vh"

`define ASSERT_EQUALS(x,y) \
        repeat(1)\
        begin\
            if( (x) != (y) ) \
            begin\
                $write( "assert failed %d != %d\n", (x), (y) );\
                $finish(1);\
            end\
        end

`define BTN_ALL_OFF 4'd0

module basys2;

    reg MCLK = 0;
    reg [7:0] sw = 8'd0;
    reg [3:0] btn = `BTN_ALL_OFF;

    wire [7:0] Led;
    wire [6:0] seg;
    wire [3:0] an;
    wire dp;

    wire clk256;

    reg t_reset;

    reg PS2C;
    reg PS2D;

    AL_Controller run_alarm_clock
        ( .MCLK(MCLK),
          .sw(sw),
          .btn(btn),
          .PS2C(PS2C),
          .PS2D(PS2D),
          .Led(Led),
          .seg(seg),
          .an(an),
          .dp(dp) );
   
    /* This is the clock */
    always
    begin
        #`HALF_PERIOD MCLK = ~MCLK;
    end

    initial
    begin
        $display("Hello, world");
        $dumpfile("basys2.vcd");
        $dumpvars(0,basys2);

        $monitor( "%d Led=%x seg=%d",$time, Led, seg );

        sw = 8'd2; // turn on fast mode
//        sw = 8'd0;
        btn = 4'd0;
        # `PERIOD;

//        # 100000;
//        $finish;
    end

endmodule

