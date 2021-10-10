;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;                   Black Wolf's File Protection Utilities 2.1s
;
;EncrEXE - This program encrypts specified file and attaches the decryption
;          code from EN_EXE onto the file so that it will decrypt on
;          each execution.  It utilizes ULTIMUTE .93á to protect then EN_EXE
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

        extrn   _ULTMUTE:near, _END_ULTMUTE:byte, Init_Rand:near
        extrn   Get_Rand:near

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
        db      'EncrEXE 2.0 (c) 1993 Black Wolf Enterprises.',0a,0dh
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
Save_Header:
        mov     ax,word ptr [exeheader+0e]    ;Save old SS
        mov     word ptr [Old_SS],ax
        mov     ax,word ptr [exeheader+10]    ;Save old SP
        mov     word ptr [Old_SP],ax
        mov     ax,word ptr [exeheader+14]    ;Save old IP
        mov     word ptr [Old_IP],ax
        mov     ax,word ptr [exeheader+16]    ;Save old CS
        mov     word ptr [Old_CS],ax
        ret

Do_File:        
        mov     ax,3d02
        mov     dx,offset Filename
        int     21
        jnc      Terminate_NOT
        jmp     Terminate
Terminate_NOt:
        xchg    bx,ax
        
        call    GetTime        
        call    BackupFile

        mov     ah,3f
        mov     cx,1a
        mov     dx,offset EXEheader
        int     21

        cmp     word ptr [EXEheader],'ZM'       ;not EXE file.
        je      IsEXE
        jmp     close_file
IsEXE:
        call    Save_Header
        
        mov     ax,4200
        xor     cx,cx
        xor     dx,dx                   ;Go back to beginning
        int     21

        mov     ax,word ptr [EXEheader+08]
        mov     cl,4                            ;convert header to bytes
        shl     ax,cl

        mov     word ptr [HeaderSize],ax

        mov     cx,ax        
        mov     dx,offset Header                ;Load header
        mov     ah,3f
        int     21
        
        call    Encrypt_Entire_File
        
        mov     ax,4202
        xor     cx,cx                   ;Go end
        xor     dx,dx
        int     21

        mov     cl,4
        shr     ax,cl
        inc     ax
        shl     ax,cl
        mov     cx,dx           ;Pad file
        mov     dx,ax
        mov     ax,4200
        int     21
        
        push    ax dx

        call    calculate_CSIP          ;calculate starting
                                        ;point.

        mov     ah,40
        mov     dx,offset Set_Segs
        mov     cx,end_set_segs-set_segs
        int     21

        push    bx        
        mov     si,offset begin_password        ;On Entry -> CS=DS=ES
        mov     di,offset _END_ULTMUTE          ;SI=Source, DI=Destination
        
        mov     bx,word ptr [exeheader+14]       ;BX=Next Entry Point
        add     bx,end_set_segs-set_segs

        mov     cx,end_password-begin_password+1 ;CX=Size to Encrypt
        add     cx,word ptr [headersize]         ;add in EXE header

        mov     ax,1                             ;AX=Calling Style
        call    _ULTMUTE                
                                                ;On Return -> CX=New Size

        pop     bx
        pop     dx ax                   ;DX:AX = unmodified
                                        ;file size.
        
        push    cx bx
        add     cx,end_set_segs-set_segs
        call    calculate_size
        pop     bx cx

        mov     dx,offset _END_ULTMUTE
        mov     ah,40
        int     21
        
        mov     ax,4200
        xor     dx,dx
        xor     cx,cx
        int     21
        
        mov     ah,40
        mov     cx,1a
        mov     dx,offset EXEheader
        int     21

        mov     cx,word ptr [headersize]        
        sub     cx,1a
        jz      Close_File

Zero_Header:
        push    cx
        mov     ah,40
        mov     cx,1
        mov     dx,offset zero
        int     21
        pop     cx
        loop    Zero_Header
        
Close_File:
        mov     ax,5701
        mov     cx,word ptr cs:[Time]
        mov     dx,word ptr cs:[Date]   ;restore date/time
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

Time    dw      0
Date    dw      0

Terminate:
        mov     ah,09
        mov     dx,offset BadFile
        int     21
        ret
BadFile db      'Error Opening File.',07,0dh,0a,24
zero    db      0,0
calculate_CSIP:
        push    ax
        mov     cl,4 
        mov     ax,word ptr [exeheader+8]       ;Get header length
                                                ;and convert it to
        shl     ax,cl                           ;bytes.
        mov     cx,ax
        pop     ax

        sub     ax,cx                           ;Subtract header
        sbb     dx,0                            ;size from file
                                                ;size for memory
                                                ;adjustments

        mov     cl,0c                           ;Convert DX into
        shl     dx,cl                           ;segment Address
        mov     cl,4
        push    ax                      ;Change offset (AX) into
        shr     ax,cl                   ;segment, except for last
        add     dx,ax                   ;digit.  Add to DX and
        shl     ax,cl                   ;save DX as new CS, put
        pop     cx                      ;left over into CX and
        sub     cx,ax                   ;store as the new IP.
        mov     word ptr [exeheader+16],dx    ;Set new CS:IP
        mov     word ptr [exeheader+10],0fffe ;Set new SP
        mov     word ptr [exeheader+0e],dx    ;Set new SS = CS
        mov     word ptr [exeheader+14],cx
        mov     word ptr [exeheader+6],0        ;Set 0 relocation items.
        ret

calculate_size:
        add     ax,cx                   ;Add virus size to DX:AX
        adc     dx,0
        
        push    ax                      ;Save offset for later
        mov     cl,7
        shl     dx,cl                   ;convert DX to pages
        mov     cl,9
        shr     ax,cl
        add     ax,dx
        inc     ax
        mov     word ptr [exeheader+04],ax  ;save # of pages

        pop     ax                              ;Get offset
        mov     dx,ax
        shr     ax,cl                           ;Calc remainder
        shl     ax,cl                           ;in last page
        sub     dx,ax
        mov     word ptr [exeheader+02],dx ;save remainder
        ret

