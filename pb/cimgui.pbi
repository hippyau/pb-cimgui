EnableExplicit
;- DON'T FORMAT INDENTATION ON THIS FILE
;- it seems to screw up the comments


;-----------------------------------------------------
; Attempts to get ImGui in PB
; 
; This attemps to import and use my compilation of CImGui.dll into PureBasic
; I am not confident in doing all the backend rendering stuff for ImGui in Purebasic myself,
; so my compilation of CImGui has extra functions to (try to) take care of the backend (openGL3 / glfw3 in this case)
;
;  Well, that's the plan... The DLL can create my display and I just use ImGui SDK calls
;  to make a cool GUI that I can use in PureBasic.  I know I can't use all the fancy GL 
;  stuff directly, but to be honest I get lost in 3D land, and I just want a 2D UI not a 
;  game engine.  
;
;  I imported the structures with PB Header Importer, and did some find/replace work
;  and I also used this crap to make it easier
Procedure AssistHeaderConversion()
  Protected fileno.l = OpenFile(1, "cimgui.h")
  Protected line.s = ""
  Protected type.s = ""
  Repeat 
    line = ReadString(fileno)    
    If StringField(line,1," ") <> "CIMGUI_API" 
      Debug line ; the line is not a CIMGUI_API definition so just print it
      Continue
    EndIf
    type.s = StringField(line,2," ") ; void / int / bool etc...
    line = ReplaceString(line,"CIMGUI_API "+type+" ", "GetLibFunc(")
    line = line + " " + type ; commment at the end of the line what type it is returning
    Debug line
  Until Eof(fileno)
  CloseFile(fileno)
EndProcedure

;
;  It's very early days, please contribute.


; Disable Unicode in Compiler Options
CompilerIf #PB_Compiler_Unicode
  Debug "cimgui.pbi:  You should disable unicode in the PB compiler settings or improve this interface to support unicode"
  End
