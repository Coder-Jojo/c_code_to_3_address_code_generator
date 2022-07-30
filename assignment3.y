%{ 
   /* Definition section */
  int yylex();
    void yyerror(char* s);
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    char* symbols[1000];
    int symbolValues[1000];
    int symbolCounter = 0;
    int labelCounter = 0;
    int flagNum = 0;
    int symbolVal(char* symbol);
    char* numToString;
    char* numToString2;
    char* labels;
    char* labels2;
    char* labels3;
    void updateTable(char* symbol,int value);
    char* split(char* s, char delimeter);
    char* split2(char* s, char delimeter);
    int relopHandler(int n,int n2,int n3);
    char* Temp();
    int tempForExp;
    char* Label();
    char* idSplit;
    char* whileLabel;
     FILE* yyout; 
     FILE* yyin;
   
    char symbolTable[50][100][100];
    int top = 0;
    int symbolTop[100] = {0};

    void addToTable(char * c){
        for(int i=0;i<symbolTop[top];i++){
            if(!strcmp(symbolTable[top][i], c)){
                //printf("%s %s\n", symbolTable[top][i], c);
                printf("%s is redeclared in the same scope", c);
                exit(1);
            }
        }
        //printf("%s\n", symbolTable[top][i]);
        strcpy(symbolTable[top][symbolTop[top]++], c);
        
        //printf("%d\n", top);
    }

    void checkDeclaration(char * c){
        int i;
        int topi = top;
        int flag = 0;
        while(topi>=0){
            for( i=0;i<symbolTop[topi];i++){
                if(!strcmp(symbolTable[topi][i], c)){
                    flag = 1;
                }
            }
            if(flag)
                break;
            topi--;
        }
        if(topi==-1){
             printf("%s is undeclared in this scope", c);
                exit(1);
        }
    }


    char identi[50][100];
    int foo = 0;

    void fillIdenti(char * c){
        strcpy(identi[foo++], c);
    }

    void printIdenti(char * c){
        for(int i = 0; i<foo; i++)
            printf("%s = %s\n",identi[i], c);
    }


    int pot = 0;
    int idType[50][100];
    void assignType(int t){
        while(pot){
            idType[top][symbolTop[top] - pot] = t;
            pot --;
        }
        pot = 0;
    }
    void printType(){
        for(int i =0;i<symbolTop[top];i++)
            printf("%s %d\n", symbolTable[top][i],idType[top][i]);
    }

    void printError(){
        printf("Error : operation performed on two different types of data\n");
        exit(1);
    }

    int giveType(char * c){
        int i;
        int topi = top;
        int flag = 0;
        while(topi>=0){
            for( i=0;i<symbolTop[topi];i++){
                if(!strcmp(symbolTable[topi][i], c)){
                    //printf("%d\n", idType[topi][i]);
                    return idType[topi][i];
                    flag = 1;
                }
            }
            if(flag)
                break;
            topi--;
        }
    }

    char * switchLabel[30][20];
    char * switchCompare[30][20];
    int switchLabelCount = 0;
    int switchCompareCount = 0;
    int switchFlag = 0;

    void printNext(){
        printf("test :\n");
        for(int i = 0; i<switchLabelCount; i++){
            printf("if t == %s goto %s\n", switchCompare[i], switchLabel[i]);
        }
        printf("next :\n");
        switchCompareCount = 0;
        switchLabelCount = 0;
    }

    int weight(int t){
        if(t==1)
            return 4;
        if(t==2)
            return 1;
        return 4;
    }
    int ifcount = 0;
    char iflabel[50][50];
%}
%union {
    struct quadruple
    {
        int num;
        int isnum;
        char *arg1;
        char *arg2;
        char * result;
        char *arg3;
        int type;
    } tuple;
    }


%start PROGRAM 

%token <tuple> CONSTANT str
%token <tuple> incDec
%token <tuple> FOR
%token <tuple> WHILE DATATYPE
%token <tuple> IDENTIFIER
%token <tuple> RELOP AND OR
%type <tuple> SIMSTMT exp factor assignment term C DD EE IDENTIFIERS CAS CASES array expo and plus
%left '!'
%left '*' '/' '%'
%left '+' '-'
%left '&'
%left '^'
%left '|'
%left RELOP AND OR

