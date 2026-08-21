local repo = 'https://raw.githubusercontent.com/KingScriptAE/No-sirve-nada./refs/heads/main/'

-- 加载库文件
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- 获取服务
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- 创建主窗口
local Window = Library:CreateWindow({
    Title = "通用脚本",
    Footer = "Universal Script",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

-- 创建标签页
local Tabs = {
    ESP = Window:AddTab("ESP透视", "eye"),
    Aimbot = Window:AddTab("自瞄", "crosshair"),
    Basic = Window:AddTab("基本功能", "settings"),
    Crosshair = Window:AddTab("准心", "target"),
    Settings = Window:AddTab("设置", "settings"),
}

-- ============================================================
-- 颜色系统（修复版）
-- ============================================================

local ColorSystem = {
    CurrentRainbowHue = 0,
    Colors = {
        ["红色"] = Color3.fromRGB(255, 0, 0),
        ["Red"] = Color3.fromRGB(255, 0, 0),
        ["绿色"] = Color3.fromRGB(0, 255, 0),
        ["Green"] = Color3.fromRGB(0, 255, 0),
        ["蓝色"] = Color3.fromRGB(0, 0, 255),
        ["Blue"] = Color3.fromRGB(0, 0, 255),
        ["青色"] = Color3.fromRGB(0, 255, 255),
        ["Cyan"] = Color3.fromRGB(0, 255, 255),
        ["黑色"] = Color3.fromRGB(0, 0, 0),
        ["Black"] = Color3.fromRGB(0, 0, 0),
        ["白色"] = Color3.fromRGB(255, 255, 255),
        ["White"] = Color3.fromRGB(255, 255, 255),
        ["彩虹"] = Color3.fromRGB(255, 0, 0),
        ["Rainbow"] = Color3.fromRGB(255, 0, 0),
        ["团队"] = Color3.fromRGB(255, 255, 255),
        ["Team"] = Color3.fromRGB(255, 255, 255),
    }
}

local function GetRainbowColor()
    ColorSystem.CurrentRainbowHue = (ColorSystem.CurrentRainbowHue + 0.005) % 1
    return Color3.fromHSV(ColorSystem.CurrentRainbowHue, 1, 1)
end

local function GetColor(colorName)
    if not colorName then
        return Color3.fromRGB(255, 255, 255)
    end
    
    if colorName == "彩虹" or colorName == "Rainbow" then
        return GetRainbowColor()
    end
    
    local color = ColorSystem.Colors[colorName]
    if color then
        return color
    end
    
    -- 如果找不到颜色，返回白色作为默认值
    return Color3.fromRGB(255, 255, 255)
end

-- 特殊处理团队颜色的函数
local function GetESPColor(colorName, player)
    if colorName == "团队" or colorName == "Team" then
        if player and player.Team then
            return player.Team.TeamColor.Color
        end
        return Color3.fromRGB(255, 0, 0)
    end
    return GetColor(colorName)
end

-- ============================================================
-- 飞行GUI
-- ============================================================

local flyGui = nil
local nowe = false
local tpwalking = false
local player = LocalPlayer
local camera = Camera

local function restoreCharacter()
    nowe = false
    tpwalking = false
    local sp = player
    if sp.Character then
        for _, v in ipairs(sp.Character:GetDescendants()) do
            if v:IsA("BodyGyro") or v:IsA("BodyVelocity") or v:IsA("BodyPosition") then
                v:Destroy()
            end
        end
        local hum = sp.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            for _, s in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
                hum:SetStateEnabled(s, true)
            end
            hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        end
        if sp.Character:FindFirstChild("Animate") then
            sp.Character.Animate.Disabled = false
        end
    end
end

local function openFlyGUI()
    if flyGui then flyGui:Destroy() end
    
    local main = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local up = Instance.new("TextButton")
    local down = Instance.new("TextButton")
    local onof = Instance.new("TextButton")
    local TextLabel = Instance.new("TextLabel")
    local plus = Instance.new("TextButton")
    local speed = Instance.new("TextLabel")
    local mine = Instance.new("TextButton")
    local closebutton = Instance.new("TextButton")
    local mini = Instance.new("TextButton")
    local mini2 = Instance.new("TextButton")

    main.Name = "main"
    local success = pcall(function()
        main.Parent = game:GetService("CoreGui")
    end)
    if not success then
        main.Parent = player:WaitForChild("PlayerGui")
    end
    main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    main.ResetOnSpawn = false

    Frame.Parent = main
    Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Frame.BorderColor3 = Color3.fromRGB(103, 221, 213)
    Frame.Position = UDim2.new(0.1, 0, 0.38, 0)
    Frame.Size = UDim2.new(0, 190, 0, 57)

    up.Name = "up"
    up.Parent = Frame
    up.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    up.Size = UDim2.new(0, 44, 0, 28)
    up.Font = Enum.Font.SourceSans
    up.Text = "上升"
    up.TextColor3 = Color3.fromRGB(0, 0, 0)
    up.TextSize = 14

    down.Name = "down"
    down.Parent = Frame
    down.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    down.Position = UDim2.new(0, 0, 0.49, 0)
    down.Size = UDim2.new(0, 44, 0, 28)
    down.Font = Enum.Font.SourceSans
    down.Text = "下降"
    down.TextColor3 = Color3.fromRGB(0, 0, 0)
    down.TextSize = 14

    onof.Name = "onof"
    onof.Parent = Frame
    onof.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    onof.Position = UDim2.new(0.7, 0, 0.49, 0)
    onof.Size = UDim2.new(0, 56, 0, 28)
    onof.Font = Enum.Font.SourceSans
    onof.Text = "窗飞行"
    onof.TextColor3 = Color3.fromRGB(0, 0, 0)
    onof.TextSize = 14

    TextLabel.Parent = Frame
    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.Position = UDim2.new(0.47, 0, 0, 0)
    TextLabel.Size = UDim2.new(0, 100, 0, 28)
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.Text = "窗飞行"
    TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.TextScaled = true
    TextLabel.TextSize = 14
    TextLabel.TextWrapped = true

    plus.Name = "plus"
    plus.Parent = Frame
    plus.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    plus.Position = UDim2.new(0.23, 0, 0, 0)
    plus.Size = UDim2.new(0, 45, 0, 28)
    plus.Font = Enum.Font.SourceSans
    plus.Text = "+"
    plus.TextColor3 = Color3.fromRGB(0, 0, 0)
    plus.TextScaled = true
    plus.TextSize = 14
    plus.TextWrapped = true

    speed.Name = "speed"
    speed.Parent = Frame
    speed.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    speed.Position = UDim2.new(0.47, 0, 0.49, 0)
    speed.Size = UDim2.new(0, 44, 0, 28)
    speed.Font = Enum.Font.SourceSans
    speed.Text = "1"
    speed.TextColor3 = Color3.fromRGB(0, 0, 0)
    speed.TextScaled = true
    speed.TextSize = 14
    speed.TextWrapped = true

    mine.Name = "mine"
    mine.Parent = Frame
    mine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    mine.Position = UDim2.new(0.23, 0, 0.49, 0)
    mine.Size = UDim2.new(0, 45, 0, 29)
    mine.Font = Enum.Font.SourceSans
    mine.Text = "-"
    mine.TextColor3 = Color3.fromRGB(0, 0, 0)
    mine.TextScaled = true
    mine.TextSize = 14
    mine.TextWrapped = true

    closebutton.Name = "Close"
    closebutton.Parent = Frame
    closebutton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    closebutton.Font = "SourceSans"
    closebutton.Size = UDim2.new(0, 45, 0, 28)
    closebutton.Text = "x"
    closebutton.TextColor3 = Color3.fromRGB(0, 0, 0)
    closebutton.TextSize = 30
    closebutton.Position = UDim2.new(0, 0, -1, 27)

    mini.Name = "minimize"
    mini.Parent = Frame
    mini.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    mini.Font = "SourceSans"
    mini.Size = UDim2.new(0, 45, 0, 28)
    mini.Text = "-"
    mini.TextColor3 = Color3.fromRGB(0, 0, 0)
    mini.TextSize = 40
    mini.Position = UDim2.new(0, 44, -1, 27)

    mini2.Name = "minimize2"
    mini2.Parent = Frame
    mini2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    mini2.Font = "SourceSans"
    mini2.Size = UDim2.new(0, 45, 0, 28)
    mini2.Text = "+"
    mini2.TextColor3 = Color3.fromRGB(0, 0, 0)
    mini2.TextSize = 40
    mini2.Position = UDim2.new(0, 44, -1, 57)
    mini2.Visible = false

    local speeds = 1
    Frame.Active = true
    Frame.Draggable = true

    -- 飞行开关
    onof.MouseButton1Down:Connect(function()
        if nowe then
            restoreCharacter()
            return
        end
        if not player.Character then return end
        nowe = true
        tpwalking = true
        
        for i = 1, speeds do
            spawn(function()
                local hb = RunService.Heartbeat
                while tpwalking and hb:Wait() and player.Character do
                    local chr = player.Character
                    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                    if hum and hum.MoveDirection.Magnitude > 0 then
                        chr:TranslateBy(hum.MoveDirection)
                    end
                end
            end)
        end
        
        if player.Character then
            if player.Character:FindFirstChild("Animate") then
                player.Character.Animate.Disabled = true
            end
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                for _, s in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
                    hum:SetStateEnabled(s, false)
                end
                hum:ChangeState(Enum.HumanoidStateType.Swimming)
            end
        end
        
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local torso = hum and hum.RigType == Enum.HumanoidRigType.R6 and player.Character:FindFirstChild("Torso") or (hum and player.Character:FindFirstChild("UpperTorso"))
            
            if hum and torso then
                local ctrl = {f = 0, b = 0, l = 0, r = 0}
                local lastctrl = {f = 0, b = 0, l = 0, r = 0}
                local maxspeed = 50
                local spd = 0
                
                local bg = Instance.new("BodyGyro", torso)
                bg.P = 9e4
                bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                bg.cframe = torso.CFrame
                
                local bv = Instance.new("BodyVelocity", torso)
                bv.velocity = Vector3.new(0, 0.1, 0)
                bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
                
                if nowe then
                    hum.PlatformStand = true
                end
                
                while nowe and player.Character and hum and hum.Health > 0 do
                    wait()
                    if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                        spd = spd + 0.5 + (spd / maxspeed)
                        if spd > maxspeed then spd = maxspeed end
                    elseif spd ~= 0 then
                        spd = spd - 1
                        if spd < 0 then spd = 0 end
                    end
                    
                    if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                        bv.velocity = ((camera.CFrame.LookVector * (ctrl.f + ctrl.b)) + ((camera.CFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) - camera.CFrame.p)) * spd
                        lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
                    elseif spd ~= 0 then
                        bv.velocity = ((camera.CFrame.LookVector * (lastctrl.f + lastctrl.b)) + ((camera.CFrame * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * 0.2, 0).p) - camera.CFrame.p)) * spd
                    else
                        bv.velocity = Vector3.new(0, 0, 0)
                    end
                    
                    bg.cframe = camera.CFrame * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * spd / maxspeed), 0, 0)
                end
                
                bg:Destroy()
                bv:Destroy()
            end
        end
    end)

    -- 上升按钮
    local tis
    up.MouseButton1Down:Connect(function()
        tis = RunService.Heartbeat:Connect(function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame * CFrame.new(0, 1, 0)
            end
        end)
    end)
    up.MouseLeave:Connect(function()
        if tis then tis:Disconnect(); tis = nil end
    end)
    up.MouseButton1Up:Connect(function()
        if tis then tis:Disconnect(); tis = nil end
    end)

    -- 下降按钮
    local dis
    down.MouseButton1Down:Connect(function()
        dis = RunService.Heartbeat:Connect(function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame * CFrame.new(0, -1, 0)
            end
        end)
    end)
    down.MouseLeave:Connect(function()
        if dis then dis:Disconnect(); dis = nil end
    end)
    down.MouseButton1Up:Connect(function()
        if dis then dis:Disconnect(); dis = nil end
    end)

    -- 加速度
    plus.MouseButton1Down:Connect(function()
        speeds = speeds + 1
        speed.Text = speeds
        if nowe then
            tpwalking = false
            for i = 1, speeds do
                spawn(function()
                    local hb = RunService.Heartbeat
                    tpwalking = true
                    while tpwalking and hb:Wait() and player.Character do
                        local chr = player.Character
                        local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                        if hum and hum.MoveDirection.Magnitude > 0 then
                            chr:TranslateBy(hum.MoveDirection)
                        end
                    end
                end)
            end
        end
    end)

    -- 减速度
    mine.MouseButton1Down:Connect(function()
        if speeds == 1 then
            speed.Text = '不能小于1'
            wait(1)
            speed.Text = speeds
        else
            speeds = speeds - 1
            speed.Text = speeds
            if nowe then
                tpwalking = false
                for i = 1, speeds do
                    spawn(function()
                        local hb = RunService.Heartbeat
                        tpwalking = true
                        while tpwalking and hb:Wait() and player.Character do
                            local chr = player.Character
                            local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                            if hum and hum.MoveDirection.Magnitude > 0 then
                                chr:TranslateBy(hum.MoveDirection)
                            end
                        end
                    end)
                end
            end
        end
    end)

    -- 关闭按钮
    closebutton.MouseButton1Click:Connect(function()
        restoreCharacter()
        main:Destroy()
        flyGui = nil
    end)

    -- 最小化按钮
    mini.MouseButton1Click:Connect(function()
        up.Visible = false
        down.Visible = false
        onof.Visible = false
        plus.Visible = false
        speed.Visible = false
        mine.Visible = false
        mini.Visible = false
        mini2.Visible = true
        Frame.BackgroundTransparency = 1
        closebutton.Position = UDim2.new(0, 0, -1, 57)
    end)

    -- 恢复按钮
    mini2.MouseButton1Click:Connect(function()
        up.Visible = true
        down.Visible = true
        onof.Visible = true
        plus.Visible = true
        speed.Visible = true
        mine.Visible = true
        mini.Visible = true
        mini2.Visible = false
        Frame.BackgroundTransparency = 0
        closebutton.Position = UDim2.new(0, 0, -1, 27)
    end)

    flyGui = main
