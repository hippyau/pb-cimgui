//  PB-CIMGUI Helpers



#include "../imgui/imgui.h"
#include "cimgui.h"
#include "pb-cimgui.h"

// to use placement new (?)
#define IMGUI_DEFINE_PLACEMENT_NEW
#include "../imgui/imgui_internal.h"
#include "imgui_impl_dx11.h"
#include <d3d11.h>
#define DIRECTINPUT_VERSION 0x0800
#include <dinput.h>




// Our DirectX Devices
static ID3D11Device*            g_pd3dDevice;// = NULL;
static ID3D11DeviceContext*     g_pd3dDeviceContext;// = NULL;
static IDXGISwapChain*          g_pSwapChain;// = NULL;
static ID3D11RenderTargetView*  g_mainRenderTargetView;// = NULL;

static ImVec4					bg_Colour;// = ImVec4(0.0f, 0.0f, 0.0f, 1.00f);



// load an image from a file (png, jpg...) and return a pointer, a ImTexture ID
// returns 0 on failure
CIMGUI_API void* _LoadImageFromFile(wchar_t* filename) {
	ID3D11Resource* texture;
	ID3D11ShaderResourceView* srv;

	HRESULT hr = DirectX::CreateWICTextureFromFile(g_pd3dDevice, g_pd3dDeviceContext, filename, &texture, &srv);
	if (FAILED(hr))
		return 0;
	return (void*)srv;
}

// load an image from memory (png, jpg...) and return a pointer, a ImTexture ID
// wicdata is a pointer to memory to the start the file contents, wicsize is the number of bytes
// returns 0 on failure
CIMGUI_API void* _LoadImageFromMemory(CONST uint8_t* wicData, size_t wicSize) {
	ID3D11Resource* texture;
	ID3D11ShaderResourceView* srv;

	HRESULT hr = DirectX::CreateWICTextureFromMemory(g_pd3dDevice, g_pd3dDeviceContext, wicData, wicSize, &texture, &srv);
	if (FAILED(hr))
		return 0;
	return (void*)srv;
}


// load a bitmap from memory and return a pointer, a ImTexture ID
// wicdata is a pointer to memory to the start the file contents, wicsize is the number of bytes
// returns 0 on failure
CIMGUI_API void* _LoadBitmapFromMemory(CONST uint8_t* wicData, size_t wicSize) {
	ID3D11Resource* texture;
	ID3D11ShaderResourceView* srv;

	HRESULT hr = DirectX::CreateWICTextureFromMemory(g_pd3dDevice, g_pd3dDeviceContext, wicData, wicSize, &texture, &srv);
	if (FAILED(hr))
		return 0;
	return (void*)srv;
}


CIMGUI_API int _ImageWidth(ID3D11ShaderResourceView* ImTextureID) {
	ID3D11Resource* textresc;
	ImTextureID->GetResource(&textresc);
	ID3D11Texture2D* tex = (ID3D11Texture2D*)textresc;
	D3D11_TEXTURE2D_DESC desc;

	tex->GetDesc(&desc);
	return desc.Width;
}

CIMGUI_API int _ImageHeight(ID3D11ShaderResourceView* ImTextureID) {
	ID3D11Resource* textresc;
	ImTextureID->GetResource(&textresc);
	ID3D11Texture2D* tex = (ID3D11Texture2D*)textresc;
	D3D11_TEXTURE2D_DESC desc;

	tex->GetDesc(&desc);
	return desc.Height;
}

// release a texture using an ImTexture ID provided by a _LoadImage* call
// returns 0 on failure, else success?
CIMGUI_API int _ReleaseImage(ID3D11ShaderResourceView* ImTextureID) {
	//ID3D11Resource* texture;

	if (ImTextureID != NULL) {
		//ImTextureID->GetResource(&texture);
		//texture->Release();
		ImTextureID->Release();
		return 1;
	}
	return 0;
}



CIMGUI_API void* _LoadFontFromMemory(void* font_data, size_t font_size, float font_pixels) {
	ImGuiIO& io = ImGui::GetIO();

	ImFont* font = io.Fonts->AddFontFromMemoryTTF(font_data, font_size, font_pixels, NULL, NULL);
	return (void*)font;
}


CIMGUI_API void* _LoadFontFromFile(CONST char* filename, float font_pixel_size) {
	ImGuiIO& io = ImGui::GetIO();
	return (void*)io.Fonts->AddFontFromFileTTF(filename, font_pixel_size);
}


CIMGUI_API void _SetBackgroundColour(float r, float g, float b, float a) {
	bg_Colour.x = r;
	bg_Colour.y = g;
	bg_Colour.z = b;
	bg_Colour.w = a;
}


