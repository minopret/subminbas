/*
    subMinimal BASIC: Source-to-source compiler for a subset of Minimal BASIC
    Copyright (C) 2020  Aaron J. Mansheim

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
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
#include "yydebug.h"


/* values defined by lex.yy.c and used by yyerror */

extern char *yytext;			/* current token */
extern int yyleng;				/* and its length */
extern int line_no;				/* current input line number - */
	/* note line_no must be defined by the programmer */


/* function defined by subminbas.tab.c */

extern int yyparse(void);


static FILE *yyerfp;			/* error stream */


/* prototypes for this file's functions */

static void usage(register char *name);
int main(int argc, char **argv);
void yyerror(register char *s);
void yywhere(void);


static void
usage(register char *name) {
	(void) fputs("usage: ", stderr);
	(void) fputs(name, stderr);
	(void) fputs(" [source]\n", stderr);
	exit(EXIT_FAILURE);
} /* usage */
	
	
int
main(int argc, char **argv) {
	int i;
	char *source;			/* input file name, from main() */
#if YYDEBUG!=0
	extern int yydebug;
	
	yydebug = 1;
#endif

	yyerfp = stdout;

	for (i=1; i < argc && argv[i][0] == '-'; i++) {
		switch (argv[i][1]) {
			/* catch allowed flags here -- currently none */
		default:
			usage(argv[0]);
		}
	}
	
	
	/* If no non-option arguments, read from stdin;
	 * If one non-option argument, read from the file it names;
	 * If more non-option arguments, display usage message.
	 */
	 
	if (i < argc) { /* have an additional argument */
		if (i + 1 < argc) {
			/* only one additional argument is allowed after flags */
			usage(argv[0]);
		} else { /* have one non-option argument */
			char *arg = argv[i];
			if (!freopen(arg, "r", stdin)) {
				/* error if can't open file as stdin */
				perror(arg);
				exit(EXIT_FAILURE);
			}
			source = (char *) malloc((strlen(arg) + 1) * sizeof(char));
			if (source) {
				strcpy(source, arg);
			} else {
				/* error if can't allocate space for "source" */
				perror(argv[0]);
				exit(EXIT_FAILURE);
			}
		} /* if(i + 1 < argc) else */
	} /* if(i < argc) */
	exit(yyparse());
} /* main */


extern int yynerrs;		/* total number of errors */


void
yyerror(register char *s) {
	fprintf(yyerfp, "[error %d] ", yynerrs);
	yywhere();
	(void) fputs(s, yyerfp);
	(void) putc('\n', yyerfp);
}	/* yyerror */


void
yywhere(void) {					/* provide position stamp */
	int colon = 0;				/* a flag */
	register int i;

	if (line_no > 0) {
		if (colon != 0) {
			(void) fputs(", ", yyerfp);
		}
		fprintf(yyerfp, "line %d", line_no);
		colon = 1;
	}

	for (i=0; i < 20; ++i) {
		if (yytext[i] == '\0' || yytext[i] == '\n') {
			break;
		}
	}
	if (i > 0) {
		if (colon != 0) {
			(void) putc(' ', yyerfp);
		}
		fprintf(yyerfp, "near \"%.*s\"", i, yytext);
		colon = 1;
	}

	if (colon != 0) {
		(void) fputs(": ", yyerfp);
	}
} /* yywhere */
