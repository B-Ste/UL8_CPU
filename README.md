# UL8 CPU

### Overview

This project aims to implement the UL8-CPU (useless 8-bit central processing unit). Inspired by a cumputer-model I first was introducted to at uni, this CPU, together with its corresponding custom ISA, shows what an extremly simple programmable computer could look like. It gets its name from beeing, altough theoretically functional, completely useless in any practical scenario.

### Intended Hardware & Programming

It is designed to be used on the Tang Nano 9k FPGA-board (featuring a GOWIN GW1NR-9 FPGA) paired with the 1.14inch LCD. Currently, its only way of beeing programmed is by inculding the program in the synthesis and PnR for the FPGA. The program is stored in raw binary in the [program file](src/program.txt), which currenlty holds a demo program that calculates *122 mod 7*.

### Features

- 32 Bytes of RAM
- 8-Bit Data-Word length
- fixed 8-Bit Instruction length

### ISA

An instruction consists of the op-code in the three most significant bits and a modifier *a* in the others bits.

| Instruction 	| Op-Code 	| Meaning (with memory-adress a) 	|
|-------------	|---------	|--------------------------------	|
| LDA a       	| 000     	| \<a> -> Akku                    	|
| STV a       	| 001     	| Akku -> a                      	|
| ADD a       	| 010     	| Akku + \<a> -> Akku             	|
| NAND a      	| 011     	| Akku NAND \<a> -> Akku          	|
| JMP a       	| 100     	| \<a> -> PC                      	|
| JMN a       	| 101     	| if MSB of Akku = 1: \<a> -> PC      	|
| NOT         	| 110     	| NOT Akku -> Akku               	|
| HLT         	| 111     	| halts the machine              	|