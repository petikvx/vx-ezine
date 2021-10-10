
; This program is a part of the
;             Anti-Debugging and Anti-Emulating Lair
;             (C) by lord julus (1998)
;
; Try new stuff at: http://members.tripod.com/~lordjulus
;
;
; Using the Taylor formulae to compute EXP(X) using the FPU instructions.
; The Taylor procedure calculates EXP(3), using a 12 steps depth. You can
; use it to compute other EXP's, but beware on the size of the results.
; The method used is described in my article Lord's Anti-debugging and
; Anti-emulator Lair.
; The procedure computes EXP(3) = 20.085212707519531, while the real value
; is EXP(3) = 20.08553692300.
; The procedure returns the integer value into AX (e.g. 20) and the real
; value is left on the ST(1) FPU stack register
;
; Well, after a little alteration of this program I found out that I can
; reliably compute the integer part of EXP(x) with 0<=x<=5
;
;      x   |  exp(x)
;      ----+---------
;      0   |      1  (0001h)
;      1   |      3  (0003h)
;      2   |      7  (0007h)
;      3   |     20  (0014h)
;      4   |     55  (0037h)
;      5   |    148  (0094h)
;
;      These values are round(exp(x)) computed with a pocket calculator
; Now run this program and see what you get on the screen...
;
;      Of course you may try higher values or bigger depths for the calculus
; but you must be sure what you are using them for. A too big approx. on
; a certain CPU could be something else on another CPU...
;
;      This procedure is used in FPU.Taylor.Crypt Algorithm
;
; Compile this with:
;                    TASM /m3 /o taylor.asm
;                    TLINK /x taylor
;                                           ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;                                           ³   Lord Julus - 1998  ³
;                                           ÀÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÙ
;

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
               fwait                         ; clear 0! exception.
               cmp cx, 0                     ;
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
               mov eax, counter              ; we compute EXP(3)
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
               call hexword                  ; print AX on screen
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
realstart:                                   ;
         mov dword ptr [counter], 0          ; start from EXP(0)
                                             ;
repeat_call:                                 ;
         call Taylor                         ; compute EXP(x)
         inc dword ptr [counter]             ; increase counter
         cmp dword ptr [counter], 06h        ; until EXP(5)
         jne repeat_call                     ;
         mov ax, 4c00h                       ;
         int 21h                             ;
                                             ;
include hexword.asm                          ; routine to print words in
end start                                    ; hexa on screen
end                                          ;
;___________________________________________/"\______________________________