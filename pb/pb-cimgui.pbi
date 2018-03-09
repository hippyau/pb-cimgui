EnableExplicit
;- DON'T FORMAT INDENTATION ON THIS FILE
;- it seems to screw up because of the function loading macros


#IMGUIDLL = "..\cimgui\debug\pb-cimgui.dll"

#_TERMINATE_IF_DLL_MISSING = 1  ; we give up if we can't load the DLL

;-----------------------------------------------------
; Interface to a modified CImGui DLL, for easy use in PureBasic
; WTFPL 2018 - Rowan MAclachlan 
; 
; This attemps to import and use my compilation of CImGui.dll into PureBasic
; The modified DLL includes functions start a DirectX 11 window, and to load fonts and images 
; It then has a function called _Run_GUI which enter a continious rendering loop, 
; calling back to a specified PureBasic Procedure for every frame, this is where we build the widgets

; I am too lazy to learn to do all the rendering DX11 stuff and to support ImGui directly in Purebasic itself,
; so I basically copied the ImGui DirectX 11 example c++ code into this DLL and extended it for my purposes...
;
; I also used a little script to import the cimgui.h file and the header importer for the enums and structs,
; and did lots of find/replace.  Some structures might not be correct and not looked into yet.
; Not every function has been prototyped yet, though by looking at the completed ones you can work out
; how to convert more. 
;

;  It's very early days, please contribute.


; Disable Unicode in Compiler Options
CompilerIf #PB_Compiler_Unicode
  Debug "cimgui.pbi:  You should disable unicode in the PB compiler settings or improve this interface to support unicode"
  End
CompilerEndIf




;- Enumerations
Enumeration
  #ImGuiWindowFlags_NoTitleBar = 1 << 0
  #ImGuiWindowFlags_NoResize = 1 << 1
  #ImGuiWindowFlags_NoMove = 1 << 2
  #ImGuiWindowFlags_NoScrollbar = 1 << 3
  #ImGuiWindowFlags_NoScrollWithMouse = 1 << 4
  #ImGuiWindowFlags_NoCollapse = 1 << 5
  #ImGuiWindowFlags_AlwaysAutoResize = 1 << 6
  #ImGuiWindowFlags_ShowBorders = 1 << 7
  #ImGuiWindowFlags_NoSavedSettings = 1 << 8
  #ImGuiWindowFlags_NoInputs = 1 << 9
  #ImGuiWindowFlags_MenuBar = 1 << 10
  #ImGuiWindowFlags_HorizontalScrollbar = 1 << 11
  #ImGuiWindowFlags_NoFocusOnAppearing = 1 << 12
  #ImGuiWindowFlags_NoBringToFrontOnFocus = 1 << 13
  #ImGuiWindowFlags_AlwaysVerticalScrollbar = 1 << 14
  #ImGuiWindowFlags_AlwaysHorizontalScrollbar = 1 << 15
  #ImGuiWindowFlags_AlwaysUseWindowPadding = 1 << 16
  #ImGuiWindowFlags_ResizeFromAnySide = 1 << 17
EndEnumeration


Enumeration
  #ImGuiInputTextFlags_CharsDecimal = 1 << 0
  #ImGuiInputTextFlags_CharsHexadecimal = 1 << 1
  #ImGuiInputTextFlags_CharsUppercase = 1 << 2
  #ImGuiInputTextFlags_CharsNoBlank = 1 << 3
  #ImGuiInputTextFlags_AutoSelectAll = 1 << 4
  #ImGuiInputTextFlags_EnterReturnsTrue = 1 << 5
  #ImGuiInputTextFlags_CallbackCompletion = 1 << 6
  #ImGuiInputTextFlags_CallbackHistory = 1 << 7
  #ImGuiInputTextFlags_CallbackAlways = 1 << 8
  #ImGuiInputTextFlags_CallbackCharFilter = 1 << 9
  #ImGuiInputTextFlags_AllowTabInput = 1 << 10
  #ImGuiInputTextFlags_CtrlEnterForNewLine = 1 << 11
  #ImGuiInputTextFlags_NoHorizontalScroll = 1 << 12
  #ImGuiInputTextFlags_AlwaysInsertMode = 1 << 13
  #ImGuiInputTextFlags_ReadOnly = 1 << 14
  #ImGuiInputTextFlags_Password = 1 << 15
  #ImGuiInputTextFlags_NoUndoRedo = 1 << 16
EndEnumeration

Enumeration
  
  #ImGuiTreeNodeFlags_Selected = 1 << 0
  #ImGuiTreeNodeFlags_Framed = 1 << 1
  #ImGuiTreeNodeFlags_AllowItemOverlap = 1 << 2
  #ImGuiTreeNodeFlags_NoTreePushOnOpen = 1 << 3
  #ImGuiTreeNodeFlags_NoAutoOpenOnLog = 1 << 4
  #ImGuiTreeNodeFlags_DefaultOpen = 1 << 5
  #ImGuiTreeNodeFlags_OpenOnDoubleClick = 1 << 6
  #ImGuiTreeNodeFlags_OpenOnArrow = 1 << 7
  #ImGuiTreeNodeFlags_Leaf = 1 << 8
  #ImGuiTreeNodeFlags_Bullet = 1 << 9
  #ImGuiTreeNodeFlags_FramePadding = 1 << 10
  #ImGuiTreeNodeFlags_CollapsingHeader = #ImGuiTreeNodeFlags_Framed | #ImGuiTreeNodeFlags_NoAutoOpenOnLog
EndEnumeration

Enumeration
  
  #ImGuiSelectableFlags_DontClosePopups = 1 << 0
  #ImGuiSelectableFlags_SpanAllColumns = 1 << 1
  #ImGuiSelectableFlags_AllowDoubleClick = 1 << 2
EndEnumeration

Enumeration ;#ImGuiComboFlags_
  
  #ImGuiComboFlags_PopupAlignLeft = 1 << 0
  #ImGuiComboFlags_HeightSmall = 1 << 1
  #ImGuiComboFlags_HeightRegular = 1 << 2
  #ImGuiComboFlags_HeightLarge = 1 << 3
  #ImGuiComboFlags_HeightLargest = 1 << 4
  #ImGuiComboFlags_HeightMask_ = #ImGuiComboFlags_HeightSmall | #ImGuiComboFlags_HeightRegular | #ImGuiComboFlags_HeightLarge | #ImGuiComboFlags_HeightLargest
EndEnumeration

Enumeration ;#ImGuiFocusedFlags_
  
  #ImGuiFocusedFlags_ChildWindows = 1 << 0
  #ImGuiFocusedFlags_RootWindow = 1 << 1
  #ImGuiFocusedFlags_RootAndChildWindows = #ImGuiFocusedFlags_RootWindow | #ImGuiFocusedFlags_ChildWindows
EndEnumeration

Enumeration ;#ImGuiHoveredFlags_
  
  #ImGuiHoveredFlags_ChildWindows = 1 << 0
  #ImGuiHoveredFlags_RootWindow = 1 << 1
  #ImGuiHoveredFlags_AllowWhenBlockedByPopup = 1 << 2
  ;#ImGuiHoveredFlags_AllowWhenBlockedByModal     = 1 << 3
  #ImGuiHoveredFlags_AllowWhenBlockedByActiveItem = 1 << 4
  #ImGuiHoveredFlags_AllowWhenOverlapped = 1 << 5
  #ImGuiHoveredFlags_RectOnly = #ImGuiHoveredFlags_AllowWhenBlockedByPopup | #ImGuiHoveredFlags_AllowWhenBlockedByActiveItem | #ImGuiHoveredFlags_AllowWhenOverlapped
  #ImGuiHoveredFlags_RootAndChildWindows = #ImGuiHoveredFlags_RootWindow | #ImGuiHoveredFlags_ChildWindows
EndEnumeration

Enumeration ;#ImGuiDragDropFlags_
  
  #ImGuiDragDropFlags_SourceNoPreviewTooltip = 1 << 0
  #ImGuiDragDropFlags_SourceNoDisableHover = 1 << 1
  #ImGuiDragDropFlags_SourceNoHoldToOpenOthers = 1 << 2
  #ImGuiDragDropFlags_SourceAllowNullID = 1 << 3
  #ImGuiDragDropFlags_SourceExtern = 1 << 4
  #ImGuiDragDropFlags_AcceptBeforeDelivery = 1 << 10
  #ImGuiDragDropFlags_AcceptNoDrawDefaultRect = 1 << 11
  #ImGuiDragDropFlags_AcceptPeekOnly = #ImGuiDragDropFlags_AcceptBeforeDelivery | #ImGuiDragDropFlags_AcceptNoDrawDefaultRect
EndEnumeration

Enumeration
  
  #ImGuiKey_Tab
  #ImGuiKey_LeftArrow
  #ImGuiKey_RightArrow
  #ImGuiKey_UpArrow
  #ImGuiKey_DownArrow
  #ImGuiKey_PageUp
  #ImGuiKey_PageDown
  #ImGuiKey_Home
  #ImGuiKey_End
  #ImGuiKey_Delete
  #ImGuiKey_Backspace
  #ImGuiKey_Enter
  #ImGuiKey_Escape
  #ImGuiKey_A
  #ImGuiKey_C
  #ImGuiKey_V
  #ImGuiKey_X
  #ImGuiKey_Y
  #ImGuiKey_Z
  #ImGuiKey_COUNT
EndEnumeration

Enumeration
  
  #ImGuiCol_Text
  #ImGuiCol_TextDisabled
  #ImGuiCol_WindowBg
  #ImGuiCol_ChildBg
  #ImGuiCol_PopupBg
  #ImGuiCol_Border
  #ImGuiCol_BorderShadow
  #ImGuiCol_FrameBg
  #ImGuiCol_FrameBgHovered
  #ImGuiCol_FrameBgActive
  #ImGuiCol_TitleBg
  #ImGuiCol_TitleBgActive
  #ImGuiCol_TitleBgCollapsed
  #ImGuiCol_MenuBarBg
  #ImGuiCol_ScrollbarBg
  #ImGuiCol_ScrollbarGrab
  #ImGuiCol_ScrollbarGrabHovered
  #ImGuiCol_ScrollbarGrabActive
  #ImGuiCol_CheckMark
  #ImGuiCol_SliderGrab
  #ImGuiCol_SliderGrabActive
  #ImGuiCol_Button
  #ImGuiCol_ButtonHovered
  #ImGuiCol_ButtonActive
  #ImGuiCol_Header
  #ImGuiCol_HeaderHovered
  #ImGuiCol_HeaderActive
  #ImGuiCol_Separator
  #ImGuiCol_SeparatorHovered
  #ImGuiCol_SeparatorActive
  #ImGuiCol_ResizeGrip
  #ImGuiCol_ResizeGripHovered
  #ImGuiCol_ResizeGripActive
  #ImGuiCol_CloseButton
  #ImGuiCol_CloseButtonHovered
  #ImGuiCol_CloseButtonActive
  #ImGuiCol_PlotLines
  #ImGuiCol_PlotLinesHovered
  #ImGuiCol_PlotHistogram
  #ImGuiCol_PlotHistogramHovered
  #ImGuiCol_TextSelectedBg
  #ImGuiCol_ModalWindowDarkening
  #ImGuiCol_DragDropTarget
  #ImGuiCol_COUNT