void CreateRenderTarget()
{
	DXGI_SWAP_CHAIN_DESC sd;
	g_pSwapChain->GetDesc(&sd);

	// Create the render target
	ID3D11Texture2D* pBackBuffer;
	D3D11_RENDER_TARGET_VIEW_DESC render_target_view_desc;
	ZeroMemory(&render_target_view_desc, sizeof(render_target_view_desc));
	render_target_view_desc.Format = sd.BufferDesc.Format;
	render_target_view_desc.ViewDimension = D3D11_RTV_DIMENSION_TEXTURE2D;
	g_pSwapChain->GetBuffer(0, __uuidof(ID3D11Texture2D), (LPVOID*)&pBackBuffer);
	g_pd3dDevice->CreateRenderTargetView(pBackBuffer, &render_target_view_desc, &g_mainRenderTargetView);
	pBackBuffer->Release();
}

void CleanupRenderTarget()
{
	if (g_mainRenderTargetView) { g_mainRenderTargetView->Release(); g_mainRenderTargetView = NULL; }
}

HRESULT CreateDeviceD3D(HWND hWnd)
{
	// Setup swap chain
	DXGI_SWAP_CHAIN_DESC sd;
	{
		ZeroMemory(&sd, sizeof(sd));
		sd.BufferCount = 2;
		sd.BufferDesc.Width = 0;
		sd.BufferDesc.Height = 0;
		sd.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
		sd.BufferDesc.RefreshRate.Numerator = 60;
		sd.BufferDesc.RefreshRate.Denominator = 1;
		sd.Flags = DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH;
		sd.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
		sd.OutputWindow = hWnd;
		sd.SampleDesc.Count = 1;
		sd.SampleDesc.Quality = 0;
		sd.Windowed = TRUE;
		sd.SwapEffect = DXGI_SWAP_EFFECT_DISCARD;
	}

	UINT createDeviceFlags = 0;
	//createDeviceFlags |= D3D11_CREATE_DEVICE_DEBUG;
	D3D_FEATURE_LEVEL featureLevel;
	const D3D_FEATURE_LEVEL featureLevelArray[2] = { D3D_FEATURE_LEVEL_11_0, D3D_FEATURE_LEVEL_10_0, };
	if (D3D11CreateDeviceAndSwapChain(NULL, D3D_DRIVER_TYPE_HARDWARE, NULL, createDeviceFlags, featureLevelArray, 2, D3D11_SDK_VERSION, &sd, &g_pSwapChain, &g_pd3dDevice, &featureLevel, &g_pd3dDeviceContext) != S_OK)
		return E_FAIL;
	
	CreateRenderTarget();

	return S_OK;
}

void CleanupDeviceD3D()
{
	CleanupRenderTarget();
	if (g_pSwapChain) { g_pSwapChain->Release(); g_pSwapChain = NULL; }
	if (g_pd3dDeviceContext) { g_pd3dDeviceContext->Release(); g_pd3dDeviceContext = NULL; }
	if (g_pd3dDevice) { g_pd3dDevice->Release(); g_pd3dDevice = NULL; }
}


extern LRESULT ImGui_ImplWin32_WndProcHandler(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam);
LRESULT WINAPI WndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	if (ImGui_ImplWin32_WndProcHandler(hWnd, msg, wParam, lParam))
		return true;

	switch (msg)
	{
	case WM_SIZE:
		if (g_pd3dDevice != NULL && wParam != SIZE_MINIMIZED)
		{
			ImGui_ImplDX11_InvalidateDeviceObjects();
			CleanupRenderTarget();
			g_pSwapChain->ResizeBuffers(0, (UINT)LOWORD(lParam), (UINT)HIWORD(lParam), DXGI_FORMAT_UNKNOWN, 0);
			CreateRenderTarget();
			ImGui_ImplDX11_CreateDeviceObjects();
		}
		return 0;
	case WM_SYSCOMMAND:
		if ((wParam & 0xfff0) == SC_KEYMENU) // Disable ALT application menu
			return 0;
		break;
	case WM_DESTROY:
		PostQuitMessage(0);
		return 0;
	}
	return DefWindowProc(hWnd, msg, wParam, lParam);
}