end

-- 角色重生时恢复状态
player.CharacterAdded:Connect(function(char)
    task.wait(0.7)
    if nowe then
        restoreCharacter()
    end
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.PlatformStand = false
    end
    if char and char:FindFirstChild("Animate") then
        char.Animate.Disabled = false
    end
end)

-- ============================================================
-- ESP 透视功能（增强版）
-- ============================================================

local ESPEnabled = false
local ESPObjects = {}
local FriendCache = {}

local ESPConfig = {
    Boxes = true,
    Names = true,
    Distance = true,
    HealthBar = true,
    Tracers = false,
    Bones = false,
    HeadDot = false,
    MaxDistance = 500,
    Highlight = false,
    Glow = false,
    HighlightColor = "红色",
    TracerThickness = 1,
    TracerTransparency = 1,
    TracerColor = "白色",
    BoneColor = "白色",
    HeadDotColor = "红色",
    BoxColor = "团队",
    WallCheck = false,
    ShowPlayerCount = true,
    ShowTeam = true,
    TeamCheck = false,
    FriendCheck = false,
    AliveCheck = true,
    HeadDotSize = 8,
}

local highlightCache = {}
local glowCache = {}

local function GetTeamColor(player)
    if player.Team then
        return player.Team.TeamColor.Color
    end
    return Color3.fromRGB(255, 0, 0)
end

local function GetTeamName(player)
    if player.Team then
        return player.Team.Name
    end
    return "无队伍"
end

