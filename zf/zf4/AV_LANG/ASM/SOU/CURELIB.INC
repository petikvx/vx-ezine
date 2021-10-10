;INTERFACE

;CureNone proc near
;FromBegOfFile proc near
;FromEndOfFile proc near

;IMPLEMENTATION
;**************************************************************************
CureNone proc near
         push dx
         inc AllVurusSkip
         lea dx,SkipFile
         call Write
         pop dx
         ret
CureNone endp
;**************************************************************************
FromEndOfFile proc near
     pusha
     pushf
     cmp CryptInfo,CryptByte1
     je _None_1
     cmp CryptInfo,CryptByte2
     je _None_1
     cmp CryptInfo,CryptWord0
     je _None_1
     cmp CryptInfo,CryptWord1
     je _None_1
     cmp CryptInfo,CryptWord2
     jne _NoCrypt_1
_None_1:
     call CureNone
_None_2:
     popf
     popa
     retn
_NoCrypt_1:
     cmp CryptInfo,CryptByte1
     je _None_1
     cmp CryptInfo,CryptByte2
     je _None_1
     cmp CryptInfo,CryptWord0
     je _None_1
     cmp CryptInfo,CryptWord1
     je _None_1
     cmp CryptInfo,CryptWord2
     mov si,SigOffset1
     dec si
     add si,BytesOffset
     mov di,SourceOffs
     xor cx,cx
     mov cl,BytesLength
     push ds es
     mov ax,FSEG
     mov ds,ax
     mov es,ax
     rep movsb
     pop ds
     mov di,FileLength
     mov cx,VirLength
     sub di,cx
     mov FileLength,di
;     mov al,0
;     rep stosb
     pop es
     inc AllFileCured
     lea dx,CureFile
     call Write
     jmp _None_2
FromEndOfFile endp
;**************************************************************************
FromBegOfFile proc near
     pusha
     pushf
     cmp CryptInfo,CryptByte1
     je _None
     cmp CryptInfo,CryptByte2
     je _None
     cmp CryptInfo,CryptWord0
     je _None
     cmp CryptInfo,CryptWord1
     je _None
     cmp CryptInfo,CryptWord2
     jne _NoCrypt
_None:
     call CureNone
_None1:
     popf
     popa
     retn
_NoCrypt:
     mov si,VirLength
     mov cx,FileLength
     sub cx,si
     mov FileLength,cx
     mov di,0
     push es
     push ds
     mov ax,FSEG
     mov es,ax
     mov ds,ax
     rep movsb
     pop ds
;     mov cx,VirLength
;     mov al,0
;     rep stosb
     pop es
     inc AllFileCured
     lea dx,CureFile
     call Write
     jmp _None1
FromBegOfFile endp
;**************************************************************************
