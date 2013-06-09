/*
 * subMinimal BASIC -- syntax analysis with error recovery
 * Aaron Mansheim, 10/17/93-10/22/93
 *
 * restrictions from Minimal BASIC:
 * only integer constants and numeric variables;
 * initially, no arrays, only statements FOR-NEXT, GOTO,
 * IF-THEN, INPUT, LET, ON-GOTO, PRINT, REM, STOP;
 * no built-ins
 *
 * On error recovery and BASIC:
 *
 * Some might say a BASIC compiler should not include error recovery.
 * In "Back to BASIC" Kemeny and Kurtz suggest that it is better not
 * to display an error cascade that might discourage beginners, but
 * instead to halt compilation on the first error each time.
 * Perhaps, but without use of error recovery, on an error the generated
 * parser will only say "syntax error" or "parse error" (not both).
 * The use of error actions allows for more informative compilation
 * error messages; to get the compiler to halt on the first error
 * one could simply make ERROR call a function which prints the
 * error message and calls exit().
 *
 * Known problems: 2/25 the (valid) program "100 END" is not accepted - a
 * statement is required before the end-line.
 * A FOR without a corresponding NEXT produces an error at the END line.
 */

%{
	#include "bison.h"
	#include "yydebug.h"
	
	#define ERROR(x)	(yywhere(), puts(x))
%}

/*
 * terminal symbols
 */

%token NumIdentifier
%token NumConstant
%token LineNumber
%token RemarkString
%token QuotedString

%token IF
%token THEN

%token FOR
%token TO
%token STEP
%token NEXT

%token ON
%token GOTO
%token GO

%token INPUT
%token PRINT

%token STOP
%token END

%token REM

%token LET

%token GE		/* >= */
%token LE		/* <= */
%token NE		/* <> */

/*
 * precedence table
 */

%nonassoc '=' NE
%nonassoc '<' '>' GE LE
%left '+' '-'
%left '*' '/'
%left UMINUS
%left '^'

%%

/* 4. Programs */

program
	: blocks end_line
	| blocks end_line error
		{ ERROR("program: blocks end_line error"); }
	| blocks error
		{ ERROR("program: blocks error"); }
	;

blocks
	: block
	| blocks block
		{ yyerrok; }
	| error
		{ ERROR("blocks: error"); }
	| blocks error
		{ ERROR("blocks: blocks error"); }
	;

block
	: line
	| for_block
	;

line
	: line_number statement end_of_line
	;

line_number
	: LineNumber
	;

end_of_line
	: '\n'
	;

end_line
	: line_number end_statement end_of_line
	;

end_statement
	: END
	;

statement
	: goto_statement
	| if_then_statement
	| input_statement
	| let_statement
	| on_goto_statement
	| print_statement
	| remark_statement
	| stop_statement
	| error
		{ ERROR("statement: error"); }
	;


/* 5. Constants */

/* section empty */


/* 6. Variables */

variable
	: NumIdentifier
	;


/* 7. Expressions */

expression
	: numeric_expression
	| QuotedString
	;

numeric_expression
	: NumIdentifier
	| NumConstant
	| '(' numeric_expression rp
	| '(' error rp
		{ ERROR("numeric_expression: '(' error ')'"); }
	| '-' numeric_expression						%prec UMINUS
	| numeric_expression '+' numeric_expression
	| numeric_expression '-' numeric_expression
	| numeric_expression '*' numeric_expression
	| numeric_expression '/' numeric_expression
	| numeric_expression '^' numeric_expression
	;

/* make right parens important */
 
rp
	: ')'
		{ yyerrok; }
	;

/* 8. Implementation-Supplied Functions */

/* currently none */


/* 9. The Let-Statement */
let_statement
	: numeric_let_statement
	;

numeric_let_statement
	: LET NumIdentifier '=' numeric_expression
	;


/* 10. Control Statements */

goto_statement
	: goto line_number_ref
	;

goto
	: GOTO
	| GO TO
	;

line_number_ref
	: NumConstant
		/* must be changed to reflect constant type structure */
	;

if_then_statement
	: IF relational_expression THEN line_number_ref
	;

relational_expression
	: numeric_expression '<' numeric_expression
	| numeric_expression '>' numeric_expression
	| numeric_expression '=' numeric_expression
	| numeric_expression LE  numeric_expression
	| numeric_expression GE  numeric_expression
	| numeric_expression NE  numeric_expression
	;

on_goto_statement
	: ON numeric_expression goto line_number_ref_list
	;

line_number_ref_list
	: line_number_ref
	| line_number_ref_list ',' line_number_ref
		{ yyerrok; }
	| error
		{	ERROR("line_number_ref_list: error");
		}
	| line_number_ref_list error
		{	ERROR("line_number_ref_list: line_number_ref_list error");
		}
	| line_number_ref_list error line_number_ref
		{	ERROR("line_number_ref_list:"
				" line_number_ref_list error line_number_ref");
			yyerrok;
		}
	| line_number_ref_list ',' error
		{	ERROR("line_number_ref_list: line_number_ref_list ',' error");
		}
	;

stop_statement
	: STOP
	;


/* 11. For-Statements and Next-Statements */

for_block
	: for_line next_line
	| for_line blocks next_line
	;

for_line
	: line_number for_statement end_of_line
	;

next_line
	: line_number next_statement end_of_line
	;

for_statement
	: FOR NumIdentifier '=' numeric_expression TO numeric_expression
	| FOR NumIdentifier '=' numeric_expression TO numeric_expression STEP numeric_expression
	;

next_statement
	: NEXT NumIdentifier
	;


/* 12. The Print-Statement */
/* not fully implemented: no TAB */

print_statement
	: PRINT print_list print_item
	;

print_list
	: /* empty */
	| print_list print_item print_separator
		{ yyerrok; }
	| print_list error
		{ ERROR("print_list: print_list error"); }
	;

print_item
	: /* empty */
	| expression
	;

print_separator
	: ','
		{ $$ = ',' }
	| ';'
		{ $$ = ';' }
	;


/* 13. The Input-Statement */

input_statement
	: INPUT variable_list
	;

variable_list
	: variable
	| variable_list ',' variable
		{	yyerrok; }
	| error
		{	ERROR("variable_list: error"); }
	| variable_list error
		{	ERROR("variable_list: variable_list error"); }
	| variable_list error variable
		{	ERROR("variable_list: variable_list error variable");
			yyerrok;
		}
	| variable_list ',' error
		{	ERROR("variable_list: variable_list ',' error"); }
	;


/* 14. The Data-, Read-, and Restore-Statements */
/* not yet implemented */


/* 15. Array-Declarations */
/* not yet implemented */


/* 16. User-Defined Functions */
/* not yet implemented */


/* 17. The Randomize-Statement */
/* not yet implemented */


/* 18. The Remark-Statement */
/* This will do, but as a step toward implementing
 * unquoted strings could make RemarkStrings start
 * and end with a non-blank char: currently they
 * consist of all text from the 'REM' to the '\n'
 */

remark_statement
	: REM
	| REM RemarkString
	;
