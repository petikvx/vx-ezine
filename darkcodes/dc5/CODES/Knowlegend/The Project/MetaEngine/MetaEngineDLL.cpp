/*
	Author: Know v3.0
	Twitter: @KnowV3
	Email: know [dot] omail [dot] pro
	Website: knowlegend.ws / knowlegend.me

	(c) 2013 - Know v3.0 alias Knowlgend
*/
#include "MetaEngineDLL.h"
enum INSTRUCTIONS_E { // enum with all available instructions as static number
		PUSH_EAX,
		PUSH_EBX,
		PUSH_ECX,
		PUSH_EDX,
		PUSH_EEX,
		PUSH_EFX,
		PUSH_EGX,

		POP_EAX,
		POP_EBX,
		POP_ECX,
		POP_EDX,
		POP_EEX,
		POP_EFX,
		POP_EGX,

		CALL_EAX,
		CALL_EBX,
		CALL_ECX,
		CALL_EDX,
		CALL_EEX,
		CALL_EFX,
		CALL_EGX,

		MOV_EAX_EAX,
		MOV_EAX_EBX,
		MOV_EAX_ECX,
		MOV_EAX_EDX,
		MOV_EAX_EEX,
		MOV_EAX_EFX,
		MOV_EAX_EGX,

		MOV_EAX__EAX_, // __ == [ or ] that means that this instruction looks like: mov eax, [eax]
		MOV_EAX__EBX_,
		MOV_EAX__ECX_,
		MOV_EAX__EDX_,
		MOV_EAX__EEX_,
		MOV_EAX__EFX_,
		MOV_EAX__EGX_,

		MOV_EAX__EAX_4_, // mov eax, [eax+4]
		MOV_EAX__EBX_4_,
		MOV_EAX__ECX_4_,
		MOV_EAX__EDX_4_,
		MOV_EAX__EEX_4_,
		MOV_EAX__EFX_4_,
		MOV_EAX__EGX_4_,

		MOV_EBX_EBX,
		MOV_EBX_EAX,
		MOV_EBX_ECX,
		MOV_EBX_EDX,
		MOV_EBX_EEX,
		MOV_EBX_EFX,
		MOV_EBX_EGX,

		MOV_EBX__EBX_,
		MOV_EBX__EAX_,
		MOV_EBX__ECX_,
		MOV_EBX__EDX_,
		MOV_EBX__EEX_,
		MOV_EBX__EFX_,
		MOV_EBX__EGX_,

		MOV_EBX__EBX_4_,
		MOV_EBX__EAX_4_,
		MOV_EBX__ECX_4_,
		MOV_EBX__EDX_4_,
		MOV_EBX__EEX_4_,
		MOV_EBX__EFX_4_,
		MOV_EBX__EGX_4_,

		MOV_ECX_ECX,
		MOV_ECX_EAX,
		MOV_ECX_EBX,
		MOV_ECX_EDX,
		MOV_ECX_EEX,
		MOV_ECX_EFX,
		MOV_ECX_EGX,

		MOV_ECX__ECX_,
		MOV_ECX__EAX_,
		MOV_ECX__EBX_,
		MOV_ECX__EDX_,
		MOV_ECX__EEX_,
		MOV_ECX__EFX_,
		MOV_ECX__EGX_,

		MOV_ECX__ECX_4_,
		MOV_ECX__EAX_4_,
		MOV_ECX__EBX_4_,
		MOV_ECX__EDX_4_,
		MOV_ECX__EEX_4_,
		MOV_ECX__EFX_4_,
		MOV_ECX__EGX_4_,

		MOV_EDX_EDX,
		MOV_EDX_EAX,
		MOV_EDX_EBX,
		MOV_EDX_ECX,
		MOV_EDX_EEX,
		MOV_EDX_EFX,
		MOV_EDX_EGX,
		
		MOV_EDX__EDX_,
		MOV_EDX__EAX_,
		MOV_EDX__EBX_,
		MOV_EDX__ECX_,
		MOV_EDX__EEX_,
		MOV_EDX__EFX_,
		MOV_EDX__EGX_,

		MOV_EDX__EDX_4_,
		MOV_EDX__EAX_4_,
		MOV_EDX__EBX_4_,
		MOV_EDX__ECX_4_,
		MOV_EDX__EEX_4_,
		MOV_EDX__EFX_4_,
		MOV_EDX__EGX_4_,

		MOV_EEX_EEX,
		MOV_EEX_EAX,
		MOV_EEX_EBX,
		MOV_EEX_ECX,
		MOV_EEX_EDX,
		MOV_EEX_EFX,
		MOV_EEX_EGX,
		
		MOV_EEX__EEX_,
		MOV_EEX__EAX_,
		MOV_EEX__EBX_,
		MOV_EEX__ECX_,
		MOV_EEX__EDX_,
		MOV_EEX__EFX_,
		MOV_EEX__EGX_,

		MOV_EEX__EEX_4_,
		MOV_EEX__EAX_4_,
		MOV_EEX__EBX_4_,
		MOV_EEX__ECX_4_,
		MOV_EEX__EDX_4_,
		MOV_EEX__EFX_4_,
		MOV_EEX__EGX_4_,

		MOV_EFX_EFX,
		MOV_EFX_EAX,
		MOV_EFX_EBX,
		MOV_EFX_ECX,
		MOV_EFX_EDX,
		MOV_EFX_EEX,
		MOV_EFX_EGX,

		MOV_EFX__EFX_,
		MOV_EFX__EAX_,
		MOV_EFX__EBX_,
		MOV_EFX__ECX_,
		MOV_EFX__EDX_,
		MOV_EFX__EEX_,
		MOV_EFX__EGX_,

		MOV_EFX__EFX_4_,
		MOV_EFX__EAX_4_,
		MOV_EFX__EBX_4_,
		MOV_EFX__ECX_4_,
		MOV_EFX__EDX_4_,
		MOV_EFX__EEX_4_,
		MOV_EFX__EGX_4_,

		MOV_EGX_EGX,
		MOV_EGX_EAX,
		MOV_EGX_EBX,
		MOV_EGX_ECX,
		MOV_EGX_EDX,
		MOV_EGX_EEX,
		MOV_EGX_EFX,

		MOV_EGX__EGX_,
		MOV_EGX__EAX_,
		MOV_EGX__EBX_,
		MOV_EGX__ECX_,
		MOV_EGX__EDX_,
		MOV_EGX__EEX_,
		MOV_EGX__EFX_,

		MOV_EGX__EGX_4_,
		MOV_EGX__EAX_4_,
		MOV_EGX__EBX_4_,
		MOV_EGX__ECX_4_,
		MOV_EGX__EDX_4_,
		MOV_EGX__EEX_4_,
		MOV_EGX__EFX_4_,

		MOV_EAX_0,
		MOV_EBX_0,
		MOV_ECX_0,
		MOV_EDX_0,
		MOV_EEX_0,
		MOV_EFX_0,
		MOV_EGX_0,

		XOR_EAX_EAX,
		XOR_EAX_EBX,
		XOR_EAX_ECX,
		XOR_EAX_EDX,
		XOR_EAX_EEX,
		XOR_EAX_EFX,
		XOR_EAX_EGX,

		XOR_EBX_EBX,
		XOR_EBX_EAX,
		XOR_EBX_ECX,
		XOR_EBX_EDX,
		XOR_EBX_EEX,
		XOR_EBX_EFX,
		XOR_EBX_EGX,

		XOR_ECX_ECX,
		XOR_ECX_EAX,
		XOR_ECX_EBX,
		XOR_ECX_EDX,
		XOR_ECX_EEX,
		XOR_ECX_EFX,
		XOR_ECX_EGX,

		XOR_EDX_EDX,
		XOR_EDX_EAX,
		XOR_EDX_EBX,
		XOR_EDX_ECX,
		XOR_EDX_EEX,
		XOR_EDX_EFX,
		XOR_EDX_EGX,

		XOR_EEX_EEX,
		XOR_EEX_EAX,
		XOR_EEX_EBX,
		XOR_EEX_ECX,
		XOR_EEX_EDX,
		XOR_EEX_EFX,
		XOR_EEX_EGX,

		XOR_EFX_EFX,
		XOR_EFX_EAX,
		XOR_EFX_EBX,
		XOR_EFX_ECX,
		XOR_EFX_EDX,
		XOR_EFX_EEX,
		XOR_EFX_EGX,

		XOR_EGX_EGX,
		XOR_EGX_EAX,
		XOR_EGX_EBX,
		XOR_EGX_ECX,
		XOR_EGX_EDX,
		XOR_EGX_EEX,
		XOR_EGX_EFX,

		ADD_EAX_EAX,
		ADD_EAX_EBX,
		ADD_EAX_ECX,
		ADD_EAX_EDX,
		ADD_EAX_EEX,
		ADD_EAX_EFX,
		ADD_EAX_EGX,

		ADD_EBX_EBX,
		ADD_EBX_EAX,
		ADD_EBX_ECX,
		ADD_EBX_EDX,
		ADD_EBX_EEX,
		ADD_EBX_EFX,
		ADD_EBX_EGX,

		ADD_ECX_ECX,
		ADD_ECX_EAX,
		ADD_ECX_EBX,
		ADD_ECX_EDX,
		ADD_ECX_EEX,
		ADD_ECX_EFX,
		ADD_ECX_EGX,

		ADD_EDX_EDX,
		ADD_EDX_EAX,
		ADD_EDX_EBX,
		ADD_EDX_ECX,
		ADD_EDX_EEX,
		ADD_EDX_EFX,
		ADD_EDX_EGX,

		ADD_EEX_EEX,
		ADD_EEX_EAX,
		ADD_EEX_EBX,
		ADD_EEX_ECX,
		ADD_EEX_EDX,
		ADD_EEX_EFX,
		ADD_EEX_EGX,

		ADD_EFX_EFX,
		ADD_EFX_EAX,
		ADD_EFX_EBX,
		ADD_EFX_ECX,
		ADD_EFX_EDX,
		ADD_EFX_EEX,
		ADD_EFX_EGX,

		ADD_EGX_EGX,
		ADD_EGX_EAX,
		ADD_EGX_EBX,
		ADD_EGX_ECX,
		ADD_EGX_EDX,
		ADD_EGX_EEX,
		ADD_EGX_EFX,
	

		ADD_EAX_4,
		ADD_EBX_4,
		ADD_ECX_4,
		ADD_EDX_4,
		ADD_EEX_4,
		ADD_EFX_4,
		ADD_EGX_4,

		SUB_EAX_EBX,
		SUB_EAX_ECX,
		SUB_EAX_EDX,
		SUB_EAX_EEX,
		SUB_EAX_EFX,
		SUB_EAX_EGX,

		SUB_EBX_EAX,
		SUB_EBX_ECX,
		SUB_EBX_EDX,
		SUB_EBX_EEX,
		SUB_EBX_EFX,
		SUB_EBX_EGX,

		SUB_ECX_EAX,
		SUB_ECX_EBX,
		SUB_ECX_EDX,
		SUB_ECX_EEX,
		SUB_ECX_EFX,
		SUB_ECX_EGX,

		SUB_EDX_EAX,
		SUB_EDX_EBX,
		SUB_EDX_ECX,
		SUB_EDX_EEX,
		SUB_EDX_EFX,
		SUB_EDX_EGX,

		SUB_EEX_EAX,
		SUB_EEX_EBX,
		SUB_EEX_ECX,
		SUB_EEX_EDX,
		SUB_EEX_EFX,
		SUB_EEX_EGX,

		SUB_EFX_EAX,
		SUB_EFX_EBX,
		SUB_EFX_ECX,
		SUB_EFX_EDX,
		SUB_EFX_EEX,
		SUB_EFX_EGX,

		SUB_EGX_EAX,
		SUB_EGX_EBX,
		SUB_EGX_ECX,
		SUB_EGX_EDX,
		SUB_EGX_EEX,
		SUB_EGX_EFX,

