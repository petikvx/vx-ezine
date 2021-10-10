;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;                   Black Wolf's File Protection Utilities 2.1s
;
;
;EN_EXE - Decryption Code for EXE file encryption protection in EncrEXE.
;         If modified, convert to data bytes and re-instate program into
;         EncrEXE.ASM, then recompile EncrEXE.
;      
;         Basically, this code is attached to a .EXE file and, when executed,
;         decrypts the .EXE file and continues execution.
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
        pop     ax        
        push    ax

Hackit:
        mov     word ptr cs:[ES_Store+bp],ax    ;save ES
        mov     word ptr cs:[tricky+bp],ax      ;Trash next command if
Tricky:                                         ;debugged
        xor     bx,bx
        add     ax,10
        mov     cx,cs
        sub     cx,ax
        shl     cx,1
        adc     bx,0
        jmp     nextset
        db      0ea             ;confuse disassemblers
lastset:
        shl     bx,1
        shl     cx,1
        adc     bx,0
        jmp     short doneset        
        
        db      0ff             ;same as above
nextset:        
        shl     bx,1
        shl     cx,1
        adc     bx,0
        jmp     short lastset
        db      9a

doneset:
        mov     es,ax
        mov     ds,ax
        xor     si,si
        xor     di,di
        call    Waiter
        
        jmp     short Decrypt_Loop
        db      0ea
Decrypt_Loop:                           ;Decrypt EXE - needs work on alg.
        lodsw
        xor     ax,[Key1+bp]
        add     ax,[Key2+bp]
        ror     ax,1
        xor     ax,[Key3+bp]
        sub     ax,[Key4+bp]
        rol     ax,1
        
        stosw
        
        push    bx cx
        mov     ax,si
        mov     bx,ax        
        mov     cl,4
        shr     ax,cl
        shl     ax,cl
        cmp     ax,bx
        jne     DoneReset
        sub     si,10
        sub     di,10
        push    ds
        pop     ax
        inc     ax
        mov     ds,ax
        mov     es,ax
DoneReset:        
        pop     cx bx
        loop    Decrypt_Loop
        
        cmp     bx,0
        je      Int_00
        dec     bx
        jmp     Decrypt_Loop
        call    Waiter

Int_00:                 ;Div by Zero Anti-Debug trick....
        push    ax ds
        xor     ax,ax
        mov     ds,ax
        lea     ax,[Restorat+bp]
        xchg    ax,ds:[0]
        push    ax
        mov     ax,cs
        xchg    ax,ds:[2]
        push    ax
        
        xor     cx,cx
        mov     word ptr cs:[divideit+bp],9090
divideit:
        div     cx
       
        pop     ax
        xchg    ax,ds:[2]
        pop     ax
        xchg    ax,ds:[0]
        pop     ds ax

Restore_EXE:        
        pop     es ds        
        
        mov     ax,word ptr cs:[ES_Store+bp]
        add     ax,10
        add     ax,word ptr cs:[Old_SS+bp]
        
        cli
        mov     ss,ax
        mov     sp,word ptr cs:[Old_SP+bp]
        sti

        xor     ax,ax
        mov     si,ax
        mov     di,ax
        jmp     dword ptr cs:[Old_IP+bp]        ;jump back to host file


Restorat:
        mov     ax,word ptr cs:[ES_Store+bp]
        add     ax,10
        add     word ptr cs:[Old_CS+bp],ax
        call    Undo_Relocation
        iret
;------------------------------------------------------------------------
Undo_Relocation:                      ;Add old ES+10 to all addresses in
                                      ;Relocation table for program to run.
        push    ax bx cx dx es ds si di bp
        mov     bx,bp

        mov     bp,word ptr cs:[Header+18+bx] ;Get offset of first relocation item
        mov     cx,word ptr cs:[Header+6+bx]
        or      cx,cx
        jz      Done_UnReloc
UnReloc_Loop:
        add     bp,bx
        lds     si,dword ptr cs:[Header+bp]
        sub     bp,bx
UnDo_Reloc:
        mov     ax,ds
        add     ax,word ptr cs:[ES_Store+bx]       ;adjust DS
        add     ax,10
        mov     ds,ax

        mov     ax,word ptr cs:[ES_Store+bx]
        add     ax,10
        add     word ptr ds:[si],ax
        add     bp,4
        call    Waiter
        loop    UnReloc_Loop

Done_UnReloc:
        pop     bp di si ds es dx cx bx ax
        ret                             
;------------------------------------------------------------------------
Get_Offset:
        pop     bp
        jmp     short confuzzled
        db      0ea
confuzzled:
        push    bp
        sub     bp,offset Displaced
        ret

Done_Waiter:
        ret
Waiter:
        jmp     W1
        db      0ea
W3:
        call    DoKB
        jmp     W4      ;Confuze people.......
W2:
        call    DoKB
        jmp     W3
w4:
        or      bp,bp
        jz      w2
        pop     bp
        jmp     Done_Waiter
W1:
        push    bp
        xor     bp,bp
        jmp     W2

        db      'Protection by Black Wolf'

DoKB:        
        in      al,21
        xor     al,2
        out     21,al
        inc      bp
        ret
;------------------------------------------------------------------------
ES_Store        dw      0
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
end_prog:
Header:
end start
