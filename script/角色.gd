extends player
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var buffcontainer: VBoxContainer = $buffcontainer
@onready var gpu_particles_2d_3: GPUParticles2D = $Node2D/GPUParticles2D3
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer2D
var texture
		
var _special_attack = special_attack_.new()
var buff_:TextureRect

func _ready() -> void:
	attack_audio()
func init_role(image_path):
	skill_config = ReadLoad.skill_data[skill_id]
	basis_hp = max_hp
	origin_attack = basis_attack
	Manager.wave_change.connect(original_attack)
	attack = basis_attack
	connect("value_change",change_value)
	texture = load(image_path)
	$Sprite2D.texture = texture
	current_hp = max_hp
	#current_mp = 100
	#$Sprite2D/Label.text = name_
	$Sprite2D/Label.text = str(current_hp)+"/"+str(max_hp)
	$Sprite2D/Label2.text = name_

func heart(damage:int):
	damage*=(1-damage_reduction)
	if name_ == "天使":
		damage*=(skill_config["effect"]["passive_value"]["extra_damage"]+1)
	animation_player.speed_scale = 1
	if invincible == "true":
		animation_player.play("金钟罩")                                                                                                        
		$Node2D/GPUParticles2D.modulate = Color(1,0,0)
		up_show("无敌","gold")
		invincible = "false"
	else :
		current_hp-=damage
		$Node2D/GPUParticles2D.emitting = true
		animation_player.play("heart")
		up_show(damage,"white")
		judge_death()
		await get_tree().create_timer(0.4).timeout
	if name_ == "狼" and not buff_:
		if current_hp <= max_hp*skill_config["effect"]["passive_value"]["hp_limit"]:
			var _buff=debuff_show("suck_blood")
			buff_ =_buff 
	elif name_ == "红色":
		$Node2D/GPUParticles2D3.emitting = true
		up_show()
		multiplier_power=round((max_hp-current_hp)/max_hp*1.0/skill_config["effect"]["passive_value"]["hp_down"]*skill_config["effect"]["passive_value"]["attack"]*100.0)/100.0+1
	elif name_ == "黄色":
		damage_reduction=skill_config["effect"]["passive_value"]["basis_damage_reduction"]-round((max_hp-current_hp)/max_hp*1.0/skill_config["effect"]["passive_value"]["hp_down"]*skill_config["effect"]["passive_value"]["damage_reduction"]*100.0)/100.0
func attack_enemy(target):
	animation_player.speed_scale = 1
	if current_mp >= 100:
		is_use_skill=true
	await get_tree().create_timer(0.2).timeout
	if not is_use_skill:
		if special_attack:
			await _special_attack.init_special_attack(target,special_attack,self)
			return
		var damage = finish_damage()
		match attack_type:
			"near":
				var original_position = global_position
				await get_tree().create_tween().tween_property(self,"position",target.position-Vector2(100,0),0.5).finished
				audio.play()
				target.heart(damage[0],damage[1])
				suck(damage[0])
				current_mp+=(50+extra_mp)
				await get_tree().create_tween().tween_property(self,"position",original_position,0.5).finished
			"far":
				var color = ball_color
				if ball_color is Array:
					color = ball_color.pick_random()
				ball_shot(color,target)
				audio.play()
				await get_tree().create_timer(0.5).timeout
				target.heart(damage[0],damage[1])
				suck(damage[0])
				current_mp+=(50+extra_mp)
				await get_tree().create_timer(0.5).timeout
	else:
		$TextureRect.show()
		$TextureRect/Label.text = ReadLoad.get_skill_config(skill_id)["name"]
		await use_skill()
		$TextureRect.hide()
	if invincible == "false":
		animation_player.speed_scale = -1
		animation_player.play("金钟罩")
		invincible = "true"
	up_attack()

func judge_death():
	if current_hp<=0:
		Manager.player_list.erase(self)
		get_tree().create_tween().tween_property($hp,"modulate",Color(1,1,1,0),0.5)
		get_tree().create_tween().tween_property($mp,"modulate",Color(1,1,1,0),0.5)
		await get_tree().create_tween().tween_property($Sprite2D,"modulate",Color(1,1,1,0),0.5).finished
		if name_ == "单绿" and Manager.player_list.size()!=0:
			await use_skill()
		queue_free()

func change_value():
	$hp.value = (1.0*current_hp)/max_hp*100
	$mp.value = (1.0*current_mp)/max_mp*100
	$Sprite2D/Label.text = str(current_hp)+"/"+str(max_hp)

func heal(value:int):
	if name_ =="天使":
		value*=(1+skill_config["effect"]["passive_value"]["up_hp"])
	$Node2D/GPUParticles2D2.emitting = true
	current_hp+=value
	var show_value = preload("res://screen/伤害显示.tscn").instantiate()
	add_child(show_value)
	show_value.value_init(value,"green")
	if name_ == "红色":
		multiplier_power=round((max_hp-current_hp)/max_hp*1.0/skill_config["effect"]["passive_value"]["hp_down"]*skill_config["effect"]["passive_value"]["attack"]*100.0)/100.0+1
	elif name_ == "黄色":
		damage_reduction=skill_config["effect"]["passive_value"]["basis_damage_reduction"]-round((max_hp-current_hp)/max_hp*1.0/skill_config["effect"]["passive_value"]["hp_down"]*skill_config["effect"]["passive_value"]["damage_reduction"]*100.0)/100.0
	elif name_ == "狼":
		if current_hp>max_hp*skill_config["effect"]["passive_value"]["hp_limit"] and buff_!=null:
			debuff_hide(buff_)

func ball_shot(color,target):
	var circle = preload("res://screen/circle.tscn").instantiate()
	circle.init(target)
	circle.modulate = Color(color)
	add_child(circle)

func _use_buff(_type,_value,_duration):
	var _buff = buff.new()
	_buff.use_buff(_type,_value,_duration,self)

func debuff_show(_debuff):
	var debuff = TextureRect.new()
	var debuff_atlas = AtlasTexture.new()
	debuff_atlas.atlas = load("res://assest/res_ui.png")
	debuff_atlas.region = ReadLoad.position_to_Rect(ReadLoad.buff_data[_debuff]["position"])
	debuff.texture = debuff_atlas
	debuff.custom_minimum_size = Vector2(80,80)
	buffcontainer.add_child(debuff)
	return debuff

func debuff_hide(debuff):
	debuff.queue_free()

func up_attack():
	if name_ == "恶魔":
		attack+=basis_attack*skill_config["effect"]["passive_value"]["attack"]
		$Node2D/GPUParticles2D3.emitting = true
		up_show()

func original_attack():
	if name_ == "恶魔":
		attack = origin_attack
		up_show("伤害重置","white")

func suck(damage):
	if suck_blood!=0:
		heal(damage*suck_blood)

func skill_suck_blood(damage):
	if suck_blood!=0:
		heal(damage*suck_blood)

func up_show(text="伤害提升",color="pink"):
	var sh_show = preload("res://screen/伤害显示.tscn").instantiate()
	add_child(sh_show)
	sh_show.value_init(text,color)
	
func attack_audio():
	if attack_type == "far":
		audio.stream = load("res://assest/voice/冰球-发射-LTT20070428_爱给网_aigei_com.ogg")
	else:
		audio.stream = load("res://assest/voice/人类受伤声-战斗击打-拟声_爱给网_aigei_com.ogg")
