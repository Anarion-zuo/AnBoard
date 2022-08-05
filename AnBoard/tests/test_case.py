from asyncio import subprocess
from fileinput import filename
from importlib import import_module
from sre_constants import ASSERT
from reg_state import RegisterState
import make_instr_mem_hex
import os
import platform
import subprocess


class TestCase:
    def __init__(self, name: str, obj_name_list: list = None) -> None:
        self.name = name
        self.reg_state = RegisterState()
        dir_path = "tests/" + self.name + "/"
        # self.expected_reg_state = RegisterState(dir_path + "expected_reg_state.txt")
        # file list for sequential test case checks
        # seperate asm files should be executed according to certain order specified by input or dict
        # each time an asm file is executed, reg state should be as specified
        self.obj_name_list = []
        if obj_name_list is not None:
            for obj_name in obj_name_list:
                if not (os.path.exists(dir_path + obj_name + '.in') and os.path.exists(dir_path + obj_name + '.asm')):
                    raise Exception("file does not exist for input object " + obj_name)
            self.obj_name_list = obj_name_list
        else:
            dir_list = os.listdir(dir_path)
            dir_list.sort()
            for file_name in dir_list:
                if os.path.isfile(dir_path + file_name) and file_name.endswith(".asm"):
                    obj_name = file_name[:-4]
                    self.obj_name_list.append(obj_name)
                    if not (os.path.exists(dir_path + obj_name + '.in') and os.path.isfile(dir_path + obj_name + ".in")):
                        raise Exception("asm file " + obj_name + " does not have corresponding reg state desc file")
        self.in_reg_states = []
        for obj_name in self.obj_name_list:
            self.in_reg_states.append(RegisterState(dir_path + obj_name + '.in'))


    def run_test(self) -> bool:
        print("==simulation begins==")
        simulate_path = "AnBoard.sim/sim_1/behav/xsim/"
        cur_path = os.getcwd()

        # different ways of launching system console
        run_prefix = ""
        if platform.system() == "Windows":
            run_prefix = "call"
        else:
            run_prefix = ""

        print("==initialize reg state==")
        self.reg_state.print()
        reg_next_state_file = open("out/reg_state.in", "w")
        self.reg_state.dump_to_memfile(reg_next_state_file)
        reg_next_state_file.close()

        os.chdir(simulate_path)
        
        for i in range(len(self.obj_name_list)):
            os.chdir(cur_path)
            # prepare instructions for this segment of input
            make_instr_mem_hex.make_mem_hex(self.name + '/' + self.obj_name_list[i])
            print("== running obj file " + self.obj_name_list[i] + " ==")
            os.chdir(simulate_path)
            # run simulation through system console command
            proc = subprocess.Popen(run_prefix + " xsim  RISCV_behav -key {Behavioral:sim_1:Functional:RISCV} -tclbatch RISCV.tcl -log simulate.log", shell=True, stdin=subprocess.PIPE)
            proc.communicate(input=b"quit\n")   # exit vivado after simulation ends
            proc.wait()   # wait for vivado to exit

            os.chdir(cur_path)

            self.reg_state.update_by_dump()
            if not RegisterState.equals(self.reg_state, self.in_reg_states[i]):
                print("==reg state after", self.obj_name_list[i], "not as expected==")
                return False
            else:
                print("==reg state after", self.obj_name_list[i], "as expected==")
            reg_next_state_file = open("out/reg_state.in", "w")
            self.reg_state.dump_to_memfile(reg_next_state_file)
            reg_next_state_file.close()

        print("==simulation ends==")
        return True

