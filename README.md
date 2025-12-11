# 🖱️ Mouse Assistance Ball

A powerful AutoHotkey v2 script that transforms your mouse extra buttons into a productivity powerhouse with a beautiful GTA-style radial launcher menu.

![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Features

### 🎯 Radial Launcher Menu
- **GTA-style weapon wheel** inspired design
- Beautiful fade-in/fade-out animations
- Circular button layout with connecting lines
- Customizable apps and websites
- Smart screen edge detection

### ⚡ Quick Actions
- **Screenshot Tool** - Instant access to Windows Snipping Tool
- **Clipboard History** - Quick clipboard manager access
- **One-Click Launches** - Open your favorite apps instantly

## 🎮 Mouse Button Mappings

| Button | Action | Description |
|--------|--------|-------------|
| **Middle Mouse Button** (Scroll Wheel Click) | Radial Menu | Opens the circular launcher menu |
| **Forward Button** (XButton2) | Screenshot | Triggers Windows Snipping Tool (Win+Shift+S) |
| **Back Button** (XButton1) | Clipboard | Opens Windows Clipboard History (Win+V) |
| **Right Click** | Close Menu | Closes the radial menu if open |
| **ESC** | Close Menu | Alternative way to close the menu |

## 📋 Default Menu Items

The radial menu includes 6 customizable slots:

1. **YouTube** - Opens YouTube in your browser
2. **Files** - Opens Windows File Explorer
3. **AI** - Launches Antigravity AI assistant
4. **Android Studio** - Opens Android Studio IDE
5. **ChatGPT** - Opens ChatGPT in your browser
6. **Notepad** - Launches Windows Notepad

## 🚀 Installation

### Quick Install (Recommended) 🌟

1. **Go to [Releases](https://github.com/mkshaonexe/mouse_extera_button_/releases)**
2. **Download both files:**
   - `AutoHotkey_2.0.19_setup.exe` (2.89 MB)
   - `MouseAssistanceBall.v.0.0.9.exe` (1.23 MB)
3. **Install in order:**
   - First: Run `AutoHotkey_2.0.19_setup.exe` to install AutoHotkey
   - Second: Run `MouseAssistanceBall.v.0.0.9.exe`
4. **Done!** The app will automatically start with Windows.

### Alternative: Script Method
If you want to modify the code:
1. Clone this repository
2. Install [AutoHotkey v2.0+](https://www.autohotkey.com/)
3. Run `mouse_assistance_ball.ahk`

## ⚙️ Customization

### Changing Menu Items

Edit the `items` array in the script (around line 26):

```autohotkey
items := [
    {name: "YouTube", target: "https://youtube.com"},
    {name: "Files", target: "explorer.exe"},
    {name: "AI", target: "C:\Users\YourName\Path\To\App.exe"},
    {name: "Your App", target: "path\to\your\app.exe"},
    {name: "ChatGPT", target: "https://chat.openai.com"},
    {name: "Notepad", target: "notepad.exe"}
]
```

**For Websites:**
```autohotkey
{name: "Google", target: "https://google.com"}
```

**For Applications:**
```autohotkey
{name: "VSCode", target: "C:\Program Files\Microsoft VS Code\Code.exe"}
```

### Visual Settings

Customize the appearance (around line 38):

```autohotkey
radius := 120                    ; Distance from center to buttons
btnW := 110                      ; Button width
btnH := 40                       ; Button height
centerSize := 50                 ; Center circle size
bgAlpha := 200                   ; Background overlay opacity (0-255)
btnFontSize := 10                ; Button font size
centerFontSize := 12             ; Center button font size
```

### Changing Mouse Buttons

Modify the button mappings (around line 15):

```autohotkey
MButton::CreateMenuGui()        ; Middle button
XButton2::Send("#+s")           ; Forward button
XButton1::Send("#v")            ; Back button
```

Available mouse buttons:
- `MButton` - Middle mouse button (scroll wheel click)
- `XButton1` - Back button (usually on the left side)
- `XButton2` - Forward button (usually on the left side)
- `LButton` - Left mouse button
- `RButton` - Right mouse button

## 🎨 How It Works

### Radial Menu System

1. **Activation**: Click the middle mouse button
2. **Menu Appears**: A semi-transparent overlay with circular buttons appears
3. **Button Layout**: Apps are arranged in a circle around a center close button
4. **Selection**: Click any button to launch the app/website
5. **Closing**: Click the center ✕ button, right-click, press ESC, or click outside

### Technical Details

- **Coordinate System**: Uses screen coordinates for accurate positioning
- **Edge Detection**: Automatically adjusts menu position to stay on screen
- **Animations**: Smooth fade-in and fade-out effects
- **Browser Support**: Prioritizes Brave browser, falls back to default browser
- **Single Instance**: Only one instance can run at a time

## 🛠️ Troubleshooting

### Script Not Working
- Ensure AutoHotkey v2.0+ is installed (not v1.1)
- Right-click the script → "Run as Administrator"
- Check if another AHK script is conflicting

### Buttons Not Responding
- Verify your mouse has extra buttons (XButton1/XButton2)
- Check Windows mouse settings
- Try running the script as administrator

### Apps Not Launching
- Verify the file paths in the `items` array
- Use absolute paths for applications
- Check if the application exists at the specified location

### Menu Appears in Wrong Position
- The script auto-adjusts for screen edges
- If issues persist, modify the `radius` value

## 📝 Changelog

### Version 1.0.0 (2025-12-11)
- Initial release
- Radial launcher menu with 6 customizable slots
- Screenshot quick action (Win+Shift+S)
- Clipboard history quick action (Win+V)
- GTA-style visual design
- Fade animations
- Smart screen edge detection

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new features
- Submit pull requests
- Improve documentation

## 📄 License

This project is licensed under the MIT License - feel free to use and modify as needed.

## 👤 Author

**MK Shaon**
- GitHub: [@mkshaonexe](https://github.com/mkshaonexe)

## 🙏 Acknowledgments

- Inspired by GTA V weapon wheel design
- Built with [AutoHotkey v2](https://www.autohotkey.com/)
- Community feedback and suggestions

## 📸 Screenshots

### Radial Menu in Action
The menu appears centered at your mouse cursor with a semi-transparent overlay, displaying all your favorite apps in a circular pattern.

### Features Showcase
- **Smooth Animations**: Fade-in and fade-out effects
- **Visual Feedback**: Connecting lines from center to buttons
- **Dark Theme**: Easy on the eyes with blue-tinted buttons
- **Responsive**: Automatically adjusts to screen edges

---

**⭐ If you find this useful, please star the repository!**

**🐛 Found a bug? [Open an issue](https://github.com/mkshaonexe/mouse_extera_button_/issues)**
