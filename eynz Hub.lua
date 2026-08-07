--[[
    ==================================================
    eynz Hub - Mobile Edition (Ultimate V3.11)
    - V3.11 Enhancements:
    - Added Premium Geometric Vortex Logo (No assets required, fully UI generated)
    - Rebuilt 3D Coin Toss Minigame (Bigger Coin, 3D Embossed H/T faces)
    - Implemented Physics-based Parabolic Coin Spin Animation
    - Added Custom Viewport Lighting for the Coin
    - Updated Multilingual Changelogs
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
if ParentGui:FindFirstChild("eynzPromptButton") then ParentGui:FindFirstChild("eynzPromptButton"):Destroy() end

----------------------------------------------------
-- MULTILINGUAL SYSTEM
----------------------------------------------------
local currentLang = "EN"
local translatables = {}
local statefulButtons = {}
local TranslationUpdaters = {}

local ChangelogTextEN = "• V3.11 Update!\n• Premium Geometric Logo\n• Improved 3D Coin Toss\n• Added Coin Faces (H/T)\n• Physics-based Coin Spin\n• E Button uses Camera & Holding"
local ChangelogTextPL = "• Aktualizacja V3.11!\n• Nowe Geometryczne Logo\n• Ulepszony Rzut Monetą 3D\n• Dodano awers/rewers (H/T)\n• Fizyka rzutu monetą"
local ChangelogTextRU = "• Обновление V3.11!\n• Премиум Логотип\n• Улучшенный 3D Бросок Монеты\n• Добавлены Орел/Решка (H/T)\n• Физика броска монеты"
local ChangelogTextES = "• ¡Actualización V3.11!\n• Logo Geométrico Premium\n• Mejorado Lanzamiento 3D\n• Caras de moneda (H/T)\n• Físicas de lanzamiento"

local Translations = {
    ["Features"] = {EN = "Features", PL = "Funkcje", RU = "Функции", ES = "Funciones"},
    ["Fun"] = {EN = "Fun", PL = "Zabawa", RU = "Веселье", ES = "Diversión"},
    ["Settings"] = {EN = "Settings", PL = "Ustawienia", RU = "Настройки", ES = "Ajustes"},
    ["Movement / Player"] = {EN = "Movement / Player", PL = "Ruch / Gracz", RU = "Движение / Игрок", ES = "Movimiento / Jugador"},
    ["Flight"] = {EN = "Flight", PL = "Lot", RU = "Полет", ES = "Vuelo"},
    ["Fly Speed"] = {EN = "Fly Speed", PL = "Szybkość Lotu", RU = "Скорость полета", ES = "Velocidad de Vuelo"},
    ["Enable Custom Speed"] = {EN = "Enable Custom Speed", PL = "Włącz Własną Prędkość", RU = "Своя скорость", ES = "Activar Velocidad Personalizada"},
    ["WalkSpeed Value"] = {EN = "WalkSpeed Value", PL = "Prędkość Chodzenia", RU = "Значение скорости", ES = "Valor de Velocidad"},
    ["Noclip"] = {EN = "Noclip", PL = "Przenikanie", RU = "Сквозь стены (Noclip)", ES = "Traspasar Paredes"},
    ["Open Player Manager"] = {EN = "Open Player Manager", PL = "Otwórz Menedżer Graczy", RU = "Открыть Менеджер Игроков", ES = "Abrir Gestor de Jugadores"},
    ["Player Manager"] = {EN = "Player Manager", PL = "Menedżer Graczy", RU = "Менеджер Игроков", ES = "Gestor de Jugadores"},
    ["Teleport"] = {EN = "Teleport", PL = "Teleport", RU = "Телепорт", ES = "Teletransportar"},
    ["Spectate"] = {EN = "Spectate", PL = "Obserwuj", RU = "Наблюдать", ES = "Espectar"},
    ["Stop Spectating"] = {EN = "Stop Spectating", PL = "Przestań Obs.", RU = "Перестать набл.", ES = "Dejar de Espectar"},
    ["Copy Username"] = {EN = "Copy Username", PL = "Kopiuj Nazwę", RU = "Скоп. Имя", ES = "Copiar Usuario"},
    ["Selected: None"] = {EN = "Selected: None", PL = "Wybrano: Brak", RU = "Выбрано: Ничего", ES = "Seleccionado: Ninguno"},
    ["Search Display Name..."] = {EN = "Search Display Name...", PL = "Szukaj nazwy...", RU = "Поиск по имени...", ES = "Buscar nombre..."},
    ["Instant Prompt"] = {EN = "Instant Prompt", PL = "Szybka Interakcja", RU = "Мгновенное действие", ES = "Interacción Instantánea"},
    ["Prompt Reach"] = {EN = "Prompt Reach", PL = "Zasięg Interakcji", RU = "Дальность действия", ES = "Alcance de interacción"},
    ["Prompt Button"] = {EN = "Prompt Button", PL = "Przycisk Interakcji", RU = "Кнопка действия", ES = "Botón de Interacción"},
    ["Lock Button"] = {EN = "Lock Button", PL = "Zablokuj Przycisk", RU = "Заблокировать кнопку", ES = "Bloquear Botón"},
    ["Max 100 studs"] = {EN = "Max 100 studs", PL = "Maks. 100 studów", RU = "Макс 100 стадов", ES = "Máximo 100 studs"},
    ["Visuals / ESP"] = {EN = "Visuals / ESP", PL = "Wizualne / ESP", RU = "Визуал / ESP", ES = "Visuales / ESP"},
    ["Fullbright"] = {EN = "Fullbright", PL = "Full Jasność", RU = "Полная яркость", ES = "Brillo Total"},
    ["Player ESP"] = {EN = "Player ESP", PL = "ESP Graczy", RU = "ESP Игроков", ES = "ESP de Jugadores"},
    ["NPC ESP"] = {EN = "NPC ESP", PL = "NPC ESP", RU = "ESP NPC", ES = "ESP de NPC"},
    ["Show Names"] = {EN = "Show Names", PL = "Pokaż Nazwy", RU = "Показывать имена", ES = "Mostrar Nombres"},
    ["Interactables ESP"] = {EN = "Interactables ESP", PL = "ESP Interakcji", RU = "ESP Предметов", ES = "ESP de Interactuables"},
    ["Show Int. Names"] = {EN = "Show Int. Names", PL = "Pokaż Nazwy Int.", RU = "Имена предметов", ES = "Mostrar Nombres Int."},
    ["General Setup"] = {EN = "General Setup", PL = "Główne Ustawienia", RU = "Общие настройки", ES = "Configuración General"},
    ["UI Scale"] = {EN = "UI Scale", PL = "Skala UI", RU = "Масштаб UI", ES = "Escala de UI"},
    ["Inner UI Outlines"] = {EN = "Inner UI Outlines", PL = "Wewnętrzne Kontury", RU = "Внутренние контуры", ES = "Bordes Internos"},
    ["Language: "] = {EN = "Language: EN", PL = "Język: PL", RU = "Язык: RU", ES = "Idioma: ES"},
    ["Color Presets & Themes"] = {EN = "Color Presets & Themes", PL = "Kolory i Motywy", RU = "Цвета и Темы", ES = "Temas y Colores"},
    ["Purple (Default)"] = {EN = "Purple (Default)", PL = "Fioletowy (Domyślny)", RU = "Фиолетовый (По умолч.)", ES = "Morado (Preder.)"},
    ["Orange"] = {EN = "Orange", PL = "Pomarańczowy", RU = "Оранжевый", ES = "Naranja"},
    ["Brown"] = {EN = "Brown", PL = "Brązowy", RU = "Коричневый", ES = "Marrón"},
    ["Yellow"] = {EN = "Yellow", PL = "Żółty", RU = "Желтый", ES = "Amarillo"},
    ["Blue"] = {EN = "Blue", PL = "Niebieski", RU = "Синий", ES = "Azul"},
    ["Red"] = {EN = "Red", PL = "Czerwony", RU = "Красный", ES = "Rojo"},
    ["Green"] = {EN = "Green", PL = "Zielony", RU = "Зеленый", ES = "Verde"},
    ["White"] = {EN = "White", PL = "Biały", RU = "Белый", ES = "Blanco"},
    ["Custom RGB"] = {EN = "Custom RGB", PL = "Własne RGB", RU = "Свой RGB", ES = "RGB Personalizado"},
    ["Poland"] = {EN = "Poland", PL = "Polska", RU = "Польша", ES = "Polonia"},
    ["Danger Zone"] = {EN = "Danger Zone", PL = "Strefa Zagrożenia", RU = "Опасная Зона", ES = "Zona Peligrosa"},
    ["Destroy Everything & UI"] = {EN = "Destroy Everything & UI", PL = "Usuń Skrypt i UI", RU = "Удалить всё и UI", ES = "Destruir Todo y UI"},
    ["About"] = {EN = "About", PL = "O Skrypcie", RU = "О скрипте", ES = "Acerca de"},
    ["Details"] = {EN = "Details", PL = "Szczegóły", RU = "Детали", ES = "Detalles"},
    ["ON"] = {EN = "ON", PL = "WŁ", RU = "ВКЛ", ES = "ENC"},
    ["OFF"] = {EN = "OFF", PL = "WYŁ", RU = "ВЫКЛ", ES = "APAG"},
    ["Wrong Format"] = {EN = "Wrong Format", PL = "Zły Format", RU = "Неверный формат", ES = "Formato Incorrecto"},
    ["Copied to Clipboard"] = {EN = "Copied to Clipboard", PL = "Skopiowano!", RU = "Скопировано!", ES = "¡Copiado!"},
    ["Toss Coin"] = {EN = "Toss Coin", PL = "Rzuć Monetą", RU = "Бросить Монету", ES = "Lanzar Moneda"},
    ["Flipping..."] = {EN = "Flipping...", PL = "Rzucanie...", RU = "Бросаем...", ES = "Lanzando..."},
    ["Heads!"] = {EN = "Heads!", PL = "Orzeł!", RU = "Орел!", ES = "¡Cara!"},
    ["Tails!"] = {EN = "Tails!", PL = "Reszka!", RU = "Решка!", ES = "¡Cruz!"},
    ["3D Coin Toss"] = {EN = "3D Coin Toss", PL = "Rzut Monetą 3D", RU = "3D Бросок Монеты", ES = "Lanzamiento Moneda 3D"},
    ["Changelog"] = {EN = ChangelogTextEN, PL = ChangelogTextPL, RU = ChangelogTextRU, ES = ChangelogTextES}
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
            if item.key == "Language: " then
                item.obj.Text = getTranslation(item.key)
            else
                item.obj.Text = item.isSection and ("-- " .. getTranslation(item.key) .. " --") or getTranslation(item.key)
            end
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
NotifContainer.Size = UDim2.new(0, 260, 1, -20)
NotifContainer.Position = UDim2.new(1, -270, 0, 10)
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
    NoteFrame.Size = UDim2.new(0, 250, 0, 50)
    NoteFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    NoteFrame.BackgroundTransparency = 1 
    
    local NoteCorner = Instance.new("UICorner") NoteCorner.CornerRadius = UDim.new(0, 6) NoteCorner.Parent = NoteFrame
    
    local NoteStroke = Instance.new("UIStroke")
    NoteStroke.Color = isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor
    NoteStroke.Thickness = isPolandMode and 2 or 1
    NoteStroke.Transparency = 1
    NoteStroke.Parent = NoteFrame
    
    local Deco = Instance.new("TextLabel")
    Deco.Size = UDim2.new(0, 20, 0, 20)
    Deco.Position = UDim2.new(0, 10, 0, 15)
    Deco.BackgroundTransparency = 1
    Deco.Text = "✧"
    Deco.TextColor3 = isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor
    Deco.Font = Enum.Font.GothamBold
    Deco.TextSize = 16
    Deco.TextTransparency = 1
    Deco.Parent = NoteFrame

    local NoteLabel = Instance.new("TextLabel")
    NoteLabel.Size = UDim2.new(1, -40, 1, -12)
    NoteLabel.Position = UDim2.new(0, 35, 0, 5)
    NoteLabel.BackgroundTransparency = 1
    NoteLabel.Text = message
    NoteLabel.TextColor3 = isPolandMode and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
    NoteLabel.Font = Enum.Font.SourceSansBold
    NoteLabel.TextSize = 14
    NoteLabel.TextWrapped = true
    NoteLabel.TextXAlignment = Enum.TextXAlignment.Left
    NoteLabel.TextTransparency = 1
    NoteLabel.Parent = NoteFrame

    local BarBG = Instance.new("Frame")
    BarBG.Size = UDim2.new(1, -10, 0, 2)
    BarBG.Position = UDim2.new(0, 5, 1, -5)
    BarBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    BarBG.BorderSizePixel = 0
    BarBG.BackgroundTransparency = 1
    BarBG.Parent = NoteFrame

    local BarFill = Instance.new("Frame")
    BarFill.Size = UDim2.new(1, 0, 1, 0)
    BarFill.BackgroundColor3 = isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor
    BarFill.BorderSizePixel = 0
    BarFill.BackgroundTransparency = 1
    BarFill.Parent = BarBG
    
    if isPolandMode then NoteFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255) end
    NoteFrame.Parent = NotifContainer
    
    TweenService:Create(NoteFrame, TweenInfo.new(0.4), {BackgroundTransparency = isPolandMode and 0.1 or 0.4}):Play()
    TweenService:Create(NoteStroke, TweenInfo.new(0.4), {Transparency = 0}):Play()
    TweenService:Create(Deco, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    TweenService:Create(NoteLabel, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    TweenService:Create(BarBG, TweenInfo.new(0.4), {BackgroundTransparency = 0.5}):Play()
    TweenService:Create(BarFill, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
    
    TweenService:Create(BarFill, TweenInfo.new(3.5, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()

    task.delay(3.5, function()
        local outTween = TweenService:Create(NoteFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1})
        TweenService:Create(NoteStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
        TweenService:Create(Deco, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(NoteLabel, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(BarBG, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TweenService:Create(BarFill, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
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

local OuterStrokes, InnerStrokes = {}, {}
local ThemeTexts, ThemeBackgrounds, ThemeUpdaters, ThemeFrames, ThemeSubFrames, DynamicTextElements = {}, {}, {}, {}, {}, {}
local ThemeInputBoxes, ThemeSecondaryBtns, ThemePresetBtns = {}, {}, {}
local InnerOutlinesEnabled = true

local function applyThemeOutline(guiObject, thickness, isOuter)
    local stroke = Instance.new("UIStroke")
    stroke.Color = ThemeColor
    stroke.Thickness = thickness or 1
    stroke:SetAttribute("OriginalThickness", stroke.Thickness)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = guiObject
    
    if isOuter then
        table.insert(OuterStrokes, stroke)
    else
        table.insert(InnerStrokes, stroke)
        stroke.Transparency = InnerOutlinesEnabled and 0 or 1
    end
    return stroke
end

local function updateInnerOutlines()
    for _, stroke in ipairs(InnerStrokes) do
        if stroke and stroke.Parent then stroke.Transparency = InnerOutlinesEnabled and 0 or 1 end
    end
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

-- V3.11 Premium Geometric UI Vortex Logo
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "eynzToggleBtn"
ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
ToggleBtn.Position = UDim2.new(0, 15, 0, 15)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(12, 10, 16)
ToggleBtn.Text = ""
ToggleBtn.ClipsDescendants = true
ToggleBtn.Active = true 
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner") 
ToggleCorner.CornerRadius = UDim.new(0, 16) 
ToggleCorner.Parent = ToggleBtn
local LauncherScale = Instance.new("UIScale", ToggleBtn)
applyThemeOutline(ToggleBtn, 1.5, true)

-- Constructing the premium structural geometry
local vortexLayers = 10
for i = 1, vortexLayers do
    local layer = Instance.new("Frame")
    local scale = 1.1 - (i * 0.1) -- Reduces size continuously towards center
    layer.Size = UDim2.new(scale, 0, scale, 0)
    layer.Position = UDim2.new(0.5, 0, 0.5, 0)
    layer.AnchorPoint = Vector2.new(0.5, 0.5)
    layer.Rotation = (i - 1) * 15
    layer.BorderSizePixel = 0
    
    if i % 2 == 1 then
        layer.BackgroundColor3 = ThemeColor
        table.insert(ThemeUpdaters, function(newColor)
            layer.BackgroundColor3 = newColor
        end)
    else
        layer.BackgroundColor3 = Color3.fromRGB(15, 12, 20)
    end
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.3, 0) -- Premium rounded squircle shapes
    corner.Parent = layer
    layer.Parent = ToggleBtn
end

local VortexCenterDot = Instance.new("Frame")
VortexCenterDot.Size = UDim2.new(0.12, 0, 0.12, 0)
VortexCenterDot.Position = UDim2.new(0.5, 0, 0.5, 0)
VortexCenterDot.AnchorPoint = Vector2.new(0.5, 0.5)
VortexCenterDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
local dotCorner = Instance.new("UICorner") dotCorner.CornerRadius = UDim.new(1, 0) dotCorner.Parent = VortexCenterDot
VortexCenterDot.Parent = ToggleBtn

-- Main UI Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 310, 0, 410)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainScale = Instance.new("UIScale", MainFrame)
MainScale.Scale = 0
local MainCorner = Instance.new("UICorner") MainCorner.CornerRadius = UDim.new(0, 10) MainCorner.Parent = MainFrame
applyThemeOutline(MainFrame, 1.5, true)

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
FeaturesTabBtn.Size = UDim2.new(0.333, 0, 1, 0)
FeaturesTabBtn.BackgroundTransparency = 1
FeaturesTabBtn.Text = "Features"
FeaturesTabBtn.TextColor3 = ThemeColor
FeaturesTabBtn.Font = Enum.Font.SourceSansBold
FeaturesTabBtn.TextSize = 14
FeaturesTabBtn.Parent = TabBar
table.insert(ThemeTexts, FeaturesTabBtn)
addTranslatable(FeaturesTabBtn, "Features")

local FunTabBtn = Instance.new("TextButton")
FunTabBtn.Size = UDim2.new(0.333, 0, 1, 0)
FunTabBtn.Position = UDim2.new(0.333, 0, 0, 0)
FunTabBtn.BackgroundTransparency = 1
FunTabBtn.Text = "Fun"
FunTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
FunTabBtn.Font = Enum.Font.SourceSansBold
FunTabBtn.TextSize = 14
FunTabBtn.Parent = TabBar
addTranslatable(FunTabBtn, "Fun")

local SettingsTabBtn = Instance.new("TextButton")
SettingsTabBtn.Size = UDim2.new(0.334, 0, 1, 0)
SettingsTabBtn.Position = UDim2.new(0.666, 0, 0, 0)
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
TitleText.Text = "eynz Hub | Mobile V3.11"
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
    TweenService:Create(MainScale, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0}):Play()
    task.delay(0.25, function()
        if MainScale.Scale == 0 then MainFrame.Visible = false end
    end)
end

local function openUI()
    MainFrame.Visible = true
    MainScale.Scale = 0
    TweenService:Create(MainScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = currentUIScale}):Play()
end

CloseBtn.MouseButton1Click:Connect(closeUI)
ToggleBtn.MouseButton1Click:Connect(function()
    if MainFrame.Visible and MainScale.Scale > 0.1 then closeUI() else openUI() end
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
local FunScroll = createScrollFrame()
local SettingsScroll = createScrollFrame()
FunScroll.Position = UDim2.new(1, 0, 0, 75)
FunScroll.Visible = false
SettingsScroll.Position = UDim2.new(1, 0, 0, 75)
SettingsScroll.Visible = false

local currentTab = FeaturesScroll

local function switchTab(tabName, scrollObj, btnObj)
    if currentTab == scrollObj then return end
    local activeCol = isPolandMode and Color3.fromRGB(255, 0, 0) or ThemeColor
    local inactiveCol = isPolandMode and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(150, 150, 150)
    
    TweenService:Create(currentTab, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, 0, 0, 75)}):Play()
    scrollObj.Position = UDim2.new(-1, 0, 0, 75)
    scrollObj.Visible = true
    TweenService:Create(scrollObj, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 75)}):Play()
    currentTab = scrollObj
    
    TweenService:Create(FeaturesTabBtn, TweenInfo.new(0.2), {TextColor3 = inactiveCol}):Play()
    TweenService:Create(FunTabBtn, TweenInfo.new(0.2), {TextColor3 = inactiveCol}):Play()
    TweenService:Create(SettingsTabBtn, TweenInfo.new(0.2), {TextColor3 = inactiveCol}):Play()
    TweenService:Create(btnObj, TweenInfo.new(0.2), {TextColor3 = activeCol}):Play()

    for i, v in ipairs(ThemeTexts) do
        if v == FeaturesTabBtn or v == FunTabBtn or v == SettingsTabBtn then table.remove(ThemeTexts, i) end
    end
    table.insert(ThemeTexts, btnObj)
end

FeaturesTabBtn.MouseButton1Click:Connect(function() switchTab("Features", FeaturesScroll, FeaturesTabBtn) end)
FunTabBtn.MouseButton1Click:Connect(function() switchTab("Fun", FunScroll, FunTabBtn) end)
SettingsTabBtn.MouseButton1Click:Connect(function() switchTab("Settings", SettingsScroll, SettingsTabBtn) end)

----------------------------------------------------
-- HELPER CREATION FUNCTIONS
----------------------------------------------------
local function createSection(textKey, parent)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Size = UDim2.new(1, 0, 0, 25)
    SectionFrame.BackgroundTransparency = 1
    SectionFrame.Parent = parent
    
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
    ToggleFrame.Parent = parent
    table.insert(ThemeFrames, ToggleFrame)
    local FrameCorner = Instance.new("UICorner") FrameCorner.CornerRadius = UDim.new(0, 6) FrameCorner.Parent = ToggleFrame
    applyThemeOutline(ToggleFrame, 1, false)

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
    applyThemeOutline(Button, 1, false)

    Button.Text = state and getTranslation("ON") or getTranslation("OFF")
    
    table.insert(statefulButtons, {
        btn = Button, getState = function() return state end,
        updateMode = function(isPoland)
            if not state then Button.BackgroundColor3 = isPoland and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(60, 60, 70) end
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
        if isPolandMode then Button.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 0, 0) end
        callback(state)
    end)
end

local function createExpandableToggle(textKey, parent, defaultState, mainCallback, subItemsConfig)
    local state = defaultState or false
    local expanded = false

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    ToggleFrame.Parent = parent
    table.insert(ThemeFrames, ToggleFrame)
    local FrameCorner = Instance.new("UICorner") FrameCorner.CornerRadius = UDim.new(0, 6) FrameCorner.Parent = ToggleFrame
    applyThemeOutline(ToggleFrame, 1, false)

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
    applyThemeOutline(ExpandBtn, 1, false)
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
    applyThemeOutline(Button, 1, false)
    Button.Text = state and getTranslation("ON") or getTranslation("OFF")
    
    table.insert(statefulButtons, {
        btn = Button, getState = function() return state end,
        updateMode = function(isPoland)
            if not state then Button.BackgroundColor3 = isPoland and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(60, 60, 70) end
        end
    })
    table.insert(ThemeUpdaters, function(newColor)
        if state then TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = newColor}):Play() end
    end)

    local ExpanderContainer = Instance.new("Frame")
    ExpanderContainer.Size = UDim2.new(1, 0, 0, 0)
    ExpanderContainer.BackgroundTransparency = 1
    ExpanderContainer.ClipsDescendants = true
    ExpanderContainer.Visible = false
    ExpanderContainer.Parent = parent

    local ContainerList = Instance.new("UIListLayout")
    ContainerList.SortOrder = Enum.SortOrder.LayoutOrder
    ContainerList.Padding = UDim.new(0, 4)
    ContainerList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContainerList.Parent = ExpanderContainer
    
    local ContPad = Instance.new("UIPadding")
    ContPad.PaddingTop = UDim.new(0, 4)
    ContPad.PaddingBottom = UDim.new(0, 4)
    ContPad.Parent = ExpanderContainer

    for _, subCfg in ipairs(subItemsConfig) do
        local subType = subCfg.type or "toggle"
        
        if subType == "toggle" then
            local subState = false
            local SubFrame = Instance.new("Frame")
            SubFrame.Size = UDim2.new(1, -8, 0, 35)
            SubFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            SubFrame.Parent = ExpanderContainer
            table.insert(ThemeSubFrames, SubFrame)
            local SubCorner = Instance.new("UICorner") SubCorner.CornerRadius = UDim.new(0, 6) SubCorner.Parent = SubFrame
            applyThemeOutline(SubFrame, 1, false)

            local SubLabel = Instance.new("TextLabel")
            SubLabel.Size = UDim2.new(0.6, 0, 1, 0)
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
            SubBtn.Position = UDim2.new(1, -55, 0.5, -10)
            SubBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            SubBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            SubBtn.Font = Enum.Font.SourceSansBold
            SubBtn.TextSize = 11
            SubBtn.Parent = SubFrame
            local SubBtnCorner = Instance.new("UICorner") SubBtnCorner.CornerRadius = UDim.new(0, 6) SubBtnCorner.Parent = SubBtn
            applyThemeOutline(SubBtn, 1, false)

            SubBtn.Text = subState and getTranslation("ON") or getTranslation("OFF")
            table.insert(statefulButtons, {
                btn = SubBtn, getState = function() return subState end,
                updateMode = function(isPoland)
                    if not subState then SubBtn.BackgroundColor3 = isPoland and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(60, 60, 70) end
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
            
        elseif subType == "input" then
            local SubRow = Instance.new("Frame")
            SubRow.Size = UDim2.new(1, -8, 0, 35)
            SubRow.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            SubRow.Parent = ExpanderContainer
            table.insert(ThemeSubFrames, SubRow)
            local SubCorner = Instance.new("UICorner") SubCorner.CornerRadius = UDim.new(0, 6) SubCorner.Parent = SubRow
            applyThemeOutline(SubRow, 1, false)

            local SubLabel = Instance.new("TextLabel")
            SubLabel.Size = UDim2.new(0.5, 0, 1, 0)
            SubLabel.Position = UDim2.new(0, 10, 0, 0)
            SubLabel.BackgroundTransparency = 1
            SubLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            SubLabel.TextSize = 13
            SubLabel.Font = Enum.Font.SourceSansSemibold
            SubLabel.TextXAlignment = Enum.TextXAlignment.Left
            SubLabel.Parent = SubRow
            addTranslatable(SubLabel, subCfg.text)
            registerDynamicText(SubLabel)

            local InputBox = Instance.new("TextBox")
            InputBox.Size = UDim2.new(0, 80, 0, 22)
            InputBox.Position = UDim2.new(1, -90, 0.5, -11)
            InputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
            InputBox.Text = tostring(subCfg.defaultVal)
            InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            InputBox.Font = Enum.Font.SourceSansBold
            InputBox.TextSize = 12
            InputBox.Parent = SubRow
            local BoxCorner = Instance.new("UICorner") BoxCorner.CornerRadius = UDim.new(0, 6) BoxCorner.Parent = InputBox
            applyThemeOutline(InputBox, 1, false)
            table.insert(ThemeInputBoxes, InputBox)

            InputBox.FocusLost:Connect(function() subCfg.callback(InputBox.Text) end)
        end
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

        if expanded then
            ExpanderContainer.Visible = true
            local targetHeight = ContainerList.AbsoluteContentSize.Y + 8
            TweenService:Create(ExpanderContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
        else
            local tw = TweenService:Create(ExpanderContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
            tw:Play()
            task.delay(0.25, function() if not expanded then ExpanderContainer.Visible = false end end)
        end
    end)
end

local function createSlider(labelText, parent, min, max, defaultVal, callback)
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(1, 0, 0, 50)
    RowFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    RowFrame.Parent = parent
    table.insert(ThemeFrames, RowFrame)
    applyThemeOutline(RowFrame, 1, false)
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = false end
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
    BtnFrame.Parent = parent

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundColor3 = colorTheme or Color3.fromRGB(45, 45, 55)
    if not colorTheme then table.insert(ThemeFrames, Btn) end
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 14
    Btn.Parent = BtnFrame
    local BtnCorner = Instance.new("UICorner") BtnCorner.CornerRadius = UDim.new(0, 6) BtnCorner.Parent = Btn
    applyThemeOutline(Btn, 1, false)

    addTranslatable(Btn, textKey)
    if not colorTheme then registerDynamicText(Btn) end

    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

local function createInputRow(labelText, parent, defaultVal, callback)
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(1, 0, 0, 40)
    RowFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    RowFrame.Parent = parent
    table.insert(ThemeFrames, RowFrame)
    local FrameCorner = Instance.new("UICorner") FrameCorner.CornerRadius = UDim.new(0, 6) FrameCorner.Parent = RowFrame
    applyThemeOutline(RowFrame, 1, false)

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
    applyThemeOutline(InputBox, 1, false)
    table.insert(ThemeInputBoxes, InputBox)

    InputBox.FocusLost:Connect(function() callback(InputBox.Text) end)
end

----------------------------------------------------
-- THEMES & PRESETS
----------------------------------------------------
local function setPolandMode(state)
    isPolandMode = state
    if state then
        MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TitleBar.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
        TabBar.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
        TitleText.TextColor3 = Color3.fromRGB(20, 20, 20)
        FeaturesTabBtn.TextColor3 = currentTab == FeaturesScroll and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(100, 100, 100)
        FunTabBtn.TextColor3 = currentTab == FunScroll and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(100, 100, 100)
        SettingsTabBtn.TextColor3 = currentTab == SettingsScroll and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(100, 100, 100)
        
        for _, stroke in ipairs(OuterStrokes) do stroke.Color = Color3.fromRGB(255, 0, 0) end
        for _, stroke in ipairs(InnerStrokes) do stroke.Color = Color3.fromRGB(255, 0, 0) end

        for _, frm in ipairs(ThemeFrames) do if frm and frm.Parent then frm.BackgroundColor3 = Color3.fromRGB(240, 240, 240) end end
        for _, frm in ipairs(ThemeSubFrames) do if frm and frm.Parent then frm.BackgroundColor3 = Color3.fromRGB(220, 220, 220) end end
        for _, box in ipairs(ThemeInputBoxes) do if box and box.Parent then box.BackgroundColor3 = Color3.fromRGB(220, 220, 220) box.TextColor3 = Color3.fromRGB(20, 20, 20) end end
        for _, btn in ipairs(ThemeSecondaryBtns) do if btn and btn.Parent then btn.BackgroundColor3 = Color3.fromRGB(210, 210, 210) btn.TextColor3 = Color3.fromRGB(20, 20, 20) end end
        for _, pBtn in ipairs(ThemePresetBtns) do if pBtn and pBtn.Parent then pBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 230) end end
        for _, txt in ipairs(ThemeTexts) do if txt and txt.Parent and txt.Name ~= "TitleText" then txt.TextColor3 = Color3.fromRGB(255, 0, 0) end end
        for _, bg in ipairs(ThemeBackgrounds) do if bg and bg.Parent then bg.BackgroundColor3 = Color3.fromRGB(255, 0, 0) end end
        for _, v in ipairs(DynamicTextElements) do if v and v.Parent then v.TextColor3 = Color3.fromRGB(255, 0, 0) end end
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
        TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
        FeaturesTabBtn.TextColor3 = currentTab == FeaturesScroll and ThemeColor or Color3.fromRGB(150, 150, 150)
        FunTabBtn.TextColor3 = currentTab == FunScroll and ThemeColor or Color3.fromRGB(150, 150, 150)
        SettingsTabBtn.TextColor3 = currentTab == SettingsScroll and ThemeColor or Color3.fromRGB(150, 150, 150)
        
        for _, stroke in ipairs(OuterStrokes) do stroke.Color = ThemeColor end
        for _, stroke in ipairs(InnerStrokes) do stroke.Color = ThemeColor end

        for _, frm in ipairs(ThemeFrames) do if frm and frm.Parent then frm.BackgroundColor3 = Color3.fromRGB(45, 45, 55) end end
        for _, frm in ipairs(ThemeSubFrames) do if frm and frm.Parent then frm.BackgroundColor3 = Color3.fromRGB(35, 35, 45) end end
        for _, box in ipairs(ThemeInputBoxes) do if box and box.Parent then box.BackgroundColor3 = Color3.fromRGB(20, 20, 26) box.TextColor3 = Color3.fromRGB(255, 255, 255) end end
        for _, btn in ipairs(ThemeSecondaryBtns) do if btn and btn.Parent then btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50) btn.TextColor3 = Color3.fromRGB(255, 255, 255) end end
        for _, pBtn in ipairs(ThemePresetBtns) do if pBtn and pBtn.Parent then pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50) end end
        for _, txt in ipairs(ThemeTexts) do if txt and txt.Parent and txt.Name ~= "TitleText" then txt.TextColor3 = ThemeColor end end
        for _, bg in ipairs(ThemeBackgrounds) do if bg and bg.Parent then bg.BackgroundColor3 = ThemeColor end end
        for _, v in ipairs(DynamicTextElements) do
            if v and v.Parent then local orig = v:GetAttribute("OrigColor") if orig then v.TextColor3 = orig end end
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
    for _, stroke in ipairs(OuterStrokes) do if stroke and stroke.Parent then TweenService:Create(stroke, TweenInfo.new(0.3), {Color = color}):Play() end end
    for _, stroke in ipairs(InnerStrokes) do if stroke and stroke.Parent then TweenService:Create(stroke, TweenInfo.new(0.3), {Color = color}):Play() end end
    for _, txt in ipairs(ThemeTexts) do if txt and txt.Parent and txt.Name ~= "TitleText" then TweenService:Create(txt, TweenInfo.new(0.3), {TextColor3 = color}):Play() end end
    for _, bg in ipairs(ThemeBackgrounds) do if bg and bg.Parent then TweenService:Create(bg, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play() end end
    for _, func in ipairs(ThemeUpdaters) do func(color) end
end

local function createColorPresetsRow(parent)
    local expanded = false
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(1, 0, 0, 40)
    RowFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    RowFrame.Parent = parent
    table.insert(ThemeFrames, RowFrame)
    applyThemeOutline(RowFrame, 1, false)
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
    applyThemeOutline(ExpandBtn, 1, false)
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
    applyThemeOutline(SubContainer, 1, false)
    
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
        applyThemeOutline(Btn, 1, false)
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
    addTranslatable(PolandBtn, "Poland")
    
    local polStroke = Instance.new("UIStroke")
    polStroke.Color = Color3.fromRGB(255, 0, 0)
    polStroke.Thickness = 1.5
    polStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    polStroke.Parent = PolandBtn
    
    PolandBtn.MouseButton1Click:Connect(function() setPolandMode(true) end)
    
    local CustomRGBRow = Instance.new("Frame")
    CustomRGBRow.Size = UDim2.new(1, -12, 0, 30)
    CustomRGBRow.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    CustomRGBRow.Parent = SubContainer
    table.insert(ThemeFrames, CustomRGBRow)
    local CRGBCorner = Instance.new("UICorner") CRGBCorner.CornerRadius = UDim.new(0, 6) CRGBCorner.Parent = CustomRGBRow
    applyThemeOutline(CustomRGBRow, 1, false)
    
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
    applyThemeOutline(InputBox, 1, false)
    table.insert(ThemeInputBoxes, InputBox)
    
    InputBox.FocusLost:Connect(function()
        local r, g, b = InputBox.Text:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
        if r and g and b then updateThemeColor(Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b)))
        else ShowNotification(getTranslation("Wrong Format")) end
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

----------------------------------------------------
-- PLAYER MANAGER WINDOW (V3.11)
----------------------------------------------------
local PlayerManagerWindow = Instance.new("Frame")
PlayerManagerWindow.Name = "PlayerManagerWindow"
PlayerManagerWindow.AnchorPoint = Vector2.new(0.5, 0.5)
PlayerManagerWindow.Size = UDim2.new(0, 420, 0, 260)
PlayerManagerWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
PlayerManagerWindow.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
PlayerManagerWindow.BackgroundTransparency = 0.15
PlayerManagerWindow.Visible = false
PlayerManagerWindow.Active = true
PlayerManagerWindow.Parent = ScreenGui

local WinCorner = Instance.new("UICorner") WinCorner.CornerRadius = UDim.new(0, 10) WinCorner.Parent = PlayerManagerWindow
applyThemeOutline(PlayerManagerWindow, 1.5, true)

local WinTitle = Instance.new("Frame")
WinTitle.Size = UDim2.new(1, 0, 0, 35)
WinTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
WinTitle.BackgroundTransparency = 0.15
WinTitle.Active = true
WinTitle.Parent = PlayerManagerWindow
local WinTitleCorner = Instance.new("UICorner") WinTitleCorner.CornerRadius = UDim.new(0, 10) WinTitleCorner.Parent = WinTitle
makeDraggable(PlayerManagerWindow, WinTitle)

local WinTitleTxt = Instance.new("TextLabel")
WinTitleTxt.Size = UDim2.new(1, -40, 1, 0)
WinTitleTxt.Position = UDim2.new(0, 12, 0, 0)
WinTitleTxt.BackgroundTransparency = 1
WinTitleTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
WinTitleTxt.TextSize = 14
WinTitleTxt.Font = Enum.Font.SourceSansBold
WinTitleTxt.TextXAlignment = Enum.TextXAlignment.Left
WinTitleTxt.Parent = WinTitle
addTranslatable(WinTitleTxt, "Player Manager")

local WinClose = Instance.new("TextButton")
WinClose.Size = UDim2.new(0, 25, 0, 25)
WinClose.Position = UDim2.new(1, -30, 0, 5)
WinClose.BackgroundTransparency = 1
WinClose.Text = "X"
WinClose.TextColor3 = Color3.fromRGB(255, 80, 80)
WinClose.TextSize = 14
WinClose.Font = Enum.Font.SourceSansBold
WinClose.Parent = WinTitle
WinClose.MouseButton1Click:Connect(function() PlayerManagerWindow.Visible = false end)

local WinLeft = Instance.new("Frame")
WinLeft.Size = UDim2.new(0.5, -5, 1, -45)
WinLeft.Position = UDim2.new(0, 5, 0, 40)
WinLeft.BackgroundTransparency = 1
WinLeft.Parent = PlayerManagerWindow

local WinSearch = Instance.new("TextBox")
WinSearch.Size = UDim2.new(1, 0, 0, 26)
WinSearch.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
WinSearch.BackgroundTransparency = 0.2
WinSearch.Text = ""
WinSearch.TextColor3 = Color3.fromRGB(255, 255, 255)
WinSearch.Font = Enum.Font.SourceSans
WinSearch.TextSize = 13
WinSearch.Parent = WinLeft
local WSrcCorner = Instance.new("UICorner") WSrcCorner.CornerRadius = UDim.new(0, 6) WSrcCorner.Parent = WinSearch
applyThemeOutline(WinSearch, 1, false)

local WinScroll = Instance.new("ScrollingFrame")
WinScroll.Size = UDim2.new(1, 0, 1, -30)
WinScroll.Position = UDim2.new(0, 0, 0, 30)
WinScroll.BackgroundTransparency = 1
WinScroll.ScrollBarThickness = 3
WinScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
WinScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
WinScroll.Parent = WinLeft
local WinList = Instance.new("UIListLayout")
WinList.Padding = UDim.new(0, 4)
WinList.SortOrder = Enum.SortOrder.LayoutOrder
WinList.Parent = WinScroll

local WinRight = Instance.new("Frame")
WinRight.Size = UDim2.new(0.5, -10, 1, -45)
WinRight.Position = UDim2.new(0.5, 5, 0, 40)
WinRight.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
WinRight.BackgroundTransparency = 0.3
WinRight.Parent = PlayerManagerWindow
local WRCorner = Instance.new("UICorner") WRCorner.CornerRadius = UDim.new(0, 6) WRCorner.Parent = WinRight
applyThemeOutline(WinRight, 1, false)

local WinAvatar = Instance.new("ImageLabel")
WinAvatar.Size = UDim2.new(0, 80, 0, 80)
WinAvatar.Position = UDim2.new(0.5, -40, 0, 15)
WinAvatar.BackgroundTransparency = 1
WinAvatar.Image = ""
WinAvatar.Parent = WinRight
local WAvCorner = Instance.new("UICorner") WAvCorner.CornerRadius = UDim.new(1, 0) WAvCorner.Parent = WinAvatar

local WinName = Instance.new("TextLabel")
WinName.Size = UDim2.new(1, -10, 0, 20)
WinName.Position = UDim2.new(0, 5, 0, 100) 
WinName.BackgroundTransparency = 1
WinName.TextColor3 = Color3.fromRGB(240, 240, 240)
WinName.TextSize = 13
WinName.Font = Enum.Font.SourceSansBold
WinName.TextTruncate = Enum.TextTruncate.AtEnd
WinName.Parent = WinRight
addTranslatable(WinName, "Selected: None")

local WinBtnTP = Instance.new("TextButton")
WinBtnTP.Size = UDim2.new(1, -20, 0, 24)
WinBtnTP.Position = UDim2.new(0, 10, 0, 125)
WinBtnTP.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
WinBtnTP.TextColor3 = Color3.fromRGB(255, 255, 255)
WinBtnTP.Font = Enum.Font.SourceSansBold
WinBtnTP.TextSize = 13
WinBtnTP.Parent = WinRight
local WBtnTPCorner = Instance.new("UICorner") WBtnTPCorner.CornerRadius = UDim.new(0, 4) WBtnTPCorner.Parent = WinBtnTP
applyThemeOutline(WinBtnTP, 1, false)
addTranslatable(WinBtnTP, "Teleport")

local WinBtnSpec = Instance.new("TextButton")
WinBtnSpec.Size = UDim2.new(1, -20, 0, 24)
WinBtnSpec.Position = UDim2.new(0, 10, 0, 155)
WinBtnSpec.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
WinBtnSpec.TextColor3 = Color3.fromRGB(255, 255, 255)
WinBtnSpec.Font = Enum.Font.SourceSansBold
WinBtnSpec.TextSize = 13
WinBtnSpec.Parent = WinRight
local WBtnSpecCorner = Instance.new("UICorner") WBtnSpecCorner.CornerRadius = UDim.new(0, 4) WBtnSpecCorner.Parent = WinBtnSpec
applyThemeOutline(WinBtnSpec, 1, false)
addTranslatable(WinBtnSpec, "Spectate")

local WinBtnCopy = Instance.new("TextButton")
WinBtnCopy.Size = UDim2.new(1, -20, 0, 24)
WinBtnCopy.Position = UDim2.new(0, 10, 0, 185)
WinBtnCopy.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
WinBtnCopy.TextColor3 = Color3.fromRGB(255, 255, 255)
WinBtnCopy.Font = Enum.Font.SourceSansBold
WinBtnCopy.TextSize = 13
WinBtnCopy.Parent = WinRight
local WBtnCopyCorner = Instance.new("UICorner") WBtnCopyCorner.CornerRadius = UDim.new(0, 4) WBtnCopyCorner.Parent = WinBtnCopy
applyThemeOutline(WinBtnCopy, 1, false)
addTranslatable(WinBtnCopy, "Copy Username")

local selectedWinPlayer = nil
local isSpectating = false
local selectedPlayerConn = nil

local managerHighlight = Instance.new("Highlight")
managerHighlight.Name = "eynzManagerHighlight"
managerHighlight.FillColor = ThemeColor
managerHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
managerHighlight.FillTransparency = 0.4
managerHighlight.OutlineTransparency = 0
table.insert(ThemeUpdaters, function(color) managerHighlight.FillColor = color end)

local function applyManagerESP()
    if selectedWinPlayer and selectedWinPlayer.Character then
        managerHighlight.Adornee = selectedWinPlayer.Character
        managerHighlight.Parent = selectedWinPlayer.Character
    else
        managerHighlight.Adornee = nil
        managerHighlight.Parent = nil
    end
end

local function refreshWinDisplay()
    if selectedWinPlayer and selectedWinPlayer.Parent then
        WinName.Text = selectedWinPlayer.DisplayName .. " (@" .. selectedWinPlayer.Name .. ")"
        task.spawn(function()
            local content, isReady = Players:GetUserThumbnailAsync(selectedWinPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            if isReady and selectedWinPlayer then WinAvatar.Image = content end
        end)
    else
        WinName.Text = getTranslation("Selected: None")
        WinAvatar.Image = ""
        isSpectating = false
        workspace.CurrentCamera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        WinBtnSpec.Text = getTranslation("Spectate")
    end
    
    applyManagerESP()
    if selectedPlayerConn then selectedPlayerConn:Disconnect() end
    if selectedWinPlayer then
        selectedPlayerConn = selectedWinPlayer.CharacterAdded:Connect(function(char)
            task.wait(0.2)
            applyManagerESP()
        end)
    end
end

local function populateWinList()
    for _, child in ipairs(WinScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local filter = string.lower(WinSearch.Text)
    local btnBg = isPolandMode and Color3.fromRGB(230, 230, 230) or Color3.fromRGB(45, 45, 55)
    local btnTxt = isPolandMode and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(220, 220, 220)
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local dName = string.lower(p.DisplayName)
            if filter == "" or string.sub(dName, 1, #filter) == filter then
                local pBtn = Instance.new("TextButton")
                pBtn.Size = UDim2.new(1, -8, 0, 26)
                pBtn.BackgroundColor3 = btnBg
                pBtn.BackgroundTransparency = 0.2
                pBtn.Text = "  " .. p.DisplayName
                pBtn.TextColor3 = btnTxt
                pBtn.Font = Enum.Font.SourceSansSemibold
                pBtn.TextSize = 13
                pBtn.TextXAlignment = Enum.TextXAlignment.Left
                pBtn.Parent = WinScroll
                local pCorner = Instance.new("UICorner") pCorner.CornerRadius = UDim.new(0, 4) pCorner.Parent = pBtn
                pBtn.MouseButton1Click:Connect(function()
                    selectedWinPlayer = p
                    refreshWinDisplay()
                end)
            end
        end
    end
end

WinSearch:GetPropertyChangedSignal("Text"):Connect(populateWinList)
table.insert(ActiveConnections, Players.PlayerAdded:Connect(function(p) if PlayerManagerWindow.Visible then populateWinList() end end))
table.insert(ActiveConnections, Players.PlayerRemoving:Connect(function(p)
    if selectedWinPlayer == p then selectedWinPlayer = nil refreshWinDisplay() end
    if PlayerManagerWindow.Visible then populateWinList() end
end))

WinBtnTP.MouseButton1Click:Connect(function()
    if selectedWinPlayer and selectedWinPlayer.Character and selectedWinPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = selectedWinPlayer.Character.HumanoidRootPart.CFrame
        end
    end
end)

WinBtnSpec.MouseButton1Click:Connect(function()
    if not selectedWinPlayer then return end
    isSpectating = not isSpectating
    if isSpectating then
        if selectedWinPlayer.Character and selectedWinPlayer.Character:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = selectedWinPlayer.Character.Humanoid
            WinBtnSpec.Text = getTranslation("Stop Spectating")
        else
            isSpectating = false
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
        end
        WinBtnSpec.Text = getTranslation("Spectate")
    end
end)

WinBtnCopy.MouseButton1Click:Connect(function()
    if selectedWinPlayer then
        pcall(function() setclipboard(selectedWinPlayer.Name) end)
        ShowNotification(getTranslation("Copied to Clipboard"))
    end
end)

table.insert(TranslationUpdaters, function()
    WinSearch.PlaceholderText = getTranslation("Search Display Name...")
    if not selectedWinPlayer then WinName.Text = getTranslation("Selected: None") end
    if not isSpectating then WinBtnSpec.Text = getTranslation("Spectate") else WinBtnSpec.Text = getTranslation("Stop Spectating") end
end)

----------------------------------------------------
-- PROMPT BUTTON GUI ("E") - Camera Distance & Hold
----------------------------------------------------
local PromptBtnGui = Instance.new("ScreenGui")
PromptBtnGui.Name = "eynzPromptButton"
PromptBtnGui.ResetOnSpawn = false
PromptBtnGui.Parent = ParentGui

local PromptBtnFrame = Instance.new("Frame")
PromptBtnFrame.Size = UDim2.new(0, 50, 0, 50)
PromptBtnFrame.Position = UDim2.new(0.5, 100, 0.5, 0)
PromptBtnFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
PromptBtnFrame.Active = true
PromptBtnFrame.Visible = false
PromptBtnFrame.Parent = PromptBtnGui
local PBtnCorner = Instance.new("UICorner") PBtnCorner.CornerRadius = UDim.new(1, 0) PBtnCorner.Parent = PromptBtnFrame
applyThemeOutline(PromptBtnFrame, 1.5, true)

local PromptBtnLabel = Instance.new("TextLabel")
PromptBtnLabel.Size = UDim2.new(1, 0, 1, 0)
PromptBtnLabel.BackgroundTransparency = 1
PromptBtnLabel.Text = "E"
PromptBtnLabel.TextColor3 = ThemeColor
PromptBtnLabel.Font = Enum.Font.GothamBlack
PromptBtnLabel.TextSize = 24
PromptBtnLabel.Parent = PromptBtnFrame
table.insert(ThemeTexts, PromptBtnLabel)

local pbDragging = false
local pbDragStart, pbStartPos
local currentHeldPrompt = nil

local function getClosestPromptToCamera(reach)
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local camPos = cam.CFrame.Position
    local closestPrompt, closestDist = nil, reach
    for _, prompt in pairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            local part = prompt.Parent
            if part and part:IsA("BasePart") then
                local dist = (camPos - part.Position).Magnitude
                if dist <= closestDist then
                    closestDist = dist
                    closestPrompt = prompt
                end
            end
        end
    end
    return closestPrompt
end

PromptBtnFrame.InputBegan:Connect(function(input)
    if not PromptBtnFrame:GetAttribute("Locked") and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        pbDragging = false
        pbDragStart = input.Position
        pbStartPos = PromptBtnFrame.Position

        local reach = PromptBtnFrame:GetAttribute("Reach") or 10
        currentHeldPrompt = getClosestPromptToCamera(reach)
        if currentHeldPrompt then
            pcall(function() currentHeldPrompt:InputHoldBegin() end)
        end
    end
end)

PromptBtnFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if currentHeldPrompt then
            pcall(function() currentHeldPrompt:InputHoldEnd() end)
            currentHeldPrompt = nil
        end
        pbDragStart = nil
    end
end)

table.insert(ActiveConnections, UserInputService.InputChanged:Connect(function(input)
    if not PromptBtnFrame:GetAttribute("Locked") and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        if pbDragStart and input.UserInputState ~= Enum.UserInputState.End then
            local delta = input.Position - pbDragStart
            if delta.Magnitude > 4 then
                pbDragging = true
                PromptBtnFrame.Position = UDim2.new(pbStartPos.X.Scale, pbStartPos.X.Offset + delta.X, pbStartPos.Y.Scale, pbStartPos.Y.Offset + delta.Y)
                if currentHeldPrompt then
                    pcall(function() currentHeldPrompt:InputHoldEnd() end)
                    currentHeldPrompt = nil
                end
            end
        end
    end
end))

----------------------------------------------------
-- ABOUT & DETAILS CARD
----------------------------------------------------
local function createAboutCard(parent)
    local expanded = false
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 95)
    Card.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Card.Parent = parent
    table.insert(ThemeFrames, Card)
    applyThemeOutline(Card, 1, false)
    local CardCorner = Instance.new("UICorner") CardCorner.CornerRadius = UDim.new(0, 6) CardCorner.Parent = Card
    
    local Lbl1 = Instance.new("TextLabel")
    Lbl1.Size = UDim2.new(1, -20, 0, 30)
    Lbl1.Position = UDim2.new(0, 10, 0, 0)
    Lbl1.BackgroundTransparency = 1
    Lbl1.Text = "Made by 1eyn"
    Lbl1.TextColor3 = Color3.fromRGB(255, 255, 255)
    Lbl1.Font = Enum.Font.SourceSansBold
    Lbl1.TextSize = 16
    Lbl1.TextXAlignment = Enum.TextXAlignment.Center
    Lbl1.Parent = Card
    registerDynamicText(Lbl1)
    
    local Lbl2 = Instance.new("TextLabel")
    Lbl2.Size = UDim2.new(1, -20, 0, 20)
    Lbl2.Position = UDim2.new(0, 10, 0, 25)
    Lbl2.BackgroundTransparency = 1
    Lbl2.Text = "Version 3.11"
    Lbl2.TextColor3 = Color3.fromRGB(200, 200, 200)
    Lbl2.Font = Enum.Font.SourceSansSemibold
    Lbl2.TextSize = 14
    Lbl2.TextXAlignment = Enum.TextXAlignment.Center
    Lbl2.Parent = Card
    registerDynamicText(Lbl2)
    
    local DetailsBtn = Instance.new("TextButton")
    DetailsBtn.Size = UDim2.new(0.6, 0, 0, 25)
    DetailsBtn.Position = UDim2.new(0.2, 0, 0, 55)
    DetailsBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    DetailsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DetailsBtn.Font = Enum.Font.SourceSansBold
    DetailsBtn.TextSize = 13
    DetailsBtn.Parent = Card
    local DBtnCorner = Instance.new("UICorner") DBtnCorner.CornerRadius = UDim.new(0, 6) DBtnCorner.Parent = DetailsBtn
    applyThemeOutline(DetailsBtn, 1, false)
    addTranslatable(DetailsBtn, "Details")

    local SubContainer = Instance.new("Frame")
    SubContainer.Size = UDim2.new(1, 0, 0, 0)
    SubContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    SubContainer.ClipsDescendants = true
    SubContainer.Visible = false
    SubContainer.Parent = parent
    table.insert(ThemeSubFrames, SubContainer)
    local SubCorner = Instance.new("UICorner") SubCorner.CornerRadius = UDim.new(0, 6) SubCorner.Parent = SubContainer
    applyThemeOutline(SubContainer, 1, false)
    
    local TextCont = Instance.new("TextLabel")
    TextCont.Size = UDim2.new(1, -20, 1, -10)
    TextCont.Position = UDim2.new(0, 10, 0, 5)
    TextCont.BackgroundTransparency = 1
    TextCont.TextColor3 = Color3.fromRGB(200, 200, 200)
    TextCont.TextSize = 13
    TextCont.Font = Enum.Font.SourceSans
    TextCont.TextXAlignment = Enum.TextXAlignment.Left
    TextCont.TextYAlignment = Enum.TextYAlignment.Top
    TextCont.TextWrapped = true
    TextCont.Parent = SubContainer
    addTranslatable(TextCont, "Changelog")
    registerDynamicText(TextCont)
    
    DetailsBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        if expanded then
            SubContainer.Visible = true
            TweenService:Create(SubContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 140)}):Play()
        else
            local tw = TweenService:Create(SubContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
            tw:Play()
            task.delay(0.3, function() if not expanded then SubContainer.Visible = false end end)
        end
    end)
end

----------------------------------------------------
-- FEATURES TAB IMPLEMENTATION
----------------------------------------------------
createSection("Movement / Player", FeaturesScroll)

local flyEnabled, flySpeed = false, 50
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
            if flightVector.Magnitude > 0 then flyBv.Velocity = flightVector.Unit * flySpeed end
        else
            flyBv.Velocity = Vector3.new(0, 0, 0)
        end
    end
end))

