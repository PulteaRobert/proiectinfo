extends KinematicBody2D

export var ACCELERATION = 100
export var MAX_SPEED = 100
export var FRICTION = 1000
export var ROLL_SPEED = 75

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var roll_vector = Vector2.ZERO
var velocity = Vector2.DOWN
var stats = PlayerStats

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox

func _ready():
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)

#Starea de miscare, in aceasta stare player-ul primeste imput-uri si
#ruleaza animatiile in directia respectiva
func move_state(delta):
	var input_vector = Vector2.ZERO
	
	#JOYSTICK like input
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	#Daca apesi roll
	#roll - SHIFT
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	#Daca apesi attack
	#attack - SPACE
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

#Starea de roll, in aceasta stare player-ul primeste imput-uri, isi da roll si
#ruleaza animatiile in directia respectiva

# warning-ignore:unused_argument
func roll_state(_delta):
	velocity = roll_vector * ROLL_SPEED * 1.5
	animationState.travel("Roll")
	move()

#Starea de atac, in aceasta stare player-ul primeste imput-uri, isi da roll si
#ruleaza animatiile in directia respectiva

# warning-ignore:unused_argument
func attack_state(_delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")

#Functia ce updateaza Vector2 velocity - vectorul de miscare 

func move():
	velocity = move_and_slide(velocity)

#Cand se termina animatia de roll se muta la starea de miscare si 
#isi pierde 1/3 din viteza totala

func roll_animation_finished():
	velocity = velocity * 0.3
	state = MOVE

#Cand se termina animatia atac se muta la starea de miscare 

func attack_anim_finished():
	state = MOVE



func _on_Hurtbox_area_entered(area):
	if state != ROLL:
		stats.health -= 1
		hurtbox.start_invincibility(0.5)
		hurtbox.create_hit_effect(area)
