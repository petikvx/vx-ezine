/* this function for Windows NT specific resolver stuff L. Kahn */

#include <inet.h>
#include <nameser.h>
#include <stdio.h>
#include <ctype.h>
#include <resolv.h>
#include <netdb.h>
#include "portability.h"

char pathnetworks[_MAX_PATH];
char pathhosts[_MAX_PATH];
char pathresconf[_MAX_PATH];

int res_paths_initialized = 0;


/* lgk new function to initialize path variables that are outside the scope of the main */
/* for backwards compatibility allow either resolv.conf or resolv.ini */
void init_res_paths()
{
   FILE *fp;
   
	if (!ExpandEnvironmentStrings(_PATH_HOSTS, pathhosts, MAX_PATH)) 
		syslog(LOG_ERR, "ExpandEnvironmentStrings(_PATH_HOSTS) failed: %m\n");

	if (!ExpandEnvironmentStrings(_PATH_NETWORKS, pathnetworks, MAX_PATH))
		syslog(LOG_ERR, "ExpandEnvironmentStrings(_PATH_NETWORKS) failed: %m\n");

	if (!ExpandEnvironmentStrings(_PATH_RESCONF, pathresconf, MAX_PATH)) 
		syslog(LOG_ERR, "ExpandEnvironmentStrings(_PATH_RESCONF) failed: %m\n");

     	else
          {
            if ((fp = fopen(pathresconf, "r")) == NULL)
              {
                /* try alternate name */
 	        if (!ExpandEnvironmentStrings(_ALT_PATH_RESCONF, pathresconf, MAX_PATH)) 
	  	  syslog(LOG_ERR, "ExpandEnvironmentStrings(_ALT_PATH_RESCONF) failed: %m\n");
              }
            else fclose(fp);
	  }

		
    res_paths_initialized = 1;
}


