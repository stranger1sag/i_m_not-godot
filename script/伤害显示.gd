extends RichTextLabel

func value_init(value,color) -> void:
	text = "[color="+color+"]"+str(value)+"[/color]"
	position = Vector2(-50,-150)
	await _show()
	#get_tree().create_tween().tween_property(self,"scale",Vector2(1.2,1.2),1)
func _show():
	await get_tree().create_tween().tween_property(self,"position",Vector2(-50,-200),1).finished
	queue_free()
