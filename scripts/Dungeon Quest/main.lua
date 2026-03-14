local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Window = Rayfield:CreateWindow({
   Name = "Reflex | Dungeon Quest",
   Icon = 0,
   LoadingTitle = "Reflex Interface Suite",
   LoadingSubtitle = "by RScripter",
   ShowText = "Reflex",
   Theme = "DarkBlue",
   ToggleUIKeybind = Enum.KeyCode.RightShift,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "ReflexDQ",
      FileName = "Config"
   }
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

local KillRadiusActive = false
local LocateEnemiesActive = false
local AutoAbilityActive = false
local MovementMethod = "Tween"
local TweenSpeed = 50
local CurrentTarget = nil

local FirstAbilityMode = "Unused Ability"
local SecondAbilityMode = "Unused Ability"
local FirstAbilityCooldown = 1
local SecondAbilityCooldown = 1
local LastFirstUsed = 0
local LastSecondUsed = 0

local function GetNearestEnemy()
    local DungeonFolder = workspace:FindFirstChild("dungeon")
    if not DungeonFolder then return nil end
    
    local nearest = nil
    local shortestDistance = math.huge
    
    for _, descendant in ipairs(DungeonFolder:GetDescendants()) do
        if descendant:IsA("Model") and descendant:FindFirstChild("Humanoid") and descendant:FindFirstChild("HumanoidRootPart") then
            local hum = descendant.Humanoid
            if hum.Health > 0 then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - descendant.HumanoidRootPart.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    nearest = descendant
                end
            end
        end
    end
    return nearest
end

local function Click()
    local x, y = 0, 0
    if workspace.CurrentCamera then
        x = workspace.CurrentCamera.ViewportSize.X / 2
        y = workspace.CurrentCamera.ViewportSize.Y / 2
    end
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.1)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

local function PressKey(key)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

local function HandleAbilityLogic(mode, key, cooldown, lastUsedTimeRef)
    if mode == "Unused Ability" then return lastUsedTimeRef end
    if tick() - lastUsedTimeRef < cooldown then return lastUsedTimeRef end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") or not character:FindFirstChild("HumanoidRootPart") then return lastUsedTimeRef end
    local humanoid = character.Humanoid
    local hrp = character.HumanoidRootPart
    
    local used = false

    if mode == "Healing" then
        if (humanoid.Health / humanoid.MaxHealth) <= 0.3 then
            PressKey(key)
            used = true
        end
    elseif mode == "Melee" then
        if CurrentTarget and CurrentTarget:FindFirstChild("HumanoidRootPart") then
            local dist = (hrp.Position - CurrentTarget.HumanoidRootPart.Position).Magnitude
            if dist <= 15 then
                PressKey(key)
                used = true
            end
        end
    elseif mode == "Ranged" then
        if CurrentTarget and CurrentTarget:FindFirstChild("HumanoidRootPart") then
            local targetPos = CurrentTarget.HumanoidRootPart.Position
            local dist = (hrp.Position - targetPos).Magnitude
            
            if dist <= 75 then
                -- Calculate Y offset. If target is significantly higher/lower, include Y in lookAt
                local yOffset = math.abs(hrp.Position.Y - targetPos.Y)
                if yOffset > 2 then
                    hrp.CFrame = CFrame.lookAt(hrp.Position, targetPos)
                else
                    hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z))
                end
                PressKey(key)
                used = true
            end
        end
    end

    if used then
        return tick()
    end
    return lastUsedTimeRef
end

