`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2023 07:58:28 AM
// Design Name: 
// Module Name: mul
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


module mul
#(  parameter bit_A = 5,
    parameter bit_B = 7
)
(
    input  wire signed [(bit_A-1):0] inputA,
    input  wire signed [(bit_B-1):0] inputB,
    output wire signed [(bit_A+bit_B-1):0] P
);
    // register for all combination of each bit of A*B
    //---------------------------------------------------------------------------------
    wire [(bit_A*bit_B-1):0] AB;
    //---------------------------------------------------------------------------------

    //generate the A*B signal and store in AB
    //---------------------------------------------------------------------------------
    genvar i,j;
    generate
        for(i=0;i<bit_A;i=i+1) begin
            for(j=0;j<bit_B;j=j+1) begin
                assign AB[7*i+j] = inputA[i]*inputB[j];
            end
        end
    endgenerate
    //---------------------------------------------------------------------------------

    // stage 1 to 2
    //---------------------------------------------------------------------------------
    wire [8:0] stage1_upper_S;
    wire [6:0] stage1_upper_C;
    wire [7:0] stage1_lower_S;
    wire [5:0] stage1_lower_C;
    //---------------------------------------------------------------------------------
    // stage 1 to stage 2 behavior (upper)
    //---------------------------------------------------------------------------------
    assign stage1_upper_S[0] = AB[0];
    HA HA_0 (.A(AB[1]),.B(AB[7]),.S(stage1_upper_S[1]),.C_out(stage1_upper_C[0]));
    generate
        for(i=0;i<4;i=i+1) begin
            FA FA_0 (.A(AB[2+i]),.B(AB[8+i]),.C_in(AB[14+i]),.S(stage1_upper_S[2+i]),.C_out(stage1_upper_C[1+i]));
        end
    endgenerate
    FA FA_1 (.A((~AB[6])),.B(AB[12]),.C_in(AB[18]),.S(stage1_upper_S[6]),.C_out(stage1_upper_C[5]));
    HA HA_1 (.A((~AB[13])),.B(AB[19]),.S(stage1_upper_S[7]),.C_out(stage1_upper_C[6]));
    assign stage1_upper_S[8] = ~AB[20];
    //---------------------------------------------------------------------------------

    // stage 1 to stage 2 behavior (lower)
    //---------------------------------------------------------------------------------
    assign stage1_lower_S[0] = AB[21];
    generate
        for(i=0;i<5;i=i+1) begin
            HA HA_2 (.A(AB[22+i]),.B(~AB[28+i]),.S(stage1_lower_S[1+i]),.C_out(stage1_lower_C[i]));
        end
    endgenerate
    HA HA_15 (.A(~AB[27]),.B(~AB[33]),.S(stage1_lower_S[6]),.C_out(stage1_lower_C[5]));
    assign stage1_lower_S[7] = AB[34];
    //---------------------------------------------------------------------------------

    // stage 2 to 3
    //---------------------------------------------------------------------------------
    wire [10:0] stage2_S;
    wire  [6:0] stage2_C;
    //---------------------------------------------------------------------------------
    // stage 2 to stage 3 behavior
    //---------------------------------------------------------------------------------
    assign stage2_S[0] = stage1_upper_S[0];
    assign stage2_S[1] = stage1_upper_S[1];
    HA HA_3 (.A(stage1_upper_S[2]),.B(stage1_upper_C[0]),.S(stage2_S[2]),.C_out(stage2_C[0]));
    generate
        for(i=0;i<6;i=i+1) begin
            FA FA_2 (.A(stage1_upper_S[3+i]),.B(stage1_upper_C[1+i]),.C_in(stage1_lower_S[0+i]),.S(stage2_S[3+i]),.C_out(stage2_C[1+i]));
        end
    endgenerate
    assign stage2_S[9] = stage1_lower_S[6];
    assign stage2_S[10] = stage1_lower_S[7];
    //---------------------------------------------------------------------------------

    // stage 3 to 4
    //---------------------------------------------------------------------------------
    wire [10:0] stage3_S;
    wire  [7:0] stage3_C;
    //---------------------------------------------------------------------------------

    // stage 3 to stage 4 behavior
    //---------------------------------------------------------------------------------
    assign stage3_S[0] = stage2_S[0];
    assign stage3_S[1] = stage2_S[1];
    assign stage3_S[2] = stage2_S[2];
    HA HA_4 (.A(stage2_S[3]),.B(stage2_C[0]),.S(stage3_S[3]),.C_out(stage3_C[0]));
    HA HA_5 (.A(stage2_S[4]),.B(stage2_C[1]),.S(stage3_S[4]),.C_out(stage3_C[1]));
    generate
        for(i=0;i<5;i=i+1) begin
            FA FA_3 (.A(stage2_S[5+i]),.B(stage2_C[2+i]),.C_in(stage1_lower_C[0+i]),.S(stage3_S[5+i]),.C_out(stage3_C[2+i]));
        end
    endgenerate
    HA HA_6 (.A(stage2_S[10]),.B(stage1_lower_C[5]),.S(stage3_S[10]),.C_out(stage3_C[7]));
    //---------------------------------------------------------------------------------

    // calculate for P_tmp (hasn't add 1'b1)
    wire  [6:0] carrier_tmp;
    wire [12:0] P_tmp;
    //---------------------------------------------------------------------------------
    assign P_tmp[0] = stage3_S[0];
    assign P_tmp[1] = stage3_S[1];
    assign P_tmp[2] = stage3_S[2];
    assign P_tmp[3] = stage3_S[3];
    HA HA_7 (.A(stage3_S[4]),.B(stage3_C[0]),.S(P_tmp[4]),.C_out(carrier_tmp[0]));
    generate
        for(i=0;i<6;i=i+1) begin
            FA FA_4(.A(stage3_S[5+i]),.B(stage3_C[1+i]),.C_in(carrier_tmp[0+i]),.S(P_tmp[5+i]),.C_out(carrier_tmp[1+i]));
        end
    endgenerate
    HA HA_8 (.A(stage3_C[7]),.B(carrier_tmp[6]),.S(P_tmp[11]),.C_out(P_tmp[12]));
    //---------------------------------------------------------------------------------

    
    // calculate for P
    wire [7:0] carrier; 
    //---------------------------------------------------------------------------------
    assign P[0] = P_tmp[0];
    assign P[1] = P_tmp[1];
    assign P[2] = P_tmp[2];
    assign P[3] = P_tmp[3];
    HA HA_9  (.A(P_tmp[4]),.B(1'b1),.S(P[4]),.C_out(carrier[0]));
    HA HA_10 (.A(P_tmp[5]),.B(carrier[0]),.S(P[5]),.C_out(carrier[1]));
    FA FA_5  (.A(P_tmp[6]),.B(1'b1),.C_in(carrier[1]),.S(P[6]),.C_out(carrier[2]));
    HA HA_11 (.A(P_tmp[7]),.B(carrier[2]),.S(P[7]),.C_out(carrier[3]));
    HA HA_12 (.A(P_tmp[8]),.B(carrier[3]),.S(P[8]),.C_out(carrier[4]));
    HA HA_13 (.A(P_tmp[9]),.B(carrier[4]),.S(P[9]),.C_out(carrier[5]));
    HA HA_14 (.A(P_tmp[10]),.B(carrier[5]),.S(P[10]),.C_out(carrier[6]));
    FA FA_6  (.A(P_tmp[11]),.B(1'b1),.C_in(carrier[6]),.S(P[11]),.C_out(carrier[7])); 
    // P12 P13 doesn't need to be calculated
    //---------------------------------------------------------------------------------

endmodule
