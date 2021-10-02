/* special dump.c for the unix/M$DOS virus */

#include <stdio.h>
#include <fcntl.h>
#include <errno.h>

int main(int argc, char **argv)
{

   	char *buf, outbuf[20] = {0}, s[100] = {0}, def[100] =  {0};
        int in1, in2, i = 0, r = 0, j = 0, count = 0, 
            len1 = 0, len2 = 0;
        FILE *out1, *out2, *fd;
        
        if (argc < 3) {
           	printf("usage: dump [file1] [file2]\n");
                return -1;
        }
        /* open head and body */
        if ((in1 = open(argv[1], O_RDWR)) < 0 ||
             (in2 = open(argv[2], O_RDONLY)) < 0) {
           	perror("open1");
                return errno;
        }
        len1 = lseek(in1, 0, SEEK_END);
        len2 = lseek(in2, 0, SEEK_END);
        sprintf(def, "#define CHARS %04d\n#define CHARS2 %03d\n\n", 
                len2, len1 + 39);
        lseek(in2, 0, SEEK_SET);
        write(in1, def, strlen(def));
        close(in1);
        in1 = open(argv[1], O_RDONLY);
        
        /* open otput-files */
        if ((out1 = fopen("B", "a+")) == NULL || 
            (out2 = fopen("C", "a+")) == NULL) {
           	perror("fopen");
                return errno;
        }
        if ((buf = (char*)malloc(5000)) == NULL) {
           	perror("malloc");
                return errno;
        }
        j = 1;
        fprintf(out1, "char B[] = \n\"");
        while ((r = read(in1, buf, 1000)) > 0) {
                for (i = 0; i < r; i++) {
                   	if ((j % 15) == 0) {
                           	fprintf(out1, "\"\n\"");
                		j = 0;
                   	}
                        j++;
                        fprintf(out1, "\\x%02x", buf[i]);  
                }
        }
        fprintf(out1, "\";\n\n");
        
        /* ok, the includes etc. are now written to char B[] ...
         * lets do the main part
         */
        fprintf(out2, "char C[] = \n\"");
        j = 1;
        while ((r = read(in2, buf, 5000)) > 0) {
           	printf("%d\n", r);
                for (i = 0; i < r; i++) {
                   	if ((j % 15) == 0) {
                           	fprintf(out2, "\"\n\"");
                                j = 0;
                        }
                        j++;
                        fprintf(out2, "\\x%02x", buf[i]);
                }
        }
        fprintf(out2, "\";\n\n");
        close(in1);
        close(in2);
        fclose(out2);
        fclose(out1);
        return 0;
}               
