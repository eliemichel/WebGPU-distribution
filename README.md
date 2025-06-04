<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/eliemichel/LearnWebGPU/main/images/webgpu-dark.svg">
    <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/eliemichel/LearnWebGPU/main/images/webgpu-light.svg">
    <img alt="Learn WebGPU Logo" src="images/webgpu-dark.svg" width="200">
  </picture>

  <a href="https://github.com/eliemichel/LearnWebGPU">LearnWebGPU</a> &nbsp;|&nbsp; <a href="https://github.com/eliemichel/WebGPU-Cpp">WebGPU-C++</a> &nbsp;|&nbsp; <a href="https://github.com/eliemichel/WebGPU-distribution">WebGPU-distribution</a><br/>
  <a href="https://github.com/eliemichel/glfw3webgpu">glfw3webgpu</a> &nbsp;|&nbsp; <a href="https://github.com/eliemichel/sdl2webgpu">sdl2webgpu</a> &nbsp;|&nbsp; <a href="https://github.com/eliemichel/sdl3webgpu">sdl3webgpu</a>
  
  <a href="https://discord.gg/2Tar4Kt564"><img src="https://img.shields.io/static/v1?label=Discord&message=Join%20us!&color=blue&logo=discord&logoColor=white" alt="Discord | Join us!"/></a>
</div>

WebGPU distribution
===================

*A unified setup to use any implementation of WebGPU in CMake projects targetting either native or web platforms.*

> [!IMPORTANT]
> You should **use an explicit tag name or commit hash** when using this repository as a **submodule** or with CMake's **FetchContent**. Do **not** point directly to the tip of a branch (be it `main` or another), so that your build does not risk breaking whenever this distribution gets updated.

Outline
-------

