extends CharacterBody2D

const SPEED := 200.0
const JUMP_VELOCITY := -350.0
const GRAVITY := 980.0

var gravity_multiplier := 1.0
var anim_state := "idle"

@onready var sprite: ColorRect = $Sprite

func _physics_process(delta: float) -> void:
	var grav := GRAVITY * gravity_multiplier

	if not is_on_floor():
		velocity.y += grav * delta

	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY * sign(gravity_multiplier)

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	_update_anim_state()

func _update_anim_state() -> void:
	if not is_on_floor():
		if velocity.y < 0:
			anim_state = "jump"
		else:
			anim_state = "fall"
	elif abs(velocity.x) > 10:
		anim_state = "run"
	else:
		anim_state = "idle"

func invert_gravity() -> void:
	gravity_multiplier = -1.0
	sprite.position.y = 0

func restore_gravity() -> void:
	gravity_multiplier = 1.0
	sprite.position.y = -48
