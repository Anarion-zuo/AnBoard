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
    input [4:0] addr1,
    input [4:0] addr2,
    input [4:0] write_addr,
    input [63:0] write_data,
    output reg[63:0] read_data1,
    output reg[63:0] read_data2
    );
    reg we, re;
    reg [63:0] regs [31:0];
    integer reg_state_fd;
    initial begin
        $readmemh("../../../../out/reg_state.in", regs);
        read_data1 = 0;
        read_data2 = 0;
        /*if (reg_state_fd == 0) begin
            for (integer i = 0; i < 32; i = i + 1) begin
                regs[i] = 0;
            end
            read_data1 = 0;
            read_data2 = 0;
        end else begin
            $readmemh(reg_state_fd, regs);
            $fclose(reg_state_fd);
        end*/
    end

    always @(addr1 or addr2 or we or write_data or write_addr) begin
        if (we == 1'b1) begin
            regs[write_addr] = write_data;
            we = 1'b0;
        end
        if (re == 1'b1) begin
            read_data1 = regs[addr1];
            read_data2 = regs[addr2];
            re = 1'b0;
        end
    end
    
endmodule