Set_Segs:
        push    es ds
        push    cs cs
        pop     es ds
 End_Set_Segs:

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
        ret

EncryptBytes:                           ;This algorithm needs help....
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
                dw      0
                dw      0
Filename_data   dw      0
Filename        db      80 dup(0)
Exeheader       db      1a dup(0)
Encrypt_Buffer  dw      400 dup(0)
HeaderSize      dw      0


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


begin_password:         ;code from en_exe
;------------------------------------------------------------------------
db 0e8h, 02dh, 01h, 058h, 050h, 02eh, 089h, 086h, 076h, 02h
db 02eh, 089h, 086h, 0fh, 01h, 033h, 0dbh, 05h, 010h, 00h
db 08ch, 0c9h, 02bh, 0c8h, 0d1h, 0e1h, 083h, 0d3h, 00h, 0ebh
db 0ch, 090h, 0eah, 0d1h, 0e3h, 0d1h, 0e1h, 083h, 0d3h, 00h
db 0ebh, 0bh, 0ffh, 0d1h, 0e3h, 0d1h, 0e1h, 083h, 0d3h, 00h
db 0ebh, 0edh, 09ah, 08eh, 0c0h, 08eh, 0d8h, 033h, 0f6h, 033h
db 0ffh, 0e8h, 0fbh, 00h, 0ebh, 01h, 0eah, 0adh, 033h, 086h
db 080h, 02h, 03h, 086h, 082h, 02h, 0d1h, 0c8h, 033h, 086h
db 084h, 02h, 02bh, 086h, 086h, 02h, 0d1h, 0c0h, 0abh, 053h
db 051h, 08bh, 0c6h, 08bh, 0d8h, 0b1h, 04h, 0d3h, 0e8h, 0d3h
db 0e0h, 03bh, 0c3h, 075h, 0dh, 083h, 0eeh, 010h, 083h, 0efh
db 010h, 01eh, 058h, 040h, 08eh, 0d8h, 08eh, 0c0h, 059h, 05bh
db 0e2h, 0c9h, 083h, 0fbh, 00h, 074h, 06h, 04bh, 0ebh, 0c1h
db 0e8h, 0b6h, 00h, 050h, 01eh, 033h, 0c0h, 08eh, 0d8h, 08dh
db 086h, 0d5h, 01h, 087h, 06h, 00h, 00h, 050h, 08ch, 0c8h
db 087h, 06h, 02h, 00h, 050h, 033h, 0c9h, 02eh, 0c7h, 086h
db 0a4h, 01h, 090h, 090h, 0f7h, 0f1h, 058h, 087h, 06h, 02h
db 00h, 058h, 087h, 06h, 00h, 00h, 01fh, 058h, 07h, 01fh
db 02eh, 08bh, 086h, 076h, 02h, 05h, 010h, 00h, 02eh, 03h
db 086h, 07ch, 02h, 0fah, 08eh, 0d0h, 02eh, 08bh, 0a6h, 07eh
db 02h, 0fbh, 033h, 0c0h, 08bh, 0f0h, 08bh, 0f8h, 02eh, 0ffh
db 0aeh, 078h, 02h, 02eh, 08bh, 086h, 076h, 02h, 05h, 010h
db 00h, 02eh, 01h, 086h, 07ah, 02h, 0e8h, 01h, 00h, 0cfh
db 050h, 053h, 051h, 052h, 06h, 01eh, 056h, 057h, 055h, 08bh
db 0ddh, 02eh, 08bh, 0afh, 0a0h, 02h, 02eh, 08bh, 08fh, 08eh
db 02h, 0bh, 0c9h, 074h, 027h, 03h, 0ebh, 02eh, 0c5h, 0b6h
db 088h, 02h, 02bh, 0ebh, 08ch, 0d8h, 02eh, 03h, 087h, 076h
db 02h, 05h, 010h, 00h, 08eh, 0d8h, 02eh, 08bh, 087h, 076h
db 02h, 05h, 010h, 00h, 01h, 04h, 083h, 0c5h, 04h, 0e8h
db 017h, 00h, 0e2h, 0d9h, 05dh, 05fh, 05eh, 01fh, 07h, 05ah
db 059h, 05bh, 058h, 0c3h, 05dh, 0ebh, 01h, 0eah, 055h, 081h
db 0edh, 03h, 01h, 0c3h, 0c3h, 0ebh, 014h, 090h, 0eah, 0e8h
db 02ch, 00h, 0ebh, 06h, 090h, 0e8h, 026h, 00h, 0ebh, 0f5h
db 0bh, 0edh, 074h, 0f7h, 05dh, 0ebh, 0e9h, 055h, 033h, 0edh
db 0ebh, 0efh, 050h, 072h, 06fh, 074h, 065h, 063h, 074h, 069h
db 06fh, 06eh, 020h, 062h, 079h, 020h, 042h, 06ch, 061h, 063h
db 06bh, 020h, 057h, 06fh, 06ch, 066h, 0e4h, 021h, 034h, 02h
db 0e6h, 021h, 045h, 0c3h, 00h, 00h
;------------------------------------------------------------------------
Old_IP  dw      0
Old_CS  dw      0fff0
Old_SS  dw      0fff0
Old_SP  dw      0
Key1    dw      0
Key2    dw      0
Key3    dw      0
Key4    dw      0
;------------------------------------------------------------------------
end_password:
Header:
        db     800 dup(0)       ;leave space for ultimute with db (0)'s
end start
