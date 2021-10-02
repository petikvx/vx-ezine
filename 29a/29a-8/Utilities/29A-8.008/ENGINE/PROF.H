
/* profile management */

#ifndef __PROF_H__
#define __PROF_H__

#include "shge.h"

void __cdecl set_default_profile(struct SHGE_OPTIONS *opt);
int __cdecl load_profile(struct SHGE_OPTIONS *opt, char* filename);
int __cdecl save_profile(struct SHGE_OPTIONS *opt, char* filename);

#endif // __PROF_H__

/* EOF */
