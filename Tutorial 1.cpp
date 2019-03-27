#define CL_USE_DEPRECATED_OPENCL_1_2_APIS
#define __CL_ENABLE_EXCEPTIONS

#include <iostream>
#include <vector>

#ifdef __APPLE__
#include <OpenCL/cl.hpp>
#else
#include <CL/cl.hpp>
#endif

#include "Utils.h"

void print_help() {
	std::cerr << "Application usage:" << std::endl;

	std::cerr << "  -p : select platform " << std::endl;
	std::cerr << "  -d : select device" << std::endl;
	std::cerr << "  -l : list all platforms and devices" << std::endl;
	std::cerr << "  -h : print this message" << std::endl;
}

int main(int argc, char **argv) {
	//Part 1 - handle command line options such as device selection, verbosity, etc.
	int platform_id = 0;
	int device_id = 0;

	for (int i = 1; i < argc; i++) {
		if ((strcmp(argv[i], "-p") == 0) && (i < (argc - 1))) { platform_id = atoi(argv[++i]); }
		else if ((strcmp(argv[i], "-d") == 0) && (i < (argc - 1))) { device_id = atoi(argv[++i]); }
		else if (strcmp(argv[i], "-l") == 0) { std::cout << ListPlatformsDevices() << std::endl; }
		else if (strcmp(argv[i], "-h") == 0) { print_help(); return 0; }
	}

	//detect any potential exceptions
	try {
		//Part 2 - host operations
		//2.1 Select computing devices
		cl::Context context = GetContext(platform_id, device_id);

		//display the selected device
		std::cout << "Running on " << GetPlatformName(platform_id) << ", " << GetDeviceName(platform_id, device_id) << std::endl;

		//create a queue to which we will push commands for the device
		cl::CommandQueue queue(context);

		//2.2 Load & build the device code
		cl::Program::Sources sources;

		AddSources(sources, "my_kernels_1.cl");

		cl::Program program(context, sources);

		//build and debug the kernel code
		try {
			program.build();
		}
		catch (const cl::Error& err) {
			std::cout << "Build Status: " << program.getBuildInfo<CL_PROGRAM_BUILD_STATUS>(context.getInfo<CL_CONTEXT_DEVICES>()[0]) << std::endl;
			std::cout << "Build Options:\t" << program.getBuildInfo<CL_PROGRAM_BUILD_OPTIONS>(context.getInfo<CL_CONTEXT_DEVICES>()[0]) << std::endl;
			std::cout << "Build Log:\t " << program.getBuildInfo<CL_PROGRAM_BUILD_LOG>(context.getInfo<CL_CONTEXT_DEVICES>()[0]) << std::endl;
			throw err;
		}

		//Part 3 - memory allocation
		//host - input
		std::vector<int> A = { 9, 4, 5, 2, 7, 8, 1, 3, 6, 0 }; //C++11 allows this type of initialisation
		std::vector<int> B = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

		size_t vector_elements = A.size();//number of elements
		size_t vector_size = A.size() * sizeof(int);//size in bytes

		//host - output
		std::vector<int> C(vector_elements);

		//device - buffers
		cl::Buffer buffer_A(context, CL_MEM_READ_WRITE, vector_size);
		cl::Buffer buffer_B(context, CL_MEM_READ_WRITE, vector_size);

		//Part 4 - device operations

		//4.1 Copy arrays A and B to device memory
		queue.enqueueWriteBuffer(buffer_A, CL_TRUE, 0, vector_size, &A[0]);
		queue.enqueueWriteBuffer(buffer_B, CL_TRUE, 0, vector_size, &B[0]);

		//4.2 Setup and execute the kernel (i.e. device code)
		cl::Kernel kernel_sort = cl::Kernel(program, "sort");
		kernel_sort.setArg(0, buffer_A);
		kernel_sort.setArg(1, buffer_B);
		kernel_sort.setArg(2, vector_elements);
		
		queue.enqueueNDRangeKernel(kernel_sort, cl::NullRange, cl::NDRange(vector_elements), cl::NullRange);
		
		//4.3 Copy the result from device to host
		std::cout << "here!" << std::endl;
		//queue.enqueueReadBuffer(buffer_B, CL_TRUE, 0, vector_size, &B[0]);
		std::cout << "past it!" << std::endl;

		std::cout << "A = " << A << std::endl;
		std::cout << "B = " << B << std::endl;

		//Excercise Code
		//cl::CommandQueue queue1(context, CL_QUEUE_PROFILING_ENABLE);

		//cl::Event prof_event;
		/*queue1.enqueueNDRangeKernel(kernel_add, cl::NullRange, cl::NDRange(vector_elements), cl::NullRange, NULL, &prof_event);

		std::cout << "Kernel execution time [ns]:" << prof_event.getProfilingInfo<CL_PROFILING_COMMAND_END>() - prof_event.getProfilingInfo<CL_PROFILING_COMMAND_START>() << std::endl;
		std::cout << GetFullProfilingInfo(prof_event, ProfilingResolution::PROF_US) << endl;*/
		//queue.enqueueWriteBuffer(buffer_A, CL_TRUE, 0, vector_size, &A[0], NULL, &A_event);

		//mult code
		/*cl::Kernel kernel_mult = cl::Kernel(program, "mult");

		kernel_mult.setArg(0, buffer_A);
		kernel_mult.setArg(1, buffer_B);
		kernel_mult.setArg(2, buffer_C);

		kernel_add.setArg(0, buffer_C);

		queue.enqueueNDRangeKernel(kernel_mult, cl::NullRange, cl::NDRange(vector_elements), cl::NullRange);
		queue.enqueueNDRangeKernel(kernel_add, cl::NullRange, cl::NDRange(vector_elements), cl::NullRange);

		queue.enqueueReadBuffer(buffer_C, CL_TRUE, 0, vector_size, &C[0]);

		std::cout << "A = " << A << std::endl;
		std::cout << "B = " << B << std::endl;
		std::cout << "C = " << C << std::endl;*/

		//cl::Device device = context.getInfo<CL_CONTEXT_DEVICES>()[0]; //get device
		//std::cerr << kernel_add.getWorkGroupInfo<CL_KERNEL_PREFERRED_WORK_GROUP_SIZE_MULTIPLE>(device) << std::endl; //get info
		//std::cerr << kernel_add.getWorkGroupInfo<CL_KERNEL_WORK_GROUP_SIZE>(device) << std::endl;
	}
	catch (cl::Error err) {
		std::cerr << "ERROR: " << err.what() << ", " << getErrorString(err.err()) << std::endl;
	}

	return 0;
}