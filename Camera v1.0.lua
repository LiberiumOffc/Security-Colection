local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local MAX_CAMS = 5
local cameras = {}
local targetCFrames = {} 
local currentCam = 1
local isViewing = false
local nvEnabled = false 

-- 1. ЭФФЕКТЫ
local cc = Instance.new("ColorCorrectionEffect")
cc.Enabled = false
cc.Parent = Lighting

local noiseGui = Instance.new("ScreenGui", PlayerGui)
local staticImg = Instance.new("ImageLabel", noiseGui)
staticImg.Size = UDim2.new(1, 0, 1, 0)
staticImg.BackgroundTransparency = 1
staticImg.Image = "rbxassetid://161204689"
staticImg.ImageTransparency = 0.85
staticImg.Visible = false

local function updateVisionEffects()
    if not isViewing then cc.Enabled = false return end
    cc.Enabled = true
    if nvEnabled then
        cc.TintColor = Color3.fromRGB(100, 255, 120)
        cc.Saturation = 0.3
        cc.Contrast = 0.6
        cc.Brightness = 0.2
    else
        cc.TintColor = Color3.fromRGB(255, 255, 255)
        cc.Saturation = -1
        cc.Contrast = 0.2
        cc.Brightness = 0
    end
end

-- 2. ПЛАНШЕТ
local tool = Instance.new("Tool", LP.Backpack)
tool.Name = "CCTV Tablet"
tool.RequiresHandle = false

-- 3. МЕНЮ
local ui = Instance.new("ScreenGui", PlayerGui)
local frame = Instance.new("Frame", ui)
frame.Size = UDim2.new(0, 340, 0, 400) -- Немного увеличил высоту под новую кнопку
frame.Position = UDim2.new(0.5, -170, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
frame.Visible = false

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0.1, 0)
title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
title.TextColor3 = Color3.new(1, 1, 1)
title.Text = "CCTV CONTROL"

local function makeBtn(txt, pos, size, parent, func)
    local b = Instance.new("TextButton", parent)
    b.Text = txt
    b.Position = pos
    b.Size = size
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.MouseButton1Click:Connect(func)
    return b
end

local function moveCam(cf)
    if targetCFrames[currentCam] then
        targetCFrames[currentCam] = targetCFrames[currentCam] * cf
    end
end

-- КНОПКИ УПРАВЛЕНИЯ
makeBtn("LOOK UP", UDim2.new(0.35, 0, 0.12, 0), UDim2.new(0.3, 0, 0.07, 0), frame, function() moveCam(CFrame.Angles(math.rad(10), 0, 0)) end)
makeBtn("LOOK DOWN", UDim2.new(0.35, 0, 0.30, 0), UDim2.new(0.3, 0, 0.07, 0), frame, function() moveCam(CFrame.Angles(math.rad(-10), 0, 0)) end)
makeBtn("LOOK LEFT", UDim2.new(0.02, 0, 0.21, 0), UDim2.new(0.3, 0, 0.07, 0), frame, function() moveCam(CFrame.Angles(0, math.rad(10), 0)) end)
makeBtn("LOOK RIGHT", UDim2.new(0.68, 0, 0.21, 0), UDim2.new(0.3, 0, 0.07, 0), frame, function() moveCam(CFrame.Angles(0, math.rad(-10), 0)) end)

makeBtn("MOVE FWD", UDim2.new(0.05, 0, 0.42, 0), UDim2.new(0.25, 0, 0.07, 0), frame, function() moveCam(CFrame.new(0, 0, -1)) end)
makeBtn("MOVE BACK", UDim2.new(0.375, 0, 0.42, 0), UDim2.new(0.25, 0, 0.07, 0), frame, function() moveCam(CFrame.new(0, 0, 1)) end)
makeBtn("MOVE UP", UDim2.new(0.7, 0, 0.42, 0), UDim2.new(0.25, 0, 0.07, 0), frame, function() moveCam(CFrame.new(0, 1, 0)) end)
makeBtn("MOVE LEFT", UDim2.new(0.05, 0, 0.52, 0), UDim2.new(0.25, 0, 0.07, 0), frame, function() moveCam(CFrame.new(-1, 0, 0)) end)
makeBtn("MOVE RIGHT", UDim2.new(0.375, 0, 0.52, 0), UDim2.new(0.25, 0, 0.07, 0), frame, function() moveCam(CFrame.new(1, 0, 0)) end)
makeBtn("MOVE DOWN", UDim2.new(0.7, 0, 0.52, 0), UDim2.new(0.25, 0, 0.07, 0), frame, function() moveCam(CFrame.new(0, -1, 0)) end)

