--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Store = require(script.Parent.Parent.Data.Store)
local PackConfig = require(script.Parent.Parent.Configs.PackConfig)

local PackCollectedEvent = ServerScriptService.CollectionGame:WaitForChild("Events"):WaitForChild("PackCollected")

local InventoryManager = {}

-- Setup RemoteEvent
local InventoryRemote = ReplicatedStorage:FindFirstChild("InventoryRemote")

-- Helper to update client
local function updateClient(player: Player)
    local data = Store.GetPlayerPersistentData(player)
    if data and data.Inventory then
        InventoryRemote:FireClient(player, "UpdateInventory", data.Inventory)
    end
end

-- --- Event Listeners ---

-- 1. Pack Collected Event (From Spawner)
PackCollectedEvent.Event:Connect(function(player, packId)
    InventoryManager.AddPackToInventory(player, packId)
end)

-- 2. Client Requests
InventoryRemote.OnServerEvent:Connect(function(player, action, ...)
    local args = {...}
    
    if action == "RequestInventory" then
        updateClient(player)
        
    elseif action == "PlacePack" then
        local packId = args[1]
        local position = args[2]
        
        if typeof(packId) == "string" and typeof(position) == "Vector3" then
            InventoryManager.PlacePack(player, packId, position)
        end
    end
end)

-- --- Core Inventory Logic ---

function InventoryManager.AddPackToInventory(player: Player, packId: string)
    Store.AddPackToInventory(player, packId)
    updateClient(player)
    print(player.Name .. " collected pack: " .. packId)
end

-- --- Placed Packs Logic ---

local function spawnPlacedPackVisual(player: Player, packEntry: any)
    local packsFolder = ServerStorage.Assets.Packs
    local packModel = packsFolder:FindFirstChild(packEntry.PackId)
    
    if not packModel then 
        warn("InventoryManager: Pack model not found for " .. tostring(packEntry.PackId))
        return 
    end
    
    local visual = packModel:Clone()
    visual.Name = "PlacedPack_" .. packEntry.InstanceId
    
    -- Handle Position (Deserialize if needed)
    local pos = packEntry.Position
    if typeof(pos) == "table" then
        pos = Vector3.new(pos.X, pos.Y, pos.Z)
    end
    
    if visual:IsA("Model") then
        visual:PivotTo(CFrame.new(pos))
    elseif visual:IsA("BasePart") then
        visual.CFrame = CFrame.new(pos)
    end
    
    visual.Parent = Workspace
    
    -- ProximityPrompt for Opening
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Open"
    prompt.ObjectText = "Unlocking..."
    prompt.HoldDuration = 1
    prompt.Parent = visual
    
    -- Initial State
    local timeLeft = math.max(0, packEntry.UnlockTime - os.time())
    if timeLeft > 0 then
        prompt.Enabled = false
        prompt.ObjectText = "Unlocking... " .. timeLeft .. "s"
    else
        prompt.ObjectText = "Ready to Open!"
        prompt.Enabled = true
    end
    
    -- Trigger Logic
    prompt.Triggered:Connect(function(triggerPlayer)
        if triggerPlayer ~= player then 
            -- Optional: Allow others to steal? For now, owner only.
            return 
        end
        
        -- Verify Time
        if os.time() < packEntry.UnlockTime then return end
        
        -- Open Pack
        InventoryManager.OpenPlacedPack(player, packEntry.InstanceId, packEntry.PackId, visual)
    end)
    
    -- Track Visual in Temporary Data
    local tempData = Store.GetPlayerTemporaryData(player)
    if tempData then
        if not tempData.PlacedPackVisuals then tempData.PlacedPackVisuals = {} end
        tempData.PlacedPackVisuals[packEntry.InstanceId] = visual
    end
end

