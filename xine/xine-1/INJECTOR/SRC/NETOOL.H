

#define UNKNOWN		0
#define TCPIP		1
#define UDPIP		2
#define ICMP		3
#define IPUNKNOWN	4
#define ARP		5


struct netpacket
	{
		int		type;
		unsigned int	proto;
		unsigned char 	ethfrom[6];
		unsigned char	ethto[6];
		unsigned char	ipfrom[4];
		unsigned char 	ipto[4];
		unsigned int	portfrom;
		unsigned int	portto;
		int		isfrag;
		unsigned int	fragoff;
		int		ismorefrag;
		int		id;
		int		issyn;
		int		isack;
		int		isfin;
		unsigned char	etharp[6];
		unsigned char	textdata[4000];
	};


void analyze(char *, struct netpacket *);

int atoip (char *, char * ip);