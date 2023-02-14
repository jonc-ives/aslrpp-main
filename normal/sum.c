int sum(int* array, int cnt)
{
	int s = 0;
	for (int i = 0; i < cnt; i++)
		s += array[i];
	return s;
}
