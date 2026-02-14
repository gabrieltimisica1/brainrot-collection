--!strict
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local Store = require(script.Parent.Parent.Data.Store)
local WorkspaceUtils = require(script.Parent.Parent.Utils.WorkspaceUtils)
local PackConfig = require(script.Parent.Parent.Configs.PackConfig)

local PackCollectedEvent = game:GetService("ServerScriptService").CollectionGame:WaitForChild("Events"):WaitForChild("PackCollected")

-- Verify it's a BindableEvent
assert(PackCollectedEvent.ClassName == "BindableEvent", "PackCollected must be a BindableEvent")


local Spawner = {}
local activeLoops = {}
local activeCardFolders = {} -- [UserId] = Folder

-- Configuration
local BELT_SPEED = 10
local SPAWN_RATE = 1

-- Assets
local Assets = ServerStorage:FindFirstChild("Assets") or error("Spawner: ServerStorage.Assets folder not found")
local PacksFolder = Assets:FindFirstChild("Packs") or error("Spawner: ServerStorage.Assets.Packs folder not found")

-- Create the billboard on the pack
local function CreateInteraction(cardModel: Model | BasePart, packData: any)
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Buy"
    prompt.ObjectText = packData.DisplayName or "Pack"
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.HoldDuration = 0  -- Instant interaction
    prompt.RequiresLineOfSight = false
    prompt.Parent = cardModel
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 300, 0, 100) -- Bigger billboard
    billboard.StudsOffset = Vector3.new(0, 4, 0) -- Slightly higher
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 20
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0) -- Better visibility
    textLabel.TextScaled = true
    textLabel.Text = packData.Description or "A mystery pack"
    textLabel.Parent = billboard
    
    billboard.Parent = cardModel
    
    prompt.Triggered:Connect(function(triggerPlayer, _)
        -- Add to inventory
        local packId = cardModel:GetAttribute("PackId")
        if packId then
            print("Spawner: Firing PackCollected for " .. triggerPlayer.Name .. " - " .. packId)
            PackCollectedEvent:Fire(triggerPlayer, packId)
		else
			error("Spawner: PackId not found for card " .. cardModel.Name)
		end
        cardModel:Destroy()
    end)
end

-- Global Movement Loop
RunService.Heartbeat:Connect(function(dt)
	for _, cardFolder in pairs(activeCardFolders) do
		for _, card in ipairs(cardFolder:GetChildren()) do
			local startPos = card:GetAttribute("StartPos")
			local moveDir = card:GetAttribute("MoveDirection")
			local maxDist = card:GetAttribute("MaxDistance") or 90
			
			if startPos and moveDir then
				local currentPos: Vector3
				local currentCFrame: CFrame
				
				if card:IsA("Model") and card.PrimaryPart then
					currentPos = card.PrimaryPart.Position
					currentCFrame = card.PrimaryPart.CFrame
				elseif card:IsA("BasePart") then
					currentPos = card.Position
					currentCFrame = card.CFrame
				else
					card:Destroy()
					continue
				end
				
				local dist = (currentPos - startPos).Magnitude

				if dist > maxDist then
					-- Reached max distance
					card:Destroy()
				else
					-- Move in direction
					local newCFrame = currentCFrame + (moveDir * BELT_SPEED * dt)
					if card:IsA("Model") then
						card:PivotTo(newCFrame)
					else
						card.CFrame = newCFrame
					end
				end
			else
				-- Card missing attributes or old format
				card:Destroy()
			end
		end
	end
end)

function Spawner.SpawnForPlayer(player: Player, baseIndex: number)
	local spawnerPart = WorkspaceUtils.GetSpawnerPart(baseIndex)
	-- Despawner part no longer needed for movement target
	
	local cardFolder = activeCardFolders[player.UserId]
	if not cardFolder then
		error("Spawner: No active card folder for player " .. player.Name)
		return
	end
	
    -- Pick a random pack
    local packKeys = {}
    for key, _ in pairs(PackConfig) do
        table.insert(packKeys, key)
    end
    
    if #packKeys == 0 then
        error("Spawner: No packs configured")
        return
    end
    
    local randomPackId = packKeys[math.random(1, #packKeys)]
    local packModel = PacksFolder:FindFirstChild(randomPackId)
    
    if not packModel then
        error("Spawner: Pack model not found regarding PackId: " .. tostring(randomPackId))
        return
    end

	local card = packModel:Clone()
	card.Name = randomPackId
	card.Parent = cardFolder
	
	-- Set Attributes for Movement
	card:SetAttribute("StartPos", spawnerPart.Position)
	card:SetAttribute("MoveDirection", Vector3.new(1, 0, 0)) -- Always move to the right
	card:SetAttribute("MaxDistance", 90) -- Triple the distance to 90 studs
	
	card:SetAttribute("OwnerName", player.Name)
	card:SetAttribute("PackId", randomPackId)
    
    -- Create Interaction (Billboard + Prompt)
    local packData = PackConfig[randomPackId]
    if packData then
        CreateInteraction(card, packData)
    end
    
    -- Spawn slightly higher
    local spawnOffset = Vector3.new(0, 2, 0)
	
	if card:IsA("Model") then
		card:PivotTo(spawnerPart.CFrame + spawnOffset)
	elseif card:IsA("BasePart") then
		card.CFrame = spawnerPart.CFrame + spawnOffset
	end
end

function Spawner.InitializeForPlayer(player: Player)
	if activeLoops[player.UserId] then return end
	activeLoops[player.UserId] = true

    local sessionData = Store.GetPlayerTemporaryData(player)
    local occupiedBase = sessionData and sessionData.occupiedBase
    if not occupiedBase then
        activeLoops[player.UserId] = nil
        error("Spawner: No occupied base found for player " .. player.Name)
    end

    local baseModel = WorkspaceUtils.GetBaseModel(occupiedBase)
    local pipeline = baseModel:FindFirstChild("Pipeline")
    if not pipeline then
        activeLoops[player.UserId] = nil
        error("Spawner: Pipeline folder not found for Base " .. occupiedBase)
    end
    
    local cardFolder = pipeline:FindFirstChild("SpawnedCards")
    if not cardFolder then
        activeLoops[player.UserId] = nil
        error("Spawner: SpawnedCards folder not found for Base " .. occupiedBase)
    end
    
    activeCardFolders[player.UserId] = cardFolder
	
	task.spawn(function()
		while activeLoops[player.UserId] and player.Parent do
            Spawner.SpawnForPlayer(player, occupiedBase)
			task.wait(SPAWN_RATE)
		end
		activeLoops[player.UserId] = nil
        activeCardFolders[player.UserId] = nil
	end)
end

function Spawner.StopForPlayer(player: Player)
	activeLoops[player.UserId] = nil
    activeCardFolders[player.UserId] = nil
end

return Spawner
