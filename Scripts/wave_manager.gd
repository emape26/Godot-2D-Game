extends Node2D
 
#SIGNALI
signal spawn_requested(enemy_scene: PackedScene)
signal wave_completed

const ENEMY_BASIC:PackedScene = preload("res://Scenes/enemy.tscn")
const ENEMY_FAST:PackedScene = preload("res://Scenes/enemy_fast.tscn")


@onready var spawn_timer : Timer = null

#varijable za wave
var wave := 1
var mobs_allowed := 5
var spawned_in_wave := 0
var killed_in_wave := 0

var total_killed : int = 0

var spawn_plan: Array[PackedScene] = []
var spawn_index: int = 0


#postavlja sve vrjednosti 
#-----------------------------------------------------
func start_wave():
	spawned_in_wave = 0
	killed_in_wave = 0
	mobs_allowed = 5 + (wave -1)*4 #funkcija za rast 
	_build_spawn_plan()

func _build_spawn_plan() -> void:
	spawn_plan.clear()
	spawn_index = 0

	# U wave 1 nema fast
	if wave < 1:
		for i in range(mobs_allowed):
			spawn_plan.append(ENEMY_BASIC)
		return

	
	var fast_ratio := 0.40
	var fast_count := int(round(mobs_allowed * fast_ratio))

	
	fast_count = clamp(fast_count, 1, mobs_allowed)

	# napuni plan
	for i in range(fast_count):
		spawn_plan.append(ENEMY_FAST)
	for i in range(mobs_allowed - fast_count):
		spawn_plan.append(ENEMY_BASIC)

	
	spawn_plan.shuffle()
#funkcije za TIMER
#---------------------------------------------------------
func set_timer(t: Timer):
	spawn_timer = t #u ovo mije spremljena noda Timer koja je u gameu
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	#nakon wait time timer poziva svaku funkicju koja je spojena na timer

func _on_spawn_timer_timeout():
	if spawned_in_wave >= mobs_allowed:
		spawn_timer.stop()
		return

	spawned_in_wave += 1

	var scene_to_spawn := spawn_plan[spawn_index]
	spawn_index += 1
	emit_signal("spawn_requested", scene_to_spawn)

#IZABERI ENEMYA
#------------------------------------------------
func pick_enemy_scene() -> PackedScene:
	if wave < 1:
		return ENEMY_BASIC
	
	var fast_chance := 0.10 + 0.05 * (wave - 2)  
	fast_chance = clamp(fast_chance, 0.10, 0.70) # max 70%

	if randf() < fast_chance:
		return ENEMY_FAST
	return ENEMY_BASIC

#ENEMY KILLED
#----------------------------------------------------------------
func enemy_killed(): 
	killed_in_wave +=1
	total_killed +=1
	if killed_in_wave >= mobs_allowed:
		emit_signal("wave_completed")

#ENEMY MULTIPLIERS MANAGER
#------------------------------------------------------
func get_enemy_multipliers():
	return{
		"hp" : 1.0 +0.15 * (wave -1),
		"speed": 1.0 + 0.05 * (wave - 1)
	}

#------------------------------
func reset_run():
	wave = 1
	total_killed = 0
	start_wave()
