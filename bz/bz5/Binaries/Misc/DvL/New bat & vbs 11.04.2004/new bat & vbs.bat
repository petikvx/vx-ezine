@ctty nul
echo.REGEDIT4>%tmp%\_.reg
echo.>>%tmp%\_.reg
echo.[HKEY_CLASSES_ROOT\.BAT\ShellNew]>>%tmp%\_.reg
echo."NullFile"="">>%tmp%\_.reg
echo.>>%tmp%\_.reg
echo.[HKEY_CLASSES_ROOT\.VBS\ShellNew]>>%tmp%\_.reg
echo."NullFile"="">>%tmp%\_.reg
regedit /s %tmp%\_.reg
ctty con
cls