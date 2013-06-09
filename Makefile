# Aaron Mansheim, 2013-06-09

all: subminbas

lex.yy.c:
	flex subminbas.l

subminbas.tab.c: lex.yy.c
	bison subminbas.y

subminbas: subminbas.tab.c
	gcc -o subminbas lex.yy.c subminbas.tab.c main+yyerr.c

clean:
	for file in subminbas subminbas.tab.c lex.yy.c test/provoke.out ; \
	do \
	    if [ -e "$${file}" ] ; \
	    then \
	        rm "$${file}" ; \
	    fi ; \
	done

test: subminbas
	./subminbas test/provoke.bas > test/provoke.out ; \
	diff test/provoke.out.expected test/provoke.out
