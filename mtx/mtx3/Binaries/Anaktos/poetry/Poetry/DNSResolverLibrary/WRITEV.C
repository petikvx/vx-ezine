#ifndef LINT
static char rcsid[] = "$Id: writev.c,v 8.2 1996/08/08 22:49:37 vixie Exp $";
#endif

/* writev() emulations contained in this source file for the following systems:
 *
 *	Cray UNICOS
 *	SCO
 *  WindowsNT
 */

#if defined(_CRAY)
#define OWN_WRITEV
#include <sys/types.h>
#include <sys/uio.h>
#include <sys/stat.h>
#include <sys/socket.h>

int
__writev(int fd, struct iovec *iov, int iovlen)
{
	struct stat statbuf;

	if (fstat(fd, &statbuf) < 0)
		return (-1);

	/*
	 * Allow for atomic writes to network.
	 */
	if (statbuf.st_mode & S_IFSOCK) {
		struct msghdr   mesg;		

		mesg.msg_name = 0;
		mesg.msg_namelen = 0;
		mesg.msg_iov = iov;
		mesg.msg_iovlen = iovlen;
		mesg.msg_accrights = 0;
		mesg.msg_accrightslen = 0;
		return (sendmsg(fd, &mesg, 0));
	} else {
		register struct iovec *tv;
		register int i, rcode = 0, count = 0;

		for (i = 0, tv = iov; i <= iovlen; tv++) {
			rcode = write(fd, tv->iov_base, tv->iov_len);

			if (rcode < 0)
				break;

			count += rcode;
		}

		if (count == 0)
			return (rcode);
		else
			return (count);
	}
}
#endif

#if defined (M_UNIX) && !defined(_SCO_DS) || defined (NEED_WRITEV)
#define OWN_WRITEV
#include <stdio.h>
#include <sys/types.h>
#include <sys/uio.h>

int
__writev(fd, vp, vpcount)
	int fd;
	const struct iovec *vp;
	register int vpcount;
{
	register int count = 0;

	while (vpcount-- > 0) {
		register int written = write(fd, vp->iov_base, vp->iov_len);

		if (written <= 0)
			return (-1);
		count += written;
		vp++;
	}
	return (count);
}
#endif

#ifdef WINNT
#define OWN_WRITEV
#define TIMEOUT_SEC 120
#include <stdarg.h>
#include "portability.h"


/*
 * writev --
 * simplistic writev implementation for WindowsNT using the WriteFile WIN32API.
 */	
/* lgk win95 does not support overlapped/async file operations so change it to
   synchronous */
#ifndef WIN95
 
int
writev(fd, iov, iovcnt)
	int fd;
	struct iovec *iov;
	int iovcnt;
{
	int i;
	char *base;
	DWORD BytesWritten, TotalBytesWritten = 0, len, dwWait;
	static HANDLE hReadWriteEvent;
	OVERLAPPED overlap;
	BOOL ret; 

    if (!hReadWriteEvent) {
        hReadWriteEvent = CreateEvent(NULL, FALSE, FALSE, NULL);
    }

	for (i=0; i<iovcnt; i++) {
		base = iov[i].iov_base;
		len = (DWORD)iov[i].iov_len;
		overlap.Offset = overlap.OffsetHigh = (DWORD)0;
		overlap.hEvent = hReadWriteEvent;
		ret = WriteFile((HANDLE)fd, (char *)base, len,
		              (LPDWORD)&BytesWritten, (LPOVERLAPPED)&overlap);
		if ((ret == FALSE) && (errno != ERROR_IO_PENDING)) {
				return (-1);
		}
		dwWait = WaitForSingleObject((HANDLE)hReadWriteEvent, (DWORD)TIMEOUT_SEC * 1000);
		if ((dwWait == WAIT_FAILED) || (dwWait == WAIT_TIMEOUT)){
			return (-1);
		}
		TotalBytesWritten += BytesWritten;
	}
	return((int)TotalBytesWritten);
}

#else // is win95 ... no async overlapped io
 
int
writev(fd, iov, iovcnt)
	int fd;
	struct iovec *iov;
	int iovcnt;
{
	int i;
	char *base;
	DWORD BytesWritten, TotalBytesWritten = 0, len, dwWait;
	BOOL ret; 

	for (i=0; i<iovcnt; i++) {
		base = iov[i].iov_base;
		len = (DWORD)iov[i].iov_len;
		ret = WriteFile((HANDLE)fd, (char *)base, len,
		              (LPDWORD)&BytesWritten, NULL);
		if (ret == FALSE)
		   return (-1);
		TotalBytesWritten += BytesWritten;
	}
	return((int)TotalBytesWritten);
}

#endif // win95 or not
#endif // winnt

#ifndef OWN_WRITEV
int __bindcompat_writev;
#endif