local function IsFriend(player)
    if FriendCache[player.UserId] ~= nil then
        return FriendCache[player.UserId]
    end
    
    local success, result = pcall(function()
        return player:IsFriendsWith(LocalPlayer.UserId)
    end)
    
    if success then
        FriendCache[player.UserId] = result
        return result
    end
    
    return false
end

local function ShouldShowPlayer(player)
    if ESPConfig.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return false
    end
    
    if ESPConfig.FriendCheck and IsFriend(player) then
        return false
    end
    
    return true
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Transparency = 1
    box.Color = GetTeamColor(player)
    box.Filled = false
    box.Visible = false
    
    local nameText = Drawing.new("Text")
    nameText.Size = 14
    nameText.Center = true
    nameText.Outline = true
    nameText.Color = Color3.fromRGB(255, 255, 255)
    nameText.Visible = false
    nameText.Text = player.Name
    
    local distanceText = Drawing.new("Text")
    distanceText.Size = 12
    distanceText.Center = true
    distanceText.Outline = true
    distanceText.Color = Color3.fromRGB(150, 150, 255)
    distanceText.Visible = false
    
    local healthBar = Drawing.new("Line")
    healthBar.Thickness = 3
    healthBar.Color = Color3.fromRGB(0, 255, 0)
    healthBar.Visible = false
    
    local tracer = Drawing.new("Line")
    tracer.Thickness = ESPConfig.TracerThickness
    tracer.Color = GetColor(ESPConfig.TracerColor)
    tracer.Transparency = ESPConfig.TracerTransparency
    tracer.Visible = false
    
    local headDot = Drawing.new("Circle")
    headDot.Radius = ESPConfig.HeadDotSize
    headDot.Filled = true
    headDot.Color = GetColor(ESPConfig.HeadDotColor)
    headDot.Visible = false
    
    local bones = {}
    local boneConnections = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"},
    }
    
    for _ = 1, #boneConnections do
        local line = Drawing.new("Line")
        line.Thickness = 2
        line.Color = GetColor(ESPConfig.BoneColor)
        line.Visible = false
        table.insert(bones, line)
    end
    
    ESPObjects[player] = {
        Box = box,
        NameText = nameText,
        DistanceText = distanceText,
        HealthBar = healthBar,
        Tracer = tracer,
        HeadDot = headDot,
        Bones = bones,
        BoneConnections = boneConnections,
    }
end

local function IsWallBetween(pointA, pointB)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, workspace.CurrentCamera}
    
    local direction = (pointB - pointA).Unit
    local distance = (pointB - pointA).Magnitude
    
    local raycastResult = workspace:Raycast(pointA, direction * distance, raycastParams)
    
    if raycastResult then
        return true
    end
    return false
end

local function ApplyHighlight(player, character)
    if ESPConfig.Highlight and ESPEnabled and character then
        if not highlightCache[player] then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESPHighlight"
            highlight.FillColor = GetColor(ESPConfig.HighlightColor)
            highlight.OutlineColor = GetColor(ESPConfig.HighlightColor)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = character
            highlightCache[player] = highlight
        else
            local highlight = highlightCache[player]
            highlight.FillColor = GetColor(ESPConfig.HighlightColor)
            highlight.OutlineColor = GetColor(ESPConfig.HighlightColor)
            highlight.Parent = character
        end
    else
        if highlightCache[player] then
            highlightCache[player]:Destroy()
            highlightCache[player] = nil
        end
    end
end

local function ApplyGlow(player, character)
    if ESPConfig.Glow and ESPEnabled and character then
        if not glowCache[player] then
            local glowParts = {}
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    local originalColor = part.Color
                    local originalMaterial = part.Material
                    part.Material = Enum.Material.Neon
                    part.Color = GetColor(ESPConfig.HighlightColor)
                    table.insert(glowParts, {part = part, originalColor = originalColor, originalMaterial = originalMaterial})
                end
            end
            glowCache[player] = glowParts
        else
            for _, glowData in pairs(glowCache[player]) do
                glowData.part.Material = Enum.Material.Neon
                glowData.part.Color = GetColor(ESPConfig.HighlightColor)
            end
        end
    else
        if glowCache[player] then
            for _, glowData in pairs(glowCache[player]) do
                if glowData.part then
                    glowData.part.Material = glowData.originalMaterial
                    glowData.part.Color = glowData.originalColor
                end
            end
            glowCache[player] = nil
        end
    end
end

