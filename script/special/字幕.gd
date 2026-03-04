extends Label

func init_label(str_):
	set_anchors_preset(Control.PRESET_FULL_RECT)
	text = str(str_)
	$AnimationPlayer.play("up")
	await $AnimationPlayer.animation_finished
	queue_free()
