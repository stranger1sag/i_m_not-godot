extends enemy
@onready var hp: ProgressBar = $hp
@onready var gpu_particles_2d_2: GPUParticles2D = $GPUParticles2D2
@onready var ice: Sprite2D = $"灵石InPixio"
@onready var ani: AnimationPlayer = $chaos/AnimationPlayer
@onready var chaos: Node2D = $chaos
@onready var buffcontainer: VBoxContainer = $buffcontainer
@onready var label: Label = $Sprite2D/Label
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer2D


func _ready() -> void:
	current_hp = max_hp
	label.text = str(current_hp)
func heart(damage:int,color = "white"):
	damage*=(1-damage_reduction)
	current_hp-=damage
	hp.value = current_hp/(max_hp*1.0)*100
	$GPUParticles2D.emitting = true
	$AnimationPlayer.play("heart")
	var show_value = preload("res://screen/伤害显示.tscn").instantiate()
	add_child(show_value)
	show_value.value_init(damage,color)
	label.text = str(current_hp)
	judge_death()
	
func attack_player(target:player):
	var original_position = global_position
	await get_tree().create_tween().tween_property(self,"global_position",target.global_position+Vector2(100,0),0.5).finished
	audio.playing = true
	target.heart(finish_damage())
	await get_tree().create_tween().tween_property(self,"global_position",original_position,0.5).finished
	
func judge_death():
	if current_hp<=0:
		Manager.enemy_list.erase(self)
		$AnimationPlayer.play("dead")
		await $AnimationPlayer.animation_finished
		queue_free()
func _use_buff(_type,_value,_duration,user=null):
	match _type:
		"ice":
			var have = false
			for i in Manager.debuff_handel_list:
				if i.type == "ice":
					i.end_rund = max(i.end_rund,Manager.rund+_duration)
					have = true
			if have:
				return
	var _buff = buff.new()
	_buff.use_buff(_type,_value,_duration,self,user)
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
	debuff.free()
func unable():
	var _unable = preload("res://screen/伤害显示.tscn").instantiate()
	add_child(_unable)
	_unable.value_init("无效","white")
func chaos_show():
	ani.play("chaos")
func chaos_hide():
	ani.stop()
	chaos.hide()
