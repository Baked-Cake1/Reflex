local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
Name = "Reflex | Escape Waves for Brainrots",
Icon = 0,
LoadingTitle = "Reflex",
LoadingSubtitle = "Loading...",
ShowText = "Reflex",
Theme = "DarkBlue",
ToggleUIKeybind = Enum.KeyCode.RightControl,
DisableRayfieldPrompts = false,
DisableBuildWarnings = false,
ConfigurationSaving = {
Enabled = true,
FolderName = "ReflexEWfB",
FileName = "EscapeWaves"
},
Discord = {
Enabled = false,
Invite = "noinvitelink",
RememberJoins = true
},
KeySystem = false
})

local MainTab = Window:CreateTab("Home", 4483362458)
local InfoSection = MainTab:CreateSection("Base Detection")

local player = game.Players.LocalPlayer
local userId = player.UserId
local basesFolder = workspace:FindFirstChild("Bases")
local myBaseModel = nil
local myBaseName = nil

if basesFolder then
for _, model in ipairs(basesFolder:GetChildren()) do
if model:IsA("Model") then
local holderAttr = model:GetAttribute("Holder")
if tostring(holderAttr) == tostring(userId) then
myBaseModel = model
myBaseName = model.Name
MainTab:CreateLabel("Detected Base: " .. myBaseName, 4483362458, Color3.fromRGB(255, 255, 255), false)
Rayfield:Notify({
Title = "Base Found!",
Content = "Successfully located base: " .. myBaseName,
Duration = 5,
Image = 4483362458,
})
end
end
end
else
MainTab:CreateLabel("Bases folder not found in Workspace", 4483362458, Color3.fromRGB(255, 0, 0), false)
end

local TeleportSection = MainTab:CreateSection("Teleports")

local TweenEnabled = false
local TweenSpeed = 50

local TPButton = MainTab:CreateButton({
Name = "Teleport to Base",
Callback = function()
if myBaseModel then
local spawnPart = myBaseModel:FindFirstChild("Spawn", true)
if spawnPart and spawnPart:IsA("BasePart") then
local character = player.Character
if character and character:FindFirstChild("HumanoidRootPart") then
if TweenEnabled then
local distance = (character.HumanoidRootPart.Position - spawnPart.Position).Magnitude
local duration = distance / TweenSpeed
local tweenService = game:GetService("TweenService")
local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
local tween = tweenService:Create(character.HumanoidRootPart, info, {CFrame = spawnPart.CFrame + Vector3.new(0, 3, 0)})
tween:Play()
else
character.HumanoidRootPart.CFrame = spawnPart.CFrame + Vector3.new(0, 3, 0)
end
Rayfield:Notify({
Title = "Success",
Content = "Moving to base spawn!",
Duration = 3,
Image = 4483362458,
})
end
else
Rayfield:Notify({
Title = "Error",
Content = "Spawn part not found in base!",
Duration = 5,
Image = 4483362458,
})
end
else
Rayfield:Notify({
Title = "Error",
Content = "No base detected!",
Duration = 5,
Image = 4483362458,
})
end
end,
})

local TweenToggle = MainTab:CreateToggle({
Name = "Tween",
CurrentValue = false,
Flag = "TweenToggle1",
Callback = function(Value)
TweenEnabled = Value
end,
})

local SpeedSlider = MainTab:CreateSlider({
Name = "Tween Speed",
Range = {10, 250},
Increment = 5,
Suffix = "Studs/sec",
CurrentValue = 50,
Flag = "SpeedSlider1",
Callback = function(Value)
TweenSpeed = Value
end,
})

local MapSection = MainTab:CreateSection("Map Modification")

local DeleteWalls = MainTab:CreateButton({
Name = "Delete VIP Walls",
Callback = function()
local walls = workspace:FindFirstChild("DefaultMap_SharedInstances") and workspace.DefaultMap_SharedInstances:FindFirstChild("VIPWalls")
if walls then
walls:Destroy()
Rayfield:Notify({
Title = "Success",
Content = "VIP Walls have been deleted!",
Duration = 3,
Image = 4483362458,
})
else
Rayfield:Notify({
Title = "Error",
Content = "VIP Walls not found or already deleted!",
Duration = 5,
Image = 4483362458,
})
end
end,
})

local UpgradeSection = MainTab:CreateSection("Upgrades")

local BuySpeed1 = MainTab:CreateButton({
Name = "Buy Speed +1",
Callback = function()
local args = {1}
game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("UpgradeSpeed"):InvokeServer(unpack(args))
end,
})

local BuySpeed10 = MainTab:CreateButton({
Name = "Buy Speed +10",
Callback = function()
local args = {10}
game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("UpgradeSpeed"):InvokeServer(unpack(args))
end,
})

local BuyCarry = MainTab:CreateButton({
Name = "Buy Carry Upgrade",
Callback = function()
game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("UpgradeCarry"):InvokeServer()
end,
})

local CollectSection = MainTab:CreateSection("Automation")
local AutoCollectEnabled = false

local Toggle = MainTab:CreateToggle({
Name = "Auto-Collect",
CurrentValue = false,
Flag = "AutoCollect1",
Callback = function(Value)
AutoCollectEnabled = Value
if AutoCollectEnabled and myBaseName then
task.spawn(function()
while AutoCollectEnabled do
for i = 1, 40 do
if not AutoCollectEnabled then break end
local args = {
"Collect Money",
myBaseName,
i
}
game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("Networking"):WaitForChild("RF/PlotAction"):InvokeServer(unpack(args))
if i % 10 == 0 then
task.wait(1)
end
end
task.wait(0.1)
end
end)
elseif not myBaseName and Value then
Rayfield:Notify({
Title = "Error",
Content = "No base detected to collect from!",
Duration = 5,
Image = 4483362458,
})
end
end,
})
