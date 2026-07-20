 `include "flip_flop_read.sv"


module sync2_read #(
            parameter DATA_WIDTH = 7
)(
            input logic [DATA_WIDTH-1:0] wptr,
            input logic rclk, rrst_n,
            output logic [DATA_WIDTH-1:0] rq2_wptr

);  

    logic[DATA_WIDTH-1:0] q1_out;

    flip_flop_read flip_flop1( 
        .rclk( rclk ),
        .rrst_n( rrst_n ),
        .d( wptr ),
        .q(q1_out)
    );

    flip_flop_read flip_flop2(
        .rclk( rclk ),
        .rrst_n( rrst_n ),
        .d( q1_out ),
        .q( rq2_wptr)
    );

endmodule
