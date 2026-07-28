-- Revenge Hub | Custom GUI by VRT PIDOR DEV
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Events")

-- Состояния функций
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

-- Создание ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VRTHubCustom"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Главный контейнер
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 360)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 229, 255)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Заголовок
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 0, 40)
TitleLabel.Position = UDim2.new(0, 10, 0, 5)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "REVENGE HUB <font color='#00e5ff'>| VRT PIDOR DEV</font>"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.RichText = true
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

-- Кнопка закрытия/сворачивания
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 85, 85)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Контейнер с кнопками-переключателями
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -20, 1, -110)
ContentFrame.Position = UDim2.new(0, 10, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ScrollBarThickness = 4
ContentFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ContentFrame

-- Функция создания переключателя
local function CreateToggle(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 38)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    Btn.Text = "  " .. text .. ": OFF"
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 13
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = ContentFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(40, 40, 50)
    Stroke.Thickness = 1
    Stroke.Parent = Btn

    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Btn.Text = "  " .. text .. ": ON"
            Btn.TextColor3 = Color3.fromRGB(0, 229, 255)
            Btn.BackgroundColor3 = Color3.fromRGB(20, 40, 50)
            Stroke.Color = Color3.fromRGB(0, 229, 255)
            if StartBalance == nil then StartBalance = GetCurrentBalance() end
        else
            Btn.Text = "  " .. text .. ": OFF"
            Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
            Stroke.Color = Color3.fromRGB(40, 40, 50)
        end
        callback(state)
    end)
end

CreateToggle("Auto Open Cases", function(s) AutoOpenEnabled = s end)
CreateToggle("Auto Sell Inventory", function(s) AutoSellEnabled = s end)
CreateToggle("Auto Fuse (Plush Pepe)", function(s) AutoFuseEnabled = s end)
CreateToggle("Auto Summer Claim", function(s) AutoSummerEnabled = s end)
CreateToggle("Auto Dice PVP Bot", function(s) AutoDiceBotEnabled = s end)

-- Статистика внизу
local StatsFrame = Instance.new("Frame")
StatsFrame.Size = UDim2.new(1, -20, 0, 50)
StatsFrame.Position = UDim2.new(0, 10, 1, -55)
StatsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
StatsFrame.Parent = MainFrame

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 6)
StatsCorner.Parent = StatsFrame

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -10, 1, 0)
StatsLabel.Position = UDim2.new(0, 5, 0, 0)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "Баланс: 0 $ | Окуп: 0 $\nВремя: 00:00:00 (Пауза)"
StatsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatsLabel.TextSize = 11
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.Parent = StatsFrame

-- Мобильная плавающая кнопка
local MobileBtn = Instance.new("TextButton")
MobileBtn.Name = "MobileToggle"
MobileBtn.Size = UDim2.new(0, 45, 0, 45)
MobileBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
MobileBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MobileBtn.Text = "VRT"
MobileBtn.TextColor3 = Color3.fromRGB(0, 229, 255)
MobileBtn.Font = Enum.Font.GothamBold
MobileBtn.TextSize = 12
MobileBtn.Active = true
MobileBtn.Draggable = true
MobileBtn.Parent = ScreenGui

local MobileCorner = Instance.new("UICorner")
MobileCorner.CornerRadius = UDim.new(0, 10)
MobileCorner.Parent = MobileBtn

local MobileStroke = Instance.new("UIStroke")
MobileStroke.Color = Color3.fromRGB(0, 229, 255)
MobileStroke.Thickness = 1
MobileStroke.Parent = MobileBtn

local function ToggleMenu()
    MainFrame.Visible = not MainFrame.Visible
end

CloseBtn.MouseButton1Click:Connect(ToggleMenu)
MobileBtn.MouseButton1Click:Connect(ToggleMenu)

-- Логика фарма и подсчёта
task.spawn(function()
    while task.wait(1) do
        local curBal = GetCurrentBalance()
        local profitText = "0 $"
        
        if StartBalance ~= nil then
            local profit = curBal - StartBalance
            profitText = (profit >= 0 and "+" or "") .. tostring(profit) .. " $"
        end
        
        if IsAnyFarmActive() then
            ElapsedSeconds = ElapsedSeconds + 1
            local h, m, s = math.floor(ElapsedSeconds / 3600), math.floor((ElapsedSeconds % 3600) / 60), ElapsedSeconds % 60
            StatsLabel.Text = string.format("Баланс: %d $ | Окуп: %s\nВремя фарма: %02d:%02d:%02d", curBal, profitText, h, m, s)
        else
            local h, m, s = math.floor(ElapsedSeconds / 3600), math.floor((ElapsedSeconds % 3600) / 60), ElapsedSeconds % 60
            StatsLabel.Text = string.format("Баланс: %d $ | Окуп: %s\nВремя фарма: %02d:%02d:%02d (Пауза)", curBal, profitText, h, m, s)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if AutoOpenEnabled then
            pcall(function() Events.OpenCase:InvokeServer("Beggar", 1, {}) end)
            task.wait(1.5)
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if AutoSellEnabled then
            pcall(function() Events.Inventory:FireServer("Sell", "ALL", false) end)
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if AutoFuseEnabled then
            pcall(function()
                local inv = LocalPlayer:FindFirstChild("_Inventory")
                if inv then
                    local items = {}
                    for _, child in pairs(inv:GetChildren()) do
                        if child.Name == "Plush Pepe (Amalgam)" then
                            table.insert(items, child)
                            if #items == 5 then break end
                        end
                    end
                    if #items == 5 then Events.Fuse:InvokeServer("Fuse", items, false) end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if AutoSummerEnabled then
            pcall(function() Events.Summer:InvokeServer("Claim") end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if AutoDiceBotEnabled then
            pcall(function()
                Events.DicePvp:InvokeServer("Create", 1000000, false)
                task.wait(0.5)
                Events.DicePvp:InvokeServer("Bot")
            end)
            task.wait(3)
        end
    end
end)

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)
