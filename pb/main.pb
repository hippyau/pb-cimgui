; call in our helper
IncludeFile "pb-cimgui.pbi"


; workaround rollover of 32bit ElapsedMilliseconds() for 64bit machines
CompilerIf #PB_Compiler_Processor = #PB_Processor_x86

    Procedure.q ElapsedMilliseconds_64()
        Static ElapsedMilliseconds_64_oldValue.q = 0                ; value of last call
        Static ElapsedMilliseconds_64_overflow.q = 0                ; how many overflows occured
        Protected current_ms.q = ElapsedMilliseconds() & $FFFFFFFF  ; get new value as unsigned number
        If ElapsedMilliseconds_64_oldValue > current_ms             ; If old value is greater than new value
            ElapsedMilliseconds_64_overflow + 1                     ;     increment overflow by 1
        EndIf
        ElapsedMilliseconds_64_oldValue = current_ms
        ProcedureReturn current_ms + ElapsedMilliseconds_64_overflow * $FFFFFFFF ; return current value + overflows
    EndProcedure

    Macro ElapsedMilliseconds()
        ElapsedMilliseconds_64()
    EndMacro
      
CompilerEndIf




;  Testing
Structure ImClr
  R.f
  G.f
  B.f
  A.f
EndStructure


; helper for buttons
Macro Pressed(button)
  button = 1  
EndMacro


#FONT_SIZE = 18.0




