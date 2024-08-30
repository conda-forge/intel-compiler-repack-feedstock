import platform
import os

if platform.system() == "Windows":
    import sys
    if len(sys.argv) !=2:
        print("Expecting 1 argument to be path to cl.cfg")
        sys.exit(1)
    f_name = sys.argv[1]
    with open(f_name, 'r') as fh:
        cl_content = fh.readlines()
    with open(f_name, 'w') as fh:
        for line in cl_content:
            if line.startswith("CL_CONFIG_TBB_DLL_PATH"):
                fh.write(f"CL_CONFIG_TBB_DLL_PATH = {os.environ['PREFIX']}\\Library\\bin\n")
            else:
                fh.write(line)
