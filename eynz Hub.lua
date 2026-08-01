--[[
    ==================================================
    eynz Hub - Mobile Edition (Ultimate V2.6)
    - Replaced Item ESP with Interactables ESP
    - Added Player Teleport with Avatar Icons
    - UI Opening/Closing Elastic Rotation Tweens
    - Fixed Mobile UI Dragging Camera Pan Bug
    - Fixed Poland Mode Sub-Elements & Input Colors
    - Fixed Color Presets Missing Translations
    - Version Bumps & Optimizations
    ==================================================
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local ActiveConnections = {}

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

if ParentGui:FindFirstChild("eynzHubMobileGUI") then ParentGui:FindFirstChild("eynzHubMobileGUI"):Destroy() end
if ParentGui:FindFirstChild("eynzNotifications") then ParentGui:FindFirstChild("eynzNotifications"):Destroy() end

----------------------------------------------------
-- MULTILINGUAL SYSTEM
----------------------------------------------------
local currentLang = "EN"
local translatables = {}
local statefulButtons = {}
local TranslationUpdaters = {}

local ChangelogTextEN = [[
• Added Player Teleport feature with avatars
• Replaced Item ESP with Interactables ESP
• Made UI opening animation cooler (elastic fly-in)
• Fixed UI camera dragging bug on Mobile
• Fixed Poland Mode colors for textboxes/buttons
• Added translations for color presets
]]

local ChangelogTextPL = [[
• Dodano Teleport do Graczy z awatarami
• Zastąpiono ESP Rzeczy przez ESP Interakcji
• Lepsza, bardziej elastyczna animacja otwierania UI
• Naprawiono błąd obracania kamery przy przesuwaniu UI
• Poprawiono kolory Trybu Polskiego dla przycisków
• Dodano tłumaczenia dla nazw kolorów
]]

local Translations = {
    ["Features"] = {EN = "Features", PL = "Funkcje"},
    ["Settings"] = {EN = "Settings", PL = "Ustawienia"},
    ["Movement / Player"] = {EN = "Movement / Player", PL = "Ruch / Gracz"},
    ["Flight"] = {EN = "Flight", PL = "Lot"},
    ["Fly Speed"] = {EN = "Fly Speed", PL = "Szybkość Lotu"},
    ["Enable Custom Speed"] = {EN = "Enable Custom Speed", PL = "Włącz Własną Prędkość"},
    ["WalkSpeed Value"] = {EN = "WalkSpeed Value", PL = "Prędkość Chodzenia"},
    ["Noclip"] = {EN = "Noclip", PL = "Przenikanie"},
    ["Teleport to Player"] = {EN = "Teleport to Player", PL = "Teleportuj do Gracza"},
    ["TP"] = {EN = "TP", PL = "TP"},
    ["No Players"] = {EN = "No Players", PL = "Brak Graczy"},
    ["Instant Prompt"] = {EN = "Instant Prompt", PL = "Szybka Interakcja"},
    ["Prompt Reach"] = {EN = "Prompt Reach", PL = "Zasięg Interakcji"},
    ["Max 100 studs"] = {EN = "Max 100 studs", PL = "Maksymalnie 100 studów"},
    ["Visuals / ESP"] = {EN = "Visuals / ESP", PL = "Wizualne / ESP"},
    ["Fullbright"] = {EN = "Fullbright", PL = "Full Jasność"},
    ["Player ESP"] = {EN = "Player ESP", PL = "ESP Graczy"},
    ["NPC ESP"] = {EN = "NPC ESP", PL = "NPC ESP"},
    ["Show Names"] = {EN = "Show Names", PL = "Pokaż Nazwy"},
    ["Interactables ESP"] = {EN = "Interactables ESP", PL = "ESP Interakcji"},
    ["Show Int. Names"] = {EN = "Show Int. Names", PL = "Pokaż Nazwy Interakcji"},
    ["General Setup"] = {EN = "General Setup", PL = "Główne Ustawienia"},
    ["UI Scale"] = {EN = "UI Scale", PL = "Skala UI"},
    ["Language: English"] = {EN = "Language: English", PL = "Język: Polski"},
    ["Color Presets & Themes"] = {EN = "Color Presets & Themes", PL = "Kolory i Motywy"},
    ["Purple (Default)"] = {EN = "Purple (Default)", PL = "Fioletowy (Domyślny)"},
    ["Orange"] = {EN = "Orange", PL = "Pomarańczowy"},
    ["Brown"] = {EN = "Brown", PL = "Brązowy"},
    ["Yellow"] = {EN = "Yellow", PL = "Żółty"},
    ["Blue"] = {EN = "Blue", PL = "Niebieski"},
    ["Red"] = {EN = "Red", PL = "Czerwony"},
    ["Green"] = {EN = "Green", PL = "Zielony"},
    ["White"] = {EN = "White", PL = "Biały"},
    ["Custom RGB"] = {EN = "Custom RGB", PL = "Własne RGB"},
    ["Poland Mode"] = {EN = "Poland Mode", PL = "Tryb Polski"},
    ["Danger Zone"] = {EN = "Danger Zone", PL = "Strefa Zagrożenia"},
    ["Destroy Everything & UI"] = {EN = "Destroy Everything & UI", PL = "Usuń Skrypt i UI"},
    ["About"] = {EN = "About", PL = "O Skrypcie"},
    ["Details"] = {EN = "Details", PL = "Szczegóły"},
    ["ON"] = {EN = "ON", PL = "WŁ"},
    ["OFF"] = {EN = "OFF", PL = "WYŁ"},
    ["Wrong Format"] = {EN = "Wrong Format", PL = "Zły Format"},
    [" Polska Gurom! "] = {EN = " Polska Gurom! ", PL = " Polska Gurom! "},
    ["eynz Hub successfully destroyed"] = {EN = "eynz Hub successfully destroyed", PL = "eynz Hub został pomyślnie usunięty"},
    ["Changelog"] = {EN = ChangelogTextEN, PL = ChangelogTextPL}
}

local function getTranslation(key)
    if Translations[key] and Translations[key][currentLang] then return Translations[key][currentLang] end
    return key
end

local function addTranslatable(obj, key, isSection)
    table.insert(translatables, {obj = obj, key = key, isSection = isSection})
    obj.Text = isSection and ("-- " .. getTranslation(key) .. " --") or getTranslation(key)
end

local function refreshTranslations()
    for _, item in ipairs(translatables) do
        if item.obj and item.obj.Parent then
            item.obj.Text = item.isSection and ("-- " .. getTranslation(item.key) .. " --") or getTranslation(item.key)
        end
    end
    for _, item in ipairs(statefulButtons) do
        if item.btn and item.btn.Parent then
            item.btn.Text = item.getState() and getTranslation("ON") or getTranslation("OFF")
        end
    end
    for _, func in ipairs(TranslationUpdaters) do func() end
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
local currentUIScale = 1.0

local function ShowNotification(message)
    local NoteFrame = Instance.new("Frame")
    NoteFrame.Size = UDim2.new(0, 200, 0, 40)
    NoteFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    NoteFrame.BackgroundTransparency = 1 
    
    local NoteCorner = Instance.new("UICorner") NoteCorner.CornerRadius = UDim.new(0, 6) NoteCorner.Parent = NoteFrame
    
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
    
    if isPolandMode then NoteFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255) end
    NoteFrame.Parent = NotifContainer
    
    TweenService:Create(NoteFrame, TweenInfo.new(0.4), {BackgroundTransparency = isPolandMode and 0.1 or 0.4}):Play()
    TweenService:Create(NoteStroke, TweenInfo.new(0.4), {Transparency = 0}):Play()
    TweenService:Create(NoteLabel, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    
    task.delay(3.5, function()
        local outTween = TweenService:Create(NoteLabel, TweenInfo.new(0.4), {TextTransparency = 1})
        TweenService:Create(NoteStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
        TweenService:Create(NoteFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        outTween:Play()
        outTween.Completed:Connect(function() NoteFrame:Destroy() end)
    end)
end

----------------------------------------------------
-- THEME MANAGERS & GUI ELEMENTS TRACKING
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

local ThemeStrokes, ThemeTexts, ThemeBackgrounds, ThemeUpdaters, ThemeFrames, ThemeSubFrames, DynamicTextElements = {}, {}, {}, {}, {}, {}, {}
local ThemeInputBoxes, ThemeSecondaryBtns, ThemePresetBtns = {}, {}, {}

local function applyThemeOutline(guiObject, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = ThemeColor
    stroke.Thickness = thickness or 1
    stroke:SetAttribute("OriginalThickness", stroke.Thickness)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = guiObject
    table.insert(ThemeStrokes, stroke)
    return stroke
end

local function registerDynamicText(element)
    element:SetAttribute("OrigColor", element.TextColor3)
    table.insert(DynamicTextElements, element)
end

----------------------------------------------------
-- UI CREATION
----------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "eynzHubMobileGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "eynzToggleBtn"
ToggleBtn.Size = UDim2.new(0, 100, 0, 35)
ToggleBtn.Position = UDim2.new(0, 15, 0, 15)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToggleBtn.Text = "eynz Hub"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Active = true -- Prevent camera dragging
ToggleBtn.Parent = ScreenGui

local LauncherScale = Instance.new("UIScale", ToggleBtn)
local ToggleCorner = Instance.new("UICorner") ToggleCorner.CornerRadius = UDim.new(0, 8) ToggleCorner.Parent = ToggleBtn
applyThemeOutline(ToggleBtn)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 310, 0, 410)
MainFrame.Position = UDim2.new(0.5, -155, 0.5, -205)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Active = true -- Prevent camera dragging
MainFrame.Parent = ScreenGui

local currentUIPos = UDim2.new(0.5, -155, 0.5, -205)
local MainScale = Instance.new("UIScale", MainFrame)
MainScale.Scale = 0
local MainCorner = Instance.new("UICorner") MainCorner.CornerRadius = UDim.new(0, 10) MainCorner.Parent = MainFrame
applyThemeOutline(MainFrame)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TitleBar.Active = true
TitleBar.Parent = MainFrame
local TitleCorner = Instance.new("UICorner") TitleCorner.CornerRadius = UDim.new(0, 10) TitleCorner.Parent = TitleBar

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 30)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
TabBar.BorderSizePixel = 0
TabBar.Active = true
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
addTranslatable(FeaturesTabBtn, "Features")

local SettingsTabBtn = Instance.new("TextButton")
SettingsTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
SettingsTabBtn.Position = UDim2.new(0.5, 0, 0, 0)
SettingsTabBtn.BackgroundTransparency = 1
SettingsTabBtn.Text = "Settings"
SettingsTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
SettingsTabBtn.Font = Enum.Font.SourceSansBold
SettingsTabBtn.TextSize = 14
SettingsTabBtn.Parent = TabBar
addTranslatable(SettingsTabBtn, "Settings")

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 12, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "eynz Hub | Mobile V2.6"
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

local function closeUI()
    local targetPos = UDim2.new(currentUIPos.X.Scale, currentUIPos.X.Offset, currentUIPos.Y.Scale, currentUIPos.Y.Offset + 60)
    
    TweenService:Create(MainScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0}):Play()
    TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Rotation = 12, Position = targetPos}):Play()
    
    task.delay(0.35, function()
        if MainScale.Scale == 0 then MainFrame.Visible = false end
    end)
