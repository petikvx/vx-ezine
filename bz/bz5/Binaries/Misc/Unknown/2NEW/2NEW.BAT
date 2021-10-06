@ECHO OFF
REM If your last disk drive is less than F:, remove the
REM non-existent letters from the two FOR commands that follow.
REM If your last disk drive is more than F:, add letters
REM as necessary to the two FOR commands that follow.
FOR %%h IN (a A b B c C d D e E f F) DO IF (%1) == (%%h) %%h:
FOR %%k IN (a A b B c C d D e E f F) DO IF (%1) == (%%k) SHIFT
CTTY NUL
REM>%1\$$TEST$$.$$$
CTTY CON
IF NOT EXIST %1\$$TEST$$.$$$ GOTO No
DEL %1\$$TEST$$.$$$
GOTO Change_Dir
:No
CD \
:Change_Dir
FOR %%f IN (%1 %2 %3 %4 %5 %6 %7 %8 %9) DO CD %%f
