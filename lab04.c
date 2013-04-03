#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Constantes básicas */
#define MAX_INSTRUCTIONS 2024
#define MAX_STRING 128

/* Contantes que definem o lado da instrução */
#define LH 0
#define RH 1

/* Contantes que definem o tipo do comando */
#define WORD 1
#define INSTRUCTION 2

/* Estrutura que aponta para a posição de uma instrução */
typedef struct {
	int line;
	int side;
} Cursor;

/* Estrutura de um comando */
typedef struct {
	char *instruction;
	Cursor cursor;
	int opcode;
	int address;
    int type;
	long long int word;
} Comand;

/* Estrutura das diretivas de montagem */

/* Estrutura de uma label */
typedef struct {
	char *label;
	Comand *comand;
	int found;
} Label;

/* Estrutura da diretiva org */
typedef struct {
	int line;
	int found;
} OrgDirective;

/* Estrutura da diretiva align */
typedef struct {
	int multiple;
	int found;
} AlignDirective;

/* Estrutura da diretiva wfill */
typedef struct {
	int lines;
	long long int value;
	int found;
} WfillDirective;

/* Estrutura da diretiva word */
typedef struct {
	long long int value;
	int found;
} WordDirective;

/* Estrutura da diretiva set */
typedef struct {
	char *label;
	long long int value;
	int found;
} SetDirective;

/* Variáveis globais para montagem do código */
int labelsLength = 0;
int directivesLength = 0;
int comandsLength = 0;

Label labels[MAX_INSTRUCTIONS];
SetDirective directives[MAX_INSTRUCTIONS];
Comand comands[MAX_INSTRUCTIONS];
char instructions[MAX_INSTRUCTIONS][MAX_STRING];

/**
  * Retorna o cursor que aponta para a label
  * 
  * start: string com a label
  */
Cursor cursor (char *start) {
	Cursor result;
	int j;

	result.line = -1;

	for (j = 0; j < labelsLength; j++) {
		if (memcmp(labels[j].label, start, strlen(labels[j].label)) == 0) {
			result.line = (*labels[j].comand).cursor.line;
			result.side = (*labels[j].comand).cursor.side;
		}
	}
	return result;
}

/**
  * Converte uma string para inteiro
  * 
  * start: string que vai ser convertida
  */
long long int toInteger(char *start) {
	long long int i = 0;
	int j;
	Cursor labelCursor;

	if (start != NULL) { /* Verifica se exite algum valor na string */
		if ((start[0] > '9' || start[0] < '0') && start[0] != '-') { /* Verifica se o valor passado é uma label ou constante */
			labelCursor = cursor(start);
			if (labelCursor.line > -1) {
                /* Caso o calor seja uma label, pega a linha dela */
				i = labelCursor.line;
			} else {
                /* Caso seja uma constante, pega o valor dela */
				for (j = 0; j < directivesLength; j++) {
					if (memcmp(directives[j].label, start, strlen(directives[j].label)) == 0) {
						i = directives[j].value;
					}
				}
			}
		} else if (start[0] == '0' && start[1] == 'X') { /* Verifica se o valor passado é hexadecimal */
			sscanf(start+2, "%llx", &i);	
		} else if (start[0] == '0' && start[1] == 'O') { /* Verifica se o valor passado é octal */
			sscanf(start+2, "%llo", &i);
		} else if (start[0] == '0' && start[1] == 'B') { /* Verifica se o valor passado é binário */
			i = 0;
			j = 2;
            /* Converte de binário para decimal */
			while (j < MAX_STRING && start[j] != '\0' && start[j] != ')' && start[j] != ' ') {
				i = i*2;
				i += start[j] - '0';
				j++;
			}
		} else { /* Pega o valor em decimal */
			sscanf(start, "%lld", &i);	
		}
	}
	return i;
}

/**
  * Remove a label de um comando
  * 
  * start: string que vai ser limpa
  */
void removeLabel (char comand [MAX_STRING]) {
	int i;
	char * position = strchr(comand, ':');

	if (position != NULL) {
        /* Seta todas as posições anteriores ao ':'' para ' ' */
		for (i = 0; i < position - comand + 1; i++) {
			comand[i] = ' ';
		}
	}
}

/**
  * Remove o comentário de um comando
  * 
  * start: string que vai ser limpa
  */
void removeComment (char comand [MAX_STRING]) {
	int i;
	char * position = strchr(comand, ';');

	if (position != NULL) {
        /* Seta todas as posições anteriores ao ':'' para '\0' */
		for (i = position - comand; i < MAX_STRING; i++) {
			comand[i] = '\0';
		}
	}
}

/**
  * Remove os espaço em branco de uma string
  * 
  * start: string que vai ser limpa
  */