end

local function openUI()
    MainFrame.Visible = true
    MainScale.Scale = 0
    MainFrame.Rotation = -15
    MainFrame.Position = UDim2.new(currentUIPos.X.Scale, currentUIPos.X.Offset, currentUIPos.Y.Scale, currentUIPos.Y.Offset + 60)
    
    TweenService:Create(MainScale, TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Scale = currentUIScale}):Play()
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = 0, Position = currentUIPos}):Play()
end

CloseBtn.MouseButton1Click:Connect(closeUI)
ToggleBtn.MouseButton1Click:Connect(function()
    if MainFrame.Visible and MainScale.Scale > 0.1 then
        closeUI()
    else
        openUI()
    end
end)
openUI()

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
            if frame == MainFrame then currentUIPos = frame.Position end
        end
    end))
end

makeDraggable(MainFrame, TitleBar, MainScale)
makeDraggable(ToggleBtn, ToggleBtn, LauncherScale)

local function createScrollFrame()
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, 0, 1, -80)
    Scroll.Position = UDim2.new(0, 0, 0, 75)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 3
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.Active = true
    Scroll.Parent = MainFrame
    
    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 8)
    Padding.PaddingRight = UDim.new(0, 12)
    Padding.PaddingTop = UDim.new(0, 2)
    Padding.PaddingBottom = UDim.new(0, 2)
    Padding.Parent = Scroll

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
        TweenService:Create(FeaturesScroll, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 75)}):Play()
        currentTab = FeaturesScroll
        
        TweenService:Create(FeaturesTabBtn, TweenInfo.new(0.2), {TextColor3 = activeCol}):Play()
        TweenService:Create(SettingsTabBtn, TweenInfo.new(0.2), {TextColor3 = inactiveCol}):Play()
    elseif tabName == "Settings" and currentTab ~= SettingsScroll then
        TweenService:Create(currentTab, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(-1, 0, 0, 75)}):Play()
        SettingsScroll.Position = UDim2.new(1, 0, 0, 75)
        SettingsScroll.Visible = true
        TweenService:Create(SettingsScroll, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 75)}):Play()
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
local function createSection(textKey, parent)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Size = UDim2.new(1, 0, 0, 25)
    SectionFrame.BackgroundTransparency = 1
    SectionFrame.Parent = parent or FeaturesScroll
    
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Name = "SectionLabel"
    SectionLabel.Size = UDim2.new(1, 0, 1, 0)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.TextColor3 = isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor
    SectionLabel.TextSize = 15
    SectionLabel.Font = Enum.Font.SourceSansBold
    SectionLabel.Parent = SectionFrame
    table.insert(ThemeTexts, SectionLabel)
    addTranslatable(SectionLabel, textKey, true)
