-- Hammerspoon Auto Resume Uploader
-- This script automatically fills file picker dialogs with the correct resume
-- based on the company name extracted from the browser tab title

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

-- Folder where resumes are stored (update this path to match your setup)
local resumeFolder = "/Users/yash/Documents/Resumes/"

-- Debug mode - set to true to see more detailed logging
local debugMode = true

-- Delay before typing into file picker (in seconds)
local typingDelay = 0.5

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Helper function to log debug messages
local function debugLog(message)
    if debugMode then
        print("[Hammerspoon Resume Uploader] " .. message)
    end
end

-- Helper to sanitize company name (remove spaces/special chars for filename)
local function sanitize(name)
    if not name or name == "" then
        return "default"
    end
    
    -- Replace spaces with underscores and strip non-alphanumerics except underscores
    local sanitized = name:gsub("%s+", "_"):gsub("[^%w_]", "")
    
    -- Ensure it's not empty after sanitization
    if sanitized == "" then
        return "default"
    end
    
    return sanitized
end

-- Helper to check if a file exists
local function fileExists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

-- ============================================================================
-- COMPANY NAME EXTRACTION PATTERNS
-- ============================================================================

-- Multiple patterns to extract company names from different job sites
local function extractCompanyName(tabTitle)
    debugLog("Extracting company name from: " .. tabTitle)
    
    -- Pattern 1: "Apply to [Company Name] – Workday"
    local company = string.match(tabTitle, "Apply to ([%w%s%-_&%.]+)")
    if company then
        debugLog("Found company (Pattern 1): " .. company)
        return company
    end
    
    -- Pattern 2: "Careers at [Company Name] – Lever"
    company = string.match(tabTitle, "Careers at ([%w%s%-_&%.]+)")
    if company then
        debugLog("Found company (Pattern 2): " .. company)
        return company
    end
    
    -- Pattern 3: "[Company Name] - Careers"
    company = string.match(tabTitle, "([%w%s%-_&%.]+) %- Careers")
    if company then
        debugLog("Found company (Pattern 3): " .. company)
        return company
    end
    
    -- Pattern 4: "Jobs at [Company Name]"
    company = string.match(tabTitle, "Jobs at ([%w%s%-_&%.]+)")
    if company then
        debugLog("Found company (Pattern 4): " .. company)
        return company
    end
    
    -- Pattern 5: "[Company Name] Jobs"
    company = string.match(tabTitle, "([%w%s%-_&%.]+) Jobs")
    if company then
        debugLog("Found company (Pattern 5): " .. company)
        return company
    end
    
    -- Fallback: use first word of title
    company = string.match(tabTitle, "^(%w+)")
    if company then
        debugLog("Found company (Fallback): " .. company)
        return company
    end
    
    debugLog("No company name found, using default")
    return "default"
end

-- ============================================================================
-- FILE PICKER HANDLER
-- ============================================================================

-- Handler when file picker window appears
local function handleFilePicker(win, appName)
    debugLog("New window detected: " .. appName .. " - " .. win:title())
    
    -- Check if this is Chrome and a file picker dialog
    if appName == "Google Chrome" then
        local title = win:title()
        local isFilePicker = string.match(title, "Open") or 
                            string.match(title, "Choose File") or
                            string.match(title, "Select File") or
                            string.match(title, "Upload")
        
        if isFilePicker then
            debugLog("File picker detected: " .. title)
            
            -- Get the frontmost Chrome window (the job page)
            local chromeApp = hs.application.get("Google Chrome")
            if not chromeApp then
                debugLog("Chrome app not found")
                return
            end
            
            local browserWin = chromeApp:focusedWindow()
            if not browserWin then
                debugLog("No focused Chrome window found")
                return
            end
            
            local tabTitle = browserWin:title()
            debugLog("Browser tab title: " .. tabTitle)
            
            -- Extract company name
            local companyName = extractCompanyName(tabTitle)
            local sanitizedCompany = sanitize(companyName)
            
            -- Build resume path
            local resumePath = resumeFolder .. sanitizedCompany .. ".pdf"
            debugLog("Looking for resume: " .. resumePath)
            
            -- Check if resume exists, if not try common variations
            if not fileExists(resumePath) then
                -- Try with different extensions
                local extensions = {".pdf", ".docx", ".doc"}
                local found = false
                
                for _, ext in ipairs(extensions) do
                    local testPath = resumeFolder .. sanitizedCompany .. ext
                    if fileExists(testPath) then
                        resumePath = testPath
                        found = true
                        break
                    end
                end
                
                if not found then
                    debugLog("Resume not found for: " .. sanitizedCompany)
                    hs.alert.show("Resume not found: " .. sanitizedCompany, 3)
                    return
                end
            end
            
            -- Show alert
            hs.alert.show("Uploading: " .. sanitizedCompany .. ".pdf", 2)
            debugLog("Will type: " .. resumePath)
            
            -- Type into file picker after delay
            hs.timer.doAfter(typingDelay, function()
                -- Focus the file picker window
                win:focus()
                
                -- Small delay to ensure focus
                hs.timer.doAfter(0.1, function()
                    -- Clear any existing text and type the path
                    hs.eventtap.keyStroke({"cmd"}, "a") -- Select all
                    hs.timer.doAfter(0.05, function()
                        hs.eventtap.keyStrokes(resumePath)
                        hs.timer.doAfter(0.1, function()
                            hs.eventtap.keyStroke({}, "return")
                            debugLog("Resume path typed and submitted")
                        end)
                    end)
                end)
            end)
        end
    end
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

-- Create window filter for Chrome
local wf = hs.window.filter.new("Google Chrome")

-- Subscribe to window creation events
wf:subscribe(hs.window.filter.windowCreated, handleFilePicker)

-- Show startup message
hs.alert.show("Resume Uploader Ready! 🚀", 2)
debugLog("Hammerspoon Resume Uploader initialized")

-- ============================================================================
-- MANUAL CONTROLS (for testing and debugging)
-- ============================================================================

-- Hotkey to manually trigger resume upload (Cmd+Shift+R)
hs.hotkey.bind({"cmd", "shift"}, "r", function()
    local chromeApp = hs.application.get("Google Chrome")
    if chromeApp then
        local win = chromeApp:focusedWindow()
        if win then
            handleFilePicker(win, "Google Chrome")
        else
            hs.alert.show("No Chrome window focused")
        end
    else
        hs.alert.show("Chrome not running")
    end
end)

-- Hotkey to toggle debug mode (Cmd+Shift+D)
hs.hotkey.bind({"cmd", "shift"}, "d", function()
    debugMode = not debugMode
    hs.alert.show("Debug mode: " .. (debugMode and "ON" or "OFF"), 1)
end)

-- Hotkey to show current Chrome tab title (Cmd+Shift+T)
hs.hotkey.bind({"cmd", "shift"}, "t", function()
    local chromeApp = hs.application.get("Google Chrome")
    if chromeApp then
        local win = chromeApp:focusedWindow()
        if win then
            local title = win:title()
            hs.alert.show("Tab: " .. title, 3)
            debugLog("Current tab title: " .. title)
        else
            hs.alert.show("No Chrome window focused")
        end
    else
        hs.alert.show("Chrome not running")
    end
end)

debugLog("Hotkeys registered:")
debugLog("  Cmd+Shift+R: Manual trigger")
debugLog("  Cmd+Shift+D: Toggle debug mode")
debugLog("  Cmd+Shift+T: Show current tab title")
