
;                             "�� �����祭��� ⮬� ��室����� ������ 䠩��.
;                              � ᫥���騩 ࠧ �� ������ �஢����,
;                              ����� �� ������� ��� �� ���ன�⢠..."
;                                                              (c) IFSMGR.VXD
;

pages                   equ     2
virsize                 equ     pages*4096

                        .386p
                        locals
                        jumps
                        .model  flat

include                 sdata.inc

                        .code
start:

                        db      virsize dup (0CCh)  ; initialize code
                        org     $-virsize

defpage                 macro   x
page&x&:
include                 #page_&x&.inc
page&x&_size            equ     $-page&x&
                        org     page&x&+4096
                        endm

                        defpage 1
                        defpage 2

initialize:             jmp     main

include                 info.inc

                        end     initialize
                                                                                                                                                                                                                           
