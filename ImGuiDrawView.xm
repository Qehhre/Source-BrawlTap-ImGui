#import "Helper/x2nios.h"

#import "Esp/ImGuiDrawView.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#include "KittyMemory/imgui.h"
#include "KittyMemory/imgui_internal.h"
#include "KittyMemory/imgui_impl_metal.h"
#import <Foundation/Foundation.h>
#import <os/log.h>
#import "pthread.h"
#include <cmath>
#include <deque>
#include <vector>
#include <fstream>
#include "Helper/Obfuscate.h"
#include "Helper/Vector3.h"
#include "Helper/Vector2.h"
#include "Helper/Quaternion.h"
#include "Helper/Monostring.h"
#include <vector>
#import <dlfcn.h>
#include <map>

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#include <unistd.h>
#include <string.h>

#import "Helper/Font.h"
#import "Helper/Functions/Hooks.h"


#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kScale [UIScreen mainScreen].scale



ImVec4 accentcolor = ImColor(15,0,255,255);
ImColor frame = (accentcolor);

@interface ImGuiDrawView () <MTKViewDelegate>
//@property (nonatomic, strong) IBOutlet MTKView *mtkView;
@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;

@end
@implementation ImGuiDrawView

ImFont* font1;
ImFont* font2;
ImFont* asteria;
ImFont* asteria2;

static bool MenDeal = true;

#define BundlePath @"/Library/PreferenceBundles/Tweak.bundle"
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];

    if (!self.device) abort();

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;

    ImGui::StyleColorsDark();
    auto& Style = ImGui::GetStyle();

    Style.Colors[ImGuiCol_WindowBg] = ImColor(55,55,55);
    Style.Colors[ImGuiCol_Border] = ImColor(0,0,0,0);
    Style.Colors[ImGuiCol_CheckMark] = frame;
    Style.Colors[ImGuiCol_FrameBg] = frame;
    Style.Colors[ImGuiCol_Button] = ImColor(31,29,31);
    Style.Colors[ImGuiCol_ButtonHovered] = ImColor(31,29,31);
    Style.Colors[ImGuiCol_ButtonActive] = ImColor(31,29,31);

    io.Fonts->ClearFonts();
    ImFontConfig font_cfg;
    ImFont* PixelFonts;
    font_cfg.SizePixels = 18.0f;
    
    font_cfg.GlyphRanges = io.Fonts->GetGlyphRangesCyrillic();

    io.Fonts->AddFontFromMemoryTTF(&Font, sizeof Font, 15.0f,&font_cfg);
    asteria=io.Fonts->AddFontFromMemoryTTF(&Font, sizeof Font , 20.0f ,&font_cfg);
    asteria2=io.Fonts->AddFontFromMemoryTTF(&Font, sizeof Font , 21.0f ,&font_cfg);
    font1=io.Fonts->AddFontFromMemoryTTF(&Font, sizeof Font , 60.0f ,&font_cfg);
    font2=io.Fonts->AddFontFromMemoryTTF(&Font, sizeof Font , 28.0f ,&font_cfg);

    ImGui_ImplMetal_Init(_device);

    return self;
}

+ (void)showChange:(BOOL)open
{
    MenDeal = open;
}

static UITextField *Norecord;


- (MTKView *)mtkView
{
    return (MTKView *)self.view;
}



- (void)loadView
{
    CGFloat w = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width;
    CGFloat h = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height;
    self.view = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mtkView.device = self.device;
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.mtkView.clipsToBounds = YES;
    
}

