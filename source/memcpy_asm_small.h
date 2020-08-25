// Copyright 2020 Daniel Way
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#ifndef MEMCPY_ASM_SMALL_H
#define MEMCPY_ASM_SMALL_H

#include <stdint.h>

void* memcpy_small (void* dst, const void* src, size_t len);

void* memcpy_smallest (void* dst, const void* src, size_t len);

#endif // MEMCPY_ASM_SMALL_H