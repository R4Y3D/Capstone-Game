extends CharacterBody3D

@export var move_speed: float = 3.0
@export var gravity: float = 50.0  # Custom gravity value

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $Knight/AnimationPlayer  # Adjust path to match your scene hierarchy
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

	# Add the knight to the 'knight' group
	add_to_group("knight")
	print("Knight added to 'knight' group.")

func _physics_process(delta: float):
	if not leader:
		# Play idle animation if no leader
		if animation_player:
			animation_player.play("Running_A")
		return

	# Apply gravity to the vertical velocity
	velocity.y -= gravity * delta  # Accelerate downward due to gravity

	var follow_target = leader.get_node("FollowPlayer")
	if not follow_target:
		print("FollowTarget node is missing!")
		if animation_player:
			animation_player.play("Running_A")
		return
	
	var target_position = follow_target.global_transform.origin
	navigation_agent.set_target_position(target_position)
	
	var next_position = navigation_agent.get_next_path_position()
	var current_position = global_transform.origin
	
	var direction = (next_position - current_position).normalized()
	
	# Set the horizontal velocity for movement
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	# Move the knight
	move_and_slide()

	# Check if the player is moving or not
	if velocity.length() > 0:  # Player is moving
		if animation_player and animation_player.current_animation != "Running_B":
			animation_player.play("Running_B")
	else:  # Player is idle
		if animation_player and animation_player.current_animation != "Running_A":
			animation_player.play("Running_A")
