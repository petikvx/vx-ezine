;VECTOR - Interrupt Vector address listing utility
;by KohnTarK for Crypt Newsletter 17.

;After staring endlessly at the vector interrupt table using 
;memory editors and dump programs, I realized that as blindness approached 
;humans aren't meant to do such things such as counting 
;on fingers and pointing at the screen with pencils. So I wrote a quick 
;& dirty utility that will output the segments and offsets of all 
;interrupt vectors in hexadecimal notation.

;This is especially useful when writing resident code or dealing with
;resident Anti-Virus software, and trying to figure out what vectors 
;are hooked the specific addresses for tracing purposes.


;USAGE:

;vector |more 

;(DOS's MORE directory has to be in the PATH) will output the
;interrupt vectors one screenful at the time.


;vector > <filename>  (No, you don't type the <>'s)

;will output the interrupt vectors to <filename>
;<filename> is useful to keep as a reference of different DOS versions, 
;memory configurations, resident AV programs etc. etc.

;$

;****************************************************************************
;
; VECTOR.ASM
; AUTHOR: K$hntark
; DATE:   10 APRIL 93
; Assemble & link with Turbo Assembler.
;****************************************************************************

MAIN    SEGMENT BYTE
        ASSUME cs:main,ds:main,ss:nothing      ;all part in one segment=com file
        org    100h

VECTORS:
            

         mov  ah,09     ;print message
         lea  dx,[START]
         int  21h

          xor  di,di                     ;interrupt count
          xor  bx,bx
          push bx
          pop  es                        ;es = 0000
          mov  cx,0FFh                   ;#of vectors = 256 = FF
          mov  si,0000                   ;starting offset
          
LOOP1:
          mov  bx,es:WORD PTR[si]   ;put vector's offset of in xx
          call PRINT_MSG1
          call BIN_TO_HEX

          
          mov  bx,es:WORD PTR[si+2]  ; put vector's segment in bx
          call  PRINT_MSG2
          call  BIN_TO_HEX        

          add si,4

          loop LOOP1

          int 20h

;****************************************************************************
PRINT_MSG1:
            push ax
            
            mov  ah,09     ;print carriage return
            lea  dx,[CR]
            int  21h
            

                           ;print carriage return
            int  21h
            
            
                           ;print INTERRUPT # message
            lea  dx,[INT_NUM]
            int  21h
            
            push bx         ;print int #
            mov  bx,di
            call BIN_TO_HEX
            inc  di
            pop  bx
            
            mov  ah,09     ;print carriage return
            lea  dx,[CR]
            int  21h
            
            mov  ah,09       ;print OFFSET

            lea  dx,[MSG1]
            int  21h

            pop  ax
            ret

;****************************************************************************
PRINT_MSG2:
            push ax
            
            mov  ah,09     ;print carriage return
            lea  dx,[CR]
            int  21h
            
            ;mov  ah,09     ;print message
            lea  dx,[MSG2]
            int  21h
            


            pop  ax
            ret

;****************************************************************************
; display # on bx

BIN_TO_HEX:
            push cx
            push dx
            
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
            mov ah,2
            int 21h
            dec ch
            jnz ROTATE

            pop  dx
            pop  cx
            ret
;****************************************************************************

START    db 'MMMMMMMMMMMMMMMMMMMMMMMMMMM',13d,10d
         db ' VECTORS.COM               ',13d,10d
         db ' Interrupt Vectors Listing ',13d,10d
         db ' (C) 1993 by K$hntark      ',13d,10d 
         db 'MMMMMMMMMMMMMMMMMMMMMMMMMMM','$'
INT_NUM  db 'INTERRUPT # ','$'
MSG1     db  'OFFSET:  ','$'

CR       db  13d,10d,'$'
MSG2     db  'SEGMENT: ','$'


MAIN ENDS
     END VECTORS

