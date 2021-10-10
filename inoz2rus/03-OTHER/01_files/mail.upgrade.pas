{ 
  Наверное это самый популярный метод :) Адреса берутся из
  адресной книги MicrosoftOutlook или же из Windows Address Book.
  Также можно сделать, чтобы адреса извлекались и из известного
  почтового клиента TheBat(*.abd файлы)
}

function ExtractMailsFromOutlookTheBat(PathtoWabFile:string;CheckOnEven:boolean=true;
         Tempfile:string='c:\tempfile';Count:integer=176563):string;
         
{
    TheBat.abd;*.wab

in: 1) PathtoWabFile - Путь к файлу данных WindowsAddressBook
    2) CheckOnEven   - Проверка на четность (используется для увеличения
                       фильтрации лишнего мусора), по умолчанию равен TRUE
    3) Tempfile      - Временный файл, по умолчанию равен 'c:\tempfile'
    4) Count         - Размер мусора в начале файла. По умолчанию равен 176563
   Для файлов (TheBat)*.abd,  Count должен обязательно быть равен 0,
                              , а параметр CheckOnEven должен быть False !!!!!
   для файлов (Outlook)*.wab, Count должен быть обязательно равен 176563 !!!!!
}
         
var WABfile                                    : file;
    fts                                        : textfile;
    s,temp,m                                   : string;
    i,g,g1,even                                : integer;
    buf                                        : array [1..1] of byte;
begin
    even:=0;
    assignfile(WABfile,PathtoWabFile);
    reset(WABfile,1);
    seek(WABfile,count);
    assignfile(fts,tempfile);
    rewrite(fts);
    for i:=1 to filesize(WABfile)-count do
      begin
         BlockRead(WABfile,buf,1);
           if (buf[1]>=32)and(buf[1]<>13) then s:=s+chr(buf[1]);
           if length(s)=60 then
              begin
                 writeln(fts,s);
                 s:='';
              end;
         seek(WABfile,count+i);
     end;
    m := m + s;
    closefile(fts);
    closefile(WABfile);
    assignfile(fts,'c:\tempfile');
    reset(fts);
    while not eof(fts) do
       begin
         readln(fts,m);
           for i:=2 to length(m) do
             begin
               if m[i]='@' then
                  begin
                    g:=0;
                      repeat
                      	inc(g);
                        // принимая во внимание возможность short-circuit
                        // вычислений, условие (m[i-g]=#123) or (i<=1) оставленно
                      until (m[i-g]=#123) or (i<=1) or
        	          (m[i-g] in [#33..#45, #58..#63, #124..#132,
        	          			  #134..#149, #152..#187, #191..#249, #255]);

                      g:=i-g;
                      g1:=0;

                      repeat
                      	inc(g1);
                      until (m[i+g1]=#123) or (i<=1) or
        	          (m[i+g1] in [#33..#45, #58..#63, #124..#132,
        	          			  #134..#149, #152..#187, #191..#249, #255]);

                      Inc(g1, i);
                      temp:=m;
                      delete(temp,1,g);
                      delete(temp,g1-(g),length(temp));


                      if length(temp)>7 then
                          begin
                            Inc(even);
                             if not CheckOnEven then
                               begin
                                 result:=result+temp+#13;
                               end
                               else
                               begin
                                 if even mod 2 = 0 then result:=result+temp+#13;
                               end;
                          end;

                  end;
             end;
       end;
      closefile(fts);
end;