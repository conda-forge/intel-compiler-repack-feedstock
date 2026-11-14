# Runtime tests

The recipe only repacks Intel's binaries, so a successful build says nothing
about whether they work. These scripts are used by the `test:` sections of
the outputs in `meta.yaml`.

| Script | What it catches |
|---|---|
| `load_libs.py` | a library that cannot be loaded: a file or dependency missing from the package, a wrong DLL name, an undefined symbol between runtime packages |
| `check_symbols.py` | a symbol removed from a runtime library in a minor release (consumers built against the previous release stop loading) |
| `check_run_exports.py` | a run_exports pin that does not match the package version, which gives consumers a wrong lower bound |

`dpcpp-cpp-rt` also loads consumers built against an earlier release of the
same major (`onemkl-sycl-blas`, `dal-gpu`) against the new runtime.

## On a new major release

Consumers of the previous major are pinned below the new one, so:

- the consumer check is switched off automatically for `x.0.*` versions
  (`check_consumers` at the top of `meta.yaml`); set it to `False` by hand if
  a minor release cannot be solved with earlier consumers for another reason;
- `check_symbols.py` reports missing symbols without failing when the
  snapshot is from another major. Refresh the snapshots after checking the
  report:

  ```
  PKG_NAME=intel-sycl-rt PREFIX=<env> python recipe/tests/check_symbols.py --write
  ```

  for each package that has a directory in `abi/`, with that package of the
  new release installed in `<env>`.
