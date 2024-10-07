#include<stdlib.h>
#include<stdio.h>
#include<string.h>

#ifdef DEBUG
    #define DEBUG_PRINT(...) printf(__VA_ARGS__)
#else
    #define DEBUG_PRINT(...)
#endif

#define LINE_LENGTH 256
#define TOKEN_DELIMETER (" \n")

typedef struct Inst {
    struct Inst *next;
    char *op;
    char *arg;
} Inst;

typedef struct Label {
    char *name;
    struct Inst *inst;
    struct Label *next;
} Label;

int main(int argc, char const *argv[])
{
    // Check for correct number of arguments.
    if (argc == 1) {
        printf("No argument provided.\n");
        return 1;
    } else if (argc > 2){
        printf("To0 many arguments provided.\n");
        return 1;
    }

    // Check for .ul8 extension
    const char *path = argv[1];
    char *p = (char *)path;
    while (*(p++) != 0);
    p -= 5;
    if(strcmp(p, ".ul8") != 0) {
        printf("Provided file needs to end with the .ul8 extension.\n");
        return 1;
    }

    //Open file
    FILE *file = fopen(path, "r");
    if (file == NULL) {
        printf("File at %s cannot be opened.\n", path);
        return 1;
    }

    // Initialize data-structure for code-generation
    Inst *ih;
    Inst *it;

    Label *lh;
    Label *lt;

    // Reads lines from file. Limited to 256 chars per line.
    char line[LINE_LENGTH];
    while (fgets(line, LINE_LENGTH, file) != NULL) {
        size_t len = strlen(line);
        if (line[len - 1] == '\n') line[len - 1] = 0;
        DEBUG_PRINT("Processing line: %s\n", line);
        char *tk = strtok(line, TOKEN_DELIMETER);
        if (tk != NULL) {
            if (tk[strlen(tk) - 1] == ':') {
                DEBUG_PRINT("Identified as label-line\n");
                Label *l = malloc(sizeof(Label));
                l->name = malloc(strlen(tk));
                strcpy(l->name, tk);
                if (lh == NULL) {
                    lh = l;
                    lt = l;
                } else {
                    lt->next = l;
                    lt = l;
                }
            } else {
                Inst *i = malloc(sizeof(Inst));
                i->op = malloc(strlen(tk));
                strcpy(i->op, tk);
                tk = strtok(NULL, TOKEN_DELIMETER);
                if (tk != NULL) {
                    i->arg = malloc(strlen(tk));
                    strcpy(i->arg, tk);
                }
                if (ih == NULL) {
                    ih = i;
                    it = i;
                } else {
                    it->next = i;
                    it = i;
                }
                if (lt->inst == NULL) lt->inst = i;
                DEBUG_PRINT("Identified as instruction-line\n");
            }
        } else DEBUG_PRINT ("Ignored empty line\n");
        DEBUG_PRINT("\n");
    }

    fclose(file);
    return 0;
}
