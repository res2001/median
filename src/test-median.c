/*
 ============================================================================
 Name        : test-median.c
 Author      : res
 Version     :
 Copyright   : 
 Description : Test quick_select() and compare it with finding the median using quicksort().
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <inttypes.h>
#include <string.h>
#include <assert.h>

#include "quickselect.h"

QUICK_SELECT(float) // @suppress("No return")

static int compare_float(const float * a, const float * b)
{
	const float r = *a - *b;
	if(r < 0.f)
		return -1;
	if(r > 0.f)
		return 1;
	return 0;
}

float select_with_qsort(float * arr, int n, int select)
{
	assert(arr && n > 0);
	qsort(arr, n, sizeof(*arr), (int(*)(const void*, const void*))compare_float);
	return arr[select];
}

// Random number generation in the range [0., 1.)
#define GETRND_F		( (float)( (((double)rand())) / (((double)RAND_MAX) + 1.) ) )

#define NUMBER_OF_CYCLE		1000

int main(void)
{
	const int sizes[] = { 100, 151, 250, 311, 512, 777, 1024, 4443, 8192, 12333, 16384, 25555, 32768 };
	const int N = sizeof(sizes) / sizeof(sizes[0]);
	float * arr, * arr1, * arr2;
	float m1, m2;
	float ts1, ts2;
	clock_t t1, t2;

	srand(time(NULL));

	for(int i = 0; i < N; ++i)
	{
		arr = malloc(sizeof(*arr) * sizes[i] * 3);
		if(!arr)
		{
			fputs("Not enough memory.", stderr);
			return 1;
		}
		arr1 = arr + sizes[i];
		arr2 = arr1 + sizes[i];

		for(int j = 0; j < sizes[i]; ++j)
		{
			arr[j] = GETRND_F;
		}

		ts1 = ts2 = 0.f;
		int is_not_equal = 0;

		printf("Array size: %d  \n", sizes[i]);
		for(int j = 0; j < NUMBER_OF_CYCLE; ++j)
		{
			memcpy(arr1, arr, sizeof(*arr) * sizes[i]);
			memcpy(arr2, arr, sizeof(*arr) * sizes[i]);

			t1 = clock();
			m1 = quick_select_float(arr1, sizes[i], sizes[i] / 2);
			t1 = clock() - t1;

			t2 = clock();
			m2 = select_with_qsort(arr2, sizes[i], sizes[i] / 2);
			t2 = clock() - t2;

			ts1 += (float)t1 / CLOCKS_PER_SEC;
			ts2 += (float)t2 / CLOCKS_PER_SEC;

			if(m1 != m2)
			{
				is_not_equal = 1;
			}

		}
		printf("Average time for quick_select(): %.3f sec.  \n", ts1);
		printf("Average time for median_with_qsort(): %.3f sec.\n", ts2);
		if(is_not_equal)
		{
			printf("Median1 not equal median2! m1 = %f\tm2 = %f  \n", m1, m2);
		}
		putchar('\n');
		fflush(stdin);
		free(arr);
	}
	return EXIT_SUCCESS;
}
