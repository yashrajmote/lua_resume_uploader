# 🍏 Hammerspoon Mastery Guide

## What is Hammerspoon?

Hammerspoon is a powerful automation tool for macOS that bridges the gap between the command line and the GUI. It's essentially a Lua scripting engine that can control almost every aspect of your Mac through APIs.

## 🚀 Getting Started

### 1. Installation
```bash
# Install via Homebrew (recommended)
brew install --cask hammerspoon

# Or download from: https://www.hammerspoon.org/
```

### 2. First Launch
1. Open Hammerspoon from Applications
2. Click "Open Config" - this opens `~/.hammerspoon/init.lua`
3. Replace the default content with our resume uploader script
4. Press `Cmd+R` to reload the config

## 📚 Core Concepts to Master

### 1. **Lua Basics** (Essential Foundation)
```lua
-- Variables
local name = "Hammerspoon"
local numbers = {1, 2, 3, 4, 5}

-- Functions
local function greet(name)
    return "Hello, " .. name .. "!"
end

-- Tables (Lua's main data structure)
local person = {
    name = "John",
    age = 30,
    skills = {"Lua", "Hammerspoon"}
}
```

### 2. **Hammerspoon APIs** (The Power Tools)

#### **Window Management**
```lua
-- Get all windows
local allWindows = hs.window.allWindows()

-- Get focused window
local focusedWindow = hs.window.focusedWindow()

-- Move window to specific position
focusedWindow:moveToUnit({0, 0, 0.5, 0.5}) -- top-left quarter

-- Resize window
focusedWindow:setSize({800, 600})
```

#### **Application Control**
```lua
-- Launch an application
hs.application.launchOrFocus("Safari")

-- Get running applications
local apps = hs.application.runningApplications()

-- Send keystrokes to focused app
hs.eventtap.keyStrokes("Hello World!")
hs.eventtap.keyStroke({"cmd"}, "c") -- Copy
```

#### **Window Filtering** (Advanced)
```lua
-- Create a filter for specific apps
local chromeFilter = hs.window.filter.new("Google Chrome")

-- Subscribe to events
chromeFilter:subscribe(hs.window.filter.windowCreated, function(win, appName)
    print("New Chrome window: " .. win:title())
end)
```

### 3. **Event Handling** (The Heart of Automation)

#### **Hotkeys**
```lua
-- Simple hotkey
hs.hotkey.bind({"cmd", "alt"}, "h", function()
    hs.alert.show("Hello!")
end)

-- Complex hotkey with modifiers
hs.hotkey.bind({"cmd", "shift", "ctrl"}, "r", function()
    -- Do something complex
end)
```

#### **Timers**
```lua
-- One-time timer
hs.timer.doAfter(2.0, function()
    print("This runs after 2 seconds")
end)

-- Repeating timer
local timer = hs.timer.doEvery(5.0, function()
    print("This runs every 5 seconds")
end)

-- Stop timer
timer:stop()
```

## 🛠️ Practical Projects to Build

### 1. **Window Management System**
```lua
-- Snap windows to screen edges
hs.hotkey.bind({"cmd", "alt"}, "left", function()
    local win = hs.window.focusedWindow()
    win:moveToUnit({0, 0, 0.5, 1}) -- Left half
end)

hs.hotkey.bind({"cmd", "alt"}, "right", function()
    local win = hs.window.focusedWindow()
    win:moveToUnit({0.5, 0, 0.5, 1}) -- Right half
end)
```

### 2. **Application Launcher**
```lua
-- Quick app switcher
local apps = {
    ["1"] = "Safari",
    ["2"] = "Chrome", 
    ["3"] = "Terminal",
    ["4"] = "VS Code"
}

for key, app in pairs(apps) do
    hs.hotkey.bind({"cmd", "alt"}, key, function()
        hs.application.launchOrFocus(app)
    end)
end
```

### 3. **Text Expansion**
```lua
-- Auto-expand shortcuts
local expansions = {
    ["@@"] = "your.email@example.com",
    ["@@@"] = "Your Name",
    ["@@@@" => "Your Company Name"
}

hs.hotkey.bind({}, "space", function()
    local win = hs.window.focusedWindow()
    local app = win:application()
    
    if app:bundleID() == "com.apple.TextEdit" then
        -- Check for expansion patterns
        -- Implementation details...
    end
end)
```

