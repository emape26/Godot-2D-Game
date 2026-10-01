extends Node


const SAVE_PATH := "user://highscores.json"
const MAX_ENTRIES := 5 #koliko se scoreova prikazuje

var scores : Array = []
# [{"name": String, "score": int}]

func _ready() -> void:
	load_scores()

func load_scores() -> void:
	scores.clear()
	#ocistim scores varijablu, u nju se svaki put ucitavaju novi podaci
	#ne brisem file 
	if not FileAccess.file_exists(SAVE_PATH):
		return #ako file nepostoji vrati se
		
	var f := FileAccess.open(SAVE_PATH,FileAccess.READ)
	#otvara datoteku za citanje
	var txt := f.get_as_text()
	var data = JSON.parse_string(txt)
	#pretvara JSON text u array
	
	if typeof(data) == TYPE_ARRAY:#provjerava jeli stvarno array
		scores = data
		_normalize()

func save_scores() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	f.store_string(JSON.stringify(scores))#pretvori listu u JSON tekst
	
func _normalize() -> void:
	var cleaned : Array = []
	for e in scores:
		if typeof(e) != TYPE_DICTIONARY:
			continue
		if not e.has("name") or not e.has("score"):
			continue
		cleaned.append({"name":  str(e["name"]), "score": int(e["score"])})
		
	scores = cleaned
	scores.sort_custom(func(a, b): return int(a["score"]) > int(b["score"]))
	
	if scores.size() > MAX_ENTRIES:
		scores = scores.slice(0, MAX_ENTRIES)
	
func is_high_score(new_score: int) -> bool:
	if scores.size() < MAX_ENTRIES:
		return true
	return new_score > int(scores[scores.size() - 1]["score"])

func add_score(player_name: String, new_score: int) -> void:
	for e in scores:
		if str(e["name"]) == player_name:
			if int(new_score) > int(e["score"]):
				e["score"] = int(new_score)
			_normalize()
			save_scores()
			return

	# ako ne postoji, dodaj novi
	scores.append({"name": player_name, "score": int(new_score)})
	_normalize()
	save_scores()
