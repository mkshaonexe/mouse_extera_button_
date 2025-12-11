#Requires AutoHotkey v2
#SingleInstance Force
SetWorkingDir A_ScriptDir

; ============================================================
; Mouse Assistance Ball - Advanced Mouse Button Customization
; ============================================================
; Author: MK Shaon
; Description: Radial launcher menu + Quick screenshot + Clipboard access
; GitHub: https://github.com/mkshaonexe/mouse_extera_button_
; ============================================================

; --- Auto-Start Logic (Install to Startup) ---
if A_IsCompiled {
    shortcutPath := A_Startup "\MouseAssistanceBall.lnk"
    if !FileExist(shortcutPath) {
        try {
            FileCreateShortcut(A_ScriptFullPath, shortcutPath)
            MsgBox("Installation Complete! `nMouse Assistance Ball will now start automatically with Windows.", "Auto-Start Enabled", "Iconi")
        } catch as err {
            MsgBox("Could not enable auto-start.`nError: " err.Message, "Installation Error", "Icon!")
        }
    }
}
; ---------------------------------------------

; ------------------------------------------------------------
; Mouse Button Remaps
; ------------------------------------------------------------
MButton::CreateMenuGui()        ; Middle button opens radial launcher
XButton2::Send("#+s")           ; Forward button → Screenshot (Win+Shift+S)
XButton1::Send("#v")            ; Back button → Clipboard history (Win+V)

; ------------------------------------------------------------
; Radial Launcher Configuration
; ------------------------------------------------------------
CoordMode("Mouse", "Screen")
OnMessage(0x200, OnHover)  ; Watch for mouse movements for hover effects

; ====== Customize your menu items ======
items := [
    {name: "YouTube", icon: "📺", target: "https://youtube.com"},
    {name: "Files", icon: "📂", target: "explorer.exe"},
    {name: "AI", icon: "🤖", target: "C:\Users\MK Shaon\AppData\Local\Programs\Antigravity\Antigravity.exe"},
    {name: "Android Studio", icon: "📱", target: "C:\Program Files\Android\Android Studio\bin\studio64.exe"},
    {name: "ChatGPT", icon: "💬", target: "https://chat.openai.com"},
    {name: "Notepad", icon: "📝", target: "notepad.exe"}
]
; =======================================

; ====== Visual Settings ======
radius := 130                    ; Distance from center to buttons
btnW := 150                       ; Button width
btnH := 45                        ; Button height
centerSize := 60                  ; Center circle size
bgAlpha := 220                    ; Background overlay opacity (0-255)
btnFontSize := 11                 ; Button font size
centerFontSize := 14              ; Center button font size
; Colors
colBackground := "000000"         ; Main GUI background
colBtnNormal := "1E1E2E"          ; Button normal color (Dark Slate)
colBtnHover := "89B4FA"           ; Button hover color (Bright Blue)
colTextNormal := "CDD6F4"         ; Text color
colTextHover := "11111B"          ; Text color on hover
colCenterNormal := "313244"       ; Center button color
colCenterHover := "F38BA8"        ; Center button hover (Red/Pink)
; ==============================

; Global reference to menu GUI and controls
global menuGuiRef := ""
global hoverControls := Map()  ; Stores control HWND -> Item Data

