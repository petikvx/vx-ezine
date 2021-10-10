
; ---------------------------------------------------------------------------
; RPME 1.00
; ---------------------------------------------------------------------------

; exit codes (EAX)
RPME_ERR_SUCCESS        equ     0       ; success, code permutated
RPME_ERR_DISASM         equ     1       ; cant disassemble instruction
RPME_ERR_SMALLBUF       equ     2       ; not enough space in output buffer
RPME_ERR_NOMEMORY       equ     3       ; not enough memory
RPME_ERR_NOTPROGRAMMED  equ     4       ; some situation not programmed yet
RPME_ERR_BADJMP         equ     5       ; bad relative jmp/call within ibuf

; entry flags
CM_STOP                 equ     1       ; JMP/RET-alike instruction
CM_HAVEREL              equ     2       ; have relative argument (CALL,etc)
CM_EXTREL               equ     4       ; rel. arg points to external label
CM_ASSEMBLED            equ     8       ; alredy assembled
CM_XREF                 equ     16      ; label, i.e. have XREF

MAXCMDLEN               equ     16      ; max length of command

; list entry structure
hooy                    struc
h_opcode                db      MAXCMDLEN dup (?) ; opcode
h_ofs                   dd      ? ; pointer to current location (temporary)
h_len                   dd      ? ; length of command
h_flags                 dd      ? ; CM_xxx
h_rel                   dd      ? ; CM_HAVEREL: 0=NULL 1= CM_EXTREL: 0=hooy* 1=BYTE*
h_nxt                   dd      ? ; CM_STOP: 1=NULL 0=hooy* (opcode 'thread')
h_next                  dd      ? ; next entry or NULL
                        ends
