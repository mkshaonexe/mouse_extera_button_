#Requires AutoHotkey v2
#SingleInstance Force
SetWorkingDir A_ScriptDir

; ------------------------------------------------------------
; Mouse Button Remaps
; ------------------------------------------------------------
MButton::CreateMenuGui()        ; Middle button opens radial launcher
XButton2::Send("#+s")           ; Forward button → Screenshot (Win+Shift+S)
XButton1::Send("#v")            ; Back button → Clipboard history (Win+V)

; ------------------------------------------------------------
; Radial Launcher (Middle mouse button)
; ------------------------------------------------------------
CoordMode("Mouse", "Screen")
OnMessage(0x201, GuiGlobalClick)  ; Watch for left-clicks while menu is open

items := [
    {name: "YouTube", target: "https://youtube.com"},
    {name: "Files", target: "explorer.exe"},
    {name: "AI", target: "C:\Users\MK Shaon\AppData\Local\Programs\Antigravity\Antigravity.exe"},
    {name: "Android Studio", target: "C:\Program Files\Android\Android Studio\bin\studio64.exe"},
    {name: "ChatGPT", target: "https://chat.openai.com"},
    {name: "Notepad", target: "notepad.exe"}
]

radius := 120
btnW := 110
btnH := 40
centerSize := 50
bgAlpha := 200
btnFontSize := 10
centerFontSize := 12

global menuGuiRef := ""

CreateMenuGui() {
    static buttons := []
    global items, radius, btnW, btnH, bgAlpha, centerSize, btnFontSize, centerFontSize, menuGuiRef

    if menuGuiRef != "" && IsObject(menuGuiRef) {
        try menuGuiRef.Destroy()
    }

    MouseGetPos(&centerX, &centerY)

    maxRadius := radius + btnW // 2
    if (centerX < maxRadius)
        centerX := maxRadius
    if (centerX > A_ScreenWidth - maxRadius)
        centerX := A_ScreenWidth - maxRadius
    if (centerY < maxRadius)
        centerY := maxRadius
    if (centerY > A_ScreenHeight - maxRadius)
        centerY := A_ScreenHeight - maxRadius

    menuGuiRef := Gui("+AlwaysOnTop -Caption +ToolWindow")
    menuGuiRef.BackColor := "000000"
    menuGuiRef.Show("x0 y0 w" A_ScreenWidth " h" A_ScreenHeight)
    WinSetTransparent(bgAlpha, menuGuiRef)

    count := items.Length
    angleStep := 360 / count
    buttons := []
    i := 0

    for item in items {
        angle := (i * angleStep) - 90
        rad := angle * (3.14159265 / 180)
        x := centerX + radius * Cos(rad) - (btnW // 2)
        y := centerY + radius * Sin(rad) - (btnH // 2)

        ctrl := menuGuiRef.Add("Button", "x" x " y" y " w" btnW " h" btnH, item.name)
        ctrl.Font := "s" btnFontSize " Bold"
        ctrl.BackColor := "2a3a5a"
        ctrl.SetFont("cFFFFFF", "s" btnFontSize " Bold")
        ctrl.OnEvent("Click", Launch.Bind(item.target))

        buttons.Push(ctrl)
        i += 1
    }

    closeBtn := menuGuiRef.Add("Button", "x" (centerX - centerSize//2) " y" (centerY - centerSize//2) " w" centerSize " h" centerSize, "✕")
    closeBtn.Font := "s" centerFontSize " Bold"
    closeBtn.BackColor := "3a2a2a"
    closeBtn.SetFont("cFF6666", "s" centerFontSize " Bold")
    closeBtn.OnEvent("Click", CloseMenu)

    CreateConnectingLines(menuGuiRef, centerX, centerY, radius, count, angleStep)
    FadeIn(menuGuiRef, bgAlpha)
}

CreateConnectingLines(gui, centerX, centerY, radius, count, angleStep) {
    lineThickness := 1
    Loop count {
        angle := ((A_Index - 1) * angleStep) - 90
        rad := angle * (3.14159265 / 180)

        segments := 8
        Loop segments {
            segmentPos := (A_Index / segments) * radius
            segX := centerX + segmentPos * Cos(rad) - lineThickness // 2
            segY := centerY + segmentPos * Sin(rad) - lineThickness // 2

            lineCtrl := gui.Add("Text", "x" segX " y" segY " w" lineThickness " h" lineThickness " BackgroundTrans", "")
            lineCtrl.BackColor := "333333"
        }
    }
}

FadeIn(gui, targetAlpha) {
    Loop 10 {
        alpha := (targetAlpha * A_Index) // 10
        try WinSetTransparent(alpha, gui)
        Sleep 5
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
                try {
                    wsh := ComObject("WScript.Shell")
                    wsh.Run(target)
                } catch {
                    Run('powershell.exe -Command "Start-Process ' target '"', , "Hide")
                }
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

GuiGlobalClick(*) {
    global menuGuiRef
    if menuGuiRef = "" || !IsObject(menuGuiRef)
        return

    MouseGetPos(&mx, &my, &winID, &ctrlID)
    if winID != menuGuiRef.Hwnd {
        CloseMenu()
    } else if ctrlID = ""
        CloseMenu()
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

