
                                    29A Labs
                                       &
                  Information Weapon Developing Center (IWDC)
                                   PRESENTS:

                        AVP 3.0 Weekly Update Generator

                    generator build 666 for AVP builds 120+

     copyright (c) 1998 by AVP research and distribution team & Z0MBiE/29A
                         proudly made in Moscow, Russia

                                 Seek & Enjoy!



                               *** WHAT IS IT ***

   This program is a generator of trojan addons for AVP 3.0 build 120+

   It produces file RULEZ.AVC which can be renamed and sent to one of
   your friends (but better to all)

   Trojan code executed without any user prompts when AVP??.EXE is just
   launched, i.e. when it checks own integrity.

   Addon contains trojan code sections for both Dos & Win32. Dos section
   writes trojan mbr code to C:\IO.SYS, and Win32 section writes trojan mbr
   directly to hd 0/0/1. After that PC is rebooted using PCI port.

   And when trojan mbr is executed, you can relax - nothing can help.
   Btw, it also contains recursive extended partition entry. |-)

                           *** REQUIRED SOFTWARE ***

                TASM             MASM            TP
                 ÃÄ tasm.exe      ÀÄ ml.exe       Ã- tpc.exe
                 ÀÄ tlink.exe                     ÀÄ turbo.tpl

                             *** FILES OVERVIEW ***

   AVP_TROJ\
   ÃÄ set_path.bat           edit this file to setup paths
   ÃÄ _go.bat                batch file to make rulez.avc
   ÃÄ rulez.avc              result of this package
   À- MAKE_AVC\
      ÃÄ _go.bat             batch file to make trojan addon
      ÃÄ eicar.avc           base-addon (to take some headers from it)
      ÃÄ -stamm.bin          virus stamm entry for trojan addon
      ÃÄ -name.bin           virus name entry for trojan addon
      ÃÄ make!!!!.pas        main program to create trojan addon
      ÃÄ avp__.pas           unit; addon headers / checksum
      ÃÄ tpu.pas             unit; file management
      ÀÄ MAKE_OBJ\
         Ã- _go.bat          batch file to compile code-sections
         Ã- add_8b.pas       utility to insert 8 bytes to begin of .obj file
         Ã- bin2inc.pas      binary -> .inc convertor
         Ã- dos.asm          dos section of trojan code
         Ã- win.asm          win32 section of trojan code
         À- fuckup.asm       mbr trojan code

                              *** HOW IT WORKS ***

   Directory of MAKE_OBJ\

     bin2inc.pas          -> [tp]         -> bin2inc.exe
     add_8b.pas           -> [tp]         -> add_8b.exe

     fuckup.asm           -> [tasm,tlink] -> fuckup.bin
     fuckup.bin           -> [bin2inc]    -> fuckup.inc
     dos.asm + fuckup.inc -> [ml]         -> dos.obj
     win.asm + fuckup.inc -> [ml]         -> win.obj
     dos.obj              -> [add_8b.exe] -> ..\-dos.bin
     win.obj              -> [add_8b.exe] -> ..\-win.bin

   Directory of MAKE_AVC\

  make!!!!.pas +
       tpu.pas +
     avp__.pas -> [tp] -> make!!!!.exe

     eicar.avc +
    -stamm.bin +
      -dos.bin +
      -win.bin +
     -name.bin -> [make!!!!.exe] -> rulez.avc
