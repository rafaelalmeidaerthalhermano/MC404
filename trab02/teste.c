/*
 * Descricao: 	exemplo de programa escrito em C que chama uma 
 *		funcÃ£o definida em linguagem de montagem.
 * Author:	Divino CÃ©sar
 * Data:	08 de maio de 2013
 *
 */
#include <stdio.h>

extern int my_strcmp(char *, char *);

int main(int argc, char *argv[]) {

	int res = my_strcmp(argv[1], argv[2]);

	printf("my_strcmp(%s, %s) = %d\n", argv[1], argv[2], res);

	return 0;	
}