void trim (char comand [MAX_STRING]) {
    size_t len = 0;
    char *frontp = comand - 1;
    char *endp = NULL;

    if (comand[0] != '\0') {
	    len = strlen(comand);
	    endp = comand + len;

	    while (isspace(*(++frontp)));
	    while (isspace(*(--endp)) && endp != frontp);

	    if (comand + len - 1 != endp) {
	        *(endp + 1) = '\0';
	    } else if (frontp != comand && endp == frontp) {
	    	*comand = '\0';
	    }

	    endp = comand;
	    if(frontp != comand) {
	        while (*frontp) {
	        	*endp++ = *frontp++;
	        }
	        *endp = '\0';
	    }
	}
}

/**
  * Verifica se um comando é uma diretiva ORG e retorna a diretiva
  * 
  * comand: comando que vai ser interpretado
  */
OrgDirective orgDirective (char comand [MAX_STRING]) {
	OrgDirective result;

	char *position = strstr(comand, ".ORG");

	if (position != NULL) {
		result.line = toInteger(position+5);
		/* Valida o valor passado */
		if (result.line < 0) {
			printf("Diretiva ORG não pode receber um parâmetro negativo.\n");
			exit(1);
		}
		result.found = 1;
	} else {
		result.found = 0;
	}
	return result;
}

/**
  * Verifica se um comando é uma diretiva ALIGN e retorna a diretiva
  * 
  * comand: comando que vai ser interpretado
  */
AlignDirective alignDirective (char comand [MAX_STRING]) {
	AlignDirective result;

	char *position = strstr(comand, ".ALIGN");

	if (position != NULL) {
		result.multiple = toInteger(position+7);
		/* Valida o valor passado */
		if (result.multiple < 1) {
			printf("Diretiva ALIGN não pode receber um parâmetro negativo ou nulo.\n");
			exit(1);
		}
		result.found = 1;
	} else {
		result.found = 0;
	}
	return result;
}

/**
  * Verifica se um comando é uma diretiva WORD e retorna a diretiva
  * 
  * comand: comando que vai ser interpretado
  */
WordDirective wordDirective (char comand [MAX_STRING]) {
	WordDirective result;

	char *position = strstr(comand, ".WORD");

	if (position != NULL) {
		result.value = toInteger(position+6);
		result.found = 1;
	} else {
		result.found = 0;
	}
	return result;
}

/**
  * Verifica se um comando é uma diretiva WFILL e retorna a diretiva
  * 
  * comand: comando que vai ser interpretado
  */
WfillDirective wfillDirective (char comand [MAX_STRING]) {
	WfillDirective result;

	char *position = strstr(comand, ".WFILL");

	if (position != NULL) {
		result.lines = toInteger(position+7);
		result.value = toInteger(strstr(position+7," ")+1);
		/* Valida o valor passado */
		if (result.lines < 1) {
			printf("Diretiva wfill não pode receber um parâmetro negativo ou nulo.\n");
			exit(1);
		}
		result.found = 1;
	} else {
		result.found = 0;
	}
	return result;
}

/**
  * Verifica se um comando é uma diretiva SET e retorna a diretiva
  * 
  * comand: comando que vai ser interpretado
  */
SetDirective setDirective (char comand [MAX_STRING]) {
	SetDirective result;

	char *position = strstr(comand, ".SET");

	if (position != NULL) {
		result.label = malloc(sizeof(char) * MAX_STRING);
		memcpy(result.label, comand + 5, strstr(comand + 5, " ") - comand - 5);
		result.value = toInteger(strstr(comand + 5, " ") + 1);
		result.found = 1;
	} else {
		result.found = 0;
	}
	return result;
}

/**
  * Verifica se um comando é possui label e retorna a label do comando
  * 
  * comand: comando que vai ser interpretado
  */
Label label (char comand [MAX_STRING]) {
	Label result;

	char *position;
	position = strstr(comand, ":");

	if (position != NULL) {
		result.label = malloc(sizeof(char) * MAX_STRING);
		memcpy(result.label, comand, position - comand);
		result.found = 1;
	} else {
		result.found = 0;
	}
	return result;
}

/**
  * Insere um comando no vetor globbal dseridoe comandos
  * 
  * comand: comando que vai ser in
  */
void comand (char *instruction, Cursor cursor, int word) {
    comands[comandsLength].instruction = instruction;
    comands[comandsLength].cursor = cursor;
    comands[comandsLength].word = word;

    if (comands[comandsLength].instruction != NULL) {
        if (label(instruction).found) { /* Se o comando possuir uma label, insere-a no vetor de labels */
            labels[labelsLength].label = label(instruction).label;
            labels[labelsLength].comand = &comands[comandsLength];
            labelsLength++;
        }
        /* Limpa o comando */
        removeLabel(comands[comandsLength].instruction);
        trim(comands[comandsLength].instruction);   
    }

    comandsLength++;   
}

