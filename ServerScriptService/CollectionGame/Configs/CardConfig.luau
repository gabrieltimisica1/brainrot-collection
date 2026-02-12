--!strict

export type Grade = "F" | "E" | "D" | "C" | "B" | "A" | "S" | "S+" | "SS" | "None"

export type Rarity = "Common" | "Bronze" | "Silver" | "Gold" | "Platinum" | "Diamond" | "Legendary"

export type CardConfig = {
	Id: string,
	DisplayName: string,
	Level: number, -- current level
	Rarity: Rarity,
	MoneyPerSecond: number, -- Money it generates per second
	Exp: number, -- Exp it currently has
	Grade: Grade, -- You can grade cards
	Description: string,
}

local listOfCards = {
    "skibidi_toilet",
    "fanum_tax",
    "ohio_rizzler",
    "grimace_shake",
    "sigma_male",
    "giga_chad",
    "max_prestige_gnome",
}

return {
    Cards = listOfCards,
}
