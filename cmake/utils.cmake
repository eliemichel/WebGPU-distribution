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

# Target architecture detection (thank you CMake for not providing that...)
function(detect_system_architecture)
	if (NOT ARCH)
		set(SYSTEM_PROCESSOR ${CMAKE_SYSTEM_PROCESSOR})
		if (SYSTEM_PROCESSOR STREQUAL "AMD64" OR SYSTEM_PROCESSOR STREQUAL "x86_64")
			if (CMAKE_SIZEOF_VOID_P EQUAL 8)
				set(ARCH "x86_64")
			elseif (CMAKE_SIZEOF_VOID_P EQUAL 4)
				set(ARCH "i686")
			endif()
		elseif (SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64|armv8|arm)$")
			set(ARCH "aarch64")
		elseif(SYSTEM_PROCESSOR MATCHES "^(armv7|armv6|armhf)$")
			set(ARCH "arm")
		else()
			message(WARNING "Unknown architecture: ${SYSTEM_PROCESSOR}")
			set(ARCH "unknown")
		endif()
	endif()
	set(ARCH "${ARCH}" PARENT_SCOPE)
endfunction()

# Create the name of the static or shared library file given the target system.
function(build_lib_filename OUT_VAR LIB_NAME USE_SHARED_LIB)
	set(STATIC_LIB_EXT)
	set(SHARED_LIB_EXT)
	set(STATIC_LIB_PREFIX)
	set(SHARED_LIB_PREFIX)

	if (CMAKE_SYSTEM_NAME STREQUAL "Windows")

		set(SHARED_LIB_EXT "dll")
		if (MSVC)
			set(STATIC_LIB_EXT "lib")
		else()
			set(STATIC_LIB_EXT "a")
			set(STATIC_LIB_PREFIX "lib")
		endif()

	elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")

		set(STATIC_LIB_EXT "a")
		set(SHARED_LIB_EXT "so")
		set(STATIC_LIB_PREFIX "lib")
		set(SHARED_LIB_PREFIX "lib")

	elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")

		set(STATIC_LIB_EXT "a")
		set(SHARED_LIB_EXT "dylib")
		set(STATIC_LIB_PREFIX "lib")
		set(SHARED_LIB_PREFIX "lib")

	else()

		message(FATAL_ERROR "Platform system '${CMAKE_SYSTEM_NAME}' not supported.")

	endif()

	if (USE_SHARED_LIB)
		set(${OUT_VAR} "${SHARED_LIB_PREFIX}${LIB_NAME}.${SHARED_LIB_EXT}" PARENT_SCOPE)
	else()
		set(${OUT_VAR} "${STATIC_LIB_PREFIX}${LIB_NAME}.${STATIC_LIB_EXT}" PARENT_SCOPE)
	endif()
endfunction()
