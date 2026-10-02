set "FC=ifx"
rem ifx intrinsic Fortran modules are shipped by ifx_impl under CONDA_PREFIX.
rem Preserve caller-provided flags and use an absolute path so activation is CWD-independent.
set "FFLAGS=%FFLAGS% -I"%CONDA_PREFIX%\opt\compiler\include\intel64""
