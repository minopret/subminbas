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
	bison.h
		Needed definitions for bison output files.
	Aaron Mansheim, 10/6/93
*/


#define bcopy(src, dst, num) memcpy((dst), (src), (num))
