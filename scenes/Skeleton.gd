extends CharacterBody3D
@export var move_speed: float = 3.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $Skeleton_Minion/AnimationPlayer
@onready var area: Area3D = $Area3D

var leader: Node3D = null
var spawner_node: Node = null  # We'll store a reference to the spawner node here

func _ready():
	# Automatically find the player
	leader = get_tree().get_first_node_in_group("player")

	# Get spawner node from the "spawner" group
	spawner_node = get_tree().get_first_node_in_group("spawner")

	if not leader:
		print("No player found in the scene!")
		return
	if not animation_player:
		print("AnimationPlayer not found!")
		return

	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5
	print("Skeleton is ready and following the leader:", leader.name)

	add_to_group("enemy")

	if area:
		area.connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta: float):
	if not leader:
		if animation_player and animation_player.current_animation != "Walking_B":
			animation_player.play("Walking_B")
		return

	var follow_target = leader.get_node("FollowPlayer")
	if not follow_target:
		print("FollowPlayer node is missing!")
		if animation_player and animation_player.current_animation != "Walking_B":
			animation_player.play("Walking_B")
		return

	var target_position = follow_target.global_transform.origin
	navigation_agent.set_target_position(target_position)

	var next_position = navigation_agent.get_next_path_position()
	var current_position = global_transform.origin
	var direction = (next_position - current_position).normalized()

	# Face the direction of movement
	var look_at_position = Vector3(next_position.x, global_transform.origin.y, next_position.z)
	look_at(look_at_position, Vector3.UP)
	rotation_degrees.y += 180  # Adjust to face forward

	velocity = direction * move_speed
	move_and_slide()

	# Play animations based on movement
	if velocity.length() > 0:
		if animation_player and animation_player.current_animation != "Walking_A":
			animation_player.play("Walking_A")
	else:
		if animation_player and animation_player.current_animation != "Walking_B":
			animation_player.play("Walking_B")

func _on_body_entered(body):
	if body.is_in_group("knight"):
		print("Knight and Skeleton killed on contact")
		body.queue_free() # Removes the Knight

		# Decrement the knight count in the spawner script
		if spawner_node:
			spawner_node.current_knight_count -= 1
			# Also call _check_game_over if it's accessible and needed
			if "_check_game_over" in spawner_node:
				spawner_node._check_game_over()

		queue_free() # Removes the Skeleton
