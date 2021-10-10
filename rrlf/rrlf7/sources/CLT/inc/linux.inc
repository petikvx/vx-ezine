.xlist
;==========================================================================
dirent				STRUC
				
	dirent_ino		dd	?
	dirent_off		dd	?
	dirent_reclen		dw	?
	dirent_name		db 256 dup(?)
	
dirent				ENDS

;--------------------------------------------------------------------------
stat				STRUC

	stat_dev		dw	?
	stat_pad1		dw	?
	stat_ino		dd	?
	stat_mode 		dw	?
	stat_nlink 		dw	?
	stat_uid 		dw	?
	stat_gid		dw	?
	stat_rdev 		dw	?
	stat_pad2 		dw	?
	stat_size 		dd	?
	stat_blksize 		dd	?
	stat_blocks		dd	?
	stat_atime		dd	?
	stat_unused1		dd	?    
	stat_mtime		dd	?
	stat_unused2		dd	?
	stat_ctime		dd	?
	stat_unused3		dd	?
	stat_unused4		dd	?
	stat_unused5		dd	?

stat				ENDS

;--------------------------------------------------------------------------
tSeekOrigin                     ENUM {        
        SEEK_BEGIN              =       0,
        SEEK_CURRENT            =       1,
        SEEK_END                =       2
}

;--------------------------------------------------------------------------
PROT_READ		= 1
PROT_WRITE              = 2
;--------------------------------------------------------------------------
MAP_SHARED		= 01h
MAP_PRIVATE             = 02h

;==========================================================================
.list

