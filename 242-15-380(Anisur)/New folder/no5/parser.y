%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
void yyerror(const char *s);

typedef struct {
    char name[50];
    int value;
} Variable;

Variable table[100];
int count = 0;
int error_flag = 0;

int lookup(char *name)
{
    for (int i = 0; i < count; i++)
        if (strcmp(table[i].name, name) == 0)
            return table[i].value;

    return 0;
}