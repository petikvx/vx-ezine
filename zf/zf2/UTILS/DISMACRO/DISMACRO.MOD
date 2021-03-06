(***************************************************************)
(*   ���⮩ ����஢騪 ����ᮢ ��� �������� DOC-䠩���    *)
(*   TopSpeed Modula-2                                         *)
(*   (c) DrMad, 1998                                           *)
(***************************************************************)
MODULE DisMacro;

IMPORT IO,FIO,Storage,Lib;

CONST
     OFFST = 0118H;

LABEL
     NEXT;

VAR
     FileNa : ARRAY [0..31] OF CHAR; (* ��� 䠩�� *)
     Q,i,j,k: CARDINAL;              (* �ᯮ����⥫�� ��६���� *)
     A      : POINTER TO ARRAY [0..MAX(CARDINAL)-1] OF SHORTCARD;
     F      : FIO.File;              (* ���� *)
     NPar   : CARDINAL;              (* ���-�� ��ࠬ��஢ � ���. ��ப� *)
     FSize  : LONGCARD;              (* ������ 䠩�� *)
     HPos   : CARDINAL;              (* ������ DOC-���������    *)
     NEnt   : CARDINAL;              (* ������⢮ ���஡�����   *)
     EPos   : CARDINAL;              (* ������ ���஢宦�����   *)
     Var    : CARDINAL;              (* ��ਠ�� ���������        *)
     UnXOR  : BOOLEAN;               (* �ਧ��� ������ ����ᮢ *)

(* 4 ���� -> ������� ᫮�� *)
PROCEDURE ToLONG( P:CARDINAL ) : LONGCARD;
 VAR
  L:LONGCARD;
BEGIN
 L:=0;
 L:=L+
    LONGCARD(A^[P])+
    LONGCARD(A^[P+1])*100H+
    LONGCARD(A^[P+2])*10000H+
    LONGCARD(A^[P+3])*1000000H;
 RETURN L;
END ToLONG;

(* 2 ���� -> ᫮�� *)
PROCEDURE ToCARD( P:CARDINAL ) : CARDINAL;
 VAR
  C:CARDINAL;
BEGIN
 C:=0;
 C:=C+
    CARDINAL(A^[P])+
    CARDINAL(A^[P+1])*100H;
 RETURN C;
END ToCARD;

