extends Node2D

var time_alive: float = 0.0
var current_score: int = 0

@export var points_per_kill: int = 10
@export var points_per_wave: int = 50
@export var points_per_second: int = 1

#kada je scena spremna stvara se varijabla 
@onready var pause_meni = %PauseMeni
@onready var label_wave = %WaveLable

func _ready() -> void:
	pause_meni.visible = false
	label_wave.visible = false
	
	update_wave_label()
	
	#TIMER-WAVEMANAGER--------------------------------------
	$WaveManager.set_timer($Timer)
	#$wavemanager uzimamo nodu wavemanager i onda pozivamo funkciju bind timer
	#kojoj saljemo $Timer, postavimo brojac  
	$WaveManager.spawn_requested.connect(spawn_mob)
	#kad wavemanager emitira signal,pozovi funk spawn_mob
	#ove dvi su za pocetak scene 
	%WaveManager.start_wave()
	$Timer.start() #nakon nekog vrimena emitira timeout
	
	%WaveManager.wave_completed.connect(_on_wave_completed)
	
	#UPGRADE-PANEL---------------------------------------
	%UpgradePanel.upgrade_chosen.connect(_on_upgrade_chosen)

#SCORE
#------------------------------------------------
func _process(delta: float) -> void:
	if get_tree().paused:
		return

	time_alive += delta
	_update_score()

func _update_score() -> void:
	var kills: int = %WaveManager.total_killed
	var wave_bonus: int = (%WaveManager.wave - 1) * points_per_wave
	var time_points: int = int(time_alive) * points_per_second
	current_score = time_points + kills * points_per_kill + wave_bonus
	%ScoreLabel.text = "%d" % current_score
	
	
#funk WAVE LABEL
func update_wave_label():
	label_wave.add_theme_constant_override("outline_size", 2)
	label_wave.text = "WAVE %d" % %WaveManager.wave
	label_wave.visible = true
	await get_tree().create_timer(1.2).timeout
	label_wave.visible = false

#UPGRADE PANEL
#---------------------------------------------------------
func _on_upgrade_chosen(upgrade_id: String) -> void:
	apply_upgrade(upgrade_id)
	get_tree().paused = false
	continue_next_wave()

func apply_upgrade(id: String) -> void:
	match id:
		"hp_up":#PLUS HEALTH
			%Player.health += 20
			%Player.max_health += 20
			%Player.get_node("ProgressBar").value = %Player.health
		"speed_up":
			%Player.speed += 30
		"fire_rate":
			var gun = $Player.get_node("Gun")
			var t: Timer = gun.get_node("Timer")
			t.wait_time =  0.5#(max(0.1,t.wait_time -0.1))
		#"extra_gun":
		#	%Player.guns += 1

#za WAVEMANAGER 
#-----WAVE-COMPLETED-----
#--------------------------------------------------
func _on_wave_completed():
	var opened = %UpgradePanel.open_panel()
	if opened:
		get_tree().paused = true
	else:
		# nema više upgradeova -> odmah nastavi
		continue_next_wave()
	
	
func continue_next_wave():
	%UpgradePanel.visible = false
	get_tree().paused = false
	
	%WaveManager.wave += 1
	%WaveManager.start_wave()
	update_wave_label()
	$Timer.start()


#STVARANJE ENEMYA-MULTI
#--------------------------------------------------
func spawn_mob(enemy_scene : PackedScene):
	var new_mob = enemy_scene.instantiate()
	
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)
	
	var mult = %WaveManager.get_enemy_multipliers()
	new_mob.apply_multipliers(mult["hp"],mult["speed"])
	#na novi mob spojimo signal died i kada se on emita pokrene se funk enemy_killed
	new_mob.died.connect(%WaveManager.enemy_killed)
	


#funkcija pokazuje GAME OVER meni
#----------------------------------------------------
func _on_player_health_down() -> void:

	%GameOver.open(current_score)
	get_tree().paused = true


#PAUSE MENI
#-----------------------------------------------------
func pauseGame():
	var paused = not get_tree().paused
	get_tree().paused = paused
	pause_meni.visible = paused

func _on_pause_button_pressed() -> void:
	pauseGame()

#botuni u pause meniju
func _on_back_to_the_game_pressed() -> void:
	pauseGame()

func _on_return_to_meni_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/meni.tscn")
	
func _on_timer_timeout() -> void:
	pass
