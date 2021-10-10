;-----------------------------------------------------------------------------
; Ring3 патчилка всякой гадости в памяти.
; Извиняюсь за отсутствие комментариев.
;-----------------------------------------------------------------------------
SEARCH_&_PATCH_RECORD  struc             ;
spr_len      db ?                        ;
spr_offs     dd ?                        ;
spr_signat   db ?                        ;
ends                                     ;
                                         ;
;-----------------------------------------------------------------------------
; Сигнатурный сканнер + патчер
; EBX -> массив сигнатур
; ESI -> стартовый адрес памяти (откуда начинаем искать)
; EDI -> конечный адрес памяти.
;-----------------------------------------------------------------------------
AAV_SearchAndPatch     proc              ;
      call     @@set_SEH                 ;
                                         ;
      mov      eax, [esp+0Ch]            ;
      or       dword ptr [eax+0A0h], 0FFFh ;
      mov      dword ptr [eax+0B8h], offset @@loop_scan ;
      xor      eax, eax                  ;
      ret                                ;
                                         ;
  @@set_SEH:                             ;
      xor      eax, eax                  ;
      push     dword ptr fs:[eax]        ;
      mov      fs:[eax], esp             ;
                                         ;
      mov      dword ptr @@end_addr[ebp], edi
      mov      edx, ebx                  ;
      mov      eax, dword ptr [ebx.spr_signat]
                                         ;
  @@scan:                                ;
      cmp      eax, [esi]                ;
      je       @@next_signat             ;
                                         ;
  @@loop_scan:                           ;
      inc  esi                           ;
      cmp      esi, 12345678h            ;
  @@end_addr equ $-4                     ;
      jbe      @@scan                    ;
      stc                                ;
      jmp      @@exit                    ;
                                         ;
  @@next_signat:                         ;
      movzx    ecx, [ebx.spr_len]        ;
      jecxz    @@found                   ;
      mov      edi, [ebx.spr_offs]       ;
      add      edi, esi                  ;
      add      ebx, spr_signat           ;
                                         ;
  @@compare:                             ;
      mov      al, [ebx]                 ;
      cmp      al, [edi]                 ;
      jne      @@restore_regs            ;
      inc      ebx                       ;
      inc      edi                       ;
      loop     @@compare                 ;
      jmp      @@next_signat             ;
                                         ;
  @@found:                               ;
      inc      ebx                       ;to patch
                                         ;
  @@next_patch:                          ;
      movzx    ecx, [ebx.spr_len]        ;
      clc                                ;
      jecxz    @@exit                    ;
      mov      edi, [ebx.spr_offs]       ;
      add      edi, esi                  ;
      add      ebx, spr_signat           ;
  @@write:                               ;
      mov      al, [ebx]                 ;
      mov      [edi], al                 ;
      inc      ebx                       ;
      inc      edi                       ;
      loop     @@write                   ;
      jmp      @@next_patch              ;
                                         ;
  @@restore_regs:                        ;
      mov      ebx, edx                  ;
      mov      eax, dword ptr [ebx.spr_signat]
      jmp      @@loop_scan               ;
                                         ;
  @@exit:                                ;
      pop      dword ptr fs:[0]          ;
      pop      eax                       ;
      ret                                ;
AAV_SearchAndPatch     endp              ;
                                         ;
