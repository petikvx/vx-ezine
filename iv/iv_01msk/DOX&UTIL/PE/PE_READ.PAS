{$A-,B-,D+,E+,F-,G+,I-,L+,N+,O-,P-,Q+,R+,S+,T-,V+,X+,Y+}
{$M 32768,0,655360}
Program PERead;
Uses Crt;

Procedure GetCh;Forward;
Procedure DoUpdate;Forward;
Procedure UpdateRunningLine;Forward;
Procedure GetMenu;Forward;
Procedure GetIndex;Forward;

Var
   Infile:File;


Type
Dword = Record
      Hi,Lo:word;
      end;
{************** Some abbreviations*****************
Sz              Size
Cnt             Count
Tbl             Table
Ttl             Total
Exp             Export
Imp             Import
Res             Resource
Exc             Exception
Sec             Security
Fxp             Fixup
Dbg             Debug
Img             Image
Dscr            Description
Mchn            Machine
Spc             Specific
Thr             Thread
Lcl             Local
Str             Storage
Entr_Pnt        Entry Point
CRC             Checksum
Rsrv            Reserve
Cmmt            Commit
Intrs           Interesting
Dirs            Directories
RVA             Relative Virual Address
TLS             Thread Local Storage
}

PEHeader = Record
{0}      Signature      :array [1..4] of char;
{4}      CPU_Type       :word;
{6}      Objects_Cnt    :word;
{8}      Time_Date_Stamp:Dword;
{12}     Reserved1      :array [1..8] of byte;
{20}     NT_HDR_Sz      :word;
{22}     Flags          :word;
{24}     Reserved2      :array [1..2] of byte;
{26}     Lmajor         :byte;
{27}     Lminor         :byte;
{28}     Reserved3      :array [1..12] of byte;
{40}     Entr_Pnt_RVA   :Dword;
{44}     Reserved4      :array [1..8] of byte;
{52}     Image_Base     :Dword;
{56}     Object_Align   :Dword;
{60}     File_Align     :Dword;
{64}     OS_Major       :Word;
{66}     OS_Minor       :Word;
{68}     User_Major     :Word;
{70}     User_Minor     :Word;
{72}     Subsys_Major   :Word;
{74}     Subsys_Minor   :Word;
{76}     Reserved5      :Array [1..4] of byte;
{80}     Image_Sz       :Dword;
{84}     Header_Sz      :Dword;
{88}     File_CRC       :Dword;
{92}     Subsystem      :Word;
{94}     Dll_Flags      :Word;
{96}     Stack_Rsrv_Sz  :Dword;
{100}    Stack_Cmmt_Sz  :Dword;
{104}    Heap_Rsrv_Sz   :Dword;
{108}    Heap_Cmmt_Sz   :Dword;
{112}    Reserved6      :Array [1..4] of byte;
{116}    _Intrs_RVA_Sz  :Dword;
{120}    Exp_Tbl_RVA    :Dword;
{124}    Tot_Exp_Data_Sz:Dword;
{128}    Imp_Tbl_RVA    :Dword;
{132}    Tot_Imp_Data_Sz:Dword;
{136}    Res_Tbl_RVA    :Dword;
{140}    Tot_Res_Data_Sz:Dword;
{144}    Exc_Tbl_RVA    :Dword;
{148}    Tot_Exc_Data_Sz:Dword;
{152}    Sec_Tbl_RVA    :Dword;
{156}    Tot_Sec_Data_Sz:Dword;
{160}    Fxp_Tbl_RVA    :Dword;
{164}    Tot_Fxp_Data_Sz:Dword;
{168}    Dbg_Tbl_RVA    :Dword;
{172}    Tot_Dbg_Dirs   :Dword;
{176}    Img_Dscr_RVA   :Dword;
{180}    Tot_Dscr_Sz    :Dword;
{184}    Mchn_Spc_RVA   :Dword;
{188}    Mchn_Spc_Sz    :Dword;
{192}    TLS_RVA        :Dword;
{196}    Tot_TLS_Sz     :Dword;
         end;

ObjTable = record
         Object_Name    :array[1..8] of byte;
         Virt_Sz        :Dword;
         RVA            :Dword;
         Phys_Sz        :Dword;
         Phys_Offs      :Dword;
         Reserved1      :array[1..12] of byte;
         Object_Flags   :Dword;
         end;


TDword = record
       Hi,Lo:word;
       end;

Var
   PEHeader1:PEHeader;
   ObjTable1:ObjTable;
   tt1,tt2:byte;
   zz1,zz2:word;
   ww1,ww2:Dword;
   cc1,cc2:char;
   kk1,kk2:String;
   bb1,bb2:boolean;
   a,b,c:integer;

Procedure TextParm(a,b:integer);
Begin
     Textcolor(a);
     TextBackGround(b);
End;



Procedure ReadPEHeader;{optimized}
Var a:LongInt;
Begin
     Seek(infile,$3C);
     BlockRead(infile,a,sizeof(a));
     Seek(infile,a);
     Blockread(infile,PEHeader1,sizeof(PEHeader));
end;

Procedure ReadObjTable;
Var a:LongInt;
Begin
     Seek(infile,$3C);
     BlockRead(infile,a,sizeof(a));

     Seek(infile,a+24+PEHeader1.NT_Hdr_Sz);
     Blockread(infile,ObjTable1,sizeof(ObjTable));
end;

Procedure JReadObjTable;
Begin
     Blockread(infile,ObjTable1,sizeof(ObjTable));
end;

Function Byte2Hex (zu:byte):word;
var
   tt:word;