;  This gets called once at startup, when DX11 is ready.
;  Great for loading initial images and fonts etc...
ProcedureCDLL LoadResources()
  
    _SetBackgroundColour(0.0,0.0,0.5,1.0)  ;  half blue
  
    ; load an image - file or memory - get a texture ID
    Global *texID
    *texID = _LoadImageFromMemory(?img1,?img2-?img1) 
 ;   *texID = _LoadImageFromFile("test.png")
    If *texID = 0
      Debug "TEXTURE NOT LOADED"
    Else
      Debug "Texture ID: " + Hex(*texID)
    EndIf
    
    Global imageW, imageH
    imageW = _ImageWidth(*texID)
    imageH = _ImageHeight(*texID)
    
    Protected fntdir$ = GetEnvironmentVariable("windir")
    If fntdir$ <> ""
      fntdir$ + "\Fonts\"
      ; crashes on some weird fonts i've tried, these seem to always work.
      _LoadFontFromFile(fntdir$ + "Arial.ttf", #FONT_SIZE)
      _LoadFontFromFile(fntdir$ + "Verdana.ttf", #FONT_SIZE) 
    EndIf 
    ; TODO: _LoadFontFromMemory() crashed on app exit for some season
    ;Global *font = _LoadFontFromMemory(?arialstart, ?arialend-?arialstart, 18.0) ; works but crashes on unload
    
  EndProcedure




; When this returns, the program is over, we release any PB resources and exit
ProcedureCDLL UnloadResources()
  
  ; cleanup whatever here...
  
  If Not _ReleaseImage(*texID)
    Debug "Unable to release texture"
  EndIf
  
EndProcedure






; This ends up being our main loop of our demo app, is a callback from the _run_gui function
ProcedureCDLL MainLoop()
  
  Static show_window2.l = 1
  Static show_demo_window.l = 0
  Static showdemowin
  
  ; stuff that must run once, but only after gfx backend is in operation
  Static init = 0 
  If Not init
    Debug "Callback: MainLoop() First Run"
    
    ; text input buffer
    #MaxStringSize = 1024 ; or whatever
    Static *TestString
    *TestString = AllocateMemory(#MaxStringSize) 
    
    ; test line data
    Static Dim TestArr.f(100)
    Protected cnt
    For cnt = 0 To 99
      TestArr(cnt) = cnt+1.0 
    Next cnt
    
    ; messing about testing colours
    Static Dim Clr.f(4)
    Static txtclr.ImClr
    
    ; setup size of FPS bar
    Static progbar_fps_size.ImVec2
    progbar_fps_size\x = 200 ; width
    progbar_fps_size\y = Int(#FONT_SIZE)  ; height
    
    init = 1
  EndIf
  
  
  ; counting FPS 
  Protected fcount = igGetFrameCount()
  Static em.q = 0, fps = 0, ofcount = 0, timetick.q = 0 
  em = ElapsedMilliseconds()
  If em >= timetick + 1000
    timetick = em 
    fps = fcount - ofcount
    ofcount = fcount       
  EndIf
  
;{- Debug Window
  ; All this ends up in a window called debug, these are elements with not inside a igBegin() igEnd() block.  
  igText("API Coverage: " + Str(LibImGui_API_Coverage) + " of " +Str(CountLibraryFunctions(LibPBCImGui)))
  igBullet();
  igSameLine(25,25)
  igText("ElapsedMilliseconds(): " + Str(em))    
  ;igText("igGetTime(): " + StrF(igGetTime()))   ; freezes?
  igText("FrameCount() " + Str(igGetFrameCount()))   
  igText("FPS: ")
  igSameLine(50,0)
  igProgressBar(0.01 * fps, @progbar_fps_size, StrF(fps))
  igSeparator()
  
  igText("ImGuiIO:")
  Protected *v.ImGuiIO  ; TODO: ImGuiIO structure is not implemented properly yet
  *v = igGetIO()
  ;Protected v.ImGuiIO             ; for viewing in PB debugger
  If *v
    ; CopyMemory(*v, @v, SizeOf(v)) ; for viewing in PB debugger
    igBullet() : igText("Window Dimensions (Width: " + StrF(*v\DisplaySize\x) + " Height: " + StrF(*v\DisplaySize\y) + ")")  
    igBullet() : igText("Frame Rate: "+Str(*v\Framerate))
    igBullet() : igText("INI Filename: "+ PeekS(*v\inifile_str))
    igBullet() : igText("Log Filename: "+ PeekS(*v\logfile_str))
  EndIf    
;}  
  
  
;{- PureBasic ImGUI window
  igBegin("Purebasic ImGUI", @show_window2, 0) 
  igNewLine()
  igCheckbox("Show Demo Window?", @showdemowin)
  If showdemowin
    igText("We are showing the demo window!")  
    igShowDemoWindow(@show_demo_window)  
  Else
    igNewLine()
  EndIf
  
  igPlotLines("Test Lines", @TestArr(0), 100)
  igPlotHistogram("Test Histogram", @TestArr(0), 100, 0, "0 to 100", 0.0, 100.0, 0.0,50.0)
  
  Static rg  
  igRadioButton("one", @rg, 1)
  igSameLine(60,0)
  igRadioButton("two", @rg, 2)
  igSameLine(120,0)
  igRadioButton("three", @rg, 3)
  
  
  Protected p.b = igButton("Button 1",190,40)
  If p
    Debug "pressed button 1"
    PokeS(*TestString, PeekS(*TestString) + " Button 1", #MaxStringSize)
  EndIf
  igSameLine(0,10)
  Protected bb.b = igButton("Button 2",190,40)
  If bb
    Debug "pressed button 2"
    Debug PeekS(*TestString)
  EndIf
  igSameLine(0,10)
  Protected cc.b = igButton("Button 3",190,40)
  If cc
    Debug "pressed button 3"
  EndIf
  
  ; coloured text
  igTextColored(clr(0)/255,clr(1)/255,clr(2)/255,0.0+clr(3)/255,"Hello World")
  
  ; colour picker
  igColorPicker3("Colour",@clr(0), #ImGuiColorEditFlags_PickerHueWheel)
  
  ; Test Drag
  Static drag.f
  igDragFloat("Drag", @drag,0.33,0.0,255.0,"%3.2f",1)
  igText("Colour: ") : igSameLine(60,0) : igDragFloat4("R G B A",@clr(0),0.33,0,255,"%.0f")
  
  igNewLine()
  ; line editor
  igText("Name: ") : igSameLine(60,0) : igInputText("(string)",*TestString,#MaxStringSize)
;}  
  
  
;{- PureBasic ImGUI Image window  
  igBegin("Purebasic ImGUI - Image Window", @show_window2, 0)                       
  ; //     tex       w/h       uva      uvb       tint rgba                  boarder rgba
  igImage(*texID,  imageW,imageH,  0.0,0.0, 1.0,1.0,  255.0,255.0,255.0,255.0,  255.0,0.0,0.0,255.0) 
  
  igEnd()
;}  
  
  ; // use a drawlist to show the texture always on top, ref to screen top left
  ;   Protected *ptrr = igGetOverlayDrawList()
  ;   ImDrawList_AddImage(*ptrr,*texID, 100,100,512,512)   
  
  igNewLine()      
  igEnd()
  Sleep_(5)
EndProcedure




;- Example Main
Procedure Main()
  
  ExamineDesktops()
  
  ; This starts app, initialized the directx window;
  ; and we get calls to @MainLoop() callback every render loop, allowing us To make a gui, 
  ; @LoadResources() is For loading initial images/fonts, before entering the loop, but after directx is initialized
  ; @UnloadResources is called before directx deinitializing, but after deciding To quit the main loop
  ProcedureReturn _Run_GUI("TestCImgui", "Test PB-IMGUI", #WS_OVERLAPPEDWINDOW | #WS_MAXIMIZE, 0,0, DesktopWidth(0),DesktopHeight(0), 1, @MainLoop(), @LoadResources(), @UnloadResources() )  
  
EndProcedure



; start our demo app
Main()


DataSection
  
  img1:
  IncludeBinary "test.jpg"
  img2:
  
  
  arialstart:
  IncludeBinary "c:\Windows\Fonts\Arial.ttf"
  arialend:
  
EndDataSection



; IDE Options = PureBasic 5.40 LTS (Windows - x86)
; CursorPosition = 25
; Folding = +-
; EnableThread
; EnableXP
; Executable = pbtest.exe