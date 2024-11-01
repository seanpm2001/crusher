import pathlib as pl
import subprocess as sp
from typing import List

# queue
# --- 00001
# ------- coverage
# ------------ *.profraw
# --- 00002
#


def get_profraws(path: pl.Path) -> List[pl.Path]:
    res = []
    for data_dir in path.iterdir():
        profraw_dir = data_dir / "coverage"
        for profraw in profraw_dir.iterdir():
            res.append(str(profraw))
    return res


queue = pl.Path("queue")
hangs = pl.Path("hangs")

res = get_profraws(queue) + get_profraws(hangs)
sp.run(["llvm-profdata", "merge", *res, "-o", "cov.profdata"])
with open("cov.info", "w") as info:
    sp.run(["llvm-cov", "export", "--format", "lcov", "-instr-profile", "cov.profdata", "../../../../build_cov/pdf_fuzzer"], stdout=info)

sp.run(["genhtml", "-o", "../../../html", "cov.info"])
