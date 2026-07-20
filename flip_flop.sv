module flip_flop(
            input logic rclk, rrst_n,
            input logic [8:0] d,
            output logic [8:0] q
);

    always_ff @(posedge rclk or negedge rrst_n) begin
            if(!rrst_n) q <= 9'b0;
            else begin
                q <= d;
            end
    end

endmodule