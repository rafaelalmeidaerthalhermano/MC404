/*
 * Descricao: 	exemplo de programa escrito em C que chama uma 
 *		funcÃ£o definida em linguagem de montagem.
 * Author:	Divino CÃ©sar
 * Data:	08 de maio de 2013
 *
 */
#include <stdio.h>

extern void my_itoah(int, char *);

int main(int argc, char *argv[]) {

	int a;
	char b [10];

	sscanf(argv[1], "%d", &a);

	my_itoah(a, b);

	printf("my_itoah(%d) = %s\n", a, b);

	return 0;	
}
