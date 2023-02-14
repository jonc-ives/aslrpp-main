#include <stdio.h>
#include "sum.h"

int array[4] = {1, 2, 3, 4};

int main()
{
	int s = 0;
	s = sum(array, 4);
	printf("%d\n", s);
	return 0;
}

