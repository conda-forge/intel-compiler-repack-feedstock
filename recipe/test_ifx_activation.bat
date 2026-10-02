@echo off
setlocal EnableDelayedExpansion

rem Verify activation preserves caller flags and supplies the absolute module path.
set "FFLAGS=-DIFX_FFLAGS_SENTINEL"
call "%PREFIX%\etc\conda\activate.d\z-activate-ifx.bat"
echo !FFLAGS! | findstr /C:"-DIFX_FFLAGS_SENTINEL" >nul || exit /b 1
echo !FFLAGS! | findstr /C:"%PREFIX%\opt\compiler\include\intel64" >nul || exit /b 1

ifx !FFLAGS! simple.f90 -o simple.exe && simple.exe
