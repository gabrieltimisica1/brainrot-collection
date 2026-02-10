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

return ProgressionConfig
