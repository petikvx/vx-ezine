======================================================================

NTFS File System Driver for DOS/Windows V2.0R+ (read-only)
Copyright (C) 1996-1997 Mark Russinovich and Bryce Cogswell

Last modified December 5, 1997

======================================================================

NTFSDOS.EXE is a network file system redirector for DOS/Windows 
that is able to recognize and mount NTFS drives for transparent
access.  It makes NTFS drives appear indistinguishable from standard 
FAT drives, providing the ability to navigate, view and execute programs 
on them from DOS or from Windows, including from the Windows 3.1 File 
Manager and Windows 95 Explorer.


Please read this entire file before contacting us for help.  


Availability
============

The latest version of NTFSDOS can be found at 
	http://www.ntinternals.com


Sample Output
=============

Here is sample output from an NTFSDOS session under DOS 7.0 (Windows 95):

C:\ntfsdos>ntfsdos

NTFS File System Redirector for DOS/Windows V2.0R+ (read-only)
Copyright (C) 1996-1997 Mark Russinovich and Bryce Cogswell
http://www.ntinternals.com

Initialized 500KB of XMS cache.

Mounting NTFS partition(0x80:3) as drive: H

C:\ntfsdos>h:

H:\>dir

 Volume in drive H is ntfs
 Directory of H:\

EMACS          <DIR>        03-16-96  8:31a emacs
FILEMON        <DIR>        04-18-96  3:30p filemon
               <DIR>        05-01-96  1:20p newlongfilename
NTICE          <DIR>        03-30-96  8:18a NTICE
PAGEFILE SYS    28,311,552  04-07-96 12:16p pagefile.sys
PROGRA~1       <DIR>        03-30-96  5:20a Program Files
RECYCLER       <DIR>        03-30-96  5:36a RECYCLER
TEMP           <DIR>        05-15-96 12:58a temp
USERS          <DIR>        03-16-96  3:27a users
WIN32APP       <DIR>        03-16-96  3:27a win32app
WINNT          <DIR>        03-30-96  8:41a WINNT
WINNT35        <DIR>        05-15-96 12:58a WINNT35
         1 file(s)     28,311,552 bytes
        11 dir(s)     388,284,416 bytes free

H:\>

----------------------------------------------------------------------


Enhancements over V1.30
=======================

NTFSDOS V2.0R+ has the following improvements over V1.30:

	- Several significant bug fixes.
	- An option for tolerating directories containing
	  files with unicode names.
	- Support for disks with many partitions.
	- Greatly improved robustness.
	- An add-on, NTFSDOS Tools, provides limited write
	  capability aimed at disaster recovery


Contents of the Package
=======================

README.TXT  - this readme
NTFSDOS.EXE - DOS/Windows NTFS file-system driver
NTFSHLP.VXD - helper VxD needed only for long filename support in
              Windows 95


Installation and Use
====================

To use NTFSDOS, simply execute it from the DOS command line (DOS
5.0 or greater is required), or from your AUTOEXEC.BAT. Executing 
NTFSDOS before Windows is started will create NTFS drives that 
are visible globally once inside Windows. Executing NTFSDOS in a DOS box 
means that the NTFS drives only exist within the DOS box where NTFSDOS 
was executed.

When NTFSDOS starts, it will scan all hard-disk partitions on
your system to look for NTFS drives. It will mount all NTFS drives
it finds as unique DOS logical drive letters, and will inform you
as it does so. 

If you run NTFSDOS under DOS 7.0, NTFS drives will support long filename 
calls *even before Windows starts*.  To propagate this support into 
Windows 95, NTFSDOS automatically has Windows run the NTFSHLP.VXD VxD 
device driver. No changes to SYSTEM.INI or the registry are necessary 
for this to occur - NTFSDOS will detect when Windows 95 starts and 
load the driver without user-intervention. You need NTFSHLP.VXD only
if you will be running NTFSDOS with Windows 95.

NTFSDOS implements its own caching, and uses one of two types of
memory, depending on how your system is configured. Its first
choice is to use XMS memory for caching, as this minimizes demands
placed on conventional memory. If you start NTFSDOS before Windows,
then HIMEM.SYS, which can be found in the WINDOWS directory under 
Windows 95 or the DOS directory under Windows 3.1, or its equivalent, 
must be started before NTFSDOS. If NTFSDOS does not detect an XMS
server, it will resort to allocating 64KB of conventional memory for
its cache. In either case, it will inform you of its action.

NTFSDOS takes six command line parameters. 

* The /L parameter lets you specify which drive letters NTFSDOS should 
attempt to use as it mounts NTFS drives. 

