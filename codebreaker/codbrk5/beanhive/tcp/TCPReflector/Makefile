SRC := ${shell ls *.java}
OBJ := ${SRC:.java=.class}

OTHER        = Makefile
BACKUP_FILES = $(SRC) $(OTHER)
JFLAGS       = 
JC           = javac

.PHONY = buildCmd build

default: buildCmd build

buildCmd:
	@echo "" > .build
	
build: $(OBJ)
	@slist=`cat .build`; \
	if [ "$$slist" != "" ]; then \
		echo $(JC) $(JFLAGS) $$slist; \
		$(JC) $(JFLAGS) $$slist; \
	fi
	rm .build

$(OBJ) : %.class : %.java
	@echo "$<" >> .build

backup:
	Date=`date`;\
	Dir=`echo $$Date | awk '{printf("%s-%s-%s-%s", $$2, $$3, $$6, $$4)}'`;\
	mkdir $$Dir > /dev/null 2>/dev/null;\
	tar cvf Backup.tar $(BACKUP_FILES);\
	gzip Backup.tar;\
	mv Backup.tar.gz $$Dir

%.class: %.java
	$(JC) $(JFLAGS) $?
