extends Sprite2D

var target
var speed:int
var is_stop =false
@onready var timer: Timer = $Timer
func init(_target,_speed:int = 2000) -> void:
	scale = Vector2(3,3)
	speed = _speed
	target = _target
func _process(delta: float) -> void:
	if is_stop:
		return
	if target == null:
		queue_free()
		return
	var direction = (target.global_position - global_position).normalized()
	if global_position.distance_to(target.global_position)<10:
		queue_free()
	position += direction*delta*speed

func _on_timer_timeout() -> void:
	queue_free()
