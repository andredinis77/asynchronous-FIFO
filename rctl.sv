
module rctl(
        rq2_wptr,
        rclk, rrst_n,
        rget,
        rptr,
        raddr,
        emp_flag
);
    parameter DATA_WIDTH = 9,
              ADDR_WIDTH = 8;

    //INPUTS
    input logic[DATA_WIDTH-1:0] rq2_wptr; //what comes from write module
    input logic rclk, rrst_n, rget;  //rget is if we have an order to read

    //OUTPUTS
    output logic[DATA_WIDTH-1:0] rptr;  //rptr that goes to write module
    output logic[ADDR_WIDTH-1:0] raddr; //what goes to fifo memory
    output logic emp_flag;              //see if it's empty

    //INTERNAL WIRES    
    logic rrdy; //flag to check if fifo is empty
    logic rinc; //incrementation of rbin
    
    logic[DATA_WIDTH-1:0] rbin, rbin_next, rgray_next;
        
    assign rrdy = ~(rptr == rq2_wptr); //checks if its empty (if what we are reading is equal to what we are getting then read is empty)

    assign emp_flag = (!rrdy);

    assign rinc = rget & rrdy; //we need to have an order to read and a valid port on our read module
     
    assign rbin_next = rbin + rinc; //incrementation: rbin + 1

    assign rgray_next = (rbin_next >> 1) ^ rbin_next; //translate to gray
    
    assign raddr = rbin[ADDR_WIDTH-1:0]; //ignore the MSB because that bit tells us the lap we are

    always_ff @(posedge rclk or negedge rrst_n) begin
        if(!rrst_n) begin 
            rptr <= 'b0;
            rbin <= 'b0;
        end
        else begin
            rbin <= rbin_next;    //next rbin
            rptr <= rgray_next;   //our output in gray code
        end 
    end    

endmodule