		SUB_EAX_4,
		SUB_EBX_4,
		SUB_ECX_4,
		SUB_EDX_4,
		SUB_EEX_4,
		SUB_EFX_4,
		SUB_EGX_4

};

#define CONNECT(num, str, func) MetaEngine::INSTRUCTION->at(num) = str; FUNC(num, func);

MetaEngine::MetaEngine(BastardEngine *bastard) {
	this->bastard = bastard;
	INSTRUCTION = new vector<char*>(500);
	FUNCTIONS = new vector<int>(500);
	// connect the instruction number(arg 1) with the instruction string(arg 2)
	// and the function(arg 3) that will called if the instruction is executed 
	CONNECT(PUSH_EAX, "push eax", &MetaEngine::push_eax);
	CONNECT(PUSH_EBX, "push ebx", &MetaEngine::push_ebx);
	CONNECT(PUSH_ECX, "push ecx", &MetaEngine::push_ecx);
	CONNECT(PUSH_EDX, "push edx", &MetaEngine::push_edx);
	CONNECT(PUSH_EEX, "push eex", &MetaEngine::push_eex);
	CONNECT(PUSH_EFX, "push efx", &MetaEngine::push_efx);
	CONNECT(PUSH_EGX, "push egx", &MetaEngine::push_egx);

	CONNECT(POP_EAX, "pop eax", &MetaEngine::pop_eax);
	CONNECT(POP_EBX, "pop ebx", &MetaEngine::pop_ebx);
	CONNECT(POP_ECX, "pop ecx", &MetaEngine::pop_ecx);
	CONNECT(POP_EDX, "pop edx", &MetaEngine::pop_edx);
	CONNECT(POP_EEX, "pop eex", &MetaEngine::pop_eex);
	CONNECT(POP_EFX, "pop efx", &MetaEngine::pop_efx);
	CONNECT(POP_EGX, "pop egx", &MetaEngine::pop_egx);

	CONNECT(CALL_EAX, "call eax", &MetaEngine::call_eax);
	CONNECT(CALL_EBX, "call ebx", &MetaEngine::call_eax);
	CONNECT(CALL_ECX, "call ecx", &MetaEngine::call_ecx);
	CONNECT(CALL_EDX, "call edx", &MetaEngine::call_edx);
	CONNECT(CALL_EEX, "call eex", &MetaEngine::call_eex);
	CONNECT(CALL_EFX, "call efx", &MetaEngine::call_efx);
	CONNECT(CALL_EGX, "call egx", &MetaEngine::call_egx);

	CONNECT(MOV_EAX_EAX, "mov eax, eax", &MetaEngine::mov_eax_eax);
	CONNECT(MOV_EAX_EBX, "mov eax, ebx", &MetaEngine::mov_eax_ebx);
	CONNECT(MOV_EAX_ECX, "mov eax, ecx", &MetaEngine::mov_eax_ecx);
	CONNECT(MOV_EAX_EDX, "mov eax, edx", &MetaEngine::mov_eax_edx);
	CONNECT(MOV_EAX_EEX, "mov eax, eex", &MetaEngine::mov_eax_eex);
	CONNECT(MOV_EAX_EFX, "mov eax, efx", &MetaEngine::mov_eax_efx);
	CONNECT(MOV_EAX_EGX, "mov eax, egx", &MetaEngine::mov_eax_egx);
	CONNECT(MOV_EAX__EAX_, "mov eax, [eax]", &MetaEngine::mov_eax__eax_);
	CONNECT(MOV_EAX__EBX_, "mov eax, [ebx]", &MetaEngine::mov_eax__ebx_);
	CONNECT(MOV_EAX__ECX_, "mov eax, [ecx]", &MetaEngine::mov_eax__ecx_);
	CONNECT(MOV_EAX__EDX_, "mov eax, [edx]", &MetaEngine::mov_eax__edx_);
	CONNECT(MOV_EAX__EEX_, "mov eax, [eex]", &MetaEngine::mov_eax__eex_);
	CONNECT(MOV_EAX__EFX_, "mov eax, [efx]", &MetaEngine::mov_eax__efx_);
	CONNECT(MOV_EAX__EGX_, "mov eax, [egx]", &MetaEngine::mov_eax__egx_);
	CONNECT(MOV_EAX__EAX_4_, "mov eax, [eax+4]", &MetaEngine::mov_eax__eax_4_);
	CONNECT(MOV_EAX__EBX_4_, "mov eax, [ebx+4]", &MetaEngine::mov_eax__ebx_4_);
	CONNECT(MOV_EAX__ECX_4_, "mov eax, [ecx+4]", &MetaEngine::mov_eax__ecx_4_);
	CONNECT(MOV_EAX__EDX_4_, "mov eax, [edx+4]", &MetaEngine::mov_eax__edx_4_);
	CONNECT(MOV_EAX__EEX_4_, "mov eax, [eex+4]", &MetaEngine::mov_eax__eex_4_);
	CONNECT(MOV_EAX__EFX_4_, "mov eax, [efx+4]", &MetaEngine::mov_eax__efx_4_);
	CONNECT(MOV_EAX__EGX_4_, "mov eax, [egx+4]", &MetaEngine::mov_eax__egx_4_);

	CONNECT(MOV_EBX_EBX, "mov ebx, ebx", &MetaEngine::mov_ebx_ebx);
	CONNECT(MOV_EBX_EAX, "mov ebx, eax", &MetaEngine::mov_ebx_eax);
	CONNECT(MOV_EBX_ECX, "mov ebx, ecx", &MetaEngine::mov_ebx_ecx);
	CONNECT(MOV_EBX_EDX, "mov ebx, edx", &MetaEngine::mov_ebx_edx);
	CONNECT(MOV_EBX_EEX, "mov ebx, eex", &MetaEngine::mov_ebx_eex);
	CONNECT(MOV_EBX_EFX, "mov ebx, efx", &MetaEngine::mov_ebx_efx);
	CONNECT(MOV_EBX_EGX, "mov ebx, egx", &MetaEngine::mov_ebx_egx);
	CONNECT(MOV_EBX__EBX_, "mov ebx, [ebx]", &MetaEngine::mov_ebx__ebx_);
	CONNECT(MOV_EBX__EAX_, "mov ebx, [eax]", &MetaEngine::mov_ebx__eax_);
	CONNECT(MOV_EBX__ECX_, "mov ebx, [ecx]", &MetaEngine::mov_ebx__ecx_);
	CONNECT(MOV_EBX__EDX_, "mov ebx, [edx]", &MetaEngine::mov_ebx__edx_);
	CONNECT(MOV_EBX__EEX_, "mov ebx, [eex]", &MetaEngine::mov_ebx__eex_);
	CONNECT(MOV_EBX__EFX_, "mov ebx, [efx]", &MetaEngine::mov_ebx__efx_);
	CONNECT(MOV_EBX__EGX_, "mov ebx, [egx]", &MetaEngine::mov_ebx__egx_);
	CONNECT(MOV_EBX__EBX_4_, "mov ebx, [ebx+4]", &MetaEngine::mov_ebx__ebx_4_);
	CONNECT(MOV_EBX__EAX_4_, "mov ebx, [eax+4]", &MetaEngine::mov_ebx__eax_4_);
	CONNECT(MOV_EBX__ECX_4_, "mov ebx, [ecx+4]", &MetaEngine::mov_ebx__ecx_4_);
	CONNECT(MOV_EBX__EDX_4_, "mov ebx, [edx+4]", &MetaEngine::mov_ebx__edx_4_);
	CONNECT(MOV_EBX__EEX_4_, "mov ebx, [eex+4]", &MetaEngine::mov_ebx__eex_4_);
	CONNECT(MOV_EBX__EFX_4_, "mov ebx, [efx+4]", &MetaEngine::mov_ebx__efx_4_);
	CONNECT(MOV_EBX__EGX_4_, "mov ebx, [egx+4]", &MetaEngine::mov_ebx__egx_4_);


	CONNECT(MOV_ECX_ECX, "mov ecx, ecx", &MetaEngine::mov_ecx_ecx);
	CONNECT(MOV_ECX_EAX, "mov ecx, eax", &MetaEngine::mov_ecx_eax);
	CONNECT(MOV_ECX_EBX, "mov ecx, ebx", &MetaEngine::mov_ecx_ebx);
	CONNECT(MOV_ECX_EDX, "mov ecx, edx", &MetaEngine::mov_ecx_edx);
	CONNECT(MOV_ECX_EEX, "mov ecx, eex", &MetaEngine::mov_ecx_eex);
	CONNECT(MOV_ECX_EFX, "mov ecx, efx", &MetaEngine::mov_ecx_efx);
	CONNECT(MOV_ECX_EGX, "mov ecx, egx", &MetaEngine::mov_ecx_egx);
	CONNECT(MOV_ECX__ECX_, "mov ecx, [ecx]", &MetaEngine::mov_ecx__ecx_);
	CONNECT(MOV_ECX__EAX_, "mov ecx, [eax]", &MetaEngine::mov_ecx__eax_);
	CONNECT(MOV_ECX__EBX_, "mov ecx, [ebx]", &MetaEngine::mov_ecx__ebx_);
	CONNECT(MOV_ECX__EDX_, "mov ecx, [edx]", &MetaEngine::mov_ecx__edx_);
	CONNECT(MOV_ECX__EEX_, "mov ecx, [eex]", &MetaEngine::mov_ecx__eex_);
	CONNECT(MOV_ECX__EFX_, "mov ecx, [efx]", &MetaEngine::mov_ecx__efx_);
	CONNECT(MOV_ECX__EGX_, "mov ecx, [egx]", &MetaEngine::mov_ecx__egx_);
	CONNECT(MOV_ECX__ECX_4_, "mov ecx, [ecx+4]", &MetaEngine::mov_ecx__ecx_4_);
	CONNECT(MOV_ECX__EAX_4_, "mov ecx, [eax+4]", &MetaEngine::mov_ecx__eax_4_);
	CONNECT(MOV_ECX__EBX_4_, "mov ecx, [ebx+4]", &MetaEngine::mov_ecx__ebx_4_);
	CONNECT(MOV_ECX__EDX_4_, "mov ecx, [edx+4]", &MetaEngine::mov_ecx__edx_4_);
	CONNECT(MOV_ECX__EEX_4_, "mov ecx, [eex+4]", &MetaEngine::mov_ecx__eex_4_);
	CONNECT(MOV_ECX__EFX_4_, "mov ecx, [efx+4]", &MetaEngine::mov_ecx__efx_4_);
	CONNECT(MOV_ECX__EGX_4_, "mov ecx, [egx+4]", &MetaEngine::mov_ecx__egx_4_);

	CONNECT(MOV_EDX_EDX, "mov edx, edx", &MetaEngine::mov_edx_edx);
	CONNECT(MOV_EDX_EAX, "mov edx, eax", &MetaEngine::mov_edx_eax);
	CONNECT(MOV_EDX_EBX, "mov edx, ebx", &MetaEngine::mov_edx_ebx);
	CONNECT(MOV_EDX_ECX, "mov edx, ecx", &MetaEngine::mov_edx_ecx);
	CONNECT(MOV_EDX_EEX, "mov edx, eex", &MetaEngine::mov_edx_eex);
	CONNECT(MOV_EDX_EFX, "mov edx, efx", &MetaEngine::mov_edx_efx);
	CONNECT(MOV_EDX_EGX, "mov edx, egx", &MetaEngine::mov_edx_egx);
	CONNECT(MOV_EDX__EDX_, "mov edx, [edx]", &MetaEngine::mov_edx__edx_);
	CONNECT(MOV_EDX__EAX_, "mov edx, [eax]", &MetaEngine::mov_edx__eax_);
	CONNECT(MOV_EDX__EBX_, "mov edx, [ebx]", &MetaEngine::mov_edx__ebx_);
	CONNECT(MOV_EDX__ECX_, "mov edx, [ecx]", &MetaEngine::mov_edx__ecx_);
	CONNECT(MOV_EDX__EEX_, "mov edx, [eex]", &MetaEngine::mov_edx__eex_);
	CONNECT(MOV_EDX__EFX_, "mov edx, [efx]", &MetaEngine::mov_edx__efx_);
	CONNECT(MOV_EDX__EGX_, "mov edx, [egx]", &MetaEngine::mov_edx__egx_);
	CONNECT(MOV_EDX__EDX_4_, "mov edx, [edx+4]", &MetaEngine::mov_edx__edx_4_);
	CONNECT(MOV_EDX__EAX_4_, "mov edx, [eax+4]", &MetaEngine::mov_edx__eax_4_);
	CONNECT(MOV_EDX__EBX_4_, "mov edx, [ebx+4]", &MetaEngine::mov_edx__ebx_4_);
	CONNECT(MOV_EDX__ECX_4_, "mov edx, [ecx+4]", &MetaEngine::mov_edx__ecx_4_);
	CONNECT(MOV_EDX__EEX_4_, "mov edx, [eex+4]", &MetaEngine::mov_edx__eex_4_);
	CONNECT(MOV_EDX__EFX_4_, "mov edx, [efx+4]", &MetaEngine::mov_edx__efx_4_);
	CONNECT(MOV_EDX__EGX_4_, "mov edx, [egx+4]", &MetaEngine::mov_edx__egx_4_);


	CONNECT(MOV_EEX_EEX, "mov eex, eex", &MetaEngine::mov_eex_eex);
	CONNECT(MOV_EEX_EAX, "mov eex, eax", &MetaEngine::mov_eex_eax);
	CONNECT(MOV_EEX_EBX, "mov eex, ebx", &MetaEngine::mov_eex_ebx);
	CONNECT(MOV_EEX_ECX, "mov eex, ecx", &MetaEngine::mov_eex_ecx);
	CONNECT(MOV_EEX_EDX, "mov eex, edx", &MetaEngine::mov_eex_edx);
	CONNECT(MOV_EEX_EFX, "mov eex, efx", &MetaEngine::mov_eex_efx);
	CONNECT(MOV_EEX_EGX, "mov eex, egx", &MetaEngine::mov_eex_egx);
	CONNECT(MOV_EEX__EEX_, "mov eex, [eex]", &MetaEngine::mov_eex__eex_);
	CONNECT(MOV_EEX__EAX_, "mov eex, [eax]", &MetaEngine::mov_eex__eax_);
	CONNECT(MOV_EEX__EBX_, "mov eex, [ebx]", &MetaEngine::mov_eex__ebx_);
	CONNECT(MOV_EEX__ECX_, "mov eex, [ecx]", &MetaEngine::mov_eex__ecx_);
	CONNECT(MOV_EEX__EDX_, "mov eex, [edx]", &MetaEngine::mov_eex__edx_);
	CONNECT(MOV_EEX__EFX_, "mov eex, [efx]", &MetaEngine::mov_eex__efx_);
	CONNECT(MOV_EEX__EGX_, "mov eex, [egx]", &MetaEngine::mov_eex__egx_);
	CONNECT(MOV_EEX__EEX_4_, "mov eex, [eex+4]", &MetaEngine::mov_eex__eex_4_);
	CONNECT(MOV_EEX__EAX_4_, "mov eex, [eax+4]", &MetaEngine::mov_eex__eax_4_);
	CONNECT(MOV_EEX__EBX_4_, "mov eex, [ebx+4]", &MetaEngine::mov_eex__ebx_4_);
	CONNECT(MOV_EEX__ECX_4_, "mov eex, [ecx+4]", &MetaEngine::mov_eex__ecx_4_);
	CONNECT(MOV_EEX__EDX_4_, "mov eex, [edx+4]", &MetaEngine::mov_eex__edx_4_);
	CONNECT(MOV_EEX__EFX_4_, "mov eex, [efx+4]", &MetaEngine::mov_eex__efx_4_);
	CONNECT(MOV_EEX__EGX_4_, "mov eex, [egx+4]", &MetaEngine::mov_eex__egx_4_);

	CONNECT(MOV_EFX_EFX, "mov efx, efx", &MetaEngine::mov_efx_efx);
	CONNECT(MOV_EFX_EAX, "mov efx, eax", &MetaEngine::mov_efx_eax);
	CONNECT(MOV_EFX_EBX, "mov efx, ebx", &MetaEngine::mov_efx_ebx);
	CONNECT(MOV_EFX_ECX, "mov efx, ecx", &MetaEngine::mov_efx_ecx);
	CONNECT(MOV_EFX_EDX, "mov efx, edx", &MetaEngine::mov_efx_edx);
	CONNECT(MOV_EFX_EFX, "mov efx, eex", &MetaEngine::mov_efx_eex);
	CONNECT(MOV_EFX_EGX, "mov efx, egx", &MetaEngine::mov_efx_egx);
	CONNECT(MOV_EFX__EEX_, "mov efx, [efx]", &MetaEngine::mov_efx__efx_);
	CONNECT(MOV_EFX__EAX_, "mov efx, [eax]", &MetaEngine::mov_efx__eax_);
	CONNECT(MOV_EFX__EBX_, "mov efx, [ebx]", &MetaEngine::mov_efx__ebx_);
	CONNECT(MOV_EFX__ECX_, "mov efx, [ecx]", &MetaEngine::mov_efx__ecx_);
	CONNECT(MOV_EFX__EDX_, "mov efx, [edx]", &MetaEngine::mov_efx__edx_);
	CONNECT(MOV_EFX__EFX_, "mov efx, [eex]", &MetaEngine::mov_efx__eex_);
	CONNECT(MOV_EFX__EGX_, "mov efx, [egx]", &MetaEngine::mov_efx__egx_);
	CONNECT(MOV_EFX__EEX_4_, "mov efx, [efx+4]", &MetaEngine::mov_efx__efx_4_);
	CONNECT(MOV_EFX__EAX_4_, "mov efx, [eax+4]", &MetaEngine::mov_efx__eax_4_);
	CONNECT(MOV_EFX__EBX_4_, "mov efx, [ebx+4]", &MetaEngine::mov_efx__ebx_4_);
	CONNECT(MOV_EFX__ECX_4_, "mov efx, [ecx+4]", &MetaEngine::mov_efx__ecx_4_);
	CONNECT(MOV_EFX__EDX_4_, "mov efx, [edx+4]", &MetaEngine::mov_efx__edx_4_);
	CONNECT(MOV_EFX__EFX_4_, "mov efx, [eex+4]", &MetaEngine::mov_efx__eex_4_);
	CONNECT(MOV_EFX__EGX_4_, "mov efx, [egx+4]", &MetaEngine::mov_efx__egx_4_);

	CONNECT(MOV_EGX_EGX, "mov egx, egx", &MetaEngine::mov_egx_efx);
	CONNECT(MOV_EGX_EAX, "mov egx, eax", &MetaEngine::mov_egx_eax);
	CONNECT(MOV_EGX_EBX, "mov egx, ebx", &MetaEngine::mov_egx_ebx);
	CONNECT(MOV_EGX_ECX, "mov egx, ecx", &MetaEngine::mov_egx_ecx);
	CONNECT(MOV_EGX_EDX, "mov egx, edx", &MetaEngine::mov_egx_edx);
	CONNECT(MOV_EGX_EFX, "mov egx, eex", &MetaEngine::mov_egx_eex);
	CONNECT(MOV_EGX_EGX, "mov egx, efx", &MetaEngine::mov_egx_egx);
	CONNECT(MOV_EGX__EGX_, "mov egx, [egx]", &MetaEngine::mov_egx__egx_);
	CONNECT(MOV_EGX__EAX_, "mov egx, [eax]", &MetaEngine::mov_egx__eax_);
	CONNECT(MOV_EGX__EBX_, "mov egx, [ebx]", &MetaEngine::mov_egx__ebx_);
	CONNECT(MOV_EGX__ECX_, "mov egx, [ecx]", &MetaEngine::mov_egx__ecx_);
	CONNECT(MOV_EGX__EDX_, "mov egx, [edx]", &MetaEngine::mov_egx__edx_);
	CONNECT(MOV_EGX__EFX_, "mov egx, [eex]", &MetaEngine::mov_egx__eex_);
	CONNECT(MOV_EGX__EFX_, "mov egx, [efx]", &MetaEngine::mov_egx__efx_);
	CONNECT(MOV_EGX__EGX_, "mov egx, [egx]", &MetaEngine::mov_egx__egx_);
	CONNECT(MOV_EGX__EAX_4_, "mov egx, [eax+4]", &MetaEngine::mov_egx__eax_4_);
	CONNECT(MOV_EGX__EBX_4_, "mov egx, [ebx+4]", &MetaEngine::mov_egx__ebx_4_);
	CONNECT(MOV_EGX__ECX_4_, "mov egx, [ecx+4]", &MetaEngine::mov_egx__ecx_4_);
	CONNECT(MOV_EGX__EDX_4_, "mov egx, [edx+4]", &MetaEngine::mov_egx__edx_4_);
	CONNECT(MOV_EGX__EFX_4_, "mov egx, [eex+4]", &MetaEngine::mov_egx__eex_4_);
	CONNECT(MOV_EGX__EFX_4_, "mov egx, [efx+4]", &MetaEngine::mov_egx__efx_4_);

	CONNECT(MOV_EAX_0, "mov eax, 0", &MetaEngine::mov_eax_0);
	CONNECT(MOV_EBX_0, "mov ebx, 0", &MetaEngine::mov_ebx_0);
	CONNECT(MOV_ECX_0, "mov ecx, 0", &MetaEngine::mov_ecx_0);
	CONNECT(MOV_EDX_0, "mov edx, 0", &MetaEngine::mov_edx_0);
	CONNECT(MOV_EEX_0, "mov eex, 0", &MetaEngine::mov_eex_0);
	CONNECT(MOV_EFX_0, "mov efx, 0", &MetaEngine::mov_efx_0);
	CONNECT(MOV_EGX_0, "mov egx, 0", &MetaEngine::mov_egx_0);
	

	CONNECT(XOR_EAX_EAX, "xor eax, eax", &MetaEngine::xor_eax_eax);
	CONNECT(XOR_EAX_EBX, "xor eax, ebx", &MetaEngine::xor_eax_ebx);
	CONNECT(XOR_EAX_ECX, "xor eax, ecx", &MetaEngine::xor_eax_ecx);
	CONNECT(XOR_EAX_EDX, "xor eax, edx", &MetaEngine::xor_eax_edx);
	CONNECT(XOR_EAX_EEX, "xor eax, eex", &MetaEngine::xor_eax_eex);
	CONNECT(XOR_EAX_EFX, "xor eax, efx", &MetaEngine::xor_eax_efx);
	CONNECT(XOR_EAX_EGX, "xor eax, egx", &MetaEngine::xor_eax_egx);

	CONNECT(XOR_EBX_EBX, "xor ebx, ebx", &MetaEngine::xor_ebx_ebx);
	CONNECT(XOR_EBX_EAX, "xor ebx, eax", &MetaEngine::xor_ebx_eax);
	CONNECT(XOR_EBX_ECX, "xor ebx, ecx", &MetaEngine::xor_ebx_ecx);
	CONNECT(XOR_EBX_EDX, "xor ebx, edx", &MetaEngine::xor_ebx_edx);
	CONNECT(XOR_EBX_EEX, "xor ebx, eex", &MetaEngine::xor_ebx_eex);
	CONNECT(XOR_EBX_EFX, "xor ebx, efx", &MetaEngine::xor_ebx_efx);
	CONNECT(XOR_EBX_EGX, "xor ebx, egx", &MetaEngine::xor_ebx_egx);

	CONNECT(XOR_ECX_ECX, "xor ecx, ecx", &MetaEngine::xor_ecx_ecx);
	CONNECT(XOR_ECX_EAX, "xor ecx, eax", &MetaEngine::xor_ecx_eax);
	CONNECT(XOR_ECX_EBX, "xor ecx, ebx", &MetaEngine::xor_ecx_ebx);
	CONNECT(XOR_ECX_EDX, "xor ecx, edx", &MetaEngine::xor_ecx_edx);
	CONNECT(XOR_ECX_EEX, "xor ecx, eex", &MetaEngine::xor_ecx_eex);
	CONNECT(XOR_ECX_EFX, "xor ecx, efx", &MetaEngine::xor_ecx_efx);
	CONNECT(XOR_ECX_EGX, "xor ecx, egx", &MetaEngine::xor_ecx_egx);
	
	CONNECT(XOR_EDX_EDX, "xor edx, edx", &MetaEngine::xor_edx_edx);
	CONNECT(XOR_EDX_EAX, "xor edx, eax", &MetaEngine::xor_edx_eax);
	CONNECT(XOR_EDX_EBX, "xor edx, ebx", &MetaEngine::xor_edx_ebx);
	CONNECT(XOR_EDX_ECX, "xor edx, ecx", &MetaEngine::xor_edx_ecx);
	CONNECT(XOR_EDX_EEX, "xor edx, eex", &MetaEngine::xor_edx_eex);
	CONNECT(XOR_EDX_EFX, "xor edx, efx", &MetaEngine::xor_edx_efx);
	CONNECT(XOR_EDX_EGX, "xor edx, egx", &MetaEngine::xor_edx_egx);

	CONNECT(XOR_EEX_EEX, "xor eex, eex", &MetaEngine::xor_eex_eex);
	CONNECT(XOR_EEX_EAX, "xor eex, eax", &MetaEngine::xor_eex_eax);
	CONNECT(XOR_EEX_EBX, "xor eex, ebx", &MetaEngine::xor_eex_ebx);
	CONNECT(XOR_EEX_ECX, "xor eex, ecx", &MetaEngine::xor_eex_ecx);
	CONNECT(XOR_EEX_EDX, "xor eex, edx", &MetaEngine::xor_eex_edx);
	CONNECT(XOR_EEX_EFX, "xor eex, efx", &MetaEngine::xor_eex_efx);
	CONNECT(XOR_EEX_EGX, "xor eex, egx", &MetaEngine::xor_eex_egx);

	CONNECT(XOR_EFX_EFX, "xor efx, efx", &MetaEngine::xor_efx_efx);
	CONNECT(XOR_EFX_EAX, "xor efx, eax", &MetaEngine::xor_efx_eax);
	CONNECT(XOR_EFX_EBX, "xor efx, ebx", &MetaEngine::xor_efx_ebx);
	CONNECT(XOR_EFX_ECX, "xor efx, ecx", &MetaEngine::xor_efx_ecx);
	CONNECT(XOR_EFX_EDX, "xor efx, edx", &MetaEngine::xor_efx_edx);
	CONNECT(XOR_EFX_EEX, "xor efx, eex", &MetaEngine::xor_efx_eex);
	CONNECT(XOR_EFX_EGX, "xor efx, egx", &MetaEngine::xor_efx_egx);

	CONNECT(XOR_EGX_EGX, "xor egx, egx", &MetaEngine::xor_ebx_ebx);
	CONNECT(XOR_EGX_EAX, "xor egx, eax", &MetaEngine::xor_ebx_eax);
	CONNECT(XOR_EGX_EBX, "xor egx, ebx", &MetaEngine::xor_ebx_ecx);
	CONNECT(XOR_EGX_ECX, "xor egx, ecx", &MetaEngine::xor_ebx_edx);
	CONNECT(XOR_EGX_EDX, "xor egx, edx", &MetaEngine::xor_ebx_eex);
	CONNECT(XOR_EGX_EEX, "xor egx, eex", &MetaEngine::xor_ebx_efx);
	CONNECT(XOR_EGX_EFX, "xor egx, efx", &MetaEngine::xor_ebx_egx);

	CONNECT(ADD_EAX_EAX, "add eax, eax", &MetaEngine::add_eax_eax);
	CONNECT(ADD_EAX_EBX, "add eax, ebx", &MetaEngine::add_eax_ebx);
	CONNECT(ADD_EAX_ECX, "add eax, ecx", &MetaEngine::add_eax_ecx);
	CONNECT(ADD_EAX_EDX, "add eax, edx", &MetaEngine::add_eax_edx);
	CONNECT(ADD_EAX_EEX, "add eax, eex", &MetaEngine::add_eax_eex);
	CONNECT(ADD_EAX_EFX, "add eax, efx", &MetaEngine::add_eax_efx);
	CONNECT(ADD_EAX_EGX, "add eax, egx", &MetaEngine::add_eax_egx);

	CONNECT(ADD_EBX_EBX, "add ebx, ebx", &MetaEngine::add_ebx_ebx);
	CONNECT(ADD_EBX_EAX, "add ebx, eax", &MetaEngine::add_ebx_eax);
	CONNECT(ADD_EBX_ECX, "add ebx, ecx", &MetaEngine::add_ebx_ecx);
	CONNECT(ADD_EBX_EDX, "add ebx, edx", &MetaEngine::add_ebx_edx);
	CONNECT(ADD_EBX_EEX, "add ebx, eex", &MetaEngine::add_ebx_eex);
	CONNECT(ADD_EBX_EFX, "add ebx, efx", &MetaEngine::add_ebx_efx);
	CONNECT(ADD_EBX_EGX, "add ebx, egx", &MetaEngine::add_ebx_egx);

	CONNECT(ADD_ECX_ECX, "add ecx, ecx", &MetaEngine::add_ecx_ecx);
	CONNECT(ADD_ECX_EAX, "add ecx, eax", &MetaEngine::add_ecx_eax);
	CONNECT(ADD_ECX_EBX, "add ecx, ebx", &MetaEngine::add_ecx_ebx);
	CONNECT(ADD_ECX_EDX, "add ecx, edx", &MetaEngine::add_ecx_edx);
	CONNECT(ADD_ECX_EEX, "add ecx, eex", &MetaEngine::add_ecx_eex);
	CONNECT(ADD_ECX_EFX, "add ecx, efx", &MetaEngine::add_ecx_efx);
	CONNECT(ADD_ECX_EGX, "add ecx, egx", &MetaEngine::add_ecx_egx);

	CONNECT(ADD_EDX_EAX, "add edx, edx", &MetaEngine::add_edx_edx);
	CONNECT(ADD_EDX_EBX, "add edx, eax", &MetaEngine::add_edx_eax);
	CONNECT(ADD_EDX_ECX, "add edx, ebx", &MetaEngine::add_edx_ebx);
	CONNECT(ADD_EDX_EDX, "add edx, ecx", &MetaEngine::add_edx_ecx);
	CONNECT(ADD_EDX_EEX, "add edx, eex", &MetaEngine::add_edx_eex);
	CONNECT(ADD_EDX_EFX, "add edx, efx", &MetaEngine::add_edx_efx);
	CONNECT(ADD_EDX_EGX, "add edx, egx", &MetaEngine::add_edx_egx);

	CONNECT(ADD_EEX_EEX, "add eex, eex", &MetaEngine::add_eex_eex);
	CONNECT(ADD_EEX_EAX, "add eex, eax", &MetaEngine::add_eex_eax);
	CONNECT(ADD_EEX_EBX, "add eex, ebx", &MetaEngine::add_eex_ebx);
	CONNECT(ADD_EEX_ECX, "add eex, ecx", &MetaEngine::add_eex_ecx);
	CONNECT(ADD_EEX_EDX, "add eex, edx", &MetaEngine::add_eex_edx);
	CONNECT(ADD_EEX_EFX, "add eex, efx", &MetaEngine::add_eex_efx);
	CONNECT(ADD_EEX_EGX, "add eex, egx", &MetaEngine::add_eex_egx);

	CONNECT(ADD_EFX_EFX, "add efx, efx", &MetaEngine::add_efx_efx);
	CONNECT(ADD_EFX_EAX, "add efx, eax", &MetaEngine::add_efx_eax);
	CONNECT(ADD_EFX_EBX, "add efx, ebx", &MetaEngine::add_efx_ebx);
	CONNECT(ADD_EFX_ECX, "add efx, ecx", &MetaEngine::add_efx_ecx);
	CONNECT(ADD_EFX_EDX, "add efx, edx", &MetaEngine::add_efx_edx);
	CONNECT(ADD_EFX_EEX, "add efx, eex", &MetaEngine::add_efx_eex);
	CONNECT(ADD_EFX_EGX, "add efx, egx", &MetaEngine::add_efx_egx);

	CONNECT(ADD_EGX_EGX, "add egx, egx", &MetaEngine::add_egx_egx);
	CONNECT(ADD_EGX_EAX, "add egx, eax", &MetaEngine::add_egx_eax);
	CONNECT(ADD_EGX_EBX, "add egx, ebx", &MetaEngine::add_egx_ebx);
	CONNECT(ADD_EGX_ECX, "add egx, ecx", &MetaEngine::add_egx_ecx);
	CONNECT(ADD_EGX_EDX, "add egx, edx", &MetaEngine::add_egx_edx);
	CONNECT(ADD_EGX_EEX, "add egx, eex", &MetaEngine::add_egx_eex);
	CONNECT(ADD_EGX_EFX, "add egx, efx", &MetaEngine::add_egx_efx);

	CONNECT(ADD_EAX_4, "add eax, 4", &MetaEngine::add_eax_4);
	CONNECT(ADD_EBX_4, "add ebx, 4", &MetaEngine::add_ebx_4);
	CONNECT(ADD_ECX_4, "add ecx, 4", &MetaEngine::add_ecx_4);
	CONNECT(ADD_EDX_4, "add edx, 4", &MetaEngine::add_edx_4);
	CONNECT(ADD_EEX_4, "add eex, 4", &MetaEngine::add_eex_4);
	CONNECT(ADD_EFX_4, "add efx, 4", &MetaEngine::add_efx_4);
	CONNECT(ADD_EGX_4, "add egx, 4", &MetaEngine::add_egx_4);

	CONNECT(SUB_EAX_EBX, "sub eax, ebx", &MetaEngine::sub_eax_ebx);
	CONNECT(SUB_EAX_ECX, "sub eax, ecx", &MetaEngine::sub_eax_ecx);
	CONNECT(SUB_EAX_EDX, "sub eax, edx", &MetaEngine::sub_eax_edx);
	CONNECT(SUB_EAX_EEX, "sub eax, eex", &MetaEngine::sub_eax_eex);
	CONNECT(SUB_EAX_EFX, "sub eax, efx", &MetaEngine::sub_eax_efx);
	CONNECT(SUB_EAX_EGX, "sub eax, egx", &MetaEngine::sub_eax_egx);

	CONNECT(SUB_EBX_EAX, "sub ebx, eax", &MetaEngine::sub_ebx_eax);
	CONNECT(SUB_EBX_ECX, "sub ebx, ecx", &MetaEngine::sub_ebx_ecx);
	CONNECT(SUB_EBX_EDX, "sub ebx, edx", &MetaEngine::sub_ebx_edx);
	CONNECT(SUB_EBX_EEX, "sub ebx, eex", &MetaEngine::sub_ebx_eex);
	CONNECT(SUB_EBX_EFX, "sub ebx, efx", &MetaEngine::sub_ebx_efx);
	CONNECT(SUB_EBX_EGX, "sub ebx, egx", &MetaEngine::sub_ebx_egx);

	CONNECT(SUB_ECX_EAX, "sub ecx, eax", &MetaEngine::sub_ecx_eax);
	CONNECT(SUB_ECX_EBX, "sub ecx, ebx", &MetaEngine::sub_ecx_ebx);
	CONNECT(SUB_ECX_EDX, "sub ecx, edx", &MetaEngine::sub_ecx_edx);
	CONNECT(SUB_ECX_EEX, "sub ecx, eex", &MetaEngine::sub_ecx_eex);
	CONNECT(SUB_ECX_EFX, "sub ecx, efx", &MetaEngine::sub_ecx_efx);
	CONNECT(SUB_ECX_EGX, "sub ecx, egx", &MetaEngine::sub_ecx_egx);

	CONNECT(SUB_EDX_EAX, "sub edx, eax", &MetaEngine::sub_edx_eax);
	CONNECT(SUB_EDX_EBX, "sub edx, ebx", &MetaEngine::sub_edx_ebx);
	CONNECT(SUB_EDX_ECX, "sub edx, ecx", &MetaEngine::sub_edx_ecx);
	CONNECT(SUB_EDX_EEX, "sub edx, eex", &MetaEngine::sub_edx_eex);
	CONNECT(SUB_EDX_EFX, "sub edx, efx", &MetaEngine::sub_edx_efx);
	CONNECT(SUB_EDX_EGX, "sub edx, egx", &MetaEngine::sub_edx_egx);

	CONNECT(SUB_EEX_EAX, "sub eex, eax", &MetaEngine::sub_eex_eax);
	CONNECT(SUB_EEX_EBX, "sub eex, ebx", &MetaEngine::sub_eex_ebx);
	CONNECT(SUB_EEX_ECX, "sub eex, ecx", &MetaEngine::sub_eex_ecx);
	CONNECT(SUB_EEX_EDX, "sub eex, edx", &MetaEngine::sub_eex_edx);
	CONNECT(SUB_EEX_EFX, "sub eex, efx", &MetaEngine::sub_eex_efx);
	CONNECT(SUB_EEX_EGX, "sub eex, egx", &MetaEngine::sub_eex_egx);

	CONNECT(SUB_EFX_EAX, "sub efx, eax", &MetaEngine::sub_efx_eax);
	CONNECT(SUB_EFX_EBX, "sub efx, ebx", &MetaEngine::sub_efx_ebx);
	CONNECT(SUB_EFX_ECX, "sub efx, evx", &MetaEngine::sub_efx_ecx);
	CONNECT(SUB_EFX_EDX, "sub efx, edx", &MetaEngine::sub_efx_edx);
	CONNECT(SUB_EFX_EEX, "sub efx, eex", &MetaEngine::sub_efx_eex);
	CONNECT(SUB_EFX_EGX, "sub efx, egx", &MetaEngine::sub_efx_egx);

	CONNECT(SUB_EGX_EAX, "sub egx, eax", &MetaEngine::sub_egx_eax);
	CONNECT(SUB_EGX_EBX, "sub egx, ebx", &MetaEngine::sub_egx_ebx);
	CONNECT(SUB_EGX_ECX, "sub egx, ecx", &MetaEngine::sub_egx_ecx);
	CONNECT(SUB_EGX_EDX, "sub egx, edx", &MetaEngine::sub_egx_edx);
	CONNECT(SUB_EGX_EEX, "sub egx, eex", &MetaEngine::sub_egx_eex);
	CONNECT(SUB_EGX_EFX, "sub egx, efx", &MetaEngine::sub_egx_efx);

	CONNECT(SUB_EAX_4, "sub eax, 4", &MetaEngine::sub_eax_4);
	CONNECT(SUB_EBX_4, "sub ebx, 4", &MetaEngine::sub_ebx_4);
	CONNECT(SUB_ECX_4, "sub ecx, 4", &MetaEngine::sub_ecx_4);
	CONNECT(SUB_EDX_4, "sub edx, 4", &MetaEngine::sub_edx_4);
	CONNECT(SUB_EEX_4, "sub eex, 4", &MetaEngine::sub_eex_4);
	CONNECT(SUB_EFX_4, "sub efx, 4", &MetaEngine::sub_efx_4);
	CONNECT(SUB_EGX_4, "sub egx, 4", &MetaEngine::sub_egx_4);

}

