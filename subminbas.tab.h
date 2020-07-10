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
#ifndef YYSTYPE
#define YYSTYPE int
#endif
#define	NumIdentifier	258
#define	NumConstant	259
#define	LineNumber	260
#define	RemarkString	261
#define	QuotedString	262
#define	IF	263
#define	THEN	264
#define	FOR	265
#define	TO	266
#define	STEP	267
#define	NEXT	268
#define	ON	269
#define	GOTO	270
#define	GO	271
#define	INPUT	272
#define	PRINT	273
#define	STOP	274
#define	END	275
#define	REM	276
#define	LET	277
#define	GE	278
#define	LE	279
#define	NE	280
#define	UMINUS	281


extern YYSTYPE yylval;
