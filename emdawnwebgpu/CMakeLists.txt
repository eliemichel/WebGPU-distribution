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

# When using emscripten, we do not download any WebGPU implementation
# because emscripten will convert all calls to the WebGPU API into their
# equivalent JavaScript counterpart, and the actual implementation is
# provided by the client's Web browser (it is not shipped with our WASM
# module).

# Using emdawnwebgpu means to download just the little component that tells
# emscripten how to compile WebGPU functions. This component is called a port
# and we get it from Dawn's repository.

set(EMDAWNWEBGPU_VERSION "v20250517.163311" CACHE STRING "\
	Version of the emdawnwebgpu to use. Must correspond to a valid tag on \
	EMDAWNWEBGPU_MIRROR. \
	Warning: The webgpu.hpp file provided in include/ may not be compatible with other \
	versions than the default.")

set(EMDAWNWEBGPU_MIRROR "https://github.com/google/dawn" CACHE STRING "\
	The repository where to find emdawnwebgpu precompiled releases.")

#################################################
# Fetch emdawnwebgpu port

include(FetchContent)

# Declare FetchContent, then make available
set(URL "${EMDAWNWEBGPU_MIRROR}/releases/download/${EMDAWNWEBGPU_VERSION}/emdawnwebgpu_pkg-${EMDAWNWEBGPU_VERSION}.zip")
set(FC_NAME "emdawnwebgpu")
FetchContent_Declare(${FC_NAME}
	URL ${URL}
)
# TODO: Display the "Fetching" message only when actually downloading
message(STATUS "Fetching emdawnwebgpu port from '${URL}'")
FetchContent_MakeAvailable(${FC_NAME})
set(emdawnwebgpu_ROOT "${${FC_NAME}_SOURCE_DIR}")

#################################################
# Define 'webgpu' target

add_library(webgpu INTERFACE)

# This is used to advertise the flavor of WebGPU that this zip provides
target_compile_definitions(webgpu INTERFACE WEBGPU_BACKEND_EMDAWNWEBGPU)

# Add include path to webgpu.hpp
target_include_directories(webgpu INTERFACE
	"${CMAKE_CURRENT_SOURCE_DIR}/include"
)

target_compile_options(webgpu INTERFACE
	"--use-port=${emdawnwebgpu_ROOT}/emdawnwebgpu.port.py"
)

target_link_options(webgpu INTERFACE
	"--use-port=${emdawnwebgpu_ROOT}/emdawnwebgpu.port.py"
	"--closure-args=--externs=${emdawnwebgpu_ROOT}/webgpu/src/webgpu-externs.js"
)

# There is no dll/so/dylib to copy in this case
function(target_copy_webgpu_binaries Target)
endfunction()
