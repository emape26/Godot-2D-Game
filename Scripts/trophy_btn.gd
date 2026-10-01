extends TextureButton

@export var popup_path: NodePath
@onready var popup: Control = get_node(popup_path)

func _ready() -> void:
	pass



func _pressed() -> void:
	if popup.visible:
		if popup.has_method("close"):
			popup.call("close")
		else:
			popup.visible = false
	else:
		if popup.has_method("open"):
			popup.call("open")
		else:
			popup.visible = true
