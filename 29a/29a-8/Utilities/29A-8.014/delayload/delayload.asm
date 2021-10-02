.586p
.model flat,stdcall
option casemap:none

include C:\masm32\include\windows.inc

include C:\masm32\include\user32.inc
includelib C:\masm32\lib\user32.lib

include C:\masm32\include\kernel32.inc
includelib C:\masm32\lib\kernel32.lib

.data

ddHint  dd 0
hwndDlg dd 0
szName  db "Delayload",0
szDesc  db "Delayloaded Executables",0

.code
DllEntry proc hInstance:HINSTANCE, reason:DWORD, reserved1:DWORD
	mov eax, [esp+4]
        mov [ddHint], eax
        mov  eax,1
	ret
DllEntry endp

PibBeg:
PibFunc proc
        ; int 3
        
        call GetDeltaVal
        
        GetDeltaVal:
        pop ebp
        sub ebp, offset GetDeltaVal

        jmp @F

        seccount dd 0
        kern     db "KERNEL32.DLL",0
        _sleep   db "Sleep",0

        @@:
        mov esi, [esp+4]
        add esi, 35h
        lodsd
        lea ebx, [ebp+kern]
        push ebx
        call eax ; LoadLibrary("KERNEL32.DLL")
        
        mov esi, [esp+4]
        lea ebx, [ebp+_sleep]
        push ebx
        push eax
        add esi, 39h
        lodsd
        call eax

        push dword ptr [ebp+seccount]
        call eax

        ret
PibFunc endp
PibEnd:

PibSizeFunc proc
        mov eax, (offset PibEnd - offset PibFunc)
        ret
PibSizeFunc endp

PibDlgFunc proc hwnd:DWORD, wmsg:DWORD, wparam:DWORD, lparam:DWORD
        mov eax, wmsg
        
        cmp eax, 110h ; WM_INITDIALOG
        jne @F
        mov eax, [hwnd]
        mov [hwndDlg], eax
        mov eax, 1
        ret

        @@:
        cmp eax, 10h ; WM_CLOSE
        jne @F
        push 0
        push [hwndDlg]
        call EndDialog
        xor eax, eax
        ret
        
        @@:
        cmp eax, 111h ; WM_COMMAND
        jne @F
        mov eax, wparam
        cmp ax, 1000
        je CalcAmt
        xor eax, eax
        ret

        @@:
        xor eax, eax
        ret
        
        CalcAmt:
        push 0
        push 0
        push 1001
        push hwnd
        call GetDlgItemInt
        
        ; int 3
        mov dword ptr [seccount], eax
        push 0
        push [hwndDlg]
        call EndDialog
        xor eax, eax
        ret
PibDlgFunc endp

PibClient proc
        ; int 3

        call GetCurrentBase

        push 0
        push offset PibDlgFunc
        push 0
        push 101
        push edx
        call DialogBoxParam
        ret
PibClient endp

PibClientWrap proc
        ; int 3
        nop
        nop
        ret
PibClientWrap endp

PibInfo proc C dwAddr:DWORD
        ;
        ; INFO STRUCT
	; char szName[20];
	; char szDesc[255];
	; BYTE bHiVer;
	; BYTE hLowVer;
	; ENDS
	;

        ; int 3
        pushad

        mov esi, offset szName
        mov edi, dword ptr [dwAddr]
        mov ecx, 5
        rep movsb
        
        mov esi, offset szDesc
        mov edi, dword ptr [dwAddr]
        add edi, 256
        mov ecx, 12
        rep movsb

        mov edi, dword ptr [dwAddr]
        mov byte ptr [edi+512], 1
        mov byte ptr [edi+513], 0
        mov byte ptr [edi+514], 3
        
        popad
        
        ret
PibInfo endp

GetCurrentBase proc
    call GetBaseOfPE

    GetBaseOfPE:
    pop edx

    LoopToFindMZ:
    cmp word ptr [edx], IMAGE_DOS_SIGNATURE
    jz LoopToFindNT
    dec edx
    jmp LoopToFindMZ
    
    LoopToFindNT:
    movzx ecx, word ptr [edx+3ch]
    add ecx, edx
    push edx
    push ecx
    push 4
    push ecx
    call IsBadReadPtr
    pop ecx
    pop edx
    or eax, eax
    jnz badaddr

    cmp dword ptr [ecx], IMAGE_NT_SIGNATURE
    jz FinishLooping
    badaddr:
    dec edx
    jmp LoopToFindMZ
    
    FinishLooping:
    TotalFinish:

    ret
GetCurrentBase endp

end DllEntry
