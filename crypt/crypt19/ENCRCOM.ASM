;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;                   Black Wolf's File Protection Utilities 2.1s
;
;EncrCOM - This program encrypts specified file and attaches the decryption
;          code from EN_COM onto the file so that it will decrypt on
;          each execution.  It utilizes ULTIMUTE .93á to protect then EN_COM
;          code from easy manipulation.
;
;LISCENSE:
;    Released As Freeware - These files may be distributed freely.
;
;Any modifications made to this program should be listed below the solid line,
;along with the name of the programmer and the date the file was changed.
;Also - they should be commented where changed.
;
;NOTE THAT MODIFICATION PRIVILEDGES APPLY ONLY TO THIS VERSION (2.1s)!  
;I'd appreciate notification of any modifications if at all possible, 
;reach me through the address listed in the documentation file (bwfpu21s.doc).
;
;DISCLAIMER:  The author takes ABSOLUTELY NO RESPONSIBILITY for any damages
;resulting from the use/misuse of this program/file.  The user agrees to hold
;the author harmless for any consequences that may occur directly or 
;indirectly from the use of this program by utilizing this program/file
;in any manner.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Modifications:
;       None as of 08/05/93 - Initial Release.

.model tiny
.radix 16
.code
       
       org 100

        extrn   _ULTMUTE:near, _END_ULTMUTE:byte, Get_Rand:near
        extrn   Init_Rand:near

start:
        call    GetFilename
        call    Init_Rand
        call    Get_Rand
        mov     [Key1],ax
        call    Get_Rand
        mov     [Key2],ax
        call    Get_Rand
        mov     [Key3],ax
        call    Get_Rand
        mov     [Key4],ax
        call    Do_File
        mov     ax,4c00
        int     21
;---------------------------------------------------------------------------
GetFilename:
        mov     ah,09
        mov     dx,offset Message
        int     21

        mov     dx,offset Filename_Data
        mov     al,60
        call    gets
        ret
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
Message:
        db      'EncrCOM 2.0 (c) 1993 Black Wolf Enterprises.',0a,0dh
        db      'Enter Filename To Protect -> $'
;---------------------------------------------------------------------------
gets:
        mov     ah,0a
        push    bx
        mov     bx,dx
        mov     byte ptr ds:[bx],al
        mov     byte ptr ds:[bx+1],0
        pop     bx
        int     21
        push    bx
        mov     bx,dx
        mov     al,byte ptr ds:[bx+1]
        xor     ah,ah
        add     bx,ax
        mov     byte ptr ds:[bx+2],0
        pop     bx
        ret
;---------------------------------------------------------------------------
Do_File:        
        mov     ax,3d02
        mov     dx,offset Filename
        int     21
        jnc     No_Terminate
        jmp     Terminate
No_Terminate:
        xchg    bx,ax
        call    GetTime
        call    BackupFile

        mov     ah,3f
        mov     cx,4
        mov     dx,offset Storage_Bytes
        int     21

        mov     ax,[Key1] 
        xor     word ptr [Storage_Bytes],ax
        mov     ax,[Key2]
        xor     word ptr [Storage_Bytes+2],ax


        mov     ax,4200
        xor     cx,cx
        xor     dx,dx
        int     21

Encrypt_Entire_File:
        mov     ah,3f        
        mov     cx,400
        mov     dx,offset Encrypt_Buffer                ;Read in buffer full
        int     21

        or      ax,ax
        jz      Add_Protection_Code                     ;None left? leave...
        
        push    ax
        call    EncryptBytes                            ;Encrypt buffer
        pop     ax
        push    ax

        xor     dx,dx
        sub     dx,ax
        mov     cx,0ffff                                ;Go back to where we
        mov     ax,4201                                 ;read from
        int     21

        mov     ah,40
        pop     cx
        mov     dx,offset Encrypt_Buffer                ;Write it back
        int     21

        cmp     ax,400                                  ;Buffer full? loop...
        je      Encrypt_Entire_File

Add_Protection_Code:
        mov     ax,4202
        xor     cx,cx
        xor     dx,dx
        int     21
        sub     ax,3
        mov     word ptr [JumpBytes+1],ax
        
        push    bx        
        mov     si,offset begin_password        ;On Entry -> CS=DS=ES
        mov     di,offset _END_ULTMUTE          ;SI=Source, DI=Destination
        mov     bx,ax                           ;BX=Next Entry Point
        add     bx,103
        mov     cx,end_password-begin_password+1 ;CX=Size to Encrypt
        mov     ax,1                             ;AX=Calling Style
        call    _ULTMUTE                
                                                ;On Return -> CX=New Size
        pop     bx
        
        mov     dx,offset _END_ULTMUTE
        mov     ah,40
        int     21
        
        mov     ax,4200
        xor     dx,dx
        xor     cx,cx
        int     21
        
        mov     ah,40
        mov     cx,4
        mov     dx,offset JumpBytes
        int     21
        

        mov     ax,5701
        mov     cx,word ptr cs:[Time]
        mov     dx,word ptr cs:[Date]
        int     21

        mov     ah,3e
        int     21
        ret

