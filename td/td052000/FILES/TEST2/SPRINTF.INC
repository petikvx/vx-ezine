;-----------------------------------------------------------------------------
; ���⥩�� ॠ������ �ᥬ ����襩�� �㭪樨.
;-----------------------------------------------------------------------------
; ��ࠢ����� �뢮���:
;    \n        = ����� ��ப� (db  0Dh,0Ah)
;    \\        = \
;    \00000000 = byte/word/dword �᫮ � hex (\0D - ��⠢�� CR, \0A0D - CRLF)
;
;    %         - �ࠪ⮢�� ��।���� ��ࠬ���
;                (��ࠬ���� ������� � �⥪�, �ࠪ������ � �뢮����� � ⮩
;                 ��� ���� �ଥ)
;    %c        = ᨬ���
;
;�����: () - ��易⥫�� ����
;       [] - ����易⥫��
;
;    %s($|c|s|z|00)
;     ��������������� �뢮� ��ப�
;       �������������  �����稢����� �୥� "$"
;         �����������  �����稢����� ᨬ����� CR (0Dh)
;           ���������  �����稢����� �஡����
;             �������  �����稢����� �㫥�
;               �����  ����� ����� 00 hex
;
;    %i[-](b|w|d)(00)(b|d|h)
;     ������������������������ �뢮� 楫���
;       ���������������������� � ������
;            ����������������� byte/word/dword
;                 ������������ ࠧ��� ���� (�᫨ 00 - ��ࠢ������� ᫥��)
;                       ������ binary/decimal/hex
;
;
;-----------------------------------------------------------------------------
LOCALS                                ;�㦭�
sprintf      proc                     ;
      pop    dword ptr @@ret_addr     ;���࠭塞 ���� ������
                                      ;
      pop    edi                      ;EDI -> �����
      pop    esi                      ;ESI -> ��ப� ���樠����樨
                                      ;
  @@main:                             ;
      lodsb                           ;AL=ᨬ���
      or     al, al                   ;�� ����� ��ப�?
      jz     @@exit                   ;��室...
                                      ;
      cmp    al, '\'                  ;�� �ࠢ���騩 ᨬ���?
      jne    @@not_slash              ;�����...
      lodsb                           ;
      cmp    al, 'n'                  ;"\n" ?
      jne    @@not_crlf               ;
      mov    al, 0Dh                  ;�⠢�� CRLF
      call   to_buff                  ;
      mov    al, 0Ah                  ;
      jmp    @@out_char               ;
  @@not_crlf:                         ;
      cmp    al, '\'                  ;"\\" ?
      je     @@out_char               ;�뢮��� ���� ���
   @@its_hex:                         ;
      dec    esi                      ;
      mov    bl, 8                    ;
      call   ascii_to_hex             ;��⠥��� ����� hex �᫮
      jc     @@loop                   ;
      mov    eax, edx                 ;
      or     ecx, ecx                 ;��祣� �� ����稫���?
      jz     @@loop                   ;�����...
      inc    ecx                      ;
      shr    ecx, 1                   ;
   @@write_hex:                       ;�뢮��� �����⭮.
      call   to_buff                  ;
      shr    eax, 8                   ;
      loop   @@write_hex              ;
      jmp    @@loop                   ;
                                      ;
  @@not_slash:                        ;
      cmp    al, '%'                  ;��㣮� �ࠢ���騩 ᨬ���?
      jne    @@out_char               ;�����...
      lodsb                           ;
      cmp    al, 'c'                  ;"%c" ?
      jne    @@not_pchar              ;
      pop    eax                      ;EAX - AL=ᨬ����
      jmp    @@out_char               ;�뢮���
  @@not_pchar:                        ;
      cmp    al, 's'                  ;"%s" ?
      jne    @@not_pstr               ;
      lodsb                           ;
      mov    dl, '$'                  ;DL = ᨬ��� ���� ��ப�
      cmp    al, dl                   ;"%s$" ?
      je     @@out_psx                ;
      mov    dl, 0Dh                  ;
      cmp    al, 'c'                  ;"%sc" ?
      je     @@out_psx                ;
      mov    dl, ' '                  ;
      cmp    al, 's'                  ;"%ss" ?
      je     @@out_psx                ;
      xor    dl, dl                   ;
      cmp    al, 'z'                  ;"%sz" ?
      jne    @@not_psx                ;
                                      ;
  @@out_psx:                          ;
      pop    ecx                      ;ECX -> ��ப�
                                      ;
  @@psx_cycle:                        ;�뢮��� ��ப�
      mov    al, [ecx]                ;
      inc    ecx                      ;
      cmp    al, dl                   ;�� ᨬ���� � DL
      jz     @@loop                   ;
      call   to_buff                  ;
      jmp    @@psx_cycle              ;
                                      ;
  @@not_psx:                          ;
      dec    esi                      ;
      call   is_hex                   ;�� hex?
      jc     @@loop                   ;
      mov    bl, 2                    ;����� ��������㥬 � �᫮
      call   ascii_to_dec             ;
      jc     @@loop                   ;
      mov    ecx, edx                 ;�����㥬 �����, ᪮�쪮 㪠����.
      or     ecx, ecx                 ;
      jz     @@loop                   ;
      pop    edx                      ;EDX -> ��ப�
   @@write_h:                         ;
      mov    al, [edx]                ;
      inc    edx                      ;
      call   to_buff                  ;
      loop   @@write_h                ;
      jmp    @@loop                   ;
                                      ;
  @@not_pstr:                         ;
      cmp    al, 'i'                  ;"%i" ?
      jne    @@not_integer            ;
      lodsb                           ;
      xor    edx, edx                 ;EDX - ����� ���
      cmp    al, '-'                  ;��������?
      jne    @@wo_sign                ;
      lodsb                           ;
      inc    edx                      ;EDX - ���� ����
  @@wo_sign:                          ;
      pop    ebx                      ;EBX = �᫮
                                      ;
      cmp    al, 'd'                  ;Dword?
      jne     @@try_word              ;
      or     edx, edx                 ;��������
      jz     @@sfixed                 ;
      xor    edx, edx                 ;���४��㥬
      test   ebx, ebx                 ;
      jns    @@sfixed                 ;
      inc    edx                      ;
      neg    ebx                      ;
      jmp    @@sfixed                 ;
                                      ;
  @@try_word:                         ;
      cmp    al, 'w'                  ;Word?
      jne     @@byte                  ;
      movzx  ebx, bx                  ;�㫥��� ���७�
      or     edx, edx                 ;
      jz     @@sfixed                 ;
      movsx  ebx, bx                  ;�������� ���७��
      xor    edx, edx                 ;
      test   ebx, ebx                 ;
      jns    @@sfixed                 ;
      inc    edx                      ;
      neg    ebx                      ;
      jmp    @@sfixed                 ;
                                      ;
  @@byte:                             ;Byte!
      movzx  ebx, bl                  ;�㫥��� ���७��
      or     edx, edx                 ;
      jz     @@sfixed                 ;
      movsx  ebx, bl                  ;�������� ���७��
      xor    edx, edx                 ;
      test   ebx, ebx                 ;
      jns    @@sfixed                 ;
      inc    edx                      ;
      neg    ebx                      ;
                                      ;
  @@sfixed:                           ;
      push   ebx edx                  ;
      mov    eax, ebx                 ;
      mov    bl, 2                    ;
      call   ascii_to_dec             ;��६ �ਭ� ����
      mov    ecx, edx                 ;
      pop    edx ebx                  ;
      jc     @@loop                   ;
                                      ;EBX = �᫮
                                      ;ECX = �ਭ� ���� �뢮��
                                      ;EDX = ����
                                      ;
      lodsb                           ;��६ ᨬ��� �ଠ�
      push   ebx                      ;
      mov    ebx, 16                  ;EBX = �᭮����� ��⥬� (16 - hex)
      cmp    al, 'h'                  ;hex?
      je     @@convert                ;
      mov    ebx, 10                  ;10 - dec
      cmp    al, 'd'                  ;dec?
      je     @@convert                ;
      mov    ebx, 2                   ;2 - bin
  @@convert:                          ;
      pop    eax                      ;EAX = �᫮
      call   all_to_ascii             ;�뢮���
      jmp    @@loop                   ;
                                      ;
  @@not_integer:                      ;
                                      ;
  @@out_char:                         ;
      call   to_buff                  ;�뢮� ᨬ���� � �����
                                      ;
  @@loop:                             ;
      jmp    @@main                   ;������
                                      ;
  @@exit:                             ;
      xor    al, al                   ;�뢮��� 0
      call   to_buff                  ;
      push   12345678h                ;�����頥���
  @@ret_addr equ $-4                  ;
      ret                             ;
