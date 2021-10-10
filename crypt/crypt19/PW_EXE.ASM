;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;                   Black Wolf's File Protection Utilities 2.1s
;
;PW_EXE - Password Code for EXE file password protection in PassEXE.
;         If modified, convert to data bytes and re-instate program into
;         PassEXE.ASM, then recompile PassEXE.
;      
;         Basically, this code is attached to a .EXE file and, when executed,
;         waits for a password - if it is legit it continues, otherwise it       
;         stops execution of the file.
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
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;Modifications:
;       None as of 08/05/93 - Initial Release.

.model tiny
.radix 16
.code
        org 100
start:
;        push    es ds
;                       ;These commands are placed _before_ the ultimute
;        push    cs cs  ;encryption.
;        pop     es ds
        
        call    Get_Offset
Displaced:
        mov     byte ptr [tr1+bp],0c3   ;move a return onto tr1 for debug..
tr1:
        jmp     tr2
tr2:
        cli
        push    ax ds
        xor     ax,ax
        mov     ds,ax
        lea     ax,[Print_Prompt+bp]
        xchg    ax,word ptr ds:[00]
        push    ax
        mov     ax,cs
        xchg    ax,word ptr ds:[02]
        push    ax
        push    ds
        push    cs
        pop     ds
        mov     word ptr cs:[Change_Div+bp],9090        
        xor     cx,cx
Change_Div:                             ;That X/0 trick again....
        div     cx
        pop     ds
        pop     ax
        xchg    ax,word ptr ds:[02]
        pop     ax
        xchg    ax,word ptr ds:[00]
        pop     ds ax
        sti

GetthePass:
        call    Getpass
aftergp:
        call    Encrypt_Password
        call    Check_Passwords
        jc      BadPass
        
        xor     ax,ax
        mov     cx,0c
        lea     si,[Entered_Pass+bp]

GetValue:                               ;Get value to use to decrypt with..
        lodsb
        add     ah,al
        ror     ah,1
        loop    GetValue
                                                ;I need an improved algorithm
        lea     si,[Goodpass+bp]                ;here.......
        mov     cx,EndGoodPass-GoodPass        

Decrypt_Restore:        
        mov     al,[si]
        xor     al,ah
        mov     [si],al
        inc     si
        loop    Decrypt_Restore
        call    RenewPrefetch
        jmp     short GoodPass
        
        db      0ff
GoodPass:        
        pop     es ds
        mov     ax,es
        add     ax,10
        add     word ptr cs:[Old_CS+bp],ax
        
        add     ax,word ptr cs:[Old_SS+bp]
        
        cli
        mov     ss,ax
        mov     sp,word ptr cs:[Old_SP+bp]
        sti
        
        xor     ax,ax
        mov     si,ax
        mov     di,ax

        jmp     dword ptr cs:[Old_IP+bp]
        nop
        nop
        nop
        nop
EndGoodPass:
        db      0ff

BadPass:        
        mov     ah,09
        lea     dx,[BadBad+bp]
        int     21
        mov     ax,4c01
        int     21
BadBad  db      0a,0dh,'Password Incorrect.',07,24

RenewPrefetch:
        nop
        jmp     loc1
loc2:        
        clc
        ret
loc1:
        cld
        jmp     loc2

;------------------------------------------------------------------------
Check_Passwords:
        lea     si,[bp+Entered_Pass]
        lea     di,[Password+bp]
        mov     cx,0c
        repz    cmpsb
        jcxz    Password_Good
        stc
        ret

Password_Good:
        clc
        ret
;------------------------------------------------------------------------
Encrypt_Password:
        mov     bx,word ptr [Key1+bp]
        mov     dx,word ptr [Key2+bp]
        lea     si,[Entered_Pass+bp]
        mov     di,si
        mov     cx,6
  EncryptIt:      
        lodsw
        xor     ax,bx
        add     bx,dx
        stosw
        loop    EncryptIt
        ret
;------------------------------------------------------------------------
GetPass:
        mov     cx,0c
        lea     di,[Entered_Pass+bp]
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
;------------------------------------------------------------------------
Print_Prompt:
        mov     ah,09
        lea     dx,[Info+bp]
        int     21
        iret
Info    db      'Password->',24
;------------------------------------------------------------------------
Get_Offset:
        pop     bp
        jmp     short confuzzled
        db      0ea
confuzzled:
        push    bp
        sub     bp,offset Displaced
        ret

;------------------------------------------------------------------------
;------------------------------------------------------------------------
Key1            dw      0
Key2            dw      0
;------------------------------------------------------------------------
Old_IP  dw      0
Old_CS  dw      0fff0
Old_SS  dw      0fff0
Old_SP  dw      0
;------------------------------------------------------------------------
Password        db      'TestPassword'
Entered_Pass    db      '            '
;------------------------------------------------------------------------
Header:
end_prog:
end start
