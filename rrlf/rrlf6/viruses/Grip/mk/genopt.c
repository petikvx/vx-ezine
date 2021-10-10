/* genopt.c: generate all variants of Linux.Grip
 * By using this file, you agree to the terms and conditions set
 * forth in the COPYING file which can be found at the top level
 * of this distribution.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char	*o0[]	= {
	" -O1", " -O2", NULL,
};
char	*o1[]	= {
	" -DUEP_LDE32"," -DUEP_RGBLDE"," -DUEP_MLDE32"," -DUEP_CATCHY"," -DUEP_CATCHY2","", NULL,
};
char	*o2[]	= {
	" -DCRYPT_XTEA", " -DCRYPT_BLOWFISH", "", NULL,
};
char	*o3[]	= {
	" -DOBFUSCATE_KEY", "", NULL,
};

int main()
{
	int	i = 0;
	char	**p0, **p1, **p2, **p3, A[1024], v[3];
	void variant(void) {
		if (i < 26) {
			v[0] = 'a' + i;
			v[1] = 0;
		} else {
			v[0] = 'a' + i / 26 - 1;
			v[1] = 'a' + i % 26;
			v[2] = 0;
		}
	}
	void mkopt(void) {
		variant();
		sprintf(A, "%s%s%s%s", *p0, *p1, *p2, (*p3 ? *p3 : ""));
		++i;
		setenv("AFLAGS", A, 1);
		setenv("VARIANT", v, 1);
		system(MAKE " -C . -e -f Makefile.mk");
	}
	
	for (p0 = o0; *p0 != NULL; p0++)
	for (p1 = o1; *p1 != NULL; p1++)
	for (p2 = o2; *p2 != NULL; p2++)
		if (strcmp(*p2, ""))
			for (p3 = o3; *p3 != NULL; p3++)
				mkopt();
		else
			mkopt();
	return 0;
}
