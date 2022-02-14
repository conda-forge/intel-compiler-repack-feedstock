@echo on
mkdir "%LIBRARY_PREFIX%\intel-ocl-cpu"
set "src=%SRC_DIR%\%PKG_NAME%\Library\lib"
robocopy /E "%src%" "%LIBRARY_LIB%\intel-ocl-cpu"
if %ERRORLEVEL% GEQ 8 exit 1

mkdir "%LIBRARY_PREFIX%\etc\OpenCL\vendors\"
echo %LIBRARY_LIB%\intel-ocl-cpu\intelocl64.dll> %LIBRARY_PREFIX%\etc\OpenCL\vendors\intel-ocl-cpu.icd


:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
FOR %%F IN (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d MKDIR %PREFIX%\etc\conda\%%F.d
    if errorlevel 1 exit 1
    copy %RECIPE_DIR%\opencl-win-%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
	:: We also copy .sh scripts to be able to use them
    :: with POSIX CLI on Windows.
    copy %RECIPE_DIR%\opencl-win-%%F.sh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.sh
)