EndEnumeration

Enumeration
  
  #ImGuiStyleVar_Alpha
  #ImGuiStyleVar_WindowPadding
  #ImGuiStyleVar_WindowRounding
  #ImGuiStyleVar_WindowBorderSize
  #ImGuiStyleVar_WindowMinSize
  #ImGuiStyleVar_ChildRounding
  #ImGuiStyleVar_ChildBorderSize
  #ImGuiStyleVar_PopupRounding
  #ImGuiStyleVar_PopupBorderSize
  #ImGuiStyleVar_FramePadding
  #ImGuiStyleVar_FrameRounding
  #ImGuiStyleVar_FrameBorderSize
  #ImGuiStyleVar_ItemSpacing
  #ImGuiStyleVar_ItemInnerSpacing
  #ImGuiStyleVar_IndentSpacing
  #ImGuiStyleVar_GrabMinSize
  #ImGuiStyleVar_ButtonTextAlign
  #ImGuiStyleVar_Count_
EndEnumeration

Enumeration
  
  #ImGuiColorEditFlags_NoAlpha = 1 << 1
  #ImGuiColorEditFlags_NoPicker = 1 << 2
  #ImGuiColorEditFlags_NoOptions = 1 << 3
  #ImGuiColorEditFlags_NoSmallPreview = 1 << 4
  #ImGuiColorEditFlags_NoInputs = 1 << 5
  #ImGuiColorEditFlags_NoTooltip = 1 << 6
  #ImGuiColorEditFlags_NoLabel = 1 << 7
  #ImGuiColorEditFlags_NoSidePreview = 1 << 8
  #ImGuiColorEditFlags_AlphaBar = 1 << 9
  #ImGuiColorEditFlags_AlphaPreview = 1 << 10
  #ImGuiColorEditFlags_AlphaPreviewHalf = 1 << 11
  #ImGuiColorEditFlags_HDR = 1 << 12
  #ImGuiColorEditFlags_RGB = 1 << 13
  #ImGuiColorEditFlags_HSV = 1 << 14
  #ImGuiColorEditFlags_HEX = 1 << 15
  #ImGuiColorEditFlags_Uint8 = 1 << 16
  #ImGuiColorEditFlags_Float = 1 << 17
  #ImGuiColorEditFlags_PickerHueBar = 1 << 18
  #ImGuiColorEditFlags_PickerHueWheel = 1 << 19
EndEnumeration

Enumeration
  
  #ImGuiMouseCursor_None = -1
  #ImGuiMouseCursor_Arrow = 0
  #ImGuiMouseCursor_TextInput
  #ImGuiMouseCursor_Move
  #ImGuiMouseCursor_ResizeNS
  #ImGuiMouseCursor_ResizeEW
  #ImGuiMouseCursor_ResizeNESW
  #ImGuiMouseCursor_ResizeNWSE
  #ImGuiMouseCursor_Count_
EndEnumeration

Enumeration
  
  #ImGuiCond_Always = 1 << 0
  #ImGuiCond_Once = 1 << 1
  #ImGuiCond_FirstUseEver = 1 << 2
  #ImGuiCond_Appearing = 1 << 3
EndEnumeration

Enumeration ;ImDrawCornerFlags_
  
  #ImDrawCornerFlags_TopLeft = 1 << 0
  #ImDrawCornerFlags_TopRight = 1 << 1
  #ImDrawCornerFlags_BotLeft = 1 << 2
  #ImDrawCornerFlags_BotRight = 1 << 3
  #ImDrawCornerFlags_Top = #ImDrawCornerFlags_TopLeft | #ImDrawCornerFlags_TopRight
  #ImDrawCornerFlags_Bot = #ImDrawCornerFlags_BotLeft | #ImDrawCornerFlags_BotRight
  #ImDrawCornerFlags_Left = #ImDrawCornerFlags_TopLeft | #ImDrawCornerFlags_BotLeft
  #ImDrawCornerFlags_Right = #ImDrawCornerFlags_TopRight | #ImDrawCornerFlags_BotRight
  #ImDrawCornerFlags_All = $F
EndEnumeration

Enumeration ;ImDrawListFlags_
  #ImDrawListFlags_AntiAliasedLines = 1 << 0
  #ImDrawListFlags_AntiAliasedFill = 1 << 1
EndEnumeration

;- Structures

Structure ImVec2
  X.f
  Y.f
EndStructure

Structure ImVec4
  X.f
  Y.f
  z.f
  w.f
EndStructure

