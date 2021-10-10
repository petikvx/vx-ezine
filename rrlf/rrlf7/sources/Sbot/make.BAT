cls
c:\Progra~1\pellesc\bin\cc.exe -c  -W1 -Gd -Zl -Os -Ze -Tx86-coff sb0t.c
c:\Progra~1\pellesc\bin\polink /ENTRY:main /SUBSYSTEM:WINDOWS /NODEFAULTLIB  /MERGE:.rdata=.text /MERGE:.data=.text /OUT:sb0t.exe C:\progra~1\PellesC\Lib\Win\msvcrt.lib C:\progra~1\PellesC\Lib\Win\kernel32.lib sb0t.obj

