program MailRipper;
const
    CF   :array [0..9]  of string  = ('0','1','2','3','4','5','6','7','8','9');
    WordG:array [0..7]  of string  = ('e','y','u','i','o','a','-','_');
    WordS:array [0..21] of string  = ('q','w','r','t','p','s','d','f',
                                      'g','h','j','k','l','z','x','c',
                                      'v','b','n','m','-','_');
    Slogi:array [0..155]of string  = ('be','by','bu','bi','bo','ba',
                                      'ce','cy','cu','ci','co','ca',
                                      'de','dy','du','di','do','da',
                                      'fe','fy','fu','fi','fo','fa',
                                      'he','hy','hu','hi','ho','ha',
                                      'qe','qy','qu','qi','qo','qa',
                                      'we','wy','wu','wi','wo','wa',
                                      're','ry','ru','ri','ro','ra',
                                      'te','ty','tu','ti','to','ta',
                                      'pe','py','pu','pi','po','pa',
                                      'se','sy','su','si','so','sa',
                                      'de','dy','du','di','do','da',
                                      'fe','fy','fu','fi','fo','fa',
                                      'ge','gy','gu','gi','go','ga',
                                      'he','hy','hu','hi','ho','ha',
                                      'je','jy','ju','ji','jo','ja',
                                      'he','hy','hu','hi','ho','ha',
                                      'ke','ky','ku','ki','ko','ka',
                                      'le','ly','lu','li','lo','la',
                                      'ze','zy','zu','zi','zo','za',
                                      'xe','xy','xu','xi','xo','xa',
                                      'ce','cy','cu','ci','co','ca',
                                      've','vy','vu','vi','vo','va',
                                      'be','by','bu','bi','bo','ba',
                                      'ne','ny','nu','ni','no','na',
                                      'me','my','mu','mi','mo','ma');

    ServerName:array[0..11]of string=('mailru.com','mail.com','mail.ru','hotbox.ru',
                         'hotmail.com','yahoo.com','yandex.ru','xakep.ru','ukr.net',
                         'freemail.ru','yahoo.com.ua','chat.ru');

function M_generate:string;
var  i,CountChar,IndexSL,IndexWSG,IndexWGL,IndexCH,SN:integer;
begin
     result:='';
     while CountChar<1 do CountChar:=random(6);
     SN:=random(11);
     IndexWSG:=random(21);
     IndexWGL:=random(7);
     i:=random(1);
       case i of
        0: begin
                result:=result+(WordS[IndexWGL]+WordG[IndexWSG]);
                for i:=2 to CountChar do
                    begin
                       IndexSL:=random(156);
                       Result:=result+slogi[IndexSL];
                    end;
           end;
       1: begin
                result:=result+(WordG[IndexWSG]+WordS[IndexWGL]+CF[random(9)]);
                for i:=2 to CountChar do
                    begin
                       randomize;
                       IndexSL:=random(156);
                       Result:=result+slogi[IndexSL];
                    end;
           end;
       end;
       Result:=Result+'@'+ServerName[SN];
end;
var f:text;
    b:integer;
    mails:string;
begin
     randomize;
     writeln('Enter quantity of addresses....');
     readln(b);
     assign(f,'mails.txt');
     rewrite(f);
     while b<>0 do
       begin
         dec(b);
         mails:=mails+m_generate+#13;
       end;
     writeln(f,mails);
     closefile(f);
     writeln('Press any key....');
     readln;
end.