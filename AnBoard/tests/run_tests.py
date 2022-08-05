from test_case import TestCase
import os
import platform


test_cases = [
    {
        "name": "addi",
        "objs": ["addi", "addi2"]
    },
    {
        "name": "ori"
    },
    {
        "name": "andi"
    },
    {
        "name": "xori"
    }
]

simulate_path = "AnBoard.sim/sim_1/behav/xsim/"
cur_path = os.getcwd()
run_prefix = ""
if platform.system() == "Windows":
    run_prefix = "call"
else:
    run_prefix = ""

# run console commands as vivado does
# compile & elaberate
os.chdir(simulate_path)
os.system(run_prefix + " xvlog  --incr --relax -prj RISCV_vlog.prj -log xvlog.log")
os.system(run_prefix + " xelab  --incr --relax --mt 2 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot RISCV_behav xil_defaultlib.RISCV xil_defaultlib.glbl -log elaborate.log")
os.chdir(cur_path)

for case in test_cases:
    test_case = TestCase(case['name'], case.get('objs'))
    ok = test_case.run_test()
    if not ok:
        raise Exception("test case failed at <" + case.name + ">")