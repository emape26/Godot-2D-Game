extends Area2D

@export var dps:float = 10.0
@export var duration : float = 3.0
@export var warmup : float = 0.3

var player_inside := false
var active := false

func _ready() -> void:
	active = false
	await get_tree().create_timer(warmup).timeout
	active = true
	
	await get_tree().create_timer(duration).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	if not active:
		return
	if not player_inside:
		return
	
	var p = get_node_or_null("/root/game/Player")
	if p and p.has_method("take_hit"):
		p.take_hit(dps*delta)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_inside = true


func _on_body_exited(body: Node2D) -> void:
	if body.name =="Player":
		player_inside = false
