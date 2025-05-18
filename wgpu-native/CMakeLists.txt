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

set(WGPU_VERSION "v24.0.3.1" CACHE STRING "\
	Version of the wgpu-native WebGPU implementation to use. Must correspond \
	to the tag name of an existing release on https://github.com/gfx-rs/wgpu-native/releases. \
	Warning: The webgpu.hpp file provided in include/ may not be compatible with other versions.")

set(WGPU_BINARY_MIRROR "https://github.com/gfx-rs/wgpu-native" CACHE STRING "\
	The repository where to find precompiled releases of wgpu-native.")

if (WEBGPU_BUILD_FROM_SOURCE)
	message(FATAL_ERROR "Building wgpu-native from source is not available. Either switch to Dawn (WEBGPU_BACKEND=DAWN) or use precompiled binaries (WEBGPU_BUILD_FROM_SOURCE=OFF).")
else()
	include(FetchWgpuNativePrecompiled.cmake)
endif()
