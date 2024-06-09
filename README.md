<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/eliemichel/LearnWebGPU/main/images/webgpu-dark.svg">
    <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/eliemichel/LearnWebGPU/main/images/webgpu-light.svg">
    <img alt="Learn WebGPU Logo" src="images/webgpu-dark.svg" width="200">
  </picture>

  <a href="https://github.com/eliemichel/LearnWebGPU">LearnWebGPU</a> &nbsp;|&nbsp; <a href="https://github.com/eliemichel/WebGPU-Cpp">WebGPU-C++</a> &nbsp;|&nbsp; <a href="https://github.com/eliemichel/WebGPU-distribution">WebGPU-distribution</a><br/>
  <a href="https://github.com/eliemichel/glfw3webgpu">glfw3webgpu</a> &nbsp;|&nbsp; <a href="https://github.com/eliemichel/sdl2webgpu">sdl2webgpu</a>
  
  <a href="https://discord.gg/2Tar4Kt564"><img src="https://img.shields.io/static/v1?label=Discord&message=Join%20us!&color=blue&logo=discord&logoColor=white" alt="Discord | Join us!"/></a>
</div>

WebGPU distribution
===================

**Important Note** If you were using [`webgpu.cmake`](https://github.com/eliemichel/WebGPU-distribution/blob/main/webgpu.cmake) prior to November 5, 2023 **please update** it to prevent breaking changes. Each revision of this file now points to a specific version of the distribution submodules to make sure your project still builds even when the distributions gets updated.

Overview
--------

The standard [WebGPU](https://www.w3.org/TR/webgpu) graphics API has multiple implementations, mostly [wgpu-native](https://github.com/gfx-rs/wgpu-native) (Firefox) and [Dawn](https://dawn.googlesource.com/dawn) (Chrome).

This repository provides **distributions** of these implementations that are:

 - **Easy to integrate.** These are standard [CMake](https://cmake.org) projects, that can be included either with a simple `add_subdirectory` (potentially using git submodules) or using [FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html). No esoteric build tool is needed.

 - **Interchangeable.** Switching from one backend to another one does not require any change to the build system. Just replace your `webgpu` directory by a different distribution. A preprocessor variable `WEBGPU_BACKEND_WGPU` or `WEBGPU_BACKEND_DAWN` is defined to handle discrepancies in the source code.

 - **emscripten-ready** When calling `emcmake`, these distributions switch to emscripten's WebGPU header (which is mapped to JavaScript WebGPU API).

As a bonus, they include a [WebGPU-C++](https://github.com/eliemichel/WebGPU-Cpp) header consistent with the backend capabilities to ease C++ development of WebGPU-based applications.

Usage
-----

Different options for using this repository are detailed bellow. The only difference is the `<branch_name>` to use when getting a distribution, either by downloading the source from:

```
https://github.com/eliemichel/WebGPU-distribution/archive/refs/heads/<branch_name>.zip
```

and including it with `add_subdirectory(webgpu)`, or by using fetch content:

```CMake
FetchContent_Declare(
  webgpu
  GIT_REPOSITORY https://github.com/eliemichel/WebGPU-distribution
  GIT_TAG        <branch_name>
)
FetchContent_MakeAvailable(webgpu)
```

This creates a `webgpu` CMake target that you can link against.

**NB** In order to ensure that dynamically linked backend are copied next to the generated application, call `target_copy_webgpu_binaries(TargetName)` at the end of your CMakeLists for each target `TargetName` that links against `webgpu`.

### Option A: Flexibility

**Branch:** `main` (recommended)

The main branch enables one to chose any backend when configuring the project by setting the `WEBGPU_BACKEND` CMake cache variable. It is even possible to maintain multiple builds that use different backends:

```bash
# Build using wgpu-native backend
cmake -B build-wgpu -DWEBGPU_BACKEND=WGPU
cmake --build build-wgpu

# Build using Dawn backend
cmake -B build-dawn -DWEBGPU_BACKEND=DAWN
cmake --build build-dawn

# Build using emscripten
emcmake cmake -B build-emscripten
cmake --build build-emscripten
```

Other branches enable only one of these solutions. Use them only if you want to target a specific backend.

An alternate way to include this option is to copy the `webgpu.cmake` file in your project and call `include(webgpu.cmake)`. You may then adapt the `GIT_TAG` to freeze the version of each backend (by specifying an exact commit hash).

### Option B: Speed

**Branch:** `wgpu`

This backend is provided as pre-compiled binaries. You need to trust these binaries, but if you do it is the fastest solution.

This is also the solution to use for fully offline builds as it does not fetch any other content.

### Option C: Comfort

**Branch:** `dawn`

**Extra dependency:** [Python](https://www.python.org)

The Dawn-based branch compiles a WebGPU backend entirely from source, including a code generation step that requires Python. This is safer but takes some time to build the first time.

Dawn provides much more details about errors than wgpu-native. And since it is a C++ project, it provides stack trace information that integrates nicely in IDEs.

### Option D: Web

**Branch:** `emscripten`

One of the strengths of WebGPU is to be possibly built as web pages. This branch is very lightweight, since when targeting only the web, no backend is needed (the web browser provides is at runtime).

Details
-------

> *Why is this distribution repository needed?*

In theory we could use WebGPU backends as packaged by their developers. However in their current state, they suffer from some limitations:

 - wgpu-native does not provide any CMake integration.

 - wgpu-native auto-built binaries have some issues: binaries for Windows and macOS were incorrectly named (defeating linking), Windows release build is sometimes missing.

 - Dawn build instructions require the installation of depot_tools, which is overkill: our distribution replaces it with a simple Python script, Python being needed anyways for code generation purposes.

 - Dawn provides a C++ interface similar in some ways to WebGPU-C++ but that cannot be used with wgpu-native because it directly communicates with the Dawn backend instead of using only the standard `webgpu.h` header.

### Shallow clone

**Important.** When using this repository as a submodule, you should advise your users to add `--shallow-submodules` to their `git clone` command so that they only download the branch you picked.

I am not very happy with this, as it is likely that people forget it. I'm thinking of splitting this repository into multiple ones, namely one per option, but it is not ideal. In the meantime, a safe option is to just copy the content of this `main` branch into your repo.


### Future work

**Single-platform precompiled library.** I initially cared about providing a standalone folder that can be dropped in any project or shared with students and works on any desktop platform without the need for an Internet connection or anything (what the `wgpu` branch does).

While I intend to maintain this possibility, since the *Flexibility* option already uses a FetchContent mechanism it could be used to download only the binaries needed for the current platform.

**Static linking.** wgpu-native now also auto-builds static libraries, they are included as an alternative in the `wgpu-static` branch but this is highly untested (and I'm pretty sure it does not work for MSVC).

**Precompiled Dawn binaries.** Is it worth it? Initial compilation takes time, but then it is okay. Could use [Zig](https://github.com/hexops/mach-gpu-dawn) for this.