end

local function createToggle(textKey, parent, defaultState, callback)
    local state = defaultState or false

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    ToggleFrame.Parent = parent or FeaturesScroll
    table.insert(ThemeFrames, ToggleFrame)

    local FrameCorner = Instance.new("UICorner") FrameCorner.CornerRadius = UDim.new(0, 6) FrameCorner.Parent = ToggleFrame
    applyThemeOutline(ToggleFrame)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSansSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    addTranslatable(Label, textKey)
    registerDynamicText(Label)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 50, 0, 24)
    Button.Position = UDim2.new(1, -60, 0.5, -12)
    Button.BackgroundColor3 = state and (isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor) or Color3.fromRGB(60, 60, 70)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 12
    Button.Parent = ToggleFrame
    
    local BtnCorner = Instance.new("UICorner") BtnCorner.CornerRadius = UDim.new(0, 6) BtnCorner.Parent = Button
    applyThemeOutline(Button)

    Button.Text = state and getTranslation("ON") or getTranslation("OFF")
    
    table.insert(statefulButtons, {
        btn = Button, 
        getState = function() return state end,
        updateMode = function(isPoland)
            if not state then
                Button.BackgroundColor3 = isPoland and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(60, 60, 70)
            end
        end
    })

    table.insert(ThemeUpdaters, function(newColor)
        if state then TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = newColor}):Play() end
    end)

    Button.MouseButton1Click:Connect(function()
        state = not state
        local targetColor = state and (isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor) or (isPolandMode and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(60, 60, 70))
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        Button.Text = state and getTranslation("ON") or getTranslation("OFF")
        
        if isPolandMode then
            Button.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 0, 0)
        end
        callback(state)
    end)
end

local function createExpandableToggle(textKey, parent, defaultState, mainCallback, subTogglesConfig)
    local state = defaultState or false
    local expanded = false
    local subToggleFrames = {}

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    ToggleFrame.Parent = parent or FeaturesScroll
    table.insert(ThemeFrames, ToggleFrame)
    local FrameCorner = Instance.new("UICorner") FrameCorner.CornerRadius = UDim.new(0, 6) FrameCorner.Parent = ToggleFrame
    applyThemeOutline(ToggleFrame)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSansSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    addTranslatable(Label, textKey)
    registerDynamicText(Label)

    local ExpandBtn = Instance.new("TextButton")
    ExpandBtn.Size = UDim2.new(0, 24, 0, 24)
    ExpandBtn.Position = UDim2.new(1, -90, 0.5, -12)
    ExpandBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    ExpandBtn.Text = "+"
    ExpandBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExpandBtn.Font = Enum.Font.SourceSansBold
    ExpandBtn.TextSize = 16
    ExpandBtn.Parent = ToggleFrame
    local ExpCorner = Instance.new("UICorner") ExpCorner.CornerRadius = UDim.new(0, 6) ExpCorner.Parent = ExpandBtn
    applyThemeOutline(ExpandBtn)
    registerDynamicText(ExpandBtn)
    table.insert(ThemeSecondaryBtns, ExpandBtn)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 50, 0, 24)
    Button.Position = UDim2.new(1, -60, 0.5, -12)
    Button.BackgroundColor3 = state and (isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor) or Color3.fromRGB(60, 60, 70)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 12
    Button.Parent = ToggleFrame
    local BtnCorner = Instance.new("UICorner") BtnCorner.CornerRadius = UDim.new(0, 6) BtnCorner.Parent = Button
    applyThemeOutline(Button)

    Button.Text = state and getTranslation("ON") or getTranslation("OFF")
    table.insert(statefulButtons, {
        btn = Button, 
        getState = function() return state end,
        updateMode = function(isPoland)
            if not state then
                Button.BackgroundColor3 = isPoland and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(60, 60, 70)
            end
        end
    })

    table.insert(ThemeUpdaters, function(newColor)
        if state then TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = newColor}):Play() end
    end)

    for _, subCfg in ipairs(subTogglesConfig) do
        local subState = false
        local SubFrame = Instance.new("Frame")
        SubFrame.Size = UDim2.new(1, 0, 0, 0)
        SubFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        SubFrame.ClipsDescendants = true
        SubFrame.Visible = false
        SubFrame.Parent = parent or FeaturesScroll
        table.insert(ThemeSubFrames, SubFrame)
        local SubCorner = Instance.new("UICorner") SubCorner.CornerRadius = UDim.new(0, 6) SubCorner.Parent = SubFrame
        applyThemeOutline(SubFrame)

        local SubLabel = Instance.new("TextLabel")
        SubLabel.Size = UDim2.new(0.6, 0, 0, 35)
        SubLabel.Position = UDim2.new(0, 10, 0, 0)
        SubLabel.BackgroundTransparency = 1
        SubLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        SubLabel.TextSize = 13
        SubLabel.Font = Enum.Font.SourceSansSemibold
        SubLabel.TextXAlignment = Enum.TextXAlignment.Left
        SubLabel.Parent = SubFrame
        addTranslatable(SubLabel, subCfg.text)
        registerDynamicText(SubLabel)

        local SubBtn = Instance.new("TextButton")
        SubBtn.Size = UDim2.new(0, 45, 0, 20)
        SubBtn.Position = UDim2.new(1, -55, 0, 7)
        SubBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        SubBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        SubBtn.Font = Enum.Font.SourceSansBold
        SubBtn.TextSize = 11
        SubBtn.Parent = SubFrame
        local SubBtnCorner = Instance.new("UICorner") SubBtnCorner.CornerRadius = UDim.new(0, 6) SubBtnCorner.Parent = SubBtn
        applyThemeOutline(SubBtn)

        SubBtn.Text = subState and getTranslation("ON") or getTranslation("OFF")
        table.insert(statefulButtons, {
            btn = SubBtn, 
            getState = function() return subState end,
            updateMode = function(isPoland)
                if not subState then
                    SubBtn.BackgroundColor3 = isPoland and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(60, 60, 70)
                end
            end
        })

        table.insert(ThemeUpdaters, function(newColor)
            if subState then TweenService:Create(SubBtn, TweenInfo.new(0.3), {BackgroundColor3 = newColor}):Play() end
        end)

        SubBtn.MouseButton1Click:Connect(function()
            subState = not subState
            local targetColor = subState and (isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor) or (isPolandMode and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(60, 60, 70))
            TweenService:Create(SubBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
            SubBtn.Text = subState and getTranslation("ON") or getTranslation("OFF")
            if isPolandMode then SubBtn.TextColor3 = subState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 0, 0) end
            subCfg.callback(subState)
        end)
        table.insert(subToggleFrames, SubFrame)
    end

    Button.MouseButton1Click:Connect(function()
        state = not state
        local targetColor = state and (isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor) or (isPolandMode and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(60, 60, 70))
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        Button.Text = state and getTranslation("ON") or getTranslation("OFF")
        if isPolandMode then Button.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 0, 0) end
        mainCallback(state)
    end)

    ExpandBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        local targetRotation = expanded and 45 or 0
        TweenService:Create(ExpandBtn, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Rotation = targetRotation}):Play()

        for _, frm in ipairs(subToggleFrames) do
            if expanded then
                frm.Visible = true
                TweenService:Create(frm, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 35)}):Play()
            else
                local tw = TweenService:Create(frm, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
                tw:Play()
                task.delay(0.25, function() if not expanded then frm.Visible = false end end)
            end
        end
    end)
