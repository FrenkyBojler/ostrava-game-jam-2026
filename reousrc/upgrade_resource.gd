class_name UpgradeResource extends Resource

@export
var headling: String

@export
var description: String

@export
var value: Variant

@export
var property: String

@export
var rarity: int

@export
var texture: CompressedTexture2D

enum Rarity { COMMON, RARE, LEGENDARY }

# Each entry: [property, description_template, rarity, value]
# Property format: "gun.<prop>" for gun stats, "player.<prop>" for player stats
const UPGRADE_POOL: Array = [
	# -- COMMON (small buffs) --
	["gun.dmg", "+{value} Damage", Rarity.COMMON, 2.0],
	["gun.max_ammo", "+{value} Max Ammo", Rarity.COMMON, 5],
	["gun.reload_time", "-{value}s Reload Time", Rarity.COMMON, 0.15],
	["gun.rate_of_fire", "-{value}s Fire Rate", Rarity.COMMON, 0.03],
	["gun.projectile_speed", "+{value} Projectile Speed", Rarity.COMMON, 3.0],
	["player.max_health", "+{value} Max Health", Rarity.COMMON, 10.0],
	["player.walk_speed", "+{value} Walk Speed", Rarity.COMMON, 1.0],
	["player.run_speed", "+{value} Run Speed", Rarity.COMMON, 1.0],
	# -- RARE (medium buffs) --
	["gun.dmg", "+{value} Damage", Rarity.RARE, 5.0],
	["gun.max_ammo", "+{value} Max Ammo", Rarity.RARE, 12],
	["gun.reload_time", "-{value}s Reload Time", Rarity.RARE, 0.35],
	["gun.rate_of_fire", "-{value}s Fire Rate", Rarity.RARE, 0.06],
	["gun.radius_of_dmg", "+{value} Explosion Radius", Rarity.RARE, 1.5],
	["player.max_health", "+{value} Max Health", Rarity.RARE, 25.0],
	["player.jump_height", "+{value} Jump Height", Rarity.RARE, 0.5],
	["player.run_speed", "+{value} Run Speed", Rarity.RARE, 2.5],
	# -- LEGENDARY (big buffs) --
	["gun.dmg", "+{value} Damage", Rarity.LEGENDARY, 12.0],
	["gun.reload_time", "-{value}s Reload Time", Rarity.LEGENDARY, 0.6],
	["gun.rate_of_fire", "-{value}s Fire Rate", Rarity.LEGENDARY, 0.1],
	["gun.ttl", "+{value}s Projectile Lifetime", Rarity.LEGENDARY, 0.8],
	["player.max_health", "+{value} Max Health", Rarity.LEGENDARY, 50.0],
	["player.max_desired_move_speed", "+{value} Max Speed", Rarity.LEGENDARY, 5.0],
]

# Rarity weights: common appears more often, legendary is rare
const RARITY_WEIGHTS: Dictionary = {
	Rarity.COMMON: 60,
	Rarity.RARE: 30,
	Rarity.LEGENDARY: 10,
}

const RARITY_NAMES: Dictionary = {
	Rarity.COMMON: "Common",
	Rarity.RARE: "Rare",
	Rarity.LEGENDARY: "Legendary",
}

static func generate_upgrades(count: int = 3) -> Array[UpgradeResource]:
	var result: Array[UpgradeResource] = []
	var used_properties: Array[String] = []

	# One slot has a chance to be a heal card
	if randi() % 100 < 40:
		var heal = UpgradeResource.new()
		heal.property = "player.heal"
		heal.value = 1
		heal.description = "Restore {value} HP".replace("{value}", str(heal.value))
		heal.rarity = Rarity.COMMON
		heal.headling = "Heal"
		result.append(heal)

	while result.size() < count:
		var rarity = _pick_rarity()
		var candidates = UPGRADE_POOL.filter(func(entry): return entry[2] == rarity and not used_properties.has(entry[0]))

		if candidates.is_empty():
			candidates = UPGRADE_POOL.filter(func(entry): return entry[2] == rarity)
		if candidates.is_empty():
			continue

		var entry = candidates.pick_random()
		randomize()

		var upgrade = UpgradeResource.new()
		upgrade.property = entry[0]
		upgrade.description = str(entry[1]).replace("{value}", str(entry[3]))
		upgrade.rarity = entry[2]
		upgrade.value = entry[3]
		upgrade.headling = RARITY_NAMES[entry[2]] + " Upgrade"

		used_properties.append(entry[0])
		result.append(upgrade)

	return result

static func _pick_rarity() -> Rarity:
	var total = 0
	for w in RARITY_WEIGHTS.values():
		total += w
	var roll = randi() % total
	var cumulative = 0
	for r in RARITY_WEIGHTS.keys():
		cumulative += RARITY_WEIGHTS[r]
		if roll < cumulative:
			return r as Rarity
	return Rarity.COMMON
