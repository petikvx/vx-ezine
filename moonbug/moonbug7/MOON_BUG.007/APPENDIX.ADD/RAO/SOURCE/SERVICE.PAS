{
                          1997 (c) by RedArc // TAVC
}
UNIT Service;

INTERFACE

USES Global;

PROCEDURE FlagOff (VAR VI : FileRecordInfo);
FUNCTION FlagCheck (VAR VI : FileRecordInfo) : Byte;

IMPLEMENTATION

PROCEDURE FlagOff (VAR VI : FileRecordInfo);
BEGIN
     WITH VI DO BEGIN
          Flag_I    := False;
          Flag_M    := False;
          Flag_S    := False;
          Flag_O    := False;
          Flag_E    := False;
     END;
END;

FUNCTION FlagCheck (VAR VI : FileRecordInfo) : Byte;
VAR
   I : Byte;
BEGIN
     I := 0;
     WITH VI DO BEGIN
          IF Flag_I THEN I := 1;
          IF Flag_M THEN I := 2;
          IF Flag_S THEN I := 3;
          IF Flag_O THEN I := 4;
          IF Flag_E THEN I := 5;
     END;
     IF I = GlobalFlag THEN
     FlagCheck := I
     ELSE FlagCheck := 0;
END;

BEGIN
     WriteLn (Ident2);
     WriteLn;
END.