end

local function createExpandableToggleWithInput(textKey, inputKey, parent, defaultState, defaultInput, callback)
    local state = defaultState
    local currentInput = defaultInput
    local expanded = false

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    ToggleFrame.Parent = parent
    table.insert(ThemeFrames, ToggleFrame)
    local FrameCorner = Instance.new("UICorner") FrameCorner.CornerRadius = UDim.new(0, 6) FrameCorner.Parent = ToggleFrame
    applyThemeOutline(ToggleFrame)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSansSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    addTranslatable(Label, textKey)
    registerDynamicText(Label)

    local ExpandBtn = Instance.new("TextButton")
    ExpandBtn.Size = UDim2.new(0, 24, 0, 24)
    ExpandBtn.Position = UDim2.new(1, -90, 0.5, -12)
    ExpandBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    ExpandBtn.Text = "+"
    ExpandBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExpandBtn.Font = Enum.Font.SourceSansBold
    ExpandBtn.TextSize = 16
    ExpandBtn.Parent = ToggleFrame
    local ExpCorner = Instance.new("UICorner") ExpCorner.CornerRadius = UDim.new(0, 6) ExpCorner.Parent = ExpandBtn
    applyThemeOutline(ExpandBtn)
    registerDynamicText(ExpandBtn)
    table.insert(ThemeSecondaryBtns, ExpandBtn)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 50, 0, 24)
    Button.Position = UDim2.new(1, -60, 0.5, -12)
    Button.BackgroundColor3 = state and (isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor) or Color3.fromRGB(60, 60, 70)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 12
    Button.Parent = ToggleFrame
    local BtnCorner = Instance.new("UICorner") BtnCorner.CornerRadius = UDim.new(0, 6) BtnCorner.Parent = Button
    applyThemeOutline(Button)

    Button.Text = state and getTranslation("ON") or getTranslation("OFF")
    table.insert(statefulButtons, {
        btn = Button, 
        getState = function() return state end,
        updateMode = function(isPoland)
            if not state then
                Button.BackgroundColor3 = isPoland and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(60, 60, 70)
            end
        end
    })

    table.insert(ThemeUpdaters, function(newColor)
        if state then TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = newColor}):Play() end
    end)

    local SubFrame = Instance.new("Frame")
    SubFrame.Size = UDim2.new(1, 0, 0, 0)
    SubFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    SubFrame.ClipsDescendants = true
    SubFrame.Visible = false
    SubFrame.Parent = parent
    table.insert(ThemeSubFrames, SubFrame)
    local SubCorner = Instance.new("UICorner") SubCorner.CornerRadius = UDim.new(0, 6) SubCorner.Parent = SubFrame
    applyThemeOutline(SubFrame)

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(0.5, 0, 0, 35)
    SubLabel.Position = UDim2.new(0, 10, 0, 0)
    SubLabel.BackgroundTransparency = 1
    SubLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SubLabel.TextSize = 13
    SubLabel.Font = Enum.Font.SourceSansSemibold
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.Parent = SubFrame
    addTranslatable(SubLabel, inputKey)
    registerDynamicText(SubLabel)

    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(0, 60, 0, 22)
    InputBox.Position = UDim2.new(1, -70, 0, 6)
    InputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    InputBox.Text = tostring(currentInput)
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.Font = Enum.Font.SourceSansBold
    InputBox.TextSize = 12
    InputBox.Parent = SubFrame
    local BoxCorner = Instance.new("UICorner") BoxCorner.CornerRadius = UDim.new(0, 6) BoxCorner.Parent = InputBox
    applyThemeOutline(InputBox)
    table.insert(ThemeInputBoxes, InputBox)

    InputBox.FocusLost:Connect(function()
        local val = tonumber(InputBox.Text)
        if val then
            if val > 100 then
                val = 100
                InputBox.Text = "100"
                ShowNotification(getTranslation("Max 100 studs"))
            end
            currentInput = val
            callback(state, currentInput)
        else
            InputBox.Text = tostring(currentInput)
        end
    end)

    Button.MouseButton1Click:Connect(function()
        state = not state
        local targetColor = state and (isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor) or (isPolandMode and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(60, 60, 70))
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        Button.Text = state and getTranslation("ON") or getTranslation("OFF")
        if isPolandMode then Button.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 0, 0) end
        callback(state, currentInput)
    end)

    ExpandBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        local targetRotation = expanded and 45 or 0
        TweenService:Create(ExpandBtn, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Rotation = targetRotation}):Play()

        if expanded then
            SubFrame.Visible = true
            TweenService:Create(SubFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 35)}):Play()
        else
            local tw = TweenService:Create(SubFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
            tw:Play()
            task.delay(0.25, function() if not expanded then SubFrame.Visible = false end end)
        end
    end)
end

local function createSlider(labelText, parent, min, max, defaultVal, callback)
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(1, 0, 0, 50)
    RowFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    RowFrame.Parent = parent or FeaturesScroll
    table.insert(ThemeFrames, RowFrame)
    applyThemeOutline(RowFrame)
    local FrameCorner = Instance.new("UICorner") FrameCorner.CornerRadius = UDim.new(0, 6) FrameCorner.Parent = RowFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSansSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = RowFrame
    addTranslatable(Label, labelText)
    registerDynamicText(Label)

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
    registerDynamicText(ValueLabel)

    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -20, 0, 10) 
    SliderBg.Position = UDim2.new(0, 10, 0, 30)
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
    
    local SliderHandle = Instance.new("Frame")
    SliderHandle.Size = UDim2.new(0, 16, 0, 16)
    SliderHandle.Position = UDim2.new(1, -8, 0.5, -8)
    SliderHandle.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    local HandleCorner = Instance.new("UICorner") HandleCorner.CornerRadius = UDim.new(1, 0) HandleCorner.Parent = SliderHandle
    SliderHandle.Parent = SliderFill

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

