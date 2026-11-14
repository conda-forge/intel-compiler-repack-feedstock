"""Check that a package's run_exports pin each named runtime at the version
installed next to it.

A consumer gets its lower bound on the runtime from these pins, so a pin left
at an older version lets the solver pair the consumer with a runtime that
lacks symbols it needs.

Usage: python check_run_exports.py RUNTIME [RUNTIME ...]
"""
import glob
import json
import os
import sys

prefix = os.environ.get("PREFIX", sys.prefix)


def meta(name):
    found = [m for m in (json.load(open(p)) for p in glob.glob(os.path.join(prefix, "conda-meta", f"{name}-*.json")))
             if m["name"] == name]
    assert len(found) == 1, f"conda-meta for {name}: {len(found)} entries"
    return found[0]


pkg = meta(os.environ["PKG_NAME"])
pkgdir = pkg.get("extracted_package_dir")
assert pkgdir, "conda-meta has no extracted_package_dir"
with open(os.path.join(pkgdir, "info", "run_exports.json")) as f:
    exports = json.load(f)
print(json.dumps(exports, indent=1))
specs = {s.split()[0]: s for kind in exports.values() for s in kind}

errors = []
for runtime in sys.argv[1:]:
    version = meta(runtime)["version"]
    spec = specs.get(runtime)
    if spec is None:
        errors.append(f"{runtime} is not exported")
        continue
    constraint = spec.split()[1]
    if constraint.startswith(">="):
        lower, _, upper = constraint[2:].partition(",")
        ok = lower == version and upper == f"<{int(version.split('.')[0]) + 1}.0a0"
    else:
        ok = constraint.lstrip("=") == version
    print("ok  " if ok else "FAIL", spec, f"(installed {version})")
    if not ok:
        errors.append(spec)

if errors:
    sys.exit(f"wrong run_exports: {errors}")
