`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2022 06:06:17 PM
// Design Name: 
// Module Name: ALU
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


module ALU(
    input[63:0] s1,
    input[63:0] s2,
    input[3:0] aluOp,
    output wire[63:0] out_reg,
    output wire zf, of, sf, cf
    );

    reg[3:0] ADD = 4'b0010, 
             SUB = 4'b0110,
             SLT = 4'b0111,
             SLTU = 4'b1000,
             AND = 4'b0000,
             OR = 4'b0001,
             XOR = 4'b0010,
             NOR = 4'b1100,
             SLL = 4'b1101,
             SRL = 4'b1110,
             SRA = 4'b1111;

    reg[64:0] out;
    assign out_reg = out[63:0];

    assign of = (s1[63] & s2[63] & ~out[63]) | (~s1[63] & ~s2[63] & out[63]);
    assign cf = out[64];
    assign sf = out[63];
    assign zf = ~|out[63:0];
    
    reg[63:0] temp;
    reg launch = 1'b0, done = 1'b0;
    reg signed [63:0] s1_signed, s2_signed;
    
    always @(launch) begin
        if (launch === 1'b1) begin
        s1_signed = s1;
        s2_signed = s2;
        launch = 1'b0;
        case(aluOp)
            AND: out = s1 & s2;
            OR: out = s1 | s2;
            ADD: begin
                out = s1_signed + s2_signed;
            end
            SUB: out = s1_signed + ~s2_signed + 1;
            SLT: out = s1_signed < s2_signed ? 1 : 0;
            SLTU: out = s1 < s2 ? 1 : 0;
            XOR: out = s1 ^ s2;
            NOR: out = ~(s1 | s2);
            SLL: out = s1 << s2;
            SRL: out = s1 >> s2;
            SRA: out = s1_signed >>> s2_signed;
            default:
                $display("unknown alu opcode 0x%h", aluOp);
        endcase
        done = 1'b1;
        end
    end
endmodule
