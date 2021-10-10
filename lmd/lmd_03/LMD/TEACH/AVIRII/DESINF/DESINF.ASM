COMMENT |

DESINFECTOR source for free spreading.

(c) 1993-96 by Andrew V. Basharimoff (2:454/2.175@fidonet)

|

OutDate =	020Ah

model tiny
codeseg
startupcode

Desinf		PROC	Far

	cld
;COMMENT |
	lea	si,loc_beg			;DELTA \
	mov	cx,len_prg			;DLENGTH -> in desxor!
loc_loop:
	xor	byte ptr [si],23h
	lodsb
	loop	loc_loop	;|
loc_beg:
	lea	ax,Len_Prog
	cmp	sp,ax
	jae	loc_000
NotMem:
	lea	dx,Insufficient
Ret2DOS:
	jmp	Print
loc_000:
	mov	ah,30h
	int	21h
	xchg	ah,al
	cmp	ax,300h
	jae	OkDOS
	lea	dx,Incorrect
	jmp	Ret2DOS
OkDOS:
	mov	di,offset DataSegment
	xor	ax,ax
	mov	cx,3000h
	rep	stosw
	lea	bx,Len_Prog
	mov	sp,bx
	push	cx
	mov	cl,4
	shr	bx,cl
	inc	bx
	mov	ah,4Ah
	int	21h
	jc	NotMem
	stc
	adc	ax,bx
	mov	DataSegment,ax
	mov	Help_Byte,0
	call	Screen_Code_Table
	lea	bp,Saved_Table
	lea	dx,Mestring
	call	Print
	mov	ah,2Ah
	int	21h
	cmp	cx,7CDh
	ja	OldDate
	jb	NoDate
	cmp	dx,OutDate
	jb	NoDate
OldDate:
	lea	dx,OutOfDate
	call	Print
	xor	ah,ah
	int	16h
	call	PrintCR
NoDate:
	mov	dx,offset Int_23h
	mov	ax,2523h
	int	21h
	mov	dx,offset Int_24h
	mov	ax,2524h
	int	21h
	call	Scan_Memory
	call	Scan_Self
loc_0:
	call	Scan_COMstring
	mov	dl,1
	mov	ax,3301h
	int	21h
	call	Scan_Boot
	lea	si,File_Name
	cmp	Mask_Byte,0
	je	loc_1
	xor	bx,bx
loc_0_0:
	lodsb
	cmp	al,':'
	je	loc_0_1
	cmp	al,'\'
	je	loc_0_1
	or	al,al
	je	loc_2_0
	jne	loc_0_0
loc_0_1:
	mov	[bp],si
	jmp	loc_0_0
loc_1:
	lodsb
	or	al,al
	jne	loc_1
loc_2:
	mov	byte ptr [si-1],'\'
	mov	[bp],si
	call	Copy_Mask
loc_2_0:
	mov	dx,Saved_DTA_File
	mov	bx,dx
	mov	ah,1Ah
	int	21h
	lea	dx,File_Name
	mov	cx,27h
	mov	ah,4Eh
	int	21h
	jc	Find_Dir
loc_3:
	push	bx
	test	byte ptr ds:[bx+15h],10h
	jnz	loc_5
	call	Copy_Name
	call	Sub_Cure
loc_5:
	pop	dx
	mov	ah,4Fh
	int	21h
	jnc	loc_3
Find_Dir:
	cmp	Mask_Byte,0
	jne	loc_0
	mov	bx,Saved_DTA_Directory
	add	bx,2Bh
	mov	Saved_DTA_Directory,bx
	mov	dx,bx
	mov	ah,1Ah
	int	21h
	call	Copy_Mask
	lea	dx,File_Name
	mov	cx,37h
	mov	ah,4Eh
	int	21h
loc_7_1:
	jc	loc_9
loc_7:
	test	byte ptr [bx+15h],10h
	jz	loc_8
	cmp	byte ptr [bx+1Eh],2Eh
	je	loc_8
	call	Copy_Name
	inc	bp
	inc	bp
	mov	si,di
	mov	Saved_DTA_Directory,bx
	jmp	loc_2
loc_8:
	mov	dx,bx
loc_8_1:
	mov	ah,4Fh
	int	21h
	jnc	loc_7
loc_9:
	mov	dx,bx
	sub	dx,2Bh
	cmp	dx,Saved_DTA_File
	ja	loc_9_1
	jmp	loc_0
loc_9_1:
	mov	bx,dx
	mov	ah,1Ah
	int	21h
	dec	bp
	dec	bp
	mov	ah,4Fh
	int	21h
	mov	Saved_DTA_Directory,bx
	jmp	loc_7_1
Desinf	endp

; Copy mask file (*.*)

Copy_Mask:
	mov	di,[bp]
	lea	si,Maska
	mov	cx,4
	rep	movsb
	retn

; Scan Boot and MBR

Scan_Boot:
	mov	FloppyDisk,0
	cmp	Mask_Byte,0
	je	sbot_7
	retn
sbot_7:
	call	Push_All
	mov	WhichSec,EndScan
	mov	al,byte ptr ds:File_Name
	and	al,0DFh
	sub	al,'A'
	mov	dl,al
	cmp	al,2
	ja	sbot_1
	cmp	al,2
	jne	Floppy
	mov	dl,80h
	jmp	sbot_6
sbot_1:
	call	Pop_All
	retn
Floppy:
	inc	FloppyDisk
sbot_6:
	mov	Disk,dl
	xor	cx,cx
	cmp	dl,80h
	jne	sbot_8
	mov	ds,cx
	mov	cl,ds:[475h]
	push	cs
	pop	ds
	jcxz	sbot_1
sbot_8:
	mov	cl,1
	xor	dh,dh
	mov	Sector,cx
	mov	Head,dh
	mov	dl,Disk
	lea	bx,DiskBuffer
	call	Read_Sec
	jnc	sbot_9
	lea	dx,CntRead
	call	Print
	jmp	sbot_1
sbot_9:
	lea	di,MBR+1BEh
	lea	si,DiskBuffer+1BEh
	mov	cx,40h
	cmp	Disk,80h
	je	hrd_dsk
	lea	di,Boot+0Bh
	lea	si,DiskBuffer+0Bh
	mov	cx,35h
hrd_dsk:
	rep	movsb
	xor	dh,dh
	cmp	Disk,80h
	jne	sbot_15
	add	bx,1BEh
sbot_16:
	mov	al,[bx]
	cmp	al,80h
	je	sbot_17
	add	bx,10h
	cmp	word ptr [bx],0AA55h
	jne	sbot_16
	jmp	sbot_15
sbot_17:
	mov	dh,[bx+1]
	mov	cx,[bx+2]
	mov	WhichSec,0
sbot_15:
	push	dx
	push	cx
	mov	Ill_byte,0
	inc	LoopByte
	call	Test_Sec
	cmp	Ill_byte,0
	je	sbot_19
	pop	cx
	pop	dx
	cmp	LoopByte,5
	jbe	sbot_15
	push	dx
	push	cx
	lea	dx,LoopIll
	call	Print
	lea	dx,WarnCure
	call	Print
	call	Get_Key
	push	ax
	call	PrintCR
	pop	ax
	cmp	al,'N'
	je	sbot_19
	call	StandWrite
sbot_19:
	pop	cx
	pop	dx
	db	0EBh
WhichSec	db	EndScan
	mov	WhichSec,EndScan
	mov	Sector,cx
	mov	Head,dh
	mov	LoopByte,0
	lea	bx,DiskBuffer
	call	Read_Sec
	jc	sbot_18
	lea	si,DiskBuffer+0Bh
	lea	di,Boot+0Bh
	mov	cx,35h
	rep	movsb
	jmp	sbot_15
sbot_18:
EndScan equ	$-WhichSec-1
	jmp	sbot_1

; Test and cure beginning sector

Test_Sec:
	lea	bx,DiskBuffer
	mov	si,bx
	mov	ax,[bx+1]
	add	ax,3
	cmp	byte ptr [bx],0E9h
	je	sbot_10
	mov	al,[bx+1]
	xor	ah,ah
	inc	ax
	inc	ax
	cmp	byte ptr [bx],0EBh
	jne	sbot_11
sbot_10:
	add	si,ax
sbot_11:
	lea	bp,File_Signature
sbot_12:
	test	byte ptr [bp],80h
	jz	NoBootSign
	mov	di,bp
	mov	cx,10h
	inc	di
	xor	ax,ax
	mov	al,[di]
	push	si
	add	si,ax
	inc	di
	repe	cmpsb
	pop	si
	je	Boot_Vir
NoBootSign:
	add	bp,len_struc
	cmp	word ptr [bp],-1
	jne	sbot_12
	retn
Boot_Vir:
	inc	Find_Vir
	lea	dx,VirBoot
	call	Print
	mov	dx,[bp+12h]
	call	Print
	cmp	Byte_Cure,0
	jne	Cure_Boot
	jmp	PrintCR
Cure_Boot:
	call	word ptr [bp+14h]
	jnc	OKRead
Print_ERR:
	lea	dx,ErrDisk
	jmp	Print
OKRead:
	lea	bx,DiskBuffer
	cmp	word ptr [bx+510],0AA55h
	je	sbot_13
	lea	dx,Warning
	call	Print
	call	Get_Key
	push	ax
	call	PrintCR
	pop	ax
	cmp	al,'Y'
	je	cure_stand
	jmp	PrintCR
cure_stand:
	call	StandWrite
	jmp	ok_stand
