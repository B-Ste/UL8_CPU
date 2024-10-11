# UL8_ASM

An assembler for the UL8-ISA as defined in it's [Github Repository](https://github.com/B-Ste/UL8_CPU).

## Usage

The assembler only accepts files with the `.ul8` extension. Use it by calling
```
./ul8_asm <file>
```
in it's direcotry, where `<file>` is the path to the `.ul8`-file you want to compile.

## UL8-Assembly

A UL8-assembly-file is made up of 2 destinct sections: `.data` and `.start`.

### `.data`
In `.data`, the user is able to declare identifiers, wich the user can use to refer to memory-addresses without explicitly declaring said address in the code. The `.data` section is also used to initialize the content at these memory-addresses. The initialization-values read as hexadecimal numbers. Each Identifier defines exactly one byte. `<identifyer>` and `<value>` shall be seperated by exactly one whitespace.

```
.data:
    <identifier> <value>
```

Example:
```
.data:
    foo 0
    bar 42
```
Here, identifier `foo` is initialized with `0` and identifier `bar` is initialized with `42` (hex).

### `.start`
This is where the code will start executing. It also defines the first (and maybe only) block of code. Blocks of code are defined using labels. A label is made of the following syntax: 
```
<label>:
```
They can be used as arguments for unconditional or conditional jump-instructions. The block of code belonging to a label begins at the instruction following the label and end at the next label or the end of the file. When called, for example at start of execution by using the `.start`-label, execution will resume on the label's block of code.

An instruction is made from the following syntax:
```
<instruction-code> <argument>
```
`<instruction-code>` and `<argument>` are separeted by exactly one whitespace, if `<argument>` is not empty. There is exactly one instruction per line. A complete listing of instructions can be found at the [UL8 repository](https://github.com/B-Ste/UL8_CPU).

## Example:
This program calculates `42 mod 7`.
```
.data:
    foo 42
    bar 7
    baz 1
.start:
    LDA bar
    NOT
    ADD baz
    STV baz
    LDA foo
loop:
    JMN exit
    ADD baz
    JMP loop
exit:
    ADD bar
    HLT
```