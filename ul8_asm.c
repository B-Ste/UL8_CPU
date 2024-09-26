#include<stdio.h>
#include<string.h>

#if !defined(ERROR)
#define ERROR(x) (fprintf(stderr, x))
#endif 

int main(int argc, char const *argv[])
{
    // Check for correct number of arguments.
    if (argc == 1) {
        ERROR("No argument provided.\n");
        return 1;
    } else if (argc > 2){
        ERROR("To many arguments provided.\n");
        return 1;
    }
    // Check for .ul8 extension
    const char *path = argv[1];
    char *p = (char *)path;
    while (*(p++) != 0);
    p -= 5;
    if(strcmp(p, ".ul8") != 0) {
        ERROR("Provided file needs to end with the .ul8 extension.\n");
        return 1;
    }
    return 0;
}
