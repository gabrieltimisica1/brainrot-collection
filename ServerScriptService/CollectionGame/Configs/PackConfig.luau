--!strict

-- TODO: add time to unpack the pack, which is per rarity


export type PackEntry = {
	PackId: string,
	DisplayName: string,
	Rarity: string,
	Price: number,
	Cards: { [string]: number }, -- CardId: Weight
}

local PackConfig: { [string]: PackEntry } = {
	["Pack1"] = {
		PackId = "Pack1", -- this is how they are named in the workspace
		DisplayName = "Basic Brain Rot Pack",
		Rarity = "Common",
		Price = 100,
		Cards = {
			["skibidi_toilet"] = 60,
			["fanum_tax"] = 30,
			["ohio_rizzler"] = 10,
		}
	},
	["Pack2"] = {
		PackId = "Pack2",
		DisplayName = "Advanced Rizz Pack",
		Rarity = "Rare",
		Price = 500,
		Cards = {
			["ohio_rizzler"] = 50,
			["grimace_shake"] = 30,
			["sigma_male"] = 15,
			["giga_chad"] = 5,
		}
	},
	["Pack3"] = {
		PackId = "Pack3",
		DisplayName = "Advanced Rizz Pack",
		Rarity = "Rare",
		Price = 500,
		Cards = {
			["ohio_rizzler"] = 50,
			["grimace_shake"] = 30,
			["sigma_male"] = 15,
			["giga_chad"] = 5,
		}
	}
}

return PackConfig
