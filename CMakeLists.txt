cmake_minimum_required(VERSION 3.0.0...3.24 FATAL_ERROR)
project(webgpu-backend-dawn VERSION 1.0.0)

message(STATUS "Using Dawn backend for WebGPU")

add_library(webgpu INTERFACE)

if (EMSCRIPTEN)

	target_include_directories(webgpu INTERFACE
		"${CMAKE_CURRENT_SOURCE_DIR}/include-emscripten"
	)

	# This is used to advertise the flavor of WebGPU that this zip provides
	target_compile_definitions(webgpu INTERFACE WEBGPU_BACKEND_EMSCRIPTEN)

	target_link_options(webgpu INTERFACE
		-sUSE_WEBGPU # Handle WebGPU symbols
	)

	# Does nothing, as this dawn-based distribution of WebGPU is statically linked
	function(target_copy_webgpu_binaries Target)
	endfunction()

else (EMSCRIPTEN)

	include(cmake/FetchDawn.cmake)

	target_link_libraries(webgpu INTERFACE webgpu_dawn)
	target_include_directories(webgpu INTERFACE
		"${CMAKE_CURRENT_SOURCE_DIR}/include"
		"${dawn_SOURCE_DIR}/include"
	)

	# This is used to advertise the flavor of WebGPU that this zip provides
	target_compile_definitions(webgpu INTERFACE WEBGPU_BACKEND_DAWN)

	# Does nothing, as this dawn-based distribution of WebGPU is statically linked
	function(target_copy_webgpu_binaries Target)
		add_custom_command(
			TARGET ${Target} POST_BUILD
			COMMAND
				"${CMAKE_COMMAND}" -E copy_if_different
				"$<TARGET_FILE_DIR:webgpu_dawn>/$<TARGET_FILE_NAME:webgpu_dawn>"
				"$<TARGET_FILE_DIR:${Target}>"
			COMMENT
				"Copying '$<TARGET_FILE_DIR:webgpu_dawn>/$<TARGET_FILE_NAME:webgpu_dawn>' to '$<TARGET_FILE_DIR:${Target}>'..."
		)
	endfunction()

endif (EMSCRIPTEN)
