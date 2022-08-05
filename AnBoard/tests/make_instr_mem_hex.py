#! /usr/bin/python3
from fileinput import filename
import sys
import re
import subprocess
import io
import os
import platform

def make_mem_hex(casename: str):
    print("creating hex memfile for test file <" + casename +">")

    rv_objdump_path = ""
    rv_as_path = ""
    if platform.system() == "Windows":
        rv_objdump_path = "C:/SysGCC/risc-v/bin/riscv64-unknown-elf-objdump"
        rv_as_path = "C:/SysGCC/risc-v/bin/riscv64-unknown-elf-as"
    else:
        rv_objdump_path = "riscv64-unknown-elf-objdump"
        rv_as_path = "riscv64-unknown-elf-as"

    print("presently on", platform.system())
    print("objdump path:", rv_objdump_path)
    print("as path:", rv_as_path)

    path_prefix = "tests/"
    file_prefix = casename
    file_name = path_prefix + file_prefix
    mem_out_path = "out/instr.mem"
    print("working on files", file_name + '.*')

    print("running as...")
    proc1 = os.system(rv_as_path + ' ' + file_name + ".asm -o " + file_name + ".o")
    print("running objdump")
    proc2 = os.popen(rv_objdump_path + " -d " + file_name + ".o")
    objdump_out = proc2.read()
    os.remove(file_name + ".o")
    f = io.StringIO(objdump_out)

    print("generating mem file")
    try:
        os.remove(mem_out_path)
    except:
        pass
    out_file = open(mem_out_path, 'x')
    instr_count = 0
    while True:
        line = f.readline()
        if len(line) == 0:
            break
        regex = ":\t[0-9a-fA-F]{8}"
        x = re.search(regex, line)
        if x is None:
            continue
        mem_line = x[0][2:]
        print(line[:-1])
        print(bin(int(mem_line, 16)))
        byte_list = []
        for i in range(4):
            byte_list.append(mem_line[i * 2 : i * 2 + 2])
        for i in range(4):
            out_file.write(byte_list[3 - i] + '\n')
        # out_file.write('\n')
        instr_count += 1
    out_file.close()
    print("mem file generated")
    out_instr_count_file = open("out/instr_count.in", 'w')
    out_instr_count_file.write(str(instr_count))
    out_instr_count_file.close()
