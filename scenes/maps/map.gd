extends Node3D

@onready var level = $"../"
var speed: float = 5.0

func _process(delta):
	position.x -= speed * delta
	if position.x < -15:
		# Use the method to get the next module's offset
		var next_offset = level.get_next_module_offset()
		level.spawnModule(position.x + (level.amnt * next_offset))
		queue_free()

# Method to update speed dynamically
func update_speed(new_speed: float):
	speed = new_speed
