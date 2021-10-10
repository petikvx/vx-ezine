;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;                   Black Wolf's File Protection Utilities 2.1s
;
;PassEXE - This program password protects the specified file by attaching
;          code from PW_EXE onto the file so that it will check for passwords
;          each execution.  It utilizes ULTIMUTE .93á to protect then PW_EXE
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

        extrn   _ULTMUTE:near, _END_ULTMUTE:byte

start:
        call    GetFilename
        call    Get_Passes
        call    EncryptGP       ;needs work here....
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
Get_Passes:
    Clear_Out_Passes:        
        mov     di,offset Entered_Pass
        mov     cx,0ch                   ;Clear out entered pass.
        xor     ax,ax
        repnz   stosb
        mov     di,offset Password
        mov     cx,0ch                   ;Clear out entered pass.
        xor     ax,ax
        repnz   stosb
        
        mov     ah,09
        mov     dx,offset Req_Pass
        int     21

        mov     di,offset Entered_Pass
        mov     cx,0ch
        call    GetPass

        mov     ah,09
        mov     dx, offset Dup_Pass
        int     21

        mov     di,offset Password
        mov     cx,0ch
        call    GetPass
        
        call    Check_Passwords
        jc      Get_Passes
        
        mov     di,offset Entered_Pass
        mov     cx,0dh                   ;Clear out entered pass.
        xor     ax,ax
        repnz   stosb

Randomize_Keys:
        push    ds
        xor     ax,ax
        mov     ds,ax
        mov     ax,word ptr ds:[46c]    ;Randomizes encryption
        pop     ds
        mov     word ptr [Key1],ax
        xor     ax,1f3eh
        ror     ax,1
        mov     word ptr [Key2],ax
        


Encrypt_Password:
        mov     bx,word ptr [Key1]
        mov     dx,word ptr [Key2]      ;Encrypt the password - needs 
        mov     si,offset Password      ;some work on algorithm....
        mov     di,si
        mov     cx,6
  EncryptIt:      
        lodsw
        xor     ax,bx
        add     bx,dx
        stosw
        loop    EncryptIt
        ret
;---------------------------------------------------------------------------
Message:
        db      'PassEXE 2.0 (c) 1993 Black Wolf Enterprises.',0a,0dh
        db      'Enter Filename To Protect -> $'
;---------------------------------------------------------------------------
Req_Pass        db      0a,0dh,'Now Enter Password (up to 12 chars): $'
Dup_Pass        db      0a,0dh,'Re-Enter Password: $'
Passes_Not      db      0a,0dh,'Passwords do not match.  Try again.',0a,0dh,24
;---------------------------------------------------------------------------
Check_Passwords:
        mov     si,offset Entered_Pass
        mov     di,offset Password
        mov     cx,0c
        repz    cmpsb
        jcxz    Password_Good
        stc
        ret
Password_Good:
        clc
        ret
;---------------------------------------------------------------------------


gets:
        mov     ah,0a           ;Get string
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
GetPass:
  KeyHit_Loop:
        push    cx
        sub     ax,ax
        int     16
        cmp     al,0dh
        je      HitReturn
        stosb
        pop     cx
        loop    KeyHit_Loop
        ret
  HitReturn:
        pop     cx
        xor     al,al
        repnz   stosb
        ret        


;---------------------------------------------------------------------------
Save_Header:                               ;Save important values from header
        
        mov     ax,word ptr [exeheader+0e]    ;Save old SS
        mov     word ptr [Old_SS],ax
        mov     ax,word ptr [exeheader+10]    ;Save old SP
        mov     word ptr [Old_SP],ax
        mov     ax,word ptr [exeheader+14]    ;Save old IP
        mov     word ptr [Old_IP],ax
        mov     ax,word ptr [exeheader+16]    ;Save old CS
        mov     word ptr [Old_CS],ax
        ret

GetTime:
        mov     ax,5700
        int     21
        mov     word ptr cs:[Time],cx
        mov     word ptr cs:[Date],dx
        ret
