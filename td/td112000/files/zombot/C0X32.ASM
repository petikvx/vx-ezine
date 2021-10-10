
data_crypt_length       equ     4096

                        p386
                        model   flat

_TEXT   segment dword public use32 'CODE'
_TEXT   ends
_DATA   segment dword public use32 'DATA'
data_start:
_DATA   ends
_BSS    segment dword public use32 'BSS'
data_end:
_BSS    ends
DGROUP  group   _BSS,_DATA

_TEXT   segment dword public use32 'CODE'

                        public  __acrtused
__acrtused:

;                       mov     ecx, offset data_end + 4095
;                       sub     ecx, offset data_start
;                       and     ecx, not 4095
;                       shr     ecx, 2

                        mov     ecx, 4096/4

 __cycle:               ror     dword ptr data_start[ecx*4-4], 1
                        loop    __cycle

                        extrn   _main:PROC
                        jmp     _main

                        nop
                        nop
                        nop
                        nop
                        nop

                        public  __InitExceptBlockLDTC
                        label   __InitExceptBlockLDTC
_TEXT   ends

                        end     __acrtused
