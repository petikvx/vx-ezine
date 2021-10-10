UNIT CureLib;

INTERFACE

USES Dos, GlobVar, VirBase;

procedure None (var S : String);
procedure FromEndOfFile (FName : String; var S : String);
procedure FromBegOfFile (FName : String; var S : String);

IMPLEMENTATION

procedure None (var S : String);
begin
     Inc (CouVirusSkip);
     S := S + ' - skiped';
end;

procedure FromEndOfFile (FName : String; var S : String);
var
   i : integer;
   f : File;
   Time : LongInt;
   P : Pointer;
   RC : Word;
begin
     Assign (f, FName);
     SetFAttr (f, Archive);
     ReSet (f, 1);
     FileMode := 2;
     if IOResult <> 0 then begin
        None (S);
        exit;
     end;
     GetFTime (f, Time);
     Seek (f, Signature[NumOfRecord].Sig1Info.SigOffset-1);
     case Signature[NumOfRecord].CryptInfo of
          CryptByte0 : begin
                            Close (f);
                            None (S);
                            exit;
                       end;
          CryptByte1 : begin
                            Close (f);
                            None (S);
                            exit;
                       end;
          CryptByte2 : begin
                            Close (f);
                            None (S);
                            exit;
                       end;
          CryptWord0 : begin
                            Close (f);
                            None (S);
                            exit;
                       end;
          CryptWord1 : begin
                            Close (f);
                            None (S);
                            exit;
                       end;
          CryptWord2 : begin
                            Close (f);
                            None (S);
                            exit;
                       end;
     end;
     for i := 1 to Signature[NumOfRecord].BytesPartCo do begin
         Seek (f, Signature[NumOfRecord].Sig1Info.SigOffset-1);
         with Signature[NumOfRecord].BytesPartIn[i] do begin
              Seek (f, FilePos(f) + BytesOffset);
              GetMem (P, BytesLength);
              BlockRead (f, P^, BytesLength, RC);
              if RC <> BytesLength then begin
                 FreeMem (P, BytesLength);
                 Close (f);
                 None (S);
                 exit;
              end;
              case BytesCrypt of
                   CryptByte0 : begin
                                     FreeMem (P, BytesLength);
                                     Close (f);
                                     None (S);
                                     exit;
                                end;
                   CryptByte1 : begin
                                     FreeMem (P, BytesLength);
                                     Close (f);
                                     None (S);
                                     exit;
                                end;
                   CryptByte2 : begin
                                     FreeMem (P, BytesLength);
                                     Close (f);
                                     None (S);
                                     exit;
                                end;
                   CryptWord0 : begin
                                     FreeMem (P, BytesLength);
                                     Close (f);
                                     None (S);
                                     exit;
                                end;
                   CryptWord1 : begin
                                     FreeMem (P, BytesLength);
                                     Close (f);
                                     None (S);
                                     exit;
                                end;
                   CryptWord2 : begin
                                     FreeMem (P, BytesLength);
                                     Close (f);
                                     None (S);
                                     exit;
                                end;
              end;
              Seek (f, SourceOffs);
              BlockWrite (f, P^, BytesLength, RC);
              FreeMem (P, BytesLength);
              if RC <> BytesLength then begin
                 Close (f);
                 None (S);
                 exit;
              end;
         end;
     end;
     Seek (f, Signature[NumOfRecord].Sig1Info.SigOffset-1);
     Seek (f, FilePos(f) - Signature[NumOfRecord].VirBegOffs);
     Truncate (f);
     SetFTime (f, Time);
     Close (f);
     Inc (CouFileDesinf);
     S := S + ' - cured!';
end;

procedure FromBegOfFile (FName : String; var S : String);
var
   A : Word;
   f : File;
   Time : LongInt;
   P : Pointer;
   RC : Word;
begin
     Assign (f, FName);
     SetFAttr (f, Archive);
     ReSet (f, 1);
     FileMode := 2;
     if IOResult <> 0 then begin
        None (S);
        exit;
     end;
     GetFTime (f, Time);
     case Signature[NumOfRecord].CryptInfo of
          CryptByte0 : begin
                            Close (f);
                            None (S);
                            exit;
                       end;
          CryptByte1 : begin
                            Close (f);
                            None (S);
                            exit;
                       end;
          CryptByte2 : begin
                            Close (f);
                            None (S);
                            exit;
                       end;
          CryptWord0 : begin
                            Close (f);
                            None (S);
                            exit;
                       end;
          CryptWord1 : begin
                            Close (f);
                            None (S);
                            exit;
                       end;
          CryptWord2 : begin
                            Close (f);
                            None (S);
                            exit;
                       end;
     end;
     Seek (f, Signature[NumOfRecord].VirLength);
     A := FileSize(f) - FilePos(f);
     GetMem (P, A);
     BlockRead (f, P^, A, RC);
     if RC <> A then begin
        FreeMem (P, A);
        Close (f);
        None (S);
        exit;
     end;
     Seek (f, 0);
     BlockWrite (f, P^, A, RC);
     FreeMem (P, A);
     if RC <> A then begin
        Close (f);
        None (S);
        exit;
     end;
     Truncate (f);
     SetFTime (f, Time);
     Close (f);
     Inc (CouFileDesinf);
     S := S + ' - cured!';
end;

END.
