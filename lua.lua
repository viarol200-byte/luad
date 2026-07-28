-- Revenge Hub | Custom GUI (No Libraries + No Neon + Unload)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Events")

-- Флаг работы скрипта
local ScriptRunning = true

-- Настройки и переменные
local SelectedCase = "Beggar"
local OpenAmount = 1
local DiceAmount = 1000000

local AutoOpenEnabled = false
local AutoSellEnabled = false
local AutoFuseEnabled = false
local AutoSummerEnabled = false
local AutoDiceBotEnabled = false

local TotalCasesOpened = 0
local ElapsedSeconds = 0
local StartBalance = nil

local function GetCurrentBalance()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("Data")
    if leaderstats then
        local cash = leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Coins") or leaderstats:FindFirstChild("Balance")
        if cash then
            return cash.Value
        end
    end
    return 0
end

local function IsAnyFarmActive()
    return AutoOpenEnabled or AutoSellEnabled or AutoFuseEnabled or AutoSummerEnabled or AutoDiceBotEnabled
end

-- Удаление старого UI при повторном запуске
if CoreGui:FindFirstChild("VRTHubCustom") then
    CoreGui.VRTHubCustom:Destroy()
end

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VRTHubCustom"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Главный контейнер
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 380)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 52)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Заголовок
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 0, 36)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "REVENGE HUB <font color='#888899'>| NFT Battles</font>"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.RichText = true
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -32, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Панель вкладок (Слева)
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 120, 1, -46)
TabBar.Position = UDim2.new(0, 8, 0, 38)
TabBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabBarCorner = Instance.new("UICorner")
TabBarCorner.CornerRadius = UDim.new(0, 6)
TabBarCorner.Parent = TabBar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Padding = UDim.new(0, 4)
TabListLayout.Parent = TabBar

-- Контейнер для страниц
local PagesFolder = Instance.new("Frame")
PagesFolder.Size = UDim2.new(1, -144, 1, -46)
PagesFolder.Position = UDim2.new(0, 134, 0, 38)
PagesFolder.BackgroundTransparency = 1
PagesFolder.Parent = MainFrame

local Tabs = {}
local CurrentTabBtn = nil

local function CreateTab(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    Page.Visible = false
    Page.Parent = PagesFolder

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 6)
    PageLayout.Parent = Page

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 32)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(160, 160, 170)
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize = 12
    TabBtn.Parent = TabBar

    local TabBtnCorner = Instance.new("UICorner")
    TabBtnCorner.CornerRadius = UDim.new(0, 6)
    TabBtnCorner.Parent = TabBtn

    TabBtn.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Page.Visible = false
            tab.Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            tab.Btn.TextColor3 = Color3.fromRGB(160, 160, 170)
        end
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(40, 48, 60)
        TabBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
    end)

    Tabs[name] = {Page = Page, Btn = TabBtn}
    return Page
end

local MainPage = CreateTab("Main")
local PVPPage = CreateTab("PVP")
local SummerPage = CreateTab("Summer")
local StatsPage = CreateTab("Stats")
local SettingsPage = CreateTab("Settings")

-- Активируем первую вкладку
Tabs["Main"].Page.Visible = true
Tabs["Main"].Btn.BackgroundColor3 = Color3.fromRGB(40, 48, 60)
Tabs["Main"].Btn.TextColor3 = Color3.fromRGB(240, 240, 240)

-- Хелперы UI
local function AddToggle(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -6, 0, 34)
    Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    Btn.Text = "  " .. text .. ": OFF"
    Btn.TextColor3 = Color3.fromRGB(160, 160, 170)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 12
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(40, 40, 48)
    Stroke.Thickness = 1
    Stroke.Parent = Btn

    local state = false
    Btn.MouseButton1Click:Connect(function()
        if not ScriptRunning then return end
        state = not state
        if state then
            Btn.Text = "  " .. text .. ": ON"
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.BackgroundColor3 = Color3.fromRGB(40, 50, 65)
            Stroke.Color = Color3.fromRGB(65, 80, 100)
            if StartBalance == nil then StartBalance = GetCurrentBalance() end
        else
            Btn.Text = "  " .. text .. ": OFF"
            Btn.TextColor3 = Color3.fromRGB(160, 160, 170)
            Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
            Stroke.Color = Color3.fromRGB(40, 40, 48)
        end
        callback(state)
    end)
end

local function AddButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -6, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 12
    Btn.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(45, 45, 52)
    Stroke.Thickness = 1
    Stroke.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        if ScriptRunning then callback() end
    end)
end

