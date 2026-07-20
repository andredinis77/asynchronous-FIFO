`timescale 1ns/1ns
`include "FIFO.sv"

module test_fifo  #(
        parameter WIDTH_DATA = 6,
        parameter VECTOR_LENGTH = 76
        )();

        logic[WIDTH_DATA-1:0] wdata;
        logic wput, wclk, wrst_n;
        logic rget, rclk, rrst_n;
        logic[WIDTH_DATA-1:0] rdata; 
        logic[WIDTH_DATA:0] wbin;
        logic wfull, emp_flag;

        
        initial wclk = 1'b0;
        always begin
                #10 wclk = ~wclk;
        end

        initial rclk = 1'b0;
        always begin
                #15 rclk = ~rclk;
        end

        initial begin
                @(posedge wclk);
                wrst_n = 1'b0;
                @(posedge wclk);
                wrst_n = 1'b1;
        end

        initial begin
                @(posedge rclk);
                rrst_n = 1'b0;
                @(posedge rclk);
                rrst_n = 1'b1;
        end

        FIFO DUT(
                .wdata( wdata ), 
                .wput( wput ), 
                .wclk( wclk ), 
                .wrst_n( wrst_n ),
                .rget( rget ), 
                .rclk( rclk ), 
                .rrst_n( rrst_n ),
                .rdata( rdata ),
                .wbin( wbin ), 
                .wfull( wfull ), 
                .emp_flag( emp_flag )
        );

        logic[WIDTH_DATA-1:0] tst_vector [0:VECTOR_LENGTH-1];
        int i, j;

        initial begin
                $readmemb("test.txt", tst_vector);
                i = 0; 
                j = 0;
                wdata = 0; wput = 0; rget = 0;
        end
        
        task pulse_write(input [WIDTH_DATA-1:0] data); //2 clk cycles
                @(posedge wclk);
                wdata <= data;
                wput  <= 1'b1;
                #5;
                @(posedge wclk);
                wput  <= 1'b0;
                #5;
        endtask

        task pulse_read; //1 cycle
             if(wfull) begin 
                rget <= 1'b1;
             end
                @(posedge rclk);
                rget <= 1'b0;
                #5;
        endtask

        always @(posedge wclk) begin
                
             pulse_write(tst_vector[i]);
             i = i + 1;
             #5;
             
        end

        always @(posedge rclk) begin
            
            pulse_read;
            $display("FLAGS: empty=%b / full=%b / READ %0d: output=%b expected=%b --> %0s", emp_flag, wfull, j, rdata, tst_vector[j], (rdata==tst_vector[j])?"OK":"MISMATCH");
            $display("wbin: %b", wbin); //this will serves to understand the full's logic
            j = j + 1;
           
            #5;
            if(j === VECTOR_LENGTH) begin
                $finish();
            end
        end

endmodule