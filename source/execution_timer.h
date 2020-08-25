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


#include <stdint.h>
#include "memcpy.h"

// Forward declare the timer utility functions
void timer_init (void);

int time_execution (void* dst, const void* src, size_t len, memcpy_ptr func);

void* tare (void*, const void*, size_t);