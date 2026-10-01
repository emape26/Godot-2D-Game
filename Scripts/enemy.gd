extends CharacterBody2D

#SIGNALI CUSTOM
signal died

const ACID_CIRCLE = preload("res://Scenes/circle_acid.tscn")

@export var health: int = 3
@export var speed: float = 120.0

var start_speed: float
var start_health: int

#var za animaciju
@onready var player = get_node("/root/game/Player")
@onready var anim = $AnimatedSprite2D


func _ready() -> void:
	start_speed = speed
	start_health = health

func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()
	animation(direction)

#WAVE_STATS
#------------------------------------------------------------
func apply_multipliers(hp_mult:float,speed_mult:float):
	health  = int(round(start_health*hp_mult))
	speed = start_speed * speed_mult


#ANIMACIJA
#---------------------------------------------------------
func animation(dir):
	if abs(dir.x) > abs(dir.y):
		if dir.x >= 0:
			anim.flip_h = false
			anim.animation = "run_right"
		else:
			anim.flip_h = true
			anim.animation = "run_right"
	anim.play()


#TAKE DAMAGE- ako bullet pogodi nekoga trazi da ima ovu funkciju da se oduzme damage
#--------------------------------------------------------------
func take_damage():
	health -= 1
	
	if health <= 0:
		var h = ACID_CIRCLE.instantiate()
		h.global_position = global_position
		get_tree().current_scene.add_child(h)
		
		emit_signal("died")
		queue_free()
