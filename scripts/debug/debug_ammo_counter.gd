extends Control
class_name DebugAmmoCounter

@onready var current_ammo_label = $HBoxContainer/CurrentAmmoLabel
@onready var separator_label = $HBoxContainer/SeparatorLabel
@onready var max_ammo_label = $HBoxContainer/MaxAmmoLabel

func _ready():
	# Set up the separator
	separator_label.text = " / "
	
	# Position in top-right corner
	set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	position.x -= 100 # Offset from right edge
	position.y += 10 # Offset from top edge
	
	# Initialize display
	update_ammo_display()

	#  Connect to PlayerData signal
	PlayerDataAutoload.ammo_changed.connect(_on_ammo_changed)
	update_ammo_display()

func setup(player_data_ref: PlayerData):
	# Connect to PlayerData ammo changes if you have signals
	# For now, we'll update manually
	update_ammo_display()

func _on_ammo_changed(current: int, max: int):
	current_ammo_label.text = str(current)
	max_ammo_label.text = str(max)

func update_ammo_display():
	if PlayerDataAutoload:
		# Get ammo properties from ItemData
		var pistol_ammo_data = ItemData.get_item_by_id("placeholder_pistol_ammo")
		if pistol_ammo_data:
			current_ammo_label.text = str(PlayerDataAutoload.current_ammo)
			max_ammo_label.text = str(pistol_ammo_data.stack_size)
		else:
			# Fallback
			current_ammo_label.text = str(PlayerDataAutoload.current_ammo)
			max_ammo_label.text = str(PlayerDataAutoload.max_ammo)

# Call this when ammo changes
func refresh_display():
	update_ammo_display()
