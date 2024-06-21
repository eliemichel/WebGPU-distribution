import os
from conans import ConanFile, tools
from conan.tools.cmake import CMake, CMakeDeps, CMakeToolchain
from conan.tools.files import replace_in_file

class WebGPUDistributionConan(ConanFile):
    name = 'WebGPU'
    version = 'latest'
    license = 'LGPL-2.0-or-later'
    author = 'Nisal Dilshan'
    description = 'Fork of WebGPU-distribution repository by Elie Michel (https://github.com/eliemichel/WebGPU-distribution)'
    url = 'https://github.com/nisaldilshan/WebGPU-distribution'
    topics = ("webgpu", "wgpu", "dawn", "emscripten", "c++")
    settings = 'os', 'compiler', 'build_type', 'arch'
    options = {
        'shared': [True, False],
        'branch': "ANY",
        'fPIC': [True, False]
    }
    default_options = {
        'shared': True,
        'branch': 'dawn',
        'fPIC': True
    }

    generators = 'VirtualBuildEnv'

    def requirements(self):
        pass

    def build_requirements(self):
        self.tool_requires('pkgconf/1.7.4')
        self.tool_requires('cmake/3.25.3')

    def source(self):
        self.run("git clone --depth=1 " + self.url + ".git --branch {} .".format(self.options.branch))
        if (self.options.branch == "dawn"):
            replace_in_file(self, os.path.join(self.source_folder, "cmake", "FetchDawn.cmake"), "EXCLUDE_FROM_ALL", "")
            replace_in_file(self, os.path.join(self.source_folder, "cmake", "FetchDawn.cmake"), "set(DAWN_ENABLE_D3D11 OFF)", 
                                            "set(DAWN_USE_GLFW OFF)\nset(TINT_BUILD_CMD_TOOLS OFF)\nset(DAWN_ENABLE_D3D11 OFF)")

    def configure(self):
        pass

    def config_options(self):
        pass

    def generate(self):
        tc = CMakeToolchain(self, generator="Ninja")
        tc.generate()
        deps = CMakeDeps(self)
        deps.generate()

    def build(self):
        cmake = CMake(self)
        cmake.verbose = True
        cmake.configure()
        cmake.build()

    def package_id(self):
        pass

    def package(self):
        self.copy(pattern="include/webgpu/webgpu.hpp", dst="include/webgpu", keep_path=False)
        if (self.options.branch == "dawn"):
            self.copy(pattern="_deps/dawn-build/gen/include/dawn/webgpu.h", dst="include/webgpu", keep_path=False)
            self.copy(pattern="*libwebgpu_dawn.a", dst="lib", keep_path=False)
            self.copy(pattern="*libwebgpu_dawn.dylib", dst="lib", keep_path=False)
            self.copy(pattern="*libdawn_native.dylib", dst="lib", keep_path=False)
            self.copy(pattern="*libwebgpu_dawn.so", dst="lib", keep_path=False)
            self.copy(pattern="*libdawn_native.so", dst="lib", keep_path=False)

    def package_info(self):
        self.cpp_info.libs = ["webgpu_dawn"]
        if self.settings.os == "Macos":
            self.cpp_info.frameworks = ["Metal", "MetalKit", "AppKit", "Foundation", "QuartzCore", "IOSurface"]


