/*
 * chm :: MAC address changer by seltorn / aI :: my coding sucks
 * chm -d<number of eth device> -a<mac address> to enjoy.
 * first you have to ifconfig ethX down, then only run this thing.
 * i heard there is better list of bytes... send it to me, s3@cd.sysda.kiev.ua
 */

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <unistd.h>


struct LIST
{
    char name[50];
    u_char mac[3];
};

/*
 * fuck. i need those MAC vendor bytes. anyone who has any - contact me
 */

struct LIST vendors[] = {
                {"3Com ? Novell ? [PS/2]               ",'\x00','\x00','\xD8'},
                {"3Com [IBM PC, Imagen, Valid, Cisco]  ",'\x02','\x60','\x8C'},
                {"3Com (ex Bridge)                     ",'\x08','\x00','\x02'},
                {"HP                                   ",'\x08','\x00','\x09'},
                {"AT&T                                 ",'\x08','\x00','\x10'},
                {"Sun                                  ",'\x08','\x00','\x20'},
                {"DEC                                  ",'\x08','\x00','\x2B'},
                {'\x0','\x0','\x0','\x0'}
                     };

void change_MAC(u_char *,int);
void list();
void help();
void addr_scan(char *,u_char *);

int
main(int argc, char ** argv)
{
    char c;
    u_char mac[6] = "\0\0\0\0\0\0";
    int nr = 0,eth_num = 0,nr2 = 0;
    extern char *optarg;

    if (argc == 1)
    {
        printf("for help: changemac -h\n");
        exit(1);
    }

    while ((c = getopt(argc, argv, "-la:rd:")) != EOF)
    {
        switch(c)
        {
            case 'l' :
                list();
                exit(1);
            case 'a' :
                nr++;
                addr_scan(optarg,mac);
                break;
            case 'd' :
                nr2++;
                eth_num = atoi(optarg);
                break;
            default:
                help();
                exit(1);
        }
        if (nr2 > 1 || nr > 1)
        {
            printf("fuck you\n");
            exit(1);
        }
    }
    change_MAC(mac,eth_num);
    return (0);
}

void
change_MAC(u_char *p, int ether)
{
    struct  ifreq  devea;
    int s, i;

    s = socket(AF_INET, SOCK_DGRAM, 0);
    if (s < 0)
    {
        perror("socket");
        exit(1);
    }
    sprintf(devea.ifr_name, "eth%d", ether);
    if (ioctl(s, SIOCGIFHWADDR, &devea) < 0)
    {
        perror(devea.ifr_name);
        exit(1);
    }
    printf("current MAC is\t");
    for (i = 0; i < 6; i++)
    {
        printf("%2.2x ", i[devea.ifr_hwaddr.sa_data] & 0xff);
    }
    printf("\n");
    for(i = 0; i < 6; i++) i[devea.ifr_hwaddr.sa_data] = i[p];
    printf("changing MAC to\t");
    printf("%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x\n", 0[p], 1[p], 2[p], 3[p], 4[p], 5[p]);


    if (ioctl(s,SIOCSIFHWADDR,&devea) < 0)
    {
        printf("shit - eth%d device is dead\n", ether);
        perror(devea.ifr_name);
        exit(1);
    }
    printf("MAC changed\n");

    /* just to be sure ... */

    if (ioctl(s, SIOCGIFHWADDR, &devea) < 0)
    {
        perror(devea.ifr_name);
        exit(1);
    }

    printf("current MAC is: ");

    for (i = 0; i < 6; i++) printf("%X ", i[devea.ifr_hwaddr.sa_data] & 0xff);
    printf("\n");

    close(s);
}

void
list()
{
    int i = 0;
    struct LIST *ptr;

    printf("\n number\t MAC addr \t vendor\n");
    while (0[i[vendors].name])
    {
        ptr = vendors + i;
        printf("%d\t=> %2.2x:%2.2x:%2.2x \t%s \n",
            i++,
            0[ptr->mac],
            1[ptr->mac],
            2[ptr->mac],
            ptr->name);
        if (!(i % 15))
        {
            printf("\n smash enter\n");
            getchar();
        }
    }
}

void
addr_scan(char *arg, u_char *mac)
{
    int i;

    if (!(2[arg] == ':' &&
            5[arg] == ':' &&
            8[arg] == ':' &&
            11[arg] == ':' &&
            14[arg] == ':' &&
            strlen(arg) == 17 ))
    {
        printf("shitty address\n");
        exit(0);
    }
    for(i = 0; i < 6; i++) i[mac] = (char)(strtoul(arg + i*3, 0, 16) & 0xff);
}

void
help()
{
    printf(" you lazy bitches! figure out what the fuck did i write! :>\n");
}
