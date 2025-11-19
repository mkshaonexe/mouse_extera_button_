#Requires AutoHotkey v2
#SingleInstance Force
SetWorkingDir A_ScriptDir

; Use screen coordinates for mouse position
CoordMode("Mouse", "Screen")

; ====== Customize your menu items ======
items := [
    {name: "YouTube", target: "https://youtube.com"},
    {name: "Gmail", target: "https://mail.google.com"},
    {name: "ChatGPT", target: "https://chat.openai.com"},
    {name: "Notepad", target: "notepad.exe"},
    {name: "Calculator", target: "calc.exe"},
    {name: "Files", target: "explorer.exe"}
]
; =======================================

; ====== Visual Settings ======
radius := 120                    ; Distance from center to buttons
btnW := 110                       ; Button width
btnH := 40                        ; Button height
centerSize := 50                  ; Center circle size
bgAlpha := 200                    ; Background overlay opacity (0-255)
btnFontSize := 10                 ; Button font size
centerFontSize := 12              ; Center button font size
; ==============================

; Global reference to menu GUI
global menuGuiRef := ""

CreateMenuGui() {
    static buttons := []
    global items, radius, btnW, btnH, bgAlpha, centerSize, btnFontSize, centerFontSize, menuGuiRef

    ; Close existing menu if open
    if menuGuiRef != "" && IsObject(menuGuiRef) {
        try menuGuiRef.Destroy()
    }

    ; Get mouse position for center (capture immediately)
    MouseGetPos(&centerX, &centerY)
    
    ; Ensure menu stays on screen - adjust center if too close to edges
    maxRadius := radius + btnW // 2
    if (centerX < maxRadius)
        centerX := maxRadius
    if (centerX > A_ScreenWidth - maxRadius)
        centerX := A_ScreenWidth - maxRadius
    if (centerY < maxRadius)
        centerY := maxRadius
    if (centerY > A_ScreenHeight - maxRadius)
        centerY := A_ScreenHeight - maxRadius

    ; Create fullscreen overlay
    menuGuiRef := Gui("+AlwaysOnTop -Caption +ToolWindow")
    menuGuiRef.BackColor := "000000"
    menuGuiRef.Show("x0 y0 w" A_ScreenWidth " h" A_ScreenHeight)
    WinSetTransparent(bgAlpha, menuGuiRef)

    ; Calculate positions
    count := items.Length
    angleStep := 360 / count
    buttons := []
    i := 0

    ; Create buttons in circular pattern
    for item in items {
        angle := (i * angleStep) - 90  ; Start at top (-90 degrees)
        rad := angle * (3.14159265 / 180)
        x := centerX + radius * Cos(rad) - (btnW // 2)
        y := centerY + radius * Sin(rad) - (btnH // 2)
        
        ; Create styled button with HUD appearance
        ctrl := menuGuiRef.Add("Button", "x" x " y" y " w" btnW " h" btnH, item.name)
        ctrl.Font := "s" btnFontSize " Bold"
        ctrl.BackColor := "2a3a5a"  ; Blue-tinted dark background
        ctrl.SetFont("cFFFFFF", "s" btnFontSize " Bold")
        ctrl.OnEvent("Click", Launch.Bind(item.target))
        
        buttons.Push(ctrl)
        i += 1
    }

    ; Create center close button (GTA-style)
    closeBtn := menuGuiRef.Add("Button", "x" (centerX - centerSize//2) " y" (centerY - centerSize//2) " w" centerSize " h" centerSize, "✕")
    closeBtn.Font := "s" centerFontSize " Bold"
    closeBtn.BackColor := "3a2a2a"  ; Dark red background
    closeBtn.SetFont("cFF6666", "s" centerFontSize " Bold")
    closeBtn.OnEvent("Click", CloseMenu)

    ; Create connecting lines (GTA weapon wheel style)
    CreateConnectingLines(menuGuiRef, centerX, centerY, radius, count, angleStep)

    ; Fade in animation
    FadeIn(menuGuiRef, bgAlpha)
}

CreateConnectingLines(gui, centerX, centerY, radius, count, angleStep) {
    ; Create visual lines from center to each button (GTA-style)
    ; Using thin rectangles positioned along the radius
    lineThickness := 1
    Loop count {
        angle := ((A_Index - 1) * angleStep) - 90
        rad := angle * (3.14159265 / 180)
        
        ; Create multiple small segments to form a line
        segments := 8
        Loop segments {
            segmentPos := (A_Index / segments) * radius
            segX := centerX + segmentPos * Cos(rad) - lineThickness // 2
            segY := centerY + segmentPos * Sin(rad) - lineThickness // 2
            
            ; Add subtle connecting line segment
            lineCtrl := gui.Add("Text", "x" segX " y" segY " w" lineThickness " h" lineThickness " BackgroundTrans", "")
            lineCtrl.BackColor := "333333"
        }
    }
}

FadeIn(gui, targetAlpha) {
    ; Simple fade-in effect
    Loop 10 {
        alpha := (targetAlpha * A_Index) // 10
        try WinSetTransparent(alpha, gui)
        Sleep 5
    }
}

Launch(target, *) {
    ; Close menu first
    CloseMenu()
    
    ; Small delay to ensure menu closes before launching
    Sleep(50)
    
    try {
        if InStr(target, "http://") || InStr(target, "https://") {
            ; Open URL in Brave browser
            bravePath := "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
            if FileExist(bravePath) {
                Run('"' bravePath '" "' target '"')
            } else {
                ; Fallback to default browser if Brave not found
                try {
                    wsh := ComObject("WScript.Shell")
                    wsh.Run(target)
                } catch {
                    Run('powershell.exe -Command "Start-Process ' target '"', , "Hide")
                }
            }
        } else {
            ; Launch application
            Run(target)
        }
    } catch as err {
        MsgBox("Failed to open: " target "`nError: " err.Message)
    }
}

CloseMenu(*) {
    global menuGuiRef
    if menuGuiRef != "" && IsObject(menuGuiRef) {
        ; Fade out animation
        Loop 5 {
            try {
                currentAlpha := WinGetTransparent(menuGuiRef)
                if currentAlpha != "" && currentAlpha > 0
                    WinSetTransparent(Max(0, currentAlpha - 40), menuGuiRef)
            }
            Sleep 10
        }
        try menuGuiRef.Destroy()
        menuGuiRef := ""
    }
}

; --- Middle mouse button trigger ---
MButton::CreateMenuGui()

; --- Close on Right click or ESC (only when menu is open) ---
RButton:: {
    global menuGuiRef
    ; Only close menu if it's open, otherwise allow normal right-click
    if menuGuiRef != "" && IsObject(menuGuiRef) {
        CloseMenu()
    } else {
        ; Pass through right-click to system
        Send("{RButton}")
    }
}

Esc::CloseMenu()
