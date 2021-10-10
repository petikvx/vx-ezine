unit Reg;
interface
type
    DWORD                                = LongWord;
    PFileTime                            = ^TFileTime;
   _FILETIME                             = record
    dwLowDateTime                        : DWORD;
    dwHighDateTime                       : DWORD;
  end;
    TFileTime                            = _FILETIME;
    FILETIME                             = _FILETIME;
    ACCESS_MASK                          = DWORD;
    REGSAM                               = ACCESS_MASK;
    PDWORD                               = ^DWORD;
    BOOL                                 = LongBool;
    PSecurityAttributes                  = ^TSecurityAttributes;
   _SECURITY_ATTRIBUTES                  = record
    nLength                              : DWORD;
    lpSecurityDescriptor                 : Pointer;
    bInheritHandle                       : BOOL;
  end;
  TSysLocale                             = packed record
    DefaultLCID                          : Integer;
    PriLangID                            : Integer;
    SubLangID                            : Integer;
    FarEast                              : Boolean;
    MiddleEast                           : Boolean;
  end;
    TSecurityAttributes                  = _SECURITY_ATTRIBUTES;
    SECURITY_ATTRIBUTES                  = _SECURITY_ATTRIBUTES;

   TRegKeyInfo = record
    NumSubKeys    : Integer;
    MaxSubKeyLen  : Integer;
    NumValues     : Integer;
    MaxValueLen   : Integer;
    MaxDataLen    : Integer;
    FileTime      : TFileTime;
  end;

  TRegDataType = (rdUnknown, rdString, rdExpandString, rdInteger, rdBinary);

  TRegDataInfo = record
    RegData: TRegDataType;
    DataSize: Integer;
  end;
     HKEY = type LongWord;
     PHKEY = ^HKEY;
  TRegistry = class(TObject)
  private
    FCurrentKey: HKEY;
    FRootKey: HKEY;
    FLazyWrite: Boolean;
    FCurrentPath: string;
    FCloseRootKey: Boolean;
    FAccess: LongWord;
    procedure SetRootKey(Value: HKEY);
  protected
    procedure ChangeKey(Value: HKey; const Path: string);
    function GetBaseKey(Relative: Boolean): HKey;
    function GetKey(const Key: string): HKEY;
    procedure PutData(const Name: string; Buffer: Pointer; BufSize: Integer; RegData: TRegDataType);
    procedure SetCurrentKey(Value: HKEY);
  public
    STRE:string;
    constructor Create; overload;
    constructor Create(AAccess: LongWord); overload;
    destructor Destroy; override;
    procedure CloseKey;
    function CreateKey(const Key: string): Boolean;
    function GetKeyInfo(var Value: TRegKeyInfo): Boolean;
    procedure GetKeyNames(Strings1: String);
    function LoadKey(const Key, FileName: string): Boolean;
    function OpenKey(const Key: string; CanCreate: Boolean): Boolean;
    function OpenKeyReadOnly(const Key: String): Boolean;
    procedure WriteString(const Name, Value: string);
    property CurrentKey: HKEY read FCurrentKey;
    property CurrentPath: string read FCurrentPath;
    property LazyWrite: Boolean read FLazyWrite write FLazyWrite;
    property RootKey: HKEY read FRootKey write SetRootKey;
    property Access: LongWord read FAccess write FAccess;
  end;


 TRegIniFile = class(TRegistry)
  private
    FFileName: string;
  public
    constructor Create(const FileName: string; AAccess: LongWord); overload;
    procedure WriteString(const Section, Ident, Value: String);
    procedure ReadSections(Strings: String);
  end;
