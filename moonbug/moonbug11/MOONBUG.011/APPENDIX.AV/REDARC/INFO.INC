;��猪� ���稭� � ���७�祭�
;(c) RedArc

;PrintString - ����� ��ப� �� ��࠭
;NewString - ��ॢ�� ����� �� ����� ��ப�
;About    - �뢮� ���ଠ樨 � ⥪�饩 ���ᨨ ��⨢����
;Protocol - �ନ஢���� � �뢮� ��⮪���
;PrintFileName - ����� ����� ����㥬��� 䠩��
;PrintVirusName - ����� ����� �����
;ClearVirusName - ���⪠ ����� �����
;ClearFileName  - ���⪠ ����� 䠩��
;Clear12bytes    - ���㫥��� 12 ����
;PrintOk - ����� ᫮�� Ok
;PrintAlert - ����� ᫮�� �����������
;CuredInfo - ᮮ�饭�� � ⮬, �� ����� �뫥祭

;����������������������������������������������������������������������������
PrintString proc near
          push ax
          mov ah,09h
          int 21h
          pop ax
          ret
PrintString endp

;����������������������������������������������������������������������������
NewString proc near
      push dx
      lea dx,CtrlEOF
      call PrintString
      pop dx
      ret
NewString endp

;����������������������������������������������������������������������������
About proc near
      push dx
      lea dx,AboutMsg
      call PrintString
      pop dx
      ret
About endp

;����������������������������������������������������������������������������
Protocol proc near
;         mov bx,ProtokolFHandle
;         mov ah,3eh
;         int 21h
         call NewString
         ret
Protocol endp

;����������������������������������������������������������������������������
PrintFileName proc near
              push si di dx cx
              lea si,FileName
              call ClearFileName
              mov si,dx
              lea di,FileName
              push di
              mov cx,12
              rep movsb
              pop dx
              call PrintString
              pop cx dx di si
              ret
PrintFileName endp

;����������������������������������������������������������������������������
ClearVirusName proc near
               push ax cx di si
               lea si,VirusName
               call Clear12bytes
               pop si di cx ax
ClearVirusName endp

;����������������������������������������������������������������������������
ClearFileName proc near
               push ax cx di si
               lea si,FileName
               call Clear12bytes
               pop si di cx ax
ClearFileName endp

;����������������������������������������������������������������������������
Clear12bytes proc near
               mov di,si
               mov cx,6
               xor ax,ax
               rep stosw
               ret
Clear12bytes endp

;����������������������������������������������������������������������������
PrintVirusName proc near
              push si di dx cx
              lea si,VirusName
              call ClearVirusName
              mov si,dx
              lea di,VirusName
              push di
              mov cx,12
@PVN1:
              lodsb
              stosb
              cmp al,0
              jne @PVN1
              pop dx
              call PrintString
              pop cx dx di si
              ret
PrintVirusName endp

;����������������������������������������������������������������������������
PrintOk proc near
        push dx
        lea dx,ClearMsg
        call PrintString
        call NewString
        pop dx
        ret
PrintOk endp

;����������������������������������������������������������������������������
PrintAlert proc near
              push dx
              lea dx,AlertMsg
              call PrintString
              pop dx
              ret
PrintAlert endp

;����������������������������������������������������������������������������
CuredInfo proc near
              push dx
              lea dx,CuredMsg
              call PrintString
              pop dx
              ret
CuredInfo endp

