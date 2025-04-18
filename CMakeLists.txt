# This file is part of the "Learn WebGPU for C++" book.
#   https://eliemichel.github.io/LearnWebGPU
# 
# MIT License
# Copyright (c) 2022-2025 Elie Michel and the wgpu-native authors
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

cmake_minimum_required(VERSION 3.0.0...3.24 FATAL_ERROR)
project(webgpu VERSION 1.0.0)

if (EMSCRIPTEN)
	set(WEBGPU_BACKEND_DEFAULT "EMDAWNWEBGPU")
else()
	set(WEBGPU_BACKEND_DEFAULT "WGPU")
endif()

set(WEBGPU_BACKEND ${WEBGPU_BACKEND_DEFAULT} CACHE STRING "\
	Backend implementation of WebGPU. Possible values are EMSCRIPTEN, EMDAWNWEBGPU, WGPU and DAWN \
	(it does not matter when using emcmake)")
set_property(CACHE WEBGPU_BACKEND PROPERTY STRINGS EMSCRIPTEN EMDAWNWEBGPU WGPU DAWN)

option(WEBGPU_BUILD_FROM_SOURCE "\
	When ON, fetch the source code of the backend and build it. \
	When OFF, fetch a precompiled version of the backend." OFF)

set(WEBGPU_LINK_TYPE "SHARED" CACHE STRING "\
	Whether the WebGPU implementation must be statically or dynamically linked. \
	Possible values are STATIC and SHARED, though not all combinations of options \
	are valid.")
set_property(CACHE WEBGPU_LINK_TYPE PROPERTY STRINGS SHARED STATIC)

# NB: There are also backend-specific options in <backend>/CMakeLists.txt

if (TARGET webgpu)
	message(STATUS "Target 'webgpu' already exists.")
	return()
endif()

# A couple of utility functions
include("${CMAKE_CURRENT_LIST_DIR}/cmake/utils.cmake")

# Convert to uppercase, so that users can provide value with any case they like
string(TOUPPER ${WEBGPU_BACKEND} WEBGPU_BACKEND_U)

if (WEBGPU_BACKEND_U STREQUAL "EMSCRIPTEN")

	if (NOT EMSCRIPTEN)
		message(FATAL_ERROR "Setting WEBGPU_BACKEND to EMSCRIPTEN is only compatible with emscripten compiler. Try WGPU or DAWN instead.")
	endif()
	add_subdirectory(emscripten)

elseif (WEBGPU_BACKEND_U STREQUAL "EMDAWNWEBGPU")

	if (NOT EMSCRIPTEN)
		message(FATAL_ERROR "Setting WEBGPU_BACKEND to EMDAWNWEBGPU is only compatible with emscripten compiler. Try WGPU or DAWN instead.")
	endif()
	add_subdirectory(emdawnwebgpu)

elseif (WEBGPU_BACKEND_U STREQUAL "WGPU")

	if (EMSCRIPTEN)
		message(FATAL_ERROR "Setting WEBGPU_BACKEND to WGPU is not compatible with emscripten compiler. Try EMSCRIPTEN or EMDAWNWEBGPU instead.")
	endif()
	add_subdirectory(wgpu-native)

elseif (WEBGPU_BACKEND_U STREQUAL "DAWN")

	if (EMSCRIPTEN)
		message(FATAL_ERROR "Setting WEBGPU_BACKEND to DAWN is not compatible with emscripten compiler. Try EMSCRIPTEN or EMDAWNWEBGPU instead.")
	endif()
	add_subdirectory(dawn)

else()

	message(FATAL_ERROR "Invalid value for WEBGPU_BACKEND: possible values are EMSCRIPTEN, WGPU, end DAWN, but '${WEBGPU_BACKEND_U}' was provided.")

endif()
