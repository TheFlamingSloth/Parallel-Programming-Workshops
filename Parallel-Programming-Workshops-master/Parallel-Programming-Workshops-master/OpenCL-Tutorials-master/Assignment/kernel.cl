kernel void sort(A[], B[], n)
{
	copy(A, 0, n, B);
	split(B, 0, n, A);
}

kernel void split(B[], first, last, A[]) {
	if (last - first < 2)
		return;

	mid = (last + first) / 2;
	split(A, first, mid, B);
	split(A, mid, last, B);

	merge(B, first, mid, last, A);
}

kernel void merge(A[], first, mid, last, B[]) {
	i = first;
	j = mid;

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

kernel void copy(A[], first, last, B[]) {
	for (k = first; k < last; k++)
		B[k] = A[k];
}