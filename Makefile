#
#   subMinimal BASIC: Source-to-source compiler for a subset of Minimal BASIC
#   Copyright (C) 2020  Aaron J. Mansheim
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

# Aaron Mansheim, 2013-06-09

all: subminbas

lex.yy.c:
	flex subminbas.l

subminbas.tab.c: lex.yy.c
	bison subminbas.y

subminbas: subminbas.tab.c
	gcc -o subminbas lex.yy.c subminbas.tab.c main+yyerr.c

clean:
	@for file in subminbas subminbas.tab.c lex.yy.c test/provoke.out ; \
	do \
	    if [ -e "$${file}" ] ; \
	    then \
	        rm "$${file}" ; \
	    fi ; \
	done

test: subminbas
	@./subminbas test/provoke.bas > test/provoke.out && \
	diff test/provoke.out.expected test/provoke.out
