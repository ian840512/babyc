%{
#include <stdio.h>
#include "syntax.c"

int yyparse(void);

void yyerror(const char *str)
{
	fprintf(stderr,"error: %s\n",str);
}

int yywrap()
{
	return 1;
}

extern FILE *yyin;

Syntax *syntax;

void write_skeleton(Syntax *syntax) {
    FILE *out = fopen("out.s", "wb");

    fprintf(out, ".text\n");
    // We seem to require at least 8 spaces for indentation.
    fprintf(out, "    .global _start\n\n");
    fprintf(out, "_start:\n");

    // TODO: do everything in eax, then move to ebx for exit.
    // TODO: recurse
    if (syntax->type == UNARY_OPERATOR) {
        UnarySyntax *unary_syntax = syntax->expression;

        fprintf(out, "    movl    $%d, %%ebx\n", unary_syntax->expression->value);

        if (unary_syntax->unary_type == BITWISE_NEGATION) {
            fprintf(out, "    not     %%ebx\n");
        } else {
            fprintf(out, "    test    $0xFFFFFFFF, %%ebx\n");
            fprintf(out, "    setz    %%bl\n");
        }
    } else {
        // Exit code as specified.
        fprintf(out, "    movl    $%d, %%ebx\n", syntax->value);
    }

    fprintf(out, "    movl    $1, %%eax\n");
    fprintf(out, "    int     $0x80\n");
    
    fclose(out);
}

int main(int argc, char *argv[])
{
    ++argv, --argc;  /* Skip over program name. */
    if (argc != 1) {
        printf("Please specify a file to compile.\n");
        printf("    $ babyc <your file here>\n");
        return 1;
    }

    yyin = fopen(argv[0], "r");

    if (yyin == NULL) {
        // TODO: work out what the error was.
        // TODO: Unit test this.
        printf("Failed to open file.\n");
        return 2;
    }
    yyparse();

    write_skeleton(syntax);
    syntax_free(syntax);

    printf("Written out.s.\n");
    printf("Build it with:\n");
    printf("    $ as out.s -o out.o\n");
    printf("    $ ld -s -o out out.o\n");

    return 0;
}

%}

%token INCLUDE HEADER_NAME
%token TYPE IDENTIFIER RETURN NUMBER
%token OPEN_BRACE CLOSE_BRACE
%token BITWISE_NEGATE LOGICAL_NEGATE

%%

program:
	function
        ;

function:
	TYPE IDENTIFIER '(' ')' OPEN_BRACE statement CLOSE_BRACE
        ;

statement:
        RETURN expression ';'
        ;

expression:
	NUMBER
        {
            syntax = immediate_new($1);
        }
        |
        BITWISE_NEGATE expression
        {
            syntax = bitwise_negation_new(syntax);
        }
        |
        LOGICAL_NEGATE expression
        {
            syntax = logical_negation_new(syntax);
        }
        ;
