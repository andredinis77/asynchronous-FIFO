`ifndef FLIP_FLOP_WRITE_SV_
`define FLIP_FLOP_WRITE_SV_

module flip_flop_write #(
            parameter DATA_WIDTH = 7
)(
            input logic wclk, wrst_n,
            input logic [DATA_WIDTH-1:0] d,
            output logic [DATA_WIDTH-1:0] q
);

    always_ff @(posedge wclk or negedge wrst_n) begin
            if(!wrst_n) q <= 'b0;
            else begin
                q <= d;
            end
    end

endmodule

`endif