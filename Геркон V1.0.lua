local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local sensors = {}
local ignoreOwner = true
local selectedSensor = nil

-- Функция выдачи инструмента
local function giveTool()
    if not Player.Backpack:FindFirstChild("Геркон") and not Player.Character:FindFirstChild("Геркон") then
        local tool = Instance.new("Tool", Player.Backpack)
        tool.Name = "Геркон"
        tool.RequiresHandle = false
        
        tool.Activated:Connect(function()
            local pos = Mouse.Hit.p
            local model = Instance.new("Model", workspace)
            
            local body = Instance.new("Part", model)
            body.Size = Vector3.new(1.2, 1.8, 0.5)
            body.CFrame = CFrame.new(pos + Vector3.new(0, 1, 0), Player.Character and Player.Character:FindFirstChild("Head") and Player.Character.Head.Position or pos)
            body.Color = Color3.new(1, 1, 1)
            body.Anchored = true
            body.Name = "Корпус"
            
            local lens = Instance.new("Part", model)
            lens.Shape = Enum.PartType.Ball
            lens.Size = Vector3.new(0.8, 0.8, 0.8)
            lens.CFrame = body.CFrame * CFrame.new(0, 0, -0.3)
            lens.Color = Color3.fromRGB(240, 240, 240)
            lens.Material = Enum.Material.Glass
            lens.Anchored = true
            lens.Name = "Линза"
            
            -- Индикатор спереди сверху
            local indicator = Instance.new("Part", model)
            indicator.Shape = Enum.PartType.Ball
            indicator.Size = Vector3.new(0.3, 0.3, 0.3)
            indicator.CFrame = body.CFrame * CFrame.new(0.5, 0.8, -0.1)
            indicator.BrickColor = BrickColor.new("Lime green")
            indicator.Material = Enum.Material.Neon
            indicator.Anchored = true
            indicator.CanCollide = false
            indicator.Name = "Индикатор"
            
            local light = Instance.new("PointLight", indicator)
            light.Range = 3
            light.Brightness = 1
            light.Color = Color3.new(0, 1, 0)
            
            -- 3D звук на датчике
            local sensorSound = Instance.new("Sound", model)
            sensorSound.SoundId = "rbxassetid://126381148704089"
            sensorSound.Volume = 0.5
            sensorSound.RollOffMode = Enum.RollOffMode.Linear
            sensorSound.MaxDistance = 50
            sensorSound.MinDistance = 5
            sensorSound.Name = "AlertSound"
            sensorSound.Looped = false
            
            -- Сварка
            local weld1 = Instance.new("WeldConstraint")
            weld1.Part0 = body
            weld1.Part1 = lens
            weld1.Parent = model
            
            local weld2 = Instance.new("WeldConstraint")
            weld2.Part0 = body
            weld2.Part1 = indicator
            weld2.Parent = model
            
            local newSensor = {
                model = model, 
                body = body, 
                lens = lens,
                indicator = indicator,
                light = light,
                sound = sensorSound,
                active = true, 
                id = #sensors + 1,
                valid = true
            }
            
            table.insert(sensors, newSensor)
            selectedSensor = newSensor
        end)
    end
end

-- Выдача при старте и при каждом спавне
giveTool()
Player.CharacterAdded:Connect(function()
    task.wait(1)
    giveTool()
end)

-- МЕНЮ
local gui = Instance.new("ScreenGui", Player.PlayerGui)
gui.Name = "SensorGui"
gui.ResetOnSpawn = false 

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 450)
frame.Position = UDim2.new(0.5, -100, 0.5, -225)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Draggable = true
frame.Active = true
frame.Visible = false

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 80, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "МЕНЮ"
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)

-- КНОПКИ
local function createBtn(text, pos, callback)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0, 180, 0, 30)
    b.Position = pos
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.MouseButton1Click:Connect(callback)
end

-- Выбор датчика
local selector = Instance.new("TextLabel", frame)
selector.Size = UDim2.new(0, 180, 0, 30)
selector.Position = UDim2.new(0, 10, 0, 10)
selector.Text = "ВЫБЕРИ ДАТЧИК:"
selector.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
selector.TextColor3 = Color3.new(1, 1, 1)

