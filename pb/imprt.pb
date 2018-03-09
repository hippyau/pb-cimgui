

Procedure AssistHeaderConversion()
  fileno.l = OpenFile(1, "cimgui.h")
  line.s = ""
  type.s = ""
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


; IDE Options = PureBasic 5.40 LTS (Windows - x86)
; CursorPosition = 2
; Folding = -
; EnableUnicode
; EnableXP