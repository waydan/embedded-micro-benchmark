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

#include "memcpy_c.h"

void* memcpy_c_forward (void* dst, const void* src, size_t len) {
    for (size_t i = 0; i < len; ++i)
        *((char*)dst + i) = *((char*)src + i);
    return dst;
}

void* memcpy_c_reverse (void* dst, const void* src, size_t len) {
    for (; --len != (size_t)(-1) ;)
        *((char*)dst + len) = *((char*)src + len);
    return dst;
}