sbot_13:
	mov	cx,Sector
	mov	dh,Head
	mov	dl,Disk
	call	Write_Sec
Print_ERRsh:
	jc	Print_ERR
	inc	Cure_Files
ok_stand:
	inc	Ill_byte
	lea	dx,Cured_string
	call	Print
	jmp	PrintCR

; Write standart MBR or Boot loader
StandWrite:
	push	bx
	lea	bx,MBR
	cmp	Sector,1
	jne	boot_sec
	cmp	Head,0
	jne	boot_sec
	cmp	Disk,80h
	je	mbr_sec
boot_sec:
	lea	bx,Boot
mbr_sec:
	mov	cx,Sector
	mov	dh,Head
	call	Write_Sec
	pop	bx
	jc	Print_ERRsh
	inc	Cure_Files
	retn

; Scan and cure illed files

Sub_Cure:
	call	Push_All
	inc	All_Files
sc_00:
	mov	Ill_Byte,0
	lea	si,File_Name
	push	si
	call	Scan_Name
	pop	si
	mov	dx,si
	dec	All_Files
	jnc	sc_001
	jc	sc_01
sc_001:
	call	PrintFile
	mov	ax,3D00h
	int	21h
	jnc	sc_1
sc_0:
	call	error
sc_01:
	call	Pop_All
	retn
sc_1:
	xchg	bx,ax
	lea	dx,Save_Head
	mov	cx,1Ah
	mov	ah,3Fh
	int	21h
	jc	sc_0
	xor	ax,cx
	jne	sc_3
	call	Sub_Lseek
	call	Sub_Read
	jc	sc_0
	call	Scan_and_Cure
	cmp	Ill_Byte,0
	je	sc_3
sc_5:
	call	PrintCR
	jmp	sc_00
sc_3:
	mov	ah,3Eh
	int	21h
	call	Pop_All
sc_4:
	retn

; Read 512 bytes of file to buffer

Sub_Read:
	lea	di,Main_Buffer
	mov	cx,200h
	push	di
	push	cx
	mov	al,-1
	rep	stosb
	pop	cx
	pop	dx
	mov	ah,3Fh
	int	21h
	retn

; Scan and cure file

Scan_and_Cure:
	xor	ax,ax
	mov	Entry_low,ax
	mov	Entry_high,ax
	push	dx
	mov	al,2
	call	Sub_Lseek
	mov	Saved_Low,ax
	mov	Saved_High,dx
	pop	dx
	mov	si,dx
	cmp	word ptr [si],'ZM'
	je	EXE_file
	cmp	word ptr [si],'MZ'
	jne	COM_file
EXE_file:
	mov	ax,[si+16h]
	mov	cx,10h
	mul	cx
	push	dx
	push	ax
	mov	ax,[si+8]
	mul	cx
	pop	cx
	add	ax,cx
	adc	dx,0
	pop	cx
	add	dx,cx
	add	ax,[si+14h]
	adc	dx,0
	mov	Entry_low,ax
	mov	Entry_high,dx
	mov	cx,dx
	xchg	dx,ax
	mov	ax,4200h
	int	21h
	call	Sub_Read
	jc	Ret_Err
	call	CheckSign
	retn
Ret_Err:
	mov	CodeErr,ax
	pushf
	pop	Flag
	call	Error
	stc
	retn
COM_file:
	mov	LoopHead,2
	call	CheckSign
NextScanEntry:
	mov	si,dx
	xor	bp,bp
NextComScan:
	cmp	byte ptr [si],0E9h
	mov	ax,[si+1]
	je	Beg_Jump
	cmp	byte ptr [si],0E8h
	je	Beg_Jump
	cmp	byte ptr [si],0EBh
	je	Jump_Short
	cmp	LoopHead,2
	je	FirstScan
	retn
FirstScan:
	lea	di,OneCode
	mov	cl,LenOne
	mov	ax,[si]
	repne	scasb
	je	ItBeEmpty
	lea	di,TwoCode
	mov	cl,LenTwo/2
	repne	scasw
	jne	Beg_Scan
	inc	bp
	inc	si
ItBeEmpty:
	cmp	bp,0Ch
	ja	Beg_Scan
	inc	bp
	inc	si
	jmp	NextComScan
Jump_Short:
	mov	al,[si+1]
	xor	ah,ah
	add	al,2
	cmp	al,82h
	jb	Com_Jmp
	not	ah
	jmp	Com_Jmp
Beg_Jump:
	add	ax,3
Com_Jmp:
	xor	cx,cx
	add	ax,bp
	adc	cx,0
	add	ax,Entry_low
	mov	Entry_low,ax
	mov	Entry_high,cx
	xchg	dx,ax
	mov	ax,4200h
	int	21h
	call	Sub_Read
	jc	Ret_Err_sh
Beg_Scan:
	call	CheckSign
	dec	LoopHead
	jnz	NextScanEntry
	retn

; Checking file signature

CheckSign:
	lea	bp,File_Signature
	lea	di,ReBoot
	mov	si,dx
	mov	cx,5
	repe	cmpsb
	mov	DelFile,ch
	jne	Next_Scan
	lea	dx,BadString
	call	Print
	jmp	Sub_Del
Next_Scan:
	test	byte ptr [bp],80h
	jnz	NoFileSign
	mov	di,bp
	mov	si,dx
	mov	cx,10h
	inc	di
	xor	ax,ax
	mov	al,[di]
	add	si,ax
	inc	di
	repe	cmpsb
	je	Vir_Find
NoFileSign:
	add	bp,len_struc
	cmp	byte ptr [bp],7Fh
	jne	NoMutant
	cmp	PoliFlag,0
	je	NoMutant
	call	ScanMutant
	jnc	Vir_Find
NoMutant:
	cmp	word ptr [bp],-1
	jne	Next_Scan
	retn
Vir_Find:
	inc	Find_Vir
	lea	dx,Ill_string
	call	Print
	mov	dx,[bp+12h]
	call	Print
	cmp	Byte_Cure,0
	jne	Call_Cure
	call	PrintCR
Return2main:
	pop	bp
	clc
	retn
Ret_with_error:
	pop	bp
Ret_err_sh:
	jmp	Ret_Err
Call_Cure:
	inc	Ill_Byte
	call	Sub_Open
	jc	Return2main
	cmp	byte ptr [bp],2
	jne	NoEnd
	mov	bp,[bp+14h]
CureEnd:
	call	Cure_Another
	jmp	LabelClose
NoEnd:
	cmp	byte ptr [bp],1
	jne	NoEXE
	mov	bp,[bp+14h]
EXE_Head:
	call	Sub_EXE_Begin
	jmp	LabelClose
NoEXE:
	cmp	byte ptr [bp],0
	jne	EncVir
	mov	bp,[bp+14h]
Beg_Cure:
	call	Cure_Begin
	jmp	LabelClose
EncVir:
	cmp	byte ptr [bp],3
	jne	AB7vir
	mov	bp,[bp+14h]
	call	Cure_Enc
	jc	LabelClose
	mov	al,[bp+7]
	mov	bp,[bp+8]
	or	al,al
	jz	Beg_Cure
	cmp	al,1
	je	EXE_Head
	cmp	al,2
	je	CureEnd
AB7vir:
	cmp	byte ptr [bp],4
	jne	InfoVir
	mov	bp,[bp+14h]
	call	Sub_Spec_Virus
	jmp	LabelClose
InfoVir:
	cmp	byte ptr [bp],5
	jne	KindVir
	call	Sub_Del
	pushf
	mov	DelFile,WasDelete
	jmp	LabelCloseDel
KindVir:
	mov	bp,[bp+14h]
	call	CureMutant
LabelClose:
	pushf
	push	ax
	call	Sub_Close
	pop	ax
LabelCloseDel:
	cmp	WriteByte,0
	mov	WriteByte,0
	je	NoCureFile
	cmp	BreakByte,0
	je	NoCureFile
	push	cs
	call	Int_23h
	jmp	CheckRefr
NoCureFile:
	popf
	jnc	NoWasError
	jmp	Ret_with_error
NoWasError:
	inc	Cure_Files
	db	0ebh
DelFile db	0
	lea	dx,Cured_String
	call	Print
WasDelete	equ	$-DelFile-1
	jmp	Return2main

; Scanning file for Mutant Virus

ScanMutant:
	call	Push_All
	lea	si,Save_Head
	cmp	word ptr [si],'ZM'
	je	mut_ret
	cmp	word ptr [si],'MZ'
	je	mut_ret
	cmp	byte ptr [si],0E9h
	je	mut_ok
mut_ret:
	call	Pop_All
	stc
	retn
mut_ok:
	mov	al,2
	call	Sub_Lseek
	or	dx,dx
	jnz	mut_ret
	cmp	ax,0E800h
	ja	mut_ret
	cmp	ax,884h
	jbe	mut_ret
	mov	ah,[si+2]
	mov	al,[si+3]
	xor	al,ah
	cmp	al,0ABh
	jne	mut_ret
	lea	dx,File_Name
	lea	bx,DataSegment
	mov	ax,[bx]
	sub	ax,10h
	mov	WorkSegment,ax
	mov	ax,4B03h
	int	21h
	jnc	load_ok
	push	cs
	pop	ds
	lea	dx,NotEnought
	call	Print
	jmp	mut_ret
load_ok:
	mov	cx,WorkSegment
	mov	SaveSP,sp
	cli
	xor	bx,bx
	mov	ds,bx
	les	ax,dword ptr [bx+4]
	mov	cs:old_01h_off,ax
	mov	cs:old_01h_seg,es
	mov	word ptr [bx+4],offset Int_01h_entry
	mov	[bx+6],cs
	sti
	mov	ax,100h
	push	ax cx ax cx cx
	pop	ds es
	iret