* The /C option lets you override the default XMS cache size. 

* The /N option should be used to optimize NTFSDOS memory usage when 
the NTFS drives you are accessing do not contain compressed files. 

* The /X option prevents NTFSDOS from using extended int 13 BIOS 
services, in case the BIOS does not properly support them. 

* The /U option has NTFSDOS correctly sort through files with unicode 
names. You should only use if a NTFSDOS directory listing enters 
an infinite loop within directories that contain files with unicode names.

* Finally, the /V option directs NTFSDOS to print messages detailing the 
drives it looks at and the memory it allocates. 

The syntax for these parameters is:

	/L:<letter>...	Specifies drive to start mounting at
	/C:<size>	Specifies size of XMS cache in KB
	/N		Disable compressed file support
	/X		Disable extended int 13 support
	/U		Tolerate unicode file names
	/V		Verbose 

Example:
	NTFSDOS /L:ge /C:1024

This command has NTFSDOS mount the first NTFS partition it finds as
drive 'g' and the second as drive 'e', and indicates that it should
create a 1MB XMS cache.  If a drive letter is specified that is 
already in use, the partition that is being mounted at the letter
will not mount and an appropriate error message will be printed.

There is no way to unload NTFSDOS from memory once it has started.


If You Have Problems Running NTFSDOS
====================================

* NTFSDOS does not recognize my NTFS drive

NTFSDOS does not handle cluster sizes > 4K on NT 4.0 formatted drives. This
is rare, since NTFS compression does not handle these cluster sizes either.

NTFSDOS requires that disks be accessible via BIOS, using the INT 13 or
extended INT 13 services. In some cases, SCSI drives may not be fully 
accessible without a DOS device driver (see your SCSI adapter documentation).

* NTFSDOS uses too much conventional memory

Some people have complained that NTFSDOS is a memory hog.  Unfortunately,
this fact is largely imposed on us by the architecture of NTFS itself 
(sorry, but its a *little* more complicated than FAT, and much more memory
intensive), coupled with our desire to provide reasonable performance
across a wide variety of NTFS installations.  In general, the footprint
of NTFSDOS increases largely with the clustersize of the largest NTFS 
partition, and slightly with the number of NTFS volumes mounted. If the
NTFS drives you will be accessing do not contain compressed files, you
should use the /N option to lower NTFSDOS' memory footprint.

* Accessing an NTFSDOS drive causes a hang or crash

NTFSDOS does not support disk striping. Further, it cannot handle drives 
that are on partitions extending beyond the 2GB boundary, or that 
are larger than 2GB in size, UNLESS the computer's BIOS has extended
INT 13 support for the drives in question. The latter restrictions are due to 
limitations in standard disk BIOS code that prevent it from addressing 
sectors 2GB or more from the start of a disk.

NTFSDOS has not been thoroughly bullet-proofed against corrupt NTFS
drive data structures, so it may cause Windows to crash or hang
when it runs into problems. To insure that a crash or hang is due
to a problem with NTFSDOS rather than your NTFS drive, be sure to
chkdsk the drive from Windows NT and try NTFSDOS again.

* Starting programs or loading files seems very slow

Access of large compressed files may be noticeably slower than of
their non-compressed versions.

* File times are not correct when running under DOS 7.0 without Windows 95

This problem is due to the fact that NTFS and LFN FAT time stamps are 
stored in Coordinated Universal Time (UTC), which is based on Greenwich Mean
Time, and Windows 95 automatically converts times stamps returned by LFN 
calls to local time.  Since local time zone information is not accessible 
outside of Windows 95, running NTFSDOS under DOS 7.0 without Windows 95 
results in the display of unadjusted times. 

* Programs complain about not being able to find files when they are 
  there

A directory listing of files that have no short filename will result
in the short filename field of the listing being blank (see the file,
"newlongfilename," in the sample listing above). Changing the current
directory to a path where any component of the pathname does not
have a short filename will result in all short filename calls failing
while in the directory. This makes most Windows 3.1 and DOS programs and 
many DOS commands (e.g. MORE) inoperative in these directories. However, 
LFN calls are supported in these directories.

* Data read from a file appears to be corrupt

Since this work is based on reverse-engineering rather than official
Microsoft specifications (which are reportedly available under special
circumstances for large amounts of money), we do not guarantee data
integrity of NTFSDOS drives. This is especially important if you are
considering using NTFSDOS as a file backup utility.

* Files or directories seem to be missing

Remember that files and directories that were created with no DOS 8.3
short filenames will not be visible if you are running DOS versions earlier
than 7.0.

