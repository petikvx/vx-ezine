; BASE64 Encoding Procedure - by Malfunction

; Input parameters:
; -----------------
;    ECX = length of data to encode in bytes
;    ESI = pointer to data to encode
;    EDI = pointer to output buffer
; Output:
; -------
;    ECX = length of encoded data
;
; Remarks: Preserves only EBP, any other register will be destroyed
;          after the call. Output buffer should be DataToEncode * 4/3 + 3
;          bytes of size.

EncodeBase64 proc
        push ebp
        xor ebp,ebp

        call above_charset
charset DB "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        DB "abcdefghijklmnopqrstuvwxyz"
        DB "0123456789+/"
above_charset:
        pop ebx

        push edi

main_loop:
        dec ecx
        js end_base64
        jnz not_one

        movzx edx,byte ptr [esi]
        bswap edx
        inc ecx
        inc ecx
        call encode_bytes
        mov ax,'=='
        stosw
        jmp end_base64

not_one:
        dec ecx
        jnz not_two

        movzx edx,word ptr [esi]
        bswap edx
        xor ecx,ecx
        mov cl,3
        call encode_bytes
        mov al,'='
        stosb
        jmp end_base64        

not_two:
        dec ecx
        push ecx
        movzx edx,word ptr [esi]
        bswap edx
        mov dh,byte ptr [esi+2]
        xor ecx,ecx
        mov cl,4
        call encode_bytes
        pop ecx
        add esi,3
        jmp main_loop

end_base64:
        pop ecx
        sub ecx,edi
        neg ecx

        pop ebp
        ret

encode_bytes:
        cmp ebp,4Ch
        jnz no_crlf
        mov ax,0A0Dh
        stosw
        xor ebp,ebp

no_crlf:
        xor eax,eax
        rol edx,6
        mov al,dl
        and al,00111111b

        xlatb
        stosb
        inc ebp
        loop encode_bytes
        ret
EncodeBase64 endp


; BASE64 Decoding Procedure - by Malfunction

; Input parameters:
; -----------------
;    ESI = pointer to data to decode
;    ECX = size of data in bytes
;    EBX = pointer to output buffer
;
; Output:
; -------
;    EAX = 1 if the call was successful
;    EAX = 0 if an error occurred
;
; Remarks: Output buffer should be DataToDecode * 3/4 bytes of size.
;          The size hold in ECX has to be a multiple of 4!
;          The function checks if there's a character in the data which
;          is not in the BASE64 character set. Like the encoding procedure
;          this procedure destroys any register except EBP.

DecodeBase64 proc
        call above_charset2
charset2 DB "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        DB "abcdefghijklmnopqrstuvwxyz"
        DB "0123456789+/"
above_charset2:
        pop edi

        shr ecx,2
main_dec:
        lodsd
        xor edx,edx
        push ecx
        mov ecx,4

decode:
        cmp al,'='
        jnz scan_loop
        cmp cl,4
        jz error
        imul ecx,6
        shl edx,cl
        jmp store_val

scan_loop:
        push ecx
        push edi
        mov ecx,64
        repnz scasb
        jnz error
        dec edi
        sub edi,offset charset2
        shl edx,6
        or edx,edi
        pop edi
        pop ecx

        shr eax,8
        loop decode
store_val:
        shl edx,8
        bswap edx
        mov [ebx],edx
        add ebx,3

        pop ecx
        loop main_dec

        mov eax,1
        jmp end_proc
error:
        xor eax,eax
end_proc:
        ret
DecodeBase64 endp