local function createButton(textKey, parent, callback, colorTheme)
    local BtnFrame = Instance.new("Frame")
    BtnFrame.Size = UDim2.new(1, 0, 0, 35)
    BtnFrame.BackgroundTransparency = 1
    BtnFrame.Parent = parent or FeaturesScroll

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundColor3 = colorTheme or Color3.fromRGB(45, 45, 55)
    if not colorTheme then table.insert(ThemeFrames, Btn) end
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 14
    Btn.Parent = BtnFrame
    local BtnCorner = Instance.new("UICorner") BtnCorner.CornerRadius = UDim.new(0, 6) BtnCorner.Parent = Btn
    applyThemeOutline(Btn)

    addTranslatable(Btn, textKey)
    if not colorTheme then registerDynamicText(Btn) end

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
        for _, frm in ipairs(ThemeFrames) do
            if frm and frm.Parent then frm.BackgroundColor3 = Color3.fromRGB(240, 240, 240) end
        end
        for _, frm in ipairs(ThemeSubFrames) do
            if frm and frm.Parent then frm.BackgroundColor3 = Color3.fromRGB(220, 220, 220) end
        end
        for _, box in ipairs(ThemeInputBoxes) do
            if box and box.Parent then box.BackgroundColor3 = Color3.fromRGB(220, 220, 220) box.TextColor3 = Color3.fromRGB(20, 20, 20) end
        end
        for _, btn in ipairs(ThemeSecondaryBtns) do
            if btn and btn.Parent then btn.BackgroundColor3 = Color3.fromRGB(210, 210, 210) btn.TextColor3 = Color3.fromRGB(20, 20, 20) end
        end
        for _, pBtn in ipairs(ThemePresetBtns) do
            if pBtn and pBtn.Parent then pBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 230) end
        end
        for _, txt in ipairs(ThemeTexts) do
            if txt and txt.Parent and txt.Name ~= "eynzToggleBtn" and txt.Name ~= "TitleText" then 
                txt.TextColor3 = Color3.fromRGB(255, 0, 0) 
            end
        end
        for _, bg in ipairs(ThemeBackgrounds) do
            if bg and bg.Parent then bg.BackgroundColor3 = Color3.fromRGB(255, 0, 0) end
        end
        for _, v in ipairs(DynamicTextElements) do
            if v and v.Parent then v.TextColor3 = Color3.fromRGB(255, 0, 0) end
        end
        for _, item in ipairs(statefulButtons) do
            if item.btn and item.btn.Parent then
                item.btn.TextColor3 = item.getState() and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 0, 0)
                if item.updateMode then item.updateMode(true) end
            end
        end
        for _, func in ipairs(ThemeUpdaters) do func(Color3.fromRGB(255, 0, 0)) end
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
            stroke.Thickness = stroke:GetAttribute("OriginalThickness") or 1
            stroke.Color = ThemeColor
        end
        for _, frm in ipairs(ThemeFrames) do
            if frm and frm.Parent then frm.BackgroundColor3 = Color3.fromRGB(45, 45, 55) end
        end
        for _, frm in ipairs(ThemeSubFrames) do
            if frm and frm.Parent then frm.BackgroundColor3 = Color3.fromRGB(35, 35, 45) end
        end
        for _, box in ipairs(ThemeInputBoxes) do
            if box and box.Parent then box.BackgroundColor3 = Color3.fromRGB(20, 20, 26) box.TextColor3 = Color3.fromRGB(255, 255, 255) end
        end
        for _, btn in ipairs(ThemeSecondaryBtns) do
            if btn and btn.Parent then btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50) btn.TextColor3 = Color3.fromRGB(255, 255, 255) end
        end
        for _, pBtn in ipairs(ThemePresetBtns) do
            if pBtn and pBtn.Parent then pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50) end
        end
        for _, txt in ipairs(ThemeTexts) do
            if txt and txt.Parent and txt.Name ~= "eynzToggleBtn" and txt.Name ~= "TitleText" then 
                txt.TextColor3 = ThemeColor 
            end
        end
        for _, bg in ipairs(ThemeBackgrounds) do
            if bg and bg.Parent then bg.BackgroundColor3 = ThemeColor end
        end
        for _, v in ipairs(DynamicTextElements) do
            if v and v.Parent then
                local orig = v:GetAttribute("OrigColor")
                if orig then v.TextColor3 = orig end
            end
        end
        for _, item in ipairs(statefulButtons) do
            if item.btn and item.btn.Parent then 
                item.btn.TextColor3 = Color3.fromRGB(255, 255, 255) 
                if item.updateMode then item.updateMode(false) end
            end
        end
        for _, func in ipairs(ThemeUpdaters) do func(ThemeColor) end
    end
end

local function updateThemeColor(color)
    ThemeColor = color
    if isPolandMode then setPolandMode(false) end
    
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
    for _, func in ipairs(ThemeUpdaters) do func(color) end
end

