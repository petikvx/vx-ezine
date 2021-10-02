@echo off

if not exist %tp%tpc.exe goto error

del output_1
del output_2
del output_3
del output_4
del make!!!!.exe
del avp__.tpu
del tpu.tpu

if not exist -dos.bin goto error
if not exist -win.bin goto error

copy -stamm.bin output_1
copy -dos.bin   output_2
copy -win.bin   output_3
copy -name.bin  output_4

%tp%tpc -b make!!!!.pas
if not exist make!!!!.exe goto exit
make!!!!.exe eicar.avc rulez.avc /ALL
del make!!!!.exe
del tpu.tpu
del avp__.tpu

del output_1
del output_2
del output_3
del output_4

if not exist rulez.avc goto error

move rulez.avc ..

del -dos.bin
del -win.bin

:success
echo - success
goto done
:error
echo - error
:done
