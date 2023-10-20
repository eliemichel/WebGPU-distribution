from conans import ConanFile, tools
from conan.tools.cmake import CMake, CMakeDeps, CMakeToolchain

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
        self.copy(pattern="_deps/dawn-build/gen/include/dawn/webgpu.h", dst="include/webgpu", keep_path=False)
        self.copy(pattern="include/webgpu/webgpu.hpp", dst="include/webgpu", keep_path=False)
        self.copy(pattern="*libwebgpu_dawn.a", dst="lib", keep_path=False)
        self.copy(pattern="*libwebgpu_dawn.dylib", dst="lib", keep_path=False)

    def package_info(self):
        pass

