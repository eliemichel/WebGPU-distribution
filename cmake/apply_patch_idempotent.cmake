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

# This is a CMake file meant to be called in script mode. It applies a patch in
# a way that is robust to re-applying it multiple times.
#
# Usage:
#   cmake -DPATCH_FILE=path/to/patch.diff -P apply_patch_idempotent.cmake
#
# Patch is applied in the current working directory.

message(STATUS "Applying patch from '${PATCH_FILE}'...")

set(PATCH_CMD git apply --ignore-space-change --ignore-whitespace ${PATCH_FILE})

# Test reverse patch
execute_process(
	RESULT_VARIABLE EXIT_CODE
	ERROR_VARIABLE STDERR
	COMMAND git apply --ignore-space-change --ignore-whitespace "${PATCH_FILE}" --reverse --check
)

if (EXIT_CODE EQUAL 0)
	# Reverse patch can be applied, which means the patch has already been applied.
	message(STATUS "Patch was already applied")
else()
	execute_process(COMMAND git apply --ignore-space-change --ignore-whitespace ${PATCH_FILE})
endif()