local prevBtn = Instance.new("TextButton", frame)
prevBtn.Size = UDim2.new(0, 80, 0, 30)
prevBtn.Position = UDim2.new(0, 10, 0, 45)
prevBtn.Text = "<"
prevBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
prevBtn.TextColor3 = Color3.new(1, 1, 1)
prevBtn.MouseButton1Click:Connect(function()
    if #sensors == 0 then 
        selector.Text = "НЕТ ДАТЧИКОВ"
        return 
    end
    local currentIndex = 1
    for i, s in pairs(sensors) do
        if s == selectedSensor then
            currentIndex = i
            break
        end
    end
    local newIndex = currentIndex - 1
    if newIndex < 1 then newIndex = #sensors end
    selectedSensor = sensors[newIndex]
    if selectedSensor and selectedSensor.valid then
        selector.Text = "ДАТЧИК " .. selectedSensor.id
    else
        selector.Text = "ДАТЧИК НЕДОСТУПЕН"
    end
end)

local nextBtn = Instance.new("TextButton", frame)
nextBtn.Size = UDim2.new(0, 80, 0, 30)
nextBtn.Position = UDim2.new(0, 100, 0, 45)
nextBtn.Text = ">"
nextBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
nextBtn.TextColor3 = Color3.new(1, 1, 1)
nextBtn.MouseButton1Click:Connect(function()
    if #sensors == 0 then 
        selector.Text = "НЕТ ДАТЧИКОВ"
        return 
    end
    local currentIndex = 1
    for i, s in pairs(sensors) do
        if s == selectedSensor then
            currentIndex = i
            break
        end
    end
    local newIndex = currentIndex + 1
    if newIndex > #sensors then newIndex = 1 end
    selectedSensor = sensors[newIndex]
    if selectedSensor and selectedSensor.valid then
        selector.Text = "ДАТЧИК " .. selectedSensor.id
    else
        selector.Text = "ДАТЧИК НЕДОСТУПЕН"
    end
end)

createBtn("АКТИВИРОВАТЬ", UDim2.new(0, 10, 0, 90), function() 
    if selectedSensor and selectedSensor.valid then 
        selectedSensor.active = true
        if selectedSensor.indicator then
            selectedSensor.indicator.BrickColor = BrickColor.new("Lime green")
            selectedSensor.light.Color = Color3.new(0, 1, 0)
        end
    end 
end)

createBtn("ДЕАКТИВИРОВАТЬ", UDim2.new(0, 10, 0, 130), function() 
    if selectedSensor and selectedSensor.valid then 
        selectedSensor.active = false
        if selectedSensor.indicator then
            selectedSensor.indicator.BrickColor = BrickColor.new("Bright red")
            selectedSensor.light.Color = Color3.new(1, 0, 0)
        end
    end 
end)

