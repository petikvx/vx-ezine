;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;                   Black Wolf's File Protection Utilities 2.1s
;
;PW_COM - Password Code for COM file password protection in PassCOM.
;         If modified, convert to data bytes and re-instate program into
;         PassCOM.ASM, then recompile PassCOM.
;      
;         Basically, this code is attached to a .COM file and, when executed,
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
        call    Get_Offset

Displaced:
        mov     byte ptr cs:[tr1+bp],0ea        ;Kill some debuggers
tr1:
        jmp     short tr2
        db      0
skip_it:
        jmp     skip2
        dw      0deadh
tr2:    
        mov     bx,offset tri3
        add     bx,bp
        push    bx
        mov     byte ptr cs:[tr2+bp],0c3   ;This one isn't a prefetch trick,
        jmp     skip_it                    ;but they might think it is....
skip2:
        jmp     tr2
tri3:
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
        mov     word ptr cs:[Change_Div+bp],9090    ;This is an interesting
        xor     cx,cx                               ;trick - it basically
Change_Div:                                         ;calls Print_Prompt...
        div     cx                                  ;try debugging it....
        pop     ds
        pop     ax
        xchg    ax,word ptr ds:[02]
        pop     ax
        xchg    ax,word ptr ds:[00]
        pop     ds ax
        sti

        call    GetPass
        add     byte ptr cs:[tri4+1+bp],10   ;mod jump to mess up debuggers
tri4:
        jmp     Do_Encr_Pass    
        db      0ea
        db      9a
Do_Encr_Pass:
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
        mov     di,100
        push    di
        lea     si,bp+Storage_Bytes      ;Restore control to COM.
        movsw
        movsw
        xor     ax,ax
        mov     si,ax
        mov     di,ax
        ret
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
        db      0ea
loc2:        
        clc
        ret
        db      9a
loc1:
        cld
        jmp     loc2
;------------------------------------------------------------------------
Check_Passwords:
        lea     si,[bp+Entered_Pass]
        lea     di,[Password+bp]
        mov     cx,0c
        repz    cmpsb
        jcxz    Password_Good   ;This spot needs to be more deeply imbedded
        stc                     ;to avoid simple hacking....
        ret
        db      0e9
Password_Good:
        clc
        ret
;------------------------------------------------------------------------
        db      0
Encrypt_Password:                       ;Here's another place I could use
        mov     bx,word ptr [Key1+bp]   ;a decent encryption algorithm....
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
        db      0ea
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
        db      0ea                     ;confuse disassemblers....
confuzzled:
        push    bp
        sub     bp,offset Displaced
        ret
;------------------------------------------------------------------------
Key1            dw      0
Key2            dw      0
;------------------------------------------------------------------------
Storage_Bytes   db      90,90,0cdh,20
;------------------------------------------------------------------------
Password        db      'Passwordtest'
Entered_Pass    db      '            '
;------------------------------------------------------------------------
end_prog:
end start