- [Overview](#overview)
- [Usage](#usage)
  * [Integration](#integration)
  * [CMake target](#cmake-target)
  * [Options](#options)
    + [Choice of implementation](#choice-of-implementation)
    + [Building from source](#building-from-source)
    + [Link type](#link-type)
    + [Implementation version](#implementation-version)
- [Troubleshooting](#troubleshooting)
  * [Path size limit on Windows](#path-size-limit-on-windows)

Overview
--------

The standard [WebGPU](https://www.w3.org/TR/webgpu) graphics API defines a [native C interface](https://github.com/webgpu-native/webgpu-headers) and has multiple cross-platform implementations, mostly [wgpu-native](https://github.com/gfx-rs/wgpu-native) (Firefox) and [Dawn](https://dawn.googlesource.com/dawn) (Chrome).

This repository provides a **distribution** of these implementations that is:

 - **Easy to integrate.** This is a standard [CMake](https://cmake.org) project, that can be included either with a simple `add_subdirectory` (potentially using git submodules) or using [FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html). No esoteric build tool is needed.

 - **Interchangeable.** Switching from one backend to another one does not require any change to the build system. A preprocessor variable is defined to handle discrepancies in the source code (if any): `WEBGPU_BACKEND_EMSCRIPTEN` `WEBGPU_BACKEND_EMDAWNWEBGPU`, `WEBGPU_BACKEND_WGPU` or `WEBGPU_BACKEND_DAWN`

 - **emscripten-ready** When calling `emcmake`, these distributions switch to emscripten's WebGPU header (which is mapped to JavaScript WebGPU API). They either use emscripten's built-in WebGPU, or fetch a more recent port from emdawnwebgpu.

 - **Built from source** or **precompiled** depending on the value of `WEBGPU_BUILD_FROM_SOURCE` specified when invoking `cmake`.

As a bonus, they include a [WebGPU-C++](https://github.com/eliemichel/WebGPU-Cpp) header consistent with the backend capabilities to ease C++ development of WebGPU-based applications.

Usage
-----

### Integration

The easiest way to integrate this distribution is to **download it as zip**, then include it in your `CMakeLists.txt` using [`add_subdirectory()`](https://cmake.org/cmake/help/latest/command/add_subdirectory.html).

```CMake
# 1. Download https://github.com/eliemichel/WebGPU-distribution/archive/refs/heads/main-next.zip
# 2. Unzip `main-next.zip` and rename the unzipped directory 'webgpu'.
# 3. Make sure it directly contains the file from this repository (and not an extra nested directory).
# 4. In your root CMakeLists.txt, add the following line:
add_subdirectory(webgpu) # 'webgpu' is the name of the directory
```

> [!NOTE]
> This repository (downloaded as zip) is rather **lightweight** since it only contains a couple of CMake files to take care of fetching the actual source code or precompiled binaries of WebGPU (depending on the options) at configuration time (i.e., when calling `cmake`).

> [!CAUTION]
> Be careful **when cloning** this repository though: it may feel heavy because some legacy branches contain binaries. **Prefer using [shallow cloning](https://github.blog/open-source/git/get-up-to-speed-with-partial-clone-and-shallow-clone/)**.

### CMake target

Once `add_subdirectory(webgpu)` has been called in your `CMakeLists.txt`, a CMake [*target*](https://cmake.org/cmake/help/book/mastering-cmake/chapter/Key%20Concepts.html#targets) called `webgpu` is defined. This is a regular CMake target, that can be used as follows:

```CMake
# Create your target (executable or library)
add_executable(MyExecutable)

# Indicate that your target depends on WebGPU
target_link_libraries(MyExecutable PRIVATE webgpu)

# (Then add sources and other dependencies)
```

When the WebGPU implementation is built (or fetched) as a **shared library** (i.e., a `.so` on linux, a `.dll` on Windows or a `.dylib` on macOS), your program may complain at runtime that it does not find the library. To avoid this issue, we provide a cmake function `target_copy_webgpu_binaries` that should be invoked for all executable target that links against `webgpu`:

```CMake
# Make sure webgpu so/dll/dylib file is copied next to your executable
# to ease development and distribution:
target_copy_webgpu_binaries(MyExecutable)
```

> [!NOTE]
> This function `target_copy_webgpu_binaries` is always defined, even if the options are set to link as a static library. In such a case the function does nothing, but should be used anyways in case one chooses to switch to a different backend.

### Options

CMake options and cache variables are defined to enable picking a specific version of the backend. You may leave them to their default values if you do not care about the details.

As a reminder, CMake options can be specified on the command line when invoking CMake:

```bash
# Call CMake with the value 'MY_VALUE' assigned to the variable 'MY_OPTION'
cmake -B build -DMY_OPTION=MY_VALUE
```

For instance, you can configure multiple builds of your project, using different setups:

```bash
# Build using a precompiled wgpu-native backend
cmake -B build-wgpu -DWEBGPU_BACKEND=WGPU -DWEBGPU_BUILD_FROM_SOURCE=OFF
cmake --build build-wgpu

# Build using a Dawn backend built from source
cmake -B build-dawn -DWEBGPU_BACKEND=DAWN -DWEBGPU_BUILD_FROM_SOURCE=ON
cmake --build build-dawn

# Build using emscripten (no need for a specific backend)
emcmake cmake -B build-emscripten
cmake --build build-emscripten
```

> [!TIP]
> You may also **override the default value** of these options, either by directly modifying their declaration (in [`CMakeLists.txt`](CMakeLists.txt), [`dawn/FetchDawnPrecompiled.cmake`](dawn/FetchDawnPrecompiled.cmake), [`dawn/FetchDawnSource.cmake`](dawn/FetchDawnSource.cmake), [`wgpu-native/FetchWgpuNativePrecompiled.cmake`](wgpu-native/FetchWgpuNativePrecompiled.cmake), etc.) or by copying their declaration in your own `CMakeLists.txt` **before** calling `add_subdirectory(webgpu)`.

#### ☑️ Choice of implementation <a name="choice-of-implementation"></a>

The first thing to decide on is the value of `WEBGPU_BACKEND`, which can be:

- `WGPU` to use [wgpu-native](https://github.com/gfx-rs/wgpu-native), that is based on the Rust library [`wgpu`](https://github.com/gfx-rs/wgpu), which not only fuels Firefox but also a large portion of Rust graphics applications.
- `DAWN` to use [Dawn](https://dawn.googlesource.com/dawn), the implementation of WebGPU used by Chromium and its derivatives (Google Chrome, MS Edge, etc.).
- `EMSCRIPTEN` to prevent fetching any implementation, because a Web app cross-compiled with emscripten uses the implementation of the client's web browser.
- `EMDAWNWEBGPU` uses a different *port* than what emscripten provides by default to convert calls to the C API into calls of the Web API. This port -- called **[emdawnwebgpu](https://dawn.googlesource.com/dawn/+/refs/heads/main/src/emdawnwebgpu/)** -- is more up to date but may break more often compatibility.

> [!TIP]
> When using `emcmake` (the CMake wrapper provided by emscripten), the default backend is `EMDAWNWEBGPU`.

> [!NOTE]
> A notable implementation of WebGPU that is not supported here is the one from [WebKit](https://webkit.org/). It might be added in the future, although it is not a priority since it is not as cross-platform (it does not support Windows).

#### ☑️ Building from source <a name="building-from-source"></a>

The option `WEBGPU_BUILD_FROM_SOURCE` can be turned `ON` to build the implementation from source rather than downloading a pre-compiled version.

**Pros of building from source:**

- You can check that no malicious code was added.
- You can refine the compilation options (e.g., you may tweak in [`dawn/FetchDawnSource.cmake`](dawn/FetchDawnSource.cmake) the options that are passed to Dawn).
- You can inspect the source code of your implementation when debugging, to better track your issues down to the underlying graphics API (DirectX, Vulkan, Metal).
- You can modify and customize the implementation (as long as you don't try to use your extensions in Web builds).
- You can build for platforms for which precompiled binaries are not provided.

**Pros of using prebuilt binaries:**

- It is much faster to build your project the first time, and slightly faster the other times.
- It uses less disk space.
- You do not need to download as much data at configuration time.
- You can use the rust implementation despite building a C++ project.
- You do not inherit all build dependencies from the implementation (e.g., Dawn build requires Python)

> [!NOTE]
> Building from source is only supported with Dawn for now, because Dawn uses CMake while building `wgpu-native` requires a rust toolchain. There are plans to add CMake support to the [upstream repository](https://github.com/gfx-rs/wgpu-native), after which this distribution could support such an option.

> [!TIP]
> This whole distribution is designed to make it **easy to switch options**. I recommend first trying precompiled binaries as it will quickly get you to your first build (unless one of the drawbacks mentioned above is a dealbreaker); you may later switch to a build from source if needed.

#### ☑️ Link type <a name="link-type"></a>

The WebGPU implementation may be linked either dynamically (`WEBGPU_LINK_TYPE=SHARED`) or statically (`WEBGPU_LINK_TYPE=STATIC`).

**Some pros of dynamic linking:**

- Your binary is smaller because it does not include the WebGPU implementation.
- The library must still be provided, as a .so/.dll/.dylib. You probably want to put this file right next to your executable because there is too much risk that versions of the backend found elsewhere on your system do not match.
- The shared library is particularly beneficial when you distribute multiple executable that are ensured to use compatible versions of WebGPU.
- You can use a different compiler to build your app than the one used to build WebGPU (e.g., MSVC vs MinGW)

**Some pros of static linking:**

- Your binary is self-contained.
- You do not risk a runtime mismatch with a wrong version of the library.

> [!TIP]
> In order to limit the risk of trouble, this distribution provides a function `target_copy_webgpu_binaries` to be called on your executable in order to copy the right .so/.dll/.dylib file next to your executable when using dynamic linking.

> [!WARNING]
> Not all combinations of options allow static linking. Feel free to request further investigation through an [Issue](https://github.com/eliemichel/WebGPU-distribution/issues) or propose changes through a [Pull Request](https://github.com/eliemichel/WebGPU-distribution/pulls) to help tackle this limitation.

> [!NOTE]
> Link type is **ignored when building with emscripten** (be it the EMSCRIPTEN or the EMDAWNWEBGPU backend), since in all cases the final WASM module calls the browser's implementation.

#### ☑️ Implementation version <a name="implementation-version"></a>

By default, this distribution points to a specific version of Dawn or wgpu-native. It is possible to change this version, but it **requires care**:

- The C++ extensions `webgpu.hpp` and `webgpu-raii.hpp` (from [WebGPU-Cpp](https://github.com/eliemichel/WebGPU-Cpp)) that are provided with this distribution are **specific to the default version** (recalled in `dawn/dawn-git-tag.txt`, `wgpu-native/wgpu-native-git-tag.txt` and `emscripten/emscripten-git-tag.txt`). You must re-generate them when switching to a different version (e.g., using the [Web interface](https://eliemichel.github.io/WebGPU-Cpp) of WebGPU-Cpp).

- Precompiled binaries are not available for all versions. In particular, Dawn does not provide any, so I regularly upload binaries on [eliemichel/dawn-prebuilt](https://github.com/eliemichel/dawn-prebuilt) (detailed build logs are available in [Actions](https://github.com/eliemichel/dawn-prebuilt/actions/workflows/ci.yml) for the sake of transparency) but you may only use a version available in [Releases](https://github.com/eliemichel/dawn-prebuilt/releases).

**Dawn.** The version of Dawn is specified through the variable `DAWN_VERSION`, and is a simple revision number (the one found after "chromium/" in the tag name used to mark releases in their git repository). When building from source, the variable `DAWN_SOURCE_MIRROR` is used as the repository to pull from. When using precompiled binaries, the variable `DAWN_BINARY_MIRROR` is the GitHub repository in which to look for a binary release that matches the target version.

**wgpu-native.** The version of wgpu-native is specified through the variable `WGPU_VERSION`, and must be a valid release of the repository passed as `WGPU_BINARY_MIRROR`. The official repository is `https://github.com/gfx-rs/wgpu-native` and I sometimes release early versions on `https://github.com/eliemichel/wgpu-native`.

Troubleshooting
---------------

### Path size limit on Windows

By default, Windows limits path size to 260 characters, which may be reached due to how CMake organizes its internal directories like `my_project/build/_deps/wgpu-windows-x86_64...`. If you run into such an issue, look for `FetchContent_Declare(${FC_NAME} ...` and **right before** this re-define the name of the fetched content with `set(FC_NAME shortname)`, where "shortname" can be anything.

> [!NOTE]
> The `FC_NAME` is longer by default to help readability when browsing the `build/_deps` directory.
