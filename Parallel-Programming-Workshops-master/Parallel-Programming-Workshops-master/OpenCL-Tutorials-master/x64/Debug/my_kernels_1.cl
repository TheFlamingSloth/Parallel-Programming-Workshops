kernel void merge(global int* A, int first, int mid, int last, global int* B) {
	int i = first;
	int j = mid;
	int k;

	for (k = first; k < last; k++) {
		if (i < mid && (j >= last || A[i] <= A[j])) {
			B[k] = A[i];
			i++;
		}

		else {
			B[k] = A[j];
			j++;
		}
	}
}

kernel void split(global int* B, int first, int last, global int* A) {
	if (last - first < 2)
		return;

	int mid = (last + first) / 2;
	split(A, first, mid, B);
	split(A, mid, last, B);

	merge(B, first, mid, last, A);
}

kernel void sort(global int* A, global int* B, int n)
{
	int k;
	for (k = 0; k < n; k++)
		B[k] = A[k];
	split(B, 0, n, A);
}
