--!strict

export type LevelConfig = {
    MaxLevel: number,
    ExpToLevelUp: { [number]: number }, -- Level: XP required to reach NEXT level
    ExpPerCombine: number, -- Flat XP given when any card is used as material
}

local ProgressionConfig: LevelConfig = {
    MaxLevel = 7,
    ExpPerCombine = 10,
    ExpToLevelUp = {
        [1] = 20,
        [2] = 50,
        [3] = 120,
        [4] = 300,
        [5] = 750,
        [6] = 2000,
    }
}

local GradingConfig = {
    Cost = 100, -- TODO: this needs to be moved somewhere else
    Grades = {
        ["F"] = { Chance = 1, Multiplier = 1 },
        ["E"] = { Chance = 2, Multiplier = 2 },
        ["D"] = { Chance = 3, Multiplier = 3 },
        ["C"] = { Chance = 4, Multiplier = 4 },
        ["B"] = { Chance = 15, Multiplier = 5 },
        ["A"] = { Chance = 10, Multiplier = 6 },
        ["S"] = { Chance = 1, Multiplier = 7 },
        ["S+"] = { Chance = 0.5, Multiplier = 8 },
        ["SS"] = { Chance = 0.25, Multiplier = 9 },
    }
}

return {
    Progression = ProgressionConfig,
    Grading = GradingConfig
}
