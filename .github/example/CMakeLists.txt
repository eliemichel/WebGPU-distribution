cmake_minimum_required(VERSION 3.14...3.24 FATAL_ERROR)
project(Test-WebGPU-Distribution VERSION 1.0.0)

add_subdirectory(../../webgpu webgpu)

add_executable(test)
target_sources(test PRIVATE main.cpp)
target_link_libraries(test PRIVATE webgpu)
target_copy_webgpu_binaries(test)