void ColorPicker(const char* name, ImVec4 &color) {
    static ImVec4 backup_color;

    bool open_popup = ImGui::ColorButton((std::string(name) + std::string("##3b")).c_str(), color);
    //open_popup |= ImGui::Button("Palette");
    if (open_popup) {
        ImGui::OpenPopup(name);
        backup_color = color;
    }
    if (ImGui::BeginPopup(name)) {
        ImGui::Spacing();
        ImGui::Text("Select Color");
        ImGui::Separator();
        ImGui::ColorPicker4("##picker", (float *) &color,ImGuiColorEditFlags_NoSidePreview |
                                                         ImGuiColorEditFlags_NoSmallPreview);
        ImGui::SameLine();

        ImGui::BeginGroup(); // Lock X position
        ImGui::Text("Current");
        ImGui::ColorButton("##current", color,
                           ImGuiColorEditFlags_NoPicker | ImGuiColorEditFlags_AlphaPreviewHalf,
                           ImVec2(60, 40));
        ImGui::Text("Previous");
        if (ImGui::ColorButton("##previous", backup_color, ImGuiColorEditFlags_NoPicker | ImGuiColorEditFlags_AlphaPreviewHalf, ImVec2(60, 40))) {
            color = backup_color;
        }
        ImGui::EndGroup();
        ImGui::EndPopup();
    }
}

void AddColorPicker(const char* name, ImVec4 &color, bool prd = false, bool* rainbow = nullptr, bool* pulse = nullptr, bool* dark = nullptr) {
    ImGuiColorEditFlags misc_flags = ImGuiColorEditFlags_AlphaPreview;
    static ImVec4 backup_color;
    bool open_popup = ImGui::ColorButton((std::string(name) + std::string(("##3b"))).c_str(), color, misc_flags);
    if (open_popup) {
        ImGui::OpenPopup(name);
        backup_color = color;
    }
    if (ImGui::BeginPopup(name)) {
        ImGui::Spacing();
        ImGui::Text(("%s"), std::string(name).c_str());
        ImGui::Separator();
        ImGui::ColorPicker4(("##picker"), (float *) &color,misc_flags | ImGuiColorEditFlags_NoSidePreview | ImGuiColorEditFlags_NoSmallPreview | ImGuiColorEditFlags_AlphaBar);
        ImGui::SameLine();
        ImGui::BeginGroup();
        ImGui::Text(("%s"),std::string(("Current")).c_str());
        ImGui::ColorButton(("##current"), color,ImGuiColorEditFlags_NoPicker | ImGuiColorEditFlags_AlphaPreviewHalf,ImVec2(60, 40));
        ImGui::Text(("%s"),std::string(("Previous")).c_str());
        if (ImGui::ColorButton(("##previous"), backup_color,ImGuiColorEditFlags_NoPicker | ImGuiColorEditFlags_AlphaPreviewHalf,ImVec2(60, 40)))color = backup_color;
        ImGui::EndGroup();
        if (prd) {
            if (rainbow) ImGui::Checkbox(("rainbow"), rainbow);
            if (pulse) ImGui::Checkbox(("pulse"), pulse);
            if (dark) ImGui::Checkbox(("dark"), dark);
        }
        ImGui::Spacing();
        ImGui::EndPopup();
    }
}

void SelectableColor(ImU32 color) {
    ImVec2 p_min = ImGui::GetItemRectMin();
    ImVec2 p_max = ImGui::GetItemRectMax();
    ImGui::GetWindowDrawList()->AddRect(p_min, p_max, color);
}

static int subtab;
static int tab;

void ImGui::MultiCombo(const char* label, bool* combos[], const char* items[], int items_count) {
    std::vector<std::string> vec;
    static std::string preview;
    for (int i = 0, j = 0; i < items_count; i++) {
        if (*combos[i]) {
            vec.push_back(items[i]);
            if (j > 2) preview = vec.at(0) + std::string(", ") + vec.at(1) + std::string(", ") + vec.at(2) + std::string(", ...");
            else if (j) preview += std::string(", ") + (std::string)items[i];
            else preview = items[i];
            j++;
        }
    }
    if (BeginCombo(label, preview.c_str())) {
        for (int i = 0; i < items_count; i++) {
            Selectable(items[i], combos[i], ImGuiSelectableFlags_DontClosePopups);
            if (*combos[i]) SelectableColor(ImColor(66,66,66));
        }
        EndCombo();
    }
    preview = ("None");
}