function InventoryManager.PlacePack(player: Player, packId: string, position: Vector3)
    local data = Store.GetPlayerPersistentData(player)
    if not data or not data.Inventory then return end
    
    -- Check ownership
    local count = data.Inventory[packId] or 0
    if count <= 0 then return end
    
    -- Deduct from Inventory
    data.Inventory[packId] = count - 1
    if data.Inventory[packId] <= 0 then
        data.Inventory[packId] = nil
    end
    updateClient(player)
    
    -- Create Pack Entry
    local packInfo = PackConfig[packId]
    local duration = 10 -- TODO: Get from PackConfig if available
    
    local entry = {
        InstanceId = game:GetService("HttpService"):GenerateGUID(false),
        PackId = packId,
        UnlockTime = os.time() + duration,
        Position = { X = position.X, Y = position.Y, Z = position.Z } -- Serialize
    }
    
    -- Save to Persistent Data
    if not data.PlacedPacks then data.PlacedPacks = {} end
    table.insert(data.PlacedPacks, entry)
    
    -- Visuals
    spawnPlacedPackVisual(player, entry)
end

function InventoryManager.OpenPlacedPack(player: Player, instanceId: string, packId: string, visualModel: Instance)
    local pData = Store.GetPlayerPersistentData(player)
    if not pData or not pData.PlacedPacks then return end
    
    -- Find and Remove Data
    local indexToRemove = nil
    for i, entry in ipairs(pData.PlacedPacks) do
        if entry.InstanceId == instanceId then
            indexToRemove = i
            break
        end
    end
    
    if indexToRemove then
        table.remove(pData.PlacedPacks, indexToRemove)
        
        -- Cleanup Visual
        if visualModel then visualModel:Destroy() end
        
        -- Cleanup Temp State
        local tempData = Store.GetPlayerTemporaryData(player)
        if tempData and tempData.PlacedPackVisuals then
            tempData.PlacedPackVisuals[instanceId] = nil
        end
        
        -- Grant Rewards
        print(player.Name .. " opened pack: " .. packId)
        -- TODO: Integrate CardManager to give cards
        -- CardManager.GrantPackCards(player, packId)
    end
end

-- --- Lifecycle ---

function InventoryManager.Initialize(player: Player)
    -- Send initial inventory
    updateClient(player)
    
    -- Initialize Temp Data Store for Visuals
    local tempData = Store.GetPlayerTemporaryData(player)
    if tempData then
        tempData.PlacedPackVisuals = {} 
    end
    
    -- Respawn Placed Packs
    local data = Store.GetPlayerPersistentData(player)
    if data and data.PlacedPacks then
        for _, entry in ipairs(data.PlacedPacks) do
            spawnPlacedPackVisual(player, entry)
        end
    end
end

function InventoryManager.Cleanup(player: Player)
    -- Destroy all placed pack visuals for this player
    local tempData = Store.GetPlayerTemporaryData(player)
    if tempData and tempData.PlacedPackVisuals then
        for _, model in pairs(tempData.PlacedPackVisuals) do
            model:Destroy()
        end
        tempData.PlacedPackVisuals = nil
    end
end

-- --- Global Loop (Timers) ---

task.spawn(function()
    while true do
        task.wait(1)
        local currentTime = os.time()
        
        for _, player in ipairs(Players:GetPlayers()) do
            local tempData = Store.GetPlayerTemporaryData(player)
            local pData = Store.GetPlayerPersistentData(player)
            
            if tempData and tempData.PlacedPackVisuals and pData and pData.PlacedPacks then
                -- Map data entries for O(1) lookup if needed, specific check for now
                for _, entry in ipairs(pData.PlacedPacks) do
                    local visual = tempData.PlacedPackVisuals[entry.InstanceId]
                    
                    if visual and visual.Parent then
                        local prompt = visual:FindFirstChildWhichIsA("ProximityPrompt")
                        if prompt and not prompt.Enabled then
                            local timeLeft = entry.UnlockTime - currentTime
                            if timeLeft <= 0 then
                                prompt.Enabled = true
                                prompt.ObjectText = "Ready to Open!"
                            else
                                prompt.ObjectText = "Unlocking... " .. timeLeft .. "s"
                            end
                        end
                    end
                end
            end
        end
    end
end)

return InventoryManager
