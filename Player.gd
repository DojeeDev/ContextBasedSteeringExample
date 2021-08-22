extends KinematicBody2D

export var maxSpeed = 100
export var steerForce = 0.1
export var lookAhead = 100
export var numRays = 8

#Context array
var rayDir = []
var interest = []
var danger = []

var chosenDir = Vector2.ZERO
var vel = Vector2.ZERO
var accel = Vector2.ZERO

func _ready():
	pause_mode = PAUSE_MODE_STOP
	
	interest.resize(numRays)
	danger.resize(numRays)
	rayDir.resize(numRays)
	for i in numRays:
		var angle = i * 2 * PI / numRays
		rayDir[i] = Vector2.RIGHT.rotated(angle)
		
func _physics_process(delta):

	#Populate context arrays
	_set_interest()
	_set_danger()
	_choose_dir()
	var desiredVel = chosenDir * maxSpeed
	vel = vel.linear_interpolate(desiredVel, steerForce)
	move_and_collide(vel * delta)

func _set_interest():
	for r in numRays:
		var d = rayDir[r].dot(position.direction_to(get_global_mouse_position())) #decides how 
#		strongly to move in this dir based on how well it aligns with the wanted dir
		interest[r] = max(0, d)
	
func _set_danger():
	var spaceState = get_world_2d().direct_space_state
	for r in numRays:
		var from = global_position
		var to = rayDir[r] * lookAhead # in local space
		
		var result = spaceState.intersect_ray(from,
			to_global(to),
			[self])
		
		if result:
			DebugDraw.add_vector(from, to_global(to), 1, Color.red)
		else:
			DebugDraw.add_vector(from, to_global(to), 1, Color.green)
		
		danger[r] = 1.0 if result else 0.0
	DebugDraw.update()
	

func _choose_dir():
	#Eliminate interests in slot of danger
	for r in numRays:
		if danger[r] > 0.0:
			interest[r] = -1 # so you can do this 2 ways, you can make it go in the other dir 
#			or even go the other dir at half speed, set it to -0.5 or you can set it to 0, but that wasn't really doing it for me?
#			idk you'll have to tweak it a bit, basically it's how hard it tries to avoid it
	#Choose direction based on remaining interest
	chosenDir = Vector2.ZERO
	for r in numRays:
		chosenDir += rayDir[r] * interest[r]
	chosenDir = chosenDir.normalized()
