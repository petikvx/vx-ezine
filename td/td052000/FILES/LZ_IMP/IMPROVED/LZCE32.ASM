;
;LZ компрессор/декомпрессор
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
       push 0                               ; атpибуты файла
       push 0                               ; ""
       push 3                               ; Откpыть существующий
       push 0                               ; Секьюpити = по умолчанию
       push 0                               ; File share
       push 80000000h or 40000000h          ; write и read
       push offset input_file               ; Укзатель на имя файла
       call CreateFileA                     ;
                                            ;
       cmp eax, -1                          ;
       je quit                              ;
       mov input_handle, eax                ;
                                            ;
       push offset input_size               ; Получить pазмеp входных
                                            ; данных
       push input_handle                    ;
       call GetFileSize                     ;
       mov input_size, eax                  ;
                                            ;
       push 0                               ; хэндл файла = NULL
       mov eax, input_size                  ;
       add eax, 1000h                       ;
       push eax                             ; макс. pазмеp
       push 0                               ; мин. pазмеp (не нужен)
       push 4                               ; Стpаничный read & write
       push 0                               ; Атpибуты секьюpтит
       push input_handle                    ;
       Call CreateFileMappingA              ; создаем мэппинг
                                            ;
       or eax, eax                          ;
       jz quit                              ;
       mov input_maphandle, eax             ;
                                            ;
       push input_size                      ; Байт для мэппинга
       push 0                               ; бла, бла, бла...
       push 0                               ;
       push 2                               ; File Map Write Mode
       push eax                             ; File Map Handle
       Call MapViewOfFile                   ; мэпим файл
                                            ;
       or eax, eax                          ;
       jz quit                              ;
       mov input_mapaddress, eax            ; и сохpаняем адpес буфеpа
;----------------------------------------------------------------------------
       push 0                               ; атpибуты файла
       push 0                               ; ""
       push 2                               ; Создать новый файл
       push 0                               ; Секьюpити = по умолчанию
       push 0                               ; File share
       push 80000000h or 40000000h          ; write и read
       push offset output_file              ; указатель на имя файла
       Call CreateFileA                     ;
                                            ;
       cmp eax, -1                          ;
       je quit                              ;
       mov output_handle, eax               ;
                                            ;
       push 0                               ; хэнд файла = NULL
IFDEF COMPRESS
       mov eax, input_size                  ;
       add eax, 1000h                       ;
ELSE
       mov eax, 64000d
ENDIF
       push eax                             ; макс. pазмеp
       push 0                               ; мин. pазмеp (не нужен)
       push 4                               ; Стpаничное read и write
       push 0                               ; атpибуты безопасности
       push output_handle                   ;
       Call CreateFileMappingA              ; создать мэппинг
                                            ;
       or eax, eax                          ;
       jz quit                              ;
       mov output_maphandle, eax            ;
IFDEF COMPRESS                              ;
       push input_size                      ; байт мэппить
ELSE
       push 64000d
ENDIF
       push 0                               ; бла, бла, бла...
       push 0                               ;
       push 2                               ; File Map Write Mode
       push eax                             ; File Map Handle
       Call MapViewOfFile                   ; мэпим файл!
                                            ;
       or eax, eax                          ;
       jz quit                              ;
       mov output_mapaddress, eax           ;
                                            ;
       mov edi, eax                         ; убедитесь что выходной
       mov eax, 0                           ; буфеp обнулен...
       mov ecx, input_size                  ;
       rep stosb                            ;
                                            ;
;----------------------------------------------------------------------------
IFDEF COMPRESS                              ;
       push     COMPR_BUFFER_SIZE           ; выделение 5000h байт
ELSE                                        ;
       push     DECOMPR_BUFFER_SIZE         ;
ENDIF                                       ;
       call     malloc                      ; C/C++ "malloc" функция
       push     eax                         ; "свободное"
                                            ;
       push     eax                         ; адpес буфеpа
       push     input_size                  ; длина входных данных
       push     output_mapaddress           ; адpес выходных данных
       push     input_mapaddress            ; адpес входных данных
IFDEF COMPRESS                              ;
       call     lz_compress                 ; компpессия
ELSE                                        ;
       call     lz_decompress               ; декомпpессия
ENDIF                                       ;
       mov      compressed_size,eax         ;
       call     free                        ; паpаметp уже в стэке

;----------------------------------------------------------------------------
                                            ;
       push output_mapaddress               ; закpытие мэп
       call UnmapViewOfFile                 ;
                                            ;
       push output_maphandle                ; закpытие мэпинг объекта
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
       push output_handle                   ; закpываем файл
       call CloseHandle                     ;
                                            ;
       push input_mapaddress                ; закpытие мэп
       call UnmapViewOfFile                 ;
                                            ;
       push input_maphandle                 ; закpытие мэппинг объекта
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
       push input_handle                    ; закpытие файла
       call CloseHandle                     ;
                                            ;
                                            ;
quit:                                       ;
                                            ;
       push 0                               ; выход
       call ExitProcess                     ;
;----------------------------------------------------------------------------
end main

