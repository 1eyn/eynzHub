--[[
    ==================================================
    eynz Hub - Mobile Edition (Ultimate V2.2)
    - Settings Tab & Tab Animations
    - Resizable UI Scaler
    - Expandable (+) Button Smooth Animations
    - Color Presets & Custom RGB under (+) Menu
    - Poland Mode (White UI, Red/Thick Outlines)
    - Custom Notification System (Destroy/Poland Mode)
    - Draggable Floating Launcher & Main UI
    - Safe "Destroy Hub" Feature
    ==================================================
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local ActiveConnections = {} -- Used for safe deletion

-- UI Parent Safety Check
local ParentGui
pcall(function()
    if gethui then
        ParentGui = gethui()
    elseif game:GetService("CoreGui") then
        ParentGui = game:GetService("CoreGui")
    else
        ParentGui = LocalPlayer:WaitForChild("PlayerGui")
    end
end)

if ParentGui:FindFirstChild("eynzHubMobileGUI") then
    ParentGui:FindFirstChild("eynzHubMobileGUI"):Destroy()
end
if ParentGui:FindFirstChild("eynzNotifications") then
    ParentGui:FindFirstChild("eynzNotifications"):Destroy()
end

----------------------------------------------------
-- NOTIFICATION SYSTEM
----------------------------------------------------
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "eynzNotifications"
NotifGui.ResetOnSpawn = false
NotifGui.Parent = ParentGui

local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "Container"
NotifContainer.Size = UDim2.new(0, 220, 1, -20)
NotifContainer.Position = UDim2.new(1, -230, 0, 10)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = NotifGui

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = NotifContainer

local isPolandMode = false
local ThemeColor = Color3.fromRGB(138, 43, 226)

local function ShowNotification(message)
    local NoteFrame = Instance.new("Frame")
    NoteFrame.Size = UDim2.new(0, 200, 0, 40)
    NoteFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    NoteFrame.BackgroundTransparency = 1 -- Start invisible
    
    local NoteCorner = Instance.new("UICorner")
    NoteCorner.CornerRadius = UDim.new(0, 6)
    NoteCorner.Parent = NoteFrame
    
    local NoteStroke = Instance.new("UIStroke")
    NoteStroke.Color = isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor
    NoteStroke.Thickness = isPolandMode and 2 or 1
    NoteStroke.Transparency = 1
    NoteStroke.Parent = NoteFrame
    
    local NoteLabel = Instance.new("TextLabel")
    NoteLabel.Size = UDim2.new(1, 0, 1, 0)
    NoteLabel.BackgroundTransparency = 1
    NoteLabel.Text = message
    NoteLabel.TextColor3 = isPolandMode and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
    NoteLabel.Font = Enum.Font.SourceSansBold
    NoteLabel.TextSize = 14
    NoteLabel.TextTransparency = 1
    NoteLabel.Parent = NoteFrame
    
    if isPolandMode then
        NoteFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    NoteFrame.Parent = NotifContainer
    
    -- Fade In
    TweenService:Create(NoteFrame, TweenInfo.new(0.4), {BackgroundTransparency = isPolandMode and 0.1 or 0.4}):Play()
    TweenService:Create(NoteStroke, TweenInfo.new(0.4), {Transparency = 0}):Play()
    TweenService:Create(NoteLabel, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    
    -- Wait & Fade Out
    task.delay(3.5, function()
        local outTween = TweenService:Create(NoteLabel, TweenInfo.new(0.4), {TextTransparency = 1})
        TweenService:Create(NoteStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
        TweenService:Create(NoteFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        outTween:Play()
        outTween.Completed:Connect(function()
            NoteFrame:Destroy()
        end)
    end)
end

----------------------------------------------------
-- SAVE ORIGINAL LIGHTING SETTINGS
----------------------------------------------------
local origBrightness = Lighting.Brightness
local origClockTime = Lighting.ClockTime
local origFogEnd = Lighting.FogEnd
local origGlobalShadows = Lighting.GlobalShadows
local origAmbient = Lighting.Ambient
local origOutdoorAmbient = Lighting.OutdoorAmbient

local function resetLighting()
    Lighting.Brightness = origBrightness
    Lighting.ClockTime = origClockTime
    Lighting.FogEnd = origFogEnd
    Lighting.GlobalShadows = origGlobalShadows
    Lighting.Ambient = origAmbient
    Lighting.OutdoorAmbient = origOutdoorAmbient
end

----------------------------------------------------
-- THEME & OUTLINE MANAGER
----------------------------------------------------
local ThemeStrokes = {}
local ThemeTexts = {}
local ThemeBackgrounds = {}
local ThemeUpdaters = {}

local function applyThemeOutline(guiObject, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = ThemeColor
    stroke.Thickness = thickness or 1.5
    stroke:SetAttribute("OriginalThickness", stroke.Thickness)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = guiObject
    table.insert(ThemeStrokes, stroke)
    return stroke
end

----------------------------------------------------
-- UI CREATION
----------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "eynzHubMobileGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentGui

-- Open/Close Floating Button for Mobile
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "eynzToggleBtn"
ToggleBtn.Size = UDim2.new(0, 100, 0, 35)
ToggleBtn.Position = UDim2.new(0, 15, 0, 15)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToggleBtn.Text = "eynz Hub"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Parent = ScreenGui

local LauncherScale = Instance.new("UIScale", ToggleBtn)
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleBtn
applyThemeOutline(ToggleBtn, 1.5)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 310, 0, 410)
MainFrame.Position = UDim2.new(0.5, -155, 0.5, -205)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local MainScale = Instance.new("UIScale", MainFrame)
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame
applyThemeOutline(MainFrame, 2)

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- Tab Bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 30)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local FeaturesTabBtn = Instance.new("TextButton")
FeaturesTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
FeaturesTabBtn.BackgroundTransparency = 1
FeaturesTabBtn.Text = "Features"
FeaturesTabBtn.TextColor3 = ThemeColor
FeaturesTabBtn.Font = Enum.Font.SourceSansBold
FeaturesTabBtn.TextSize = 14
FeaturesTabBtn.Parent = TabBar
table.insert(ThemeTexts, FeaturesTabBtn)

local SettingsTabBtn = Instance.new("TextButton")
SettingsTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
SettingsTabBtn.Position = UDim2.new(0.5, 0, 0, 0)
SettingsTabBtn.BackgroundTransparency = 1
SettingsTabBtn.Text = "Settings"
SettingsTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
SettingsTabBtn.Font = Enum.Font.SourceSansBold
SettingsTabBtn.TextSize = 14
SettingsTabBtn.Parent = TabBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 12, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "eynz Hub | Mobile"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 16
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Parent = TitleBar

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Draggable Logic (Scalable)
local function makeDraggable(frame, dragHandle, scaleObj)
    local dragging, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            local inputEndedConn
            inputEndedConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    inputEndedConn:Disconnect()
                end
            end)
        end
    end)

    table.insert(ActiveConnections, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local scale = scaleObj and scaleObj.Scale or 1
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + (delta.X / scale), 
                startPos.Y.Scale, startPos.Y.Offset + (delta.Y / scale)
            )
        end
    end))