MetaEngine::~MetaEngine(void)
{
}

void MetaEngine::FUNC(int num, function_pointer func) {
	int addr;	
	__asm {
		mov ebx, func;
		mov addr, ebx;
	}
	MetaEngine::FUNCTIONS->at(num) = addr;	

}

void MetaEngine::push_eax() {
	int count = -1;
	for(int i = 0; i < this->bastard->Engine->stack->size(); ++i) {
		++count;
		if(this->bastard->Engine->stack->at(i) == NULL) {
			break;
		
		}
	
	}
	this->bastard->Engine->stack->at(count) = this->bastard->Engine->eax;

}

void MetaEngine::push_ebx() {
	int count = -1;
	for(int i = 0; i < this->bastard->Engine->stack->size(); ++i) {
		++count;
		if(this->bastard->Engine->stack->at(i) == NULL) {
			break;
		
		}
	
	}
	this->bastard->Engine->stack->at(count) = this->bastard->Engine->ebx;
	

}

void MetaEngine::push_ecx() {
	int count = -1;
	for(int i = 0; i < this->bastard->Engine->stack->size(); ++i) {
		++count;
		if(this->bastard->Engine->stack->at(i) == NULL) {
			break;
		
		}
	
	}
	this->bastard->Engine->stack->at(count) = this->bastard->Engine->ecx;
	

}

