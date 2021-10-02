
/* DEBUG parameters */

#define SKIP_PRINTF
#define SKIP_DEBUGFILES

/* ENGINE parameters */

#define SKIP_JMPS
//#define SKIP_JMPS_BUT_ADD_NOPS

#define RANDOM_JCC
//#define INVERSE_JCC

#define SKIP_NOP
//#define SKIP_INT3

#define SKIP_RANDOM

#define ADD_RANDOM       30
#define CHANGE_CMD

//#define FILL_UNUSED_CC
#define FILL_UNUSED_RANDOM

#define USE_RANDOM_IP    20

#define min_left         20
#define min_right        40
#define min_right_left   20

#define KILL_J2J
#define MAKE_SHORT_JMPS





#define max_size 0x3000+0x0100
#define max_cmd  3000
