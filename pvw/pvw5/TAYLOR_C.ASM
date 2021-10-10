
; This program is a part of the
;             Anti-Debugging and Anti-Emulating Lair
;             (C) by lord julus (1998)
;
; Try new stuff at: http://members.tripod.com/~lordjulus
;
; This is the program that really demonstrates the use of the Taylor
; formula for computing EXP(X) in encryption. When you run this program
; a text will be displayed on the screen. Yo'll have to press a key to
; see then the same text, but encrypted. Then another keypress and you
; will see the text decrypted again... You will notice the quickness of
; the algorithm and the fact that no code-emulator can emulate it.
;
; Of course, this is just a small ideea in the sea of posibilities. Here
; I compute EXP(0..5) and I add the result to the sliding key. This can
; be easily bypassed by an av by adding the known results of the calculus
; from a table. But... this is because he knows this source. If you make
; your own and make use of the info and ideas here it's gonna be hell tough
; to be beat up !
;
; But... ;-) always a but !! Starting from EXP(6) the Taylor procedure does
; not compute anymore the correct answer... Ring a bell ? I'll tell you:
; use the Taylor procedure to compute EXP(x) with x until 15 or something.
; In this way, the result given by the procedure will always be different
; from a result given by a pocket calculator... The av guy doesn't know that,
; however. Check it for yourself. I set this program up to compute EXP(x)
; until x = 10... And also notice that by modifying the depth of the Taylor
; formula you can obtain different values ! Make it random !
;
; As you see I do not use a buffer to move code and encrypt. I simply
; encrypt it and then decrypt it at the same address. The movement of
; the code could slow down the process but unnoticeable.
;
; In order to understand all of the below code you should have my article
; called 'Lord's Anti-debuggin and Anti-emulator Lair'.
;
; Compile with:
;                       TASM /m3 /o taylor_c.asm
;                       TLINK /x taylor_c
;
;                                           ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;                                           ³   Lord Julus - 1998  ³
;                                           ÀÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÙ


title FPU.TAYLOR.CRYPT Algorithm by Lord Julus (C) 1998

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
Factorial proc near                          ; This procedure computes
                                             ; N!, where N is stored into
               finit                         ; the ECX register.
               fwait                         ; syncronize FPU/CPU
               cmp cx, 0                     ; clear 0! exception.
               je exit_1                     ;
               fild dword ptr [m]            ; load value 1
               fild dword ptr [m]            ; three times
               fild dword ptr [m]            ;
                                             ;
repeat_factorial:                            ;
               fmul st(1), st                ; multiply by the base
               fadd st, st(2)                ; increase the base
               loop repeat_factorial         ; and repeat
               fincstp                       ; mov ST(1) to ST(0)
               fistp dword ptr [m]           ; store the result
                                             ;
exit_1:                                      ;
               mov eax, dword ptr [m]        ; and get it into EAX
               mov dword ptr [m], 1          ;
               ret                           ;
                                             ;
m dd 1                                       ;
Factorial endp                               ;
                                             ;
                                             ;
Power Proc Near                              ; This computes EAX to the power
               finit                         ; of ECX.
               fwait                         ;
               cmp cx, 0                     ; clear 0^n and n^0 exceptions
               je exit_3                     ;
               cmp cx, 1                     ;
               je exit_2                     ;
               mov dword ptr [n], eax        ; save the initial EAX
               fild dword ptr [n]            ; and reload it two times
               fild dword ptr [n]            ;
               dec cx                        ; a little correction is needed
                                             ;
repeat_power:                                ;
               fmul st, st(1)                ; multiply the number by itself
               loop repeat_power             ; CX times.
               fistp dword ptr [n]           ; and store the result
                                             ;
exit_3:                                      ;
               mov eax, dword ptr [n]        ;
               mov dword ptr [n], 1          ;
                                             ;
exit_2:                                      ;
               ret                           ;
                                             ;
n dd 1                                       ;
Power Endp                                   ;
                                             ;
Taylor Proc near                             ; The main procedure
               push cx                       ;
               finit                         ; Initialize FPU
               fwait                         ;
               Mov cx, 12                    ; the depth of the algorithm
                                             ;
