
 ** Bat.Unborn Leader ** [DvL] - also published on rRLF #4

 size: 10.927 bytes
 runs on: win9x

 ** Capabilities **

 * multi-infector, infects .bat, .reg, .theme, autorun.inf, .com, .inf
 * in autorun.inf infection the virus will run every time the user enters
   in "my computer"
 * in .com infection, some .com files will be overwrited with a small .com
   file that only displays a silly message (payload), it can not spread itself
 * in .inf infection was designed to affect the desktop.inf file used by atari
   to display the desktop of the current machine running, but it will also
   overwrite all .inf files from "inf" folder or any other it founds
 * atacks Kaspersky AntiVirus via registry
 * spreads via p2p
 * it will copy itself on every disk (except b:\)
 * it will set my webpage as the default internet startup page
 * it will run every time the computer is restarted via registry