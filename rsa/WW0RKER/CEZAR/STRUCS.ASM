lfile_header    struc
pksign          dw      0
lfsign          dw      0
ver             dw      0
bitflag         dw      0
comp_method     dw      0
modtime         dw      0
moddate         dw      0
crc32           dw      0,0
compsize        dw      0,0
uncompsize      dw      0,0
fname_len       dw      0
extra_len       dw      0
lfile_header    ends

dir_header      struc
dir_pksign      dw      0
dir_sign        dw      0
dir_version     dw      0
dir_vex         dw      0
dir_bitflag     dw      0
dir_comp_method dw      0
dir_modtime     dw      0
dir_moddate     dw      0
dir_crc32       dw      0,0
dir_compsize    dw      0,0
dir_uncompsize  dw      0,0
dir_fname_len   dw      0
dir_extra_len   dw      0
dir_coment_len  dw      0
dir_dns         dw      0
dir_ifa         dw      0
dir_efa         dw      0,0
dir_rolf        dw      0,0
dir_header      ends

edir_header     struc
edir_pksign     dw      0
edir_sign       dw      0
edir_notd       dw      0
edir_scd        dw      0
edir_cdod       dw      0
edir_cd         dw      0
edir_size_cd    dw      0,0
edir_sdn        dw      0,0
edir_coment_len dw      0
edir_header     ends

ArjArcHeader    struc
A_Sig           dw      0
A_BasicHeadSize dw      0
A_HeadSize1     db      0
A_Version       db      0
A_MinVersion    db      0
A_OS            db      0
A_Flags         db      0
A_SecurityVer   db      0
A_FileType      db      0
A_Reserved      db      0
A_CreateDate    dw      0,0
A_ModDate       dw      0,0
A_ArcSize       dw      0,0
A_SecurityOffset dw     0,0
A_FileSpecPos   dw      0
A_SecurityLength dw     0
A_Reserved1     dw      0
ArjArcHeader	ends

ArjFileHead	struc
F_Sig		dw	0
F_BHSize	dw	0
F_HSize1	db	0
F_Version	db	0
F_MinVersion	db	0
F_OS		db	0
F_Flags 	db	0
F_Method	db	0
F_FileType	db	0
F_Res		db	0
F_ModDate	dw	0,0
F_CompSize	dw	0,0
F_OrgSize	dw	0,0
F_Crc32 	dw	0,0
F_FileSpecPos	dw	0
F_FAccessMode	dw	0
F_HostData	dw	0
ArjFileHead	ends


