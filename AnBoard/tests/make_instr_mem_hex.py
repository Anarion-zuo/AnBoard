#! /usr/bin/python3
import sys
import re
import subprocess
import io
import os

casename = sys.argv[1]
# casename = "tests/addi"
print("creating hex memfile for test case <" + casename +">")
compiled_out = ""
proc1 = os.system("clang --target=riscv64 -march=rv64gc " + casename + ".asm -c -o " + casename + ".compiled")
proc2 = os.popen("riscv64-unknown-elf-objdump -d " + casename + ".compiled")
objdump_out = proc2.read()
os.remove(casename + ".compiled")
f = io.StringIO(objdump_out)

os.remove(casename + ".mem")
out_file = open(casename + ".mem", 'a')
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
        out_file.write(byte_list[3 - i] + ' ')
    out_file.write('\n')
out_file.close()
