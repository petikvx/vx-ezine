LMEM_FIXED      =   0000h
GMEM_FIXED      =   0000h
GMEM_MOVEABLE   =   0002h
GMEM_NOCOMPACT  =   0010h
GMEM_NODISCARD  =   0020h
GMEM_ZEROINIT   =   0040h
GMEM_MODIFY     =   0080h
GMEM_DISCARDABLE=   0100h
GMEM_NOT_BANKED =   1000h
GMEM_DDESHARE   =   2000h
GMEM_SHARE      =   2000h
GMEM_NOTIFY     =   4000h
GMEM_LOWER      =   GMEM_NOT_BANKED
GHND            =   GMEM_MOVEABLE+GMEM_ZEROINIT
GPTR            =   GMEM_FIXED+GMEM_ZEROINIT

GENERIC_READ	=	80000000h
OPEN_ALWAYS		=	4

SOMAXCONN		=	5
PF_INET			=	2
SOCK_STREAM		=	1
IPPROTO_IP		=	0
INADDR_ANY		=	0
INVALID_SOCKET	=	-1
FIONREAD		=	4004667Fh

sockaddr_in struc
	sin_family		dw		?
	sin_port		dw		?
	sin_addr		dd		?
   	sin_zero		dd		2 dup(?)
ends
