#ifndef LINT
static char rcsid[] = "$Id: gettimeofday.c,v 8.1 1994/12/15 06:23:51 vixie Exp $";
#endif

#include "portability.h"

#if !defined(NEED_GETTIMEOFDAY)
int __bindcompat_gettimeofday;
#else
int
gettimeofday(tvp, tzp)
	struct timeval *tvp;
	struct _TIMEZONE *tzp;
{
#ifndef WINNT
	time_t clock, time __P((time_t *));

	if (time(&clock) == (time_t) -1)
		return (-1);
	if (tvp) {
		tvp->tv_sec = clock;
		tvp->tv_usec = 0;
	}
	if (tzp) {
		tzp->tz_minuteswest = 0;
		tzp->tz_dsttime = 0;
	}
#else
	struct _timeb timebuffer;
	_ftime(&timebuffer);
	tvp->tv_sec = (long) timebuffer.time;
	tvp->tv_usec = (long) (1000 * (timebuffer.millitm));
#endif
	return (0);
}

#endif /*NEED_GETTIMEOFDAY*/