Structure ImGuiStyle
  Alpha.f
  WindowPadding.ImVec2
  WindowRounding.f
  WindowBorderSize.f
  WindowMinSize.ImVec2
  WindowTitleAlign.ImVec2
  ChildRounding.f
  ChildBorderSize.f
  PopupRounding.f
  PopupBorderSize.f
  FramePadding.ImVec2
  FrameRounding.f
  FrameBorderSize.f
  ItemSpacing.ImVec2
  ItemInnerSpacing.ImVec2
  TouchExtraPadding.ImVec2
  IndentSpacing.f
  ColumnsMinSpacing.f
  ScrollbarSize.f
  ScrollbarRounding.f
  GrabMinSize.f
  GrabRounding.f
  ButtonTextAlign.ImVec2
  DisplayWindowPadding.ImVec2
  DisplaySafeAreaPadding.ImVec2
  AntiAliasedLines.b
  AntiAliasedFill.b
  CurveTessellationTol.f
  Colors.ImVec4[#ImGuiCol_COUNT]
EndStructure



; TODO:  Confirm the is proper, I think it might be misaligned as FrameRate is always 0!
Structure ImGuiIO
  DisplaySize.ImVec2
  DeltaTime.f
  IniSavingRate.f
  *inifile_str
  *logfile_str
  MouseDoubleClickTime.f
  MouseDoubleClickMaxDist.f
  MouseDragThreshold.f
  KeyMap.l[#ImGuiKey_COUNT]
  KeyRepeatDelaY.f
  KeyRepeatRate.f
  *UserData
  *Fonts.ImFontAtlas
  FontGlobalScale.f
  FontAllowUserScaling.b
  *FontDefault.ImFontc
  DisplayFramebufferScale.ImVec2
  DisplayVisibleMin.ImVec2
  DisplayVisibleMax.ImVec2
  OptMacOSXBehaviors.b
  OptCursorBlink.b
  *RenderDrawListsFn
  *GetClipboardTextFn
  *SetClipboardTextFn
  *ClipboardUserData
 ; *MemAllocFn
  *MemFreeFn
  *ImeSetInputScreenPosFn
  *ImeWindowHandle
  MousePos.ImVec2
  MouseDown.b[5]
  MouseWheel.f
  MouseDrawCursor.b
  KeyCtrl.b
  KeyShift.b
  KeyAlt.b
  KeySuper.b
  KeysDown.b[512]
  InputCharacters.u[16+1]
  WantCaptureMouse.b
  WantCaptureKeyboard.b
  WantTextInput.b
  Framerate.f
  MetricsAllocs.l
  MetricsRenderVertices.l
  MetricsRenderIndices.l
  MetricsActiveWindows.l
  MouseDelta.ImVec2
  MousePosPrev.ImVec2
  MouseClicked.b[5]
  MouseClickedPos.ImVec2[5]
  MouseClickedTime.f[5]
  MouseDoubleClicked.b[5]
  MouseReleased.b[5]
  MouseDownOwned.b[5]
  MouseDownDuration.f[5]
  MouseDownDurationPrev.f[5]
  MouseDragMaxDistanceAbs.ImVec2[5]
  MouseDragMaxDistanceSqr.f[5]
  KeysDownDuration.f[512]
  KeysDownDurationPrev.f[512]
EndStructure

Structure ImGuiTextEditCallbackData
  EventFlag.l
  Flags.l
  *UserData
  ReadOnly.b
  EventChar.w
  EventKey.l
  *Buf;.b
  BufTextLen.l
  BufSize.l
  BufDirty.b
  CursorPos.l
  SelectionStart.l
  SelectionEnd.l
EndStructure

Structure ImGuiSizeConstraintCallbackData
  *UserData
  Pos.ImVec2
  CurrentSize.ImVec2
  DesiredSize.ImVec2
EndStructure

Structure ImDrawCmd
  ElemCount.l
  ClipRect.ImVec4
  *TextureId
  *UserCallback  ; (*ImDrawCallback)(CONST struct ImDrawList *parent_list, CONST struct ImDrawCmd *cmd);
  *UserCallbackData
EndStructure

Structure ImDrawData
  Valid.b
  *PtrCmdLists;.ImDrawList  ;**CmdLists.ImDrawList
  CmdListsCount.l
  TotalVtxCount.l
  TotalIdxCount.l
EndStructure

Structure ImDrawVert
  pos.ImVec2
  uv.ImVec2
  col.l;.ImU32
EndStructure

Structure ImFontConfig
  *FontData
  FontDataSize.l
  FontDataOwnedByAtlas.b
  FontNo.l
  SizePixels.f
  OversampleH.l
  OversampleV.l
  PixelSnapH.b
  GlyphExtraSpacing.ImVec2
  GlyphOffset.ImVec2
  MergeMode.b
  RasterizerFlags.l
  RasterizerMultiplY.f
  Name.b[32]
  *DstFont.ImFont
EndStructure

Structure ImGuiListClipper
  StartPosY.f
  ItemsHeight.f
  ItemsCount.l
  StepNo.l
  DisplayStart.l
  DisplayEnd.l
EndStructure

Structure ImGuiPayload
  DataSize.l
  SourceId.l;   ImU32 ImGuiID;   .ImGuiID
  SourceParentId.l ;.ImGuiID
  DataFrameCount.l
  DataType.b[8+1]
  Preview.b
  Delivery.b
EndStructure

;---- Open DLL
Global LibPBCImGui = OpenLibrary(#PB_Any, #IMGUIDLL)
Global LibImGui_API_Coverage = 0 ; count found functions

Macro _dq_  ; double quotes
  "
EndMacro

; functions with arguments
Macro Get_UI_Lib_Func(name, parameters)
  PrototypeC name#_Prototype parameters
  Global name.name#_Prototype
  If IsLibrary(LibPBCImGui)
    name = GetFunction(LibPBCImGui, _dq_#name#_dq_)
    If Not name 
      Debug "Failed to find '" + _dq_#name#_dq_ +"'"
    Else
      ;Debug _dq_ name parameters _dq_
      LibImGui_API_Coverage + 1
    EndIf
  Else
    Debug "Library not open."    
    Print("Error, Unable To open " +#IMGUIDLL+" -  Please reinstall this software.")
    CallDebugger
    End 
  EndIf
EndMacro

; function with no arguments
Macro Get_UI_Lib_FuncVoid(name)
  Get_UI_Lib_Func(name,())
EndMacro

;-----------------------
;----- Helper Functions

; load api
If IsLibrary(LibPBCImGui)
  
; my helpers....
Get_UI_Lib_Func(_LoadImageFromFile,(filename.p-unicode)) ; pass a filename to a jpg/png file, returns TextureID
Get_UI_Lib_Func(_LoadImageFromMemory,(*data, sizel.l)) ; ptr to jpg/png data and size, returns TextureID
Get_UI_Lib_Func(_ImageWidth, (textureID.l)) ; return pixel width of texture
Get_UI_Lib_Func(_ImageHeight, (textureID.l)) ; return pixel height of texture
Get_UI_Lib_Func(_ReleaseImage,(textureID.l))

; Supply a TTF file and pixel size.  crashes on some fonts, not sure why...
Get_UI_Lib_Func(_LoadFontFromFile, (filename.s, pixel_size.f))
; Supply a TTF file from memory and it's size, and a pixel size.  crashes on exit app, not sure why...
Get_UI_Lib_Func(_LoadFontFromMemory, (*data, data_size.l, pixel_size.f))
 
Get_UI_Lib_Func(_SetBackgroundColour, (r.f,g.f,b.f,a.f))

; This is the main loop.
; note we have to supply unicode strings here, but only for the classname and window title
; we supply callbacks to our main loop, our init function (after DX11 is ready but before loop), and shutdown function (before DX11 shuts down)
Get_UI_Lib_Func(_Run_GUI, (classname.p-unicode, title.p-unicode, style.l, x.l, y.l, w.l, h.l, vsync.l, *callback_loop, *callback_init = #Null, *callback_shutdown = #Null))



;----- CIMGUI Functions...

;- Main 
Get_UI_Lib_FuncVoid(igGetIO)
Get_UI_Lib_FuncVoid(igGetStyle)
Get_UI_Lib_FuncVoid(igGetDrawData)
Get_UI_Lib_FuncVoid(igNewFrame)
Get_UI_Lib_FuncVoid(igRender)
Get_UI_Lib_FuncVoid(igEndFrame)
Get_UI_Lib_FuncVoid(igShutdown)

;- Demo/Debug/Info
Get_UI_Lib_Func(igShowDemoWindow, (*opened))
Get_UI_Lib_Func(igShowMetricsWindow, (*opened))
Get_UI_Lib_Func(igShowStyleEditor, (*ref.ImGuiStyle))
Get_UI_Lib_Func(igShowStyleSelector, (*label)) ; string
Get_UI_Lib_Func(igShowFontSelector, (*label))  ; string
Get_UI_Lib_FuncVoid(igShowUserGuide)           ;


;- Window
Get_UI_Lib_Func(igBegin, (name.s, *p_open, flags))                                             
Get_UI_Lib_FuncVoid(igEnd)                        

Get_UI_Lib_Func(igBeginChild, (*str_id, w.f,h.f, border.b, extra_flags));
Get_UI_Lib_Func(igBeginChildEx, (id.l, w.f,h.f, border.b, extra_flags)) ;

Get_UI_Lib_FuncVoid(igEndChild);
Get_UI_Lib_Func(igGetContentRegionMax, (*out.ImVec2));
Get_UI_Lib_Func(igGetContentRegionAvail, (*out.ImVec2));
Get_UI_Lib_FuncVoid(igGetContentRegionAvailWidth)      ;
Get_UI_Lib_Func(igGetWindowContentRegionMin, (*out.ImVec2));
Get_UI_Lib_Func(igGetWindowContentRegionMax, (*out.ImVec2));
Get_UI_Lib_FuncVoid(igGetWindowContentRegionWidth)         ;
Get_UI_Lib_FuncVoid(igGetWindowDrawList)                   ;
Get_UI_Lib_Func(igGetWindowPos, (*out.ImVec2))             ;
Get_UI_Lib_Func(igGetWindowSize, (*out.ImVec2))            ;
Get_UI_Lib_FuncVoid(igGetWindowWidth)                      ;
Get_UI_Lib_FuncVoid(igGetWindowHeight)                     ;
Get_UI_Lib_FuncVoid(igIsWindowCollapsed)                   ;
Get_UI_Lib_FuncVoid(igIsWindowAppearing)                   ;
Get_UI_Lib_Func(igSetWindowFontScale, (scale.f))           ;

Get_UI_Lib_Func(igSetNextWindowPos, (X.f,Y.f, cond.l=0, pivot.p-variant=0))
Get_UI_Lib_Func(igSetNextWindowSize, (w.f,h.f, cond.l=0))
Get_UI_Lib_Func(igSetNextWindowSizeConstraints, (minW.f,minH.f, maxW.f,maxH.f, *custom_callback, *custom_callback_data)) ; (CONST struct ImVec2 size_min, CONST struct ImVec2 size_max, ImGuiSizeConstraintCallback custom_callback, void *custom_callback_data);
Get_UI_Lib_Func(igSetNextWindowContentSize, (eo.p-variant) )                                                                       ; ImVec2
Get_UI_Lib_Func(igSetNextWindowCollapsed, (collapsed.b, cond.l))
Get_UI_Lib_FuncVoid(igSetNextWindowFocus)
Get_UI_Lib_Func(igSetWindowPos, (X.f,Y.f, cond.l)) ; (CONST struct ImVec2 pos, ImGuiCond cond);
Get_UI_Lib_Func(igSetWindowSize, (w.f,h.f, cond.l)); (CONST struct ImVec2 size, ImGuiCond cond);
Get_UI_Lib_Func(igSetWindowCollapsed, (collapsed.b, cond.l))
Get_UI_Lib_FuncVoid(igSetWindowFocus);
Get_UI_Lib_Func(igSetWindowPosByName, (name.s, X.f,Y.f, cond.l))
Get_UI_Lib_Func(igSetWindowSize2, (name.s, w.f,h.f, cond.l))
Get_UI_Lib_Func(igSetWindowCollapsed2, (name.s, collapsed.b, cond.l))
Get_UI_Lib_Func(igSetWindowFocus2, (name.s));

Get_UI_Lib_FuncVoid(igGetScrollX) ; float
Get_UI_Lib_FuncVoid(igGetScrollY) ; float
Get_UI_Lib_FuncVoid(igGetScrollMaxX) ; float
Get_UI_Lib_FuncVoid(igGetScrollMaxY) ; float
Get_UI_Lib_Func(igSetScrollX, (scroll_X.f))
Get_UI_Lib_Func(igSetScrollY, (scroll_Y.f))
Get_UI_Lib_Func(igSetScrollHere, (center_y_ratio.f))
Get_UI_Lib_Func(igSetScrollFromPosY, (pos_Y.f, center_y_ratio.f));

;TODO:  ImGuiStorage structure
;Get_UI_Lib_Func(igSetStateStorage, (*tree.ImGuiStorage))
;Get_UI_Lib_FuncVoid(igGetStateStorage) ;.ImGuiStorage

;- Parameters stacks (Shared)
Get_UI_Lib_Func(igPushFont, (*font)); void
Get_UI_Lib_Func(igPopFont,())       ; void
Get_UI_Lib_Func(igPushStyleColorU32, (idx.l, col.l)); void
Get_UI_Lib_Func(igPushStyleColor, (idx.l, R.f,G.f,B.f,A.f)); void  ; col is ImVec4
Get_UI_Lib_Func(igPopStyleColor,(count.l))               ; void
Get_UI_Lib_Func(igPushStyleVar,(idx.l, val.f))           ; void
Get_UI_Lib_Func(igPushStyleVarVec,(idx.l, X.f,Y.f)); void ; val is ImVec2
Get_UI_Lib_Func(igPopStyleVar,(count.l))                 ; void
Get_UI_Lib_Func(igGetStyleColorVec4,(*pOut.ImVec4, idx.l)); void
Get_UI_Lib_Func(igGetFont,())                             ; struct *ImFont
Get_UI_Lib_Func(igGetFontSize,())                         ; float
Get_UI_Lib_Func(igGetFontTexUvWhitePixel,(*pOut.ImVec2))  ; void
Get_UI_Lib_Func(igGetColorU32,(idx.l, alpha_mul.f))       ; ImU32
Get_UI_Lib_Func(igGetColorU32Vec,(*col.ImVec4))           ; ImU32
Get_UI_Lib_Func(igGetColorU32U32,(col.l))                 ; ImU32

;- Parameters stacks (current window)
Get_UI_Lib_Func(igPushItemWidth,(item_width.f)); void
Get_UI_Lib_Func(igPopItemWidth,())             ; void
Get_UI_Lib_Func(igCalcItemWidth,())            ; float
Get_UI_Lib_Func(igPushTextWrapPos,(wrap_pos_X.f)); void
Get_UI_Lib_Func(igPopTextWrapPos,())             ; void
Get_UI_Lib_Func(igPushAllowKeyboardFocus,(v.b))  ; void
Get_UI_Lib_Func(igPopAllowKeyboardFocus,())      ; void
Get_UI_Lib_Func(igPushButtonRepeat,(Repeat_.b))  ; void
Get_UI_Lib_Func(igPopButtonRepeat,())            ; void

;- Cursor / Layout
Get_UI_Lib_Func(igSeparator,()); void
Get_UI_Lib_Func(igSameLine,(pos_X.f, spacing_w.f)); void
Get_UI_Lib_Func(igNewLine,())                     ; void
Get_UI_Lib_Func(igSpacing,())                     ; void
Get_UI_Lib_Func(igDummy,(*size.ImVec2))           ; void
Get_UI_Lib_Func(igIndent,(indent_w.f))            ; void
Get_UI_Lib_Func(igUnindent,(indent_w.f))          ; void
Get_UI_Lib_Func(igBeginGroup,())                  ; void
Get_UI_Lib_Func(igEndGroup,())                    ; void
Get_UI_Lib_Func(igGetCursorPos,(*pOut.ImVec2))    ; void
Get_UI_Lib_Func(igGetCursorPosX,())               ; float
Get_UI_Lib_Func(igGetCursorPosY,())               ; float
Get_UI_Lib_Func(igSetCursorPos,(local_pos.p-variant)); void ; ImVec2 
Get_UI_Lib_Func(igSetCursorPosX,(X.f))               ; void
Get_UI_Lib_Func(igSetCursorPosY,(Y.f))               ; void
Get_UI_Lib_Func(igGetCursorStartPos,(*pOut.ImVec2))  ; void
Get_UI_Lib_Func(igGetCursorScreenPos,(*pOut.ImVec2)) ; void
Get_UI_Lib_Func(igSetCursorScreenPos,(pos.p-variant)); void ; ImVec2
Get_UI_Lib_Func(igAlignTextToFramePadding,())        ; void
Get_UI_Lib_Func(igGetTextLineHeight,())              ; float
Get_UI_Lib_Func(igGetTextLineHeightWithSpacing,())   ; float
Get_UI_Lib_Func(igGetFrameHeight,())                 ; float
Get_UI_Lib_Func(igGetFrameHeightWithSpacing,())      ; float

;- Columns
Get_UI_Lib_Func(igColumns,(count.l, id.s, border.b)); void
Get_UI_Lib_Func(igNextColumn,())                    ; void
Get_UI_Lib_Func(igGetColumnIndex,())                ; int
Get_UI_Lib_Func(igGetColumnWidth,(column_index.l))  ; // get column width (in pixels). pass -1 to use current column float
Get_UI_Lib_Func(igSetColumnWidth,(column_index.l, width.f)); void
Get_UI_Lib_Func(igGetColumnOffset,(column_index.l))        ; float
Get_UI_Lib_Func(igSetColumnOffset,(column_index.l, offset_X.f)); void
Get_UI_Lib_Func(igGetColumnsCount,())                          ; int


;- ID scopes
;// If you are creating widgets in a loop you most likely want To push a unique identifier so ImGui can differentiate them
;// You can also use "##extra" within your widget name To distinguish them from each others (see 'Programmer Guide')
Get_UI_Lib_Func(igPushIDStr,(str_id.s)); void
Get_UI_Lib_Func(igPushIDStrRange,(str_begin.s, str_end.s)); void
Get_UI_Lib_Func(igPushIDPtr,(*ptr_id))                    ; void
Get_UI_Lib_Func(igPushIDInt,(int_id.l))                   ; void
Get_UI_Lib_Func(igPopID,())                               ; void
Get_UI_Lib_Func(igGetIDStr,(str_id.s))                    ; ImGuiID
Get_UI_Lib_Func(igGetIDStrRange,(str_begins, str_end.s))  ; ImGuiID
Get_UI_Lib_Func(igGetIDPtr,(*ptr_id))                     ; ImGuiID

;- Widgets: Text
Get_UI_Lib_Func(igTextUnformatted,(text.s, text_end.s)); void
Get_UI_Lib_Func(igText,(fmt.s))                        ; void
Get_UI_Lib_Func(igTextV,(fmt.s, args.p-variant))       ; void
Get_UI_Lib_Func(igTextColored,(R.f,G.f,B.f,A.f, fmt.s))  ; void ; RGBA
Get_UI_Lib_Func(igTextColoredV,(R.f,G.f,B.f,A.f, fmt.s, args.p-variant=0)); void ; RGBA 
Get_UI_Lib_Func(igTextDisabled,(fmt.s))                                 ; void
Get_UI_Lib_Func(igTextDisabledV,(fmt.s, args.p-variant))                ; void
Get_UI_Lib_Func(igTextWrapped,(fmt.s))                                  ; void
Get_UI_Lib_Func(igTextWrappedV,(fmt.s, args.p-variant=0))               ; void
Get_UI_Lib_Func(igLabelText,(label.s, fmt.s))                           ; void
Get_UI_Lib_Func(igLabelTextV,(label.s, fmt.s, args.p-variant=0))        ; void
Get_UI_Lib_Func(igBulletText,(fmt.s))                                   ; void
Get_UI_Lib_Func(igBulletTextV,(fmt.s, args.p-variant=0))                ; void
Get_UI_Lib_Func(igBullet,())                                            ; void


;- Widgets: Main
Get_UI_Lib_Func(igButton,(label.s, W.f=0.0, H.f=0.0)); bool ; ; ImVec2
Get_UI_Lib_Func(igSmallButton,(label.s))           ; bool
Get_UI_Lib_Func(igInvisibleButton,(*str_id, W.f=0.0, H.f=0.0)); bool ; ImVec2

;TODO: 
;Get_UI_Lib_Func(igImage,(user_texture_id.i, size.p-variant, uv0.p-variant, uv1.p-variant, tint_col.p-variant, border_col.p-variant)); void ; ImVec2 - col ImVec4
;-  Testing

;CIMGUI_API void igImage(ImTextureID user_texture_id, CONST struct ImVec2 size, CONST struct ImVec2 uv0, CONST struct ImVec2 uv1, CONST struct ImVec4 tint_col, CONST struct ImVec4 border_col);

;TODO: igImage - doesn't work, doesn't seem like they get drawn at all
Get_UI_Lib_Func(igImage,(textureid.l, W.f, H.f, uv0X.f=0.0, uv0Y.f=0.0, uv1X.f=1.0, uv1Y.f=1.0,   tintR.f=255.0,tintG.f=255.0,tintB.f=255.0,tintA.f=255.0, border_colR.f=0.0,border_colG.f=0.0,border_colB.f=0.0,border_colA.f=0.0)); void ; ImVec2 - col ImVec4
;Get_UI_Lib_Func(igImage,(user_texture_id.l)); void ; ImVec2 - col ImVec4
Get_UI_Lib_Func(igImageButton,(user_texture_id.l, W.f, H.f, topleftX.f=0.0, topleftY.f=0.0, bottom_rightX.f=1.0, bottom_rightY.f=1.0, frame_padding.l=0, bordercolorR.f=0.0,bordercolorG.f=0.0,bordercolorB.f=0.0,bordercolorA.f=0.0, tintR.f=0.0,tintG.f=0.0,tintB.f=0.0,tintA.f=0.0)); bool
Get_UI_Lib_Func(igCheckbox,(label.s, *v))                                                                                                              ; bool ; v is bool
Get_UI_Lib_Func(igCheckboxFlags,(label.s, *flags, flags_value.l))                                                                                      ; bool
Get_UI_Lib_Func(igRadioButtonBool,(label.s, active.b))                                                                                                 ; bool
Get_UI_Lib_Func(igRadioButton,(label.s, *v, v_button.l))                                                                                               ; bool
Get_UI_Lib_Func(igPlotLines,(label.s, *values, values_count.l, values_offset.l=0, overlay_text.s="", scale_min.f=0.0, scale_max.f=100.0, W.f=0.0,H.f=0.0, stride.l=4)); void ; graph_size is ImVec2
;Get_UI_Lib_Func(igPlotLines2(label.s, float (*values_getter)(void *Data, int idx), void *Data, int values_count, int values_offset, CONST char *overlay_text, float scale_min, float scale_max, struct ImVec2 graph_size); void
Get_UI_Lib_Func(igPlotHistogram,(label.s, *values, values_count.l, values_offset.l=0, overlay_text.s="", scale_min.f=0.0, scale_max.f=100.0, W.f=0.0,H.f=0.0, stride.l=4)); void
;Get_UI_Lib_Func(igPlotHistogram2,(label.s, float (*values_getter)(void *Data, int idx), void *Data, int values_count, int values_offset, CONST char *overlay_text, float scale_min, float scale_max, struct ImVec2 graph_size); void
Get_UI_Lib_Func(igProgressBar,(fraction.f, *size_arg.ImVec2, overlay.s))                                                                                      ; void

Get_UI_Lib_Func(igBeginCombo,(label.s, preview_value.s, flags.l)); bool
Get_UI_Lib_Func(igEndCombo,())                                   ; void
Get_UI_Lib_Func(igCombo,(label.s, *current_item, *items, items_count.l, popup_max_height_in_items.l)); bool
Get_UI_Lib_Func(igCombo2,(label.s, *current_item, *items_separated_by_zeros, popup_max_height_in_items.l)); bool
;Get_UI_Lib_Func(igCombo3,(label.s, *current_item, Bool (*items_getter)(void *Data, int idx, CONST char **out_text), void *Data, int items_count, int popup_max_height_in_items); bool

;- Widgets: Drags (tip: ctrl+click on a drag box To input With keyboard. manually input values aren't clamped, can go off-bounds)
;// For all the Float2/Float3/Float4/Int2/Int3/Int4 versions of every functions, note that a 'float v[X]' function argument is the same As 'float* v', the Array syntax is just a way To document the number of elements that are expected To be accessible. You can pass address of your first element out of a contiguous set, e.g. &myvector.x
Get_UI_Lib_Func(igDragFloat,(label.s, *v, v_speed.f, v_min.f, v_maX.f, display_format.s, power.f)); // If v_max >= v_max we have no bound bool
Get_UI_Lib_Func(igDragFloat2,(label.s, *vF2, v_speed.f=0, v_min.f=0.0, v_max.f=255.0, display_format.s="", power.f=1)); bool
Get_UI_Lib_Func(igDragFloat3,(label.s, *vF3, v_speed.f=0, v_min.f=0.0, v_max.f=255.0, display_format.s="", power.f=1)); bool
Get_UI_Lib_Func(igDragFloat4,(label.s, *vF4, v_speed.f=0, v_min.f=0.0, v_max.f=255.0, display_format.s="", power.f=1)); bool
Get_UI_Lib_Func(igDragFloatRange2,(label.s, *v_current_min_f, *v_current_max_f, v_speed.f, v_min.f, v_max.f, display_format.s, display_format_max.s, power.f)); bool
Get_UI_Lib_Func(igDragInt,(label.s, *vL1, v_speed.f=0, v_min.l=0.0, v_max.l=255, display_format.s="%.0f")); // If v_max >= v_max we have no bound bool
Get_UI_Lib_Func(igDragInt2,(label.s, *vL2, v_speed.f=0, v_min.l=0, v_max.l=255, display_format.s="%.0f")); // If v_max >= v_max we have no bound bool
Get_UI_Lib_Func(igDragInt3,(label.s, *vL3, v_speed.f=0, v_min.l=0, v_max.l=255, display_format.s="%.0f")); // If v_max >= v_max we have no bound bool
Get_UI_Lib_Func(igDragInt4,(label.s, *vL4, v_speed.f=0, v_min.l=0, v_max.l=255, display_format.s="%.0f")); // If v_max >= v_max we have no bound bool
Get_UI_Lib_Func(igDragIntRange2,(label.s, *v_current_min_int, *v_current_max_int, v_speed.f, v_min.l, v_max.l, display_format.s, display_format_max.s)); bool

;- Widgets: Input With Keyboard
Get_UI_Lib_Func(igInputText, (label.s, *buf_char, buf_size.l, flags.i=0, *callback=#Null, *user_data=#Null)); bool ; ImGuiInputTextFlags ; ImGuiTextEditCallback 
Get_UI_Lib_Func(igInputTextMultiline, (label.s, *buf_char, buf_size.l, W.f=0.0, H.f=0.0, flags.l=#Null, *callback=#Null, *user_data=#Null)); bool
Get_UI_Lib_Func(igInputFloat, (label.s, *vF, step_size.f, step_fast.f, decimal_precision.l, extra_flags.l))                                ; bool
Get_UI_Lib_Func(igInputFloat2, (label.s, *vF2, step_size.f, step_fast.f, decimal_precision.l, extra_flags.l))
Get_UI_Lib_Func(igInputFloat3, (label.s, *vF3, step_size.f, step_fast.f, decimal_precision.l, extra_flags.l))
Get_UI_Lib_Func(igInputFloat4, (label.s, *vF4, step_size.f, step_fast.f, decimal_precision.l, extra_flags.l))
Get_UI_Lib_Func(igInputInt, (label.s, *vL, step_size.l, step_fast.l, extra_flags.l)); bool
Get_UI_Lib_Func(igInputInt2, (label.s, *vL, step_size.l, step_fast.l, extra_flags.l));
Get_UI_Lib_Func(igInputInt3, (label.s, *vL, step_size.l, step_fast.l, extra_flags.l))
Get_UI_Lib_Func(igInputInt4, (label.s, *vL, step_size.l, step_fast.l, extra_flags.l))

;- Widgets: Sliders (tip: ctrl+click on a slider To input With keyboard. manually input values aren't clamped, can go off-bounds)
Get_UI_Lib_Func(igSliderFloat, (label.s, *vF, v_min.f, v_max.f, display_format.s="%.2f", power.f=1.0)); bool
Get_UI_Lib_Func(igSliderFloat2, (label.s, *vF2, v_min.f, v_max.f, display_format.s="%.2f", power.f=1.0)); bool
Get_UI_Lib_Func(igSliderFloat3, (label.s, *vF3, v_min.f, v_max.f, display_format.s="%.2f", power.f=1.0)); bool ;  *VFx is pointer to array/struct of float of size X
Get_UI_Lib_Func(igSliderFloat4, (label.s, *vF4, v_min.f, v_max.f, display_format.s="%.2f", power.f=1.0)); bool
Get_UI_Lib_Func(igSliderAngle, (label.s, *v_rad, v_degrees_min.f, v_degrees_max.f)); bool
Get_UI_Lib_Func(igSliderInt, (label.s, *vL, v_min.l, v_max.l, display_format.s="%.0f")); bool
Get_UI_Lib_Func(igSliderInt2, (label.s, *vL2, v_min.l, v_max.l, display_format.s="%.0f")); bool
Get_UI_Lib_Func(igSliderInt3, (label.s, *vL3, v_min.l, v_max.l, display_format.s="%.0f")); bool
Get_UI_Lib_Func(igSliderInt4, (label.s, *vL4, v_min.l, v_max.l, display_format.s="%.0f")); bool
Get_UI_Lib_Func(igVSliderFloat, (label.s, W.f, H.f, *vF, v_min.f, v_max.f, display_format.s="", power.f=1.0)); bool
Get_UI_Lib_Func(igVSliderInt, (label.s, W.f, H.f, *vL, v_min.l, v_max.l, display_format.s="")); bool
; 
;- Widgets: Color Editor/Picker (tip: the ColorEdit* functions have a little colored preview square that can be left-clicked To open a picker, And right-clicked To open an option menu.)
; // Note that a 'float v[X]' function argument is the same As 'float* v', the Array syntax is just a way To document the number of elements that are expected To be accessible. You can the pass the address of a first float element out of a contiguous Structure, e.g. &myvector.x
Get_UI_Lib_Func(igColorEdit3, (label.s, *col_float3, flags.l=0)); bool ; ImGuiColorEditFlags 
Get_UI_Lib_Func(igColorEdit4, (label.s, *col_float4, flags.l=0)); bool ; ImGuiColorEditFlags 
Get_UI_Lib_Func(igColorPicker3, (label.s, *col_float3, flags.l=0)); bool ; ImGuiColorEditFlags 
Get_UI_Lib_Func(igColorPicker4, (label.s, *col_float4, flags.l=0, *ref_col_float=#Null)); bool ; ImGuiColorEditFlags 
Get_UI_Lib_Func(igColorButton, (desc_id.s, R.f,G.f,B.f,A.f, flags.l=0, W.f=0.0, H.f=0.0)); bool
Get_UI_Lib_Func(igSetColorEditOptions, (flags.l)); void ; ImGuiColorEditFlags 
;
; TODO: 
;{
;- Widgets: Trees
Get_UI_Lib_Func(igTreeNode, (label.s)); bool
Get_UI_Lib_Func(igTreeNodeStr, (str_id.s, fmt.s, *args=#Null)); bool ; *args is pointer to array of pointers to each arg
Get_UI_Lib_Func(igTreeNodePtr, (*ptr_id, fmt.s, *args=#Null)); bool
; Get_UI_Lib_Func(igTreeNodeStrV(CONST char *str_id, CONST char *fmt, va_list args); bool
; Get_UI_Lib_Func(igTreeNodePtrV(CONST void *ptr_id, CONST char *fmt, va_list args); bool
Get_UI_Lib_Func(igTreeNodeEx, (label.s, flags.l)); bool ; ImGuiTreeNodeFlags 
Get_UI_Lib_Func(igTreeNodeExStr, (str_id.s, flags.l, fmt.s, *args=#Null)); bool ; ImGuiTreeNodeFlags 
Get_UI_Lib_Func(igTreeNodeExPtr, (*ptr_id, flags.l, fmt.s, *args=#Null)); bool ; ImGuiTreeNodeFlags 
; Get_UI_Lib_Func(igTreeNodeExV(CONST char *str_id, ImGuiTreeNodeFlags flags, CONST char *fmt, va_list args); bool
; Get_UI_Lib_Func(igTreeNodeExVPtr(CONST void *ptr_id, ImGuiTreeNodeFlags flags, CONST char *fmt, va_list args); bool
Get_UI_Lib_Func(igTreePushStr, (str_id.s)); void
Get_UI_Lib_Func(igTreePushPtr, (*ptr_id)); void
Get_UI_Lib_Func(igTreePop, ()); void
Get_UI_Lib_Func(igTreeAdvanceToLabelPos, ()); void
Get_UI_Lib_Func(igGetTreeNodeToLabelSpacing, ()); float
Get_UI_Lib_Func(igSetNextTreeNodeOpen, (opened.b, cond.l)); void ; ImGuiCond 
Get_UI_Lib_Func(igCollapsingHeader, (label.s, flags.l)); bool ; ImGuiTreeNodeFlags 
Get_UI_Lib_Func(igCollapsingHeaderEx, (label.s, *p_open_bool, flags.l)); bool ; ImGuiTreeNodeFlags 
; 
; // Widgets: Selectable / Lists
; Get_UI_Lib_Func(igSelectable(label.s, bool selected, ImGuiSelectableFlags flags, CONST struct ImVec2 size); bool
; Get_UI_Lib_Func(igSelectableEx(label.s, bool *p_selected, ImGuiSelectableFlags flags, CONST struct ImVec2 size); bool
; Get_UI_Lib_Func(igListBox(label.s, int *current_item, CONST char *CONST *items, int items_count, int height_in_items); bool
; Get_UI_Lib_Func(igListBox2(label.s, int *current_item, Bool (*items_getter)(void *Data, int idx, CONST char **out_text), void *Data, int items_count, int height_in_items); bool
; Get_UI_Lib_Func(igListBoxHeader(label.s, CONST struct ImVec2 size); bool
; Get_UI_Lib_Func(igListBoxHeader2(label.s, int items_count, int height_in_items); bool
; Get_UI_Lib_Func(igListBoxFooter(); void
; 
; // Widgets: Value() Helpers. Output single value in "name: value" format (tip: freely Declare your own within the ImGui namespace!)
Get_UI_Lib_Func(igValueBool, (prefix.s, boolean.b)); void
Get_UI_Lib_Func(igValueInt, (prefix.s, v.l)); void
Get_UI_Lib_Func(igValueUInt, (prefix.s, v.l)); void
Get_UI_Lib_Func(igValueFloat, (prefix.s, v.f, float_format.s="")); void
; 
;- Tooltip
Get_UI_Lib_Func(igSetTooltip, (fmt.s, *args=#Null)); void
; Get_UI_Lib_Func(igSetTooltipV(CONST char *fmt, va_list args); void
Get_UI_Lib_Func(igBeginTooltip,()); void
Get_UI_Lib_Func(igEndTooltip,()); void
; 
;- Widgets: Menus
Get_UI_Lib_Func(igBeginMainMenuBar, ()); bool
Get_UI_Lib_Func(igEndMainMenuBar, ()); void
Get_UI_Lib_Func(igBeginMenuBar, ()); bool
Get_UI_Lib_Func(igEndMenuBar, ()); void
Get_UI_Lib_Func(igBeginMenu, (label.s, enabled.b)); bool
Get_UI_Lib_Func(igEndMenu, ()); void
Get_UI_Lib_Func(igMenuItem, (label.s, shortcut.s, selected.b, enabled.b)); bool
Get_UI_Lib_Func(igMenuItemPtr, (label.s, shortcut.s, *p_selected_bool, enabled.b)); bool
; 
;- Popup
Get_UI_Lib_Func(igOpenPopup, (str_id.s)); void
Get_UI_Lib_Func(igOpenPopupOnItemClick, (str_id.s, mouse_button.l)); bool
Get_UI_Lib_Func(igBeginPopup, (str_id.s)); bool
Get_UI_Lib_Func(igBeginPopupModal, (name.s, *p_open_bool, extra_flags.l)); bool ; ImGuiWindowFlags 
Get_UI_Lib_Func(igBeginPopupContextItem, (str_id.s, mouse_button.l)); bool
Get_UI_Lib_Func(igBeginPopupContextWindow, (str_id.s, mouse_button.l, also_over_items.b)); bool
Get_UI_Lib_Func(igBeginPopupContextVoid, (str_id.s, mouse_button.l)); bool
Get_UI_Lib_Func(igEndPopup, ()); void
Get_UI_Lib_Func(igIsPopupOpen, (str_id.s)); bool
Get_UI_Lib_Func(igCloseCurrentPopup, ()); void
; 
;- Logging: all text output from Interface is redirected To tty/file/clipboard. Tree nodes are automatically opened.
Get_UI_Lib_Func(igLogToTTY, (max_depth.l)); void
Get_UI_Lib_Func(igLogToFile, (max_depth.l, filename.s)); void
Get_UI_Lib_Func(igLogToClipboard, (max_depth.l)); void
Get_UI_Lib_Func(igLogFinish, ()); void
Get_UI_Lib_Func(igLogButtons, ()); void
Get_UI_Lib_Func(igLogText, (fmt.s, *v1=#Null, *v2=#Null)); void
; 
; Get_UI_Lib_Func(igBeginDragDropSource(ImGuiDragDropFlags flags, int mouse_button); bool
; Get_UI_Lib_Func(igSetDragDropPayload(CONST char *type, CONST void *Data, size_t size, ImGuiCond cond); bool
; Get_UI_Lib_Func(igEndDragDropSource(); void
; Get_UI_Lib_Func(igBeginDragDropTarget(); bool
; Get_UI_Lib_Func(struct ImGuiPayload *igAcceptDragDropPayload(CONST char *type, ImGuiDragDropFlags flags); CONST
; Get_UI_Lib_Func(igEndDragDropTarget(); void
; 
; // Clipping
; Get_UI_Lib_Func(igPushClipRect(CONST struct ImVec2 clip_rect_min, CONST struct ImVec2 clip_rect_max, bool intersect_with_current_clip_rect); void
; Get_UI_Lib_Func(igPopClipRect(); void
; 
; // Styles
; Get_UI_Lib_Func(igStyleColorsClassic(struct ImGuiStyle *dst); void
; Get_UI_Lib_Func(igStyleColorsDark(struct ImGuiStyle *dst); void
; Get_UI_Lib_Func(igStyleColorsLight(struct ImGuiStyle *dst); void
; 
; Get_UI_Lib_Func(igSetItemDefaultFocus(); void
; Get_UI_Lib_Func(igSetKeyboardFocusHere(int offset); void
; 
; // Utilities
; Get_UI_Lib_Func(igIsItemHovered(ImGuiHoveredFlags flags); bool
; Get_UI_Lib_Func(igIsItemActive(); bool
; Get_UI_Lib_Func(igIsItemClicked(int mouse_button); bool
; Get_UI_Lib_Func(igIsItemVisible(); bool
; Get_UI_Lib_Func(igIsAnyItemHovered(); bool
; Get_UI_Lib_Func(igIsAnyItemActive(); bool
; Get_UI_Lib_Func(igGetItemRectMin(struct ImVec2 *pOut); void
; Get_UI_Lib_Func(igGetItemRectMax(struct ImVec2 *pOut); void
; Get_UI_Lib_Func(igGetItemRectSize(struct ImVec2 *pOut); void
; Get_UI_Lib_Func(igSetItemAllowOverlap(); void
; Get_UI_Lib_Func(igIsWindowFocused(ImGuiFocusedFlags flags); bool
; Get_UI_Lib_Func(igIsWindowHovered(ImGuiHoveredFlags falgs); bool
; Get_UI_Lib_Func(igIsAnyWindowFocused(); bool
; Get_UI_Lib_Func(igIsAnyWindowHovered(); bool
; Get_UI_Lib_Func(igIsRectVisible(CONST struct ImVec2 item_size); bool
; Get_UI_Lib_Func(igIsRectVisible2(CONST struct ImVec2 *rect_min, CONST struct ImVec2 *rect_max); bool
Get_UI_Lib_Func(igGetTime,()); float
Get_UI_Lib_Func(igGetFrameCount,()); int
; 
Get_UI_Lib_Func(igGetOverlayDrawList, ()); struct * ImDrawList 
Get_UI_Lib_Func(igGetDrawListSharedData, ()); struct * ImDrawListSharedData
; 
; Get_UI_Lib_Func(char *igGetStyleColorName(ImGuiCol idx); CONST
; Get_UI_Lib_Func(igCalcItemRectClosestPoint(struct ImVec2 *pOut, CONST struct ImVec2 pos, bool on_edge, float outward); void
; Get_UI_Lib_Func(igCalcTextSize(struct ImVec2 *pOut, CONST char *text, CONST char *text_end, bool hide_text_after_double_hash, float wrap_width); void
; Get_UI_Lib_Func(igCalcListClipping(int items_count, float items_height, int *out_items_display_start, int *out_items_display_end); void
; 
; Get_UI_Lib_Func(igBeginChildFrame(ImGuiID id, CONST struct ImVec2 size, ImGuiWindowFlags extra_flags); bool
; Get_UI_Lib_Func(igEndChildFrame(); void
; 
; Get_UI_Lib_Func(igColorConvertU32ToFloat4(struct ImVec4 *pOut, ImU32 in); void
; Get_UI_Lib_Func(igColorConvertFloat4ToU32(CONST struct ImVec4 in); ImU32
; Get_UI_Lib_Func(igColorConvertRGBtoHSV(float r, float g, float b, float *out_h, float *out_s, float *out_v); void
; Get_UI_Lib_Func(igColorConvertHSVtoRGB(float h, float s, float v, float *out_r, float *out_g, float *out_b); void
; 
;- Inputs
; Get_UI_Lib_Func(igGetKeyIndex(ImGuiKey imgui_key); int
; Get_UI_Lib_Func(igIsKeyDown(int user_key_index); bool
; Get_UI_Lib_Func(igIsKeyPressed(int user_key_index, bool Repeat); bool
; Get_UI_Lib_Func(igIsKeyReleased(int user_key_index); bool
; Get_UI_Lib_Func(igGetKeyPressedAmount(int key_index, float repeat_delay, float rate); int
; Get_UI_Lib_Func(igIsMouseDown(int button); bool
; Get_UI_Lib_Func(igIsMouseClicked(int button, bool Repeat); bool
; Get_UI_Lib_Func(igIsMouseDoubleClicked(int button); bool
; Get_UI_Lib_Func(igIsMouseReleased(int button); bool
; Get_UI_Lib_Func(igIsMouseDragging(int button, float lock_threshold); bool
; Get_UI_Lib_Func(igIsMouseHoveringRect(CONST struct ImVec2 r_min, CONST struct ImVec2 r_max, bool clip); bool
; Get_UI_Lib_Func(igIsMousePosValid(CONST struct ImVec2 *mouse_pos); bool
; ;
Get_UI_Lib_Func(igGetMousePos, (*pOut_ImVec2)); void
; Get_UI_Lib_Func(igGetMousePosOnOpeningCurrentPopup(struct ImVec2 *pOut); void
; Get_UI_Lib_Func(igGetMouseDragDelta(struct ImVec2 *pOut, int button, float lock_threshold); void
; Get_UI_Lib_Func(igResetMouseDragDelta(int button); void
; Get_UI_Lib_Func(igGetMouseCursor(); ImGuiMouseCursor
; Get_UI_Lib_Func(igSetMouseCursor(ImGuiMouseCursor type); void
; Get_UI_Lib_Func(igCaptureKeyboardFromApp(bool capture); void
; Get_UI_Lib_Func(igCaptureMouseFromApp(bool capture); void
; 
;- Helpers functions To access functions pointers in ImGui::GetIO()
; Get_UI_Lib_Func(*igMemAlloc(size_t sz); void
; Get_UI_Lib_Func(igMemFree(void *ptr); void
; Get_UI_Lib_Func(char *igGetClipboardText(); CONST
Get_UI_Lib_Func(igSetClipboardText, (text.s)); void
; 
; // Internal state access - If you want To share ImGui state between modules (e.g. DLL) Or allocate it yourself
Get_UI_Lib_Func(igGetVersion,()); CONST char *
; Get_UI_Lib_Func(ImGuiContext *igCreateContext(void *(*malloc_fn)(size_t), void (*free_fn)(void *)); struct
; Get_UI_Lib_Func(igDestroyContext(struct ImGuiContext *ctx); void
; Get_UI_Lib_Func(ImGuiContext *igGetCurrentContext(); struct
; Get_UI_Lib_Func(igSetCurrentContext(struct ImGuiContext *ctx); void
; 
; Get_UI_Lib_Func(ImFontConfig_DefaultConstructor(struct ImFontConfig *config); void
; 
; // ImGuiIO
; Get_UI_Lib_Func(ImGuiIO_AddInputCharacter(unsigned short c); void
; Get_UI_Lib_Func(ImGuiIO_AddInputCharactersUTF8(CONST char *utf8_chars); void
; Get_UI_Lib_Func(ImGuiIO_ClearInputCharacters(); void
; 
; // ImGuiTextFilter
; Get_UI_Lib_Func(ImGuiTextFilter *ImGuiTextFilter_Create(CONST char *default_filter); struct
; Get_UI_Lib_Func(ImGuiTextFilter_Destroy(struct ImGuiTextFilter *filter); void
; Get_UI_Lib_Func(ImGuiTextFilter_Clear(struct ImGuiTextFilter *filter); void
; Get_UI_Lib_Func(ImGuiTextFilter_Draw(struct ImGuiTextFilter *filter, label.s, float width); bool
; Get_UI_Lib_Func(ImGuiTextFilter_PassFilter(CONST struct ImGuiTextFilter *filter, CONST char *text, CONST char *text_end); bool
; Get_UI_Lib_Func(ImGuiTextFilter_IsActive(CONST struct ImGuiTextFilter *filter); bool
; Get_UI_Lib_Func(ImGuiTextFilter_Build(struct ImGuiTextFilter *filter); void
; Get_UI_Lib_Func(char *ImGuiTextFilter_GetInputBuf(struct ImGuiTextFilter *filter); CONST
; 
; // ImGuiTextBuffer
; Get_UI_Lib_Func(ImGuiTextBuffer *ImGuiTextBuffer_Create(); struct
; Get_UI_Lib_Func(ImGuiTextBuffer_Destroy(struct ImGuiTextBuffer *buffer); void
; Get_UI_Lib_Func(ImGuiTextBuffer_index(struct ImGuiTextBuffer *buffer, int i); char
; Get_UI_Lib_Func(char *ImGuiTextBuffer_begin(CONST struct ImGuiTextBuffer *buffer); CONST
; Get_UI_Lib_Func(char *ImGuiTextBuffer_end(CONST struct ImGuiTextBuffer *buffer); CONST
; Get_UI_Lib_Func(ImGuiTextBuffer_size(CONST struct ImGuiTextBuffer *buffer); int
; Get_UI_Lib_Func(ImGuiTextBuffer_empty(struct ImGuiTextBuffer *buffer); bool
; Get_UI_Lib_Func(ImGuiTextBuffer_clear(struct ImGuiTextBuffer *buffer); void
; Get_UI_Lib_Func(char *ImGuiTextBuffer_c_str(CONST struct ImGuiTextBuffer *buffer); CONST
; Get_UI_Lib_Func(ImGuiTextBuffer_appendf(struct ImGuiTextBuffer *buffer, CONST char *fmt, ...); void
; Get_UI_Lib_Func(ImGuiTextBuffer_appendfv(struct ImGuiTextBuffer *buffer, CONST char *fmt, va_list args); void
; 
; // ImGuiStorage
; Get_UI_Lib_Func(ImGuiStorage *ImGuiStorage_Create(); struct
; Get_UI_Lib_Func(ImGuiStorage_Destroy(struct ImGuiStorage *storage); void
; Get_UI_Lib_Func(ImGuiStorage_GetInt(struct ImGuiStorage *storage, ImGuiID key, int default_val); int
; Get_UI_Lib_Func(ImGuiStorage_SetInt(struct ImGuiStorage *storage, ImGuiID key, int val); void
; Get_UI_Lib_Func(ImGuiStorage_GetBool(struct ImGuiStorage *storage, ImGuiID key, bool default_val); bool
; Get_UI_Lib_Func(ImGuiStorage_SetBool(struct ImGuiStorage *storage, ImGuiID key, bool val); void
; Get_UI_Lib_Func(ImGuiStorage_GetFloat(struct ImGuiStorage *storage, ImGuiID key, float default_val); float
; Get_UI_Lib_Func(ImGuiStorage_SetFloat(struct ImGuiStorage *storage, ImGuiID key, float val); void
; Get_UI_Lib_Func(*ImGuiStorage_GetVoidPtr(struct ImGuiStorage *storage, ImGuiID key); void
; Get_UI_Lib_Func(ImGuiStorage_SetVoidPtr(struct ImGuiStorage *storage, ImGuiID key, void *val); void
; Get_UI_Lib_Func(*ImGuiStorage_GetIntRef(struct ImGuiStorage *storage, ImGuiID key, int default_val); int
; Get_UI_Lib_Func(*ImGuiStorage_GetBoolRef(struct ImGuiStorage *storage, ImGuiID key, bool default_val); bool
; Get_UI_Lib_Func(*ImGuiStorage_GetFloatRef(struct ImGuiStorage *storage, ImGuiID key, float default_val); float
; Get_UI_Lib_Func(**ImGuiStorage_GetVoidPtrRef(struct ImGuiStorage *storage, ImGuiID key, void *default_val); void
; Get_UI_Lib_Func(ImGuiStorage_SetAllInt(struct ImGuiStorage *storage, int val); void
; 
; // ImGuiTextEditCallbackData
; Get_UI_Lib_Func(ImGuiTextEditCallbackData_DeleteChars(struct ImGuiTextEditCallbackData *Data, int pos, int bytes_count); void
; Get_UI_Lib_Func(ImGuiTextEditCallbackData_InsertChars(struct ImGuiTextEditCallbackData *Data, int pos, CONST char *text, CONST char *text_end); void
; Get_UI_Lib_Func(ImGuiTextEditCallbackData_HasSelection(struct ImGuiTextEditCallbackData *Data); bool
; 
; // ImGuiListClipper
; Get_UI_Lib_Func(ImGuiListClipper_Step(struct ImGuiListClipper *clipper); bool
; Get_UI_Lib_Func(ImGuiListClipper_Begin(struct ImGuiListClipper *clipper, int count, float items_height); void
; Get_UI_Lib_Func(ImGuiListClipper_End(struct ImGuiListClipper *clipper); void
; Get_UI_Lib_Func(ImGuiListClipper_GetDisplayStart(struct ImGuiListClipper *clipper); int
; Get_UI_Lib_Func(ImGuiListClipper_GetDisplayEnd(struct ImGuiListClipper *clipper); int
; 
; //ImDrawList
Get_UI_Lib_Func(ImDrawList_GetVertexBufferSize, (*ImDrawList)); int
Get_UI_Lib_Func(ImDrawList_GetVertexPtr, (*ImDrawList, n.l)); struct ImDrawVert *
; Get_UI_Lib_Func(ImDrawList_GetIndexBufferSize(struct ImDrawList *List); int
; Get_UI_Lib_Func(*ImDrawList_GetIndexPtr(struct ImDrawList *List, int n); ImDrawIdx
; Get_UI_Lib_Func(ImDrawList_GetCmdSize(struct ImDrawList *List); int
; Get_UI_Lib_Func(ImDrawCmd *ImDrawList_GetCmdPtr(struct ImDrawList *List, int n); struct
; 
; Get_UI_Lib_Func(ImDrawList_Clear(struct ImDrawList *List); void
; Get_UI_Lib_Func(ImDrawList_ClearFreeMemory(struct ImDrawList *List); void
; Get_UI_Lib_Func(ImDrawList_PushClipRect(struct ImDrawList *List, struct ImVec2 clip_rect_min, struct ImVec2 clip_rect_max, bool intersect_with_current_clip_rect); void
; Get_UI_Lib_Func(ImDrawList_PushClipRectFullScreen(struct ImDrawList *List); void
; Get_UI_Lib_Func(ImDrawList_PopClipRect(struct ImDrawList *List); void
; Get_UI_Lib_Func(ImDrawList_PushTextureID(struct ImDrawList *List, CONST ImTextureID texture_id); void
; Get_UI_Lib_Func(ImDrawList_PopTextureID(struct ImDrawList *List); void
; Get_UI_Lib_Func(ImDrawList_GetClipRectMin(struct ImVec2 *pOut, struct ImDrawList *List); void
; Get_UI_Lib_Func(ImDrawList_GetClipRectMax(struct ImVec2 *pOut, struct ImDrawList *List); void
; 
; // Primitives
; Get_UI_Lib_Func(ImDrawList_AddLine(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, ImU32 col, float thickness); void
; Get_UI_Lib_Func(ImDrawList_AddRect(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, ImU32 col, float rounding, int rounding_corners_flags, float thickness); void
; Get_UI_Lib_Func(ImDrawList_AddRectFilled(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, ImU32 col, float rounding, int rounding_corners_flags); void
; Get_UI_Lib_Func(ImDrawList_AddRectFilledMultiColor(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, ImU32 col_upr_left, ImU32 col_upr_right, ImU32 col_bot_right, ImU32 col_bot_left); void
; Get_UI_Lib_Func(ImDrawList_AddQuad(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 c, CONST struct ImVec2 d, ImU32 col, float thickness); void
; Get_UI_Lib_Func(ImDrawList_AddQuadFilled(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 c, CONST struct ImVec2 d, ImU32 col); void
; Get_UI_Lib_Func(ImDrawList_AddTriangle(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 c, ImU32 col, float thickness); void
; Get_UI_Lib_Func(ImDrawList_AddTriangleFilled(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 c, ImU32 col); void
; Get_UI_Lib_Func(ImDrawList_AddCircle(struct ImDrawList *List, CONST struct ImVec2 centre, float radius, ImU32 col, int num_segments, float thickness); void
; Get_UI_Lib_Func(ImDrawList_AddCircleFilled(struct ImDrawList *List, CONST struct ImVec2 centre, float radius, ImU32 col, int num_segments); void
; Get_UI_Lib_Func(ImDrawList_AddText(struct ImDrawList *List, CONST struct ImVec2 pos, ImU32 col, CONST char *text_begin, CONST char *text_end); void
; Get_UI_Lib_Func(ImDrawList_AddTextExt(struct ImDrawList *List, CONST struct ImFont *font, float font_size, CONST struct ImVec2 pos, ImU32 col, CONST char *text_begin, CONST char *text_end, float wrap_width, CONST struct ImVec4 *cpu_fine_clip_rect); void
Get_UI_Lib_Func(ImDrawList_AddImage, (*ImDrawList, user_texture_id.l, aX.f,aY.f, bX.f,bY.f,  uv_aX.f=0.0,uv_aY.f=0.0, uv_bX.f=1.0,uv_bY.f=1.0, col.l=-1)); void
; Get_UI_Lib_Func(ImDrawList_AddImageQuad(struct ImDrawList *List, ImTextureID user_texture_id, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 c, CONST struct ImVec2 d, CONST struct ImVec2 uv_a, CONST struct ImVec2 uv_b, CONST struct ImVec2 uv_c, CONST struct ImVec2 uv_d, ImU32 col); void
; Get_UI_Lib_Func(ImDrawList_AddImageRounded(struct ImDrawList *List, ImTextureID user_texture_id, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 uv_a, CONST struct ImVec2 uv_b, ImU32 col, float rounding, int rounding_corners); void
; Get_UI_Lib_Func(ImDrawList_AddPolyline(struct ImDrawList *List, CONST struct ImVec2 *points, CONST int num_points, ImU32 col, bool closed, float thickness); void
; Get_UI_Lib_Func(ImDrawList_AddConvexPolyFilled(struct ImDrawList *List, CONST struct ImVec2 *points, CONST int num_points, ImU32 col); void
; Get_UI_Lib_Func(ImDrawList_AddBezierCurve(struct ImDrawList *List, CONST struct ImVec2 pos0, CONST struct ImVec2 cp0, CONST struct ImVec2 cp1, CONST struct ImVec2 pos1, ImU32 col, float thickness, int num_segments); void
; 
; // Stateful path API, add points then finish With PathFill() Or PathStroke()
; Get_UI_Lib_Func(ImDrawList_PathClear(struct ImDrawList *List); void
; Get_UI_Lib_Func(ImDrawList_PathLineTo(struct ImDrawList *List, CONST struct ImVec2 pos); void
; Get_UI_Lib_Func(ImDrawList_PathLineToMergeDuplicate(struct ImDrawList *List, CONST struct ImVec2 pos); void
; Get_UI_Lib_Func(ImDrawList_PathFillConvex(struct ImDrawList *List, ImU32 col); void
; Get_UI_Lib_Func(ImDrawList_PathStroke(struct ImDrawList *List, ImU32 col, bool closed, float thickness); void
; Get_UI_Lib_Func(ImDrawList_PathArcTo(struct ImDrawList *List, CONST struct ImVec2 centre, float radius, float a_min, float a_max, int num_segments); void
; Get_UI_Lib_Func(ImDrawList_PathArcToFast(struct ImDrawList *List, CONST struct ImVec2 centre, float radius, int a_min_of_12, int a_max_of_12); // Use precomputed angles for a 12 steps circle void
; Get_UI_Lib_Func(ImDrawList_PathBezierCurveTo(struct ImDrawList *List, CONST struct ImVec2 p1, CONST struct ImVec2 p2, CONST struct ImVec2 p3, int num_segments); void
; Get_UI_Lib_Func(ImDrawList_PathRect(struct ImDrawList *List, CONST struct ImVec2 rect_min, CONST struct ImVec2 rect_max, float rounding, int rounding_corners_flags); void
; 
; // Channels
; Get_UI_Lib_Func(ImDrawList_ChannelsSplit(struct ImDrawList *List, int channels_count); void
; Get_UI_Lib_Func(ImDrawList_ChannelsMerge(struct ImDrawList *List); void
; Get_UI_Lib_Func(ImDrawList_ChannelsSetCurrent(struct ImDrawList *List, int channel_index); void
; 
; // Advanced
; Get_UI_Lib_Func(ImDrawList_AddCallback(struct ImDrawList *List, ImDrawCallback callback, void *callback_data); // Your rendering function must check for 'UserCallback' in ImDrawCmd and call the function instead of rendering triangles. void
; Get_UI_Lib_Func(ImDrawList_AddDrawCmd(struct ImDrawList *List);                                                // This is useful if you need to forcefully create a new draw call (to allow for dependent rendering / blending). Otherwise primitives are merged into the same draw-call as much as possible void
; 
; // Internal helpers
; Get_UI_Lib_Func(ImDrawList_PrimReserve(struct ImDrawList *List, int idx_count, int vtx_count); void
; Get_UI_Lib_Func(ImDrawList_PrimRect(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, ImU32 col); void
; Get_UI_Lib_Func(ImDrawList_PrimRectUV(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 uv_a, CONST struct ImVec2 uv_b, ImU32 col); void
; Get_UI_Lib_Func(ImDrawList_PrimQuadUV(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 c, CONST struct ImVec2 d, CONST struct ImVec2 uv_a, CONST struct ImVec2 uv_b, CONST struct ImVec2 uv_c, CONST struct ImVec2 uv_d, ImU32 col); void
; Get_UI_Lib_Func(ImDrawList_PrimWriteVtx(struct ImDrawList *List, CONST struct ImVec2 pos, CONST struct ImVec2 uv, ImU32 col); void
; Get_UI_Lib_Func(ImDrawList_PrimWriteIdx(struct ImDrawList *List, ImDrawIdx idx); void
; Get_UI_Lib_Func(ImDrawList_PrimVtx(struct ImDrawList *List, CONST struct ImVec2 pos, CONST struct ImVec2 uv, ImU32 col); void
; Get_UI_Lib_Func(ImDrawList_UpdateClipRect(struct ImDrawList *List); void
; Get_UI_Lib_Func(ImDrawList_UpdateTextureID(struct ImDrawList *List); void
; 
; // ImDrawData
; Get_UI_Lib_Func(ImDrawData_DeIndexAllBuffers(struct ImDrawData *drawData); void
; Get_UI_Lib_Func(ImDrawData_ScaleClipRects(struct ImDrawData *drawData, CONST struct ImVec2 sc); void
; 
; // ImFontAtlas
; Get_UI_Lib_Func(ImFontAtlas_GetTexDataAsRGBA32(struct ImFontAtlas *atlas, unsigned char **out_pixels, int *out_width, int *out_height, int *out_bytes_per_pixel); void
; Get_UI_Lib_Func(ImFontAtlas_GetTexDataAsAlpha8(struct ImFontAtlas *atlas, unsigned char **out_pixels, int *out_width, int *out_height, int *out_bytes_per_pixel); void
; Get_UI_Lib_Func(ImFontAtlas_SetTexID(struct ImFontAtlas *atlas, ImTextureID id); void
; Get_UI_Lib_Func(ImFont *ImFontAtlas_AddFont(struct ImFontAtlas *atlas, CONST struct ImFontConfig *font_cfg); struct
; Get_UI_Lib_Func(ImFont *ImFontAtlas_AddFontDefault(struct ImFontAtlas *atlas, CONST struct ImFontConfig *font_cfg); struct
; Get_UI_Lib_Func(ImFont *ImFontAtlas_AddFontFromFileTTF(struct ImFontAtlas *atlas, CONST char *filename, float size_pixels, CONST struct ImFontConfig *font_cfg, CONST ImWchar *glyph_ranges); struct
; Get_UI_Lib_Func(ImFont *ImFontAtlas_AddFontFromMemoryTTF(struct ImFontAtlas *atlas, void *font_data, int font_size, float size_pixels, CONST struct ImFontConfig *font_cfg, CONST ImWchar *glyph_ranges); struct
; Get_UI_Lib_Func(ImFont *ImFontAtlas_AddFontFromMemoryCompressedTTF(struct ImFontAtlas *atlas, CONST void *compressed_font_data, int compressed_font_size, float size_pixels, CONST struct ImFontConfig *font_cfg, CONST ImWchar *glyph_ranges); struct
; Get_UI_Lib_Func(ImFont *ImFontAtlas_AddFontFromMemoryCompressedBase85TTF(struct ImFontAtlas *atlas, CONST char *compressed_font_data_base85, float size_pixels, CONST struct ImFontConfig *font_cfg, CONST ImWchar *glyph_ranges); struct
; Get_UI_Lib_Func(ImFontAtlas_ClearTexData(struct ImFontAtlas *atlas); void
; Get_UI_Lib_Func(ImFontAtlas_Clear(struct ImFontAtlas *atlas); void
; Get_UI_Lib_Func(ImWchar *ImFontAtlas_GetGlyphRangesDefault(struct ImFontAtlas *atlas); CONST
; Get_UI_Lib_Func(ImWchar *ImFontAtlas_GetGlyphRangesKorean(struct ImFontAtlas *atlas); CONST
; Get_UI_Lib_Func(ImWchar *ImFontAtlas_GetGlyphRangesJapanese(struct ImFontAtlas *atlas); CONST
; Get_UI_Lib_Func(ImWchar *ImFontAtlas_GetGlyphRangesChinese(struct ImFontAtlas *atlas); CONST
; Get_UI_Lib_Func(ImWchar *ImFontAtlas_GetGlyphRangesCyrillic(struct ImFontAtlas *atlas); CONST
; Get_UI_Lib_Func(ImWchar *ImFontAtlas_GetGlyphRangesThai(struct ImFontAtlas *atlas); CONST
; 
; Get_UI_Lib_Func(ImFontAtlas_GetTexID(struct ImFontAtlas *atlas); ImTextureID
; Get_UI_Lib_Func(char *ImFontAtlas_GetTexPixelsAlpha8(struct ImFontAtlas *atlas); unsigned
; Get_UI_Lib_Func(int *ImFontAtlas_GetTexPixelsRGBA32(struct ImFontAtlas *atlas); unsigned
; Get_UI_Lib_Func(ImFontAtlas_GetTexWidth(struct ImFontAtlas *atlas); int
; Get_UI_Lib_Func(ImFontAtlas_GetTexHeight(struct ImFontAtlas *atlas); int
; Get_UI_Lib_Func(ImFontAtlas_GetTexDesiredWidth(struct ImFontAtlas *atlas); int
; Get_UI_Lib_Func(ImFontAtlas_SetTexDesiredWidth(struct ImFontAtlas *atlas, int TexDesiredWidth_); void
; Get_UI_Lib_Func(ImFontAtlas_GetTexGlyphPadding(struct ImFontAtlas *atlas); int
; Get_UI_Lib_Func(ImFontAtlas_SetTexGlyphPadding(struct ImFontAtlas *atlas, int TexGlyphPadding_); void
; Get_UI_Lib_Func(ImFontAtlas_GetTexUvWhitePixel(struct ImFontAtlas *atlas, struct ImVec2 *pOut); void
; 
; // ImFontAtlas::Fonts;
; Get_UI_Lib_Func(ImFontAtlas_Fonts_size(struct ImFontAtlas *atlas); int
; Get_UI_Lib_Func(ImFont *ImFontAtlas_Fonts_index(struct ImFontAtlas *atlas, int index); struct
; 
; // ImFont
; Get_UI_Lib_Func(ImFont_GetFontSize(CONST struct ImFont *font); float
; Get_UI_Lib_Func(ImFont_SetFontSize(struct ImFont *font, float FontSize_); void
; Get_UI_Lib_Func(ImFont_GetScale(CONST struct ImFont *font); float
; Get_UI_Lib_Func(ImFont_SetScale(struct ImFont *font, float Scale_); void
; Get_UI_Lib_Func(ImFont_GetDisplayOffset(CONST struct ImFont *font, struct ImVec2 *pOut); void
; Get_UI_Lib_Func(struct IMFONTGLYPH *ImFont_GetFallbackGlyph(CONST struct ImFont *font); CONST
; Get_UI_Lib_Func(ImFont_SetFallbackGlyph(struct ImFont *font, CONST struct IMFONTGLYPH *FallbackGlyph_); void
; Get_UI_Lib_Func(ImFont_GetFallbackAdvanceX(CONST struct ImFont *font); float
; Get_UI_Lib_Func(ImFont_GetFallbackChar(CONST struct ImFont *font); ImWchar
; Get_UI_Lib_Func(ImFont_GetConfigDataCount(CONST struct ImFont *font); short
; Get_UI_Lib_Func(ImFontConfig *ImFont_GetConfigData(struct ImFont *font); struct
; Get_UI_Lib_Func(ImFontAtlas *ImFont_GetContainerAtlas(struct ImFont *font); struct
; Get_UI_Lib_Func(ImFont_GetAscent(CONST struct ImFont *font); float
; Get_UI_Lib_Func(ImFont_GetDescent(CONST struct ImFont *font); float
; Get_UI_Lib_Func(ImFont_GetMetricsTotalSurface(CONST struct ImFont *font); int
; Get_UI_Lib_Func(ImFont_ClearOutputData(struct ImFont *font); void
; Get_UI_Lib_Func(ImFont_BuildLookupTable(struct ImFont *font); void
; Get_UI_Lib_Func(struct IMFONTGLYPH *ImFont_FindGlyph(CONST struct ImFont *font, ImWchar c); CONST
; Get_UI_Lib_Func(ImFont_SetFallbackChar(struct ImFont *font, ImWchar c); void
; Get_UI_Lib_Func(ImFont_GetCharAdvance(CONST struct ImFont *font, ImWchar c); float
; Get_UI_Lib_Func(ImFont_IsLoaded(CONST struct ImFont *font); bool
; Get_UI_Lib_Func(char *ImFont_GetDebugName(CONST struct ImFont *font); CONST
; Get_UI_Lib_Func(ImFont_CalcTextSizeA(CONST struct ImFont *font, struct ImVec2 *pOut, float size, float max_width, float wrap_width, CONST char *text_begin, CONST char *text_end, CONST char **remaining); // utf8 void
; Get_UI_Lib_Func(char *ImFont_CalcWordWrapPositionA(CONST struct ImFont *font, float scale, CONST char *text, CONST char *text_end, float wrap_width); CONST
; Get_UI_Lib_Func(ImFont_RenderChar(CONST struct ImFont *font, struct ImDrawList *draw_list, float size, struct ImVec2 pos, ImU32 col, unsigned short c); void
; Get_UI_Lib_Func(ImFont_RenderText(CONST struct ImFont *font, struct ImDrawList *draw_list, float size, struct ImVec2 pos, ImU32 col, CONST struct ImVec4 *clip_rect, CONST char *text_begin, CONST char *text_end, float wrap_width, bool cpu_fine_clip); void
; // ImFont::Glyph
; Get_UI_Lib_Func(ImFont_Glyphs_size(CONST struct ImFont *font); int
; Get_UI_Lib_Func(IMFONTGLYPH *ImFont_Glyphs_index(struct ImFont *font, int index); struct
; // ImFont::IndexXAdvance
; Get_UI_Lib_Func(ImFont_IndexXAdvance_size(CONST struct ImFont *font); int
; Get_UI_Lib_Func(ImFont_IndexXAdvance_index(CONST struct ImFont *font, int index); float
; // ImFont::IndexLookup
; Get_UI_Lib_Func(ImFont_IndexLookup_size(CONST struct ImFont *font); int
; Get_UI_Lib_Func(short ImFont_IndexLookup_index(CONST struct ImFont *font, int index); unsigned
;}


Else ; if library is not open
  Debug "Cannot load requred library " + #IMGUIDLL
  CompilerIf Defined(_TERMINATE_IF_DLL_MISSING, #PB_Constant)
    End
  CompilerEndIf  
EndIf;  // end of load library


Debug "pb-cimgui: Loaded " + LibImGui_API_Coverage + " Functions"

; IDE Options = PureBasic 5.40 LTS (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 5
; Folding = --
; Markers = 353,736
; EnableXP