## 🎯 Advanced Techniques

### 1. **State Management**
```lua
-- Global state object
local state = {
    isRecording = false,
    currentApp = nil,
    lastAction = nil
}

-- State management functions
local function setState(key, value)
    state[key] = value
    print("State updated: " .. key .. " = " .. tostring(value))
end
```

### 2. **Error Handling**
```lua
local function safeExecute(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        hs.alert.show("Error: " .. tostring(result))
        print("Error: " .. tostring(result))
    end
    return success, result
end
```

### 3. **Configuration Management**
```lua
-- Configuration table
local config = {
    resumeFolder = "/Users/yash/Documents/Resumes/",
    debugMode = true,
    typingDelay = 0.5,
    hotkeys = {
        manualTrigger = {"cmd", "shift", "r"},
        toggleDebug = {"cmd", "shift", "d"}
    }
}

-- Load from external config file
local function loadConfig()
    local configPath = hs.configdir .. "/config.json"
    if hs.fs.attributes(configPath) then
        local file = io.open(configPath, "r")
        local content = file:read("*all")
        file:close()
        return hs.json.decode(content)
    end
    return config
end
```

## 🔧 Debugging and Development

### 1. **Console Access**
- Open Hammerspoon console: `Cmd+Shift+C`
- Use `print()` for debugging
- Use `hs.alert.show()` for user feedback

### 2. **Reloading**
- `Cmd+R` in Hammerspoon app
- Or use: `hs.reload()`

### 3. **Logging**
```lua
-- Create a logger
local logger = hs.logger.new("MyScript", "debug")

-- Use it
logger:d("Debug message")
logger:i("Info message")
logger:w("Warning message")
logger:e("Error message")
```

## 📖 Essential Resources

### 1. **Official Documentation**
- [Hammerspoon API Docs](https://www.hammerspoon.org/docs/)
- [Lua 5.4 Reference](https://www.lua.org/manual/5.4/)

### 2. **Community Resources**
- [Hammerspoon GitHub](https://github.com/Hammerspoon/hammerspoon)
- [Spoon Repository](https://github.com/Hammerspoon/Spoons)
- [Reddit Community](https://www.reddit.com/r/hammerspoon/)

### 3. **Learning Path**
1. **Week 1**: Master Lua basics and simple hotkeys
2. **Week 2**: Learn window management APIs
3. **Week 3**: Build application launchers and switchers
4. **Week 4**: Create complex automation workflows
5. **Week 5**: Build reusable modules and error handling
6. **Week 6**: Contribute to community or build advanced tools

## 🎯 Your Resume Uploader Script Explained

Let's break down the script we created:

### 1. **Configuration Section**
```lua
local resumeFolder = "/Users/yash/Documents/Resumes/"
local debugMode = true
```
- Centralized settings
- Easy to modify
- Clear separation of concerns

### 2. **Utility Functions**
```lua
local function sanitize(name)
    return (name:gsub("%s+", "_"):gsub("[^%w_]", ""))
end
```
- Reusable code
- Clean, focused functions
- Easy to test and modify

### 3. **Pattern Matching**
```lua
local function extractCompanyName(tabTitle)
    -- Multiple patterns for different job sites
    local company = string.match(tabTitle, "Apply to ([%w%s%-_&%.]+)")
    -- ... more patterns
end
```
- Handles various job site formats
- Extensible design
- Fallback mechanisms

### 4. **Event Handling**
```lua
wf:subscribe(hs.window.filter.windowCreated, handleFilePicker)
```
- Reactive programming
- Event-driven architecture
- Clean separation of concerns

## 🚀 Next Steps for Mastery

1. **Start Simple**: Begin with basic hotkeys and window management
2. **Build Incrementally**: Add one feature at a time
3. **Read Others' Code**: Study community scripts
4. **Experiment**: Try different APIs and approaches
5. **Document**: Comment your code and keep notes
6. **Share**: Contribute back to the community

## 🔥 Pro Tips

1. **Use `hs.console`** for interactive debugging
2. **Create modules** for reusable code
3. **Use `hs.json`** for configuration files
4. **Implement error handling** from the start
5. **Test with different applications** and edge cases
6. **Keep backups** of working configurations
7. **Use version control** for your scripts

Happy automating! 🎉
