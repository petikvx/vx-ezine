컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[vs2000.pas]컴�
program VirSort_2000_for_29A_4;

uses
     dos, crt, lgarray;

var
   f         : text;
   g         : text;
   newfile   : text;
   flag1     : boolean;
   flag2     : boolean;
   count     : longint;
   log_file  : string;
   tipo      : string;
   d         : dictionary;
   i         : integer;
   log       : text;
   instring  : string;
   filename  : string;
   virusname : string;
   newvirus  : string;
   test      : longint;
   parm1     : string;
   parm2     : string;
   parm3     : string;
   spos2     : integer;
   last_bar  : byte;
   tmp_str   : string;
   temp_string      : string;
   space_position   : byte;

procedure ShowHelp;
begin
     writeln('   -b {s} {w}          <logname>            Build new DAT file');
     writeln('   -c {s} {w}          <logname>            Compare someone elses log');
     writeln('   -a {l} {s} {w}      <logname>            Add new virii');
     writeln('   -h {u}                                   Count virii');
     writeln;
     halt;
end;

procedure no_virii;
begin
writeln('No virii found to process!');
end;

procedure no_new_virii_found;
begin
writeln('No new virii found');
end;

procedure no_new_virii_added;
begin
writeln('No new virii added');
end;

procedure not_find_avp;
begin
writeln('Can not find AVP.DAT in current directory!');
end;

procedure not_find_fprot;
begin
writeln('Can not find FPROT.DAT in current directory!');
end;

procedure no_dat;
begin
writeln('No DAT files found!');
end;

procedure longitud(log_file : string);
var
   f            : file of Byte;
   size         : Longint;

begin
     assign(f,log_file);
     reset(f);
     size := filesize(f);
     close(f);
     if size = 0 then erase(f);
end;

procedure OpenLog(logname : string);
begin
     spos2 := WhereY;
     assign(log, logname);
     {$I-}
     reset(log);
     {$I+}
     flag2:=false;
     if IOResult <> 0 then flag2 := true;
end;

