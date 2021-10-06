
   Batch Shell for XL-it! and XFormer
   ==================================

This batch makes it easier to use a couple of popular Atari 8 bit
computer emulators. It is designed with Windows in mind, associate
your ATR and XFD files with it to double-click and run them. To
make life easier it remembers the setup and emulator used by each
virtual Atari disk.

Dos 6 or Windows 95 is required. If you have 95, check to see
if QBasic.exe is installed. If not find it on the CD or download
it from Microsoft's web site.

Installation:

Copy RUNATARI.BAT and SELFILE.COM to either a path directory
or to the same directory as the emulator files. Both emulators
should be in the same directory. Before using you *must* edit
the RUNATARI.BAT file to specify your program directory, and
probably program/doc filenames. Load the batch into Notepad or
any other plain text editor and alter the indicated parts, only
change the parts after the = characters in the set var= lines.

Usage:

If run without a parm it comes up with an option menu. If run
by double-clicking an associated Atari disk or if the disk is
specified on the command line it waits 2 seconds for Esc to
bring up the menu, otherwise it runs the disk with the last
settings for it or with the default options. Settings for the
boot disk (or default if none) are saved whenever the emulator
is ran from the menu, all you have to do is press Esc while
loading, change the options and Go.

Extra:

The mount and copy disk functions only access ATR files, use
the Files option to mount XFD files or 8 bit files for XFormer.
Unmount does not unmount the boot disk when run by association.
Configuration is stored in the RUNATARI.CFG file but wasn't
designed to be human readable, the disk names are backwards.

The SELFILE utility maxes out if too many files, shouldn't
be a problem though. See SELFILE.TXT for notes on how to use
this utility from batch files.

When entering data, avoid using batch-illegal characters like
<, > or | to avoid crashing the input routine.

Update:

XFormer 3.6 is now free and it rocks! www.emulators.com
Updated the batch to pick XFormer options using 1-6, thought
I might could get away with just typing in and saving the
command line options, but this is better. Now shells a new
command.com with more environment space to avoid possible
errors, also to hide all those evars.

Made by Terry Newton, email wtnewton@nc5.infi.net
Last Modified Feb. 11, 1998
