extends Area2D
class_name ItemPickup

var item_id: String
var amount: int

func _ready():
	body_entered.connect(_on_body_entered)

func setup(pickup_item_id: String, pickup_amount: int, pickup_position: Vector2):
	item_id = pickup_item_id
	amount = pickup_amount
	position = pickup_position

# might have to rewrite the debug messages used here
func _on_body_entered(body):
	DebugManager.log_debug("ItemPickup: Body entered - " + str(body.name))
	if body.is_in_group("player"):
		DebugManager.log_debug("ItemPickup: Player detected, attempting pickup of " + str(amount) + " " + item_id)
		if PlayerDataAutoload.add_item(item_id, amount):
			DebugManager.log_debug("ItemPickup: Successfully picked up " + str(amount) + " " + item_id)
			queue_free()
		else:
			DebugManager.log_debug("ItemPickup: Failed to pick up " + str(amount) + " " + item_id)
	else:
		DebugManager.log_debug("ItemPickup: Body is not in player group")