const
  REG_SZ                      = 1;
  REG_EXPAND_SZ               = 2;
  REG_BINARY                  = 3;
  REG_DWORD                   = 4;
  REG_NONE                    = 0;
  HKEY_CURRENT_USER     = DWORD($80000001);
  STANDARD_RIGHTS_ALL      = $001F0000;
  KEY_QUERY_VALUE    = $0001;
  KEY_SET_VALUE      = $0002;
  KEY_CREATE_SUB_KEY = $0004;
  KEY_ENUMERATE_SUB_KEYS = $0008;
  KEY_NOTIFY         = $0010;
  KEY_CREATE_LINK    = $0020;
  SYNCHRONIZE = $00100000;
  READ_CONTROL             = $00020000;
  STANDARD_RIGHTS_READ     = READ_CONTROL;
  ///
  KEY_ALL_ACCESS = (STANDARD_RIGHTS_ALL or
                    KEY_QUERY_VALUE or
                    KEY_SET_VALUE or
                    KEY_CREATE_SUB_KEY or
                    KEY_ENUMERATE_SUB_KEYS or
                    KEY_NOTIFY or
                    KEY_CREATE_LINK) and not
                    SYNCHRONIZE;
//
   REG_OPTION_NON_VOLATILE = ($00000000);
   ERROR_SUCCESS = 0;
//
   KEY_READ = (STANDARD_RIGHTS_READ or
               KEY_QUERY_VALUE or
               KEY_ENUMERATE_SUB_KEYS or
               KEY_NOTIFY) and not
               SYNCHRONIZE;
//
    VER_PLATFORM_WIN32_NT = 2;

    advapi32  = 'advapi32.dll';

function     RegCloseKey(hKey:HKEY):Longint;
                         stdcall external advapi32 name 'RegCloseKey';
function     RegFlushKey(hKey:HKEY):Longint;
                         stdcall external advapi32 name 'RegFlushKey';
function    RegOpenKeyEx(hKey:HKEY;
                         lpSubKey:PChar;
                         ulOptions:DWORD;
                         samDesired:REGSAM;
                         var phkResult:HKEY):Longint;
                         stdcall;external advapi32 name 'RegOpenKeyExA';
function  RegCreateKeyEx(hKey:HKEY;
                         lpSubKey:PChar;
                         Reserved:DWORD;
                         lpClass:PChar;
                         dwOptions:DWORD;
                         samDesired:REGSAM;
                         lpSecurityAttributes:PSecurityAttributes; var
                         phkResult:HKEY;
                         lpdwDisposition:PDWORD):Longint;
                         stdcall;external advapi32 name 'RegCreateKeyExA';
function   RegSetValueEx(hKey:HKEY;
                         lpValueName:PChar;
                         Reserved:DWORD;
                         dwType:DWORD;
                         lpData:Pointer;
                         cbData:DWORD):Longint;
                         stdcall; external advapi32 name 'RegSetValueExA';
function RegQueryInfoKey(hKey:HKEY;
                         lpClass:PChar;
                         lpcbClass:PDWORD;
                         lpReserved:Pointer;
                         lpcSubKeys,
                         lpcbMaxSubKeyLen,
                         lpcbMaxClassLen,
                         lpcValues,
                         lpcbMaxValueNameLen,
                         lpcbMaxValueLen,
                         lpcbSecurityDescriptor:PDWORD;
                         lpftLastWriteTime:PFileTime):Longint;
                         stdcall;external advapi32 name 'RegQueryInfoKeyA';
function     RegEnumKeyEx(hKey:HKEY;
                         dwIndex:DWORD;
                         lpName:PChar;
                         var lpcbName:DWORD;
                         lpReserved:Pointer;
                         lpClass:PChar;
                         lpcbClass:PDWORD;
                         lpftLastWriteTime:PFileTime):Longint;
                         stdcall; external advapi32 name 'RegEnumKeyExA';
function      RegLoadKey(hKey:HKEY;
                         lpSubKey,
                         lpFile:PChar):Longint;
                         stdcall;external advapi32 name 'RegLoadKeyA';
