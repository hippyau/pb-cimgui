
#include "../imgui/imgui.h"
#include "cimgui.h"

// to use placement new (?)
#define IMGUI_DEFINE_PLACEMENT_NEW
#include "../imgui/imgui_internal.h"
#include "imgui_impl_dx11.h"
#include <d3d11.h>
#define DIRECTINPUT_VERSION 0x0800
#include <dinput.h>
#include <tchar.h>
#include <wincodec.h>
#include "WICTextureLoader\WICTextureLoader.h"
#include "WICTextureLoader\ScreenGrab.h"


typedef void(*callback)();


// load an image from a file (png, jpg...) and return a pointer, a ImTexture ID
// returns 0 on failure
CIMGUI_API void* _LoadImageFromFile(wchar_t* filename);

// load an image from memory (png, jpg...) and return a pointer, a ImTexture ID
// wicdata is a pointer to memory to the start the file contents, wicsize is the number of bytes
// returns 0 on failure
CIMGUI_API void* _LoadImageFromMemory(CONST uint8_t* wicData, size_t wicSize);

// release a texture using an ImTexture ID provided by a _LoadImage* call
// returns 0 on failure, else success?
CIMGUI_API int _ReleaseImage(ID3D11ShaderResourceView* ImTextureID);

// supply a pointer to memory containing a ttf file with it's size, at the wanted pixels
CIMGUI_API void* _LoadFontFromMemory(void* font_data, size_t font_size, float font_pixels);

// supply a string filename for a ttf file at desired size
CIMGUI_API void* _LoadFontFromFile(CONST char* filename, float font_pixel_size);

// set the background colour
CIMGUI_API void _SetBackgroundColour(float r, float g, float b, float a);

// provide a class name, title, style, x,y,w,h
CIMGUI_API int _Run_GUI(const wchar_t* classname, const wchar_t* title, int style, int x, int y, int w, int h, int vsync, callback ptr_reg_callback, callback ptr_reg_init_callback, callback ptr_reg_shutdown_callback());



