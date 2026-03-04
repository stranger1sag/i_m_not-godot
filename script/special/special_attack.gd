extends Node
class_name special_attack_

func init_special_attack(target,special,user):
	match special:
		"three_colors_attack":
			await three_colors_attack(target,user)
		"lang_suck_blood_attack":
			await lang_suck_blood_attack(target,user)
func three_colors_attack(target,user:player):
	var color = ["red","blue"].pick_random()
	var min_hp = INF
	var target_
	for _target in Manager.player_list:
		if _target.current_hp<min_hp:
			target_ = _target
			min_hp = _target.current_hp
	if min_hp<=target_.max_hp*0.5:
		color = "green"
	match color:
		"red":
			user.ball_shot(color,target)
			user.audio.play()
			await user.get_tree().create_timer(0.5).timeout
			var _config = user.skill_config
			var damage = user.finish_damage()
			target.heart(damage[0]*user.skill_config["effect"]["passive_value"]["red"],damage[1])
		"green":
			user.ball_shot(color,target_)
			await user.get_tree().create_timer(0.5).timeout
			target_.heal(user.attack*user.skill_config["effect"]["passive_value"]["green"])
		"blue":
			user.ball_shot(color,target)
			user.audio.play()
			await user.get_tree().create_timer(0.5).timeout
			var damage = user.finish_damage()
			target.heart(damage[0]*user.skill_config["effect"]["passive_value"]["blue"],damage[1])
			randomize()
			if user.judge_debuff(user.skill_config["effect"]["passive_value"]["random"]):
				target._use_buff("ice",0,user.skill_config["effect"]["passive_value"]["duration"])
	if user.suck_blood!=0:
		user.heal(user.attack*user.suck_blood)
	user.current_mp+=(50+user.extra_mp)
	await user.get_tree().create_timer(0.5).timeout
func lang_suck_blood_attack(target,user:player):
	var original_position = user.global_position
	await user.get_tree().create_tween().tween_property(user,"position",target.position-Vector2(100,0),0.5).finished
	var damage = user.finish_damage()
	user.audio.play()
	target.heart(damage[0],damage[1])
	if user.current_hp<=user.max_hp*user.skill_config["effect"]["passive_value"]["hp_limit"]:
		user.heal(damage[0]*user.skill_config["effect"]["passive_value"]["suck_blood"])
	user.current_mp+=(50+user.extra_mp)
	await user.get_tree().create_tween().tween_property(user,"position",original_position,0.5).finished