/**
  * Retorna o endereço de uma instrução
  * 
  * comand: comando que vai ser interpretado
  */
int address (Comand comand) { 
	if (strstr(comand.instruction,"(") != NULL) {
		return toInteger(strstr(comand.instruction,"(") + 1);	
	} else {
		return 0;
	}
}

/**
  * Retorna o opcode de um comando
  * 
  * comand: comando que vai ser interpretado
  */
int opcode (Comand comand) {
	Cursor labelCursor;

    /* Caso o endereço da instrução seja uma label, pegar o cursor da label */
	if (strstr(comand.instruction,"(") != NULL) {
		labelCursor = cursor(strstr(comand.instruction,"(") + 1);
	}

    /* Removo do comando tudo que vem depois do nome do comando */
	if (strstr(comand.instruction, " ") != NULL) {
		*strstr(comand.instruction, " ") = '\0';
	}

	if (strcmp(comand.instruction, "LMQ") == 0) {
		return 10;
	} else if (strcmp(comand.instruction, "LMQM") == 0) {
		return 9;
	} else if (strcmp(comand.instruction, "ST") == 0) {
		return 33;
	} else if (strcmp(comand.instruction, "LD") == 0) {
		return 1;
	} else if (strcmp(comand.instruction, "LDN") == 0) {
		return 2;
	} else if (strcmp(comand.instruction, "LDMOD") == 0) {
		return 3;
	} else if (strcmp(comand.instruction, "JMP") == 0) {
        if (labelCursor.side == LH) {
            return 13;
        } else if (labelCursor.side == RH) {
            return 14;
        } else {
            return 13;
        }
	} else if (strcmp(comand.instruction, "JMPP") == 0) {
        if (labelCursor.side == LH) {
            return 15;
        } else if (labelCursor.side == RH) {
            return 16;
        } else {
            return 15;
        }
	} else if (strcmp(comand.instruction, "ADD") == 0) {
		return 5;
	} else if (strcmp(comand.instruction, "ADDMOD") == 0) {
		return 7;
	} else if (strcmp(comand.instruction, "SUB") == 0) {
		return 6;
	} else if (strcmp(comand.instruction, "SUBMOD") == 0) {
		return 8;
	} else if (strcmp(comand.instruction, "MUL") == 0) {
		return 11;
	} else if (strcmp(comand.instruction, "DIV") == 0) {
		return 12;
	} else if (strcmp(comand.instruction, "LSH") == 0) {
		return 20;
	} else if (strcmp(comand.instruction, "RSH") == 0) {
		return 21;
	} else if (strcmp(comand.instruction, "STM") == 0) {
		if (labelCursor.side == LH) {
			return 18;
		} else if (labelCursor.side == RH) {
			return 19;
		} else {
            return 18;
        }
	}

	return 0;
}

/**
  * Pega uma matriz de chars e monta o vetor de comandos
  */
void parse () {
	int i,j;
	Cursor cursor;

    /* Iicio o cursor */
	cursor.line = 0;
	cursor.side = LH;
    /*
       Nesta parte do código, ocorre apenas uma triagem, calculando as linhas e lados das instruções
       e calculamos as labels e constantes
    */
	for (i = 0; i < MAX_INSTRUCTIONS; i++) {
        removeComment(instructions[i]);
        if (instructions[i][0]!='\0') {
    		if (orgDirective(instructions[i]).found) { /* Verifica se o comando é uma diretiva org */
                 /* Ajusto a posição do cursor */
    			cursor.line = orgDirective(instructions[i]).line;
    			cursor.side = LH;
    		} else if (alignDirective(instructions[i]).found) { /* Verifica se o comando é uma diretiva align */
                 /* Ajusto a posição do cursor */
    			cursor.line = cursor.line - (cursor.line % alignDirective(instructions[i]).multiple) + alignDirective(instructions[i]).multiple;
    			cursor.side = LH;
    		} else if (wordDirective(instructions[i]).found) {
                 /* Ajusto a posição do cursor */
    			if (cursor.side == RH) {
    				cursor.line ++;
    				cursor.side = LH;
    			}
                 /* Inserindo um comando do tipo word */
    			comand(instructions[i], cursor, -1);
    			cursor.line ++;
    		} else if (wfillDirective(instructions[i]).found) { /* Verifica se o comando é uma diretiva wfill */
                 /* Ajusto a posição do cursor */
    			if (cursor.side == RH) {
    				cursor.line ++;
    				cursor.side = LH;
    			}
                 /* Para cada posição do wfill insiro um comando do tipo word */
    			for (j = 0; j < wfillDirective(instructions[i]).lines; j++) {
    				comand(instructions[i], cursor, -1);
    				cursor.line++;
    			}
    		} else if (setDirective(instructions[i]).found) { /* Verifica se o comando é uma diretiva set */
                 /* Adiciono a constante ao vetor de constantes */
    			directives[directivesLength].label = setDirective(instructions[i]).label;
    			directives[directivesLength].value = setDirective(instructions[i]).value;
    			directivesLength++;
    		} else if (instructions[i][0] != '\0') { /* Verifica se o comando é uma instrução válida */
                /* Adiciono o comando */
    			comand(instructions[i], cursor, -1);
                if (comands[comandsLength - 1].instruction[0] != '\0') {
                     /* Ajusto a posição do cursor */
                    if (cursor.side == LH) {
                        cursor.side = RH;
                    } else {
                        cursor.side = LH;
                        cursor.line++;
                    }
                } else {
                    comandsLength--;
                }
    		}
        }
	}
    /*
       Após calculadas as linhas das intruções, as labels e constantes, podemos calcular os endereços
       ou palavras das instruções e o opcode das instruções
     */
	for (i = 0; i < comandsLength; i++) {
		if (wordDirective(comands[i].instruction).found) {
			comands[i].word = wordDirective(comands[i].instruction).value;
			comands[i].type = WORD;
		} else if (wfillDirective(comands[i].instruction).found) {
			comands[i].word = wfillDirective(comands[i].instruction).value;
			comands[i].type = WORD;
		} else if (comands[i].instruction[0] != '\0') {
            comands[i].type = INSTRUCTION;
			comands[i].address = address(comands[i]);
			comands[i].opcode  = opcode(comands[i]);
		}
	}
}

