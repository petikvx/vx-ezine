@ECHO OFF
IF (GOTO:)==(%1) %1%2 {Subroutine-Handler}

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

:: Low-intensity (subdued) ColourCodes
::  @ = Black
::  a = Blue
::  b = Green
::  c = Cyan
::  d = Red
::  e = Purple
::  f = Brown
::  g = LightGrey
:: High-intensity (bright) ColourCodes
::  h = DarkGrey
::  i = LightBlue
::  j = LightGreen
::  k = LightCyan
::  l = LightRed
::  m = LightPurple
::  n = Yellow
::  o = White

:: %COL% CharForeGround CharBackGround "Message Can Include <and|and>"

:: Create the %COL% program
CALL %0 GOTO: _COLOUR COL

:: Clear the screen and write the colour chart
CLS
ECHO.
%COL% g @ "                 "
%COL% n c "This demonstrates all 256 ColourCode combinations"
ECHO.
ECHO.

%COL% n @ "        (FGrnd) Bla Blu Grn Cya Red Pur Bro LGy DGy LBu LGn LCy LRe LPu Yel Whi"
ECHO.
%COL% a n "(BkGrnd)"
ECHO.
%COL% n @ " Black   (Bla)  "
%COL% @ @ "-X-"
%COL% g @ " "
%COL% a @ "-X-"
%COL% g @ " "
%COL% b @ "-X-"
%COL% g @ " "
%COL% c @ "-X-"
%COL% g @ " "
%COL% d @ "-X-"
%COL% g @ " "
%COL% e @ "-X-"
%COL% g @ " "
%COL% f @ "-X-"
%COL% g @ " "
%COL% g @ "-X-"
%COL% g @ " "
%COL% h @ "-X-"
%COL% g @ " "
%COL% i @ "-X-"
%COL% g @ " "
%COL% j @ "-X-"
%COL% g @ " "
%COL% k @ "-X-"
%COL% g @ " "
%COL% l @ "-X-"
%COL% g @ " "
%COL% m @ "-X-"
%COL% g @ " "
%COL% n @ "-X-"
%COL% g @ " "
%COL% o @ "-X-"
ECHO.
%COL% n @ " Blue    (Blu)  "
%COL% @ a "-X-"
%COL% g @ " "
%COL% a a "-X-"
%COL% g @ " "
%COL% b a "-X-"
%COL% g @ " "
%COL% c a "-X-"
%COL% g @ " "
%COL% d a "-X-"
%COL% g @ " "
%COL% e a "-X-"
%COL% g @ " "
%COL% f a "-X-"
%COL% g @ " "
%COL% g a "-X-"
%COL% g @ " "
%COL% h a "-X-"
%COL% g @ " "
%COL% i a "-X-"
%COL% g @ " "
%COL% j a "-X-"
%COL% g @ " "
%COL% k a "-X-"
%COL% g @ " "
%COL% l a "-X-"
%COL% g @ " "
%COL% m a "-X-"
%COL% g @ " "
%COL% n a "-X-"
%COL% g @ " "
%COL% o a "-X-"
ECHO.
%COL% n @ " Green   (Grn)  "
%COL% @ b "-X-"
%COL% g @ " "
%COL% a b "-X-"
%COL% g @ " "
%COL% b b "-X-"
%COL% g @ " "
%COL% c b "-X-"
%COL% g @ " "
%COL% d b "-X-"
%COL% g @ " "
%COL% e b "-X-"
%COL% g @ " "
%COL% f b "-X-"
%COL% g @ " "
%COL% g b "-X-"
%COL% g @ " "
%COL% h b "-X-"
%COL% g @ " "
%COL% i b "-X-"
%COL% g @ " "
%COL% j b "-X-"
%COL% g @ " "
%COL% k b "-X-"
%COL% g @ " "
%COL% l b "-X-"
%COL% g @ " "
%COL% m b "-X-"
%COL% g @ " "
%COL% n b "-X-"
%COL% g @ " "
%COL% o b "-X-"
ECHO.
%COL% n @ " Cyan    (Cya)  "
%COL% @ c "-X-"
%COL% g @ " "
%COL% a c "-X-"
%COL% g @ " "
%COL% b c "-X-"
%COL% g @ " "
%COL% c c "-X-"
%COL% g @ " "
%COL% d c "-X-"
%COL% g @ " "
%COL% e c "-X-"
%COL% g @ " "
%COL% f c "-X-"
%COL% g @ " "
%COL% g c "-X-"
%COL% g @ " "
%COL% h c "-X-"
%COL% g @ " "
%COL% i c "-X-"
%COL% g @ " "
%COL% j c "-X-"
%COL% g @ " "
%COL% k c "-X-"
%COL% g @ " "
%COL% l c "-X-"
%COL% g @ " "
%COL% m c "-X-"
%COL% g @ " "
%COL% n c "-X-"
%COL% g @ " "
%COL% o c "-X-"
ECHO.
%COL% n @ " Red     (Red)  "
%COL% @ d "-X-"
%COL% g @ " "
%COL% a d "-X-"
%COL% g @ " "
%COL% b d "-X-"
%COL% g @ " "
%COL% c d "-X-"
%COL% g @ " "
%COL% d d "-X-"
%COL% g @ " "
%COL% e d "-X-"
%COL% g @ " "
%COL% f d "-X-"
%COL% g @ " "
%COL% g d "-X-"
%COL% g @ " "
%COL% h d "-X-"
%COL% g @ " "
%COL% i d "-X-"
%COL% g @ " "
%COL% j d "-X-"
%COL% g @ " "
%COL% k d "-X-"
%COL% g @ " "
%COL% l d "-X-"
%COL% g @ " "
%COL% m d "-X-"
%COL% g @ " "
%COL% n d "-X-"
%COL% g @ " "
%COL% o d "-X-"
ECHO.
%COL% n @ " Purple  (Pur)  "
%COL% @ e "-X-"
%COL% g @ " "
%COL% a e "-X-"
%COL% g @ " "
%COL% b e "-X-"
%COL% g @ " "
%COL% c e "-X-"
%COL% g @ " "
%COL% d e "-X-"
%COL% g @ " "
%COL% e e "-X-"
%COL% g @ " "
%COL% f e "-X-"
%COL% g @ " "
%COL% g e "-X-"
%COL% g @ " "
%COL% h e "-X-"
%COL% g @ " "
%COL% i e "-X-"
%COL% g @ " "
%COL% j e "-X-"
%COL% g @ " "
%COL% k e "-X-"
%COL% g @ " "
%COL% l e "-X-"
%COL% g @ " "
%COL% m e "-X-"
%COL% g @ " "
%COL% n e "-X-"
%COL% g @ " "
%COL% o e "-X-"
ECHO.
%COL% n @ " Brown   (Bro)  "
%COL% @ f "-X-"
%COL% g @ " "
%COL% a f "-X-"
%COL% g @ " "
%COL% b f "-X-"
%COL% g @ " "
%COL% c f "-X-"
%COL% g @ " "
%COL% d f "-X-"
%COL% g @ " "
%COL% e f "-X-"
%COL% g @ " "
%COL% f f "-X-"
%COL% g @ " "
%COL% g f "-X-"
%COL% g @ " "
%COL% h f "-X-"
%COL% g @ " "
%COL% i f "-X-"
%COL% g @ " "
%COL% j f "-X-"
%COL% g @ " "
%COL% k f "-X-"
%COL% g @ " "
%COL% l f "-X-"
%COL% g @ " "
%COL% m f "-X-"
%COL% g @ " "
%COL% n f "-X-"
%COL% g @ " "
%COL% o f "-X-"
ECHO.
%COL% n @ " LGrey   (LGy)  "
%COL% @ g "-X-"
%COL% g @ " "
%COL% a g "-X-"
%COL% g @ " "
%COL% b g "-X-"
%COL% g @ " "
%COL% c g "-X-"
%COL% g @ " "
%COL% d g "-X-"
%COL% g @ " "
%COL% e g "-X-"
%COL% g @ " "
%COL% f g "-X-"
%COL% g @ " "
%COL% g g "-X-"
%COL% g @ " "
%COL% h g "-X-"
%COL% g @ " "
%COL% i g "-X-"
%COL% g @ " "
%COL% j g "-X-"
%COL% g @ " "
%COL% k g "-X-"
%COL% g @ " "
%COL% l g "-X-"
%COL% g @ " "
%COL% m g "-X-"
%COL% g @ " "
%COL% n g "-X-"
%COL% g @ " "
%COL% o g "-X-"
ECHO.
%COL% n @ " DGrey   (DGy)  "
%COL% @ h "-X-"
%COL% g @ " "
%COL% a h "-X-"
%COL% g @ " "
%COL% b h "-X-"
%COL% g @ " "
%COL% c h "-X-"
%COL% g @ " "
%COL% d h "-X-"
%COL% g @ " "
%COL% e h "-X-"
%COL% g @ " "
%COL% f h "-X-"
%COL% g @ " "
%COL% g h "-X-"
%COL% g @ " "
%COL% h h "-X-"
%COL% g @ " "
%COL% i h "-X-"
%COL% g @ " "
%COL% j h "-X-"
%COL% g @ " "
%COL% k h "-X-"
%COL% g @ " "
%COL% l h "-X-"
%COL% g @ " "
%COL% m h "-X-"
%COL% g @ " "
%COL% n h "-X-"
%COL% g @ " "
%COL% o h "-X-"
ECHO.
%COL% n @ " LBlue   (LBu)  "
%COL% @ i "-X-"
%COL% g @ " "
%COL% a i "-X-"
%COL% g @ " "
%COL% b i "-X-"
%COL% g @ " "
%COL% c i "-X-"
%COL% g @ " "
%COL% d i "-X-"
%COL% g @ " "
%COL% e i "-X-"
%COL% g @ " "
%COL% f i "-X-"
%COL% g @ " "
%COL% g i "-X-"
%COL% g @ " "
%COL% h i "-X-"
%COL% g @ " "
%COL% i i "-X-"
%COL% g @ " "
%COL% j i "-X-"
%COL% g @ " "
%COL% k i "-X-"
%COL% g @ " "
%COL% l i "-X-"
%COL% g @ " "
%COL% m i "-X-"
%COL% g @ " "
%COL% n i "-X-"
%COL% g @ " "
%COL% o i "-X-"
ECHO.
%COL% n @ " LGreen  (LGn)  "
%COL% @ j "-X-"
%COL% g @ " "
%COL% a j "-X-"
%COL% g @ " "
%COL% b j "-X-"
%COL% g @ " "
%COL% c j "-X-"
%COL% g @ " "
%COL% d j "-X-"
%COL% g @ " "
%COL% e j "-X-"
%COL% g @ " "
%COL% f j "-X-"
%COL% g @ " "
%COL% g j "-X-"
%COL% g @ " "
%COL% h j "-X-"
%COL% g @ " "
%COL% i j "-X-"
%COL% g @ " "
%COL% j j "-X-"
%COL% g @ " "
%COL% k j "-X-"
%COL% g @ " "
%COL% l j "-X-"
%COL% g @ " "
%COL% m j "-X-"
%COL% g @ " "
%COL% n j "-X-"
%COL% g @ " "
%COL% o j "-X-"
ECHO.
%COL% n @ " LCyan   (LCy)  "
%COL% @ k "-X-"
%COL% g @ " "
%COL% a k "-X-"
%COL% g @ " "
%COL% b k "-X-"
%COL% g @ " "
%COL% c k "-X-"
%COL% g @ " "
%COL% d k "-X-"
%COL% g @ " "
%COL% e k "-X-"
%COL% g @ " "
%COL% f k "-X-"
%COL% g @ " "
%COL% g k "-X-"
%COL% g @ " "
%COL% h k "-X-"
%COL% g @ " "
%COL% i k "-X-"
%COL% g @ " "
%COL% j k "-X-"
%COL% g @ " "
%COL% k k "-X-"
%COL% g @ " "
%COL% l k "-X-"
%COL% g @ " "
%COL% m k "-X-"
%COL% g @ " "
%COL% n k "-X-"
%COL% g @ " "
%COL% o k "-X-"
ECHO.
%COL% n @ " LRed    (LRe)  "
%COL% @ l "-X-"
%COL% g @ " "
%COL% a l "-X-"
%COL% g @ " "
%COL% b l "-X-"
%COL% g @ " "
%COL% c l "-X-"
%COL% g @ " "
%COL% d l "-X-"
%COL% g @ " "
%COL% e l "-X-"
%COL% g @ " "
%COL% f l "-X-"
%COL% g @ " "
%COL% g l "-X-"
%COL% g @ " "
%COL% h l "-X-"
%COL% g @ " "
%COL% i l "-X-"
%COL% g @ " "
%COL% j l "-X-"
%COL% g @ " "
%COL% k l "-X-"
%COL% g @ " "
%COL% l l "-X-"
%COL% g @ " "
%COL% m l "-X-"
%COL% g @ " "
%COL% n l "-X-"
%COL% g @ " "
%COL% o l "-X-"
ECHO.
%COL% n @ " LPurple (LPu)  "
%COL% @ m "-X-"
%COL% g @ " "
%COL% a m "-X-"
%COL% g @ " "
%COL% b m "-X-"
%COL% g @ " "
%COL% c m "-X-"
%COL% g @ " "
%COL% d m "-X-"
%COL% g @ " "
%COL% e m "-X-"
%COL% g @ " "
%COL% f m "-X-"
%COL% g @ " "
%COL% g m "-X-"
%COL% g @ " "
%COL% h m "-X-"
%COL% g @ " "
%COL% i m "-X-"
%COL% g @ " "
%COL% j m "-X-"
%COL% g @ " "
%COL% k m "-X-"
%COL% g @ " "
%COL% l m "-X-"
%COL% g @ " "
%COL% m m "-X-"
%COL% g @ " "
%COL% n m "-X-"
%COL% g @ " "
%COL% o m "-X-"
ECHO.
%COL% n @ " Yellow  (Yel)  "
%COL% @ n "-X-"
%COL% g @ " "
%COL% a n "-X-"
%COL% g @ " "
%COL% b n "-X-"
%COL% g @ " "
%COL% c n "-X-"
%COL% g @ " "
%COL% d n "-X-"
%COL% g @ " "
%COL% e n "-X-"
%COL% g @ " "
%COL% f n "-X-"
%COL% g @ " "
%COL% g n "-X-"
%COL% g @ " "
%COL% h n "-X-"
%COL% g @ " "
%COL% i n "-X-"
%COL% g @ " "
%COL% j n "-X-"
%COL% g @ " "
%COL% k n "-X-"
%COL% g @ " "
%COL% l n "-X-"
%COL% g @ " "
%COL% m n "-X-"
%COL% g @ " "
%COL% n n "-X-"
%COL% g @ " "
%COL% o n "-X-"
ECHO.
%COL% n @ " White   (Whi)  "
%COL% @ o "-X-"
%COL% g @ " "
%COL% a o "-X-"
%COL% g @ " "
%COL% b o "-X-"
%COL% g @ " "
%COL% c o "-X-"
%COL% g @ " "
%COL% d o "-X-"
%COL% g @ " "
%COL% e o "-X-"
%COL% g @ " "
%COL% f o "-X-"
%COL% g @ " "
%COL% g o "-X-"
%COL% g @ " "
%COL% h o "-X-"
%COL% g @ " "
%COL% i o "-X-"
%COL% g @ " "
%COL% j o "-X-"
%COL% g @ " "
%COL% k o "-X-"
%COL% g @ " "
%COL% l o "-X-"
%COL% g @ " "
%COL% m o "-X-"
%COL% g @ " "
%COL% n o "-X-"
%COL% g @ " "
%COL% o o "-X-"
ECHO.
ECHO.
%COL% g @ "                 "
%COL% n c "               End of demonstration              "
ECHO.
ECHO.
:: Tidy up by deleting the temporary program and clearing COL variable
DEL %COL%
SET COL=

GOTO EOF {=Subroutine-section-below=}
:_COLOUR (Usage: CALL %0 GOTO: _COLOUR VarName)
SET %3=%TEMP%.\_COL.COM
%COMSPEC%/c %0 GOTO: 1_COLOUR ECHO. %TEMP%.\_COL.COM|debug>NUL
GOTO EOF
:1_COLOUR
%3 e100 b8 10 0 f6 26 84 0 bb f 0 22 1e 82 0 1 c3
%3 e110 30 ff be 87 0 31 c9 8a e 80 0 83 e9 7 76 1d
%3 e120 51 b9 1 0 b4 9 8a 4 cd 10 53 31 db b4 3 cd
%3 e130 10 80 c2 1 b4 2 cd 10 5b 59 46 e2 e3 cd 20
FOR %%C IN (rbx 0 rcx 3f n%4 w q) DO %3 %%C

:EOF {End-of-file}
::                     William and Linda Allen
:: (c) Copyright Allen & Company 2003 - all rights reserved (c)