end

makeDraggable(MainFrame, TitleBar, MainScale)
makeDraggable(ToggleBtn, ToggleBtn, LauncherScale) -- Launcher is now draggable

-- SCROLL FRAMES (TABS)
local function createScrollFrame()
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -16, 1, -80)
    Scroll.Position = UDim2.new(0, 8, 0, 75)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 4
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.Parent = MainFrame

    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 8)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Parent = Scroll
    return Scroll
end

local FeaturesScroll = createScrollFrame()
local SettingsScroll = createScrollFrame()
SettingsScroll.Position = UDim2.new(1, 0, 0, 75)
SettingsScroll.Visible = false

local currentTab = FeaturesScroll

local function switchTab(tabName)
    local activeCol = isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor
    local inactiveCol = isPolandMode and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(150, 150, 150)
    
    if tabName == "Features" and currentTab ~= FeaturesScroll then
        TweenService:Create(currentTab, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, 0, 0, 75)}):Play()
        FeaturesScroll.Position = UDim2.new(-1, 0, 0, 75)
        FeaturesScroll.Visible = true
        TweenService:Create(FeaturesScroll, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 8, 0, 75)}):Play()
        currentTab = FeaturesScroll
        
        TweenService:Create(FeaturesTabBtn, TweenInfo.new(0.2), {TextColor3 = activeCol}):Play()
        TweenService:Create(SettingsTabBtn, TweenInfo.new(0.2), {TextColor3 = inactiveCol}):Play()
    elseif tabName == "Settings" and currentTab ~= SettingsScroll then
        TweenService:Create(currentTab, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(-1, 0, 0, 75)}):Play()
        SettingsScroll.Position = UDim2.new(1, 0, 0, 75)
        SettingsScroll.Visible = true
        TweenService:Create(SettingsScroll, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 8, 0, 75)}):Play()
        currentTab = SettingsScroll

        TweenService:Create(SettingsTabBtn, TweenInfo.new(0.2), {TextColor3 = activeCol}):Play()
        TweenService:Create(FeaturesTabBtn, TweenInfo.new(0.2), {TextColor3 = inactiveCol}):Play()
        
        table.insert(ThemeTexts, SettingsTabBtn)
        for i, v in ipairs(ThemeTexts) do if v == FeaturesTabBtn then table.remove(ThemeTexts, i) break end end
    end
end

FeaturesTabBtn.MouseButton1Click:Connect(function() switchTab("Features") end)
SettingsTabBtn.MouseButton1Click:Connect(function() switchTab("Settings") end)

----------------------------------------------------
-- HELPER CREATION FUNCTIONS
----------------------------------------------------
local function createSection(text, parent)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Size = UDim2.new(1, -10, 0, 25)
    SectionFrame.BackgroundTransparency = 1
    SectionFrame.Parent = parent or FeaturesScroll
    
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Size = UDim2.new(1, 0, 1, 0)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Text = "-- " .. text .. " --"
    SectionLabel.TextColor3 = isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor
    SectionLabel.TextSize = 15
    SectionLabel.Font = Enum.Font.SourceSansBold
    SectionLabel.Parent = SectionFrame
    table.insert(ThemeTexts, SectionLabel)
end