local speedEnabled, walkSpeedValue = false, 32
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
        for part, _ in pairs(noclipCache) do if part and part.Parent then part.CanCollide = true end end
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

createButton("Open Player Manager", FeaturesScroll, function()
    PlayerManagerWindow.Visible = true
    populateWinList()
end)

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

createExpandableToggle("Instant Prompt", FeaturesScroll, false, function(state)
    instantPromptEnabled = state
    PromptBtnFrame:SetAttribute("Reach", promptReachValue)
    refreshAllPrompts()
end, {
    { type = "toggle", text = "Prompt Button", callback = function(state) PromptBtnFrame.Visible = state end},
    { type = "toggle", text = "Lock Button", callback = function(state) PromptBtnFrame:SetAttribute("Locked", state) end},
    { type = "input", text = "Prompt Reach", defaultVal = promptReachValue, callback = function(val)
        local num = tonumber(val)
        if num then
            if num > 100 then num = 100 ShowNotification(getTranslation("Max 100 studs")) end
            promptReachValue = num
            PromptBtnFrame:SetAttribute("Reach", num)
            refreshAllPrompts()
        end
    end}
})

table.insert(ActiveConnections, workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ProximityPrompt") then
        task.wait(0.1)
        updatePrompt(obj)
    end
end))

----------------------------------------------------
-- FUN TAB (3D Premium Coin Toss)
----------------------------------------------------
createSection("3D Coin Toss", FunScroll)

