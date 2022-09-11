import sys
import shutil

print("POST SCRIPT")

args = sys.argv

shutil.copyfile(args[1], args[2])