local function createToggle(text, parent, defaultState, callback)
    local state = defaultState or false

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    ToggleFrame.Parent = parent or FeaturesScroll

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 6)
    FrameCorner.Parent = ToggleFrame
    applyThemeOutline(ToggleFrame, 1)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSansSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 50, 0, 24)
    Button.Position = UDim2.new(1, -60, 0.5, -12)
    Button.BackgroundColor3 = state and (isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor) or Color3.fromRGB(60, 60, 70)
    Button.Text = state and "ON" or "OFF"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 12
    Button.Parent = ToggleFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Button
    applyThemeOutline(Button, 1)

    table.insert(ThemeUpdaters, function(newColor)
        if state then TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = newColor}):Play() end
    end)

    Button.MouseButton1Click:Connect(function()
        state = not state
        local targetColor = state and (isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor) or Color3.fromRGB(60, 60, 70)
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        Button.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

local function createExpandableToggle(text, parent, defaultState, mainCallback, subTogglesConfig)
    local state = defaultState or false
    local expanded = false
    local subToggleFrames = {}

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    ToggleFrame.Parent = parent or FeaturesScroll
    
    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 6)
    FrameCorner.Parent = ToggleFrame
    applyThemeOutline(ToggleFrame, 1)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSansSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local ExpandBtn = Instance.new("TextButton")
    ExpandBtn.Size = UDim2.new(0, 24, 0, 24)
    ExpandBtn.Position = UDim2.new(1, -90, 0.5, -12)
    ExpandBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    ExpandBtn.Text = "+"
    ExpandBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExpandBtn.Font = Enum.Font.SourceSansBold
    ExpandBtn.TextSize = 16
    ExpandBtn.Parent = ToggleFrame
    
    local ExpCorner = Instance.new("UICorner")
    ExpCorner.CornerRadius = UDim.new(0, 6)
    ExpCorner.Parent = ExpandBtn
    applyThemeOutline(ExpandBtn, 1)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 50, 0, 24)
    Button.Position = UDim2.new(1, -60, 0.5, -12)
    Button.BackgroundColor3 = state and (isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor) or Color3.fromRGB(60, 60, 70)
    Button.Text = state and "ON" or "OFF"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 12
    Button.Parent = ToggleFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Button
    applyThemeOutline(Button, 1)

    table.insert(ThemeUpdaters, function(newColor)
        if state then TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = newColor}):Play() end
    end)

    for _, subCfg in ipairs(subTogglesConfig) do
        local subState = false
        local SubFrame = Instance.new("Frame")
        SubFrame.Size = UDim2.new(1, -30, 0, 0)
        SubFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        SubFrame.ClipsDescendants = true
        SubFrame.Visible = false
        SubFrame.Parent = parent or FeaturesScroll

        local SubCorner = Instance.new("UICorner")
        SubCorner.CornerRadius = UDim.new(0, 6)
        SubCorner.Parent = SubFrame
        applyThemeOutline(SubFrame, 1)

        local SubLabel = Instance.new("TextLabel")
        SubLabel.Size = UDim2.new(0.6, 0, 0, 35)
        SubLabel.Position = UDim2.new(0, 10, 0, 0)
        SubLabel.BackgroundTransparency = 1
        SubLabel.Text = subCfg.text
        SubLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        SubLabel.TextSize = 13
        SubLabel.Font = Enum.Font.SourceSansSemibold
        SubLabel.TextXAlignment = Enum.TextXAlignment.Left
        SubLabel.Parent = SubFrame

        local SubBtn = Instance.new("TextButton")
        SubBtn.Size = UDim2.new(0, 45, 0, 20)
        SubBtn.Position = UDim2.new(1, -55, 0, 7)
        SubBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        SubBtn.Text = "OFF"
        SubBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        SubBtn.Font = Enum.Font.SourceSansBold
        SubBtn.TextSize = 11
        SubBtn.Parent = SubFrame

        local SubBtnCorner = Instance.new("UICorner")
        SubBtnCorner.CornerRadius = UDim.new(0, 6)
        SubBtnCorner.Parent = SubBtn
        applyThemeOutline(SubBtn, 1)

        table.insert(ThemeUpdaters, function(newColor)
            if subState then TweenService:Create(SubBtn, TweenInfo.new(0.3), {BackgroundColor3 = newColor}):Play() end
        end)

        SubBtn.MouseButton1Click:Connect(function()
            subState = not subState
            local targetColor = subState and (isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor) or Color3.fromRGB(60, 60, 70)
            TweenService:Create(SubBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
            SubBtn.Text = subState and "ON" or "OFF"
            subCfg.callback(subState)
        end)
        table.insert(subToggleFrames, SubFrame)
    end

    Button.MouseButton1Click:Connect(function()
        state = not state
        local targetColor = state and (isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor) or Color3.fromRGB(60, 60, 70)
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        Button.Text = state and "ON" or "OFF"
        mainCallback(state)
    end)

    ExpandBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        local targetRotation = expanded and 45 or 0
        TweenService:Create(ExpandBtn, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Rotation = targetRotation}):Play()

        for _, frm in ipairs(subToggleFrames) do
            if expanded then
                frm.Visible = true
                TweenService:Create(frm, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -30, 0, 35)}):Play()
            else
                local tw = TweenService:Create(frm, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -30, 0, 0)})
                tw:Play()
                task.delay(0.25, function() if not expanded then frm.Visible = false end end)
            end
        end
    end)
end