implementation
function IsRelative(const Value: string): Boolean;
begin
  Result := not ((Value <> '') and (Value[1] = '\'));
end;

function RegDataToDataType(Value: TRegDataType): Integer;
begin
  case Value of
    rdString: Result := REG_SZ;
    rdExpandString: Result := REG_EXPAND_SZ;
    rdInteger: Result := REG_DWORD;
    rdBinary: Result := REG_BINARY;
  else
    Result := REG_NONE;
  end;
end;

function DataTypeToRegData(Value: Integer): TRegDataType;
begin
  if Value = REG_SZ then Result := rdString
  else if Value = REG_EXPAND_SZ then Result := rdExpandString
  else if Value = REG_DWORD then Result := rdInteger
  else if Value = REG_BINARY then Result := rdBinary
  else Result := rdUnknown;
end;

constructor TRegistry.Create;
begin
  RootKey := HKEY_CURRENT_USER;
  FAccess := KEY_ALL_ACCESS;
  LazyWrite := True;
end;

constructor TRegistry.Create(AAccess: LongWord);
begin
  Create;
  FAccess := AAccess;
end;

destructor TRegistry.Destroy;
begin
  CloseKey;
  inherited;
end;

procedure TRegistry.CloseKey;
begin
  if CurrentKey <> 0 then
  begin
    if LazyWrite then
      RegCloseKey(CurrentKey) else
      RegFlushKey(CurrentKey);
    FCurrentKey := 0;
    FCurrentPath := '';
  end;
end;

procedure TRegistry.SetRootKey(Value: HKEY);
begin
  if RootKey <> Value then
  begin
    if FCloseRootKey then
    begin
      RegCloseKey(RootKey);
      FCloseRootKey := False;
    end;
    FRootKey := Value;
    CloseKey;
  end;
end;

procedure TRegistry.ChangeKey(Value: HKey; const Path: string);
begin
  CloseKey;
  FCurrentKey := Value;
  FCurrentPath := Path;
end;

function TRegistry.GetBaseKey(Relative: Boolean): HKey;
begin
  if (CurrentKey = 0) or not Relative then
    Result := RootKey else
    Result := CurrentKey;
end;

procedure TRegistry.SetCurrentKey(Value: HKEY);
begin
  FCurrentKey := Value;
end;

function TRegistry.CreateKey(const Key: string): Boolean;
var
  TempKey: HKey;
  S: string;
  Disposition: Integer;
  Relative: Boolean;
begin
  TempKey := 0;
  S := Key;
  Relative := IsRelative(S);
  if not Relative then Delete(S, 1, 1);
  Result := RegCreateKeyEx(GetBaseKey(Relative), PChar(S), 0, nil,
    REG_OPTION_NON_VOLATILE, KEY_ALL_ACCESS, nil, TempKey, @Disposition) = ERROR_SUCCESS;
  if Result then RegCloseKey(TempKey)
end;

function TRegistry.OpenKey(const Key: String; Cancreate: boolean): Boolean;
var
  TempKey: HKey;
  S: string;
  Disposition: Integer;
  Relative: Boolean;
begin
  S := Key;
  Relative := IsRelative(S);

  if not Relative then Delete(S, 1, 1);
  TempKey := 0;
  if not CanCreate or (S = '') then
  begin
    Result := RegOpenKeyEx(GetBaseKey(Relative), PChar(S), 0,
      FAccess, TempKey) = ERROR_SUCCESS;
  end else
    Result := RegCreateKeyEx(GetBaseKey(Relative), PChar(S), 0, nil,
      REG_OPTION_NON_VOLATILE, FAccess, nil, TempKey, @Disposition) = ERROR_SUCCESS;
  if Result then
  begin
    if (CurrentKey <> 0) and Relative then S := CurrentPath + '\' + S;
    ChangeKey(TempKey, S);
  end;
end;

function TRegistry.OpenKeyReadOnly(const Key: String): Boolean;
var
  TempKey: HKey;
  S: string;
  Relative: Boolean;
begin
  S := Key;
  Relative := IsRelative(S);

  if not Relative then Delete(S, 1, 1);
  TempKey := 0;
  Result := RegOpenKeyEx(GetBaseKey(Relative), PChar(S), 0,
      KEY_READ, TempKey) = ERROR_SUCCESS;
  if Result then
  begin
    FAccess := KEY_READ;
    if (CurrentKey <> 0) and Relative then S := CurrentPath + '\' + S;
    ChangeKey(TempKey, S);
  end
  else
  begin
    Result := RegOpenKeyEx(GetBaseKey(Relative), PChar(S), 0,
        STANDARD_RIGHTS_READ or KEY_QUERY_VALUE or KEY_ENUMERATE_SUB_KEYS,
        TempKey) = ERROR_SUCCESS;
    if Result then
    begin
      FAccess := STANDARD_RIGHTS_READ or KEY_QUERY_VALUE or KEY_ENUMERATE_SUB_KEYS;
      if (CurrentKey <> 0) and Relative then S := CurrentPath + '\' + S;
      ChangeKey(TempKey, S);
    end
    else
    begin
      Result := RegOpenKeyEx(GetBaseKey(Relative), PChar(S), 0,
          KEY_QUERY_VALUE, TempKey) = ERROR_SUCCESS;
      if Result then
      begin
        FAccess := KEY_QUERY_VALUE;
        if (CurrentKey <> 0) and Relative then S := CurrentPath + '\' + S;
        ChangeKey(TempKey, S);
      end
    end;
  end
end;

function TRegistry.GetKeyInfo(var Value: TRegKeyInfo): Boolean;
const
  Win32Platform: Integer = 0;
var SysLocale:tSysLocale;
begin
  FillChar(Value, SizeOf(TRegKeyInfo), 0);
  Result := RegQueryInfoKey(CurrentKey, nil, nil, nil, @Value.NumSubKeys,
    @Value.MaxSubKeyLen, nil, @Value.NumValues, @Value.MaxValueLen,
    @Value.MaxDataLen, nil,@Value.FileTime) = ERROR_SUCCESS;
  if SysLocale.FarEast and (Win32Platform = VER_PLATFORM_WIN32_NT) then
    with Value do
    begin
      Inc(MaxSubKeyLen, MaxSubKeyLen);
      Inc(MaxValueLen, MaxValueLen);
    end;
end;

procedure TRegistry.GetKeyNames(Strings1: String);
var
  Len: DWORD;
  I: Integer;
  Info: TRegKeyInfo;
  S: string;
begin
  if GetKeyInfo(Info) then
  begin
    SetString(S, nil, Info.MaxSubKeyLen + 1);
    for I := 0 to Info.NumSubKeys - 1 do
    begin
      Len := Info.MaxSubKeyLen + 1;
      RegEnumKeyEx(CurrentKey, I, PChar(S), Len, nil, nil, nil,nil);
    strings1:=strings1+pchar(s);
    end;
  end;
  STRE:=strings1;
end;

procedure TRegistry.WriteString(const Name, Value: string);
begin
  PutData(Name, PChar(Value), Length(Value)+1, rdString);
end;

procedure TRegistry.PutData(const Name: string; Buffer: Pointer;
  BufSize: Integer; RegData: TRegDataType);
var
  DataType: Integer;
begin
  DataType := RegDataToDataType(RegData);
  if RegSetValueEx(CurrentKey, PChar(Name), 0, DataType, Buffer,
    BufSize) <> ERROR_SUCCESS then
end;

function TRegistry.GetKey(const Key: string): HKEY;
var
  S: string;
  Relative: Boolean;
begin
  S := Key;
  Relative := IsRelative(S);
  if not Relative then Delete(S, 1, 1);
  Result := 0;
  RegOpenKeyEx(GetBaseKey(Relative), PChar(S), 0, FAccess, Result);
end;

function TRegistry.LoadKey(const Key, FileName: string): Boolean;
var
  S: string;
begin
  S := Key;
  if not IsRelative(S) then Delete(S, 1, 1);
  Result := RegLoadKey(RootKey, PChar(S), PChar(FileName)) = ERROR_SUCCESS;
end;
constructor TRegIniFile.Create(const FileName: string; AAccess: LongWord);
begin
  inherited Create(AAccess);
  FFilename := FileName;
  OpenKey(FileName, True);
end;

procedure TRegIniFile.WriteString(const Section, Ident, Value: String);
var
  Key, OldKey: HKEY;
begin
  CreateKey(Section);
  Key := GetKey(Section);
  if Key <> 0 then
  try
    OldKey := CurrentKey;
    SetCurrentKey(Key);
    try
      inherited WriteString(Ident, Value);
    finally
      SetCurrentKey(OldKey);
    end;
  finally
    RegCloseKey(Key);
  end;
end;

procedure TRegIniFile.ReadSections(Strings: String);
begin
  GetKeyNames(Strings);
end;

end.



