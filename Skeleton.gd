extends CharacterBody3D

@export var move_speed: float = 3.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $Skeleton_Minion/AnimationPlayer  # Update path if needed
var leader: Node3D = null

func _ready():
	# Automatically find the player in the scene
	leader = get_tree().get_first_node_in_group("player")
	
	if not leader:
		print("No player found in the scene!")
		return

	# Verify the AnimationPlayer is found
	if not animation_player:
		print("AnimationPlayer not found!")
		return

	# Navigation setup
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

	print("Skeleton is ready and following the leader:", leader.name)

func _physics_process(delta: float):
	if not leader:
		# Play Walking_B animation if no leader (idle state)
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
	
	# Make the skeleton face the sphere (leader) correctly
	var look_at_position = Vector3(next_position.x, global_transform.origin.y, next_position.z)  # Keep Y unchanged
	look_at(look_at_position, Vector3.UP)  # Rotate to face the direction of movement
	
	# Adjust the rotation to fix the skeleton facing backward
	rotation_degrees.y += 180  # Rotate the skeleton by 180 degrees on the Y-axis to face forward
	
	# Set the velocity as a vector
	velocity = direction * move_speed
	
	# Use move_and_slide with velocity
	move_and_slide()

	# Check if the skeleton is moving or idle
	if velocity.length() > 0:  # Skeleton is moving
		if animation_player and animation_player.current_animation != "Walking_A":
			animation_player.play("Walking_A")
	else:  # Skeleton is idle
		if animation_player and animation_player.current_animation != "Walking_B":
			animation_player.play("Walking_B")