void MetaEngine::push_edx() {
	int count = -1;
	for(int i = 0; i < this->bastard->Engine->stack->size(); ++i) {
		++count;
		if(this->bastard->Engine->stack->at(i) == NULL) {
			break;
		
		}
	
	}
	this->bastard->Engine->stack->at(count) = this->bastard->Engine->edx;
	

}

void MetaEngine::push_eex() {
	int count = -1;
	for(int i = 0; i < this->bastard->Engine->stack->size(); ++i) {
		++count;
		if(this->bastard->Engine->stack->at(i) == NULL) {
			break;
		
		}
	
	}
	this->bastard->Engine->stack->at(count) = this->bastard->Engine->eex;
	
}

void MetaEngine::push_efx() {
	int count = -1;
	for(int i = 0; i < this->bastard->Engine->stack->size(); ++i) {
		++count;
		if(this->bastard->Engine->stack->at(i) == NULL) {
			break;
		
		}
	
	}
	this->bastard->Engine->stack->at(count) = this->bastard->Engine->efx;
	
}

void MetaEngine::push_egx() {
	int count = -1;
	for(int i = 0; i < this->bastard->Engine->stack->size(); ++i) {
		++count;
		if(this->bastard->Engine->stack->at(i) == NULL) {
			break;
		
		}
	
	}
	this->bastard->Engine->stack->at(count) = this->bastard->Engine->egx;
	
}


