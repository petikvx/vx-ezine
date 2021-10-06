 ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
 บ These batch files and concepts are intended to run McAfee's SCAN v2.x  บ
 บ check for VSHIELD and echo any error messages back to the users screen บ 
 บ as well as log the errors for diagnostic purposes by the ADMIN         บ
 บ        Written by: DJ Tech @ McAfee PSET - June 1995                   บ
 ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ


Step 1:
LOGIN to server as SUPERVISOR or equivalant
	SYS:\> LOGIN server_name/SUPERVISOR

Step 2:
The following lines must be added to the system login script
The first line just sets a user variable which will be utilized
in the MCAFEE.BAT and CHK4VSH.BAT file for identifying the user 
which is running the batch files during login.
 
 ADD TO SYSTEM LOGIN SCRIPT:  
 ------------------------------------
 (included seperately as NET$LOG.INS)

  SET USER_ID="%USER_ID"          <---- Sets variable to the user's id #
  SET LOG_NAME="%LOGIN_NAME"      <---- Sets variable to the user's login name
  MAP ROOT O:=SYS:MCAFEE\         <---- Maps drive to MCAFEE directory
  MAP ROOT K:=SYS:HOME\%LOGIN_NAME<---- Map roots to users home directory
  
  IF LOGIN_NAME = "SUPERVISOR" THEN GOTO SKIPSCAN
  
  IF MEMBER OF "SCAN" THEN        <---- This could be group SCAN or

     IF "%<SCAN>" != "YES" THEN
     #COMMAND /c O:\SCANNORY.BAT  <---- Calls batch file to ask user if
					 they would like to be scanned
  FDISPLAY K:BANNER.TXT           <---- If user says no display warning banner
     IF "%ERRORLEVEL"="0" THEN 
	DOS SET SCAN="YES"        <---- After user says no set SCAN to YES 
	#COMMAND /C DEL K:\BANNER.TXT   <--- Delete file for next time
	ELSE
	DOS SET SCAN=             <---- Else set SCAN so that scan will run   
     END
  END

  IF MEMBER OF "SCAN" THEN      <---- This could be group SCAN or
				      substitute another group like EVERYONE
     MAP X:=SYS:MCAFEE\         <---- Maps drive to MCAFEE directory
     IF "%<SCAN>" != "YES" THEN <---- Tests SET Variable if NOT equal to YES
	 EXIT "O:MCAFEE.BAT"    <---- If above line is true exits to batch file
	 ELSE 
      END
  END
  
  IF MEMBER OF "SCANTSR" THEN
     MAP X:=SYS:MCAFEE\         <---- Maps drive to MCAFEE directory
     IF "%<SCANTSR>"!="YES" THEN<---- Tests SET Variable if NOT equal to YES
	 EXIT "X:CHK4VSH.BAT"   <---- If above line is true exits to batch file
	 ELSE
      END
  END
:SKIPSCAN


Step 3.
Create a MCAFEE directory on the SYS volume of the server.
	SYS:\> MD\MCAFEE
	Users will need READ and FILESCAN rights
	SYS:\> MD\MCAFEE\VIRUSLOG
	Users will need READ, WRITE, CREATE, & MODIFY rights

Step 4.
Files that must be copied to the SYS:\MCAFEE directory:
	SCAN.EXE
	SCAN.DAT
	CLEAN.DAT    - (optional)
	NAMES.DAT
	CHKVSHLD.EXE
	MCAFEE.BAT
	CHK4VSH.BAT
	PKUNZIP.EXE  - (optional for later updates)
	WSCAN.EXE    - (optional for Windows Scan)
	WSCAN.HLP    - (optional for Windows Scan)
	WSCAN.INI    - (optional for Windows Scan)
	PROFILE1.PRF - (optional for Windows Scan)
	PROFILE2.PRF - (optional for Windows Scan)

Step 5.
Now the files should all be in place.  The LOGIN script is going to check 
to see if the user is a member of the group called SCAN.
If indeed the user is a member of the group it will then check for a DOS
variable called SCAN.  If the SET SCAN=YES, this means the user has already
been scanned once since they turned on their computer and thus skips scanning
them again.  
If SET SCAN NOT EQUAL TO YES then the login script will exit to a batch file 
called MCAFEE.BAT (file included).


