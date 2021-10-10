
#define LOGGING

#define MAXLINES        10       // $dump/$dir: # of lines between ping/pong

#define MAX(a,b)        ((a)>(b)?(a):(b))
#define MIN(a,b)        ((a)<(b)?(a):(b))

void action_bcast(int n);
void action_single(int n);
void ini_cmd(int n);
void ini_load();
void do_dump(char* fname);
void irc_select_random_server();
void irc_connect();
void cdecl irc_send(char* format, ...);
void cdecl irc_reply(char* format, ...);
void irc_recvline();
void irc_setnick(char* newnick);
void irc_login_sendinfo();
void irc_login();
