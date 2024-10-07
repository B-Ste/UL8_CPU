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
    int8_t line;
    int8_t adress;
    char *op;
    char op_code;
    char *arg;
    struct Inst *next;
} Inst;

typedef struct Label {
    int8_t line;
    char *name;
    struct Inst *inst;
    struct Label *next;
} Label;

// decodes an operation-specifier in string form into it's opcode. 
int8_t op_code_of(char* str) {
    if (strcmp(str, "LDA") == 0) {
        return 0;
    } else if (strcmp(str, "STV") == 0) {
        return 1;
    } else if (strcmp(str, "ADD") == 0) {
        return 2;
    } else if (strcmp(str, "NAND") == 0) {
        return 3;
    } else if (strcmp(str, "JMP") == 0) {
        return 4;
    } else if (strcmp(str, "JMN") == 0) {
        return 5;
    } else if (strcmp(str, "NOT") == 0) {
        return 6;
    } else if (strcmp(str, "HLT") == 0) {
        return 7;
    } else return -1;
}

int main(int argc, char const *argv[])
{
    // Check for correct number of arguments.
    if (argc == 1) {
        printf("ERROR: No argument provided.\n");
        return 1;
    } else if (argc > 2){
        printf("ERROR: Too many arguments provided.\n");
        return 1;
    }

    // Check for .ul8 extension
    const char *path = argv[1];
    char *p = (char *)path;
    while (*(p++) != 0);
    p -= 5;
    if(strcmp(p, ".ul8") != 0) {
        printf("ERROR: Provided file needs to end with the .ul8 extension.\n");
        return 1;
    }

    //Open file
    FILE *file = fopen(path, "r");
    if (file == NULL) {
        printf("ERROR: File at %s cannot be opened.\n", path);
        return 1;
    }

    // Initialize data-structure for code-generation
    Inst *ih;
    Inst *it;

    Label *lh;
    Label *lt;

    // Reads lines from file. Limited to 256 chars per line.
    char line[LINE_LENGTH];
    int8_t line_nr = 1;
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
                l->line = line_nr;
                if (lh == NULL) {
                    lh = l;
                    lt = l;
                } else {
                    lt->next = l;
                    lt = l;
                }
            } else {
                DEBUG_PRINT("Identified as instruction-line\n");
                Inst *i = malloc(sizeof(Inst));
                i->op = malloc(strlen(tk));
                strcpy(i->op, tk);
                i->line = line_nr;
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
                if (lt != NULL && lt->inst == NULL) lt->inst = i;
            }
        } else DEBUG_PRINT ("Ignored empty line\n");
        DEBUG_PRINT("\n");
        line_nr++;
    }

    fclose(file);

    // perform checks for mandatory labels (.data as first and .start as second
    if (lh == NULL) {
        printf("ERROR: Did not find any labels. Labels '.data' and '.start' are mandatory.\n");
        return 1;
    }

    if (strcmp(lh->name, ".data:")) {
        printf("ERROR: Missing '.data'-label as first label. Found %s\n", lh->name);
        return 1;
    }

    if (lh->next == NULL) {
        printf("ERROR: Did not find second label. '.start' as second label is mandatory.\n");
        return 1;
    }

    if (strcmp(lh->next->name, ".start:")) {
        printf("ERROR: Missing '.start'-label as second label. Found %s\n", lh->next->name);
        return 1;
    }

    DEBUG_PRINT("Found '.data' and '.start' at expected positions.\n");

    // Map memory-adresses and op-codes to instructions
    Inst *code_start = lh->next->inst;
    int8_t adress = 0;
    while (code_start != NULL) {
        code_start->adress = adress;
        code_start->op_code = op_code_of(code_start->op);
        if (code_start->op_code < 0) {
            printf("ERROR: Operation '%s' at line %d could not be identified.", code_start->op, code_start->line);
            return 1;
        }
        code_start = code_start->next;
        adress++;
    }
    Inst *data_start =lh->inst;
    while (data_start != lh->next->inst) {
        data_start->adress = adress;
        data_start = data_start->next;
        adress++;
    }

    if (adress >= 32) {
        printf("%d bytes are needed to store this program, UL8 offeres a maximum of 32 bytes of memory.\n", adress);
        return 1;
    }

    DEBUG_PRINT("Finished successfully.\n");

    return 0;
}