Step 6.
After completion of the scanning it is possible to check if VSHIELD is loaded
this can be done by calling CHK4VSH.BAT is utilized in the above example by
using a group called SCANTSR.  The CHK4VSH.BAT should look something like the 
one included as CHK4VSH.BAT.

Note: The following lines are utilized throughout the 2 batch files, they 
create a report log. One is in the users directory (k:scan.log) and the other 
is in a common place (o:\viruslog\allscan.log) This will allow the system 
admin to keep track of what users are getting errors and what the errors are.

:error1
echo.
echo ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
echo บ    ***  WARNING  ***                                  ***  VIRUS  ***  บ
echo บ Please refer to your documentation or contact SYSADMIN / Help Desk     บ
echo ฬออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน
echo บ Error occured while accessing a file (reading or writing).             บ
echo บ                                                                        บ
echo ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
echo.                                 
pause
echo ------------------------------------------------------------  >>K:SCAN.LOG
z:\SYSTIME                                                         >>K:SCAN.LOG
echo Error occured while accessing a file (reading or writing).    >>K:SCAN.LOG
echo ErrorLevel 1 occured at above date / time                     >>K:SCAN.LOG
echo ------------------------------------------------->>o:\viruslog\allscan.log
z:\SYSTIME                                            >>o:\viruslog\allscan.log
echo Error accessing a file (reading or writing).     >>o:\viruslog\allSCAN.LOG
echo Error 1 occured at above date/time on %log_name% >>o:\viruslog\allscan.log
echo %log_name% is located at station # %station%     >>o:\viruslog\allscan.log 
echo.
goto end

Step 7.
After the CHK4VSH.BAT has completed successfully the SCANTSR will be set to YES
so that when the LOGIN script is executed again it will pass through the normal 
LOGIN script.


TIPS, TECHNIQUES and Other Important Stuff to Know:
---------------------------------------------------
- if users LOGIN to another server first this will not work unless it has also
  been converted. Tip to force this would be to make this server their 
  PREFERRED SERVER in their NET.CFG file. This will force them to run the LOGIN 
  script rather than ATTACH.EXE.

- if users ATTACH to the server rather that LOGIN they will not be running the
  system login script or the batch files created.

- when new versions of SCAN are available they just need to be placed into the
  X:\MCAFEE\ directory.  This will ensure the latest version of scan is being
  used.

- if a user finds traces of a particular virus in memory the admin will have to
  go to the workstation and cold boot it from a clean, DOS, write-protected 
  floppy and then run SCAN C: /CLEAN from a floppy.

- "FILE CREATION ERROR" - can mean many different things
   - user doesn't have a user directory needed to create a .LOG file
   - user doesn't have rights to create a .LOG file as specified

- INVALID DRIVE SPECIFICATION
- if using drive Z:,K:,O: as specified in the examples make sure the users do 
  not have a LASTDRIVE= statement where it is set to something higher than E:

- if user gets error: 
-->  There is no room to expand the PATH environment variable with the mapping:
     "MAP ROOT x:=SYS:\ "                                                            <---- or something similiar
	** OR **
-->  Could not add "LOG_NAME=DJOHNSON" to the local enviroment variables             <---- or something similiar
	** OR **
-->  Out of environment space
	** OR **
-->  MEMORY ALLOCATION ERROR
     CANNOT LOAD COMMAND SYSTEM HALTED

any of these messages could be a sign that there is not enough environment 
space this can be addressed by increasing the /E parameter on the SHELL = 
line in config.sys

- in some very rare cases a user may get:
	--> run-time error R6009
	    -not enough space for environment
  
  this will ONLY occur if the user has very low memory, around 200k of
  conventional memory, which is to low for anything including the compiler
  interpreter. However the MCAFEE.BAT will return an error level 21+    


PLEASE NOTE:
This is just one possible implementation of SCAN and VSHIELD, however due to 
the memory limitations SCAN can not always be executed directly from the 
system login script.