rep_taylor:                                  ;
               push cx                       ; save the CX register
               mov eax, counter              ; we compute EXP(X)
               call power                    ; compute EAX^ECX
               mov dword ptr [temp1], eax    ; store temporary result
               pop cx                        ; restore ECX
               push cx                       ;
               mov eax, ecx                  ;
               call factorial                ; Compute ECX!
               mov dword ptr [temp2], eax    ; store the temporary result
               finit                         ; reinitialize FPU
               fild dword ptr [temp1]        ; load the two temporary results
               fild dword ptr [temp2]        ;
               fdiv                          ; and divide them (X^n / n!)
               fld dword ptr [rez]           ; then load the number in REZ
               fadd                          ; and add the division result
               fst dword ptr [rez]           ; and then store it as float
               pop cx                        ; restore counter
               dec cx                        ; and decrease it.
               cmp cx, 0FFFFh                ; I used this trick because I
               jne rep_taylor                ; needed a step also with cx=0
               fld dword ptr [rez]           ; load the final result
               frndint                       ; and round it to nearest integer
               fist word ptr [taylor_rez]    ; store it
               mov ax, word ptr [taylor_rez] ; and put it into ax
               mov dword ptr [taylor_rez], 0 ; clear these addresses
               mov dword ptr [rez], 0        ;
               pop cx                        ; restore CX
               ret                           ; (only AX get's changed here)
                                             ;
taylor_rez dw 0                              ;
rez dd 0                                     ;
temp1 dd 0                                   ;
temp2 dd 0                                   ;
Taylor Endp                                  ;
counter dd 0                                 ;
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
         mov ecx, text_len                   ;
         sub ecx, 4                          ;
         mov edx, 0                          ;
repeat_crypt:                                ;
         mov dword ptr [counter], edx        ;
         call Taylor                         ; compute EXP(EDX)
         add al, byte ptr key                ; increase key with result
         xor byte ptr [bx], al               ; xor the code
         add byte ptr [key], 3               ; increase key with 3
         inc edx                             ; increase x for EXP(x)
         cmp edx, 11                         ; and make it 0 if we gone
         jne over1                           ; over 10
         mov edx, 0                          ;
over1:                                       ;
         inc bx                              ; increment pointer
         loop repeat_crypt                   ;
         ret                                 ;
Encrypt endp                                 ;
                                             ;
Decrypt proc near                            ; same proc...
         push cs cs                          ;
         pop ds ds                           ;
         mov bx, offset text                 ;
         mov ecx, text_len                   ;
         sub ecx, 4                          ;
         mov edx, 0                          ;
repeat_decrypt:                              ;
         mov dword ptr [counter], edx        ;
         call Taylor                         ;
         add al, byte ptr key                ;
         xor byte ptr [bx], al               ;
         add byte ptr [key], 3               ;
         inc edx                             ;
         cmp edx, 11                         ;
         jne over2                           ;
         mov edx, 0                          ;
over2:                                       ;
         inc bx                              ;
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
       db 'º   When to the sessions of sweet silent thought          º',0ah,0dh
       db 'º   I summon up remembrance of things past,               º',0ah,0dh
       db 'º   I sigh the lack of many things I sought               º',0ah,0dh
       db 'º   And with old woes new wail my dear time''s waste:      º',0ah,0dh
       db 'º   Then can I drown an eye, unused to flow               º',0ah,0dh
       db 'º   For precious friends hid in death''s dateless night    º',0ah,0dh
       db 'º   And weep afresh love''s long-since-cancell''d woe,      º',0ah,0dh
       db 'º   And moan the expense of many a vanish sight:          º',0ah,0dh
       db 'º   Then can I grieve at grievances foregone,             º',0ah,0dh
       db 'º   And heavily from woe to woe tell o''er                 º',0ah,0dh
       db 'º   The sad account of fore-bemoaned moan                 º',0ah,0dh
       db 'º   Which I new pay as if not paid before.                º',0ah,0dh
       db 'º     But if the while I think of thee, dear friend.      º',0ah,0dh
       db 'º     All losses are restored, and sorrows end.           º',0ah,0dh
       db 'º                (Willian Shakespeare - Sonnet XXX)       º',0ah,0dh
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