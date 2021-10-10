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

extrn TUNNEL:proc

MAIN    SEGMENT BYTE
        ASSUME cs:main,ds:main,ss:nothing      ;all part in one segment=com file
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

FIRST_MSG      db  'ออออออออออออออออออออออออออออออออ',13d,10d
               db  '  K”hntarK',027h,'s Tunneling Toolkit  ',13d,10d
               db  '    Version 4.1 DEMO (C) 1993   ',13d,10d
               db  'ออออออออออออออออออออออออออออออออ',13d,10d,13d,10d,'$'

OK_MSG             db  'INT 21h not hooked. ',13d,10d,'$'
FOUND_MSG          db  'ORIGINAL INT 21h FOUND! ',13d,10d,'$'
OFFSET_MSG         db  'INT 21h OFFSET FOUND:  ','$'
SEGMENT_MSG        db  13d,10d,'INT 21h SEGMENT FOUND: ','$'
SAD_MSG            db  'COULDN',027h,'T FIND INT 21h ! ',13d,10d,'$'
RECURSION_DEPT_MSG db  13d,10d,'RECURSION DEPT: ','$'
TROUBLE_MSG        db  'Internal DOS interrupts hooked ',13d,10d,'$'

INT_21_OFF         dw  0      
INT_21_SEG         dw  0      

MAIN ENDS
     END START
