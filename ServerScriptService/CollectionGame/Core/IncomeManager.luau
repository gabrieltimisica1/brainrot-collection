--!strict
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local Store = require(script.Parent.Parent.Data.Store)
local CardConfig = require(ServerScriptService.CollectionGame.Configs.CardConfig)

local IncomeManager = {}
local TICK_RATE = 1 
local lastTick = os.time()

function IncomeManager.Start()
	RunService.Heartbeat:Connect(function()
		local now = os.time()
		if now - lastTick >= TICK_RATE then
			lastTick = now
			IncomeManager.ProcessAllPlayers()
		end
	end)
end

function IncomeManager.ProcessAllPlayers()
	for _, player in ipairs(Players:GetPlayers()) do
		local pData = Store.GetPlayerPersistentData(player)
        
		if pData and pData.Collection then
            for cardId, instance in pairs(pData.Collection) do
                local config = CardConfig.Cards[cardId]
                if config then
                    local gradeMult = CardConfig.GradeMultipliers[instance.Grade] or 1
                    local income = config.MoneyPerSecond * gradeMult * instance.Level
                    
                    if not instance.moneyCollected then instance.moneyCollected = 0 end
                    instance.moneyCollected += income
                end
            end
		end
	end
end

return IncomeManager
