/*
	Author: Know v3.0
	Twitter: @KnowV3
	Email: know [dot] omail [dot] pro
	Website: knowlegend.ws / knowlegend.me

	(c) 2013 - Know v3.0 alias Knowlgend
*/
#include "KeyGenerator.h"
#include <iostream>
#include <cstdlib>
#include <time.h> 
#include <vector>
using namespace std;
vector<char*> *buffer = new vector<char*>(0x510); // max posible tries..
int counter = -1;
char* KeyGenerator::generateMasterKey(int len) {
	/* generates a new key to crypt the dll */
	srand(time(NULL));
	char *char_arr = {"zA'yBw"};
	char *key = (char*)malloc(sizeof(char)*(len+1));
	int times = rand() % 6;
	key[len] = '\0';
	for(int x = 0; x < times; ++x) {
		for(int i = 0; i < len; ++i) {
				int b = rand() % 6;
				key[i] = char_arr[b];
		}

	}
	
	return key;
}

bool test(char* buf) {
	/* tests if a new key is used or not */
	for(int i = 0; i < buffer->size(); ++i) {
		if(buffer->at(i) != NULL) {
			if(strcmp(buffer->at(i), buf) == 0 ) {
				return true;
			}
		
		}
	
	}return false;
}

char* KeyGenerator::generateKey(int len) {
	/* generates a new key to decrypt the dll */
	srand(time(NULL));
	
	char *char_arr = {"zA'yBw"};
	char *key = new char[len+1];
nochmal:
	
	for(int i = 0; i < len; ++i) {
			int b = rand() % 6;
			key[i] = char_arr[b];
	}
	key[len] = '\0';
	if(counter == 0x50f) {
		free(buffer);
		buffer = new vector<char*>(0x510);
		counter = -1;
	}
	if(test(key)) { goto nochmal; }
	++counter;
	/* pushs every key to a vector to test if the key exists, see function "test" */
	buffer->at(counter) = key;
	return key;
}