local function createColorPresetsRow(parent)
    local expanded = false
    
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(1, 0, 0, 40)
    RowFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    RowFrame.Parent = parent
    table.insert(ThemeFrames, RowFrame)
    applyThemeOutline(RowFrame)
    local FrameCorner = Instance.new("UICorner") FrameCorner.CornerRadius = UDim.new(0, 6) FrameCorner.Parent = RowFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSansSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = RowFrame
    addTranslatable(Label, "Color Presets & Themes")
    registerDynamicText(Label)

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
    applyThemeOutline(ExpandBtn)
    registerDynamicText(ExpandBtn)
    table.insert(ThemeSecondaryBtns, ExpandBtn)

    local SubContainer = Instance.new("Frame")
    SubContainer.Size = UDim2.new(1, 0, 0, 0)
    SubContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    SubContainer.ClipsDescendants = true
    SubContainer.Visible = false
    SubContainer.Parent = parent
    table.insert(ThemeSubFrames, SubContainer)
    local SubCorner = Instance.new("UICorner") SubCorner.CornerRadius = UDim.new(0, 6) SubCorner.Parent = SubContainer
    applyThemeOutline(SubContainer)
    
    local SubList = Instance.new("UIListLayout")
    SubList.Padding = UDim.new(0, 6)
    SubList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SubList.SortOrder = Enum.SortOrder.LayoutOrder
    SubList.Parent = SubContainer
    
    local SubPad = Instance.new("UIPadding") SubPad.PaddingTop = UDim.new(0, 6) SubPad.PaddingBottom = UDim.new(0, 6) SubPad.Parent = SubContainer

    local colors = {
        {key = "Purple (Default)", rgb = Color3.fromRGB(138, 43, 226)},
        {key = "Orange", rgb = Color3.fromRGB(255, 128, 0)},
        {key = "Brown", rgb = Color3.fromRGB(139, 69, 19)},
        {key = "Yellow", rgb = Color3.fromRGB(255, 255, 0)},
        {key = "Blue", rgb = Color3.fromRGB(0, 100, 255)},
        {key = "Red", rgb = Color3.fromRGB(255, 50, 50)},
        {key = "Green", rgb = Color3.fromRGB(50, 255, 50)},
        {key = "White", rgb = Color3.fromRGB(255, 255, 255)}
    }
    
    for _, clr in ipairs(colors) do
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -12, 0, 26)
        Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        Btn.TextColor3 = clr.rgb
        Btn.Font = Enum.Font.SourceSansBold
        Btn.TextSize = 13
        Btn.Parent = SubContainer
        local BtnCorner = Instance.new("UICorner") BtnCorner.CornerRadius = UDim.new(0, 6) BtnCorner.Parent = Btn
        applyThemeOutline(Btn)
        addTranslatable(Btn, clr.key)
        table.insert(ThemePresetBtns, Btn)
        Btn.MouseButton1Click:Connect(function() updateThemeColor(clr.rgb) end)
    end
    
    local PolandBtn = Instance.new("TextButton")
    PolandBtn.Size = UDim2.new(1, -12, 0, 26)
    PolandBtn.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    PolandBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
    PolandBtn.Font = Enum.Font.SourceSansBold
    PolandBtn.TextSize = 13
    PolandBtn.Parent = SubContainer
    local PolCorner = Instance.new("UICorner") PolCorner.CornerRadius = UDim.new(0, 6) PolCorner.Parent = PolandBtn
    addTranslatable(PolandBtn, "Poland Mode")
    
    local polStroke = Instance.new("UIStroke")
    polStroke.Color = Color3.fromRGB(255, 0, 0)
    polStroke.Thickness = 1.5
    polStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    polStroke.Parent = PolandBtn
    
    PolandBtn.MouseButton1Click:Connect(function()
        setPolandMode(true)
        ShowNotification(getTranslation(" Polska Gurom! "))
    end)
    
    local CustomRGBRow = Instance.new("Frame")
    CustomRGBRow.Size = UDim2.new(1, -12, 0, 30)
    CustomRGBRow.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    CustomRGBRow.Parent = SubContainer
    table.insert(ThemeFrames, CustomRGBRow)
    local CRGBCorner = Instance.new("UICorner") CRGBCorner.CornerRadius = UDim.new(0, 6) CRGBCorner.Parent = CustomRGBRow
    applyThemeOutline(CustomRGBRow)
    
    local CLabel = Instance.new("TextLabel")
    CLabel.Size = UDim2.new(0.4, 0, 1, 0)
    CLabel.Position = UDim2.new(0, 10, 0, 0)
    CLabel.BackgroundTransparency = 1
    CLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    CLabel.TextSize = 13
    CLabel.Font = Enum.Font.SourceSansSemibold
    CLabel.TextXAlignment = Enum.TextXAlignment.Left
    CLabel.Parent = CustomRGBRow
    addTranslatable(CLabel, "Custom RGB")
    registerDynamicText(CLabel)
    
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
    applyThemeOutline(InputBox)
    table.insert(ThemeInputBoxes, InputBox)
    
    InputBox.FocusLost:Connect(function()
        local r, g, b = InputBox.Text:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
        if r and g and b then
            updateThemeColor(Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b)))
        else
            ShowNotification(getTranslation("Wrong Format"))
        end
    end)
    
    ExpandBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        local targetRotation = expanded and 45 or 0
        TweenService:Create(ExpandBtn, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Rotation = targetRotation}):Play()

        if expanded then
            SubContainer.Visible = true
            local contentHeight = SubList.AbsoluteContentSize.Y + 12
            TweenService:Create(SubContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, contentHeight)}):Play()
        else
            local tw = TweenService:Create(SubContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
            tw:Play()
            task.delay(0.3, function() if not expanded then SubContainer.Visible = false end end)
        end
    end)
end

local function createInputRow(labelText, parent, defaultVal, callback)
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(1, 0, 0, 40)
    RowFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    RowFrame.Parent = parent or FeaturesScroll
    table.insert(ThemeFrames, RowFrame)

    local FrameCorner = Instance.new("UICorner") FrameCorner.CornerRadius = UDim.new(0, 6) FrameCorner.Parent = RowFrame
    applyThemeOutline(RowFrame)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSansSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = RowFrame
    addTranslatable(Label, labelText)
    registerDynamicText(Label)

    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(0, 100, 0, 26)
    InputBox.Position = UDim2.new(1, -110, 0.5, -13)
    InputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    InputBox.Text = tostring(defaultVal)
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.Font = Enum.Font.SourceSansBold
    InputBox.TextSize = 13
    InputBox.Parent = RowFrame
    local BoxCorner = Instance.new("UICorner") BoxCorner.CornerRadius = UDim.new(0, 6) BoxCorner.Parent = InputBox
    applyThemeOutline(InputBox)
    table.insert(ThemeInputBoxes, InputBox)

    InputBox.FocusLost:Connect(function() callback(InputBox.Text) end)
end

