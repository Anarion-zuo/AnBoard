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

module Controller(
    );
`define dump_regs(REGFILE) \
    $display("=======================");\
    for (integer i = 0; i < 32; i = i + 1) begin\
        $display("x%d:\t0x%h", i, REGFILE.regs[i]);\
    end\
    $display("=======================");

`define dump_regs_tofile(REGFILE) \
    $display("---begin reg file dump tofile---");\
    temp = $fseek(dump_reg_state_fd, 0, 0);\
    for (integer i = 0; i < 32; i = i + 1) begin\
        $fdisplay(dump_reg_state_fd, "x%d:\t0x%h", i, REGFILE.regs[i]);\
    end\
    $fflush(dump_reg_state_fd);\
    $display("---end reg file dump tofile---");

    localparam OP_IMM = 5'b00100,
               OP = 5'b01100;
    integer dump_reg_state_fd, temp, instr_count, instr_count_fd, cur_instr_count;

    RegMemory instr_mem(
        .addr(instr_ptr),
        .we(1'b0)
    );

    initial begin
        dump_reg_state_fd = $fopen("../../../../out/reg_state.out", "w");

        instr_count_fd = $fopen("../../../../out/instr_count.in", "r");
        instr_count = 0;
        temp = $fscanf(instr_count_fd, "%d", instr_count);
        instr_ptr = 0;
        next_cycle = 1'b1;
        // for (cur_instr_count = 0; cur_instr_count < instr_count; cur_instr_count = cur_instr_count + 1) begin
            // $display("---instr\ %d---", cur_instr_count);
            // if (^instr === 1'bx) begin
            //     $display("---undefined instr---");
            //     $finish;
            // end
        //     #10;
        //     instr_ptr = instr_ptr + 4;
        // end
        // $display("---executed %d instructions---", instr_count);
        // $finish;
    end

    reg[31:0] instr;
    reg[63:0] instr_ptr;
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
    // reg reg_we;
    reg [63:0] reg_write_data;
    wire [63:0] reg_read_data1, reg_read_data2;

    RegisterFile registerFile(
        // .we(reg_we),
        .addr1(register_src_1),
        .addr2(register_src_2),
        .write_addr(register_dest),
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

    // fetch instruction
    reg instr_fetched = 1'b0;
    reg next_cycle = 1'b0, instr_fetch_issued = 1'b0;
    always @(next_cycle) begin
        // fetch instr
        if (next_cycle === 1'b1) begin
        next_cycle = 1'b0;
        instr_mem.launch = 1'b1;
        instr_fetch_issued = 1'b1;
        end
    end
    always @(instr_fetch_issued or instr_mem.done) begin
        // intr fetched
        if (instr_fetch_issued === 1'b1 && instr_mem.done === 1'b1) begin
        instr_fetch_issued = 1'b0;
        instr_mem.done = 1'b0;
        instr = instr_mem.data_reg[31:0];
        instr_fetched = 1;
        end
    end

    // read register
    always @(instr_fetched) begin
        if (instr_fetched == 1'b1) begin
        instr_fetched = 1'b0;
        registerFile.re = 1'b1;
        registerFile.we = 1'b0;
        registerFile.launch = 1'b1;
        end
    end
    // setup alu operands
    reg alu_operand_ready = 1'b0, is_valid_instr = 1'b1, aluout_write_regfile = 1'b0;
    always @(registerFile.done) begin
        if (registerFile.done == 1'b1) begin
        case (opcode[6:2])
            OP_IMM: begin
                // arith with immediate values
                aluS1 = registerFile.read_data1;
                aluS2 = imm_val;
                aluout_write_regfile = 1'b1;
            end
            OP: begin
                // arith with regs
                aluS1 = registerFile.read_data1;
                aluS2 = registerFile.read_data2;
                aluout_write_regfile = 1'b1;
            end
            default: begin
                $display("unknow opcode 0x%h", opcode);
                is_valid_instr = 1'b0;
            end
        endcase
        if (is_valid_instr == 1'b1) alu_operand_ready = 1'b1;
        is_valid_instr = 1'b1;
        end
    end

    reg alu_opcode_ready = 1'b0;
    // setup alu arith type
    always @(registerFile.done) begin
        if (registerFile.done == 1'b1) begin
        case (funct3)
            3'b000: begin
                if (imm_val[11:6] == 6'b010000) begin
                    if (opcode[6:2] == OP_IMM) aluS2[11:6] = 1'b0;
                    aluOp = ALU.SUB;
                end else aluOp = ALU.ADD;
            end
            3'b010: aluOp = ALU.SLT;
            3'b100: aluOp = ALU.XOR;
            3'b110: aluOp = ALU.OR;
            3'b111: aluOp = ALU.AND;
            // shifts
            3'b001: aluOp = ALU.SLL;
            3'b101: begin
                if (imm_val[11:6] == 6'b010000) begin
                    if( opcode[6:2] == OP_IMM) aluS2[11:6] = 1'b0;
                    aluOp = ALU.SRA;
                end else aluOp = ALU.SRL;
            end
            default: begin
                $display("unkown funct3 0b%b", funct3);
                is_valid_instr = 1'b0;
            end
        endcase
        end
        alu_opcode_ready = 1'b1;
    end

    // execute alu
    always @(alu_opcode_ready or alu_operand_ready) begin
        if (alu_opcode_ready === 1'b1 && alu_operand_ready === 1'b1) begin
        registerFile.done = 1'b0;
        registerFile.re = 1'b0;
        alu_opcode_ready = 1'b0;
        alu_operand_ready = 1'b0;
        alu.launch = 1'b1;
        end
    end

    // write back
    reg instr_regs_written = 1'b0;
    always @(alu.done) begin
        if (alu.done === 1'b1) begin
        alu.done = 1'b0;
        if (aluout_write_regfile == 1'b1) begin
            registerFile.write_data = alu_out;
            registerFile.we = 1'b1;
            aluout_write_regfile = 1'b0;
            registerFile.launch = 1'b1;
        end
        instr_regs_written = 1'b1;
        end
    end

    // cycle done
    always @(instr_regs_written or registerFile.done) begin
        if (instr_regs_written === 1'b1 && registerFile.done === 1'b1) begin
        instr_regs_written = 1'b0;
        registerFile.done = 1'b0;
        registerFile.we = 1'b0;
        registerFile.re = 1'b0;
        `dump_regs(registerFile)
        `dump_regs_tofile(registerFile)

        instr_ptr = instr_ptr + 4;
        next_cycle = 1'b1;

        end
    end

endmodule
