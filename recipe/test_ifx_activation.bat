@echo off
setlocal EnableDelayedExpansion

rem conda-build provides PREFIX but does not source conda activate hooks.
rem Emulate an activated environment before calling the hook directly.
set "CONDA_PREFIX=%PREFIX%"

rem Verify activation preserves caller flags and supplies the absolute module path.
set "FFLAGS=-DIFX_FFLAGS_SENTINEL"
call "%PREFIX%\etc\conda\activate.d\z-activate-ifx.bat"
echo !FFLAGS! | findstr /C:"-DIFX_FFLAGS_SENTINEL" >nul || exit /b 1
echo !FFLAGS! | findstr /C:"%PREFIX%\opt\compiler\include\intel64" >nul || exit /b 1

ifx !FFLAGS! simple.f90 -o simple.exe && simple.exe
