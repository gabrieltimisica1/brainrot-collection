--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local InventoryRemote = ReplicatedStorage:WaitForChild("InventoryRemote")

local PlacementManager = {}
local currentHoldingPackId: string? = nil
local phantomModel: Model | BasePart | nil = nil

-- Configuration
local MAX_PLACE_DISTANCE = 20

local function cleanup()
    if phantomModel then
        phantomModel:Destroy()
        phantomModel = nil
    end
    currentHoldingPackId = nil
end

function PlacementManager.EquipPack(packId: string)
    cleanup()
    
    currentHoldingPackId = packId
    
    -- Create a "phantom" visual for the pack
    -- We look in ReplicatedStorage for assets if they are there, otherwise we just use a placeholder
    -- Assuming Assets/Packs is visible or using a standard cube for now
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    local model = assets and assets.Packs:FindFirstChild(packId)
    
    if model then
        phantomModel = model:Clone()
        for _, part in ipairs(phantomModel:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.Transparency = 0.5
            end
        end
        phantomModel.Parent = workspace
    end
end

-- Update phantom position
RunService.RenderStepped:Connect(function()
    if not phantomModel or not currentHoldingPackId then return end
    
    local targetPos = mouse.Hit.Position
    local charPos = player.Character and player.Character.PrimaryPart and player.Character.PrimaryPart.Position
    
    if charPos then
        local dist = (targetPos - charPos).Magnitude
        if dist > MAX_PLACE_DISTANCE then
            targetPos = charPos + (targetPos - charPos).Unit * MAX_PLACE_DISTANCE
        end
    end
    
    if phantomModel:IsA("Model") then
        phantomModel:PivotTo(CFrame.new(targetPos + Vector3.new(0, 1.5, 0)))
    elseif phantomModel:IsA("BasePart") then
        phantomModel.Position = targetPos + Vector3.new(0, 1.5, 0)
    end
end)

-- Handle Clicking to Place
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if not currentHoldingPackId then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local targetPos = mouse.Hit.Position
        
        -- Send to server
        InventoryRemote:FireServer("PlacePack", currentHoldingPackId, targetPos)
        
        cleanup()
    elseif input.KeyCode == Enum.KeyCode.Q then
        -- Cancel placement
        cleanup()
    end
end)

return PlacementManager
