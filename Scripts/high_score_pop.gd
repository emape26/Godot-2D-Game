extends Control

@onready var score_list: VBoxContainer = $ScorePanel/ScoreList

func open() -> void:
	HighScore.load_scores()
	visible = true
	_refresh()

func close() -> void:
	visible = false

func _refresh() -> void:
	for c in score_list.get_children():
		c.queue_free()

	for i in range(HighScore.MAX_ENTRIES): # 5
		var line := Label.new()
		line.add_theme_color_override("font_color", Color("#372361"))
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		line.add_theme_font_size_override("font_size", 24)

		if i < HighScore.scores.size():
			var e = HighScore.scores[i]
			line.text = "%d. %s - %d" % [i + 1, str(e["name"]), int(e["score"])]
		else:
			line.text = "%d. ---" % [i + 1]

		score_list.add_child(line)