/**
  * Imprime em um arquivo o código montado
  * 
  * name: nome do arquivo que vai receber o código montado
  */
void print (char *name) {
    FILE *file;
    char word [MAX_STRING];
    int i;

    /* le o arquivo */
    if(!(file = fopen(name, "w"))) {
        printf("Arquivo não encontrado\n");
    } else {
        for (i = 0; i < comandsLength; i++) {
            /* Se for um comando à esquerda, imprime o número da linha */
            if (comands[i].cursor.side == LH) {
                fprintf(file, "%03X ", comands[i].cursor.line);
            }
            /* Verifica se é um comando normal */
            if (comands[i].type == INSTRUCTION) {
                sprintf(word, "%016X", comands[i].address);
                fprintf(file, "%02X%s", comands[i].opcode, word + 13);
            }
            /* Verifica se é um comando do tipo word*/
            if (comands[i].type == WORD) {
                sprintf(word, "%016llX", comands[i].word);
                fprintf(file, "%10s", word + 6);
            }
            /* Se na linha do comando não aparecer mais nenhum comando, imprimir 00000 */
            if (comands[i+1].cursor.side == LH && comands[i].cursor.side == LH && comands[i].type == INSTRUCTION) {
                fprintf(file, "00000");
            }
            /* Se o comando for o ultimo da linha, imprimir quebra de linha */
            if (comands[i+1].cursor.side == LH) {
                fprintf(file, "\n");
            }
        }
        fprintf(file, "\n");
        fclose(file);
    }
}

/**
  * Imprime a estrutura de dados para debug
  */
void dump () {
    char word [MAX_STRING];
    int i;

    for (i = 0; i < comandsLength; i++) {
        /* Verifica se é um comando normal */
        if (comands[i].type == INSTRUCTION) {
            sprintf(word, "%016X", comands[i].address);
            printf("%20s %03X %02X %s\n", comands[i].instruction, comands[i].cursor.line, comands[i].opcode, word + 13);
        }
        /* Verifica se é um comando do tipo word*/
        if (comands[i].type == WORD) {
            sprintf(word, "%016llX", comands[i].word);
            printf("%20s %03X %10s\n", comands[i].instruction, comands[i].cursor.line, word + 6);
        }
    }
}


/**
  * Le em um arquivo o código desmontado
  * 
  * name: nome do arquivo que vai entregar o código desmontado
  */
void scan (char *name) {
    FILE *file;
    char current;
    int status = 0;
    int i,j;

    /* Reseta a matriz de entrada */
    for (i = 0; i < MAX_INSTRUCTIONS; i++) {
        for (j = 0; j < MAX_STRING; j++) {
            instructions[i][j] = '\0';
        }
    }

    /* le o arquivo */
    if(!(file = fopen(name, "r+"))) {
        printf("Arquivo não encontrado\n");
    } else {
        i = 0;
        j = 0;
        while(status > -1) {
            status = fscanf(file, "%c", &current);
            if (current == '\n' || status == -1) {
                i++;
                j = 0;
            } else {
                if (current >= 'a' && current <= 'z') {
                    current = current - 'a' + 'A';
                }
                instructions[i][j] = current;
                j++;
            }
        }
    }
}

int main (int argc, char *argv[] ) {
    scan(argv[1]);
	parse();
    //dump();
    print(argv[2]);

	return 0;
}
