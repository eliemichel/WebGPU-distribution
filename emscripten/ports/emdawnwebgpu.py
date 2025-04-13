# from https://github.com/emscripten-core/emscripten/issues/23432#issuecomment-2798903250
import os

TAG = 'v2025.04.12-03.06.48'
HASH = 'd5627fb822317a8573ad133100a15917517ad44ca39c6927b4dd37b3a3476082a077f8474dcde348bb42a4058c92b9c25beeffb5bd71b83c44df93efea48c1cf'

# contrib port information (required)
URL = 'https://dawn.googlesource.com/dawn'
DESCRIPTION = 'Dawn is an open-source and cross-platform implementation of the WebGPU standard'
LICENSE = 'BSD 3-Clause License'

port_name = 'emdawnwebgpu'

lib_name = 'lib_emdawnwebgpu.a'


def get_root_path(ports):
  return os.path.join(ports.get_dir(), port_name, 'emdawnwebgpu_pkg')


def get_include_path(ports):
  return os.path.join(get_root_path(ports), 'webgpu', 'include')


def get_cpp_include_path(ports):
  return os.path.join(get_root_path(ports), 'webgpu_cpp', 'include')


def get_source_path(ports):
  return os.path.join(get_root_path(ports), 'webgpu', 'src')


def get(ports, settings, shared):
  # get the port
  ports.fetch_project(port_name, f'https://github.com/kainino0x/dawn/releases/download/{TAG}/emdawnwebgpu_pkg-{TAG}.zip', sha512hash=HASH)

  def create(final):
    source_path = get_source_path(ports)
    include_path = get_include_path(ports)

    includes = [include_path]
    srcs = ['webgpu.cpp']
    flags = ['-std=c++17', '-fno-exceptions']

    ports.build_port(source_path, final, port_name, includes=includes, srcs=srcs, flags=flags)

  return [shared.cache.get_lib(lib_name, create, what='port')]


def clear(ports, settings, shared):
  shared.cache.erase_lib(lib_name)


def linker_setup(ports, settings):
  if settings.USE_WEBGPU:
    raise Exception('dawn may not be used with -sUSE_WEBGPU=1')

  src_dir = get_source_path(ports)

  settings.JS_LIBRARIES += [
    os.path.join(src_dir, 'library_webgpu_enum_tables.js'),
    os.path.join(src_dir, 'library_webgpu_generated_struct_info.js'),
    os.path.join(src_dir, 'library_webgpu_generated_sig_info.js'),
    os.path.join(src_dir, 'library_webgpu.js'),
  ]
  # TODO(crbug.com/371024051): Emscripten needs a way for us to pass
  # --closure-args too.


def process_args(ports):
  # It's important that these take precedent over Emscripten's builtin
  # system/include/, which also currently has webgpu headers.
  return ['-isystem', get_include_path(ports), '-isystem', get_cpp_include_path(ports)]


if __name__ == "__main__":
  print(f'''# To compute checksums run this
curl -sfL https://github.com/kainino0x/dawn/releases/download/{TAG}/emdawnwebgpu_pkg-{TAG}.zip | shasum -a 512
''')
