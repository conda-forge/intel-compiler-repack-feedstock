@echo on
if not exist "%LIBRARY_BIN%\intel-ocl-cpu" mkdir "%LIBRARY_BIN%\intel-ocl-cpu"
set "src1=%SRC_DIR%\%PKG_NAME%\Library\bin"
robocopy /E "%src1%" "%LIBRARY_BIN%\intel-ocl-cpu"
if %ERRORLEVEL% GEQ 8 exit 1

:: Make way for using conda-forge's OpenCL loader
del "%LIBRARY_BIN%\intel-ocl-cpu\OpenCL.dll"

set "src2=%SRC_DIR%\%PKG_NAME%\Library\lib"
robocopy /E "%src2%" "%LIBRARY_LIB%"
if %ERRORLEVEL% GEQ 8 exit 1

:: Make way for using conda-forge's OpenCL loader
del "%LIBRARY_LIB%\OpenCL.lib"

:: populate CL_CONFIG_TBB_DLL_PATH = entry in cl.cfg setting it to %LIBRARY_BIN%
python %RECIPE_DIR%\set_tbb_dll_path.py %LIBRARY_BIN%\intel-ocl-cpu\cl.cfg
mkdir "%LIBRARY_PREFIX%\etc\OpenCL\vendors\"
echo %LIBRARY_BIN%\intel-ocl-cpu\intelocl64.dll> %LIBRARY_PREFIX%\etc\OpenCL\vendors\intel-ocl-cpu.icd
