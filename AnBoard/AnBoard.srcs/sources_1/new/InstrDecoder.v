`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2022 05:31:54 PM
// Design Name: 
// Module Name: InstrDecoder
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

module ImmDecoder(
    input[31:0] instr,
    output[20:0] imm_val
    );

    // I type
    assign imm_val = instr[31:20];

endmodule


module InstrDecoder(
    input[31:0] instr,
    output wire[6:0] opcode,
    output wire[2:0] funct3,
    output wire[6:0] funct7,
    output wire[4:0] register_dest,
    output wire[4:0] register_src_1,
    output wire[4:0] register_src_2,
    output wire[20:0] imm_val
    );
    
    assign opcode = instr[6:0];
    assign register_dest = instr[11:7];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];
    assign register_src_2 = instr[24:20];
    assign register_src_1 = instr[19:15];

    ImmDecoder immDecoder(
        .instr(instr),
        .imm_val(imm_val)
    );

    always @(instr) begin
        $display("instr 0x%h", instr);
        if (^instr === 1'bx) begin
            $display("invalid instr");
            $finish;
        end
    end

endmodule
