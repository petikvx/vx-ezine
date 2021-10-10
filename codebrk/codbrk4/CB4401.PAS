{

  For an explanation of the RC4 algorithm see my virus YeLeT 0.9b

}
program _rc4_;
uses crt,windos;


var
  we,inputfile,outputfile,key,codebreakers:string;
  ende,auto:boolean;
  command:char;
  y,i:byte;
  sizek,curpos:longint;


procedure swap_byte(var i,j:byte);
  var
    help:byte;
  begin
    help:=i;
    i:=j;
    j:=help;
  end;

procedure rc4(infile, outfile, key:string);
  var
    keylength: byte;
    state: array[0..255] of byte;
    i,j,n: byte;
    key_ptr: byte;
    inf,outf:file;
    buffer:array[1..2048] of byte;
    numread,numwritten:word;
    msg_ptr:word;
  begin
    {$I-}
    assign(inf,infile);
    reset(inf,1);
    close(inf);
    {$I+}
    if (ioresult=0) and (infile<>'')=false then
      begin
        textcolor(red);
        gotoxy(1,17); write(' Input file doesn''t exist! ');
        textcolor(white);
        delay(2000);
        y:=1;
        auto:=false;
        exit;
      end;

    if outfile='' then
      begin
        textcolor(red);
        gotoxy(1,17); write('Output file doesn''t exist! ');
        textcolor(white);
        delay(2000);
        y:=2;
        auto:=false;
        exit;
      end;
    assign(outf,outfile);
    setfattr(outf,faarchive);
    rewrite(outf,1);
    assign(inf,infile);
    reset(inf,1);

    if key='' then
      begin
        textcolor(red);
        gotoxy(1,17); write('   Secret Key missing!    ');
        textcolor(white);
        delay(2000);
        y:=3;
        auto:=false;
        exit;
      end;

    keylength:=length(key);


    for i:=0 to 255 do
      state[i]:=i;

    i:=0;
    j:=0;

    for i:=0 to 255 do
      begin
        key_ptr:=i mod keylength;
        inc(key_ptr);
        j:=(j+state[i]+ord(key[key_ptr])) mod 256;
        swap_byte(state[i],state[j]);
      end;



    i:=0;
    j:=0;

    sizek:=filesize(inf) div 1024;
    curpos:=0;

    repeat
        blockread(inf,buffer,sizeof(buffer),numread);
        for msg_ptr:=1 to numread do
          begin
            j:=(j+state[i]) mod 256;
            swap_byte(state[i],state[j]);
            n:=(state[i]+state[j]) mod 256;
            buffer[msg_ptr]:=buffer[msg_ptr] xor n;
            i:=(i+1) mod 256;
          end;
        blockwrite(outf,buffer,numread,numwritten);
        inc(curpos,numread);
        gotoxy(1,17); write('Filesize: ',sizek,'kB       ');
        gotoxy(1,18); write('Done:     ',curpos div 1024,'kB       ');
    until (numread=0) or (numread<>numwritten);
    gotoxy(1,19); write('*** DONE ***'); delay(2000);
    close(inf);
    close(outf);
    ende:=true;
  end;