// provide a class name, title, style, x,y,w,h
CIMGUI_API int _Run_GUI(const wchar_t* classname, const wchar_t* title, int style, int x, int y, int w, int h, int vsync, callback ptr_reg_callback, callback ptr_reg_init_callback, callback ptr_reg_shutdown_callback())
{

	g_pd3dDevice = NULL;
	g_pd3dDeviceContext = NULL;
	g_pSwapChain = NULL;
	g_mainRenderTargetView = NULL;
	//bg_Colour = ImVec4(0.0f, 0.0f, 0.0f, 1.00f);


	// Create application window
	WNDCLASSEX wc = { sizeof(WNDCLASSEX), CS_CLASSDC, WndProc, 0L, 0L, GetModuleHandle(NULL), NULL, LoadCursor(NULL, IDC_ARROW), NULL, NULL, classname, NULL };
	RegisterClassEx(&wc);
	HWND hwnd = CreateWindow(classname, title, style, x, y, w, h, NULL, NULL, wc.hInstance, NULL);

	// As required by WIC texture loader
#if (_WIN32_WINNT >= 0x0A00 ) 
	{  /*_WIN32_WINNT_WIN10*/
	Microsoft::WRL::Wrappers::RoInitializeWrapper initialize(RO_INIT_MULTITHREADED);
	if (FAILED(initialize))
		UnregisterClass(classname, wc.hInstance);
	return 1;
	}
#else
	HRESULT hr = CoInitializeEx(nullptr, COINITBASE_MULTITHREADED);
	if (FAILED(hr)) {
		UnregisterClass(classname, wc.hInstance);
		return 1;
	}
#endif

	// Initialize Direct3D
	if (CreateDeviceD3D(hwnd) < 0)
	{
		CleanupDeviceD3D();
		UnregisterClass(classname, wc.hInstance);
		printf("failed to init directX\n");
		return 1;
	}

	// Show the window
	ShowWindow(hwnd, SW_SHOWDEFAULT);
	UpdateWindow(hwnd);

	// Setup ImGui binding
	ImGui_ImplDX11_Init(hwnd, g_pd3dDevice, g_pd3dDeviceContext);

	// Setup style
	//ImGui::StyleColorsClassic();
	ImGui::StyleColorsDark();

	// Load Fonts
	// - If no fonts are loaded, dear imgui will use the default font. You can also load multiple fonts and use ImGui::PushFont()/PopFont() to select them. 
	// - AddFontFromFileTTF() will return the ImFont* so you can store it if you need to select the font among multiple. 
	// - If the file cannot be loaded, the function will return NULL. Please handle those errors in your application (e.g. use an assertion, or display an error and quit).
	// - The fonts will be rasterized at a given size (w/ oversampling) and stored into a texture when calling ImFontAtlas::Build()/GetTexDataAsXXXX(), which ImGui_ImplXXXX_NewFrame below will call.
	// - Read 'extra_fonts/README.txt' for more instructions and details.
	// - Remember that in C/C++ if you want to include a backslash \ in a string literal you need to write a double backslash \\ !
	//ImGuiIO& io = ImGui::GetIO();
	////io.Fonts->AddFontFromMemoryTTF()
	//io.Fonts->AddFontDefault();
	//io.Fonts->AddFontFromFileTTF("../../extra_fonts/Roboto-Medium.ttf", 16.0f);
	//io.Fonts->AddFontFromFileTTF("../../extra_fonts/Cousine-Regular.ttf", 15.0f);
	//io.Fonts->AddFontFromFileTTF("../../extra_fonts/DroidSans.ttf", 16.0f);
	//io.Fonts->AddFontFromFileTTF("../../extra_fonts/ProggyTiny.ttf", 10.0f);
	//ImFont* font = io.Fonts->AddFontFromFileTTF("c:\\Windows\\Fonts\\ArialUni.ttf", 18.0f, NULL, io.Fonts->GetGlyphRangesJapanese());
	//IM_ASSERT(font != NULL);

	// run the init callback supplied, if not null 
	if (ptr_reg_init_callback) (*ptr_reg_init_callback)();


	MSG msg;
	ZeroMemory(&msg, sizeof(msg));
	// Main loop
	while (msg.message != WM_QUIT)
	{
		// You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
		// - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application.
		// - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application.
		// Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
		if (PeekMessage(&msg, NULL, 0U, 0U, PM_REMOVE))
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
			continue;
		}

		ImGui_ImplDX11_NewFrame();

		// run the callback to pb where we create the UI widgets
		if (ptr_reg_callback) (*ptr_reg_callback)();

		// Rendering
		g_pd3dDeviceContext->OMSetRenderTargets(1, &g_mainRenderTargetView, NULL);
		g_pd3dDeviceContext->ClearRenderTargetView(g_mainRenderTargetView, (float*)&bg_Colour);
		ImGui::Render();

		switch (vsync) {
		case 1:
			g_pSwapChain->Present(1, 0); // Present with vsync
			break;
		case 0:
			g_pSwapChain->Present(0, 0); // Present without vsync
			break;
		}

	}

	// run the shutdown callback supplied, if not null 
	if (ptr_reg_shutdown_callback) (*ptr_reg_shutdown_callback)();

	ImGui_ImplDX11_Shutdown();
	CleanupDeviceD3D();
	UnregisterClass(classname, wc.hInstance);

	return 0;
}
