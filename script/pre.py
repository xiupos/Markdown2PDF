import sys
import shutil

print("PRE SCRIPT")

args = sys.argv

shutil.copyfile(args[1], args[2])
