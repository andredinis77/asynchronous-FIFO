module wctl(
        wq2_rptr,
        wclk, wrst_n,
        wput,
        wfull,
        waddr,
        wenable,
        wptr
);

    parameter DATA_WIDTH = 9,
              ADDR_WIDTH = 8;
    
    //INPUTS
    input logic[DATA_WIDTH-1:0] wq2_rptr;
    input logic wclk, wrst_n, wput;

    //OUTPUTS
    output logic[DATA_WIDTH-1:0] wptr;
    output logic[ADDR_WIDTH-1:0] waddr;
    output logic wfull, wenable;
    
    //internal wires
    logic winc;
    logic[DATA_WIDTH-1:0] wbin, wbin_next, wgray;


    logic[1:0] aux;
    assign aux = ~wq2_rptr[DATA_WIDTH - 1: DATA_WIDTH - 2];
    logic[DATA_WIDTH-1:0] comp;
    assign comp = {aux, wq2_rptr[DATA_WIDTH-3:0]};

    assign wfull = (comp == wptr);

    assign winc = ~wfull & wput;

    assign wbin_next = wbin + winc;

    assign wgray = (wbin_next >> 1) ^ wbin_next;

    assign waddr = wbin[ADDR_WIDTH-1:0];
    
    assign wenable = winc;

    always_ff @(posedge wclk or negedge wrst_n) begin
        if(!wrst_n) begin
                wbin <= 'b0;
                wptr <= 'b0;
        end
        else begin
                wbin <= wbin_next;
                wptr <= wgray;
        end
    end

endmodule

    

    
