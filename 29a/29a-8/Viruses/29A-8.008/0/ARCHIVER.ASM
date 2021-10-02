.586
.model flat
locals

include header.inc

.data
dotdot    db "..",0
filename2 db "_"
filename  db "0.exe",0
filemask  db "*.*",0

.data?
finddata  WIN32_FIND_DATA ?
memory    dd ?

.code

main:
        sub ebp,ebp
        push 256*1024
        push 40h
        callW GlobalAlloc
        test eax,eax
        jz @@error
        mov [memory],eax
        xchg edi,eax

        push ebp
        push FILE_ATTRIBUTE_NORMAL
        push OPEN_EXISTING
        push ebp
        push FILE_SHARE_READ
        push GENERIC_READ
        push ofs filename2
        callW CreateFileA
        mov ebx,eax
        inc eax
        jz @@error

        push ebp
        push ebx
        callW GetFileSize
        xchg esi,eax

        push ebp
        mov eax,esp

        push ebp
        push eax
        push esi
        push edi
        push ebx
        callW ReadFile
        pop eax
        add edi,eax

        push ebx
        callW CloseHandle

        push ofs dotdot
        callW SetCurrentDirectoryA

        push ofs finddata
        push ofs filemask
        callW FindFirstFileA
        mov ebx,eax
        inc eax
  @@add_file:
        jz @@done_files

        test dwo [finddata.WFD_dwFileAttributes],FILE_ATTRIBUTE_DIRECTORY
        jnz @@next_file

        mov edx,edi
        stosb

        lea esi,[finddata.WFD_szFileName]
  @@cpy_fname:
        lodsb
        stosb
        test al,al
        jnz @@cpy_fname

        mov eax,edi
        sub eax,edx
        dec eax
        mov [edx],al

        or  [esi-5],20202000h
        cmp [esi-5],"tab."
        jne @@skipskip
        mov by [edi-1],1

  @@skipskip:

        pushad

        push ebp
        push FILE_ATTRIBUTE_NORMAL
        push OPEN_EXISTING
        push ebp
        push FILE_SHARE_READ
        push GENERIC_READ
        push ofs finddata.WFD_szFileName
        callW CreateFileA
        mov ebx,eax
        inc eax
        jz @@next_file2

        push ebp
        push ebx
        callW GetFileSize
        xchg edi,eax

        push edi
        push 40h
        callW GlobalAlloc
        test eax,eax
        jz @@next_file3
        xchg esi,eax

        push ebp
        mov eax,esp

        push ebp
        push eax
        push edi
        push esi
        push ebx
        callW ReadFile
        pop eax

        xchg ecx,edi
        mov edi,[esp.Pushad_edi]
        call z_encode_asm

        mov eax,[edi]
        add [esp.Pushad_edi],eax

  @@next_file3:
        push ebx
        callW CloseHandle

  @@next_file2:
        popad

  @@next_file:
        push ofs finddata
        push ebx
        callW FindNextFileA
        test eax,eax
        jmp @@add_file

  @@done_files:
        push ebx
        callW FindClose

        sub eax,eax
        stosd

        push ebp
        push FILE_ATTRIBUTE_NORMAL
        push CREATE_ALWAYS
        push ebp
        push ebp
        push GENERIC_WRITE
        push ofs filename
        callW CreateFileA
        mov ebx,eax
        inc eax
        jz @@error

        push ebp
        mov eax,esp

        sub edi,[memory]
        push ebp
        push eax
        push edi
        push dwo [memory]
        push ebx
        callW WriteFile
        pop eax

        push ebx
        callW CloseHandle

  @@error:
        push ebp
        callW ExitProcess

include z_encode.inc

end     main
