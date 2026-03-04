extends Node
class_name Skill
var config : Dictionary

func init(_config:Dictionary):
	config = _config
func special_skill(target,user):
	match config["special_skill"]:
		"three_colors":
			await three_colors(user)
		"ice_animation_play":
			await ice_animation_play(target,user)
		"hide_purple":
			await hide_purple(target,user)
func three_colors(user:player):
	var rad = TAU/user.ball_color.size()
	var list =[]
	for i in range(user.ball_color.size()):
		var circle = preload("res://screen/circle.tscn").instantiate()
		circle.position+=Vector2(200,0).rotated(rad*i)
		circle.modulate = Color(user.ball_color[i])
		circle.scale = Vector2(5,5)
		circle.add_to_group("circle")
		randomize()
		user.add_child(circle)
		circle.is_stop = true
		match user.ball_color[i]:
			"red":
				circle.init(Manager.enemy_list.pick_random(),3000)
			"green":
				var min_hp = INF
				var target_=Manager.player_list[0]
				for _target in Manager.player_list:
					if _target.current_hp<min_hp and _target.current_hp!=_target.max_hp:
						target_ = _target
						min_hp = _target.current_hp
				circle.init(target_,300)
			"blue":
				circle.init(Manager.enemy_list.pick_random(),3000)
		list.append(circle)
	await user.get_tree().create_timer(0.3).timeout
	var dic_color={}
	for circle in list:
		circle.is_stop = false
		dic_color[circle.modulate] = circle.target
	await user.get_tree().create_timer(0.2).timeout
	for key in dic_color.keys():
		match key:
			Color(1,0,0,1):
				dic_color[key].heart(config["effect"]["value"]["red"]*user.attack)
			Color(0,1,0,1):
				dic_color[key].heal(config["effect"]["value"]["green"]*user.attack)
			Color(0,0,1,1):
				dic_color[key].heart(config["effect"]["value"]["blue"]*user.attack)
				randomize()
				if user.judge_debuff(config["effect"]["value"]["random"]):
					dic_color[key]._use_buff(config["basis"]["debuff"],0,config["duration"])
		await user.get_tree().create_timer(0.1).timeout
func ice_animation_play(target,user):
	var circle = preload("res://screen/circle.tscn").instantiate()
	circle.init(target[0])
	circle.modulate = Color(0,0,1)
	circle.scale = Vector2(5,5)
	user.add_child(circle)
	user.animation_player.play(config["name"])
	await user.get_tree().create_timer(0.5).timeout
	target[0].heart(config["effect"]["value"]["attack"]*user.attack)
	randomize()
	if user.judge_debuff(config["effect"]["value"]["random"]):
		if config["basis"]["debuff"] in config["effect"]["value"].keys():
			target[0]._use_buff(config["basis"]["debuff"],config["effect"]["value"][config["basis"]["debuff"]],config["duration"])
		else:
			target[0]._use_buff(config["basis"]["debuff"],0,config["duration"])
	await user.animation_player.animation_finished
func hide_purple(target,user):
	var animation_count = 0
	user.animation_player.play(config["name"])
	animation_count+=1
	var circle = preload("res://screen/circle.tscn").instantiate()
	circle.init(target[0])
	circle.modulate = Color("purple")
	circle.scale = Vector2(5,5)
	user.add_child(circle)
	await user.get_tree().create_timer(0.5).timeout
	#target[0].heart(config["effect"]["value"]["attack"]*user.attack)
	if Manager.player_list.size()!=1:
		user._use_buff("hide",0,1)
		user.up_show("开始隐匿","white")
	await user.animation_player.animation_finished
	await apply_skill(target,user,animation_count)
