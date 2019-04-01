#ifndef QUICKSELECT_H
#define QUICKSELECT_H

#include <assert.h>

/*
 * http://ndevilla.free.fr/median/median/index.html
 * http://ndevilla.free.fr/median/median/src/quickselect.c
 * https://github.com/MythTV/mythtv/blob/master/mythtv/programs/mythcommflag/quickselect.c
 *
 *  This Quickselect routine is based on the algorithm described in
 *  "Numerical recipes in C", Second Edition,
 *  Cambridge University Press, 1992, Section 8.5, ISBN 0-521-43108-5
 *  This code by Nicolas Devillard - 1998. Public domain.
 */

#define ELEM_SWAP(elem_type, a, b) { elem_type t=(a); (a)=(b); (b)=t; }

#define QUICK_SELECT(elem_type)												\
elem_type quick_select_ ## elem_type (elem_type arr[], int n, int select)	\
{																			\
	assert(arr && n > 0 && select > 0);										\
	int low, high;															\
	int middle, ll, hh;														\
																			\
	low = 0;																\
	high = n - 1;															\
	for (;;)																\
	{																		\
		if (high <= low)													\
		{ /* One element only */											\
			return arr[select];												\
		}																	\
																			\
		if (high == low + 1)												\
		{ /* Two elements only */											\
			if (arr[low] > arr[high])										\
			{																\
				ELEM_SWAP(elem_type, arr[low], arr[high]);					\
			}																\
			return arr[select];												\
		}																	\
																			\
		/* Find median of low, middle and high items; swap into position low */	\
		middle = (low + high) / 2;											\
		if (arr[middle] > arr[high])										\
		{																	\
			ELEM_SWAP(elem_type, arr[middle], arr[high]);					\
		}																	\
		if (arr[low] > arr[high])											\
		{																	\
			ELEM_SWAP(elem_type, arr[low], arr[high]);						\
		}																	\
		if (arr[middle] > arr[low])											\
		{																	\
			ELEM_SWAP(elem_type, arr[middle], arr[low]);					\
		}																	\
																			\
		/* Swap low item (now in position middle) into position (low+1) */	\
		ELEM_SWAP(elem_type, arr[middle], arr[low + 1]);					\
																			\
		/* Nibble from each end towards middle, swapping items when stuck */\
		ll = low + 1;														\
		hh = high;															\
		for (;;)															\
		{																	\
			do ll++; while (arr[low] > arr[ll]);							\
			do hh--; while (arr[hh] > arr[low]);							\
																			\
			if (hh < ll) break;												\
																			\
			ELEM_SWAP(elem_type, arr[ll], arr[hh]);							\
		}																	\
																			\
		/* Swap middle item (in position low) back into correct position */	\
		ELEM_SWAP(elem_type, arr[low], arr[hh]);							\
																			\
		/* Re-set active partition */										\
		if (hh <= select)													\
		{																	\
			low = ll;														\
		}																	\
		if (hh >= select)													\
		{																	\
			high = hh - 1;													\
		}																	\
	}																		\
}

//#undef ELEM_SWAP
#endif // QUICKSELECT_H
