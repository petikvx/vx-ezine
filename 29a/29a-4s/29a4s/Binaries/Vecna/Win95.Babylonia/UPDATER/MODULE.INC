M_SIGN equ 'DOMV'                              ;Vecna's Module :)


M_PLAIN      equ 0000000000000001b          ;encripted/not encripted
M_COMPATIBLE equ 0000000000000010b          ;use standard calling scheme
M_NOCRC      equ 0000000000000100b          ;file dont use crc32
M_EXTHDR     equ 0000000000001000b          ;module has a extended header


module struc
m_header  dd ?                          ;signature
m_version dd ?                          ;version need to execute
m_flags   dw ?
m_ehdrsz  dw ?                          ;lenght of extra header
m_crc32   dd ?
m_key     dd ?
m_entry   dd ?                          ;entrypoint
module ends

;LOADER_VERSION = 00.01
