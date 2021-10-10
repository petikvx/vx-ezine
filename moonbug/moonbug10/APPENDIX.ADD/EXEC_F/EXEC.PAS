{$S-}
{$M 1024,0,0}
unit exec;
interface
type TRegisters=record
     case byte of
          1:(BP,ES,DS,DI,SI,DX,CX,BX,AX,IP,CS,Flags:word);
          2:(Reserv1:array [0..4] of word; DL,DH,CL,CH,BL,BH,AL,AH:byte; Reserv2:array [0..1] of word; LFlags,HFlags:byte);
     end;
     UserProcType=procedure(var regs:TRegisters);
     PUserProcType=^UserProcType;
     HeadExeType=record
                       Sign,
                       PartPag,
                       PageCnt,
                       ReloCnt,
                       HdrSize,
                       MinMem,
                       MaxMem,
                       ReloSS,
                       ExeSP,
                       ChkSum,
                       ExeIP,
                       ReloCS,
                       TablOff,
                       Overlay:word;
end;

const ExeOK=0; NotEnMem=-1; BadExeHeader=-2; ExeNotFound=-3;

var VideoMode:byte;
    MyPSP,PSPSeg,EnvSeg,StartSeg,MyEnvSeg,EnvSize,HeadSize:word;
    ExecResult:shortint;
    Trace:boolean;
    OldTraceProc,EndProc:pointer;

procedure RunExe(var Exe);
procedure TerminateExe(var StackIP:word);
procedure ExecInit;
procedure RestoreDS;
procedure SetTrace(UTraceProc:PUserProcType);
procedure StopTrace;
procedure Execute(Path, CmdLine: string);

implementation
uses dos,memory;
var Vectors:array [byte] of pointer;
    CurPSP,MySP,ExitIP,ExitCS:word;
    UserTraceProc:UserProcType;
    DosExe:file;
    Load:boolean;
    PathSp,Cmd:string;

procedure SetDS;
interrupt;
assembler;
asm
   pop bp
   add sp,16
   ret
end;

procedure RestoreDS;
assembler;
asm
   call SetDS
end;

procedure TraceProc(Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP: Word);
interrupt;
var regs:TRegisters absolute BP;
    CurCS:word;
begin
     if Trace then begin
        asm
           mov CurCS,cs
        end;
        if CS>CurCS then UserTraceProc(regs);
        regs.HFlags:=regs.HFlags or 1;
     end else regs.HFlags:=regs.HFlags and 254;
end;

procedure SetTrace(UTraceProc:PUserProcType);
begin
     @UserTraceProc:=UTraceProc;
     setintvec(1,@TraceProc);
     Trace:=true;
end;

procedure StopTrace;
begin
     Trace:=false
end;

procedure Execute(Path, CmdLine: string);
var PHeadExe:^HeadExeType;
    PExe:pointer absolute PHeadExe;
begin
     assign(DosExe,Path);
{$I-}
     reset(DosExe,1);
{$I+}if (ioresult<>0) or (Path='') then begin
        ExecResult:=ExeNotFound;
        exit;
     end;
     PathSp:=fexpand(Path);
     Cmd:=CmdLine+#13;
     getmem(PHeadExe,sizeof(HeadExeType));
     blockread(DosExe,PHeadExe^,sizeof(HeadExeType));
     HeadSize:=PHeadExe^.HdrSize*16;
     seek(DosExe,0);
     freemem(PHeadExe,sizeof(HeadExeType));
     getmem(PExe,HeadSize);
     blockread(DosExe,PExe^,HeadSize);
     load:=true;
     RunExe(PExe^);
     load:=false;
     freemem(PExe,HeadSize);
     close(DosExe);
end;

procedure Terminate;
far;
assembler;
asm
   call RestoreDS
   mov sp,[MySP]
end;

procedure RestoreAll;
var Int:byte;
    IntVec:pointer;
begin
    for Int:=0 to 255 do begin
        getintvec(Int,IntVec);
        if (seg(IntVec^)>=CurPSP) and (IntVec<>Vectors[Int]) then
           if int<>$15 then setintvec(Int,Vectors[Int]);
    end;
    asm
       mov al,00110110b
       out 43h,al
       mov al,0FFh
       out 40h,al
       out 40h,al
       mov ah,0Fh
       int 10h
       cmp [VideoMode],al
       je @end
       mov al,[VideoMode]
       mov ah,0
       int 10h
    @end:
    end;
end;

procedure Start;
far;
assembler;
asm
   push es
   pop ds
   mov ss,dx
   mov sp,si
   push ax
   push bx
   pushf
   pop ax
   or  ah,ch
   push ax
   popf
   xor ax,ax
   mov bx,ax
   mov cx,ax
   mov dx,ax
   mov si,ax
   mov di,ax
   mov bp,ax
