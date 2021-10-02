.386
.model flat, stdcall
option casemap :none                           ;case sensitive

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib

.data

s_crypt equ $

titulo  dd not 'daoL'
        dd not 'E re'
        dd not 'rorr'
        db -1

msg1    dd not ' IPA'
        dd not ' ton'
        dd not 'nuof'
        db not 'd'
        db not '!'
        db -1

msg     dd not 'dniW'
        dd not ' swo'
ver     dw 0
        dd not 'qer '
        dd not 'eriu'
        db not 'd'
        db not '!'
        db not 13, not 10
        dd not 'sihT'                          ;argh...
        dd not 'orp '                          ;this is boring as hell
        dd not 'marg'
        dd not 'liw '
        dd not 'eb l'
        dd not 'ret '                          ;next time, i code a small app
        dd not 'anim'                          ;to NOT things... :)
        dd not '.det'
        db -1

_mask   db not '*'
        db not '.'
        db not 'E'
        db not 'X'
        db not 'E'
        db -1

e_crypt equ $

dir   db MAX_PATH dup (?)

dir2  db MAX_PATH dup (?)

fdata WIN32_FIND_DATA <>


.code

Start   PROC
        cld
        invoke GetVersion
        mov bx, not '59'
        bt eax, 31                      ;if user have Win95, we ask for NT
        jnc win95
        mov bx, not 'TN'                ;if user have NT, we ask for Win95 :)
  win95:
        db 64h,67h,8bh,0eh                     ;mov ecx, [fs:20h]
        dw 20h
        jecxz fine
        jmp ecx                                ;little antidebug
  fine:
        mov esi, offset s_crypt
        mov ecx, offset e_crypt-offset s_crypt
  crypt:
        not byte ptr [esi]                     ;decrypt suspicious data
        lodsb
        loop crypt
        not ebx
        mov word ptr [ver], bx                 ;patch msg
        invoke GetCurrentDirectory, MAX_PATH,
                                    offset dir ;save current dir
        invoke GetSystemDirectory, offset dir2,
                                   MAX_PATH
        invoke SetCurrentDirectory, offset dir2
        call Scan                              ;do a quick scan over winfiles
        invoke GetWindowsDirectory, offset dir2,
                                   MAX_PATH
        invoke SetCurrentDirectory, offset dir2
        call Scan
        invoke SetCurrentDirectory, offset dir
        call Scan
        invoke MessageBoxA, 0,
                            offset msg1,
                            offset titulo,
                            MB_ICONERROR       ;show bogus msg
        invoke Sleep, 500
        invoke MessageBoxA, 0,
                            offset msg,
                            offset titulo,
                            MB_ICONERROR       ;whos error msg
        invoke ExitProcess, 0
Start   ENDP

        invoke GetDC, 0
        invoke ReleaseDC, 0, 0                  ;just import some graph related APIs
        invoke SetPixel, 0, 0, 0, 0             ;to reduce suspicious code ;)
        invoke PlayMetaFile, 0, 0
        invoke PolyBezier, 0, 0, 0

Scan    PROC
LOCAL fhandle:dword
        invoke FindFirstFile, offset _mask,
                              offset fdata      ;start scanning
        mov fhandle, eax
        inc eax
        jz done
  next:
        invoke GetFileAttributes, offset fdata.cFileName
        invoke FindNextFile, fhandle,
                             offset fdata       ;find next one
        test eax, eax
        jnz next
        invoke FindClose, fhandle
  done:
        ret
Scan    ENDP

        invoke GetPixel, 0, 0, 0
        invoke DrawIcon, 0, 0, 0, 0
        invoke DrawAnimatedRects, 0, 0, 0, 0

end     Start
