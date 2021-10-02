.model tiny
locals       
.386         
.code        
             
org     100h

Main            proc
                mov     ax, 3
                int     10h   ; Blank screen

                mov     ah, 2
                xor     bx, bx
                mov     dx, 1900h
		int	10h

		push	ds
		pop	es
                mov     bp, offset FinPrograma ;+ 800h
                mov     ax, 1110h
                mov     bx, 0A00h ;1000h
                mov     cx, 100h
                xor     dx, dx
		int	10h

                mov     dx, offset Buffer
                push    cs
                pop     es
                mov     ax, 1009h
                int     10h
                mov     al, cs:[Buffer+2]
                mov     cs:[Buffer+1], al
                mov     cs:[Buffer+4], al
                mov     al, cs:[Buffer+7]
                mov     cs:[Buffer+5], al
                mov     cs:[Buffer+6], al
                mov     al, cs:[Buffer+0Ah]
                mov     cs:[Buffer+0Bh], al
                mov     cs:[Buffer+0Ch], al
                mov     al, cs:[Buffer+0Fh]
                mov     cs:[Buffer+0Dh], al
                mov     cs:[Buffer+0Eh], al
                mov     ax, 1002h
                int     10h

                call    SetInt1Ch
                call    DoMatrix
                call    QuitInt1Ch
                
   @@Error:     mov     ax, 0003
                int     10h
                mov     ax, 4c00h
                int     21h
Main            endp

DoMatrix        proc
                mov     ax, 0B800h
                mov     es, ax

      @@Other1:
                xor     bp, bp
      @@Other_1:
                mov     bx, bp
                call    Random
                and     al, 0Fh
                jnz   @@Incrementa
                mov     byte ptr [bx+Columnas], 0
                jmp   @@Pinta
 @@Incrementa:  cmp     byte ptr [bx+Columnas], 0
                ja    @@Incrementa2
                call    Random
                and     al, 07h
               ; jnz   @@Pinta
                jnz  @@OK_2
               ; jmp   @@Incrementa3
@@Incrementa2: ; call    Random
               ; and     al, 3
               ; jz    @@Pinta
@@Incrementa3:  inc     byte ptr [bx+Columnas]
      @@Pinta:  movzx   ax, byte ptr [bx+Columnas]
                push    ax
                shl     bx, 1
                shl     ax, 7
                add     bx, ax
                shr     ax, 2
                add     bx, ax
                pop     ax
            ;    and     byte ptr es:[bx+1], 0Fh
            ;    and     byte ptr es:[bx+0A0h+0A0h+1], 0Fh
                or      byte ptr es:[bx+0A0h+1], 0Fh ; 70h
                or      ax, ax
                jz    @@OK_2
                mov     ah, 0Ah
                push    bx
      @@Other2: call    Random
               ; and     al, 7Fh ; 3Fh
               ; cmp     al, 70h ; 38h
               ; jae   @@Other2
               ; add     al, 4Ch ; 0A6h
                mov     es:[bx], ax
      @@OK:     sub     bx, 00A0h
                jc    @@OK_2_2
                call    Random
                and     al, 1
                jz    @@Other2
                or      bx, bx
                jns   @@OK
        @@OK_2_2:
                pop     bx
                or      byte ptr es:[bx+1], 0Fh
        @@OK_2:
                inc     bp
                ; inc    bp ; provisional
                cmp     bp, 80
                jnz   @@Other_1
comment ^
  @@PonCursor:  xor     bx, bx
    @@Loop_01:  movzx   ax, byte ptr [bx+Columnas]
                or      ax, ax
                jz    @@SiguienteCursor
                mov     di, bx
                shl     ax, 7
                add     di, ax
                shr     ax, 2
                add     di, ax
                or      byte ptr es:[di+1], 70h
                and     byte ptr es:[di+1-00A0h], 0Fh
@@SiguienteCursor:
                inc     bx
                cmp     bx, 00080d
                jnz   @@Loop_01
^
     @@Fades:   xor     di, di
     @@Loop_02: movzx   bx, byte ptr [di+Columnas]
                or      bl, bl
                jnz   @@Next