local function createSlider(labelText, parent, min, max, defaultVal, callback)
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(1, -10, 0, 50)
    RowFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    RowFrame.Parent = parent or FeaturesScroll
    applyThemeOutline(RowFrame, 1)
    local FrameCorner = Instance.new("UICorner") FrameCorner.CornerRadius = UDim.new(0, 6) FrameCorner.Parent = RowFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSansSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = RowFrame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.5, 0, 0, 20)
    ValueLabel.Position = UDim2.new(0.5, -10, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(defaultVal)
    ValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ValueLabel.TextSize = 13
    ValueLabel.Font = Enum.Font.SourceSansBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = RowFrame

    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -20, 0, 8)
    SliderBg.Position = UDim2.new(0, 10, 0, 32)
    SliderBg.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    SliderBg.Parent = RowFrame
    local BgCorner = Instance.new("UICorner") BgCorner.CornerRadius = UDim.new(1, 0) BgCorner.Parent = SliderBg

    local SliderFill = Instance.new("Frame")
    local pct = math.clamp((defaultVal - min) / (max - min), 0, 1)
    SliderFill.Size = UDim2.new(pct, 0, 1, 0)
    SliderFill.BackgroundColor3 = isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor
    SliderFill.Parent = SliderBg
    local FillCorner = Instance.new("UICorner") FillCorner.CornerRadius = UDim.new(1, 0) FillCorner.Parent = SliderFill
    table.insert(ThemeBackgrounds, SliderFill)

    local DragBtn = Instance.new("TextButton")
    DragBtn.Size = UDim2.new(1, 0, 1, 10)
    DragBtn.Position = UDim2.new(0, 0, 0, -5)
    DragBtn.BackgroundTransparency = 1
    DragBtn.Text = ""
    DragBtn.Parent = SliderBg

    local isDragging = false
    DragBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    table.insert(ActiveConnections, UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local sliderX = SliderBg.AbsolutePosition.X
            local sliderW = SliderBg.AbsoluteSize.X
            local mouseX = input.Position.X
            
            local percent = math.clamp((mouseX - sliderX) / sliderW, 0, 1)
            local val = min + (max - min) * percent
            val = math.floor(val * 100) / 100
            
            TweenService:Create(SliderFill, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
            ValueLabel.Text = tostring(val)
            callback(val)
        end
    end))
end

local function createButton(text, parent, callback, colorTheme)
    local BtnFrame = Instance.new("Frame")
    BtnFrame.Size = UDim2.new(1, -10, 0, 35)
    BtnFrame.BackgroundTransparency = 1
    BtnFrame.Parent = parent or FeaturesScroll

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundColor3 = colorTheme or Color3.fromRGB(32, 32, 42)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 14
    Btn.Parent = BtnFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn
    applyThemeOutline(Btn, 1)

    Btn.MouseButton1Click:Connect(callback)
end

local function setPolandMode(state)
    isPolandMode = state
    
    if state then
        MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TitleBar.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
        TabBar.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
        TitleText.TextColor3 = Color3.fromRGB(20, 20, 20)
        FeaturesTabBtn.TextColor3 = currentTab == FeaturesScroll and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(100, 100, 100)
        SettingsTabBtn.TextColor3 = currentTab == SettingsScroll and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(100, 100, 100)
        
        for _, stroke in ipairs(ThemeStrokes) do
            stroke.Thickness = 3
            stroke.Color = Color3.fromRGB(255, 0, 0)
        end
        for _, txt in ipairs(ThemeTexts) do
            if txt and txt.Parent and txt.Name ~= "eynzToggleBtn" and txt.Name ~= "TitleText" then 
                txt.TextColor3 = Color3.fromRGB(255, 0, 0) 
            end
        end
        for _, bg in ipairs(ThemeBackgrounds) do
            if bg and bg.Parent then bg.BackgroundColor3 = Color3.fromRGB(255, 0, 0) end
        end
        for _, func in ipairs(ThemeUpdaters) do
            func(Color3.fromRGB(255, 0, 0))
        end
    else
        MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
        TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        TabBar.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
        FeaturesTabBtn.TextColor3 = currentTab == FeaturesScroll and ThemeColor or Color3.fromRGB(150, 150, 150)
        SettingsTabBtn.TextColor3 = currentTab == SettingsScroll and ThemeColor or Color3.fromRGB(150, 150, 150)
        
        for _, stroke in ipairs(ThemeStrokes) do
            stroke.Thickness = stroke:GetAttribute("OriginalThickness") or 1.5
            stroke.Color = ThemeColor
        end
        for _, txt in ipairs(ThemeTexts) do
            if txt and txt.Parent and txt.Name ~= "eynzToggleBtn" and txt.Name ~= "TitleText" then 
                txt.TextColor3 = ThemeColor 
            end
        end
        for _, bg in ipairs(ThemeBackgrounds) do
            if bg and bg.Parent then bg.BackgroundColor3 = ThemeColor end
        end
        for _, func in ipairs(ThemeUpdaters) do
            func(ThemeColor)
        end
    end
end