begin
     asm
     mov al,zu
     shr al,4
     cmp al,10
     jae @@1
     add al,"0"
     jmp @1
@@1:
     add al,"A"-10
@1:
     mov dh,al {dh-HiChar}
     mov al,zu
     shl al,4  {al-LoByte}
     shr al,4
     cmp al,10
     jae @@2
     add al,"0"
     jmp @2
@@2:
     add al,"A"-10
@2:
     mov dl,al {dl-loByte}
     mov tt,dx
     end;
     Byte2Hex:=tt;

end;

Procedure Word2Hex(zu:word;Var Res:Dword);
Var
   tt1,tt2:word;
Begin
     tt1:=Byte2Hex(Hi(zu));
     tt2:=Byte2Hex(Lo(zu));
     Res.hi:=tt1;
     Res.lo:=tt2;
end;

Procedure WriteByte(zz:byte);
Var
   tt:word;
Begin
     tt:=Byte2Hex(zz);
     write(Chr(Hi(tt)),Chr(Lo(tt)));
End;

Procedure WriteWord(zz:word);
Begin
     WriteByte(hi(zz));
     WriteByte(Lo(zz));
end;

Procedure WriteDword(zz:Dword);
Begin
     WriteWord(zz.Lo);
     WriteWord(zz.Hi);
end;

Procedure Space(zu:byte);
Var tt:byte;
Begin
     For tt:=1 to zu do Write(' ');
end;

Procedure Vspace(zu:byte);
Var tt:byte;
Begin
     For tt:=1 to zu do Writeln;
end;

Procedure Wspace(zu:integer);
Var tt:byte;
Begin
     For tt:=1 to zu do Write(' ');
end;


Procedure GetObjectEntryDetails;
Var
   tt:byte;
Label zzz;
Begin
     Writeln;
     Write('Enter Object Entry Number [1..5]:  ');
zzz:
     Write(^h);
     DoUpdate;
     cc1:=Readkey;
     If (cc1=chr(13)) OR (cc1=chr(27)) then Begin
                                                 ClrScr;
                                                 exit;
                                            End;
     If NOT ( cc1 in ['1','2','3','4','5']) then goto zzz;
     tt:=ord(cc1)-48;
     Write(tt);

     ClrScr;
     Writeln;
     case tt of
     1: Begin
               Writeln('>>VIRTUAL SIZE = DD Virtual memory size.  The size of the object that will be');
               Writeln('>>allocated when the object is loaded. Any difference between PHYSICAL SIZE ');
               Writeln('>>and VIRTUAL SIZE is zero filled.');
        End;
     2: Begin
               Writeln('>>RVA = DD Relative Virtual Address.  The virtual address the object is curren-');
               Writeln('>>tly relocated to, relative to the Image Base.  Each Object''s virtual address');
               Writeln('>>space consumes a multiple of Object Align (power of 2 between 512 and 256M ');
               Writeln('>>inclusive. Default is 64K), and immediately follows the previous Object in ');
               Writeln('>>the virtual address space (the virtual address space for a image must be ');
               Writeln('>>dense).');
        End;
     3: Begin
               Writeln('>>PHYSICAL SIZE = DD Physical file size of initialized data.  The size of the ');
               Writeln('>>initialized data in the file for the object. The physical size must be a mul-');
               Writeln('>>tiple of the File Align field in the PE Header,and must be less than or equal');
               Writeln('>>to the Virtual Size.');
        End;
     4: Begin
               Writeln('>>PHYSICAL OFFSET = DD Physical offset for object''s first page. This offset is ');
               Writeln('>>relative to beginning of the EXE file, and is aligned on a multiple of the ');
               Writeln('>>File Align field in the PE Header.  The offset is used as a seek value.');
        End;
     5: Begin
               Writeln('Displaing Object Falgs...');
               Write('Current value is ');
               WriteDword(ObjTable1.Object_Flags);
               Writeln('. Decoding...');
               If (ObjTable1.Object_Flags.Lo=0) and (ObjTable1.Object_Flags.Hi=0) then Writeln('[]__NO Flags set...');
               If (Lo(ObjTable1.Object_Flags.Hi) AND  32)=32 then Writeln('[]__Code object.');
               If (Lo(ObjTable1.Object_Flags.Hi) AND  64)=64 then Writeln('[]__Initialized data object.');
               If (Lo(ObjTable1.Object_Flags.Hi) AND  128)=128 then Writeln('[]__Uninitialized data object.');
               If (Hi(ObjTable1.Object_Flags.Lo) AND  4)=4 then Writeln('[]__Object must not be cached.');
               If (Hi(ObjTable1.Object_Flags.Lo) AND  8)=8 then Writeln('[]__Object is not pageable.');
               If (Hi(ObjTable1.Object_Flags.Lo) AND  $10)=$10 then Writeln('[]__Object is shared.');
               If (Hi(ObjTable1.Object_Flags.Lo) AND  $20)=$20 then Writeln('[]__Executable object.');
               If (Hi(ObjTable1.Object_Flags.Lo) AND  $40)=$40 then Writeln('[]__Readable object.');
               If (Hi(ObjTable1.Object_Flags.Lo) AND  $80)=$80 then Writeln('[]__Writeable object.');
               Writeln;
               Writeln('>>OBJECT FLAGS = DD Flag bits for the object.  The object flag bits');
               Writeln('>>have the following definitions:');
               Writeln('>>  o  000000020h __Code object.');
               Writeln('>>  o  000000040h __Initialized data object.');
               Writeln('>>  o  000000080h __Uninitialized data object.');
               Writeln('>>  o  040000000h __Object must not be cached.');
               Writeln('>>  o  080000000h __Object is not pageable.');
               Writeln('>>  o  100000000h __Object is shared.');
               Writeln('>>  o  200000000h __Executable object.');
               Writeln('>>  o  400000000h __Readable object.');
               Writeln('>>  o  800000000h __Writeable object.');
               Writeln;
               Writeln('>>All other bits are reserved for future use and should be set to zero.');

        End;
     End;

     Writeln;
     Writeln('Press Any Key When Ready to DIE!');
     Readkey;

