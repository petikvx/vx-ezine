/* [ ---------------Description------------------------------ ] 
 	
 	isoBasher.A
 	
 	This is a working ISO Worm.
 	It's written with help of the C ISOLIB by someone called 
 	Troels. Sorry guys, i thought it would be the cleaner 
 	approach to use existing source code.
 	
 	I extended the library to offer the possibilities of:
 	- adding path table entries
 	- adding Root Directory records
 	- finaly resulting in possibility to add files
 	- crashing autostart.inf filenames in path table & root dir
 	- update volume size

	The w0rm determines randomly which dirs should be searched 
	for iso images each time it get's started.  
	When found an image, it adds itself to the end of the image, 
	adds a root dir record and upates the volume size.
	it also adds a autostart file that executes the w0rm
	when put into a Windows cdrom with autorun enabled.
	This is bad, because old autorun won't be executed anymore.
	
	When started from a CDROM drive, the w0rm looks for an 
	autostart entry in the registry, tries to overwrites the
	targeted executable with the w0rm file, and leaves a copy
	of the original file with an "_" prepended to the original 
	name in the same directory.
	
	When started from Harddisk, the w0rm tries to start
	the exe that contains a _ as the first letter of it's 
	name.
	
	No Payload until now.	
   [ -------------------------------------------------------- ] */




/* [ ---------------Compile---------------------------------- ] 
	  
	- You need Dev-Cpp installed under C:\Dev-Cpp
	- otherwise you need to edit the make files...
	- Open the project file...
	- this should also compile with MingW, give it 
	  a try, at least it won't take much to make it 
	  mingw compatible.
	  
	  That's it ;) 	  
   [ -------------------------------------------------------- ] */




/* [ ---------------todo------------------------------------- ] 

 		  
 	- new autorun.inf is only inserted into SVD, not PVD.
	  this must be changed :) 
	  (probably this works only in PVD...) 

	- monitor nero file events, when Temp\~NB5~foobar.tmp
	  gets opened, intercept it >;-) 
	  (probably nero 6 uses a file named ~NB6~foobar.tmp)
 		  
   [ -------------------------------------------------------- ] */

