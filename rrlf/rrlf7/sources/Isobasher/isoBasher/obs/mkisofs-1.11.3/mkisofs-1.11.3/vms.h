/*
 * Header file mkisofs.h - assorted structure definitions and typecasts.

   Written by Eric Youngdale (1993).

 * $Id: vms.h,v 1.1 1997/02/23 15:59:18 eric Rel $
 */

#ifdef VMS
#define stat(X,Y) VMS_stat(X,Y)
#define lstat VMS_stat

/* gmtime not available under VMS - make it look like we are in Greenwich */
#define gmtime localtime

#define S_ISBLK(X) (0)
#define S_ISCHR(X) (0)
#define S_ISREG(X)  (((X) & S_IFMT) == S_IFREG)
#define S_ISDIR(X)  (((X) & S_IFMT) == S_IFDIR)
#endif
