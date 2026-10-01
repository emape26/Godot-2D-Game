extends Control

class_name UpgradePanel
#custom signal koji se salje
signal upgrade_chosen(upgrade_id:String)

@onready var btn1: Button = $Option1
@onready var btn2: Button = $Option2

#array UPGRADEOVA
var upgrades = [
	{"id": "hp_up","name":"+20 HP"},
	{"id": "speed_up","name":"+20 Speed"},
	{"id": "fire_rate","name":"Faster shooting"},
	#{"id": "extra_gun","name":"+1 gun"}
]

var current_ids : Array[String] = []


func open_panel():
	if upgrades.size() == 0:
		visible = false
		return false

	visible = true
	_pick_two()
	return true

func _pick_two():
	if upgrades.size() == 0:
		visible = false
		return
	
	var dupplicate_array = upgrades.duplicate()
	dupplicate_array.shuffle()
	
	var u1
	
	if upgrades.size() == 1:
		u1 = dupplicate_array[0]
		current_ids = [u1["id"]]
		
		btn1.text = u1["name"]
		btn1.visible = true
		
		btn2.visible = false
		return
	
	u1 = dupplicate_array[0]
	var u2 = dupplicate_array[1]
	
	current_ids = [u1["id"], u2["id"]]
	
	btn1.text = u1["name"]
	btn2.text = u2["name"]
	
	btn1.visible = true
	btn2.visible = true


func _on_option_1_pressed() -> void:
	var chosen_id = current_ids[0]
	remove_upgrade(chosen_id)
	emit_signal("upgrade_chosen",current_ids[0])
	visible = false


func _on_option_2_pressed() -> void:
	if current_ids.size() < 2:
		return
	var chosen_id = current_ids[1]
	remove_upgrade(chosen_id)
	emit_signal("upgrade_chosen", current_ids[1])
	visible = false

#MICANJE DUPLIH
#--------------------------------------------------------------
func remove_upgrade(id:String):
	for i in range(upgrades.size()):
		if upgrades[i]["id"] == id:
			upgrades.remove_at(i)
			return