void MetaEngine::pop_eax() {
	int count = this->bastard->Engine->stack->size();
	for(int i = this->bastard->Engine->stack->size(); i >= 0; --i) {
		--count;
		if(this->bastard->Engine->stack->at(i) == NULL) {
			break;
		
		}
	
	}
	 this->bastard->Engine->eax = this->bastard->Engine->stack->at(count);
	
}

void MetaEngine::pop_ebx() {
	int count = this->bastard->Engine->stack->size();
	for(int i = this->bastard->Engine->stack->size(); i >= 0; --i) {
		--count;
		if(this->bastard->Engine->stack->at(i) == NULL) {
			break;
		
		}
	
	}
	 this->bastard->Engine->ebx = this->bastard->Engine->stack->at(count);
	
}

void MetaEngine::pop_ecx() {
	int count = this->bastard->Engine->stack->size();
	for(int i = this->bastard->Engine->stack->size(); i >= 0; --i) {
		--count;
		if(this->bastard->Engine->stack->at(i) == NULL) {
			break;
		
		}
	
	}
	 this->bastard->Engine->ecx = this->bastard->Engine->stack->at(count);
	
}

void MetaEngine::pop_edx() {
	int count = this->bastard->Engine->stack->size();
	for(int i = this->bastard->Engine->stack->size(); i >= 0; --i) {
		--count;
		if(this->bastard->Engine->stack->at(i) == NULL) {
			break;
		
		}
	
	}
	 this->bastard->Engine->edx = this->bastard->Engine->stack->at(count);
	
}

void MetaEngine::pop_eex() {
		int count = this->bastard->Engine->stack->size();
	for(int i = this->bastard->Engine->stack->size(); i >= 0; --i) {
		--count;
		if(this->bastard->Engine->stack->at(i) == NULL) {
			break;
		
		}
	
	}
	 this->bastard->Engine->eex = this->bastard->Engine->stack->at(count);
	
}

void MetaEngine::pop_efx(){
		int count = this->bastard->Engine->stack->size();
	for(int i = this->bastard->Engine->stack->size(); i >= 0; --i) {
		--count;
		if(this->bastard->Engine->stack->at(i) == NULL) {
			break;
		
		}
	
	}
	 this->bastard->Engine->efx = this->bastard->Engine->stack->at(count);
	
}

void MetaEngine::pop_egx(){
	int count = this->bastard->Engine->stack->size();
	for(int i = this->bastard->Engine->stack->size(); i >= 0; --i) {
		--count;
		if(this->bastard->Engine->stack->at(i) == NULL) {
			break;
		
		}
	
	}
	 this->bastard->Engine->egx = this->bastard->Engine->stack->at(count);
	
}


void MetaEngine::call_eax() {
	CALL(this->bastard->Engine->eax);
	
}

void MetaEngine::call_ebx() {
	CALL(this->bastard->Engine->ebx);
	
}

void MetaEngine::call_ecx() {
	CALL(this->bastard->Engine->ecx);
	
}

void MetaEngine::call_edx() {
	CALL(this->bastard->Engine->edx);
	
}

void MetaEngine::call_eex() {
	CALL(this->bastard->Engine->eex);
	
}

void MetaEngine::call_efx() {
	CALL(this->bastard->Engine->efx);
	
}

void MetaEngine::call_egx() {
	CALL(this->bastard->Engine->egx);
	
}


void MetaEngine::mov_eax_eax() {
	this->bastard->Engine->eax = this->bastard->Engine->eax;
}

void MetaEngine::mov_eax_ebx(){
	this->bastard->Engine->eax = this->bastard->Engine->ebx;
}

void MetaEngine::mov_eax_ecx(){
	this->bastard->Engine->eax = this->bastard->Engine->ecx;
}

void MetaEngine::mov_eax_edx(){
	this->bastard->Engine->eax = this->bastard->Engine->edx;
}

void MetaEngine::mov_eax_eex() {
	this->bastard->Engine->eax = this->bastard->Engine->eex;
}

void MetaEngine::mov_eax_efx() {
	this->bastard->Engine->eax = this->bastard->Engine->efx;
}

void MetaEngine::mov_eax_egx() {
	this->bastard->Engine->eax = this->bastard->Engine->egx;
}

void MetaEngine::mov_eax__eax_() {
	OFFSET(&this->bastard->Engine->eax, &this->bastard->Engine->eax);

}

void MetaEngine::mov_eax__ebx_() {
	OFFSET(&this->bastard->Engine->eax, &this->bastard->Engine->ebx);

}

void MetaEngine::mov_eax__ecx_() {
	OFFSET(&this->bastard->Engine->eax, &this->bastard->Engine->ecx);

}

void MetaEngine::mov_eax__edx_() {
	OFFSET(&this->bastard->Engine->eax, &this->bastard->Engine->edx);

}

void MetaEngine::mov_eax__eex_() {
	OFFSET(&this->bastard->Engine->eax, &this->bastard->Engine->eex);


}

void MetaEngine::mov_eax__efx_() {
	OFFSET(&this->bastard->Engine->eax, &this->bastard->Engine->efx);

}

void MetaEngine::mov_eax__egx_() {
	OFFSET(&this->bastard->Engine->eax, &this->bastard->Engine->egx);

}

void MetaEngine::mov_eax__eax_4_() {
	MOV_4_(&this->bastard->Engine->eax, &this->bastard->Engine->eax);
}

void MetaEngine::mov_eax__ebx_4_() {
	MOV_4_(&this->bastard->Engine->eax, &this->bastard->Engine->ebx);

}

void MetaEngine::mov_eax__ecx_4_() {
	MOV_4_(&this->bastard->Engine->eax, &this->bastard->Engine->ecx);

}

