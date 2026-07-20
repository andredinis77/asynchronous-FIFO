module wctl #(
    parameter DATA_WIDTH = 7,
    parameter ADDR_WIDTH = 6
)(
    //INPUTS
    input logic[DATA_WIDTH-1:0] wq2_rptr,
    input logic wclk, wrst_n, wput,

    //OUTPUTS
    output logic[DATA_WIDTH-1:0] wptr, wbin,
    output logic[ADDR_WIDTH-1:0] waddr,
    output logic wfull, wenable
);
    
    //internal wires
    logic winc;
    logic[DATA_WIDTH-1:0] wbin_next, wgray_next;


    logic[1:0] aux;
    logic[DATA_WIDTH-1:0] comp;
    assign aux = ~wq2_rptr[DATA_WIDTH - 1: DATA_WIDTH - 2];
    assign comp = {aux, wq2_rptr[DATA_WIDTH-3:0]};

    assign winc = ~wfull & wput;

    assign wbin_next = wbin + winc;

    assign wgray_next = (wbin_next >> 1) ^ wbin_next;

    assign wfull = (comp == wptr);

    assign waddr = wbin[ADDR_WIDTH-1:0];
    
    assign wenable = winc;

    always_ff @(posedge wclk or negedge wrst_n) begin
        if(!wrst_n) begin
                wbin <= 'b0;
                wptr <= 'b0;
        end
        else begin
                wbin <= wbin_next;
                wptr <= wgray_next;
        end
    end

endmodule

    

    