local function UpdateESP()
    local localCharacter = LocalPlayer.Character
    if not localCharacter then return end
    
    local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    
    local visiblePlayers = 0
    
    for player, espData in pairs(ESPObjects) do
        local character = player.Character
        if not character then
            espData.Box.Visible = false
            espData.NameText.Visible = false
            espData.DistanceText.Visible = false
            espData.HealthBar.Visible = false
            espData.Tracer.Visible = false
            espData.HeadDot.Visible = false
            for _, bone in pairs(espData.Bones) do
                bone.Visible = false
            end
            ApplyHighlight(player, nil)
            ApplyGlow(player, nil)
            continue
        end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        local head = character:FindFirstChild("Head")
        
        if not humanoidRootPart or not humanoid or not head or humanoid.Health <= 0 then
            espData.Box.Visible = false
            espData.NameText.Visible = false
            espData.DistanceText.Visible = false
            espData.HealthBar.Visible = false
            espData.Tracer.Visible = false
            espData.HeadDot.Visible = false
            for _, bone in pairs(espData.Bones) do
                bone.Visible = false
            end
            ApplyHighlight(player, nil)
            ApplyGlow(player, nil)
            continue
        end
        
        if ESPConfig.AliveCheck and humanoid.Health <= 0 then
            espData.Box.Visible = false
            espData.NameText.Visible = false
            espData.DistanceText.Visible = false
            espData.HealthBar.Visible = false
            espData.Tracer.Visible = false
            espData.HeadDot.Visible = false
            for _, bone in pairs(espData.Bones) do
                bone.Visible = false
            end
            ApplyHighlight(player, nil)
            ApplyGlow(player, nil)
            continue
        end
        
        if not ShouldShowPlayer(player) then
            espData.Box.Visible = false
            espData.NameText.Visible = false
            espData.DistanceText.Visible = false
            espData.HealthBar.Visible = false
            espData.Tracer.Visible = false
            espData.HeadDot.Visible = false
            for _, bone in pairs(espData.Bones) do
                bone.Visible = false
            end
            ApplyHighlight(player, nil)
            ApplyGlow(player, nil)
            continue
        end
        
        local headScreenPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
        local distance = (localRoot.Position - humanoidRootPart.Position).Magnitude
        
        local wallBlocked = false
        if ESPConfig.WallCheck then
            wallBlocked = IsWallBetween(Camera.CFrame.Position, head.Position)
        end
        
        if headOnScreen and distance <= ESPConfig.MaxDistance and ESPEnabled and not wallBlocked then
            visiblePlayers = visiblePlayers + 1
            
            local boxHeight = math.clamp(4000 / distance, 30, 300)
            local boxWidth = math.clamp(2000 / distance, 15, 150)
            
            local boxColor = GetESPColor(ESPConfig.BoxColor, player)
            
            if ESPConfig.Boxes then
                espData.Box.Size = Vector2.new(boxWidth, boxHeight)
                espData.Box.Position = Vector2.new(headScreenPos.X - boxWidth / 2, headScreenPos.Y - boxHeight / 2)
                espData.Box.Color = boxColor
                espData.Box.Visible = true
            else
                espData.Box.Visible = false
            end
            
            local nameDisplay = player.Name
            if ESPConfig.ShowTeam then
                nameDisplay = nameDisplay .. " [" .. GetTeamName(player) .. "]"
            end
            
            if ESPConfig.Names then
                espData.NameText.Text = nameDisplay
                espData.NameText.Position = Vector2.new(headScreenPos.X, headScreenPos.Y - 25)
                espData.NameText.Visible = true
            else
                espData.NameText.Visible = false
            end
            
            if ESPConfig.Distance then
                espData.DistanceText.Text = string.format("%.1fm", distance)
                espData.DistanceText.Position = Vector2.new(headScreenPos.X, headScreenPos.Y + boxHeight / 2 + 10)
                espData.DistanceText.Visible = true
            else
                espData.DistanceText.Visible = false
            end
            
            if ESPConfig.HealthBar then
                local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                local barWidth = 50
                local barY = headScreenPos.Y - boxHeight / 2 - 10
                
                espData.HealthBar.From = Vector2.new(headScreenPos.X - barWidth / 2, barY)
                espData.HealthBar.To = Vector2.new(headScreenPos.X - barWidth / 2 + barWidth * healthPercent, barY)
                espData.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                espData.HealthBar.Visible = true
            else
                espData.HealthBar.Visible = false
            end
            
            if ESPConfig.Tracers then
                espData.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                espData.Tracer.To = Vector2.new(headScreenPos.X, headScreenPos.Y)
                espData.Tracer.Visible = true
                espData.Tracer.Thickness = ESPConfig.TracerThickness
                espData.Tracer.Transparency = ESPConfig.TracerTransparency
                espData.Tracer.Color = GetColor(ESPConfig.TracerColor)
            else
                espData.Tracer.Visible = false
            end
            
            if ESPConfig.HeadDot then
                espData.HeadDot.Radius = ESPConfig.HeadDotSize
                espData.HeadDot.Position = Vector2.new(headScreenPos.X, headScreenPos.Y)
                espData.HeadDot.Color = GetColor(ESPConfig.HeadDotColor)
                espData.HeadDot.Visible = true
            else
                espData.HeadDot.Visible = false
            end
            
            if ESPConfig.Bones then
                local boneColor = GetColor(ESPConfig.BoneColor)
                for i, connection in ipairs(espData.BoneConnections) do
                    local part1 = character:FindFirstChild(connection[1])
                    local part2 = character:FindFirstChild(connection[2])
                    
                    if part1 and part2 then
                        local pos1, onScreen1 = Camera:WorldToViewportPoint(part1.Position)
                        local pos2, onScreen2 = Camera:WorldToViewportPoint(part2.Position)
                        
                        if onScreen1 and onScreen2 then
                            espData.Bones[i].From = Vector2.new(pos1.X, pos1.Y)
                            espData.Bones[i].To = Vector2.new(pos2.X, pos2.Y)
                            espData.Bones[i].Color = boneColor
                            espData.Bones[i].Visible = true
                        else
                            espData.Bones[i].Visible = false
                        end
                    else
                        espData.Bones[i].Visible = false
                    end
                end
            else
                for _, bone in pairs(espData.Bones) do
                    bone.Visible = false
                end
            end
            
            ApplyHighlight(player, character)
            ApplyGlow(player, character)
        else
            espData.Box.Visible = false
            espData.NameText.Visible = false
            espData.DistanceText.Visible = false
            espData.HealthBar.Visible = false
            espData.Tracer.Visible = false
            espData.HeadDot.Visible = false
            for _, bone in pairs(espData.Bones) do
                bone.Visible = false
            end
            ApplyHighlight(player, nil)
            ApplyGlow(player, nil)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        CreateESP(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        ESPObjects[player].Box:Remove()
        ESPObjects[player].NameText:Remove()
        ESPObjects[player].DistanceText:Remove()
        ESPObjects[player].HealthBar:Remove()
        ESPObjects[player].Tracer:Remove()
        ESPObjects[player].HeadDot:Remove()
        for _, bone in pairs(ESPObjects[player].Bones) do
            bone:Remove()
        end
        ESPObjects[player] = nil
    end
    if highlightCache[player] then
        highlightCache[player]:Destroy()
        highlightCache[player] = nil
    end
    if glowCache[player] then
        for _, glowData in pairs(glowCache[player]) do
            if glowData.part then
                glowData.part.Material = glowData.originalMaterial
                glowData.part.Color = glowData.originalColor
            end
        end
        glowCache[player] = nil
    end
    FriendCache[player.UserId] = nil
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        task.spawn(function()
            task.wait(1)
            CreateESP(player)
        end)
    end
end

RunService.RenderStepped:Connect(function()
    UpdateESP()
end)

-- ============================================================
-- 自瞄功能（增强版）
-- ============================================================

local AimbotEnabled = false
local AimbotConfig = {
    Target = "Head",
    FOV = 200,
    Smoothness = 0.1,
    ShowFOV = true,
    Prediction = 0.15,
    TeamCheck = false,
    AimAtNPC = false,
    WallCheck = false,
    OffsetX = 0,
    OffsetY = 0,
    FOVColor = "白色",
    FOVTransparency = 1,
    FOVThickness = 1,
    SmoothAimbot = true,
    PredictionAimbot = false,
    PredictionTime = 0.15,
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = AimbotConfig.FOVThickness
FOVCircle.Transparency = AimbotConfig.FOVTransparency
FOVCircle.Color = GetColor(AimbotConfig.FOVColor)
FOVCircle.Radius = AimbotConfig.FOV
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCircle.Visible = false

local function GetNPCs()
    local npcs = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            local humanoid = obj:FindFirstChild("Humanoid")
            if humanoid.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                table.insert(npcs, obj)
            end
        end
    end
    return npcs
end

local function GetClosestPlayer()
    local closestPlayer = nil
    local closestDistance = AimbotConfig.FOV
    local closestIsNPC = false
    
    local localCharacter = LocalPlayer.Character
    if not localCharacter then return nil, false end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if AimbotConfig.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local head = character:FindFirstChild("Head")
                
                if humanoid and rootPart and head and humanoid.Health > 0 then
                    local targetPart = (AimbotConfig.Target == "Head") and head or rootPart
                    
                    if AimbotConfig.WallCheck then
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                        
                        local raycastResult = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 500, raycastParams)
                        if raycastResult and raycastResult.Instance ~= targetPart.Parent then
                            continue
                        end
                    end
                    
                    local screenPos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
                    
                    if onScreen then
                        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local distanceFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        
                        if distanceFromCenter <= closestDistance then
                            closestDistance = distanceFromCenter
                            closestPlayer = player
                            closestIsNPC = false
                        end
                    end
                end
            end
        end
    end
    
    if AimbotConfig.AimAtNPC then
        for _, npc in pairs(GetNPCs()) do
            local humanoid = npc:FindFirstChild("Humanoid")
            local rootPart = npc:FindFirstChild("HumanoidRootPart")
            local head = npc:FindFirstChild("Head")
            
            if humanoid and rootPart and head and humanoid.Health > 0 then
                local targetPart = (AimbotConfig.Target == "Head") and head or rootPart
                
                local screenPos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
                
                if onScreen then
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local distanceFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    
                    if distanceFromCenter <= closestDistance then
                        closestDistance = distanceFromCenter
                        closestPlayer = npc
                        closestIsNPC = true
                    end
                end
            end
        end
    end
    
    return closestPlayer, closestIsNPC
end

local function AimbotLoop()
    local target, isNPC = GetClosestPlayer()
    if not target then return end
    
    local targetCharacter = nil
    if isNPC then
        targetCharacter = target
    else
        targetCharacter = target.Character
    end
    
    if not targetCharacter then return end
    
    local targetPart = nil
    if AimbotConfig.Target == "Head" then
        targetPart = targetCharacter:FindFirstChild("Head")
    else
        targetPart = targetCharacter:FindFirstChild("HumanoidRootPart")
    end
    
    if not targetPart then return end
    
    local aimPosition = targetPart.Position
    
    if AimbotConfig.PredictionAimbot then
        local velocity = targetPart.Velocity or Vector3.new(0, 0, 0)
        aimPosition = aimPosition + velocity * AimbotConfig.PredictionTime
    end
    
    aimPosition = aimPosition + Vector3.new(AimbotConfig.OffsetX / 100, AimbotConfig.OffsetY / 100, 0)
    
    local targetDirection = (aimPosition - Camera.CFrame.Position).Unit
    
    if AimbotConfig.SmoothAimbot then
        local smoothDirection = Camera.CFrame.LookVector:Lerp(targetDirection, AimbotConfig.Smoothness)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + smoothDirection)
    else
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + targetDirection)
    end