End;




Procedure GetObjectDetails;
Var
   zz1:char;
   kkk:integer;
{Start INSIDE Procedure}

Procedure GetCh;
Begin
     Write('Press [N] or Enter to continue, [D] for Details, Esc to Exit...');
     bb1:=true;
     While bb1 do
     Begin
          While Not Keypressed Do UpdateRunningLine;
          cc1:=Readkey;
          if cc1 in [#27,#13,' ','N','n','D','d'] then bb1:=false;
     end;
     if cc1=#13 then Begin
                          ClrScr;
                          Exit;
                     End;
     if cc1=#27 then Halt;
     if (cc1='D') or (cc1='d') Then GetObjectEntryDetails;
     end;

{End INSIDE Procedure}


Begin
     Writeln;
     ReadObjTable;
     Writeln('*Details to the Objects...');
     Write('>Objects Count [Objects_Cnt]              : ');
     WriteWord(PEHeader1.Objects_Cnt);
     Writeln(' or ',Lo(PEHeader1.Objects_Cnt)+Hi(PEHeader1.Objects_Cnt)*10,' Dec');
     For b:=0 to PEHeader1.Objects_Cnt-1 do
     Begin
                  ClrScr;
                  Writeln;
                  Writeln('Decoding Object Table N',b+1,'...');
                  Writeln('                     ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»');
                  Writeln('                     º   Entry N',b+1:3,' º');
                  Writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÐÄÄÄÄÄÄÄÄÄÄÄÄÄÄÐÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
                  Write('³                         ');
                  For a:=1 to 8 do write(chr(ObjTable1.Object_Name[a]));
                  Writeln('                      ³');
                  Writeln('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');

                  Write  ('Ã[1] Virtual Size           ³         ');
                  WriteDword(ObjTable1.Virt_Sz);
                  Writeln('          ³'); ;
                  Writeln('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
                  Write  ('Ã[2] RVA                    ³         ');
                  WriteDword(ObjTable1.RVA);
                  Writeln('          ³'); ;
                  Writeln('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
                  Write  ('Ã[3] Physical Size          ³         ');
                  WriteDword(ObjTable1.Phys_Sz);
                  Writeln('          ³'); ;
                  Writeln('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
                  Write  ('Ã[4] Physical Offset        ³         ');
                  WriteDword(ObjTable1.Phys_Offs);
                  Writeln('          ³'); ;
                  Writeln('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
                  Write  ('Ã[5] Flags                  ³         ');
                  WriteDword(ObjTable1.Object_Flags);
                  Writeln('          ³'); ;
                  Writeln('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');

                  Writeln;
                  GetCh;
                  JReadObjTable;
                  Writeln;
     End;
     JReadObjTable;
     ClrScr;
     Writeln;
     Writeln('Decoding Object Table FREE Space...');
     Writeln;
     Write('Here is FREE Space Header: [');
     kkk:=0;

     For a:=1 to 8 do
     Begin
          write(chr(ObjTable1.Object_Name[a]):1);
          kkk:=kkk+ObjTable1.Object_Name[a];
     End;

     Writeln(']');
     Writeln;

     If kkk=0 then
     Begin
          Writeln('You can easy use this free space to add Virus Object Table Entry');
          Writeln('and infect this file as you''ll wish.');
     End
     else
     Begin
          Writeln('WARNING! Free space Header contains non-zero characters! IT can');
          Writeln('NOT to be a free space after Object Table and you can damage ');
          Writeln('this file if You''ll infect it like BOZA...');
     End;
     Writeln;
     Writeln('Press Any Key for Menu...');
     ReadKey;

End;

Procedure GetHeaderDetails;
label zzz;
Var
   tt:byte;
Begin
     GetIndex;
     Writeln;
     Write('Enter Field Number [01..31]:  ');
zzz:
     Write(^h);
     bb1:=true;
     While bb1 do
     Begin
          DoUpdate;
          cc1:=Readkey;
          If (cc1=chr(13)) OR (cc1=chr(27)) then Begin
                                                      ClrScr;
                                                      exit;
                                                 End;
          If cc1 in ['0','1','2','3'] then bb1:=false;
     End;
     Write(cc1);
     bb1:=true;
     cc2:=Readkey;
     If not (cc2 in ['1','2','3','4','5','6','7','8','9','0']) then goto zzz;
     Writeln(cc2);
     tt:=(ord(cc1)-48)*10+ord(cc2)-48;

     Case tt of
          1 : Begin
                   Writeln;
                   Writeln('*Details for The CPU_Type...');
                   Write('>This Program will run on ');
                   case PEHeader1.CPU_Type of
                             0    :Write('unknown');
                             $014c:Write('80386+');
                             $014d:Write('80486+');
                             $014e:Write('80586+');
                             $0162:Write('__MIPS Mark I (R2000, R3000)');
                             $0163:Write('__MIPS Mark II (R6000)');
                             $0166:Write('__MIPS Mark III (R4000)');
                             else Write('UNKNOWN');
                   end;
                   Writeln(' System Processor or Compatible');
                   end;

          2 : Begin
                  GetObjectDetails;
              End;

          3 : Begin
                  Writeln;
                  Writeln('*Details on TIME/DATE Stamp...');
                  Writeln;
                  Writeln('>>This field used to store the time and date the file was');
                  Writeln('>>created or modified by the linker.');
                  Writeln('>>Unable to decrypt this field in this version');
                  Writeln('>>You Should get NEW VERSION of PE_READ !');
              End;
          4 : Begin
                  Writeln;
                  Writeln('*Details on NT HDR Size...');
                  Write('>The current value is                      : ');
                  WriteWord(PEHeader1.NT_Hdr_Sz);
                  Writeln;
                  Writeln;
                  Writeln('>>This is the number of remaining bytes in the NT header');
                  Writeln('>>that follow the FLAGS field.');
              End;
          5 : Begin
                  Writeln;
                  Writeln('*Details on FLAG Field...');
                  Write('>The current value is                      : ');
                  WriteWord(PEHeader1.Flags);
                  Writeln;
                  Writeln('>Decrypting FLAGS...');
                  If ((Lo(PEHeader1.Flags) OR $fd) XOR $fd)=$02 then Writeln('[]__Image is executable');
                  If ((Hi(PEHeader1.Flags) OR $df) XOR $df)=$20 then Writeln('[]__Library image');
                  If ((Hi(PEHeader1.Flags) OR $fd) XOR $fd)=$02 then Writeln('[]__Fixed');
                  If PEHeader1.Flags=0 Then Writeln('[]__Program Image');
              End;
          6 : Begin
                  Writeln;
                  Writeln('*Details on Linker version...No Details');
              End;
          7 : Begin
                  Writeln;
                  Writeln('*Details on Entrypoint RVA...');
                  Write('>The Current Entrypoint is                 :');
                  WriteDword(PEHeader1.Entr_Pnt_RVA);
                  Writeln;
                  Writeln;
                  Writeln('>>The Entrypoint relative virtual address.The address is relative to the Image ');
                  Writeln('>>Base. The address is the starting address for program images and the library ');
                  Writeln('>>initialization and library termination address for library images.');
              End;
          8 : Begin
                  Writeln;
                  Writeln('*Details on Image Virtual Base...');
                  Write('>The Current Value is                      :');
                  WriteDword(PEHeader1.Image_Base);
                  Writeln;
                  Writeln;
                  Writeln('>>The virtual base of the image. This will be the virtual address of the first ');
                  Writeln('>>byte of the file (Dos Header).  This must be a multiple of 64K.              ');
              End;
          9 : Begin
                  Writeln;
                  Writeln('*Details on Object Alignment...');
                  Write('>The Current Value is                      :');
                  WriteDword(PEHeader1.Object_Align);
                  Writeln(' [',PEHeader1.Object_Align.Lo*65536+PEHeader1.Object_Align.Hi,'  Dec]');
                  Writeln;
                  Writeln('>>The alignment of the objects. This must be a power of 2 between 512 and 256M ');
                  Writeln('>>inclusive. The default is 64K.');
              End;
          10: Begin
                  Writeln;
                  Writeln('*Details on File Alignment...');
                  Write('>The Current Value is                      :');
                  WriteDword(PEHeader1.File_Align);
                  Writeln(' [',PEHeader1.File_Align.Lo*65536+PEHeader1.File_Align.Hi,'  Dec]');
                  Writeln;
                  Writeln('>>Alignment factor used to align image pages.  The alignment factor (in bytes) ');
                  Writeln('>>used to align the base of  the image pages and to  determine the granularity ');
                  Writeln('>>of per-object  trailing zero pad.  Larger alignment  factors will  cost more ');
                  Writeln('>>file space; smaller  alignment factors will  impact demand load  performance,');
                  Writeln('>>perhaps  significantly. Of  the two, wasting  file space is preferable. This ');
                  Writeln('>>value should be a power of 2 between 512 and 64K inclusive.');
              End;
          11: Begin
                  Writeln;
                  Writeln('*Details on OS Version...');
                  Write('>The Current Value is                      :');
                  WriteWord(PEHeader1.OS_Major);Write(' ');
                  WriteWord(PEHeader1.OS_Minor);
                  Writeln(' [',PEHeader1.OS_Major,'.',PEHeader1.OS_Minor,']');
                  Writeln;
                  Writeln('>>OS version number required to run this image.');
              End;
          12: Begin
                  Writeln;
                  Writeln('*Details on USER Version...');
                  Write('>The Current Value is                      :');
                  WriteWord(PEHeader1.User_Major);Write(' ');
                  WriteWord(PEHeader1.User_Minor);
                  Writeln(' [',PEHeader1.User_Major,'.',PEHeader1.User_Minor,']');
                  Writeln;
                  Writeln('>>User version number required to run this image. This is useful for differen- ');
                  Writeln('>>tiating between revisions of images/dynamic linked libraries. The values are ');
                  Writeln('>>specified at link time by the user.');
              End;
          13: Begin
                  Writeln;
                  Writeln('*Details on Subsystem Version...');
                  Write('>The Current Value is                      :');
                  WriteWord(PEHeader1.Subsys_Major);
                  Write(' ');
                  WriteWord(PEHeader1.Subsys_Minor);
                  Writeln(' [',PEHeader1.Subsys_Major,'.',PEHeader1.Subsys_Minor,']');
                  Writeln;
                  Writeln('>>OS version number required to run this image.');
              End;
          14: Begin
                  Writeln;
                  Writeln('*Details on Image Size...');
                  Write('>The Current Value is                      :');
                  WriteDword(PEHeader1.Image_Sz);
                  Writeln(' [',PEHeader1.Image_Sz.Lo*65536+PEHeader1.Image_Sz.Hi,'  Dec]');
                  Writeln;
                  Writeln('>>The virtual size (in bytes) of the image. This includes all headers.  The to-');
                  Writeln('>>tal image size must be a multiple of Object Align.');
              End;
          15: Begin
                  Writeln;
                  Writeln('*Details on Total Header Size...');
                  Write('>The Current Value is                      :');
                  WriteDword(PEHeader1.Header_Sz);
                  Writeln(' [',PEHeader1.Header_Sz.Lo*65536+PEHeader1.Header_Sz.Hi,'  Dec]');
                  Writeln;
                  Writeln('>>Total header size. The combined size of the Dos Header, PE Header and Object ');
                  Writeln('>>Table.');
              End;
          16: Begin
                  Writeln;
                  Writeln('*Details on File Checksum [CRC]...');
                  Write('>The Current Value is                      :');
                  WriteDword(PEHeader1.File_CRC);
                  If (PEHeader1.File_CRC.Hi=PEHeader1.File_CRC.Lo) and
                     (PEHeader1.File_CRC.Hi=0) Then Writeln(' (Set by the Linker)')
                                  else Writeln;
                  Writeln;
                  Writeln('>>Checksum for entire file. Set to 0 by the linker.');
              End;
          17: Begin
                  Writeln;
                  Writeln('*Details on Required NT Subsystem...');
                  Write('>The Current Value is                      :');
                  WriteWord(PEHeader1.Subsystem);
                  Writeln;
                  Write('>Required NT Subsystem ');
                  Case PEHeader1.Subsystem of
                      $0000:Writeln('__unknown)');
                      $0001:Writeln('__Native)');
                      $0002:Writeln('__Windows GUI)');
                      $0003:Writeln('__Windows Character)');
                      $0005:Writeln('__OS/2 Character)');
                      $0007:Writeln('__Posix Character');
                      else Writeln('UNKNOWN VALUE IN THIS FIELD');
                  End;
                  Writeln;
                  Writeln('>>NT Subsystem required to run this image.');
                  Writeln('>>The values are:');
                  Writeln('>>    0000h __Unknown');
                  Writeln('>>    0001h __Native');
                  Writeln('>>    0002h __Windows GUI');
                  Writeln('>>    0003h __Windows Character');
                  Writeln('>>    0005h __OS/2 Character');
                  Writeln('>>    0007h __Posix Character');
                  Writeln;
              End;
          18: Begin
                  Writeln;
                  Writeln('*Details on DLL FLAGS special for loader...');
                  Write('>The Current Value is                      :');
                  WriteWord(PEHeader1.DLL_Flags);
                  Writeln;
                  Writeln('>Decrypting DLL Flags...');
                  If PEHeader1.DLL_Flags =0 then Writeln('[]__NO Flags set...');
                  If (Lo(PEHeader1.DLL_Flags) AND  1)=1 then Writeln('[]__Per-Process Library Initialization.');
                  If (Lo(PEHeader1.DLL_Flags) AND  2)=2 then Writeln('[]__Per-Process Library Termination.');
                  If (Lo(PEHeader1.DLL_Flags) AND  1)=1 then Writeln('[]__Per-Thread Library Initialization.');
                  If (Lo(PEHeader1.DLL_Flags) AND  1)=1 then Writeln('[]__Per-Thread Library Termination.');
                  Writeln;
                  Writeln('>>Indicates special loader requirements.');
                  Writeln('>>This flag has the following bit values:');
                  Writeln('>>    0001h __Per-Process Library Initialization.');
                  Writeln('>>    0002h __Per-Process Library Termination.');
                  Writeln('>>    0004h __Per-Thread Library Initialization.');
                  Writeln('>>    0008h __Per-Thread Library Termination.');
                  Writeln('>>All other bits are reserved for future use and should be set to zero.');
              End;
          19: Begin
                  Writeln;
                  Writeln('*Details on Stack Reserve|Commit Size...');
                  Write('>The Current Value is                      :');
                  WriteDword(PEHeader1.Stack_Rsrv_Sz);
                  Space(1);
                  WriteDword(PEHeader1.Stack_Cmmt_Sz);
                  Writeln;
                  Writeln;
                  Writeln('>>STACK RESERVE SIZE - Stack size needed for image. The memory is reserved, but');
                  Writeln('>>only the STACK COMMIT  SIZE  is committed.  The next page  of the stack  is a');
                  Writeln('>>''guarded page''.  When the application hits the guarded page, the guarded page');
                  Writeln('>>becomes valid, and the next page becomes the guarded page. This continues un-');
                  Writeln('>>til the RESERVE SIZE is reached.');
              End;
          20: Begin
                  Writeln;
                  Writeln('*Details on Heap Reserve|Commit Size...');
                  Write('>The Current Value is                      :');
                  WriteDword(PEHeader1.Heap_Rsrv_Sz);
                  Write(' ');
                  WriteDword(PEHeader1.Heap_Cmmt_Sz);
                  Writeln;
              End;
          21: Begin
                  Writeln;
                  Writeln('*Details on Size of the VA/SIZE array...');
                  Write('>The Current Value is                      :');
                  WriteDword(PEHeader1._Intrs_RVA_Sz);
                  Writeln;
                  Writeln;
                  Writeln('>>Indicates the size of the VA/SIZE array that follows.');
              End;





          else Writeln('No Detailed Help on This Point At Present Time. Sorry.');
          end;
          Writeln;
          Writeln('Press Any Key For Menu...');
          DoUpdate;
          ClrScr;
End;



Const
     RunningLine1:string='                                                                              PExe Decoder and'+
     ' Explainer'+
     '. Helps You to Understand and to Generate IDEA of _INFECTION_ Portable-Executable files. Copyright and left by Murph th'+
     'e Keeper, Murph uLtd., 1996.';
     RunningLine2:string=' It is FREEWARE version. May the force be with you, virmaker! SGWW Alive! 2 Rats Techno '+
     'Soft is [00l'+
     #$FA+#$F9+#09+'Cut'+#09+#$F9+#$FA+' Thank You for using _aLKANAFT_. RTFM Now!'+
     ' You Can send me any comments on working of my program to alex@matterhorn.dnttm.rssi.ru ';
     RunningLine3:string=#$FA+#$F9+#09+'Cut'+#09+#$F9+#$FA+' Special Thanx to [*] LovinGOD for his very infected voice [*] '+
     'VLAD for'+
     ' his Biztach {Boza} virus, _'+
     'First_ Assembler Virus Under Win95/NT [*] Micheal J. O''Leary for the PE-files detailed description '+
     '[*] And to Lord ASD Great Thanx for His Help ';
     RunningLine4:string=#$FA+#$F9+#09+'Cut'+#09+#$F9+#$FA+' Hi, AvirMakers! You can CRY, You can Fuck yourself Downstairs, '+
     'But you '+
     'Failed to Win in our WAR!'+
     ' All of you Will DIE anyway... YOU - DIE BY MY HAND! Fucking Hi to MS-SUXX! Thank You for Developing World-Wide OS! '+
     'Win''95 Must DIE!';
     RunningLine5:string=' Let''s spread _USER DEATH_! Anyway, Good User - DEAD User!'+
     ' We will fill The World with FEAR! >>WELL, ANYWAY, YOU ARE GOING TO DIE!<< '+#$FA+#$F9+#09+'Cut'+#09+#$F9+#$FA;
     RunningLine6:string=' Lets take Fun of MetallicA, SLAYER, HelloweeN, Iron Maiden, QUEEN, Gamma Ray, SEPULTURA! '+
     #$FA+#$F9+#09+'Cut'+#09+#$F9+#$FA;

     Cur_Pos:integer=1;
     Cur_line:byte=1;
Var
     s:string;
     jj,kk:integer;
     xx,yy:byte;

Function GetCurLine:string;
Begin
     Case Cur_line of
     1: GetCurLine:=RunningLine1;
     2: GetCurLine:=RunningLine2;
     3: GetCurLine:=RunningLine3;
     4: GetCurLine:=RunningLine4;
     5: GetCurLine:=RunningLine5;
     6: GetCurLine:=RunningLine6;
     end;
End;

Function GetNextLine:string;
Begin
     Case Cur_line of
     1: GetNextLine:=RunningLine2;
     2: GetNextLine:=RunningLine3;
     3: GetNextLine:=RunningLine4;
     4: GetNextLine:=RunningLine5;
     5: GetNextLine:=RunningLine6;
     6: GetNextLine:=Copy(RunningLine1,78,80);
     end;
End;

Procedure NextLine;
Begin
     Case Cur_line of
     1: Cur_line:=2;
     2: Cur_line:=3;
     3: Cur_line:=4;
     4: Cur_line:=5;
     5: Cur_line:=6;
     6: Begin
             Cur_line:=1;
             Cur_Pos:=80;
        End;
     end;
End;



Procedure DoUpdate;
Begin
     While Not Keypressed do UpdateRunningLine;
End;

Procedure UpdateRunningLine;
Begin
     TextParm(Green ,Black);
     xx:=WhereX;
     yy:=WhereY;
     if Cur_Pos>=Length(GetCurLine) then Begin
                                         Cur_Pos:=1;
                                         NextLine;
                                         end;
     s:=Copy(GetCurLine,Cur_pos,80);
     GotoXY(1,1);
     If Length(s)<80 then s:=s+Copy(GetNextLine,1,80-Length(s));
     Write(s);
     Inc(Cur_Pos);
     Delay(100);

     TextParm(White,0);
     GotoXY(xx,yy);
End;

Procedure GetIndex;
Begin
     ClrScr;
     Writeln;
     Writeln('Index of Header Entries:');
     Writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
     Writeln('³[01] CPU Type                          ³ [02] Number of entries in the OBJECT³');
     Writeln('³[03] Time/Date Stamp                   ³      table                          ³');
     Writeln('³[04] NT Header Size                    ³ [05] FLAG for the Image             ³');
     Writeln('³[06] DB Linker version                 ³ [07] Entrypoint RVA                 ³');
     Writeln('³[08] Image Virtual Base                ³ [09] Object Alignment               ³');
     Writeln('³[10] File Alignment                    ³ [11] OS Version                     ³');
     Writeln('³[12] User Version                      ³ [13] Subsystem Version              ³');
     Writeln('³[14] Image Size                        ³ [15] Total Header Size              ³');
     Writeln('³[16] File Checksum [CRC]               ³ [17] Required NT Subsystem          ³');
     Writeln('³[18] DLL FLAGS special for loader      ³ [19] Stack Reserve|Commit Size      ³');
     Writeln('³[20] Heap Reserve|Commit Size          ³ [21] Size of the RVA/SIZE array     ³');
     Writeln('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
     Writeln('³[22] Export Table RVA/Size             ³ [23] Import Table RVA/Size          ³');
     Writeln('³[24] Resource Table RVA/Size           ³ [25] Exception Table RVA/Size       ³');
     Writeln('³[26] Security Table RVA/Size           ³ [27] Fixup Table RVA/Size           ³');
     Writeln('³[28] Debug Table RVA/Size              ³ [29] Description : Image RVA/Total  ³');
     Writeln('³[30] Machine Specific RVA/Size         ³      Size                           ³');
     Writeln('³[31] TLS RVA/Size                      ³                                     ³');
     Writeln('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');

End;



Procedure GetCh;
Begin
     Write('Press [N] or Enter to continue, [M] for Menu, Esc to Exit...');
     bb1:=true;
     While bb1 do
     Begin
          While Not Keypressed Do UpdateRunningLine;
          cc1:=Readkey;
          if cc1 in [#27,#13,'N','n','M','m'] then bb1:=false;
     end;
     if cc1=#27 then Halt;
     if (cc1='M') or (cc1='m') Then Begin
                                         ClrScr;
                                         GetMenu;
                                    End;
end;

Procedure WritePEHeader;
Begin
     ClrScr;
     Writeln;
     Writeln('Decoding PE Header...');

     If (PEHeader1.Signature[1]<>'P') and
        (PEHeader1.Signature[2]<>'E') then
                                      begin
                                           writeln('Not PE-file');
                                           halt;
                                      end;

     Write('[1]  CPU Type                              : ');
     WriteWord(PEHeader1.CPU_Type);
     Write(' (');
     case PEHeader1.CPU_Type of
          0    :Writeln('__unknown)');
          $014c:Writeln('__80386)');
          $014d:Writeln('__80486)');
          $014e:Writeln('__80586 or Pentium)');
          $0162:Writeln('__MIPS Mark I (R2000, R3000)');
          $0163:Writeln('__MIPS Mark II (R6000)');
          $0166:Writeln('__MIPS Mark III (R4000)');
          else Writeln('UNKNOWN VALUE IN THIS FIELD)');
     end;

     Write('[2]  Number of entries in the OBJECT table : ');
     WriteWord(PEHeader1.Objects_Cnt);
     Writeln;

     Write('[3]  Time/Date Stamp                       : ');
     WriteDword(PEHeader1.Time_Date_Stamp);
     Writeln;

     Write('[4]  NT Header Size                        : ');
     WriteWord(PEHeader1.NT_Hdr_Sz);
     Writeln;

     Write('[5]  FLAG for the Image                    : ');
     WriteWord(PEHeader1.Flags);
     Writeln;
     Write('[6]  DB Linker version                     : ');

     WriteByte(PEHeader1.Lmajor);
     Write(' ');
     WriteByte(PEHeader1.Lminor);
     Writeln('     [',PEHeader1.Lmajor,'.',PEHeader1.LMinor,']');

     Write('[7]  Entrypoint RVA                        : ');
     WriteDword(PEHeader1.Entr_Pnt_RVA);
     Writeln;

     Write('[8]  Image Virtual Base                    : ');
     WriteDword(PEHeader1.Image_Base);
     Writeln;

     Write('[9]  Object Alignment                      : ');
     WriteDword(PEHeader1.Object_Align);
     Writeln('  [',PEHeader1.Object_Align.Lo*65536+PEHeader1.Object_Align.Hi,'  Dec]');

     Write('[10] File Alignment                        : ');
     WriteDword(PEHeader1.File_Align);
     Writeln('  [',PEHeader1.File_Align.Lo*65536+PEHeader1.File_Align.Hi,'  Dec]');

     Write('[11] OS Version                            : ');
     WriteWord(PEHeader1.OS_Major);Write(' ');
     WriteWord(PEHeader1.OS_Minor);
     Writeln(' [',PEHeader1.OS_Major,'.',PEHeader1.OS_Minor,']');

     Write('[12] User Version                          : ');
     WriteWord(PEHeader1.User_Major);
     Write(' ');
     WriteWord(PEHeader1.User_Minor);
     Writeln(' [',PEHeader1.User_Major,'.',PEHeader1.User_Minor,']');

     Write('[13] Subsystem Version                     : ');
     WriteWord(PEHeader1.Subsys_Major);
     Write(' ');
     WriteWord(PEHeader1.Subsys_Minor);
     Writeln(' [',PEHeader1.Subsys_Major,'.',PEHeader1.Subsys_Minor,']');

     Write('[14] Image Size                            : ');
     WriteDword(PEHeader1.Image_Sz);
     Writeln('  [',PEHeader1.Image_Sz.Lo*65536+PEHeader1.Image_Sz.Hi,'  Dec]');

     Write('[15] Total Header Size                     : ');
     WriteDword(PEHeader1.Header_Sz);
     Writeln('  [',PEHeader1.Header_Sz.Lo*65536+PEHeader1.Header_Sz.Hi,'  Dec]');

     Write('[16] File Checksum [CRC]                   : ');
     WriteDword(PEHeader1.File_CRC);
     If (PEHeader1.File_CRC.Hi=PEHeader1.File_CRC.Lo) and
        (PEHeader1.File_CRC.Hi=0) Then Writeln(' (Set by the Linker)')
                                  else Writeln;

     Write('[17] Required NT Subsystem                 : ');
     WriteWord(PEHeader1.Subsystem);
     Writeln;

     Write('[18] DLL FLAGS special for loader          : ');
     WriteWord(PEHeader1.DLL_Flags);
     Writeln;

     Write('[19] Stack Reserve|Commit Size             : ');
     WriteDword(PEHeader1.Stack_Rsrv_Sz);
     Space(1);
     WriteDword(PEHeader1.Stack_Cmmt_Sz);
     Writeln;

     Write('[20] Heap Reserve|Commit Size              : ');
     WriteDword(PEHeader1.Heap_Rsrv_Sz);
     Write(' ');
     WriteDword(PEHeader1.Heap_Cmmt_Sz);
     Writeln;

     Write('[21] Size of the RVA/SIZE array            : ');
     WriteDword(PEHeader1._Intrs_RVA_Sz);
     Writeln;
     Writeln;

     Getch;
     Writeln;

     Writeln('Decoding RVA/Sizes Table...');

     Write('[22] Export Table RVA/Size                  : ');
     WriteDword(PEHeader1.Exp_Tbl_RVA);
     Write(' / ');
     WriteDword(PEHeader1.Tot_Exp_DATA_Sz);
     Writeln;

     Write('[23] Import Table RVA/Size                  : ');
     WriteDword(PEHeader1.Imp_Tbl_RVA);
     Write(' / ');
     WriteDword(PEHeader1.Tot_Imp_DATA_Sz);
     Writeln;

     Write('[24] Resource Table RVA/Size                : ');
     WriteDword(PEHeader1.Res_Tbl_RVA);
     Write(' / ');
     WriteDword(PEHeader1.Tot_Res_DATA_Sz);
     Writeln;

     Write('[25] Exception Table RVA/Size               : ');
     WriteDword(PEHeader1.Exc_Tbl_RVA);
     Write(' / ');
     WriteDword(PEHeader1.Tot_Exc_DATA_Sz);
     Writeln;

     Write('[26] Security Table RVA/Size                : ');
     WriteDword(PEHeader1.Sec_Tbl_RVA);
     Write(' / ');
     WriteDword(PEHeader1.Tot_Sec_DATA_Sz);
     Writeln;

     Write('[27] Fixup Table RVA/Size                   : ');
     WriteDword(PEHeader1.Fxp_Tbl_RVA);
     Write(' / ');
     WriteDword(PEHeader1.Tot_Fxp_DATA_Sz);
     Writeln;

     Write('[28] Debug Table RVA/Size                   : ');
     WriteDword(PEHeader1.Dbg_Tbl_RVA);
     Write(' / ');
     WriteDword(PEHeader1.Tot_Dbg_Dirs);
     Writeln;

     Write('[29] Description : Image RVA/Total Size     : ');
     WriteDword(PEHeader1.Img_Dscr_RVA);
     Write(' / ');
     WriteDword(PEHeader1.Tot_Dscr_Sz);
     Writeln;

     Write('[30] Machine Specific RVA/Size              : ');
     WriteDword(PEHeader1.Mchn_Spc_RVA);
     Write(' / ');
     WriteDword(PEHeader1.Mchn_Spc_Sz);
     Writeln;

     Write('[31] TLS RVA/Size                           : ');
     WriteDword(PEHeader1.TLS_RVA);
     Write(' / ');
     WriteDword(PEHeader1.Tot_TLS_Sz);
     Writeln;


     Vspace(12);
     Writeln('Press Any Key For Menu...');
     DoUpdate;
     ClrScr;


end;

Procedure GetMenu;
Var
  bb1:boolean;
  cc1:char;
Begin
     ClrScr;
     Writeln;
     Writeln('Input File : ',paramstr(1));
{     Writeln;}
     Writeln('You Can Choice Item from Menu:');
     Writeln;
     Writeln('[1] Get Information on PE Header');
     Writeln('[2] Details On Some element of the Header');
     Writeln('[3] Decode Object Table');
{     Wrietln('[4]}
     Writeln('[4] Index of Elements');
     Writeln('[Esc] Immoral Exit to DOS');
     Writeln;
     Write('Your Choice:');

     bb1:=true;
     While bb1 do
     Begin
          DoUpdate;
          cc1:=Readkey;
          if cc1 in [#27,'1','2','3','4'] then bb1:=false else
             Begin
                  TextParm(Green+16,0);
                  GotoXY(13,WhereY);
                  Write('>>>Wrong Choice<<<');
             End;
          GotoXY(13,WhereY);
          Delay(20);
          Wspace(18);
     end;
     TextParm(White,0);
     if cc1=#27 then Halt;
     if cc1='1' then WritePEHeader;
     if cc1='2' then GetHeaderDetails;
     if cc1='3' then GetObjectDetails;
     if cc1='4' then Begin
                          GetIndex;
                          DoUpdate;
                     End;


end;







Procedure Main;
Begin
     TextParm(White,0);
     ClrScr;
     Writeln;
     Writeln('Portable Executable files (Alkanaft) Utility. Copyright (c) Murph uLtd. 1996');
     If Paramcount<>1 then
                          Begin
                               Writeln('Usage: PE_READ {FILENAME}');
                               Writeln('where {FILENAME} - PE COM/EXE/DLL/CPL/SCR/SYS and many other...');
                               halt;
                          end;
     Assign(infile,Paramstr(1));
     Reset(infile,1);
     If IOResult<>0 then Begin
                         Writeln('>>>Fatal<<<: Can''t open input file for reading');
                         exit;
                         end;
     ReadPEHeader;
     While TRue Do GetMenu;
End;

BEGIN
     main;
END.