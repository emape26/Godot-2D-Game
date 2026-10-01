extends CharacterBody2D

#moj custom signal
signal health_down

# varijable za func movement
@export var speed := 250.0
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var max_health: float = 100.0

#varijable za func damage_and_health
var health : float = 100.0
var last_direction := Vector2.DOWN


func _ready():
	anim.animation = "idle_front"
	anim.play()


#ovo je MAIN
func _physics_process(delta: float) -> void:
	movement(delta)
	damage_and_health(delta)



#DAMAGE -smanjuje health playeru
#salje signal health down koji prima kode GAME 
#-----------------------------------------------------------
func damage_and_health(delta):
	const DAMAGE_RATE = 25.0
	
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	
	if overlapping_mobs.is_empty():
		return
	
	health -= DAMAGE_RATE * overlapping_mobs.size() * delta
	%ProgressBar.value = health
	
	if health <= 0.0:
		health_down.emit()

#PLAYER-DAMAGE-ACID
#-------------------------------------------------

func take_hit(dmg:float)->void:
	health -= dmg
	%ProgressBar.value = health
	if health <= 0.0:
		health_down.emit()


#funkcija ZA KRETANJE - pokriva kretanje i animacije
#--------------------------------------------------------------------
func movement(_delta):

	var dir := Input.get_vector("left","right","up","down")
	
	velocity = dir * speed
	move_and_slide()
	
	
	#kada stoji lik, nema inputa
	
	if dir == Vector2.ZERO:
		match last_direction:
			Vector2.RIGHT:
				anim.animation = "idle_right"
				anim.flip_h = false
			Vector2.LEFT:
				anim.animation = "idle_right"
				anim.flip_h = true
			Vector2.UP:
				anim.animation = "idle_back"
				anim.flip_h = false
			Vector2.DOWN:
				anim.animation = "idle_front"
				anim.flip_h = false
		anim.play()
		return
	
	#za pamcenje zadnjeg smjera
	if abs(dir.x) >= abs(dir.y):
		last_direction = Vector2.RIGHT if dir.x > 0 else Vector2.LEFT
	else:
		last_direction = Vector2.DOWN if dir.y > 0 else Vector2.UP
	# ANIMACIJE
	
	if abs(dir.x)> 0.0:
		anim.animation = "run_right"
		anim.flip_h = dir.x < 0
	else:
		anim.flip_h = false
		anim.animation = "run_front" if dir.y >0 else "run_back"
	
	anim.play()
