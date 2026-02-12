--!strict
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Store = require(ServerScriptService.CollectionGame.Data.Store)
local ManageBase = require(ServerScriptService.CollectionGame.Core.ManageBase)
local CardsSpawner = require(ServerScriptService.CollectionGame.Core.CardsSpawner)
local InventoryManager = require(ServerScriptService.CollectionGame.Core.InventoryManager)

local function onPlayerAdded(player: Player)
	print("Lifecycle: Player Added - " .. player.Name)

	Store.InitializeSession(player)
	ManageBase.Initialize(player)
    CardsSpawner.InitializeForPlayer(player)
    InventoryManager.Initialize(player)

	player.CharacterAdded:Connect(function(character)
		ManageBase.TeleportToOwnedBase(player)
	end)
end

local function onPlayerRemoving(player: Player)
	print("Lifecycle: Player Removing - " .. player.Name)
    CardsSpawner.StopForPlayer(player)
	ManageBase.ReleaseFromPlayer(player)
    InventoryManager.Cleanup(player)
	Store.ClearSession(player)
end

-- Listen for events
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle players already in the server (Studio testing)
-- TODO ?
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

-- BindToClose ensures data is saved on server shutdown
game:BindToClose(function()
    print("Lifecycle: Server shutting down, saving all data...")
    for _, player in ipairs(Players:GetPlayers()) do
        Store.SaveToCloud(player)
    end
    task.wait(2)
end)

return {}
