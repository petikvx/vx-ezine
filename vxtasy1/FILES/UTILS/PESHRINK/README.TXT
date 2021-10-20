
PEShrink.ASM

        This is a tool designed to shorten the PE files. It's main idea is to
 remove  the  relocations  section,  which is obsolete and realign the end of
 file.

 Command line:

        PESHRINK <filename>

        To compile PESHRINK type:

        MAKE

        but  be sure you set the right directory for the import32.lib file in
 the MAKEFILE file.

        DISCLAIMER:  This  utility  was not tested to the full extent and the
 author  may  not  be held responsible for the damages produced on certain PE
 files which rendered them to being unfunctionable.

                                Lord Julus - 1999
