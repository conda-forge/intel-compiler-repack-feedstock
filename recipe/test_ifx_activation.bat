@echo off
setlocal EnableDelayedExpansion

echo Testing IFX activation hook

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
set "_CONDA_IFX_LIB_SET="
set "_CONDA_IFX_BACKUP_LIB="
call "%PREFIX%\etc\conda\deactivate.d\z-deactivate-ifx.bat"
if not "!LIB!"=="!LIB_BEFORE!" (
  echo Deactivation without activation changed LIB
  exit /b 1
)

rem The stripped LIB must actually reproduce the failure, otherwise the link below would
rem pass without exercising the hook. Pass the module path so only the link step can fail.
ifx -I"%PREFIX%\opt\compiler\include\intel64" simple.f90 -o simple_no_activation.exe >nul 2>&1
if not errorlevel 1 (
  echo Linking without the activation hook unexpectedly succeeded
  exit /b 1
)

rem Verify activation preserves caller flags and supplies the absolute module path.
set "FFLAGS=-DIFX_FFLAGS_SENTINEL"
call "%PREFIX%\etc\conda\activate.d\z-activate-ifx.bat"
echo FFLAGS=!FFLAGS!
echo LIB=!LIB!
if "!LIB:%COMPILER_LIB%=!"=="!LIB!" (
  echo Activation did not add %COMPILER_LIB% to LIB
  exit /b 1
)
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
if errorlevel 1 exit /b 1

call "%PREFIX%\etc\conda\deactivate.d\z-deactivate-ifx.bat"
if not "!LIB!"=="!LIB_BEFORE!" (
  echo Deactivation did not restore LIB
  exit /b 1
)
