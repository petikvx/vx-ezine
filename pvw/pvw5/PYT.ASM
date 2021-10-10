
; This program is a part of the
;             Anti-Debugging and Anti-Emulating Lair
;             (C) by lord julus (1998)
;
; This is a program that demonstrates the propriety of the Pythagora's
; numbers to form triplets which used as a triangle's sides create a
; triangle with one 90ø angle. The program will generate a set of a, b, c
; Pythagora's numbers (you can change them by modifying the root numbers
; m and n, or adding a random routine). Then the program will compute
; cosine(B+C), where B+C = 90ø. The result should be 0. Actually, due to the
; approximations it's sometimes 0, sometimes 1. I took care of that and now
; no matter what m and n you choose a 1 is placed into AX.
; All the formulas used in this program are presented in the article
; A-D & A-E Lair. Also, check the article for the instruction's description.
;
; The PYT Procedure is used in the FPU.Pythagoras.Crypt Algorithm
;
; Try new stuff at: http://members.tripod.com/~lordjulus
;
;
;                                            ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;                                            ³  Lord Julus - 1998 ³
;                                            ÀÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÙ


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
         ffree st(1)                         ;
         ret                                 ;
Arccos endp                                  ;
                                             ;
Pyt proc near                                ;
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
         frndint                             ; round(cos(B+C)) = 0 or 1
         fistp word ptr [result]             ; (for m=1/n=2 result is 1)
         mov ax, word ptr [result]           ;
         ret                                 ;
M dw 1                                       ; Root numbers M and N
N dw 2                                       ;
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
realstart:                                   ;
         call pyt                            ;
         mov ax, 4c00h                       ;
         int 21h                             ;
                                             ;
end start                                    ;
end                                          ;