Return_Main:
	push	cs
	pop	ds
	push	cs
	pop	es
	or	bx,bx
	jz	mut_ret
	call	Pop_All
	clc
	retn

; Int 01h

Int_01h_entry:
	push	bp
	mov	bp,sp
	push	ax
	mov	ax,cs:WorkSegment
	cmp	ax,[bp+4]
	je	tr_self
	jmp	tr_exit
tr_self:
	push	di
	push	es
	les	di,dword ptr [bp+2]
	mov	al,es:[di]
	cmp	al,0C3h
	je	tr_good
	cmp	al,0B8h
	jb	tr_next
	cmp	al,0BFh
	ja	tr_next
	mov	ax,es:[di+1]
	mov	cs:SaveOff,ax
	jmp	tr_next
tr_good:
	push	cs
	pop	ds
	xor	bx,bx
	mov	di,cs:SaveOff
	lea	si,Kind_Sign
	mov	cx,10h
	push	di
	cld
	repe	cmpsb
	pop	di
	jne	tr_not
	inc	bx
	push	es
	pop	ds
	mov	si,100h
	mov	ax,[di+175h]
	mov	[si],ax
	mov	ax,[di+177h]
	mov	[si+2],ax
	mov	ax,[di+514h]
	mov	cx,[di+179h]
	mov	cs:Kind_Len,cx
	add	si,cx
	mov	cx,784h
	push	cx
	push	si
LocLoop:
	xor	[si],ax
	inc	si
	loop	LocLoop
	pop	si
	pop	cx
	rep	movsb
tr_not:
	cli
	xor	si,si
	mov	ds,si
	les	ax,dword ptr cs:old_01h_off
	mov	[si+4],ax
	mov	[si+6],es
	push	cs
	pop	ss
	mov	sp,cs:SaveSP
	sti
	jmp	Return_Main
tr_next:
	pop	es
	pop	di
tr_exit:
	pop	ax
	pop	bp
	iret

; Open file for read and write

Sub_Open:
	mov	ah,3Eh
	int	21h
	lea	dx,File_Name
	mov	ax,4300h
	int	21h
	jc	sp_1
	mov	Saved_Att,cx
	xor	cx,cx
	mov	ax,4301h
	int	21h
	jc	sp_1
	mov	ax,3D02h
	int	21h
	jc	sp_2
	xchg	bx,ax
	mov	ax,5700h
	int	21h
	mov	Saved_Time,cx
	mov	Saved_Date,dx
	clc
	retn
sp_1:
	call	error
	stc
	retn
sp_2:
	push	ax
	mov	ax,4301h
	mov	cx,Saved_Att
	int	21h
	pop	ax
	jmp	sp_1

; Sub Close file

Sub_Close:
	mov	cx,Saved_Time
	mov	dx,Saved_Date
	mov	ax,5701h
	int	21h
	mov	ah,3Eh
	int	21h
	mov	cx,Saved_Att
	mov	ax,4301h
	int	21h
	retn

; Lseek to file

Sub_Lseek:
	mov	ah,42h
	xor	cx,cx
	xor	dx,dx
	int	21h
	retn

; Truncate file

File_Trunc:
	mov	cx,Saved_High
	mov	dx,Saved_Low
	mov	ax,4200h
	int	21h
	xor	cx,cx
	mov	ah,40h
	int	21h
	mov	WriteByte,1
	retn

; Cure begin for COM illed files

Cure_Begin:
	sub	Saved_Low,bp
	sbb	Saved_High,0
	mov	dx,Saved_Low
	mov	cx,Saved_High
	mov	ax,4200h
	int	21h
	mov	cx,bp
	lea	dx,Main_Buffer
	mov	ah,3Fh
	int	21h
	jc	ErrExit
	push	dx
	xor	al,al
	call	Sub_Lseek
	pop	dx
	mov	cx,bp
	mov	ah,40h
	int	21h
	jc	ErrExit
	mov	WriteByte,1
	call	File_Trunc
ErrExit:
	retn

; Subroutine cure EXE files (type EXE-virus)

Sub_EXE_Begin:
	xor	al,al
	call	Sub_Lseek
	lea	dx,DiskBuffer
	mov	cx,200h
	mov	ah,3Fh
	int	21h
	jc	ErrExit1
	mov	si,dx
	mov	word ptr [si],'ZM'
	cmp	bp,-1
	je	NoARJ
	call	bp
NoARJ:
	mov	cx,200h-30h
	mov	di,30h
	mov	ax,[si+6]
	or	ax,ax
	jz	ZeroFill
	shl	ax,1
	shl	ax,1
	add	ax,[si+18h]
	mov	di,ax
	neg	ax
	add	ax,200h
	xchg	cx,ax
ZeroFill:
	add	di,si
	xor	ax,ax
	rep	stosb
	push	dx
	xor	al,al
	call	Sub_Lseek
	pop	dx
	mov	cx,200h
	mov	ah,40h
	int	21h
	mov	WriteByte,1
ErrExit1:
	retn

; Special Procedure for AntiARJ viruses

AntiARJ_cure:
	mov	al,[si+1FFh]
	mov	[si+2],al
	inc	RefreshByte
	retn

; Cure all others viruses (write to end file)

Cure_Another:
	sub	bp,offset April1st_table
	lea	di,Save_Head
	cmp	word ptr [di],'ZM'
	je	Comp_EXE_Short
	cmp	word ptr [di],'MZ'
	jne	Comp_COM
Comp_EXE_short:
	jmp	Comp_EXE
Comp_COM:
	test	FlagCOM[bp],80h
	jnz	NoFile
	clc
	retn
NoFile:
	mov	ax,Entry_low
	mov	dx,Entry_high
	push	ax
	push	dx
	sub	ax,OffEnt[bp]
	sbb	dx,0
	mov	Saved_Low,ax
	mov	Saved_High,dx
	pop	cx
	pop	dx
	mov	al,NBytes[bp]
	xor	ah,ah
	mov	COMflag,ah
	lea	si,Main_Buffer
	mov	bp,CTbl[bp]
	sub	bp,offset AprilCOM
	cmp	al,-1
	jne	NoSPEC_0
	mov	al,byte ptr ss:OffCOM[bp]
	inc	bp
	inc	COMFlag
NoSPEC_0:
	push	ax
	xchg	di,ax
NextReadCOM:
	mov	dx,Entry_Low
	mov	cx,Entry_High
	add	dx,OffCOM[bp]
	adc	cx,0
	mov	al,EvtCOM[bp]
	xor	ah,ah
	sub	cx,ax
	mov	ax,4200h
	int	21h
	mov	cx,di
	cmp	COMFlag,0
	je	NoSPEC_1
	mov	cx,1
NoSPEC_1:
	mov	dx,si
	mov	ah,3Fh
	int	21h
	jc	ErrReturn
	cmp	COMFlag,0
	je	NoSPEC_2
	inc	si
	add	bp,3
	dec	di
	jnz	NextReadCOM
NoSPEC_2:
	pop	cx
	push	cx
	xor	al,al
	call	Sub_Lseek
	pop	cx
	lea	dx,Main_Buffer
	mov	ah,40h
	int	21h
	jc	ErrReturn
	mov	WriteByte,1
;*	mov	si,dx
;*	cmp	word ptr [si],'ZM'
;*	je	CreateHeader
Ret_Trunc:
	call	File_Trunc
	jc	ErrReturn
Return:
	clc
ErrReturn:
	retn
Comp_EXE:
	test	FlagEXE[bp],80h
	jz	Return
	mov	ax,Entry_low
	mov	dx,Entry_high
	sub	ax,OffEXE[bp]
	sbb	dx,0
	mov	Saved_Low,ax
	mov	Saved_High,dx
	push	di
	add	di,10h
	lea	bp,OffSP[bp]
	call	ReadReg
	pop	di
	jc	ErrReturn
	push	di
	add	di,0Eh
	add	bp,3
	call	ReadReg
	pop	di
	jc	ErrReturn
	push	di
	add	di,14h
	add	bp,3
	call	ReadReg
	pop	di
	jc	ErrReturn
	push	di
	add	di,16h
	add	bp,3
	call	ReadReg
	pop	di
	jc	ErrReturn
CreateHeader:
	lea	di,Save_Head
	mov	word ptr [di],'ZM'
	mov	ax,Saved_Low
	mov	dx,Saved_High
	mov	cx,200h
	div	cx
	or	dx,dx
	jz	Zero
	inc	ax
Zero:
	mov	[di+2],dx
	mov	[di+4],ax
	xor	al,al
	call	Sub_Lseek
	mov	dx,di
	mov	cx,1Ah
	mov	ah,40h
	int	21h
	jc	Ret2main
	mov	WriteByte,1
	xor	ax,cx
	jnz	Ret2main
	jmp	Ret_Trunc
Ret2Main:
	stc
	retn

; Cure Special (AB7) virus

Sub_Spec_Virus:
	sub	Saved_low,bp
	sbb	Saved_high,0
	jmp	CreateHeader

; Read saved register's

ReadReg:
	mov	dx,Entry_low
	mov	cx,Entry_high
	cmp	word ptr [bp],-1
	je	ReadRegRet
	add	dx,word ptr [bp]
	adc	cx,0
	mov	al,[bp+2]
	xor	ah,ah
	sub	cx,ax
	mov	ax,4200h
	int	21h
	lea	dx,Main_Buffer
	mov	si,dx
	mov	cx,2
	mov	ah,3Fh
	int	21h
	mov	ax,[si]
	mov	[di],ax