local nvBtn = makeBtn("[ NIGHT VISION: OFF ]", UDim2.new(0.1, 0, 0.62, 0), UDim2.new(0.8, 0, 0.07, 0), frame, function()
    nvEnabled = not nvEnabled
    updateVisionEffects()
end)

makeBtn("NEXT CAMERA", UDim2.new(0.1, 0, 0.72, 0), UDim2.new(0.8, 0, 0.07, 0), frame, function()
    if #cameras > 0 then
        currentCam = (currentCam % #cameras) + 1
        title.Text = "CCTV (CAM " .. currentCam .. "/" .. #cameras .. ")"
    end
end)

-- НОВАЯ КНОПКА: REMOVE CAM
makeBtn("REMOVE CURRENT CAM", UDim2.new(0.1, 0, 0.85, 0), UDim2.new(0.8, 0, 0.1, 0), frame, function()
    if #cameras > 0 then
        local camToDelete = cameras[currentCam]
        if camToDelete and camToDelete.Parent then
            camToDelete.Parent:Destroy() -- Удаляем всю модель
        end
        table.remove(cameras, currentCam)
        table.remove(targetCFrames, currentCam)
        
        if #cameras == 0 then
            isViewing = false
            frame.Visible = false
            staticImg.Visible = false
            cc.Enabled = false
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        else
            currentCam = 1
            title.Text = "CCTV (CAM " .. currentCam .. "/" .. #cameras .. ")"
        end
    end
end).BackgroundColor3 = Color3.fromRGB(150, 0, 0)

-- 4. УСТАНОВКА КАМЕРЫ
local setBtn = Instance.new("TextButton", ui)
setBtn.Text = "PLACE CAM"
setBtn.Size = UDim2.new(0.15, 0, 0.08, 0)
setBtn.Position = UDim2.new(0.8, 0, 0.4, 0)
setBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
setBtn.Visible = false

setBtn.MouseButton1Click:Connect(function()
    if #cameras >= MAX_CAMS then return end
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local model = Instance.new("Model", workspace)
    local body = Instance.new("Part", model)
    body.Size = Vector3.new(0.6, 0.6, 1.4)
    body.CFrame = root.CFrame * CFrame.new(0, 2, -3)
    body.Anchored = true
    body.Color = Color3.fromRGB(230, 230, 230)
    
    local lens = Instance.new("Part", model)
    lens.Size = Vector3.new(0.35, 0.35, 0.1)
    lens.CFrame = body.CFrame * CFrame.new(0, 0, -0.71)
    lens.Anchored = true
    lens.Color = Color3.new(0, 0, 0)
    lens.Material = Enum.Material.Glass

    local hinge = Instance.new("Part", model)
    hinge.Size = Vector3.new(0.3, 0.3, 0.3)
    hinge.CFrame = body.CFrame * CFrame.new(0, 0, 0.75)
    hinge.Anchored = true
    
    local arm = Instance.new("Part", model)
    arm.Size = Vector3.new(0.2, 0.2, 1.2)
    arm.CFrame = hinge.CFrame * CFrame.new(0, 0.3, 0.5) * CFrame.Angles(math.rad(-30), 0, 0)
    arm.Anchored = true

    for _, p in ipairs(model:GetChildren()) do
        if p ~= body then
            local w = Instance.new("WeldConstraint", body)
            w.Part0 = body
            w.Part1 = p
            p.Anchored = false
        end
    end

    table.insert(cameras, body)
    table.insert(targetCFrames, body.CFrame)
    title.Text = "CCTV (CAM " .. currentCam .. "/" .. #cameras .. ")"
end)

-- 5. ЛОГИКА
tool.Equipped:Connect(function() setBtn.Visible = true end)
tool.Unequipped:Connect(function() setBtn.Visible = false isViewing = false frame.Visible = false cc.Enabled = false staticImg.Visible = false workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)

tool.Activated:Connect(function()
    if #cameras == 0 then return end
    isViewing = not isViewing
    frame.Visible = isViewing
    staticImg.Visible = isViewing
    updateVisionEffects()
    if nvBtn then nvBtn.Text = nvEnabled and "[ NIGHT VISION: ON ]" or "[ NIGHT VISION: OFF ]" end
    workspace.CurrentCamera.CameraType = isViewing and Enum.CameraType.Scriptable or Enum.CameraType.Custom
end)

RunService.RenderStepped:Connect(function()
    for i, camBody in ipairs(cameras) do
        if targetCFrames[i] then camBody.CFrame = camBody.CFrame:Lerp(targetCFrames[i], 0.1) end
    end
    if isViewing and cameras[currentCam] then
        workspace.CurrentCamera.CFrame = cameras[currentCam].CFrame * CFrame.new(0, 0, -0.75)
    end
end)
