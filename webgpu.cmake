include(FetchContent)

set(WEBGPU_BACKEND "WGPU" CACHE STRING "Backend implementation of WebGPU. Possible values are WGPU and DAWN (it does not matter when using emcmake)")

if (NOT TARGET webgpu)
	string(TOUPPER ${WEBGPU_BACKEND} WEBGPU_BACKEND_U)

	if (EMSCRIPTEN OR WEBGPU_BACKEND_U STREQUAL "EMSCRIPTEN")

		FetchContent_Declare(
			webgpu-backend-emscripten
			GIT_REPOSITORY https://github.com/eliemichel/WebGPU-distribution
			GIT_TAG        emscripten
		)
		FetchContent_MakeAvailable(webgpu-backend-emscripten)

	elseif (WEBGPU_BACKEND_U STREQUAL "WGPU")

		FetchContent_Declare(
			webgpu-backend-wgpu
			GIT_REPOSITORY https://github.com/eliemichel/WebGPU-distribution
			GIT_TAG        wgpu
		)
		FetchContent_MakeAvailable(webgpu-backend-wgpu)

	elseif (WEBGPU_BACKEND_U STREQUAL "DAWN")

		FetchContent_Declare(
			webgpu-backend-dawn
			GIT_REPOSITORY https://github.com/eliemichel/WebGPU-distribution
			GIT_TAG        dawn
		)
		FetchContent_MakeAvailable(webgpu-backend-dawn)

	else()

		message(FATAL_ERROR "Invalid value for WEBGPU_BACKEND: possible values are WGPU and DAWN, but '${WEBGPU_BACKEND_U}' was provided.")

	endif()
endif()
