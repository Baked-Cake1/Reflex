local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Reflex | BedFight",
    Icon = 0,
    LoadingTitle = "Reflex",    LoadingSubtitle = "Loading...",
    ShowText = "Reflex",
    Theme = "DarkBlue",
    ToggleUIKeybind = Enum.KeyCode.RightShift,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ReflexBedFight",
        FileName = "Config"
    },
    KeySystem = false
})

local RangedTab = Window:CreateTab("Ranged", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local ChecksTab = Window:CreateTab("Checks", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AimbotEnabled = false
local CheckRangedEquipped = false
local PredictionEnabled = false
local PredictionValue = 0.1

local TeamCheck = false
local FriendCheck = false
local WallCheck = false
local AimbotOnlyWall = false
local ESPOnlyWall = false

local BedESPEnabled = false
local PlayerESPEnabled = false
local TracersEnabled = false
local HealthBarEnabled = false
local HealthNumEnabled = false
local ShowHitbox = false

local AutoPingEnabled = false
local AutoScaffoldEnabled = false
local ScaffoldDistance = 5
local ScaffoldUnderFeet = false

local function IsVisible(TargetPart)
    if not TargetPart then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, TargetPart.Parent}
    
    local origin = Camera.CFrame.Position
    local direction = (TargetPart.Position - origin)
    local result = workspace:Raycast(origin, direction, params)
    
    return result == nil
end

local function GetCharacter(player)
    return workspace:FindFirstChild("PlayersContainer") and workspace.PlayersContainer:FindFirstChild(player.Name) or player.Character
end

local function GetWoolItem()
    local item = nil
    -- Check Backpack
    for _, obj in pairs(LocalPlayer.Backpack:GetChildren()) do
        if string.find(obj.Name, "Wool") then
            item = obj.Name
            break
        end
    end
    -- Check Character (Equipped)
    if not item and LocalPlayer.Character then
        for _, obj in pairs(LocalPlayer.Character:GetChildren()) do
            if obj:IsA("Tool") and string.find(obj.Name, "Wool") then
                item = obj.Name
                break
            end
        end
    end
    return item
end

local function GetClosestPlayer()
    local target = nil
    local dist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        local char = GetCharacter(v)
        if v ~= LocalPlayer and char and char:FindFirstChild("HumanoidRootPart") then
            if TeamCheck and v.Team == LocalPlayer.Team then continue end
            if FriendCheck and LocalPlayer:IsFriendsWith(v.UserId) then continue end
            if WallCheck and AimbotOnlyWall and not IsVisible(char.HumanoidRootPart) then continue end
            
            local pos, onScreen = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
            if onScreen then
                local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if magnitude < dist then
                    target = v
                    dist = magnitude
                end
            end
        end
    end
    return target
end

RangedTab:CreateToggle({
    Name = "Bow Aimbot",
    CurrentValue = false,
    Flag = "BowAimbot",
    Callback = function(Value)
        AimbotEnabled = Value
        if Value then
            Rayfield:Notify({Title = "Aimbot ON", Content = "Ranged assistance activated.", Duration = 3, Image = 4483362458})
        end
    end
})

RangedTab:CreateToggle({
    Name = "Check if Ranged Equipped",
    CurrentValue = false,
    Flag = "RangedEquipCheck",
    Callback = function(Value)
        CheckRangedEquipped = Value
    end
})

RangedTab:CreateToggle({
    Name = "Use Prediction",
    CurrentValue = false,
    Flag = "PredictionToggle",
    Callback = function(Value)
        PredictionEnabled = Value
    end
})

RangedTab:CreateSlider({
    Name = "Prediction Strength",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "Factor",
    CurrentValue = 0.1,
    Flag = "PredValue",
    Callback = function(Value)
        PredictionValue = Value
    end
})

VisualsTab:CreateToggle({
    Name = "Bed ESP",
    CurrentValue = false,
    Flag = "BedESP",
    Callback = function(Value)
        BedESPEnabled = Value
    end
})

VisualsTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(Value)
        PlayerESPEnabled = Value
    end
})

VisualsTab:CreateToggle({
    Name = "Tracers",
    CurrentValue = false,
    Flag = "Tracers",
    Callback = function(Value)
        TracersEnabled = Value
    end
})

VisualsTab:CreateToggle({
    Name = "Health Bar",
    CurrentValue = false,
    Flag = "HBar",
    Callback = function(Value)
        HealthBarEnabled = Value
    end
})

VisualsTab:CreateToggle({
    Name = "Show Health Number",
    CurrentValue = false,
    Flag = "HNum",
    Callback = function(Value)
        HealthNumEnabled = Value
    end
})

VisualsTab:CreateToggle({
    Name = "Show Hitbox",
    CurrentValue = false,
    Flag = "ShowHitbox",
    Callback = function(Value)
        ShowHitbox = Value
    end
})

ChecksTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Flag = "TCheck",
    Callback = function(Value)
        TeamCheck = Value
    end
})

ChecksTab:CreateToggle({
    Name = "Friend Check",
    CurrentValue = false,
    Flag = "FCheck",
    Callback = function(Value)
        FriendCheck = Value
    end
})

ChecksTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = false,
    Flag = "WCheck",
    Callback = function(Value)
        WallCheck = Value
    end
})

ChecksTab:CreateToggle({
    Name = "Aimbot Only (Wall)",
    CurrentValue = false,
    Flag = "AWall",
    Callback = function(Value)
        AimbotOnlyWall = Value
    end
})

ChecksTab:CreateToggle({
    Name = "ESP Only (Wall)",
    CurrentValue = false,
    Flag = "EWall",
    Callback = function(Value)
        ESPOnlyWall = Value
    end
})

