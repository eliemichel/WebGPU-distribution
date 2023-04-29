cmake_minimum_required(VERSION 3.0.0...3.24 FATAL_ERROR)
project(webgpu-backend-emscripten VERSION 1.0.0)

message(STATUS "Using emscripten backend for WebGPU")

add_library(webgpu INTERFACE)

target_include_directories(webgpu INTERFACE
	"${CMAKE_CURRENT_SOURCE_DIR}/include"
)

target_compile_definitions(webgpu INTERFACE WEBGPU_BACKEND_EMSCRIPTEN)

function(target_copy_webgpu_binaries Target)
endfunction()
