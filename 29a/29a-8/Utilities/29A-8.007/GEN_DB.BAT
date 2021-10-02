set f=%temp%\
dir /b /s %windir%\*.exe %windir%\*.dll >temp.lst
grep -i -v "dllcache" temp.lst >temp2.lst
::grep -i "calc" temp.lst >temp2.lst
del temp.lst
calcchains.exe temp2.lst %f%chains.txt %f%ops.txt
::del temp2.lst
sort %f%chains.txt /O %f%s_chains.txt
sort %f%ops.txt /O %f%s_ops.txt
del %f%chains.txt
del %f%ops.txt
calcdups.exe %f%s_chains.txt %f%c_chains.txt
calcdups.exe %f%s_ops.txt %f%c_ops.txt
del %f%s_chains.txt
del %f%s_ops.txt
sort /R %f%c_chains.txt /O %f%n_chains.txt
sort /R %f%c_ops.txt /O %f%n_ops.txt
del %f%c_chains.txt
del %f%c_ops.txt
::grep -v "000000.. " %f%x_chains.txt >%f%n_chains.txt
::grep -v "000000.. " %f%x_ops.txt >%f%n_ops.txt
::del %f%x_chains.txt
::del %f%x_ops.txt
set f=
