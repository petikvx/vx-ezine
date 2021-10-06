.386p 
include vmm.inc 
include shell.inc

DECLARE_VIRTUAL_DEVICE MESSAGE,1,0, MESSAGE_Control, UNDEFINED_DEVICE_ID, UNDEFINED_INIT_ORDER

Begin_control_dispatch MESSAGE
	Control_Dispatch Create_Process, evileye
End_control_dispatch MESSAGE

VxD_PAGEABLE_DATA_SEG
MsgTitle  	db "WindowsUserProfileInformation:",0
VMCreated 	db "The current user is lame as hell!!!!",0
VxD_PAGEABLE_DATA_ENDS

VxD_PAGEABLE_CODE_SEG

BeginProc evileye
	mov ecx, OFFSET32 VMCreated
	VMMCall Get_sys_vm_handle
        mov eax,MB_OK
	mov edi, OFFSET32 MsgTitle
	xor esi,esi
	xor edx,edx
        VxDCall SHELL_sysmodal_Message		
	ret
EndProc evileye

VxD_PAGEABLE_CODE_ENDS

end
