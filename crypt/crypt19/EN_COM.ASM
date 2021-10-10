;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;                   Black Wolf's File Protection Utilities 2.1s
;
;EN_COM - Decryption Code for COM file encryption protection in EncrCOM.
;         If modified, convert to data bytes and re-instate program into
;         EncrCOM.ASM, then recompile EncrCOM.
;      
;         Basically, this code is attached to a .COM file and, when executed,
;         decrypts the .COM file and continues execution.
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
        lea     si,[Decrypt_COM+bp]  
        lea     di,[Get_Offset+bp]   
        mov     cx,(Get_Offset-Decrypt_COM)/2
        cld
        jmp     short EncrLoop      ;EncrLoop here isn't really much of an
        db      0ea                 ;encryption, but disassemblers should
                                    ;love it - it flips the code in memory.

EncrLoop:                           ;This part must be stepped through and
        lodsb                       ;re-saved before using the resulting 
        dec     di                  ;.COM as data for EncrCOM, otherwise
        mov     ah,[di]             ;it will simply flip the memory image
        mov     [si-1],ah           ;of the program and crash when run...
        mov     [di],al
        loop    EncrLoop
        cmp     cs:[Counter+bp],4       ;Check if last Anti-debug trick was
        jb      Yip                     ;skipped, if so, mess up user....
        
        sub     word ptr [bp+Decrypt_COM+1],100 ;another prefetch trick...
Decrypt_COM:
        mov     si,100
        mov     di,si
        mov     cx,bp
        shr     cx,1
        inc     cx

Decrypt_Loop:                   ;This could be LOTS better....
        lodsw                   ;Suggestions on the algorithm?
        xor     ax,[Key1+bp]
        add     ax,[Key2+bp]
        ror     ax,1
        xor     ax,[Key3+bp]
        sub     ax,[Key4+bp]
        rol     ax,1
        stosw
        loop    Decrypt_Loop

        mov     byte ptr [bp+RestoreFile],0c3
RestoreFile:
        mov     di,100
        push    di
        lea     si,bp+Storage_Bytes      ;Restore control to COM.
        movsw
        movsw

        mov     ax,[Key1+bp]
        xor     ds:[100h],ax
        mov     ax,[Key2+bp]
        xor     ds:[102h],ax

        xor     ax,ax
        call    KillInt3
        mov     si,ax
        mov     di,ax
        jmp     RestoreFile


Yip:                            ;If you end up here... you messed up.
        push    ax bx cx        
        mov     ax,ss
        mov     bx,sp           ;reverse words in stack - probably end up
        push    ax              ;somewhere in BIOS ROM....
        xchg    bx,ax
        mov     ss,ax
        mov     sp,bx
        pop     ax
        pop     cx bx ax
        mov     byte ptr cs:[Thinker+bp],0c3    ;move a return w/prefetch
Thinker:
        db      0ea,0,0,0ff,0ff ;if they skipped prefetch... reboot cold.

;------------------------------------------------------------------------
Get_Offset:
        pop     bp
        jmp     short confuzzled
        db      0ea
confuzzled:
        push    bp
        sub     bp,offset Displaced
        call    killInt3
        ret

Killint3:                       ;Xor first 4 interrupts with 0d00dh...
        push    ax es ds        ;not nice on debuggers if traced....
        xor     ax,ax
        mov     ds,ax
        mov     es,ax
        xor     si,si
        xor     di,di
        mov     cx,8

killints:        
        lodsw
        xor     ax,0d00dh
        stosw
        inc     word ptr cs:[Counter+bp]
        loop    killints

        pop     ds es ax
        ret

Counter dw      0
;------------------------------------------------------------------------
Storage_Bytes   db      90,90,0cdh,20
Key1            dw      0
Key2            dw      0
Key3            dw      0
Key4            dw      0
;------------------------------------------------------------------------
end_prog:
end start