end;

procedure SetEnv(SrcSeg,DstSeg,EnvSize:word; Path:string);
assembler;
asm
   push es
   push ds
   mov ds,SrcSeg
   mov ax,DstSeg
   mov es,ax
   xor si,si
   xor di,di
   mov cx,EnvSize
   rep movsb
   lds si,Path
   mov cl,[si]
   xor ch,ch
   inc si
   rep movsb
   mov byte ptr es:[di],0
   pop ds
   dec ax
   mov es,ax
   mov dx,[PSPSeg]
   mov es:[1],dx
   pop es
end;

function GetEnvSize(TargetPSP:word):word;
assembler;
asm
   mov es,TargetPSP
   mov es,es:[2Ch]
   mov [MyEnvSeg],es
   xor bx,bx
   mov ax,1
@loop1:
   inc bx
   cmp es:[bx],ax
   jne @loop1
   add bx,2
   mov [EnvSize],bx
   add bx,128
   mov cl,4
   shr bx,cl
   inc bx
   mov ax,bx
end;

procedure SetCmdLn;
assembler;
asm
   mov al,Cmd.byte
   dec al
   mov es:[80h],al
   mov si,(offset Cmd)+1
   mov di,81h
   mov cl,al
   xor ch,ch
   rep movsb
end;

procedure ExecInit;
var Int:byte;
begin
     for Int:=0 to 255 do getintvec(Int,Vectors[Int]);
     asm
        mov ah,0Fh
        int 10h
        mov [VideoMode],al
        mov ah,62h
        int 21h
        mov [MyPSP],bx
     end;
end;

procedure RunExe(var Exe);
var CodeSizePar,SeekExe,ReloSeg,ItemOfs,ItemSeg,ItemNum,RSS,ESP,RCS,EIP,CurSeg,FSizePar,EnvSizePar:word;
    Int:byte;
    CodeSize,SizeLeft:longint;
    HeadExe:HeadExeType absolute Exe;

begin
     with HeadExe do begin
          asm
             push es
             push di
          end;
          if not (($5A in [lo(sign),hi(sign)]) and ($4D in [lo(sign),hi(sign)])) then begin
             ExecResult:=BadExeHeader;
             exit;
          end;
          SeekExe:=HdrSize*16;
          CodeSize:=longint((PageCnt-1))*512+PartPag-SeekExe;
          CodeSizePar:=CodeSize shr 4 + 1;
          ExecInit;
          EnvSizePar:=GetEnvSize(MyPSP);
          setmemtop(HeapPtr);
          asm
             pop di
             pop es
             mov bx,EnvSizePar
             mov ah,48h
             int 21h
             jc  @bad
             mov [EnvSeg],ax
             mov bx,es:[di][MaxMem]
             mov dx,CodeSizePar
             add dx,16
             add bx,dx
             jnc @cont
             mov bx,0FFFFh
          @cont:
             mov ah,48h
             int 21h
             jnc @ok
             mov ax,es:[di][MinMem]
             add ax,dx
             jc @bad
             cmp bx,ax
             jb @bad
             mov ah,48h
             int 21h
             jnc @ok
          @bad:
             mov [EnvSeg],0
             jmp @end
          @ok:
             mov [PSPSeg],ax
             push es
             mov dx,ax
             dec ax
             mov es,ax
             mov es:[1],dx
             pop es
          @end:
          end;
          if EnvSeg=0 then begin
             ExecResult:=NotEnMem;
             exit;
          end;
          ExecResult:=ExeOK;
          StartSeg:=PSPSeg+16;
          SetEnv(MyEnvSeg,EnvSeg,EnvSize,PathSp);
          if not load then asm
             push ds
             lds si,HeadExe
             add si,SeekExe
             mov es,[StartSeg]
             xor di,di
             mov cx,CodeSize.word
             rep movsb
             pop ds
          end else begin
              CurSeg:=StartSeg;
              SizeLeft:=CodeSize;
              while SizeLeft>65535 do begin
                    blockread(DosExe,ptr(CurSeg,0)^,65535);
                    blockread(DosExe,ptr(CurSeg,$FFFF)^,1);
                    dec(SizeLeft,65536);
                    inc(CurSeg,$1000);
              end;
              blockread(DosExe,ptr(CurSeg,0)^,SizeLeft);
          end;
          if ReloCnt>0 then for ItemNum:=0 to ReloCnt-1 do begin
             ItemOfs:=memw[seg(HeadExe):ofs(HeadExe)+TablOff+ItemNum*4];
             ItemSeg:=memw[seg(HeadExe):ofs(HeadExe)+TablOff+ItemNum*4+2];
             ReloSeg:=StartSeg+ItemSeg;
             inc(memw[ReloSeg:ItemOfs],StartSeg);
          end;
          RSS:=ReloSS;
          ESP:=ExeSP;
          RCS:=ReloCS;
          EIP:=ExeIP;
     end;
     asm
        push bp
        mov es,[MyPSP]
        mov ax,sp
        sub ax,4
        mov [MySP],ax
        mov dx,[PSPSeg]
        mov ah,55h
        int 21h
        mov bx,dx
        mov ah,50h
        int 21h
        sub word ptr es:[2Eh],4
        mov es,bx
        mov ax,[EnvSeg]
        mov es:[2Ch],ax
        mov ax,offset Terminate
        mov es:[0Ah],ax
        mov ax,seg Terminate
        mov es:[0Ch],ax
        call SetCmdLn
        mov dx,[StartSeg]
        add dx,RSS
        mov si,ESP
        mov bx,EIP
        mov ax,[StartSeg]
        add ax,RCS
        mov ch,[Trace]
        xor cl,cl
        call Start
        call RestoreDS
        pop bp
        mov es,[EnvSeg]
        mov ah,49h
        int 21h
        mov es,[PSPSeg]
        mov ah,49h
        int 21h
     end;
     setmemtop(HeapEnd);
