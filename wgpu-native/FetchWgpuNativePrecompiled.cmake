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

include(FetchContent)

# Not using emscripten, so we download binaries. There are many different
# combinations of OS, CPU architecture and compiler (the later is only
# relevant when using static linking), so here are a lot of boring "if".

detect_system_architecture()

# Check 'WEBGPU_LINK_TYPE' argument
set(USE_SHARED_LIB)
if (WEBGPU_LINK_TYPE STREQUAL "SHARED")
	set(USE_SHARED_LIB TRUE)
elseif (WEBGPU_LINK_TYPE STREQUAL "STATIC")
	set(USE_SHARED_LIB FALSE)
else()
	message(FATAL_ERROR "Link type '${WEBGPU_LINK_TYPE}' is not valid. Possible values for WEBGPU_LINK_TYPE are SHARED and STATIC.")
endif()

# Build URL to fetch
set(URL_OS)
set(URL_COMPILER)
if (CMAKE_SYSTEM_NAME STREQUAL "Windows")

	set(URL_OS "windows")

	if (MSVC)
		set(URL_COMPILER "msvc")
	else()
		set(URL_COMPILER "gnu")
	endif()

elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")

	set(URL_OS "linux")

elseif (CMAKE_SYSTEM_NAME STREQUAL "Darwin")

	set(URL_OS "macos")

else()

	message(FATAL_ERROR "Platform system '${CMAKE_SYSTEM_NAME}' not supported by this release of WebGPU. You may consider building it yourself from its source (see https://github.com/gfx-rs/wgpu-native)")

endif()

# Determine architectures to download
if (CMAKE_SYSTEM_NAME STREQUAL "Darwin" AND WEBGPU_UNIVERSAL_MAC_LIB)
	set(DOWNLOAD_ARCHS "x86_64" "aarch64")
	message(STATUS "Universal macOS build requested - will download both x86_64 and aarch64 binaries")
else()
	set(DOWNLOAD_ARCHS "${ARCH}")
endif()

# Prepare variables for universal binary creation
set(ALL_LIBS "")
set(UNIVERSAL_ZIP_DIR "")

# Process each architecture
foreach(CURRENT_ARCH IN LISTS DOWNLOAD_ARCHS)
	set(URL_ARCH)
	if (CURRENT_ARCH STREQUAL "x86_64")
		set(URL_ARCH "x86_64")
	elseif (CURRENT_ARCH STREQUAL "aarch64")
		set(URL_ARCH "aarch64")
	elseif (CURRENT_ARCH STREQUAL "i686" AND CMAKE_SYSTEM_NAME STREQUAL "Windows")
		set(URL_ARCH "i686")
	else()
		message(FATAL_ERROR "Platform architecture '${CURRENT_ARCH}' not supported by this release of WebGPU. You may consider building it yourself from its source (see https://github.com/gfx-rs/wgpu-native)")
	endif()

	# We only fetch release builds (NB: this may cause issue when using static
	# linking, but not with dynamic)
	set(URL_CONFIG release)

	# Finally build the URL. The URL_NAME is also used as FetchContent
	# identifier (BTW it must be lowercase).
	if (URL_COMPILER)
		set(URL_NAME "wgpu-${URL_OS}-${URL_ARCH}-${URL_COMPILER}-${URL_CONFIG}")
	else()
		set(URL_NAME "wgpu-${URL_OS}-${URL_ARCH}-${URL_CONFIG}")
	endif()
	set(URL "${WGPU_BINARY_MIRROR}/releases/download/${WGPU_VERSION}/${URL_NAME}.zip")

	string(TOLOWER "${URL_NAME}" FC_NAME)

	# Declare FetchContent, then make available
	FetchContent_Declare(${FC_NAME}
		URL ${URL}
	)
	# TODO: Display the "Fetching" message only when actually downloading
	message(STATUS "Fetching WebGPU implementation from '${URL}'")
	FetchContent_MakeAvailable(${FC_NAME})
	set(CURRENT_ZIP_DIR "${${FC_NAME}_SOURCE_DIR}")

	# Store the library path for this architecture
	build_lib_filename(BINARY_FILENAME "wgpu_native" ${USE_SHARED_LIB})
	set(CURRENT_LIB "${CURRENT_ZIP_DIR}/lib/${BINARY_FILENAME}")
	list(APPEND ALL_LIBS "${CURRENT_LIB}")

	# Use first architecture's directory structure as template
	if (NOT UNIVERSAL_ZIP_DIR)
		set(UNIVERSAL_ZIP_DIR "${CURRENT_ZIP_DIR}")
	endif()
endforeach()

