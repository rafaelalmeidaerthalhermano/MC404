/*
 * Descricao: 	exemplo de programa escrito em C que chama uma 
 *		funcÃ£o definida em linguagem de montagem.
 * Author:	Divino CÃ©sar
 * Data:	08 de maio de 2013
 *
 */
#include <stdio.h>

extern int my_atoi_head(char *, char *);

int main(int argc, char *argv[]) {

	int res = my_atoi_head(argv[1]);

	printf("my_atoi_head(%s) = %d\n", argv[1], res);

	return 0;	
}
