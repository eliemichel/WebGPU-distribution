# This file is part of the "Learn WebGPU for C++" book.
#   https://eliemichel.github.io/LearnWebGPU
# 
# MIT License
# Copyright (c) 2022-2024 Elie Michel and the wgpu-native authors
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

message(STATUS "Using emscripten backend for WebGPU")

# When using emscripten, we do not download any WebGPU implementation
# because emscripten will convert all calls to the WebGPU API into their
# equivalent JavaScript counterpart, and the actual implementation is
# provided by the client's Web browser (it is not shipped with our WASM
# module).

add_library(webgpu INTERFACE)

# Add include path to webgpu.hpp
target_include_directories(webgpu INTERFACE
	"${CMAKE_CURRENT_SOURCE_DIR}/include"
)

# This is used to advertise the flavor of WebGPU that this zip provides
target_compile_definitions(webgpu INTERFACE WEBGPU_BACKEND_EMSCRIPTEN)

target_link_options(webgpu INTERFACE
    -sUSE_WEBGPU # Handle WebGPU symbols when linking
)

# There is no dll/so/dylib to copy in this case
function(target_copy_webgpu_binaries Target)
endfunction()