local function createPlayerCycler(parent)
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(1, 0, 0, 50)
    RowFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    RowFrame.Parent = parent
    table.insert(ThemeFrames, RowFrame)
    applyThemeOutline(RowFrame)
    local FrameCorner = Instance.new("UICorner") FrameCorner.CornerRadius = UDim.new(0, 6) FrameCorner.Parent = RowFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 16)
    Label.Position = UDim2.new(0, 10, 0, 4)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 13
    Label.Font = Enum.Font.SourceSansSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = RowFrame
    addTranslatable(Label, "Teleport to Player")
    registerDynamicText(Label)

    local CyclerContainer = Instance.new("Frame")
    CyclerContainer.Size = UDim2.new(1, -20, 0, 26)
    CyclerContainer.Position = UDim2.new(0, 10, 0, 20)
    CyclerContainer.BackgroundTransparency = 1
    CyclerContainer.Parent = RowFrame

    local PrevBtn = Instance.new("TextButton")
    PrevBtn.Size = UDim2.new(0, 26, 1, 0)
    PrevBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    PrevBtn.Text = "<"
    PrevBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    PrevBtn.Font = Enum.Font.SourceSansBold
    PrevBtn.Parent = CyclerContainer
    local PBtnCorner = Instance.new("UICorner") PBtnCorner.CornerRadius = UDim.new(0, 4) PBtnCorner.Parent = PrevBtn
    table.insert(ThemeSecondaryBtns, PrevBtn)

    local NextBtn = Instance.new("TextButton")
    NextBtn.Size = UDim2.new(0, 26, 1, 0)
    NextBtn.Position = UDim2.new(1, -70, 0, 0)
    NextBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    NextBtn.Text = ">"
    NextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    NextBtn.Font = Enum.Font.SourceSansBold
    NextBtn.Parent = CyclerContainer
    local NBtnCorner = Instance.new("UICorner") NBtnCorner.CornerRadius = UDim.new(0, 4) NBtnCorner.Parent = NextBtn
    table.insert(ThemeSecondaryBtns, NextBtn)

    local TPBtn = Instance.new("TextButton")
    TPBtn.Size = UDim2.new(0, 40, 1, 0)
    TPBtn.Position = UDim2.new(1, -40, 0, 0)
    TPBtn.BackgroundColor3 = ThemeColor
    TPBtn.Text = "TP"
    TPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TPBtn.Font = Enum.Font.SourceSansBold
    TPBtn.Parent = CyclerContainer
    local TPBtnCorner = Instance.new("UICorner") TPBtnCorner.CornerRadius = UDim.new(0, 4) TPBtnCorner.Parent = TPBtn
    addTranslatable(TPBtn, "TP")
    table.insert(ThemeUpdaters, function(newColor) TPBtn.BackgroundColor3 = newColor end)

    local PlayerIcon = Instance.new("ImageLabel")
    PlayerIcon.Size = UDim2.new(0, 20, 0, 20)
    PlayerIcon.Position = UDim2.new(0, 32, 0.5, -10)
    PlayerIcon.BackgroundTransparency = 1
    PlayerIcon.Image = ""
    PlayerIcon.Parent = CyclerContainer
    local IconCorner = Instance.new("UICorner") IconCorner.CornerRadius = UDim.new(1, 0) IconCorner.Parent = PlayerIcon

    local PlayerNameLbl = Instance.new("TextLabel")
    PlayerNameLbl.Size = UDim2.new(1, -135, 1, 0)
    PlayerNameLbl.Position = UDim2.new(0, 58, 0, 0)
    PlayerNameLbl.BackgroundTransparency = 1
    PlayerNameLbl.Text = "No Players"
    PlayerNameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlayerNameLbl.TextSize = 14
    PlayerNameLbl.Font = Enum.Font.SourceSansBold
    PlayerNameLbl.TextXAlignment = Enum.TextXAlignment.Left
    PlayerNameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    PlayerNameLbl.Parent = CyclerContainer
    registerDynamicText(PlayerNameLbl)
    
    local validPlayers = {}
    local currentIndex = 1

    local function updateDisplay()
        validPlayers = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(validPlayers, p) end
        end

        if #validPlayers == 0 then
            PlayerNameLbl.Text = getTranslation("No Players")
            PlayerIcon.Image = ""
            return
        end

        if currentIndex > #validPlayers then currentIndex = 1 end
        if currentIndex < 1 then currentIndex = #validPlayers end

        local selected = validPlayers[currentIndex]
        PlayerNameLbl.Text = selected.DisplayName .. " (@" .. selected.Name .. ")"
        
        task.spawn(function()
            local content, isReady = Players:GetUserThumbnailAsync(selected.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            if isReady and validPlayers[currentIndex] == selected then
                PlayerIcon.Image = content
            end
        end)
    end

    PrevBtn.MouseButton1Click:Connect(function()
        if #validPlayers > 0 then
            currentIndex = currentIndex - 1
            updateDisplay()
        end
    end)

    NextBtn.MouseButton1Click:Connect(function()
        if #validPlayers > 0 then
            currentIndex = currentIndex + 1
            updateDisplay()
        end
    end)

    TPBtn.MouseButton1Click:Connect(function()
        if #validPlayers > 0 and validPlayers[currentIndex] then
            local targetPlayer = validPlayers[currentIndex]
            if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                end
            end
        end
    end)

    table.insert(TranslationUpdaters, updateDisplay)
    table.insert(ActiveConnections, Players.PlayerAdded:Connect(updateDisplay))
    table.insert(ActiveConnections, Players.PlayerRemoving:Connect(updateDisplay))
    updateDisplay()
end

local function createAboutCard(parent)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 60)
    Card.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Card.Parent = parent
    table.insert(ThemeFrames, Card)
    applyThemeOutline(Card)
    local CardCorner = Instance.new("UICorner") CardCorner.CornerRadius = UDim.new(0, 6) CardCorner.Parent = Card
    
    local Lbl1 = Instance.new("TextLabel")
    Lbl1.Size = UDim2.new(1, 0, 0, 30)
    Lbl1.BackgroundTransparency = 1
    Lbl1.Text = "Made by 1eyn"
    Lbl1.TextColor3 = Color3.fromRGB(255, 255, 255)
    Lbl1.Font = Enum.Font.SourceSansBold
    Lbl1.TextSize = 16
    Lbl1.Parent = Card
    registerDynamicText(Lbl1)
    
    local Lbl2 = Instance.new("TextLabel")
    Lbl2.Size = UDim2.new(1, 0, 0, 30)
    Lbl2.Position = UDim2.new(0, 0, 0, 25)
    Lbl2.BackgroundTransparency = 1
    Lbl2.Text = "Version 2.6"
    Lbl2.TextColor3 = Color3.fromRGB(200, 200, 200)
    Lbl2.Font = Enum.Font.SourceSansSemibold
    Lbl2.TextSize = 14
    Lbl2.Parent = Card
    registerDynamicText(Lbl2)
end

