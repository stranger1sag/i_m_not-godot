extends CanvasLayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("move")
	label.text = Manager.label_str
@onready var label: Label = $Panel/TextureRect/Label



func _on_button_2_pressed() -> void:
	ChangeScene.change_scene("res://screen/select.tscn")

func button_pressed() -> void:
	get_tree().quit(0)
