`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2022 06:28:04 PM
// Design Name: 
// Module Name: RISCV
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


module RISCV(
    
    );

    wire[31:0] instr;

    Controller controller(
        .instr(instr)
    );
    reg[63:0] instr_addr = 0;
    RegMemory instr_mem(
        .addr(instr_addr),
        .we(1'b0),
        .data(instr)
    );

    initial begin
        for (reg[16:0] i = 0; i < 2^8; i = i + 4) begin
            #10;
            instr_addr = instr_addr + i * 4;
        end
    end

    // assign instr = 32'b
    //00000000000100000000000010010011;
              // 100111000001100010011
              // 100111110001100010011

endmodule
