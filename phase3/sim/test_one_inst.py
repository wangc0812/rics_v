import os
import subprocess
import sys

def bin_to_mem(infile, outfile):
    binfile = open(infile, 'rb')
    binfile_content = binfile.read(os.path.getsize(infile))
    datafile = open(outfile, 'w')

    index = 0
    b0 = 0
    b1 = 0
    b2 = 0
    b3 = 0

    for b in  binfile_content:
        if index == 0:
            b0 = b
            index = index + 1
        elif index == 1:
            b1 = b
            index = index + 1
        elif index == 2:
            b2 = b
            index = index + 1
        elif index == 3:
            b3 = b
            index = 0
            array = []
            array.append(b3)
            array.append(b2)
            array.append(b1)
            array.append(b0)
            datafile.write(bytearray(array).hex() + '\n')

    binfile.close()
    datafile.close()

def list_binfiles(path):
    files = []
    list_dir = os.walk(path)
    for maindir, subdir, all_file in list_dir:
        for filename in all_file:
            apath = os.path.join(maindir, filename)
            if apath.endswith('.bin'):
                files.append(apath)

    return files

def compile():
    #获取上一级目录
    rtl_dir = os.path.abspath(os.path.join(os.getcwd(), ".."))
    # iverilog程序
    iverilog_cmd = ['iverilog']
    # 编译生成文件
    iverilog_cmd += ['-o', r'out.vvp']
    # 头文件(defines.v)路径
    iverilog_cmd += ['-I', rtl_dir + r'/rtl']

    # testbench文件
    iverilog_cmd.append(rtl_dir + r'/tb/tb.v')

    # 内核core
    iverilog_cmd.append(rtl_dir + r'/rtl/defines.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/pc_reg.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/if_id.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/id.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/id_ex.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/ex.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/regs.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/ctrl.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/ram.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/rom.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/debug_button_debounce.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/uart_debug.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/open_risc_v.v')
    # 通用utils
    iverilog_cmd.append(rtl_dir + r'/utils/dff_set.v')
    iverilog_cmd.append(rtl_dir + r'/utils/dual_ram.v')

    # 顶层soc
    iverilog_cmd.append(rtl_dir + r'/tb/open_risc_v_soc.v')

    # 编译
    process = subprocess.Popen(iverilog_cmd)
    process.wait(timeout=5)

def run_sim():
    # 1.编译rtl文件
    compile()
    # 2.运行
    vvp_cmd = [r'vvp']
    vvp_cmd.append(r'out.vvp')
    process = subprocess.Popen(vvp_cmd)
    try:
        process.wait(timeout=10)
    except subprocess.TimeoutExpired:
        print('!!!Fail, vvp exec timeout!!!')

def main(name = 'addi'):
    # 获取上一级路径
    rtl_dir = os.path.abspath(os.path.join(os.getcwd(), ".."))

    all_bin_files = list_binfiles(rtl_dir + r'/sim/generated/')

    for file in all_bin_files:
        if(file.find(name) != -1 and file.find('.bin') != -1):
            test_binfile = file

    # 文件名字
    out_mem = rtl_dir + r'/sim/generated/inst_data.txt'
    # bin 转 mem
    bin_to_mem(test_binfile, out_mem)
    # 运行仿真
    run_sim()
    # 获取波形
    # gtkwave_cmd = [r'gtkwave']
    # gtkwave_cmd.append(r'tb.vcd')
    # process = subprocess.Popen(gtkwave_cmd)

if __name__ == '__main__':
    sys.exit(main(sys.argv[1]))