bool renderer_subtab(const char* label, const ImVec2& size_arg, const bool selected)
{
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems)
        return false;

    static float sizeplus = 0.f;

    ImGuiContext& g = *GImGui;
    const ImGuiStyle& style = g.Style;
    const ImGuiID id = window->GetID(label);
    const ImVec2 label_size = ImGui::CalcTextSize(label, NULL, true);

    ImVec2 pos = window->DC.CursorPos;

    ImVec2 size = ImGui::CalcItemSize(size_arg, label_size.x + style.FramePadding.x * 2.0f, label_size.y + style.FramePadding.y * 2.0f);

    const ImRect bb(pos, ImVec2(pos.x + size.x, pos.y + size.y));
    ImGui::ItemSize(size, style.FramePadding.y);
    if (!ImGui::ItemAdd(bb, id))
        return false;

    bool hovered, held;
    bool pressed = ImGui::ButtonBehavior(bb, id, &hovered, &held, 0);

    if (hovered || held)
        ImGui::SetMouseCursor(7);

    if (selected) {
        window->DrawList->AddRectFilled({ bb.Min.x - 12,bb.Min.y - 3 }, { bb.Min.x - 5,bb.Max.y + 4 }, ImColor(accentcolor));
        window->DrawList->AddRectFilledMultiColor({ bb.Min.x - 10,bb.Min.y - 3 }, { bb.Min.x + 170,bb.Max.y + 4 }, ImColor(46, 46, 46), ImColor(34, 34, 34), ImColor(34, 34, 34), ImColor(46, 46, 46));


        window->DrawList->AddText(ImVec2(bb.Min.x, bb.Min.y + size_arg.y / 2 - ImGui::CalcTextSize(label).y / 2), ImColor(230, 230, 230), label);

    }
    else {

        window->DrawList->AddText(ImVec2(bb.Min.x, bb.Min.y + size_arg.y / 2 - ImGui::CalcTextSize(label).y / 2), ImColor(140, 140, 140), label);

    }

    return pressed;
}

void render_subtab()
{

    ImGui::SetCursorPos({ 21,19 });

    ImGui::BeginGroup();
    {
        if (tab == 0) {

            if (renderer_subtab("Visual", ImVec2(250, 25), subtab == 0 ? true : false))
                subtab = 0;
            ImGui::Spacing();
            ImGui::Spacing();
            if (renderer_subtab("Chams", ImVec2(250, 25), subtab == 1 ? true : false))
                subtab = 1;
        }
        if (tab == 1) {

            if (renderer_subtab("AimBot", ImVec2(250, 25), subtab == 0 ? true : false))
                subtab = 0;
            ImGui::Spacing();
            ImGui::Spacing();
            if (renderer_subtab("SpinBot", ImVec2(250, 25), subtab == 1 ? true : false))
                subtab = 1;
        }
        if (tab == 2) {

            if (renderer_subtab("Weapon", ImVec2(250, 25), subtab == 0 ? true : false))
                subtab = 0;
            ImGui::Spacing();
            ImGui::Spacing();
            if (renderer_subtab("Knife", ImVec2(250, 25), subtab == 1 ? true : false))
                subtab = 1;
        }
        if (tab == 3) {

            if (renderer_subtab("Menu settings", ImVec2(250, 25), subtab == 0 ? true : false))
                subtab = 0;
            
        }
    }
    ImGui::EndGroup();

}

float menu_alpha = 0.0f;

void update_menu() {
    if (MenDeal) {
        if (menu_alpha < 1.0f) {
            menu_alpha += 0.01f; // Увеличиваем прозрачность меню на каждом кадре
        }
    } else{
        if (menu_alpha > 0.0f) {
            menu_alpha -= 0.01f; // Уменьшаем прозрачность меню на каждом кадре
        }
    }   
}

#pragma mark - Interaction



