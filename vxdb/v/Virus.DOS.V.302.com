�BgY   	P�PtP�P�
*�*t*�*�  T  l    l      l      ) �%	�P���.�&���    ��.�ÜP� ���X��P���$�<@X����u����u	����� .�>W t
��v��v�.�.V3��ދ����sdSR�x �����&:Wv�&�WZ[.��Su@���u9��uƄ�aPQ�� �f�sY^�`�o�u���S��X��DtƄ�TYX��uB��u5�� u0�B�u+��� u$&�tWVQ&�O��	&�O
���I�
 ��.�Y^_� �^� ��u�P.��Uu"����sQR�� � ������ZY���u�^��.��S�<r0<w,��Tw'RS3�.��
�t:�s��	��W����.��_�u[ZX닀�*v<w	r���tu�T���.�B.�E[ZQ�  �>� ��.�Y�  ��S�    �`	�@+\�
UJ�	U��
UH�
DISKCOPYDISKCOMP�=Dub��`u\�����uSPSQRVW�b��.��ێ, ���F�< u���F�< u�N�<\u�F��ֿ)� �t
��1� �_^ZY[Xt�.�.��.��WQP�ڋG� �	��u)��������&��G&�E�G&�E�G&�E�G��XY_�� 
 ����������������������������������������������������������������������������Ŀ
 �  800 II    Diskette BIOS Enhancer     Version 1.40        March 22nd 1989  �
 ����������������������������������������������������������������������������Ĵ
 �  Written by   Alberto PASQUALE    Via Monteverdi 32  41100  Modena  ITALY  �
 ����������������������������������������������������������������������������Ĵ
 �  Drive A:                             800 now O                            �
 �  Drive B:                             800 /? for help.                     �
 ������������������������������������������������������������������������������
$
 ����������������������������������������������������������������������������Ŀ
 �  WARNING:                                                                  �
 �                                                                            �
 ������������������������������������������������������������������������������
$Invalid command^Command line too long !
 ����������������������������������������������������������������������������Ŀ
 �  WARNING:  800 requires DOS 3.30 or later for full performance !!!         �
 �            Many DOS commands will malfunction.                             �
 ������������������������������������������������������������������������������
$ ����������������������������������������������������������������������������Ŀ
 �  800 II                          H E L P                     Version 1.40  �
 �                        E)nglish           I)taliano                        �
 ����������������������������������������������������������������������������Ĵ
 �     Press E to see English help           Premi I per l'aiuto italiano     �
 ������������������������������������������������������������������������������ 
 ����������������������������������������������������������������������������Ŀ
 �  800 II                    ENGLISH HELP page 1               Version 1.40  �
 ����������������������������������������������������������������������������Ĵ
 �  800 II is a little resident program that allows you to use many new       �
 �  floppy formats while preserving total DOS compatibility.                  �
 �  800 II takes as little as 864 bytes of resident memory, so that you can   �
 �  install it from your Autoexec.bat without minding the lost memory.        �
 �  New formats are supported at the BIOS level: this way they are fully      �
 �  compatible with DOS 3.30 or above and with many utilities.                �
 ����������������������������������������������������������������������������Ĵ
 �  FORMAT/MEDIA          SUITABLE DRIVES              FORMAT COMMAND EXAMPLE �
 �                                                                            �
 �  360KB  DD  5�"(360KB & 1.2MB),3�"(720KB & 1.44MB)  Format [d:] /T:40/N:9  �
 �  400KB  DD  5�"(360KB & 1.2MB),3�"(720KB & 1.44MB)  Format [d:] /T:40/N:10 �
 �  720KB  DD  5�"(        1.2MB),3�"(720KB & 1.44MB)  Format [d:] /T:80/N:9  �
 �  800KB  DD  5�"(        1.2MB),3�"(720KB & 1.44MB)  Format [d:] /T:80/N:10 �
 � 1200KB  HD  5�"(        1.2MB),3�"(        1.44MB)  Format [d:] /T:80/N:15 �
 � 1360KB  HD  5�"(        1.2MB),3�"(        1.44MB)  Format [d:] /T:80/N:17 �
 � 1440KB  HD                     3�"(        1.44MB)  Format [d:] /T:80/N:18 �
 � 1600KB  HD                     3�"(        1.44MB)  Format [d:] /T:80/N:20 �
 ����������������������������������������������������������������������������Ĵ
 �                             Press PgDn or Esc                              �
 ������������������������������������������������������������������������������ 
 ����������������������������������������������������������������������������Ŀ
 �  800 II                    ENGLISH HELP page 2               Version 1.40  �
 ����������������������������������������������������������������������������Ĵ
 �  800 II allows you to use Diskcopy between drives of different types       �
 �  provided that they both support the format of the floppy to be copied.    �
 �  This way you can now use Diskcopy between 5�" and 3�" drives.             �
 ����������������������������������������������������������������������������Ĵ
 �  The most convenient format is 720KB in 1.2MB drive: it is reliable, fast  �
 �  standard (don't forget you can diskcopy a 720KB 5�" to a 720KB 3�") and   �
 �  cheap (it uses the same double density media used by the 360KB format).   �
 �  Now you can use the Diskcopy and Diskcomp commands of DOS 3.30 or above   �
 �  on diskettes of any format, provided that you do not change the filename  �
 �  of those commands.  The following formats may result slower (especially   �
 �  during diskcopy): 400KB,800KB,1360KB,1600KB.                              �
 ����������������������������������������������������������������������������Ĵ
 �  All formats (except for 1600KB) can be made bootable by the /s switch:    �
 �  Example: "Format A: /s /t:80/n:10" formats an 800KB diskette and makes    �
 �  it bootable. However if you boot from a 5�" 720KB or 800KB diskette you   �
 �  should call 800 from your AUTOEXEC.BAT; otherwise 5�" 720KB and 800KB     �
 �  diskettes will not work after disk change.                                �
 ����������������������������������������������������������������������������Ĵ
 �                          Press PgUp, PgDn or Esc                           �
 ������������������������������������������������������������������������������ 
 ����������������������������������������������������������������������������Ŀ
 �  800 II                    ENGLISH HELP page 3               Version 1.40  �
 ����������������������������������������������������������������������������Ĵ
 �  800 II does not replace the diskette BIOS, they work side by side:        �
 �  some BIOS can't bear 800 II behaviour when you use 1.2MB drive with 720KB �
 �  or 800KB formats: you must try to be sure about your BIOS compatibility.  �
 �  800 II works well with most BIOSes but there are exceptions.              �
 ����������������������������������������������������������������������������Ĵ
 �  800 II can be installed at any moment by typing "800" from the DOS prompt �
 �  or calling it from a batch file.  However the best thing is to call 800   �
 �  from your Autoexec.bat so that it is always installed.                    �
 �  If you have some other resident program that works with diskettes at the  �
 �  BIOS level, it could be necessary to call 800 before or after that TSR.   �
 �  If 800 II does not work well, remove all TSR programs and try again.      �
 ����������������������������������������������������������������������������Ĵ
 �  Generally 800 II is completely transparent with respect to programs that  �
 �  call diskette BIOS (INT 13h), however should you experience any trouble   �
 �  with special programs (e.g. copiers), you can disable 800 II by calling   �
 �  "800 /off" from DOS or (better) from the batch that calls that program.   �
 �  "800 /on" enables again.                                                  �
 ����������������������������������������������������������������������������Ĵ
 �                          Press PgUp, PgDn or Esc                           �
 ������������������������������������������������������������������������������ 
 ����������������������������������������������������������������������������Ŀ
 �  800 II                    ENGLISH HELP page 4               Version 1.40  �
 ����������������������������������������������������������������������������Ĵ
 �  800 automatically recognizes the types of the diskette drives installed,  �
 �  and shows them after installation. Should you find discrepancies between  �
 �  the effective drive types and those sensed by 800, you can specify them   �
 �  on the command line (e.g."800/12/14" means A: is 1.2MB, B: is 1.44MB).    �
 ����������������������������������������������������������������������������Ĵ
 �                           COMMAND LINE SWITCHES                            �
 �  /off disables 800 II     /on  enables again     /0  drive not installed   �
 �  /00  drive not installed /36  double density    /12 high density          �
 �  /72  3�"(720KB)          /14  3�"(1.44MB)       /?  help                  �
 �  /co compatibility mode   /ke  keep environment (only at installation time)�
 ����������������������������������������������������������������������������Ĵ
 �  If you have trouble using 720K and 800K formats in 1.2M drive, try the    �
 �  /co switch. It is useful with some strange BIOSes.                        �
 ����������������������������������������������������������������������������Ĵ
 �  Some strange problems have been reported about memory allocation errors   �
 �  occurred after FORMAT especially in multitasking environments: should you �
 �  experience similar problems try the /ke switch at installation time.      �
 ����������������������������������������������������������������������������Ĵ
 �                          Press PgUp, PgDn or Esc                           �
 ������������������������������������������������������������������������������ 
 ����������������������������������������������������������������������������Ŀ
 �  800 II                    ENGLISH HELP page 5               Version 1.40  �
 ����������������������������������������������������������������������������Ĵ
 �  WARNING: diskcopy and diskcomp functions of some utilities can't work with�
 �  the new formats supported by 800: use the DOS commands to avoid troubles. �
 ����������������������������������������������������������������������������Ĵ
 �  You can use some formats besides those already described: in the FORMAT   �
 �  command you can type /T:n, where 1<=n<=85 is the number of cylinders.     �
 �  The maximum value for the 360K drive is n=43.                             �
 �  ATTENTION: Now Diskcopy and Diskcomp work with any diskette format !!     �
 �  WARNING: /T:41,/T:81 are safe; some drives may not work with more tracks !�
 �  The first time you try to format a floppy with more than 81 tracks        �
 �  (41 tracks for the 360K drive), you must carefully listen to the drive to �
 �  realize if the head carriage bumps against the stop.                      �
 �  Even if you don't hear anything suspect, you should verify the floppy     �
 �  using some disk-verify utility to be sure that all the tracks have been   �
 �  correctly formatted. The extra tracks could be less realiable !           �
 ����������������������������������������������������������������������������Ĵ
 �  In the FORMAT command you can use /N:n with n<=s, where s is the number   �
 �  of sectors shown in the examples of page 1.                               �
 ����������������������������������������������������������������������������Ĵ
 �                          Press PgUp, PgDn or Esc                           �
 ������������������������������������������������������������������������������ 
 ����������������������������������������������������������������������������Ŀ
 �  800 II                    ENGLISH HELP page 6               Version 1.40  �
 ����������������������������������������������������������������������������Ĵ
 �                                                                            �
 �  You may copy and distribute 800 II freely, provided that:                 �
 �                                                                            �
 �  1)  No fee is charged for such copy and distribution.                     �
 �                                                                            �
 �  2)  It is distributed ONLY in its original form.                          �
 �                                                                            �
 ����������������������������������������������������������������������������Ĵ
 �                                                                            �
 �                                                                            �
 �  If you find 800 II of value a little                                      �
 �  contribution (e.g. LIT 10000 (US$7))            PASQUALE Alberto          �
 �  will be greatly appreciated.                    Via Monteverdi 32         �
 �  Please make checks payable in Italian           41100  Modena             �
 �  liras to:                                       ITALY                     �
 �                                                                            �
 �                                                                            �
 ����������������������������������������������������������������������������Ĵ
 �                             Press PgUp or Esc                              �
 ������������������������������������������������������������������������������ 
 ����������������������������������������������������������������������������Ŀ
 �  800 II                  AIUTO ITALIANO pag. 1               Version 1.40  �
 ����������������������������������������������������������������������������Ĵ
 �  800 II � un breve programma residente che permette di usare molti nuovi   �
 �  formati di floppy conservando la totale compatibilit� col DOS.            �
 �  800 II occupa appena 864 bytes di memoria residente, cos� che lo si pu�   �
 �  installare dall'Autoexec.bat senza preoccuparsi della memoria persa.      �
 �  I nuovi formati sono supportati a livello di BIOS, in questo modo sono    �
 �  completamente compatibili col DOS 3.30 o superiore e con molte utilities. �
 ����������������������������������������������������������������������������Ĵ
 �  FORMATO/DISCO       DRIVES UTILIZZABILI            ESEMPIO DI FORMAT      �
 �                                                                            �
 �  360KB  DD  5�"(360KB & 1.2MB),3�"(720KB & 1.44MB)  Format [d:] /T:40/N:9  �
 �  400KB  DD  5�"(360KB & 1.2MB),3�"(720KB & 1.44MB)  Format [d:] /T:40/N:10 �
 �  720KB  DD  5�"(        1.2MB),3�"(720KB & 1.44MB)  Format [d:] /T:80/N:9  �
 �  800KB  DD  5�"(        1.2MB),3�"(720KB & 1.44MB)  Format [d:] /T:80/N:10 �
 � 1200KB  HD  5�"(        1.2MB),3�"(        1.44MB)  Format [d:] /T:80/N:15 �
 � 1360KB  HD  5�"(        1.2MB),3�"(        1.44MB)  Format [d:] /T:80/N:17 �
 � 1440KB  HD                     3�"(        1.44MB)  Format [d:] /T:80/N:18 �
 � 1600KB  HD                     3�"(        1.44MB)  Format [d:] /T:80/N:20 �
 ����������������������������������������������������������������������������Ĵ
 �                             Premi PgDn o Esc                               �
 ������������������������������������������������������������������������������ 
 ����������������������������������������������������������������������������Ŀ
 �  800 II                  AIUTO ITALIANO pag. 2               Version 1.40  �
 ����������������������������������������������������������������������������Ĵ
 �  800 II permette di usare il Diskcopy tra drives di tipi differenti purch� �
 �  entrambi supportino il formato del floppy che deve essere copiato.        �
 �  In questo modo ora si pu� usare il Diskcopy tra drives da 5�" e 3�".      �
 ����������������������������������������������������������������������������Ĵ
 �  Il formato pi� conveniente � il 720KB nel drive da 1.2MB: � affidabile,   �
 �  veloce, standard (si pu� fare il diskcopy da un 720KB 5�" a un 720KB 3�") �
 �  ed economico (usa gli stessi dischi double density del formato da 360KB). �
 �  Ora puoi usare i comandi Diskcopy e Diskcomp del DOS 3.30 o superiore su  �
 �  dischetti di qualunque formato, purch� non cambi il nome di quei comandi. �
 �  I seguenti formati possono risultare pi� lenti (soprattutto col diskcopy):�
 �  400KB,800KB,1360KB,1600KB.                                                �
 ����������������������������������������������������������������������������Ĵ
 �  Tutti i formati (tranne il 1600KB) si possono rendere boot-abili con /s:  �
 �  Esempio: "Format A: /s /t:80/n:10" formatta un disco a 800KB e lo rende   �
 �  boot-abile. Tuttavia se si fa il boot da un floppy 5�" 720KB o 800KB      �
 �  occorre chiamare 800 dall'AUTOEXEC.BAT; altrimenti i dischi 5�" da 720KB  �
 �  o 800KB non funzioneranno dopo un cambio di disco.                        �
 ����������������������������������������������������������������������������Ĵ
 �                          Premi PgUp, PgDn o Esc                            �
 ������������������������������������������������������������������������������ 
 ����������������������������������������������������������������������������Ŀ
 �  800 II                  AIUTO ITALIANO pag. 3               Version 1.40  �
 ����������������������������������������������������������������������������Ĵ
 �  800 II non sostituisce il BIOS del floppy, lavorano fianco a fianco:      �
 �  qualche BIOS non va d'accordo con 800 nell'uso del drive da 1.2MB a 720KB �
 �  e 800KB: occorre provare per vedere se il proprio BIOS � compatibile.     �
 �  800 II funziona bene con la maggioranza dei BIOS, ma ci sono eccezioni.   �
 ����������������������������������������������������������������������������Ĵ
 �  800 II pu� essere installato in ogni momento battendo "800" al prompt del �
 �  DOS o chiamandolo da un file batch. Tuttavia la cosa migliore � chiamare  �
 �  800 dall'Autoexec.bat cosicch� � sempre installato.                       �
 �  Se c'� qualche altro programma residente che lavora coi dischi al livello �
 �  del BIOS, potrebbe essere necessario chiamare 800 prima o dopo quel TSR.  �
 �  Se 800 II non funziona bene, rimuovi tutti i programmi TSR e prova ancora.�
 ����������������������������������������������������������������������������Ĵ
 �  Generalmente 800 II � completamente trasparente rispetto ai programmi che �
 �  chiamano il BIOS dei dischi (INT 13h), tuttavia se dovessi avere problemi �
 �  con programmi speciali (es. copiatori), puoi disabilitare 800 II battendo �
 �  "800 /off" dal DOS o (meglio) dal file batch che chiama quel programma.   �
 �  "800 /on" abilita nuovamente.                                             �
 ����������������������������������������������������������������������������Ĵ
 �                          Premi PgUp, PgDn o Esc                            �
 ������������������������������������������������������������������������������ 
 ����������������������������������������������������������������������������Ŀ
 �  800 II                  AIUTO ITALIANO pag. 4               Version 1.40  �
 ����������������������������������������������������������������������������Ĵ
 �  800 II riconosce automaticamente i tipi dei drives installati, e li       �
 �  mostra dopo l'installazione. Se dovessero esserci discrepanze tra i tipi  �
 �  effettivi dei drives e quelli rilevati da 800, li puoi specificare sulla  �
 �  linea di comando (es."800/12/14" significa A: � 1.2MB, B: � 1.44MB).      �
 ����������������������������������������������������������������������������Ĵ
 �                      PARAMETRI SULLA LINEA DI COMANDO                      �
 �  /off disabilita 800 II    /on  abilita ancora    /0  drive non installato �
 �  /00  drive non installato /36  double density    /12 high density         �
 �  /72  3�"(720KB)           /14  3�"(1.44MB)       /?  aiuto                �
 �  /co  modo compatibilit�   /ke  keep environment (solo all'installazione)  �
 ����������������������������������������������������������������������������Ĵ
 �  Se ci sono problemi con i formati 720K e 800K nel drive da 1.2M, prova lo �
 �  switch /co. E' utile con alcuni strani BIOS.                              �
 ����������������������������������������������������������������������������Ĵ
 �  Sono stati riferiti strani problemi riguardo errori di allocazione della  �
 �  memoria occorsi dopo un FORMAT specialmente in ambienti multitasking: se  �
 �  si manifestano simili problemi prova lo switch /ke all'installazione.     �
 ����������������������������������������������������������������������������Ĵ
 �                          Premi PgUp, PgDn o Esc                            �
 ������������������������������������������������������������������������������ 
 ����������������������������������������������������������������������������Ŀ
 �  800 II                  AIUTO ITALIANO pag. 5               Version 1.40  �
 ����������������������������������������������������������������������������Ĵ
 �  ATTENZIONE: le funzioni di diskcopy e diskcomp di alcune utilities non    �
 �  funzionano con i nuovi formati: per evitare guai usa i comandi del DOS.   �
 ����������������������������������������������������������������������������Ĵ
 �  Si possono usare altri formati oltre quelli gi� descritti: nel comando    �
 �  FORMAT si pu� scrivere /T:n, dove 1<=n<=85 � il numero di cilindri.       �
 �  Il massimo valore per i drives da 360K � n=43.                            �
 �  ATTENZIONE: Ora Diskcopy e Diskcomp funzionano con qualunque formato !!   �
 �  ATTENZIONE: /T:41,/T:81 sono sicuri;certi drive non vanno con pi� tracce !�
 �  La prima volta che provi a formattare un floppy con pi� di 81 tracce      �
 �  (41 tracce per il drive da 360K), dovresti ascoltare attentamente il drive�
 �  per renderti conto se il carrello delle teste sbatte contro il fermo.     �
 �  Anche se non senti nulla dovresti verificare il floppy con una utility di �
 �  disk-verify per essere sicuro che tutte le tracce siano state formattate  �
 �  correttamente. Le tracce in pi� possono essere meno affidabili !          �
 ����������������������������������������������������������������������������Ĵ
 �  Nel comando FORMAT si pu� usare /N:n con n<=s, dove s � il numero di      �
 �  settori mostrato negli esempi di pagina 1.                                �
 ����������������������������������������������������������������������������Ĵ
 �                          Premi PgUp, PgDn o Esc                            �
 ������������������������������������������������������������������������������ 
 ����������������������������������������������������������������������������Ŀ
 �  800 II                  AIUTO ITALIANO pag. 6               Version 1.40  �
 ����������������������������������������������������������������������������Ĵ
 �                                                                            �
 �  Si pu� copiare e distribuire 800 II liberamente purch�:                   �
 �                                                                            �
 �  1)  Nessuna tariffa sia richiesta per tale copia o distribuzione.         �
 �                                                                            �
 �  2)  Sia distribuito SOLO nella sua forma originale.                       �
 �                                                                            �
 ����������������������������������������������������������������������������Ĵ
 �                                                                            �
 �                                                                            �
 �  Se trovi utile 800 II un piccolo                                          �
 �  contributo (es. lire 10000) sar�                PASQUALE Alberto          �
 �  molto apprezzato.                               Via Monteverdi 32         �
 �  Inviare ogni corrispondenza a:                  41100  Modena             �
 �                                                                            �
 �                                                                            �
 �                                                                            �
 ����������������������������������������������������������������������������Ĵ
 �                             Premi PgUp o Esc                               �
 ������������������������������������������������������������������������������ ~b�b�b�b�b�b Not Installed.  Double density. High density.   3.5" (720KB).   3.5" (1.44MB).  Unknown type.  (Compatibility mode)           3���&�N��b���&�b�>�b��P��&�b������t
��b &�&��&�b����&�b&�>c�u
� ���b �� ����R��^��b��b�&�b��ؠ�b2����<wt<
t<t"< t/�&�FGG��F�>�b�����b�bF��VWS��>�b�[_^F�+�b���6�b�������>�b��À>�buR���t��%���Z�k��)�����a��R���3Ɋ6�b��b�ʷ� ��>�b��  �ZÊ>�b��6�b�Ʋ �ô	�!ô�uô ������� �������������e�� :(�/  �6>VE�L�S+[  ���9	�X������3�<iu� �<It�<et<Et	��u��X��3ۋ�Yd�t�SV��^[��t��Iu�uSV��� �^[��KK��CC�̀>�  wÿ  �  �� ��� ��/tO�� tD&�W�>� ;w ��(��� ��.��� ��2�� ��.������� ��������F��u�À�r�F�ɋ�� ��  ��?u
��XX� L�!��0u��w�&ƅS G��rŁ�00u��� ��rJ��36u��w?&ƅSG� ��12u��w*&ƅSG� ��72u��w&ƅSG� ��14u��v�&�&ƅSG�n��cou�T&�>Wt�W&�&���P��keu�>�bu�����b�9��onu&�W�+��oft�����s������ Ft
��� ft��F��&�W F������  &��S2�����v� �獽rbV���5��u��Q� ��.�^F��v�&�>W t��n ��!����ff�� !&�>Tt��b��� ��.����g��3��ؾ ���$�<@uƄ�aNt�À� w"���Ot�ˁ�	Ot�ˁ�Ot
�ˁ�	't��ô� ����=��u��b�$�� �r��u�U�����u�V���>�btu&�>S um�2��r��&�S����p�&�T�I� ��ؠ��<�s<�u��t1&�S���<r#&�T���p� � � �q2� ������&�S������>�bu� L�!�0�!��=s���G��>�bt	.�, �I�!�5�!���!5�!����-
 ���������.��u�%�!�9�!%�!�6 � 1�!   � �BgY�f ���=K ��t
���uk�f��PSQR�=�!rL�j �ع ��?�!r;�>MZt3�>
Yt,��:  ��-��.� �@�!r2�� � ��@�!Z�>�!�0 Y[X��9f3ɋѴB�!�ϿQ+P�$5�!�������%�!X�R���$%�!Z�PSQRVW�Eh���!=ft;�� ) � ��H�ء +ã � �/�V�^�!5�!������%�!�� � �Ȏ؎�����_^ZY[� P3��