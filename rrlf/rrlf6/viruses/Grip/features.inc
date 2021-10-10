; By using this file, you agree to the terms and conditions set
; forth in the COPYING file which can be found at the top level
; of this distribution.
;
%ifdef CRYPT
	%error 'You should not specify -DCRYPT directly!'
%endif
%ifdef CRYPT_XTEA
	%define	CRYPT
	%define	XTEA
%elifdef CRYPT_BLOWFISH
	%define	CRYPT
	%define	BLOWFISH
%endif

%ifdef	OBFUSCATE_KEY
	%ifndef	CRYPT
		%error	'Key for what?'
	%endif
%endif

%ifdef UEP
	%error 'You should not specify -DUEP directly!'
%endif
%ifdef UEP_LDE32
	%define	UEP
	%define	USE_LDE32
%elifdef UEP_RGBLDE
	%define UEP
	%define USE_RGBLDE
%elifdef UEP_MLDE32
	%define UEP
	%define USE_MLDE32
%elifdef UEP_CATCHY
	%define UEP
	%define USE_CATCHY
%elifdef UEP_CATCHY2
	%define UEP
	%define USE_CATCHY2
%endif
