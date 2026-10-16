set "FC=ifx"
rem Resolve the prefix this script was installed into (<prefix>\etc\conda\activate.d), so the
rem paths below point at the compiler's env without depending on CONDA_PREFIX.
for %%I in ("%~dp0..\..\..") do set "_IFX_COMPILER_PREFIX=%%~fI"
rem ifx intrinsic Fortran modules are shipped by ifx_impl in the compiler's prefix.
rem Preserve caller-provided flags and use an absolute path so activation is CWD-independent.
set "FFLAGS=%FFLAGS% -I"%_IFX_COMPILER_PREFIX%\opt\compiler\include\intel64""
rem ifx resolves its runtime import libraries (libifcoremt.lib, libircmt.lib, ...) only through
rem LIB. When building a recipe the compiler lives in BUILD_PREFIX, but the VS activation only
rem puts the host prefix on LIB. Append the compiler's Library\lib, so libraries from the host
rem prefix keep precedence. The whole directory becomes a fallback search path, so a library
rem missing from the host prefix but present in the compiler's env still resolves from there.
set "_CONDA_IFX_BACKUP_LIB=%LIB%"
set "_CONDA_IFX_LIB_SET=1"
set "LIB=%LIB%;%_IFX_COMPILER_PREFIX%\Library\lib"
set "_IFX_COMPILER_PREFIX="