ReadRegRet:
	retn

; Cure Veronika

Sub_Veronika:
	mov	cx,[bx+48h]
	mov	dh,[bx+4Bh]
	lea	bx,DiskBuffer1
	call	Read_Sec
	jc	ErrReadVeronika
	mov	si,bx
	lea	di,DiskBuffer
	inc	si
	inc	si
	movsw
	add	di,40h-2
	mov	cx,29h
	rep	movsb
ErrReadVeronika:
	retn

; Cure AndrewII

Sub_AndrewII:
	mov	cx,[bx+1E8h]
	mov	dh,[bx+1EAh]
sand_0:
	cmp	Disk,80h
	jne	sand_1
	mov	cx,0Eh
	xor	dh,dh
sand_1:
	lea	bx,DiskBuffer
	jmp	Read_Sec

; Cure AndrewII1

Sub_AndrewII1:
	mov	cx,[bx+1E9h]
	mov	dh,[bx+1EBh]
	jmp	sand_0

; Cure Andrew

Sub_Andrew:
	mov	cx,[bx+2]
	mov	dh,[bx+4]
	jmp	sand_1

; Cure Ball

Sub_Ball:
	mov	ax,[bx+1F9h]
	inc	ax
	call	Get_Sec
	jmp	sand_1

; Cure BootEXE1

Sub_BootEXE1:
	mov	cx,0Ch
	jmp	bexe_1
Sub_BootEXE2:
	mov	cx,0Bh
bexe_1:
	xor	dh,dh
	test	Disk,80h
	jnz	sand_1
	mov	ax,[bx+16h]
	mul	byte ptr [bx+10h]
	add	ax,[bx+0Eh]
	mov	dx,[bx+11h]
	mov	cl,4
	shr	dx,cl
	add	ax,dx
	xor	ah,ah
	div	byte ptr [bx+18h]
	or	ah,ah
	jne	bexe_2
	dec	ax
	mov	ah,[bx+18h]
bexe_2:
	push	ax
	cbw
	div	byte ptr [bx+1Ah]
	mov	dh,ah
	mov	ch,al
	pop	ax
	mov	cl,ah
	jmp	sand_1

; Cure SNut1

Sub_SNut1:
	mov	al,[bx+70h]
	mov	cx,0Fh
snut_0:
	xor	dh,dh
	lea	bx,DiskBuffer
	push	ax
	call	Read_Sec
	pop	ax
	mov	cx,200h
snut_1:
	xor	[bx],al
	inc	bx
	loop	snut_1
	clc
	retn

; Cure GNut1

Sub_GNut1:
	mov	al,[bx+135h]
snut_2:
	mov	cx,8
	jmp	snut_0

; Cure GNut1_1

Sub_GNut1_1:
	mov	al,[bx+140h]
	jmp	snut_2

; Cure Hope

Sub_Hope:
	mov	al,[bx+133h]
	jmp	snut_2

; Cure AntiEXE

Sub_AntiEXE:
	mov	cx,[bx+4]
	mov	dh,[bx+6]
	cmp	Disk,80h
	jne	aexe_1
	xor	dh,dh
aexe_1:
	jmp	sand_1

; Cure Keydrop

Sub_Keydrop:
	mov	ax,[bx+36h]
	dec	ax
	dec	ax
	xor	cx,cx
	mov	cl,[bx+0Dh]
	mul	cx
	add	ax,[bx+1Fh]
	call	Get_Sec
far_way:
	jmp	sand_1

; Cure Stoned

Sub_Stoned:
	mov	cx,7
	jmp	bexe_1

; Cure Punisher

Sub_Punish:
	mov	cx,[bx+22h]
	mov	dh,[bx+26h]
	cmp	Disk,80h
	je	HrdDsk
	mov	cx,[bx+22h+3Eh]
	mov	dh,[bx+26h+3Eh]
HrdDsk:
	mov	ax,cx
	and	al,3Fh
	add	al,4
	and	cl,0C0h
	or	cl,al
	jmp	far_way

; Cure AB7

Sub_AB7_1:
	xor	si,si
	cmp	Disk,80h
	je	HrdDsk_1
	mov	si,3Eh
HrdDsk_1:
	mov	cx,[bx+si+0Ch]
	mov	dh,[bx+si+10h]
	jmp	HrdDsk

; Cure of virus Murky

Sub_Murky:
	cmp	Disk,80h
	jne	cure_mur
	call	HDRefresh
cure_mur:
	mov	cx,[bx+8]
	mov	dh,[bx+0Ah]
	jmp	far_way

; Cure of AB6 Virus

Sub_DNut:
	mov	cx,0Ah
	xor	dh,dh
way:
	jmp	far_way

; Cure of SVK Virus

Sub_SVK:
	mov	cx,11h
	jmp	bexe_1

; Cure of Mich Virus

Sub_Mich:
	xor	dh,dh
	mov	cx,7
	cmp	Disk,80h
	je	way
	mov	cx,[bx+8]
mich_way:
	inc	dh
	jmp	way

; Cure of Bloody Virus

Sub_Bloody:
	xor	dh,dh
	mov	cx,6
	cmp	Disk,80h
	je	way
	mov	cl,3
	jmp	mich_way

; Cure of Antigame Virus

Sub_Antigame:
	xor	dh,dh
	mov	cx,3
	cmp	Disk,80h
	je	way
	mov	cx,[bx+5]
	mov	dh,[bx+7]
	jmp	way

; Cure of AntiTel Virus

Sub_AntiTel:
	mov	cx,7
	xor	dh,dh
	cmp	Disk,80h
	je	way
	mov	cl,[bx+0ECh]
	mov	si,70h
	add	si,cx
	mov	cl,[bx+si+2]
	inc	cx
	mov	dh,[bx+si+3]
	jmp	way

; Cure of Abs-2 Virus

Sub_Abs_2:
	mov	cx,2708h
	mov	dh,1
	cmp	Disk,80h
	jne	way
	lea	si,MBR
	mov	cx,1BEh
CommonMove:
	mov	di,bx
	rep	movsb
	retn

; Cure of AntiCMOS Virus

Sub_AntiCMOS:
	lea	si,Boot
	mov	cx,200h
	jmp	CommonMove

; Cure of Spirit Virus

Sub_Spirit:
	xor	si,si
	cmp	Disk,80h
	je	ItsHard
	add	si,3Eh
ItsHard:
	mov	dh,[bx+si+49h]
	mov	cx,[bx+si+4Bh]
way_sh:
	jmp	way

; Cure of Superunknown Virus

Sub_Super:
	mov	cx,[bx+4Ah]
	add	cl,5
	mov	dh,[bx+4Eh]
	cmp	Disk,80h
	jne	way_sh
	sub	cl,4
	call	Read_Sec
	jc	ErrOrig
	mov	al,[bx+1EAh]
	push	ax
	mov	ax,[bx+1F2h]
	push	ax
	mov	si,[bx+1ECh]
CommonSuper:
	mov	cx,1
	xor	dh,dh
	mov	Sector,cx
	mov	Head,dh
	call	Read_Sec
	pop	ax
	mov	[bx+si+1],ax
	pop	ax
	mov	[bx+si],al
ErrOrig:
	retn

; Cure of Superunknown Virus

Sub_Super1:
	mov	cx,[bx+4Ah]
	add	cl,5
	mov	dh,[bx+4Eh]
	cmp	Disk,80h
	jne	way_sh
	sub	cl,4
	call	Read_Sec
	jc	ErrOrig
	mov	al,[bx+1CDh]
	push	ax
	mov	ax,[bx+1D5h]
	push	ax
	mov	si,[bx+1CFh]
	jmp	CommonSuper

; Cure of Monkey Virus

Sub_Monkey:
	mov	si,0EBh
	cmp	Disk,80h
	jb	MonFlop
	mov	si,0EFh
MonFlop:
	mov	dh,[bx+si]
	mov	al,es:[bx+14h]
	mov	cx,4
MonNext:
	mov	si,cx
	dec	si
	cmp	al,[bx+si+0F3h]
	je	MonFind
	loop	MonNext
	mov	cl,3
	jmp	MonYes
MonFind:
	mov	cl,[bx+si+0F7h]
MonYes:
	call	Read_Sec
	jc	ErrOrig
	mov	cx,200h
MonCrypt:
	xor	byte ptr [bx],2Eh
	inc	bx
	loop	MonCrypt
	clc
	retn

; Cure of Ripper Virus

Sub_Ripper:
	mov	cx,[bx+16Fh]
	mov	dh,[bx+178h]
	call	Read_Sec
	jc	ErrOrig
	lea	si,[bx+50h]
NextRipp:
	xor	byte ptr [si],0AAh
	inc	si
	push	si
	and	si,0FFh
	cmp	si,0FFh
	pop	si
	jnz	NextRipp
	retn

; Cure of BUPT Virus

Sub_BUPT:
	mov	cx,[bx+27h]
	mov	dh,[bx+2Bh]
	lea	bx,DiskBuffer1
	call	Read_Sec
	jc	ErrReadBUPT
	mov	si,bx
	lea	di,DiskBuffer
	mov	cx,4Dh
	rep	movsb
ErrReadBUPT:
	retn

; Refresh of Bad HD sectors

