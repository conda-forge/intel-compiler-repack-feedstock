"""Compare the symbols a runtime library exports with a recorded snapshot.

Consumers (MKL, oneDAL, ...) are built against one release and run against
whatever newer release of the same major the solver picks, so a symbol that
disappears in a minor release breaks them at load time. Each file in
abi/<PKG_NAME>/ is named after a library and lists the dynamic symbols it
defined in the release named on its first line ("# <version>").

A missing symbol fails the test while the package has the snapshot's major
version. A new major may drop symbols (its consumers are pinned below it),
so then missing symbols are only reported; record a new snapshot with
--write.

Usage: python check_symbols.py [--write [LIBRARY ...]]   (linux only)
LIBRARY names start a snapshot for a library that has none yet.
"""
import glob
import json
import os
import sys

from elftools.elf.elffile import ELFFile

prefix = os.environ.get("PREFIX", sys.prefix)
name = os.environ["PKG_NAME"]
snapdir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "abi", name)
write = "--write" in sys.argv

meta = next(json.load(open(m)) for m in glob.glob(os.path.join(prefix, "conda-meta", f"{name}-*.json"))
            if json.load(open(m))["name"] == name)
version = meta["version"]


def exported(path):
    with open(path, "rb") as f:
        dynsym = ELFFile(f).get_section_by_name(".dynsym")
        return {s.name for s in dynsym.iter_symbols()
                if s.name and s["st_shndx"] != "SHN_UNDEF"
                and s["st_info"]["bind"] in ("STB_GLOBAL", "STB_WEAK")}


snaps = sorted(glob.glob(os.path.join(snapdir, "*")))
if write and sys.argv[2:]:
    os.makedirs(snapdir, exist_ok=True)
    snaps = [os.path.join(snapdir, lib) for lib in sys.argv[2:]]
assert snaps, f"no snapshots in {snapdir}"
failed = False
for snap in snaps:
    lib = os.path.basename(snap)
    now = exported(os.path.join(prefix, "lib", lib))
    if write:
        with open(snap, "w") as f:
            f.write(f"# {version}\n" + "".join(s + "\n" for s in sorted(now)))
        print(f"wrote {lib}: {len(now)} symbols")
        continue
    lines = open(snap).read().splitlines()
    base, recorded = lines[0][2:], set(lines[1:])
    missing, added = sorted(recorded - now), now - recorded
    strict = base.split(".")[0] == version.split(".")[0]
    print(f"{lib}: {len(now)} symbols, {len(added)} new, {len(missing)} missing vs {base}")
    for s in missing:
        print("  missing", s)
    if missing and strict:
        failed = True
    elif missing:
        print(f"  {version} is a new major after {base}: not failing, refresh with --write")

if failed:
    sys.exit("symbols were removed in a minor release; consumers built against the snapshot release will not load")
