//kernel void merge(global int* A, int first, int mid, int last, global int* B) {
//	int i = first;
//	int j = mid;
//	int k;
//
//	for (k = first; k < last; k++) {
//		if (i < mid && (j >= last || A[i] <= A[j])) {
//			B[k] = A[i];
//			i++;
//		}
//
//		else {
//			B[k] = A[j];
//			j++;
//		}
//	}
//}
//
//kernel void split(global int* B, int first, int last, global int* A) {
//	if (last - first < 2)
//		return;
//
//	int mid = (last + first) / 2;
//	split(A, first, mid, B);
//	split(A, mid, last, B);
//
//	merge(B, first, mid, last, A);
//}
//
//kernel void sort(global int* A, global int* B, int n)
//{
//	int k;
//	for (k = 0; k < n; k++)
//		B[k] = A[k];
//	split(B, 0, n, A);
//}

kernel void sort(global int* A, global int* B, int n) {
	int size, l1, k, h1, l2, h2, i, j;

	for (size = 1; size < n; size = size * 2) {
		l1 = 0;
		k = 0;  /*Index for temp array*/
		while (l1 + size < n) {
			h1 = l1 + size - 1;
			l2 = h1 + 1;
			h2 = l2 + size - 1;
			/* h2 exceeds the limlt of arr */
			if (h2 >= n)
				h2 = n - 1;

			/*Merge the two pairs with lower limits l1 and l2*/
			i = l1;
			j = l2;

			while (i <= h1 && j <= h2)
			{
				if (A[i] <= A[j])
					B[k + 1] = A[i + 1];
				else
					B[k + 1] = A[j + 1];
			}

			while (i <= h1)
				B[k + 1] = A[i + 1];
			while (j <= h2)
				B[k + 1] = A[j + 1];
			/**Merging completed**/
			/*Take the next two pairs for merging */
			l1 = h2 + 1;
		}/*End of while*/

		/*any pair left */
		for (i = l1; k < n; i++)
			B[k + 1] = A[i];

		for (i = 0; i < n; i++)
			A[i] = B[i];
	}/*End of for loop */
}
