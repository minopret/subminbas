/*
	main+yyerr.c
	
	Main & error reporting module for yacc projects.
	Modelled on routines from
		Schreiner, Axel T. and H.George Friedman, Jr. INTRODUCTION
			TO COMPILER CONSTRUCTION WITH UNIX. Englewood Cliffs, NJ:
			Prentice-Hall, 1985.
	(Modifications: doesn't assume the yacc input is first filtered through the
	C preprocessor, an impossibility in THINK C 4; uses ANSI C;
	doesn't use yylineno, an undocumented feature not supported in GNU flex.)
	
	Aaron Mansheim, 10/16/93
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#ifdef THINK_C
	#include <console.h>
#endif
#include "yydebug.h"


/* values defined by lex.yy.c and used by yyerror */

extern char *yytext;			/* current token */
extern int yyleng;				/* and its length */
extern int line_no;				/* current input line number - */
	/* note line_no must be defined by the programmer */


static char *source;			/* input file name, from main() */
FILE * yyerfp = NULL;			/* error stream */


/* prototypes for this file's functions */

static void usage(register char *name);
int main(int argc, char **argv);
void yyerror(register char *s);
void yywhere(void);


static void
usage(register char *name) {
	fputs("usage: ", stderr);
	fputs(name, stderr);
	fputs(" [source]\n", stderr);
	exit(1);
	} /* usage */
	
	
int
main(int argc, char **argv) {
	char **argp;
#if YYDEBUG!=0
	extern int yydebug;
	
	yydebug = 1;
#endif
#ifdef THINK_C
	argc = ccommand(&argv);
#endif

    yyerfp = stdout;
    
	for (argp = argv; *++argp && **argp == '-'; ) {
		switch ((*argp)[1]) {
			/* catch allowed flags here -- currently none */
		default:
			usage(argv[0]);
			}
		}
	
	
	/* If no non-option arguments, read from stdin;
	 * If one non-option argument, read from the file it names;
	 * If more non-option arguments, display usage message.
	 */
	 
	if (argp[0]) { /* have an additional argument */
		if (argp[0] && argp[1]) {
			/* only one additional argument is allowed after flags */
			usage(argv[0]);
			}
		else { /* have one non-option argument */
			if (*argp && !freopen(*argp, "r", stdin)) {
				/* error if can't open file as stdin */
				perror(*argp);
				exit(1);
				}
			if ( source = (char *) malloc( (strlen(*argp)+1) * sizeof(char) ) ) {
				strcpy(source, *argp);
				}
			else {
				/* error if can't allocate space for "source" */
				perror(argv[0]);
				exit(1);
				}
			} /* if(argp[0]&&argp[1]) else */
		} /* if(arpg[0]) */
	exit(yyparse());
	} /* main */


void
yyerror(register char *s) {
	extern int yynerrs;		/* total number of errors */
	
	fprintf(yyerfp, "[error %d] ", yynerrs);
	yywhere();
	fputs(s, yyerfp);
	putc('\n', yyerfp);
	}	/* yyerror */


void
yywhere(void) {					/* provide position stamp */
	char colon = 0;				/* a flag */

#if 0
	/* I now don't care to print the source file's name -
	 * this can be done by a setup action instead. */
	 
	if (source && *source && strcmp(source, "\"\"")) {
		char *cp = source;
		int len = strlen(source);
		
		if (*cp == '"') {
			++cp, len -= 2;
			}
		fprintf(yyerfp, "file %.*s", len, cp);
		colon = 1;
		}
#endif
	if (line_no > 0) {
		if (colon) {
			fputs(", ", yyerfp);
			}
		fprintf(yyerfp, "line %d", line_no);
		colon = 1;
		}
	if (*yytext) {
		register int i;
		
		for (i=0; i < 20; ++i) {
			if (!yytext[i] || yytext[i] == '\n') {
				break;
				}
			}
		if (i) {
			if (colon) {
				putc(' ', yyerfp);
				}
			fprintf(yyerfp, "near \"%.*s\"", i, yytext);
			colon = 1;
			}
		}
	if (colon) {
		fputs(": ", yyerfp);
		}
	} /* yywhere */