MiscTab:CreateToggle({
    Name = "Auto-Ping",
    CurrentValue = false,
    Flag = "AutoPing",
    Callback = function(Value)
        AutoPingEnabled = Value
    end
})

MiscTab:CreateToggle({
    Name = "Auto-Scaffold",
    CurrentValue = false,
    Flag = "AutoScaffold",
    Callback = function(Value)
        AutoScaffoldEnabled = Value
    end
})

MiscTab:CreateToggle({
    Name = "Scaffold Under Feet",
    CurrentValue = false,
    Flag = "ScafUnder",
    Callback = function(Value)
        ScaffoldUnderFeet = Value
    end
})

MiscTab:CreateSlider({
    Name = "Scaffold Distance",
    Range = {1, 15},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 5,
    Flag = "ScafDist",
    Callback = function(Value)
        ScaffoldDistance = Value
    end
})

local function CreateBedUI(bed, color)
    if bed:FindFirstChild("ReflexESP") then return end
    local bgui = Instance.new("BillboardGui")
    bgui.Name = "ReflexESP"
    bgui.Adornee = bed
    bgui.Size = UDim2.new(0, 100, 0, 50)
    bgui.AlwaysOnTop = true
    local lbl = Instance.new("TextLabel", bgui)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = color
    lbl.Text = "Bed"
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 14
    bgui.Parent = bed
end

local function UpdatePlayerVisuals(p)
    local char = GetCharacter(p)
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    local isFriendly = (TeamCheck and p.Team == LocalPlayer.Team) or (FriendCheck and LocalPlayer:IsFriendsWith(p.UserId))
    local isOccluded = not IsVisible(root)
    local shouldHide = (WallCheck and ESPOnlyWall and isOccluded) or isFriendly

    local high = char:FindFirstChild("ReflexHighlight") or Instance.new("Highlight")
    high.Name = "ReflexHighlight"
    high.Parent = char
    high.Enabled = PlayerESPEnabled and not shouldHide
    high.FillColor = p.TeamColor.Color
    high.OutlineColor = Color3.new(1,1,1)
    
    for _, part in pairs(char:GetChildren()) do
        if part.Name == "Hitbox" then
            part.Transparency = ShowHitbox and 0.5 or 1
            high.Adornee = (not ShowHitbox) and char or nil
        end
    end

    local bgui = char:FindFirstChild("ReflexHealth") or Instance.new("BillboardGui")
    bgui.Name = "ReflexHealth"
    bgui.Adornee = root
    bgui.Size = UDim2.new(0, 50, 0, 20)
    bgui.StudsOffset = Vector3.new(0, 3, 0)
    bgui.AlwaysOnTop = true
    bgui.Parent = char
    bgui.Enabled = (HealthBarEnabled or HealthNumEnabled) and PlayerESPEnabled and not shouldHide

    local txt = bgui:FindFirstChild("HText") or Instance.new("TextLabel", bgui)
    txt.Name = "HText"
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.new(1,1,1)
    txt.Text = HealthNumEnabled and math.floor(hum.Health) or ""
    txt.Visible = HealthNumEnabled
end

RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = GetClosestPlayer()
        local char = target and GetCharacter(target)
        local hasBow = not CheckRangedEquipped or (LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("Bow") or LocalPlayer.Character:FindFirstChild("Crossbow")))
        
        if target and char and char:FindFirstChild("HumanoidRootPart") and hasBow then
            local aimPos = char.HumanoidRootPart.Position
            if PredictionEnabled then
                aimPos = aimPos + (char.HumanoidRootPart.Velocity * PredictionValue)
            end
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPos)
        end
    end
    
    if AutoPingEnabled then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local args = { root.Position }
            local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
            local ping = remotes and remotes:FindFirstChild("Ping")
            if ping then ping:FireServer(unpack(args)) end
        end
    end

    if AutoScaffoldEnabled then
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local woolItem = GetWoolItem()
        
        if root and woolItem then
            local checkPos = root.Position
            if not ScaffoldUnderFeet then
                checkPos = root.Position + (root.CFrame.LookVector * ScaffoldDistance)
            end
            
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            raycastParams.FilterDescendantsInstances = {char}
            
            local ray = workspace:Raycast(checkPos, Vector3.new(0, -500, 0), raycastParams)
            
            if not ray then
                local placeX = math.floor(checkPos.X)
                local placeY = math.floor(checkPos.Y - 4)
                local placeZ = math.floor(checkPos.Z)
                
                local args = {
                    woolItem,
                    214,
                    Vector3.new(placeX, placeY, placeZ)
                }
                local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                local items = remotes and remotes:FindFirstChild("ItemsRemotes")
                local place = items and items:FindFirstChild("PlaceBlock")
                
                if place then
                    place:FireServer(unpack(args))
                end
            end
        end
    end
    
    local container = workspace:FindFirstChild("BedsContainer")
    if container then
        for _, bed in pairs(container:GetChildren()) do
            if bed.Name == "Bed" then
                local ui = bed:FindFirstChild("ReflexESP")
                if BedESPEnabled then
                    local color = Color3.fromRGB(255,255,255)
                    local teamAttr = bed:GetAttribute("Team")
                    if teamAttr == "Red" then color = Color3.fromRGB(255,0,0)
                    elseif teamAttr == "Blue" then color = Color3.fromRGB(0,0,255)
                    elseif teamAttr == "Green" then color = Color3.fromRGB(0,255,0)
                    elseif teamAttr == "Yellow" then color = Color3.fromRGB(255,255,0) end
                    
                    if not ui then CreateBedUI(bed, color) else ui.Enabled = true end
                elseif ui then
                    ui.Enabled = false
                end
            end
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            UpdatePlayerVisuals(p)
        end
    end
end)