* You get the message "No drive letter to mount NTFS partition..."

If NTFSDOS complains that it cannot mount a drive because there
are no available drive letters, you must find the line in your CONFIG.SYS
that begins with "LASTDRIVE=". If you do not find one, then add one. Set
the LASTDRIVE variable to a letter that is greater, by the number
of NTFS drives on your system, than the largest drive letter you normally
have under DOS/Windows. For example, if the highest drive letter normally
in use is E: and you have two NTFS drives, set LASTDRIVE to G: with a 
statement in CONFIG.SYS like: 
LASTDRIVE=G: 
If you still get the message then increment the letter and try again. 
Remember to reboot after every change to CONFIG.SYS.

* You get the message "Could not allocate XMS or conventional cache"

Memory usage on your machine is so high that NTFSDOS could not allocate
64KB for a conventional cache. Try removing unnecessary TSRs and drivers
and/or running a DOS memory optimizer or manager.

* XCOPY does not work in a DOS box

XCOPY will not work on NTFS drives that are mounted in DOS boxes under 
Windows 95 (e.g. running NTFSDOS in a DOS box). This is because you 
cannot run Windows programs off of non-global drives, and under Windows 95, 
XCOPY starts the Windows console program XCOPY32.EXE.


Reporting Bugs
==============

When you report a bug (see Reaching Us, below), please provide the following
information about your system:

	- disk types (IDE, etc.)
	- disk and partition sizes
	- BIOS version
	- drive sizes and formats
	- version of NT that was used to format NTFS drives
	- version of NTFSDOS you are using
	- an output dump of NTFSDOS run with the /V (verbose) option
	- version of DOS and/or Windows you are running NTFSDOS on


Implementation
==============

NTFSDOS scans the system's partition tables looking for partitions
that have the NTFS attribute byte. When it finds one, it looks for an
unused DOS driver letter and registers a network drive on it. After
it completes the drive search it hooks the network redirector
interrupt and goes resident. Requests come into NTFSDOS as full path
names, or continuations of a previous directory traversal (as with
findnext), so it proceeds to determine where, based on NTFS internal
data structures, the target file is located. When it retrieves the
header for the target file it can determine where the file's data is
located, and read it when it receives requests to do so.

To provide long filename support (LFN), NTFSDOS hooks INT 21/AH=0x71
calls and implements LFN functionality when it sees an LFN call. 
Under Windows 95, NTFSHLP.VXD is required to send LFN calls down to 
the NTFSDOS for it to process; otherwise NTFSDOS would not see LFN calls 
since Windows assumes DOS redirected drives do not provide LFN support.

NTFSDOS also uses the INT 2F/11 and INT 13 APIs. In addition, it contains 
memory and cache management plus interpretation of the NTFS on-disk 
structures.


Read/Write NTFSDOS
==================

A full read/write version of NTFSDOS will not be released. 

If you have a dead system that you would like to recover data 
from or repair, and you have access to a second NT machine, you 
may want to try NTRecover, another utility we have written that 
is available at the Winternals Web site (http://www.winternals.com). 
A read-only NTRecover is available for free download, and with 
it you can access the drives on the dead system from the working 
system using native NT file systems and uiltities. In fact, to 
NT the drives appear as if they were local drives on the working 
system. With the read/write version, you can copy/edit/delete files. 

If you require limited write access for disaster recovery purposes, 
NTFSDOS Tools may help. NTFSDOS Tools is an add-on package available 
for sale at the Winternals Web site (http://www.winternals.com). 
It consists of two utilties, NTFSCopy and NTFSRen, that work with
NTFSDOS 2.0R+. NTFSCopy allows you to overwrite a NTFSfile with a fresh 
copy in cases where one has become corrupt and is preventing NT from booting. 
NTFSRen will give a specified file a new name. This is useful in cases where a 
new driver or application is installed and is preventing NT from booting. 
With NTFSRen an offending file can be renamed so that NT will not load it.


Reaching Us
===========

We would appreciate any feedback you have concerning this utility
including suggestions and bug reports. Mark can be reached at
mark@ntinternals.com, and Bryce can be reached at cogswell@winternals.com.


Acknowledgments
===============

We thank everybody that e-mailed us with bug reports and other feedback. 

Significant understanding of the NTFS file system layout was derived by 
studying the Linux-based NTFS driver code maintained by Martin von Loewis. 
We acknowledge his indirect contribution to this endeavor.

Andrew Schulman, et. al.'s, book, Undocumented DOS 2nd Edition 
(Addison-Wesley), was invaluable in providing network redirector 
information necessary for implementing NTFSDOS.
