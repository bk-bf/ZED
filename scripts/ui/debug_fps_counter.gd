extends Control
class_name DebugFPSCounter

@onready var fps_label = $HBoxContainer/FPSLabel
@onready var value_label = $HBoxContainer/ValueLabel

var fps_update_timer: float = 0.0
var fps_update_interval: float = 0.1 # Update every 0.1 seconds for more responsive display
var fps_samples: Array[float] = []
var max_samples: int = 10

func _ready():
    # Set up the labels
    fps_label.text = "FPS: "
    value_label.text = "--"
    
    # Position in top-right corner
    set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
    position.x -= 130 # Offset from right edge
    position.y += 30 # Offset from top edge
    
    # Set z_index to ensure it's on top
    z_index = 100
    
    # Initialize display
    update_fps_display(0.0)

func _process(delta):
    update_fps_display(delta)

func update_fps_display(delta: float):
    fps_update_timer += delta
    if fps_update_timer >= fps_update_interval:
        # Try both methods to see which gives uncapped results
        var delta_fps = 1.0 / delta if delta > 0 else 0
        var engine_fps = Engine.get_frames_per_second()
        
        # Use the higher value (Engine method might be uncapped in newer Godot versions)
        var current_fps = max(delta_fps, engine_fps)
        
        # Keep a rolling average for smoother display
        fps_samples.append(current_fps)
        if fps_samples.size() > max_samples:
            fps_samples.pop_front()
        
        # Calculate average FPS
        var avg_fps = 0.0
        for sample in fps_samples:
            avg_fps += sample
        avg_fps /= fps_samples.size()
        
        var fps_color = _get_fps_color(int(avg_fps))
        
        # Show both values for debugging
        value_label.text = str(int(avg_fps)) + " (" + str(int(delta_fps)) + ")"
        value_label.add_theme_color_override("font_color", fps_color)
        
        fps_update_timer = 0.0

func _get_fps_color(fps: int) -> Color:
    """Get color based on FPS performance"""
    if fps >= 120:
        return Color.CYAN
    elif fps >= 60:
        return Color.GREEN
    elif fps >= 30:
        return Color.YELLOW
    elif fps >= 20:
        return Color.ORANGE
    else:
        return Color.RED

func set_visible_state(visible_state: bool):
    visible = visible_state