void MetaEngine::mov_eax__edx_4_() {
	MOV_4_(&this->bastard->Engine->eax, &this->bastard->Engine->edx);

}

void MetaEngine::mov_eax__eex_4_() {
	MOV_4_(&this->bastard->Engine->eax, &this->bastard->Engine->eex);

}

void MetaEngine::mov_eax__efx_4_() {
	MOV_4_(&this->bastard->Engine->eax, &this->bastard->Engine->efx);

}

void MetaEngine::mov_eax__egx_4_() {
	MOV_4_(&this->bastard->Engine->eax, &this->bastard->Engine->egx);

}


void MetaEngine::mov_ebx_ebx(){
	this->bastard->Engine->ebx = this->bastard->Engine->ebx;
}

void MetaEngine::mov_ebx_eax(){
	this->bastard->Engine->ebx = this->bastard->Engine->eax;
}

void MetaEngine::mov_ebx_ecx(){
	this->bastard->Engine->ebx = this->bastard->Engine->ecx;
}

void MetaEngine::mov_ebx_edx(){
	this->bastard->Engine->ebx = this->bastard->Engine->edx;
}

void MetaEngine::mov_ebx_eex() {
	this->bastard->Engine->ebx = this->bastard->Engine->eex;
}

void MetaEngine::mov_ebx_efx() {
	this->bastard->Engine->ebx = this->bastard->Engine->efx;
}

void MetaEngine::mov_ebx_egx() {
	this->bastard->Engine->ebx = this->bastard->Engine->egx;
}

void MetaEngine::mov_ebx__ebx_() {
	OFFSET(&this->bastard->Engine->ebx, &this->bastard->Engine->ebx);

}

void MetaEngine::mov_ebx__eax_() {
	OFFSET(&this->bastard->Engine->ebx, &this->bastard->Engine->eax);

}

void MetaEngine::mov_ebx__ecx_() {
	OFFSET(&this->bastard->Engine->ebx, &this->bastard->Engine->ecx);

}

void MetaEngine::mov_ebx__edx_() {
	OFFSET(&this->bastard->Engine->ebx, &this->bastard->Engine->edx);

}

void MetaEngine::mov_ebx__eex_() {
	OFFSET(&this->bastard->Engine->ebx, &this->bastard->Engine->eex);

}

void MetaEngine::mov_ebx__efx_() {
	OFFSET(&this->bastard->Engine->ebx, &this->bastard->Engine->efx);

}

void MetaEngine::mov_ebx__egx_() {
	OFFSET(&this->bastard->Engine->ebx, &this->bastard->Engine->egx);

}

void MetaEngine::mov_ebx__ebx_4_() {
	MOV_4_(&this->bastard->Engine->ebx, &this->bastard->Engine->ebx);

}

void MetaEngine::mov_ebx__eax_4_() {
	MOV_4_(&this->bastard->Engine->ebx, &this->bastard->Engine->eax);

}

void MetaEngine::mov_ebx__ecx_4_() {
	MOV_4_(&this->bastard->Engine->ebx, &this->bastard->Engine->ecx);
	
}

void MetaEngine::mov_ebx__edx_4_() {
	MOV_4_(&this->bastard->Engine->ebx, &this->bastard->Engine->edx);

}

void MetaEngine::mov_ebx__eex_4_() {
	MOV_4_(&this->bastard->Engine->ebx, &this->bastard->Engine->eex);

}

void MetaEngine::mov_ebx__efx_4_() {
	MOV_4_(&this->bastard->Engine->ebx, &this->bastard->Engine->efx);

}

void MetaEngine::mov_ebx__egx_4_() {
	MOV_4_(&this->bastard->Engine->ebx, &this->bastard->Engine->egx);

}


void MetaEngine::mov_ecx_ecx(){
	this->bastard->Engine->ecx = this->bastard->Engine->ecx;

}

void MetaEngine::mov_ecx_eax(){
	this->bastard->Engine->ecx = this->bastard->Engine->eax;

}

void MetaEngine::mov_ecx_ebx(){
	this->bastard->Engine->ecx = this->bastard->Engine->ebx;

}

void MetaEngine::mov_ecx_edx(){
	this->bastard->Engine->ecx = this->bastard->Engine->edx;

}

void MetaEngine::mov_ecx_eex() {
	this->bastard->Engine->ecx = this->bastard->Engine->eex;
}

void MetaEngine::mov_ecx_efx() {
	this->bastard->Engine->ecx = this->bastard->Engine->efx;
}

void MetaEngine::mov_ecx_egx() {
	this->bastard->Engine->ecx = this->bastard->Engine->egx;
}

void MetaEngine::mov_ecx__ecx_() {
	OFFSET(&this->bastard->Engine->ecx, &this->bastard->Engine->ecx);

}

void MetaEngine::mov_ecx__eax_() {
	OFFSET(&this->bastard->Engine->ecx, &this->bastard->Engine->eax);

}

void MetaEngine::mov_ecx__ebx_() {
	OFFSET(&this->bastard->Engine->ecx, &this->bastard->Engine->ebx);

}

void MetaEngine::mov_ecx__edx_() {
	OFFSET(&this->bastard->Engine->ecx, &this->bastard->Engine->edx);

}

void MetaEngine::mov_ecx__eex_() {
	OFFSET(&this->bastard->Engine->ecx, &this->bastard->Engine->eex);

}

void MetaEngine::mov_ecx__efx_() {
	OFFSET(&this->bastard->Engine->ecx, &this->bastard->Engine->efx);

}

void MetaEngine::mov_ecx__egx_() {
	OFFSET(&this->bastard->Engine->ecx, &this->bastard->Engine->egx);

}

void MetaEngine::mov_ecx__ecx_4_() {
	MOV_4_(&this->bastard->Engine->ecx, &this->bastard->Engine->ecx);

}

void MetaEngine::mov_ecx__eax_4_() {
	MOV_4_(&this->bastard->Engine->ecx, &this->bastard->Engine->eax);

}

void MetaEngine::mov_ecx__ebx_4_() {
	MOV_4_(&this->bastard->Engine->ecx, &this->bastard->Engine->ebx);

}

void MetaEngine::mov_ecx__edx_4_() {
	MOV_4_(&this->bastard->Engine->ecx, &this->bastard->Engine->edx);

}

void MetaEngine::mov_ecx__eex_4_() {
	MOV_4_(&this->bastard->Engine->ecx, &this->bastard->Engine->eex);

}

void MetaEngine::mov_ecx__efx_4_() {
	MOV_4_(&this->bastard->Engine->ecx, &this->bastard->Engine->efx);

}

void MetaEngine::mov_ecx__egx_4_() {
	MOV_4_(&this->bastard->Engine->ecx, &this->bastard->Engine->egx);

}


void MetaEngine::mov_edx_edx() {
	this->bastard->Engine->edx = this->bastard->Engine->edx;

}

void MetaEngine::mov_edx_eax() {
	this->bastard->Engine->edx = this->bastard->Engine->eax;

}

void MetaEngine::mov_edx_ebx() {
	this->bastard->Engine->edx = this->bastard->Engine->ebx;

}

void MetaEngine::mov_edx_ecx() {
	this->bastard->Engine->edx = this->bastard->Engine->ecx;

}

void MetaEngine::mov_edx_eex() {
	this->bastard->Engine->edx = this->bastard->Engine->eex;
}

void MetaEngine::mov_edx_efx() {
	this->bastard->Engine->edx = this->bastard->Engine->efx;
}

void MetaEngine::mov_edx_egx() {
	this->bastard->Engine->edx = this->bastard->Engine->egx;
}

void MetaEngine::mov_edx__edx_() {
	OFFSET(&this->bastard->Engine->edx, &this->bastard->Engine->edx);

}

void MetaEngine::mov_edx__eax_() {
	OFFSET(&this->bastard->Engine->edx, &this->bastard->Engine->eax);

}

void MetaEngine::mov_edx__ebx_() {
	OFFSET(&this->bastard->Engine->edx, &this->bastard->Engine->ebx);

}

void MetaEngine::mov_edx__ecx_() {
	OFFSET(&this->bastard->Engine->edx, &this->bastard->Engine->ecx);

}

void MetaEngine::mov_edx__eex_() {
	OFFSET(&this->bastard->Engine->edx, &this->bastard->Engine->eex);

}

void MetaEngine::mov_edx__efx_() {
	OFFSET(&this->bastard->Engine->edx, &this->bastard->Engine->efx);

}

void MetaEngine::mov_edx__egx_() {
	OFFSET(&this->bastard->Engine->edx, &this->bastard->Engine->egx);

}

void MetaEngine::mov_edx__edx_4_() {
	MOV_4_(&this->bastard->Engine->edx, &this->bastard->Engine->edx);

}

void MetaEngine::mov_edx__eax_4_() {
	MOV_4_(&this->bastard->Engine->edx, &this->bastard->Engine->eax);

}

void MetaEngine::mov_edx__ebx_4_() {
	MOV_4_(&this->bastard->Engine->edx, &this->bastard->Engine->ebx);

}

void MetaEngine::mov_edx__ecx_4_() {
	MOV_4_(&this->bastard->Engine->edx, &this->bastard->Engine->ecx);

}

void MetaEngine::mov_edx__eex_4_() {
	MOV_4_(&this->bastard->Engine->edx, &this->bastard->Engine->eex);

}

void MetaEngine::mov_edx__efx_4_() {
	MOV_4_(&this->bastard->Engine->edx, &this->bastard->Engine->efx);

}

void MetaEngine::mov_edx__egx_4_() {
	MOV_4_(&this->bastard->Engine->edx, &this->bastard->Engine->egx);

}


void MetaEngine::mov_eex_eex() {
	this->bastard->Engine->eex = this->bastard->Engine->eex;
}

void MetaEngine::mov_eex_eax() {
	this->bastard->Engine->eex = this->bastard->Engine->eax;
}

void MetaEngine::mov_eex_ebx() {
	this->bastard->Engine->eex = this->bastard->Engine->ebx;
}

void MetaEngine::mov_eex_ecx() {
	this->bastard->Engine->eex = this->bastard->Engine->ecx;
}

void MetaEngine::mov_eex_edx() {
	this->bastard->Engine->eex = this->bastard->Engine->edx;
}

void MetaEngine::mov_eex_efx() {
	this->bastard->Engine->eex = this->bastard->Engine->efx;
}

void MetaEngine::mov_eex_egx() {
	this->bastard->Engine->eex = this->bastard->Engine->egx;
}

void MetaEngine::mov_eex__eex_() {
	OFFSET(&this->bastard->Engine->eex, &this->bastard->Engine->eex);

}

void MetaEngine::mov_eex__eax_() {
	OFFSET(&this->bastard->Engine->eex, &this->bastard->Engine->eax);

}

void MetaEngine::mov_eex__ebx_() {
	OFFSET(&this->bastard->Engine->eex, &this->bastard->Engine->ebx);

}

void MetaEngine::mov_eex__ecx_() {
	OFFSET(&this->bastard->Engine->eex, &this->bastard->Engine->ecx);

}

void MetaEngine::mov_eex__edx_() {
	OFFSET(&this->bastard->Engine->eex, &this->bastard->Engine->edx);

}

void MetaEngine::mov_eex__efx_() {
	OFFSET(&this->bastard->Engine->eex, &this->bastard->Engine->efx);

}

void MetaEngine::mov_eex__egx_() {
	OFFSET(&this->bastard->Engine->eex, &this->bastard->Engine->egx);

}

void MetaEngine::mov_eex__eex_4_() {
	MOV_4_(&this->bastard->Engine->eex, &this->bastard->Engine->eex);

}

void MetaEngine::mov_eex__eax_4_() {
	MOV_4_(&this->bastard->Engine->eex, &this->bastard->Engine->eax);

}

void MetaEngine::mov_eex__ebx_4_() {
	MOV_4_(&this->bastard->Engine->eex, &this->bastard->Engine->ebx);

}