local CoinContainer = Instance.new("Frame")
CoinContainer.Size = UDim2.new(1, 0, 0, 170)
CoinContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
CoinContainer.Parent = FunScroll
table.insert(ThemeFrames, CoinContainer)
applyThemeOutline(CoinContainer, 1, false)
local CoinContCorner = Instance.new("UICorner") CoinContCorner.CornerRadius = UDim.new(0, 6) CoinContCorner.Parent = CoinContainer

local CoinViewport = Instance.new("ViewportFrame")
CoinViewport.Size = UDim2.new(1, 0, 0, 110)
CoinViewport.Position = UDim2.new(0, 0, 0, 5)
CoinViewport.BackgroundTransparency = 1
-- Adding premium 3D lighting setup for the gold to shine
CoinViewport.LightColor = Color3.fromRGB(255, 255, 255)
CoinViewport.Ambient = Color3.fromRGB(150, 150, 150)
CoinViewport.LightDirection = Vector3.new(-1, -1, -1)
CoinViewport.Parent = CoinContainer

local CoinCam = Instance.new("Camera")
-- Backing the camera up so we can see the full toss trajectory
CoinCam.CFrame = CFrame.new(Vector3.new(0, 1.0, 6.0), Vector3.new(0, 1.0, 0))
CoinViewport.CurrentCamera = CoinCam