local function updateThemeColor(color)
    ThemeColor = color
    if isPolandMode then 
        setPolandMode(false) 
    end
    
    for _, stroke in ipairs(ThemeStrokes) do
        if stroke and stroke.Parent then TweenService:Create(stroke, TweenInfo.new(0.3), {Color = color}):Play() end
    end
    for _, txt in ipairs(ThemeTexts) do
        if txt and txt.Parent and txt.Name ~= "eynzToggleBtn" and txt.Name ~= "TitleText" then 
            TweenService:Create(txt, TweenInfo.new(0.3), {TextColor3 = color}):Play() 
        end
    end
    for _, bg in ipairs(ThemeBackgrounds) do
        if bg and bg.Parent then TweenService:Create(bg, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play() end
    end
    for _, func in ipairs(ThemeUpdaters) do
        func(color)
    end
end

local function createColorPresetsRow(parent)
    local expanded = false
    
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(1, -10, 0, 40)
    RowFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    RowFrame.Parent = parent
    applyThemeOutline(RowFrame, 1)
    local FrameCorner = Instance.new("UICorner") FrameCorner.CornerRadius = UDim.new(0, 6) FrameCorner.Parent = RowFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "Color Presets & Themes"
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSansSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = RowFrame

    local ExpandBtn = Instance.new("TextButton")
    ExpandBtn.Size = UDim2.new(0, 24, 0, 24)
    ExpandBtn.Position = UDim2.new(1, -34, 0.5, -12)
    ExpandBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    ExpandBtn.Text = "+"
    ExpandBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExpandBtn.Font = Enum.Font.SourceSansBold
    ExpandBtn.TextSize = 16
    ExpandBtn.Parent = RowFrame
    local ExpCorner = Instance.new("UICorner") ExpCorner.CornerRadius = UDim.new(0, 6) ExpCorner.Parent = ExpandBtn
    applyThemeOutline(ExpandBtn, 1)

    local SubContainer = Instance.new("Frame")
    SubContainer.Size = UDim2.new(1, -30, 0, 0)
    SubContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    SubContainer.ClipsDescendants = true
    SubContainer.Visible = false
    SubContainer.Parent = parent
    local SubCorner = Instance.new("UICorner") SubCorner.CornerRadius = UDim.new(0, 6) SubCorner.Parent = SubContainer
    applyThemeOutline(SubContainer, 1)
    
    local SubList = Instance.new("UIListLayout")
    SubList.Padding = UDim.new(0, 6)
    SubList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SubList.SortOrder = Enum.SortOrder.LayoutOrder
    SubList.Parent = SubContainer
    
    local SubPad = Instance.new("UIPadding")
    SubPad.PaddingTop = UDim.new(0, 6)
    SubPad.PaddingBottom = UDim.new(0, 6)
    SubPad.Parent = SubContainer

    local colors = {
        {name = "Yellow", rgb = Color3.fromRGB(255, 255, 0)},
        {name = "Blue", rgb = Color3.fromRGB(0, 100, 255)},
        {name = "Red", rgb = Color3.fromRGB(255, 50, 50)},
        {name = "Green", rgb = Color3.fromRGB(50, 255, 50)},
        {name = "White", rgb = Color3.fromRGB(255, 255, 255)}
    }
    
    for _, clr in ipairs(colors) do
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -12, 0, 26)
        Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        Btn.Text = clr.name
        Btn.TextColor3 = clr.rgb
        Btn.Font = Enum.Font.SourceSansBold
        Btn.TextSize = 13
        Btn.Parent = SubContainer
        local BtnCorner = Instance.new("UICorner") BtnCorner.CornerRadius = UDim.new(0, 6) BtnCorner.Parent = Btn
        applyThemeOutline(Btn, 1)
        
        Btn.MouseButton1Click:Connect(function() updateThemeColor(clr.rgb) end)
    end
    
    local PolandBtn = Instance.new("TextButton")
    PolandBtn.Size = UDim2.new(1, -12, 0, 26)
    PolandBtn.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    PolandBtn.Text = "Poland Mode"
    PolandBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
    PolandBtn.Font = Enum.Font.SourceSansBold
    PolandBtn.TextSize = 13
    PolandBtn.Parent = SubContainer
    local PolCorner = Instance.new("UICorner") PolCorner.CornerRadius = UDim.new(0, 6) PolCorner.Parent = PolandBtn
    
    local polStroke = Instance.new("UIStroke")
    polStroke.Color = Color3.fromRGB(255, 0, 0)
    polStroke.Thickness = 1.5
    polStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    polStroke.Parent = PolandBtn
    
    PolandBtn.MouseButton1Click:Connect(function()
        setPolandMode(true)
        ShowNotification(" Polska Gurom! ")
    end)
    
    local CustomRGBRow = Instance.new("Frame")
    CustomRGBRow.Size = UDim2.new(1, -12, 0, 30)
    CustomRGBRow.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    CustomRGBRow.Parent = SubContainer
    local CRGBCorner = Instance.new("UICorner") CRGBCorner.CornerRadius = UDim.new(0, 6) CRGBCorner.Parent = CustomRGBRow
    applyThemeOutline(CustomRGBRow, 1)
    
    local CLabel = Instance.new("TextLabel")
    CLabel.Size = UDim2.new(0.4, 0, 1, 0)
    CLabel.Position = UDim2.new(0, 10, 0, 0)
    CLabel.BackgroundTransparency = 1
    CLabel.Text = "Custom RGB"
    CLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    CLabel.TextSize = 13
    CLabel.Font = Enum.Font.SourceSansSemibold
    CLabel.TextXAlignment = Enum.TextXAlignment.Left
    CLabel.Parent = CustomRGBRow
    
    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(0, 90, 0, 22)
    InputBox.Position = UDim2.new(1, -100, 0.5, -11)
    InputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    InputBox.Text = "138, 43, 226"
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.Font = Enum.Font.SourceSansBold
    InputBox.TextSize = 12
    InputBox.Parent = CustomRGBRow
    local BoxCorner = Instance.new("UICorner") BoxCorner.CornerRadius = UDim.new(0, 6) BoxCorner.Parent = InputBox
    applyThemeOutline(InputBox, 1)
    
    InputBox.FocusLost:Connect(function()
        local r, g, b = InputBox.Text:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
        if r and g and b then
            updateThemeColor(Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b)))
        end
    end)
    
    ExpandBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        local targetRotation = expanded and 45 or 0
        TweenService:Create(ExpandBtn, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Rotation = targetRotation}):Play()

        if expanded then
            SubContainer.Visible = true
            local contentHeight = SubList.AbsoluteContentSize.Y + 12
            TweenService:Create(SubContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -30, 0, contentHeight)}):Play()
        else
            local tw = TweenService:Create(SubContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -30, 0, 0)})
            tw:Play()
            task.delay(0.3, function() if not expanded then SubContainer.Visible = false end end)
        end
    end)
