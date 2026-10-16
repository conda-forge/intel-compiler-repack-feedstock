@echo off
setlocal EnableDelayedExpansion

echo Testing DPC++ activation hook

rem conda-build activates the test env before running this script; set CONDA_PREFIX
rem explicitly so the direct hook calls below do not depend on that.
set "CONDA_PREFIX=%PREFIX%"

rem In a recipe build the compiler sits in BUILD_PREFIX, whose Library\lib is not on LIB.
rem Reproduce that by dropping this prefix from LIB, so the link below only succeeds if
rem the activation hook supplies the compiler's own library directory.
set "COMPILER_LIB=%PREFIX%\Library\lib"
set "LIB=!LIB:%COMPILER_LIB%=!"
set "LIB_BEFORE=!LIB!"

rem Deactivating without a prior activation (package installed into an already active
rem env) must leave LIB alone. The test env has already been activated, which ran this
rem hook, so clear its state first.
set "_CONDA_DPCPP_LIB_SET="
set "_CONDA_DPCPP_BACKUP_LIB="
call "%PREFIX%\etc\conda\deactivate.d\z-deactivate-dpcpp.bat"
if not "!LIB!"=="!LIB_BEFORE!" (
  echo Deactivation without activation changed LIB
  exit /b 1
)

rem The stripped LIB must actually reproduce the failure, otherwise the check below
rem would pass without exercising the hook.
icpx -fsycl simple.cpp -o simple_no_activation.exe >nul 2>&1
if not errorlevel 1 (
  echo Linking without the activation hook unexpectedly succeeded
  exit /b 1
)

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
