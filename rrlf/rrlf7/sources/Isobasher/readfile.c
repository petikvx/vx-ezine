#include <stdio.h>

char * readfile(char * path)
{
		FILE 	*f;
		int 	fs, read;
		void 	*data; 

		f = fopen( path, "r+b");
		if(!f)
			return((int)NULL);
		fs = filelength( fileno(f) );
		
		data = malloc( fs );
		if( !data )
			return( (int)NULL );
		read = fread( data, 1, fs, f );
		fclose( f );
		
		if( read != fs )
		{
			if(data != NULL)
				free(data);
			return( (int)NULL );	
		}
		return( data );
}

int __fastcall filesize( char * path)
{
	FILE 	*f;
	int 	fs;
	f = fopen( path, "r+b");
	if(!f)
		return(-1);
	fs = filelength( fileno(f) );	
	fclose(f);
	return(fs);
}


int __fastcall filesz( FILE * file)
{
	if(file)
		return(filelength(fileno(file)));		
	return(-1);
	
}

