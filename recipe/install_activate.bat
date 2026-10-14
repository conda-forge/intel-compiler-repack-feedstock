if not exist %PREFIX%\etc\conda\activate.d MKDIR %PREFIX%\etc\conda\activate.d
if errorlevel 1 exit 1
if not exist %PREFIX%\etc\conda\deactivate.d MKDIR %PREFIX%\etc\conda\deactivate.d
if errorlevel 1 exit 1
if "%PKG_NAME%" == "dpcpp_win-64" (
    copy %RECIPE_DIR%\scripts\activate-dpcpp.bat %PREFIX%\etc\conda\activate.d\z-activate-dpcpp.bat
    copy %RECIPE_DIR%\scripts\deactivate-dpcpp.bat %PREFIX%\etc\conda\deactivate.d\z-deactivate-dpcpp.bat
)
if "%PKG_NAME%" == "ifx_win-64" (
    copy %RECIPE_DIR%\scripts\activate-ifx.bat %PREFIX%\etc\conda\activate.d\z-activate-ifx.bat
    copy %RECIPE_DIR%\scripts\deactivate-ifx.bat %PREFIX%\etc\conda\deactivate.d\z-deactivate-ifx.bat
)
