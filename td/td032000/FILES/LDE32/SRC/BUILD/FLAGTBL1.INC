; GENERATED FILE. DO NOT EDIT
; ----- begin of FLAGTBL1.INC -----
@@buildflagtbl:
xor     eax, eax
push    eax
push    eax
push    eax
push    000AAAA00h
push    00FFFDA1Fh
push    0FFF9B7A8h
push    036F57FFFh
push    0FFFFAAAAh
push    0AAAAAAAAh
push    0AAAA8000h
push    eax
push    eax
push    eax
push    eax
push    eax
push    eax
push    000000055h
push    0107FFD55h
push    05577B76Ah
push    084E55444h
push    0444447FFh
push    0FEABFE86h
push    0A66B9F2Dh
push    0FA65AD55h
push    055555511h
push    0111111AAh
push    0A51AAB36h
push    06CD9AA8Eh
push    06AAAABFFh
push    0FFFDADF2h
push    0D1111111h
push    011111111h
push    01AA68F95h
push    08C867BDFh
push    0AAAAAAAAh
push    0AAAAAAAAh
push    0ABA94FFDh
push    0D4A7FEEAh
push    053FF7529h
push    0FFA4A7FEh
push    0929FF24Ah
push    07FE929FFh
mov     ecx, 512
xor     ebx, ebx
@@cycle:
call    @@tree
stosd
loop    @@cycle
retn
@@getbit:
or      ebx, ebx
jnz     @@skip
pop     eax
pop     esi
pop     edx
push    esi
push    eax
mov     bl, 32
@@skip:
dec     ebx
shr     edx, 1
retn
@@tree:
call    @@getbit
jnc     @@tree0
@@tree1:
call    @@getbit
jnc     @@tree10
@@tree11:
mov     eax, C_MODRM
retn
@@tree10:
call    @@getbit
jc      @@tree101
@@tree100:
call    @@getbit
jnc     @@tree1000
@@tree1001:
call    @@getbit
jnc     @@tree10010
@@tree10011:
call    @@getbit
jc      @@tree100111
@@tree100110:
call    @@getbit
jnc     @@tree1001100
@@tree1001101:
mov     eax, C_MEM67
retn
@@tree1001100:
call    @@getbit
jnc     @@tree10011000
@@tree10011001:
mov     eax, C_DATA2
retn
@@tree10011000:
call    @@getbit
jnc     @@tree100110000
@@tree100110001:
mov     eax, C_PREFIX+C_67
retn
@@tree100110000:
mov     eax, C_PREFIX+C_66
retn
@@tree100111:
call    @@getbit
jnc     @@tree1001110
@@tree1001111:
mov     eax, C_MODRM+C_DATA66
retn
@@tree1001110:
call    @@getbit
jnc     @@tree10011100
@@tree10011101:
mov     eax, C_DATA2+C_DATA1
retn
@@tree10011100:
mov     eax, C_DATA66+C_MEM2
retn
@@tree10010:
mov     eax, C_DATAW0
retn
@@tree1000:
mov     eax, C_DATA1
retn
@@tree101:
call    @@getbit
jnc     @@tree1010
@@tree1011:
call    @@getbit
jnc     @@tree10110
@@tree10111:
mov     eax, C_PREFIX
retn
@@tree10110:
mov     eax, C_MODRM+C_DATA1
retn
@@tree1010:
mov     eax, C_DATA66
retn
@@tree0:
call    @@getbit
jc      @@tree01
@@tree00:
mov     eax, -1
retn
@@tree01:
mov     eax, 0
retn
; ----- end of FLAGTBL1.INC -----
