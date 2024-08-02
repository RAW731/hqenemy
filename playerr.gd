extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 8
const max_jump = 2

func jump(): 
	if Input.is_action_just_pressed("jump"): 
		if current_jump < max_jump: 
			velocity.y = JUMP_VELOCITY
			current_jump = current_jump + 1
	else: 
		velocity.y -= gravity



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var lookat
var current_jump = 1
var lastLookAtDirection : Vector3
var state_machine 
@onready var animtree : AnimationTree = $AnimationTree


func _ready():
	lookat = get_tree().get_nodes_in_group("CameraController")[0].get_node("LookAt")
	animtree.active = true
	

func _physics_process(delta):
	state_machine = $AnimationTree.get("parameters/playback") 
	
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor(): 
		velocity.y += JUMP_VELOCITY
		
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		var lerpDirection = lerp(lastLookAtDirection, Vector3(lookat.global_position.x, global_position.y, lookat.global_position.z), .05)
		look_at(Vector3(lerpDirection.x, global_position.y, lerpDirection.z))
		lastLookAtDirection = lerpDirection
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	
	
	update_animation_parameters()
	
	
	move_and_slide()


func update_animation_parameters(): 
	if (velocity == Vector3.ZERO): 
		state_machine.travel("idle")
	else: 
		state_machine.travel("walk")
	if (Input.is_action_just_pressed("Attackk")): 
		animtree[" parameter/conditions/attack"] = true
	else: 
		animtree["parameters/condition/attack"] = false
	





func _on_area_3d_body_entered(body):
	if body.is_in_group("water"): 
		velocity.y += gravity