BEGIN

 IO.WrStr('�����஢뢠��騪 ����ᮢ � DOC-䠩��� ���ᨩ 6.0'+15C+12C);
 IO.WrStr('                                   (c) DrMad, 1998'+15C+12C);
 IO.WrStr('��������������������������������������������������'+15C+12C);

 (* ��⠥� ��� 䠩�� �� ��ࠬ��஢ ��� � ����� *)
 NPar := Lib.ParamCount();
 IF NPar < 1
  THEN
   IO.WrStr('FileName> ');IO.RdStr(FileNa);
  ELSE
   Lib.ParamStr(FileNa, 1)
 END;

 IF ~FIO.Exists(FileNa) THEN IO.WrStr('��� ⠪��� 䠩��!'+7C);HALT END;

 F:=FIO.Open(FileNa); FSize := FIO.Size(F);
 IF (FSize>0FFFFH) THEN IO.WrStr('���� ����� 64 ��!'+7C);FIO.Close(F);HALT END;

 (* ���।��塞 ������ *)
 IF Storage.Available(CARDINAL(FSize))
  THEN Storage.ALLOCATE( A , CARDINAL(FSize) );
  ELSE IO.WrStr('�� 墠⠥� �������᪮� �����!'+7C);FIO.Close(F);HALT
 END;

 (* ��⠥� 䠩�� � ���� *)
 Q := FIO.RdBin ( F, A^, CARDINAL(FSize) );

 (* �஢��塞 �� �ਧ��� OLE2-��ꥪ� *)
 IF (Q<>CARDINAL(FSize)) OR
    (A^[0]# 0D0H) OR
    (A^[1]# 0CFH) OR
    (A^[2]# 011H) OR
    (A^[3]# 0E0H) OR
    (A^[4]# 0A1H) OR
    (A^[5]# 0B1H) OR
    (A^[6]# 01AH) OR
    (A^[7]# 0E1H)
      THEN IO.WrStr('�� �� 䠩� WORD 6.0!'+7C);
           FIO.Close(F);
           Storage.DEALLOCATE( A, CARDINAL(FSize) );
           HALT END;

  (* �饬 ������ ���⨪� DOC-���������, ������ ��⭠ 10H *)
  Var:=0; j:=0;

NEXT:

  i:= j;
  HPos := 0;
  LOOP
   IF ((A^[i]=0DCH)&(A^[i+1]=0A5H)) OR
      ((A^[i]=097H)&(A^[i+1]=0A6H)) OR
      ((A^[i]=099H)&(A^[i+1]=0A6H)) OR
      ((A^[i]=0ECH)&(A^[i+1]=0A5H)) THEN HPos:=i; j:=i+16; EXIT END;
   i := i + 16;
   IF i > CARDINAL(FSize) THEN EXIT END;
  END;

  IF (HPos=0) & (Var=0)
      THEN IO.WrStr('��������� WORD 6.0 �� ������!'+7C);
           FIO.Close(F);
           Storage.DEALLOCATE( A, CARDINAL(FSize) );
           HALT END;

  IF (HPos=0) & (Var#0)
      THEN IO.WrStr('������ � ���㬥�� ����������!'+7C);
           FIO.Close(F);
           Storage.DEALLOCATE( A, CARDINAL(FSize) );
           HALT END;

  IF (ToLONG(HPos+OFFST+4) <= 2) THEN INC(Var);GOTO NEXT END;

  IF (A^[CARDINAL( ToLONG(HPos+OFFST))+HPos] # 0FFH)
      THEN IO.WrStr('��������� ���ᠭ�� ���� ����� �������⨬� �ଠ�!'+7C);
           FIO.Close(F);
           Storage.DEALLOCATE( A, CARDINAL(FSize) );
           HALT END;

  IF (A^[CARDINAL( ToLONG(HPos+OFFST))+HPos+1] # 01H)
      THEN IO.WrStr('��������� ���ᠭ�� ���� ����� �������⨬� �ଠ�!'+7C);
           FIO.Close(F);
           Storage.DEALLOCATE( A, CARDINAL(FSize) );
           HALT END;

  NEnt := ToCARD(CARDINAL(ToLONG(HPos+OFFST))+HPos+2);

  IO.WrStr('������⢮ �����ࠣ���⮢ : '); IO.WrCard(NEnt, 5);IO.WrLn;

  (* �����ࠥ� ���ਯ��� � ���ਢ��� ������ *)
  EPos := CARDINAL( ToLONG(HPos+OFFST) )+HPos+4; UnXOR:=FALSE;
  FOR i:=0 TO NEnt-1 DO
   IF A^[EPos+1] > 0
    THEN
     j:=CARDINAL(ToLONG(EPos+14H))+HPos; k:=0;
     WHILE k<CARDINAL(ToLONG(EPos+0CH)) DO
      A^[j] := SHORTCARD ( BITSET(A^[j])/BITSET(A^[EPos+1]));
      INC(j);
      INC(k);
     END;
     A^[EPos+1]:=0;
     UnXOR := TRUE;
   END;
   EPos:=EPos+18H;
  END;

  (* �᫨ ���ਫ�, � ���� ������� १���� *)
  IF UnXOR
   THEN
    IO.WrStr('�ࠣ����� ����஢���');
    FIO.Seek(F,0);
    FIO.WrBin(F, A^, CARDINAL(FSize) );
   ELSE
    IO.WrStr('�����஢�� �� �ॡ����');
  END;

  FIO.Close(F);
  Storage.DEALLOCATE( A, CARDINAL(FSize) );

END DisMacro.