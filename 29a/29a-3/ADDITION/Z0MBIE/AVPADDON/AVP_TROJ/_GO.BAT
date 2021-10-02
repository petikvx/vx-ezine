@echo off

call set_path.bat

cd make_avc
cd make_obj
call _go
cd ..
call _go
cd ..
