extends CanvasLayer

@onready var score_list: VBoxContainer = %ScoreList
@onready var name_input: LineEdit = %NameInput
@onready var submit_btn: Button = %SubmitButton

var pending_score: int = 0

func open(final_score: int) -> void:
	visible = true
	pending_score = final_score

	_refresh_table()

	var qualifies := HighScore.is_high_score(final_score)
	name_input.visible = qualifies
	submit_btn.visible = qualifies

	if qualifies:
		name_input.text = ""
		name_input.grab_focus()

func _refresh_table() -> void:
	for c in score_list.get_children():
		c.queue_free()

	for i in range(HighScore.MAX_ENTRIES):
		var line := Label.new()
		line.add_theme_font_size_override("font_size", 26) # promijeni broj kako ti paše
		
		if i < HighScore.scores.size():
			var e = HighScore.scores[i]
			line.text = "%d. %s - %d" % [i + 1, e["name"], e["score"]]
		else:
			line.text = "%d. ---" % [i + 1]
		score_list.add_child(line)


func _on_submit_button_pressed() -> void:
	var player_name := name_input.text.strip_edges()
	if player_name.is_empty():
		player_name = "Player"
	if player_name.length() > 12:
		player_name = player_name.substr(0, 12)
	HighScore.add_score(player_name, pending_score)
	
	_refresh_table()
	name_input.visible = false
	submit_btn.visible = false
