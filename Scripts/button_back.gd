extends Button


func _ready():
	pass

func button_pressed_back():
	get_tree().change_scene_to_file("res://Scenes/meni.tscn")
