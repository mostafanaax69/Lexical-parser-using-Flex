%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef enum{BIN_INT, OCT_INT, DEC_INT, HEX_INT, STRING, NESTED_COMMENT, COMMENT, UNCLOSED_COMMENT, UNCLOSED_STRING} Token;
void showToken(Token);
%}


%option yylineno
%option noyywrap

letter ([a-zA-Z])
digit ([0-9])
octal ([0-7])
hex ([0-9a-fA-F])
WhiteSpace ([\t\r\n ])
PrintableChar ([\x20-\x7e\t\r\n])
EscapeSeq ((\\a)|(\\b)|(\\e)|(\\f)|(\\n)|(\\r)|(\\t)|(\\v)|(\\')|(\\\\)|(\\")|(\\\?))
ASCIIesc (\\u\{[0-9a-fA-F]+\})

%%

(Int)|(UInt)|(Double)|(Float)|(Bool)|(String)|(Character) printf("%d TYPE %s\n", yylineno, yytext);
var                                        printf("%d VAR %s\n", yylineno, yytext);
let                                        printf("%d LET %s\n", yylineno, yytext);
func                                       printf("%d FUNC %s\n", yylineno, yytext);
import                                     printf("%d IMPORT %s\n", yylineno, yytext);
nil                                        printf("%d NIL %s\n", yylineno, yytext);
while                                      printf("%d WHILE %s\n", yylineno, yytext);
if                                         printf("%d IF %s\n", yylineno, yytext);
else                                       printf("%d ELSE %s\n", yylineno, yytext);
return                                     printf("%d RETURN %s\n", yylineno, yytext);
true                                       printf("%d TRUE %s\n", yylineno, yytext);
false                                      printf("%d FALSE %s\n", yylineno, yytext);
[a-zA-Z][a-zA-Z0-9]*|_[a-zA-Z0-9]+         printf("%d ID %s\n", yylineno, yytext);
0b[01]+                                    showToken(BIN_INT);
0o[0-7]+                                   showToken(OCT_INT);
[0-9]+                                     showToken(DEC_INT);
0x[0-9a-fA-F]+                             showToken(HEX_INT);
(([0-9]+\.[0-9]*)|([0-9]*\.[0-9]+))([eE][\+-][0-9]+)?	printf("%d DEC_REAL %s\n", yylineno, yytext);
0x[0-9a-fA-F]+[pP][-\+][0-9]+              printf("%d HEX_FP %s\n", yylineno, yytext);
\"([\x20\x21\x23-\x7e\t]|\\\")*\"	showToken(STRING);
\"([\x20\x21\x23-\x7e\t]|\\\")*(.|[\n\r])?     showToken(UNCLOSED_STRING);
;                                          printf("%d SC %s\n", yylineno, yytext);
,                                          printf("%d COMMA %s\n", yylineno, yytext);
\(                                         printf("%d LPAREN %s\n", yylineno, yytext);
\)                                         printf("%d RPAREN %s\n", yylineno, yytext);
\{                                         printf("%d LBRACE %s\n", yylineno, yytext);
\}                                         printf("%d RBRACE %s\n", yylineno, yytext);
\[                                         printf("%d LBRACKET %s\n", yylineno, yytext);
\]                                         printf("%d RBRACKET %s\n", yylineno, yytext);
=                                          printf("%d ASSIGN %s\n", yylineno, yytext);
((<=)|(>=)|(<)|(>)|(!=)|(==))              printf("%d RELOP %s\n", yylineno, yytext);
\|\||&&                                    printf("%d LOGOP %s\n", yylineno, yytext);
\+|-|\*|\/|%                               printf("%d BINOP %s\n", yylineno, yytext);
->                                         printf("%d ARROW %s\n", yylineno, yytext);
:                                          printf("%d COLON %s\n", yylineno, yytext);
(\/\*([\x20-\x29\x2b-\x2e\x30-\x7e\t\n\r]|\/[\x20-\x29\x2b-\x7e\t\n\r]|\*[\x20-\x2e\x30-\x7e\t\n\r])*\*\/)|(\/\/[\x20-\x7e\t]*)  showToken(COMMENT);
(\/\*([\x20-\x29\x2b-\x2e\x30-\x7e\t\n\r]|\/[\x20-\x29\x2b-\x7e\t\n\r]|\*[\x20-\x2e\x30-\x7e\t\n\r])*\/\*([\x20-\x29\x2b-\x2e\x30-\x7e\t\n\r]|\/[\x20-\x29\x2b-\x7e\t\n\r]|\*[\x20-\x2e\x30-\x7e\t\n\r])*)([\x0-\x8\xb\xc\xe-\x1f\x7f-\xff])? showToken(NESTED_COMMENT);
(\/\*([\x20-\x29\x2b-\x2e\x30-\x7e\t\n\r]|\/[\x20-\x29\x2b-\x7e\t\n\r]|\*[\x20-\x2e\x30-\x7e\t\n\r])*)([\x0-\x8\xb\xc\xe-\x1f\x7f-\xff])?  showToken(UNCLOSED_COMMENT);
\x20|\n|\r|\t                                 ;
.        {printf("Error "); fwrite(yytext,1,1,stdout); printf("\n"); exit(0);}

%%




    void isvalid(char* str, int strlength) 
	{
      for (int i = 1; i < strlength - 1; i++)
      {
		  if(str[i] == '\\' && i==strlength - 2){
			  printf("Error unclosed string\n");
			  exit(0);
		  }
		  if(str[i] == '\\' && str[i + 1] == '\\'){
			  i++;
		  }
		  else if (str[i] == '\\' &&
			(str[i + 1] != 'u' && str[i + 1] != 'n' &&
			  str[i + 1] != 'r' && str[i + 1] != 't' && str[i + 1] != '"'))
		  {
				printf("Error undefined escape sequence %c\n", str[i + 1]);
				exit(0);
		  }
		  else if (str[i] == '\\' && str[i + 1] == 'u')
		  {
			  char* tmp = strchr(str+i,'}');
			  if(!tmp){
				printf("Error undefined escape sequence u\n");
			  	exit(0);
			  }
			  size_t n = tmp - (str+i+3);
			  if(n>6){
					printf("Error undefined escape sequence u\n");
					exit(0);
			  }
			char* sub = malloc(n);
			memcpy(sub,str+i+3,n);
				
				for(int k=0;k<n;k++){
					if(!(sub[k]>='0'&&sub[k]<='9')&&!(sub[k]>='a'&&sub[k]<='f')&&!(sub[k]>='A'&&sub[k]<='F')){
						printf("Error undefined escape sequence u\n");
						free(sub);
						exit(0);
					}
				}
				free(sub);
			}
      }
    }

    void showToken(Token name) 
	{
		if (name == NESTED_COMMENT)
		{
			int strlength = yyleng;
			char* str = yytext;
			int i = strlength-1;
			if(str[i]!='\t'&&str[i]!='\n'&&str[i]!='\r'&&(str[i]<32||str[i]>126)){
				printf("Error ");
				fwrite(str+i,1,1,stdout);
				printf("\n");
				exit(0);
			}
			printf("Warning nested comment\n");
			exit(0);
		}
		if (name == UNCLOSED_COMMENT)
		{
			int strlength = yyleng;
			char* str = yytext;
			int i = strlength-1;
			if(str[i]!='\t'&&str[i]!='\n'&&str[i]!='\r'&&(str[i]<32||str[i]>126)){
				printf("Error ");
				fwrite(str+i,1,1,stdout);
				printf("\n");
				exit(0);
			}
			printf("Error unclosed comment\n");
			exit(0);
		}
		if (name == UNCLOSED_STRING)
		{
			int strlength = yyleng;
			char * str = yytext;
			for (int i = 1; i < strlength; i++)
			{
				if(str[i]!='\t'&&str[i]!='\n'&&str[i]!='\r'&&(str[i]<32||str[i]>126)){
					printf("Error ");
					fwrite(str+i,1,1,stdout);
					printf("\n");
					exit(0);
				}
				if(str[i]=='\\' && i == strlength-1){
					printf("Error unclosed string\n");
				    exit(0);
				}
				if (str[i] == '\\' &&
				(str[i + 1] != 'u' && str[i + 1] != '\\' && str[i + 1] != 'n' &&
				  str[i + 1] != 'r' && str[i + 1] != 't' && str[i + 1] != '"'))
				{
					printf("Error undefined escape sequence %c\n", str[i + 1]);
					exit(0);
				}
				if (str[i] == '\\' && str[i + 1] == 'u')
				{
					char* tmp = strchr(str+i,'}');
					if(!tmp){
						printf("Error undefined escape sequence u\n");
						exit(0);
					}
					size_t n = tmp - (str+i+3);
					if(n>6){
						printf("Error undefined escape sequence u\n");
						exit(0);
					}
					char* sub = malloc(n);
					memcpy(sub,str+i+3,n);
					for(int k=0;k<n;k++){
						if(!(sub[k]>='0'&&sub[k]<='9')&&!(sub[k]>='a'&&sub[k]<='f')&&!(sub[k]>='A'&&sub[k]<='F')){
							printf("Error undefined escape sequence u\n");
							free(sub);
							exit(0);
						}
					}
					int c = strtol(sub,NULL,16);
					free(sub);
					if(c!=9&&c!=10&&c!=13&&(c<32||c>126)){
						printf("Error undefined escape sequence u\n");
						exit(0);
					}
				} 
			}
			printf("Error unclosed string\n");
			exit(0);
		}
		else if (name == STRING)
		{
			int strlength = strlen(yytext);
			isvalid(yytext,strlength);
			char * str = yytext;
			char arr[1025];
			int j = 0;
			for (int i = 1; i < strlength - 1; i++)
			{
				if (str[i] == '\\' && str[i + 1] == 'u')
				{
					size_t n = strchr(str+i,'}') - (str+i+3);
					char* sub = malloc(n);
					memcpy(sub,str+i+3,n);
					int c = strtol(sub,NULL,16);
					free(sub);
					if(c!=9&&c!=10&&c!=13&&(c<32||c>126)){
						printf("Error undefined escape sequence u\n");
						exit(0);
					}
					arr[j++] = c;
					i+=n+3;
				} else if (str[i] == '\\' && str[i + 1] == 'n')
				{
					arr[j++] = '\n';
					i++;
				} else if (str[i] == '\\' && str[i + 1] == 't')
				{
					arr[j++] = '\t';
					i++;
				} else if (str[i] == '\\' && str[i + 1] == 'r')
				{
					arr[j++] = '\r';
					i++;
				} else if (str[i] == '\\' && str[i + 1] == '\\')
				{
					arr[j++] = '\\';
					i++;
				}  else if (str[i] == '\\' && str[i + 1] == '"')
				{
					arr[j++] = '"';
					i++;
				} else
				{
					arr[j++] = str[i];
				}
			}
			arr[j++] = '\0';
			printf("%d STRING %s\n", yylineno, arr);
		} else if (name == BIN_INT)
		{
			char* str = yytext;
			int dec = strtol(str+2,NULL,2);
			printf("%d BIN_INT %d\n", yylineno, dec);
		} else if (name == DEC_INT)
		{
			int c = strtol(yytext,NULL,10);
			printf("%d DEC_INT %d\n", yylineno, c);
		} else if (name == OCT_INT)
		{
			char * str = yytext;
			int dec = strtol (str+2,NULL,8);
			printf("%d OCT_INT %d\n", yylineno, dec);
      } else if (name == HEX_INT)
      {
			char * str = yytext;
			int dec = strtol (str+2,NULL,16);
			printf("%d HEX_INT %d\n", yylineno, dec);
      } else if (name == COMMENT)
      {
        int strlength = yyleng;
        char * str = yytext;
        int cnt = 1;
        for (int i = 0; i < strlength; i++)
        {
          if (str[i] == '\r'){
			  cnt++;
			  if(i!=strlength-1 && str[i+1]=='\n') i++;
		  }
		  else if (str[i] == '\n') cnt++;
		}
		printf("%d COMMENT %d\n",yylineno,cnt);
	  }

    }
