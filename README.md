"subminbas" is a syntax checker for a subset of the ANSI Minimal
BASIC programming language. The copyright for the syntax checker
belongs to me, Aaron Mansheim. I have not decided upon a free or
open-source license for this software.

The "sub-Minimal BASIC" programming language is quite a restricted
language. For example, all line numbers must be from one to four
digits long. There are no AND and OR operators. Addition and
multiplication may be used instead. There is no GOSUB statement.

"subminbas" can be built and tested as follows:

    make
    make test

The test is silent when successful.

The input for the test is the error-filled BASIC file
"test/provoke.bas". The expected output is in the file
"test/provoke.out.expected".
