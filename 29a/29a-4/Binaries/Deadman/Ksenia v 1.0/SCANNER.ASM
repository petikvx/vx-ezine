                        model   tiny
                        codeseg
                        org     100h
                        .386
 v_id                   equ     8FA0h
 start:                 mov     ax,2524h
                        lea     dx,int24
                        int     21h
                        call    mon_init

 scan:                  lea     dx,masker
                        call    collect
                        jc      nextdrv
                        dec     file_cnt
                        mov     si,dx
                        lodsb
                        or      al,al
                        jnz     $-3
                        cmp     word ptr [si-4],'XE'
                        je      goodext
                        cmp     word ptr [si-4],'OC'
                        jne     scan

 goodext:               inc     file_cnt
                        mov     bp,dx
                        mov     ah,3
                        mov     bh,0
                        int     10h
                        push    dx
                        push    bp
                        mov     dx,bp

                        call    test_infected
                        jnc     no_inf

                        mov     ah,9
                        int     21h
                        pop     dx
                        mov     ah,9
                        int     21h
                        mov     ah,2
                        pop     dx
                        cmp     dh,20
                        jb      allok
                        call    mon_init
                        jmp     rty
 allok:                 int     10h
                        mov     ah,2
                        mov     dl,0ah
                        int     21h
                        mov     dl,0dh
                        int     21h
 rty:                   inc     virused_cnt
                        jmp     scan

 no_inf:                pop     dx
                        mov     ah,9
                        int     21h
                        mov     ah,2
                        pop     dx
                        int     10h
                        jmp     scan

 nextdrv:               add     totfilc,dx
                        inc     byte ptr masker
                        cmp     byte ptr masker,'E'+1
                        jnz     scan

                        movzx   eax,totfilc
                        lea     di,file_number
                        call    count
                        mov     eax,virused_cnt
                        lea     di,vir_asciz
                        call    count
                        mov     ah,9
                        lea     dx,log
                        int     21h

                        mov     ax,4c00h
                        int     21h

 test_infected:         mov     ax,3d00h
                        int     21h
                        xchg    ax,bx
                        jc      clcret

                        mov     ax,4202h
                        mov     cx,-1
                        mov     dx,-marklen
                        int     21h
                        mov     ah,3fh
                        mov     cx,marklen
                        lea     dx,buffer
                        int     21h
                        xor     cx,ax
                        jnz     clcret
                        lea     si,mark
                        lea     di,buffer
                        mov     cx,marklen
                        repe    cmpsb
                        jnz     clcret

                        lea     dx,cured
                        jmp     stcret

 clcret:                mov     ah,3eh
                        int     21h
                        clc
                        ret

 stcret:                mov     ah,3eh
                        int     21h
                        stc
                        ret
 mark                   db      '[KSENIA/Deadman]',0
 marklen                equ     $-mark

                        include count.inc
 ; --- cut here ---