@@RestaTodaLinea:
                mov     si, di
                shl     si, 1
     @@Loop_03: cmp     byte ptr es:[si+1], 0
                jz    @@Next3
     @@Salto01: movzx   bx, byte ptr es:[si+1]
                mov     bl, byte ptr [bx+Greens]
                mov     byte ptr es:[si+1], bl
       @@Next3: add     si, 00A0h
                cmp     si, 00A0h*0040d ; 25d
                jb    @@Loop_03
                jmp   @@Next2

    @@Next:     mov     si, di
                mov     bx, di
                shl     si, 1
                add     si, 00A0h*0039d ; 24d
  @@Siguiente2: cmp     byte ptr es:[si+1], 0
                jz    @@Siguiente
                cmp     byte ptr es:[bx+di+1], 0Ah
                jnz   @@RestaTodaLinea
@@RestaHasta0A: cmp     byte ptr es:[si+1], 0Ah
                jz    @@Next2
                push    bx
                movzx   bx, byte ptr es:[si+1]
                mov     cx, bx
                and     bx, 000Fh
                mov     bl, byte ptr [bx+Greens]
                and     cl, 0F0h
                or      bl, cl
                mov     byte ptr es:[si+1], bl
                pop     bx
                sub     si, 00A0h
                jnc   @@RestaHasta0A
                jmp   @@Next2

  @@Siguiente:  sub     si, 00A0h
                jnc   @@Siguiente2

    @@Next2:    inc     di
                cmp     di, 80
                jnz   @@Loop_02

                mov     di, 1
      @@LoopKK: and     byte ptr es:[di], 0Fh
                add     di, 2
                cmp     di, 00A0h*0002
                jb    @@LoopKK

                call    Espera
                call    Espera

                mov     ah, 01
                int     16h
                jz    @@Other1

                ret
DoMatrix        endp

comment ^
ReadFile        proc
                push    ax
                push    bx
                push    dx
                push    ds
                mov     ax, 3D00h
                int     21h
                jc    @@Error
                mov     bx, ax
                mov     ah, 3Fh
                push    es
                pop     ds
                mov     dx, di
                int     21h
                jc    @@Error
                mov     cx, ax
                mov     ah, 3Eh
                int     21h
                clc
       @@Error: pop     ds
                pop     dx
                pop     bx
                pop     ax
                ret
ReadFile        endp
^

Espera          proc
                mov     byte ptr cs:[Esperando], 1
       @@Loop:  cmp     byte ptr cs:[Esperando], 0
                jnz   @@Loop
                ret
Espera          endp

Esperando       db      0

NewInt1Ch       proc
                mov     byte ptr cs:[Esperando], 0
                iret
NewInt1Ch       endp

AntInt1Ch       dw      2 dup (0)

SetInt1Ch       proc
                push    ds
                xor     ax, ax
                mov     ds, ax
                mov     ax, word ptr ds:[001Ch*4]
                mov     cs:[AntInt1Ch], ax
                mov     ax, word ptr ds:[001Ch*4+2]
                mov     cs:[AntInt1Ch+2], ax
                cli
                mov     word ptr ds:[001Ch*4], offset NewInt1Ch
                mov     word ptr ds:[001Ch*4+2], cs
                sti
                pop     ds
                ret
SetInt1Ch       endp

QuitInt1Ch      proc
                xor     ax, ax
                mov     ds, ax
                cli
                mov     ax, cs:[AntInt1Ch]
                mov     word ptr ds:[001Ch*4], ax
                mov     ax, cs:[AntInt1Ch+2]
                mov     word ptr ds:[001Ch*4+2], ax
                sti
                ret
QuitInt1Ch      endp


Random          proc
                in      al, 40h
                add     al, byte ptr cs:[Aleatorio]
                add     byte ptr cs:[Aleatorio], al
                rol     al, 1
                ret
Random          endp

Aleatorio       db      12h
Aleatorio2      db      34h

Buffer  db      20h dup (0)

Greens          db      0,4,1,0,0,2,5,6,0,0,0Bh,0Ch,07h,0Eh,7,0Dh ; 7
Columnas        db      80 dup (0)                 ;0Fh      ;0Dh

FinPrograma     label   word

include matrix.fnt

                end     Main
