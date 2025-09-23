-- Simple File System Browser for Hammerspoon
-- A clean GUI that allows you to browse and select files from your file system

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

-- Default starting directory
local currentPath = "/Users/yash/Desktop/"

-- Debug mode
local debugMode = true

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Helper function to log debug messages
local function debugLog(message)
    if debugMode then
        print("[File Browser] " .. message)
    end
end

-- Check if a path is a directory
local function isDirectory(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return false
    end
    return true
end

-- Get directory contents
local function getDirectoryContents(path)
    local contents = {}
    local handle = io.popen("ls -la '" .. path .. "' 2>/dev/null")
    
    if handle then
        for line in handle:lines() do
            local name = string.match(line, "%s+([^%s]+)$")
            if name and name ~= "." and name ~= ".." then
                local fullPath = path .. (string.match(path, "/$") and "" or "/") .. name
                local isDir = isDirectory(fullPath)
                table.insert(contents, {
                    name = name,
                    path = fullPath,
                    isDirectory = isDir,
                    display = (isDir and "📁 " or "📄 ") .. name
                })
            end
        end
        handle:close()
    end
    
    return contents
end

-- ============================================================================
-- FILE BROWSER GUI
-- ============================================================================

-- Main file browser chooser
local fileChooser = nil

-- Function to refresh the file browser
local function refreshFileBrowser()
    if not fileChooser then return end
    
    debugLog("Refreshing file browser for: " .. currentPath)
    
    local contents = getDirectoryContents(currentPath)
    local choices = {}
    
    -- Add parent directory option if not at root
    if currentPath ~= "/" then
        local parentPath = string.match(currentPath, "^(.*)/[^/]+/?$")
        if parentPath then
            table.insert(choices, {
                text = "📁 ..",
                subText = "Go to parent directory",
                path = parentPath,
                isDirectory = true
            })
        end
    end
    
    -- Add current directory contents
    for _, item in ipairs(contents) do
        table.insert(choices, {
            text = item.display,
            subText = item.path,
            path = item.path,
            isDirectory = item.isDirectory
        })
    end
    
    fileChooser:choices(choices)
end

-- Function to show file browser
local function showFileBrowser()
    fileChooser = hs.chooser.new(function(choice)
        if choice then
            if choice.isDirectory then
                -- Navigate to directory
                currentPath = choice.path
                if not string.match(currentPath, "/$") then
                    currentPath = currentPath .. "/"
                end
                debugLog("Navigating to: " .. currentPath)
                refreshFileBrowser()
            else
                -- File selected
                debugLog("File selected: " .. choice.path)
                hs.alert.show("Selected: " .. choice.text, 3)
                
                -- You can add file handling logic here
                -- For example, open the file:
                hs.execute("open '" .. choice.path .. "'")
            end
        end
    end)
    
    fileChooser:placeholderText("Browse files and folders...")
    fileChooser:queryChangedCallback(function(query)
        -- Optional: Add search/filter functionality here
    end)
    
    refreshFileBrowser()
    fileChooser:show()
end

-- Function to show current path
local function showCurrentPath()
    hs.alert.show("Current path: " .. currentPath, 4)
    debugLog("Current path: " .. currentPath)
end

-- Function to set custom path
local function setCustomPath()
    -- Use AppleScript for reliable text input
    local script = [[
        tell application "System Events"
            set thePath to text returned of (display dialog "Enter the full path to browse:" default answer "]] .. currentPath .. [[" with title "Set Directory Path" buttons {"Cancel", "Set Path"} default button "Set Path")
            return thePath
        end tell
    ]]
    
    local success, result = hs.osascript.applescript(script)
    
    if success and result and result ~= "" then
        -- Clean up the input
        local input = result:gsub("^%s+", ""):gsub("%s+$", "") -- Trim whitespace
        input = input:gsub("\n", ""):gsub("\r", "") -- Remove newlines
        
        debugLog("Raw input received: '" .. input .. "'")
        
        if input and input ~= "" then
            -- Ensure path ends with /
            if not string.match(input, "/$") then
                input = input .. "/"
            end
            
            currentPath = input
            hs.alert.show("Path updated: " .. currentPath, 3)
            debugLog("Path changed to: " .. currentPath)
            
            if fileChooser then
                refreshFileBrowser()
            end
        else
            hs.alert.show("No path entered", 2)
            debugLog("Empty path received")
        end
    else
        hs.alert.show("Path selection cancelled", 2)
        debugLog("Custom path cancelled or failed. Success: " .. tostring(success) .. ", Result: " .. tostring(result))
    end
end

-- Function to open Finder at current path
local function openFinder()
    hs.execute("open '" .. currentPath .. "'")
    hs.alert.show("Finder opened at: " .. currentPath, 3)
    debugLog("Finder opened at: " .. currentPath)
end

-- ============================================================================
-- MAIN MENU
-- ============================================================================

-- Function to show main menu
local function showMainMenu()
    local menuChooser = hs.chooser.new(function(choice)
        if choice then
            if choice.text == "Browse Files" then
                showFileBrowser()
            elseif choice.text == "Set Custom Path" then
                setCustomPath()
            elseif choice.text == "Show Current Path" then
                showCurrentPath()
            elseif choice.text == "Open Finder" then
                openFinder()
            elseif choice.text == "Toggle Debug" then
                debugMode = not debugMode
                hs.alert.show("Debug mode: " .. (debugMode and "ON" or "OFF"), 2)
            end
        end
    end)
    
    menuChooser:choices({
        {text = "Browse Files", subText = "Open file browser"},
        {text = "Set Custom Path", subText = "Change starting directory"},
        {text = "Show Current Path", subText = "Display current directory"},
        {text = "Open Finder", subText = "Open Finder at current path"},
        {text = "Toggle Debug", subText = "Toggle debug mode"}
    })
    
    menuChooser:placeholderText("File System Browser - Choose an option")
    menuChooser:show()
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

-- Show startup message
hs.alert.show("File System Browser Ready! 🗂️", 2)
debugLog("File System Browser initialized")

-- ============================================================================
-- HOTKEYS
-- ============================================================================

-- Hotkey to open main menu (Cmd+Shift+F)
hs.hotkey.bind({"cmd", "shift"}, "f", function()
    showMainMenu()
end)

-- Hotkey to directly open file browser (Cmd+Shift+B)
hs.hotkey.bind({"cmd", "shift"}, "b", function()
    showFileBrowser()
end)

-- Hotkey to toggle debug mode (Cmd+Shift+D)
hs.hotkey.bind({"cmd", "shift"}, "d", function()
    debugMode = not debugMode
    hs.alert.show("Debug mode: " .. (debugMode and "ON" or "OFF"), 1)
end)