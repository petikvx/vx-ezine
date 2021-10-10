uses DOS;

const
  InFileName='movie';

var i,j:integer;
    s:array[1..25] of string[80];
    infile:text;

    screen: array[0..24, 0..2*80-1] of char absolute $B800:0;

function readkey:word; assembler;
asm
  xor ax,ax
  int 16h
end;

procedure Pause( secs:integer );
var i,j,j1:word;
  function a:boolean;
  begin
    if j1<>j then
    begin
      Inc(j);
      Dec(secs);
    end;

    a:=secs<=0;
  end;
begin
  GetTime(i,i,j,i);

  repeat
    GetTime(i,i,j1,i);
  until a;
end;

begin
  Assign( infile, InFileName );

  repeat
    Reset( infile );

    Pause(1);

    while not Eof(infile) do
    begin
      i:=0;
      while not Eof(infile) and (i<25) do
      begin
        Inc(i);
        readln( infile, s[i] );
      end;

      for i:=1 to 25 do
        for j:=0 to Length(s[i])-1 do
          screen[i-1,j*2]:=s[i,j+1];
      Pause(1);
    end;
  until lo(readkey)=$1b;

  Close( infile );
end.
