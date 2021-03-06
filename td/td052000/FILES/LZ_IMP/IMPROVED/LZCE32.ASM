;
;LZ ��������/����������
;

include lzcd.asi

.486p                                       ;
.model flat                                 ;
locals                                      ;
                                            ;
extrn ExitProcess:proc                      ;
extrn CreateFileA:proc                      ;
extrn CloseHandle:proc                      ;
extrn MapViewOfFile:proc                    ;
extrn CreateFileMappingA:proc               ;
extrn FlushViewOfFile:proc                  ;
extrn GetFileSize:proc                      ;
extrn SetFilePointer:proc                   ;
extrn SetEndOfFile:proc                     ;
extrn UnmapViewOfFile:proc                  ;
extrn malloc:proc                           ;
extrn free:proc                             ;
                                            ;
.data                                       ;
                                            ;
output_handle     dd 0                      ;
output_maphandle  dd 0                      ;
output_mapaddress dd 0                      ;
input_handle      dd 0                      ;
input_maphandle   dd 0                      ;
input_mapaddress  dd 0                      ;
input_size        dd 0                      ;
compressed_size   dd 0                      ;
                                            ;
IFDEF COMPRESS                              ;
 output_file       db 'compress.dat', 0     ;
 input_file        db 'input.dat', 0        ;
ELSE                                        ;
 output_file       db 'output.dat', 0       ;
 input_file        db 'compress.dat', 0     ;
ENDIF                                       ;
                                            ;
                                            ;
.code                                       ;
;----------------------------------------------------------------------------
IFDEF COMPRESS
        include lzc1.inc
ELSE
        include lzd1.inc
ENDIF

main:                                       ;
       push 0                               ; ��p����� 䠩��
       push 0                               ; ""
       push 3                               ; ��p��� �������騩
       push 0                               ; �����p�� = �� 㬮�砭��
       push 0                               ; File share
       push 80000000h or 40000000h          ; write � read
       push offset input_file               ; ����⥫� �� ��� 䠩��
       call CreateFileA                     ;
                                            ;
       cmp eax, -1                          ;
       je quit                              ;
       mov input_handle, eax                ;
                                            ;
       push offset input_size               ; ������� p����p �室���
                                            ; ������
       push input_handle                    ;
       call GetFileSize                     ;
       mov input_size, eax                  ;
                                            ;
       push 0                               ; ����� 䠩�� = NULL
       mov eax, input_size                  ;
       add eax, 1000h                       ;
       push eax                             ; ����. p����p
       push 0                               ; ���. p����p (�� �㦥�)
       push 4                               ; ��p����� read & write
       push 0                               ; ��p����� ᥪ��p��
       push input_handle                    ;
       Call CreateFileMappingA              ; ᮧ���� �������
                                            ;
       or eax, eax                          ;
       jz quit                              ;
       mov input_maphandle, eax             ;
                                            ;
       push input_size                      ; ���� ��� ��������
       push 0                               ; ���, ���, ���...
       push 0                               ;
       push 2                               ; File Map Write Mode
       push eax                             ; File Map Handle
       Call MapViewOfFile                   ; ����� 䠩�
                                            ;
       or eax, eax                          ;
       jz quit                              ;
       mov input_mapaddress, eax            ; � ��p��塞 ��p�� ���p�
;----------------------------------------------------------------------------
       push 0                               ; ��p����� 䠩��
       push 0                               ; ""
       push 2                               ; ������� ���� 䠩�
       push 0                               ; �����p�� = �� 㬮�砭��
       push 0                               ; File share
       push 80000000h or 40000000h          ; write � read
       push offset output_file              ; 㪠��⥫� �� ��� 䠩��
       Call CreateFileA                     ;
                                            ;
       cmp eax, -1                          ;
       je quit                              ;
       mov output_handle, eax               ;
                                            ;
       push 0                               ; ���� 䠩�� = NULL
IFDEF COMPRESS
       mov eax, input_size                  ;
       add eax, 1000h                       ;
ELSE
       mov eax, 64000d
ENDIF
       push eax                             ; ����. p����p
       push 0                               ; ���. p����p (�� �㦥�)
       push 4                               ; ��p���筮� read � write
       push 0                               ; ��p����� ������᭮��
       push output_handle                   ;
       Call CreateFileMappingA              ; ᮧ���� �������
                                            ;
       or eax, eax                          ;
       jz quit                              ;
       mov output_maphandle, eax            ;
IFDEF COMPRESS                              ;
       push input_size                      ; ���� �������
ELSE
       push 64000d
ENDIF
       push 0                               ; ���, ���, ���...
       push 0                               ;
       push 2                               ; File Map Write Mode
       push eax                             ; File Map Handle
       Call MapViewOfFile                   ; ����� 䠩�!
                                            ;
       or eax, eax                          ;
       jz quit                              ;
       mov output_mapaddress, eax           ;
                                            ;
       mov edi, eax                         ; 㡥����� �� ��室���
       mov eax, 0                           ; ���p ���㫥�...
       mov ecx, input_size                  ;
       rep stosb                            ;
                                            ;
;----------------------------------------------------------------------------
IFDEF COMPRESS                              ;
       push     COMPR_BUFFER_SIZE           ; �뤥����� 5000h ����
ELSE                                        ;
       push     DECOMPR_BUFFER_SIZE         ;
ENDIF                                       ;
       call     malloc                      ; C/C++ "malloc" �㭪��
       push     eax                         ; "᢮������"
                                            ;
       push     eax                         ; ��p�� ���p�
       push     input_size                  ; ����� �室��� ������
       push     output_mapaddress           ; ��p�� ��室��� ������
       push     input_mapaddress            ; ��p�� �室��� ������
IFDEF COMPRESS                              ;
       call     lz_compress                 ; ����p����
ELSE                                        ;
       call     lz_decompress               ; ������p����
ENDIF                                       ;
       mov      compressed_size,eax         ;
       call     free                        ; ��p����p 㦥 � �����

;----------------------------------------------------------------------------
                                            ;
       push output_mapaddress               ; ���p�⨥ ���
       call UnmapViewOfFile                 ;
                                            ;
       push output_maphandle                ; ���p�⨥ ������ ��ꥪ�
       call CloseHandle                     ;
                                            ;
       push 0                               ;
       push 0                               ;
       push compressed_size                 ;
       push output_handle                   ;
       call SetFilePointer                  ;
                                            ;
       push output_handle                   ;
       call SetEndOfFile                    ;
                                            ;
       push output_handle                   ; ���p뢠�� 䠩�
       call CloseHandle                     ;
                                            ;
       push input_mapaddress                ; ���p�⨥ ���
       call UnmapViewOfFile                 ;
                                            ;
       push input_maphandle                 ; ���p�⨥ ������� ��ꥪ�
       call CloseHandle                     ;
                                            ;
       push 0                               ;
       push 0                               ;
       push input_size                      ;
       push input_handle                    ;
       call SetFilePointer                  ;
                                            ;
       push input_handle                    ;
       call SetEndOfFile                    ;
                                            ;
       push input_handle                    ; ���p�⨥ 䠩��
       call CloseHandle                     ;
                                            ;
                                            ;
quit:                                       ;
                                            ;
       push 0                               ; ��室
       call ExitProcess                     ;
;----------------------------------------------------------------------------
end main

