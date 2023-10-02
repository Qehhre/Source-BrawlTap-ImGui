#pragma once

#include <stdint.h>
#include <algorithm>
#include <iostream>
#include <iomanip>
#include <map>

#include "KittyMemory/imgui.h"
#include "KittyMemory/imgui_internal.h"

namespace custom_interface {
    bool tab(const char* label, const char* nametext, bool selected);
    bool subtab(const char* label, bool selected);
    bool substabs(const char* label, bool selected, ImVec2 size);
}