CreateMenuGui() {
    static buttons := []
    global items, radius, btnW, btnH, bgAlpha, centerSize, btnFontSize, centerFontSize, menuGuiRef, hoverControls
    
    ; Reset hover controls
    hoverControls := Map()

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
    menuGuiRef := Gui("+AlwaysOnTop -Caption +ToolWindow +LastFound")
    menuGuiRef.BackColor := colBackground
    menuGuiRef.Show("x0 y0 w" A_ScreenWidth " h" A_ScreenHeight " NoActivate")
    WinSetTransparent(bgAlpha, menuGuiRef)
    
    ; Add Center Label for visual feedback (initially empty)
    global centerLabel := menuGuiRef.Add("Text", "x0 y" (centerY + radius + 30) " w" A_ScreenWidth " h40 Center BackgroundTrans cWhite", "")
    centerLabel.SetFont("s16 Bold", "Segoe UI")

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
        
        ; Styled "Button" using Progress (background) and Text (label)
        ; We use a Text control as the clickable element with a background color
        
        ; Create a "Container" Look
        ctrl := menuGuiRef.Add("Text", "x" x " y" y " w" btnW " h" btnH " +0x200 +Center Background" colBtnNormal, item.icon "  " item.name)
        ctrl.SetFont("s" btnFontSize " c" colTextNormal, "Segoe UI Semibold")
        
        ; Bind events
        ctrl.OnEvent("Click", Launch.Bind(item.target))
        
        ; Register for hover tracking
        hoverControls[ctrl.Hwnd] := {
            ctrl: ctrl, 
            type: "btn", 
            name: item.name,
            normalBg: colBtnNormal,
            hoverBg: colBtnHover,
            normalFg: colTextNormal,
            hoverFg: colTextHover
        }
        
        i += 1
    }

    ; Create center close button
    closeBtn := menuGuiRef.Add("Text", "x" (centerX - centerSize//2) " y" (centerY - centerSize//2) " w" centerSize " h" centerSize " +0x200 +Center Background" colCenterNormal, "✕")
    closeBtn.SetFont("s" centerFontSize " cWhite", "Segoe UI")
    closeBtn.OnEvent("Click", CloseMenu)
    
    hoverControls[closeBtn.Hwnd] := {
        ctrl: closeBtn, 
        type: "close", 
        name: "Close",
        normalBg: colCenterNormal,
        hoverBg: colCenterHover,
        normalFg: "White",
        hoverFg: "White"
    }

    ; Create connecting lines (Visual only)
    CreateConnectingLines(menuGuiRef, centerX, centerY, radius, count, angleStep)

    ; Fade in animation
    FadeIn(menuGuiRef, bgAlpha)
}

CreateConnectingLines(gui, centerX, centerY, radius, count, angleStep) {
    lineThickness := 2
    Loop count {
        angle := ((A_Index - 1) * angleStep) - 90
        rad := angle * (3.14159265 / 180)
        
        ; Draw line from near center to near button
        startR := centerSize // 2 + 5
        endR := radius - (btnH // 2) - 5
        
        len := endR - startR
        segments := 10
        
        Loop segments {
            pos := startR + (A_Index / segments) * len
            lx := centerX + pos * Cos(rad) - lineThickness // 2
            ly := centerY + pos * Sin(rad) - lineThickness // 2
            
            gui.Add("Progress", "x" lx " y" ly " w" lineThickness " h" lineThickness " Background585B70 c585B70", 100)
        }
    }
}

OnHover(wParam, lParam, msg, hwnd) {
    static lastHwnd := 0
    global hoverControls, centerLabel
    
    if (hwnd != lastHwnd) {
        ; Restore previous control if it was ours
        if (lastHwnd && hoverControls.Has(lastHwnd)) {
            prev := hoverControls[lastHwnd]
            prev.ctrl.Opt("Background" prev.normalBg)
            prev.ctrl.SetFont("c" prev.normalFg)
            prev.ctrl.Redraw()
        }
        
        ; Highlight new control if it is ours
        if (hoverControls.Has(hwnd)) {
            curr := hoverControls[hwnd]
            curr.ctrl.Opt("Background" curr.hoverBg)
            curr.ctrl.SetFont("c" curr.hoverFg)
            curr.ctrl.Redraw()
            
            ; Update center label
            try centerLabel.Text := curr.name
        } else {
             try centerLabel.Text := ""
        }
        
        lastHwnd := hwnd
    }
}

FadeIn(gui, targetAlpha) {
    ; Start invisible
    WinSetTransparent(0, gui)
    ; Fast fade in
    Loop 5 {
        alpha := (targetAlpha * A_Index) // 5
        try WinSetTransparent(alpha, gui)
        Sleep 10
    }
}

Launch(target, *) {
    CloseMenu()
    Sleep(50)
    try {
        if InStr(target, "http://") || InStr(target, "https://") {
            bravePath := "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
            if FileExist(bravePath) {
                Run('"' bravePath '" "' target '"')
            } else {
                 Run(target)
            }
        } else {
            Run(target)
        }
    } catch as err {
        MsgBox("Failed to open: " target "`nError: " err.Message)
    }
}

CloseMenu(*) {
    global menuGuiRef
    if menuGuiRef != "" && IsObject(menuGuiRef) {
        Loop 5 {
            try {
                cur := WinGetTransparent(menuGuiRef)
                if (cur > 0)
                    WinSetTransparent(Max(0, cur - 50), menuGuiRef)
            }
            Sleep 10
        }
        try menuGuiRef.Destroy()
        menuGuiRef := ""
    }
}

RButton:: {
    global menuGuiRef
    if menuGuiRef != "" && IsObject(menuGuiRef) {
        CloseMenu()
    } else {
        Send("{RButton}")
    }
}

Esc::CloseMenu()
