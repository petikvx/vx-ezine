var
  f : file;
  a : longint;
  b : longint;
  c : array[1..16384] of byte;
begin
  assign(f, 'dos.obj');
  reset(f,1);
  a := filesize(f)+8;
  b := 0;
  blockread(f, c, a-8);
  close(f);
  assign(f, '-dos.bin');
  rewrite(f,1);
  blockwrite(f, a, a);
  close(f);

  assign(f, 'win.obj');
  reset(f,1);
  a := filesize(f)+8;
  b := 0;
  blockread(f, c, a-8);
  close(f);
  assign(f, '-win.bin');
  rewrite(f,1);
  blockwrite(f, a, a);
  close(f);
end.
