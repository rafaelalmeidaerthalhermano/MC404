/*
 * Descricao: 	exemplo de programa escrito em C que chama uma 
 *		funcÃ£o definida em linguagem de montagem.
 * Author:	Divino CÃ©sar
 * Data:	08 de maio de 2013
 *
 */
#include <stdio.h>

extern void my_itoa(int, char *);

int main(int argc, char *argv[]) {

	int a;
	char *b;

	sscanf(argv[1], "%d", &a);

	my_itoa(a, b);

	printf("my_itoa(%d) = %s\n", a, b);

	return 0;	
}