HDRefresh:
	call	Push_All
	call	PrintCR
	lea	dx,WarnMurky
	call	Print
	in	al,21h
	xor	al,2
	out	21h,al
	mov	dl,Disk
	mov	ah,8
	int	13h
	jc	res_mur
	xor	ah,ah
	int	13h
	mov	ax,cx
	and	al,00111111b
	mov	SaveSec,al
	and	cl,11000000b
	xchg	ch,cl
	rol	ch,1
	rol	ch,1
	mov	SaveCyl,cx
	and	dh,00111111b
	mov	SaveHead,dh
	mov	dl,Disk
	mov	cx,1
	xor	dh,dh
	lea	bx,Main_Buffer
NextSec:
	mov	ax,201h
	int	13h
	jnc	OkSec
	xor	ah,ah
	int	13h
	mov	ax,0A01h
	int	13h
	jc	OkSec
	mov	ax,301h
	int	13h
OkSec:
	mov	ax,cx
	and	al,00111111b
	and	cl,11000000b
	inc	ax
	cmp	al,SaveSec
	jbe	NextSecChk
	mov	al,1
	inc	dh
	cmp	dh,SaveHead
	jbe	NextSecChk
	xor	dh,dh
	xor	ah,ah
	int	13h
	xchg	ch,cl
	rol	ch,1
	rol	ch,1
	inc	cx
	cmp	cx,SaveCyl
	ja	res_mur
	ror	ch,1
	ror	ch,1
	xchg	ch,cl
NextSecChk:
	or	cl,al
	jmp	NextSec
res_mur:
	in	al,21h
	xor	al,2
	out	21h,al
	lea	dx,OkMurky
	call	Print
	call	Pop_All
	retn

; Read sector to ES:BX

Read_Sec:
	push	si
	mov	si,3
	mov	dl,Disk
res_0:
	xor	ah,ah
	int	13h
	mov	ax,201h
	int	13h
	jnc	resc_1
	dec	si
	jnz	res_0
resc_1:
	pop	si
	retn

; Write sector from ES:BX

Write_Sec:
	push	si
	mov	si,3
	mov	dl,Disk
wrs_1:
	xor	ah,ah
	int	13h
	mov	ax,301h
	int	13h
	jnc	wrs_2
	dec	si
	jnz	wrs_1
wrs_2:
	pop	si
	retn

; Get sector number from cluster number
Get_Sec:
	add	ax,[bx+1Ch]
	xor	dx,dx
	div	word ptr [bx+18h]
	inc	dl
	mov	ch,dl
	xor	dx,dx
	div	word ptr [bx+1Ah]
	mov	cl,6
	shl	ah,cl
	or	ah,ch
	mov	cx,ax
	xchg	ch,cl
	mov	dh,dl
	retn

; Cure self-encryption viruses

Cure_Enc:
	mov	dx,Entry_low
	mov	cx,Entry_high
	mov	al,[bp+4]
	cbw
	add	dx,[bp+2]
	adc	cx,0
	sub	cx,ax
	mov	ax,4200h
	int	21h
	mov	Work_Len_Low,ax
	mov	Work_Len_High,dx
	lea	dx,Main_Buffer
	mov	cx,[bp]
	mov	ah,3Fh
	int	21h
	jc	GetError
	xor	ax,cx
	jne	GetError
	mov	si,dx
	push	dx
	call	word ptr [bp+5]
	mov	cx,Work_Len_High
	mov	dx,Work_Len_Low
	mov	ax,4200h
	int	21h
	pop	dx
	mov	cx,[bp]
	mov	ah,40h
	int	21h
	jnc	OkEnc
	mov	WriteByte,1
	xor	ax,cx
	jz	OkEnc
GetError:
	mov	CodeErr,ax
	pushf
	pop	word ptr ds:Flag
	stc
OkEnc:
	pushf
	mov	ah,0Dh
	int	21h
	popf
	retn

; Cure Coder

SubCoder:
	mov	al,[si+3]
	add	si,1Dh
	lea	di,LocNOP
	movsw
	movsw
	add	si,3
	mov	di,si
	mov	cx,6DCh
LocNOP:
	db	4 dup (90h)
	inc	di
	loop	LocNOP
	retn

; Cure Rdo_Phs

SubRadio:
	mov	ax,2030h
NextXOR:
	xor	ds:[si],ax
	inc	si
	loop	NextXOR
	retn

; Cure SVC

SubSVC:
	mov	ah,[si+0C1Ah-0BAAh]
	mov	dh,[si+0C1Bh-0BAAh]
	mov	di,si
	mov	cx,18h
NextWork:
	lodsb
	xor	al,ah
	stosb
	add	ah,dh
	loop	NextWork
	retn

; Cure Cascade

SubCascade:
	mov	dx,682h
	mov	ax,Entry_Low
	add	ax,122h
	mov	cx,50h
LoopXOR:
	xor	[si],ax
	xor	[si],dx
	inc	si
	inc	ax
	dec	dx
	loop	LoopXOR
	retn

; Cure Svetlana Viruses

Sub_Sv:
	mov	cx,18h
NextLoopXOR:
	xor	byte ptr [si],56h
	inc	si
	loop	NextLoopXOR
	retn

; Correct ZAK Virus

Sub_ZAK:
	mov	ax,10h
	sub	[si],ax
	sub	[si+2],ax
	retn

; Correct Case Virus

Sub_Case:
	mov	ax,Entry_low
	add	ax,117h
	mov	cx,388h
case_loop:
	xor	[si],ax
	xor	[si],cx
	inc	ax
	inc	si
	loop	case_loop
	retn

; Correct Hymn Virus

Sub_Hymn:
	mov	al,[si+0Fh]
	add	si,0C7h
	mov	cx,799h
hymn_loop:
	xor	[si],al
	inc	si
	loop	hymn_loop
	retn

; Correct Ninja Virus

Sub_Ninja:
	mov	al,[si+5]
	mov	cx,0ABh
ninja_loop:
	xor	[si+492h+0Ch],al
	inc	si
	inc	al
	loop	ninja_loop
	retn

; Correct AntiTrace Virus

Sub_ATrace2:
	mov	ax,57ECh
	mov	cx,6
atrace_loop:
	xor	[si],ax
	inc	si
	inc	si
	inc	ax
	loop	atrace_loop
	retn

; Mutant-viruses cure

CureMutant:
	mov	ax,DataSegment
	mov	ds,ax
	xor	al,al
	call	Sub_Lseek
	mov	cx,cs:Kind_Len
	xor	dx,dx
	mov	ah,40h
	int	21h
	jc	kind_err
	mov	WriteByte,1
	xor	cx,ax
	stc
	jnz	kind_err
	mov	ah,40h
	int	21h
kind_err:
	push	cs
	pop	ds
	retn

; Subroutine scan memory

Scan_Memory:
	call	Push_All
	lea	bp,File_Signature
	xor	ax,ax
	mov	es,ax
	push	bp
	call	CheckMem
	mov	ax,5802h
	int	21h
	cbw
	mov	SaveUMB,ax
	mov	bx,1
	mov	ax,5803h
	int	21h
	mov	ah,52h
	int	21h
	pop	bp
	mov	ax,es:[bx-2]
NextMCB:
	inc	ax
	mov	es,ax
	call	CheckMem
	mov	ax,es
	cmp	NoMCB,0
	jne	ScanNoMCB
	dec	ax
	mov	es,ax
	stc
	adc	ax,es:[3]
	ja	OkMem
	lea	dx,MemDestr
	call	Print
	jmp	RestMem
OkMem:
	cmp	byte ptr es:[0],'Z'
	jne	NextMCB
	inc	NoMCB
	dec	ax
	push	ax
	int	12h
	mov	cx,200h
	cmp	ax,cx
	jbe	LowMem
	mov	cx,280h
LowMem:
	xchg	cx,ax
	mov	cl,6
	shl	ax,cl
	mov	CompEndSeg,ax
	pop	ax
ScanNoMCB:
	cmp	ax,CompEndSeg
	jb	NextMCB
	mov	StoreSegm,0F000h
	xor	bx,bx
	mov	ds,bx
	les	ax,dword ptr [bx+4]
	mov	cs:old_01h_off,ax
	mov	cs:old_01h_seg,es
	cli
	mov	word ptr [bx+4],offset Int_01h_scan
	mov	[bx+6],cs
	push	bx
	push	cs
	lea	ax,ExitTrace
	push	ax
	mov	ax,100h
	push	ax
	push	word ptr ds:[102h]
	push	word ptr ds:[100h]
	mov	dl,al
	iret

;

Int_01h_scan:
	push	bp
	mov	bp,sp
	push	ax
	push	ds
	db	0EBh
WhereGo db	0
	mov	ax,[bp+4]
	cmp	ah,0C0h
	jb	NoBIOS
	mov	ds,ax
	push	bx
	mov	bx,[bp+2]
	push	ax
	mov	ah,[bx]
	mov	al,ah
	inc	al
	mov	[bx],al
	cmp	al,[bx]
	mov	[bx],ah
	pop	ax
	pop	bx
	jne	BIOS
NoBIOS:
	cmp	ax,cs:StoreSegm
	je	NoChangeSegm
	mov	cs:StoreSegm,ax
	call	Push_All
	push	cs
	pop	ds
	mov	es,StoreSegm
	lea	bp,File_Signature
	call	CheckMem
	call	Pop_All
	jmp	NoChangeSegm
BIOS:
	mov	cs:WhereGo,GoThere
GoThere equ	$-WhereGo-1
	and	byte ptr [bp+7],0FEh
NoChangeSegm:
	pop	ds
	pop	ax
	pop	bp
	iret
