
; This program is a part of the
;             Anti-Debugging and Anti-Emulating Lair
;             (C) by lord julus (1998)
;
; Try new stuff at: http://members.tripod.com/~lordjulus
;
;
; In order to understand all of the below code you should have my article
; called 'Lord's Anti-debuggin and Anti-emulator Lair'.
;
; This code kinda like speaks for itself. It's strength resides in the huge
; amount of mathematical calculations made by the coprocessor. Basically the
; encryptor itself is very weak, it's only a demo for what you could do.
; It uses the result of cos(90) to increase the pointer in the code.
;
; Compile with:
;                       TASM /m3 /o taylor_c.asm
;                       TLINK /x taylor_c
;
;                                           ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;                                           ³   Lord Julus - 1998  ³
;                                           ÀÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÙ


title FPU.Pythagora.CRYPT by Lord Julus (C) 1998

.386                                         ; all the needed stuff
.387                                         ;
.model tpascal                               ;
.code                                        ;
                                             ;
org 0                                        ;
                                             ;
start:                                       ;
         Jmp realstart                       ;
                                             ;
Arcsin proc near                             ; Compute arcsin(number)
         finit                               ; initialize FPU
         fld dword ptr [number]              ; load the number
         fld dword ptr [number]              ;
         fmul                                ; make it ^2
         fld1                                ; load 1
         fsub st, st(1)                      ; compute 1-N^2
         fsqrt                               ; compute sqrt(1-N^2)
         fld dword ptr [number]              ; load N again
         fxch st(1)                          ; xchange ST(1) w/ ST(0)
         fpatan                              ; compute ARCTAN(N/(sqrt(1-N^2))
         fwait                               ;
         nop                                 ;
         ret                                 ; which equals Arcsin(N)
Arcsin endp                                  ;
                                             ;
Arccos proc near                             ; the same ideea, only the
         finit                               ; formula is
         fld dword ptr [number]              ; ARCTAN(sqrt(1-N^2))/N)
         fld dword ptr [number]              ;
         fmul                                ;
         fld1                                ;
         fsub st, st(1)                      ;
         fsqrt                               ;
         fld dword ptr [number]              ;
         fpatan                              ;
         fwait                               ;
         nop                                 ;
         ffree st(1)                         ;
         ret                                 ;
Arccos endp                                  ;
                                             ;
Pyt proc near                                ;
         call randomize                      ;
         mov cx, 4                           ; compute random m and n
         call random                         ;
         inc ax                              ;
         mov word ptr [m], ax                ;
         mov cx, 4                           ;
         call random                         ;
         inc ax                              ;
         mov word ptr [n], ax                ;
                                             ;
         finit                               ; initialize FPU
         fild word ptr [n]                   ; load the root numbers M and N
         fild word ptr [m]                   ;
         fild word ptr [n]                   ;
         fild word ptr [m]                   ;
         fmul st, st(2)                      ; M*M
         fincstp                             ;
         fmul st, st(2)                      ; N*N
         fdecstp                             ;
         fadd st, st(1)                      ; M*M + N*N
         fist word ptr [a]                   ; store it to a
         fsub st, st(1)                      ;
         fsub st, st(1)                      ;
         fabs                                ; |M*M - N*N|
         fist word ptr [c]                   ; store it to c
         fincstp                             ;
         fincstp                             ;
         fmul                                ;
         fimul word ptr [two]                ; 2*M*N
         fist word ptr [b]                   ; store it to b
         finit                               ; Now a^2 = b^2 + c^2
         fwait                               ;
         fild word ptr [c]                   ;
         fild word ptr [a]                   ;
         fdiv                                ; compute c/a
         fst dword ptr [number]              ;
         call arccos                         ; compute arccos(c/a)
         fst dword ptr [_B]                  ;
         call arcsin                         ; compute arcsin(c/a)
         fst dword ptr [_C]                  ;
         finit                               ;
         fwait                               ;
         fld dword ptr [_B]                  ;
         fcos                                ; cos(arccos(c/a))
         fld dword ptr [_C]                  ;
         fcos                                ; cos(arcsin(c/a))
         fmul                                ; cos(B)*cos(C)
         fld dword ptr [_B]                  ;
         fsin                                ; sin(arccos(c/a))
         fld dword ptr [_C]                  ;
         fsin                                ; sin(arcsin(c/a))
         fmul                                ; sin(B)*sin(C)
         fadd                                ; cos(B+C)
         frndint                             ; round(cos(B+C)) = 1
         fistp word ptr [result]             ;
         mov ax, word ptr [result]           ;
         cmp ax, 0                           ; correct approx.
         je correct                          ;
         ret                                 ;
correct:                                     ;
         inc ax                              ;
         ret                                 ;
M dw 0                                       ; Root numbers M and N
N dw 0                                       ;
a dw ?                                       ; Pythagora's triplet
b dw ?                                       ;
c dw ?                                       ;
two dw 2                                     ;
number dd 0                                  ;
_B dd 0                                      ;
_C dd 0                                      ;
result dw 0                                  ;
Pyt endp                                     ;
                                             ;
Print_text proc near                         ; Procedure to print an
         mov ah, 0                           ; ASCIIZ string on screen
         mov al, 3                           ;
         int 10h                             ;
         push cs                             ;
         pop ds                              ;
         push dx                             ;
         mov si, offset text                 ;
         mov ah, 0eh                         ;
         mov cx, text_len                    ;
                                             ;
