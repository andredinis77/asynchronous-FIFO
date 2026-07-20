`include "flip_flop.sv"


module sync2_read(
            input logic [8:0] wptr,
            input logic rclk, rrst_n,
            output logic [8:0] rq2_wptr

);  

    logic[7:0] q1_out;

    flip_flop flip_flop1( 
        .rclk( rclk ),
        .rrst_n( rrst_n ),
        .d( wptr ),
        .q(q1_out)
    );

    flip_flop flip_flop2(
        .rclk( rclk ),
        .rrst_n( rrst_n ),
        .d( q1_out ),
        .q( rq2_wptr)
    );

endmodule