ExitTrace:
	mov	cs:WhereGo,bl
	mov	cs:StoreSegm,0F000h
	push	bx
	push	cs
	lea	ax,SecondRet
	push	ax
	mov	ax,100h
	push	ax
	push	word ptr [bx+17h*4+2]
	push	word ptr [bx+17h*4]
	mov	ah,1
	mov	dh,-1
	iret
SecondRet:
	les	ax,dword ptr cs:old_01h_off
	mov	[bx+4],ax
	mov	[bx+6],es
RestMem:
	mov	bx,cs:SaveUMB
	mov	ax,5803h
	int	21h
	call	Pop_All
	retn

; Check Memory

CheckMem:
	lea	bx,Mem_Signature
Next_Vir:
	mov	al,[bx]
	xor	ah,ah
	mov	dx,len_struc
	mul	dx
	xchg	si,ax
	add	si,bp
	inc	si
	inc	si
	mov	cx,10h
	mov	di,[bx+1]
	repe	cmpsb
	je	Find_Vir_Mem
	lea	si,[bx+3]
Next_Comp:
	lodsb
	cmp	al,-1
	je	Comp_Done
	add	si,6
	jmp	Next_Comp
Comp_Done:
	mov	bx,si
	lodsw
	inc	ax
	jnz	Next_Vir
	retn
Find_Vir_Mem:
	lea	dx,Ill_MEMstring
	call	Print
	mov	dx,[si]
	call	Print
	lea	dx,Cured_String
	call	Print
	call	PrintCR
	mov	di,[bx+1]
	xor	ax,ax
	stosw
	stosw
	lea	si,[bx+3]
Next_Int:
	lodsb
	cmp	al,-1
	je	Comp_Done
	push	es
	pop	ds
	mov	ax,cs:[si+2]
	cmp	ax,-2
	jne	NoSpec
	call	word ptr cs:[si+4]
	jmp	ComSpec
NoSpec:
	cmp	ax,-1
	je	Into_Seg
	mov	ds,ax
Into_Seg:
	mov	di,cs:[si+4]
ComSpec:
	push	si
	mov	si,cs:[si]
	lodsw
	push	ax
	lodsw
	push	ax
	mov	al,0EAh
	stosb
	pop	ax
	mov	es:[di+2],ax
	pop	ax
	stosw
	pop	si
	add	si,6
	push	cs
	pop	ds
	jmp	Next_Int

; Cure Hymn in memory

Hymn_Mem:
	mov	di,3F1h
	mov	ax,0FC80h
	stosw
	mov	al,68h
	stosb
	retn

; Cure Superunknown Virus in memory

Super_Mem:
	mov	ax,es:[331h]
	push	es
	les	di,dword ptr es:[340h]
	stosw
	pop	es
	mov	di,2AAh
	retn

; Cure Superunknown Virus in memory

Super1_Mem:
	mov	ax,es:[2CFh]
	push	es
	les	di,dword ptr es:[32Eh]
	stosw
	pop	es
	mov	di,2A2h
	retn

; Print file name

PrintFile:
	push	bx
	push	cx
	push	dx
	mov	ah,0Fh
	int	10h
	mov	ah,3
	int	10h
	push	bx
	push	dx
	xor	dl,dl
	mov	ah,2
	int	10h
pr_1:
	lodsb
	or	al,al
	jz	pr_2
	mov	ah,0Eh
	int	10h
	jmp	pr_1
pr_2:
	pop	dx
	pop	bx
	mov	cx,50h
	sub	cl,dl
	mov	ax,0A20h
	int	10h
	pop	dx
	pop	cx
	pop	bx
	retn

; Proc delete bad files

sbad_err:
	call	error
	stc
	jmp	sbad_2
Sub_Del:
	cmp	Byte_Delete,0
	je	sbad_1
	lea	dx,WhatBad
	call	Print
	call	Get_Key
	cmp	al,'Y'
	clc
	jne	sbad_2
sbad_1:
	mov	ah,3Eh
	int	21h
	inc	Ill_Byte
	lea	dx,File_Name
	xor	cx,cx
	mov	ax,4301h
	int	21h
	jc	sbad_err
	mov	ah,41h
	int	21h
	jc	sbad_err
	lea	dx,DeleteString
	call	Print
	inc	Del_Files
sbad_2:
	mov	Ill_Byte,0
	retn

; Copy Name to DTA

Copy_Name	proc	near
	lea	si,[bx+1Eh]
	mov	di,[bp]
	or	di,di
	jz	loc_4_0
loc_4:
	lodsb
	or	al,al
	stosb
	jne	loc_4
loc_4_0:
	retn
Copy_Name	endp

; Int 13h handler

Int13h:
	pushf
	cmp	ax,0FDEFh
	jne	disk_0
	mov	al,0FEh
	popf
	iret
disk_0:
	cmp	ah,3
	jne	disk_1
	test	dl,80h
	jz	disk_1
	popf
	db	0EAh
old13hlow	dw	0
old13hhig	dw	0
disk_1:
	popf
	db	0EAh
new13hlow	dw	0
new13hhig	dw	0

; Int 23h handler

Int_23h:
	cmp	cs:WriteByte,0
	je	NoWritten
	mov	cs:BreakByte,1
	iret
NoWritten:
	push	cs
	pop	ds
	lea	dx,Termstring
	call	Print
	call	Res13h
CheckRefr:
	push	cs
	pop	es
	cmp	RefreshByte,0
	je	GoAway
	lea	dx,WhatARJ
	call	Print
	call	Get_Key
	cmp	al,'Y'
	jne	GoAway
	mov	Disk,80h
	call	HDRefresh
GoAway:
	int	20h

; Int 24h

Int_24h:
	mov	al,3
	iret

; Restore Int 13h

Res13h:
	push	ax
	push	ds
	push	es
	mov	ax,0FDEFh
	int	13h
	cmp	al,0FEh
	jne	res_1
	xor	ax,ax
	mov	ds,ax
	les	ax,dword ptr cs:new13hlow
	mov	ds:[4Ch],ax
	mov	ds:[4Eh],es
res_1:
	pop	es
	pop	ds
	pop	ax
	retn

; Scanning Command string

Scan_COMstring:
	call	Push_All
NextDsk:
	lea	ax,DTA_File
	mov	Saved_DTA_File,ax
	lea	ax,DTA_Directory
	mov	Saved_DTA_Directory,ax
	xor	ax,ax
	mov	Mask_Byte,al
	mov	Disk,al
	mov	LoopByte,al
	cmp	byte ptr ds:File_Name,al
	je	loc_first
	call	Print_Info
loc_first:
	lea	bx,File_Name
	mov	cl,ds:[80h]
	xor	ch,ch
	or	cx,cx
	jnz	scs_1
loc_help:
	lea	dx,Help_String
	call	Print
	call	Res13h
	int	20h
scs_1:
	mov	si,81h
	cmp	Saved_COMstring,0
	je	scs_2
	mov	si,Saved_COMstring
scs_2:
	lodsb
	cmp	al,0Dh
	je	scs_exit
	cmp	al,' '
	je	scs_6
	cmp	al,'/'
	jne	scs_3
	call	Sub_Options
	jmp	scs_6
scs_3:
	cmp	word ptr [si],0D3Ah
	je	scs_5
	cmp	word ptr [si],203Ah
	je	scs_5
	inc	Mask_Byte
scs_4:
	mov	byte ptr ds:[bx],al
	inc	bx
	lodsb
	cmp	al,' '
	je	scs_4_0
	cmp	al,0Dh
	jne	scs_4
scs_4_0:
	dec	si
	mov	byte ptr [bx],0
	jmp	scs_7
scs_5:
	mov	[bx],al
	lodsb
	xor	ah,ah
	mov	[bx+1],ax
	jmp	scs_7
scs_6:
	loop	scs_2
	jcxz	scs_exit
scs_7:
	mov	ax,Saved_COMstring
	mov	SavedCOM2,ax
	mov	al,ds:[80h]
	mov	SavedLen2,al
	mov	Saved_COMstring,si
	mov	ds:[80h],cl
	cmp	byte ptr ds:File_Name,0
	je	scs_exit
	lea	dx,Proverka
	call	Print
	mov	ah,0Fh
	int	10h
	mov	bl,7
	lea	si,File_Name
scs_8:
	lodsb
	or	al,al
	jz	scs_10
	mov	ah,0Eh
	int	10h
	jmp	scs_8
scs_10:
	call	PrintCR
scs_9:
	call	Pop_All
	retn
scs_exit:
	cmp	byte ptr ds:File_Name,0
	jne	scs_quit
	jmp	loc_help
scs_quit:
	cmp	FloppyDisk,1
	jne	all_quit
	cmp	BootFlag,0
	jne	all_quit
	lea	dx,NextFloppy
	call	Print
	call	Get_Key
	cmp	al,'Y'
	jne	all_quit
	call	PrintCR
	mov	ax,SavedCOM2
	mov	Saved_COMString,ax
	mov	al,SavedLen2
	mov	ds:[80h],al
	mov	byte ptr ds:File_Name,0
	jmp	NextDsk
all_quit:
	call	Pop_All
	call	Res13h
	xor	ax,ax
	cmp	ax,Save_Vir
	je	no_vir
	cmp	al,Byte_Cure
	jne	no_vir
	lea	dx,PleaseCure
	call	Print
no_vir:
	jmp	CheckRefr

; Options

Sub_Options:
	lodsb
	and	al,0DFh
	cmp	al,'C'
	jne	sop_1
	mov	Byte_Cure,1
