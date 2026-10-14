set "FC=ifx"
rem ifx intrinsic Fortran modules are shipped by ifx_impl under CONDA_PREFIX.
rem Preserve caller-provided flags and use an absolute path so activation is CWD-independent.
set "FFLAGS=%FFLAGS% -I"%CONDA_PREFIX%\opt\compiler\include\intel64""
rem ifx resolves its runtime import libraries (libifcoremt.lib, libircmt.lib, ...) only through
rem LIB. When building a recipe the compiler lives in BUILD_PREFIX, but the VS activation only
rem puts the host prefix on LIB. Append the prefix this script was installed into, so libraries
rem from the host prefix keep precedence.
for %%I in ("%~dp0..\..\..") do set "_IFX_COMPILER_PREFIX=%%~fI"
set "_CONDA_IFX_BACKUP_LIB=%LIB%"
set "LIB=%LIB%;%_IFX_COMPILER_PREFIX%\Library\lib"
set "_IFX_COMPILER_PREFIX="
