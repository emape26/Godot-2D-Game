extends Area2D

@export var speed: float = 1000.0
var travelled_distance = 0
const RANGE = 1200

func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta
	
	travelled_distance += speed * delta
	if travelled_distance > RANGE:
		queue_free()


func _on_body_entered(body: Node2D):
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage()
	
