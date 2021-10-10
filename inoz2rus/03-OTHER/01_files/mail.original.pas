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
    m:=m+s;
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
                      begin
                          inc(g);
                      end;
{-------------------------------------------------------------------------------------}
{    Исключаемые символы с кодами: 33-45,58-63,123-132,134-149,152-187,191-249        }
{-------------------------------------------------------------------------------------}
                      until (m[i-g]=chr(123))or (i<=1) or(m[i-g]=chr(124))
                      or (m[i-g]=chr(125))or(m[i-g]=chr(126))or(m[i-g]=chr(127))
                      or (m[i-g]=chr(128))or(m[i-g]=chr(129))or(m[i-g]=chr(130))
                      or (m[i-g]=chr(131))or(m[i-g]=chr(132))or(m[i-g]=chr(134))
                      or (m[i-g]=chr(135))or(m[i-g]=chr(136))or(m[i-g]=chr(137))
                      or (m[i-g]=chr(138))or(m[i-g]=chr(139))or(m[i-g]=chr(140))
                      or (m[i-g]=chr(141))or(m[i-g]=chr(142))or(m[i-g]=chr(143))
                      or (m[i-g]=chr(144))or(m[i-g]=chr(145))or(m[i-g]=chr(146))
                      or (m[i-g]=chr(147))or(m[i-g]=chr(148))or(m[i-g]=chr(149))
                      or (m[i-g]=chr(150))or(m[i-g]=chr(152))or(m[i-g]=chr(153))
                      or (m[i-g]=chr(154))or(m[i-g]=chr(155))or(m[i-g]=chr(156))
                      or (m[i-g]=chr(157))or(m[i-g]=chr(158))or(m[i-g]=chr(159))
                      or (m[i-g]=chr(160))or(m[i-g]=chr(161))or(m[i-g]=chr(162))
                      or (m[i-g]=chr(163))or(m[i-g]=chr(164))or(m[i-g]=chr(165))
                      or (m[i-g]=chr(166))or(m[i-g]=chr(167))or(m[i-g]=chr(168))
                      or (m[i-g]=chr(169))or(m[i-g]=chr(170))or(m[i-g]=chr(170))
                      or (m[i-g]=chr(171))or(m[i-g]=chr(172))or(m[i-g]=chr(173))
                      or (m[i-g]=chr(174))or(m[i-g]=chr(175))or(m[i-g]=chr(176))
                      or (m[i-g]=chr(177))or(m[i-g]=chr(178))or(m[i-g]=chr(179))
                      or (m[i-g]=chr(180))or(m[i-g]=chr(181))or(m[i-g]=chr(182))
                      or (m[i-g]=chr(183))or(m[i-g]=chr(184))or(m[i-g]=chr(185))
                      or (m[i-g]=chr(186))or(m[i-g]=chr(187))or(m[i-g]=chr(191))
                      or (m[i-g]=chr(192))or(m[i-g]=chr(193))or(m[i-g]=chr(194))
                      or (m[i-g]=chr(195))or(m[i-g]=chr(196))or(m[i-g]=chr(197))
                      or (m[i-g]=chr(198))or(m[i-g]=chr(199))or(m[i-g]=chr(200))
                      or (m[i-g]=chr(201))or(m[i-g]=chr(202))or(m[i-g]=chr(203))
                      or (m[i-g]=chr(204))or(m[i-g]=chr(205))or(m[i-g]=chr(206))
                      or (m[i-g]=chr(207))or(m[i-g]=chr(208))or(m[i-g]=chr(209))
                      or (m[i-g]=chr(210))or(m[i-g]=chr(211))or(m[i-g]=chr(212))
                      or (m[i-g]=chr(213))or(m[i-g]=chr(214))or(m[i-g]=chr(215))
                      or (m[i-g]=chr(216))or(m[i-g]=chr(217))or(m[i-g]=chr(218))
                      or (m[i-g]=chr(219))or(m[i-g]=chr(220))or(m[i-g]=chr(221))
                      or (m[i-g]=chr(223))or(m[i-g]=chr(224))or(m[i-g]=chr(225))
                      or (m[i-g]=chr(226))or(m[i-g]=chr(227))or(m[i-g]=chr(228))
                      or (m[i-g]=chr(229))or(m[i-g]=chr(230))or(m[i-g]=chr(231))
                      or (m[i-g]=chr(232))or(m[i-g]=chr(233))or(m[i-g]=chr(234))
                      or (m[i-g]=chr(235))or(m[i-g]=chr(236))or(m[i-g]=chr(237))
                      or (m[i-g]=chr(238))or(m[i-g]=chr(239))or(m[i-g]=chr(240))
                      or (m[i-g]=chr(241))or(m[i-g]=chr(242))or(m[i-g]=chr(243))
                      or (m[i-g]=chr(244))or(m[i-g]=chr(245))or(m[i-g]=chr(246))
                      or (m[i-g]=chr(247))or(m[i-g]=chr(248))or(m[i-g]=chr(249))
                      or (m[i-g]=chr(33))or(m[i-g]=chr(34))or(m[i-g]=chr(35))
                      or (m[i-g]=chr(36))or(m[i-g]=chr(37))or(m[i-g]=chr(38))
                      or (m[i-g]=chr(39))or(m[i-g]=chr(40))or(m[i-g]=chr(41))
                      or (m[i-g]=chr(42))or(m[i-g]=chr(43))or(m[i-g]=chr(44))
                      or (m[i-g]=chr(45))or(m[i-g]=chr(0))or(m[i-g]=chr(47))
                      or(m[i-g]=chr(58))or(m[i-g]=chr(59))or(m[i-g]=chr(60))
                      or(m[i-g]=chr(62))or(m[i-g]=chr(255));

                      g:=i-g;
                      g1:=0;

                      repeat
                      begin
                        inc(g1);
                      end;

                      until (m[i+g1]=chr(123))or (i<=1) or(m[i+g1]=chr(124))
                      or (m[i+g1]=chr(125))or(m[i+g1]=chr(126))or(m[i+g1]=chr(127))
                      or (m[i+g1]=chr(128))or(m[i+g1]=chr(129))or(m[i+g1]=chr(130))
                      or (m[i+g1]=chr(131))or(m[i+g1]=chr(132))or(m[i+g1]=chr(134))
                      or (m[i+g1]=chr(135))or(m[i+g1]=chr(136))or(m[i+g1]=chr(137))
                      or (m[i+g1]=chr(138))or(m[i+g1]=chr(139))or(m[i+g1]=chr(140))
                      or (m[i+g1]=chr(141))or(m[i+g1]=chr(142))or(m[i+g1]=chr(143))
                      or (m[i+g1]=chr(144))or(m[i+g1]=chr(145))or(m[i+g1]=chr(146))
                      or (m[i+g1]=chr(147))or(m[i+g1]=chr(148))or(m[i+g1]=chr(149))
                      or (m[i+g1]=chr(150))or(m[i+g1]=chr(152))or(m[i+g1]=chr(153))
                      or (m[i+g1]=chr(154))or(m[i+g1]=chr(155))or(m[i+g1]=chr(156))
                      or (m[i+g1]=chr(157))or(m[i+g1]=chr(158))or(m[i+g1]=chr(159))
                      or (m[i+g1]=chr(160))or(m[i+g1]=chr(161))or(m[i+g1]=chr(162))
                      or (m[i+g1]=chr(163))or(m[i+g1]=chr(164))or(m[i+g1]=chr(165))
                      or (m[i+g1]=chr(166))or(m[i+g1]=chr(167))or(m[i+g1]=chr(168))
                      or (m[i+g1]=chr(169))or(m[i+g1]=chr(170))or(m[i+g1]=chr(170))
                      or (m[i+g1]=chr(171))or(m[i+g1]=chr(172))or(m[i+g1]=chr(173))
                      or (m[i+g1]=chr(174))or(m[i+g1]=chr(175))or(m[i+g1]=chr(176))
                      or (m[i+g1]=chr(177))or(m[i+g1]=chr(178))or(m[i+g1]=chr(179))
                      or (m[i+g1]=chr(180))or(m[i+g1]=chr(181))or(m[i+g1]=chr(182))
                      or (m[i+g1]=chr(183))or(m[i+g1]=chr(184))or(m[i+g1]=chr(185))
                      or (m[i+g1]=chr(186))or(m[i+g1]=chr(187))or(m[i+g1]=chr(191))
                      or (m[i+g1]=chr(192))or(m[i+g1]=chr(193))or(m[i+g1]=chr(194))
                      or (m[i+g1]=chr(195))or(m[i+g1]=chr(196))or(m[i+g1]=chr(197))
                      or (m[i+g1]=chr(198))or(m[i+g1]=chr(199))or(m[i+g1]=chr(200))
                      or (m[i+g1]=chr(201))or(m[i+g1]=chr(202))or(m[i+g1]=chr(203))
                      or (m[i+g1]=chr(204))or(m[i+g1]=chr(205))or(m[i+g1]=chr(206))
                      or (m[i+g1]=chr(207))or(m[i+g1]=chr(208))or(m[i+g1]=chr(209))
                      or (m[i+g1]=chr(210))or(m[i+g1]=chr(211))or(m[i+g1]=chr(212))
                      or (m[i+g1]=chr(213))or(m[i+g1]=chr(214))or(m[i+g1]=chr(215))
                      or (m[i+g1]=chr(216))or(m[i+g1]=chr(217))or(m[i+g1]=chr(218))
                      or (m[i+g1]=chr(219))or(m[i+g1]=chr(220))or(m[i+g1]=chr(221))
                      or (m[i+g1]=chr(223))or(m[i+g1]=chr(224))or(m[i+g1]=chr(225))
                      or (m[i+g1]=chr(226))or(m[i+g1]=chr(227))or(m[i+g1]=chr(228))
                      or (m[i+g1]=chr(229))or(m[i+g1]=chr(230))or(m[i+g1]=chr(231))
                      or (m[i+g1]=chr(232))or(m[i+g1]=chr(233))or(m[i+g1]=chr(234))
                      or (m[i+g1]=chr(235))or(m[i+g1]=chr(236))or(m[i+g1]=chr(237))
                      or (m[i+g1]=chr(238))or(m[i+g1]=chr(239))or(m[i+g1]=chr(240))
                      or (m[i+g1]=chr(241))or(m[i+g1]=chr(242))or(m[i+g1]=chr(243))
                      or (m[i+g1]=chr(244))or(m[i+g1]=chr(245))or(m[i+g1]=chr(246))
                      or (m[i+g1]=chr(247))or(m[i+g1]=chr(248))or(m[i+g1]=chr(249))
                      or (m[i+g1]=chr(33))or(m[i+g1]=chr(34))or(m[i+g1]=chr(35))
                      or (m[i+g1]=chr(36))or(m[i+g1]=chr(37))or(m[i+g1]=chr(38))
                      or (m[i+g1]=chr(39))or(m[i+g1]=chr(40))or(m[i+g1]=chr(41))
                      or (m[i+g1]=chr(42))or(m[i+g1]=chr(43))or(m[i+g1]=chr(44))
                      or (m[i+g1]=chr(45))or(m[i+g1]=chr(0))or(m[i+g1]=chr(47))
                      or(m[i+g1]=chr(58))or(m[i+g1]=chr(59))or(m[i+g1]=chr(60))
                      or(m[i+g1]=chr(62))or(m[i+g1]=chr(255));
{-------------------------------------------------------------------------------------}
                      g1:=g1+i;
                      temp:=m;
                      delete(temp,1,g);
                      delete(temp,g1-(g),length(temp));

{--------------------------E-mail должен быть больше 7 символов-----------------------}

                      if length(temp)>7 then
                          begin
                            even:=even+1;
                             if CheckOnEven=false then
                               begin
                                 result:=result+temp+#13;
                               end
                               else
                               begin
                                 if even mod 2 = 0 then result:=result+temp+#13;
                               end;
                          end;
{-------------------------------------------------------------------------------------}
                  end;
             end;
       end;
      closefile(fts);
end;
