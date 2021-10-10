;Библиотека для COM-программ
;(c) RedArc

;Inspect_COM_File - менеджер работы с COM-программами

;────────────────────────────────────────────────────────────────────────────
Inspect_COM_File proc near
ICOMF0:
                 call _SpecVpp3
                 call _SpecVpp1
                 call _SpecVpp2
                 jc ICOMF0
                 call PrintOk
ICOMF:
                 ret
Inspect_COM_File endp

