					README for: BAT.Terror1st - By SAD1c

 NAME: BAT.Terror1st
 TYPE: Batch
 SIZE: 944 Bytes
 ENCRYPTED: Yes
 INFECTION: Overwrite all .reg files in current & parent dir., root, path & windows dir.
 NET SPREAD: Share ALL Hard Drives (stealth mode)
 DESTRUCTIVE: No
 PAYLOAD: Install itself using a .reg file, so is executed on every startup
 NOTES: For the Drives sharing use "LanMan" method, so it can't work on NT systems
 HOW TO FIX: Remove The startup key using "regedit", remove all the drives sharing keys & delete infected .reg files.
Here the complete list of things to do:

 1. Click on windows "Start" button.
 2. Click on "Run..."
 3. Write "regedit" & click "OK" button.
 4. Navigate through register & remove this keys:

 - HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run
	delete "DataBaseRegSet" key.
 - HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Network
	delete "Installed" key.
 - HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Network\LanMan
	delete ALL keys!!!

 5. Delete this file: %windir%\temp\DbRegSet.reg ("%windir%" is your windows directory)
 6. Using windows file search, find all "*.reg" files that contain this text: "Network\LanMan"
 7. Now you're perfectly clean!!!

 HOW TO PREVENT: Never run unknown .bat files!!!