end

local function createInputRow(labelText, parent, defaultVal, callback)
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(1, -10, 0, 40)
    RowFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    RowFrame.Parent = parent or FeaturesScroll

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 6)
    FrameCorner.Parent = RowFrame
    applyThemeOutline(RowFrame, 1)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSansSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = RowFrame

    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(0, 100, 0, 26)
    InputBox.Position = UDim2.new(1, -110, 0.5, -13)
    InputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    InputBox.Text = tostring(defaultVal)
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.Font = Enum.Font.SourceSansBold
    InputBox.TextSize = 13
    InputBox.Parent = RowFrame

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 6)
    BoxCorner.Parent = InputBox
    applyThemeOutline(InputBox, 1)

    InputBox.FocusLost:Connect(function()
        callback(InputBox.Text)
    end)
end

----------------------------------------------------
-- FEATURES TAB: SCRIPTS IMPLEMENTATION
----------------------------------------------------
createSection("Movement / Player", FeaturesScroll)

local flyEnabled = false
local flySpeed = 50
local flyBv, flyBg

local function disableFly()
    if flyBv then flyBv:Destroy() flyBv = nil end
    if flyBg then flyBg:Destroy() flyBg = nil end
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

createToggle("Directional Flight", FeaturesScroll, false, function(state)
    flyEnabled = state
    if not flyEnabled then disableFly() end
end)

createInputRow("Fly Speed", FeaturesScroll, flySpeed, function(val)
    local num = tonumber(val)
    if num then flySpeed = num end
end)

table.insert(ActiveConnections, RunService.RenderStepped:Connect(function()
    if flyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local char = LocalPlayer.Character
        local root = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")
        local cam = workspace.CurrentCamera

        if hum then hum.PlatformStand = true end

        if not flyBv or flyBv.Parent ~= root then
            flyBv = Instance.new("BodyVelocity")
            flyBv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            flyBv.Velocity = Vector3.new(0, 0, 0)
            flyBv.Parent = root
        end

        if not flyBg or flyBg.Parent ~= root then
            flyBg = Instance.new("BodyGyro")
            flyBg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            flyBg.P = 9e4
            flyBg.CFrame = root.CFrame
            flyBg.Parent = root
        end

        flyBg.CFrame = cam.CFrame

        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local flatLook = (cam.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
            local flatRight = (cam.CFrame.RightVector * Vector3.new(1, 0, 1)).Unit
            
            local forward = moveDir:Dot(flatLook)
            local right = moveDir:Dot(flatRight)

            local flightVector = (cam.CFrame.LookVector * forward) + (cam.CFrame.RightVector * right)
            if flightVector.Magnitude > 0 then
                flyBv.Velocity = flightVector.Unit * flySpeed
            end
        else
            flyBv.Velocity = Vector3.new(0, 0, 0)
        end
    end
end))

local speedEnabled = false
local walkSpeedValue = 32

createToggle("Enable Custom Speed", FeaturesScroll, false, function(state)
    speedEnabled = state
    if not speedEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end)

createInputRow("WalkSpeed Value", FeaturesScroll, walkSpeedValue, function(val)
    local num = tonumber(val)
    if num then walkSpeedValue = num end
end)

table.insert(ActiveConnections, RunService.Heartbeat:Connect(function()
    if speedEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = walkSpeedValue end
    end
end))

local noclipEnabled = false
local noclipCache = {}

createToggle("Noclip", FeaturesScroll, false, function(state)
    noclipEnabled = state
    if not noclipEnabled then
        for part, _ in pairs(noclipCache) do
            if part and part.Parent then part.CanCollide = true end
        end
        noclipCache = {}
    end
end)

table.insert(ActiveConnections, RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                noclipCache[part] = true
                part.CanCollide = false
            end
        end
    end
end))

----------------------------------------------------
-- VISUALS / ESP
----------------------------------------------------
createSection("Visuals / ESP", FeaturesScroll)

local fullbrightEnabled = false
createToggle("Looping Fullbright", FeaturesScroll, false, function(state)
    fullbrightEnabled = state
    if not fullbrightEnabled then resetLighting() end
end)