end

RunService.RenderStepped:Connect(function()
    if AimbotConfig.ShowFOV and AimbotEnabled then
        FOVCircle.Visible = true
        FOVCircle.Radius = AimbotConfig.FOV
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Color = GetColor(AimbotConfig.FOVColor)
        FOVCircle.Transparency = AimbotConfig.FOVTransparency
        FOVCircle.Thickness = AimbotConfig.FOVThickness
    else
        FOVCircle.Visible = false
    end
    
    if AimbotEnabled then
        AimbotLoop()
    end
end)

-- ============================================================
-- 准心系统
-- ============================================================

local CrosshairConfig = {
    Enabled = false,
    Style = "十字",
    Size = 20,
    Gap = 10,
    Thickness = 2,
    Transparency = 1,
    Color = "白色",
    CrossGap = 10,
    DotSize = 5,
}

local crosshairDrawings = {}

local function CreateCrosshair()
    for _, drawing in pairs(crosshairDrawings) do
        drawing:Remove()
    end
    crosshairDrawings = {}
    
    if not CrosshairConfig.Enabled then return end
    
    local centerX = Camera.ViewportSize.X / 2
    local centerY = Camera.ViewportSize.Y / 2
    local size = CrosshairConfig.Size
    local gap = CrosshairConfig.Gap
    local thickness = CrosshairConfig.Thickness
    local transparency = CrosshairConfig.Transparency
    local color = GetColor(CrosshairConfig.Color)
    
    if CrosshairConfig.Style == "十字" then
        local line1 = Drawing.new("Line")
        line1.From = Vector2.new(centerX, centerY - gap)
        line1.To = Vector2.new(centerX, centerY - gap - size)
        line1.Thickness = thickness
        line1.Transparency = transparency
        line1.Color = color
        line1.Visible = true
        
        local line2 = Drawing.new("Line")
        line2.From = Vector2.new(centerX, centerY + gap)
        line2.To = Vector2.new(centerX, centerY + gap + size)
        line2.Thickness = thickness
        line2.Transparency = transparency
        line2.Color = color
        line2.Visible = true
        
        local line3 = Drawing.new("Line")
        line3.From = Vector2.new(centerX - gap, centerY)
        line3.To = Vector2.new(centerX - gap - size, centerY)
        line3.Thickness = thickness
        line3.Transparency = transparency
        line3.Color = color
        line3.Visible = true
        
        local line4 = Drawing.new("Line")
        line4.From = Vector2.new(centerX + gap, centerY)
        line4.To = Vector2.new(centerX + gap + size, centerY)
        line4.Thickness = thickness
        line4.Transparency = transparency
        line4.Color = color
        line4.Visible = true
        
        crosshairDrawings = {line1, line2, line3, line4}
        
    elseif CrosshairConfig.Style == "红点" then
        local dot = Drawing.new("Circle")
        dot.Position = Vector2.new(centerX, centerY)
        dot.Radius = CrosshairConfig.DotSize
        dot.Filled = true
        dot.Transparency = transparency
        dot.Color = color
        dot.Visible = true
        
        crosshairDrawings = {dot}
        
    elseif CrosshairConfig.Style == "圆圈" then
        local circle = Drawing.new("Circle")
        circle.Position = Vector2.new(centerX, centerY)
        circle.Radius = size / 2
        circle.Filled = false
        circle.Thickness = thickness
        circle.Transparency = transparency
        circle.Color = color
        circle.Visible = true
        
        crosshairDrawings = {circle}
        
    elseif CrosshairConfig.Style == "X型" then
        local line1 = Drawing.new("Line")
        line1.From = Vector2.new(centerX - gap, centerY - gap)
        line1.To = Vector2.new(centerX - gap - size, centerY - gap - size)
        line1.Thickness = thickness
        line1.Transparency = transparency
        line1.Color = color
        line1.Visible = true
        
        local line2 = Drawing.new("Line")
        line2.From = Vector2.new(centerX + gap, centerY + gap)
        line2.To = Vector2.new(centerX + gap + size, centerY + gap + size)
        line2.Thickness = thickness
        line2.Transparency = transparency
        line2.Color = color
        line2.Visible = true
        
        local line3 = Drawing.new("Line")
        line3.From = Vector2.new(centerX + gap, centerY - gap)
        line3.To = Vector2.new(centerX + gap + size, centerY - gap - size)
        line3.Thickness = thickness
        line3.Transparency = transparency
        line3.Color = color
        line3.Visible = true
        
        local line4 = Drawing.new("Line")
        line4.From = Vector2.new(centerX - gap, centerY + gap)
        line4.To = Vector2.new(centerX - gap - size, centerY + gap + size)
        line4.Thickness = thickness
        line4.Transparency = transparency
        line4.Color = color
        line4.Visible = true
        
        crosshairDrawings = {line1, line2, line3, line4}
        
    elseif CrosshairConfig.Style == "自定义" then
        local dot = Drawing.new("Circle")
        dot.Position = Vector2.new(centerX, centerY)
        dot.Radius = CrosshairConfig.DotSize
        dot.Filled = true
        dot.Transparency = transparency
        dot.Color = color
        dot.Visible = true
        
        local line1 = Drawing.new("Line")
        line1.From = Vector2.new(centerX - CrosshairConfig.CrossGap, centerY - CrosshairConfig.CrossGap)
        line1.To = Vector2.new(centerX - CrosshairConfig.CrossGap - size, centerY - CrosshairConfig.CrossGap - size)
        line1.Thickness = thickness
        line1.Transparency = transparency
        line1.Color = color
        line1.Visible = true
        
        local line2 = Drawing.new("Line")
        line2.From = Vector2.new(centerX + CrosshairConfig.CrossGap, centerY - CrosshairConfig.CrossGap)
        line2.To = Vector2.new(centerX + CrosshairConfig.CrossGap + size, centerY - CrosshairConfig.CrossGap - size)
        line2.Thickness = thickness
        line2.Transparency = transparency
        line2.Color = color
        line2.Visible = true
        
        local line3 = Drawing.new("Line")
        line3.From = Vector2.new(centerX - CrosshairConfig.CrossGap, centerY + CrosshairConfig.CrossGap)
        line3.To = Vector2.new(centerX - CrosshairConfig.CrossGap - size, centerY + CrosshairConfig.CrossGap + size)
        line3.Thickness = thickness
        line3.Transparency = transparency
        line3.Color = color
        line3.Visible = true
        
        local line4 = Drawing.new("Line")
        line4.From = Vector2.new(centerX + CrosshairConfig.CrossGap, centerY + CrosshairConfig.CrossGap)
        line4.To = Vector2.new(centerX + CrosshairConfig.CrossGap + size, centerY + CrosshairConfig.CrossGap + size)
        line4.Thickness = thickness
        line4.Transparency = transparency
        line4.Color = color
        line4.Visible = true
        
        crosshairDrawings = {dot, line1, line2, line3, line4}
    end
end

