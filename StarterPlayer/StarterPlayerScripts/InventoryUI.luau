--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local InventoryUI = {}

-- Variables for UI elements
local screenGui: ScreenGui
local mainFrame: Frame
local container: ScrollingFrame

-- Constants
local UI_NAME = "InventoryHUD"
local SLOT_SIZE = UDim2.fromOffset(80, 80)
local PADDING = UDim.new(0, 10)

-- Function to create the UI if it doesn't exist
local function ensureUI()
    if screenGui then return end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = UI_NAME
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 10
    screenGui.Parent = playerGui
    
    mainFrame = Instance.new("CanvasGroup")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.6, 0, 0, 100)
    mainFrame.Position = UDim2.new(0.5, 0, 0.95, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 1)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BackgroundTransparency = 0.3 -- This is for the layer color
    mainFrame.GroupTransparency = 1 -- Start fully invisible
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 100)
    stroke.Transparency = 0.5
    stroke.Thickness = 2
    stroke.Parent = mainFrame
    
    container = Instance.new("ScrollingFrame")
    container.Name = "Container"
    container.Size = UDim2.new(1, -20, 1, -20)
    container.Position = UDim2.new(0.5, 0, 0.5, 0)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.ScrollBarThickness = 4
    container.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = PADDING
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = container
end

local function createSlot(id: string, count: number)
    local slot = Instance.new("Frame")
    slot.Name = id
    slot.Size = SLOT_SIZE
    slot.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    slot.BackgroundTransparency = 0.5
    slot.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = slot
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.7, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = id
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.Parent = slot
    
    local amount = Instance.new("TextLabel")
    amount.Size = UDim2.new(1, -5, 0.3, 0)
    amount.Position = UDim2.new(0, 0, 0.7, 0)
    amount.BackgroundTransparency = 1
    amount.Text = "x" .. tostring(count)
    amount.TextColor3 = Color3.fromRGB(200, 200, 200)
    amount.TextSize = 12
    amount.Font = Enum.Font.Gotham
    amount.TextXAlignment = Enum.TextXAlignment.Right
    amount.Parent = slot
    
    -- Placement logic: clicking slot places the pack
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromScale(1, 1)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = slot
    
    button.MouseButton1Click:Connect(function()
        local InventoryRemote = ReplicatedStorage:WaitForChild("InventoryRemote")
        local character = player.Character
        if character and character:FindFirstChild("PrimaryPart") then
            local pos = character.PrimaryPart.Position + (character.PrimaryPart.CFrame.LookVector * 5)
            InventoryRemote:FireServer("PlacePack", id, pos)
        end
    end)
    
    return slot
end

function InventoryUI.Refresh(inventory: {[string]: number})
    ensureUI()
    container:ClearAllChildren()
    
    -- Re-add layout
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = PADDING
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = container
    
    local count = 0
    for id, amount in pairs(inventory) do
        if amount > 0 then
            local slot = createSlot(id, amount)
            slot.Parent = container
            count += 1
        end
    end
    
    -- Auto-resize canvas
    container.CanvasSize = UDim2.new(0, count * (SLOT_SIZE.X.Offset + PADDING.Offset), 0, 0)
    
    -- Simple Fade-in animation
    TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
end

return InventoryUI
