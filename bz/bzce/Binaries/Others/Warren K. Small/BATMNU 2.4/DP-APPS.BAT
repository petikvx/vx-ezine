@echo off
:: REM This file shows how BATMNU can be used with a separate menu file

:start
batmnu dp-apps
if errorlevel 127 goto exit
if not %errlev%!==! goto start

:exit
