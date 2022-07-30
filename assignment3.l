%{
 #include<stdio.h> 
  #include "assignment3.tab.h" 
  #include<string.h>
  char * split(char* s,char* delimeter);
%}

%%
([0-9]*)\.([0-9]+) {yylval.tuple.result= strdup(yytext); yylval.tuple.type = 3; return str;}
"#include"|"#define" {return INCLUDE;}
"=" {return EQUAL;}
"&&"  {yylval.tuple.arg1 =strdup(yytext);return AND;}
"||" {yylval.tuple.arg1 =strdup(yytext);return OR;}
"<<"|">>"|"&="|"|="|"^="|"+="|"-="|"*="|"/="|"=="|"!="|"<="|">="|"<"|">"|"->" {yylval.tuple.arg1 =strdup(yytext); return RELOP;}
[-+*/%!&|^] {return yytext[0];}
"int" { yylval.tuple.type = 1; return DATATYPE;}
"char" { yylval.tuple.type = 2; return DATATYPE;}
"float" { yylval.tuple.type = 3; return DATATYPE;}
"array"|"struct"|"union" {return DERIVEDDATATYPE;}
"break"|"continue"|"return" {return SIMPLESTATMENT;}
"if" {return IF;}
"else" {return ELSE;}
"switch" {return SWITCH;}
"do" {return DO;}
"while" {return WHILE;}
"for" {return FOR;}
"default" {return DEFAULT;}
"case" {return CASE;}
"{" {return OPENCUR;}
"}" {return CLOSECUR;}
"[" {return OPENS;}
"]" {return CLOSES;}
"(" {return OPENC;}
")" {return CLOSEC;}
"," {return COMMA;}
";" {return SEMI;}
":" {return COLON;}
"printf" {return PRINT;}
"scanf" {return SCAN;}
"__global__".* {return GLOBAL;}
"<".*".""h"">" {return LIBRARY;}
[a-zA-Z_][a-zA-Z0-9_]*"<<<".*">>>" {return KERNALINVOC;}
[a-zA-Z_][a-zA-Z0-9_]* { yylval.tuple.result = strdup(yytext); return IDENTIFIER;}
[0-9]+  {yylval.tuple.num= atoi(yytext); yylval.tuple.type = 1; return CONSTANT;}
(["]([^"\\\n]|\\.|\\\n)*["])|(\'.\') {yylval.tuple.result= strdup(yytext); yylval.tuple.type = 2; return str;}
"//".*" "*    {;}
\/\*(.*\n)*.*\*\/    {;}
\n  {;}
. {;}
%%

int yywrap()								
{
    return 1;
}


