include(FetchContent)

set(WEBGPU_BACKEND "WGPU" CACHE STRING "Backend implementation of WebGPU. Possible values are WGPU and DAWN (it does not matter when using emcmake)")

if (NOT TARGET webgpu)
	string(TOUPPER ${WEBGPU_BACKEND} WEBGPU_BACKEND_U)

	if (EMSCRIPTEN OR WEBGPU_BACKEND_U STREQUAL "EMSCRIPTEN")

		message(STATUS "Using emscripten backend for WebGPU")
		FetchContent_Declare(
			webgpu-backend-emscripten
			GIT_REPOSITORY https://github.com/eliemichel/WebGPU-binaries
			GIT_TAG        emscripten
		)
		FetchContent_MakeAvailable(webgpu-backend-emscripten)

	elseif (WEBGPU_BACKEND_U STREQUAL "WGPU")

		message(STATUS "Using wgpu-native backend for WebGPU")
		FetchContent_Declare(
			webgpu-backend-wgpu
			GIT_REPOSITORY https://github.com/eliemichel/WebGPU-binaries
			GIT_TAG        wgpu
		)
		FetchContent_MakeAvailable(webgpu-backend-wgpu)

	elseif (WEBGPU_BACKEND_U STREQUAL "DAWN")

		message(STATUS "Using Dawn backend for WebGPU")
		FetchContent_Declare(
			webgpu-backend-dawn
			GIT_REPOSITORY https://github.com/eliemichel/WebGPU-binaries
			GIT_TAG        dawn
		)
		FetchContent_MakeAvailable(webgpu-backend-dawn)

	else()

		message(FATAL_ERROR "Invalid value for WEBGPU_BACKEND: possible values are WGPU and DAWN, but '${WEBGPU_BACKEND_U}' was provided.")

	endif()
endif()
