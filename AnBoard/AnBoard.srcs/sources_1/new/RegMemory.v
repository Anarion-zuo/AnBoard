`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/02/2022 07:04:05 PM
// Design Name: 
// Module Name: Memory
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


module RegMemory(
    input[63:0] addr,
    input we,
    output reg[63:0] data
    );

    localparam ADDR_MAX = 2^8;

    reg [7:0] internal_mem_storage [ADDR_MAX - 1:0];

    initial begin
        // for (integer i = 0; i < ADDR_MAX; i = i + 1)
        //     internal_mem_storage[i] = 8'b0;
        // internal_mem_storage[0] = 1;
        $readmemh("../../../../tests/addi.mem", internal_mem_storage);
    end

    always @(addr or we) begin
        if (we == 1'b1) begin
            internal_mem_storage[addr] = data[1 * 8 - 1 : 0];
            internal_mem_storage[addr + 1] = data[2 * 8 - 1 : 1 * 8];
            internal_mem_storage[addr + 2] = data[3 * 8 - 1 : 2 * 8];
            internal_mem_storage[addr + 3] = data[4 * 8 - 1 : 3 * 8];
            internal_mem_storage[addr + 4] = data[5 * 8 - 1 : 4 * 8];
            internal_mem_storage[addr + 5] = data[6 * 8 - 1 : 5 * 8];
            internal_mem_storage[addr + 6] = data[7 * 8 - 1 : 6 * 8];
            internal_mem_storage[addr + 7] = data[8 * 8 - 1 : 7 * 8];
        end else begin
            data[7:0] = internal_mem_storage[addr];
            data[2 * 8 - 1 : 1 * 8] = internal_mem_storage[addr + 1];
            data[3 * 8 - 1 : 2 * 8] = internal_mem_storage[addr + 2];
            data[4 * 8 - 1 : 3 * 8] = internal_mem_storage[addr + 3];
            data[5 * 8 - 1 : 4 * 8] = internal_mem_storage[addr + 4];
            data[6 * 8 - 1 : 5 * 8] = internal_mem_storage[addr + 5];
            data[7 * 8 - 1 : 6 * 8] = internal_mem_storage[addr + 6];
            data[8 * 8 - 1 : 7 * 8] = internal_mem_storage[addr + 7];
        end
    end

endmodule
