;������⥪� ��� COM-�ணࠬ�
;(c) RedArc

;Inspect_COM_File - �������� ࠡ��� � COM-�ணࠬ����

;����������������������������������������������������������������������������
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

