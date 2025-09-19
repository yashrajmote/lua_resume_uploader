# 🍏 Hammerspoon Resume Uploader

Automatically upload the correct resume based on the company name extracted from your browser tab title. Perfect for job applications!

## 🚀 Quick Start

### 1. Install Hammerspoon
```bash
brew install --cask hammerspoon
```

### 2. Install the Script
```bash
# Copy the script to Hammerspoon config directory
cp init.lua ~/.hammerspoon/

# Create resume folder
mkdir -p ~/Documents/Resumes
```

### 3. Add Your Resumes
Place your resume files in `~/Documents/Resumes/` with company names:
- `Apple_Inc.pdf`
- `Google_LLC.pdf`
- `Microsoft_Corporation.pdf`

### 4. Test It Out
1. Open Hammerspoon from Applications
2. Press `Cmd+R` to reload the configuration
3. Go to any job site (Workday, Lever, etc.)
4. Click "Upload Resume" - it should auto-fill!

## 🎯 How It Works

1. **Detects File Picker**: Watches for Chrome file picker dialogs
2. **Extracts Company**: Reads the browser tab title to get company name
3. **Finds Resume**: Looks for matching resume file in your folder
4. **Auto-Uploads**: Types the path and presses Enter automatically

## 🔧 Hotkeys

- `Cmd+Shift+R`: Manual trigger (test the script)
- `Cmd+Shift+D`: Toggle debug mode
- `Cmd+Shift+T`: Show current tab title

## 📁 File Structure

```
lua_resume_uploader/
├── init.lua                    # Main Hammerspoon script
├── README.md                   # This file
└── HAMMERSPOON_LEARNING_GUIDE.md  # Complete learning guide
```

## 🛠️ Customization

Edit the configuration in `init.lua`:

```lua
-- Change resume folder location
local resumeFolder = "/Users/yash/Documents/Resumes/"

-- Adjust typing delay (seconds)
local typingDelay = 0.5

-- Toggle debug mode
local debugMode = true
```

### Resume Naming Convention
Your resume files should be named using the sanitized company name:
- "Apple Inc." → `Apple_Inc.pdf`
- "Google LLC" → `Google_LLC.pdf`
- "Microsoft Corporation" → `Microsoft_Corporation.pdf`
- "Bank of America" → `Bank_of_America.pdf`

## 🎓 Learning Hammerspoon

Check out `HAMMERSPOON_LEARNING_GUIDE.md` for a comprehensive guide to mastering Hammerspoon!

## 🔍 Troubleshooting

### Script Not Working?
1. Check if Hammerspoon is running
2. Press `Cmd+R` to reload the configuration
3. Check the console for error messages (`Cmd+Shift+C`)
4. Make sure Chrome is the active browser

### Resume Not Found?
1. Check the company name extraction with `Cmd+Shift+T`
2. Ensure your resume filename matches the sanitized company name
3. Check the resume folder path in the script

### File Picker Not Detected?
1. Make sure you're using Chrome
2. Try the manual trigger: `Cmd+Shift+R`
3. Check if the file picker title matches the patterns

## 📝 Supported Job Sites

The script works with most job sites including:
- Workday
- Lever
- Greenhouse
- Indeed
- LinkedIn Jobs
- Company career pages

## 🤝 Contributing

Feel free to submit issues or pull requests to improve the script!

## 📄 License

MIT License - feel free to use and modify as needed.
