cmake_minimum_required(VERSION 3.0.0...3.24 FATAL_ERROR)
project(webgpu-backend-wgpu VERSION 1.0.0)

message(STATUS "Using wgpu-native backend for WebGPU")

if (EMSCRIPTEN)

	add_library(webgpu INTERFACE)

	target_include_directories(webgpu INTERFACE
		"${CMAKE_CURRENT_SOURCE_DIR}/include-emscripten"
	)

	# This is used to advertise the flavor of WebGPU that this zip provides
	target_compile_definitions(webgpu INTERFACE WEBGPU_BACKEND_EMSCRIPTEN)

	target_link_options(webgpu INTERFACE
		-sUSE_WEBGPU # Handle WebGPU symbols
	)

else (EMSCRIPTEN)

	set(WGPU ${CMAKE_CURRENT_SOURCE_DIR})

	# Target architecture detection (thank you CMake for not providing that...)
	if (NOT ARCH)
		set(SYSTEM_PROCESSOR ${CMAKE_SYSTEM_PROCESSOR})
		if (SYSTEM_PROCESSOR STREQUAL "AMD64" OR SYSTEM_PROCESSOR STREQUAL "x86_64")
			if (CMAKE_SIZEOF_VOID_P EQUAL 8)
				set(ARCH "x86_64")
			elseif (CMAKE_SIZEOF_VOID_P EQUAL 4)
				set(ARCH "i686")
			endif()
		elseif (SYSTEM_PROCESSOR STREQUAL "arm64")
			set(ARCH "aarch64")
		endif()
	endif()

	# A pre-compiled target (IMPORTED) that is a statically
	# linked library (STATIC, meaning .lib or .a).
	add_library(webgpu STATIC IMPORTED GLOBAL)

	# This is used to advertise the flavor of WebGPU that this zip provides
	target_compile_definitions(webgpu INTERFACE WEBGPU_BACKEND_WGPU)

	if(CMAKE_SYSTEM_NAME STREQUAL "Windows")

		set(WGPU_RUNTIME_LIB ${WGPU}/lib/windows-${ARCH}/wgpu_native.lib)
		set_target_properties(
			webgpu
			PROPERTIES
				IMPORTED_LOCATION "${WGPU_RUNTIME_LIB}"
				IMPORTED_IMPLIB "${WGPU_RUNTIME_LIB}"
				INTERFACE_INCLUDE_DIRECTORIES "${WGPU}/include"
		)

	elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")

		set(WGPU_RUNTIME_LIB ${WGPU}/lib/linux-${ARCH}/libwgpu_native.a)
		set_target_properties(
			webgpu
			PROPERTIES
				IMPORTED_LOCATION "${WGPU_RUNTIME_LIB}"
				INTERFACE_INCLUDE_DIRECTORIES "${WGPU}/include"
		)

	elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")

		set(WGPU_RUNTIME_LIB ${WGPU}/lib/macos-${ARCH}/libwgpu_native.a)
        target_link_libraries(webgpu INTERFACE "-framework Metal" "-framework QuartzCore" "-framework MetalKit")
		set_target_properties(
			webgpu
			PROPERTIES
				IMPORTED_LOCATION "${WGPU_RUNTIME_LIB}"
				INTERFACE_INCLUDE_DIRECTORIES "${WGPU}/include"
		)

	else()

		message(FATAL_ERROR "Platform not supported by this release of WebGPU. You may consider building it yourself from its source (see https://github.com/gfx-rs/wgpu-native)")

	endif()

	message(STATUS "Using WebGPU backend from '${WGPU_RUNTIME_LIB}'")
	set(WGPU_RUNTIME_LIB ${WGPU_RUNTIME_LIB} PARENT_SCOPE)
	set(WGPU_RUNTIME_LIB ${WGPU_RUNTIME_LIB} CACHE INTERNAL "Path to the WebGPU library binary")

endif (EMSCRIPTEN)

# Does nothing when statically linked
function(target_copy_webgpu_binaries Target)
endfunction()