local CoinModel = Instance.new("Model")
CoinModel.Parent = CoinViewport

local CoinPart = Instance.new("Part")
CoinPart.Shape = Enum.PartType.Cylinder
CoinPart.Size = Vector3.new(0.4, 2.5, 2.5) -- Made it thicker and larger
CoinPart.Color = Color3.fromRGB(235, 195, 0) -- Premium Gold Color
CoinPart.Material = Enum.Material.SmoothPlastic
CoinPart.CFrame = CFrame.new(0,0,0) * CFrame.Angles(0, math.rad(90), 0)
CoinPart.Parent = CoinModel
CoinModel.PrimaryPart = CoinPart

-- Creating structural 3D text for H (Heads) and T (Tails)
local function createTextPart(size, offset)
    local p = Instance.new("Part")
    p.Size = size
    p.Color = Color3.fromRGB(190, 140, 0) -- Darker Embossed Gold
    p.Material = Enum.Material.SmoothPlastic
    p.CFrame = CoinPart.CFrame * CFrame.new(offset)
    p.Parent = CoinModel
    return p
end

local hThickness = 0.08
local faceOffset = 0.2 + (hThickness / 2) -- Ensures text sits perfectly on the coin's flat faces

-- H structure (Heads) on the Right Face (+X)
createTextPart(Vector3.new(hThickness, 1.2, 0.25), Vector3.new(faceOffset, 0, -0.4)) -- Left bar
createTextPart(Vector3.new(hThickness, 1.2, 0.25), Vector3.new(faceOffset, 0, 0.4))  -- Right bar
createTextPart(Vector3.new(hThickness, 0.25, 0.8), Vector3.new(faceOffset, 0, 0))    -- Mid bar

