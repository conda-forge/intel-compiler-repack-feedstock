@echo on

set "src=%SRC_DIR%\%PKG_NAME%"

pushd %SRC_DIR%
  FOR /F "usebackq tokens=1" %%i IN (`DIR /S/B *.conda` ) DO (
    echo "Converting .conda to .tar.bz2"
    cph transmute %%i .tar.bz2
    del %%i
  )

  FOR /F "usebackq tokens=1" %%i IN (`DIR /S/B *.tar.bz2` ) DO (
    echo "Extracting .tar.bz2"
    cph extract %%i --dest %%i\..
    del %%i
  )
popd

:: TODO: do we need compiler_shared as a separate package? Is there any other use
:: except dpcpp_impl_linux-64 ? May be there are some conda forge pacakges we can
:: link to.
if "%PKG_NAME%" == "dpcpp_impl_win-64" (
  rmdir /s /q %SRC_DIR%\compiler_shared\info
  xcopy /E %SRC_DIR%\compiler_shared %src%
)

if "%PKG_NAME%" == "ifx_impl_win-64" (
  rmdir /s /q %SRC_DIR%\compiler_shared\info
  xcopy /E %SRC_DIR%\compiler_shared %src%
)

robocopy /E "%src%" "%PREFIX%"
if %ERRORLEVEL% GEQ 8 exit 1

:: replace old info folder with our new regenerated one
rd /s /q %PREFIX%\info