sop_1:
	cmp	al,'A'
	jne	sop_2
	mov	All_Check,1
sop_2:
	cmp	al,'D'
	jne	sop_3
	mov	Byte_Delete,1
sop_3:
	cmp	al,'B'
	jne	sop_4
	mov	BootFlag,1
sop_4:
	cmp	al,'O'
	jne	sop_5
	mov	PoliFlag,1
sop_5:
	retn

; Scan names of files

Scan_Name:
	cmp	All_Check,0
	je	sn_1
sn_0:
	inc	All_FIles
	clc
	retn
sn_1:
	lodsb
	or	al,al
	jnz	sn_1
	cmp	byte ptr [si-5],'.'
	jne	sn_exit
	mov	ax,[si-4]
	and	ax,0DFDFh
	mov	cl,[si-2]
	and	cl,0DFh
	cmp	ax,'OC'
	je	sn_3
	cmp	ax,'XE'
	je	sn_4
	cmp	ax,'YS'
	je	sn_5
	cmp	ax,'VO'
	je	sn_0
	cmp	ax,'IB'
	jne	sn_exit
	cmp	cl,'N'
	jmp	cmp_name
sn_3:
	cmp	cl,'M'
cmp_name:
	je	sn_0
sn_exit:
	stc
	retn
sn_4:
	cmp	cl,'E'
	jmp	cmp_name
sn_5:
	cmp	cl,'S'
	jmp	cmp_name

; Error procedure

Error:
	mov	ax,CodeErr
	cmp	Ill_Byte,0
	je	erloc_0
	push	word ptr ds:Flag
	popf
	jnc	erloc_2
	cmp	al,5
	je	erloc_2
	cmp	al,29
	je	erloc_2
	cmp	al,19
	je	erloc_2
erloc_0:
	lea	dx,Error_Read
erloc_1:
	call	Print
	call	PrintCR
	mov	Ill_Byte,0
	stc
	retn
erloc_2:
	lea	dx,Error_Write
	jmp	erloc_1

; Push all registers to stack

Push_All:
	pop	cs:Work
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp
	push	ds
	push	es
pop_1:
	jmp	cs:Work

; Pop all registers from stack

Pop_All:
	pop	cs:Work
	pop	es
	pop	ds
	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	jmp	pop_1

; Convert value from BIN to ASCII format

Bin_ASCII:
	lea	si,Buffer
	push	dx
	push	di
	push	ax
	mov	cx,5
	mov	di,si
	mov	al,20h
	rep	stosb
	pop	ax
	push	bx
	mov	bx,10
clr_dvd:
	xor	dx,dx
	div	bx
	add	dx,'0'
	dec	di
	mov	[di],dl
	or	ax,ax
	jnz	clr_dvd
	pop	bx
	pop	di
	pop	dx
	retn

; Scan Self body

Scan_Self:
	xor	di,di
	mov	es,[di+2Ch]
	xor	ax,ax
scse_1:
	xor	cx,cx
	dec	cx
	repne	scasb
	scasb
	jnz	scse_1
	inc	di
	inc	di
	mov	si,di
	push	es
	pop	ds
	push	cs
	pop	es
	lea	di,File_Name
	push	di
scse_2:
	lodsb
	or	al,al
	stosb
	jne	scse_2
	pop	si
	push	cs
	pop	ds
	inc	Byte_Cure
	call	Sub_Cure
	dec	Byte_Cure
	dec	All_Files
	cmp	Find_Vir,0
	jne	scse_4
	mov	dx,si
	mov	ax,3D00h
	int	21h
	jnc	scse_5
scse_3:
	lea	dx,Cannot_Self
	call	Print
scse_4:
	lea	di,File_Name
	xor	al,al
	mov	cx,64
	rep	stosb
	retn
scse_5:
	xchg	bx,ax
	lea	dx,Main_Buffer
	mov	cx,12
	mov	ah,3fh
	int	21h
	jc	scse_3
	cmp	ax,cx
	jne	scse_3
	mov	si,dx
	cmp	byte ptr [si],0E9h
	je	AttVir
	cmp	byte ptr [si],0EBh
	je	AttVir
	cmp	byte ptr [si],0E8h
	je	AttVir
	mov	cl,7
	add	si,cx
	lea	di,CompBuffer
	repe	cmpsb
	je	scse_4
AttVir:
	lea	dx,Attention_Self
	call	Print
	call	Get_Key
scse_6:
	cmp	al,'Y'
	je	scse_7
	inc	sp
	inc	sp
	retn
scse_7:
Reboot	db	0EAh,0F0h,-1,0,0F0h

; Print info about working

Print_Info:
	mov	ah,0Fh
	int	10h
	mov	ah,3
	int	10h
	xor	dl,dl
	mov	ah,2
	int	10h
	mov	cx,50h
	mov	ax,0A20h
	int	10h
	lea	dx,Allstring
	call	Print
	mov	ax,All_Files
	lea	si,Buffer
	call	Bin_ASCII
	call	Print_Char
	lea	dx,FindString
	call	Print
	mov	ax,Find_Vir
	mov	Save_Vir,ax
	call	Bin_ASCII
	call	Print_Char
	lea	dx,Curestring
	call	Print
	mov	ax,Cure_Files
	call	Bin_ASCII
	call	Print_Char
	lea	dx,Delstring
	call	Print
	mov	ax,Del_Files
	call	Bin_ASCII
	call	Print_Char
	xor	ax,ax
	mov	Del_Files,ax
	mov	Cure_Files,ax
	mov	Find_Vir,ax
	mov	All_Files,ax
	retn
Print_Char:
	mov	cx,5
NextPrnCh:
	lodsb
	mov	ah,0Eh
	int	10h
	loop	NextPrnCh
	mov	ax,0E0Dh
	int	10h
	mov	ax,0E0Ah
	int	10h
	retn

; Get key ASCII-code (Y or N)

Get_Key:
	mov	ax,0C08h
	int	21h
	and	al,0DFh
	cmp	al,'Y'
	je	ok_key
	cmp	al,'N'
	jne	get_key
ok_key:
	retn

; Modify data area to main ASCII code table

Screen_Code_Table:
	mov	cl,ds:[80h]
	xor	ch,ch
	jcxz	Alter_Code
	mov	si,81h
Next_Load:
	lodsb
	cmp	al,'/'
	je	Option
	loop	Next_Load
Alter_Code:
	cmp	Help_byte,0
	je	NoHelp
	lea	dx,FullHelp
	call	Print
	call	Res13h
	int	20h
NoHelp:
	retn
Option:
	lodsb
	and	al,0DFh
	cmp	al,'M'
	je	Beg_Conv
	cmp	al,'P'
	je	SetOld13h
	cmp	al,'H'
	jne	Next_Load
	mov	Help_byte,1
	jmp	Next_Load
SetOld13h:
	push	si
	push	cx
	mov	ah,30h
	int	21h
	xchg	ah,al
	cmp	ax,31Eh
	jb	Next_Load
	mov	ax,0FDEFh
	int	13h
	cmp	al,0FEh
	je	End_Prot
	mov	ax,3513h
	int	21h
	mov	new13hlow,bx
	mov	new13hhig,es
	mov	ah,13h
	int	2Fh
	mov	cs:old13hlow,dx
	mov	cs:old13hhig,ds
	mov	ah,13h
	int	2Fh
	lea	dx,Int13h
	mov	ax,2513h
	int	21h
End_Prot:
	push	cs
	pop	es
	pop	cx
	pop	si
	jmp	Next_Load
Beg_Conv:
	lea	bx,MeString
Next_Conv:
	mov	al,[bx]
	inc	bx
	cmp	al,-1
	je	Next_Load
	cmp	al,80h
	jb	Next_Conv
	cmp	al,0B0h
	jae	Another_Conv
	add	al,30h
	mov	[bx-1],al
	jmp	Next_Conv
Another_Conv:
	cmp	al,0F0h
	jae	Next_Conv
	cmp	al,179
	jne	NextChar1
	mov	byte ptr [bx-1],165
	jmp	Next_Conv
NextChar1:
	cmp	al,184
	jne	NextChar2
	mov	byte ptr [bx-1],134
	jmp	Next_Conv
NextChar2:
	cmp	al,190
	jne	NextChar3
	mov	byte ptr [bx-1],140
	jmp	Next_Conv
NextChar3:
	cmp	al,205
	jne	NextChar4
	mov	byte ptr [bx-1],148
	jmp	Next_Conv
NextChar4:
	cmp	al,212
	jne	NextChar5
	mov	byte ptr [bx-1],137
	jmp	Next_Conv
NextChar5:
	cmp	al,213
	jne	Next_Conv
	mov	byte ptr [bx-1],138
	jmp	Next_Conv

; Print String

PrintCR:
	lea	dx,EnterString
Print:
	push	bx
	push	si
	mov	si,dx
	mov	ah,0Fh
	int	10h
	mov	bl,7
NextPrn:
	lodsb
	cmp	al,'$'
	je	EndPrn
	mov	ah,0Eh
	int	10h
	jmp	NextPrn
EndPrn:
	pop	si
	pop	bx
	retn

; Data of program

CompBuffer		db	3Bh,0C4h,73h,79h,8Bh,0C4h,2Dh

