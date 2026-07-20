`ifndef FLIP_FLOP_READ_SV_
`define FLIP_FLOP_READ_SV_

module flip_flop_read #(
            parameter DATA_WIDTH = 7
)(
            input logic rclk, rrst_n,
            input logic [DATA_WIDTH-1:0] d,
            output logic [DATA_WIDTH-1:0] q
);

    always_ff @(posedge rclk or negedge rrst_n) begin
            if(!rrst_n) q <= 'b0;
            else begin
                q <= d;
            end
    end

endmodule

`endif