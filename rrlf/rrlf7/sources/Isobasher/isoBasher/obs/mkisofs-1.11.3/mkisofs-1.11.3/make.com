$!
$! $Id: make.com,v 1.1 1997/02/23 15:55:47 eric Rel $
$!
$! Set the def dir to proper place for use in batch. Works for interactive too.
$flnm = f$enviroment("PROCEDURE")     ! get current procedure name
$set default 'f$parse(flnm,,,"DEVICE")''f$parse(flnm,,,"DIRECTORY")'
$!
$!
$if "''p1'".eqs."LINK" then goto link
$gcc/debug mkisofs.c
$gcc/debug write.c
$gcc/debug tree.c
$gcc/debug hash.c
$gcc/debug rock.c
$gcc/debug vms.c
$gcc/debug exclude.c
$link:
$link mkisofs.obj+write.obj+tree.obj+hash.obj+rock.obj+vms.obj+exclude.obj+  -
	gnu_cc:[000000]gcclib/lib+sys$library:vaxcrtl/lib
