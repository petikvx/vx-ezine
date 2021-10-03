VAR
  f1,f2 : FILE OF BYTE;
  a     : BYTE;
  crc   : WORD;


PROCEDURE Store(a:BYTE);
VAR
  b,i : BYTE;

BEGIN
  FOR i:=1 TO 8 DO BEGIN
    b:=a MOD 2;
    a:=a DIV 2;
    b:=-b;
    WRITE(f2,b);
  END;
END;



BEGIN
  IF PARAMCOUNT<>2 THEN BEGIN
    WRITELN('Program "BIN2TXT" v1.0 [For TxtVirus]');
    WRITELN('Copyright (c) by DJ Sadovnikov, 2000');
    WRITELN('HomePage: http://i.am/djsad');
    WRITELN('E-Mail: djsad@i.am');
    WRITELN;
    WRITELN('Use: BIN2TXT <Input File> <Output File>');
    HALT;
  END;
  ASSIGN(f1,PARAMSTR(1));
  ASSIGN(f2,PARAMSTR(2));
  RESET(f1);
  REWRITE(f2);
  crc:=0;
  REPEAT
    READ(f1,a);
    crc:=crc+a;
    Store(a);
  UNTIL EOF(f1);
  Store(LO(FILESIZE(f1)));
  Store(HI(FILESIZE(f1)));
  Store(LO(crc));
  Store(HI(crc));
  CLOSE(f1);
  CLOSE(f2);
END.
