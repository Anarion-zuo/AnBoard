`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2022 06:49:34 PM
// Design Name: 
// Module Name: RegisterFile
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

module RegisterFile(
    input we,
    input [4:0] addr1,
    input [4:0] addr2,
    input [4:0] write_addr,
    input [63:0] write_data,
    output reg[63:0] read_data1,
    output reg[63:0] read_data2
    );
    reg [63:0] regs [31:0];

    initial begin
        for (integer i = 0; i < 32; i = i + 1) begin
            regs[i] = 0;
        end
        read_data1 = 0;
        read_data2 = 0;
    end

    always @(addr1 or addr2 or we or write_data or write_addr) begin
        if (we == 1'b1) regs[write_addr] <= write_data;
        else begin
            read_data1 <= regs[addr1];
            read_data2 <= regs[addr2];
        end
    end
    
endmodule
