
; This program is a part of the
;             Anti-Debugging and Anti-Emulating Lair
;             (C) by lord julus (1998)
;
; This little program here demonstrates the quickness of the memory movement
; using FPU instructions. This little program moves 24,000 bytes from one
; buffer to another using a loop.
;
; Try new stuff at: http://members.tripod.com/~lordjulus
;
;
;                                            ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;                                            ³  Lord Julus - 1998 ³
;                                            ÀÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÙ



.386                                      ;
.387                                      ;
.model Tpascal                            ;
.code                                     ;
                                          ;
start:                                    ;
             jmp realstart                ;
                                          ;
buffer1 db 24*1000 dup ('A')              ; source buffer
buffer2 db 24*1000 dup ('B')              ; destination buffer
                                          ;
realstart:                                ;
             nop                          ;
             nop                          ;
             push cs cs                   ; CS = ES = DS
             pop ds es                    ;
             lea esi, buffer1             ; get first buffer's address
             lea edi, buffer2             ; get second buffer's address
             mov ecx, 24*1000             ; counter
                                          ;
mov_loop:                                 ;
             fild qword ptr [esi]         ; take a qword
             fild qword ptr [esi+8]       ; and another
             fxch                         ; exchange ST(0) with ST(1)
             fistp qword ptr es:[edi]     ; and store them to destination
             fistp qword ptr es:[edi+8]   ;
             add edi, 16                  ; increment with 16
             add esi, 16                  ;
             sub ecx, 16                  ; and decrement counter
             jns mov_loop                 ; gone below 0 yet ?
                                          ;
             mov ax, 4c00h                ; end.
             int 21h                      ;
                                          ;
end start                                 ;
end                                       ;