`timescale 1ns / 1ps

module tb_trafficlight;
    logic clk;
    logic rst_n;
    logic red;
    logic orange;
    logic green;

    trafficlight dut(
        .clk(clk),
        .rst_n(rst_n),
        .red(red),
        .orange(orange),
        .green(green)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;

        #10 rst_n = 1; 
        
        
        #400 $stop;
    end
endmodule