rep_print:                                   ;
         mov al, byte ptr cs:[si]            ;
         cmp bx, 2                           ;
         jne no_matter                       ;
         cmp al, 32                          ;
         ja no_matter                        ;
         mov al, '.'                         ;
no_matter:                                   ;
         int 10h                             ;
         inc si                              ;
         loop rep_print                      ;
                                             ;
ready:                                       ;
         cmp bx, 1                           ;
         jne not_bx_1                        ;
         mov dx, offset text1                ;
         jmp print_string                    ;
                                             ;
not_bx_1:                                    ;
         cmp bx, 2                           ;
         jne not_bx_2                        ;
         mov dx, offset text2                ;
         jmp print_string                    ;
                                             ;
not_bx_2:                                    ;
         cmp bx, 3                           ;
         mov dx, offset text3                ;
                                             ;
print_string:                                ;
         mov ah, 09h                         ;
         int 21h                             ;
         mov ah,1                            ;
         int 21h                             ;
         pop dx                              ;
         ret                                 ;
Print_text endp                              ;

; Note: The encryption procedure and the decryption one are exactly the
; same (that's because I used a XOR algorithm). However, I used two
; procedures so you can try out your own ways of encryption/decryption

Encrypt proc near                            ; The encryption procedure
         push cs cs                          ;
         pop ds ds                           ;
         mov bx, offset text                 ;
         sub bx, 1                           ;
         mov ecx, text_len                   ;
         sub ecx, 4                          ;
repeat_crypt:                                ;
         push cx                             ;
         call Pyt                            ; compute EXP(EDX)
         add bx, ax                          ; increment pointer
         add al, byte ptr key                ; increase key with result
         xor byte ptr [bx], al               ; xor the code
         add byte ptr [key], 3               ; increase key with 3
         pop cx                              ;
         loop repeat_crypt                   ;
         ret                                 ;
Encrypt endp                                 ;
                                             ;
Decrypt proc near                            ; same proc...
         push cs cs                          ;
         pop ds ds                           ;
         mov bx, offset text                 ;
         sub bx, 1                           ;
         mov ecx, text_len                   ;
         sub ecx, 4                          ;
repeat_decrypt:                              ;
         push cx                             ;
         Call Pyt                            ;
         add bx, ax                          ;
         add al, byte ptr key                ;
         xor byte ptr [bx], al               ;
         add byte ptr [key], 3               ;
         pop cx                              ;
         loop repeat_decrypt                 ;
         ret                                 ;
Decrypt endp                                 ;
                                             ;
                                             ;
                                             ;
realstart:                                   ;
         call randomize                      ; initialize random nr. gen.
         mov cx, 250d                        ;
         call random                         ;
         mov byte ptr [key], al              ;
         push ax                             ;
         mov bx, 1                           ;
         call print_text                     ;
         call encrypt                        ;
         mov bx, 2                           ;
         call print_text                     ;
         pop ax                              ;
         mov byte ptr [key], al              ;
         call decrypt                        ;
         mov bx, 3                           ;
         call print_text                     ;
         mov ax, 4c00h                       ;
         int 21h                             ;

 text: db 0ah, 0dh, 0ah, 0dh
       db 'ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·',0ah,0dh
       db 'º   My glass shall not persuade me I am old               º',0ah,0dh
       db 'º   So long as youth and thou are one of date             º',0ah,0dh
       db 'º   But when in thee time''s furrows I behold              º',0ah,0dh
       db 'º   Then look I death my days should expiate              º',0ah,0dh
       db 'º   For all that beauty that doth cover thee              º',0ah,0dh
       db 'º   Is but the seemly raiment of my heart                 º',0ah,0dh
       db 'º   Which in my breast doth leave, as thine in me:        º',0ah,0dh
       db 'º   How can I, then, be elder than thou art?              º',0ah,0dh
       db 'º   O, therefore, love, be of thyself so wary             º',0ah,0dh
       db 'º   As I, not for myself, but for thee will;              º',0ah,0dh
       db 'º   Bearing thy heart, which I keep so chary              º',0ah,0dh
       db 'º   As tender nurse her babe from faring ill.             º',0ah,0dh
       db 'º     Presume not on thy heart when mine is slain.        º',0ah,0dh
       db 'º     Thou gave me thine, not to give back again.         º',0ah,0dh
       db 'º                (Willian Shakespeare - Sonnet XXII)      º',0ah,0dh
       db 'ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½',0ah,0dh,0ah,0dh,0ah,0dh

 text_len equ $-text

text1 db 'This is the initial unencrypted text.',0ah,0dh
      db 'Press space to see it encrypted...',0ah,0dh,0ah,0dh,'$'
text2 db 0ah,0dh,0ah,0dh,'This is the encrypted text. ("." character marks unprintable chars)',0ah,0dh
      db 'Press space to see it decrypted now...',0ah,0dh,0ah,0dh,'$'
text3 db 'This is the initial text unencrypted.',0ah,0dh
      db 'Press space to exit...',0ah,0dh,0ah,0dh,'$'
key   db 0

include hexword.asm                          ; routine to print hexa words
include random.asm                           ; random routine
end start                                    ;
end                                          ;
;___________________________________________/"\______________________________