SetTime:
        mov     ax,5701
        mov     cx,word ptr cs:[Time]
        mov     dx,word ptr cs:[Date]
        int     21
        ret


Do_File:        
        mov     ax,3d02
        mov     dx,offset Filename
        int     21                      ;open read/write
        jc      Terminate
        xchg    bx,ax
        
        call    GetTime        
        call    BackupFile

        mov     ah,3f
        mov     cx,1a
        mov     dx,offset EXEheader     ;read in header info
        int     21

        cmp     word ptr [EXEheader],'ZM'       ;not EXE file - don't 
        jne     close_file                      ;protect it....
        call    Save_Header
        
        mov     ax,4202
        xor     cx,cx                   ;go to end of file
        xor     dx,dx
        int     21
        
        push    ax dx                   ;save file size

        call    calculate_CSIP          ;calculate starting
                                        ;point.

        mov     ah,40
        mov     dx,offset Set_Segs       ;write in the 'push es ds'
        mov     cx,end_set_segs-set_segs ;'push cs cs' 'pop es ds' stuff...
        int     21

        push    bx        
        mov     si,offset begin_password        ;On Entry -> CS=DS=ES
        mov     di,offset _END_ULTMUTE          ;SI=Source, DI=Destination
        
        mov     bx,word ptr [exeheader+14]       ;BX=Next Entry Point
        add     bx,end_set_segs-set_segs

        mov     cx,end_password-begin_password+1 ;CX=Size to Encrypt
        mov     ax,1                             ;AX=Calling Style
        
        call    _ULTMUTE                        ;Encrypt code
                                                
                                                ;On Return -> CX=New Size

        pop     bx
        
        pop     dx ax                   ;DX:AX = unmodified
                                        ;file size.
        
        push    cx bx
        add     cx,end_set_segs-set_segs
        call    calculate_size
        pop     bx cx

        mov     dx,offset _END_ULTMUTE
        mov     ah,40                   ;Append host
        int     21
        
        mov     ax,4200
        xor     dx,dx
        xor     cx,cx
        int     21
        
        mov     ah,40
        mov     cx,1a
        mov     dx,offset EXEheader
        int     21
        
Close_File:
        call    SetTime
        mov     ah,3e
        int     21
        ret

Terminate:
        mov     ah,09
        mov     dx,offset BadFile
        int     21
        ret
BadFile db      'Error Opening File.',07,0dh,0a,24

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
        ret

calculate_size:
        push    ax                      ;Save offset for later
        
        add     ax,cx                   ;Add program size to DX:AX
        
        adc     dx,0

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

EncryptGP:                              ;Encrypt GoodPass
        xor     ax,ax
        mov     cx,0c
        mov     si,offset Password

GetValue:        
        lodsb
        add     ah,al
        ror     ah,1                    ;Get value to use for encrypt...
        loop    GetValue

        mov     si,offset Goodpass
        mov     cx,EndGoodPass-GoodPass
        
Decrypt_Restore:        
        mov     al,[si]
        xor     al,ah
        mov     [si],al
        inc     si
        loop    Decrypt_Restore
        ret        

Time    dw      0
Date    dw      0

Set_Segs:
        push    es ds
        push    cs cs
        pop     es ds
 End_Set_Segs:

BackupFile:                     ;Make backup of file...
        mov     si,offset Filename
        mov     cx,80

  Find_Eofn:                    ;Find end of file name...
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
        mov     byte ptr [si+2],'D'     ;Set filename to *.OLD
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
        mov     dx,offset FileBuffer
        int     21

        mov     cx,ax
        mov     ah,40
        mov     bx,word ptr cs:[Destf]
        mov     dx,offset Filebuffer
        int     21

        cmp     ax,400
        je      BackLoop