local function UpdateCrosshair()
    if not CrosshairConfig.Enabled then
        for _, drawing in pairs(crosshairDrawings) do
            drawing.Visible = false
        end
        return
    end
    
    local centerX = Camera.ViewportSize.X / 2
    local centerY = Camera.ViewportSize.Y / 2
    local size = CrosshairConfig.Size
    local gap = CrosshairConfig.Gap
    local thickness = CrosshairConfig.Thickness
    local transparency = CrosshairConfig.Transparency
    local color = GetColor(CrosshairConfig.Color)
    
    if CrosshairConfig.Style == "十字" and #crosshairDrawings == 4 then
        crosshairDrawings[1].From = Vector2.new(centerX, centerY - gap)
        crosshairDrawings[1].To = Vector2.new(centerX, centerY - gap - size)
        crosshairDrawings[2].From = Vector2.new(centerX, centerY + gap)
        crosshairDrawings[2].To = Vector2.new(centerX, centerY + gap + size)
        crosshairDrawings[3].From = Vector2.new(centerX - gap, centerY)
        crosshairDrawings[3].To = Vector2.new(centerX - gap - size, centerY)
        crosshairDrawings[4].From = Vector2.new(centerX + gap, centerY)
        crosshairDrawings[4].To = Vector2.new(centerX + gap + size, centerY)
        
        for _, drawing in pairs(crosshairDrawings) do
            drawing.Thickness = thickness
            drawing.Transparency = transparency
            drawing.Color = color
            drawing.Visible = true
        end
    elseif CrosshairConfig.Style == "红点" and #crosshairDrawings == 1 then
        crosshairDrawings[1].Position = Vector2.new(centerX, centerY)
        crosshairDrawings[1].Radius = CrosshairConfig.DotSize
        crosshairDrawings[1].Transparency = transparency
        crosshairDrawings[1].Color = color
        crosshairDrawings[1].Visible = true
    elseif CrosshairConfig.Style == "圆圈" and #crosshairDrawings == 1 then
        crosshairDrawings[1].Position = Vector2.new(centerX, centerY)
        crosshairDrawings[1].Radius = size / 2
        crosshairDrawings[1].Thickness = thickness
        crosshairDrawings[1].Transparency = transparency
        crosshairDrawings[1].Color = color
        crosshairDrawings[1].Visible = true
    elseif CrosshairConfig.Style == "X型" and #crosshairDrawings == 4 then
        crosshairDrawings[1].From = Vector2.new(centerX - gap, centerY - gap)
        crosshairDrawings[1].To = Vector2.new(centerX - gap - size, centerY - gap - size)
        crosshairDrawings[2].From = Vector2.new(centerX + gap, centerY + gap)
        crosshairDrawings[2].To = Vector2.new(centerX + gap + size, centerY + gap + size)
        crosshairDrawings[3].From = Vector2.new(centerX + gap, centerY - gap)
        crosshairDrawings[3].To = Vector2.new(centerX + gap + size, centerY - gap - size)
        crosshairDrawings[4].From = Vector2.new(centerX - gap, centerY + gap)
        crosshairDrawings[4].To = Vector2.new(centerX - gap - size, centerY + gap + size)
        
        for _, drawing in pairs(crosshairDrawings) do
            drawing.Thickness = thickness
            drawing.Transparency = transparency
            drawing.Color = color
            drawing.Visible = true
        end
    end
end

RunService.RenderStepped:Connect(function()
    UpdateCrosshair()
end)

-- ============================================================
-- 基本功能
-- ============================================================

local BasicConfig = {
    Speed = 16,
    JumpPower = 7.2,
    BulletTracking = false,
    Noclip = false,
    InfiniteJump = false,
}

local function ApplySpeed()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = BasicConfig.Speed
    end
end

local function ApplyJumpPower()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.JumpPower = BasicConfig.JumpPower
    end
end

local InfiniteJumpConnection = nil

