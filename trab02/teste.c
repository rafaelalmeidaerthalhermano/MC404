/*
 * Descricao: 	exemplo de programa escrito em C que chama uma 
 *		funcÃ£o definida em linguagem de montagem.
 * Author:	Divino CÃ©sar
 * Data:	08 de maio de 2013
 *
 */
#include <stdio.h>

extern int my_div(int, int);

int main(int argc, char *argv[]) {

	int a,b;

	sscanf(argv[1], "%d", &a);
	sscanf(argv[2], "%d", &b);

	int res = my_div(a, b);

	printf("my_div(%d, %d) = %d\n", a, b, res);

	return 0;	
}