DoneBack:
        call    SetTime

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
db 0e8h, 01fh, 01h, 0c6h, 086h, 08h, 01h, 0c3h, 0ebh, 01h
db 090h, 0fah, 050h, 01eh, 033h, 0c0h, 08eh, 0d8h, 08dh, 086h
db 0eh, 02h, 087h, 06h, 00h, 00h, 050h, 08ch, 0c8h, 087h
db 06h, 02h, 00h, 050h, 01eh, 0eh, 01fh, 02eh, 0c7h, 086h
db 02eh, 01h, 090h, 090h, 033h, 0c9h, 0f7h, 0f1h, 01fh, 058h
db 087h, 06h, 02h, 00h, 058h, 087h, 06h, 00h, 00h, 01fh
db 058h, 0fbh, 0e8h, 0b2h, 00h, 0e8h, 095h, 00h, 0e8h, 07fh
db 00h, 072h, 050h, 033h, 0c0h, 0b9h, 0ch, 00h, 08dh, 0b6h
db 044h, 02h, 0ach, 02h, 0e0h, 0d0h, 0cch, 0e2h, 0f9h, 08dh
db 0b6h, 06fh, 01h, 0b9h, 029h, 00h, 08ah, 04h, 032h, 0c4h
db 088h, 04h, 046h, 0e2h, 0f7h, 0e8h, 051h, 00h, 0ebh, 01h
db 0ffh 

GoodPass:
db 07h, 01fh, 08ch, 0c0h, 05h, 010h, 00h, 02eh, 01h
db 086h, 032h, 02h, 02eh, 03h, 086h, 034h, 02h, 0fah, 08eh
db 0d0h, 02eh, 08bh, 0a6h, 036h, 02h, 0fbh, 033h, 0c0h, 08bh
db 0f0h, 08bh, 0f8h, 02eh, 0ffh, 0aeh, 030h, 02h, 090h, 090h
db 090h, 090h, 0ffh 
EndGoodPass:

db 0b4h, 09h, 08dh, 096h, 0a6h, 01h, 0cdh
db 021h, 0b8h, 01h, 04ch, 0cdh, 021h, 0ah, 0dh, 050h, 061h
db 073h, 073h, 077h, 06fh, 072h, 064h, 020h, 049h, 06eh, 063h
db 06fh, 072h, 072h, 065h, 063h, 074h, 02eh, 07h, 024h, 090h
db 0ebh, 03h, 090h, 0f8h, 0c3h, 0fch, 0ebh, 0fbh, 08dh, 0b6h
db 044h, 02h, 08dh, 0beh, 038h, 02h, 0b9h, 0ch, 00h, 0f3h
db 0a6h, 0e3h, 02h, 0f9h, 0c3h, 0f8h, 0c3h, 08bh, 09eh, 02ch
db 02h, 08bh, 096h, 02eh, 02h, 08dh, 0b6h, 044h, 02h, 08bh
db 0feh, 0b9h, 06h, 00h, 0adh, 033h, 0c3h, 03h, 0dah, 0abh
db 0e2h, 0f8h, 0c3h, 0b9h, 0ch, 00h, 08dh, 0beh, 044h, 02h
db 051h, 02bh, 0c0h, 0cdh, 016h, 03ch, 0dh, 074h, 05h, 0aah
db 059h, 0e2h, 0f3h, 0c3h, 059h, 032h, 0c0h, 0f2h, 0aah, 0c3h
db 0b4h, 09h, 08dh, 096h, 017h, 02h, 0cdh, 021h, 0cfh, 050h
db 061h, 073h, 073h, 077h, 06fh, 072h, 064h, 02dh, 03eh, 024h
db 05dh, 0ebh, 01h, 0eah, 055h, 081h, 0edh, 03h, 01h, 0c3h
;------------------------------------------------------------------------
Key1            dw      0
Key2            dw      0
;------------------------------------------------------------------------
Old_IP  dw      0
Old_CS  dw      0fff0
Old_SS  dw      0fff0
Old_SP  dw      0
;------------------------------------------------------------------------
Password        db      'Greets progr'
Entered_Pass    db      'ammers.. }-)'
;------------------------------------------------------------------------
end_password:
                dw      0
                dw      0
Filename_data   dw      0
Filename        db      80 dup(0)
FileBuffer      dw      400 dup(0)
Exeheader       db      1a dup(0)
end start



