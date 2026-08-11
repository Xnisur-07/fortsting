%{
#include <stdio.h>
%}

%%

"int"|"float"|"char"|"double"|"if"|"else"|"for"|"while"|"return"|"void" {
    printf("%s : KEYWORD\n", yytext);
}

[0-9]+(\.[0-9]+)? {
    printf("%s : NUMBER\n", yytext);
}

[a-zA-Z_][a-zA-Z0-9_]* {
    printf("%s : IDENTIFIER\n", yytext);
}

"=="|"!="|"<="|">="|"++"|"--"|"+"|"-"|"*"|"/"|"="|"<"|">" {
    printf("%s : OPERATOR\n", yytext);
}

"("|")"|"{"|"}"|"["|"]"|","|";"|":" {
    printf("%s : PUNCTUATION\n", yytext);
}

[ \t\n]+ ;

. {
    printf("%s : UNKNOWN\n", yytext);
}

%%

int yywrap()
{
    return 1;
}

int main()
{
    yylex();
    return 0;
}