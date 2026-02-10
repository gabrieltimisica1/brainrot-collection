-- --!strict
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local ServerScriptService = game:GetService("ServerScriptService")

-- local CardManager = require(ServerScriptService.CollectionGame.Core.CardManager)
-- local Store = require(ServerScriptService.CollectionGame.Data.Store)
-- local CardConfig = require(ServerScriptService.CollectionGame.Configs.CardConfig)

-- local RemotesFolder = ReplicatedStorage:WaitForChild("CollectionGame"):WaitForChild("Remotes")
-- local GetCollectionDataParams = RemotesFolder:WaitForChild("GetCollectionData")
-- local CollectMoneyEvent = RemotesFolder:WaitForChild("CollectMoney")

-- -- Handlers

-- GetCollectionDataParams.OnServerInvoke = function(player)
--     local pData = Store.GetPlayerPersistentData(player)
--     if not pData then error("Network: No persistent data found for " .. player.Name) end
    
--     -- Metadata about cards (DisplayNames, etc.) since CardConfig is now Server-Only
--     local cardMetadata = {}
--     for id, config in pairs(CardConfig) do
--         cardMetadata[id] = {
--             DisplayName = config.DisplayName,
--             Rarity = config.Rarity,
--             BaseIncome = config.BaseIncome,
--             MaxLevel = config.MaxLevel
--         }
--     end
    
--     return {
--         PersistentData = pData,
--         Metadata = cardMetadata
--     }
-- end

-- CollectMoneyEvent.OnServerEvent:Connect(function(player, cardId)
--     if typeof(cardId) ~= "string" then error("Network: Invalid cardId received from " .. player.Name) end
--     CardManager.CollectMoney(player, cardId)
-- end)

-- return {}