# Create universal binary if needed
if (CMAKE_SYSTEM_NAME STREQUAL "Darwin" AND WEBGPU_UNIVERSAL_MAC_LIB)
	# Create universal library directory
	set(UNIVERSAL_LIB_DIR "${CMAKE_BINARY_DIR}/webgpu_universal/lib")
	file(MAKE_DIRECTORY "${UNIVERSAL_LIB_DIR}")

	# Universal library path
	set(UNIVERSAL_LIB "${UNIVERSAL_LIB_DIR}/${BINARY_FILENAME}")

	# Create universal binary during configuration stage
	message(STATUS "Creating universal binary: ${UNIVERSAL_LIB}")
	execute_process(
		COMMAND lipo -create ${ALL_LIBS} -output "${UNIVERSAL_LIB}"
		RESULT_VARIABLE LIPO_RESULT
		ERROR_VARIABLE LIPO_ERROR
	)

	if(NOT LIPO_RESULT EQUAL 0)
		message(FATAL_ERROR "Failed to create universal binary: ${LIPO_ERROR}")
	endif()

	# Copy include directories from first architecture
	set(UNIVERSAL_INCLUDE_DIR "${CMAKE_BINARY_DIR}/webgpu_universal/include")
	file(MAKE_DIRECTORY "${UNIVERSAL_INCLUDE_DIR}")
	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory "${UNIVERSAL_ZIP_DIR}/include" "${UNIVERSAL_INCLUDE_DIR}")

	# Update paths to use universal binary
	set(ZIP_DIR "${CMAKE_BINARY_DIR}/webgpu_universal")
	set(WEBGPU_RUNTIME_LIB "${UNIVERSAL_LIB}")
else()
	# Single architecture - use existing logic
	set(ZIP_DIR "${UNIVERSAL_ZIP_DIR}")
	set(WEBGPU_RUNTIME_LIB "${ZIP_DIR}/lib/${BINARY_FILENAME}")
endif()

# A pre-compiled target (IMPORTED) that is a dynamically linked library
# (SHARED, meaning .dll, .so or .dylib) or statically linked (.a or .lib).
if (USE_SHARED_LIB)
	add_library(webgpu SHARED IMPORTED GLOBAL)
else()
	add_library(webgpu STATIC IMPORTED GLOBAL)
endif()

# This is used to advertise the flavor of WebGPU that this zip provides
target_compile_definitions(webgpu INTERFACE WEBGPU_BACKEND_WGPU)

# This add webgpu.hpp
target_include_directories(webgpu INTERFACE "${CMAKE_CURRENT_LIST_DIR}/include")

# TODO: There should be a wgpu-native-config.cmake file provided together with wgpu-native
build_lib_filename(BINARY_FILENAME "wgpu_native" ${USE_SHARED_LIB})
# Use WEBGPU_RUNTIME_LIB which is set appropriately above for both universal and single-arch cases
set_target_properties(
	webgpu
	PROPERTIES
		IMPORTED_LOCATION "${WEBGPU_RUNTIME_LIB}"
)

target_include_directories(webgpu INTERFACE
	"${ZIP_DIR}/include"
	"${ZIP_DIR}/include/webgpu"  # see https://github.com/gfx-rs/wgpu-native/pull/424
)

if (USE_SHARED_LIB)

	if (CMAKE_SYSTEM_NAME STREQUAL "Windows")

		if (MSVC)
			set(STATIC_LIB_EXT "lib")
			set(STATIC_LIB_PREFIX "")
		else()
			set(STATIC_LIB_EXT "a")
			set(STATIC_LIB_PREFIX "lib")
		endif()

		set(WGPU_IMPLIB "${ZIP_DIR}/lib/${STATIC_LIB_PREFIX}${BINARY_FILENAME}.${STATIC_LIB_EXT}")
		set_target_properties(
			webgpu
			PROPERTIES
				IMPORTED_IMPLIB "${WGPU_IMPLIB}"
		)

	elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")

		set_target_properties(
			webgpu
			PROPERTIES
				IMPORTED_NO_SONAME TRUE
		)

	endif()

	message(STATUS "Using WebGPU runtime from '${WEBGPU_RUNTIME_LIB}'")
	set(WEBGPU_RUNTIME_LIB ${WEBGPU_RUNTIME_LIB} CACHE INTERNAL "Path to the WebGPU library binary")

	# The application's binary must find the .dll/.so/.dylib at runtime,
	# so we automatically copy it (it's called WEBGPU_RUNTIME_LIB in general)
	# next to the binary.
	# Also make sure that the binary's RPATH is set to find this shared library.
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

else (USE_SHARED_LIB)

	if (CMAKE_SYSTEM_NAME STREQUAL "Windows")

		target_link_libraries(
			webgpu
			INTERFACE
				d3dcompiler.lib
				Ws2_32.lib
				Userenv.lib
				ntdll.lib
				Bcrypt.lib
				Opengl32.lib
				Propsys.lib
				RuntimeObject.lib
		)

	elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")

		target_link_libraries(
			webgpu
			INTERFACE
				dl
				pthread
				m
		)

	elseif (CMAKE_SYSTEM_NAME STREQUAL "Darwin")

		target_link_libraries(
			webgpu
			INTERFACE
				"-framework Metal"
				"-framework QuartzCore"
				"-framework MetalKit"
		)

	endif()

	function(target_copy_webgpu_binaries Target)
	endfunction()

endif (USE_SHARED_LIB)
