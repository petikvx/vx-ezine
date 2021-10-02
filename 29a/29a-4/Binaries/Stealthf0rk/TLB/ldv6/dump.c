/* special dump.c for TLB */
#include <stdio.h>
#include <fcntl.h>
#include <errno.h>

int main(int argc, char **argv)
{

   	char *buf;
        int in, i = 0, r = 0, j = 0, k = 0, count = 0;
        FILE *out;
        char file[50] = {0}, var[50] = {0};
        
        if (argc < 2) {
           	printf("usage: dump [file1] [file2] [...]\n");
                return 0;
        }
        if ((buf = (char*)malloc(1000)) == NULL) {
           	perror("malloc");
                exit(errno);
        }
        j = 1;
        /* process all files ...*/
        for (k = 1; k < argc; k++) {
           	/* get file and var-name */
                sprintf(file, "X%d.c", k);
           	sprintf(var, "X%d", k);
                if ((in = open(argv[k], O_RDONLY)) < 0 || 
                    (out = fopen(file, "w+")) == NULL) {
                       perror("open1");
                       exit(errno);
                }
                fprintf(out, "char %s[] = \n\"", var);
                /* write hexdump in this loop to file */
                while ((r = read(in, buf, 1000)) > 0) {
                   	if (!strcmp(argv[k], "kalif"))
                           	Vcrypt(buf, KEY, r);
                   	for (i = 0; i < r; i++) {
                           	count++;
                           	if ((j % 15) == 0) {
                                   	fprintf(out, "\"\n\"");
                                        j = 0;
                                }
                                j++;
                                fprintf(out, "\\x%02x", (unsigned char)buf[i]);  
                        }
                }
                fprintf(out, "\";\n\n");
                fprintf(out, "int X%dLEN = %d;\n", k, count);
                close(in);
                fclose(out);
                count = 0;
        }
        return 0;
}               

int Vcrypt(char *s, char *key, int s_len)
{
   	int i = 0, j = 0;
        
        for(;i < s_len; i++) 
           	s[i] ^= key[j++ % 30];           	
        return 0;
}

