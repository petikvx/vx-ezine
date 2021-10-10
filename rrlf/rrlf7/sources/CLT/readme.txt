[CAPZLOQ TEKNIQ v1.0] - a multiplatform virus by JPanic (c) 2006.

<Contents>
~~~~~~~~~~
	- <Description>
	- <File List>
	- <'make' usage>

<Description>
~~~~~~~~~~~~~
	CLT10 is a 1.2k infector of Win32 PE and Linux ELF files.
	The virus runs under 2 very different platforms: Win32 and Linux.
	One of the main aims of this virus, besides running under dual
	Operating Systems, is keeping it small and simple.

	On execution under either Operating System the virus attempts to
	infect all PE and ELF files in the current directory. Under Win32 
	the virus calls Kernel32.dll, whilst under Linux the virus calls 
	INT 0x80.

	Infection of Win32 PE files is achieved by adding the virus to the
	last section. This is a fairly standard method. When infecting
	Linux ELF files, the virus creates a cave after the PHdrs, before
	".text".

	The virus is written in TASM and assembles and links to a Win32 PE
	host. This host can be used to infect other PE or ELF files.

	The virus is built with Borland 'make' - see <'make' commands>.

<File List>
~~~~~~~~~~~
	CLT.EXE		-	First generation (win32) virus launcher.

	ReadMe.txt	-	This file.	
	
	MAKEFILE	-	'make' definition file. See section:
				<'make' usage>

	clt.def		-	TLink definition file.	

	codeseg.ash	-	Assembler Header file to declare '.code'.
	
	crc.ash		-	Assembler Header file to declare crc32
				routines and macros.
	crc.asm		-	Assembler Module containing crc32 
				procedures.
	inf-elf.ash	-	Assembler Header to declare ELF
				infection routines.
	inf-elf.asm	-	Assembler Module containing code to
				infect Linux ELF files.

	inf-pe.ash	-	Assembler Header to declare PE
				infection routines.
	inf-pe.asm	-	Assembler Module containing Win32 PE
				infection code.

	linuxproc.asm	-	Assembler Module containing procedures
				to make Linux SYSCALLS (INT 0x80h).


	osprocs.ash	-	Assembler Header to declare OS specific
				procedure tables.

	osprocs.asm	-	Assembler Module to manager OS specific
				calls.



	vheap.ash	-	Assembler Header file to define the 
				virus heap structure.

	vhost.asm	-	Assembler Module defining first
				generation host.

	vmain.ash	-	Assembler Header declaring virus
				main routines.
	vmain.asm	-	Assembler Module defining main
				virus routines.

	w32imps.ash	-	Assembler Header file defining kernel32
				imports under Win32.

	win32proc.asm	-	Assembler Module containing procedures
				to make Win32 kernel32 calls.

	inc\*.*		- 	Several assembler 'include' files.

	samples\	-	Contains 2 directories: UninfectedSamples
				and InfectedSamples. 'InfectedSamples'
				files are created with the 'make SAMPLES'
				command (see section <'make' usage>.

	zips\		-	Contains the 2 .ZIP distributions of this
				virus: Full source code, and InfectedSamples.

<'make' Usage>
~~~~~~~~~~~~~~
[Note: I used borland turbo 'make'.]

	Command:		Result:
	--------		-------
	'make'			Compile and link 'clt.exe'.

	'make -B'		Build and link 'clt.exe'.

	'make -B -DDEBUG	Build and link 'debug' version of 'clt.exe'

	'make CLEANUP'		Delete temporary .lst. .obj. and debug files.

	'make SAMPLES'		Copy .\samples\UninfectedSamples\*.* into
				.\samples\InfectedSamples, and infect them.

	'make ZIPS'		Creates 2 .ZIP files (uses winzip 10), one
				containing just the infected 'samples', the
				other one containing the full release package
				for the virus.

- Best wishes: JPanic (aka Sepultura, aka The Soul Manager)!.