%token NUMBER CLOSECUR OPENS OPENCUR CASE CLOSES IF  SIMPLESTATMENT
%token INCLUDE DO DEFAULT SEMI SWITCH OP OPENC EQUAL COMMA 
%token LIBRARY COLON CLOSEC ELSE
%token  GLOBAL PRINT SCAN
%token DEFINE KERNALINVOC DERIVEDDATATYPE
 
/* Rule Section */
%% 
  
PROGRAM: DECLIST        { 
                            printf("The program executed successfully"); 
                            return 0; 
                            } 
DECLIST: DECLIST DECL {;}
  | DECL {;} 
  
DECL : FUNDIC {;}
    | STMT

IDENTIFIERS : IDENTIFIERS COMMA IDENTIFIER {addToTable($3.result); fillIdenti($3.result); pot++;}
        | IDENTIFIER {addToTable($1.result); fillIdenti($1.result); pot++;}
        
array   : IDENTIFIER OPENS EE CLOSES {addToTable($1.result); fillIdenti($1.result); pot++; $$.result = $1.result; $$.type = $1.type; $$.arg1 = $3.result;}

FUNDIC : DATATYPE IDENTIFIER OPENC CLOSEC OPENCUR{top++;} STMT CLOSECUR{symbolTop[top--]=0;}
     

STMT : SIMSTMT STMT
    | SIMSTMT

SIMSTMT :  assignment SEMI {;}
     | DATATYPE IDENTIFIERS SEMI {assignType($1.type);foo = 0;}
     | DATATYPE array SEMI {assignType($1.type);foo = 0;}
     | exp SEMI {;}
     | IF OPENC EE { labels = Label(); $3.arg2 = labels;labels2 = Label();$3.arg3 = labels2; printf("If %s Goto %s\nGoto %s\n%s :\n",$3.result,labels, labels2, labels);   }   CLOSEC OPENCUR{top++;} STMT{labels3 = Label(); strcpy(iflabel[ifcount++], labels3);} CLOSECUR{symbolTop[top--]=0; printf("temp = 1\n%s :\n",$3.arg3);ifcount--;} 
     | WHILE {labels = Label(); $1.arg1 = labels; printf("%s:\n",$1.arg1);} OPENC EE { labels = Label(); $1.arg2 = labels; $1.result = Label(); printf("if %s Goto %s\nGoto %s\n%s \n",$4.result,$1.result,$1.arg2,$1.result);} CLOSEC OPENCUR{top++;} STMT CLOSECUR { printf("Goto %s:\n %s:\n",$1.arg1,$1.arg2); symbolTop[top--]=0;}
     | ELSE  OPENCUR{top++;printf("if temp == 1 Goto %s\n", iflabel[ifcount]);} STMT CLOSECUR { printf("%s :\n",iflabel[ifcount]); symbolTop[top--]=0;}
     | SWITCH OPENC EE CLOSEC{printf("t = %s\ngoto test\n", $3.result);} OPENCUR{top++;} CASES CLOSECUR{symbolTop[top--]=0; printNext();}
    ;

CASES : CASES CAS 
        | CAS

CAS : CASE{labels = Label(); printf("%s :\n", labels); strcpy(switchLabel[switchLabelCount++], labels); switchFlag = 1;}  factor COLON{switchFlag = 0;} STMT {printf("goto next :\n");}


