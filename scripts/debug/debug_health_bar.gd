# scripts/ui/debug_health_bar.gd
extends Control
class_name DebugHealthBar

@onready var health_progress: ProgressBar = $ProgressBar
@onready var health_label: Label = $HealthLabel

var player_data: PlayerData

func _ready():
	# Reset the Control's anchors first
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	# Position in screen space (top-left corner)
	position = Vector2(50, 5)
	
	# Simple red health bar setup
	health_progress.custom_minimum_size = Vector2(120, 8)
	health_progress.show_percentage = false
	
	# Simple styling
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color.RED
	fill_style.set_content_margin_all(0)
	
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.3, 0.3, 0.3, 0.8)
	bg_style.set_content_margin_all(0)
	
	health_progress.add_theme_stylebox_override("fill", fill_style)
	health_progress.add_theme_stylebox_override("background", bg_style)
	
	# Label positioning
	health_label.position = Vector2(130, -2)
	health_label.add_theme_font_size_override("font_size", 12)
	health_label.add_theme_color_override("font_color", Color.WHITE)

func setup(data: PlayerData):
	player_data = data
	if health_progress:
		health_progress.max_value = player_data.max_health
		health_progress.value = player_data.health
	update_display()

func update_display():
	if not player_data or not health_progress or not health_label:
		return
		
	health_progress.value = player_data.health
	health_label.text = str(player_data.health) + "/" + str(player_data.max_health)

func _process(delta):
	if player_data:
		update_display()
