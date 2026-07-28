local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Revenge Hub | NFT Battles",
    SubTitle = "by VRT PIDOR DEV",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    PVP = Window:AddTab({ Title = "PVP", Icon = "swords" }),
    Summer = Window:AddTab({ Title = "Summer Event", Icon = "sun" }),
    Stats = Window:AddTab({ Title = "Stats & Profit", Icon = "line-chart" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local SelectedCase = "Beggar"
local OpenAmount = 1

local AutoOpenEnabled = false
local AutoSellEnabled = false
local AutoFuseEnabled = false
local AutoSummerEnabled = false
local AutoDiceBotEnabled = false
local DiceAmount = 1000000

local TotalCasesOpened = 0
local ElapsedSeconds = 0
local StartBalance = nil

local LocalPlayer = game:GetService("Players").LocalPlayer

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

local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "MobileToggleGui"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ToggleButton.Position = UDim2.new(0.05, 0, 0.15, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "MENU"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Active = true
ToggleButton.Draggable = true

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    if Window.Root then
        Window.Root.Visible = not Window.Root.Visible
    end
end)

Tabs.Main:AddSection("Cases")

Tabs.Main:AddDropdown("CaseSelect", {
    Title = "Case to open (Select One)",
    Values = {
        "Beggar", "Plodder", "Office Clerk", "Manager", 
        "Director", "Oligarch", "Frozen Heart", "Bubble Gum", 
        "Cats", "Glitch", "Dream", "Bloody Night"
    },
    Default = 1,
    Callback = function(Value)
        SelectedCase = Value
    end
})

Tabs.Main:AddInput("AmountInput", {
    Title = "Amount to open (1-10)",
    Default = "1",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            OpenAmount = math.clamp(num, 1, 10)
        end
    end
})

Tabs.Main:AddToggle("AutoOpen", {
    Title = "Auto Open", 
    Default = false,
    Callback = function(Value)
        AutoOpenEnabled = Value
        if Value and StartBalance == nil then
            StartBalance = GetCurrentBalance()
        end
    end
})

Tabs.Main:AddSection("Inventory & Fuse")

Tabs.Main:AddToggle("AutoSell", {
    Title = "Auto Sell ALL Items", 
    Default = false,
    Callback = function(Value)
        AutoSellEnabled = Value
        if Value and StartBalance == nil then
            StartBalance = GetCurrentBalance()
        end
    end
})

Tabs.Main:AddToggle("AutoFuse", {
    Title = "Auto Fuse (Plush Pepe)", 
    Default = false,
    Callback = function(Value)
        AutoFuseEnabled = Value
        if Value and StartBalance == nil then
            StartBalance = GetCurrentBalance()
        end
    end
})

Tabs.PVP:AddSection("Dice PVP")

Tabs.PVP:AddInput("DiceBetInput", {
    Title = "Bet Amount",
    Default = "1000000",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            DiceAmount = num
        end
    end
})

Tabs.PVP:AddToggle("AutoDiceBot", {
    Title = "Auto Create & Play with Bot", 
    Default = false,
    Callback = function(Value)
        AutoDiceBotEnabled = Value
        if Value and StartBalance == nil then
            StartBalance = GetCurrentBalance()
        end
    end
})

Tabs.Summer:AddSection("Summer Event")

Tabs.Summer:AddToggle("AutoSummer", {
    Title = "Auto Claim Event Rewards", 
    Default = false,
    Callback = function(Value)
        AutoSummerEnabled = Value
        if Value and StartBalance == nil then
            StartBalance = GetCurrentBalance()
        end
    end
})

Tabs.Stats:AddSection("Balance & Profit Tracker")

local CurrentBalanceParagraph = Tabs.Stats:AddParagraph({
    Title = "Current Balance",
    Content = "0 $"
})

local ProfitParagraph = Tabs.Stats:AddParagraph({
    Title = "Total Profit / Loss",
    Content = "0 $"
})

Tabs.Stats:AddSection("Farm Statistics")

local CasesStatParagraph = Tabs.Stats:AddParagraph({
    Title = "Total Cases Opened",
    Content = "0"
})

local TimeStatParagraph = Tabs.Stats:AddParagraph({
    Title = "Active Time Elapsed",
    Content = "00:00:00 (Paused)"
})

Tabs.Stats:AddSection("Performance & Utilities")

Tabs.Stats:AddButton({
    Title = "Reset Profit Tracker",
    Description = "Сбросить отсчёт окупа на текущий баланс.",
    Callback = function()
        StartBalance = GetCurrentBalance()
        Fluent:Notify({
            Title = "Profit Tracker",
            Content = "Точка отсчёта окупа сброшена!",
            Duration = 2
        })
    end
})

Tabs.Stats:AddButton({
    Title = "FPS Booster (Low Graphics)",
    Description = "Убирает эффекты, текстуры и тени для снижения лагов.",
    Callback = function()
        pcall(function()
            local Terrain = workspace:FindFirstChildOfClass('Terrain')
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 0
            
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
        
        Fluent:Notify({
            Title = "FPS Booster",
            Content = "Графика снижена, нагрузка уменьшена!",
            Duration = 3
        })
    end
})

Tabs.Stats:AddButton({
    Title = "Rejoin Server",
    Description = "Перезайти на этот же сервер.",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

Tabs.Stats:AddButton({
    Title = "Server Hop",
    Description = "Перейти на случайный другой сервер.",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local HttpService = game:GetService("HttpService")
        
        pcall(function()
            local Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
            for _, server in pairs(Servers) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                    break
                end
            end
        end)
    end
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Events")

task.spawn(function()
    while task.wait(1) do
        local curBal = GetCurrentBalance()
        CurrentBalanceParagraph:SetDesc(tostring(curBal) .. " $")
        
        if StartBalance ~= nil then
            local profit = curBal - StartBalance
            if profit >= 0 then
                ProfitParagraph:SetDesc("+" .. tostring(profit) .. " $")
            else
                ProfitParagraph:SetDesc(tostring(profit) .. " $")
            end
        else
            ProfitParagraph:SetDesc("Включите фарм для старта отсчёта")
        end
        
        if IsAnyFarmActive() then
            ElapsedSeconds = ElapsedSeconds + 1
            local hours = math.floor(ElapsedSeconds / 3600)
            local minutes = math.floor((ElapsedSeconds % 3600) / 60)
            local seconds = ElapsedSeconds % 60
            TimeStatParagraph:SetDesc(string.format("%02d:%02d:%02d", hours, minutes, seconds))
        else
            local hours = math.floor(ElapsedSeconds / 3600)
            local minutes = math.floor((ElapsedSeconds % 3600) / 60)
            local seconds = ElapsedSeconds % 60
            TimeStatParagraph:SetDesc(string.format("%02d:%02d:%02d (Пауза)", hours, minutes, seconds))
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if AutoOpenEnabled then
            local success = pcall(function()
                Events.OpenCase:InvokeServer(SelectedCase, OpenAmount, {})
            end)
            
            if success then
                TotalCasesOpened = TotalCasesOpened + OpenAmount
                CasesStatParagraph:SetDesc(tostring(TotalCasesOpened))
            end
            
            task.wait(1.5)
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if AutoSellEnabled then
            pcall(function()
                Events.Inventory:FireServer("Sell", "ALL", false)
            end)
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
                    
                    if #items == 5 then
                        local args = {
                            "Fuse",
                            items,
                            false
                        }
                        Events.Fuse:InvokeServer(unpack(args))
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if AutoSummerEnabled then
            pcall(function()
                Events.Summer:InvokeServer("Claim")
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if AutoDiceBotEnabled then
            pcall(function()
                Events.DicePvp:InvokeServer("Create", DiceAmount, false)
                task.wait(0.5)
                Events.DicePvp:InvokeServer("Bot")
            end)
            task.wait(3)
        end
    end
end)

local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    Fluent:Notify({
        Title = "VRT PIDOR DEV - Anti-AFK",
        Content = "Защита от АФК сработала!",
        Duration = 2
    })
end)

Window:SelectTab(1)
