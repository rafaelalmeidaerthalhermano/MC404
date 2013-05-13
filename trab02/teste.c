/*
 * Descricao: 	exemplo de programa escrito em C que chama uma 
 *		funcÃ£o definida em linguagem de montagem.
 * Author:	Divino CÃ©sar
 * Data:	08 de maio de 2013
 *
 */
#include <stdio.h>

extern void my_itoa(int, char *);

//extern int my_atoi(char *);

int main(int argc, char *argv[]) {
/*
	int result = my_atoi(argv[1]);

	printf("my_atoi(%s) = %d\n", argv[1], result);
*/

	int a;
	char b [10];

	sscanf(argv[1], "%d", &a);

	my_itoa(a, b);

	printf("my_itoa(%d) = %s\n", a, b);

	return 0;	

}
