`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2023 09:50:06 AM
// Design Name: 
// Module Name: mul_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mul_tb
#(
    parameter bit_A = 5,
    parameter bit_B = 7
)
(
);
    reg  signed [(bit_A-1):0] inputA;
    reg  signed [(bit_B-1):0] inputB;
    wire signed [(bit_A+bit_B-1):0] P;
    
    mul mul_DUT (.inputA(inputA),.inputB(inputB),.P(P));
    
    integer q,k,count;    
    //initial begin
    //    $dumpfile("mul.vcd");
    //    $dumpvars();
    //end
    reg signed [(bit_A+bit_B-1):0] golden;
    initial begin
        count <= 1;
        #10;
        for(q=1;q<((2**5)-1);q=q+1) begin
            for(k=1;k<((2**7)-1);k=k+1) begin
                inputdata(5'b0+q,7'b0+k,count);
                count = count + 1;
            end
        end
    end
    task inputdata;
        input  signed     [bit_A-1:0] A; // input A
        input  signed     [bit_B-1:0] B; // input B  
        input               [31:0] pcnt; // pattern count
        reg signed [(bit_A+bit_B-1):0] golden;
        begin
            inputA <= A;
            inputB <= B;
            golden <= A*B;
                $display("[Pattern %d] input A = %d , input B = %d ", pcnt, A , B);
            #10;
            if(P !== golden) begin
                $display("[ERROR] [Pattern %d] Golden answer: %d, Your answer: %d", pcnt, golden , P);
                $finish;
            end else begin
                $display("[Correct] [Pattern %d] Golden answer: %d, Your answer: %d", pcnt, golden , P);
            end
        end
    endtask
endmodule
