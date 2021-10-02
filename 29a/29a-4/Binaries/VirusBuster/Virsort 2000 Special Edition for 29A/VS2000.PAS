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
