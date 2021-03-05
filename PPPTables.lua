-- ALL THE PLANTS --
PPPPlants = {
	[168583] = {
		name="Widowbloom",
		tech_name="Widowbloom",
		file=3610996,
		pigments={
			173056,175788,173057
		},
	},
	[171315] = {
		name="Nightshade",
		tech_name="Nightshade",
		file=3692438,
		pigments={
			173056,175788,173057
		},
	},
	[168586] = {
		name="Rising Glory",
		tech_name="RisingGlory",
		file=3613630,
		pigments={
			173056,175788,173057
		},
	},
	[170554] = {
		name="Vigil's Torch",
		tech_name="VigilsTorch",
		file=3387974,
		pigments={
			173056,175788,173057
		},
	},
	[168589] = {
		name="Marrowroot",
		tech_name="Marrowroot",
		file=3480675,
		pigments={
			173056,175788,173057
		},
	},
	[169701] = {
		name="Death Blossom",
		tech_name="DeathBlossom",
		file=3502461,
		pigments={
			173056,175788,173057
		},
	}
}
PPPShadowlandsPlants = {168583,171315,168586,170554,168589,169701}

-- ALL THE PIGMENTS --
PPPPigments = {
	[173057] = {
		name="Luminous Pigment",
		file=3716974,
		ink=173059,
	},
	[175788] = {
		name="Tranquil Pigment",
		file=3716977,
		ink=175970,
	},
	[173056] = {
		name="Umbral Pigment",
		file=3716978,
		ink=173058,
	}
}

-- ALL THE INKS --
PPPInks = {
	[173059] = {
		name="Luminous Ink",
		file=3716970,
		pigment=173057,
	},
	[175970] = {
		name="Tranquil Ink",
		file=3716971,
		pigment=175788,
	},
	[173058] = {
		name="Umbral Ink",
		file=3716972,
		pigment=173056,
	},
}

-- ALL THE MILLING SPELLS --
PPPMillingSpells = {
	[51005] = true, -- normal milling
	[311413] = 169701, -- mass death blossom
	[311414] = 170554, -- mass vigil's torch
	[311415] = 168583, -- mass widowbloom
	[311416] = 168589, -- mass marrowroot
	[311417] = 168586, -- mass rising glory
	[311418] = 171315, -- mass nightshade
}

-- ALL THE ALCHEMY CREATIONS --
PPPAlchemyCreations = {
	[171276] = {
		name = "Spectral Flask of Power",
		tech_name = "SpectralFlaskOfPower",
		file=3566840,
		ingredients = {
			[171315] = 3,
			[168586] = 4,
			[168589] = 4,
			[168583] = 4,
			[170554] = 4
		}
	},
	[171273] = {
		name = "Potion of Spectral Intellect",
		tech_name = "PotionOfSpectralIntellect",
		file=3566836,
		ingredients = {
			[168589] = 5
		}
	},
	[171278] = {
		name="Spectral Flask of Stamina",
		tech_name="SpectralFlaskOfStamina",
		file=3566841,
		ingredients={
			[171315] = 1,
			[168586] = 3,
			[168589] = 3,
		},
	},
	[171270] = {
		name="Potion of Spectral Agility",
		tech_name="PotionOfSpectralIntellect",
		file=3566835,
		ingredients={
			[168583] = 5
		}
	},
	[171274] = {
		name="Potion of Spectral Stamina",
		tech_name="PotionOfSpectralStamina",
		file=3566837,
		ingredients={
			[170554]=5
		}
	}
}
PPPShadowlandsAlchemy = {171276, 171273,171278,171270,171274}

-- ALL THE INSCRIPTION CREATIONS --
PPPInscriptionCreations = {
	[173067] = {
		name="Vantus Rune: Castle Nathria",
		tech_name="VantusRuneCastleNathria",
		file=3716924,
		ingredients={
			[173059]=10, -- luminous
			[173058]=10, -- umbral
			[175970]=1 -- tranquil
		}
	},
	[173160]={
		name="Missive of Haste",
		tech_name="MissiveOfHaste",
		file=3717598,
		ingredients={
			[173059]=6,
			[173058]=4,
			[175970]=1,
		}
	},
	[173161]={
		name="Missive of Critical Strike",
		tech_name="MissiveOfCriticalStrike",
		file=3717596,
		ingredients={
			[173059]=8,
			[173058]=2,
			[175970]=1
		}
	},
	[173163]={
		name="Missive of Versatility",
		tech_name="MissiveOfVersatility",
		file=3717599,
		ingredients={
			[173059]=2,
			[173058]=8,
			[175970]=1
		}
	},
	[173162]={
		name="Missive of Mastery",
		tech_name="MissiveOfMastery",
		file=3717603,
		ingredients={
			[173059]=4,
			[173058]=6,
			[175970]=1
		}
	},
	[173048]={
		name="Codex of the Still Mind",
		tech_name="CodexOfTheStillMind",
		file=3717417,
		ingredients={
			[173059]=7,
			[173058]=7,
			[175970]=1
		}
	},
	[173049]={
		name="Tome of the Still Mind",
		tech_name="TomeOfTheStillMind",
		file=3717418,
		ingredients={
			[173059]=3,
			[173058]=3
		}
	}
}
PPPShadowlandsInscription = {173067,173048,173049,173160,173161,173163,173162}