; подпрограмма "collect" для нахождения файлов по заданной маске
; copyright (c) 1998-99 Deadman
; на входе: cs:dx - маска
; на выходе cs:dx - найденный файл в формате ASCIZ+'$'
; если файлов больше нет, то cf=1 и dx = количество найденных до файлов
; при повторном вызове работает как "find next"
; при отсутствии файлов (cf=1) процедура сбрасывается в режим "find first"
; портит регистры: flags, dx
; замечание: подпрограмма должна быть расположена последней, т.к. ей
; требуется место для хранения DTA вложенных подкаталогов
 collect:
          push    ax bx cx si di bp ds es  ; сохранить регистры \dx

          mov     ah,2fh                   ; получить в es:bx адрес
          int     21h                      ; текущего dta
          push    es bx                    ; сохранить его в стеке

          push    cs cs         ; установить сегментные регистры
          pop     es ds         ; ds и es на сегмент кода

          cmp     fron,0        ; первый вызов (find first)?
          jne     find_next

          mov     in_dx,dx      ; сохранить смещение маски поиска
          mov     file_cnt,0    ; total files found: 0

          mov     si,dx              ; засунуть в di адрес маски
          dec     si
 col_get_eol:                        ; ищем зиро в маске
          inc     si
          cmp     byte ptr [si],0
          jne     col_get_eol        ; нашли?

          std                   ; ищем начало голой маски (например, *.COM)
 get_mask:
          lodsb                 ; считать в al символ
          cmp     al,':'        ; разделитель? (c:...)
          je      have_got
          cmp     al,'\'        ; \...?
          je      have_got
          cmp     si,dx         ; если указана голая маска, т.е. без ":" и "\"
          jae     get_mask      ; то взять за начало оной смещение из dx
          dec     si
 have_got:
          inc     si            ; выравнивание на начало (ебаный std :-)
          inc     si
          mov     msk_pnt,si    ; сохранить смещение
          mov     cx,si         ; вычислить количество байт от начала строки
          sub     cx,dx         ; до начала маски (т.е. путь)

          lea     di,result     ; перекачать путь из юзеровского буфера в
          mov     si,dx         ; буфер результатов
          cld
          repz    movsb
          mov     res_post,di   ; сохранить смещение конца ;-) пути
 find_first:
          mov     ah,4eh        ; ищем первый файл
          jmp     $+4           ; чтоб не испахабили ah

 find_next:
          mov     ah,4fh        ; а тут ищем next
          push    ax dx         ; устанавливаем dta по адресу, указанному
          mov     ah,1ah        ; в переменной "dta_pnt"
          mov     dx,dta_pnt
          int     21h
          pop     dx ax
          mov     cx,0ffefh and (not 1000b) ; ищем все ?*:%;( кроме каталогов
          int     21h
          jc      check_dir     ; нету больше файлов -> перейти в другую
                                ; 'папку'

          mov     si,dta_pnt    ; тута качаем имя и фамилию найденного файла
          add     si,1eh        ; по адресу "res_post"

          mov     di,res_post
          lodsb
          stosb
          or      al,al
          jnz     $-4
 clear:   cmp     byte ptr [di],0ffh
          jz      cleared
          mov     byte ptr [di],20h
          inc     di
          jmp     clear
 cleared: mov     word ptr [di-2],0240dh
          jmp     yes_more

 check_dir:
          mov     ah,4eh                ; ищем папки
          mov     si,res_post
          mov     word ptr [si],'.*'    ; (dir)\(*.*),0
          mov     word ptr [si+2],'*'
          lea     dx,result
          mov     cx,0ffffh             ; это для того, чтобы всякие hidden'ы
 check_again:                           ; не ускользнули от моего глаза
          int     21h
          jc      cd_dotdot             ; тута ниче нету -> делаем псевдо-CD
          mov     si,dta_pnt            ; иначе тестим юнит, есть ли он
          mov     ah,4fh                ; нормальная папка, или он
          cmp     byte ptr [si+1eh],'.' ; файл или (.)(..), т.е. фильтруем
          je      check_again
          cmp     dword ptr [si+1eh],'YCER'
          je      check_again
          cmp     dword ptr [si+1eh],'IRIV'
          je      check_again

 no_virii:
          test    byte ptr [si+15h],10000b
          jz      check_again

          mov     si,dta_pnt            ; нашли папку -> перекачать
          add     si,1eh                ; название в 'result'
          mov     di,res_post

          lodsb
          stosb
          or      al,al
          jnz     $-4
          mov     byte ptr [di-1],'\'   ; конец пути
          mov     ax,di
          xchg    res_post,ax
          mov     si,dta_pnt            ; сохранить указатель на конец пути
          mov     [si+43],ax            ; предыдущего уровня

          mov     si,msk_pnt     ; перекачать маску для поиска в ЭТОЙ папке
          lodsb
          stosb
          or      al,al
          jnz     $-4

          lea     dx,result      ; ищем следующие файлы, затем каталоги
          add     dta_pnt,45
          inc     dir_cnt
          jmp     find_first

 cd_dotdot:                      ; тут надо сделать псевдо CD .. для поиска
          dec     dir_cnt        ; оставшихся файлов и папок в предыдущей
          jz      no_more        ; папке
          sub     dta_pnt,45
          mov     si,dta_pnt
          mov     dx,si
          mov     ah,1ah
          int     21h
          mov     di,[si+43]
          mov     res_post,di
          mov     ah,4fh
          jmp     check_again

 yes_more:                                  ; выводим найденный файл
          inc     dword ptr file_cnt        ; количество найденных файлов
          clc
          mov     fron,1                    ; следующий вызов - find next
          lea     dx,result

 exit:    mov     bp,dx
          pop     dx ds
          pushf
          mov     ah,1ah
          int     21h
          popf
          mov     dx,bp

          pop     es ds bp di si cx bx ax
          ret

 no_more: mov     fron,0                        ; сбрасываем переменные
          mov     dta_pnt,offset dtaz
          mov     dir_cnt,1
          mov     dx,file_cnt                   ; было найдено dx файлов
          stc
          jmp     exit

 fron     db      0
 file_cnt dw      0
 dir_cnt  dw      1
 dta_pnt  dw      dtaz
 msk_pnt  dw      ?
 res_post dw      ?
 in_dx    dw      ?
          db      0ah
 result   db      100h dup (0),0ffh

; --- cut here ---


 int24:                 mov     al,3
                        iret

 mon_init:              mov     ax,3
                        int     10h
                        mov     ah,1
                        mov     ch,100000b
                        int     10h
                        lea     dx,cop
                        mov     ah,9
                        int     21h
       mov     ax,1856h
       int     21h
        cmp     ax,3265h        ; AX=3265 - значит, что копия вируса уже в

                        jnz     initret
                        lea     dx,mem
                        mov     ah,9
                        int     21h
                        xor     ax,ax
                        int     16h
                        xor     ax,ax
                        int     21h
 initret:               ret

 totfilc                dw      0
 cop                    db      "[KSENIA] Virus Finder",0dh,0ah,24h
 mem                    db      "Virus found in memory",0dh,0ah,24h
 masker                 db      "C:\*.*",0
 log                    db      0dh
                        db      '------------------------------------',0dh,0ah
                        db      'Total files tested: '
 file_number            db      15 dup (' '),0dh,0ah
                        db      'Infected: '
 vir_asciz              db      15 dup (' '),0dh,0ah,24h
 cured                  db      'Infected - ',24h
 virused_cnt            dd      0
 buffer                 db      4096 dup (?)
 dtaz                   db      4096 dup (?)

                        end     start