sprintf      endp                     ;
                                      ;
;-----------------------------------------------------------------------------
;�뢮� ᨬ���� � �����
;AL = ᨬ���
;EDI -> �����
;-----------------------------------------------------------------------------
to_buff      proc                     ;
      mov    [edi], al                ;
      inc    edi                      ;
      ret                             ;
to_buff      endp                     ;
                                      ;
;-----------------------------------------------------------------------------
;��।����, �७������� �� ᨬ��� �������� �������� ������
;AL = ᨬ���
;��室: CF = 0 - �७�������
;            1 - ���
;-----------------------------------------------------------------------------
is_dec         proc                   ;
      cmp      al, '0'                ;
      jb       @@exit                 ;
      cmp      al, '9'                ;
      ja       @@exit                 ;
      clc                             ;
      ret                             ;
  @@exit:                             ;
      stc                             ;
      ret                             ;
is_dec         endp                   ;
                                      ;
;-----------------------------------------------------------------------------
;��।����, �७������� �� ᨬ��� �������� ��⭠������� ������
;AL = ᨬ���
;��室: CF = 0 - �७�������
;            1 - ���
;-----------------------------------------------------------------------------
is_hex         proc                   ;
      call     is_dec                 ;
      jnc      @@ok                   ;
      and      al, 0DFh               ;
      cmp      al, 'A'                ;
      jb       @@exit                 ;
      cmp      al, 'F'                ;
      jbe      @@ok                   ;
  @@exit:                             ;
      stc                             ;
      ret                             ;
  @@ok:                               ;
      clc                             ;
      ret                             ;
