`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2022 06:06:45 PM
// Design Name: 
// Module Name: Controller
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

`define dump_regs(REGFILE) \
    $display("=======================");\
    for (integer i = 0; i < 32; i = i + 1) begin\
        $display("1:\t0x%h", REGFILE.regs[i]);\
    end\
    $display("=======================");


module Controller(
    input[31:0] instr
    );

    localparam OP_IMM = 5'b00100,
               OP = 5'b01100;

    // decode
    wire[6:0] opcode;
    wire[2:0] funct3;
    wire[6:0] funct7;
    wire[4:0] register_dest;
    wire[4:0] register_src_1;
    wire[4:0] register_src_2;
    wire[20:0] imm_val;
    // alu
    reg[63:0] aluS1;
    reg[63:0] aluS2;
    reg[3:0] aluOp;
    wire [63:0] alu_out;
    wire alu_eflags;
    wire alu_zf, alu_of, alu_cf, alu_sf;
    // register file
    reg reg_we = 1'b0;
    reg [63:0] reg_write_data;
    wire [63:0] reg_read_data1, reg_read_data2;

    RegisterFile registerFile(
        .we(reg_we),
        .addr1(register_src_1),
        .addr2(register_src_1),
        .write_addr(register_dest),
        .write_data(alu_out),
        .read_data1(reg_read_data1),
        .read_data2(reg_read_data2)
    );

    ALU alu(
        .s1(aluS1),
        .s2(aluS2),
        .aluOp(aluOp),
        .out_reg(alu_out),
        .zf(alu_zf),
        .of(alu_of),
        .sf(alu_sf),
        .cf(alu_cf)
    );

    // decode
    InstrDecoder decoder(
        .instr(instr),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .register_dest(register_dest),
        .register_src_1(register_src_1),
        .register_src_2(register_src_2),
        .imm_val(imm_val)
    );

    // read register
    // automatically done

    // execute alu
    always @(opcode or funct3 or funct7) begin
        reg_we = 1'b0;
        case (opcode[6:2])
            OP_IMM: begin
                // arith with immediate values
                $display("opcode OP_IMM");
                aluS1 = reg_read_data1;
                aluS2 = imm_val;
                case (funct3)
                    3'b000: begin
                        aluOp = ALU.ADD;
                    end
                    3'b100: begin
                        aluOp = ALU.XOR;
                    end
                    3'b110: aluOp = ALU.OR;
                    3'b111: aluOp = ALU.AND;
                    3'b010: begin
                        aluOp = ALU.SLT;
                    end
                    default: $display("unkown funct3 0b%b", funct3);
                endcase
                reg_we = 1'b1;
            end
            OP: begin
                // arith with regs
            end
            default: $display("unknow opcode 0x%h", opcode);
        endcase
    end

    // write back
    // automatically done
    always @(register_dest) begin
        `dump_regs(registerFile)
    end

endmodule
