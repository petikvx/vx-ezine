@echo off

if not exist %tasm%tasm.exe goto error
if not exist %tasm%tlink.exe goto error
if not exist %masm%ml.exe goto error
if not exist %tp%tpc.exe goto error

del fuckup.obj
del fuckup.bin
del fuckup.inc
del bin2inc.exe
del dos.obj
del win.obj
del dos.bin
del win.bin

%tasm%tasm.exe fuckup.asm
if not exist fuckup.obj goto error

%tasm%tlink.exe /t /x fuckup.obj,fuckup.bin
if not exist fuckup.bin goto error
del fuckup.obj

%tp%tpc -b bin2inc.pas
if not exist bin2inc.exe goto error

bin2inc.exe /a fuckup.bin fuckup.inc @fuckup
del bin2inc.exe

del fuckup.bin

if not exist fuckup.inc goto error

%masm%ml.exe /c dos.asm
if not exist dos.obj goto error

%masm%ml.exe /c /coff win.asm
if not exist win.obj goto error

del fuckup.inc

%tp%tpc -b add_8b.pas
if not exist add_8b.exe goto error
add_8b.exe
del add_8b.exe

del dos.obj
del win.obj

if not exist -dos.bin goto error
if not exist -win.bin goto error

move -dos.bin ..
move -win.bin ..

:success
echo - success
goto done
:error
echo - error
:done