end;

procedure Restor;
far;
assembler;
asm
   call RestoreDS
   call RestoreAll
   mov ax,[ExitCS]
   push ax
   mov ax,[ExitIP]
   push ax
end;

procedure KillMode; forward;
procedure BreakExe;
far;
assembler;
asm
   call KillMode
   {mov es,[CurPSP]
   mov ax,es:[0Ah]
   mov [ExitIP],ax
   mov ax,es:[0Ch]
   mov [ExitCS],ax
   mov word ptr es:[0Ah],offset Restor
   mov word ptr es:[0Ch],seg Restor}
   mov ax,4CFFh
   int 21h
end;

procedure KillMode;
assembler;
var LastMCB:word;
procedure NextMCB;
assembler;
asm
   mov ax,es:[3]
   inc ax
   mov bx,es
   add bx,ax
   mov es,bx
   pop bp
   ret
end;

asm
   call RestoreDS
   mov ah,62h
   int 21h
   mov [CurPSP],bx
   mov dx,bx                    {в dx текущий PSP}
   mov ah,52h
   int 21h                      {в es:[bx-2] cег первого mcb}
   mov es,es:[bx-2]             {в es его!}
   jmp @getPSP
@getMCB:
   cmp di,bx
   jz @otherMCB
   mov si,di
   mov di,bx
@otherMCB:
   call NextMCB
@getPSP:
   cmp byte ptr es:[0],4Dh      {- а mcb ли это?}
   jnz @end                     {- нет!}
   mov LastMCB,es
   mov bx,es:[1]                {- да, в bx PSP}
   mov ax,es
   mov es,bx                    {и в es тоже}
   cmp word ptr es:[0],$20CD
   mov es,ax
   jnz @otherMCB
   cmp bx,dx                    {не текущий ли он?}
   jb @getMCB
   jnz @end
   mov ax,[MyPSP]
   cmp di,ax
   jnz @upd
   mov di,[PSPSeg]
   xor ax,ax
   cmp di,ax
   jnz @upd
   mov di,si
@upd:
   mov es,dx
   mov ax,es:[16h]
   mov bx,[CurPSP]
   cmp bx,ax
   ja @wipe
   mov es:[16h],di
   mov ax,offset BreakExe
   mov es:[0Ah],ax
   mov ax,seg BreakExe
   mov es:[0Ch],ax
@wipe:
   mov es,LastMCB
   call NextMCB
   cmp byte ptr es:[0],4Dh
   jnz @unmap
   mov LastMCB,es
   mov ax,es:[1]
   cmp word ptr [CurPSP],ax
   jnz @unmap
   mov ax,es
   inc ax
   mov es,ax
   mov ah,49h
   int 21h
   jmp @wipe
@unmap:
   mov bx,[PSPSeg]
   xor ax,ax
   cmp bx,ax
   jz @end
   mov es,[CurPSP]
   mov ah,49h
   int 21h
@end:
   call RestoreAll
end;

procedure TerminateExe(var StackIP:word);
assembler;
asm
   les bx,StackIP
   mov ax,offset BreakExe
   mov es:[bx],ax
   add bx,2
   mov ax,seg BreakExe
   mov es:[bx],ax
end;

procedure ExecDone;
far;
begin
     ExitProc:=EndProc;
     if Trace then setintvec(1,OldTraceProc);
end;

begin
     EndProc:=ExitProc;
     ExitProc:=@ExecDone;
     getintvec(1,OldTraceProc);
end.
