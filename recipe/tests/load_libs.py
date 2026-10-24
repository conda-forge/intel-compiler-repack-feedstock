"""Load every shared library a package installs.

A repack copies files without linking anything, so a library whose
dependencies are missing from the package's run requirements (or whose
symbols are missing from the runtime it needs) only fails when a user
loads it.

Libraries are loaded with global visibility and retried until a pass makes
no progress; whatever is left cannot be loaded in any order. Libraries
matching a SKIP substring need something the test environment does not
provide (a GPU driver, MPI). A +LIBRARY argument (relative to the library
directory) is loaded too, in the same retry loop, for libraries that take
symbols from something the application loads first.

The package is PKG_NAME (the output under test) unless --pkg=NAME is
given, which is how consumers built against an older release are loaded
against the runtime being tested.

Usage: python load_libs.py [--pkg=NAME] [+LIBRARY ...] [SKIP_SUBSTRING ...]
"""
import ctypes
import glob
import json
import os
import sys

WIN = sys.platform == "win32"
prefix = os.path.normpath(os.environ.get("PREFIX", sys.prefix))
args = sys.argv[1:]
name = next((a[6:] for a in args if a.startswith("--pkg=")), os.environ.get("PKG_NAME"))
args = [a for a in args if not a.startswith("--pkg=")]
skip = [a for a in args if not a.startswith("+")]
preload = [a[1:] for a in args if a.startswith("+")]

metas = [m for m in glob.glob(os.path.join(prefix, "conda-meta", f"{name}-*.json"))
         if json.load(open(m))["name"] == name]
assert len(metas) == 1, f"conda-meta for {name}: {metas}"
meta = json.load(open(metas[0]))
print(f"{name} {meta['version']} {meta['build']}")
files = meta["files"]

if WIN:
    os.add_dll_directory(os.path.join(prefix, "Library", "bin"))
    libs = [os.path.normpath(f) for f in files if f.lower().endswith(".dll")]
    mode = 0
else:
    # every real consumer is a C++ program that already has the C++ runtime loaded
    ctypes.CDLL(os.path.join(prefix, "lib", "libstdc++.so.6"), mode=ctypes.RTLD_GLOBAL)
    libs = [f for f in files if ".so" in os.path.basename(f)]
    mode = os.RTLD_LAZY | os.RTLD_GLOBAL

assert libs, f"{name} installs no shared libraries"

libdir = os.path.join("Library", "bin") if WIN else "lib"
pending = [os.path.join(libdir, lib) for lib in preload]
for lib in sorted(libs):
    path = os.path.join(prefix, lib)
    if any(s in os.path.basename(lib) for s in skip):
        print("skip", lib)
    elif not os.path.exists(path):
        # unversioned dev links into another package's -devel files
        print("skip", lib, "(dangling link)")
    elif not WIN and open(path, "rb").read(4) != b"\x7fELF":
        # linker scripts (INPUT(libfoo.so.5)) and gdb pretty-printers
        print("skip", lib, "(not ELF)")
    else:
        pending.append(lib)

errors = {}
progress = True
while pending and progress:
    progress = False
    for lib in list(pending):
        try:
            ctypes.CDLL(os.path.join(prefix, lib), mode=mode)
        except OSError as e:
            errors[lib] = e
        else:
            print("ok  ", lib)
            pending.remove(lib)
            progress = True

for lib in pending:
    print("FAIL", lib, errors[lib])
if pending:
    sys.exit(f"{len(pending)} of {len(libs)} libraries failed to load: {pending}")
