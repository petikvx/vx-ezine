;����� ��⨢����

memaddr dd ? ;���� ����� ��� ᪠��஢����
baddr   dd ? ;���� �᪮���� �����
msize   dw ? ;ࠧ��� ����� ��� ᪠��஢����
bsize   dw ? ;ࠧ��� �᪮���� �����

AllFileMask db '*.*',0h ;��᪠ 䠩��� ��� ���᪠

MaskByte db ? ;���� ��� ��।������ ᮮ⢥��⢨� ���७�� 䠩��
Result   db ? ;������� ࠡ��� ��⨢����
              ;0 - �� � ���浪�
              ;1 - ������� ����஢���� 䠩��
              ;2 - �뫥祭� ����஢���� 䠩��
              ;3 - ������� ������⥫�� 䠩��
              ;4 - 㤠���� ������⥫�� 䠩��
              ;5 - ������� ����䨪�樨 ����ᮢ
              ;6 - 㤠���� ����䨪�樨 ����ᮢ
              ;7 - ���뢠��� �ணࠬ�� ���짮��⥫��
              ;8 - �訡�� ࠡ��� ��⨢����

AllSignature dw ? ;������⢮ ������祭��� ����ᮢ

ProtokolAllFileScaned dw ? ;�஢�७� 䠩���
ProtokolAllFileInfect dw ? ;����஢��� 䠩���
ProtokolAllFileCured  dw ? ;�뫥祭� 䠩���
ProtokolAllFileDelete dw ? ;㤠���� 䠩���
ProtokolAllFileModify dw ? ;������� ����䨪�権 ����ᮢ
ProtokolAllFileUnknow dw ? ;������� ������⥫��� 䠩���
ProtokolAllVirusName  dw ? ;������� ����ᮢ
ProtokolAllErrorFile  dw ? ;�訡�� �� ࠡ�� � 䠩����

ProtokolFHandle dw ? ;������� 䠩�� ⥪�⮢��� ��⮪���
OpenFileHandle  dw ? ;������� ����㥬��� 䠩��

TabelleFileExtension: ;⠡��� �⠭������ ���७�� 䠩���
ExeExt db 4,'.EXE' ;����७�� EXE-䠩���
ComExt db 4,'.COM' ;����७�� COM-䠩���
EndExt dw ?       ;����� ⠡���� ���७��

ProtNameTxt db 'redarc.rpt',0h ;��� 䠩�� � ��⮪����
MainBased   db 'redarc.vbs',0h ;��� �᭮���� ����᭮� ����
AddBased    db '*.ubs',0h      ;���७�� �����⮢ ��� ���� ᨣ�����
AddProced   db '*.plg',0h      ;���७�� �����⮢ ��� ��楤�� PlugIn


AboutMsg db 0ah,0dh ;���ଠ�� � ⥪�饩 ���ᨨ ��⨢����
         db '�����������������������ķ',0ah,0dh
         db '� ��⨢���� RedArc v1.0 �',0ah,0dh
         db '�����������������������Ķ',0ah,0dh
         db '�����ᮢ � ����:  ##### �',0ah,0dh
         db '�����������������������ͼ',0ah,0dh
         db '$'

CtrlEOF  db 0ah,0dh,'$'
ErrorMsg db '�� ����$'
ClearMsg db 'Ok$'
AlertMsg db '������� ���� $'
CuredMsg db ' - �᤮夫� - $'
DeletMsg db ' - ��ꥪ� �����஢��$'
ModifMsg db '���� ��� $'
UnknoMsg db '������ �� ���� �����$'
FileName db 12 dup (?)
         db ' - $'
VirusName db 12 dup (?)
          db ' $'

;--- ��⮪�� ---
PErrorMsg db '�訡��'
PClearMsg db 'Ok'
PAlertMsg db '����஢�� '
PCuredMsg db ' - �뫥祭'
PDeletMsg db ' - ��ꥪ� 㤠���'
PModifMsg db '����䨪��� ����� '
PUnknoMsg db '�������� ����஢��'
;--- ��⮪�� ---

;--- 䫠�� ---
FPFlag db ? ;���� ᮧ����� ⥪�⮢��� ��⮪���
;--- 䫠�� ---

