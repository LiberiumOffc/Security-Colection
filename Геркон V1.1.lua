local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local sensors = {}
local ignoreOwner = true

-- Функция выдачи инструмента
local function giveTool()
    if not Player.Backpack:FindFirstChild("Геркон") and not Player.Character:FindFirstChild("Геркон") then
        local tool = Instance.new("Tool", Player.Backpack)
        tool.Name = "Геркон"
        tool.RequiresHandle = false
        
        -- Переподключение события активации к новому инструменту
        tool.Activated:Connect(function()
            local pos = Mouse.Hit.p
            local model = Instance.new("Model", workspace)
            
            local body = Instance.new("Part", model)
            body.Size = Vector3.new(1.2, 1.8, 0.5)
            body.CFrame = CFrame.new(pos + Vector3.new(0, 1, 0), Player.Character and Player.Character:FindFirstChild("Head") and Player.Character.Head.Position or pos)
            body.Color = Color3.new(1, 1, 1); body.Anchored = true
            
            local lens = Instance.new("Part", model)
            lens.Shape = Enum.PartType.Ball; lens.Size = Vector3.new(0.8, 0.8, 0.8)
            lens.CFrame = body.CFrame * CFrame.new(0, 0, -0.3)
            lens.Color = Color3.fromRGB(240, 240, 240); lens.Material = Enum.Material.Glass; lens.Anchored = true
            
            table.insert(sensors, {model = model, body = body, active = true, id = #sensors + 1})
        end)
    end
end

-- Выдача при старте и при каждом спавне
giveTool()
Player.CharacterAdded:Connect(function()
    task.wait(1) -- Задержка для загрузки персонажа
    giveTool()
end)

-- 2. МЕНЮ
local gui = Instance.new("ScreenGui", Player.PlayerGui)
gui.Name = "SensorGui"
gui.ResetOnSpawn = false 

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 350); frame.Position = UDim2.new(0.5, -100, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); frame.Draggable = true; frame.Active = true; frame.Visible = false

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 80, 0, 30); toggleBtn.Position = UDim2.new(0, 10, 0, 10); toggleBtn.Text = "МЕНЮ"
toggleBtn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)

-- КНОПКИ
local function createBtn(text, pos, callback)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0, 180, 0, 40); b.Position = pos; b.Text = text
    b.MouseButton1Click:Connect(callback)
end

createBtn("АКТИВИРОВАТЬ", UDim2.new(0, 10, 0, 20), function() if sensors[#sensors] then sensors[#sensors].active = true end end)
createBtn("ДЕАКТИВИРОВАТЬ", UDim2.new(0, 10, 0, 70), function() if sensors[#sensors] then sensors[#sensors].active = false end end)
createBtn("УДАЛИТЬ", UDim2.new(0, 10, 0, 120), function() if sensors[#sensors] then sensors[#sensors].model:Destroy(); table.remove(sensors, #sensors) end end)

local modeBtn = Instance.new("TextButton", frame)
modeBtn.Size = UDim2.new(0, 180, 0, 40); modeBtn.Position = UDim2.new(0, 10, 0, 170)
modeBtn.Text = "ДЕТЕКТ МЕНЯ: ВЫКЛ"
modeBtn.MouseButton1Click:Connect(function()
    ignoreOwner = not ignoreOwner
    modeBtn.Text = ignoreOwner and "ДЕТЕКТ МЕНЯ: ВЫКЛ" or "ДЕТЕКТ МЕНЯ: ВКЛ"
end)

-- 4. ДЕТЕКТ
local notify = Instance.new("Frame", gui); notify.Size = UDim2.new(0, 300, 0, 50); notify.Position = UDim2.new(1, -310, 1, -60)
notify.BackgroundColor3 = Color3.fromRGB(200, 0, 0); notify.Visible = false
local lbl = Instance.new("TextLabel", notify); lbl.Size = UDim2.new(1,0,1,0); lbl.TextScaled = true; lbl.TextColor3 = Color3.new(1,1,1)

RunService.Heartbeat:Connect(function()
    for _, s in pairs(sensors) do
        if s.active and s.body.Parent then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character then
                    if ignoreOwner and p == Player then continue end
                    local root = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso")
                    if root and (s.body.Position - root.Position).Magnitude <= 10 then
                        lbl.Text = "Датчик " .. s.id .. ": " .. p.Name .. " ОБНАРУЖЕН!"
                        notify.Visible = true; task.wait(3); notify.Visible = false
                    end
                end
            end
        end
    end
end)
