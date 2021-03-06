
D			[0-9]
L			[a-zA-Z]
X			[A-Z]
%{
#define YYSTYPE char*
#include "y.tab.h"

void yyerror();
%}


%%
#[^\n]*       { /* Discard preprocessor comments. */ }
"//"[^\n]*    { /* Discard c99 comments. */ }

[ \t\n]+      { /* Ignore whitespace */ }

"{"           { return LBRACE; } /*special symbols*/
"}"           { return RBRACE; }
"("           { return '('; }
")"           { return ')'; }
"["	{return LSQUARE;}
"]"	{return RSQUARE;}
";"	{return ';';}
","	{return ',';}

"!"           { return '!'; } /*arithmetic operators*/
"+"           { return '+'; }
"-"           { return '-'; }
"*"           { return '*'; }
"="           { return '='; }
"/"	{return '/';}

"=="	{return EQ;} /*comparison operators*/
"!="	{return NE;}
"<"	{return '<';}
">"	{return '>';}
"<="	{return LE;}
">="	{return GE;}
"&&"	{return AND;}
"||"	{return OR;}

\".\"	{yylval=strdup(yytext); return K_Char;} /*Char*/

[0-9]+        {
                yylval = strdup(yytext); return NUMBER;
              } /*number*/

"if"          { return IF; } /*keywords*/
"while"       { return WHILE; }
"return"      { return RETURN; }
"char"	{return CHAR;}
"else"	{return ELSE;}
"int"         { return INT; }
"break"	{return BREAK;}
"printf"	{return PRINT;}
"read"	{return READ;}

id{X}({L})*	{yylval=strdup(yytext); return ID;} /*identifier*/
%%