-- T structure (Tails) on the Left Face (-X)
createTextPart(Vector3.new(hThickness, 0.25, 1.1), Vector3.new(-faceOffset, 0.5, 0))  -- Top bar
createTextPart(Vector3.new(hThickness, 1.0, 0.25), Vector3.new(-faceOffset, -0.1, 0)) -- Mid bar

local CoinResult = Instance.new("TextLabel")
CoinResult.Size = UDim2.new(1, 0, 0, 20)
CoinResult.Position = UDim2.new(0, 0, 0, 115)
CoinResult.BackgroundTransparency = 1
CoinResult.Text = ""
CoinResult.TextColor3 = Color3.fromRGB(255, 255, 255)
CoinResult.Font = Enum.Font.SourceSansBold
CoinResult.TextSize = 16
CoinResult.Parent = CoinContainer
registerDynamicText(CoinResult)

local isTossing = false
createButton("Toss Coin", FunScroll, function()
    if isTossing then return end
    isTossing = true
    CoinResult.Text = getTranslation("Flipping...")
    
    local isHeads = math.random(1, 2) == 1
    local spinTime = 2.0
    local startTime = tick()
    local flips = 6
    local targetRotation = isHeads and 0 or math.pi
    
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local t = tick() - startTime
        local alpha = math.clamp(t / spinTime, 0, 1)
        
        -- High quality easing out for realistic deceleration
        local easeOut = 1 - math.pow(1 - alpha, 3)
        -- Parabolic jump path (up to 2.5 studs)
        local h = 2.5 * 4 * alpha * (1 - alpha)
        
        local totalRot = (flips * math.pi * 2) + targetRotation
        local currentRot = easeOut * totalRot
        
        -- Pivot directly affects the root & rigidly moves all the 3D Text parts
        CoinModel:PivotTo(CFrame.new(0, h, 0) * CFrame.Angles(currentRot, math.rad(90), 0))
        
        if alpha >= 1 then
            conn:Disconnect()
            isTossing = false
            CoinResult.Text = isHeads and getTranslation("Heads!") or getTranslation("Tails!")
            CoinModel:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(targetRotation, math.rad(90), 0))
        end
    end)
    table.insert(ActiveConnections, conn)