procedure f_macrow;
begin
if pos(#9'Infection:'#9,instring) > 0 then
    begin
tmp_str:=copy(instring,pos(#9'Infection:'#9,instring)+12,length(instring));
tmp_str:=concat('  Infection: ',tmp_str);
space_position:=pos(#9,instring);
temp_string:=copy(instring,1,space_position-1);
instring:=concat(temp_string,tmp_str);
    end
else
    begin
tmp_str:=copy(instring,pos('    Infection:      ',instring)+20,length(instring));
tmp_str:=concat('  Infection: ',tmp_str);
space_position:=pos(' ',instring);
temp_string:=copy(instring,1,space_position-1);
instring:=concat(temp_string,tmp_str);
    end;
if pos('WordMacro/',instring) > 0 then
                                      begin
tmp_str:=copy(instring,pos('WordMacro/',instring)+10,length(instring));
tmp_str:=concat('WM/',tmp_str);
space_position:=pos('WordMacro/',instring);
temp_string:=copy(instring,1,space_position-1);
instring:=concat(temp_string,tmp_str);
                                      end
else if pos('Word97Macro/',instring) > 0 then
                                             begin
tmp_str:=copy(instring,pos('Word97Macro/',instring)+12,length(instring));
tmp_str:=concat('W97M/',tmp_str);
space_position:=pos('Word97Macro/',instring);
temp_string:=copy(instring,1,space_position-1);
instring:=concat(temp_string,tmp_str);
                                             end
else if pos('ExcelFormula/',instring) > 0 then
                                              begin
tmp_str:=copy(instring,pos('ExcelFormula/',instring)+13,length(instring));
tmp_str:=concat('XF/',tmp_str);
space_position:=pos('ExcelFormula/',instring);
temp_string:=copy(instring,1,space_position-1);
instring:=concat(temp_string,tmp_str);
                                              end
else if pos('Excel97Macro/',instring) > 0 then
                                                     begin
tmp_str:=copy(instring,pos('Excel97Macro/',instring)+13,length(instring));
tmp_str:=concat('X97M/',tmp_str);
space_position:=pos('Excel97Macro/',instring);
temp_string:=copy(instring,1,space_position-1);
instring:=concat(temp_string,tmp_str);
                                                     end
else if pos('ExcelMacro/',instring) > 0 then
                                                     begin
tmp_str:=copy(instring,pos('ExcelMacro/',instring)+11,length(instring));
tmp_str:=concat('XM/',tmp_str);
space_position:=pos('ExcelMacro/',instring);
temp_string:=copy(instring,1,space_position-1);
instring:=concat(temp_string,tmp_str);
                                                     end
else if pos('Word2Macro/',instring) > 0 then
                                             begin
tmp_str:=copy(instring,pos('Word2Macro/',instring)+11,length(instring));
tmp_str:=concat('W2M/',tmp_str);
space_position:=pos('Word2Macro/',instring);
temp_string:=copy(instring,1,space_position-1);
instring:=concat(temp_string,tmp_str);
                                             end
else if pos('PowerPoint97Macro/',instring) > 0 then
                                             begin
tmp_str:=copy(instring,pos('PowerPoint97Macro/',instring)+18,length(instring));
tmp_str:=concat('PP97M/',tmp_str);
space_position:=pos('PowerPoint97Macro/',instring);
temp_string:=copy(instring,1,space_position-1);
instring:=concat(temp_string,tmp_str);
                                             end;
end;

procedure DetectLog;
begin
     flag1:=false;
     tipo:='';
     while flag1=false do
     begin
     readln(log,instring);
     if (pos('infected:',instring)) or (pos('warning:',instring)) or
     (pos(': infected by',instring)) or (pos(': warning',instring)) > 0 then
     begin
     tipo:='AVP';
     flag1:=true;
     end
     else if (pos(#9'Infection:'#9,instring)) or (pos('    Infection:      ',instring)) or
             (pos(' Infection: ',instring)) > 0 then
             begin
             tipo:='F-PROT';
             flag1:=true;
             end;
     if eof(log) then flag1:=true;
     end;
end;

procedure BuildNewDat_A;
begin
     writeln('Detected AVP log file');
     assign(f,'AVP.DAT');
     rewrite(f);
     dicAssign(d,'testing dict');
     dicRewrite(d,100);
     count := 0;
     repeat
           readln(log,instring);
           if (pos('infected:',instring)) or (pos('warning:',instring)) or
              (pos(': infected by',instring)) or (pos(': warning',instring)) > 0 then
           begin
           if ((parm1 = '-BW') or (parm1 = '-BSW')) and
              (pos('warning:',instring) or (pos(': warning',instring)) >0) then
           else
           begin
                if pos('-based',instring) <> 0 then
                else
                begin
                     filename := instring;
                     virusname := instring;
                     if pos(' ',filename) > 0 then delete(filename,pos(' ',filename),length(filename));
                     if pos(#9,filename) > 0 then delete(filename,pos(#9,filename),length(filename));

                     if pos('warning:',virusname) >0 then
                     begin
                          delete(virusname,1,(pos('ning:',virusname)+5));
                          virusname := concat(virusname,'.warning');
                     end
                     else if pos(': warning',virusname) > 0 then
                     begin
                          delete(virusname,1,(pos('rning',virusname)+5));
                          virusname := concat(virusname,'.warning');
                     end
                     else
                     begin
                     for last_bar:=length(virusname) downto 0 do
                     begin
                     if virusname[last_bar]=' ' then break;
                     end;
                     delete(virusname,1,last_bar);
                     end;

                     dicFind(d,virusname,test);
                     if test < 0 then
                     begin
                          gotoxy(1,spos2);
                          inc(count);
                          write(count,' virii found for AVP...');
                          dicWrite(d,virusname);
                          temp_string:=concat(filename,' ',virusname);
                          writeln(f,temp_string);
                     end;
                end;
           end;
           end;

     until eof(log);
     dicClose;
     dicErase(d);
     close(f);
end;

procedure BuildNewDAT_F;
begin
     writeln('Detected F-Prot log file');
     assign(f,'FPROT.DAT');
     rewrite(f);
     dicAssign(d,'testing dict');
     dicRewrite(d,100);

     count := 0;

     repeat
           readln(log,instring);
           if (pos(#9'Infection:'#9,instring)) or (pos('    Infection:      ',instring)) > 0 then f_macrow;

           if pos('Infection: ', instring) > 0 then
           begin
                if pos('New or',instring) <> 0 then
                else
                if pos('could be',instring) <> 0 then
                else
                begin
                     filename := instring;
                     virusname := instring;

                     if pos(' ',filename) > 0 then delete(filename,pos(' ',filename),length(filename));
                     if pos(#9,filename) > 0 then delete(filename,pos(#9,filename),length(filename));
                     if pos('->(',filename) > 0 then delete(filename,pos('->(',filename),length(filename));

                     delete(virusname,1,(pos('ion:',virusname)+4));

                     if (parm1 = '-BS') or (parm1 = '-BSW') then
                     else if pos(' ',virusname) > 0 then delete(virusname,pos(' ',virusname),length(virusname));

                     dicFind(d,virusname,test);
                     if test < 0 then
                     begin
                          gotoxy(1,spos2);
                          inc(count);
                          write(count,' virii found for F-Prot...');
                          dicWrite(d,virusname);
                          temp_string:=concat(filename,' ',virusname);
                          writeln(f,temp_string);
                     end;
                end;
           end;

     until eof(log);
     dicClose;
     dicErase(d);
     close(f);
end;

procedure CompareDAT_A;
begin
     writeln('Detected AVP log file');
     dicAssign(d,'testing dict');
     dicRewrite(d,100);
     assign(f,'avp.dat');
     {$I-}
     reset(f);
     {$I+}
     if IOResult <> 0 then
     begin
          flag2 := true;
          not_find_avp;
     end;
     if flag2 <> true then
     begin
     repeat
           readln(f,temp_string);
           space_position := pos(' ',temp_string);
           virusname:=copy(temp_string,space_position+1,length(temp_string));
           dicWrite(d,virusname);
     until eof(f);
     close(f);

     tmp_str:=('NEWAVP.LOG');
     assign(newfile,'NEWAVP.LOG');
     {$I-}
     reset(newfile);
     {$I+}
     count:=1;
     while IOResult = 0 do
     begin
         close(newfile);
         str(count,tmp_str);
         for i:=1 to 1-length(tmp_str) do tmp_str:=tmp_str;
         tmp_str:=concat('NEWAVP.LO'+tmp_str);
         inc(count);
         assign(newfile,tmp_str);
         {$I-}
         reset(newfile);
         {$I+}
     end;

     rewrite(newfile);

     count := 0;
     log_file:=tmp_str;

     repeat
           readln(log,instring);
           newvirus := instring;

           if (pos('infected:',instring)) or (pos('warning:',instring)) or
              (pos(': infected by',instring)) or (pos(': warning',instring)) > 0 then
           begin
           if ((parm1 = '-CW') or (parm1 = '-CSW')) and
              (pos('warning:',instring) or (pos(': warning',instring)) >0) then
           else
           begin
                if pos('-based',instring) <> 0 then
                else
                begin
                     filename := instring;
                     virusname := instring;
                     if pos(' ',filename) > 0 then delete(filename,pos(' ',filename),length(filename));
                     if pos(#9,filename) > 0 then delete(filename,pos(#9,filename),length(filename));

                     if pos('warning:',virusname) >0 then
                     begin
                          delete(virusname,1,(pos('ning:',virusname)+5));
                          virusname := concat(virusname,'.warning');
                     end
                     else if pos(': warning',virusname) > 0 then
                     begin
                          delete(virusname,1,(pos('rning',virusname)+5));
                          virusname := concat(virusname,'.warning');
                     end
                     else
                     begin
                     for last_bar:=length(virusname) downto 0 do
                     begin
                     if virusname[last_bar]=' ' then break;
                     end;
                     delete(virusname,1,last_bar);
                     end;

                     dicFind(d,virusname,test);
                     if test < 0 then
                     begin
                          gotoxy(1,spos2);
                          inc(count);
                          write(count,' new AVP virii found...');
                          dicWrite(d,virusname);
                          writeln(newfile,newvirus);
                     end;
                end;
           end;
           end;

     until eof(log);
     dicClose;
     dicErase(d);
     close(newfile);

longitud(log_file);
if count=0 then no_new_virii_found;
end;
end;

procedure CompareDAT_F;
begin
     writeln('Detected F-Prot log file');
     dicAssign(d,'testing dict');
     dicRewrite(d,100);
     assign(f,'fprot.dat');
     {$I-}
     reset(f);
     {$I+}
     if IOResult <> 0 then
     begin
          flag2 := true;
          not_find_fprot;
     end;
     if flag2 <> true then
     begin
     repeat
           readln(f,temp_string);
           space_position := pos(' ',temp_string);
           virusname:=copy(temp_string,space_position+1,length(temp_string));
           dicWrite(d,virusname);
     until eof(f);
     close(f);

     tmp_str:=('NEWFPROT.LOG');
     assign(newfile,'NEWFPROT.LOG');
     {$I-}
     reset(newfile);
     {$I+}
     count:=1;
     while IOResult = 0 do
     begin
         close(newfile);
         str(count,tmp_str);
         for i:=1 to 1-length(tmp_str) do tmp_str:=tmp_str;
         tmp_str:=concat('NEWFPROT.LO'+tmp_str);
         inc(count);
         assign(newfile,tmp_str);
         {$I-}
         reset(newfile);
         {$I+}
     end;

     rewrite(newfile);

     count := 0;
     log_file:=tmp_str;

     repeat
           readln(log,instring);
           newvirus := instring;

           if (pos(#9'Infection:'#9,instring)) or (pos('    Infection:      ',instring)) > 0 then f_macrow;

           if pos('Infection: ', instring) > 0 then
           begin
                if pos('New or',instring) <> 0 then
                else
                if pos('could be',instring) <> 0 then
                else
                begin
                     filename := instring;
                     virusname := instring;

                     if pos(' ',filename) > 0 then delete(filename,pos(' ',filename),length(filename));
                     if pos(#9,filename) > 0 then delete(filename,pos(#9,filename),length(filename));
                     if pos('->(',filename) > 0 then delete(filename,pos('->(',filename),length(filename));

                     delete(virusname,1,(pos('ion:',virusname)+4));

                     if (parm1 = '-CS') or (parm1 = '-CSW') then
                     else if pos(' ',virusname) > 0 then delete(virusname,pos(' ',virusname),length(virusname));

                     dicFind(d,virusname,test);
                     if test < 0 then
                     begin
                          gotoxy(1,spos2);
                          inc(count);
                          write(count,' new F-Prot virii found...');
                          dicWrite(d,virusname);
                          writeln(newfile,newvirus);
                     end;
                end;
           end;

     until eof(log);
     dicClose;
     dicErase(d);
     close(newfile);

longitud(log_file);
if count=0 then no_new_virii_found;
end;
end;

procedure AddNewDAT_A;
begin
     writeln('Detected AVP log file');
     dicAssign(d,'testing dict');
     dicRewrite(d,100);
     assign(f,'avp.dat');
     {$I-}
     reset(f);
     {$I+}
     if IOResult <> 0 then
     begin
          flag2 := true;
          not_find_avp;
     end;
     if flag2 <> true then
     begin
     assign(g,'temp.dat');
     rewrite(g);

     repeat
           readln(f,temp_string);
           writeln(g,temp_string);
           space_position := pos(' ',temp_string);
           virusname:=copy(temp_string,space_position+1,length(temp_string));
           dicWrite(d,virusname);
     until eof(f);
     close(f);

     if (parm1 = '-AL') or (parm1 = '-ALW') or (parm1 = '-ALSW') then
     begin
     tmp_str:=('NEWAVP.LOG');
     assign(newfile,tmp_str);
     {$I-}
     reset(newfile);
     {$I+}
     count:=1;
     while IOResult = 0 do
     begin
         close(newfile);
         str(count,tmp_str);
         for i:=1 to 1-length(tmp_str) do tmp_str:=tmp_str;
         tmp_str:=concat('NEWAVP.LO'+tmp_str);
         inc(count);
         assign(newfile,tmp_str);
         {$I-}
         reset(newfile);
         {$I+}
     end;
         rewrite(newfile);
         log_file:=tmp_str;
                                                   end;

     count := 0;

     repeat
           readln(log,instring);
           newvirus := instring;
           if (pos('infected:',instring)) or (pos('warning:',instring)) or
              (pos(': infected by',instring)) or (pos(': warning',instring)) > 0 then
           begin
           if ((parm1 = '-AW') or (parm1 = '-ALW') or 
              (parm1 = '-ASW') or (parm1 = '-ALSW')) and
              (pos('warning:',instring) or (pos(': warning',instring)) >0) then
           else
           begin
                if pos('-based',instring) <> 0 then
                else
                begin
                     filename := instring;
                     virusname := instring;
                     if pos(' ',filename) > 0 then delete(filename,pos(' ',filename),length(filename));
                     if pos(#9,filename) > 0 then delete(filename,pos(#9,filename),length(filename));

                     if pos('warning:',virusname) >0 then
                     begin
                          delete(virusname,1,(pos('ning:',virusname)+5));
                          virusname := concat(virusname,'.warning');
                     end
                     else if pos(': warning',virusname) > 0 then
                     begin
                          delete(virusname,1,(pos('rning',virusname)+5));
                          virusname := concat(virusname,'.warning');
                     end
                     else
                     begin
                     for last_bar:=length(virusname) downto 0 do
                     begin
                     if virusname[last_bar]=' ' then break;
                     end;
                     delete(virusname,1,last_bar);
                     end;

                     dicFind(d,virusname,test);
                     if test < 0 then
                     begin
                          gotoxy(1,spos2);
                          inc(count);
                          write('Adding ',count,' new virii for AVP...');
                          dicWrite(d,virusname);
                          temp_string:=concat(filename,' ',virusname);
                          writeln(g,temp_string);

     if (parm1 = '-AL') or (parm1 = '-ALW') or (parm1 = '-ALSW')
     then writeln(newfile,newvirus);
                     end;
                end;
           end;
           end;

     until eof(log);
     dicClose;
     dicErase(d);
     erase(f);
     close(g);
     rename(g,'AVP.DAT');
     if (parm1 = '-AL') or (parm1 = '-ALW') or (parm1 = '-ALSW')  then
                                                   begin
                                                   close(newfile);
                                                   longitud(log_file);
                                                   end;
if count=0 then no_new_virii_added;
end;
end;

procedure AddNewDAT_F;
begin
     writeln('Detected F-Prot log file');
     dicAssign(d,'testing dict');
     dicRewrite(d,100);
     assign(f,'fprot.dat');
     {$I-}
     reset(f);
     {$I+}
     if IOResult <> 0 then
     begin
          flag2 := true;
          not_find_fprot;
     end;
     if flag2 <> true then
     begin
     assign(g,'temp.dat');
     rewrite(g);
     repeat
           readln(f,temp_string);
           writeln(g,temp_string);
           space_position := pos(' ',temp_string);
           virusname:=copy(temp_string,space_position+1,length(temp_string));
           dicWrite(d,virusname);
     until eof(f);
     close(f);

     if (parm1 = '-AL') or (parm1 = '-ALS') or (parm1 = '-ALSW') then
     begin
     tmp_str:=('NEWFPROT.LOG');
     assign(newfile,tmp_str);
     {$I-}
     reset(newfile);
     {$I+}
     count:=1;
     while IOResult = 0 do
     begin
         close(newfile);
         str(count,tmp_str);
         for i:=1 to 1-length(tmp_str) do tmp_str:=tmp_str;
         tmp_str:=concat('NEWFPROT.LO'+tmp_str);
         inc(count);
         assign(newfile,tmp_str);
         {$I-}
         reset(newfile);
         {$I+}
     end;
         rewrite(newfile);
         log_file:=tmp_str;
                                                   end;

     count := 0;

     repeat
           readln(log,instring);
           newvirus := instring;

           if (pos(#9'Infection:'#9,instring)) or (pos('    Infection:      ',instring)) > 0 then f_macrow;

           if pos('Infection: ', instring) > 0 then
           begin
                if pos('New or',instring) <> 0 then
                else
                if pos('could be',instring) <> 0 then
                else
                begin
                     filename := instring;
                     virusname := instring;

                     if pos(' ',filename) > 0 then delete(filename,pos(' ',filename),length(filename));
                     if pos(#9,filename) > 0 then delete(filename,pos(#9,filename),length(filename));
                     if pos('->(',filename) > 0 then delete(filename,pos('->(',filename),length(filename));

                     delete(virusname,1,(pos('ion:',virusname)+4));

                     if (parm1 = '-AS') or (parm1 = '-ASW') then
                     else if pos(' ',virusname) > 0 then delete(virusname,pos(' ',virusname),length(virusname));

                     dicFind(d,virusname,test);
                     if test < 0 then
                     begin
                          gotoxy(1,spos2);
                          inc(count);
                          write('Adding ',count,' new virii for F-Prot...');
                          dicWrite(d,virusname);
                          temp_string:=concat(filename,' ',virusname);
                          writeln(g,temp_string);

     if (parm1 = '-AL') or (parm1 = '-ALS') or (parm1 = '-ALSW') then writeln(newfile,newvirus);
                     end;
                end;
           end;

     until eof(log);
     dicClose;
     dicErase(d);
     erase(f);
     close(g);
     rename(g,'FPROT.DAT');
     if (parm1 = '-AL') or (parm1 = '-ALS') or (parm1 = '-ALSW') then
                                                   begin
                                                   close(newfile);
                                                   longitud(log_file);
                                                   end;

if count=0 then no_new_virii_added;
end;
end;

procedure CountViruses;
begin

      flag1 := false;

      assign(f,'avp.dat');
      {$I-}
      reset(f);
      {$I+}
      if IOResult = 0 then
                          begin
                          flag1 := true;
                          count:= 0;
                          if parm1 = '-H' then
                                              begin
                                              repeat
                                              readln(f,temp_string);
                                              count := count + 1;
                                              until eof(f);
                                              writeln(count,' virii for AVP');
                                              end
                          else
                              begin
                              repeat
                              readln(f,temp_string);
                              if (pos('warning',temp_string) > 0) or
                                 (pos('warning',temp_string) > 0) or
                                 (pos('warning',temp_string) > 0) or
                                 (pos('warning',temp_string) > 0) or
                                 (pos('warning',temp_string) > 0) then
                              else count := count + 1;
                              until eof(f);
                              writeln(count,' unique virii for AVP');
                              end;
                          close(f);
                          end;

      assign(f,'fprot.dat');
      {$I-}
      reset(f);
      {$I+}
      if IOResult = 0 then
                          begin
                          flag1 := true;
                          count := 0;
                          if parm1 = '-H' then
                                              begin
                                              repeat
                                              readln(f,temp_string);
                                              count := count + 1;
                                              until eof(f);
                                              writeln(count,' virii for F-Prot');
                                              end
                          else
                              begin
                              repeat
                              readln(f,temp_string);
                              if (pos('unknown?',temp_string) > 0) or
                                 (pos('unknown?',temp_string) > 0) or
                                 (pos('unknown?',temp_string) > 0) or
                                 (pos('unknown?',temp_string) > 0) or
                                 (pos('unknown?',temp_string) > 0) or
                                 (pos('damaged?',temp_string) > 0) or
                                 (pos('damaged?',temp_string) > 0) or
                                 (pos('damaged?',temp_string) > 0) or
                                 (pos('damaged?',temp_string) > 0) or
                                 (pos('damaged?',temp_string) > 0) then
                              else count := count + 1;
                              until eof(f);
                              writeln(count,' unique virii for F-Prot');
                              end;
                          close(f);
                          end;

      if flag1 = false then no_dat;
      halt;
end;

procedure BuildNew;

begin
     DetectLog;
     if tipo = 'AVP' then BuildNewDat_A
     else if tipo = 'F-PROT' then BuildNewDat_F
     else no_virii;
end;

procedure CompareDat;
begin
     DetectLog;
     if tipo = 'AVP' then CompareDat_A
     else if tipo = 'F-PROT' then CompareDat_F
     else no_virii;
end;

procedure AddNewDat;
begin
     DetectLog;
     if tipo = 'AVP' then AddNewDat_A
     else if tipo = 'F-PROT' then AddNewDat_F
     else no_virii;
end;

begin
     writeln;
     writeln('   Virsort 2000 Special Edition for 29A       by VirusBuster/29A');
     writeln('-=---------------------------------------------------------------=-');
     writeln;

parm1 := paramstr(1);
parm2 := paramstr(2);
parm3 := paramstr(3);

for i := 1 to Length(parm1) do parm1[i] := UpCase(parm1[i]);
for i := 1 to Length(parm2) do parm2[i] := UpCase(parm2[i]);
for i := 1 to Length(parm3) do parm3[i] := UpCase(parm3[i]);

if (parm1 = '') or (parm1[1] <> '-') then ShowHelp;

if (parm1 = '-H') or (parm1 = '-HU') then CountViruses
else OpenLog(parm2);
if flag2 = True then
                    begin
                    writeln('Log file not found!');
                    halt;
                    end
else
    begin
    if (parm1 = '-B') or (parm1 = '-BW') or (parm1 = '-BS') or (parm1 = '-BSW') then BuildNew
    else if (parm1 = '-C') or (parm1 = '-CW') or (parm1 = '-CS') or (parm1 = '-CSW') then CompareDAT
    else if (parm1 = '-A') or (parm1 = '-AL') or (parm1 = '-AW') or (parm1 = '-ALW') or
            (parm1 = '-AS') or (parm1 = '-ALS') or (parm1 = '-ASW') or (parm1 = '-ALSW') then AddNewDAT
    else writeln('Unknown command. Run VS2000 without parameters for help!');
    close(log);
    end;
writeln;
end.
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[vs2000.pas]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[lgarray.pas]컴�
unit lgArray;
interface
type longArray=record name: string[40];
                      private: array[1..35] of byte
     end;
     stringPtr=^string;

    longintPtr=^longint;
    dictionary=record name: string[40];
                    index,corpus: longArray;
                    frequency: longint;
                    fqPtr: longintPtr;
     end;

procedure memAssign(var a: longArray; st: string);
procedure memRewrite(var a: longArray; items: longint; itemSize: word);
procedure memReset(var a: longArray);
procedure memSeek(var a: longArray; item: longint);
procedure memAppend(var a: longArray);
procedure memRead(var a: longArray; var item);
procedure memWrite(var a: longArray; var item);
procedure memSeekAndRead(var a: longArray; i: longint; var item);
procedure memSeekAndWrite(var a: longArray; i: longint; var item);
procedure memGet(var a: longArray; var item);
procedure memPut(var a: longArray; var item);
procedure memSeekAndGet(var a: longArray; i: longint; var item);
procedure memSeekAndPut(var a: longArray; i: longint; var item);
procedure memClose;
procedure memErase(var a: longArray);
function  memFileSize(var a: longArray):longint;
function  memLast(var a: longArray): longint;
function  memFilePos(var a: longArray): longint;
function  memEof(var a: longArray): boolean;

procedure dicAssign(var d: dictionary; st: string);
procedure dicRewrite(var d: dictionary; items: longint);
procedure dicReset(var d: dictionary);
procedure dicSeek(var d: dictionary; item: longint);
procedure dicAppend(var d: dictionary);
procedure dicFind(var d: dictionary; st: string; var foundPos: longint);
procedure dicFindBetween(var d: dictionary; st: string; lo,hi: longint; var foundPos: longint);
procedure dicRead(var d: dictionary; var st: string);
procedure dicWrite(var d: dictionary; st: string);
procedure dicPut(var d: dictionary; st: string);
procedure dicGet(var d: dictionary; var st: string);
procedure dicAdd(var d: dictionary; st: string; fq: longint);
procedure dicSeekAndWrite(var d: dictionary; i: longint; st: string);
procedure dicSeekAndRead(var d: dictionary; i: longint; var st: string);
procedure dicSeekAndGet(var d: dictionary; i: longint; var st: string);
procedure dicSeekAndPut(var d: dictionary; i: longint; st: string);
procedure dicClose;
procedure dicErase(var d: dictionary);
function  dicFileSize(var d: dictionary):longint;
function  dicLast(var d: dictionary): longint;
function  dicFilePos(var d: dictionary): longint;
function  dicEof(var d: dictionary): boolean;

procedure SetFq(var st: string; fq: longint);
procedure GetFq(var st: string; var fq: longint);

const expectedWordLength=10;

type aRowPtr=^aRow;
     aDictionaryPtr=^dictionary;
     anIndex=array[0..0] of aRowPtr;
     anIndexPtr=^anIndex;
     aRow= array[0..0] of byte;

     memRec=object
       name: string[40];
       bytesPerRow,bytesInIndex,lastRow,recordsPerRow,
       bytesPerRecord,shift,mask: word;
       maxRecordsInArray,lastRecord,pos: longint;
       insertMode: boolean;
       rowPtrNo: anIndexPtr;
       dicPtr:   aDictionaryPtr;
     end;

implementation

uses crt;

procedure SaveDic(var d: dictionary; fn: string);
var f: text; c,cc: char; i: longint; st: string;
begin write('Save current state of dictionary? (y/n) ');
      repeat c:=upcase(readkey);
             if keypressed then cc:=readkey
      until (c='Y') or (c='N');
      writeln;
      if c='Y' then
      begin assign(f,fn);
            rewrite(f);
            write('Saving to '+fn+'... ');
            dicSeek(d,1);
            for i:=1 to dicLast(d) do
            begin dicRead(d,st);
                  SetFq(st,d.frequency);
                  writeln(f,st)
            end;
            Close(f);
            writeln(' Dictionary saved.')
      end;
end;

procedure SaveMem(var a: longArray; fn: string);
var f: file of byte; i: longint; j,n: word; c,cc: char;
    unknown: array[1..8196] of byte;
begin write('Save current state of array? (y/n) ');
      repeat c:=upcase(readkey);
             if keypressed then cc:=readkey
      until (c='Y') or (c='N');
      writeln;
      if c='Y' then
      begin assign(f,fn);
            rewrite(f);
            write('Saving to '+fn+'... ');
            memReset(a);
            n:=memRec(a).bytesPerRecord;
            for i:=0 to memLast(a) do
            begin memRead(a,unknown);
                  for j:=1 to n do write(f,unknown[j])
            end;
            Close(f);
            writeln(' Array saved.')
      end;
end;

procedure Abort(var a: longArray; bytesNeeded: longint; msg: string);
begin with memRec(a) do
begin    writeln;
         write('Not enough space for '+msg+' of "'+name+'"');
         if dicPtr<>nil then
         writeln(' of dictionary "'+dicPtr^.name+'"')
         else writeln;
         writeln(bytesNeeded,' bytes needed, ',MaxAvail,' available');
         if dicPtr<>nil then
         begin SaveDic(dicPtr^,'ABORTED.DIC'); dicErase(dicPtr^);
         end
         else
         begin SaveMem(a,'ABORTED.MEM'); memErase(a)
         end;
         Halt(1);
end
end;

procedure SetFq(var st: string; fq: longint);
begin if length(st)>251 then st[0]:=#251;
      move(fq,st[length(st)+1],4); inc(st[0],4);
end;

procedure GetFq(var st: string; var fq: longint);
begin dec(st[0],4);
      move(st[length(st)+1],fq,4)
end;

procedure MemAssign(var a: longArray; st: string);
begin a.name:=st
end;

procedure MemReset(var a: longArray);
begin MemSeek(a,0)
end;

procedure MemAppend(var a: longArray);
begin MemSeek(a,MemFileSize(a))
end;

procedure MemRewrite(var a: longArray; items: longint; itemSize: word);
var i: word; expectedSize,n: longint;
begin
    FillChar(a.Private,SizeOf(a.Private),0);
    with memRec(a) do
begin
   bytesPerRecord:=itemSize;
   expectedSize:=items*bytesPerRecord;
   recordsPerRow:=65520 div bytesPerRecord;
   if recordsPerRow>items then recordsPerRow:=items;
   n:=32768; shift:=15;
   while (n>recordsPerRow) and (n>2) do begin n:=n div 2; dec(shift) end;
   mask:=(1 shl shift) -1;
   recordsPerRow:=n;
   bytesPerRow:=recordsPerRow * bytesPerRecord;
   lastRow:=items div recordsPerRow; (* first Row = 0 *)
   maxRecordsInArray:=longint(lastRow+1) * longint(recordsPerRow);
   lastRecord:=-1;
   bytesInIndex:=(lastRow+1)*sizeOf(pointer);
   GetMem(rowPtrNo,bytesInIndex);
   for i:=0 to lastRow do
   begin
         GetMem(rowPtrNo^[i],bytesPerRow);
         FillChar(rowPtrNo^[i]^,bytesPerRow,0)
   end;
end
end;

procedure MemExpand(var a: longArray; items: longint);
var newLastRow,bytesInNewIndex,i: word;
    newIndex_: anIndexPtr;
begin with memRec(a) do
begin
   newLastRow:=(items) div recordsPerRow;
   if newLastRow<=lastRow then exit;
   bytesInNewIndex:=(newLastRow+1)*sizeOf(pointer);
   if bytesInNewIndex>MaxAvail then Abort(a,bytesInNewIndex,' index ');


   GetMem(newIndex_,bytesInNewIndex);
   Move(rowPtrNo^,newIndex_^,bytesInIndex);
   FreeMem(rowPtrNo,bytesInIndex);
   rowPtrNo:=newIndex_;
   for i:=lastRow+1 to newLastRow do
   begin
         if bytesPerRow>MaxAvail then
         Abort(a,bytesPerRow,' data ');

         GetMem(rowPtrNo^[i],bytesPerRow);
         FillChar(rowPtrNo^[i]^,bytesPerRow,0);
   end;
   lastRow:=newLastRow;
   bytesInIndex:=bytesInNewIndex;
   maxRecordsInArray:=(lastRow+1)*recordsPerRow;
end
end;

procedure memReadString(var a: longArray; var st: string);
var row,col,lgth: word;
    stPtr: stringPtr;
begin with memRec(a) do
begin
      row:= pos shr shift;
      col:=(pos and mask);
      stPtr:=addr(rowPtrNo^[row]^[col]);
      lgth:=length(stPtr^)+1;
      Move(stPtr^,st,lgth);
      inc(pos,lgth);
end
end;

procedure memReadStringPtr(var a: longArray; var st: stringPtr);
var row,col: word;
begin with memRec(a) do
begin
      row:= pos shr shift;
      col:=(pos and mask);
      st:=addr(rowPtrNo^[row]^[col]);
end
end;

procedure MemWriteString(var a: longArray; st: string);
var row,col,lgth: word;
begin with memRec(a) do
begin lgth:=length(st)+1;
      row:= pos shr shift;
      col:=(pos and mask);
      if col+lgth>bytesPerRow-1
      then
      begin inc(row); col:=0;
            if row>lastRow then
            MemExpand(a,longint(row+1)*bytesPerRow);
      end;
      Move(st,rowPtrNo^[row]^[col],lgth);
      lastRecord:=longint(row)*bytesPerRow+col+lgth-1;
      pos:=lastRecord+1;
end
end;

procedure MemSeek(var a: longArray; item: longint);
begin with memRec(a) do
begin if (item<0) then Exit;
      if (item>maxRecordsInArray) then MemExpand(a,item);
      pos:=item;
end;
end;

procedure memMoveVar(var a: longArray; pos1,pos2,itemsToMove: longint);
var newlastRecord,newItemCapacity: longint;
    itemsFromSource,itemsIntoTarget: word;
    res, {Row of end of source }
    rss, {Row of start of source }
    css, {Col of start of source }
    ces, {Col of end of source }
    ret, {Row of end of target }
    cet  {Col of end of target }
    : word;
begin with MemRec(a) do
begin newlastRecord:=pos2+itemsToMove-1;
      if newLastRecord<lastRecord then newLastRecord:=lastRecord;
      newItemCapacity:=newlastRecord div recordsPerRow * recordsPerRow{-1};
      lastRecord:=newLastRecord;
      if newLastRecord>=maxRecordsInArray then
      begin MemExpand(a,newlastRecord);
      end;
      rss:=pos1 div recordsPerRow;
      css:= pos1 mod recordsPerRow;
      inc(pos1,itemsToMove-1); inc(pos2,itemsToMove-1);
      res:=pos1 div recordsPerRow;
      ret:=pos2 div recordsPerRow;
      ces:=pos1 mod recordsPerRow;
      cet:=pos2 mod recordsPerRow;
      repeat
             if rss=res then
             itemsFromSource:=itemsToMove
             else itemsFromSource:=ces+1;
             itemsIntoTarget:=cet+1;
             if itemsFromSource>itemsIntoTarget
             then itemsFromSource:=itemsIntoTarget;
                  Move(rowPtrNo^[res]^[bytesPerRecord*(ces+1-itemsFromSource)],
                  rowPtrNo^[ret]^[bytesPerRecord*(cet+1-itemsFromSource)],
                  itemsFromSource*bytesPerRecord);
             dec(itemsToMove,itemsFromSource);
             dec(pos1,itemsFromSource);
             res:=pos1 div recordsPerRow;
             ces:=pos1 mod recordsPerRow;
             dec(pos2,itemsFromSource);
             ret:=pos2 div recordsPerRow;
             cet:=pos2 mod recordsPerRow;
      until itemsToMove=0;
end
end;

procedure memPutVar(var a: longArray; var what);
var row,col: word;
    dummy: byte absolute what;
begin with memRec(a) do
begin
      if pos+1>maxRecordsInArray then BEGIN
        MemExpand(a,pos);
      END;
      if pos>lastRecord then lastRecord:=pos;
      row:= pos shr shift;
      col:=(pos and mask) * bytesPerRecord;
      Move(dummy,rowPtrNo^[row]^[col],bytesPerRecord);
end;
end;

procedure memInsertVar(var a: longArray; var what);
var row,col: word;
    dummy: byte absolute what;
begin with memRec(a) do
begin if pos<=lastRecord
      then memMoveVar(a,pos,pos+1,lastRecord-pos+1)
      else
      begin if pos+1>maxRecordsInArray then MemExpand(a,pos);
            if pos>lastRecord then lastRecord:=pos;
      end;
      row:= pos shr shift;
      col:=(pos and mask) * bytesPerRecord;
      Move(dummy,rowPtrNo^[row]^[col],bytesPerRecord);
end;
end;

procedure MemRead(var a: longArray; var item);
var row,col: word; dummy: byte absolute item;
begin with MemRec(a) do
begin
    if pos>lastRecord then FillChar(dummy,bytesPerRecord,0)
    else
    begin
      row:= pos shr shift;
      col:=(pos and mask) * bytesPerRecord;
      Move(rowPtrNo^[row]^[col],dummy,bytesPerRecord);
      inc(pos)
    end
end
end;

procedure MemGet(var a: longArray; var item);
var row,col: word; dummy: byte absolute item;
begin with MemRec(a) do
begin
    if pos>lastRecord then FillChar(dummy,bytesPerRecord,0)
    else
    begin
      row:= pos shr shift;
      col:=(pos and mask) * bytesPerRecord;
      Move(rowPtrNo^[row]^[col],dummy,bytesPerRecord);
    end
end
end;

procedure MemWrite(var a: longArray; var item);
var anon: byte absolute item;
begin with memRec(a) do
begin
       if insertMode then MemInsertVar(a,anon)
       else MemPutVar(a,anon);
       inc(pos)
end;
end;

procedure MemPut(var a: longArray; var item);
var anon: byte absolute item;
begin with memRec(a) do
begin if insertMode then MemInsertVar(a,anon)
      else MemPutVar(a,anon);
end;
end;

procedure MemSeekAndWrite(var a: longArray; i: longint; var item);
var anon: byte absolute item;
begin with memRec(a) do
begin pos:=i;
      if insertMode then MemInsertVar(a,anon)
      else MemPutVar(a,anon);
      inc(pos);
end;
end;

procedure MemSeekAndPut(var a: longArray; i: longint; var item);
var anon: byte absolute item;
begin with memRec(a) do
begin pos:=i;
      if insertMode then MemInsertVar(a,anon)
      else MemPutVar(a,anon);
end;
end;

procedure MemSeekAndRead(var a: longArray; i: longint; var item);
var row,col: word; dummy: byte absolute item;
begin with MemRec(a) do
begin pos:=i;
    if pos>lastRecord then FillChar(dummy,bytesPerRecord,0)
    else
    begin
      row:= pos shr shift;
      col:=(pos and mask) * bytesPerRecord;
      Move(rowPtrNo^[row]^[col],dummy,bytesPerRecord);
      inc(pos)
    end
end
end;

procedure MemSeekAndGet(var a: longArray; i: longint; var item);
var row,col: word; dummy: byte absolute item;
begin with MemRec(a) do
begin pos:=i;
    if pos>lastRecord then FillChar(dummy,bytesPerRecord,0)
    else
    begin
      row:= pos shr shift;
      col:=(pos and mask) * bytesPerRecord;
      Move(rowPtrNo^[row]^[col],dummy,bytesPerRecord);
    end
end
end;

procedure MemSetInsertMode(var a: longArray; onOff: boolean);
begin memRec(a).insertMode:=onOff
end;

procedure MemClose;
begin
end;

procedure MemErase(var a: longArray);
var i: word;
begin with MemRec(a) do
begin for i:=lastRow downto 0 do
      FreeMem(rowPtrNo^[i],bytesPerRow);
      FreeMem(rowPtrNo,bytesInIndex);
end
end;

function MemLast(var a: longArray): longint;
begin MemLast:=memRec(a).lastRecord
end;

function  MemFileSize(var a: longArray):longint;
begin MemFileSize:=memRec(a).lastRecord+1
end;

function  MemEof(var a: longArray): boolean;
begin with memRec(a) do MemEof:=pos>lastRecord;
end;

function  MemFilePos(var a: longArray): longint;
begin MemFilePos:=memRec(a).pos
end;

procedure dicAssign(var d: dictionary; st: string);
begin with d do
begin name:=st;
      memAssign(index,'index'); memAssign(corpus,'corpus');
end
end;

procedure dicReset(var d: dictionary);
begin dicSeek(d,0)
end;

procedure dicAppend(var d: dictionary);
begin dicSeek(d,dicFileSize(d))
end;

procedure dicRewrite(var d: dictionary; items: longint);
var null: string;
begin with d do
begin memRewrite(index,items,SizeOf(pointer));
      memSetInsertMode(index,true);
      items:=items*(expectedWordLength+5);
      if items<256 then items:=256;
      memRewrite(corpus,items,sizeOf(char));
      memRec(index).dicPtr:=@d;
      memRec(corpus).dicPtr:=@d;
end;
      null:='';
      dicPut(d,null);
end;

procedure dicClose;
begin
end;

procedure dicErase(var d: dictionary);
begin memErase(d.corpus); memErase(d.index)
end;

procedure dicSeek(var d: dictionary; item: longint);
begin memSeek(d.index,item)
end;

procedure dicFind(var d: dictionary; st: string; var foundPos: longint);
var lo,mid,hi,posInCorpus,oldPos: longint; found: boolean;
    tmpPtr: stringPtr; tmp: string;
begin with d do
begin found:=false; lo:=0; hi:=memFileSize(index)-1;
      oldPos:=memRec(corpus).pos;
      while (lo<=hi) and not found do
      begin mid:=(lo+hi) div 2;
         memSeekAndRead(index,mid,posInCorpus);
         memSeek(corpus,posInCorpus);
         memReadStringPtr(corpus,tmpPtr);
         tmp:=tmpPtr^;
         GetFq(tmp,frequency);
         if st>tmp then lo:=mid+1 else
         if st<tmp then hi:=mid-1 else
         if st=tmp then found:=true;
      end;
      if found then
      begin FoundPos:=mid;
            fqPtr:=longintPtr(longint(tmpPtr)+length(tmp)+1);
      end
      else foundPos:=-lo;
      memRec(corpus).pos:=oldPos;
end;
end;

procedure dicFindBetween(var d: dictionary; st: string; lo,hi: longint; var foundPos: longint);
var mid,posInCorpus,oldPos: longint; found: boolean;
    tmpPtr: stringPtr; tmp: string;
begin with d do
begin found:=false;
      if lo>hi then
      begin mid:=lo; lo:=hi; hi:=mid
      end;
      mid:=memFileSize(index)-1;
      if lo>mid then lo:=mid;
      if hi>mid then hi:=mid;
      oldPos:=memRec(corpus).pos;
      while (lo<=hi) and not found do
      begin mid:=(lo+hi) div 2;
         memSeekAndRead(index,mid,posInCorpus);
         memSeek(corpus,posInCorpus);
         memReadStringPtr(corpus,tmpPtr);
         tmp:=tmpPtr^;
         GetFq(tmp,frequency);
         if st>tmp then lo:=mid+1 else
         if st<tmp then hi:=mid-1 else
         if st=tmp then found:=true;
      end;
      if found then
      begin FoundPos:=mid;
            fqPtr:=longintPtr(longint(tmpPtr)+length(tmp)+1);
      end
      else foundPos:=-lo;
      memRec(corpus).pos:=oldPos;
end;
end;

procedure dicRead(var d: dictionary; var st: string);
var posInCorpus: longint;
begin with d do
begin memRead(index,posInCorpus);
      memSeek(corpus,posInCorpus);
      memReadString(corpus,st);
      GetFq(st,frequency);
end
end;

procedure dicGet(var d: dictionary; var st: string);
var posInCorpus: longint;
begin with d do
begin memGet(index,posInCorpus);
      memSeek(corpus,posInCorpus);
      memReadString(corpus,st);
      GetFq(st,frequency);
end
end;

procedure dicPut(var d: dictionary; st: string);
var indexPos: longint;
begin with d do
begin
      SetFq(st,1);
      memWriteString(corpus,st);
      indexPos:=memFileSize(corpus)-(length(st)+1);
      memWrite(index,indexPos);
end
end;

procedure dicSeekAndRead(var d: dictionary; i: longint; var st: string);
var posInCorpus: longint;
begin with d do
begin memSeekAndRead(index,i,posInCorpus);
      memSeek(corpus,posInCorpus);
      memReadString(corpus,st);
      GetFq(st,frequency);
end
end;

procedure dicSeekAndWrite(var d: dictionary; i: longint; st: string);
var corpusPos: longint;
begin with d do
begin SetFq(st,1);
      memWriteString(corpus,st);
      corpusPos:=memFilePos(corpus)-(length(st)+1);
      memSeekAndWrite(index,i,corpusPos);
end
end;


procedure dicSeekAndGet(var d: dictionary; i: longint; var st: string);
var posInCorpus: longint;
begin with d do
begin memSeekAndPut(index,i,posInCorpus);
      memSeek(corpus,posInCorpus);
      memReadString(corpus,st);
      GetFq(st,frequency);
end
end;

procedure dicSeekAndPut(var d: dictionary; i: longint; st: string);
var corpusPos: longint;
begin with d do
begin SetFq(st,1);
      memWriteString(corpus,st);
      corpusPos:=memFilePos(corpus)-(length(st)+1);
      memSeekAndPut(index,i,corpusPos);
end
end;

procedure dicWrite(var d: dictionary; st: string);
var i: longint;
begin dicFind(d,st,i);
      if i<0 then dicSeekAndWrite(d,-i,st)
      else inc(d.fqPtr^);
end;

procedure dicAdd(var d: dictionary; st: string; fq: longint);
var i: longint;
begin dicFind(d,st,i);
      if i<0 then
      begin SetFq(st,fq);
            dicSeekAndWrite(d,-i,st)
      end
      else
      begin inc(d.fqPtr^,fq);
            d.frequency:=d.fqPtr^
      end
end;

function dicLast(var d: dictionary): longint;
begin with d do dicLast:=memLast(index);
end;

function  dicFileSize(var d: dictionary):longint;
begin with d do dicFileSize:=memFileSize(index);
end;

function  dicFilePos(var d: dictionary): longint;
begin with d do dicFilePos:=memFilePos(index)
end;

function  dicEof(var d: dictionary): boolean;
begin with d do dicEof:=memEof(index)
end;
end.

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[lgarray.pas]컴�
