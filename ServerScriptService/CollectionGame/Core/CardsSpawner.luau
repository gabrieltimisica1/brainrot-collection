--!strict
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Store = require(script.Parent.Parent.Data.Store)
local WorkspaceUtils = require(script.Parent.Parent.Utils.WorkspaceUtils)

local Spawner = {}
local activeLoops = {}
local activeCardFolders = {} -- [UserId] = Folder

-- Configuration
local BELT_SPEED = 8
local SPAWN_RATE = 1

-- Assets
local Assets = ServerStorage:FindFirstChild("Assets") or error("Spawner: ServerStorage.Assets folder not found")
local CardModelBase = Assets.Cards.fanum_tax:FindFirstChild("fanum_tax_common") or error("Spawner: ServerStorage.Assets.CardModel not found")

-- Global Movement Loop
RunService.Heartbeat:Connect(function(dt)
	for _, cardFolder in pairs(activeCardFolders) do
		for _, card in ipairs(cardFolder:GetChildren()) do
			local targetPos = card:GetAttribute("TargetPos")
			if targetPos then
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
				
				local direction = (targetPos - currentPos).Unit
				local distance = (targetPos - currentPos).Magnitude

				if distance < 1 then
					-- Reached despawner
					card:Destroy()
				else
					-- Move towards target
					local newCFrame = currentCFrame + (direction * BELT_SPEED * dt)
					if card:IsA("Model") then
						card:PivotTo(newCFrame)
					else
						card.CFrame = newCFrame
					end
				end
			else
				card:Destroy()
			end
		end
	end
end)

function Spawner.SpawnForPlayer(player: Player, baseIndex: number)
	local spawnerPart = WorkspaceUtils.GetSpawnerPart(baseIndex)
	local despawnerPart = WorkspaceUtils.GetDespawnerPart(baseIndex)
	
	local cardFolder = activeCardFolders[player.UserId]
	if not cardFolder then
		warn("Spawner: No active card folder for player " .. player.Name)
		return
	end
	
	local card = CardModelBase:Clone()
	card.Name = "Card"
	card.Parent = cardFolder
	
	card:SetAttribute("TargetPos", despawnerPart.Position)
	card:SetAttribute("OwnerName", player.Name)
	
	if card:IsA("Model") then
		card:PivotTo(spawnerPart.CFrame)
	elseif card:IsA("BasePart") then
		card.CFrame = spawnerPart.CFrame
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
        -- Create if missing or error? User code implies expected existence or finding it.
        -- User's previous code: `... or error(...) `
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