assignment : DATATYPE IDENTIFIERS EQUAL exp {assignType($1.type); printIdenti($4.result); foo = 0; if($1.type != $4.type) printError();}
           | IDENTIFIER EQUAL exp {checkDeclaration($1.result); fprintf(yyout,"%s = %s\n",$1.result,$3.result); if(giveType($1.result) != $3.type) printError();}          
           | DATATYPE array EQUAL exp {assignType($1.type);foo = 0;if(giveType($1.result) != $4.type) printError(); labels = Temp(); printf("%s = %s * %d\n%s[%s] = %s\n", labels, $2.result, weight(giveType($1.result)), $2.result, labels, $2.arg1); }
           | IDENTIFIER OPENS EE CLOSES EQUAL exp {checkDeclaration($1.result);if(giveType($1.result) != $6.type) printError(); labels = Temp(); printf("%s = %s * %d\n%s[%s] = %s\n", labels, $3.result, weight(giveType($1.result)), $1.result, labels, $6.result);}
           ;
exp : expo {$$.type = $1.type;}
    | '!' exp {$$.result = Temp(); printf("%s = !%s\n",$$.result, $2.result); $$.type = $2.type;}
    | '-' '-' exp   { printf("%s = %s - 1\n",$3.result, $3.result); $$.type = $3.type;}       
    | '+' '+' exp {printf("%s = %s + 1\n",$3.result, $3.result); $$.type = $3.type;}
    | exp '-' '-'    { printf("%s = %s - 1\n",$1.result, $1.result); $$.type = $1.type;}       
    | exp '+' '+'  {printf("%s = %s + 1\n",$1.result, $1.result); $$.type = $1.type;}
    | exp '|' expo { $$.arg1 = $1.result; $$.arg2 = $3.result; $$.result = Temp(); $$.isnum = 0;  if($1.isnum == 1){  printf("%s = %d | %s\n",$$.result,$1.num,$3.result);}else { printf("%s = %s | %s\n",$$.result,$$.arg1,$$.arg2);} if($1.type != $3.type) printError(); else $$.type = $1.type;}
    ;

expo : and {$$.type = $1.type;}
    | exp '^' and { $$.arg1 = $1.result; $$.arg2 = $3.result; $$.result = Temp(); $$.isnum = 0;  if($1.isnum == 1){  printf("%s = %d ^ %s\n",$$.result,$1.num,$3.result);}else { printf("%s = %s ^ %s\n",$$.result,$$.arg1,$$.arg2);} if($1.type != $3.type) printError(); else $$.type = $1.type;}

and : plus {$$.type = $1.type;}
    | and '&' plus { $$.arg1 = $1.result; $$.arg2 = $3.result; $$.result = Temp(); $$.isnum = 0;  if($1.isnum == 1){  printf("%s = %d & %s\n",$$.result,$1.num,$3.result);}else { printf("%s = %s & %s\n",$$.result,$$.arg1,$$.arg2);} if($1.type != $3.type) printError(); else $$.type = $1.type;}

plus : term {$$.type = $1.type;}
    | exp '+' term { $$.arg1 = $1.result; $$.arg2 = $3.result; $$.result = Temp(); $$.isnum = 0;  if($1.isnum == 1){  printf("%s = %d + %s\n",$$.result,$1.num,$3.result);}else { printf("%s = %s + %s\n",$$.result,$$.arg1,$$.arg2);} if($1.type != $3.type) printError(); else $$.type = $1.type;}
    | exp '-' term { $$.arg1 = $1.result; $$.arg2 = $3.result; $$.result = Temp(); $$.isnum = 0;  if($1.isnum == 1){  printf("%s = %d - %s\n",$$.result,$1.num,$3.result);}else { printf("%s = %s - %s\n",$$.result,$$.arg1,$$.arg2);} if($1.type != $3.type) printError(); else $$.type = $1.type;}

EE : EE OR DD {  if($3.isnum == 1){ $$.arg1 = Temp(); $$.result = Temp(); printf("%s = %d\n",$$.arg1,$3.num);  printf("%s = %s %s %s\n",$$.result,$1.result,$2.arg1,$$.arg1);}else {  $$.result = Temp(); printf("%s = %s %s %s\n",$$.result,$1.result,$2.arg1,$3.result);}}
  | DD {$$.result = $1.result;}

DD : DD AND C {  if($3.isnum == 1){ $$.arg1 = Temp(); $$.result = Temp(); printf("%s = %d\n",$$.arg1,$3.num);  printf("%s = %s %s %s\n",$$.result,$1.result,$2.arg1,$$.arg1);}else {  $$.result = Temp(); printf("%s = %s %s %s\n",$$.result,$1.result,$2.arg1,$3.result);}}
  | C {$$.result = $1.result;}

