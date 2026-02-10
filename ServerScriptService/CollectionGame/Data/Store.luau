--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreService = game:GetService("DataStoreService")

local Types = require(script.Parent.Types)

local playerDataStore = DataStoreService:GetDataStore("CollectionGame_V1")

local Store = {
	temporaryData = {
        bases = {},
		players = {},
	},
	persistentData = {
		players = {},
	}
}

-- Initialize 8 bases (Global Server State)
for i = 1, 8 do
	Store.temporaryData.bases[i] = {
		owner = nil, 
		locked = true,
	}
end

-- --- CLOUD METHODS ---

function Store.LoadFromCloud(player: Player): Types.PlayerPersistentData?
	local key = "Player_" .. player.UserId
	local success, data = pcall(function()
		return playerDataStore:GetAsync(key)
	end)
	
	if success and data then
		print("Store: Cloud data loaded", data)
		return data
	else
		return nil
	end
end

function Store.SaveToCloud(player: Player)
	local userId = tostring(player.UserId)
	local data = Store.persistentData.players[userId]
    if not data then return end

	local key = "Player_" .. player.UserId
	local success, err = pcall(function()
		playerDataStore:SetAsync(key, data)
	end)
	
	if not success then
		error("Store: Cloud save failed for " .. player.Name .. ": " .. tostring(err))
	end
end

-- --- SESSION METHODS ---

function Store.InitializeSession(player: Player)
	local userId = tostring(player.UserId)
	local savedData = Store.LoadFromCloud(player)
	
    if savedData then
        if not savedData.Collection then savedData.Collection = {} end
        if not savedData.Money then savedData.Money = 0 end
        if not savedData.SealedPacks then savedData.SealedPacks = 0 end
        
		Store.persistentData.players[userId] = savedData
	else
		print("New player joined: " .. player.Name)
		Store.persistentData.players[userId] = {
			Money = 0,
			Collection = {},
            SealedPacks = 0,
		}
	end
    
	Store.temporaryData.players[userId] = {
		IncomeRate = 0,
        occupiedBase = nil,
	}
end

function Store.GetPlayerPersistentData(player: Player): Types.PlayerPersistentData
	return Store.persistentData.players[tostring(player.UserId)]
end

function Store.GetPlayerTemporaryData(player: Player): Types.PlayerSessionData
	return Store.temporaryData.players[tostring(player.UserId)]
end

function Store.ClearSession(player: Player)
	local userId = tostring(player.UserId)
    Store.SaveToCloud(player)
	Store.persistentData.players[userId] = nil
	Store.temporaryData.players[userId] = nil
end

return Store
