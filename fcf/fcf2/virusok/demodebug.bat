@echo off
cls
Echo.
Echo Hogy k‚sz¡tsnk bin ris k¢dot BAT-b¢l?
Echo.
Echo El‹sz”r is elk‚sz¡tnk egy un. debug scriptet.
Echo Gombnyom sra indul...
pause>nul
echo n $DroP$.com>DroP.t
echo e 0100  EB 3F 90>>DroP.t
echo e 012A  1A 90 00 00 00 00>>DroP.t
echo e 0130  00 00 00 00 00 00 00 00 00 B8 40 00 FF 00 00 00>>DroP.t
echo e 0140  00 B0 08 BA 2C 01 E8 3F 01 B0 08 BA 86 01 E8 50>>DroP.t
echo e 0150  01 B4 2C CD 21 89 16 BE 02 C6 06 3E 01 FF B4 0F>>DroP.t
echo e 0160  CD 10 3C 06 74 0D 3C 07 74 09 C7 06 38 01 00 B8>>DroP.t
echo e 0170  EB 07 90 C7 06 38 01 00 B0 BA C0 02 B1 04 D3 EA>>DroP.t
echo e 0180  42 B4 31 CD 21 90 9C 50 B4 02 CD 16 24 40 74 1B>>DroP.t
echo e 0190  2E 80 3E 3E 01 00 74 08 2E FE 0E 3E 01 EB 0C 90>>DroP.t
echo e 01A0  2E 80 3E 3D 01 00 75 03 EB 08 90 58 9D 2E FF 2E>>DroP.t
echo e 01B0  2C 01 9C 2E FF 1E 2C 01 06 1E 52 51 57 56 0E 1F>>DroP.t
echo e 01C0  A1 38 01 8E C0 2E 80 3E 3F 01 00 74 0C 8B 3E 30>>DroP.t
echo e 01D0  01 8B 36 32 01 FB EB 5A 90 C6 06 3D 01 FF FB C6>>DroP.t
echo e 01E0  06 40 01 64 80 3E 40 01 00 75 03 E9 8B 00 FE 0E>>DroP.t
echo e 01F0  40 01 E8 B7 00 25 FE 0F 8B F0 26 8A 04 3C 20 74>>DroP.t
echo e 0200  E3 3C 00 74 DF 81 FE A0 0F 73 D9 8B FE 81 C7 A0>>DroP.t
echo e 0210  00 81 FF A0 0F 73 44 26 8A 05 3C 20 74 04 3C 00>>DroP.t
echo e 0220  75 C2 89 3E 30 01 89 36 32 01 C6 06 3F 01 FF EB>>DroP.t
echo e 0230  48 90 C6 06 3F 01 00 26 8A 04 26 88 05 26 C6 04>>DroP.t
echo e 0240  20 8B F7 81 C7 A0 00 81 FF A0 0F 73 0E 26 8A 05>>DroP.t
echo e 0250  3C 20 74 CE 3C 00 74 CA EB 05 90 26 C6 04 20 FF>>DroP.t
echo e 0260  0E 3A 01 75 0A D0 2E 3C 01 C7 06 3A 01 40 00 E8>>DroP.t
echo e 0270  3A 00 22 06 3C 01 A2 3E 01 5E 5F 59 5A 1F 07 58>>DroP.t
echo e 0280  9D 2E C6 06 3D 01 00 CF 50 06 53 55 52 B4 35 CD>>DroP.t
echo e 0290  21 8B D3 5D 89 56 00 45 45 8C 46 00 5D 5B 07 58>>DroP.t
echo e 02A0  C3 50 1E 0E 1F B4 25 CD 21 1F 58 C3 A1 BE 02 50>>DroP.t
echo e 02B0  80 E4 B4 58 7A 01 F9 D1 D0 A3 BE 02 C3 90 00 00>>DroP.t
echo rcx>>DroP.t
echo 1C0>>DroP.t
echo w>>DroP.t
echo q>>DroP.t
Echo.
Echo K‚sz a DroP.t nevû f jl.
Echo Most pedig gombnyom sra bin ris k¢dd  ford¡tjuk.
Echo.
pause>nul
@Echo on
debug<DroP.t