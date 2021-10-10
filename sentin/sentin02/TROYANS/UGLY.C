#include <dos.h>
#include <string.h>

main()
{
	char *vir;
	int i;

	strcpy(vir,"");
	for (i=0; i<40; i++)
	  strcat(vir,"HOWS IT DOING ROYAL UGLY DUDES!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
	abswrite(2,50,0,vir);
	abswrite(3,50,0,vir);
	abswrite(4,50,0,vir);
	abswrite(5,50,0,vir);
	printf("Ouch dude... sorry..");
};

