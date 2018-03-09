# pb-cimgui 

![sample](screenshot.png)

This is a PureBasic (PB) wrapper for a slightly modified [cimgui](https://github.com/Extrawurst/cimgui).

pb-cimgui.cpp adds some helper functions to cimgui, that create a DX11 environment and provide basic imaage and font loading.

The _run_gui() function exported by the DLL starts a loop, which then calls back to a specified PB function, which is now your main loop for your PB App.  This loop will exit when the app is closed.

cimgui is a thin c-api wrapper for the excellent C++ intermediate gui [imgui](https://github.com/ocornut/imgui).
Most of the functions have wrapper counterparts now, missing stuff is added on a as-needed basis (PR welcome).
This library is intended as a intermediate layer to be able to use imgui from other languages that can interface with C (like D - see [D-binding](https://github.com/Extrawurst/DerelictImgui))


Usage:

0)  Use Visual Studio 2015 Community Edition or whatever to build pb-cimgui.dll from the pb-cimgui.sln solution.

1)  Include the pb-cimgui.pbi file from the pb directory in PureBasic 5.40 into your project to import DLL functions.  See main.pb for an example usage in PB.


Notes:
* currently cimgui wrapper is based on version [1.53 of imgui](https://github.com/ocornut/imgui/releases/tag/v1.53)