CompilerEndIf




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
Global LibImGui = OpenLibrary(#PB_Any, "cimgui.dll")
Global LibImGui_API_Coverage = 0 ; count found functions

Macro _dq_
  "
EndMacro

; functions with arguments
Macro GetLibFunc(name, parameters)
  PrototypeC name#_Prototype parameters
  Global name.name#_Prototype
  If IsLibrary(LibImGui)
    name = GetFunction(LibImGui, _dq_#name#_dq_)
    If Not name 
      Debug "Failed to find '" + _dq_#name#_dq_ +"'"
    Else
    ;  Debug _dq_ name parameters _dq_
      LibImGui_API_Coverage + 1
    EndIf
  Else
    Debug "Library not open."    
    Print("Error, Unable To open cimgui.dll  -  Please reinstall this software.")
    CallDebugger
    End
  EndIf
EndMacro

; function with no arguments
Macro GetLibFuncVoid(name)
  GetLibFunc(name,())
EndMacro

;-----------------------
;----- CIMGUI Functions


;- Main 
GetLibFuncVoid(igGetIO)
GetLibFuncVoid(igGetStyle)
GetLibFuncVoid(igGetDrawData)
GetLibFuncVoid(igNewFrame)
GetLibFuncVoid(igRender)
GetLibFuncVoid(igEndFrame)
GetLibFuncVoid(igShutdown)

;- Demo/Debug/Info
GetLibFunc(igShowDemoWindow, (*opened))
GetLibFunc(igShowMetricsWindow, (*opened))
GetLibFunc(igShowStyleEditor, (*ref.ImGuiStyle))
GetLibFunc(igShowStyleSelector, (*label)) ; string
GetLibFunc(igShowFontSelector, (*label))  ; string
GetLibFuncVoid(igShowUserGuide)           ;


;- Window
GetLibFunc(igBegin, (name.s, *p_open, flags))                                             
GetLibFuncVoid(igEnd)                        

GetLibFunc(igBeginChild, (*str_id, w.f,h.f, border.b, extra_flags));
GetLibFunc(igBeginChildEx, (id.l, w.f,h.f, border.b, extra_flags)) ;

GetLibFuncVoid(igEndChild);
GetLibFunc(igGetContentRegionMax, (*out.ImVec2));
GetLibFunc(igGetContentRegionAvail, (*out.ImVec2));
GetLibFuncVoid(igGetContentRegionAvailWidth)      ;
GetLibFunc(igGetWindowContentRegionMin, (*out.ImVec2));
GetLibFunc(igGetWindowContentRegionMax, (*out.ImVec2));
GetLibFuncVoid(igGetWindowContentRegionWidth)         ;
GetLibFuncVoid(igGetWindowDrawList)                   ;
GetLibFunc(igGetWindowPos, (*out.ImVec2))             ;
GetLibFunc(igGetWindowSize, (*out.ImVec2))            ;
GetLibFuncVoid(igGetWindowWidth)                      ;
GetLibFuncVoid(igGetWindowHeight)                     ;
GetLibFuncVoid(igIsWindowCollapsed)                   ;
GetLibFuncVoid(igIsWindowAppearing)                   ;
GetLibFunc(igSetWindowFontScale, (scale.f))           ;

GetLibFunc(igSetNextWindowPos, (X.f,Y.f, cond.l=0, pivot.p-variant=0))
GetLibFunc(igSetNextWindowSize, (w.f,h.f, cond.l=0))
GetLibFunc(igSetNextWindowSizeConstraints, (minW.f,minH.f, maxW.f,maxH.f, *custom_callback, *custom_callback_data)) ; (CONST struct ImVec2 size_min, CONST struct ImVec2 size_max, ImGuiSizeConstraintCallback custom_callback, void *custom_callback_data);
GetLibFunc(igSetNextWindowContentSize, (eo.p-variant) )                                                                       ; ImVec2
GetLibFunc(igSetNextWindowCollapsed, (collapsed.b, cond.l))
GetLibFuncVoid(igSetNextWindowFocus)
GetLibFunc(igSetWindowPos, (X.f,Y.f, cond.l)) ; (CONST struct ImVec2 pos, ImGuiCond cond);
GetLibFunc(igSetWindowSize, (w.f,h.f, cond.l)); (CONST struct ImVec2 size, ImGuiCond cond);
GetLibFunc(igSetWindowCollapsed, (collapsed.b, cond.l))
GetLibFuncVoid(igSetWindowFocus);
GetLibFunc(igSetWindowPosByName, (name.s, X.f,Y.f, cond.l))
GetLibFunc(igSetWindowSize2, (name.s, w.f,h.f, cond.l))
GetLibFunc(igSetWindowCollapsed2, (name.s, collapsed.b, cond.l))
GetLibFunc(igSetWindowFocus2, (name.s));

GetLibFuncVoid(igGetScrollX) ; float
GetLibFuncVoid(igGetScrollY) ; float
GetLibFuncVoid(igGetScrollMaxX) ; float
GetLibFuncVoid(igGetScrollMaxY) ; float
GetLibFunc(igSetScrollX, (scroll_X.f))
GetLibFunc(igSetScrollY, (scroll_Y.f))
GetLibFunc(igSetScrollHere, (center_y_ratio.f))
GetLibFunc(igSetScrollFromPosY, (pos_Y.f, center_y_ratio.f));

;TODO:  ImGuiStorage structure
;GetLibFunc(igSetStateStorage, (*tree.ImGuiStorage))
;GetLibFuncVoid(igGetStateStorage) ;.ImGuiStorage

;- Parameters stacks (Shared)
GetLibFunc(igPushFont, (*font)); void
GetLibFunc(igPopFont,())       ; void
GetLibFunc(igPushStyleColorU32, (idx.l, col.l)); void
GetLibFunc(igPushStyleColor, (idx.l, R.f,G.f,B.f,A.f)); void  ; col is ImVec4
GetLibFunc(igPopStyleColor,(count.l))               ; void
GetLibFunc(igPushStyleVar,(idx.l, val.f))           ; void
GetLibFunc(igPushStyleVarVec,(idx.l, X.f,Y.f)); void ; val is ImVec2
GetLibFunc(igPopStyleVar,(count.l))                 ; void
GetLibFunc(igGetStyleColorVec4,(*pOut.ImVec4, idx.l)); void
GetLibFunc(igGetFont,())                             ; struct *ImFont
GetLibFunc(igGetFontSize,())                         ; float
GetLibFunc(igGetFontTexUvWhitePixel,(*pOut.ImVec2))  ; void
GetLibFunc(igGetColorU32,(idx.l, alpha_mul.f))       ; ImU32
GetLibFunc(igGetColorU32Vec,(*col.ImVec4))           ; ImU32
GetLibFunc(igGetColorU32U32,(col.l))                 ; ImU32

;- Parameters stacks (current window)
GetLibFunc(igPushItemWidth,(item_width.f)); void
GetLibFunc(igPopItemWidth,())             ; void
GetLibFunc(igCalcItemWidth,())            ; float
GetLibFunc(igPushTextWrapPos,(wrap_pos_X.f)); void
GetLibFunc(igPopTextWrapPos,())             ; void
GetLibFunc(igPushAllowKeyboardFocus,(v.b))  ; void
GetLibFunc(igPopAllowKeyboardFocus,())      ; void
GetLibFunc(igPushButtonRepeat,(Repeat_.b))  ; void
GetLibFunc(igPopButtonRepeat,())            ; void

;- Cursor / Layout
GetLibFunc(igSeparator,()); void
GetLibFunc(igSameLine,(pos_X.f, spacing_w.f)); void
GetLibFunc(igNewLine,())                     ; void
GetLibFunc(igSpacing,())                     ; void
GetLibFunc(igDummy,(*size.ImVec2))           ; void
GetLibFunc(igIndent,(indent_w.f))            ; void
GetLibFunc(igUnindent,(indent_w.f))          ; void
GetLibFunc(igBeginGroup,())                  ; void
GetLibFunc(igEndGroup,())                    ; void
GetLibFunc(igGetCursorPos,(*pOut.ImVec2))    ; void
GetLibFunc(igGetCursorPosX,())               ; float
GetLibFunc(igGetCursorPosY,())               ; float
GetLibFunc(igSetCursorPos,(local_pos.p-variant)); void ; ImVec2 
GetLibFunc(igSetCursorPosX,(X.f))               ; void
GetLibFunc(igSetCursorPosY,(Y.f))               ; void
GetLibFunc(igGetCursorStartPos,(*pOut.ImVec2))  ; void
GetLibFunc(igGetCursorScreenPos,(*pOut.ImVec2)) ; void
GetLibFunc(igSetCursorScreenPos,(pos.p-variant)); void ; ImVec2
GetLibFunc(igAlignTextToFramePadding,())        ; void
GetLibFunc(igGetTextLineHeight,())              ; float
GetLibFunc(igGetTextLineHeightWithSpacing,())   ; float
GetLibFunc(igGetFrameHeight,())                 ; float
GetLibFunc(igGetFrameHeightWithSpacing,())      ; float

;- Columns
GetLibFunc(igColumns,(count.l, id.s, border.b)); void
GetLibFunc(igNextColumn,())                    ; void
GetLibFunc(igGetColumnIndex,())                ; int
GetLibFunc(igGetColumnWidth,(column_index.l))  ; // get column width (in pixels). pass -1 to use current column float
GetLibFunc(igSetColumnWidth,(column_index.l, width.f)); void
GetLibFunc(igGetColumnOffset,(column_index.l))        ; float
GetLibFunc(igSetColumnOffset,(column_index.l, offset_X.f)); void
GetLibFunc(igGetColumnsCount,())                          ; int


;- ID scopes
;// If you are creating widgets in a loop you most likely want To push a unique identifier so ImGui can differentiate them
;// You can also use "##extra" within your widget name To distinguish them from each others (see 'Programmer Guide')
GetLibFunc(igPushIDStr,(str_id.s)); void
GetLibFunc(igPushIDStrRange,(str_begin.s, str_end.s)); void
GetLibFunc(igPushIDPtr,(*ptr_id))                    ; void
GetLibFunc(igPushIDInt,(int_id.l))                   ; void
GetLibFunc(igPopID,())                               ; void
GetLibFunc(igGetIDStr,(str_id.s))                    ; ImGuiID
GetLibFunc(igGetIDStrRange,(str_begins, str_end.s))  ; ImGuiID
GetLibFunc(igGetIDPtr,(*ptr_id))                     ; ImGuiID

;- Widgets: Text
GetLibFunc(igTextUnformatted,(text.s, text_end.s)); void
GetLibFunc(igText,(fmt.s))                        ; void
GetLibFunc(igTextV,(fmt.s, args.p-variant))       ; void
GetLibFunc(igTextColored,(R.f,G.f,B.f,A.f, fmt.s))  ; void ; RGBA
GetLibFunc(igTextColoredV,(R.f,G.f,B.f,A.f, fmt.s, args.p-variant=0)); void ; RGBA 
GetLibFunc(igTextDisabled,(fmt.s))                                 ; void
GetLibFunc(igTextDisabledV,(fmt.s, args.p-variant))                ; void
GetLibFunc(igTextWrapped,(fmt.s))                                  ; void
GetLibFunc(igTextWrappedV,(fmt.s, args.p-variant=0))               ; void
GetLibFunc(igLabelText,(label.s, fmt.s))                           ; void
GetLibFunc(igLabelTextV,(label.s, fmt.s, args.p-variant=0))        ; void
GetLibFunc(igBulletText,(fmt.s))                                   ; void
GetLibFunc(igBulletTextV,(fmt.s, args.p-variant=0))                ; void
GetLibFunc(igBullet,())                                            ; void


;- Widgets: Main
GetLibFunc(igButton,(label.s, W.f=0.0, H.f=0.0)); bool ; ; ImVec2
GetLibFunc(igSmallButton,(label.s))           ; bool
GetLibFunc(igInvisibleButton,(*str_id, W.f=0.0, H.f=0.0)); bool ; ImVec2

;TODO: 
;GetLibFunc(igImage,(user_texture_id.i, size.p-variant, uv0.p-variant, uv1.p-variant, tint_col.p-variant, border_col.p-variant)); void ; ImVec2 - col ImVec4
;-  Testing

;CIMGUI_API void igImage(ImTextureID user_texture_id, CONST struct ImVec2 size, CONST struct ImVec2 uv0, CONST struct ImVec2 uv1, CONST struct ImVec4 tint_col, CONST struct ImVec4 border_col);

;TODO: igImage - doesn't work, doesn't seem like they get drawn at all
GetLibFunc(igImage,(textureid.l, W.f, H.f, uv0X.f=0.0, uv0Y.f=0.0, uv1X.f=1.0, uv1Y.f=1.0,   tintR.f=255.0,tintG.f=255.0,tintB.f=255.0,tintA.f=255.0, border_colR.f=0.0,border_colG.f=0.0,border_colB.f=0.0,border_colA.f=0.0)); void ; ImVec2 - col ImVec4
;GetLibFunc(igImage,(user_texture_id.l)); void ; ImVec2 - col ImVec4
GetLibFunc(igImageButton,(user_texture_id.l, W.f, H.f, topleftX.f=0.0, topleftY.f=0.0, bottom_rightX.f=1.0, bottom_rightY.f=1.0, frame_padding.l=0, bordercolorR.f=0.0,bordercolorG.f=0.0,bordercolorB.f=0.0,bordercolorA.f=0.0, tintR.f=0.0,tintG.f=0.0,tintB.f=0.0,tintA.f=0.0)); bool
GetLibFunc(igCheckbox,(label.s, *v))                                                                                                              ; bool ; v is bool
GetLibFunc(igCheckboxFlags,(label.s, *flags, flags_value.l))                                                                                      ; bool
GetLibFunc(igRadioButtonBool,(label.s, active.b))                                                                                                 ; bool
GetLibFunc(igRadioButton,(label.s, *v, v_button.l))                                                                                               ; bool
GetLibFunc(igPlotLines,(label.s, *values, values_count.l, values_offset.l=0, overlay_text.s="", scale_min.f=0.0, scale_max.f=100.0, W.f=0.0,H.f=0.0, stride.l=4)); void ; graph_size is ImVec2
;GetLibFunc(igPlotLines2(label.s, float (*values_getter)(void *Data, int idx), void *Data, int values_count, int values_offset, CONST char *overlay_text, float scale_min, float scale_max, struct ImVec2 graph_size); void
GetLibFunc(igPlotHistogram,(label.s, *values, values_count.l, values_offset.l=0, overlay_text.s="", scale_min.f=0.0, scale_max.f=100.0, W.f=0.0,H.f=0.0, stride.l=4)); void
;GetLibFunc(igPlotHistogram2,(label.s, float (*values_getter)(void *Data, int idx), void *Data, int values_count, int values_offset, CONST char *overlay_text, float scale_min, float scale_max, struct ImVec2 graph_size); void
GetLibFunc(igProgressBar,(fraction.f, *size_arg.ImVec2, overlay.s))                                                                                      ; void

GetLibFunc(igBeginCombo,(label.s, preview_value.s, flags.l)); bool
GetLibFunc(igEndCombo,())                                   ; void
GetLibFunc(igCombo,(label.s, *current_item, *items, items_count.l, popup_max_height_in_items.l)); bool
GetLibFunc(igCombo2,(label.s, *current_item, *items_separated_by_zeros, popup_max_height_in_items.l)); bool
;GetLibFunc(igCombo3,(label.s, *current_item, Bool (*items_getter)(void *Data, int idx, CONST char **out_text), void *Data, int items_count, int popup_max_height_in_items); bool

;- Widgets: Drags (tip: ctrl+click on a drag box To input With keyboard. manually input values aren't clamped, can go off-bounds)
;// For all the Float2/Float3/Float4/Int2/Int3/Int4 versions of every functions, note that a 'float v[X]' function argument is the same As 'float* v', the Array syntax is just a way To document the number of elements that are expected To be accessible. You can pass address of your first element out of a contiguous set, e.g. &myvector.x
GetLibFunc(igDragFloat,(label.s, *v, v_speed.f, v_min.f, v_maX.f, display_format.s, power.f)); // If v_max >= v_max we have no bound bool
GetLibFunc(igDragFloat2,(label.s, *vF2, v_speed.f=0, v_min.f=0.0, v_max.f=255.0, display_format.s="", power.f=1)); bool
GetLibFunc(igDragFloat3,(label.s, *vF3, v_speed.f=0, v_min.f=0.0, v_max.f=255.0, display_format.s="", power.f=1)); bool
GetLibFunc(igDragFloat4,(label.s, *vF4, v_speed.f=0, v_min.f=0.0, v_max.f=255.0, display_format.s="", power.f=1)); bool
GetLibFunc(igDragFloatRange2,(label.s, *v_current_min_f, *v_current_max_f, v_speed.f, v_min.f, v_max.f, display_format.s, display_format_max.s, power.f)); bool
GetLibFunc(igDragInt,(label.s, *vL1, v_speed.f=0, v_min.l=0.0, v_max.l=255, display_format.s="%.0f")); // If v_max >= v_max we have no bound bool
GetLibFunc(igDragInt2,(label.s, *vL2, v_speed.f=0, v_min.l=0, v_max.l=255, display_format.s="%.0f")); // If v_max >= v_max we have no bound bool
GetLibFunc(igDragInt3,(label.s, *vL3, v_speed.f=0, v_min.l=0, v_max.l=255, display_format.s="%.0f")); // If v_max >= v_max we have no bound bool
GetLibFunc(igDragInt4,(label.s, *vL4, v_speed.f=0, v_min.l=0, v_max.l=255, display_format.s="%.0f")); // If v_max >= v_max we have no bound bool
GetLibFunc(igDragIntRange2,(label.s, *v_current_min_int, *v_current_max_int, v_speed.f, v_min.l, v_max.l, display_format.s, display_format_max.s)); bool

;- Widgets: Input With Keyboard
GetLibFunc(igInputText, (label.s, *buf_char, buf_size.l, flags.i=0, *callback=#Null, *user_data=#Null)); bool ; ImGuiInputTextFlags ; ImGuiTextEditCallback 
GetLibFunc(igInputTextMultiline, (label.s, *buf_char, buf_size.l, W.f=0.0, H.f=0.0, flags.l=#Null, *callback=#Null, *user_data=#Null)); bool
GetLibFunc(igInputFloat, (label.s, *vF, step_size.f, step_fast.f, decimal_precision.l, extra_flags.l))                                ; bool
GetLibFunc(igInputFloat2, (label.s, *vF2, step_size.f, step_fast.f, decimal_precision.l, extra_flags.l))
GetLibFunc(igInputFloat3, (label.s, *vF3, step_size.f, step_fast.f, decimal_precision.l, extra_flags.l))
GetLibFunc(igInputFloat4, (label.s, *vF4, step_size.f, step_fast.f, decimal_precision.l, extra_flags.l))
GetLibFunc(igInputInt, (label.s, *vL, step_size.l, step_fast.l, extra_flags.l)); bool
GetLibFunc(igInputInt2, (label.s, *vL, step_size.l, step_fast.l, extra_flags.l));
GetLibFunc(igInputInt3, (label.s, *vL, step_size.l, step_fast.l, extra_flags.l))
GetLibFunc(igInputInt4, (label.s, *vL, step_size.l, step_fast.l, extra_flags.l))

;- Widgets: Sliders (tip: ctrl+click on a slider To input With keyboard. manually input values aren't clamped, can go off-bounds)
GetLibFunc(igSliderFloat, (label.s, *vF, v_min.f, v_max.f, display_format.s="%.2f", power.f=1.0)); bool
GetLibFunc(igSliderFloat2, (label.s, *vF2, v_min.f, v_max.f, display_format.s="%.2f", power.f=1.0)); bool
GetLibFunc(igSliderFloat3, (label.s, *vF3, v_min.f, v_max.f, display_format.s="%.2f", power.f=1.0)); bool ;  *VFx is pointer to array/struct of float of size X
GetLibFunc(igSliderFloat4, (label.s, *vF4, v_min.f, v_max.f, display_format.s="%.2f", power.f=1.0)); bool
GetLibFunc(igSliderAngle, (label.s, *v_rad, v_degrees_min.f, v_degrees_max.f)); bool
GetLibFunc(igSliderInt, (label.s, *vL, v_min.l, v_max.l, display_format.s="%.0f")); bool
GetLibFunc(igSliderInt2, (label.s, *vL2, v_min.l, v_max.l, display_format.s="%.0f")); bool
GetLibFunc(igSliderInt3, (label.s, *vL3, v_min.l, v_max.l, display_format.s="%.0f")); bool
GetLibFunc(igSliderInt4, (label.s, *vL4, v_min.l, v_max.l, display_format.s="%.0f")); bool
GetLibFunc(igVSliderFloat, (label.s, W.f, H.f, *vF, v_min.f, v_max.f, display_format.s="", power.f=1.0)); bool
GetLibFunc(igVSliderInt, (label.s, W.f, H.f, *vL, v_min.l, v_max.l, display_format.s="")); bool
; 
;- Widgets: Color Editor/Picker (tip: the ColorEdit* functions have a little colored preview square that can be left-clicked To open a picker, And right-clicked To open an option menu.)
; // Note that a 'float v[X]' function argument is the same As 'float* v', the Array syntax is just a way To document the number of elements that are expected To be accessible. You can the pass the address of a first float element out of a contiguous Structure, e.g. &myvector.x
GetLibFunc(igColorEdit3, (label.s, *col_float3, flags.l=0)); bool ; ImGuiColorEditFlags 
GetLibFunc(igColorEdit4, (label.s, *col_float4, flags.l=0)); bool ; ImGuiColorEditFlags 
GetLibFunc(igColorPicker3, (label.s, *col_float3, flags.l=0)); bool ; ImGuiColorEditFlags 
GetLibFunc(igColorPicker4, (label.s, *col_float4, flags.l=0, *ref_col_float=#Null)); bool ; ImGuiColorEditFlags 
GetLibFunc(igColorButton, (desc_id.s, R.f,G.f,B.f,A.f, flags.l=0, W.f=0.0, H.f=0.0)); bool
GetLibFunc(igSetColorEditOptions, (flags.l)); void ; ImGuiColorEditFlags 
;
; TODO: 
;{
;- Widgets: Trees
GetLibFunc(igTreeNode, (label.s)); bool
GetLibFunc(igTreeNodeStr, (str_id.s, fmt.s, *args=#Null)); bool ; *args is pointer to array of pointers to each arg
GetLibFunc(igTreeNodePtr, (*ptr_id, fmt.s, *args=#Null)); bool
; GetLibFunc(igTreeNodeStrV(CONST char *str_id, CONST char *fmt, va_list args); bool
; GetLibFunc(igTreeNodePtrV(CONST void *ptr_id, CONST char *fmt, va_list args); bool
GetLibFunc(igTreeNodeEx, (label.s, flags.l)); bool ; ImGuiTreeNodeFlags 
GetLibFunc(igTreeNodeExStr, (str_id.s, flags.l, fmt.s, *args=#Null)); bool ; ImGuiTreeNodeFlags 
GetLibFunc(igTreeNodeExPtr, (*ptr_id, flags.l, fmt.s, *args=#Null)); bool ; ImGuiTreeNodeFlags 
; GetLibFunc(igTreeNodeExV(CONST char *str_id, ImGuiTreeNodeFlags flags, CONST char *fmt, va_list args); bool
; GetLibFunc(igTreeNodeExVPtr(CONST void *ptr_id, ImGuiTreeNodeFlags flags, CONST char *fmt, va_list args); bool
GetLibFunc(igTreePushStr, (str_id.s)); void
GetLibFunc(igTreePushPtr, (*ptr_id)); void
GetLibFunc(igTreePop, ()); void
GetLibFunc(igTreeAdvanceToLabelPos, ()); void
GetLibFunc(igGetTreeNodeToLabelSpacing, ()); float
GetLibFunc(igSetNextTreeNodeOpen, (opened.b, cond.l)); void ; ImGuiCond 
GetLibFunc(igCollapsingHeader, (label.s, flags.l)); bool ; ImGuiTreeNodeFlags 
GetLibFunc(igCollapsingHeaderEx, (label.s, *p_open_bool, flags.l)); bool ; ImGuiTreeNodeFlags 
; 
; // Widgets: Selectable / Lists
; GetLibFunc(igSelectable(label.s, bool selected, ImGuiSelectableFlags flags, CONST struct ImVec2 size); bool
; GetLibFunc(igSelectableEx(label.s, bool *p_selected, ImGuiSelectableFlags flags, CONST struct ImVec2 size); bool
; GetLibFunc(igListBox(label.s, int *current_item, CONST char *CONST *items, int items_count, int height_in_items); bool
; GetLibFunc(igListBox2(label.s, int *current_item, Bool (*items_getter)(void *Data, int idx, CONST char **out_text), void *Data, int items_count, int height_in_items); bool
; GetLibFunc(igListBoxHeader(label.s, CONST struct ImVec2 size); bool
; GetLibFunc(igListBoxHeader2(label.s, int items_count, int height_in_items); bool
; GetLibFunc(igListBoxFooter(); void
; 
; // Widgets: Value() Helpers. Output single value in "name: value" format (tip: freely Declare your own within the ImGui namespace!)
GetLibFunc(igValueBool, (prefix.s, boolean.b)); void
GetLibFunc(igValueInt, (prefix.s, v.l)); void
GetLibFunc(igValueUInt, (prefix.s, v.l)); void
GetLibFunc(igValueFloat, (prefix.s, v.f, float_format.s="")); void
; 
;- Tooltip
GetLibFunc(igSetTooltip, (fmt.s, *args=#Null)); void
; GetLibFunc(igSetTooltipV(CONST char *fmt, va_list args); void
GetLibFunc(igBeginTooltip,()); void
GetLibFunc(igEndTooltip,()); void
; 
;- Widgets: Menus
GetLibFunc(igBeginMainMenuBar, ()); bool
GetLibFunc(igEndMainMenuBar, ()); void
GetLibFunc(igBeginMenuBar, ()); bool
GetLibFunc(igEndMenuBar, ()); void
GetLibFunc(igBeginMenu, (label.s, enabled.b)); bool
GetLibFunc(igEndMenu, ()); void
GetLibFunc(igMenuItem, (label.s, shortcut.s, selected.b, enabled.b)); bool
GetLibFunc(igMenuItemPtr, (label.s, shortcut.s, *p_selected_bool, enabled.b)); bool
; 
;- Popup
GetLibFunc(igOpenPopup, (str_id.s)); void
GetLibFunc(igOpenPopupOnItemClick, (str_id.s, mouse_button.l)); bool
GetLibFunc(igBeginPopup, (str_id.s)); bool
GetLibFunc(igBeginPopupModal, (name.s, *p_open_bool, extra_flags.l)); bool ; ImGuiWindowFlags 
GetLibFunc(igBeginPopupContextItem, (str_id.s, mouse_button.l)); bool
GetLibFunc(igBeginPopupContextWindow, (str_id.s, mouse_button.l, also_over_items.b)); bool
GetLibFunc(igBeginPopupContextVoid, (str_id.s, mouse_button.l)); bool
GetLibFunc(igEndPopup, ()); void
GetLibFunc(igIsPopupOpen, (str_id.s)); bool
GetLibFunc(igCloseCurrentPopup, ()); void
; 
;- Logging: all text output from Interface is redirected To tty/file/clipboard. Tree nodes are automatically opened.
GetLibFunc(igLogToTTY, (max_depth.l)); void
GetLibFunc(igLogToFile, (max_depth.l, filename.s)); void
GetLibFunc(igLogToClipboard, (max_depth.l)); void
GetLibFunc(igLogFinish, ()); void
GetLibFunc(igLogButtons, ()); void
GetLibFunc(igLogText, (fmt.s, *v1=#Null, *v2=#Null)); void
; 
; GetLibFunc(igBeginDragDropSource(ImGuiDragDropFlags flags, int mouse_button); bool
; GetLibFunc(igSetDragDropPayload(CONST char *type, CONST void *Data, size_t size, ImGuiCond cond); bool
; GetLibFunc(igEndDragDropSource(); void
; GetLibFunc(igBeginDragDropTarget(); bool
; GetLibFunc(struct ImGuiPayload *igAcceptDragDropPayload(CONST char *type, ImGuiDragDropFlags flags); CONST
; GetLibFunc(igEndDragDropTarget(); void
; 
; // Clipping
; GetLibFunc(igPushClipRect(CONST struct ImVec2 clip_rect_min, CONST struct ImVec2 clip_rect_max, bool intersect_with_current_clip_rect); void
; GetLibFunc(igPopClipRect(); void
; 
; // Styles
; GetLibFunc(igStyleColorsClassic(struct ImGuiStyle *dst); void
; GetLibFunc(igStyleColorsDark(struct ImGuiStyle *dst); void
; GetLibFunc(igStyleColorsLight(struct ImGuiStyle *dst); void
; 
; GetLibFunc(igSetItemDefaultFocus(); void
; GetLibFunc(igSetKeyboardFocusHere(int offset); void
; 
; // Utilities
; GetLibFunc(igIsItemHovered(ImGuiHoveredFlags flags); bool
; GetLibFunc(igIsItemActive(); bool
; GetLibFunc(igIsItemClicked(int mouse_button); bool
; GetLibFunc(igIsItemVisible(); bool
; GetLibFunc(igIsAnyItemHovered(); bool
; GetLibFunc(igIsAnyItemActive(); bool
; GetLibFunc(igGetItemRectMin(struct ImVec2 *pOut); void
; GetLibFunc(igGetItemRectMax(struct ImVec2 *pOut); void
; GetLibFunc(igGetItemRectSize(struct ImVec2 *pOut); void
; GetLibFunc(igSetItemAllowOverlap(); void
; GetLibFunc(igIsWindowFocused(ImGuiFocusedFlags flags); bool
; GetLibFunc(igIsWindowHovered(ImGuiHoveredFlags falgs); bool
; GetLibFunc(igIsAnyWindowFocused(); bool
; GetLibFunc(igIsAnyWindowHovered(); bool
; GetLibFunc(igIsRectVisible(CONST struct ImVec2 item_size); bool
; GetLibFunc(igIsRectVisible2(CONST struct ImVec2 *rect_min, CONST struct ImVec2 *rect_max); bool
GetLibFunc(igGetTime,()); float
GetLibFunc(igGetFrameCount,()); int
; 
GetLibFunc(igGetOverlayDrawList, ()); struct * ImDrawList 
GetLibFunc(igGetDrawListSharedData, ()); struct * ImDrawListSharedData
; 
; GetLibFunc(char *igGetStyleColorName(ImGuiCol idx); CONST
; GetLibFunc(igCalcItemRectClosestPoint(struct ImVec2 *pOut, CONST struct ImVec2 pos, bool on_edge, float outward); void
; GetLibFunc(igCalcTextSize(struct ImVec2 *pOut, CONST char *text, CONST char *text_end, bool hide_text_after_double_hash, float wrap_width); void
; GetLibFunc(igCalcListClipping(int items_count, float items_height, int *out_items_display_start, int *out_items_display_end); void
; 
; GetLibFunc(igBeginChildFrame(ImGuiID id, CONST struct ImVec2 size, ImGuiWindowFlags extra_flags); bool
; GetLibFunc(igEndChildFrame(); void
; 
; GetLibFunc(igColorConvertU32ToFloat4(struct ImVec4 *pOut, ImU32 in); void
; GetLibFunc(igColorConvertFloat4ToU32(CONST struct ImVec4 in); ImU32
; GetLibFunc(igColorConvertRGBtoHSV(float r, float g, float b, float *out_h, float *out_s, float *out_v); void
; GetLibFunc(igColorConvertHSVtoRGB(float h, float s, float v, float *out_r, float *out_g, float *out_b); void
; 
;- Inputs
; GetLibFunc(igGetKeyIndex(ImGuiKey imgui_key); int
; GetLibFunc(igIsKeyDown(int user_key_index); bool
; GetLibFunc(igIsKeyPressed(int user_key_index, bool Repeat); bool
; GetLibFunc(igIsKeyReleased(int user_key_index); bool
; GetLibFunc(igGetKeyPressedAmount(int key_index, float repeat_delay, float rate); int
; GetLibFunc(igIsMouseDown(int button); bool
; GetLibFunc(igIsMouseClicked(int button, bool Repeat); bool
; GetLibFunc(igIsMouseDoubleClicked(int button); bool
; GetLibFunc(igIsMouseReleased(int button); bool
; GetLibFunc(igIsMouseDragging(int button, float lock_threshold); bool
; GetLibFunc(igIsMouseHoveringRect(CONST struct ImVec2 r_min, CONST struct ImVec2 r_max, bool clip); bool
; GetLibFunc(igIsMousePosValid(CONST struct ImVec2 *mouse_pos); bool
; ;
GetLibFunc(igGetMousePos, (*pOut_ImVec2)); void
; GetLibFunc(igGetMousePosOnOpeningCurrentPopup(struct ImVec2 *pOut); void
; GetLibFunc(igGetMouseDragDelta(struct ImVec2 *pOut, int button, float lock_threshold); void
; GetLibFunc(igResetMouseDragDelta(int button); void
; GetLibFunc(igGetMouseCursor(); ImGuiMouseCursor
; GetLibFunc(igSetMouseCursor(ImGuiMouseCursor type); void
; GetLibFunc(igCaptureKeyboardFromApp(bool capture); void
; GetLibFunc(igCaptureMouseFromApp(bool capture); void
; 
;- Helpers functions To access functions pointers in ImGui::GetIO()
; GetLibFunc(*igMemAlloc(size_t sz); void
; GetLibFunc(igMemFree(void *ptr); void
; GetLibFunc(char *igGetClipboardText(); CONST
GetLibFunc(igSetClipboardText, (text.s)); void
; 
; // Internal state access - If you want To share ImGui state between modules (e.g. DLL) Or allocate it yourself
GetLibFunc(igGetVersion,()); CONST char *
; GetLibFunc(ImGuiContext *igCreateContext(void *(*malloc_fn)(size_t), void (*free_fn)(void *)); struct
; GetLibFunc(igDestroyContext(struct ImGuiContext *ctx); void
; GetLibFunc(ImGuiContext *igGetCurrentContext(); struct
; GetLibFunc(igSetCurrentContext(struct ImGuiContext *ctx); void
; 
; GetLibFunc(ImFontConfig_DefaultConstructor(struct ImFontConfig *config); void
; 
; // ImGuiIO
; GetLibFunc(ImGuiIO_AddInputCharacter(unsigned short c); void
; GetLibFunc(ImGuiIO_AddInputCharactersUTF8(CONST char *utf8_chars); void
; GetLibFunc(ImGuiIO_ClearInputCharacters(); void
; 
; // ImGuiTextFilter
; GetLibFunc(ImGuiTextFilter *ImGuiTextFilter_Create(CONST char *default_filter); struct
; GetLibFunc(ImGuiTextFilter_Destroy(struct ImGuiTextFilter *filter); void
; GetLibFunc(ImGuiTextFilter_Clear(struct ImGuiTextFilter *filter); void
; GetLibFunc(ImGuiTextFilter_Draw(struct ImGuiTextFilter *filter, label.s, float width); bool
; GetLibFunc(ImGuiTextFilter_PassFilter(CONST struct ImGuiTextFilter *filter, CONST char *text, CONST char *text_end); bool
; GetLibFunc(ImGuiTextFilter_IsActive(CONST struct ImGuiTextFilter *filter); bool
; GetLibFunc(ImGuiTextFilter_Build(struct ImGuiTextFilter *filter); void
; GetLibFunc(char *ImGuiTextFilter_GetInputBuf(struct ImGuiTextFilter *filter); CONST
; 
; // ImGuiTextBuffer
; GetLibFunc(ImGuiTextBuffer *ImGuiTextBuffer_Create(); struct
; GetLibFunc(ImGuiTextBuffer_Destroy(struct ImGuiTextBuffer *buffer); void
; GetLibFunc(ImGuiTextBuffer_index(struct ImGuiTextBuffer *buffer, int i); char
; GetLibFunc(char *ImGuiTextBuffer_begin(CONST struct ImGuiTextBuffer *buffer); CONST
; GetLibFunc(char *ImGuiTextBuffer_end(CONST struct ImGuiTextBuffer *buffer); CONST
; GetLibFunc(ImGuiTextBuffer_size(CONST struct ImGuiTextBuffer *buffer); int
; GetLibFunc(ImGuiTextBuffer_empty(struct ImGuiTextBuffer *buffer); bool
; GetLibFunc(ImGuiTextBuffer_clear(struct ImGuiTextBuffer *buffer); void
; GetLibFunc(char *ImGuiTextBuffer_c_str(CONST struct ImGuiTextBuffer *buffer); CONST
; GetLibFunc(ImGuiTextBuffer_appendf(struct ImGuiTextBuffer *buffer, CONST char *fmt, ...); void
; GetLibFunc(ImGuiTextBuffer_appendfv(struct ImGuiTextBuffer *buffer, CONST char *fmt, va_list args); void
; 
; // ImGuiStorage
; GetLibFunc(ImGuiStorage *ImGuiStorage_Create(); struct
; GetLibFunc(ImGuiStorage_Destroy(struct ImGuiStorage *storage); void
; GetLibFunc(ImGuiStorage_GetInt(struct ImGuiStorage *storage, ImGuiID key, int default_val); int
; GetLibFunc(ImGuiStorage_SetInt(struct ImGuiStorage *storage, ImGuiID key, int val); void
; GetLibFunc(ImGuiStorage_GetBool(struct ImGuiStorage *storage, ImGuiID key, bool default_val); bool
; GetLibFunc(ImGuiStorage_SetBool(struct ImGuiStorage *storage, ImGuiID key, bool val); void
; GetLibFunc(ImGuiStorage_GetFloat(struct ImGuiStorage *storage, ImGuiID key, float default_val); float
; GetLibFunc(ImGuiStorage_SetFloat(struct ImGuiStorage *storage, ImGuiID key, float val); void
; GetLibFunc(*ImGuiStorage_GetVoidPtr(struct ImGuiStorage *storage, ImGuiID key); void
; GetLibFunc(ImGuiStorage_SetVoidPtr(struct ImGuiStorage *storage, ImGuiID key, void *val); void
; GetLibFunc(*ImGuiStorage_GetIntRef(struct ImGuiStorage *storage, ImGuiID key, int default_val); int
; GetLibFunc(*ImGuiStorage_GetBoolRef(struct ImGuiStorage *storage, ImGuiID key, bool default_val); bool
; GetLibFunc(*ImGuiStorage_GetFloatRef(struct ImGuiStorage *storage, ImGuiID key, float default_val); float
; GetLibFunc(**ImGuiStorage_GetVoidPtrRef(struct ImGuiStorage *storage, ImGuiID key, void *default_val); void
; GetLibFunc(ImGuiStorage_SetAllInt(struct ImGuiStorage *storage, int val); void
; 
; // ImGuiTextEditCallbackData
; GetLibFunc(ImGuiTextEditCallbackData_DeleteChars(struct ImGuiTextEditCallbackData *Data, int pos, int bytes_count); void
; GetLibFunc(ImGuiTextEditCallbackData_InsertChars(struct ImGuiTextEditCallbackData *Data, int pos, CONST char *text, CONST char *text_end); void
; GetLibFunc(ImGuiTextEditCallbackData_HasSelection(struct ImGuiTextEditCallbackData *Data); bool
; 
; // ImGuiListClipper
; GetLibFunc(ImGuiListClipper_Step(struct ImGuiListClipper *clipper); bool
; GetLibFunc(ImGuiListClipper_Begin(struct ImGuiListClipper *clipper, int count, float items_height); void
; GetLibFunc(ImGuiListClipper_End(struct ImGuiListClipper *clipper); void
; GetLibFunc(ImGuiListClipper_GetDisplayStart(struct ImGuiListClipper *clipper); int
; GetLibFunc(ImGuiListClipper_GetDisplayEnd(struct ImGuiListClipper *clipper); int
; 
; //ImDrawList
GetLibFunc(ImDrawList_GetVertexBufferSize, (*ImDrawList)); int
GetLibFunc(ImDrawList_GetVertexPtr, (*ImDrawList, n.l)); struct ImDrawVert *
; GetLibFunc(ImDrawList_GetIndexBufferSize(struct ImDrawList *List); int
; GetLibFunc(*ImDrawList_GetIndexPtr(struct ImDrawList *List, int n); ImDrawIdx
; GetLibFunc(ImDrawList_GetCmdSize(struct ImDrawList *List); int
; GetLibFunc(ImDrawCmd *ImDrawList_GetCmdPtr(struct ImDrawList *List, int n); struct
; 
; GetLibFunc(ImDrawList_Clear(struct ImDrawList *List); void
; GetLibFunc(ImDrawList_ClearFreeMemory(struct ImDrawList *List); void
; GetLibFunc(ImDrawList_PushClipRect(struct ImDrawList *List, struct ImVec2 clip_rect_min, struct ImVec2 clip_rect_max, bool intersect_with_current_clip_rect); void
; GetLibFunc(ImDrawList_PushClipRectFullScreen(struct ImDrawList *List); void
; GetLibFunc(ImDrawList_PopClipRect(struct ImDrawList *List); void
; GetLibFunc(ImDrawList_PushTextureID(struct ImDrawList *List, CONST ImTextureID texture_id); void
; GetLibFunc(ImDrawList_PopTextureID(struct ImDrawList *List); void
; GetLibFunc(ImDrawList_GetClipRectMin(struct ImVec2 *pOut, struct ImDrawList *List); void
; GetLibFunc(ImDrawList_GetClipRectMax(struct ImVec2 *pOut, struct ImDrawList *List); void
; 
; // Primitives
; GetLibFunc(ImDrawList_AddLine(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, ImU32 col, float thickness); void
; GetLibFunc(ImDrawList_AddRect(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, ImU32 col, float rounding, int rounding_corners_flags, float thickness); void
; GetLibFunc(ImDrawList_AddRectFilled(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, ImU32 col, float rounding, int rounding_corners_flags); void
; GetLibFunc(ImDrawList_AddRectFilledMultiColor(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, ImU32 col_upr_left, ImU32 col_upr_right, ImU32 col_bot_right, ImU32 col_bot_left); void
; GetLibFunc(ImDrawList_AddQuad(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 c, CONST struct ImVec2 d, ImU32 col, float thickness); void
; GetLibFunc(ImDrawList_AddQuadFilled(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 c, CONST struct ImVec2 d, ImU32 col); void
; GetLibFunc(ImDrawList_AddTriangle(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 c, ImU32 col, float thickness); void
; GetLibFunc(ImDrawList_AddTriangleFilled(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 c, ImU32 col); void
; GetLibFunc(ImDrawList_AddCircle(struct ImDrawList *List, CONST struct ImVec2 centre, float radius, ImU32 col, int num_segments, float thickness); void
; GetLibFunc(ImDrawList_AddCircleFilled(struct ImDrawList *List, CONST struct ImVec2 centre, float radius, ImU32 col, int num_segments); void
; GetLibFunc(ImDrawList_AddText(struct ImDrawList *List, CONST struct ImVec2 pos, ImU32 col, CONST char *text_begin, CONST char *text_end); void
; GetLibFunc(ImDrawList_AddTextExt(struct ImDrawList *List, CONST struct ImFont *font, float font_size, CONST struct ImVec2 pos, ImU32 col, CONST char *text_begin, CONST char *text_end, float wrap_width, CONST struct ImVec4 *cpu_fine_clip_rect); void
GetLibFunc(ImDrawList_AddImage, (*ImDrawList, user_texture_id.l, aX.f,aY.f, bX.f,bY.f,  uv_aX.f=0.0,uv_aY.f=0.0, uv_bX.f=1.0,uv_bY.f=1.0, col.l=-1)); void
; GetLibFunc(ImDrawList_AddImageQuad(struct ImDrawList *List, ImTextureID user_texture_id, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 c, CONST struct ImVec2 d, CONST struct ImVec2 uv_a, CONST struct ImVec2 uv_b, CONST struct ImVec2 uv_c, CONST struct ImVec2 uv_d, ImU32 col); void
; GetLibFunc(ImDrawList_AddImageRounded(struct ImDrawList *List, ImTextureID user_texture_id, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 uv_a, CONST struct ImVec2 uv_b, ImU32 col, float rounding, int rounding_corners); void
; GetLibFunc(ImDrawList_AddPolyline(struct ImDrawList *List, CONST struct ImVec2 *points, CONST int num_points, ImU32 col, bool closed, float thickness); void
; GetLibFunc(ImDrawList_AddConvexPolyFilled(struct ImDrawList *List, CONST struct ImVec2 *points, CONST int num_points, ImU32 col); void
; GetLibFunc(ImDrawList_AddBezierCurve(struct ImDrawList *List, CONST struct ImVec2 pos0, CONST struct ImVec2 cp0, CONST struct ImVec2 cp1, CONST struct ImVec2 pos1, ImU32 col, float thickness, int num_segments); void
; 
; // Stateful path API, add points then finish With PathFill() Or PathStroke()
; GetLibFunc(ImDrawList_PathClear(struct ImDrawList *List); void
; GetLibFunc(ImDrawList_PathLineTo(struct ImDrawList *List, CONST struct ImVec2 pos); void
; GetLibFunc(ImDrawList_PathLineToMergeDuplicate(struct ImDrawList *List, CONST struct ImVec2 pos); void
; GetLibFunc(ImDrawList_PathFillConvex(struct ImDrawList *List, ImU32 col); void
; GetLibFunc(ImDrawList_PathStroke(struct ImDrawList *List, ImU32 col, bool closed, float thickness); void
; GetLibFunc(ImDrawList_PathArcTo(struct ImDrawList *List, CONST struct ImVec2 centre, float radius, float a_min, float a_max, int num_segments); void
; GetLibFunc(ImDrawList_PathArcToFast(struct ImDrawList *List, CONST struct ImVec2 centre, float radius, int a_min_of_12, int a_max_of_12); // Use precomputed angles for a 12 steps circle void
; GetLibFunc(ImDrawList_PathBezierCurveTo(struct ImDrawList *List, CONST struct ImVec2 p1, CONST struct ImVec2 p2, CONST struct ImVec2 p3, int num_segments); void
; GetLibFunc(ImDrawList_PathRect(struct ImDrawList *List, CONST struct ImVec2 rect_min, CONST struct ImVec2 rect_max, float rounding, int rounding_corners_flags); void
; 
; // Channels
; GetLibFunc(ImDrawList_ChannelsSplit(struct ImDrawList *List, int channels_count); void
; GetLibFunc(ImDrawList_ChannelsMerge(struct ImDrawList *List); void
; GetLibFunc(ImDrawList_ChannelsSetCurrent(struct ImDrawList *List, int channel_index); void
; 
; // Advanced
; GetLibFunc(ImDrawList_AddCallback(struct ImDrawList *List, ImDrawCallback callback, void *callback_data); // Your rendering function must check for 'UserCallback' in ImDrawCmd and call the function instead of rendering triangles. void
; GetLibFunc(ImDrawList_AddDrawCmd(struct ImDrawList *List);                                                // This is useful if you need to forcefully create a new draw call (to allow for dependent rendering / blending). Otherwise primitives are merged into the same draw-call as much as possible void
; 
; // Internal helpers
; GetLibFunc(ImDrawList_PrimReserve(struct ImDrawList *List, int idx_count, int vtx_count); void
; GetLibFunc(ImDrawList_PrimRect(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, ImU32 col); void
; GetLibFunc(ImDrawList_PrimRectUV(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 uv_a, CONST struct ImVec2 uv_b, ImU32 col); void
; GetLibFunc(ImDrawList_PrimQuadUV(struct ImDrawList *List, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 c, CONST struct ImVec2 d, CONST struct ImVec2 uv_a, CONST struct ImVec2 uv_b, CONST struct ImVec2 uv_c, CONST struct ImVec2 uv_d, ImU32 col); void
; GetLibFunc(ImDrawList_PrimWriteVtx(struct ImDrawList *List, CONST struct ImVec2 pos, CONST struct ImVec2 uv, ImU32 col); void
; GetLibFunc(ImDrawList_PrimWriteIdx(struct ImDrawList *List, ImDrawIdx idx); void
; GetLibFunc(ImDrawList_PrimVtx(struct ImDrawList *List, CONST struct ImVec2 pos, CONST struct ImVec2 uv, ImU32 col); void
; GetLibFunc(ImDrawList_UpdateClipRect(struct ImDrawList *List); void
; GetLibFunc(ImDrawList_UpdateTextureID(struct ImDrawList *List); void
; 
; // ImDrawData
; GetLibFunc(ImDrawData_DeIndexAllBuffers(struct ImDrawData *drawData); void
; GetLibFunc(ImDrawData_ScaleClipRects(struct ImDrawData *drawData, CONST struct ImVec2 sc); void
; 
; // ImFontAtlas
; GetLibFunc(ImFontAtlas_GetTexDataAsRGBA32(struct ImFontAtlas *atlas, unsigned char **out_pixels, int *out_width, int *out_height, int *out_bytes_per_pixel); void
; GetLibFunc(ImFontAtlas_GetTexDataAsAlpha8(struct ImFontAtlas *atlas, unsigned char **out_pixels, int *out_width, int *out_height, int *out_bytes_per_pixel); void
; GetLibFunc(ImFontAtlas_SetTexID(struct ImFontAtlas *atlas, ImTextureID id); void
; GetLibFunc(ImFont *ImFontAtlas_AddFont(struct ImFontAtlas *atlas, CONST struct ImFontConfig *font_cfg); struct
; GetLibFunc(ImFont *ImFontAtlas_AddFontDefault(struct ImFontAtlas *atlas, CONST struct ImFontConfig *font_cfg); struct
; GetLibFunc(ImFont *ImFontAtlas_AddFontFromFileTTF(struct ImFontAtlas *atlas, CONST char *filename, float size_pixels, CONST struct ImFontConfig *font_cfg, CONST ImWchar *glyph_ranges); struct
; GetLibFunc(ImFont *ImFontAtlas_AddFontFromMemoryTTF(struct ImFontAtlas *atlas, void *font_data, int font_size, float size_pixels, CONST struct ImFontConfig *font_cfg, CONST ImWchar *glyph_ranges); struct
; GetLibFunc(ImFont *ImFontAtlas_AddFontFromMemoryCompressedTTF(struct ImFontAtlas *atlas, CONST void *compressed_font_data, int compressed_font_size, float size_pixels, CONST struct ImFontConfig *font_cfg, CONST ImWchar *glyph_ranges); struct
; GetLibFunc(ImFont *ImFontAtlas_AddFontFromMemoryCompressedBase85TTF(struct ImFontAtlas *atlas, CONST char *compressed_font_data_base85, float size_pixels, CONST struct ImFontConfig *font_cfg, CONST ImWchar *glyph_ranges); struct
; GetLibFunc(ImFontAtlas_ClearTexData(struct ImFontAtlas *atlas); void
; GetLibFunc(ImFontAtlas_Clear(struct ImFontAtlas *atlas); void
; GetLibFunc(ImWchar *ImFontAtlas_GetGlyphRangesDefault(struct ImFontAtlas *atlas); CONST
; GetLibFunc(ImWchar *ImFontAtlas_GetGlyphRangesKorean(struct ImFontAtlas *atlas); CONST
; GetLibFunc(ImWchar *ImFontAtlas_GetGlyphRangesJapanese(struct ImFontAtlas *atlas); CONST
; GetLibFunc(ImWchar *ImFontAtlas_GetGlyphRangesChinese(struct ImFontAtlas *atlas); CONST
; GetLibFunc(ImWchar *ImFontAtlas_GetGlyphRangesCyrillic(struct ImFontAtlas *atlas); CONST
; GetLibFunc(ImWchar *ImFontAtlas_GetGlyphRangesThai(struct ImFontAtlas *atlas); CONST
; 
; GetLibFunc(ImFontAtlas_GetTexID(struct ImFontAtlas *atlas); ImTextureID
; GetLibFunc(char *ImFontAtlas_GetTexPixelsAlpha8(struct ImFontAtlas *atlas); unsigned
; GetLibFunc(int *ImFontAtlas_GetTexPixelsRGBA32(struct ImFontAtlas *atlas); unsigned
; GetLibFunc(ImFontAtlas_GetTexWidth(struct ImFontAtlas *atlas); int
; GetLibFunc(ImFontAtlas_GetTexHeight(struct ImFontAtlas *atlas); int
; GetLibFunc(ImFontAtlas_GetTexDesiredWidth(struct ImFontAtlas *atlas); int
; GetLibFunc(ImFontAtlas_SetTexDesiredWidth(struct ImFontAtlas *atlas, int TexDesiredWidth_); void
; GetLibFunc(ImFontAtlas_GetTexGlyphPadding(struct ImFontAtlas *atlas); int
; GetLibFunc(ImFontAtlas_SetTexGlyphPadding(struct ImFontAtlas *atlas, int TexGlyphPadding_); void
; GetLibFunc(ImFontAtlas_GetTexUvWhitePixel(struct ImFontAtlas *atlas, struct ImVec2 *pOut); void
; 
; // ImFontAtlas::Fonts;
; GetLibFunc(ImFontAtlas_Fonts_size(struct ImFontAtlas *atlas); int
; GetLibFunc(ImFont *ImFontAtlas_Fonts_index(struct ImFontAtlas *atlas, int index); struct
; 
; // ImFont
; GetLibFunc(ImFont_GetFontSize(CONST struct ImFont *font); float
; GetLibFunc(ImFont_SetFontSize(struct ImFont *font, float FontSize_); void
; GetLibFunc(ImFont_GetScale(CONST struct ImFont *font); float
; GetLibFunc(ImFont_SetScale(struct ImFont *font, float Scale_); void
; GetLibFunc(ImFont_GetDisplayOffset(CONST struct ImFont *font, struct ImVec2 *pOut); void
; GetLibFunc(struct IMFONTGLYPH *ImFont_GetFallbackGlyph(CONST struct ImFont *font); CONST
; GetLibFunc(ImFont_SetFallbackGlyph(struct ImFont *font, CONST struct IMFONTGLYPH *FallbackGlyph_); void
; GetLibFunc(ImFont_GetFallbackAdvanceX(CONST struct ImFont *font); float
; GetLibFunc(ImFont_GetFallbackChar(CONST struct ImFont *font); ImWchar
; GetLibFunc(ImFont_GetConfigDataCount(CONST struct ImFont *font); short
; GetLibFunc(ImFontConfig *ImFont_GetConfigData(struct ImFont *font); struct
; GetLibFunc(ImFontAtlas *ImFont_GetContainerAtlas(struct ImFont *font); struct
; GetLibFunc(ImFont_GetAscent(CONST struct ImFont *font); float
; GetLibFunc(ImFont_GetDescent(CONST struct ImFont *font); float
; GetLibFunc(ImFont_GetMetricsTotalSurface(CONST struct ImFont *font); int
; GetLibFunc(ImFont_ClearOutputData(struct ImFont *font); void
; GetLibFunc(ImFont_BuildLookupTable(struct ImFont *font); void
; GetLibFunc(struct IMFONTGLYPH *ImFont_FindGlyph(CONST struct ImFont *font, ImWchar c); CONST
; GetLibFunc(ImFont_SetFallbackChar(struct ImFont *font, ImWchar c); void
; GetLibFunc(ImFont_GetCharAdvance(CONST struct ImFont *font, ImWchar c); float
; GetLibFunc(ImFont_IsLoaded(CONST struct ImFont *font); bool
; GetLibFunc(char *ImFont_GetDebugName(CONST struct ImFont *font); CONST
; GetLibFunc(ImFont_CalcTextSizeA(CONST struct ImFont *font, struct ImVec2 *pOut, float size, float max_width, float wrap_width, CONST char *text_begin, CONST char *text_end, CONST char **remaining); // utf8 void
; GetLibFunc(char *ImFont_CalcWordWrapPositionA(CONST struct ImFont *font, float scale, CONST char *text, CONST char *text_end, float wrap_width); CONST
; GetLibFunc(ImFont_RenderChar(CONST struct ImFont *font, struct ImDrawList *draw_list, float size, struct ImVec2 pos, ImU32 col, unsigned short c); void
; GetLibFunc(ImFont_RenderText(CONST struct ImFont *font, struct ImDrawList *draw_list, float size, struct ImVec2 pos, ImU32 col, CONST struct ImVec4 *clip_rect, CONST char *text_begin, CONST char *text_end, float wrap_width, bool cpu_fine_clip); void
; // ImFont::Glyph
; GetLibFunc(ImFont_Glyphs_size(CONST struct ImFont *font); int
; GetLibFunc(IMFONTGLYPH *ImFont_Glyphs_index(struct ImFont *font, int index); struct
; // ImFont::IndexXAdvance
; GetLibFunc(ImFont_IndexXAdvance_size(CONST struct ImFont *font); int
; GetLibFunc(ImFont_IndexXAdvance_index(CONST struct ImFont *font, int index); float
; // ImFont::IndexLookup
; GetLibFunc(ImFont_IndexLookup_size(CONST struct ImFont *font); int
; GetLibFunc(short ImFont_IndexLookup_index(CONST struct ImFont *font, int index); unsigned
;}


; TODO: Fix images not showing in ImGui, inside the DLL
; Load a image from file as a texture, return a handle  
GetLibFunc(_LoadImageFromFile,(filename.p-unicode))
GetLibFunc(_LoadImageFromMemory,(*data, sizel.l))
GetLibFunc(_ReleaseImage,(textureID.l))
GetLibFunc(_LoadFontFromFile, (filename.s, pixel_size.f))
GetLibFunc(_LoadFontFromMemory, (*data, data_size.l, pixel_size.f))


;---------------------
; initialize the window and call *init_callback_procedure(), then enter a loop, calling *callback_procedure for every frame loop
GetLibFunc(_Run_GUI,(classname.p-unicode,titlename.p-unicode,style.l,x.l,y.l,w.l,h.l,vsync,*callback_procedure, *init_callback_procedure = #Null, *shutdown_callback_Procedure = #Null))



; IDE Options = PureBasic 5.40 LTS (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 1166
; FirstLine = 1129
; Folding = +-
; Markers = 372,730
; EnableXP