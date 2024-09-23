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

include(FetchContent)

set(DAWN_LINK_TYPE "SHARED" CACHE STRING "Whether the wgpu-native WebGPU implementation must be statically or dynamically linked. Possible values are STATIC and SHARED in theory, though only SHARED is really supported upstream for now")
set_property(CACHE DAWN_LINK_TYPE PROPERTY STRINGS SHARED STATIC)
set(DAWN_VERSION "6734" CACHE STRING "Version of the Dawn release to use. Must correspond to the number after 'chromium/' in the tag name of an existing release on https://github.com/eliemichel/dawn-prebuilt/releases. Warning: The webgpu.hpp file provided in include/ may not be compatible with other versions.")
set(DAWN_MIRROR "https://github.com/eliemichel/dawn-prebuilt" CACHE STRING "This is ultimately supposed to be https://github.com/google/dawn, where official binaries will be auto-released, but in the meantime we use a different mirror.")

# Not using emscripten, so we download binaries. There are many different
# combinations of OS, CPU architecture and compiler (the later is only
# relevant when using static linking), so here are a lot of boring "if".

detect_system_architecture()

# Check 'DAWN_LINK_TYPE' argument
set(USE_SHARED_LIB)
if (DAWN_LINK_TYPE STREQUAL "SHARED")
	set(USE_SHARED_LIB TRUE)
elseif (DAWN_LINK_TYPE STREQUAL "STATIC")
	set(USE_SHARED_LIB FALSE)
	message(FATAL_ERROR "Link type '${DAWN_LINK_TYPE}' is not supported yet in Dawn releases.")
else()
	message(FATAL_ERROR "Link type '${DAWN_LINK_TYPE}' is not valid. Possible values for DAWN_LINK_TYPE are SHARED and STATIC.")
endif()

# Build URL to fetch
set(URL_OS)
if (CMAKE_SYSTEM_NAME STREQUAL "Windows")

	set(URL_OS "windows")

elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")

	set(URL_OS "linux")

elseif (CMAKE_SYSTEM_NAME STREQUAL "Darwin")

	set(URL_OS "macos")

else()

	message(FATAL_ERROR "Platform system '${CMAKE_SYSTEM_NAME}' not supported by this release of WebGPU. You may consider building it yourself from its source (see https://dawn.googlesource.com/dawn)")

endif()

# NB: No arch is specified in the URL for now in Dawn releases (only 1 arch is supported per OS)
set(URL_ARCH)
if (ARCH STREQUAL "x86_64" AND CMAKE_SYSTEM_NAME STREQUAL "Windows")
	set(URL_ARCH "")
elseif (ARCH STREQUAL "x86_64" AND CMAKE_SYSTEM_NAME STREQUAL "Linux")
	set(URL_ARCH "")
elseif (ARCH STREQUAL "aarch64" AND CMAKE_SYSTEM_NAME STREQUAL "Darwin")
	set(URL_ARCH "")
else()
	message(FATAL_ERROR "Platform architecture '${ARCH}' not supported for system '${CMAKE_SYSTEM_NAME}' by this release of WebGPU. You may consider building it yourself from its source (see https://dawn.googlesource.com/dawn)")
endif()

# We only fetch release builds (NB: this may cause issue when using static
# linking, but not with dynamic)
set(URL_CONFIG Release)
set(URL_NAME "Dawn-${DAWN_VERSION}-${URL_OS}${URL_ARCH}-${URL_CONFIG}")
string(TOLOWER "${URL_NAME}" FC_NAME)
set(URL "${DAWN_MIRROR}/releases/download/chromium%2F${DAWN_VERSION}/${URL_NAME}.zip")

# Declare FetchContent, then make available
FetchContent_Declare(${FC_NAME}
	URL ${URL}
)
# TODO: Display the "Fetching" message only when actually downloading
message(STATUS "Fetching WebGPU implementation from '${URL}'")
FetchContent_MakeAvailable(${FC_NAME})

set(Dawn_ROOT "${${FC_NAME}_SOURCE_DIR}")
set(Dawn_DIR "${${FC_NAME}_SOURCE_DIR}/lib64/cmake/Dawn")
find_package(Dawn CONFIG REQUIRED)

# Unify target name with other backends and provide webgpu.hpp
add_library(webgpu INTERFACE)
target_link_libraries(webgpu INTERFACE dawn::webgpu_dawn)
# This is used to advertise the flavor of WebGPU that this zip provides
target_compile_definitions(webgpu INTERFACE WEBGPU_BACKEND_DAWN)
# This add webgpu.hpp
target_include_directories(webgpu INTERFACE "${CMAKE_CURRENT_LIST_DIR}/include")

# Get path to .dll/.so/.dylib, for target_copy_webgpu_binaries
get_target_property(WEBGPU_RUNTIME_LIB dawn::webgpu_dawn IMPORTED_LOCATION_RELEASE)
message(STATUS "Using WebGPU runtime from '${WEBGPU_RUNTIME_LIB}'")
set(WEBGPU_RUNTIME_LIB ${WEBGPU_RUNTIME_LIB} CACHE INTERNAL "Path to the WebGPU library binary")

# The application's binary must find the .dll/.so/.dylib at runtime,
# so we automatically copy it next to the binary.
function(target_copy_webgpu_binaries Target)
	add_custom_command(
		TARGET ${Target} POST_BUILD
		COMMAND
			${CMAKE_COMMAND} -E copy_if_different
			${WEBGPU_RUNTIME_LIB}
			$<TARGET_FILE_DIR:${Target}>
		COMMENT
			"Copying '${WEBGPU_RUNTIME_LIB}' to '$<TARGET_FILE_DIR:${Target}>'..."
	)
endfunction()
