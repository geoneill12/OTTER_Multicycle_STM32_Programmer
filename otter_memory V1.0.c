#include <stdio.h>
#include <stdlib.h>

int main(){

	/********** Remove "otter_memory.h" file if already present; create new "otter_memory.h" file, write first lines **********/
	remove("otter_memory.h");
	FILE *otter_memory;
	otter_memory = fopen("otter_memory.h", "w");
	char str1[] = "#ifndef INC_OTTER_MEMORY_H_\n";
	char str2[] = "#define INC_OTTER_MEMORY_H_\n";
	char str3[] = "uint32_t otter_memory[] = {\n";
	char str4[] = "};\n";
	char str5[] = "#endif\n";
	fputc( 0x0A, otter_memory);			// New line
	for (int i=0; str1[i] != '\n'; i++){		// Write "#ifndef INC_OTTER_MEMORY_H_"
		fputc(str1[i], otter_memory);
	}
	fputc( 0x0A, otter_memory);			// New line
	for (int i=0; str2[i] != '\n'; i++){		// Write "#define INC_OTTER_MEMORY_H_"
		fputc(str2[i], otter_memory);
	}
	fputc( 0x0A, otter_memory);			// New line
	fputc( 0x0A, otter_memory);			// New line
	for (int i=0; str3[i] != '\n'; i++){		// Write "uint32_t otter_memory[] = {"
		fputc(str3[i], otter_memory);
	}
	fputc( 0x0A, otter_memory);			// New line
	fputc( 0x0A, otter_memory);			// New line
	fputc( 0x30, otter_memory);			// Write "0"
	fputc( 0x78, otter_memory);			// Write "x"

	/********** Open "mem.txt" file, count how many instructions there are by counting how many new-line characters there are **********/
	FILE *mem;
	mem = fopen("mem.txt", "r");
	char hex_char;
	int NUM_INSTR = 0;
	while((hex_char = fgetc(mem))!=EOF){
		if (hex_char == 0x0A){
			NUM_INSTR++;
		}
	}
	fclose(mem);
	
	/********** Re-open "mem.txt", read each character, add to "otter_memory.h" **********/
	mem = fopen("mem.txt", "r");
	int j = 0;
	while((hex_char = fgetc(mem))!=EOF){
		switch(hex_char){
			case 0x0A:	// j keeps track of how many instructions have been copied over so far,
					// increment each time a new-line character is reached
					j++;
					// if we've reached the final instruction,
					// add a new-line character only (no comma)
					if (j == NUM_INSTR){
						fputc(0x0A, otter_memory);			// write ASCII character 0x0A (new-line) from "mem.txt" to "otter_memory.h"
						break;
					}
					// if we haven't reached the final instruction,
					// add a comma, new-line character, then a "0x"
					fputc(0x2C, otter_memory);				// write ASCII character 0x2C (,) from "mem.txt" to "otter_memory.h"
					fputc(0x0A, otter_memory);				// write ASCII character 0x0A (new-line) from "mem.txt" to "otter_memory.h"
					fputc(0x30, otter_memory);				// write ASCII character 0x30 (0) from "mem.txt" to "otter_memory.h"
					fputc(0x78, otter_memory);				// write ASCII character 0x78 (x) from "mem.txt" to "otter_memory.h"
					break;

			case 0x30: 	fputc(hex_char, otter_memory);	break;		// write ASCII character 0x30 (0) from "mem.txt" to "otter_memory.h"
			case 0x31: 	fputc(hex_char, otter_memory);	break;		// write ASCII character 0x31 (1) from "mem.txt" to "otter_memory.h"
			case 0x32: 	fputc(hex_char, otter_memory);	break;		// write ASCII character 0x32 (2) from "mem.txt" to "otter_memory.h"
			case 0x33: 	fputc(hex_char, otter_memory);	break;		// write ASCII character 0x33 (3) from "mem.txt" to "otter_memory.h"
			case 0x34: 	fputc(hex_char, otter_memory);	break;		// write ASCII character 0x34 (4) from "mem.txt" to "otter_memory.h"
			case 0x35: 	fputc(hex_char, otter_memory);	break;		// write ASCII character 0x35 (5) from "mem.txt" to "otter_memory.h"
			case 0x36: 	fputc(hex_char, otter_memory);	break;		// write ASCII character 0x36 (6) from "mem.txt" to "otter_memory.h"
			case 0x37: 	fputc(hex_char, otter_memory);	break;		// write ASCII character 0x37 (7) from "mem.txt" to "otter_memory.h"
			case 0x38: 	fputc(hex_char, otter_memory);	break;		// write ASCII character 0x38 (8) from "mem.txt" to "otter_memory.h"
			case 0x39: 	fputc(hex_char, otter_memory);	break;		// write ASCII character 0x39 (9) from "mem.txt" to "otter_memory.h"
			case 0x61: 	fputc(hex_char, otter_memory);	break;		// write ASCII character 0x61 (a) from "mem.txt" to "otter_memory.h"
			case 0x62: 	fputc(hex_char, otter_memory);	break;		// write ASCII character 0x62 (b) from "mem.txt" to "otter_memory.h"
			case 0x63: 	fputc(hex_char, otter_memory);	break;		// write ASCII character 0x63 (c) from "mem.txt" to "otter_memory.h"
			case 0x64: 	fputc(hex_char, otter_memory);	break;		// write ASCII character 0x64 (d) from "mem.txt" to "otter_memory.h"
			case 0x65: 	fputc(hex_char, otter_memory);	break;		// write ASCII character 0x65 (e) from "mem.txt" to "otter_memory.h"
			case 0x66: 	fputc(hex_char, otter_memory);	break;		// write ASCII character 0x66 (f) from "mem.txt" to "otter_memory.h"
		}
	}
	
	/********** Write final lines to "otter_memory.h"; close both "mem.txt" and "otter_memory.h" files **********/
	fputc( 0x0A, otter_memory);			// New line
	for (int i=0; str4[i] != '\n'; i++){		// Write "};"
		fputc(str4[i], otter_memory);
	}
	fputc( 0x0A, otter_memory);			// New line
	fputc( 0x0A, otter_memory);			// New line
	for (int i=0; str5[i] != '\n'; i++){		// Write "#endif"
		fputc(str5[i], otter_memory);
	}

	fclose(mem);
	fclose(otter_memory);
}