Mestring		db	0dh,0ah
			db	'╒═══════════════════════════════╕          131 вирус - тест и лечение.',0dh,0ah
			db	'│     ■■■  DESINFECTOR  ■■■     │    Используйте авторский пакет системных',0dh,0ah
			db	'│   версия 3.61 от 10.12.1996   │    утилит "BashUt". В него входят разно-',0dh,0ah
			db	'│  г.Брест, БрПИ (c) Copyright  │    образные  программы для защиты инфор-',0dh,0ah
			db	'│ Башаримов Андрей Владимирович │    мации  от  вирусов, несанкционирован-',0dh,0ah
			db	'╘═══════════════════════════════╛    ного копирования и т.д. ',0dh,0ah,'$'
help_string		db	0dh,0ah,0ah,' Фоpмат: DESINF [/опции] drive1 [drive2...]',0dh,0ah
			db	' где drive - имя диска ,файла или группы файлов по маске.',0dh,0ah
			db	' Опции:',0dh,0ah
			db	'  A - проверка всех файлов (не только COM,EXE,SYS,BIN,OV*).',0dh,0ah
			db	'  C - проверка с лечением.',0dh,0ah
			db	'  O - проверка на наличие вирусов-мутантов.',0dh,0ah
			db	'  D - запрос на удаление испорченных файлов.',0dh,0ah
			db	'  M - main cirillic coding.',0dh,0ah
			db	'  P - отключить защиту винчестера на время лечения.',0dh,0ah
			db	'  B - не выдавать запрос на повторную проверку дискет.',0dh,0ah
			db	'  H - выдать перечень услуг и условия распространения.',0dh,0ah,0ah
			db	' Ориентирован на вирусы, встречавшиеся в Брестском политехническом институте.',0dh,0ah
			db	' Подробная информация - файл DESINF.DOC'
Enterstring		db	0dh,0ah
			db	'$'
Insufficient		db	7,'Insufficient memory!',0dh,0ah,'$'
Termstring		db	0dh,0ah,'■■■ Ненормальное завершение ■■■',0dh,0ah,'$'
Maska			db	'*.*',0
Ill_String		db	' - болен $'
Cured_String		db	' - ВЫЛЕЧЕН$'
Error_Read		db	7,' - не могу прочитать файл.$'
Error_Write		db	7,' - не могу вылечить. Ошибка записи.$'
Ill_MEMstring		db	7,' В памяти вирус $'
Proverka		db	0dh,0ah,0ah,'Проверка $'
BadString		db	' - испорчен вирусом [Vienna]$'
WhatBad 		db	0dh,0ah,'Лечение невозможно. Удалить файл ?[Y/N]$'
DeleteString		db	' - УДАЛЕН',0dh,0ah,'$'
Cannot_Self		db	7,'- не могу проверить себя!$'
VirBoot 		db	'Вирус в начальном секторе $'
ErrDisk 		db	7,' - ОШИБКА ДИСКА.',0dh,0ah,'$'
LoopIll 		db	'Не могу вылечить. Диск многократно заражен.$'
CntRead 		db	7,'Не могу прочитать начальный сектор диска.',0dh,0ah,'$'
MemDestr		db	7,'Блоки управления памятью разрушены.',0dh,0ah,'$'
Warning 		db	0dh,0ah,7
			db	'При лечении весьма вероятна утеря Boot или MBR.'
WarnCure		db	0dh,0ah,'Попытаться вылечить данный диск, записав стандартный загрузчик?[Y/N]$'
WhatARJ 		db	7,0dh,0ah,'Вирусом возможно испорчены некоторые сектора винчестера.',0dh,0ah
			db	'Просканировать винчестер на предмет их наличия и восстановить данные?[Y/N]$'
WarnMurky		db	'Идет восстановление испорченных секторов винчестера.',0dh,0ah
			db	'Наберитесь терпения. Процедура довольно долгая...',0dh,0ah,'$'
OkMurky 		db	'Процесс успешно завершен.',0dh,0ah,'$'
NextFloppy		db	0dh,0ah,'Проверить еще одну дискету ?[Y/N]$'
Incorrect		db	7,'Incorrect DOS version (< 3.00).',0dh,0ah,'$'
Attention_Self		db	7,7,0dh,0ah,'ВНИМАНИЕ !',0dh,0ah
			db	' Desinfector заражен неизвестным вирусом...',0dh,0ah
			db	'Просьба передать зараженную версию данной программы по адресу:',0dh,0ah
			db	'FIDO  : 2:454/2.175',0dh,0ah
			db	' Перезагружаться ?[Y/N]','$'
NotEnought		db	' - Не хватает памяти для проверки.',0dh,0ah,'$'
Allstring		db	0dh,0ah,'Проверено файлов:$'
Findstring		db	'Найдено вирусов :$'
Curestring		db	'Обезврежено     :$'
Delstring		db	'Стерто файлов   :$'
FullHelp		db	0Dh,0Ah,'    Программа  DESINFECTOR относится  к свободному программному обеспечению.',0Dh,0Ah
			db	'Никакие изменения или дополнения настоящей программы недопустимы без согласия',0Dh,0Ah
			db	'на то ее автора. Автор будет благодарен за предоставленные  отзывы, замечания',0Dh,0Ah
			db	'и предложения по улучшению работы программы.',0Dh,0Ah,0Ah
			db	'Предлагаемые услуги:',0Dh,0Ah
			db	'1) Антивирусная СКОРАЯ ПОМОЩЬ - обнаружение и уничтожение новых вирусов. Вос-',0Dh,0Ah
			db	'становление данных.',0Dh,0Ah
			db	'2) Включение рекламы в настоящую программу.',0Dh,0Ah
			db	'3) Разработка системного  программного обеспечения и систем защиты информа-',0Dh,0Ah
			db	'ции (по желанию заказчика).',0Dh,0Ah,0Dh,0Ah
			db	'Если Вас заинтересовала программа DESINFECTOR, обращайтесь по телефонам:',0Dh,0Ah
			db	'в г. Бресте    -  (0162)  41-70-49  (с 19 до 20)',0Dh,0Ah
			db	'в г. Кобрине   -  (01642)  2-32-12  (с 19 до 21)',0Dh,0Ah
			db	'Для получения новых версии программы - по адресу:',0Dh,0Ah
			db	'FIDO    : 2:454/5.9',0Dh,0Ah,'$'
OutOfDate		db	0Dh,0Ah,7,'ВНИМАНИЕ !!!',0Dh,0Ah,7
			db	'Данная версия программы DESINFECTOR уже устарела. Дальнейшее  ее использование ',0Dh,0Ah
			db	'может привести к тому, что Вы пропустите появление на Вашей  машине нового ви-',0Dh,0Ah
			db	'руса!!! По вопросам  поставки новых версий программы - см. файл DESINF.DOC или',0Dh,0Ah
			db	'запустите DESINFECTOR с опцией /H.',0Dh,0Ah
			db	'Нажмите любую клавишу для продолжения...$'
PleaseCure		db	0Dh,0Ah,7,'Для лечения обнаруженных вирусов запустите DESINF с опцией /C.',0Dh,0Ah,7,'$'
Okay			db	'OK',0Dh,0Ah,'$'
			db	-1			;end byte

; Table of one-code instructions

OneCode db	90h,91h,92h,93h,94h,95h,96h,97h,98h,99h,9Eh,9Fh,0CCh,0CEh,0F8h
	db	0F9h,0FAh,0FBh,0FCh,0FDh,26h,27h,36h,37h,41h,42h,43h,44h,45h,46h
	db	47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh,0F0h,0F5h,2Eh,2Fh,3Eh,3Fh
LenOne	equ	$-OneCode
TwoCode dw	5850h,5951h,5A52h,5B53h,5C54h,5D55h,5E56h,5F57h
LenTwo	equ	$-TwoCode

include desinf.sig

; Another data

len_prg 	equ	$-loc_beg
DataSegment		dw	?
WorkSegment		dw	?
SaveUMB 		dw	?
NoMCB			db	?
RefreshByte		db	?
CompEndSeg		dw	?
BootFlag		db	?
SaveCyl 		dw	?
SaveHead		db	?
SaveSec 		db	?
SaveSP			dw	?
SaveOff 		dw	?
Kind_Len		dw	?
Saved_DTA_File		dw	?
Saved_DTA_Directory	dw	?
Entry_low		dw	?
Help_Byte		db	?
FloppyDisk		db	?
WriteByte		db	?
BreakByte		db	?
SavedCOM2		dw	?
SavedLen2		db	?
Disk			db	?
LoopByte		db	?
COMFlag 		db	?
LoopHead		db	?
Sector			dw	?
Head			db	?
Entry_high		dw	?
Saved_COMstring 	dw	?
All_Files		dw	?
Find_Vir		dw	?
Save_Vir		dw	?
Cure_Files		dw	?
Del_Files		dw	?
Byte_Cure		db	?
All_Check		db	?
Byte_Delete		db	?
Mask_Byte		db	?
PoliFlag		db	?
Work			dw	?
Saved_Low		dw	?
Saved_High		dw	?
Saved_Time		dw	?
Saved_Date		dw	?
Saved_Att		dw	?
Ill_Byte		db	?
CodeErr 		dw	?
Flag			dw	?
Work_Len_Low		dw	?
Work_Len_High		dw	?
old_01h_off		dw	?
old_01h_seg		dw	?
StoreSegm		dw	?
Buffer			db	18h dup (?)
Save_Head		db	1Ah dup (?)
Saved_Table		db	128 dup (?)
File_Name		db	200h dup (?)
DTA_file		db	0C00h dup (?)
DTA_directory		db	0C00h dup (?)
DiskBuffer		db	200h dup (?)
DiskBuffer1		db	200h dup (?)
Main_Buffer		db	1000h dup (?)
			db	400h dup (?)
Len_Prog:

; End of program

	end
