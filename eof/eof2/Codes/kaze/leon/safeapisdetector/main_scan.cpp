#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <windows.h>
#include <list>

#define rol(a,b) (((a) << (b)) | ((a) >> (32 - (b)))) 

using namespace std;
typedef struct {
    char* apiname;
    int nb_args;
}NA_API;

typedef struct {
    char* dllname;
    list<NA_API> na_apis;
}NA_DLL;

//Les dlls a scanner
char *dll_noms[]={"kernel32.dll","ws2_32.dll","user32.dll","gdi32.dll",NULL};

void perr(char* s)
{
    fprintf(stderr,"%s\n",s);
    exit(1);   
}

//calcule un hash d'un char*
DWORD crc(char* s)
{
    DWORD eax=0;
    DWORD ecx=0;
    while(*s!=0)
    {
        eax=eax & 0xFFFFFF00;
        eax|=(DWORD)*s;
        BYTE t=(BYTE)(ecx&0xFF);
        t+=(BYTE)(*s);
        ecx&=0xFFFFFF00;
        ecx|=(DWORD)t;
        eax=rol(eax,(DWORD)t);
        ecx+=eax;        
        s++;
    }   
    return ecx;
}

int main(int argc,char** argv)
{  
    int nb_apis_total=0;
    int nb_apis_noop=0;
    char **dlls=dll_noms;
    list<NA_DLL> resultat;
    //parcoure la liste des dlls a scanner
    while(*dlls!=NULL)
    {
        NA_DLL na_dll_courant;
        na_dll_courant.dllname=*dlls;
        
        DWORD hdll=(DWORD)LoadLibrary(*dlls);
        if(hdll==NULL)
        {
            perr("DLL not found");   
        }
        
        printf("===== Chargement de %s =====\n\n",*dlls);
        
        PIMAGE_DOS_HEADER pdos=(PIMAGE_DOS_HEADER)hdll;
        PIMAGE_NT_HEADERS ppe=(PIMAGE_NT_HEADERS)(hdll+pdos->e_lfanew);
        PIMAGE_EXPORT_DIRECTORY eat=(PIMAGE_EXPORT_DIRECTORY)(hdll+ppe->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress);
        int nb_apis=eat->NumberOfNames;
        char** noms_apis=(char**)(eat->AddressOfNames+hdll);
        WORD* ordinaux_apis=(WORD*)(eat->AddressOfNameOrdinals+hdll);
        DWORD* rva_apis=(DWORD*)(eat->AddressOfFunctions+hdll);
        int indice=0;
        //Parcourt la liste des apis exportées
        while(indice<nb_apis)
        {
            nb_apis_total++;
            PROCESS_INFORMATION pi;
            STARTUPINFO si;
            NA_API na_api_courant;
            int nb_args=-1;
            
            char commandline[100];
            char* nom=(char*)((DWORD)noms_apis[indice]+hdll);
            
            
            DWORD ord=(DWORD)ordinaux_apis[indice];
            DWORD rva=rva_apis[indice];
            printf("Test de l'api %s (Ordinal %d Rva %p) ... ",nom,ord,rva);
            FILE* l = fopen("last.log","w");
            fprintf(l,"Test de l'api %s (Ordinal %d Rva %p) ... ",nom,ord,rva);
            fclose(l);
            
            //test de l'api
            GetStartupInfo(&si);         
            //Lance na_test (main.exe en fait)   
            snprintf(commandline,100,"main.exe %s %s",*dlls,nom);
            if(CreateProcess(NULL,commandline,NULL,NULL,
                    FALSE,0,NULL,NULL,&si,&pi)==0)
            {
                perr("Impossible de créer le process!\n");    
            }
            DWORD statut=WaitForSingleObject(pi.hProcess,2000);
            //Plus de 2secondes ? ca pue !
            if(statut==WAIT_TIMEOUT)
            {
                TerminateProcess(pi.hProcess,0);
            }
            
            bool apiok=true;
            //Recup le fichier créé par na_test
            FILE* f=fopen("na_retour.txt","r");
            if(f<=0) 
                apiok=false;
            //et choppe le nb d'args
            nb_args=(int)fgetc(f)-'0';    
            if(feof(f) || nb_args<0)
            {
                apiok=false;
            }
            if(f>0)
                fclose(f);
                
            if(apiok)
            {
                nb_apis_noop++;
                na_api_courant.apiname=nom;
                na_api_courant.nb_args=nb_args;
                na_dll_courant.na_apis.push_back(na_api_courant);
                printf("[ OK ] (%d)",nb_args);       
            }
            else
            {
                printf("[ KO ]");       
            }
            printf("\n");
            
            indice++;    
        }
        resultat.push_back(na_dll_courant);
        dlls++;
    }
    
    //Ecriture du resultat
    FILE* f1=fopen("fake_apis.inc","w");
    FILE* f2=fopen("fake_apis.txt","w");
    
    fprintf(f1,";Liste des fake_apis\nliste_fake_apis:\n");
    fprintf(f2,"========= Liste des fake_apis ==========\n");
    
    list<NA_DLL>::iterator d=resultat.begin();
    while(d!=resultat.end())
    {
        fprintf(f1,"\tdb \"%s\",0\n",d->dllname);
        list<NA_API>::iterator a=d->na_apis.begin();
        while(a!=d->na_apis.end())
        {
            fprintf(f2,"%s %s (%d)\n",d->dllname,a->apiname,a->nb_args);   
            fprintf(f1,"\tFAKE_API 0%ph %d ; %s\n",crc(a->apiname),a->nb_args,a->apiname);
            a++;
        }
        if(++d!=resultat.end())
        {
            fprintf(f1,"\tFAKE_API_SEPARATEUR\n");
        }
        else
        {
            fprintf(f1,"\tFAKE_API_FIN\n");
        }
    }
    fprintf(f2,"\n%d noop apis trouvees sur un total de %d apis testees\n",nb_apis_noop,nb_apis_total);
    fprintf(f2,"Soit %f%%\n",(float)nb_apis_noop/(float)nb_apis_total*100);
    fprintf(f1,"\n;%d noop apis trouvees sur un total de %d apis testees\n",nb_apis_noop,nb_apis_total);
    fprintf(f1,";Soit %f%%\n",(float)nb_apis_noop/(float)nb_apis_total*100);
    fclose(f1);
    fclose(f2);
    system("pause");
    return EXIT_SUCCESS;   
}

