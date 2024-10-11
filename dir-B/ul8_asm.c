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

// Holds one Instruction complete with it's operation and argument.
// line holds line of instruction in UL8-ASM file for debugging purposes.
// adress holds adress of instruction in memory.
// op_code holds bit-format of instruction in UL8-ISA.
// next points to the instruction immediately following.
typedef struct Inst {
    int8_t line;
    int8_t adress;
    char *op;
    char *arg;
    char op_code;
    struct Inst *next;
} Inst;

// Holds one Label with it's name.
// inst points to the first instruction of the label's code-block.
// next points to the label immediately following.
typedef struct Label {
    int8_t line;
    char *name;
    struct Inst *inst;
    struct Label *next;
} Label;

// decodes an operation in string form into it's opcode. 
char op_code_of(char* str) {
    if (strcmp(str, "LDA") == 0) {
        return 0b00000000;
    } else if (strcmp(str, "STV") == 0) {
        return 0b00100000;
    } else if (strcmp(str, "ADD") == 0) {
        return 0b01000000;
    } else if (strcmp(str, "NAND") == 0) {
        return 0b01100000;
    } else if (strcmp(str, "JMP") == 0) {
        return 0b10000000;
    } else if (strcmp(str, "JMN") == 0) {
        return 0b10100000;
    } else if (strcmp(str, "NOT") == 0) {
        return 0b11000000;
    } else if (strcmp(str, "HLT") == 0) {
        return 0b11100000;
    } else exit(1);
}

// Decodes an UL8-opcode into it's string-format (1s and 0s as text characters) with newline at the end.
char *string_of_op(char op) {
    char *str = malloc(10);
    if (!str) exit(1);
    for (int i = 0; i < 8; i++) str[i] = (op & (128 >> i)) ? '1' : '0';
    str[8] = '\n';
    str[9] = 0;
    return str;
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
                // Decode line with label into datastructure
                DEBUG_PRINT("Identified as label-line\n");
                Label *l = malloc(sizeof(Label));
                size_t tk_len = strlen(tk);
                tk[tk_len - 1] = 0;
                l->name = malloc(tk_len - 1);
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
                // Decode line with instruction into datastructure
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

    // perform checks for mandatory labels (.data as first and .start as second)
    // This also guarantees the safety of memory-accesses in the following
    if (lh == NULL) {
        printf("ERROR: Did not find any labels. Labels '.data' and '.start' are mandatory.\n");
        return 1;
    }

    if (strcmp(lh->name, ".data")) {
        printf("ERROR: Missing '.data'-label as first label. Found %s\n", lh->name);
        return 1;
    }

    if (lh->next == NULL) {
        printf("ERROR: Did not find second label. '.start' as second label is mandatory.\n");
        return 1;
    }

    if (strcmp(lh->next->name, ".start")) {
        printf("ERROR: Missing '.start'-label as second label. Found %s\n", lh->next->name);
        return 1;
    }

    DEBUG_PRINT("Found '.data' and '.start' at expected positions.\n");

    // Create memory-adresses and instruction-op-codes for instructions
    Inst *code = lh->next->inst;
    int8_t adress = 0;
    while (code != NULL) {
        code->adress = adress;
        code->op_code = op_code_of(code->op);
        if (code->op_code == 1) {
            printf("ERROR: Operation '%s' at line %d could not be identified.\n", code->op, code->line);
            return 1;
        }
        code = code->next;
        adress++;
    }

    // Create memory-adresses for data directly behind memory
    // Decode value of data 
    Inst *data = ih;
    while (data != lh->next->inst) {
        data->adress = adress;
        data->op_code = atoi(data->arg);
        data = data->next;
        adress++;
    }

    // Cheack for memory size
    if (adress >= 32) {
        printf("%d bytes are needed to store this program, UL8 offeres a maximum of 32 bytes of memory.\n", adress);
        return 1;
    }

    DEBUG_PRINT("Finished adress- and op-code-assignment.\n");

    // Deode data-names
    code = lh->next->inst;
    data =ih;
    Label *label = lh;
    while (code != NULL) {
        int8_t found = 0;
        if (code->arg != NULL) {
            // Check, whether instructions have data (op_code < 128) or labels (op_code >= 128) as argument
            if ((u_int8_t) code->op_code < 128) {
                // search for symbols in data-section
                while(data != lh->next->inst) {
                    if (!strcmp(code->arg, data->op)) {
                        code->op_code = (code->op_code | data->adress);
                        found = 1;
                        break;
                    }
                    data = data->next;
                }
            } else {
                // search for symbols in labels
                while (label != NULL) {
                    if (!strcmp(code->arg, label->name)) {
                        code->op_code = (code->op_code | label->inst->adress);
                        found = 1;
                        break;
                    }
                    label = label->next;
                }
            }
            if (!found) {
                printf("Could not find symbol '%s' in line %d.\n", code->arg, code->line);
                return 1;
            }
            found = 0;
        }
        data = lh->inst;
        code = code->next;
        label = lh;
    }

    // Create array, that holds the string-representation of the op_codes
    char *op_strings[32];
    char *zero = "00000000\n";
    memset_pattern8(op_strings, &zero, 32 * 8);
    code = ih;
    while (code != NULL) {
        op_strings[code->adress] = string_of_op(code->op_code);
        code = code->next;
    }

    for (int i = 0; i < 32; i++) {
        DEBUG_PRINT("%s", op_strings[i]);
    }

    // Create output-file and write string-representations of code to it
    FILE *out = fopen("out", "w");
    if (!out) {
        printf("Could not open/create output-file.\n");
        exit(1);
    }

    for (int i = 0; i < 32; i++) {
        fprintf(out, "%s", op_strings[i]);
        if (op_strings[i] != zero) free(op_strings[i]);
    }

    fclose(out);

    // free allocated memory
    Label *label_inter;
    while (lh != NULL) {
        label_inter = lh->next;
        free(lh->name);
        free(lh);
        lh = label_inter;
    }

    Inst *inst_inter;
    while(ih != NULL) {
        inst_inter = ih->next;
        free(ih->op);
        if (ih->arg) free(ih->arg);
        free(ih);
        ih = inst_inter;
    }

    DEBUG_PRINT("Finished successfully.\n");

    return 0;
}
