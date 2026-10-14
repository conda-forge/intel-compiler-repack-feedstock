@echo off
setlocal EnableDelayedExpansion

echo Testing DPC++ activation hook

rem conda-build provides PREFIX but does not source conda activate hooks.
rem Emulate an activated environment before calling the hook directly.
set "CONDA_PREFIX=%PREFIX%"

rem In a recipe build the compiler sits in BUILD_PREFIX, whose Library\lib is not on LIB.
rem Reproduce that by dropping this prefix from LIB, so the link below only succeeds if
rem the activation hook supplies the compiler's own library directory.
set "COMPILER_LIB=%PREFIX%\Library\lib"
set "LIB=!LIB:%COMPILER_LIB%=!"
set "LIB_BEFORE=!LIB!"

call "%PREFIX%\etc\conda\activate.d\z-activate-dpcpp.bat"
echo LIB=!LIB!
if "!LIB:%COMPILER_LIB%=!"=="!LIB!" (
  echo Activation did not add %COMPILER_LIB% to LIB
  exit /b 1
)

icpx -fsycl simple.cpp -o simple_activation.exe
if errorlevel 1 (
  echo Linking with the activated LIB failed
  exit /b 1
)

call "%PREFIX%\etc\conda\deactivate.d\z-deactivate-dpcpp.bat"
if not "!LIB!"=="!LIB_BEFORE!" (
  echo Deactivation did not restore LIB
  exit /b 1
)
