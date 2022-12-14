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
    output wire[63:0] data_wire
    );

    localparam ADDR_MAX = 2^64;

    reg [7:0] internal_mem_storage [ADDR_MAX - 1:0];
    reg [63:0]data_reg;
    assign data_wire = data_reg;
    reg launch = 1'b0, done = 1'b0;

    initial begin
        // for (integer i = 0; i < ADDR_MAX; i = i + 1)
        //     internal_mem_storage[i] = 8'b0;
        // internal_mem_storage[0] = 1;
        $readmemh("../../../../out/instr.mem", internal_mem_storage);
    end

    always @(launch) begin
        if (launch === 1'b1) begin
        launch = 1'b0;
        if (we == 1'b1) begin
            internal_mem_storage[addr] = data_wire[1 * 8 - 1 : 0];
            internal_mem_storage[addr + 1] = data_wire[2 * 8 - 1 : 1 * 8];
            internal_mem_storage[addr + 2] = data_wire[3 * 8 - 1 : 2 * 8];
            internal_mem_storage[addr + 3] = data_wire[4 * 8 - 1 : 3 * 8];
            internal_mem_storage[addr + 4] = data_wire[5 * 8 - 1 : 4 * 8];
            internal_mem_storage[addr + 5] = data_wire[6 * 8 - 1 : 5 * 8];
            internal_mem_storage[addr + 6] = data_wire[7 * 8 - 1 : 6 * 8];
            internal_mem_storage[addr + 7] = data_wire[8 * 8 - 1 : 7 * 8];
        end else begin
            data_reg[7:0] = internal_mem_storage[addr];
            data_reg[2 * 8 - 1 : 1 * 8] = internal_mem_storage[addr + 1];
            data_reg[3 * 8 - 1 : 2 * 8] = internal_mem_storage[addr + 2];
            data_reg[4 * 8 - 1 : 3 * 8] = internal_mem_storage[addr + 3];
            data_reg[5 * 8 - 1 : 4 * 8] = internal_mem_storage[addr + 4];
            data_reg[6 * 8 - 1 : 5 * 8] = internal_mem_storage[addr + 5];
            data_reg[7 * 8 - 1 : 6 * 8] = internal_mem_storage[addr + 6];
            data_reg[8 * 8 - 1 : 7 * 8] = internal_mem_storage[addr + 7];
        end
        done = 1'b1;
        end
    end

endmodule
