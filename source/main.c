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

#include "execution_timer.h"
#include "memcpy.h"

#define GENERIC_RAM_ADDRESS 0x20000000

int useless[] = {0, 1, 2, 3, 4, 5, 6, 7};

int main (void) {

    timer_init();

    while(1) {

        // Set safe default values for generic timing function parameters
        void* default_dst = (void*)GENERIC_RAM_ADDRESS;
        memcpy_ptr default_func = tare;

        // A breakpoint will be set for the timing function and parameters
        // will be loaded by debug probe for each benchmark test.
        // Guarantee that no data is copied if running unsupervised.
        time_execution(default_dst, default_dst, 0, default_func);
        ++useless[0];
    }
}