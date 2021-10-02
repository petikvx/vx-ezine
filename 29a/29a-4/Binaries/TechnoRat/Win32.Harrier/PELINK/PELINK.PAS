(*=================================================================*)
(* (C) by TechnoRat "PE Linker" (Tool for "95-th Harrier")         *)
(*                  ~~~~~~~~~~~               16-Jul-1997y Ver 1.0 *)
(*=================================================================*)
Program PE_Linker;      (*$M 4096,0,0*) (*$I+*) (*$R-,S-,Q-*) (*!!!*)
(*-----------------------------------------------------------------*)
(*                G L O B A L   D E F I N I T I O N S              *)
(*-----------------------------------------------------------------*)
Type
 ResourcesEnum=(rStubFile,rBodyFile,rProduceFile,
                rDefFile,rMapFile,rTempFile);

Const
 StdFault='Unknown Fault';

Var StubFile,BodyFile,ProduceFile:File;
    StubName,BodyName,ProduceName:String;
    DefFile,MapFile:Text; DefName,MapName:String;
    TempFile:File; TempName:String;

    UsedResources:Set Of ResourcesEnum;
    OldExit:Pointer; FaultMsg:String;

(*-----------------------------------------------------------------*)
(*                      M E S S A G E S                            *)
(*-----------------------------------------------------------------*)
Const
 msgEntrySect='Entry Section: ';
 msgFixSect='FixUp Section: ';
 msgImportSect='Imprt Section: ';
 msgSizeMsg='h bytes size.';
 msgItemsMsg=' items.';
 msgLinkDone='Linking process completed successfully.';
 msgTarget='Target file after linking has ';
 msgCorrected='Corrected places Import/Self: ';

 msgCopyrt1='(C) 16-Jul-1997y by TechnoRat "PE Linker" Ver 1.0';
 msgCopyrt2='                              ~~~~~~~~~~~        ';
 msgUsage1='Usage: PELINK.EXE DefinitionFile';
 msgUsage2=' to perform linking as described in DefinitionFile';

 erConcat=' during ';
 erFatalWipe='Error erasing temporary files';
 erCtrlBreak='Control-Break Passed!';
 erBadNumericSymb=' - Bad number';
 erTooManyComStr='Too many parameters in command string';
 erStubOpening='Opening stub file failure';
 erBodyOpening='Opening body file failure';
 erProduceCreating='Creating target file failure';
 erFileProcessing='Disk I/O failure during files processing';
 erCreatingTemp='Creation temporary files failure';

 erOpeningDef='Opening definition file failure';
 erReadingDef='Reading definition file failure';
 erNoVar='Non-variable construction illegal';
 erVarReq='Variable required before "=" delimiter';
 erVarValReq='Variable value required after "=" delimiter';
 erUnknownVar=' - Unknown variable detected';
 erWarnVar=' - Variable not found';
 erNeedVar=' - Variable required, not found';

 erMapOpening='Opening map file failure';
 erMapReading='Reading map file failure';
 erNoPublicSection='Public section in map file not found';
 erMapLabelReq=' - Map public label not found';
 
 erStubNotExe='Stub file is not EXE file';
 erStubCanNotBeNew='Stub file can not be NEW EXE file';
 erStubNotPE='Stub file is not PE file';
 erBodyNotExe='Body file is not EXE file';
 erBodyCanNotBeNew='Body file can not be NEW EXE file';
 erBodyNotPE='Body file is not PE file';
 erNoRoomForObjRec='No room in middle of file for new section record';
 erBadStubAlloc='Bad stub sections allocation';
 erBodyNoEntry='Entry point in body file not found';
 erBodyNoFixUp='FixUp''s table in body not found';
 erFixOverFlow='FixUp''s table is out of section';
 erBadFixItem='FixUp item is invalid';
 erFixSkipped='FixUp''s table skipped, cause no variables defined';
 erImportSkipped='Import table skipped, cause no variables defined';
 erBodyNoImport='Import table in body not found';
 erImportOverFlow='Import table is out of section';
 erTooManyImports='Too many importing modules, can not process';
 erBadImpRVA='All import RVA''s must be in same section';
 erStubNoImport='Import table in stub file not found';
 erStubImportEmpty='Stub file has no import table';
 erExternalFixUp='External sections relation fixup detected';

Procedure GenFault(Msg:String);Forward;
(*-----------------------------------------------------------------*)
(*                       U T I L I T Y                             *)
(*-----------------------------------------------------------------*)
Function UpStr(S:String):String;
Var I:Integer;
Begin
 For I:=1 To Length(S) Do S[I]:=UpCase(S[I]);
 UpStr:=S;
End;

