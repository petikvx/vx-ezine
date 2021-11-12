/*
	Author: Know v3.0
	Twitter: @KnowV3
	Email: know [dot] omail [dot] pro
	Website: knowlegend.ws / knowlegend.me

	(c) 2013 - Know v3.0 alias Knowlgend
*/
#pragma once
class KeyGenerator
{
public:
	KeyGenerator(void){}
	~KeyGenerator(void){}
	char* generateKey(int len);
	char* generateMasterKey(int len);
};

