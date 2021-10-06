                   Allenware.com Batch Library
               StudyPacks - Generic README.TXT file
                   For use in Windows 95/98/ME

 StudyPacks are Educational packages to supplement our Batch File Course
    Course Syllabus and Index to Lessons at: http://www.allenware.com/


===Disclaimer

This package is provided free of charge. It is purely for educational
and study purposes. Use it at your own risk. No warranties are given.
Never use a computer unless all valuable data are safely backed up.


===StudyPacks

These are ZIP-ped collections of fully-documented Batch files. Each of
the StudyPacks covers a particular subject area. Each StudyPack has the
same general format. The pattern of files in each pack is:

  {SubjectArea}.TXT    (A text file explaining the StudyPack)
  {SubjectArea}1.BAT   (Simple example Batch file for SubjectArea)
  {SubjectArea}2.BAT   (More complex example for SubjectArea)
  ... and possibly more numbered examples ...
  {SubjectArea}_.BAT   (A tutorial Batch file for the SubjectArea)

In the case of the Subroutine StudyPack (StudyPack 1), there is also a
template (TEMPLATE.BAT) which you can use to write new Batch files that
contain Subroutines. These will then be compatible with all our standard
Subroutines (which you can paste directly into your code).

The {SubjectArea} is usually a seven (or fewer) character mnemonic for
the particular Subject Area the StudyPack covers.


===Batch File Course

The documentation in the StudyPacks assumes you are familiar with the
MS-DOS Batch Language to the level reached in our Batch File Course.
This is a fully interactive Web Course for newcomers to Batch Files.
Course Syllabus and Index to Lessons at: http://www.allenware.com/


===Using StudyPacks

After you've unzipped all the files to a folder, discard this general
README.TXT file, and read the specific instructions for the StudyPack
in the relevant {SubjectArea}.TXT text file.


===Naming convention for filenames in StudyPacks

As we said, the {SubjectArea} is usually a seven (or fewer) character
mnemonic for the Subject Area the StudyPack covers. This convention,
combined with a generic README.TXT file common to all StudyPacks, means
you can unzip more than one StudyPack to a common folder, if you wish.

Only this generic README.TXT file is common to any of the StudyPacks
and you can allow it to be overwritten in subsequent unzip operations.

If you unzip several StudyPacks to the same folder, an alphabetically
ordered folder listing (for example, a DIR /o command) will group all
related files together in a meaningful order.


===BatchWindow  (setting up a Custom MS-DOS window)

The examples in the StudyPacks are best studied by using them in a
custom MS-DOS BatchWindow. Details of how to set up and configure a
custom MS-DOS window are in the Introduction to our Batch File Course.
Course Syllabus and Index to Lessons at: http://www.allenware.com/

When you've followed our Introduction once, this summary of the main
points will probably be all you need to set up a new BatchWindow
whenever you wish:

(1) Create a working folder, for example C:\WORK

(2) Create a Shortcut to C:\WINDOWS\command.com (use your own Windows
    folder path to COMMAND.COM if it's not the standard C:\WINDOWS)

(3) Right-click the Shortcut and Click "Properties":
    In the Tabbed Property Sheet Editor that opens:
    (a) In Program Tab:
       (i)   Set the name at the top = BatchWindow
       (ii)  Set the "Working" field to your Working folder = C:\WORK
       (iii) Set the Batch file field to the CLS command (clear screen)
             (remember if you're a Windows Millennium user, you won't
              normally do this, since it would prevent operation of
              the CMDINIT.BAT file that normally runs in Millennium)
       (iv)  If you need to set a keyb command, such as: keyb uk
             in the Batch file field, remember to enter this command
             instead of the CLS. Again, Windows Millennium users will
             usually find they don't have to do this. For full details
             of testing whether or not a keyb setting is needed for your
             system, see the Introduction to our Batch File Course.
       (v)   Change icon to "Open door" (in C:\WINDOWS\SYSTEM\user.exe)
     (b) In Font Tab:
        (i)  Set the Font to, say 9x15 (or the next smaller size if
             that's not available). Choose a TrueType Font (if they're
             available on your system). TrueType fonts make a number of
             Batch operation characters much clearer to read.
     (c) In Memory Tab:
        (i)  Use Initial Environment pull-down box to set 2048 (bytes).

    Click OK to Close the Property Sheet Editor and save your settings.

 (4) Open the BatchWindow by double-clicking its Shortcut and make sure
     the Window is maximized - it will have interlinked squares in the
     middle symbol in the top right corner window controls. Remember that
     a maximized MS-DOS window doesn't fill the screen, its size is
     determined by the Font size you set in (3)(b)(i) above.

 (5) Don't forget that Alt-Enter (hold down Alt key and press Enter)
     toggles the display between full screen and windowed. You will
     normally use windowed display.

 (6) If you have to create the BatchWindow Shortcut each time you use
     your machine (perhaps because you're not its exclusive user), you
     may as well leave it on your DeskTop once you've created it.
     Otherwise, copy it to your programs folder as explained in our
     Batch File Course Introduction.


               We hope you find this StudyPack useful


                     William and Linda Allen
 (c) Copyright Allen & Company 2003 - all rights reserved (c)


===Note on Windows NT/2000/XP

The solutions in this Batch StudyPack are for use in Windows 95/98/ME.
They are not designed for use in Windows NT/2000/XP operating systems.

The more advanced Batch syntax in Windows NT/2000/XP allows relatively
straightforward solutions to Windows 95/98/ME problems examined here.

Most of the Batch File examples in the StudyPacks have the lines:

  :: Check that the Operating System is suitable
  ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

included. In Windows 95/98/ME the ECHO line is treated as one ECHO
command and redirected to NUL, and therefore has no effect.

However, in Windows NT/2000/XP the & character is a command separator,
and the :EOF label exists by default (even where not explicitly coded
in the Batch file). Therefore, in Windows NT/2000/XP, the ECHO line
behaves as two separate commands:

  ECHO/Not suitable for Windows NT/2000/XP
  GOTO :EOF>NUL

This ECHOes the message: "Not suitable for Windows NT/2000/XP" and
executes a GOTO :EOF so terminating the Batch file without running
the Windows 95/98/ME code in Windows NT/2000/XP.
