@echo on
mkdir "%LIBRARY_PREFIX%\intel-ocl-cpu"
set "src=%SRC_DIR%\%PKG_NAME%\Library\lib"
robocopy /E "%src%" "%LIBRARY_LIB%\intel-ocl-cpu"
if %ERRORLEVEL% GEQ 8 exit 1

mkdir "%LIBRARY_PREFIX%\etc\OpenCL\vendors\"
echo %LIBRARY_LIB%\intel-ocl-cpu\intelocl64.dll> %LIBRARY_PREFIX%\etc\OpenCL\vendors\intel-ocl-cpu.icd

:: populate CL_CONFIG_TBB_DLL_PATH = entry in cl.cfg setting it to %LIBRARY_BIN%
python %RECIPE_DIR%\set_tbb_dll_path.py %LIBRARY_LIB%\intel-ocl-cpu\cl.cfg
:: display configuration file
type %LIBRARY_LIB%\intel-ocl-cpu\cl.cfg
