FIND_BOOT_VIRII:
      db 60h
      mov ah,09h
      lea dx,WAR_0
      int 21h
;Чтение сектора в память
                cld
                push cs
                pop es
                push cs
                pop ds
                lea bx, buff
                mov     dx, 80h ; 'А' ; ** VOID **
                mov     cx, 1
                mov     ax, 201h ; ** VOID **
                int     13h             ; DISK - READ SECTORS INTO MEMORY
                                        ; AL = number of sectors to read, CH = track, CL = sector
                                        ; DH = head, DL = drive, ES:BX -> buffer to fill
                                        ; Return: CF set on error, AH = status (see AH=01h), AL = number of sectors read
;Проверка на зараженность
                lea si,SIG_SGB_Olga
                push cx
                xor cx,cx
LOC_1:
                mov al,byte ptr [si]
                cmp byte ptr [bx],al
                jnz      NOT_FOUND
                cmp cx,8
                jz YES_FOUND
                inc si
                inc cx
                inc bx
                jmp short LOC_1
YES_FOUND:
                pop cx
                mov ah,09h
                lea dx,WAR_1
                int 21h
Read_Source_Sector:
                lea bx, buff
                mov     dx, 80h ; 'А' ; ** VOID **
                mov     cl, 4
                mov     ax, 201h ; ** VOID **
                int     13h             ; DISK - READ SECTORS INTO MEMORY
                                        ; AL = number of sectors to read, CH = track, CL = sector
                                        ; DH = head, DL = drive, ES:BX -> buffer to fill
                                        ; Return: CF set on error, AH = status (see AH=01h), AL = number of sectors read
Write_Source_Sector:
                lea bx, buff
                mov     dx, 80h ; 'А' ; ** VOID **
                mov     cx, 1
                mov     ax, 301h ; ** VOID **
                int     13h             ; DISK - WRITE SECTORS INTO MEMORY
                                        ; AL = number of sectors to read, CH = track, CL = sector
                                        ; DH = head, DL = drive, ES:BX -> buffer to fill
                                        ; Return: CF set on error, AH = status (see AH=01h), AL = number of sectors read

                mov     cx, 1
                mov     ax, 305h ; ** VOID **
                int     13h             ; DISK - WRITE SECTORS INTO MEMORY

                db 61h
                ret
NOT_FOUND:
                pop cx
                mov ah,09h
                lea dx,WAR_2
                int 21h
                db 61h
                ret
