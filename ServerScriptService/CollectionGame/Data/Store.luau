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

local newPlayerPersistentData = {
    Money = 0,
    Collection = {},
    Inventory = {},
    PlacedPacks = {},
}

-- this is what the player gets when they join
local playerTemporaryData = {
    IncomeRate = 0,
    occupiedBase = nil,
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
		--print("Store: Cloud data loaded", data)
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
        if not savedData.Inventory then savedData.Inventory = {} end
        if not savedData.PlacedPacks then savedData.PlacedPacks = {} end
        
		Store.persistentData.players[userId] = savedData
	else
		print("New player joined: " .. player.Name)
        -- Deep copy or at least shallow copy to avoid reference sharing
		Store.persistentData.players[userId] = {
            Money = newPlayerPersistentData.Money,
            Collection = table.clone(newPlayerPersistentData.Collection),
            Inventory = table.clone(newPlayerPersistentData.Inventory),
            PlacedPacks = table.clone(newPlayerPersistentData.PlacedPacks),
        }
	end
    
	Store.temporaryData.players[userId] = {
        IncomeRate = playerTemporaryData.IncomeRate,
        occupiedBase = playerTemporaryData.occupiedBase 
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

function Store.AddPackToInventory(player: Player, packId: string)
    local persistentData = Store.GetPlayerPersistentData(player)
    persistentData.Inventory[packId] = (persistentData.Inventory[packId] or 0) + 1
	print("Store: Added pack " .. packId .. " to inventory for " .. player.Name)
	print(persistentData.Inventory)
end

return Store
