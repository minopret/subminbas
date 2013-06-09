%{
/*
 * subMinimal BASIC -- lexical analysis
 * Aaron Mansheim, 10/17/93-10/22/93
 *
 * restrictions from Minimal BASIC:
 * only integer constants and numerical variables;
 * initially, no arrays, only statements FOR-NEXT, GOTO,
 * IF-THEN, INPUT, LET, PRINT, REM, STOP;
 * no built-ins
 */

#include <stdlib.h>

#ifdef DEBUG		/* debugging version */

	char *rettokname;
	
	int main(int argc, char **argv) {
		while (yylex()) {
			printf("%-10.10s is \"%s\"\n", rettokname, yytext);
		}
	}
	
	s_lookup() {}
	int yynerrs = 0;
	
	#define token(x) (rettokname = #x, 1)
	#define rwtoken(x) (1)
	
#else DEBUG		/* production version */

	#include "subminbas.tab.h"
	#define token(x) x
	#define rwtoken(x) x
	s_lookup() {}
	
#endif DEBUG

unsigned line_no = 0;
#define ENDTABLE(v)	( v-1 + sizeof(v)/sizeof(v[0]) )
static int screen();
%}

%option noyywrap

letter				[A-Z]
digit				[0-9]
blank				" "
other				.
quotedstrchar		[A-Z0-9 &'*^):,$=!><#(%?;/_+.-]
strchar				[A-Z0-9 "&'*^):,$=!><#(%?;/_+.-]

%Start remark quoted

%%

<remark>{blank}{strchar}*$	{	/* Cheap trick:
							  	 * In order for this pattern to
							  	 * be chosen over the one for
							  	 * keywords, which requires trailing
							  	 * context, must also require trailing
							  	 * context here. But then must match
							  	 * the blank which (fortunately) always
							  	 * must follow an REM that has text;
							  	 * without explicitly matching that
							  	 * would get an infinite loop as
							  	 * {strchar}*$ matches \n without
							  	 * consuming it.
							  	 */
							  	 return token(RemarkString);
							}

<remark>\n					{	/* line_no++; */
								BEGIN 0;
								return token(yytext[0]);
							}
							
<quoted>{quotedstrchar}*\"	{	BEGIN 0;
								return token(QuotedString);
							}

\"							BEGIN quoted;

">="						return token(GE);
"<="						return token(LE);
"<>"						return token(NE);

^{digit}{1,4}				{
							line_no = atoi(yytext);
							return token(LineNumber);
							}

{digit}+					return token(NumConstant);

{letter}					|
{letter}{digit}				{	s_lookup(token(NumIdentifier));
								return token(NumIdentifier);
							}

{blank}{letter}{letter}+/[ \n]	{
								/* This is the pattern for keywords */
								return screen();
							}

{blank}+					/* ignore otherwise unmatched blanks */;

\n							{
							/* line_no++; */
							return token(yytext[0]);
							}

{other}						return token(yytext[0]);

%%

/*
 *		reserved word screener
 */
 
static struct rwtable {		/* reserved word table */
	char *rw_name;			/* representation */
	int rw_yylex;			/* yylex() value */
} rwtable[] = {				/* sorted */
	"END",		rwtoken(END),
	"FOR",		rwtoken(FOR),
	"GO",		rwtoken(GO),
	"GOTO",		rwtoken(GOTO),
	"IF",		rwtoken(IF),
	"INPUT",	rwtoken(INPUT),
	"LET",		rwtoken(LET),
	"NEXT",		rwtoken(NEXT),
	"ON",		rwtoken(ON),
	"PRINT",	rwtoken(PRINT),
	"REM",		rwtoken(REM),
	"STEP",		rwtoken(STEP),
	"STOP",		rwtoken(STOP),
	"THEN",		rwtoken(THEN),
	"TO",		rwtoken(TO)
};

static int screen() {
	struct rwtable *low = rwtable,
		*high = ENDTABLE(rwtable),
		*mid;
	int c;
	
	while (low <= high) {
		mid = low + (high - low)/2;
		if ((c = strcmp(mid->rw_name, yytext+1)) == 0) {
		#ifdef DEBUG
			rettokname = mid->rw_name;
		#endif
			if (strcmp("REM", mid->rw_name) == 0) {
				BEGIN remark;
			}
			return mid->rw_yylex;
		} else if (c < 0) {
			low = mid + 1;
		} else {
			high = mid - 1;
		}
	}
	return token(RemarkString);
	/* The RemarkString token type returned for unmatched strings is
	 * guaranteed to cause a syntax error at the parser, and sort of
	 * appropriate */

} /* screen */