end)

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
local function refreshAllPlayersESP() for _, p in pairs(Players:GetPlayers()) do applyPlayerESP(p) end end
createExpandableToggle("Player ESP", FeaturesScroll, false, function(state)
    playerEspEnabled = state
    refreshAllPlayersESP()
end, {{ type = "toggle", text = "Show Names", callback = function(state) playerNamesEnabled = state refreshAllPlayersESP() end }})
table.insert(ActiveConnections, Players.PlayerAdded:Connect(function(p)
    table.insert(ActiveConnections, p.CharacterAdded:Connect(function() task.wait(0.2) applyPlayerESP(p) end))
end))
for _, p in pairs(Players:GetPlayers()) do
    table.insert(ActiveConnections, p.CharacterAdded:Connect(function() task.wait(0.2) applyPlayerESP(p) end))
end

local function isNPC(obj) return obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) end
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
        for _, obj in pairs(workspace:GetDescendants()) do if isNPC(obj) then activeNPCs[obj] = {}; applyNPCVisuals(obj) end end
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
end, {{ type = "toggle", text = "Show Names", callback = function(state) npcNamesEnabled = state refreshAllNPCsESP() end }})

local function applyInteractableVisuals(intObj)
    if not activeInteractables[intObj] then activeInteractables[intObj] = {} end
    local data = activeInteractables[intObj]
    local adornee = getESPAdornee(intObj)
    if interactableEspEnabled and adornee then
        if not data.Highlight then
            local hl = Instance.new("Highlight")
            hl.FillColor = Color3.fromRGB(255, 215, 0); hl.FillTransparency = 0.5; hl.OutlineColor = Color3.new(1,1,1)
            hl.Adornee = adornee; hl.Parent = adornee
            data.Highlight = hl
        else
            data.Highlight.Adornee = adornee; data.Highlight.Parent = adornee
        end
        if interactableNamesEnabled and not data.NameTag then
            local nameStr = intObj.Name
            if intObj:IsA("ProximityPrompt") and intObj.ActionText ~= "" then nameStr = intObj.ActionText
            elseif intObj.Parent and (intObj:IsA("ClickDetector") or intObj:IsA("ProximityPrompt")) then nameStr = intObj.Parent.Name end
            local bg = createNameTag(nameStr, Color3.fromRGB(255, 215, 0))
            bg.Adornee = adornee; bg.Parent = adornee
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
            if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then activeInteractables[obj] = {}; applyInteractableVisuals(obj) end
        end
        interactableDescendantConn = workspace.DescendantAdded:Connect(function(obj)
            task.wait(0.1)
            if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then activeInteractables[obj] = {}; applyInteractableVisuals(obj) end
        end)
        if not table.find(ActiveConnections, interactableDescendantConn) then table.insert(ActiveConnections, interactableDescendantConn) end
        interactableCleanLoop = task.spawn(function()
            while task.wait(2) do
                for intObj, data in pairs(activeInteractables) do
                    if not intObj.Parent or not getESPAdornee(intObj) then
                        if data.Highlight then data.Highlight:Destroy() end
                        if data.NameTag then data.NameTag:Destroy() end
                        activeInteractables[intObj] = nil
                    else applyInteractableVisuals(intObj) end
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
end, {{ type = "toggle", text = "Show Int. Names", callback = function(state) interactableNamesEnabled = state refreshAllInteractablesESP() end }})

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

