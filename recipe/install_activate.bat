if not exist %PREFIX%\etc\conda\activate.d MKDIR %PREFIX%\etc\conda\activate.d
if errorlevel 1 exit 1
copy %RECIPE_DIR%\scripts\activate-dpcpp.bat %PREFIX%\etc\conda\activate.d\z-activate-dpcpp.bat
