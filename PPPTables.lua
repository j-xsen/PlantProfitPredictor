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
		pigment=173059,
	},
	[175788] = {
		name="Tranquil Pigment",
		file=3716977,
		pigment=175970,
	},
	[173056] = {
		name="Umbral Pigment",
		file=3716978,
		pigment=173058,
	}
}

PPPInks = {
	[173059] = {
		name="Luminous Ink",
		file=3716970,
	},
	[175970] = {
		name="Tranquil Ink",
		file=3716971,
	},
	[173058] = {
		name="Umbral Ink",
		file=3716972,
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
	}
}
PPPShadowlandsAlchemy = {171276, 171273,171278}