C : C RELOP exp {  if($3.isnum == 1){ $$.arg1 = Temp(); $$.result = Temp(); printf("%s = %d\n",$$.arg1,$3.num);  printf("%s = %s %s %s\n",$$.result,$1.result,$2.arg1,$$.arg1);}else {  $$.result = Temp(); printf("%s = %s %s %s\n",$$.result,$1.result,$2.arg1,$3.result);} if($1.type != $3.type) printError(); else $$.type = $1.type;}
  | exp {$$.result = $1.result; $$.type = $1.type;}
  ;
term : factor {$$.type = $1.type;}
     | term '*' factor {  $$.arg1 = $1.result; $$.arg2 = $3.result; $$.result = Temp(); $$.isnum = 0;  if($1.isnum == 1){  printf("%s = %d * %s\n",$$.result,$1.num,$3.result);}else { printf("%s = %s * %s\n",$$.result,$$.arg1,$$.arg2);} if($1.type != $3.type) printError(); else $$.type = $1.type;}
     | term '/' factor { $$.arg1 = $1.result; $$.arg2 = $3.result; $$.result = Temp(); $$.isnum = 0;  if($1.isnum == 1){  printf("%s = %d / %s\n",$$.result,$1.num,$3.result);}else { printf("%s = %s / %s\n",$$.result,$$.arg1,$$.arg2);} if($1.type != $3.type) printError(); else $$.type = $1.type;}
     | term '%' factor { $$.arg1 = $1.result; $$.arg2 = $3.result; $$.result = Temp(); $$.isnum = 0;  if($1.isnum == 1){  printf("%s = %d / %s\n",$$.result,$1.num,$3.result);}else { printf("%s = %s / %s\n",$$.result,$$.arg1,$$.arg2);} if($1.type != $3.type) printError(); else $$.type = $1.type;}
     ;
factor : CONSTANT {$$.type =$1.type; sprintf(numToString,"%d",$1.num); $1.isnum = 1; $1.arg1 = numToString; $1.result = numToString; $$ =$1; if(switchFlag) strcpy(switchCompare[switchCompareCount++], $1.result);}
        | str {$$.type =$1.type; strcpy($$.result, $1.result); if(switchFlag) strcpy(switchCompare[switchCompareCount++], $1.result);}
       | OPENC exp CLOSEC { $2.isnum=0;  $$ = $2; $$.type = $2.type;} 
       | IDENTIFIER {  $$.result = $1.result; checkDeclaration($1.result); $$.type = giveType($1.result);}
       | IDENTIFIER OPENS EE CLOSES {$$.result = Temp(); labels = Temp();printf("%s = %s * %d\n%s = %s[%s]\n", labels, $3.result, weight(giveType($1.result)), $$.result, $1.result, labels);} 
       ;


%% 

char * Temp(){
    
    symbolCounter++;
    char *temp=(char *)malloc(sizeof(5*sizeof(char)));
    sprintf(temp,"t%d",symbolCounter);
    return temp;   
}
char * Label(){
    
    labelCounter++;
    char *temp=(char *)malloc(sizeof(5*sizeof(char)));
    sprintf(temp,"L%d",labelCounter);
    return temp;  
}

//driver code 
void main() 
{ 
  FILE* yyout;

    numToString = malloc(11 * sizeof(char));
    numToString2 = malloc(10 * sizeof(char));
    labels = malloc(10 * sizeof(char));
    labels2 = malloc(10 * sizeof(char));
    labels3 = malloc(10 * sizeof(char));
    idSplit = malloc(10 * sizeof(char));
    whileLabel = malloc(10 * sizeof(char));
   
    yyout = fopen("out.txt","w");
//  yyin = fopen("input.txt", "r");
//    yyparse();

printf("\nPlease, write the code here line by line\n"); 
   yyparse(); 
       fclose(yyout);
} 
void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 