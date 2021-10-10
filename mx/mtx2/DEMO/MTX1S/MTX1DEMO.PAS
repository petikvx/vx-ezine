
{ MATRiX #1 DEMO  (x) 2000 Z0MBiE  }
{ compiler: TMT Pascal 2.11        }

{$OPTFRM+,OPT+,OPTREG+,A+,R-,I-,P-,T-,X+,B-,CC+,Q-,V-,S-,W+,D-,L-}

{$DEFINE USEGRAPH}      { use pascal graphics and /pas option }

{$DEFINE USEPOINTS}     { draw points }
{$DEFINE USELINES}      { draw lines  }
{$DEFINE USEPLANES}     { draw planes }
{$DEFINE USETEXT}       { draw text   }
{$DEFINE USEBMP}        { draw background bitmap }
{$DEFINE USEFLAME}      { draw flame as background }

uses crt,
{$IFDEF USEGRAPH}
     graph,
{$ENDIF}
     zentimer;

{$IFDEF USETEXT}
{$I FONT.INC}
{$ENDIF}

{$IFDEF USEBMP}
{$I BKGR.INC}
{$ENDIF}

const
  C_STACKSIZE           = 8192;
  C_MAXANGLE            = 2048;
  C_SHRSC               = 8;
  C_MAXSC               = 1 shl C_SHRSC;
  C_SHRZ                = 18;
  C_MAXX                = 320;
  C_MAXY                = 200;
  C_CENTERX             = C_MAXX div 2;
  C_CENTERY             = C_MAXY div 2;
  C_FPS                 = 30;
  C_VIDEOPTR            = $A0000;

  C_PAL0                = 0;
  C_PAL1                = 128;
  C_PAL2                = 128+64;

  C_point_max           = 8192;
  C_line_max            = 8192;
  C_plane_max           = 8192;

const
  dd_C_MAXANGLE_div2 : longint = C_MAXANGLE div 2;
  dd_C_MAXSC         : longint = C_MAXSC;

  OPT_NOFIXFPS : longint = 0;
  OPT_CONT     : longint = 0;
  OPT_VGA      : longint = 1;

  look_z : longint = 0;

  angle_x : longint = 0;
  angle_y : longint = 0;
  angle_z : longint = 0;

var
  cos_x, cos_y, cos_z,
  sin_x, sin_y, sin_z : longint;

  draw_type, bkgr_type, flame_type : longint;

  point_max,
  plane_max,
  line_max : longint;

  point3_x, point2_x : array[0..C_point_max-1] of longint;
  point3_y, point2_y : array[0..C_point_max-1] of longint;
  point3_z, point2_z : array[0..C_point_max-1] of longint;

  plane_p1,
  plane_p2,
  plane_p3,
  plane_z,
  index   : array[0..C_plane_max-1] of longint;

  line_p1, line_p2 : array[0..C_line_max-1] of longint;

  buf,bmp : array[0..C_MAXY-1+8,0..C_MAXX-1] of byte;

procedure initgraph;
  begin
{$IFDEF USEGRAPH}
    if OPT_VGA=1 then begin
{$ENDIF}
      asm
        mov     ax, 0013h
        int     10h
      end;
{$IFDEF USEGRAPH}
    end else begin
      setsvgamode(640,480,8,LFBOrBanked);
    end;
{$ENDIF}
  end;

procedure donegraph;
  begin
{$IFDEF USEGRAPH}
    if OPT_VGA=1 then begin
{$ENDIF}
      asm
        mov     ax, 0003h
        int     10h
      end;
{$IFDEF USEGRAPH}
    end else begin
      closegraph;
    end;
{$ENDIF}
  end;

const
  page:longint=0;

procedure clearscreen;
  begin
{$IFDEF USEGRAPH}
   if OPT_VGA=0 then begin

      page:=1-page;
      setactivepage(page);
      clearpage;

    end else begin
{$ENDIF}
      asm
        mov     edi, offset buf
        mov     ecx, C_MAXX*C_MAXY/4
{$IFDEF USEBMP}
        mov     esi, offset bmp
        rep     movsd
{$ELSE}
        xor     eax, eax
        rep     stosd
{$ENDIF}
      end;
{$IFDEF USEGRAPH}
    end;
{$ENDIF}
  end;

procedure onscreen;
  begin
{$IFDEF USEGRAPH}
    if OPT_VGA=1 then
    begin
{$ENDIF}
      asm
        mov     esi, offset buf
        mov     edi, C_VIDEOPTR
        mov     ecx, C_MAXX*C_MAXY/4
        rep     movsd
      end;
{$IFDEF USEGRAPH}
    end else begin
      setvisualpage(page,true);
    end;
{$ENDIF}
  end;

procedure calc_angle; assembler;
  asm
    xor     ebx, ebx

@@1:and     angle_x[ebx], C_MAXANGLE-1

    fild    angle_x[ebx]
    fldpi
    fmul
    fild    dd_C_MAXANGLE_div2
    fdiv
    fsincos
    fild    dd_C_MAXSC
    fmul
    fistp   cos_x[ebx]
    fild    dd_C_MAXSC
    fmul
    fistp   sin_x[ebx]

    add     ebx, 4
    cmp     ebx, 3*4
    jb      @@1
  end;

procedure calc_points; assembler;
  asm
    mov     ebx, point_max
    shl     ebx, 2

@@1:sub     ebx, 4

    mov     eax, dword ptr point3_x[ebx]
    mov     ecx, dword ptr point3_y[ebx]
    mov     edx, dword ptr point3_z[ebx]

    mov     esi, ecx
    imul    esi, cos_x
    mov     edi, edx
    imul    edi, sin_x
    add     esi, edi
    sar     esi, C_SHRSC
    imul    ecx, sin_x
    imul    edx, cos_x
    sub     edx, ecx
    sar     edx, C_SHRSC
    mov     ecx, esi

    mov     esi, eax
    imul    esi, cos_y
    mov     edi, edx
    imul    edi, sin_y
    add     esi, edi
    sar     esi, C_SHRSC
    imul    eax, sin_y
    imul    edx, cos_y
    sub     edx, eax
    sar     edx, C_SHRSC
    mov     eax, esi

    mov     esi, eax
    imul    esi, cos_z
    mov     edi, ecx
    imul    edi, sin_z
    add     esi, edi
    sar     esi, C_SHRSC
    imul    eax, sin_z
    imul    ecx, cos_z
    sub     ecx, eax
    sar     ecx, C_SHRSC
    mov     eax, esi

    mov     dword ptr point2_z[ebx], edx

    add     edx, look_z
    imul    eax, edx
    imul    ecx, edx
    sar     eax, C_SHRZ
    sar     ecx, C_SHRZ

    add     eax, C_CENTERX
    add     ecx, C_CENTERY

    mov     dword ptr point2_x[ebx], eax
    mov     dword ptr point2_y[ebx], ecx

    or      ebx, ebx
    jnz     @@1
end;

procedure draw_line(x1,y1,x2,y2,color : longint); assembler;
  asm
    mov     eax, x1
    mov     ebx, y1
    mov     ecx, x2
    mov     edx, y2

    cmp     eax, C_MAXX
    jae     @@o
    cmp     ebx, C_MAXY
    jae     @@o
    cmp     ecx, C_MAXX
    jae     @@o
    cmp     edx, C_MAXY
    jae     @@o

    mov     ecx, 1
    mov     eax, x2
    sub     eax, x1
    jl      @@1
    jg      @@2
    dec     ecx
@@1:neg     eax
    neg     ecx
@@2:mov     dword ptr @@q - 4, eax
    mov     dword ptr @@i - 4, ecx

    mov     ecx, 1
    mov     ebx, y2
    sub     ebx, y1
    jl      @@3
    jg      @@4
    dec     ecx
@@3:neg     ebx
    neg     ecx
@@4:mov     dword ptr @@w - 4, ebx
    imul    ecx, C_MAXX
    mov     dword ptr @@j - 4, ecx

    sub     ebx, eax
    sbb     ecx, ecx
    xor     ecx, -1
    and     ecx, ebx
    add     ecx, eax

    mov     edx, ecx
    mov     esi, x1
    mov     edi, y1
    imul    edi, C_MAXX

    mov     eax, color
    mov     byte ptr @@k - 1, al

{-$DEFINE X1}

{$IFDEF X1}
    mov     dword ptr @@u-4, esp
    mov     dword ptr @@y-4, ebp
{$ENDIF}

    xor     eax, eax
    xor     ebx, ebx

@@cycle:
    mov     byte ptr buf[esi+edi], 12h
@@k:

{$IFDEF X1}
    add     eax, 12345678h
@@q:cmp     ecx, eax
    sbb     ebp, ebp
    mov     esp, ebp
    and     ebp, ecx
    and     esp, 12345678h
@@i:sub     eax, ebp
    add     esi, esp

    add     ebx, 12345678h
@@w:cmp     ecx, ebx
    sbb     ebp, ebp
    mov     esp, ebp
    and     ebp, ecx
    and     esp, 12345678h
@@j:sub     ebx, ebp
    add     edi, esp
{$ELSE}
    add     eax, 12345678h
@@q:cmp     eax, ecx
    jb      @@i
    sub     eax, ecx
    add     esi, 12345678h
@@i:

    add     ebx, 12345678h
@@w:cmp     ebx, ecx
    jb      @@j
    sub     ebx, ecx
    add     edi, 12345678h
@@j:
{$ENDIF}

    dec     edx
    jge     @@cycle

{$IFDEF X1}
    mov     esp, 12345678h
@@u:mov     ebp, 12345678h
@@y:
{$ENDIF}

@@o:
  end;

procedure draw_point(x,y,color : longint); assembler;
  asm
    mov     eax, y
    cmp     eax, C_MAXY
    jae     @@exit
    mov     ebx, x
    mov     ecx, C_MAXX
    cmp     ebx, ecx
    jae     @@exit
    imul    eax, ecx
    add     ebx, eax

    mov     eax, color
    mov     ah, al
    mov     ecx, eax
    shl     ecx, 16
    or      eax, ecx

    mov     dword ptr buf[ebx], eax
    mov     dword ptr buf[ebx+320], eax
    mov     dword ptr buf[ebx+2*320], eax

    mov     byte ptr bmp[ebx], 110

@@exit:
  end;

procedure draw_plane3(x1,y1,x2,y2,x3,y3,color:longint);
  var
    rv1, rv2 : longint;
  asm

    mov     eax, x1
    mov     ebx, y1
    mov     ecx, x2
    mov     edx, y2
    mov     esi, x3
    mov     edi, y3

    cmp     eax, C_MAXX
    jae     @@exit
    cmp     ebx, C_MAXY
    jae     @@exit
    cmp     ecx, C_MAXX
    jae     @@exit
    cmp     edx, C_MAXY
    jae     @@exit
    cmp     esi, C_MAXX
    jae     @@exit
    cmp     edi, C_MAXY
    jae     @@exit

    cmp     edx, edi
    jle     @@1
    xchg    ecx, esi
    xchg    edx, edi
@@1:

    cmp     ebx, edx
    jle     @@2
    xchg    eax, ecx
    xchg    ebx, edx
@@2:

    cmp     edx, edi
    jle     @@3
    xchg    ecx, esi
    xchg    edx, edi
@@3:

    mov     x1, eax
    mov     y1, ebx
    mov     x2, ecx
    mov     y2, edx
    mov     x3, esi
    mov     y3, edi

    mov     esi, y1
    imul    esi, C_MAXX
    add     esi, x1
    mov     edx, esi

    mov     eax, y3
    sub     eax, y1
    inc     eax
    mov     dword ptr @@dey1-4, eax
    mov     rv1, eax

    mov     eax, y2
    sub     eax, y1
    inc     eax
    mov     dword ptr @@dey2-4, eax
    mov     rv2, eax

    mov     ebx, 1
    mov     eax, x3
    sub     eax, x1
    jge     @@skipdxneg1
    neg     eax
    neg     ebx
@@skipdxneg1:
    inc     eax
    mov     dword ptr @@dex1-4, eax
    mov     dword ptr @@if1-4, ebx

    mov     ebx, 1
    mov     eax, x2
    sub     eax, x1
    jge     @@skipdxneg2
    neg     eax
    neg     ebx
@@skipdxneg2:
    inc     eax
    mov     dword ptr @@dex2-4, eax
    mov     dword ptr @@if2-4, ebx

    call    @@drawloop

    mov     eax, y3
    sub     eax, y2
    inc     eax
    mov     dword ptr @@dey2-4, eax
    mov     rv2, eax

    mov     ebx, 1
    mov     eax, x3
    sub     eax, x2
    jnc     @@dx2pos
    neg     eax
    neg     ebx
@@dx2pos:
    inc     eax
    mov     dword ptr @@dex2-4, eax
    mov     dword ptr @@if2-4, ebx

    call    @@drawloop

    jmp     @@exit

@@drawloop:
    mov     eax, color
    mov     ah, al
    mov     ebx, eax
    shl     ebx, 16
    or      eax, ebx

    mov     ebx, dword ptr @@dey2-4

    mov     dword ptr @@esp0-4, esp
    mov     dword ptr @@ebp0-4, ebp

    mov     esp, rv1
    mov     ebp, rv2

@@drawloop1:

    mov     edi, edx
    mov     ecx, esi
    cmp     ecx, edi
    ja      @@dontswap1
    xchg    ecx, edi
@@dontswap1:
    sub     ecx, edi
   {inc     ecx}
    add     edi, offset buf
    shr     ecx, 1
    jnc     @@q1
    stosb
@@q1:
    shr     ecx, 1
    jnc     @@q2
    stosw
@@q2:
    rep     stosd

    sub     esp, 12345678h
@@dex1:
    jg      @@donothing1
@@dosomething1:
    add     edx, 12345678h
@@if1:
    add     esp, 12345678h
@@dey1:
    jle     @@dosomething1
@@donothing1:
    add     edx, C_MAXX

    sub     ebp, 12345678h
@@dex2:
    jg      @@donothing2
@@dosomething2:
    add     esi, 12345678h
@@if2:
    add     ebp, 12345678h
@@dey2:
    jle     @@dosomething2
@@donothing2:
    add     esi, C_MAXX

    dec     ebx
    jnz     @@drawloop1

    mov     esp, 12345678h
@@esp0:
    mov     ebp, 12345678h
@@ebp0:

    db      0C3h {retn}

@@exit:
  end;

const
  min_z : longint = $7FFFFFFF;
  max_z : longint = $80000000;
var
  delt_z : longint;

procedure calc_minmax;
  var
    i,z:longint;
  begin
    for i := 0 to point_max-1 do
    begin
      z := point2_z[i];
      if min_z>z then min_z:=z;
      if max_z<z then max_z:=z;
    end;
    delt_z := max_z - min_z;
  end;

procedure sortplanes;
  procedure sort(l,r:longint);
    var
      i,j,x,t:longint;
    begin
      i:=l;
      j:=r;
      x:=(l+r) div 2;
      repeat
        while plane_z[index[i]] < plane_z[index[x]] do inc(i);
        while plane_z[index[x]] < plane_z[index[j]] do dec(j);
        if i<=j then
        begin
          if x=i then x:=j else if x=j then x:=i;
          t:=index[i];
          index[i]:=index[j];
          index[j]:=t;
          inc(i);
          dec(j);
        end;
      until i>j;
      if l<j then sort(l,j);
      if i<r then sort(i,r);
    end;
  var
    i,z : longint;
  begin
    for i := 0 to plane_max-1 do
    begin
      index[i] := i;
      z := (point2_z[ plane_p1[i] ] +
            point2_z[ plane_p2[i] ] +
            point2_z[ plane_p3[i] ]) div 3;
      plane_z[i] := z;
    end;
    sort(0,plane_max-1);
  end;

procedure draw;
  var
    i,j,z,x,y : longint;
    vert : array[1..3] of record X,Y:longint; end;
  begin

    if draw_type=1 then
    for i := 0 to point_max-1 do
    begin
      z:=C_PAL1+((point2_z[i]-min_z) * 63) div delt_z;
      x:=point2_x[i];
      y:=point2_y[i];
{$IFDEF USEGRAPH}
      if OPT_VGA=1 then begin
{$ENDIF}
        draw_point(x,y,z);
{$IFDEF USEGRAPH}
      end else begin
        x:=x shl 1;
        y:=y shl 1+40;
        putpixel(x,y,z);
        putpixel(x+1,y,z);
        putpixel(x,y+1,z);
        putpixel(x+1,y+1,z);
      end;
{$ENDIF}
    end;

    if draw_type=2 then
    for i := 0 to line_max-1 do
    begin
      z:=(point2_z[ line_p1[i] ] +
          point2_z[ line_p2[i] ]) shr 1;
      z:=C_PAL1+((z-min_z) * 63) div delt_z;
{$IFDEF USEGRAPH}
      if OPT_VGA=1 then begin
{$ENDIF}
        draw_line(point2_x[ line_p1[i] ], point2_y[ line_p1[i] ],
                  point2_x[ line_p2[i] ], point2_y[ line_p2[i] ], z);
{$IFDEF USEGRAPH}
      end else begin
        setcolor(z);
        line(point2_x[ line_p1[i] ] shl 1, point2_y[ line_p1[i] ] shl 1+40,
             point2_x[ line_p2[i] ] shl 1, point2_y[ line_p2[i] ] shl 1+40);
      end;
{$ENDIF}
    end;

    if draw_type=3 then
    for i := 0 to plane_max-1 do
    begin
      j:=index[i];
      z:=C_PAL1+((plane_z[j]-min_z) * 63) div delt_z;
{$IFDEF USEGRAPH}
      if OPT_VGA=1 then begin
{$ENDIF}
        draw_plane3(point2_x[ plane_p1[j] ], point2_y[ plane_p1[j] ],
                    point2_x[ plane_p2[j] ], point2_y[ plane_p2[j] ],
                    point2_x[ plane_p3[j] ], point2_y[ plane_p3[j] ],
                    z);
{$IFDEF USEGRAPH}
      end else begin
        setfillcolor(z);
        vert[1].x:=point2_x[ plane_p1[j] ] shl 1;
        vert[1].y:=point2_y[ plane_p1[j] ] shl 1+40;
        vert[2].x:=point2_x[ plane_p2[j] ] shl 1;
        vert[2].y:=point2_y[ plane_p2[j] ] shl 1+40;
        vert[3].x:=point2_x[ plane_p3[j] ] shl 1;
        vert[3].y:=point2_y[ plane_p3[j] ] shl 1+40;
        fillpoly(3, vert);
      end;
{$ENDIF}
    end;

  end;

function addpoint(x,y,z:longint):longint;
  var
    l:longint;
  begin
    for l:=0 to point_max-1 do
    if point3_x[l]=x then
    if point3_y[l]=y then
    if point3_z[l]=z then
    begin
      addpoint:=l;
      exit;
    end;
    point3_x[point_max]:=x;
    point3_y[point_max]:=y;
    point3_z[point_max]:=z;
    addpoint:=point_max;
    inc(point_max);
  end;

procedure addline(p1,p2:longint);
  var
    l:longint;
  begin
    for l:=0 to line_max-1 do
    if ((line_p1[l]=p1) and (line_p2[l]=p2)) or
       ((line_p1[l]=p2) and (line_p2[l]=p1)) then
      exit;
    line_p1[line_max]:=p1;
    line_p2[line_max]:=p2;
    inc(line_max);
  end;

procedure addplane3(p1,p2,p3:longint);
  var
    l:longint;
  begin
    for l:=0 to plane_max-1 do
    if ((plane_p1[l]=p1) and (plane_p2[l]=p2) and (plane_p3[l]=p3)) or
       ((plane_p1[l]=p1) and (plane_p2[l]=p3) and (plane_p3[l]=p2)) or
       ((plane_p1[l]=p2) and (plane_p2[l]=p1) and (plane_p3[l]=p3)) or
       ((plane_p1[l]=p2) and (plane_p2[l]=p3) and (plane_p3[l]=p1)) or
       ((plane_p1[l]=p3) and (plane_p2[l]=p1) and (plane_p3[l]=p2)) or
       ((plane_p1[l]=p3) and (plane_p2[l]=p2) and (plane_p3[l]=p1)) then
      exit;
    plane_p1[plane_max]:=p1;
    plane_p2[plane_max]:=p2;
    plane_p3[plane_max]:=p3;
    inc(plane_max);
  end;

procedure addplane4(p1,p2,p3,p4:longint);
  begin
    addplane3(p1,p2,p3);
    addplane3(p1,p4,p3);
  end;

procedure addcube(x,y,z,C:longint);
  var
    t,p1,p2,p3,p4,p5,p6,p7,p8:longint;
    nx,ny,nz:longint;
  begin
    p1:=addpoint(x-C,y-C,z-C);
    p2:=addpoint(x-C,y+C,z-C);
    p3:=addpoint(x+C,y+C,z-C);
    p4:=addpoint(x+C,y-C,z-C);
    p5:=addpoint(x-C,y-C,z+C);
    p6:=addpoint(x-C,y+C,z+C);
    p7:=addpoint(x+C,y+C,z+C);
    p8:=addpoint(x+C,y-C,z+C);

    addline(p1,p2);
    addline(p2,p3);
    addline(p3,p4);
    addline(p4,p1);
    addline(p5,p6);
    addline(p6,p7);
    addline(p7,p8);
    addline(p8,p5);
    addline(p1,p5);
    addline(p2,p6);
    addline(p3,p7);
    addline(p4,p8);

    addplane4(p1,p2,p3,p4);
    addplane4(p5,p6,p7,p8);
    addplane4(p1,p4,p8,p5);
    addplane4(p2,p3,p7,p6);
    addplane4(p1,p2,p6,p5);
    addplane4(p4,p3,p7,p8);
  end;

procedure gen_data(n:longint);
  const
    mx=48;
    my=10;
    a:array[0..my-1,0..mx-1] of byte =
      (
        (1,0,0,0,0,0,1,0,0,0,0,0,1,1,0,0,0,0,1,1,1,1,1,1,1,0,0,1,1,1,1,1,0,0,0,1,0,0,1,1,0,0,0,0,0,0,1,1),
        (1,2,0,0,0,3,1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0),
        (1,0,2,0,3,0,1,0,0,0,0,1,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,1,0,1,1,1,0,0,0,2,0,0,0,0,3,0,0),
        (1,0,0,1,0,0,1,0,0,0,0,3,0,0,2,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,1,0,0,1,0,0,0,0,0,2,0,0,3,0,0,0),
        (1,0,0,0,0,0,1,0,0,0,1,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,1,1,1,1,0,0,0,1,0,0,0,0,0,0,1,1,0,0,0,0),
        (1,0,0,0,0,0,1,0,0,0,1,1,1,1,1,1,0,0,0,0,0,1,0,0,0,0,0,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,0,0,0),
        (1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,1,0,4,0,0,0,0,0,1,0,0,0,0,0,3,0,0,2,0,0,0),
        (1,0,0,0,0,0,1,0,0,3,0,0,0,0,0,0,2,0,0,0,0,1,0,0,0,0,0,1,0,0,4,0,0,0,0,1,0,0,0,0,3,0,0,0,0,2,0,0),
        (1,0,0,0,0,0,1,0,3,0,0,0,0,0,0,0,0,2,0,0,0,1,0,0,0,0,0,1,0,0,0,4,0,0,0,1,0,0,0,1,0,0,0,0,0,0,1,0),
        (1,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,1,0,0,0,0,4,0,1,1,1,0,1,1,0,0,0,0,0,0,1,1)
      );
  var
    x,y,z,rx,ry,rz:longint;
  begin

    point_max := 0;
    line_max  := 0;
    plane_max := 0;

    if n and 1 <>0 then
    begin
      for y := 0 to my-1 do
      for x := 0 to mx-1 do
      if a[y,x]<>0 then
      begin
        rx:=(x-mx div 2)*200;
        ry:=(y-my div 2)*200;
        rz:=0;
        if x>7 then
        if x<=17 then
        begin
          rz:=rx+11*200;
          rx:=-11*200;
        end;
        if x>26 then
        if x<=32 then
        begin
          rz:=ry;
          ry:=0;
        end;
        addcube(rx,ry,rz,100);
      end;
    end;

    if n and 2 <>0 then
    begin

      for z := -3 to 3 do
      for y := -3 to 3 do
      for x := -3 to 3 do
      if byte(abs(x)=3) + byte(abs(y)=3) + byte(abs(z)=3) = 2 then
        addcube(x*500,y*500,z*500,200);

    end;

  end;

procedure setrgb(c,r,g,b:longint);
  begin
     port[$3c8]:=c;
     port[$3c9]:=r;
     port[$3c9]:=g;
     port[$3c9]:=b;
  end;

procedure setrgbpal(a,b,r1,g1,b1,r2,g2,b2:longint);
  var
    i:longint;
  begin
    for i:=a to b do
      setrgb(i,
             r1+(r2-r1)*(i-a) div (b-a),
             g1+(g2-g1)*(i-a) div (b-a),
             b1+(b2-b1)*(i-a) div (b-a));
  end;

var
  timer:longint absolute $40:$6C;
  dx,dy,dz,totalframes,totaltime:longint;

procedure quit;
  begin
    donegraph;

    writeln('MATRiX #1 Demo  (x) 2000 Z0MBiE, http://z0mbie.cjb.net');
    writeln;
    writeln(point_max:6,' points   ',totalframes:7,' frames');
    writeln(line_max :6,' lines    ',totaltime/1000000.0:7:2,' seconds');
    writeln(plane_max:6,' planes   ',totalframes*1000000.0/(totaltime+1):7:2,' fps');

    halt;
  end;

{$IFDEF USETEXT}

const
  s_text:string='                     '+
                '  ULTRAS mort NBK Henkey Del_Armg0 '+
                '                                '+
                '  greetz to VX scene '+
                '                     ';

  x_ptr:longint=0;
  s_ptr:longint=0;

procedure puttext;
  var
    rx,ry,i,x,y,tx,c:longint;
    s:string;
  begin
    if s_ptr=-1 then exit;
    tx:=1;
    for i:=0+1 to 19-1 do
    for x:=0 to 7 do
    begin
      if s_text[s_ptr+i]<>#32 then
      begin
        c:=C_PAL2+63;
        if tx<=63 then c:=C_PAL2+tx;
        if C_MAXX shr 1-tx<=63 then c:=C_PAL2+C_MAXX shr 1-tx;
        for y:=0 to 15 do
          if font[ ord(s_text[s_ptr+i]) shl 4+y] shl x and $80 <> 0 then
          begin
            rx:=(i shl 3+x) shl 1-x_ptr;
            ry:=C_MAXY-32+y shl 1;
{$IFDEF USEGRAPH}
            if OPT_VGA=1 then begin
{$ENDIF}
              asm
                mov esi, ry
                imul esi,320
                add esi, rx
                mov eax,c
                mov ah,al
                mov word ptr buf[esi], ax
                mov word ptr buf[esi+320], ax
              end;
              if bkgr_type=1 then
              if flame_type=2 then
                bmp[ry,rx]:=random(2)*160;
{$IFDEF USEGRAPH}
            end else begin
              putpixel(rx shl 1, ry shl 1+40, c);
            end;
{$ENDIF}
          end;
        end;
      inc(tx);
    end;
    x_ptr:=(x_ptr+1) and 15;
    if x_ptr=0 then
    inc(s_ptr);
    if s_ptr>=length(s_text)-20 then s_ptr:= -1;
  end;

{$ENDIF}


{$IFDEF USEBMP}

procedure setbmppal(scale:longint);
  var
    c:longint;
  begin
    for c:=0 to 127 do
      setrgb(C_PAL0+c,
             bkgr[1+54+c shl 2+2]*scale div 255,
             bkgr[1+54+c shl 2+1]*scale div 255,
             bkgr[1+54+c shl 2+0]*scale div 255);
  end;

procedure processbmp;
  var
    c,x,y:longint;
  begin
    fillchar(bmp,sizeof(bmp),0);
    for y:=0 to 199 do
    for x:=0 to 319 do
      bmp[y,x]:= bkgr[1+54+1024+(199-y)*320+x]+C_PAL0;
    setbmppal(0);
  end;
{$ENDIF}

{$IFDEF USEFLAME}

procedure setflamepal(scale:longint);
  var
    x,y:longint;
  begin
    for x := 0 to 31 do
    begin
      y:=x*scale div 31;
      setrgb(C_PAL0+x, y, 0, 0);
      setrgb(C_PAL0+x+32, scale, y, 0);
      setrgb(C_PAL0+x+64, scale, scale, y);
      setrgb(C_PAL0+x+96, scale, scale, scale);
    end;
  end;

procedure updateflame;
  var
    x:longint;
  begin
    x:=random(65536);
    asm
      mov     ecx, x
      xor     esi, esi
  @@cycle1:
      mov     edi, 0*320
  @@cycle2:
      xor     eax, eax
      mov     al, byte ptr bmp[edi+esi]
      xor     ebx, ebx
      mov     bl, byte ptr bmp[edi+esi+2]
      add     eax, ebx
      mov     bl, byte ptr bmp[edi+esi-2]
      add     eax, ebx
      mov     bl, byte ptr bmp[edi+esi+2*320+2]
      add     eax, ebx
      shr     eax, 2
      jz      @@1
      dec     al
  @@1:mov     ah, al
      mov     word ptr bmp[esi+edi-2*320], ax
      mov     word ptr bmp[esi+edi-1*320], ax
      add     edi, 2*320
      cmp     edi, 204*320
      jbe     @@cycle2

      cmp     flame_type,2
      je      @@3
      imul    ecx, 214013
      add     ecx, 2531011
      xor     al, al
      test    ecx, 10000h
      jz      @@2
      mov     al, 160
  @@2:mov     byte ptr bmp[edi+esi-2*320], al
  @@3:

      add     esi, 2
      cmp     esi, 320
      jb      @@cycle1
    end;
  end;

{$ENDIF}

function cycle : boolean;
  var
    time1,time2:longint;
  begin
    cycle:=true;

    time1 := LZTimerLap;

    angle_x := angle_x + dx;
    angle_y := angle_y + dy;
    angle_z := angle_z + dz;

{$IFDEF USEFLAME}
    if bkgr_type=1 then updateflame;
{$ENDIF}

    clearscreen;
    calc_angle;
    calc_points;
    calc_minmax;
    if draw_type=3 then sortplanes;
    draw;
{$IFDEF USETEXT}
    puttext;
{$ENDIF}
    onscreen;

    inc(totalframes);
    repeat
      time2:=LZTimerLap-time1;
    until (OPT_NOFIXFPS=1) or (time2 > 1000000 div C_FPS);
    inc(totaltime,time2);

    if keypressed then
      case readkey of
        #32: OPT_NOFIXFPS:=OPT_NOFIXFPS xor 1;
        #27: quit;
        'x': cycle := false;
      end;

  end;

procedure showhelp;
  begin
    writeln('options:');
    writeln('  /maxfps -- allow max avail fps rate (SPACE within the demo)');
    writeln('  /cont   -- execute demo continously');
{$IFDEF USEGRAPH}
    writeln('  /pas    -- use pascal''s graph (sucks)');
{$ENDIF}
    halt;
  end;

procedure initbkgr;
  begin
    if bkgr_type=1 then begin
{$IFDEF USEFLAME}
      fillchar(bmp, sizeof(bmp), 0);
{$ENDIF}
    end else begin
{$IFDEF USEBMP}
      if OPT_VGA=1 then processbmp;
{$ENDIF}
    end;
  end;

var
  i,j:longint;
begin

  for i:=1 to paramcount do
  begin
    if paramstr(i)='/maxfps' then OPT_NOFIXFPS:=1 else
    if paramstr(i)='/cont'   then OPT_CONT:=1     else
{$IFDEF USEGRAPH}
    if paramstr(i)='/pas'    then OPT_VGA:=0      else
{$ENDIF}
      showhelp;
  end;

  initgraph;

{
  look_z:=7000;
  angle_x:=128;
  angle_y:=128;
  angle_z:=0;
  draw_type := 2;
  bkgr_type := 2;
  initbkgr;
  gen_data(1);
  setrgbpal(C_PAL1,C_PAL1+63,  63,0,0, 0,0,63);
  clearscreen;
  calc_angle;
  calc_points;
  calc_minmax;
  sortplanes;
  draw;
  onscreen;
  readkey;
  quit;
}

  for i:=0 to 63 do
    setrgb(C_PAL2+i, i,i,i);

  fillchar(buf, sizeof(buf), 0);

  totalframes:=0;
  totaltime:=0;
  ZTimerInit;
  LZTimerOn;

  j:=0;
  repeat

    {$IFDEF USETEXT}
    if s_ptr=-1 then s_ptr:=0;
    {$ENDIF}

    angle_x:=0;
    angle_y:=0;
    angle_z:=0;

    case j mod 3 of
      0:
{$IFDEF USEPOINTS}
         gen_data(1);
{$ELSE}
         gen_data(3);
{$ENDIF}
      1: gen_data(1);
      2: gen_data(2);
    end;

{$IFDEF USEPOINTS}
    if j<>2 then
    begin
      look_z := 5000;
      setrgbpal(C_PAL1,C_PAL1+63,  63,0,0, 63,63,42);
      draw_type := 1;
      bkgr_type := 1;
      flame_type := 2;
      initbkgr;
      dx:=8;
      dy:=0;
      dz:=8;
      for i:=0 to 63 do
      begin
{$IFDEF USEFLAME}
        setflamepal(i);
{$ENDIF}
        if not cycle then break;
      end;
      for i:=1+64 to C_MAXANGLE div 2-64 do
        if not cycle then break;
      for i:=0 to 63 do
      begin
{$IFDEF USEFLAME}
        setflamepal(63-i);
{$ENDIF}
        setrgbpal(C_PAL1,C_PAL1+63,  63-i,0,0, 63-i,63,42-i*2 div 3);
        if not cycle then break;
      end;
    end;

    case j mod 3 of
      0: gen_data(3);
    end;

{$ENDIF}


{$IFDEF USELINES}
    look_z := 5000;
    setrgbpal(C_PAL1,C_PAL1+63,  0,0,0, 0,63,0);
    draw_type := 2;
    bkgr_type := 2;
    initbkgr;
    dx:=16;
    dy:=8;
    dz:=0;
    for i:=0 to 99 do
    begin
{$IFDEF USEBMP}
      if i<=63 then setbmppal(i);
{$ENDIF}
      inc(look_z,50);
      if not cycle then break;
    end;
    for i:=100 to C_MAXANGLE div 4 do
      if not cycle then break;
    dy:=-dy;
    for i:=100 to C_MAXANGLE div 4-64 do
      if not cycle then break;
    for i:=0 to 63 do
    begin
{$IFDEF USEBMP}
      setbmppal(63-i);
{$ENDIF}
      setrgbpal(C_PAL1,C_PAL1+63,  i,0,0, i,63,i*2 div 3);
      if not cycle then break;
    end;
{$ENDIF}

{$IFDEF USEPLANES}
    look_z := 10000;
    setrgbpal(C_PAL1,C_PAL1+63,  63,0,0, 63,63,42);
    draw_type:=3;
    bkgr_type := 1;
    flame_type := 1;
    initbkgr;
    dx:=4;
    dy:=-16;
    dz:=4;
    for i:=0 to 63 do
    begin
{$IFDEF USEFLAME}
      setflamepal(i);
{$ENDIF}
      if not cycle then break;
    end;
    for i:=64 to C_MAXANGLE div 4-64 do
      if not cycle then break;
    for i:=0 to 63 do
    begin
{$IFDEF USEFLAME}
      setflamepal(63-i);
{$ENDIF}
      setrgbpal(C_PAL1,C_PAL1+63, 63,i,i, 63-i,63-i,42+i div 3);
      if not cycle then break;
    end;
    bkgr_type := 3;
    for i:=1 to C_MAXANGLE div 4-200 do
      if not cycle then break;
    for i:=0 to 199 do
    begin
      dec(look_z,25);
      if not cycle then break;
    end;
{$ENDIF}

    inc(j);
    if (OPT_CONT=0) and (j>=3) then quit;

  until false;

end.