table.insert(ActiveConnections, RunService.RenderStepped:Connect(function()
    if fullbrightEnabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    end
end))

local function createNameTag(nameText, color)
    local bg = Instance.new("BillboardGui")
    bg.Name = "eynzNameTag"
    bg.Size = UDim2.new(0, 100, 0, 20)
    bg.StudsOffset = Vector3.new(0, 2.5, 0)
    bg.AlwaysOnTop = true
    bg.MaxDistance = 500

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = nameText
    txt.TextColor3 = color
    txt.TextStrokeTransparency = 0
    txt.Font = Enum.Font.SourceSansBold
    txt.TextSize = 14
    txt.Parent = bg
    return bg
end

-- ESP SYSTEM
local playerEspEnabled, playerNamesEnabled = false, false
local npcEspEnabled, npcNamesEnabled = false, false
local itemEspEnabled, itemNamesEnabled = false, false
local playerESPData, activeNPCs, activeItems = {}, {}, {}
local npcDescendantConn, itemDescendantConn, npcCleanLoop, itemCleanLoop

local function applyPlayerESP(player)
    if player == LocalPlayer then return end
    if not playerESPData[player] then playerESPData[player] = {} end
    local data = playerESPData[player]
    local char = player.Character

    if playerEspEnabled and char then
        if not data.Highlight then
            local hl = Instance.new("Highlight")
            hl.FillColor = isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor
            hl.FillTransparency = 0.5
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.Adornee = char
            hl.Parent = char
            data.Highlight = hl
            table.insert(ThemeUpdaters, function(newColor)
                if hl.Parent then hl.FillColor = newColor end
            end)
        end
        if playerNamesEnabled and not data.NameTag then
            local adornee = char:FindFirstChild("Head") or char.PrimaryPart
            if adornee then
                local bg = createNameTag(player.Name, isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor)
                bg.Adornee = adornee
                bg.Parent = char
                data.NameTag = bg
                table.insert(ThemeUpdaters, function(newColor)
                    if bg.Parent then bg:FindFirstChildOfClass("TextLabel").TextColor3 = newColor end
                end)
            end
        end
    end
    if not playerEspEnabled or not char then
        if data.Highlight then data.Highlight:Destroy(); data.Highlight = nil end
        if data.NameTag then data.NameTag:Destroy(); data.NameTag = nil end
    else
        if not playerNamesEnabled and data.NameTag then data.NameTag:Destroy(); data.NameTag = nil end
    end
end

local function refreshAllPlayersESP()
    for _, p in pairs(Players:GetPlayers()) do applyPlayerESP(p) end
end

createExpandableToggle("Player ESP", FeaturesScroll, false, function(state)
    playerEspEnabled = state
    refreshAllPlayersESP()
end, {{ text = "Show Names", callback = function(state) playerNamesEnabled = state refreshAllPlayersESP() end }})

table.insert(ActiveConnections, Players.PlayerAdded:Connect(function(p)
    table.insert(ActiveConnections, p.CharacterAdded:Connect(function() task.wait(0.2) applyPlayerESP(p) end))
end))
for _, p in pairs(Players:GetPlayers()) do
    table.insert(ActiveConnections, p.CharacterAdded:Connect(function() task.wait(0.2) applyPlayerESP(p) end))
end

-- NPC ESP
local function isNPC(obj)
    return obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj)
end
local function applyNPCVisuals(npc)
    if not activeNPCs[npc] then activeNPCs[npc] = {} end
    local data = activeNPCs[npc]
    if npcEspEnabled then
        if not data.Highlight then
            local hl = Instance.new("Highlight", npc)
            hl.FillColor = Color3.fromRGB(255, 60, 60); hl.FillTransparency = 0.5; hl.OutlineColor = Color3.new(1,1,1); hl.Adornee = npc
            data.Highlight = hl
        end
        if npcNamesEnabled and not data.NameTag then
            local adornee = npc:FindFirstChild("Head") or npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart")
            if adornee then
                local bg = createNameTag(npc.Name, Color3.fromRGB(255, 60, 60)); bg.Adornee = adornee; bg.Parent = npc
                data.NameTag = bg
            end
        end
    end
    if not npcEspEnabled then
        if data.Highlight then data.Highlight:Destroy(); data.Highlight = nil end
        if data.NameTag then data.NameTag:Destroy(); data.NameTag = nil end
    else
        if not npcNamesEnabled and data.NameTag then data.NameTag:Destroy(); data.NameTag = nil end
    end
end
local function refreshAllNPCsESP() for npc, _ in pairs(activeNPCs) do applyNPCVisuals(npc) end end