- (void)updateIOWithTouchEvent:(UIEvent *)event
{
    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self.view];
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);

    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches)
    {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled)
        {
            hasActiveTouch = YES;
            break;
        }
    }
    io.MouseDown[0] = hasActiveTouch;

   

    
}

 

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}



- (void)drawInMTKView:(MTKView*)view
{


 


    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;


    CGFloat framebufferScale = view.window.screen.nativeScale ?: UIScreen.mainScreen.nativeScale;
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    io.DeltaTime = 1 / float(view.preferredFramesPerSecond ?: 60);
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];

    
    
   
        static bool show_line = false; 
        if (MenDeal == true) 
        {
            [self.view setUserInteractionEnabled:YES];
        } 
        else if 
        (MenDeal == false) 
        {
           
            [self.view setUserInteractionEnabled:NO];

        }
        
     

        MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
        if (renderPassDescriptor != nil)
        {
            id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
            [renderEncoder pushDebugGroup:@"ImGui Jane"];

            ImGui_ImplMetal_NewFrame(renderPassDescriptor);
            ImGui::NewFrame();
            
            ImFont* font = ImGui::GetFont();
            font->Scale = 16.f / font->FontSize;
            
            CGFloat x = (([UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width) - 360) / 2;
            CGFloat y = (([UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height) - 320) / 2;
            
            ImGui::SetNextWindowPos(ImVec2(x, y), ImGuiCond_FirstUseEver);
            //ImGui::SetNextWindowSize(ImVec2(300, 300), ImGuiCond_FirstUseEver);

            
            

            
            if (MenDeal == true)
            {
                
                ImGui::PushStyleColor(ImGuiCol_Border, ImVec4(ImColor(55,55,55)));
                ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 5);
                /*Imgui::PushStyleVar(ImGuiStyleVar_Alpha,menu_alpha);*/

                ImGui::Begin(ENCRYPT("BrawlTap parasha"), nullptr, ImGuiWindowFlags_NoDecoration);
                ImGui::PopStyleColor();
                ImGui::SetWindowSize("BrawlTap parasha", ImVec2(450,325));
                ImGui::PushStyleColor(ImGuiCol_FrameBg,ImVec4(accentcolor.x, accentcolor.y, accentcolor.z, accentcolor.w - 200));
                ImGui::PushStyleColor(ImGuiCol_Button,ImVec4(accentcolor.x, accentcolor.y, accentcolor.z, accentcolor.w - 200));
                ImGui::PushStyleColor(ImGuiCol_ButtonHovered,ImVec4(accentcolor.x, accentcolor.y, accentcolor.z, accentcolor.w - 200));
                ImGui::PushStyleColor(ImGuiCol_ButtonActive,ImVec4(accentcolor.x, accentcolor.y, accentcolor.z, accentcolor.w - 200));
                const auto& p = ImGui::GetWindowPos();

                ImGui::SetCursorPos(ImVec2(5,5));
                ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(ImColor(31,29,32)));
                ImGui::BeginChild("tabs",ImVec2(445,40));
                ImGui::PopStyleColor();

                ImGui::SetCursorPos(ImVec2(20,9));
                ImGui::PushFont(asteria2);
                ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(ImColor(accentcolor)));
                ImGui::Text("BrawlTap Parasha");
                ImGui::PopStyleColor();
                ImGui::PopFont();

                ImGui::SetCursorPos(ImVec2(20,9));
                ImGui::PushFont(asteria);
                ImGui::Text("BrawlTap Parasha");
                ImGui::PopFont();

                ImGui::SetCursorPos(ImVec2(125,-5));
                ImGui::BeginGroup();
                if (ImGui::tab("Player",   tab == 0))tab = 0; ImGui::SameLine();
                if (ImGui::tab("AimBot", tab == 1))tab = 1; ImGui::SameLine();
                if (ImGui::tab("Skins",   tab == 2))tab = 2; ImGui::SameLine();
                if (ImGui::tab("Misc",  tab == 3))tab = 3;
                ImGui::EndGroup();
                ImGui::EndChild();

                //subtabs

                ImGui::GetForegroundDrawList()->AddRectFilled(ImVec2(p.x + 5, p.y + 45), ImVec2(p.x + 103, p.y + 45), ImColor(1,1,1), 0, 0);

                ImGui::SetCursorPos(ImVec2(5,40));
                ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(ImColor(31,29,32)));
                ImGui::BeginChild("subtabs",ImVec2(100,280));
                render_subtab();
                ImGui::PopStyleColor();
                ImGui::EndChild();

                ImGui::SetCursorPos(ImVec2(105,40));
                ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(ImColor(19,17,21)));
                ImGui::BeginChild("main", ImVec2(345,280));

                ImGui::SetCursorPos(ImVec2(8,8));
                ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(ImColor(31,29,32)));
                ImGui::BeginChild("scroll", ImVec2(325,265));
                if(tab == 0){
                    if (subtab == 0){
                        ImGui::BeginChild("child1", ImVec2(160,250), true);
                        ImGui::Text("Main");
                        ImGui::Spacing();

                        ImGui::Checkbox(ENCRYPT("Enable"), &espen);
                        ImGui::SameLine();
                        ColorPicker(ENCRYPT("VisColor"), visibleCol);
                        ImGui::SameLine();
                        ColorPicker(ENCRYPT("InisColor"), invisibleCol);
                        ImGui::Checkbox(ENCRYPT("Box"), &espbox);
                            if(espbox){
                                ImGui::Spacing();
                                ImGui::SliderFloat(ENCRYPT("Stroke"), &espstroke,0.0f, 5.0f );
                                ImGui::SliderFloat(ENCRYPT("Round"), &espround,0.0f, 10.0f );
                                ImGui::Checkbox(ENCRYPT("Filled##box"), &espfill);
                                if (espfill) {
                                    ImGui::Spacing();
                                    ImGui::SliderFloat(ENCRYPT("Fill value##box"), &espfillp, 20, 80);
                                    ImGui::Checkbox(ENCRYPT("Fill gradient##box"), &espgradient);
                                }
                            }
                        
                        ImGui::Checkbox(ENCRYPT("Health"), &esphealth);
                            if(esphealth){
                                ImGui::SliderFloat(ENCRYPT("Stroke##hp"), &esphpsize ,0.0f, 10.0f );
                            }
                        ImGui::Checkbox(ENCRYPT("Armor"), &esparm);
                        ImGui::Checkbox(ENCRYPT("Skeleton"), &espskeleton);
                            
                        ImGui::Checkbox(ENCRYPT("NickName"), &espname);
                        ImGui::Checkbox(ENCRYPT("Weapon"), &espweapon);    
                        ImGui::EndChild();


                        ImGui::SameLine(0,1);
                        ImGui::BeginChild("child2", ImVec2(160,250), true);
                        ImGui::Text("Misc");
                        ImGui::Spacing();   

ImGui::Text(ENCRYPT("Box color"));
                        ImGui::SameLine();
                        ColorPicker(ENCRYPT("VisColor"), visibleCol);
                        ImGui::SameLine();
                        ColorPicker(ENCRYPT("InisColor"), invisibleCol);

ImGui::Text("Accent color");
                        ImGui::SameLine();
                        ColorPicker(ENCRYPT("Accent"), accentcolor);

                        ImGui::EndChild();
                    }
if (subtab == 1){
	ImGui::BeginChild("child1", ImVec2(160,250), true);
                        ImGui::Text("Main");
                        ImGui::Spacing();

ImGui::Text("Not Work");                           
                        ImGui::EndChild();
				
					}
                }


                ImGui::PopStyleColor();
                ImGui::EndChild();
                //ImGui::PopStyleVar();

                ImGui::PopStyleColor();
                ImGui::EndChild();



                ImGui::PopStyleColor();
                ImGui::PopStyleColor();
                ImGui::PopStyleColor();
                ImGui::PopStyleColor();

                ImGui::End();
                ImGui::PopStyleVar();
                ImGui::PopStyleVar();
                
            }

            ImDrawList* draw_list = ImGui::GetForegroundDrawList();

            DrawEsp();
            
            ImGui::Render();
            ImDrawData* draw_data = ImGui::GetDrawData();
            ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);

            [renderEncoder popDebugGroup];
            [renderEncoder endEncoding];

            [commandBuffer presentDrawable:view.currentDrawable];
            
        }
        

        [commandBufferg commit];
          
}

- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size
{
    
}



void hooking(){
    HOOK(ENCRYPTOFFSET("самищи"), Player_Update, old_Player_Update);
    HOOK(ENCRYPTOFFSET("самищи"), becameinvisible, old_becameinvisible);
    HOOK(ENCRYPTOFFSET("самищи"), becamevisible, old_becamevisible);
    
    //HOOK(ENCRYPTOFFSET("самищи"), hitts, old_hitts);

    IsLocal = (bool (*)(void *))getRealOffset(ENCRYPTOFFSET("самищи"));
    AddScore = (void (*)(void *, int))getRealOffset(ENCRYPTOFFSET("самищи"));
    AddKill = (void (*)(void *))самищи(ENCRYPTOFFSET("0x1AA58EC"));
    GetPlayerTeam = (int (*)(void *))getRealOffset(ENCRYPTOFFSET("самищи"));
    GetPlayerArmor = (int (*)(void *))getRealOffset(ENCRYPTOFFSET("самищи"));
    GetPlayerHealth = (int (*)(void *))getRealOffset(ENCRYPTOFFSET("самищи"));
    get_position = (Vector3 (*)(void *))getRealOffset(ENCRYPTOFFSET("самищи"));
    WorldToScreenPoint = (Vector3 (*)(void *, Vector3, int ))getRealOffset(ENCRYPTOFFSET("самищи"));
    get_camera = (void* (*)())getRealOffset(ENCRYPTOFFSET("самищи"));
    get_transform = (void *(*)(void*))getRealOffset(ENCRYPTOFFSET("самищи"));
    get_BipedMap = (void *(*)(void*))getRealOffset(ENCRYPTOFFSET("самищи"));
    GetNickName = (monoString* (*)(void *))getRealOffset(ENCRYPTOFFSET("самищи"));
    set_position = (void (*)(void*, Vector3))getRealOffset(ENCRYPTOFFSET("самищи"));
    set_TpsView = (void (*)(void*))самищи(ENCRYPTOFFSET("0x18168A4"));
    set_FpsView = (void (*)(void*))getRealOffset(ENCRYPTOFFSET("самищи"));
    get_forward = (Vector3 (*)(void*))getRealOffset(ENCRYPTOFFSET("самищи"));
    Linecast228 = (bool (*)(Vector3, Vector3, int))getRealOffset(ENCRYPTOFFSET("самищи"));
    GetWeaponID = (int (*)(void*))getRealOffset(ENCRYPTOFFSET("самищи"));
    GetActiveWeapon = (void* (*)(void*))getRealOffset(ENCRYPTOFFSET("самищи"));  
    get_up = (Vector3 (*)(void*))getRealOffset(ENCRYPTOFFSET("самищи")); 
    get_gravity = (Vector3 (*)())getRealOffset(ENCRYPTOFFSET("самищи"));
    get_width = (int (*)())getRealOffset(ENCRYPTOFFSET("самищи"));
    get_height = (int (*)())getRealOffset(ENCRYPTOFFSET("самищи"));
}

void *hack_thread(void *) {
    sleep(5);
    hooking();
    pthread_exit(nullptr);
    return nullptr;
}

void __attribute__((constructor)) initialize() {
    pthread_t hacks;
    pthread_create(&hacks, NULL, hack_thread, NULL); 
}

@end





