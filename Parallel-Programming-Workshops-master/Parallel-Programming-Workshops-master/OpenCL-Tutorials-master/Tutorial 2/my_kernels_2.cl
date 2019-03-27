//a simple OpenCL kernel which copies all pixels from A to B
kernel void identity(global const uchar4* A, global uchar4* B) {
	int id = get_global_id(0);
	B[id] = A[id];
}

//simple 2D identity kernel
kernel void identity2D(global const uchar4* A, global uchar4* B) {
	int x = get_global_id(0);
	int y = get_global_id(1);
	int width = get_global_size(0); //width in pixels
	int id = x + y*width;
	B[id] = A[id];
}

//2D averaging filter
kernel void avg_filter2D(global const uchar4* A, global uchar4* B) {
	int x = get_global_id(0);
	int y = get_global_id(1);
	int width = get_global_size(0); //width in pixels
	int id = x + y*width;

	uint4 result = (uint4)(0);//zero all 4 components

	for (int i = (x-1); i <= (x+1); i++)
	for (int j = (y-1); j <= (y+1); j++) 
		result += convert_uint4(A[i + j*width]); //convert pixel values to uint4 so the sum can be larger than 255

	result /= (uint4)(9); //normalise all components (the result is a sum of 9 values) 

	B[id] = convert_uchar4(result); //convert back to uchar4 
}

//2D 3x3 convolution kernel
kernel void convolution2D(global const uchar4* A, global uchar4* B, constant float* mask) {
	int x = get_global_id(0);
	int y = get_global_id(1);
	int width = get_global_size(0); //width in pixels
	int id = x + y*width;

	float4 result = (float4)(0.0f,0.0f,0.0f,0.0f);//zero all 4 components

	for (int i = (x-1); i <= (x+1); i++)
	for (int j = (y-1); j <= (y+1); j++)
		result += convert_float4(A[i + j*width])*(float4)(mask[i-(x-1) + (j-(y-1))*3]);//convert pixel and mask values to float4

	B[id] = convert_uchar4(result); //convert back to uchar4
}

//red colour filter
kernel void filter_r(global const uchar4* A, global const uchar4* B) {
	int x = get_global_id(0);
	int y = get_global_id(1);
	int width = get_global_size(0); //width in pixels
	int id = x + y * width;

	B[id].x = A[id].x;
	B[id].y = 0;
	B[id].z = 0;
	B[id].w = 0;
}

kernel void invert(global const uchar4* A, global const uchar4* B) {
	int x = get_global_id(0);
	int y = get_global_id(1);
	int width = get_global_size(0); //width in pixels
	int id = x + y * width;

	B[id].x = 255 - A[id].x;
	B[id].y = 255 - A[id].y;
	B[id].z = 255 - A[id].z;
	B[id].w = 255 - A[id].w;
}

kernel void rgb2grey(global const uchar4* A, global const uchar4* B) {
	int x = get_global_id(0);
	int y = get_global_id(1);
	int width = get_global_size(0); //width in pixels
	int id = x + y * width;
	double sum;

	sum = (0.2126 * A[id].x) + (0.7152 * A[id].y) + (0.0722 * A[id].z);
	B[id].x = sum;
	B[id].y = sum;
	B[id].z = sum;
	B[id].w = A[id].w;
}