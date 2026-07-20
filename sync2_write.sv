`include "flip_flop.sv"


module sync2_read(
            input logic [8:0] rptr,
            input logic wclk, wrst_n,
            output logic [8:0] wq2_rptr

);  

    logic[8:0] q1_out;

    flip_flop flip_flop1( 
        .rclk( wclk ),
        .rrst_n( wrst_n ),
        .d( rptr ),
        .q(q1_out)
    );

    flip_flop flip_flop2(
        .rclk( wclk ),
        .rrst_n( wrst_n ),
        .d( q1_out ),
        .q( wq2_rptr)
    );

endmodule
