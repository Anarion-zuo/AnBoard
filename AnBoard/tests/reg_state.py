import os
import io
import re

class RegisterState(object):
    def __init__(self, dump_file_path: str = None):
        self.regs_ = [0 for i in range(2**5)]
        self.dump_file_path = ""
        if dump_file_path is None:
            self.dump_file_path = "out/reg_state.out"
        else:
            self.dump_file_path = dump_file_path
            self.update_by_dump()

    def update_by_dump_fio(self, dumped_file_buffer: io.BufferedReader):
        p = re.compile(r"x[ ]*([0-9]+):[\t ]+0x([0-9a-fA-F]+)")
        while True:
            line = dumped_file_buffer.readline()
            if len(line) == 0:
                break
            x = p.findall(line)
            if x is None:
                continue
            self.regs_[int(x[0][0])] = int(x[0][1], 16)

    def update_by_dump(self):
        file = open(self.dump_file_path, "r")
        self.update_by_dump_fio(file)
        file.close()

    def print(self):
        for i in range(len(self.regs_)):
            print("x" + str(i), hex(self.regs_[i]))

    def dump_to_memfile(self, file_buffer: io.BufferedWriter):
        for reg in self.regs_:
            out_list = []
            hex_str = hex(reg)[2:]
            hex_str = hex_str.zfill(16)
            for i in range(8):
                out_list.append(hex_str[i * 2 : i * 2 + 2])
            for i in range(8):
                file_buffer.write(out_list[i])
            file_buffer.write('\n')

    @staticmethod
    def equals(x, expect) -> bool:
        length = len(x.regs_)
        if length != len(expect.regs_):
            return False
        result = True
        for i in range(length):
            if x.regs_[i] != expect.regs_[i]:
                result = False
                print("==diff reg", str(i), "expected: " + hex(expect.regs_[i]), "got: " + hex(x.regs_[i]))
        return result