createExpandableToggle("NPC ESP", FeaturesScroll, false, function(state)
    npcEspEnabled = state
    if npcEspEnabled then
        for _, obj in pairs(workspace:GetDescendants()) do
            if isNPC(obj) then activeNPCs[obj] = {}; applyNPCVisuals(obj) end
        end
        npcDescendantConn = workspace.DescendantAdded:Connect(function(obj)
            task.wait(0.1)
            if isNPC(obj) then activeNPCs[obj] = {}; applyNPCVisuals(obj)
            elseif obj:IsA("Humanoid") and obj.Parent and isNPC(obj.Parent) then
                activeNPCs[obj.Parent] = {}; applyNPCVisuals(obj.Parent)
            end
        end)
        table.insert(ActiveConnections, npcDescendantConn)
        npcCleanLoop = task.spawn(function()
            while task.wait(2) do
                for npc, data in pairs(activeNPCs) do
                    local hum = npc:FindFirstChildOfClass("Humanoid")
                    if not npc.Parent or not hum or hum.Health <= 0 then
                        if data.Highlight then data.Highlight:Destroy() end
                        if data.NameTag then data.NameTag:Destroy() end
                        activeNPCs[npc] = nil
                    end
                end
            end
        end)
    else
        if npcDescendantConn then npcDescendantConn:Disconnect(); npcDescendantConn = nil end
        if npcCleanLoop then task.cancel(npcCleanLoop); npcCleanLoop = nil end
        refreshAllNPCsESP(); activeNPCs = {}
    end
end, {{ text = "Show Names", callback = function(state) npcNamesEnabled = state refreshAllNPCsESP() end }})

-- ITEM ESP
local function isItem(obj) return obj:IsA("Tool") and obj.Parent and not Players:GetPlayerFromCharacter(obj.Parent) end
local function applyItemVisuals(item)
    if not activeItems[item] then activeItems[item] = {} end
    local data = activeItems[item]
    if itemEspEnabled then
        if not data.Highlight then
            local hl = Instance.new("Highlight", item)
            hl.FillColor = Color3.fromRGB(255, 215, 0); hl.FillTransparency = 0.5; hl.OutlineColor = Color3.new(1,1,1); hl.Adornee = item
            data.Highlight = hl
        end
        if itemNamesEnabled and not data.NameTag then
            local adornee = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            if adornee then
                local bg = createNameTag(item.Name, Color3.fromRGB(255, 215, 0)); bg.Adornee = adornee; bg.Parent = item
                data.NameTag = bg
            end
        end
    end
    if not itemEspEnabled then
        if data.Highlight then data.Highlight:Destroy(); data.Highlight = nil end
        if data.NameTag then data.NameTag:Destroy(); data.NameTag = nil end
    else
        if not itemNamesEnabled and data.NameTag then data.NameTag:Destroy(); data.NameTag = nil end
    end
end
local function refreshAllItemsESP() for item, _ in pairs(activeItems) do applyItemVisuals(item) end end

createExpandableToggle("Item ESP", FeaturesScroll, false, function(state)
    itemEspEnabled = state
    if itemEspEnabled then
        for _, obj in pairs(workspace:GetDescendants()) do
            if isItem(obj) then activeItems[obj] = {}; applyItemVisuals(obj) end
        end
        itemDescendantConn = workspace.DescendantAdded:Connect(function(obj)
            task.wait(0.1)
            if isItem(obj) then activeItems[obj] = {}; applyItemVisuals(obj) end
        end)
        table.insert(ActiveConnections, itemDescendantConn)
        itemCleanLoop = task.spawn(function()
            while task.wait(2) do
                for item, data in pairs(activeItems) do
                    if not item.Parent or not isItem(item) then
                        if data.Highlight then data.Highlight:Destroy() end
                        if data.NameTag then data.NameTag:Destroy() end
                        activeItems[item] = nil
                    end
                end
            end
        end)
    else
        if itemDescendantConn then itemDescendantConn:Disconnect(); itemDescendantConn = nil end
        if itemCleanLoop then task.cancel(itemCleanLoop); itemCleanLoop = nil end
        refreshAllItemsESP(); activeItems = {}
    end
end, {{ text = "Show Names", callback = function(state) itemNamesEnabled = state refreshAllItemsESP() end }})

----------------------------------------------------
-- SETTINGS TAB IMPLEMENTATION
----------------------------------------------------
createSection("General Setup", SettingsScroll)

createSlider("UI Scale", SettingsScroll, 0.5, 1.5, 1.0, function(val)
    TweenService:Create(MainScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = val}):Play()
    TweenService:Create(LauncherScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = val}):Play()
end)

-- The Color Presets + RGB Selector replaced the standard input row
createColorPresetsRow(SettingsScroll)

createSection("Danger Zone", SettingsScroll)

-- Global Destruction Logic
local function DestroyHub()
    flyEnabled = false; disableFly()
    speedEnabled = false
    if LocalPlayer.Character then 
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end 
    end
    noclipEnabled = false
    for part, _ in pairs(noclipCache) do 
        if part and part.Parent then part.CanCollide = true end 
    end
    
    fullbrightEnabled = false; resetLighting()
    
    playerEspEnabled = false; refreshAllPlayersESP()
    npcEspEnabled = false; refreshAllNPCsESP()
    itemEspEnabled = false; refreshAllItemsESP()

    for _, connection in ipairs(ActiveConnections) do
        if connection and connection.Disconnect then
            connection:Disconnect()
        end
    end

    if npcCleanLoop then task.cancel(npcCleanLoop) end
    if itemCleanLoop then task.cancel(itemCleanLoop) end

    if ScreenGui then ScreenGui:Destroy() end
    
    -- Using the distinct Notification Gui to send our destroy message safely
    ShowNotification("eynz Hub successfully destroyed")
end

createButton("Destroy Everything & UI", SettingsScroll, function()
    DestroyHub()
end, Color3.fromRGB(180, 40, 40))
