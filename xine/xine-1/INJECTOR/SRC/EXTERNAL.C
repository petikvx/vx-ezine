#include <stdlib.h>
#include <string.h>

#include "netool.h"
#include "inject.h"


#define MAXEXT 10

char * ext_name[MAXEXT];
void (* ext_func[MAXEXT]) (void);

void initexternals(void)
{
	ext_name[0]="inject";		/* packet injector */
	ext_func[0]=inject;
	ext_name[1]="injectip";		/* packet injector with ip */
	ext_func[1]=injectip;
	ext_name[2]="rawlog";		/* raw logging facility */
	ext_func[2]=rawlog;
	ext_name[3]="flood";		/* packet flooding */
	ext_func[3]=flood;
	ext_name[4]="getarp";		/* do an arp request */
	ext_func[4]=getarp;
	ext_name[5]="getarpto";		/* do an arp request */
	ext_func[5]=getarpto;
	ext_name[6]="synflood";		/* do a syn flood */
	ext_func[6]=synflood;
	ext_name[7]=NULL;		/* the last must be NULL */
}

int doext(char * w)
{
	int i;


	i=0;
	while (ext_name[i])
	{
		if (!strcmp(ext_name[i],w))
		{
			(*ext_func[i])();
			return 0;
		}
		i++;
	}
	return 1;
}