--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Store = require(script.Parent.Parent.Data.Store)
local CardConfig = require(ServerScriptService.CollectionGame.Configs.CardConfig)
local ProgressionConfig = require(ServerScriptService.CollectionGame.Configs.ProgressionConfig)

local CardManager = {}

function CardManager.AddCard(player: Player, cardId: string, levelAmount: number)
    local data = Store.GetPlayerPersistentData(player)
    if not data then return end
    
    local config = CardConfig.Cards[cardId]
    if not config then 
        error("CardManager: Invalid Card ID: " .. cardId)
    end
    
    local collection = data.Collection
    
    if not collection[cardId] then
        collection[cardId] = {
            Level = config.Level or 1,
            Exp = config.Exp or 0,
            Grade = config.Grade or "None",
            moneyCollected = 0
        }
    else
        local currentCard = collection[cardId]
        
        -- Use universal ProgressionConfig for leveling
        if currentCard.Level >= ProgressionConfig.MaxLevel then
            -- Refund if at max level
            local refund = config.MoneyPerSecond * 10 
            data.Money += refund
        else
            -- For now, simple level addition or merge logic
            local nextLevel = math.min(currentCard.Level + levelAmount, ProgressionConfig.MaxLevel)
            currentCard.Level = nextLevel
        end
    end
    
    CardManager.RecalculateIncome(player)
end

function CardManager.RecalculateIncome(player: Player)
    local pData = Store.GetPlayerPersistentData(player)
    local tData = Store.GetPlayerTemporaryData(player)
    if not pData or not tData then return end
    
    local totalIncome = 0
    
    for cardId, instance in pairs(pData.Collection) do
        local config = CardConfig.Cards[cardId]
        if config then
            local gradeMultiplier = CardConfig.GradeMultipliers[instance.Grade] or 1
            -- Income = BasePerSec * GradeMultiplier * Level
            local income = config.MoneyPerSecond * gradeMultiplier * instance.Level
            totalIncome += income
        end
    end
    
    tData.IncomeRate = totalIncome
end

function CardManager.CollectMoney(player: Player, cardId: string)
    local pData = Store.GetPlayerPersistentData(player)
    if not pData then return 0 end
    
    local card = pData.Collection[cardId]
    if card and card.moneyCollected > 0 then
        local amount = card.moneyCollected
        pData.Money += amount
        card.moneyCollected = 0
        return amount
    end
    return 0
end

return CardManager
