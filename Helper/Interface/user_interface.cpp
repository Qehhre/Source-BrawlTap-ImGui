#include "user_interface.h"
ImFont* icfont;
ImFont* tabs;

struct tab_anim
{
    int hovered_anim;
    int active_anim;
};

bool custom_interface::tab(const char* label, const char* nametext, bool selected)
{
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems)
        return false;

    ImGuiContext& g = *GImGui;
    const ImGuiStyle& style = g.Style;
    const ImGuiID id = window->GetID(label);
    const ImVec2 label_size = ImGui::CalcTextSize(label, NULL, true);
    ImVec2 pos = window->DC.CursorPos;

    const ImRect rect(pos, ImVec2(pos.x + ImGui::CalcTextSize(label).x + ImGui::CalcTextSize(nametext).x + 30, pos.y + 25));
    ImGui::ItemSize(ImVec4(rect.Min.x, rect.Min.y, rect.Max.x, rect.Max.y + 5), style.FramePadding.y);
    if (!ImGui::ItemAdd(rect, id))
        return false;

    bool hovered, held;
    bool pressed = ImGui::ButtonBehavior(rect, id, &hovered, &held, ImGuiButtonFlags_None);

    static std::map <ImGuiID, tab_anim> anim;
    auto it_anim = anim.find(id);
    if (it_anim == anim.end())
    {
        anim.insert({ id, {0, 0} });
        it_anim = anim.find(id);
    }

   /* if (hovered)
        it_anim->second.hovered_anim += 8 * (1.f - ImGui::GetIO().DeltaTime);
    else
        it_anim->second.hovered_anim -= 8 * (1.f - ImGui::GetIO().DeltaTime);

    if (it_anim->second.hovered_anim > 50)
        it_anim->second.hovered_anim = 50;
    else if (it_anim->second.hovered_anim < 0)
        it_anim->second.hovered_anim = 0;*/

    if (selected)
        it_anim->second.active_anim += 16 * (1.f - ImGui::GetIO().DeltaTime);
    else
        it_anim->second.active_anim -= 16 * (1.f - ImGui::GetIO().DeltaTime);

    if (it_anim->second.active_anim > 155)
        it_anim->second.active_anim = 155;
    else if (it_anim->second.active_anim < 0)
        it_anim->second.active_anim = 0;
    //41 50
    ImColor color;
    if (selected) {
        color = ImColor(255,132,27, 100 + it_anim->second.hovered_anim + it_anim->second.active_anim); // оранжевый
    } else {
        color = ImColor(255, 255, 255, 100 + it_anim->second.hovered_anim + it_anim->second.active_anim); // серый
    }

    if (selected) {
        ImVec2 lineStart(rect.Min.x, rect.Min.y - 15);
        ImVec2 lineEnd(rect.Min.x + ImGui::CalcTextSize(label).x + ImGui::CalcTextSize(nametext).x + 15, rect.Min.y - 15);
        window->DrawList->AddLine(lineStart, lineEnd, color, 4.0f);
    }

    ImGui::PushFont(icfont);
    window->DrawList->AddText(
        ImVec2(rect.Min.x, rect.Min.y),
        color,
        label
    );
    ImGui::PopFont();

    ImVec2 nametextPos(
        rect.Min.x + ImGui::CalcTextSize(label).x + 15,  
        rect.Min.y + 5                       
    );
    window->DrawList->AddText(
        nametextPos,
        color,
        nametext
    );

    return pressed;
}

struct substabs_anim
{
    int button_hovered_anim;
    int button_active_anim;
};

