class_name Upgrade extends TextureButton

@export
var upgrade_res: UpgradeResource

func _ready() -> void:
	%Headline.text = upgrade_res.headling
	%Description.text = upgrade_res.description
	%Value.text = str(upgrade_res.value)
	modulate = rarity_to_color(upgrade_res.rarity)
	
	pressed.connect(func():
		_pick_upgrade()
	)

func _pick_upgrade() -> void:
	GlobalUpgrades.pick_upgrade(upgrade_res)

func rarity_to_color(rarity: int) -> Color:
	var t = float(rarity - 1) / 4.0  # normalize 1–5 → 0–1
	
	var hue = lerp(0.0, 0.75, t)     # red → purple
	var saturation = lerp(0.1, 0.9, t)
	var value = lerp(0.6, 1.0, t)
	
	return Color.from_hsv(hue, saturation, value)
