--!strict

-- Import Grade type from CardConfig if possible, or redefine for independence
export type Grade = "F" | "E" | "D" | "C" | "B" | "A" | "S" | "S+" | "SS" | "None"

export type CardInstance = {
	Level: number,
	Exp: number,
    Grade: Grade,
    moneyCollected: number, -- Money waiting to be collected (lowercase per user request)
}

export type Collection = { [string]: CardInstance }

export type PlayerPersistentData = {
	Money: number,
	Collection: Collection,
    SealedPacks: number,
}

export type BaseData = {
	owner: string?, -- UserId
	locked: boolean,
}

export type PlayerSessionData = {
    IncomeRate: number,
    occupiedBase: number?,
}

export type StoreData = {
    temporaryData: {
        bases: { [number]: BaseData },
        players: { [string]: PlayerSessionData }
    },
    persistentData: {
        players: { [string]: PlayerPersistentData }
    }
}

return {}