is_hex         endp                   ;
                                      ;
;-----------------------------------------------------------------------------
;�८�ࠧ�� HEX ����� ASCII � �᫮ (४��ᨢ��)
;ESI -> ascii ��ப�
; BL =  ᪮�쪮 ᨬ����� �८�ࠧ��뢠�� (��࠭��⥫� ४��ᨨ)
;��室:
; ECX = ᪮�쪮 ᨬ����� ����⢨⥫쭮 �८�ࠧ�����
; EDX = �᫮
;-----------------------------------------------------------------------------
ascii_to_hex   proc                   ;
      xor      edx, edx               ;
      xor      ecx, ecx               ;
      mov      al, [esi]              ;
      call     is_hex                 ;
      jc       @@exit                 ;
      sub      bl, 1                  ;
      jc       @@exit                 ;
      inc      esi                    ;
                                      ;
      push     ax                     ;
      call     ascii_to_hex           ;
      pop      ax                     ;
                                      ;
      movzx    eax, al                ;
      sub      al, '0'                ;
      cmp      al, 9                  ;
      jbe      @@1                    ;
      sub      al, 'A'-'0'-0Ah        ;
  @@1:                                ;
      push     ecx                    ;
      shl      ecx, 2                 ;
      shl      eax, cl                ;
      or       edx, eax               ;
      pop      ecx                    ;
      inc      ecx                    ;
      clc                             ;
                                      ;
  @@exit:                             ;
      ret                             ;
ascii_to_hex   endp                   ;
                                      ;
