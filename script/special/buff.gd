extends Node
class_name buff
var end_rund:int
var value
var type
var target
var buff_texture
var user_name
func use_buff(_type,_value,_duration,_target,_user=null):
	Manager.debuff_handel_list.append(self)
	end_rund=Manager.rund+_duration
	value = _value;type = _type;target = _target
	if _user:
		user_name =_user.name_
	buff_texture = target.debuff_show(type)
	match type:
		"weakness":
			if user_name== "紫色":
				target.damage_reduction-=_user.skill_.config["effect"]["passive_value"]["extra_damage"]
			target.weakness+=value
			target.gpu_particles_2d_2.emitting = true
			var sh_show = preload("res://screen/伤害显示.tscn").instantiate()
			target.add_child(sh_show)
			sh_show.value_init("伤害降低","purple")
		"ice":
			target.is_move =false
			target.ice.show()
		"chaos":
			target.is_move = false
			target.chaos_show()
		"suck_blood":
			target.suck_blood+=value
		"hide":
			target.modulate.a = 0.5
func remove_buff():
	if end_rund>Manager.rund:
		return
	Manager.debuff_handel_list.erase(self)
	if target ==null:
		self.queue_free()
		return
	match type:
		"bleed":
			target.heart(value)
	if end_rund <= Manager.rund:
		target.debuff_hide(buff_texture)
		match type:
			"weakness":
				if user_name == "紫色":
					target.damage_reduction+=0.2
				target.weakness-=value
			"ice":
				if judge_move():
					target.is_move =true
				target.ice.hide()
			"chaos":
				if judge_move():
					target.is_move =true
				target.chaos_hide()
			"suck_blood":
				target.suck_blood-=value
			"hide":
				target.modulate.a = 1
				target.up_show("结束隐匿","white")
	self.queue_free()

func judge_move():
	for i in Manager.debuff_handel_list:
		if i.type =="ice" or  i.type == "chaos":
			if i.end_rund>end_rund:
				return false
	return true
