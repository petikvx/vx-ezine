;Данные антивируса

memaddr dd ? ;адрес памяти для сканирования
baddr   dd ? ;адрес искомого блока
msize   dw ? ;размер памяти для сканирования
bsize   dw ? ;размер искомого блока

AllFileMask db '*.*',0h ;маска файлов для поиска

MaskByte db ? ;Флаг для определения соответствия расширения файла
Result   db ? ;Результат работы антивируса
              ;0 - все в порядке
              ;1 - найдены инфецированные файлы
              ;2 - вылечены инфецированные файлы
              ;3 - найдены подозрительные файлы
              ;4 - удалены подозрительные файлы
              ;5 - найдены модификации вирусов
              ;6 - удалены модификации вирусов
              ;7 - прерывание программы пользователем
              ;8 - ошибка работы антивируса

AllSignature dw ? ;Количество подключенных вирусов

ProtokolAllFileScaned dw ? ;проверено файлов
ProtokolAllFileInfect dw ? ;инфецировано файлов
ProtokolAllFileCured  dw ? ;вылечено файлов
ProtokolAllFileDelete dw ? ;удалено файлов
ProtokolAllFileModify dw ? ;найдено модификаций вирусов
ProtokolAllFileUnknow dw ? ;найдено подозрительных файлов
ProtokolAllVirusName  dw ? ;найдено вирусов
ProtokolAllErrorFile  dw ? ;ошибок при работе с файлами

ProtokolFHandle dw ? ;хэндлер файла текстового протокола
OpenFileHandle  dw ? ;хэндлер тестируемого файла

TabelleFileExtension: ;таблица стандартных расширений файлов
ExeExt db 4,'.EXE' ;Расширение EXE-файлов
ComExt db 4,'.COM' ;Расширение COM-файлов
EndExt dw ?       ;Конец таблицы расширений

ProtNameTxt db 'redarc.rpt',0h ;имя файла с протоколом
MainBased   db 'redarc.vbs',0h ;имя основной вирусной базы
AddBased    db '*.ubs',0h      ;расширение апдейтов для базы сигнатур
AddProced   db '*.plg',0h      ;расширение апдейтов для процедур PlugIn


AboutMsg db 0ah,0dh ;Информация о текущей версии антивируса
         db '┌───────────────────────╖',0ah,0dh
         db '│ Антивирус RedArc v1.0 ║',0ah,0dh
         db '├───────────────────────╢',0ah,0dh
         db '│Вирусов в базе:  ##### ║',0ah,0dh
         db '╘═══════════════════════╝',0ah,0dh
         db '$'

CtrlEOF  db 0ah,0dh,'$'
ErrorMsg db 'ой блин$'
ClearMsg db 'Ok$'
AlertMsg db 'найдена вошь $'
CuredMsg db ' - исдохдла - $'
DeletMsg db ' - объект ампутирован$'
ModifMsg db 'косит под $'
UnknoMsg db 'кажись не мылся давно$'
FileName db 12 dup (?)
         db ' - $'
VirusName db 12 dup (?)
          db ' $'

;--- протокол ---
PErrorMsg db 'ошибка'
PClearMsg db 'Ok'
PAlertMsg db 'инфецирован '
PCuredMsg db ' - вылечен'
PDeletMsg db ' - объект удален'
PModifMsg db 'модификация вируса '
PUnknoMsg db 'возможно инфецирован'
;--- протокол ---

;--- флаги ---
FPFlag db ? ;Флаг создания текстового протокола
;--- флаги ---

