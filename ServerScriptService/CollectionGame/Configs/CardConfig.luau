--!strict

export type Grade = "F" | "E" | "D" | "C" | "B" | "A" | "S" | "S+" | "SS" | "None"

export type CardEntry = {
	Id: string,
	DisplayName: string,
	Level: number, -- current level
	MoneyPerSecond: number, -- Money it generates per second
	Exp: number, -- Exp it currently has
	Grade: Grade, -- You can grade cards
	Description: string,
}

-- When grading, your card's money generation will be multiplied by the grade's multiplier
local GradeMoneyGenerationMultiplier: { [Grade]: number } = {
	["F"] = 1,
	["E"] = 2,
	["D"] = 3,
	["C"] = 4,
	["B"] = 5,
	["A"] = 6,
	["S"] = 7,
	["S+"] = 8,
	["SS"] = 9,
    ["None"] = 1,
}

local CardConfig: { [string]: CardEntry } = {
	["skibidi_toilet"] = {
		Id = "skibidi_toilet",
		DisplayName = "Skibidi Toilet",
		Level = 1,
        MoneyPerSecond = 1,
        Exp = 0,
        Grade = "None",
		Description = "A singing toilet from Ohio. Very common.",
	},
	["fanum_tax"] = {
		Id = "fanum_tax",
		DisplayName = "Fanum Tax Collector",
		Level = 1,
        MoneyPerSecond = 3,
        Exp = 0,
        Grade = "None",
		Description = "He will tax your food. Generates steady income.",
	},
	["ohio_rizzler"] = {
		Id = "ohio_rizzler",
		DisplayName = "Ohio Rizzler",
		Level = 1,
        MoneyPerSecond = 8,
        Exp = 0,
        Grade = "None",
		Description = "Rizz levels appearing from the mist of Ohio.",
	},
	["grimace_shake"] = {
		Id = "grimace_shake",
		DisplayName = "Grimace Shake",
		Level = 1,
        MoneyPerSecond = 20,
        Exp = 0,
        Grade = "None",
		Description = "Happy Birthday Grimace! Don't drink it.",
	},
	["sigma_male"] = {
		Id = "sigma_male",
		DisplayName = "Sigma Male",
		Level = 1,
        MoneyPerSecond = 25,
        Exp = 0,
        Grade = "None",
		Description = "Respect the grind. High income potential.",
	},
	["giga_chad"] = {
		Id = "giga_chad",
		DisplayName = "Giga Chad",
		Level = 1,
        MoneyPerSecond = 50,
        Exp = 0,
        Grade = "None",
		Description = "The ultimate specimen. Massive income.",
	},
	["max_prestige_gnome"] = {
		Id = "max_prestige_gnome",
		DisplayName = "Max Prestige Gnome",
		Level = 1,
        MoneyPerSecond = 150,
        Exp = 0,
        Grade = "None",
		Description = "Wizards fear him. The peak of brain rot.",
	},
}

return {
    Cards = CardConfig,
    GradeMultipliers = GradeMoneyGenerationMultiplier
}