MIS/ADMIN Notes:
----------------
The O:ALLSCAN.LOG (SYS:\MCAFEE\ALLSCAN.LOG) will be the central location where 
users errorlevels are recorded.  So the SYS:\MCAFEE\ALLSCAN.LOG should be 
viewed frequently to check who is getting errors.

For a more detailed report each user has their own SCAN.LOG located in their
HOME USER directory (K: or SYS:USER\ or SYS:\HOME).  Also in the same directory
is a file called LASTSCAN.RPT, which contains the report generated by SCAN.  
The LASTSCAN.RPT not only can point out specific problems, it also will be
time and date stamped the last time SCAN was run (even if it was succesful).


Options in MCAFEE.BAT
---------------------
(1) SCAN C:\                       <---- will just scan root of drive c:
(2) SCAN C:                        <---- will scan all of drive c: 
					 including MBR/LBS
(3) SCAN C: /ALL                   <---- same as (2) and all files which have 
					 a executable header regardless of 
					 extension
(4) SCAN C: /REPORT K:lastscan.rpt <---- same as (2) and will write a report 
					 file named lastscan.rpt to K: drive.
(5) SCAN C: /FREQUENCY 48          <---- same as (2) except if a scan has been 
					 performed in last 48 hours it will 
					 skip scanning and return a errorlevel 
					 20 in MCAFEE.BAT. 48 can be substitued 
					 with any number, which is the number 
					 of hours. SCAN uses a hidden file 
					 MCAFEE.FRC in the root of the C: drive 
					 to keep track of the last scan.
(6) SCAN C: /NOBREAK               <---- will make scan complete without giving 
					 the ability to CTRL-BREAK out before 
					 completion.
(7) SCAN C: /PAUSE                 <---- will pause the scanning output when 
					 the screen fills, so that messages 
					 will not scroll by before being read.
(8) SCAN /ADL                      <---- will scan ALL DRIVES LOCAL (C:, D:) 
					 except floppies.
(9) SCAN /ADN                      <---- will scan ALL DRIVES NETWORK, 
					 everything currently mapped.
 

WINDOWS SCAN (Optional)
-----------------------
If you would like to use WSCAN.EXE from a network drive there are a few 
things which need to be setup.

Step 1.
Copy the follwing files to the SYS:\>MCAFEE\ directory
	WSCAN.EXE    - (optional for Windows Scan)
	WSCAN.HLP    - (optional for Windows Scan)
	WSCAN.INI    - (optional for Windows Scan)
	PROFILE1.PRF - (optional for Windows Scan)
	PROFILE2.PRF - (optional for Windows Scan)


Step 2. 
Since the users ONLY have READ and FILESCAN rights they will not be able 
to create log files or profiles in the SYS:MCAFEE\ directory.
Therefor the following change needs to be made in the WSCAN.INI
	
	WSCAN.INI
	-----------
	[ActivityLog]
	KeepLog=1
  --->  LogFile=K:WSCAN.LOG
	Last10=0

Make sure each user has a personal area, in this case the SYS:HOME\USER 
directory where they have rights to create an activity log.

Step 3.
How to load WSCAN.INI from directory other than WSCAN.EXE startup directory?
Answer:
During loading WSCAN.EXE first looks in WIN.INI in the section [VIRUSSCAN]
     
	  [VIRUSSCAN]
     
	  for the entry
     
	  INIFILE=C:\MCAFEE\WSCAN.INI
     
In case the name contains full path to WSCAN.INI, WSCAN tries to load it.
If entry contains only file's name and extension, WSCAN.EXE maps it to the 
program directory.
     
If WSCAN.EXE didn't find the entry in WIN.INI, it tries to load WSCAN.INI 
from program directory. In case WSCAN.INI doesn't exist, it gives warning: 
	  "Cannot load configuration file".
							 
So, the solution is to add or modify the entry INIFILE in the section 
VIRUSSCAN in WIN.INI. This is only needed if each user needs a custom
WSCAN.INI file.
     
