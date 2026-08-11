%{
#include "parser.tab.h"
#include <string.h>
%}

%option noyywrap
%option yylineno

%%

[ \t\r]+        ;

\n              ;

[0-9]+
{
    yylval.num = atoi(yytext);
    return NUMBER;
}

[a-zA-Z_][a-zA-Z0-9_]*
{
    strcpy(yylval.id.name, yytext);
    yylval.id.line = yylineno;
    return ID;
}

"="             return '=';
"+"             return '+';
"-"             return '-';
"*"             return '*';
"/"             return '/';
";"             return ';';

.               return yytext[0];

%%