func apply_skill(_target:Array,user:player,count=0):
	var animation_count = count
	var target = []
	for i in _target:
		target.append(i)
	if "near_damage" in config["effect"]["type"]:
		var original_position=Vector2.ZERO
		if user.animation_player.has_animation(config["name"]) and animation_count==0:
			if config["effect"]["target"] == "enemy_all":
				original_position = user.global_position
				await user.get_tree().create_tween().tween_property(user,"position",Vector2(333,610),0.75).finished
				user.animation_player.play(config["name"])
				await user.animation_player.animation_finished
			else:
				original_position = user.global_position
				await user.get_tree().create_tween().tween_property(user,"position",target[0].global_position-Vector2(100,0),0.75).finished
				user.animation_player.play(config["name"])
				await user.animation_player.animation_finished
			animation_count+=1
		for target_number in target:
			if target_number==null:
				continue
			if config["basis"]["near_damage"] == "attack":
				target_number.heart(user.attack*config["effect"]["value"]["attack"]*user.multiplier_power)
				user.skill_suck_blood(user.attack*config["effect"]["value"]["attack"]*user.multiplier_power)
			else:
				target_number.heart(config["effect"]["value"])
				user.skill_suck_blood(config["effect"]["value"])
		if original_position!=Vector2.ZERO:
			await user.get_tree().create_tween().tween_property(user,"position",original_position,0.5).finished
	if "far_damage" in config["effect"]["type"]:
		if user.animation_player.has_animation(config["name"]) and animation_count==0:
			user.animation_player.play(config["name"])
			await user.animation_player.animation_finished
			animation_count+=1
		for target_number in target:
			if config["basis"]["far_damage"] =="attack":
				target_number.heart(user.attack*config["effect"]["value"]["attack"]*user.multiplier_power)
				user.skill_suck_blood(user.attack*config["effect"]["value"]["attack"]*user.multiplier_power)
			else:
				target_number.heart(config["effect"]["value"])
				user.skill_suck_blood(config["effect"]["value"])
	if "debuff" in config["effect"]["type"]:
		if user.animation_player.has_animation(config["name"]) and animation_count==0:
			user.animation_player.play(config["name"])
			await user.animation_player.animation_finished
			animation_count+=1
		for target_number in target:
			if target_number==null:
				continue
			randomize()
			if user.judge_debuff(config["effect"]["value"]["random"]):
				if config["basis"]["debuff"]=="bleed":
					target_number._use_buff(config["basis"]["debuff"],0.2*user.attack*user.multiplier_power,config["duration"],user)
				else:
					if config["basis"]["debuff"] in config["effect"]["value"].keys():
						target_number._use_buff(config["basis"]["debuff"],config["effect"]["value"][config["basis"]["debuff"]],config["duration"],user)
					else:
						target_number._use_buff(config["basis"]["debuff"],0,config["duration"],user)
			else:
				target_number.unable()
			#await user.get_tree().create_timer(1.3).timeout
	if "buff" in config["effect"]["type"]:
		if user.animation_player.has_animation(config["name"]) and animation_count==0:
				user.animation_player.play(config["name"])
				await user.animation_player.animation_finished
				animation_count+=1
		for target_number in target:
			if target_number==null:
				continue
			target_number._use_buff(config["basis"]["buff"],config["effect"]["value"][config["basis"]["buff"]],config["duration"])
	if "heal" in config["effect"]["type"]:
		if user.animation_player.has_animation(config["name"]) and animation_count==0:
			user.animation_player.play(config["name"])
			await user.animation_player.animation_finished
			animation_count+=1
		for target_number in target:
			if config["basis"]["heal"] == "hp":
				if user.name_ =="绿色":
					target_number.heal(user.max_hp*(config["effect"]["value"]["hp"]+(Manager.max_count-Manager.player_list.size())*config["effect"]["passive_value"]["hp"]))
				else:
					target_number.heal(user.max_hp*config["effect"]["value"]["hp"])
			elif config["basis"]["heal"] == "attack":
				target_number.heal(user.attack*config["effect"]["value"]["attack"])
			else:
				target_number.heal(config["effect"]["value"])
		await user.get_tree().create_timer(1.3).timeout
