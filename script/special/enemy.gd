extends Node2D
class_name enemy

#最大生命
var max_hp:int=100
#当前生命
var current_hp:int=100:
	set(v):
		current_hp = clamp(v,0,max_hp)
#攻击力
var attack:int=100
#虚弱
var weakness:float = 0
#是否攻击
var is_move = true
var damage_reduction = 0
func finish_damage():
	return attack*(1-weakness)
