#define WEBGPU_CPP_IMPLEMENTATION
#include <webgpu/webgpu.h>
#include <webgpu/webgpu.hpp>
#include <iostream>


int main(int, char**) {
	std::cout << "Hello, WebGPU!" << std::endl;

	wgpu::InstanceDescriptor desc = wgpu::Default;
	wgpu::Instance instance = wgpu::createInstance(desc);

	std::cout << "instance = " << instance << std::endl;

	return instance == nullptr ? 1 : 0;
}