createToggle("Inner UI Outlines", SettingsScroll, true, function(state)
    InnerOutlinesEnabled = state
    updateInnerOutlines()
end)

createColorPresetsRow(SettingsScroll)

local langOrder = {"EN", "PL", "RU", "ES"}
local LangBtn
LangBtn = createButton("Language: ", SettingsScroll, function()
    local idx = table.find(langOrder, currentLang)
    idx = idx + 1
    if idx > #langOrder then idx = 1 end
    currentLang = langOrder[idx]
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
    for part, _ in pairs(noclipCache) do if part and part.Parent then part.CanCollide = true end end
    
    fullbrightEnabled = false; resetLighting()
    instantPromptEnabled = false; refreshAllPrompts()
    
    playerEspEnabled = false; refreshAllPlayersESP()
    npcEspEnabled = false; refreshAllNPCsESP()
    interactableEspEnabled = false; toggleInteractablesESP()

    if isSpectating then
        workspace.CurrentCamera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    end
    
    if managerHighlight then managerHighlight:Destroy() end

    for _, connection in ipairs(ActiveConnections) do if connection and connection.Disconnect then connection:Disconnect() end end
    if ScreenGui then ScreenGui:Destroy() end
    if NotifGui then NotifGui:Destroy() end
    if PromptBtnGui then PromptBtnGui:Destroy() end
end

createButton("Destroy Everything & UI", SettingsScroll, function() DestroyHub() end, Color3.fromRGB(180, 40, 40))

createSection("About", SettingsScroll)
createAboutCard(SettingsScroll)

-- Initial Setting Update
refreshTranslations()
updateInnerOutlines()