void MetaEngine::mov_eex__ecx_4_() {
	MOV_4_(&this->bastard->Engine->eex, &this->bastard->Engine->ecx);

}

void MetaEngine::mov_eex__edx_4_() {
	MOV_4_(&this->bastard->Engine->eex, &this->bastard->Engine->edx);

}

void MetaEngine::mov_eex__efx_4_() {
	MOV_4_(&this->bastard->Engine->eex, &this->bastard->Engine->efx);

}

void MetaEngine::mov_eex__egx_4_() {
	MOV_4_(&this->bastard->Engine->eex, &this->bastard->Engine->egx);

}


void MetaEngine::mov_efx_efx() {
	this->bastard->Engine->efx = this->bastard->Engine->efx;
}

void MetaEngine::mov_efx_eax() {
	this->bastard->Engine->efx = this->bastard->Engine->eax;
}

void MetaEngine::mov_efx_ebx() {
	this->bastard->Engine->efx = this->bastard->Engine->ebx;
}

void MetaEngine::mov_efx_ecx() {
	this->bastard->Engine->efx = this->bastard->Engine->ecx;
}

void MetaEngine::mov_efx_edx() {
	this->bastard->Engine->efx = this->bastard->Engine->edx;
}

void MetaEngine::mov_efx_eex() {
	this->bastard->Engine->efx = this->bastard->Engine->eex;
}

void MetaEngine::mov_efx_egx() {
	this->bastard->Engine->efx = this->bastard->Engine->egx;
}

void MetaEngine::mov_efx__efx_() {
	OFFSET(&this->bastard->Engine->efx, &this->bastard->Engine->efx);

}

void MetaEngine::mov_efx__eax_() {
	OFFSET(&this->bastard->Engine->efx, &this->bastard->Engine->eax);

}

void MetaEngine::mov_efx__ebx_() {
	OFFSET(&this->bastard->Engine->efx, &this->bastard->Engine->ebx);

}

void MetaEngine::mov_efx__ecx_() {
	OFFSET(&this->bastard->Engine->efx, &this->bastard->Engine->ecx);

}

void MetaEngine::mov_efx__edx_() {
	OFFSET(&this->bastard->Engine->efx, &this->bastard->Engine->edx);

}

void MetaEngine::mov_efx__eex_() {
	OFFSET(&this->bastard->Engine->efx, &this->bastard->Engine->eex);

}

void MetaEngine::mov_efx__egx_() {
	OFFSET(&this->bastard->Engine->efx, &this->bastard->Engine->egx);

}

void MetaEngine::mov_efx__efx_4_() {
	MOV_4_(&this->bastard->Engine->efx, &this->bastard->Engine->efx);

}

void MetaEngine::mov_efx__eax_4_() {
	MOV_4_(&this->bastard->Engine->efx, &this->bastard->Engine->eax);

}

void MetaEngine::mov_efx__ebx_4_() {
	MOV_4_(&this->bastard->Engine->efx, &this->bastard->Engine->ebx);

}

void MetaEngine::mov_efx__ecx_4_() {
	MOV_4_(&this->bastard->Engine->efx, &this->bastard->Engine->ecx);

}

void MetaEngine::mov_efx__edx_4_() {
	MOV_4_(&this->bastard->Engine->efx, &this->bastard->Engine->edx);

}

void MetaEngine::mov_efx__eex_4_() {
	MOV_4_(&this->bastard->Engine->efx, &this->bastard->Engine->eex);

}

void MetaEngine::mov_efx__egx_4_() {
	MOV_4_(&this->bastard->Engine->efx, &this->bastard->Engine->egx);

}


void MetaEngine::mov_egx_egx() {
	this->bastard->Engine->egx = this->bastard->Engine->egx;
}

void MetaEngine::mov_egx_eax() {
	this->bastard->Engine->egx = this->bastard->Engine->eax;
}

void MetaEngine::mov_egx_ebx() {
	this->bastard->Engine->egx = this->bastard->Engine->ebx;
}

void MetaEngine::mov_egx_ecx() {
	this->bastard->Engine->egx = this->bastard->Engine->ecx;
}

void MetaEngine::mov_egx_edx() {
	this->bastard->Engine->egx = this->bastard->Engine->edx;
}

void MetaEngine::mov_egx_eex() {
	this->bastard->Engine->egx = this->bastard->Engine->eex;
}

void MetaEngine::mov_egx_efx() {
	this->bastard->Engine->egx = this->bastard->Engine->efx;
}

void MetaEngine::mov_egx__egx_() {
	OFFSET(&this->bastard->Engine->egx, &this->bastard->Engine->egx);

}

void MetaEngine::mov_egx__eax_() {
	OFFSET(&this->bastard->Engine->egx, &this->bastard->Engine->eax);

}

void MetaEngine::mov_egx__ebx_() {
	OFFSET(&this->bastard->Engine->egx, &this->bastard->Engine->ebx);

}

void MetaEngine::mov_egx__ecx_() {
	OFFSET(&this->bastard->Engine->egx, &this->bastard->Engine->ecx);

}

void MetaEngine::mov_egx__edx_() {
	OFFSET(&this->bastard->Engine->egx, &this->bastard->Engine->edx);

}

void MetaEngine::mov_egx__eex_() {
	OFFSET(&this->bastard->Engine->egx, &this->bastard->Engine->eex);

}

void MetaEngine::mov_egx__efx_() {
	OFFSET(&this->bastard->Engine->egx, &this->bastard->Engine->efx);

}

void MetaEngine::mov_egx__egx_4_() {
	MOV_4_(&this->bastard->Engine->egx, &this->bastard->Engine->egx);

}

void MetaEngine::mov_egx__eax_4_() {
	MOV_4_(&this->bastard->Engine->egx, &this->bastard->Engine->eax);

}

void MetaEngine::mov_egx__ebx_4_() {
	MOV_4_(&this->bastard->Engine->egx, &this->bastard->Engine->ebx);

}

void MetaEngine::mov_egx__ecx_4_() {
	MOV_4_(&this->bastard->Engine->egx, &this->bastard->Engine->ecx);

}

void MetaEngine::mov_egx__edx_4_() {
	MOV_4_(&this->bastard->Engine->egx, &this->bastard->Engine->edx);

}

void MetaEngine::mov_egx__eex_4_() {
	MOV_4_(&this->bastard->Engine->egx, &this->bastard->Engine->eex);

}

void MetaEngine::mov_egx__efx_4_() {
	MOV_4_(&this->bastard->Engine->egx, &this->bastard->Engine->efx);

}


void MetaEngine::xor_eax_eax() {
	this->bastard->Engine->eax ^= this->bastard->Engine->eax;
}

void MetaEngine::xor_eax_ebx() {
	this->bastard->Engine->eax ^= this->bastard->Engine->ebx;
}

void MetaEngine::xor_eax_ecx() {
	this->bastard->Engine->eax ^= this->bastard->Engine->ecx;
}

void MetaEngine::xor_eax_edx() {
	this->bastard->Engine->eax ^= this->bastard->Engine->edx;
}

void MetaEngine::xor_eax_eex() {
	this->bastard->Engine->eax ^= this->bastard->Engine->eex;
}

void MetaEngine::xor_eax_efx() {
	this->bastard->Engine->eax ^= this->bastard->Engine->efx;
}

void MetaEngine::xor_eax_egx() {
	this->bastard->Engine->eax ^= this->bastard->Engine->egx;
}


void MetaEngine::xor_ebx_ebx() {
	this->bastard->Engine->ebx ^= this->bastard->Engine->ebx;
}

void MetaEngine::xor_ebx_eax() {
	this->bastard->Engine->ebx ^= this->bastard->Engine->eax;
}

void MetaEngine::xor_ebx_ecx() {
	this->bastard->Engine->ebx ^= this->bastard->Engine->ecx;
}

void MetaEngine::xor_ebx_edx() {
	this->bastard->Engine->ebx ^= this->bastard->Engine->edx;
}

void MetaEngine::xor_ebx_eex() {
	this->bastard->Engine->ebx ^= this->bastard->Engine->eex;
}

void MetaEngine::xor_ebx_efx() {
	this->bastard->Engine->ebx ^= this->bastard->Engine->efx;
}

void MetaEngine::xor_ebx_egx() {
	this->bastard->Engine->ebx ^= this->bastard->Engine->egx;
}


void MetaEngine::xor_ecx_ecx() {
	this->bastard->Engine->ecx ^= this->bastard->Engine->ecx;
}

void MetaEngine::xor_ecx_eax() {
	this->bastard->Engine->ecx ^= this->bastard->Engine->eax;
}

void MetaEngine::xor_ecx_ebx() {
	this->bastard->Engine->ecx ^= this->bastard->Engine->ebx;
}

void MetaEngine::xor_ecx_edx() {
	this->bastard->Engine->ecx ^= this->bastard->Engine->edx;
}

void MetaEngine::xor_ecx_eex() {
	this->bastard->Engine->ecx ^= this->bastard->Engine->eex;
}

void MetaEngine::xor_ecx_efx() {
	this->bastard->Engine->ecx ^= this->bastard->Engine->efx;
}

void MetaEngine::xor_ecx_egx() {
	this->bastard->Engine->ecx ^= this->bastard->Engine->egx;
}


void MetaEngine::xor_edx_edx() {
	this->bastard->Engine->edx ^= this->bastard->Engine->edx;
}

void MetaEngine::xor_edx_eax() {
	this->bastard->Engine->edx ^= this->bastard->Engine->eax;
}

void MetaEngine::xor_edx_ebx() {
	this->bastard->Engine->edx ^= this->bastard->Engine->ebx;
}

void MetaEngine::xor_edx_ecx() {
	this->bastard->Engine->edx ^= this->bastard->Engine->ecx;
}

void MetaEngine::xor_edx_eex() {
	this->bastard->Engine->edx ^= this->bastard->Engine->eex;
}

void MetaEngine::xor_edx_efx() {
	this->bastard->Engine->edx ^= this->bastard->Engine->efx;
}

void MetaEngine::xor_edx_egx() {
	this->bastard->Engine->edx ^= this->bastard->Engine->egx;
}


void MetaEngine::xor_eex_eex() {
	this->bastard->Engine->eex ^= this->bastard->Engine->eex;
}

void MetaEngine::xor_eex_eax() {
	this->bastard->Engine->eex ^= this->bastard->Engine->eax;
}

void MetaEngine::xor_eex_ebx() {
	this->bastard->Engine->eex ^= this->bastard->Engine->ebx;
}

void MetaEngine::xor_eex_ecx() {
	this->bastard->Engine->eex ^= this->bastard->Engine->ecx;
}

void MetaEngine::xor_eex_edx() {
	this->bastard->Engine->eex ^= this->bastard->Engine->edx;
}

void MetaEngine::xor_eex_efx() {
	this->bastard->Engine->eex ^= this->bastard->Engine->efx;
}

void MetaEngine::xor_eex_egx() {
	this->bastard->Engine->eex ^= this->bastard->Engine->egx;
}


void MetaEngine::xor_efx_efx() {
	this->bastard->Engine->efx ^= this->bastard->Engine->efx;
}

void MetaEngine::xor_efx_eax() {
	this->bastard->Engine->efx ^= this->bastard->Engine->eax;
}

void MetaEngine::xor_efx_ebx() {
	this->bastard->Engine->efx ^= this->bastard->Engine->ebx;
}

void MetaEngine::xor_efx_ecx() {
	this->bastard->Engine->efx ^= this->bastard->Engine->ecx;
}

void MetaEngine::xor_efx_edx() {
	this->bastard->Engine->efx ^= this->bastard->Engine->edx;
}

void MetaEngine::xor_efx_eex() {
	this->bastard->Engine->efx ^= this->bastard->Engine->eex;
}

void MetaEngine::xor_efx_egx() {
	this->bastard->Engine->efx ^= this->bastard->Engine->egx;
}


void MetaEngine::xor_egx_egx() {
	this->bastard->Engine->egx ^= this->bastard->Engine->egx;
}