bool custom_interface::substabs(const char* label, bool selected, ImVec2 size) {

    ImGuiWindow* window = ImGui::GetCurrentWindow();
    ImGuiContext& g = *GImGui;
    const ImGuiStyle& style = g.Style;
    const ImGuiID id = window->GetID(label);
    static std::map <ImGuiID, tab_anim> anim;
    auto it_anim = anim.find(id);
    if (it_anim == anim.end())
    {
        anim.insert({ id, {0, 0} });
        it_anim = anim.find(id);
    }

    if (selected)
        it_anim->second.active_anim += 16 * (1.f - ImGui::GetIO().DeltaTime);
    else
        it_anim->second.active_anim -= 16 * (1.f - ImGui::GetIO().DeltaTime);

    if (it_anim->second.active_anim > 155)
        it_anim->second.active_anim = 155;
    else if (it_anim->second.active_anim < 0)
        it_anim->second.active_anim = 0;

    ImColor color;
    if (selected) {
        color = ImColor(255,132,27, 100 + it_anim->second.hovered_anim + it_anim->second.active_anim); // оранжевый
    } else {
        color = ImColor(60, 60, 60, 100 + it_anim->second.hovered_anim + it_anim->second.active_anim); // серый
    }

    if (selected) {
        ImGui::PushStyleColor(ImGuiCol_Button, static_cast<ImVec4>(color));
        ImGui::PushStyleColor(ImGuiCol_ButtonHovered, static_cast<ImVec4>(color));
        ImGui::PushStyleColor(ImGuiCol_ButtonActive, static_cast<ImVec4>(color));
    }
    else {
        ImGui::PushStyleColor(ImGuiCol_Button, static_cast<ImVec4>(color));
        ImGui::PushStyleColor(ImGuiCol_ButtonHovered, static_cast<ImVec4>(color));
        ImGui::PushStyleColor(ImGuiCol_ButtonActive, static_cast<ImVec4>(color));
    }


    bool pressed = false;
    if (ImGui::Button(label, size)) {
        pressed = true;
    }

    ImGui::PopStyleColor(3);

    return pressed;
}

struct subtab_anim
{
    int active_text_anim;
    int active_rect_alpha;
};

bool custom_interface::subtab(const char* label, bool selected)
{
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems)
        return false;

    ImGuiContext& g = *GImGui;
    const ImGuiStyle& style = g.Style;
    const ImGuiID id = window->GetID(label);
    const ImVec2 label_size = ImGui::CalcTextSize(label, NULL, true);
    ImVec2 pos = window->DC.CursorPos;

    const ImRect rect(pos, ImVec2(pos.x + label_size.x, pos.y + 40));
    ImGui::ItemSize(ImVec4(rect.Min.x, rect.Min.y, rect.Max.x + 2.f, rect.Max.y), style.FramePadding.y);
    if (!ImGui::ItemAdd(rect, id))
        return false;

    bool hovered, held;
    bool pressed = ImGui::ButtonBehavior(rect, id, &hovered, &held, ImGuiButtonFlags_None);

    static std::map <ImGuiID, subtab_anim> anim;
    auto it_anim = anim.find(id);
    if (it_anim == anim.end())
    {
        anim.insert({ id, {0, 0} });
        it_anim = anim.find(id);
    }

    if (selected)
        it_anim->second.active_text_anim += 16 * (1.f - ImGui::GetIO().DeltaTime);
    else
        it_anim->second.active_text_anim -= 16 * (1.f - ImGui::GetIO().DeltaTime);

    if (it_anim->second.active_text_anim > 155)
        it_anim->second.active_text_anim = 155;
    else if (it_anim->second.active_text_anim < 0)
        it_anim->second.active_text_anim = 0;

    if (selected)
        it_anim->second.active_rect_alpha += 20 * (1.f - ImGui::GetIO().DeltaTime);
    else
        it_anim->second.active_rect_alpha -= 20 * (1.f - ImGui::GetIO().DeltaTime);

    if (it_anim->second.active_rect_alpha > 255)
        it_anim->second.active_rect_alpha = 255;
    else if (it_anim->second.active_rect_alpha < 0)
        it_anim->second.active_rect_alpha = 0;

    window->DrawList->AddRectFilled(ImVec2(rect.Min.x, rect.Min.y + 26), ImVec2(rect.Max.x, rect.Max.y - 16), ImColor(129, 137, 183, it_anim->second.active_rect_alpha));
    window->DrawList->AddText(ImVec2((rect.Min.x + rect.Max.x) / 2.f - (label_size.x / 2.f), (rect.Min.y + rect.Max.y) / 2.f - (label_size.y / 2.f) - 5), ImColor(255, 255, 255, (100 + it_anim->second.active_text_anim)), label);

    return pressed;
}
