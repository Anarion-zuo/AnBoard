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

    @staticmethod
    def equals(x, y) -> bool:
        length = len(x.regs_)
        if length != len(y.regs_):
            return False
        for i in range(length):
            if x.regs_[i] != y.regs_[i]:
                return False
        return True