GetTime:
        mov     ax,5700
        int     21
        mov     word ptr cs:[Time],cx
        mov     word ptr cs:[Date],dx
        ret

Terminate:
        mov     ah,09
        mov     dx,offset BadFile
        int     21
        ret
BadFile db      'Error Opening File.',07,0dh,0a,24
JumpBytes       db      0e9,0,0,'á'

EncryptBytes:
        push    ax bx cx dx si di
        
        mov     si,offset Encrypt_Buffer
        mov     di,si
        mov     cx,200

Decrypt_Loop:        
        lodsw
        
        ror     ax,1
        add     ax,[Key4]
        xor     ax,[Key3]
        rol     ax,1
        sub     ax,[Key2]
        xor     ax,[Key1]
        
        stosw
        loop    Decrypt_Loop
        
        pop     di si dx cx bx ax
        ret
Time    dw      0
Date    dw      0

BackupFile:
        mov     si,offset Filename
        mov     cx,80

  Find_Eofn:
        lodsb
        cmp     al,'.'
        je      FoundDot
        or      al,al
        jz      FoundZero
        loop    Find_Eofn
        jmp     Terminate
FoundZero:
        mov     byte ptr [si-1],'.'
        inc     si
FoundDot:
        mov     word ptr [si],'LO'
        mov     byte ptr [si+2],'D'
        mov     byte ptr [si+3],0

        
        mov     dx,offset Filename
        mov     word ptr [SourceF],bx
        mov     ah,3c
        xor     cx,cx
        int     21
        jnc     GCreate
         jmp    Terminate
GCreate:
        mov     word ptr cs:[Destf],ax
BackLoop:
        mov     ah,3f
        mov     bx,word ptr cs:[Sourcef]
        mov     cx,400
        mov     dx,offset Encrypt_Buffer
        int     21

        mov     cx,ax
        mov     ah,40
        mov     bx,word ptr cs:[Destf]
        mov     dx,offset Encrypt_Buffer
        int     21

        cmp     ax,400
        je      BackLoop
DoneBack:
        mov     ah,3e
        mov     bx,word ptr cs:[Destf]
        int     21

        mov     ax,4200
        xor     cx,cx
        xor     dx,dx
        mov     bx,word ptr cs:[Sourcef]
        int     21
        ret

SourceF dw      0
DestF   dw      0



begin_password:
;------------------------------------------------------------------------
db 0e8h, 090h, 00h, 08dh, 0b6h, 02bh, 01h, 08dh, 0beh, 093h
db 01h, 0b9h, 034h, 00h, 0fch, 0ebh, 01h, 0eah, 0ach, 04fh
db 08ah, 025h, 088h, 064h, 0ffh, 088h, 05h, 0e2h, 0f5h, 02eh
db 083h, 0beh, 0c0h, 01h, 04h, 072h, 052h, 081h, 0aeh, 02ch
db 01h, 00h, 01h, 0ffh, 0ffh, 00h, 00h, 0eah, 0c3h, 01h
db 08eh, 086h, 0c6h, 02eh, 058h, 05bh, 059h, 058h, 0e3h, 08bh
db 0d0h, 08eh, 093h, 050h, 0dch, 08bh, 0d0h, 08ch, 051h, 053h
db 050h, 0dbh, 0ebh, 0f8h, 08bh, 0f0h, 08bh, 00h, 02fh, 0e8h
db 0c0h, 033h, 01h, 02h, 06h, 031h, 01h, 0c8h, 086h, 08bh
db 01h, 00h, 06h, 031h, 01h, 0c6h, 086h, 08bh, 0a5h, 0a5h
db 01h, 0c2h, 0b6h, 08dh, 057h, 01h, 00h, 0bfh, 0c3h, 01h
db 052h, 086h, 0c6h, 0e8h, 0e2h, 0abh, 0c0h, 0d1h, 01h, 0cch
db 086h, 02bh, 01h, 0cah, 086h, 033h, 0c8h, 0d1h, 01h, 0c8h
db 086h, 03h, 01h, 0c6h, 086h, 033h, 0adh, 041h, 0e9h, 0d1h
db 0cdh, 08bh, 0feh, 08bh, 01h, 00h, 0beh, 05dh, 0ebh, 01h
db 0eah, 055h, 081h, 0edh, 03h, 01h, 0e8h, 01h, 00h, 0c3h
db 050h, 06h, 01eh, 033h, 0c0h, 08eh, 0d8h, 08eh, 0c0h, 033h
db 0f6h, 033h, 0ffh, 0b9h, 08h, 00h, 0adh, 035h, 0dh, 0d0h
db 0abh, 02eh, 0ffh, 086h, 0c0h, 01h, 0e2h, 0f4h, 01fh, 07h
db 058h, 0c3h, 00h, 00h
;------------------------------------------------------------------------
Storage_Bytes   db      90,90,0cdh,20

Key1    dw      0
Key2    dw      0
Key3    dw      0
Key4    dw      0
;------------------------------------------------------------------------
end_password:
                dw      0
                dw      0
Filename_data   dw      0
Filename        db      80 dup(0)
Encrypt_Buffer  db      400 dup(0)
end start
