extends CanvasLayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var node: Node2D = $Node

func change_scene(path):
	node.show()
	set_process_input(false)
	animation_player.play("change")
	await animation_player.animation_finished
	set_process_input(true)
	get_tree().change_scene_to_file(path)
	animation_player.play("change_back")
	await animation_player.animation_finished
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		$GPUParticles2D.position = event.position
		$GPUParticles2D.emitting = true
