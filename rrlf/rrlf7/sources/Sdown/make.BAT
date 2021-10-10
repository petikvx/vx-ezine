cls
c:\pellesc\bin\cc.exe -c  -W1 -Gd -Zl -Os -Ze -Tx86-coff sd0wn.c
c:\pellesc\bin\polink /ENTRY:main /SUBSYSTEM:WINDOWS /NODEFAULTLIB  /MERGE:.rdata=.text /MERGE:.data=.text /OUT:sd0wn.exe c:\pellesc\lib\win\kernel32.lib sd0wn.obj