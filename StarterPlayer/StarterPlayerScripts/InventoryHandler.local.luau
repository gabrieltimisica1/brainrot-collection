--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InventoryRemote = ReplicatedStorage:WaitForChild("InventoryRemote")
local InventoryUI = require(script.Parent:WaitForChild("InventoryUI"))

-- Local storage for the player's inventory
local currentInventory = {}

-- Function to handle inventory updates from the server
local function onUpdateInventory(inventoryData: {[string]: number})
    currentInventory = inventoryData
    
    -- Update the UI
    InventoryUI.Refresh(currentInventory)
end

-- Listen for the server event
InventoryRemote.OnClientEvent:Connect(function(action, ...)
    local args = {...}
    
    if action == "UpdateInventory" then
        onUpdateInventory(args[1])
    end
end)

print("InventoryHandler: Client-side initialized.")
