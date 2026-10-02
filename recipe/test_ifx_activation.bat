@echo off
setlocal EnableDelayedExpansion

echo Testing IFX activation hook

rem conda-build provides PREFIX but does not source conda activate hooks.
rem Emulate an activated environment before calling the hook directly.
set "CONDA_PREFIX=%PREFIX%"

rem Verify activation preserves caller flags and supplies the absolute module path.
set "FFLAGS=-DIFX_FFLAGS_SENTINEL"
call "%PREFIX%\etc\conda\activate.d\z-activate-ifx.bat"
echo FFLAGS=!FFLAGS!
if not exist "%CONDA_PREFIX%\opt\compiler\include\intel64\iso_fortran_env.modintr" (
  echo Missing intrinsic module under %CONDA_PREFIX%
  exit /b 1
)
if "!FFLAGS:-DIFX_FFLAGS_SENTINEL=!"=="!FFLAGS!" (
  echo Activation discarded caller-provided FFLAGS
  exit /b 1
)
set "MODULE_DIR=%CONDA_PREFIX%\opt\compiler\include\intel64"
if "!FFLAGS:%MODULE_DIR%=!"=="!FFLAGS!" (
  echo Activation did not add the intrinsic module directory
  exit /b 1
)

ifx !FFLAGS! simple.f90 -o simple.exe && simple.exe
