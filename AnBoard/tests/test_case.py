from ast import Assert
from importlib import import_module
from sre_constants import ASSERT
from reg_state import RegisterState
import make_instr_mem_hex
import os


class TestCase:
    def __init__(self, name) -> None:
        self.name = name
        self.reg_state = RegisterState()
        self.expected_reg_state = RegisterState("tests/" + self.name + "/expected_reg_state.txt")

    def run_test(self) -> bool:
        make_instr_mem_hex.make_mem_hex(self.name)
        print("==simulation begins==")
        simulate_path = "AnBoard.sim\\sim_1\\behav\\xsim\\"
        cur_path = os.getcwd()
        os.chdir(simulate_path)
        os.system("call xvlog  --incr --relax -prj RISCV_vlog.prj -log xvlog.log")
        os.system("call xelab  --incr --debug typical --relax --mt 2 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot RISCV_behav xil_defaultlib.RISCV xil_defaultlib.glbl -log elaborate.log")
        os.system("call xsim  RISCV_behav -key {Behavioral:sim_1:Functional:RISCV} -tclbatch RISCV.tcl -log simulate.log")
        os.chdir(cur_path)
        print("==simulation ends==")
        self.reg_state.update_by_dump()
        if not RegisterState.equals(self.reg_state, self.expected_reg_state):
            print("==reg state not as expected==")
            return False
        else:
            print("==reg state as expected==")
            return True


for case in ["addi"]:
    test_case = TestCase(case)
    ok = test_case.run_test()
    if not ok:
        raise Exception("test case failed at <" + case + ">")