createBtn("СОРВАТЬ", UDim2.new(0, 10, 0, 170), function() 
    if selectedSensor and selectedSensor.valid then 
        selectedSensor.active = false
        selectedSensor.valid = false
        
        for _, part in pairs(selectedSensor.model:GetChildren()) do
            if part:IsA("BasePart") then
                part.Anchored = false
                part.CanCollide = true
            end
        end
        
        -- Первый звук при срыве
        if selectedSensor.sound then
            selectedSensor.sound:Play()
        end
        
        -- Звук через 10 секунд
        task.spawn(function()
            task.wait(10)
            if selectedSensor.model and selectedSensor.model.Parent and selectedSensor.sound then
                selectedSensor.sound:Play()
            end
        end)
        
        task.spawn(function()
            task.wait(5)
            if selectedSensor.model and selectedSensor.model.Parent then
                selectedSensor.model:Destroy()
                for i, s in pairs(sensors) do
                    if s == selectedSensor then
                        table.remove(sensors, i)
                        break
                    end
                end
                
                -- Обновляем выбранный датчик
                if #sensors > 0 then
                    selectedSensor = sensors[#sensors]
                    selector.Text = "ДАТЧИК " .. selectedSensor.id
                else
                    selectedSensor = nil
                    selector.Text = "НЕТ ДАТЧИКОВ"
                end
            end
        end)
    end 
end)

local modeBtn = Instance.new("TextButton", frame)
modeBtn.Size = UDim2.new(0, 180, 0, 30)
modeBtn.Position = UDim2.new(0, 10, 0, 210)
modeBtn.Text = "ДЕТЕКТ МЕНЯ: ВЫКЛ"
modeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
modeBtn.TextColor3 = Color3.new(1, 1, 1)
modeBtn.MouseButton1Click:Connect(function()
    ignoreOwner = not ignoreOwner
    modeBtn.Text = ignoreOwner and "ДЕТЕКТ МЕНЯ: ВЫКЛ" or "ДЕТЕКТ МЕНЯ: ВКЛ"
end)

-- ДЕТЕКТ
local notify = Instance.new("Frame", gui)
notify.Size = UDim2.new(0, 300, 0, 50)
notify.Position = UDim2.new(1, -310, 1, -60)
notify.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
notify.Visible = false
notify.BackgroundTransparency = 0.1
notify.ZIndex = 10

local lbl = Instance.new("TextLabel", notify)
lbl.Size = UDim2.new(1,0,1,0)
lbl.TextScaled = true
lbl.TextColor3 = Color3.new(1,1,1)
lbl.BackgroundTransparency = 1
lbl.ZIndex = 11
lbl.Text = ""

RunService.Heartbeat:Connect(function()
    for _, s in pairs(sensors) do
        if s.active and s.valid and s.body and s.body.Parent then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character then
                    if ignoreOwner and p == Player then 
                        continue 
                    end
                    
                    local root = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso")
                    if root then
                        local dist = (s.body.Position - root.Position).Magnitude
                        if dist <= 10 then
                            -- Красный индикатор при обнаружении
                            if s.indicator then
                                s.indicator.BrickColor = BrickColor.new("Bright red")
                                s.light.Color = Color3.new(1, 0, 0)
                            end
                            
                            lbl.Text = "Датчик " .. s.id .. ": " .. p.Name .. " ОБНАРУЖЕН!"
                            notify.Visible = true
                            
                            -- 3D звук с датчика
                            if s.sound and not s.sound.Playing then
                                s.sound:Play()
                            end
                            
                            task.wait(3)
                            notify.Visible = false
                            
                            -- Возвращаем зеленый если активен
                            if s.active and s.valid then
                                s.indicator.BrickColor = BrickColor.new("Lime green")
                                s.light.Color = Color3.new(0, 1, 0)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Срыв при клике
Mouse.Button1Down:Connect(function()
    local target = Mouse.Target
    if target then
        for i, sensor in pairs(sensors) do
            if sensor.valid and (sensor.model == target or sensor.model:IsAncestorOf(target)) then
                sensor.active = false
                sensor.valid = false
                
                for _, part in pairs(sensor.model:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Anchored = false
                        part.CanCollide = true
                    end
                end
                
                -- Первый звук при срыве
                if sensor.sound then
                    sensor.sound:Play()
                end
                
                -- Звук через 10 секунд
                task.spawn(function()
                    task.wait(10)
                    if sensor.model and sensor.model.Parent and sensor.sound then
                        sensor.sound:Play()
                    end
                end)
                
                task.spawn(function()
                    task.wait(5)
                    if sensor.model and sensor.model.Parent then
                        sensor.model:Destroy()
                        table.remove(sensors, i)
                        
                        -- Обновляем выбранный датчик
                        if #sensors > 0 then
                            selectedSensor = sensors[#sensors]
                            selector.Text = "ДАТЧИК " .. selectedSensor.id
                        else
                            selectedSensor = nil
                            selector.Text = "НЕТ ДАТЧИКОВ"
                        end
                    end
                end)
                
                break
            end
        end
    end
end)
