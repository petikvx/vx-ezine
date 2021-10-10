/* ------------------------------ *\
Author: Ole Loots
Date:	06.03.2006 - 20:24
Desc:	File Abstraction Functions
		--------------------------
		Work with files under C
		just by using the Path 
		Parameter.

\* ------------------------------ */

//extern int readfile(const char * path, void * data);
extern char * readfile(const char * path);

/*	This function reads a file into memory, you pass 
	the filepath and a pointer, where the functions stores
	the content of the file. This function takes care
	of allocation enoug memory for the file, but you have to
	free it when exiting !!!
	returns NULL on failure.
*/

extern int __fastcall filesize(const char * path);
/*
	Get filesize in number of bytes, just by passing the path
	to the file. 
	returns -1 on failure.
*/


extern int __fastcall filesz(FILE * file);
/*
	Get filesize in number of bytes, by passing the Filehandle.
	returns -1 on failure.
*/