begin
  codebreakers:='WWW.CODEBREAKERS.ORG';
  if paramcount>2 then
    auto:=true
  else
    auto:=false;
  clrscr;
  textmode(co40);
  textcolor(red);

  asm                                   { remove the blinking cursor }
    mov ah,1
    mov cx,2000h
    int 10h
  end;
  we:=paramstr(0);
  for i:=1 to length(we) do
    if we[i]='\' then
      y:=i;
  we:=copy(we,y+1,length(we)-y);

  gotoxy(14,1); write('RC4Crypt v1,');
  textcolor(green);
  gotoxy(3,3); write('an example encryption program using');
  gotoxy(2,4); write('Ron Rivest''s RC4 encryption algorithm,');
  gotoxy(7,5); write('written for CB #4 by SPo0ky.');
  textcolor(blue);
  gotoxy(1,6); write('----------------------------------------');
  textcolor(7);
  gotoxy(1,8); write('Commandline:');
  gotoxy(2,9); write(we+' <in-file> <out-file> <key>');
  textcolor(8);
  gotoxy(1,11); write('Input file:');
  gotoxy(1,12); write('Output file:');
  gotoxy(1,13); write('Key:');
  textcolor(15);
  gotoxy(1,15); write('Status:');
  gotoxy(28,16);write(#24+'   - UP');
  gotoxy(28,17);write(#25+'   - DOWN');
  gotoxy(28,18);write('RET - START');
  gotoxy(28,19);write('ESC - CANCEL');

  textcolor(blue);
  gotoxy(1,23); write('---------------------------------------');
  textcolor(8);
  gotoxy(7,24); write('*** '+codebreakers+' ***');

  y:=1;

  if paramcount>0 then
    begin
      inputfile:=paramstr(1);
      y:=2;
    end
  else
    inputfile:='';

  if paramcount>1 then
    begin
    outputfile:=paramstr(2);
    y:=3;
    end
  else
    outputfile:='';

  if paramcount>2 then
    begin
    key:=paramstr(3);
    y:=1;
    end
  else
    key:='';

  for i:=4 to paramcount do
    key:=key+' '+paramstr(i);

  ende:=false;
  while not ende do
    begin
      textcolor(white);
      if y = 1 then
        begin
          textbackground(1);
          gotoxy(14,11); write(inputfile:12);
          textbackground(black);
          gotoxy(14,12); write(outputfile);
          for i:=length(outputfile)+1 to 12 do
            write(' ');
          gotoxy(14,13); write(key);
          for i:=length(key)+1 to 27 do
            write(' ');
          gotoxy(1,17); write('Enter the Input file       ');
        end;
      if y = 2 then
        begin
          textbackground(1);
          gotoxy(14,12); write(outputfile:12);
          textbackground(black);
          gotoxy(14,11); write(inputfile);
          for i:=length(inputfile)+1 to 12 do
            write(' ');
          gotoxy(14,13); write(key);
          for i:=length(key)+1 to 27 do
            write(' ');
          gotoxy(1,17); write('Enter the Output file      ');
        end;
      if y = 3 then
        begin
          textbackground(1);
          gotoxy(14,13); write(key:27);
          textbackground(black);
          gotoxy(14,11); write(inputfile);
          for i:=length(inputfile)+1 to 12 do
            write(' ');
          gotoxy(14,12); write(outputfile);
          for i:=length(outputfile)+1 to 12 do
            write(' ');
          gotoxy(1,17); write('Enter the Secret Key       ');
        end;
      textbackground(black);
      gotoxy(14,10+y);

      if auto=true then
        command:=#13
      else
        command:=readkey;
      case command of
        #72: begin
               if y=1 then
                 y:=3
               else
                 dec(y);
             end;
        #80: begin
               if y=3 then
                 y:=1
               else
                 inc(y);
             end;
        #27: begin
               gotoxy(1,17); write('     *** CANCELED ***      ');
               delay(1000);
               ende:=true;
             end;
        #13: begin
               rc4(inputfile,outputfile,key);
             end;
        #8:  case y of
               1: if length(inputfile) > 0 then
                    inputfile:=copy(inputfile,0,length(inputfile)-1);
               2: if length(outputfile) > 0 then
                    outputfile:=copy(outputfile,0,length(outputfile)-1);
               3: if length(key) > 0 then
                    key:=copy(key,0,length(key)-1);
             end;
        else
          if command <> #0 then
            case y of
              1: if length(inputfile)<12 then
                   inputfile:=inputfile+command;
              2: if length(outputfile)<12 then
                   outputfile:=outputfile+command;
              3: if length(key)<27 then
                   key:=key+command;
            end;
      end;
    end;

  for i:=1 to length(key) do    { just to be sure.... }
    key[i]:='?';
  key:='';

  textbackground(black);
  textcolor(7);
  textmode(co80);
  clrscr;
end.