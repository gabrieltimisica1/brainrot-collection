--!strict
local Store = require(script.Parent.Parent.Data.Store)
local WorkspaceUtils = require(script.Parent.Parent.Utils.WorkspaceUtils)

local ManageBase = {}

-- Logic to find and assign a base
function ManageBase.AssignToPlayer(player: Player)
	local available = {}
	for i = 1, 8 do
        local base = Store.temporaryData.bases[i]
		if not base.owner then
			table.insert(available, i)
		end
	end
	
	if #available > 0 then
		local baseIndex = available[1] -- Just take the first available for now
		local userId = tostring(player.UserId)
		local base = Store.temporaryData.bases[baseIndex]
		local sessionData = Store.GetPlayerTemporaryData(player)
		
		base.owner = userId
		base.locked = false
		sessionData.occupiedBase = baseIndex
		
		print("ManageBase: Assigned " .. player.Name .. " to Base " .. baseIndex)
		return baseIndex
	else
		error("ManageBase: No available bases for " .. player.Name)
        return nil
	end
end

-- Logic to release a base
function ManageBase.ReleaseFromPlayer(player: Player)
	local sessionData = Store.GetPlayerTemporaryData(player)
	if sessionData and sessionData.occupiedBase ~= nil then
        local baseIndex = sessionData.occupiedBase
		Store.temporaryData.bases[baseIndex].owner = nil
		Store.temporaryData.bases[baseIndex].locked = true
		print("ManageBase: Released Base " .. baseIndex)
		sessionData.occupiedBase = nil
	end
end

-- Logic to move player character to their base (Visual/Spawn logic)
function ManageBase.TeleportToOwnedBase(player: Player)
	task.defer(function()
		local sessionData = Store.GetPlayerTemporaryData(player)
		local baseId = sessionData and sessionData.occupiedBase
		if not baseId then
			error("ManageBase: No base assigned to player " .. player.Name)
		end
		
        local spawnPoint = WorkspaceUtils.GetPlayerSpawnPoint(baseId)
		
		local character = player.Character or player.CharacterAdded:Wait()
		local rootPart = character:WaitForChild("HumanoidRootPart", 5)
		if rootPart then
			character:PivotTo(spawnPoint.CFrame + Vector3.new(0, 5, 0))
		else
			error("ManageBase: Character HumanoidRootPart not found for player " .. player.Name)
		end
	end)
end

function ManageBase.Initialize(player: Player)
    local baseIndex = ManageBase.AssignToPlayer(player)
    if baseIndex then
        ManageBase.TeleportToOwnedBase(player)
    else
        error("ManageBase: Critical failure assigning base to " .. player.Name)
    end
end

return ManageBase