local function EnableInfiniteJump()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if InfiniteJumpConnection then
        InfiniteJumpConnection:Disconnect()
    end
    
    InfiniteJumpConnection = humanoid.StateChanged:Connect(function(oldState, newState)
        if BasicConfig.InfiniteJump and newState == Enum.HumanoidStateType.Landed then
            task.wait(0.01)
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function DisableInfiniteJump()
    if InfiniteJumpConnection then
        InfiniteJumpConnection:Disconnect()
        InfiniteJumpConnection = nil
    end
end

local NoclipConnection = nil

local function EnableNoclip()
    if NoclipConnection then
        NoclipConnection:Disconnect()
    end
    
    NoclipConnection = RunService.Stepped:Connect(function()
        if BasicConfig.Noclip then
            local character = LocalPlayer.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end

local function DisableNoclip()
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    
    local character = LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

local function EnableBulletTracking()
    local function TrackBullets()
        for _, bullet in pairs(workspace:GetDescendants()) do
            if bullet:IsA("BasePart") and bullet.Name:lower():find("bullet") then
                local closestTarget = nil
                local closestDistance = 100
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        local character = player.Character
                        if character then
                            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                            if humanoidRootPart and humanoidRootPart.Position then
                                local distance = (bullet.Position - humanoidRootPart.Position).Magnitude
                                if distance < closestDistance then
                                    closestDistance = distance
                                    closestTarget = humanoidRootPart
                                end
                            end
                        end
                    end
                end
                
                if closestTarget then
                    bullet.Velocity = (closestTarget.Position - bullet.Position).Unit * bullet.Velocity.Magnitude
                end
            end
        end
    end
    
    if BasicConfig.BulletTracking then
        RunService.RenderStepped:Connect(TrackBullets)
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    ApplySpeed()
    ApplyJumpPower()
    
    if BasicConfig.Noclip then
        EnableNoclip()
    end
    
    if BasicConfig.InfiniteJump then
        EnableInfiniteJump()
    end
end)

-- ============================================================
-- ESP UI
-- ============================================================

local ESPGroup = Tabs.ESP:AddLeftGroupbox("ESP设置")

ESPGroup:AddToggle('ESPEnabled', {
    Text = '启用ESP',
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
    end
})

ESPGroup:AddToggle('ESPBoxes', {
    Text = '方框',
    Default = ESPConfig.Boxes,
    Callback = function(Value)
        ESPConfig.Boxes = Value
    end
})

ESPGroup:AddDropdown('ESPBoxColor', {
    Text = '方框颜色',
    Values = {'团队', '红色', '绿色', '蓝色', '彩虹', '青色', '黑色', '白色'},
    Default = '团队',
    Multi = false,
    Callback = function(Value)
        ESPConfig.BoxColor = Value
    end
})

ESPGroup:AddToggle('ESPNames', {
    Text = '名字',
    Default = ESPConfig.Names,
    Callback = function(Value)
        ESPConfig.Names = Value
    end
})

ESPGroup:AddToggle('ESPDistance', {
    Text = '距离',
    Default = ESPConfig.Distance,
    Callback = function(Value)
        ESPConfig.Distance = Value
    end
})

ESPGroup:AddToggle('ESPHealthBar', {
    Text = '血条',
    Default = ESPConfig.HealthBar,
    Callback = function(Value)
        ESPConfig.HealthBar = Value
    end
})

ESPGroup:AddToggle('ESPTracers', {
    Text = '射线',
    Default = ESPConfig.Tracers,
    Callback = function(Value)
        ESPConfig.Tracers = Value
    end
})

ESPGroup:AddDropdown('ESPTracerColor', {
    Text = '射线颜色',
    Values = {'红色', '绿色', '蓝色', '彩虹', '青色', '黑色', '白色'},
    Default = '白色',
    Multi = false,
    Callback = function(Value)
        ESPConfig.TracerColor = Value
        for player, espData in pairs(ESPObjects) do
            espData.Tracer.Color = GetColor(Value)
        end
    end
})

ESPGroup:AddToggle('ESPBones', {
    Text = '骨骰',
    Default = ESPConfig.Bones,
    Callback = function(Value)
        ESPConfig.Bones = Value
    end
})

ESPGroup:AddDropdown('ESPBoneColor', {
    Text = '骨骰颜色',
    Values = {'红色', '绿色', '蓝色', '彩虹', '青色', '黑色', '白色'},
    Default = '白色',
    Multi = false,
    Callback = function(Value)
        ESPConfig.BoneColor = Value
        for player, espData in pairs(ESPObjects) do
            for _, bone in pairs(espData.Bones) do
                bone.Color = GetColor(Value)
            end
        end
    end
})

ESPGroup:AddToggle('ESPHeadDot', {
    Text = '头部圆点',
    Default = ESPConfig.HeadDot,
    Callback = function(Value)
        ESPConfig.HeadDot = Value
    end
})

ESPGroup:AddDropdown('ESPHeadDotColor', {
    Text = '头部圆点颜色',
    Values = {'红色', '绿色', '蓝色', '彩虹', '青色', '黑色', '白色'},
    Default = '红色',
    Multi = false,
    Callback = function(Value)
        ESPConfig.HeadDotColor = Value
        for player, espData in pairs(ESPObjects) do
            espData.HeadDot.Color = GetColor(Value)
        end
    end
})

ESPGroup:AddSlider('ESPHeadDotSize', {
    Text = '头部圆点大小',
    Default = ESPConfig.HeadDotSize,
    Min = 2,
    Max = 20,
    Rounding = 0,
    Callback = function(Value)
        ESPConfig.HeadDotSize = Value
    end
})

ESPGroup:AddToggle('ESPShowTeam', {
    Text = '显示队伍',
    Default = ESPConfig.ShowTeam,
    Callback = function(Value)
        ESPConfig.ShowTeam = Value
    end
})

ESPGroup:AddToggle('ESPTeamCheck', {
    Text = '队伍检测',
    Default = ESPConfig.TeamCheck,
    Callback = function(Value)
        ESPConfig.TeamCheck = Value
    end
})

ESPGroup:AddToggle('ESPFriendCheck', {
    Text = '好友检测',
    Default = ESPConfig.FriendCheck,
    Callback = function(Value)
        ESPConfig.FriendCheck = Value
    end
})

ESPGroup:AddToggle('ESPAliveCheck', {
    Text = '活体检测',
    Default = ESPConfig.AliveCheck,
    Callback = function(Value)
        ESPConfig.AliveCheck = Value
    end
})

ESPGroup:AddToggle('ESPWallCheck', {
    Text = '墙壁检查',
    Default = ESPConfig.WallCheck,
    Callback = function(Value)
        ESPConfig.WallCheck = Value
    end
})

ESPGroup:AddToggle('ESPShowPlayerCount', {
    Text = '显示人数',
    Default = ESPConfig.ShowPlayerCount,
    Callback = function(Value)
        ESPConfig.ShowPlayerCount = Value
    end
})

ESPGroup:AddToggle('ESPHighlight', {
    Text = '玩家高亮',
    Default = ESPConfig.Highlight,
    Callback = function(Value)
        ESPConfig.Highlight = Value
        for player, highlight in pairs(highlightCache) do
            highlight:Destroy()
            highlightCache[player] = nil
        end
    end
})

ESPGroup:AddDropdown('ESPHighlightColor', {
    Text = '高亮颜色',
    Values = {'红色', '绿色', '蓝色', '彩虹', '青色', '黑色', '白色'},
    Default = '红色',
    Multi = false,
    Callback = function(Value)
        ESPConfig.HighlightColor = Value
        for player, highlight in pairs(highlightCache) do
            local color = GetColor(Value)
            highlight.FillColor = color
            highlight.OutlineColor = color
        end
    end
})

ESPGroup:AddToggle('ESPGlow', {
    Text = '玩家发光效果',
    Default = ESPConfig.Glow,
    Callback = function(Value)
        ESPConfig.Glow = Value
        for player, glowParts in pairs(glowCache) do
            for _, glowData in pairs(glowParts) do
                if glowData.part then
                    glowData.part.Material = glowData.originalMaterial
                    glowData.part.Color = glowData.originalColor
                end
            end
            glowCache[player] = nil
        end
    end
})

ESPGroup:AddSlider('ESPMaxDistance', {
    Text = '最大距离',
    Default = ESPConfig.MaxDistance,
    Min = 100,
    Max = 1000,
    Rounding = 0,
    Suffix = " m",
    Callback = function(Value)
        ESPConfig.MaxDistance = Value
    end
})

ESPGroup:AddSlider('ESPTracerThickness', {
    Text = '射线粗细',
    Default = ESPConfig.TracerThickness,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(Value)
        ESPConfig.TracerThickness = Value
    end
})

ESPGroup:AddSlider('ESPTracerTransparency', {
    Text = '射线透明度',
    Default = ESPConfig.TracerTransparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        ESPConfig.TracerTransparency = Value
    end
})

local PlayerCountLabel = ESPGroup:AddLabel("当前可见玩家: 0")
RunService.RenderStepped:Connect(function()
    if ESPConfig.ShowPlayerCount and ESPEnabled then
        local count = 0
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 and ShouldShowPlayer(player) then
                    count = count + 1
                end
            end
        end
        PlayerCountLabel:SetText("当前可见玩家: " .. count)
    else
        PlayerCountLabel:SetText("")
    end
end)

-- ============================================================
-- 自瞄 UI
-- ============================================================

local AimbotGroup = Tabs.Aimbot:AddLeftGroupbox("自瞄设置")

AimbotGroup:AddToggle('AimbotEnabled', {
    Text = '启用自瞄',
    Default = false,
    Callback = function(Value)
        AimbotEnabled = Value
    end
})

AimbotGroup:AddToggle('AimbotAimAtNPC', {
    Text = '自瞄NPC',
    Default = AimbotConfig.AimAtNPC,
    Callback = function(Value)
        AimbotConfig.AimAtNPC = Value
    end
})

AimbotGroup:AddToggle('AimbotWallCheck', {
    Text = '墙壁检测',
    Default = AimbotConfig.WallCheck,
    Callback = function(Value)
        AimbotConfig.WallCheck = Value
    end
})

AimbotGroup:AddToggle('AimbotTeamCheck', {
    Text = '队伍检查',
    Default = AimbotConfig.TeamCheck,
    Callback = function(Value)
        AimbotConfig.TeamCheck = Value
    end
})

AimbotGroup:AddToggle('AimbotSmoothAimbot', {
    Text = '平滑自瞄',
    Default = AimbotConfig.SmoothAimbot,
    Callback = function(Value)
        AimbotConfig.SmoothAimbot = Value
    end
})

AimbotGroup:AddToggle('AimbotPredictionAimbot', {
    Text = '预判自瞄',
    Default = AimbotConfig.PredictionAimbot,
    Callback = function(Value)
        AimbotConfig.PredictionAimbot = Value
    end
})

AimbotGroup:AddDropdown('AimbotTarget', {
    Text = '瞄准部位',
    Values = {'Head', 'Torso'},
    Default = 'Head',
    Multi = false,
    Callback = function(Value)
        AimbotConfig.Target = Value
    end
})

AimbotGroup:AddSlider('AimbotFOV', {
    Text = 'FOV圈大小',
    Default = AimbotConfig.FOV,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Suffix = " px",
    Callback = function(Value)
        AimbotConfig.FOV = Value
    end
})

AimbotGroup:AddSlider('AimbotFOVThickness', {
    Text = 'FOV圈厚度',
    Default = AimbotConfig.FOVThickness,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(Value)
        AimbotConfig.FOVThickness = Value
    end
})

AimbotGroup:AddSlider('AimbotSmoothness', {
    Text = '平滑度',
    Default = AimbotConfig.Smoothness,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        AimbotConfig.Smoothness = Value
    end
})

AimbotGroup:AddSlider('AimbotPredictionTime', {
    Text = '预判时间',
    Default = AimbotConfig.PredictionTime,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        AimbotConfig.PredictionTime = Value
    end
})

AimbotGroup:AddSlider('AimbotOffsetX', {
    Text = '准心偏移 X',
    Default = AimbotConfig.OffsetX,
    Min = -200,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        AimbotConfig.OffsetX = Value
    end
})

AimbotGroup:AddSlider('AimbotOffsetY', {
    Text = '准心偏移 Y',
    Default = AimbotConfig.OffsetY,
    Min = -200,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        AimbotConfig.OffsetY = Value
    end
})

AimbotGroup:AddToggle('AimbotShowFOV', {
    Text = '显示FOV圈',
    Default = AimbotConfig.ShowFOV,
    Callback = function(Value)
        AimbotConfig.ShowFOV = Value
    end
})

AimbotGroup:AddSlider('AimbotFOVTransparency', {
    Text = 'FOV透明度',
    Default = AimbotConfig.FOVTransparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        AimbotConfig.FOVTransparency = Value
        FOVCircle.Transparency = Value
    end
})

AimbotGroup:AddDropdown('AimbotFOVColor', {
    Text = 'FOV圈颜色',
    Values = {'彩虹', '红色', '蓝色', '白色', '黑色', '绿色', '青色'},
    Default = '白色',
    Multi = false,
    Callback = function(Value)
        AimbotConfig.FOVColor = Value
        FOVCircle.Color = GetColor(Value)
    end
})

-- ============================================================
-- 准心 UI
-- ============================================================

local CrosshairGroup = Tabs.Crosshair:AddLeftGroupbox("准心设置")

CrosshairGroup:AddToggle('CrosshairEnabled', {
    Text = '显示准心',
    Default = false,
    Callback = function(Value)
        CrosshairConfig.Enabled = Value
        if Value then
            CreateCrosshair()
        else
            for _, drawing in pairs(crosshairDrawings) do
                drawing:Remove()
            end
            crosshairDrawings = {}
        end
    end
})

CrosshairGroup:AddDropdown('CrosshairStyle', {
    Text = '准心样式',
    Values = {'十字', '红点', '圆圈', 'X型', '自定义'},
    Default = '十字',
    Multi = false,
    Callback = function(Value)
        CrosshairConfig.Style = Value
        if CrosshairConfig.Enabled then
            CreateCrosshair()
        end
    end
})

CrosshairGroup:AddDropdown('CrosshairColor', {
    Text = '准心颜色',
    Values = {'彩虹', '红色', '蓝色', '白色', '黑色', '绿色', '青色'},
    Default = '白色',
    Multi = false,
    Callback = function(Value)
        CrosshairConfig.Color = Value
        if CrosshairConfig.Enabled then
            CreateCrosshair()
        end
    end
})

CrosshairGroup:AddSlider('CrosshairSize', {
    Text = '准心大小',
    Default = CrosshairConfig.Size,
    Min = 5,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        CrosshairConfig.Size = Value
        if CrosshairConfig.Enabled then
            CreateCrosshair()
        end
    end
})

CrosshairGroup:AddSlider('CrosshairGap', {
    Text = '准心间隙',
    Default = CrosshairConfig.Gap,
    Min = 0,
    Max = 50,
    Rounding = 0,
    Callback = function(Value)
        CrosshairConfig.Gap = Value
        if CrosshairConfig.Enabled then
            CreateCrosshair()
        end
    end
})

CrosshairGroup:AddSlider('CrosshairThickness', {
    Text = '准心厚度',
    Default = CrosshairConfig.Thickness,
    Min = 1,
    Max = 20,
    Rounding = 0,
    Callback = function(Value)
        CrosshairConfig.Thickness = Value
        if CrosshairConfig.Enabled then
            CreateCrosshair()
        end
    end
})

CrosshairGroup:AddSlider('CrosshairTransparency', {
    Text = '准心透明度',
    Default = CrosshairConfig.Transparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        CrosshairConfig.Transparency = Value
        if CrosshairConfig.Enabled then
            CreateCrosshair()
        end
    end
})

CrosshairGroup:AddSlider('CrosshairCrossGap', {
    Text = '十字间隔',
    Default = CrosshairConfig.CrossGap,
    Min = 0,
    Max = 50,
    Rounding = 0,
    Callback = function(Value)
        CrosshairConfig.CrossGap = Value
        if CrosshairConfig.Enabled then
            CreateCrosshair()
        end
    end
})

CrosshairGroup:AddSlider('CrosshairDotSize', {
    Text = '红点大小',
    Default = CrosshairConfig.DotSize,
    Min = 1,
    Max = 30,
    Rounding = 0,
    Callback = function(Value)
        CrosshairConfig.DotSize = Value
        if CrosshairConfig.Enabled then
            CreateCrosshair()
        end
    end
})

-- ============================================================
-- 基本功能 UI
-- ============================================================

local BasicGroup = Tabs.Basic:AddLeftGroupbox("基本功能")

BasicGroup:AddSlider('BasicSpeed', {
    Text = '移动速度',
    Default = BasicConfig.Speed,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        BasicConfig.Speed = Value
        ApplySpeed()
    end
})

BasicGroup:AddSlider('BasicJumpPower', {
    Text = '跳跃高度',
    Default = BasicConfig.JumpPower,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        BasicConfig.JumpPower = Value
        ApplyJumpPower()
    end
})

BasicGroup:AddToggle('BasicInfiniteJump', {
    Text = '无限跳跃',
    Default = BasicConfig.InfiniteJump,
    Callback = function(Value)
        BasicConfig.InfiniteJump = Value
        if Value then
            EnableInfiniteJump()
            Library:Notify("无限跳跃已开启！", 3)
        else
            DisableInfiniteJump()
            Library:Notify("无限跳跃已关闭！", 3)
        end
    end
})

BasicGroup:AddButton({
    Text = '打开飞行GUI',
    Func = function()
        openFlyGUI()
        Library:Notify("飞行GUI已创建！", 3)
    end,
})

BasicGroup:AddToggle('BasicNoclip', {
    Text = '穿墙',
    Default = BasicConfig.Noclip,
    Callback = function(Value)
        BasicConfig.Noclip = Value
        if Value then
            EnableNoclip()
        else
            DisableNoclip()
        end
    end
})

BasicGroup:AddToggle('BasicBulletTracking', {
    Text = '子弹追踪',
    Default = BasicConfig.BulletTracking,
    Callback = function(Value)
        BasicConfig.BulletTracking = Value
        if Value then
            EnableBulletTracking()
        end
    end
})

BasicGroup:AddLabel("警告：速度和跳跃高度可能被服务器检测")
BasicGroup:AddLabel("飞行说明：点击按钮打开GUI，按飞行按钮开启，WASD移动，上升/下降按钮控制高度")

-- ============================================================
-- 自动朝向玩家
-- ============================================================

local AutoFaceEnabled = false
local AutoFaceRange = 30

local function GetNearestPlayerInRange()
    local character = LocalPlayer.Character
    if not character then return nil end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local nearestPlayer = nil
    local nearestDistance = AutoFaceRange

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= LocalPlayer then
            local targetCharacter = targetPlayer.Character
            if targetCharacter then
                local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")

                if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                    local distance = (targetRoot.Position - root.Position).Magnitude

                    if distance <= nearestDistance then
                        nearestDistance = distance
                        nearestPlayer = targetPlayer
                    end
                end
            end
        end
    end

    return nearestPlayer
end

RunService.RenderStepped:Connect(function()
    if not AutoFaceEnabled then return end

    local character = LocalPlayer.Character
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local targetPlayer = GetNearestPlayerInRange()

    if targetPlayer and targetPlayer.Character then
        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")

        if targetRoot then
            local targetPosition = Vector3.new(
                targetRoot.Position.X,
                root.Position.Y,
                targetRoot.Position.Z
            )

            root.CFrame = CFrame.lookAt(root.Position, targetPosition)
        end
    end
end)

BasicGroup:AddToggle('AutoFacePlayer', {
    Text = '自动朝向玩家',
    Default = false,
    Callback = function(Value)
        AutoFaceEnabled = Value
        if Value then
            Library:Notify("自动朝向玩家已开启", 3)
        else
            Library:Notify("自动朝向玩家已关闭", 3)
        end
    end
})

BasicGroup:AddSlider('AutoFaceRange', {
    Text = '朝向玩家范围',
    Default = 30,
    Min = 5,
    Max = 200,
    Rounding = 0,
    Suffix = ' studs',
    Callback = function(Value)
        AutoFaceRange = Value
    end
})

-- ============================================================
-- 设置标签页
-- ============================================================

local MenuGroup = Tabs.Settings:AddLeftGroupbox('菜单')
MenuGroup:AddButton('卸载脚本', function() Library:Unload() end)
MenuGroup:AddLabel('菜单快捷键'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Library.Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder("UniversalScriptTheme")
SaveManager:SetFolder("UniversalScriptConfig")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- 通知脚本加载成功
Library:Notify("脚本加载成功！", 3)
