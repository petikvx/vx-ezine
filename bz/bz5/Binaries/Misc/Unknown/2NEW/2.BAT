@ECHO OFF
FOR %%h IN (a A b B c C d D e E f F) DO IF (%1) == (%%h) %%h:
FOR %%k IN (a A b B c C d D e E f F) DO IF (%1) == (%%k) SHIFT
IF NOT EXIST %1\NUL CD \
FOR %%f IN (%1 %2 %3 %4 %5 %6 %7 %8 %9) DO CD %%f
