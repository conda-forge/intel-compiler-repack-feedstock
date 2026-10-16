set "CC=icx"
set "CXX=icx"
rem icx resolves its own runtime import libraries (libircmt.lib, libmmt.lib, ...) only
rem through LIB, which oneAPI's setvars.bat normally provides. When building a recipe the
rem compiler lives in BUILD_PREFIX, but the VS activation only puts the host prefix on LIB.
rem Find the prefix relative to this script (<prefix>\etc\conda\activate.d) so it does not
rem depend on CONDA_PREFIX, and append so libraries from the host prefix keep precedence.
rem The whole compiler Library\lib becomes a fallback search path, so a library missing
rem from the host prefix but present in the compiler's env still resolves from there.
for %%I in ("%~dp0..\..\..") do set "_DPCPP_COMPILER_PREFIX=%%~fI"
set "_CONDA_DPCPP_BACKUP_LIB=%LIB%"
set "_CONDA_DPCPP_LIB_SET=1"
set "LIB=%LIB%;%_DPCPP_COMPILER_PREFIX%\Library\lib"
set "_DPCPP_COMPILER_PREFIX="
