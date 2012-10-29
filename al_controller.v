//-- Top Alarm Clock Controller.
//--
//-- ECE 4/530 Fall 2012
//--
//-- David Poole 27-Oct-2012
//-- 
//

`timescale 1 ns / 10 ps

/*
module AL_Controller
    ( input  MCLK,
      input  [7:0] sw,
      input  [3:0] btn,

      output  [7:0] Led,
      output  [6:0] seg,
      output  dp,
      output  [3:0] an
    );
*/

module AL_Controller ( MCLK, Led, sw, seg, dp, an, btn );

    input MCLK; 
    input [7:0] sw;
    input [3:0] btn;

    output wire [7:0] Led;
    output wire [6:0] seg;
    output wire dp;
    output wire [3:0] an;

    wire freq_div_out_time_gen_in;

    // internal signals
    reg int_fast_mode;
    wire int_one_second;
    wire int_one_minute;
    reg int_reset;

    wire [6:0] int_seg;
    wire [3:0] int_an;
    wire int_dp;

//    reg [7:0] second_counter = 0;
//    reg [7:0] minute_counter = 0;

    reg [3:0] bcd_ms_hour = 0;
    reg [3:0] bcd_ls_hour = 0;
    reg [3:0] bcd_ms_min = 0;
    reg [3:0] bcd_ls_min = 0;

    wire [3:0] bcd_ms_hour_out;
    wire [3:0] bcd_ls_hour_out;
    wire [3:0] bcd_ms_min_out;
    wire [3:0] bcd_ls_min_out;


`ifdef SIMULATION
    localparam clock_div = 2;  
`else
//    localparam clock_div = 195312;  // 50Mhz -> 256Hz
    localparam clock_div = 97656;  // 25Mhz -> 256Hz
`endif

    FREQ_DIV #(clock_div) run_freq_div
        (.clk(MCLK),
         .reset(int_reset),
         .clk256(freq_div_out_time_gen_in) );

    TIME_GEN run_time_gen
        (.clk256(freq_div_out_time_gen_in),
         .reset(int_reset),
         .fast_mode( int_fast_mode ),
         .one_second(int_one_second),
         .one_minute(int_one_minute) );

    /* increments current time by one minute */
    bcd_clock run_bcd_clock
        (.add_one(int_one_minute),
         .ms_hour(bcd_ms_hour),
         .ls_hour(bcd_ls_hour),
         .ms_min(bcd_ms_min),
         .ls_min(bcd_ls_min),
         
         .out_ms_hour(bcd_ms_hour_out),
         .out_ls_hour(bcd_ls_hour_out),
         .out_ms_min(bcd_ms_min_out),
         .out_ls_min(bcd_ls_min_out)
    );

`ifdef SIMULATION
    stub_digits_to_7seg run_digits_to_7seg 
`else
    hex_to_7seg run_digits_to_7seg 
`endif
        ( .rst(int_reset),
          .mclk(MCLK),
          .word_in( {bcd_ms_hour,bcd_ls_hour,bcd_ms_min,bcd_ls_min} ),
          .seg(int_seg),
          .an(int_an),
          .dp(int_dp) );

    assign seg = int_seg;
    assign an = int_an;
    assign dp = int_dp;

    assign Led ={ int_one_minute,int_one_minute,int_one_minute,int_one_minute,
                  int_one_second,int_one_second,int_one_second,int_one_second}; 

    always @(posedge MCLK)
    begin
        int_reset <= btn[0];
        int_fast_mode <= sw[1];
    end

    // reassign output of BCD hour/minute clock +1 back to current value
    always @(posedge int_reset, posedge MCLK )
    begin
        if( int_reset ) 
        begin
            bcd_ms_hour <= 0;
            bcd_ls_hour <= 0;
            bcd_ms_min <= 0;
            bcd_ls_min <= 0;
        end
        else 
        begin
            bcd_ms_hour <= bcd_ms_hour_out;
            bcd_ls_hour <= bcd_ls_hour_out;
            bcd_ms_min <= bcd_ms_min_out;
            bcd_ls_min <= bcd_ls_min_out;
        end
    end
/*
    always @(posedge int_reset, posedge int_one_second )
    begin
        if( int_reset ) 
        begin
            second_counter <= 0;
        end
        else 
        begin
            if( second_counter <= 58 )
            begin
                second_counter <= second_counter+1;
            end
            else
            begin
                second_counter <= 0;
            end
        end
    end

    always @(posedge int_reset, posedge int_one_minute )
    begin
        if( int_reset ) 
        begin
            minute_counter <= 0;
        end
        else 
        begin
            if( minute_counter <= 58 )
            begin
                $display( "minute +1 = %d", minute_counter+1 );
                minute_counter <= minute_counter+1;
            end
            else
            begin
                $display( "minute reset" );
                minute_counter <= 0;
            end
        end
    end
*/

endmodule