void MetaEngine::xor_egx_eax() {
	this->bastard->Engine->egx ^= this->bastard->Engine->eax;
}

void MetaEngine::xor_egx_ebx() {
	this->bastard->Engine->egx ^= this->bastard->Engine->ebx;
}

void MetaEngine::xor_egx_ecx() {
	this->bastard->Engine->egx ^= this->bastard->Engine->ecx;
}

void MetaEngine::xor_egx_edx() {
	this->bastard->Engine->egx ^= this->bastard->Engine->edx;
}

void MetaEngine::xor_egx_eex() {
	this->bastard->Engine->egx ^= this->bastard->Engine->eex;
}

void MetaEngine::xor_egx_efx() {
	this->bastard->Engine->egx ^= this->bastard->Engine->efx;
}


void MetaEngine::add_eax_eax() {
	this->bastard->Engine->eax += this->bastard->Engine->eax;
}

void MetaEngine::add_eax_ebx() {
	this->bastard->Engine->eax += this->bastard->Engine->ebx;
}

void MetaEngine::add_eax_ecx() {
	this->bastard->Engine->eax += this->bastard->Engine->ecx;
}

void MetaEngine::add_eax_edx() {
	this->bastard->Engine->eax += this->bastard->Engine->edx;
}

void MetaEngine::add_eax_eex() {
	this->bastard->Engine->eax += this->bastard->Engine->eex;
}

void MetaEngine::add_eax_efx() {
	this->bastard->Engine->eax += this->bastard->Engine->efx;
}

void MetaEngine::add_eax_egx() {
	this->bastard->Engine->eax += this->bastard->Engine->egx;
}


void MetaEngine::add_ebx_ebx() {
	this->bastard->Engine->ebx += this->bastard->Engine->ebx;
}

void MetaEngine::add_ebx_eax() {
	this->bastard->Engine->ebx += this->bastard->Engine->eax;
}

void MetaEngine::add_ebx_ecx() {
	this->bastard->Engine->ebx += this->bastard->Engine->ecx;
}

void MetaEngine::add_ebx_edx() {
	this->bastard->Engine->ebx += this->bastard->Engine->edx;
}

void MetaEngine::add_ebx_eex() {
	this->bastard->Engine->ebx += this->bastard->Engine->eex;
}

void MetaEngine::add_ebx_efx() {
	this->bastard->Engine->ebx += this->bastard->Engine->efx;
}

void MetaEngine::add_ebx_egx() {
	this->bastard->Engine->ebx += this->bastard->Engine->egx;
}


void MetaEngine::add_ecx_ecx() {
	this->bastard->Engine->ecx += this->bastard->Engine->ecx;
}

void MetaEngine::add_ecx_eax() {
	this->bastard->Engine->ecx += this->bastard->Engine->eax;
}

void MetaEngine::add_ecx_ebx() {
	this->bastard->Engine->ecx += this->bastard->Engine->ebx;
}

void MetaEngine::add_ecx_edx() {
	this->bastard->Engine->ecx += this->bastard->Engine->edx;
}

void MetaEngine::add_ecx_eex() {
	this->bastard->Engine->ecx += this->bastard->Engine->eex;
}

void MetaEngine::add_ecx_efx() {
	this->bastard->Engine->ecx += this->bastard->Engine->efx;
}

void MetaEngine::add_ecx_egx() {
	this->bastard->Engine->ecx += this->bastard->Engine->egx;
}


void MetaEngine::add_edx_edx() {
	this->bastard->Engine->edx += this->bastard->Engine->edx;
}

void MetaEngine::add_edx_eax() {
	this->bastard->Engine->edx += this->bastard->Engine->eax;
}

void MetaEngine::add_edx_ebx() {
	this->bastard->Engine->edx += this->bastard->Engine->ebx;
}

void MetaEngine::add_edx_ecx() {
	this->bastard->Engine->edx += this->bastard->Engine->ecx;
}

void MetaEngine::add_edx_eex() {
	this->bastard->Engine->edx += this->bastard->Engine->eex;
}

void MetaEngine::add_edx_efx() {
	this->bastard->Engine->edx += this->bastard->Engine->efx;
}

void MetaEngine::add_edx_egx() {
	this->bastard->Engine->edx += this->bastard->Engine->egx;
}


void MetaEngine::add_eex_eex() {
	this->bastard->Engine->eex += this->bastard->Engine->eex;
}

void MetaEngine::add_eex_eax() {
	this->bastard->Engine->eex += this->bastard->Engine->eax;
}

void MetaEngine::add_eex_ebx() {
	this->bastard->Engine->eex += this->bastard->Engine->ebx;
}

void MetaEngine::add_eex_ecx() {
	this->bastard->Engine->eex += this->bastard->Engine->ecx;
}

void MetaEngine::add_eex_edx() {
	this->bastard->Engine->eex += this->bastard->Engine->edx;
}

void MetaEngine::add_eex_efx() {
	this->bastard->Engine->eex += this->bastard->Engine->efx;
}

void MetaEngine::add_eex_egx() {
	this->bastard->Engine->eex += this->bastard->Engine->egx;
}


void MetaEngine::add_efx_efx() {
	this->bastard->Engine->efx += this->bastard->Engine->efx;
}

void MetaEngine::add_efx_eax() {
	this->bastard->Engine->efx += this->bastard->Engine->eax;
}

void MetaEngine::add_efx_ebx() {
	this->bastard->Engine->efx += this->bastard->Engine->ebx;
}

void MetaEngine::add_efx_ecx() {
	this->bastard->Engine->efx += this->bastard->Engine->ecx;
}

void MetaEngine::add_efx_edx() {
	this->bastard->Engine->efx += this->bastard->Engine->edx;
}

void MetaEngine::add_efx_eex() {
	this->bastard->Engine->efx += this->bastard->Engine->eex;
}

void MetaEngine::add_efx_egx() {
	this->bastard->Engine->efx += this->bastard->Engine->egx;
}


void MetaEngine::add_egx_egx() {
	this->bastard->Engine->egx += this->bastard->Engine->egx;
}

void MetaEngine::add_egx_eax() {
	this->bastard->Engine->egx += this->bastard->Engine->eax;
}

void MetaEngine::add_egx_ebx() {
	this->bastard->Engine->egx += this->bastard->Engine->ebx;
}

void MetaEngine::add_egx_ecx() {
	this->bastard->Engine->egx += this->bastard->Engine->ecx;
}

void MetaEngine::add_egx_edx() {
	this->bastard->Engine->egx += this->bastard->Engine->edx;
}

void MetaEngine::add_egx_eex() {
	this->bastard->Engine->egx += this->bastard->Engine->eex;
}

void MetaEngine::add_egx_efx() {
	this->bastard->Engine->egx += this->bastard->Engine->efx;
}


void MetaEngine::sub_eax_ebx() {
	this->bastard->Engine->eax -= this->bastard->Engine->ebx;
}

void MetaEngine::sub_eax_ecx() {
	this->bastard->Engine->eax -= this->bastard->Engine->ecx;
}

void MetaEngine::sub_eax_edx() {
	this->bastard->Engine->eax -= this->bastard->Engine->edx;
}

void MetaEngine::sub_eax_eex() {
	this->bastard->Engine->eax -= this->bastard->Engine->eex;
}

void MetaEngine::sub_eax_efx() {
	this->bastard->Engine->eax -= this->bastard->Engine->efx;
}

void MetaEngine::sub_eax_egx() {
	this->bastard->Engine->eax -= this->bastard->Engine->egx;
}


void MetaEngine::sub_ebx_eax() {
	this->bastard->Engine->ebx -= this->bastard->Engine->eax;
}

void MetaEngine::sub_ebx_ecx() {
	this->bastard->Engine->ebx -= this->bastard->Engine->ecx;
}

void MetaEngine::sub_ebx_edx() {
	this->bastard->Engine->ebx -= this->bastard->Engine->edx;
}

void MetaEngine::sub_ebx_eex() {
	this->bastard->Engine->ebx -= this->bastard->Engine->eex;
}

void MetaEngine::sub_ebx_efx() {
	this->bastard->Engine->ebx -= this->bastard->Engine->efx;
}

void MetaEngine::sub_ebx_egx() {
	this->bastard->Engine->ebx -= this->bastard->Engine->egx;
}


void MetaEngine::sub_ecx_eax() {
	this->bastard->Engine->ecx -= this->bastard->Engine->eax;
}

void MetaEngine::sub_ecx_ebx() {
	this->bastard->Engine->ecx -= this->bastard->Engine->ebx;
}

void MetaEngine::sub_ecx_edx() {
	this->bastard->Engine->ecx -= this->bastard->Engine->edx;
}

void MetaEngine::sub_ecx_eex() {
	this->bastard->Engine->ecx -= this->bastard->Engine->eex;
}

void MetaEngine::sub_ecx_efx() {
	this->bastard->Engine->ecx -= this->bastard->Engine->efx;
}

void MetaEngine::sub_ecx_egx() {
	this->bastard->Engine->ecx -= this->bastard->Engine->egx;
}


void MetaEngine::sub_edx_eax() {
	this->bastard->Engine->edx -= this->bastard->Engine->eax;
}

void MetaEngine::sub_edx_ebx() {
	this->bastard->Engine->edx -= this->bastard->Engine->ebx;
}

void MetaEngine::sub_edx_ecx() {
	this->bastard->Engine->edx -= this->bastard->Engine->ecx;
}

void MetaEngine::sub_edx_eex() {
	this->bastard->Engine->edx -= this->bastard->Engine->eex;
}

void MetaEngine::sub_edx_efx() {
	this->bastard->Engine->edx -= this->bastard->Engine->efx;
}

void MetaEngine::sub_edx_egx() {
	this->bastard->Engine->edx -= this->bastard->Engine->egx;
}


void MetaEngine::sub_eex_eax() {
	this->bastard->Engine->eex -= this->bastard->Engine->eax;
}

void MetaEngine::sub_eex_ebx() {
	this->bastard->Engine->eex -= this->bastard->Engine->ebx;
}

void MetaEngine::sub_eex_ecx() {
	this->bastard->Engine->eex -= this->bastard->Engine->ecx;
}

void MetaEngine::sub_eex_edx() {
	this->bastard->Engine->eex -= this->bastard->Engine->edx;
}

void MetaEngine::sub_eex_efx() {
	this->bastard->Engine->eex -= this->bastard->Engine->efx;
}

void MetaEngine::sub_eex_egx() {
	this->bastard->Engine->eex -= this->bastard->Engine->egx;
}


void MetaEngine::sub_efx_eax() {
	this->bastard->Engine->efx -= this->bastard->Engine->eax;
}

void MetaEngine::sub_efx_ebx() {
	this->bastard->Engine->efx -= this->bastard->Engine->ebx;
}

void MetaEngine::sub_efx_ecx() {
	this->bastard->Engine->efx -= this->bastard->Engine->ecx;
}

void MetaEngine::sub_efx_edx() {
	this->bastard->Engine->efx -= this->bastard->Engine->edx;
}

void MetaEngine::sub_efx_eex() {
	this->bastard->Engine->efx -= this->bastard->Engine->eex;
}

void MetaEngine::sub_efx_egx() {
	this->bastard->Engine->efx -= this->bastard->Engine->egx;
}


void MetaEngine::sub_egx_eax() {
	this->bastard->Engine->egx -= this->bastard->Engine->eax;
}

void MetaEngine::sub_egx_ebx() {
	this->bastard->Engine->egx -= this->bastard->Engine->ebx;
}

void MetaEngine::sub_egx_ecx() {
	this->bastard->Engine->egx -= this->bastard->Engine->ecx;
}

void MetaEngine::sub_egx_edx() {
	this->bastard->Engine->egx -= this->bastard->Engine->edx;
}

void MetaEngine::sub_egx_eex() {
	this->bastard->Engine->egx -= this->bastard->Engine->eex;
}

void MetaEngine::sub_egx_efx() {
	this->bastard->Engine->egx -= this->bastard->Engine->efx;
}