task.spawn(function()
    while true do
        if AutoAbilityActive then
            LastFirstUsed = HandleAbilityLogic(FirstAbilityMode, Enum.KeyCode.Q, FirstAbilityCooldown, LastFirstUsed)
            LastSecondUsed = HandleAbilityLogic(SecondAbilityMode, Enum.KeyCode.E, SecondAbilityCooldown, LastSecondUsed)
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        if KillRadiusActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if not CurrentTarget or not CurrentTarget.Parent or not CurrentTarget:FindFirstChild("Humanoid") or CurrentTarget.Humanoid.Health <= 0 then
                CurrentTarget = GetNearestEnemy()
            end
            
            if CurrentTarget then
                local targetPart = CurrentTarget:FindFirstChild("HumanoidRootPart")
                local character = LocalPlayer.Character
                local myPart = character.HumanoidRootPart
                local myHum = character:FindFirstChildOfClass("Humanoid")
                
                if MovementMethod == "Teleport" then
                    myPart.CFrame = targetPart.CFrame * CFrame.new(0, 0, 3)
                    Click()
                elseif MovementMethod == "Tween" then
                    local distance = (myPart.Position - targetPart.Position).Magnitude
                    local duration = distance / TweenSpeed
                    local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(myPart, info, {CFrame = targetPart.CFrame * CFrame.new(0, 0, 3)})
                    tween:Play()
                    if distance < 10 then Click() end
                elseif MovementMethod == "Pathfind" then
                    if myHum and myHum.SeatPart then
                        myHum.Sit = false
                        task.wait(0.1)
                    end

                    local path = PathfindingService:CreatePath({AgentCanJump = true, AgentRadius = 3, AgentHeight = 6})
                    local success, response = pcall(function()
                        path:ComputeAsync(myPart.Position, targetPart.Position)
                    end)

                    if success and path.Status == Enum.PathStatus.Success then
                        local waypoints = path:GetWaypoints()
                        for i, waypoint in ipairs(waypoints) do
                            if not KillRadiusActive or not CurrentTarget or CurrentTarget.Humanoid.Health <= 0 or MovementMethod ~= "Pathfind" then break end
                            
                            myHum:MoveTo(waypoint.Position)
                            
                            local timeout = 0
                            repeat
                                if not myPart or not waypoint then break end
                                local dist = (waypoint.Position - myPart.Position).Magnitude
                                timeout = timeout + 1
                                task.wait()
                            until dist <= 4 or not KillRadiusActive or timeout > 100
                            
                            if (myPart.Position - targetPart.Position).Magnitude < 12 then 
                                Click()
                                break 
                            end
                        end
                    else
                        myHum:MoveTo(targetPart.Position)
                        if (myPart.Position - targetPart.Position).Magnitude < 10 then Click() end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

CombatTab:CreateToggle({
   Name = "KillRadius",
   CurrentValue = false,
   Flag = "KillRadiusToggle",
   Callback = function(Value)
      KillRadiusActive = Value
      if not Value then 
          CurrentTarget = nil 
          if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
              LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):MoveTo(LocalPlayer.Character.HumanoidRootPart.Position)
          end
      end
   end,
})

CombatTab:CreateDropdown({
   Name = "Movement Method",
   Options = {"Tween", "Teleport", "Pathfind"},
   CurrentOption = {"Tween"},
   MultipleOptions = false,
   Flag = "MethodDropdown",
   Callback = function(Options)
      MovementMethod = Options[1]
   end,
})

CombatTab:CreateSlider({
   Name = "Tween Speed",
   Range = {10, 500},
   Increment = 5,
   Suffix = "Studs/sec",
   CurrentValue = 50,
   Flag = "SpeedSlider",
   Callback = function(Value)
      TweenSpeed = Value
   end,
})

CombatTab:CreateSection("Abilities")

CombatTab:CreateToggle({
    Name = "Auto-Ability",
    CurrentValue = false,
    Flag = "AutoAbilityToggle",
    Callback = function(Value)
        AutoAbilityActive = Value
    end,
})

CombatTab:CreateDropdown({
    Name = "First Ability (Q)",
    Options = {"Healing", "Ranged", "Melee", "Unused Ability"},
    CurrentOption = {"Unused Ability"},
    MultipleOptions = false,
    Flag = "FirstAbility",
    Callback = function(Options)
        FirstAbilityMode = Options[1]
    end,
})

CombatTab:CreateSlider({
    Name = "First Ability Cooldown",
    Range = {0.1, 10},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 1,
    Flag = "FirstCooldown",
    Callback = function(Value)
        FirstAbilityCooldown = Value
    end,
})

CombatTab:CreateDropdown({
    Name = "Second Ability (E)",
    Options = {"Healing", "Ranged", "Melee", "Unused Ability"},
    CurrentOption = {"Unused Ability"},
    MultipleOptions = false,
    Flag = "SecondAbility",
    Callback = function(Options)
        SecondAbilityMode = Options[1]
    end,
})

CombatTab:CreateSlider({
    Name = "Second Ability Cooldown",
    Range = {0.1, 10},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 1,
    Flag = "SecondCooldown",
    Callback = function(Value)
        SecondAbilityCooldown = Value
    end,
})

VisualsTab:CreateToggle({
   Name = "Locate Enemies",
   CurrentValue = false,
   Flag = "LocateToggle",
   Callback = function(Value)
      LocateEnemiesActive = Value
   end,
})

RunService.RenderStepped:Connect(function()
    local DungeonFolder = workspace:FindFirstChild("dungeon")
    if not DungeonFolder then return end
    
    for _, descendant in ipairs(DungeonFolder:GetDescendants()) do
        if descendant:IsA("Model") then
            local highlight = descendant:FindFirstChild("ReflexHighlight")
            if LocateEnemiesActive then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ReflexHighlight"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.Parent = descendant
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end)