local function AddInput(parent, text, defaultVal, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -6, 0, 34)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    Frame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(40, 40, 48)
    Stroke.Thickness = 1
    Stroke.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(160, 160, 170)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(0.35, -8, 0, 22)
    Box.Position = UDim2.new(0.65, 0, 0.5, -11)
    Box.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    Box.Text = tostring(defaultVal)
    Box.TextColor3 = Color3.fromRGB(240, 240, 240)
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 11
    Box.Parent = Frame

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = Box

    Box.FocusLost:Connect(function()
        callback(Box.Text)
    end)
end

local function AddParagraph(parent, title)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -6, 0, 42)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Frame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local TTitle = Instance.new("TextLabel")
    TTitle.Size = UDim2.new(1, -12, 0, 18)
    TTitle.Position = UDim2.new(0, 6, 0, 4)
    TTitle.BackgroundTransparency = 1
    TTitle.Text = title
    TTitle.TextColor3 = Color3.fromRGB(200, 200, 210)
    TTitle.Font = Enum.Font.GothamBold
    TTitle.TextSize = 11
    TTitle.TextXAlignment = Enum.TextXAlignment.Left
    TTitle.Parent = Frame

    local TDesc = Instance.new("TextLabel")
    TDesc.Size = UDim2.new(1, -12, 0, 16)
    TDesc.Position = UDim2.new(0, 6, 0, 20)
    TDesc.BackgroundTransparency = 1
    TDesc.Text = "---"
    TDesc.TextColor3 = Color3.fromRGB(150, 150, 160)
    TDesc.Font = Enum.Font.Gotham
    TDesc.TextSize = 11
    TDesc.TextXAlignment = Enum.TextXAlignment.Left
    TDesc.Parent = Frame

    return TDesc
end

-- MAIN TAB
AddInput(MainPage, "Open Amount (1-10)", "1", function(val)
    local num = tonumber(val)
    if num then OpenAmount = math.clamp(num, 1, 10) end
end)
AddToggle(MainPage, "Auto Open Cases", function(s) AutoOpenEnabled = s end)
AddToggle(MainPage, "Auto Sell Inventory", function(s) AutoSellEnabled = s end)
AddToggle(MainPage, "Auto Fuse (Plush Pepe)", function(s) AutoFuseEnabled = s end)

-- PVP TAB
AddInput(PVPPage, "Bet Amount", "1000000", function(val)
    local num = tonumber(val)
    if num then DiceAmount = num end
end)
AddToggle(PVPPage, "Auto Dice PVP Bot", function(s) AutoDiceBotEnabled = s end)

-- SUMMER TAB
AddToggle(SummerPage, "Auto Summer Claim", function(s) AutoSummerEnabled = s end)

-- STATS TAB
local BalText = AddParagraph(StatsPage, "Current Balance")
local ProfitText = AddParagraph(StatsPage, "Total Profit / Loss")
local CasesText = AddParagraph(StatsPage, "Total Cases Opened")
local TimeText = AddParagraph(StatsPage, "Active Time Elapsed")

AddButton(StatsPage, "Reset Profit Tracker", function()
    StartBalance = GetCurrentBalance()
end)

-- SETTINGS TAB
AddButton(SettingsPage, "FPS Booster", function()
    pcall(function()
        local Terrain = workspace:FindFirstChildOfClass('Terrain')
        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 0
        end
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").FogEnd = 9e9
        
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
        end
    end)
end)

AddButton(SettingsPage, "Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

AddButton(SettingsPage, "Server Hop", function()
    pcall(function()
        local Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
        for _, server in pairs(Servers) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                break
            end
        end
    end)
end)

-- UNLOAD BUTTON
local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(1, -6, 0, 32)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(50, 25, 25)
UnloadBtn.Text = "UNLOAD SCRIPT"
UnloadBtn.TextColor3 = Color3.fromRGB(220, 100, 100)
UnloadBtn.Font = Enum.Font.GothamBold
UnloadBtn.TextSize = 11
UnloadBtn.Parent = SettingsPage

local UnloadCorner = Instance.new("UICorner")
UnloadCorner.CornerRadius = UDim.new(0, 6)
UnloadCorner.Parent = UnloadBtn

local UnloadStroke = Instance.new("UIStroke")
UnloadStroke.Color = Color3.fromRGB(80, 35, 35)
UnloadStroke.Thickness = 1
UnloadStroke.Parent = UnloadBtn

-- Мобильная плавающая кнопка
local MobileBtn = Instance.new("TextButton")
MobileBtn.Name = "MobileToggle"
MobileBtn.Size = UDim2.new(0, 42, 0, 42)
MobileBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
MobileBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
MobileBtn.Text = "MENU"
MobileBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
MobileBtn.Font = Enum.Font.GothamBold
MobileBtn.TextSize = 10
MobileBtn.Active = true
MobileBtn.Draggable = true
MobileBtn.Parent = ScreenGui

local MobileCorner = Instance.new("UICorner")
MobileCorner.CornerRadius
