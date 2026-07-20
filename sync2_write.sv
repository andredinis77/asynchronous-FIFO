`include "flip_flop_write.sv"


module sync2_write #(
            parameter DATA_WIDTH = 7
)(
            input logic [DATA_WIDTH-1:0] rptr,
            input logic wclk, wrst_n,
            output logic [DATA_WIDTH-1:0] wq2_rptr

);  

    logic[DATA_WIDTH-1:0] q1_out;

    flip_flop_write flip_flop1( 
        .wclk( wclk ),
        .wrst_n( wrst_n ),
        .d( rptr ),
        .q(q1_out)
    );

    flip_flop_write flip_flop2(
        .wclk( wclk ),
        .wrst_n( wrst_n ),
        .d( q1_out ),
        .q( wq2_rptr)
    );

endmodule
