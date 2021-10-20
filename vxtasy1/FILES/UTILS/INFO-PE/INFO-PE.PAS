{$G+}
Program INFO_PE;

{Description: A Portable Exe Information Program by Lord Julus (C) 1998 }
{             VERSION 2.1 05/09/1998                                    }
{                                                                       }
{(lordjulus@geocities.com)                                              }
{                                                                       }
{Warning: requires fixing in the EXE file to work on >200Mhz CPUs       }
{It's a Borland bug... There are a few utilities to fix this...         }

uses crt, dos;

Const
     image_numberof_directory_entries = 16;
     contline = 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ';
     blank = 'º       ³       º';
     bound : boolean = true;
     totalimpnames: word = 0;
     totalimpaddrs: word = 0;

Type
     TImage_Dos_Header   = ^Image_Dos_Header;
     Image_Dos_Header    = Record
     dh_magic            : word; { Magic word 'MZ'                     }
     dh_cplb             : word; { Bytes on the last page              }
     dh_cp               : word; { Pages in file                       }
     dh_crlc             : word; { Relocations                         }
     dh_cparhdr          : word; { Size of header in paragraphs        }
     dh_minalloc         : word; { Minimum paragraphs needed           }
     dh_maxalloc         : word; { Maximum paragraphs needed           }
     dh_ss               : word; { Initial (relative) SS value         }
     dh_sp               : word; { Initial SP value                    }
     dh_chksum           : word; { File Checksum                       }
     dh_ip               : word; { Initial IP value                    }
     dh_cs               : word; { Initial (relative) CS value         }
     dh_farlc            : word; { File address relocation table       }
     dh_ovno             : word; { Overlay number                      }
     dh_res1             : array[1..4] of word; { Reserved words       }
     dh_oemid            : word; { OEM identifier                      }
     dh_oemidinfo        : word; { OEM information                     }
     dh_res2             : array[1..10] of word; {Reserved words       }
     dh_lfanew           : longint; {File address of the New Exe header}
     End;

     TImage_PE_Header     = ^Image_PE_Header;
     Image_PE_Header      = Record
     Machine              : word;
     NumberOfSections     : word;
     TimeDateStamp        : Longint;
     PointerToSymbolTable : Longint;
     NumberOfSymbols      : Longint;
     SizeOfOptionalHeader : Word;
     Characteristics      : Word;
     End;

     Image_Directory_Entry  = Record
     VirtualAddress         : longint;
     Size                   : longint;
     End;

     TImage_Optional_Header      = ^Image_Optional_Header;
     Image_Optional_Header       = Record
     Magic                       : word;
     MajorLinkerVersion          : byte;
     MinorLinkerVersion          : byte;
     SizeOfCode                  : longint;
     SizeOfInitializedData       : longint;
     SizeOfUninitializedData     : longint;
     AddressOfEntryPoint         : longint;
     BaseOfCode                  : longint;
     BaseOfData                  : longint;
     ImageBase                   : longint;
     SectionAlignment            : longint;
     FileAlignment               : longint;
     MajorOperatingSystemVersion : word;
     MinorOperatingSystemVersion : word;
     MajorImageVersion           : word;
     MinorImageVersion           : word;
     MajorSubsystemVersion       : word;
     MinorSubsystemVersion       : word;
     Reserved1                   : longint;
     SizeOfImage                 : longint;
     SizeOfHeaders               : longint;
     Checksum                    : longint;
     Subsystem                   : word;
     DLLCharacteristics          : word;
     SizeOfStackReserve          : longint;
     SizeOfStackCommit           : longint;
     SizeOfHeapReserve           : longint;
     SizeOfHeapCommit            : longint;
     LoaderFlags                 : longint;
     NumberOfRVAAndSizes         : longint;
     Image_Data_Directory        : array[0..image_numberof_directory_entries-1]
                                   of Image_Directory_Entry;
     end;

     TImage_Section_Header       = ^Image_Section_Header;
     Image_Section_Header        = Record
     Name                        : array[1..8] of char;
     PhysicalAddress             : longint;
     VirtualAddress              : longint;
     SizeOfRawData               : longint;
     PointerToRawData            : longint;
     PointerToRelocations        : longint;
     PointerToLineNumbers        : longint;
     NumberOfRelocations         : word;
     NumberOfLineNumbers         : word;
     Characteristics             : longint;
     end;

     Image_Import_By_Name        = record
     Hint                        : word;
     Name                        : array[1..20] of char;
     End;

     TImage_Import_Descriptor    = ^Image_Import_Descriptor;
     Image_Import_Descriptor     = Record
     Characteristics             : longint;
     TimeDateStamp               : longint;
     ForwarderChain              : longint;
     Name                        : longint;
     FirstThunk                  : longint;
     end;

     TImage_Export_Directory        = ^Image_Export_Directory;
     Image_Export_Directory         = Record
     Characteristics                : longint;
     TimeDateStamp                  : Longint;
     MajorVersion                   : word;
     MinorVersion                   : word;
     Name                           : longint;
     Base                           : longint;
     NumberOfFunctions              : longint;
     NumberOfNames                  : longint;
     AddressOfFunctions             : longint;
     AddressOfNames                 : longint;
     AddressOfNameOrdinals          : word;
     end;

     string_type = array[1..128] of char;

const
image_dos_header_size      : word = sizeof(image_dos_header);
image_pe_header_size       : word = sizeof(image_pe_header);
image_optional_header_size : word = sizeof(image_optional_header);
image_section_header_size  : word = sizeof(image_section_header);

var
PImage_Dos_Header      : TImage_Dos_Header;
PImage_PE_Header       : TImage_PE_Header;
PImage_Optional_Header : TImage_Optional_Header;
PImage_Section_Header  : TImage_Section_Header;
PImage_Import_Descriptor: Timage_Import_Descriptor;
PImage_Export_Directory : TImage_Export_Directory;
TImage_Import_By_Name   : Image_Import_By_Name;

const {Directories Addresses}
Aidata : longint = 0 ;
Aedata : longint = 0 ;
Aivirt : longint = 0 ;
Aevirt : longint = 0 ;

var
st: string_type;
PE_Signature,l : longint;
importednames, importedaddresses: word;
cdosoffset, cpeoffset: word;
ft: DateTime;
dos_stub_ofs: word;
pc: ^byte;
tattr: byte;

var
   pefile: file;
   outf: text;
   f: integer;
   k, junk: word;
   s, filemask, filename, outfile, s1, s2: string;
   search: searchrec;
   ok: boolean;

Procedure CloseAll;
begin
    close(pefile);
    close(outf);
End;

Function readstr:string;
var f: integer;
begin
   For f:=1 to 125 do st[f]:=#0;
   f:=1;
   repeat
   if not eof(pefile) then blockread(pefile,st[f],1);
   inc(f);
   until (st[f-1]=#0) or (f>120);
   if f>120 then readstr:=' ' else  readstr:=st;
end;

Procedure ExitError(error: byte);
begin
   writeln;
   write('Error #',100+error,': ');
   case error of
   1: writeln('File not found ('+filename+')');
   2: writeln('Cannot open input file ('+filename+')');
   3: writeln('Connot output to file ('+outfile+')');
   4: writeln('Invalid command line option ('+paramstr(2)+')');
   5: writeln('Not an EXE file ! ');
   6: writeln('Not a PE file ! ');
   end;
   textattr:=tattr;
   halt(255);
end;

Procedure Write_line(s: string);
begin
    s:='ÄÄÄÄÄÄÄ´ '+s+' Ã';
    repeat if length(s)<78 then s:=s+'Ä' until length(s)>=78;
    writeln(outf);
    writeln(outf,s);
    writeln(outf);
end;

Procedure Writef(s:string);
Begin
     write(outf, s);
End;

Procedure Writefln(s:string);
Begin
     writeln(outf, s);
End;

function LZero(w : Word) : String;
var
  s : String;
begin
  Str(w:0,s);
  if Length(s) = 1 then
    s := '0' + s;
  LZero := s;
end;

function HexWord(w: Word): string;
const
 hexChars: array [0..$F] of Char =
   '0123456789ABCDEF';
begin
 HexWord:= hexChars[Hi(w) shr 4]+
           hexChars[Hi(w) and $F]+
           hexChars[Lo(w) shr 4]+
           hexChars[Lo(w) and $F]+'H';
end;

Function HexLong(w: longint): string;
var s1, s2: string;
    w1, w2: word;
Begin
  w1:=w shr 16;
  w2:=(w and $FFFF);
  s1:=hexword(w1);
  s1:=copy(s1,1,4);
  s2:=hexword(w2);
  s1:=s1+s2;
  repeat if length(s1)<9 then s1:='0'+s1 until length(s1)>=9;
  HexLong:=s1;
End;

Function N(x: word): string;
var s: string;
begin
    str(x, s);
    repeat if length(s)<5 then s:='0'+s until length(s)>=5;
    s:=s+'d';
    N:=s;
end;

Procedure Help;
begin
    writeln;
    writeln('Usage: info-pe <filename> [/o:<output>]');
    writeln;
    writeln('   <filename>  = The Portable Exe file');
    writeln('   /o:<output> = Specify the output file');
    writeln('                 The default file is <filename>.ipe');
    writeln;
    textattr:=tattr;
    halt(0);
end;

Procedure UpperCase(var s:string);
var index: integer;
begin
    for index:=1 to length(s) do s[index]:=UpCase(s[index]);
end;

Procedure Open_files;
begin
    if (paramcount=0) or (paramcount>2) then help;
    s1:=paramstr(1);
    s2:=paramstr(2);
    if s2<>'' then
       if (((s2[1]<>'/') and (s2[1]<>'-')) or (s2[2]<>'o') or (s2[3]<>':'))
          then ExitError(4)
       else s2:=copy(s2, 4, length(s2)-3);
    uppercase(s1);
    uppercase(s2);
    if ((paramstr(1)='/H')    or
        (paramstr(1)='/HELP') or
        (paramstr(1)='/?')    or
        (paramstr(1)='-h')    or
        (paramstr(1)='-HELP') or
        (paramstr(1)='-?'))   then help;

    filemask:=s1;
    outfile :=s2;
    ok:=false;
    for f:=1 to length(filemask) do if filemask[f]='.' then ok:=true;
    if not ok then filemask:=filemask+'.EXE';
    filename:=copy(filemask, 1, length(filemask)-4);
    findfirst(filemask, $3f, search);
    if doserror <> 0 then exiterror(1);
    if outfile='' then outfile:=filename+'.IPE';
    assign(outf, outfile);
    assign(pefile, search.name);
    {$i-}
    rewrite(outf);
    {$i+}
    if ioresult<>0 then exiterror(2);
    {$i-}
    reset(pefile, 1);
    {$i+}
    if ioresult<>0 then exiterror(3);
end;

Procedure Initialize;
Begin
     writefln(contline);
     writefln('      INFO-PE v.2.1 Information on Portable Exes by Lord Julus (c) 1998');
     writefln(contline);
     writefln('');
End;

Procedure WriteOffsets(x: integer);
begin
    write(outf,'º ',hexword(cdosoffset),' ³ ',hexword(cpeoffset),' º');
    inc(cdosoffset,x);
    inc(cpeoffset,x)
end;

Procedure WriteBlankOfs;
begin
    write(outf,'º       ³       º');
end;


{============================( OUTPUT PROCEDURES )===========================}

Procedure Write_Dos_Stuff;
Begin
    write_line('DOS INFORMATION');
    Writefln('Analyzed File: '+filemask);
    Writefln('');
    Writefln('DOS Reports: ');
    unpacktime(search.time, ft);
Writeln(outf, '             ş File Size  - ', hexword(search.size), '      (',n(search.size),')');
Writeln(outf, '             ş File Time  - ', lzero(ft.hour),':',lzero(ft.min),':',lzero(ft.sec),'   (hh:mm:ss)');
Writeln(outf, '             ş File Date  - ', lzero(ft.day),'/',lzero(ft.month),'/',lzero(ft.year),' (dd/mm/yy)');
s:='';
if search.attr and $01 = 1 then s:=s+'ReadOnly ';
if (search.attr and $02) shr 1 = 1 then s:=s+'Hidden ';
if (search.attr and $04) shr 2 = 1 then s:=s+'System ';
if (search.attr and $20) shr 5 = 1 then s:=s+'Archive ';
Writeln(outf, '             ş Attributes : ', s);
End;

Procedure Write_Dos_Header;
Begin
     write_line('Original DOS Header');
writeln(outf,' ÚÄ':9,'ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿');
writeln(outf,' ³ ':9,'OFFS. ³ Explanation for data           ³ Hexa  ³ Dec.   ³ ');
writeln(outf,' ÃÄ':9,'ÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ´');
     with PImage_Dos_Header^ do
     begin
     k:=0;
write(outf,' ³ ':9, hexword(k), ' '); k:=k+2;
writeln(outf,'³ Magic word "MZ"                ³ ',hexword(dh_magic),' ³ ',n(dh_magic),' ³ ');
write(outf,' ³ ':9, hexword(k), ' '); k:=k+2;
writeln(outf,'³ Bytes on the last page         ³ ',hexword(dh_cplb),' ³ ',n(dh_cplb),' ³ ');
write(outf,' ³ ':9, hexword(k), ' '); k:=k+2;
writeln(outf,'³ Pages in file                  ³ ',hexword(dh_cp),' ³ ',n(dh_cp),' ³ ');
write(outf,' ³ ':9, hexword(k), ' '); k:=k+2;
writeln(outf,'³ Relocations                    ³ ',hexword(dh_crlc),' ³ ',n(dh_crlc),' ³ ');
write(outf,' ³ ':9, hexword(k), ' '); k:=k+2;
writeln(outf,'³ Size of header in paragraphs   ³ ',hexword(dh_cparhdr),' ³ ',n(dh_cparhdr),' ³ ');
write(outf,' ³ ':9, hexword(k), ' '); k:=k+2;
writeln(outf,'³ Minimum paragraphs needed      ³ ',hexword(dh_minalloc),' ³ ',n(dh_minalloc),' ³ ');
write(outf,' ³ ':9, hexword(k), ' '); k:=k+2;
writeln(outf,'³ Maximum paragraphs needed      ³ ',hexword(dh_maxalloc),' ³ ',n(dh_maxalloc),' ³ ');
write(outf,' ³ ':9, hexword(k), ' '); k:=k+2;
writeln(outf,'³ Initial (relative) SS value    ³ ',hexword(dh_ss),' ³ ',n(dh_ss),' ³ ');
write(outf,' ³ ':9, hexword(k), ' '); k:=k+2;
writeln(outf,'³ Initial SP value               ³ ',hexword(dh_sp),' ³ ',n(dh_sp),' ³ ');
write(outf,' ³ ':9, hexword(k), ' '); k:=k+2;
writeln(outf,'³ File Checksum                  ³ ',hexword(dh_chksum),' ³ ',n(dh_chksum),' ³ ');
write(outf,' ³ ':9, hexword(k), ' '); k:=k+2;
writeln(outf,'³ Initial IP value               ³ ',hexword(dh_ip),' ³ ',n(dh_ip),' ³ ');
write(outf,' ³ ':9, hexword(k), ' '); k:=k+2;
writeln(outf,'³ Initial (relative) CS value    ³ ',hexword(dh_cs),' ³ ',n(dh_cs),' ³ ');
write(outf,' ³ ':9, hexword(k), ' '); k:=k+2;
writeln(outf,'³ File address relocation table  ³ ',hexword(dh_farlc),' ³ ',n(dh_farlc),' ³ ');
write(outf,' ³ ':9, hexword(k), ' '); k:=k+2;
writeln(outf,'³ Overlay number                 ³ ',hexword(dh_ovno),' ³ ',n(dh_ovno),' ³ ');
for f:=1 to 4 do begin
write(outf,' ³ ':9, hexword(k), ' '); k:=k+2;
writeln(outf,'³ Reserved word                  ³ ',hexword(dh_res1[f]),' ³ ',n(dh_res1[f]),' ³ ');
end;
write(outf,' ³ ':9, hexword(k), ' '); k:=k+2;
writeln(outf,'³ OEM identifier                 ³ ',hexword(dh_oemid),' ³ ',n(dh_oemid),' ³ ');
write(outf,' ³ ':9, hexword(k), ' '); k:=k+2;
writeln(outf,'³ OEM information                ³ ',hexword(dh_oemidinfo),' ³ ',n(dh_oemidinfo),' ³ ');
for f:=1 to 10 do begin
write(outf,' ³ ':9, hexword(k), ' '); k:=k+2;
writeln(outf,'³ Reserved word                  ³ ',hexword(dh_res2[f]),' ³ ',n(dh_res2[f]),' ³ ');
end;
writeln(outf,'ÃÄ':9,'ÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´');
write(outf,' ³ ':9, hexword(k), ' ');
{s:=copy(s,1,length(s)-1);}
writeln(outf,'³ Address of the PE header (DW)  ³ ',hexlong(dh_lfanew),'      ³ ');
writeln(outf,'ÀÄ':9,'ÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
writeln(outf);
writeln(outf);
end;
End;

Procedure Check_file_Type;
Begin
    blockread(pefile, PE_signature, 4);
    if PE_signature = $4550 then ok:=true else ok:=false;
    if ok then exit;
    case PE_signature of
    $454E: s:='Error: This file appeares to be a New Exe file !';
    $454C, $4558: s:='Error: This file appeares to be a virtual driver !';
    else
    s:='Error: Unrecognized second signature. File might be a simple old DOS Exe !';
    end;
    writeln(outf,'');
    writeln(outf,'  ',s);
    writeln(outf,contline);
    CloseAll;
    ExitError(6);
end;

Procedure Write_Dos_Stub;
Begin
    k:=PImage_Dos_Header^.dh_lfanew-$3c-4;
    if k>$100 then exiterror(6);
    dos_stub_ofs:=$3c + 4;
    seek(pefile, Dos_Stub_Ofs);
    getmem(pc, k);
    blockread(pefile, pc^, k);
    if filepos(pefile)+PImage_Dos_Header^.dh_lfanew>filesize(pefile)
       then ExitError(6);
    if filepos(pefile)<>PImage_Dos_Header^.dh_lfanew then
       seek(pefile,PImage_Dos_Header^.dh_lfanew);
    check_file_type;
    write_line('DOS Stub Info');
    writeln(outf, '         DOS Stub length       - ', hexword(k),' ('+n(k)+')');
    writeln(outf, '         DOS Stub Start Offset - ', hexword(dos_stub_ofs),' ('+n(dos_stub_ofs)+')');
    writeln(outf, '         DOS Stub End Offset   - ', hexword(dos_stub_ofs+k),' ('+n(dos_stub_ofs+k)+')');
    writeln(outf,'');
    for f:=1 to k-1 do inc(pc);
    s:='';
    f:=k;
    repeat if (char(pc^)<>'$') then begin dec(pc); dec(f) end;
    until (char(pc^)='$') or (f<=1);
    f:=k;
    repeat
        if (char(pc^)='$') or (pc^=$0d) or (pc^=$0a) or (pc^=0) then begin dec(pc); dec(f); end;
    until ((char(pc^)<>'$') and (pc^<>$0d) and (pc^<>$0a)) and (pc^<>0) or (f<=1);
    if f<=1 then
    writeln(outf,'Could no retrieve Dos Stub string')
    else
    begin
    ok:=true;
    repeat
        if (char(pc^) in ['0'..'9']) or (char(pc^) in ['A'..'Z']) or
           (char(pc^) in ['a'..'z']) or (char(pc^)=' ') or (char(pc^)='.')
           then
               begin
                s:=char(pc^)+s;
                dec(pc);
               end
                else ok:=false
    until not ok;
    writeln(outf,'');
    writeln(outf,'   String displayed by the DOS Stub: ');
    writeln(outf,'');
    writeln(outf,'   "'+s+'"');
    end;
end;

Procedure Read_file_Dos_Header;
begin
    writeln('Reading from file '+filemask+'... Please wait...');
    getmem(PImage_Dos_Header, sizeof(Image_Dos_Header));
    blockread(pefile, PImage_Dos_Header^, sizeof(Image_Dos_Header),f);
    with PImage_Dos_Header^
    do
    begin
         if dh_magic <> $5A4D then exiterror(5);
         initialize;
         write_dos_stuff;
         write_Dos_Header;
         write_Dos_Stub;
    end;
end;

Procedure Read_file_PE_header;
begin
    cdosoffset:=PImage_Dos_Header^.dh_lfanew;
    cpeoffset:=0;
    getmem(PImage_PE_Header, sizeof(Image_PE_Header));
    blockread(pefile, PImage_PE_Header^, sizeof(Image_PE_Header),f);
    write_line('PE Header');
    writeln(outf,'ÖÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄ·');
    writeln(outf,'º O_DOS ³ O_PE  º (Offset from Dos Header / PE Header');
    writeln(outf,'ÇÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄ¶');
    writeoffsets(4);
    Writeln(outf, '  PE Header Signature - PE/0/0');
    writeoffsets(2);
    with PImage_PE_Header^ do
    begin
    case Machine of
    $14C: s:='Intel 386';
    $162: s:='MIPS L-endian, 0160h B-endian';
    $166,$168: s:='MIPS L-endian';
    $184: s:='Alpha_AXP';
    $1F0: s:='IBM PowerPC L-Endian';
    else
    s:='Machine type Unknown';
    end;
    Writeln(outf, '  The machine for this EXE is '+s+' (value = '+hexword(machine)+')');
    writeoffsets(2);
    Writeln(outf, '  Number of sections in the file - '+hexword(NumberOfSections));
    unpacktime(TimeDateStamp, ft);
    writeoffsets(4);
    Writeln(outf, '  File was linked at : ',lzero(ft.day),'/',lzero(ft.month),'/',lzero(ft.year));
    writeoffsets(4);
    Writeln(outf, '  Pointer to Symbol Table : ',hexlong(PointerToSymbolTable));
    writeoffsets(4);
    Writeln(outf, '  Number of Symbols : ', hexlong(NumberOfSymbols));
    writeoffsets(2);
    Writeln(outf, '  Size of the Optional Header : ', hexword(SizeOfOptionalHeader));
    writeblankofs;
    Writeln(outf);
    writeoffsets(2);
    Writeln(outf, '  File Characteristics - ', hexword(characteristics),' : ');
    k:=Characteristics;
    if k and $0001 = $0001 then writeln(outf,'º       ³       º  ù Relocation info stripped from file');
    if k and $0002 = $0002 then writeln(outf,'º       ³       º  ù File is executable');
    if k and $0004 = $0004 then writeln(outf,'º       ³       º  ù Line numbers stripped from file');
    if k and $0008 = $0008 then writeln(outf,'º       ³       º  ù Local symbols stripped from file');
    if k and $0040 = $0040 then writeln(outf,'º       ³       º  ù 16 bit word machine');
    if k and $0080 = $0080 then writeln(outf,'º       ³       º  ù Bytes of machine word are reversed');
    if k and $0100 = $0100 then writeln(outf,'º       ³       º  ù 32 bit word machine');
    if k and $0200 = $0200 then writeln(outf,'º       ³       º  ù Debugging info stripped from file in .DBG file');
    if k and $1000 = $1000 then writeln(outf,'º       ³       º  ù System File');
    if k and $2000 = $2000 then writeln(outf,'º       ³       º  ù File is a DLL');
    if k and $8000 = $8000 then writeln(outf,'º       ³       º  ù Bytes of machine word are reversed');
    writeln(outf,'ÓÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ½');
    writeln(outf);
    end;
end;

Procedure Read_file_Optional_header;
begin
    getmem(PImage_Optional_Header, sizeof(Image_Optional_Header));
    blockread(pefile, PImage_Optional_Header^, sizeof(Image_Optional_Header),f);
    write_line('PE Optional Header');
    writeln(outf,'ÖÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄ·');
    writeln(outf,'º O_DOS ³ O_PE  º (Offset from Dos Header / PE Header');
    writeln(outf,'ÇÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄ¶');
    With PImage_Optional_Header^ do
    Begin
    writeoffsets(2);
    Writeln(outf,'  Magic Value                : ', hexword(Magic), ' (`', char(hi(Magic)),char(lo(Magic)),'`)');
    writeoffsets(1);
    Writeln(outf,'  Major Linker Version       : ', MajorLinkerVersion);
    Writeoffsets(1);
    Writeln(outf,'  Minor Linker Version       : ', MinorLinkerVersion);
    writeblankofs;
    Writeln(Outf,'  Linker Version             : ', MajorLinkerVersion,'.',MinorLinkerVersion);
    Writeoffsets(4);
    Writeln(outf,'  Size of Code               : ', hexlong(SizeOfCode));
    writeoffsets(4);
    Writeln(outf,'  Size of Initialized Data   : ', hexlong(SizeOfInitializedData));
    Writeoffsets(4);
    Writeln(outf,'  Size of Uninitialized Data : ', hexlong(SizeOfUninitializedData));
    Writeoffsets(4);
    Writeln(outf,'  Address of Entry Point     : ', hexlong(AddressOfEntryPoint));
    writeoffsets(4);
    Writeln(outf,'  Base of Code (.text ofs.)  : ', hexlong(BaseOfCode));
    writeoffsets(4);
    Writeln(outf,'  Base of Data (.bss ofs.)   : ', hexlong(BaseOfData));
    writeoffsets(4);
    Writeln(outf,'  Image Base                 : ', hexlong(ImageBase));
    writeoffsets(4);
    Writeln(outf,'  Section Alignment          : ', hexlong(SectionAlignment));
    writeoffsets(4);
    Writeln(outf,'  File Alignment             : ', hexlong(FileAlignment));
    writeoffsets(2);
    Writeln(outf,'  Major Operating System Version : ',MajorOperatingSystemVersion);
    writeoffsets(2);
    Writeln(outf,'  Minor Operating System Version : ',MinorOperatingSystemVersion);
    writeoffsets(2);
    Writeln(outf,'  Major Image Version        : ', MajorImageVersion);
    writeoffsets(2);
    Writeln(outf,'  Minor Image Version        : ', MinorImageVersion);
    writeoffsets(2);
    Writeln(outf,'  Major SubSystem Version    : ', MajorSubsystemVersion);
    writeoffsets(2);
    Writeln(outf,'  Minor SubSystem Version    : ', MinorSubsystemVersion);
    writeoffsets(4);
    Writeln(outf,'  Reserved Long              : ', hexlong(Reserved1));
    writeoffsets(4);
    Writeln(outf,'  Size of Image              : ', hexlong(SizeOfImage));
    writeoffsets(4);
    Writeln(outf,'  Size of Headers            : ', hexlong(SizeOfHeaders));
    writeoffsets(4);
    Writeln(outf,'  File Checksum              : ', hexlong(Checksum));
    writeoffsets(2);
    Writeln(outf,'  SubSystem                  : ', Subsystem);
    writeblankofs;
    case Subsystem of
    0: Writeln(outf,'      ù Unknown subsystem');
    1: Writeln(outf,'      ù Image doesn''t require a subsystem');
    2: Writeln(outf,'      ù Image runs in the Windows GUI subsystem');
    3: Writeln(outf,'      ù Image runs in the Windows character subsystem');
    5: Writeln(outf,'      ù Image runs in the OS/2 character subsystem');
    7: Writeln(outf,'      ù Image run  in the Posix character subsystem');
    end;
    writeoffsets(2);
    Writeln(outf,'  DLL Characteristics        : ', hexword(DLLCharacteristics));
    if DLLCharacteristics <> 0 then writeblankofs;
    case DLLCharacteristics of
    1: write(outf,'      ù Dll has a process initialization routine');
    2: write(outf,'      ù Dll has a thread termination routine');
    4: write(outf,'      ù Dll has a thread initialization routine');
    8: write(outf,'      ù Dll has a thread termination routine');
    end;
    writeoffsets(4);
    Writeln(outf,'  Size of Stack Reserve      : ',hexlong(SizeOfStackReserve));
    writeoffsets(4);
    Writeln(outf,'  Size of Stack Commit       : ', hexlong(SizeOfStackCommit));
    writeoffsets(4);
    Writeln(outf,'  Size of Heap Reserve       : ',hexlong(SizeOfHeapReserve));
    writeoffsets(4);
    Writeln(outf,'  Size of Heap Commit        : ',hexlong(SizeOfHeapCommit));
    writeoffsets(4);
    Writeln(outf,'  Loader Flags               : ', hexlong(LoaderFlags));
    if LoaderFlags<>0 then writeblankofs;
    case LoaderFlags of
    1: Write(outf,'      ù Invoke a breakpoint before starting the process');
    2: Write(outf,'      ù Invoke a debuggeron the process after it''s been loaded');
    end;
    writeoffsets(4);
    Writeln(outf,'  Number Directories         : ', hexlong(NumberOfRVAAndSizes));
    writeln(outf,'ÓÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ½');
    writeln(outf);

    writeln(outf, '   The Image Data Directory : ');
    writeln(outf,'');
    writeln(outf,'ÖÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄ·');
    for f:=0 to Image_numberof_directory_entries-1 do
    begin
    writeblankofs;
    case f of
    0 : Writeln(outf,'   Export Directory');
    1 : Writeln(outf,'   Import Directory');
    2 : Writeln(outf,'   Resource Directory');
    3 : Writeln(outf,'   Exception Directory');
    4 : Writeln(outf,'   Security Directory');
    5 : Writeln(outf,'   Base Relocation Table');
    6 : Writeln(outf,'   Debug Directory');
    7 : Writeln(outf,'   Description String');
    8 : Writeln(outf,'   Machine Value (MIPS GP)');
    9 : Writeln(outf,'   TLS Directory');
    10: Writeln(outf,'   Load Configuration Directory');
    11: Writeln(outf,'   Bound Import Directory in headers');
    12: Writeln(outf,'   Import Address Table');
    13: Writeln(outf,'   Reserved');
    14: Writeln(outf,'   Reserved');
    15: Writeln(outf,'   Reserved');
    end;
    if f=0 then Aevirt:=Image_Data_Directory[f].VirtualAddress;
    writeoffsets(4);
    writeln(outf,'          VA:   ',hexlong(Image_Data_Directory[f].VirtualAddress));
    writeoffsets(4);
    writeln(outf,'          Size: ',hexlong(Image_Data_Directory[f].Size));
    end;
    writeln(outf,'ÓÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ½');
    end;
end;

Procedure Read_File_Section_Header;
var index: word;
begin
    k:=filepos(pefile);
    write_line('PE Section Headers');
    writeln(outf,'ÖÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄ·');
    writeln(outf,'º O_DOS ³ O_PE  º (Offset from Dos Header / PE Header');
    writeln(outf,'ÇÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄ¶');
    getmem(PImage_Section_Header, sizeof(Image_Section_Header));

    for index:=1 to PImage_PE_Header^.NumberOfSections do
    begin
        blockread(pefile, PImage_Section_Header^, sizeof(Image_Section_Header));
        With PImage_Section_Header^ do
        begin
            writeoffsets(8);
            s:=copy(name, 1, 8);
            if copy(s,1,6)='.idata' then
                                    begin
                                    Aidata:=PointerToRawData;
                                    Aivirt:=VirtualAddress;
                                    end;

            if Aevirt = VirtualAddress then
                        begin
                         Aedata:=PointerToRawData;
                         Aevirt:=VirtualAddress;
                        end;

            if (copy(s,1,5)='_INIT') or (copy(s,1,6)='.edata') then
                                    begin
                                    Aedata:=PointerToRawData;
                                    Aevirt:=VirtualAddress;
                                    end;
            writeln(outf,'  Section name            : ', s);
            writeoffsets(4);
            Writeln(outf,'  Virtual Size            : ', hexlong(PhysicalAddress));
            writeoffsets(4);
            Writeln(outf,'  Virtual Address         : ', hexlong(VirtualAddress));
            writeoffsets(4);
            writeln(outf,'  Size of RAW data        : ', hexlong(SizeOfRawData));
            writeoffsets(4);
            writeln(outf,'  Pointer to RAW data     : ', hexlong(PointerToRawData));
            writeoffsets(4);
            writeln(outf,'  Pointer to relocations  : ', hexlong(PointerToRelocations));
            writeoffsets(4);
            writeln(outf,'  Pointer to line numbers : ', hexlong(PointerToLinenumbers));
            writeoffsets(2);
            writeln(outf,'  Number of Relocations   : ', hexword(NumberOfRelocations));
            writeoffsets(2);
            writeln(outf,'  Number of line numbers  : ', hexword(NumberOfLineNumbers));
            writeoffsets(4);
            writeln(outf,'  Characteristics         : ', hexlong(Characteristics));
            l:=Characteristics;
if l and $00000020 = $00000020 then writeln(outf,blank,'  ù Section contains code.');
if l and $00000040 = $00000040 then writeln(outf,blank,'  ù Section contains initialized data.');
if l and $00000080 = $00000080 then writeln(outf,blank,'  ù Section contains uninitialized data.');
if l and $00000200 = $00000200 then writeln(outf,blank,'  ù Section contains comments or some other type of information.');
if l and $00000800 = $00000800 then writeln(outf,blank,'  ù Section contents will not become part of image.');
if l and $00001000 = $00001000 then writeln(outf,blank,'  ù Section contents comdat.');
if l and $00020000 = $00020000 then writeln(outf,blank,'  ù Section is purgeable');
if l and $00040000 = $00040000 then writeln(outf,blank,'  ù Section is locked in memory');
if l and $00080000 = $00080000 then writeln(outf,blank,'  ù Section is preloaded in memory');
if l and $00100000 = $00100000 then writeln(outf,blank,'  ù 1 Byte alignment');
if l and $00200000 = $00200000 then writeln(outf,blank,'  ù 2 Bytes alignment');
if l and $00300000 = $00300000 then writeln(outf,blank,'  ù 4 Bytes alignment');
if l and $00400000 = $00400000 then writeln(outf,blank,'  ù 8 bytes alignment');
if l and $00500000 = $00500000 then writeln(outf,blank,'  ù 16 Bytes alignment');
if l and $00600000 = $00600000 then writeln(outf,blank,'  ù 32 Bytes alignment');
if l and $00700000 = $00700000 then writeln(outf,blank,'  ù 64 Bytes alignment');
if l and $01000000 = $01000000 then writeln(outf,blank,'  ù Section contains extended relocations.');
if l and $02000000 = $02000000 then writeln(outf,blank,'  ù Section can be discarded.');
if l and $04000000 = $04000000 then writeln(outf,blank,'  ù Section is not cachable.');
if l and $08000000 = $08000000 then writeln(outf,blank,'  ù Section is not pageable.');
if l and $10000000 = $10000000 then writeln(outf,blank,'  ù Section is shareable.');
if l and $20000000 = $20000000 then writeln(outf,blank,'  ù Section is executable.');
if l and $40000000 = $40000000 then writeln(outf,blank,'  ù Section is readable.');
if l and $80000000 = $80000000 then writeln(outf,blank,'  ù Section is writeable.');
             writeblankofs; writeln(outf,'');
        end;
    end;
    writeln(outf,'ÓÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ½');
end;

Procedure Read_File_Exported_Modules;
var l1, l2, l3, l4, l: longint;
Begin
    write_line('Exported Functions Analisis');
    if Aedata = 0 then Writeln(outf,' File does not Export any Functions.',#10,#13)
else
begin
    seek(pefile, Aedata);
    getmem(PImage_Export_Directory, sizeof(TImage_Export_Directory));
    blockread(pefile, PImage_Export_Directory^,sizeof(Image_Export_Directory),f);
    with PImage_Export_Directory^ do
    begin
    writeln(outf, '  Characteristics: ', Characteristics);
    unpacktime(TimeDateStamp,ft);
    write(outf,   '  Time/Date: ',lzero(ft.hour),':',lzero(ft.min),':',lzero(ft.sec),' / ');
    Writeln(outf,lzero(ft.day),'/',lzero(ft.month),'/',lzero(ft.year));
    writeln(outf, '  Major Version : ',MajorVersion);
    writeln(outf, '  Minor Version : ',MinorVersion);
    writeln(outf, '  RVA of the ASCIZZ Name : ',hexlong(Name));
    writeln(outf, '  Starting Ordinal for exported functions : ',hexlong(Base));
    writeln(outf, '  The Number of Exported Functions : ',hexlong(NumberOfFunctions));
    writeln(outf, '  The Number of Exported Names     : ',hexlong(NumberOfNames));
    writeln(outf, '  A RVA to the function addresses  : ',hexlong(AddressOfFunctions));
    writeln(outf, '  A RVA to the names addresses     : ',hexlong(AddressOfNames));
    writeln(outf, '  A RVA to the address of ordinals : ',hexword(AddressOfNameOrdinals));

    l := Name + Aedata - Aevirt;
    seek(pefile, l);
    s:=readstr;
    writeln(outf);
    writeln(outf, '  The Exporting Module Name : ', s);
    writeln(outf);
    writeln(outf, '  Exported functions : ');
    writeln(outf);
    writeln(outf, ' ÖÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    writeln(outf, ' º  Ordinal  ³  Address  ³  Name      ');
    writeln(outf, ' ÇÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    l1:=AddressOfNameOrdinals + Aedata - Aevirt;
    l2:=AddressOffunctions + Aedata - Aevirt;
    l3:=filepos(pefile);
    for l:=1 to NumberOfFunctions do
    begin
        seek(pefile, l1);
        blockread(pefile, f, sizeof(f));
        write(outf,' º  ',hexword(f),'    ³ ');
        seek(pefile, l2);
        blockread(pefile, l4, sizeof(l4));
        write(outf,hexlong(l4),' ³  ');
        seek(pefile, l3);
        s:=readstr;
        writeln(outf, s);
        l3:=filepos(pefile);
        l1:=l1+2;
        l2:=l2+4;
    end;
    end;
    writeln(outf, ' ÓÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
end;
End;

Procedure Read_File_Imported_Modules;
var l1, l2, l3, l4, l5, l6, savedl: longint;
label 1000, 2000, 3000;
Begin
    write_line('Imported Functions Analisis');
    if Aidata = 0 then Writeln(outf,' File does not Import any Functions.',#10,#13)
else
begin
    getmem(PImage_Import_Descriptor, sizeof(TImage_Import_Descriptor));
    seek(pefile, Aidata);
    repeat
    blockread(pefile, PImage_Import_Descriptor^,sizeof(Image_Import_Descriptor),f);
    with PImage_Import_Descriptor^ do
    begin
       if (characteristics=0) and (TimeDateStamp=0) then goto 1000;
       writeln(outf, 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
       writeln(outf, '³ Hint/Name Table     : ', hexlong(Characteristics));
       writeln(outf, '³ Time                : ', hexlong(timedatestamp));
       writeln(outf, '³ Forwarder Chain     : ', hexlong(ForwarderChain));
       writeln(outf, '³ Address to DLL Name : ', hexlong(Name));
       writeln(outf, '³ First Thunk RVA     : ', hexlong(FirstThunk));
       writeln(outf, 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
       writeln(outf);
       l3:=filepos(pefile);
       l1:=Aidata + Name - Aivirt;
       seek(pefile, l1);
       s:=readstr;
       writeln(outf, '  Imported functions from ', s);
       writeln(outf, ' ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
       writeln(outf);
       writeln(outf,'    ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
       writeln(outf,'    ³   RVA     ³ Physical  ³  Ord.  ³  Function Name                                 ');
       writeln(outf,'    ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');

       savedl:=l1;
       seek(pefile, l3);
       l4:=Aidata + Characteristics - Aivirt;
       l5:=Aidata + FirstThunk - Aivirt;
       bound:=true;
       importednames:=0;
       importedaddresses:=0;
repeat
       seek(pefile, l4);
       blockread(pefile, l2, sizeof(l2));
       l4:=filepos(pefile);
       if l2<0 then goto 3000;
       if l2=0 then goto 2000;
       l2:=Aidata + l2 - Aivirt;
       seek(pefile, l2);
       if (filepos(pefile)+sizeof(k))>filesize(pefile) then goto 2000;
       blockread(pefile, k, sizeof(k));
       s:=readstr;
       seek(pefile, l5);
       l6:=l5;
       blockread(pefile, l2, sizeof(l2));
       l5:=filepos(pefile);
       l2:=Aidata+l2-Aivirt;
       if (l2>0) and (l2<filesize(pefile)) then
       begin
         seek(pefile, l2);
         blockread(pefile, k, sizeof(k));
         s:=readstr;
         bound:=false;
       end;
        l2:=Aidata+l2-Aivirt;
       write(outf, '    ³ ',hexlong(l6+Aivirt-Aidata),' ³ ',hexlong(l2+Aivirt-Aidata),' ³ ', hexword(k),'  ³  ');
       writeln(outf, s);
       if s[1]<>#0 then inc(importednames);
       inc(importedaddresses);
3000:
until l4>=savedl;
2000:
       writeln(outf,'    ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
       writeln(outf);
       if bound then
       Writeln(outf, '    The import addresses for this module are bounded.')
       else
       Writeln(outf, '    The import addresses for this module are not bounded.');
       Writeln(outf, '    Number of Imported Names from this module     : ', importednames);
       Writeln(outf, '    Number of Imported Addresses from this module : ', importedaddresses);
       writeln(outf);
       totalimpnames:=totalimpnames+importednames;
       totalimpaddrs:=totalimpaddrs+importedaddresses;
       seek(pefile, l3);

    end;
1000:

    until (PImage_Import_Descriptor^.characteristics=0) and
          (PImage_Import_Descriptor^.TimeDateStamp=0);
    Writeln(outf, '    Total number of Imported Names from all modules     : ', totalimpnames);
    Writeln(outf, '    Total number of Imported Addresses from all modules : ', totalimpaddrs);
    writeln(outf);

End;
End;


Procedure Intro;
begin
    tattr:= textattr;
    textcolor(yellow);
    textbackground(lightred);
    writeln;
    writeln('    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿   ');
    writeln('    ³   INFO-PE v.2.1 - Portable Exe Information by Lord Julus (C) 1998    ³   ');
      write('    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   ');
    textbackground(black);
    writeln;
    writeln;
end;

Procedure Outro;
begin
    writeln('Processing file... Done.');
    writeln('Outputing file ', outfile, '... Done.');
    textcolor(yellow);
    textbackground(lightred);
    writeln;
    writeln('    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿   ');
    writeln('    ³   Write me with impressions on e-mail at: lordjulus@geocities.com    ³   ');
      write('    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   ');
    textattr:=tattr;
    writeln;
    writeln;
end;


begin
    asm
    push di
    db 'LORD_JULUS[C]'
    add sp, 3
    pop di
    inc dx
    dec bx
    end;
    Intro;
    Open_files;
    Read_file_Dos_Header;
    Read_file_PE_Header;
    Read_file_Optional_Header;
    Read_file_Section_Header;
    Read_file_Exported_Modules;
    Read_file_Imported_Modules;
    CloseAll;
    Outro;
    halt(0);
end.
