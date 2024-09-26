#include<stdio.h>
#include<string.h>

typedef struct Inst {
    struct Inst *next;
    char op;
    char arg;
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

    // Reads lines from file. Limited to 256 chars per line.
    // TODO: Make length of lines irrelevant
    char line[256];

    while (fgets(line, 256, file) != NULL) {
        printf("%s", line);
    }

    fclose(file);
    return 0;
}
