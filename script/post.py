import os, sys
import shutil
from pprint import pprint
import frontmatter
import PyPDF2

args = sys.argv
print("POST SCRIPT")

main_path = args[1]
pdf_path = args[2]
out_path = args[3]

# Add cover
fm = frontmatter.load(main_path).metadata
if ("cover" in fm):
  cover_path = os.path.join(os.path.dirname(main_path), fm["cover"])
  print("Merge " + pdf_path + " + " + cover_path + " -> " + out_path + ".")
  merger = PyPDF2.PdfFileMerger()
  merger.append(cover_path)
  merger.append(pdf_path)
  merger.write(out_path)
  merger.close()
else:
  print("Copy " + pdf_path + " -> " + out_path + ".")
  shutil.copyfile(pdf_path, out_path)
