#!/bin/sh
#
#

TARGET=/rltd/WWW/DocRoot/sourceofkaos/cgi-bin/mos/a.out
TOPSTUFF='Content-type: text/html

<HTML>
<HEAD>
<TITLE>Source Of Kaos - MOS-REHU</TITLE>
</HEAD>
<BODY BGCOLOR="#e8e8ff">
<P ALIGN=Left>
'
if [ -x $TARGET ]; then
        if [ $# = 0 ]; then
                echo "$TOPSTUFF<H1>Mass O Shit Online Virus Generator</H1>"
		$TARGET 2>&1
	fi
else 
	echo AcK: somethings wrong ..
	fi