;-----------------------------------------------------------------------------
;�८�ࠧ�� DEC ����� ASCII � �᫮ (४��ᨢ��)
;ESI -> ascii ��ப�
; BL =  ᪮�쪮 ᨬ����� �८�ࠧ��뢠�� (��࠭��⥫� ४��ᨨ)
;��室:
; ECX = ᪮�쪮 ᨬ����� ����⢨⥫쭮 �८�ࠧ�����
; EDX = �᫮
;-----------------------------------------------------------------------------
ascii_to_dec   proc                   ;
      xor      edx, edx               ;
      xor      ecx, ecx               ;
      mov      al, [esi]              ;
      call     is_dec                 ;
      jc       @@exit                 ;
      sub      bl, 1                  ;
      jc       @@exit                 ;
                                      ;
      inc      esi                    ;
                                      ;
      push     ax                     ;
      call     ascii_to_dec           ;
      pop      ax                     ;
                                      ;
      movzx    eax, al                ;
      sub      al, '0'                ;
      push     ecx                    ;
      jecxz    @@add                  ;
   @@pow:                             ;
      lea      ebx, [eax*2]           ;
      lea      eax, [eax*8+ebx]       ;
      loop     @@pow                  ;
                                      ;
  @@add:                              ;
      add      edx, eax               ;
      pop      ecx                    ;
      inc      ecx                    ;
      clc                             ;
                                      ;
  @@exit:                             ;
      ret                             ;
ascii_to_dec   endp                   ;
                                      ;
;-----------------------------------------------------------------------------
                                      ;
get_max_cap    proc                   ;
      mov      ecx, 7                 ;
      cmp      ebx, 16                ;
      je       @@exit                 ;
      mov      ecx, 9                 ;
      cmp      ebx, 10                ;
      je       @@exit                 ;
      mov      ecx, 31                ;
  @@exit:                             ;
      ret                             ;
get_max_cap    endp                   ;
                                      ;
;-----------------------------------------------------------------------------
;�⥯���
;-----------------------------------------------------------------------------
pow   proc                            ;
      push     eax ecx                ;
                                      ;
      mov      ebx, edx               ;
      xor      eax, eax               ;
      inc      eax                    ;
      jecxz    @@exit                 ;
  @@pow:                              ;
      mul      ebx                    ;
      loop     @@pow                  ;
                                      ;
  @@exit:                             ;
      mov      ebx, eax               ;
      pop      ecx eax                ;
      ret                             ;
pow   endp                            ;
                                      ;
;-----------------------------------------------------------------------------
;��� � ASCII
;���� �� ����������, ���, ᠬ� ������ (�᫨ ���)
;-----------------------------------------------------------------------------
all_to_ascii   proc PASCAL
      LOCAL    Frame:Dword, Digs:DWord, Buffe:Byte:32, DBS:DWord, Capa:DWord
      USES     esi                    ;
                                      ;
      lea      esi, Buffe             ;
      mov      DBS, ebx               ;
      mov      Frame, ecx             ;
      mov      Digs, 0                ;
                                      ;
      call     get_max_cap            ;
      mov      Capa, ecx              ;
                                      ;
      or       edx, edx               ;
      jz       @@rec                  ;
      push     eax                    ;
      mov      al, '-'                ;
      call     to_buff                ;
      pop      eax                    ;
                                      ;
 @@rec:                               ;
      mov      edx, DBS               ;
      call     pow                    ;
                                      ;
      xor      edx, edx               ;
      div      ebx                    ;
                                      ;
      cmp      Digs, 0                ;
      jne      @@2                    ;
      or       eax, eax               ;
      jz       @@2                    ;
      mov      Digs, ecx              ;
  @@2:                                ;
      mov      [esi], al              ;
      inc      esi                    ;
      mov      eax, edx               ;
      sub      ecx, 1                 ;
      jnc      @@rec                  ;
      inc      Digs                   ;
                                      ;
      lea      esi, Buffe             ;
      add      esi, Capa              ;
      inc      esi                    ;
      mov      ecx, Digs              ;
      sub      esi, ecx               ;
                                      ;
      mov      eax, Frame             ;
      mov      ebx, eax               ;
      sub      eax, ecx               ;
      jbe      @@gen_chars            ;
                                      ;
      mov      ecx, eax               ;
      mov      al, '0'                ;
  @@fill:                             ;
      call     to_buff                ;
      loop     @@fill                 ;
      mov      ecx, Digs              ;
                                      ;
  @@gen_chars:                        ;
      mov      al, [esi]              ;
      add      al, '0'                ;
      cmp      al, '9'                ;
      jbe      @@3                    ;
      add      al, 'A'-'0'-0Ah        ;
  @@3:                                ;
      call     to_buff                ;
      inc      esi                    ;
      loop     @@gen_chars            ;
                                      ;
      ret                             ;
all_to_ascii   endp                   ;
                                      ;