(*-----------------------------------------------------------------*)
Procedure AllTrim(Var S:String);
Var I:Integer;
Begin
 I:=1; While I<=Length(S) Do Begin              (*Remove All Spaces*)
  While ((S[I]=' ') Or (S[I]=#9)) And (I<=Length(S)) Do Delete(S,I,1);
  Inc(I);
 End; S:=UpStr(S);                                       (*UpString*)
End;

(*-----------------------------------------------------------------*)
Function HexWord(W:Word):String;
Const HexDigits:Array[0..$F] Of Char
                ='0123456789ABCDEF';
Var I:Byte; S:String[4];
Begin
 S[0]:=#4; For I:=4 DownTo 1 Do Begin
  S[I]:=HexDigits[W And $F]; W:=W Shr 4;
 End; HexWord:=S;
End;

(*-----------------------------------------------------------------*)
Function HexLong(L:LongInt):String;
Begin
 HexLong:=HexWord(L Shr 16)+HexWord(L And $FFFF);
End;

(*-----------------------------------------------------------------*)
Function Str2Long(S:String):LongInt;
Var I,Base,C:Integer; L:LongInt;
Begin
 S:=UpStr(S);
 If S[Length(S)]='H' Then Begin
  S:=Copy(S,1,Length(S)-1); Base:=16;
 End Else If Copy(S,1,2)='0X' Then Begin
  Delete(S,1,2); Base:=16;
 End Else If Copy(S,1,2)='&H' Then Begin
  Delete(S,1,2); Base:=16;
 End Else If Copy(S,1,2)='&O' Then Begin
  Delete(S,1,2); Base:=8;
 End Else If Copy(S,1,2)='&B' Then Begin
  Delete(S,1,2); Base:=2;
 End Else If Copy(S,1,2)='&D' Then Begin
  Delete(S,1,2); Base:=10;
 End Else If Copy(S,1,1)='$' Then Begin
  Delete(S,1,1); Base:=16;
 End Else Base:=10;
 L:=0; For I:=1 To Length(S) Do Begin
  C:=Ord(S[I])-48;
  If (C<0) Or ((C>9) And (C<17)) Then
   GenFault(S+erBadNumericSymb+erConcat+FaultMsg);
  If C>9 Then C:=C-7; If C>=Base Then
   GenFault(S+erBadNumericSymb+erConcat+FaultMsg);
  L:=L*Base+C;
 End; Str2Long:=L;
End;

(*-----------------------------------------------------------------*)
Function ZeroEqu(Var Buf; BufSz:Word):Boolean;
Var A:Array[1..65520] Of Byte Absolute Buf;
    I:Word;
Begin
 For I:=1 To BufSz Do Begin
  If A[I]<>0 Then Begin
   ZeroEqu:=False; Exit;
  End;
 End; ZeroEqu:=True;
End;

(*-----------------------------------------------------------------*)
Procedure AlignOnBoundary(Var L:LongInt; Boundary:LongInt);
Begin
 If (L Mod Boundary)<>0 Then L:=L-(L Mod Boundary)+Boundary;
End;

(*-----------------------------------------------------------------*)
Procedure FileTransferBytes(Var InFile,OutFile:File; Counter:LongInt;
                            Var Buffer; BufSz:Word);
Var I,L:LongInt; W:Word;
Begin
 L:=FileSize(InFile)-FilePos(InFile);
 If Counter<L Then L:=Counter;
 I:=0; While I<L Do Begin
  If (L-I)>BufSz Then W:=BufSz Else W:=L-I;
  BlockRead(InFile,Buffer,W); BlockWrite(OutFile,Buffer,W);
  Inc(I,W);
 End;
End;

(*-----------------------------------------------------------------*)
Procedure AlignFile(Var InFile:File; Bound:LongInt);
Var L,L0:LongInt; B:Byte;
Begin
 L:=(FileSize(InFile) Mod Bound);
 If L<>0 Then Begin
  Seek(InFile,FileSize(InFile)); B:=0;
  For L0:=L+1 To Bound Do BlockWrite(InFile,B,SizeOf(B));
 End;
End;

(*-----------------------------------------------------------------*)
(*                  F A U L T   H A N D L E R S                    *)
(*-----------------------------------------------------------------*)
Procedure FaultHandler;Far;
(*$I-*) Begin
 ExitProc:=OldExit;
 If ErrorAddr<>Nil Then Begin
  WriteLn('Error (',ExitCode,
          '/',HexWord(Seg(ErrorAddr^)),
          ':',HexWord(Ofs(ErrorAddr^)),
          '): ',FaultMsg,'!');
  ErrorAddr:=Nil;
 End Else If ExitCode=255 Then WriteLn(#10#13,erCtrlBreak);
 If rDefFile In UsedResources Then Close(DefFile);
 If rStubFile In UsedResources Then Close(StubFile);
 If rBodyFile In UsedResources Then Close(BodyFile);
 If rMapFile In UsedResources Then Close(MapFile);
 If rProduceFile In UsedResources Then Begin
  Close(ProduceFile); Erase(ProduceFile);
 End;
 If rTempFile In UsedResources Then Begin
  Close(TempFile); Erase(TempFile);
 End;
 If IOResult<>0 Then WriteLn('Fatal: ',erFatalWipe,'!');
(*$I+*) End;

(*-----------------------------------------------------------------*)
Procedure GenFault(Msg:String);
Begin
 FaultMsg:=Msg; RunError;
End;

(*-----------------------------------------------------------------*)
Procedure GenWarn(Msg:String);
Begin
 WriteLn('Warning: ',Msg,'!');
End;

(*-----------------------------------------------------------------*)
(*           I N T E R N A L   D E F I N I T I O N S               *)
(*-----------------------------------------------------------------*)
Type
 IniVarType=Record
  Name:String[20];
  isLong:Boolean;
  Req:Boolean;
  Present:Boolean;
  Case Boolean Of
   False:(St:String);
   True :(Long:LongInt);
 End;
 MapVarType=Record
  IniIdx:Byte;
  Present:Boolean;
  Place:LongInt;
 End;

Const
 MaxVarNumber=16;
 MaxMapNumber=8;

 vStub        =0;
 vBody        =1;
 vProduce     =2;
 vFlags       =3;
 vStubEntry   =4;  mStubEntry   =0;
 vStubImport  =5;  mStubImport  =1;
 vProgramBase =6;  mProgramBase =2;
 vSectionBase =7;  mSectionBase =3;
 vFixUpOfs    =8;  mFixUpOfs    =4;
 vFixUpLen    =9;  mFixUpLen    =5;
 vImportOfs   =10; mImportOfs   =6;
 vImportLen   =11; mImportLen   =7;
 vBufferStart =12; mBufferStart =8;
 vBufferSize  =13;
 vMap         =14;
 vSectionName =15;
 vPhysAlways  =16;

Const
 IniVars:Array[0..MaxVarNumber] Of IniVarType=(
  (Name:'STUB';        isLong:False; Req:True;  Present:False; St:''),
  (Name:'BODY';        isLong:False; Req:True;  Present:False; St:''),
  (Name:'PRODUCE';     isLong:False; Req:True;  Present:False; St:''),
  (Name:'CODEFLAGS';   isLong:True;  Req:False; Present:False; Long:$60000020),
  (Name:'STUBENTRY';   isLong:False; Req:True;  Present:False; St:''),
  (Name:'STUBIMPORT';  isLong:False; Req:False; Present:False; St:''),
  (Name:'PROGRAMBASE'; isLong:False; Req:False; Present:False; St:''),
  (Name:'SECTIONBASE'; isLong:False; Req:False; Present:False; St:''),
  (Name:'FIXUPOFS';    isLong:False; Req:False; Present:False; St:''),
  (Name:'FIXUPCOUNT';  isLong:False; Req:False; Present:False; St:''),
  (Name:'IMPORTOFS';   isLong:False; Req:False; Present:False; St:''),
  (Name:'IMPORTLEN';   isLong:False; Req:False; Present:False; St:''),
  (Name:'BUFFERSTART'; isLong:False; Req:False; Present:False; St:''),
  (Name:'BUFFERSIZE';  isLong:True;  Req:False; Present:False; Long:0),
  (Name:'MAPFILE';     isLong:False; Req:True;  Present:False; St:''),
  (Name:'CODENAME';    isLong:False; Req:False; Present:False; St:'PELINKER'),
  (Name:'PHYSALWAYS';  isLong:True;  Req:False; Present:False; Long:0)
 );

 MapVars:Array[0..MaxMapNumber] Of MapVarType=(
  (IniIdx:vStubEntry;   Present:False; Place:0),
  (IniIdx:vStubImport;  Present:False; Place:0),
  (IniIdx:vProgramBase; Present:False; Place:0),
  (IniIdx:vSectionBase; Present:False; Place:0),
  (IniIdx:vFixUpOfs;    Present:False; Place:0),
  (IniIdx:vFixUpLen;    Present:False; Place:0),
  (IniIdx:vImportOfs;   Present:False; Place:0),
  (IniIdx:vImportLen;   Present:False; Place:0),
  (IniIdx:vBufferStart; Present:False; Place:0)
 );

(*-----------------------------------------------------------------*)
(*               I N T E R N A L   R O U T I N E S                 *)
(*-----------------------------------------------------------------*)
Procedure LoadVarFile;
Var S,S1,S2,OldFault:String; I,J:Integer; B:Boolean;
Begin
 OldFault:=FaultMsg;
 FaultMsg:=erOpeningDef; Assign(DefFile,DefName); Reset(DefFile);
 Include(UsedResources,rDefFile); FaultMsg:=erReadingDef;

 While Not(Eof(DefFile)) Do Begin
  ReadLn(DefFile,S); AllTrim(S);
  I:=Pos(';',S); If I<>0 Then S:=Copy(S,1,I-1);
  If S='' Then Continue;
  I:=Pos('=',S); If I=0 Then GenFault(erNoVar);
  S1:=Copy(S,1,I-1); S2:=Copy(S,I+1,Length(S)-I);
  If S1='' Then GenFault(erVarReq);
  If S2='' Then GenFault(erVarValReq);
  B:=True; For J:=0 To MaxVarNumber Do Begin
   If IniVars[J].Name=S1 Then Begin
    If IniVars[J].isLong Then IniVars[J].Long:=Str2Long(S2)
    Else IniVars[J].St:=S2;
    IniVars[J].Present:=True;
    B:=False; Break;
   End;
  End; If B Then GenFault(S1+erUnknownVar);
 End;

 Close(DefFile); Exclude(UsedResources,rDefFile);
 For J:=0 To MaxVarNumber Do
  If IniVars[J].Req And Not(IniVars[J].Present)
  Then GenFault(IniVars[J].Name+erNeedVar);
 For J:=0 To MaxVarNumber Do
  If Not(IniVars[J].Present)
  Then GenWarn(IniVars[J].Name+erWarnVar);
 FaultMsg:=OldFault;
End;

(*-----------------------------------------------------------------*)
Procedure LoadMapFile(Segm:Word);
Const MapHeader='PUBLICSBYNAME';

Var S,S0,OldFault:String; B:Boolean; L1,L2:LongInt; J:Integer;
Begin
 OldFault:=FaultMsg;
 MapName:=IniVars[vMap].St; FaultMsg:=erMapOpening;
 Assign(MapFile,MapName); Reset(MapFile);
 Include(UsedResources,rMapFile);
 FaultMsg:=erMapReading;
 B:=True; While Not(Eof(MapFile)) Do Begin
  ReadLn(MapFile,S); AllTrim(S);
  If Pos(MapHeader,S)<>0 Then Begin
   B:=False; Break;
  End;
 End; If B Then GenFault(erNoPublicSection);

 While Not(Eof(MapFile)) Do Begin
  ReadLn(MapFile,S); AllTrim(S); If S='' Then Continue;
  If (Pos(':',S)<>5) Or (Length(S)<18) Then Break;
  L1:=Str2Long(Copy(S,1,4)+'h'); L2:=Str2Long(Copy(S,6,8)+'h');
  S0:=Copy(S,18,Length(S)-17);
  If L1=Segm Then Begin
   For J:=0 To MaxMapNumber Do Begin
    If IniVars[MapVars[J].IniIdx].Present And
       (S0=IniVars[MapVars[J].IniIdx].St) Then Begin
     MapVars[J].Place:=L2; MapVars[J].Present:=True;
     Break;
    End;
   End;(*for*)
  End;(*if segm*)
 End;(*while*)

 Close(MapFile); Exclude(UsedResources,rMapFile);
 For J:=0 To MaxMapNumber Do
  If IniVars[MapVars[J].IniIdx].Present And Not(MapVars[J].Present)
  Then GenFault(IniVars[MapVars[J].IniIdx].St+erMapLabelReq);
 FaultMsg:=OldFault;
End;

(*-----------------------------------------------------------------*)
(*                M A I N   D E F I N I T I O N S                  *)
(*-----------------------------------------------------------------*)
Type
 PEHeaderType=Record
  Sign          :LongInt;
  CPUType       :Word;
  NumOfSections :Word;
  TimeDate      :LongInt;
  PtrToCOFFTbl  :LongInt;
  COFFTblSize   :LongInt;
  NTHDRSize     :Word;
  Flags         :Word;
  Magic         :Word;
  LMajor        :Byte;
  LMinor        :Byte;
  SizeOfCode    :LongInt;
  SizeOfIData   :LongInt;
  SizeOfUIData  :LongInt;
  EntryPointRVA :LongInt;
  BaseOfCode    :LongInt;
  BaseOfData    :LongInt;
  ImageBase     :LongInt;
  ObjectAlign   :LongInt;
  FileAlign     :LongInt;
  OsMajor       :Word;
  OsMinor       :Word;
  UserMajor     :Word;
  UserMinor     :Word;
  SubSysMajor   :Word;
  SubSysMinor   :Word;
  Reserv1       :LongInt;
  ImageSize     :LongInt;
  HeaderSize    :LongInt;
  FileChkSum    :LongInt;
  SubSystem     :Word;
  DllFlags      :Word;
  StackReserveSz:LongInt;
  StackCommitSz :LongInt;
  HeapReserveSz :LongInt;
  HeapCommitSz  :LongInt;
  LoaderFlags   :LongInt;
  NumOfRVAAndSz :LongInt;
  ExportTableRVA:LongInt;
  ExportDataSz  :LongInt;
  ImportTableRVA:LongInt;
  ImportDataSz  :LongInt;
  RsrcTableRVA  :LongInt;
  RsrcDataSz    :LongInt;
  ExceptTableRVA:LongInt;
  ExceptDataSz  :LongInt;
  SecurTableRVA :LongInt;
  SecurDataSz   :LongInt;
  FixUpTableRVA :LongInt;
  FixUpDataSz   :LongInt;
  DebugTableRVA :LongInt;
  DebugTableSz  :LongInt;
  ImageDescrRVA :LongInt;
  DescriptionSz :LongInt;
  MachineSpecRVA:LongInt;
  MachineSpecSz :LongInt;
  TLSRVA        :LongInt;
  TLSSz         :LongInt;
  Reserv0       :Array[0..47] Of Byte;
 End;

 SectionType=Record
  SectionName:Array[0..7] Of Char;
  VirtualSize    :LongInt;
  RVA            :LongInt;
  PhysicalSize   :LongInt;
  PhysicalOffset :LongInt;
  Reserv1        :LongInt;
  Reserv2        :LongInt;
  Reserv3        :LongInt;
  Flags          :LongInt;
 End;

 ImportDirType=Record
  LookUpRVA,
  TimeDate,
  ForwardedChain,
  NameRVA,
  AddressRVA:LongInt;
 End;


(*-----------------------------------------------------------------*)
(*                      M A I N   E N T R Y                        *)
(*-----------------------------------------------------------------*)
Const MaxImpMod=29;
Type
 TempImpType=Record
  I:ImportDirType;
  AddrRVA:LongInt;
  AddrHighLimit:LongInt;
 End;

Var StubStart,BodyStart:LongInt; StubHeader,BodyHeader:PEHeaderType;
    ProduceBegin,ProduceFixOfs,ProduceFixCount:LongInt;
    ProduceImpOfs,ProduceImpSize,ProduceStubImp:LongInt;
    ProduceImpTotalSz:LongInt;

    ProduceEntryRVA:LongInt; ProduceEntrySect:SectionType;
    ProduceBuffer:LongInt;  ProduceHeader:PEHeaderType;

    EntrySect:SectionType; EntrySectNum:Word;
    FixSect:SectionType; FixSectNum:Word;
    ImportSect:SectionType; ImportSectNum:Word;

    IMods:Array[0..MaxImpMod] Of TempImpType;
    MaxArrMod:Integer;

Var W:Word; B:Boolean; L,LL,L0,L1,LLL:LongInt; J,I:Integer; Bt:Byte;
    Buf:Array[0..16383] Of Byte; Sect:SectionType; SectNum:Word;
    OldFault:String; Dr:ImportDirType;
Begin
 UsedResources:=[]; FaultMsg:=StdFault;
 OldExit:=ExitProc; ExitProc:=@FaultHandler;
 WriteLn(msgCopyrt1); WriteLn(msgCopyrt2);
 If ParamCount=0 Then Begin
  WriteLn(msgUsage1); WriteLn(msgUsage2);
  Exit;
 End;
 If ParamCount>1 Then GenFault(erTooManyComStr);
 DefName:=ParamStr(1); LoadVarFile;

(*-----------------------------------------------------------------*)
 StubName:=IniVars[vStub].St; FaultMsg:=erStubOpening;
 Assign(StubFile,StubName); Reset(StubFile,1);
 Include(UsedResources,rStubFile);

 BodyName:=IniVars[vBody].St; FaultMsg:=erBodyOpening;
 Assign(BodyFile,BodyName); Reset(BodyFile,1);
 Include(UsedResources,rBodyFile);

 ProduceName:=IniVars[vProduce].St; FaultMsg:=erProduceCreating;
 Assign(ProduceFile,ProduceName); Rewrite(ProduceFile,1);
 Include(UsedResources,rProduceFile);

(*-----------------------------------------------------------------*)
 FaultMsg:=erFileProcessing;                       (*Test Raw Files*)
 BlockRead(StubFile,W,SizeOf(W));
 If (W<>$4D5A) And (W<>$5A4D) Then GenFault(erStubNotExe);
 Seek(StubFile,$18); BlockRead(StubFile,W,SizeOf(W));
 If W<$40 Then GenFault(erStubCanNotBeNew);
 Seek(StubFile,$3C); BlockRead(StubFile,StubStart,SizeOf(StubStart));
 Seek(StubFile,StubStart); BlockRead(StubFile,StubHeader,SizeOf(StubHeader));
 If StubHeader.Sign<>$4550 Then GenFault(erStubNotPE);

 BlockRead(BodyFile,W,SizeOf(W));
 If (W<>$4D5A) And (W<>$5A4D) Then GenFault(erBodyNotExe);
 Seek(BodyFile,$18); BlockRead(BodyFile,W,SizeOf(W));
 If W<$40 Then GenFault(erBodyCanNotBeNew);
 Seek(BodyFile,$3C); BlockRead(BodyFile,BodyStart,SizeOf(BodyStart));
 Seek(BodyFile,BodyStart); BlockRead(BodyFile,BodyHeader,SizeOf(BodyHeader));
 If BodyHeader.Sign<>$4550 Then GenFault(erBodyNotPE);

(*-----------------------------------------------------------------*)
 Seek(StubFile,StubStart+$18+StubHeader.NTHDRSize+
      StubHeader.NumOfSections*SizeOf(SectionType));
 BlockRead(StubFile,Sect,SizeOf(Sect));           (*Checking Free Space*)
 If Not((($18+StubHeader.NTHDRSize+
          (StubHeader.NumOfSections+1)*SizeOf(SectionType))
         <=StubHeader.HeaderSize)
        And ZeroEqu(Sect,SizeOf(Sect)))
 Then GenFault(erNoRoomForObjRec);

 Seek(StubFile,StubStart+$18+StubHeader.NTHDRSize); B:=True; L:=0;
 For W:=1 To StubHeader.NumOfSections Do Begin
  BlockRead(StubFile,Sect,SizeOf(Sect));
  If Sect.RVA>=L Then Begin
   L:=Sect.RVA; LL:=Sect.VirtualSize;
  End; B:=False;
 End; If B Then GenFault(erBadStubAlloc);
 L:=L+LL; AlignOnBoundary(L,StubHeader.ObjectAlign);
 ProduceEntrySect.RVA:=L; ProduceEntrySect.Flags:=IniVars[vFlags].Long;
 ProduceEntryRVA:=L;

(*-----------------------------------------------------------------*)
 Seek(BodyFile,BodyStart+$18+BodyHeader.NTHDRSize); B:=True;
 For W:=1 To BodyHeader.NumOfSections Do Begin   (*Searching Entry Point*)
  BlockRead(BodyFile,EntrySect,SizeOf(EntrySect));
  If (BodyHeader.EntryPointRVA>=EntrySect.RVA) And
     (BodyHeader.EntryPointRVA<EntrySect.RVA+EntrySect.VirtualSize)
  Then Begin B:=False; EntrySectNum:=W; Break; End;
 End;
 If B Then GenFault(erBodyNoEntry);
 Write(msgEntrySect,EntrySectNum,' "');
 For I:=0 To 7 Do
  If EntrySect.SectionName[I]=#0 Then Break
  Else Write(EntrySect.SectionName[I]);
 WriteLn('" ',HexLong(EntrySect.VirtualSize),'h/',
              HexLong(EntrySect.PhysicalSize),msgSizeMsg);
 LoadMapFile(EntrySectNum);

 Seek(StubFile,0);                             (*Transfer Stub File*)
 FileTransferBytes(StubFile,ProduceFile,FileSize(StubFile),
                   Buf,SizeOf(Buf));
 AlignFile(ProduceFile,StubHeader.FileAlign);
 ProduceBegin:=FileSize(ProduceFile);     (*And Transfer Executable*)
 ProduceEntrySect.PhysicalOffset:=ProduceBegin;
 Seek(BodyFile,EntrySect.PhysicalOffset);
 If (EntrySect.VirtualSize<=EntrySect.PhysicalSize)
 Then FileTransferBytes(BodyFile,ProduceFile,
                        EntrySect.VirtualSize,Buf,SizeOf(Buf))
 Else Begin
  FileTransferBytes(BodyFile,ProduceFile,
                    EntrySect.PhysicalSize,Buf,SizeOf(Buf));
  If (IniVars[vPhysAlways].Long=0) Then Begin
   Bt:=0; For L:=EntrySect.PhysicalSize+1 To EntrySect.VirtualSize Do
    BlockWrite(ProduceFile,Bt,SizeOf(Bt)); (*byte!!!*)
  End;
 End;

(*-----------------------------------------------------------------*)
 If IniVars[vFixUpOfs].Present Or IniVars[vFixUpLen].Present Then Begin
  ProduceFixOfs:=FileSize(ProduceFile);
  Seek(BodyFile,BodyStart+$18+BodyHeader.NTHDRSize); B:=True;
  For W:=1 To BodyHeader.NumOfSections Do Begin   (*Searching FixUp Point*)
   BlockRead(BodyFile,FixSect,SizeOf(FixSect));
   If (BodyHeader.FixUpTableRVA>=FixSect.RVA) And
      (BodyHeader.FixUpTableRVA<FixSect.RVA+FixSect.VirtualSize)
   Then Begin B:=False; FixSectNum:=W; Break; End;
  End;
  If B Then GenFault(erBodyNoFixUp);
  Write(msgFixSect,FixSectNum,' "');
  For I:=0 To 7 Do
   If FixSect.SectionName[I]=#0 Then Break
   Else Write(FixSect.SectionName[I]);
  WriteLn('" ',HexLong(FixSect.VirtualSize),'h/',
               HexLong(FixSect.PhysicalSize),msgSizeMsg);

  ProduceFixCount:=0;                        (*Transferring FixUp's*)
  Seek(BodyFile,FixSect.PhysicalOffset+BodyHeader.FixUpTableRVA-FixSect.RVA);
  If (BodyHeader.FixUpDataSz+BodyHeader.FixUpTableRVA)>
     (FixSect.RVA+FixSect.PhysicalSize) Then GenFault(erFixOverFlow);
  LL:=0; While LL<BodyHeader.FixUpDataSz Do Begin
   BlockRead(BodyFile,L0,SizeOf(L0)); BlockRead(BodyFile,L1,SizeOf(L1));
   L:=8; While L<L1 Do Begin
    BlockRead(BodyFile,W,SizeOf(W)); Inc(L,2);
    If ((W And $F000)<>0) And ((W And $F000)<>$3000)
    Then GenFault(erBadFixItem);
    If (W And $F000)<>0 Then Begin
     W:=W And $FFF;
     If ((W+L0)>=EntrySect.RVA) And
        ((W+L0)<(EntrySect.RVA+EntrySect.VirtualSize))
     Then Begin
      LLL:=(L0-EntrySect.RVA)+W; BlockWrite(ProduceFile,LLL,SizeOf(LLL));
      Inc(ProduceFixCount);
     End;
    End;(*if fix*)
   End;(*while in block*)
   Inc(LL,L);
  End;(*while block*)
 End Else GenWarn(erFixSkipped);

(*-----------------------------------------------------------------*)
 If IniVars[vImportOfs].Present Or IniVars[vImportLen].Present
  Or IniVars[vStubImport].Present Then Begin
  OldFault:=FaultMsg; FaultMsg:=erCreatingTemp; TempName:='PELINK.$$$';
  Assign(TempFile,TempName); Rewrite(TempFile,1);
  Include(UsedResources,rTempFile); FaultMsg:=OldFault;

  AlignFile(ProduceFile,4);
  Seek(BodyFile,BodyStart+$18+BodyHeader.NTHDRSize); B:=True;
  For W:=1 To BodyHeader.NumOfSections Do Begin  (*Searching Imports*)
   BlockRead(BodyFile,ImportSect,SizeOf(ImportSect));
   If (BodyHeader.ImportTableRVA>=ImportSect.RVA) And
      (BodyHeader.ImportTableRVA<ImportSect.RVA+ImportSect.VirtualSize)
   Then Begin B:=False; ImportSectNum:=W; Break; End;
  End;
  If B Then GenFault(erBodyNoImport);
  Write(msgImportSect,ImportSectNum,' "');
  For I:=0 To 7 Do
   If ImportSect.SectionName[I]=#0 Then Break
   Else Write(ImportSect.SectionName[I]);
  WriteLn('" ',HexLong(ImportSect.VirtualSize),'h/',
               HexLong(ImportSect.PhysicalSize),msgSizeMsg);
  Seek(BodyFile,ImportSect.PhysicalOffset+
       BodyHeader.ImportTableRVA-ImportSect.RVA);

  MaxArrMod:=-1; Repeat
   If FilePos(BodyFile)>=(ImportSect.PhysicalOffset+
      ImportSect.PhysicalSize) Then GenFault(erImportOverFlow);
   If MaxArrMod=MaxImpMod Then GenFault(erTooManyImports);
   Inc(MaxArrMod); With IMods[MaxArrMod] Do Begin
    BlockRead(BodyFile,I,SizeOf(I));
    If ZeroEqu(I,SizeOf(I)) Then Break;
    L0:=FilePos(BodyFile);

    If I.LookUpRVA<>0 Then Begin
     Seek(TempFile,0); Truncate(TempFile);
     L:=I.LookUpRVA-ImportSect.RVA;
     If (L<0) Or (L>=ImportSect.PhysicalSize) Then GenFault(erBadImpRVA);
     Seek(BodyFile,L+ImportSect.PhysicalOffset);
     Repeat (*Transfer LookUps*)
      BlockRead(BodyFile,L,SizeOf(L)); LL:=FilePos(BodyFile);
      If L<>0 Then Begin
       L:=L-ImportSect.RVA;
       If (L<0) Or (L>=ImportSect.PhysicalSize) Then GenFault(erBadImpRVA);
       Seek(BodyFile,L+ImportSect.PhysicalOffset);
       L:=FileSize(ProduceFile)-ProduceBegin+ProduceEntrySect.RVA;
       BlockRead(BodyFile,W,SizeOf(W)); (*Transfer HintName*)
       BlockWrite(ProduceFile,W,SizeOf(W));
       J:=0; Repeat
        BlockRead(BodyFile,Bt,SizeOf(Bt));
        BlockWrite(ProduceFile,Bt,SizeOf(Bt));
        Inc(J);
       Until Bt=0;
       If Odd(J) Then BlockWrite(ProduceFile,Bt,SizeOf(Bt));
      End; BlockWrite(TempFile,L,SizeOf(L));
      Seek(BodyFile,LL);
     Until L=0; Seek(TempFile,0);
     LLL:=FileSize(ProduceFile)-ProduceBegin+ProduceEntrySect.RVA;
     FileTransferBytes(TempFile,ProduceFile,FileSize(TempFile),
                       Buf,SizeOf(Buf));
     I.LookUpRVA:=LLL;
    End; (*Done Transferring LookUpTable*)

    If I.NameRVA<>0 Then Begin
     L:=I.NameRVA-ImportSect.RVA;
     If (L<0) Or (L>=ImportSect.PhysicalSize) Then GenFault(erBadImpRVA);
     Seek(BodyFile,L+ImportSect.PhysicalOffset);
     L:=FileSize(ProduceFile)-ProduceBegin+ProduceEntrySect.RVA;
     J:=0; Repeat (*Transfer .DLL Name*)
      BlockRead(BodyFile,Bt,SizeOf(Bt));
      BlockWrite(ProduceFile,Bt,SizeOf(Bt));
      Inc(J);
     Until Bt=0;
     If Odd(J) Then BlockWrite(ProduceFile,Bt,SizeOf(Bt));
     I.NameRVA:=L;
    End; (*Done Transferring DLL Name*)

    AddrRVA:=I.AddressRVA;
    If I.AddressRVA<>0 Then Begin
     LLL:=FileSize(ProduceFile)-ProduceBegin+ProduceEntrySect.RVA;
     L:=I.AddressRVA-ImportSect.RVA;
     If (L<0) Or (L>=ImportSect.PhysicalSize) Then GenFault(erBadImpRVA);
     Seek(BodyFile,L+ImportSect.PhysicalOffset);
     AddrHighLimit:=I.AddressRVA; Repeat
      BlockRead(BodyFile,L,SizeOf(L));
      BlockWrite(ProduceFile,L,SizeOf(L));
      If L<>0 Then Inc(AddrHighLimit,SizeOf(L));
     Until L=0;
     I.AddressRVA:=LLL;
    End; (*Done Transferring Address Table*)

    Seek(BodyFile,L0);
   End;(*with*)
  Until False; (*All Import Modules Loaded OK*)

  (*Correct Program Links*) LLL:=0;
  L:=0; While L<ProduceFixCount Do Begin
   Seek(ProduceFile,ProduceFixOfs+L*4); (*DWord!!!*)
   BlockRead(ProduceFile,LL,SizeOf(LL)); Inc(L);
   Seek(ProduceFile,ProduceBegin+LL);
   BlockRead(ProduceFile,L0,SizeOf(L0));
   Dec(L0,BodyHeader.ImageBase);
   B:=True; For I:=0 To MaxArrMod-1 Do Begin
    If (L0>=IMods[I].AddrRVA) And (L0<IMods[I].AddrHighLimit)
    Then Begin
     L0:=L0-IMods[I].AddrRVA+IMods[I].I.AddressRVA-ProduceEntrySect.RVA;
     Seek(ProduceFile,ProduceBegin+LL);
     BlockWrite(ProduceFile,L0,SizeOf(L0));
     B:=False; Inc(LLL); Break;
    End;
   End;
   If B Then Begin
    If (L0>=EntrySect.RVA) And
            (L0<EntrySect.RVA+EntrySect.VirtualSize)
    Then Begin
     L0:=L0-EntrySect.RVA;
     Seek(ProduceFile,ProduceBegin+LL);
     BlockWrite(ProduceFile,L0,SizeOf(L0));
    End Else GenFault(erExternalFixUp);
   End;
  End; Seek(ProduceFile,FileSize(ProduceFile));
  WriteLn(msgCorrected,LLL,'/',(ProduceFixCount-LLL),msgItemsMsg);

  (*Last Module is EMPTY!!!*)
  ProduceImpOfs:=FileSize(ProduceFile);
  For I:=0 To MaxArrMod-1 Do Begin
   BlockWrite(ProduceFile,IMods[I].I,SizeOf(IMods[I].I));
  End; ProduceImpSize:=FileSize(ProduceFile)-ProduceImpOfs;
  ProduceStubImp:=FileSize(ProduceFile);

  If StubHeader.ImportTableRVA=0 Then Begin
   GenWarn(erStubImportEmpty);
   BlockWrite(ProduceFile,IMods[MaxArrMod].I,SizeOf(IMods[MaxArrMod].I));
  End Else Begin
   Seek(StubFile,StubStart+$18+StubHeader.NTHDRSize); B:=True;
   For W:=1 To StubHeader.NumOfSections Do Begin  (*Searching Imports*)
    BlockRead(StubFile,Sect,SizeOf(Sect));
    If (StubHeader.ImportTableRVA>=Sect.RVA) And
       (StubHeader.ImportTableRVA<Sect.RVA+Sect.VirtualSize)
    Then Begin B:=False; SectNum:=W; Break; End;
   End;
   If B Then GenFault(erStubNoImport);
   Seek(StubFile,Sect.PhysicalOffset+StubHeader.ImportTableRVA-Sect.RVA);
   Repeat
    BlockRead(StubFile,Dr,SizeOf(Dr));
    BlockWrite(ProduceFile,Dr,SizeOf(Dr));
   Until ZeroEqu(Dr,SizeOf(Dr));
  End; ProduceImpTotalSz:=FileSize(ProduceFile)-ProduceImpOfs;

  Close(TempFile); Erase(TempFile);
  Exclude(UsedResources,rTempFile);
 End Else GenWarn(erImportSkipped);

(*-----------------------------------------------------------------*)
 ProduceBuffer:=FileSize(ProduceFile);      (*Allocating The Buffer*)
 ProduceEntrySect.VirtualSize:=ProduceBuffer-
                               ProduceBegin+IniVars[vBufferSize].Long;
 AlignFile(ProduceFile,StubHeader.FileAlign);
 ProduceEntrySect.PhysicalSize:=FileSize(ProduceFile)-ProduceBegin;
 ProduceHeader:=StubHeader;
 If IniVars[vImportOfs].Present Or IniVars[vImportLen].Present
  Or IniVars[vStubImport].Present Then Begin
  ProduceHeader.ImportTableRVA:=ProduceEntrySect.RVA+
                                 ProduceImpOfs-ProduceBegin;
  ProduceHeader.ImportDataSz:=ProduceImpTotalSz;
 End;
 ProduceHeader.EntryPointRVA:=(BodyHeader.EntryPointRVA-
                               EntrySect.RVA)+ProduceEntryRVA;
 L:=ProduceEntrySect.VirtualSize;
 AlignOnBoundary(L,StubHeader.ObjectAlign);
 ProduceHeader.ImageSize:=L+StubHeader.ImageSize;
 ProduceHeader.SizeOfIData:=L+StubHeader.SizeOfIData;
 Inc(ProduceHeader.NumOfSections);
 Seek(ProduceFile,StubStart);                       (*Write Headers*)
 BlockWrite(ProduceFile,ProduceHeader,SizeOf(ProduceHeader));
 While Length(IniVars[vSectionName].St)<8 Do
  IniVars[vSectionName].St:=IniVars[vSectionName].St+#0;
 Move(IniVars[vSectionName].St[1],
      ProduceEntrySect.SectionName,SizeOf(ProduceEntrySect.SectionName));
 Seek(ProduceFile,StubStart+$18+ProduceHeader.NTHDRSize+
      (ProduceHeader.NumOfSections-1)*SizeOf(SectionType));
 BlockWrite(ProduceFile,ProduceEntrySect,SizeOf(ProduceEntrySect));

(*-----------------------------------------------------------------*)
 If IniVars[vStubEntry].Present Then Begin      (*Writing Variables*)
  L:=StubHeader.EntryPointRVA;
  Seek(ProduceFile,ProduceBegin+MapVars[mStubEntry].Place);
  BlockWrite(ProduceFile,L,SizeOf(L));
 End;
 If IniVars[vProgramBase].Present Then Begin
  Seek(ProduceFile,ProduceBegin+MapVars[mProgramBase].Place);
  BlockWrite(ProduceFile,ProduceHeader.ImageBase,
             SizeOf(ProduceHeader.ImageBase));
 End;
 If IniVars[vSectionBase].Present Then Begin
  Seek(ProduceFile,ProduceBegin+MapVars[mSectionBase].Place);
  BlockWrite(ProduceFile,ProduceEntrySect.RVA,
             SizeOf(ProduceEntrySect.RVA));
 End;
 If IniVars[vStubImport].Present Then Begin
  L:=ProduceStubImp-ProduceBegin;
  Seek(ProduceFile,ProduceBegin+MapVars[mStubImport].Place);
  BlockWrite(ProduceFile,L,SizeOf(L));
 End;
 If IniVars[vFixUpOfs].Present Then Begin
  L:=ProduceFixOfs-ProduceBegin;
  Seek(ProduceFile,ProduceBegin+MapVars[mFixUpOfs].Place);
  BlockWrite(ProduceFile,L,SizeOf(L));
 End;
 If IniVars[vFixUpLen].Present Then Begin
  Seek(ProduceFile,ProduceBegin+MapVars[mFixUpLen].Place);
  BlockWrite(ProduceFile,ProduceFixCount,SizeOf(ProduceFixCount));
 End;
 If IniVars[vImportOfs].Present Then Begin
  L:=ProduceImpOfs-ProduceBegin;
  Seek(ProduceFile,ProduceBegin+MapVars[mImportOfs].Place);
  BlockWrite(ProduceFile,L,SizeOf(L));
 End;
 If IniVars[vImportLen].Present Then Begin
  Seek(ProduceFile,ProduceBegin+MapVars[mImportLen].Place);
  BlockWrite(ProduceFile,ProduceImpSize,SizeOf(ProduceImpSize));
 End;
 If IniVars[vBufferStart].Present Then Begin
  L:=ProduceBuffer-ProduceBegin;
  Seek(ProduceFile,ProduceBegin+MapVars[mBufferStart].Place);
  BlockWrite(ProduceFile,L,SizeOf(L));
 End;

(*-----------------------------------------------------------------*)
 WriteLn(msgTarget,HexLong(FileSize(ProduceFile)),msgSizeMsg);
 Close(ProduceFile); Exclude(UsedResources,rProduceFile);
 Close(BodyFile); Exclude(UsedResources,rBodyFile);
 Close(StubFile); Exclude(UsedResources,rStubFile);
 WriteLn(msgLinkDone);
End.
(*=================================================================*)
