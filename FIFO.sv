`include "sync2_read.sv"
`include "sync2_write.sv"
`include "rctl.sv"
`include "wctl.sv"

module FIFO #(
    parameter DATA_WIDTH = 7,
    parameter ADDR_WIDTH = 6,
    parameter FIFO_DEPTH = 64,
    parameter BITS       = 6
)(
    input  logic [BITS-1:0] wdata,
    input  logic            wput, wclk, wrst_n,
    input  logic            rget, rclk, rrst_n,
    output logic [BITS-1:0] rdata,
    output logic[DATA_WIDTH-1:0] wbin,
    output logic            wfull, emp_flag
);

    //INTERNAL DATA
    logic[BITS-1:0] FIFO [0:FIFO_DEPTH];
    logic[DATA_WIDTH-1:0] wptr, rptr, rq2_wptr, wq2_rptr;
    logic[ADDR_WIDTH-1:0] waddr, raddr;
    logic wren;
    
    sync2_read  sync2_read(
        .wptr( wptr ),
        .rclk( rclk ),
        .rrst_n( rrst_n ),
        .rq2_wptr( rq2_wptr )
    );

    rctl rctl(
        .rq2_wptr( rq2_wptr ),
        .rclk( rclk ),
        .rrst_n( rrst_n ),
        .rget( rget ),
        .rptr( rptr ),
        .raddr( raddr ),
        .emp_flag( emp_flag )
    );

    sync2_write sync2_write(
        .rptr( rptr ),
        .wclk( wclk ),
        .wrst_n( wrst_n ),
        .wq2_rptr( wq2_rptr )
    );

    wctl wctl(
        .wq2_rptr( wq2_rptr ),
        .wclk( wclk ),
        .wrst_n( wrst_n ),
        .wput( wput ),
        .wbin( wbin ),
        .wfull( wfull ),
        .waddr( waddr ),
        .wenable( wren ),
        .wptr( wptr )
    );


    always_ff @(posedge wclk) begin
            if(wren) begin
                FIFO[waddr] <= wdata;
        end
    end

   assign rdata = FIFO[raddr];
   

endmodule 
