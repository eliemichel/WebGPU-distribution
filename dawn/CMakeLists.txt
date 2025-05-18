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

set(DAWN_VERSION "7187" CACHE STRING "\
	Version of the Dawn release to use. Must correspond to the number after 'chromium/' \
	in the tag name of an existing release on DAWN_MIRROR. \
	Warning: The webgpu.hpp file provided in include/ may not be compatible with other \
	versions than the default.")

set(DAWN_SOURCE_MIRROR "https://dawn.googlesource.com/dawn" CACHE STRING "\
	The repository where to find Dawn source code.")

set(DAWN_BINARY_MIRROR "https://github.com/eliemichel/dawn-prebuilt" CACHE STRING "\
	The repository where to find Dawn precompiled releases. This is ultimately supposed \
	to be https://github.com/google/dawn, where official binaries will be auto-released, \
	but in the meantime we use a different mirror.")

if (WEBGPU_BUILD_FROM_SOURCE)
	include(FetchDawnSource.cmake)
else()
	include(FetchDawnPrecompiled.cmake)
endif()