local function createDetailsExpandable(parent)
    local expanded = false
    
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(1, 0, 0, 40)
    RowFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    RowFrame.Parent = parent
    table.insert(ThemeFrames, RowFrame)
    applyThemeOutline(RowFrame)
    local FrameCorner = Instance.new("UICorner") FrameCorner.CornerRadius = UDim.new(0, 6) FrameCorner.Parent = RowFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.8, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSansSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = RowFrame
    addTranslatable(Label, "Details")
    registerDynamicText(Label)

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
    applyThemeOutline(ExpandBtn)
    registerDynamicText(ExpandBtn)
    table.insert(ThemeSecondaryBtns, ExpandBtn)

    local SubContainer = Instance.new("Frame")
    SubContainer.Size = UDim2.new(1, 0, 0, 0)
    SubContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    SubContainer.ClipsDescendants = true
    SubContainer.Visible = false
    SubContainer.Parent = parent
    table.insert(ThemeSubFrames, SubContainer)
    local SubCorner = Instance.new("UICorner") SubCorner.CornerRadius = UDim.new(0, 6) SubCorner.Parent = SubContainer
    applyThemeOutline(SubContainer)
    
    local TextCont = Instance.new("TextLabel")
    TextCont.Size = UDim2.new(1, -20, 1, -10)
    TextCont.Position = UDim2.new(0, 10, 0, 5)
    TextCont.BackgroundTransparency = 1
    TextCont.TextColor3 = Color3.fromRGB(200, 200, 200)
    TextCont.TextSize = 12
    TextCont.Font = Enum.Font.SourceSans
    TextCont.TextXAlignment = Enum.TextXAlignment.Left
    TextCont.TextYAlignment = Enum.TextYAlignment.Top
    TextCont.TextWrapped = true
    TextCont.Parent = SubContainer
    addTranslatable(TextCont, "Changelog")
    registerDynamicText(TextCont)
    
    ExpandBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        local targetRotation = expanded and 45 or 0
        TweenService:Create(ExpandBtn, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Rotation = targetRotation}):Play()

        if expanded then
            SubContainer.Visible = true
            local contentHeight = 110
            TweenService:Create(SubContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, contentHeight)}):Play()
        else
            local tw = TweenService:Create(SubContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
            tw:Play()
            task.delay(0.3, function() if not expanded then SubContainer.Visible = false end end)
        end
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

createToggle("Flight", FeaturesScroll, false, function(state)
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

-- TELEPORT TO PLAYER
createPlayerCycler(FeaturesScroll)

-- INSTANT PROMPT & REACH
local instantPromptEnabled = false
local promptReachValue = 10

local function updatePrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    if not prompt:GetAttribute("OrigHold") then
        prompt:SetAttribute("OrigHold", prompt.HoldDuration)
        prompt:SetAttribute("OrigReach", prompt.MaxActivationDistance)
    end
    
    if instantPromptEnabled then
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = promptReachValue
    else
        prompt.HoldDuration = prompt:GetAttribute("OrigHold")
        prompt.MaxActivationDistance = prompt:GetAttribute("OrigReach")
    end
end

local function refreshAllPrompts()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then updatePrompt(obj) end
    end
end

createExpandableToggleWithInput("Instant Prompt", "Prompt Reach", FeaturesScroll, false, 10, function(state, reach)
    instantPromptEnabled = state
    promptReachValue = reach
    refreshAllPrompts()
end)

table.insert(ActiveConnections, workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ProximityPrompt") then
        task.wait(0.1)
        updatePrompt(obj)
    end
end))

----------------------------------------------------
-- VISUALS / ESP
----------------------------------------------------
createSection("Visuals / ESP", FeaturesScroll)

local fullbrightEnabled = false
createToggle("Fullbright", FeaturesScroll, false, function(state)
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
local interactableEspEnabled, interactableNamesEnabled = false, false

local playerESPData, activeNPCs, activeInteractables = {}, {}, {}
local npcDescendantConn, interactableDescendantConn
local npcCleanLoop, interactableCleanLoop

local function getESPAdornee(obj)
    if obj:IsA("Tool") then
        if obj.Parent and (Players:GetPlayerFromCharacter(obj.Parent) or obj.Parent:FindFirstChildOfClass("Humanoid")) then return nil end
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart") or obj
    end
    if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then
        local parent = obj.Parent
        if parent then
            local model = parent:IsA("Model") and parent or parent.Parent
            if model and model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") then return nil end
            if parent:IsA("BasePart") then return parent end
            if parent:IsA("Model") then return parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart") or parent end
        end
    end
    return nil
end

local function applyPlayerESP(player)
    if player == LocalPlayer then return end
    if not playerESPData[player] then playerESPData[player] = {} end
    local data = playerESPData[player]
    local char = player.Character

    if data.Char ~= char then
        if data.Highlight then data.Highlight:Destroy(); data.Highlight = nil end
        if data.NameTag then data.NameTag:Destroy(); data.NameTag = nil end
        data.Char = char
    end

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

-- INTERACTABLES ESP
local function applyInteractableVisuals(intObj)
    if not activeInteractables[intObj] then activeInteractables[intObj] = {} end
    local data = activeInteractables[intObj]
    local adornee = getESPAdornee(intObj)
    
    if interactableEspEnabled and adornee then
        if not data.Highlight then
            local hl = Instance.new("Highlight")
            hl.FillColor = Color3.fromRGB(255, 215, 0) -- Gold for Interactables
            hl.FillTransparency = 0.5
            hl.OutlineColor = Color3.new(1,1,1)
            hl.Adornee = adornee
            hl.Parent = adornee
            data.Highlight = hl
        else
            data.Highlight.Adornee = adornee
            data.Highlight.Parent = adornee
        end
        
        if interactableNamesEnabled and not data.NameTag then
            local nameStr = intObj.Name
            if intObj:IsA("ProximityPrompt") and intObj.ActionText ~= "" then
                nameStr = intObj.ActionText
            elseif intObj.Parent and (intObj:IsA("ClickDetector") or intObj:IsA("ProximityPrompt")) then
                nameStr = intObj.Parent.Name
            end
            
            local bg = createNameTag(nameStr, Color3.fromRGB(255, 215, 0))
            bg.Adornee = adornee
            bg.Parent = adornee
            data.NameTag = bg
        end
    end
    
    if not interactableEspEnabled or not adornee then
        if data.Highlight then data.Highlight:Destroy(); data.Highlight = nil end
        if data.NameTag then data.NameTag:Destroy(); data.NameTag = nil end
    else
        if not interactableNamesEnabled and data.NameTag then data.NameTag:Destroy(); data.NameTag = nil end
    end
end

local function refreshAllInteractablesESP() for intObj, _ in pairs(activeInteractables) do applyInteractableVisuals(intObj) end end

local function toggleInteractablesESP()
    if interactableEspEnabled then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then 
                activeInteractables[obj] = {}; applyInteractableVisuals(obj) 
            end
        end
        interactableDescendantConn = workspace.DescendantAdded:Connect(function(obj)
            task.wait(0.1)
            if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then 
                activeInteractables[obj] = {}; applyInteractableVisuals(obj) 
            end
        end)
        if not table.find(ActiveConnections, interactableDescendantConn) then table.insert(ActiveConnections, interactableDescendantConn) end
        
        interactableCleanLoop = task.spawn(function()
            while task.wait(2) do
                for intObj, data in pairs(activeInteractables) do
                    if not intObj.Parent or not getESPAdornee(intObj) then
                        if data.Highlight then data.Highlight:Destroy() end
                        if data.NameTag then data.NameTag:Destroy() end
                        activeInteractables[intObj] = nil
                    else
                        applyInteractableVisuals(intObj)
                    end
                end
            end
        end)
    else
        if interactableDescendantConn then interactableDescendantConn:Disconnect(); interactableDescendantConn = nil end
        if interactableCleanLoop then task.cancel(interactableCleanLoop); interactableCleanLoop = nil end
        refreshAllInteractablesESP(); activeInteractables = {}
    end
end

createExpandableToggle("Interactables ESP", FeaturesScroll, false, function(state)
    interactableEspEnabled = state
    toggleInteractablesESP()
end, {
    { text = "Show Int. Names", callback = function(state) interactableNamesEnabled = state refreshAllInteractablesESP() end }
})

----------------------------------------------------
-- SETTINGS TAB IMPLEMENTATION
----------------------------------------------------
createSection("General Setup", SettingsScroll)

createSlider("UI Scale", SettingsScroll, 0.5, 1.5, 1.0, function(val)
    currentUIScale = val
    if MainFrame.Visible and MainScale.Scale > 0.1 then
        TweenService:Create(MainScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = val}):Play()
    end
    TweenService:Create(LauncherScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = val}):Play()
end)

createColorPresetsRow(SettingsScroll)

createButton("Language: English", SettingsScroll, function()
    currentLang = currentLang == "EN" and "PL" or "EN"
    refreshTranslations()
end)

createSection("Danger Zone", SettingsScroll)

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
    instantPromptEnabled = false; refreshAllPrompts()
    
    playerEspEnabled = false; refreshAllPlayersESP()
    npcEspEnabled = false; refreshAllNPCsESP()
    interactableEspEnabled = false; toggleInteractablesESP()

    for _, connection in ipairs(ActiveConnections) do
        if connection and connection.Disconnect then connection:Disconnect() end
    end

    if ScreenGui then ScreenGui:Destroy() end
    ShowNotification(getTranslation("eynz Hub successfully destroyed"))
end

createButton("Destroy Everything & UI", SettingsScroll, function() DestroyHub() end, Color3.fromRGB(180, 40, 40))

createSection("About", SettingsScroll)
createAboutCard(SettingsScroll)
createDetailsExpandable(SettingsScroll)

-- Initial Translation Refresh
refreshTranslations()
