extends Node2D
class_name player
signal value_change
var name_
#技能
var skill_ = Skill.new()
#技能id
var skill_id:String
#技能配置
var skill_config
#基础生命
var basis_hp:int=100
#最大生命
var max_hp:float=100:
	set(v):
		var cha = v - max_hp
		max_hp = v
		current_hp+=cha
		value_change.emit()
#当前生命
var current_hp:float=100:
	set(v):
		current_hp = clamp(v,0,max_hp)
		value_change.emit()
#最大蓝量
var max_mp:int=100
#当前蓝量
var current_mp:int=0:
	set(v):
		current_mp = v
		value_change.emit()
#基础攻击力
var basis_attack:int=100
#攻击力
var attack:int=200:
	set(v):
		attack = v
#暴击
var crit:float=0
#爆伤
var critical_multiplier:float = 1.5
#增伤倍率
var multiplier_power:float = 1
#自身减伤
var damage_reduction:float = 0
#虚弱
var weakness:float = 0
#是否使用技能
var is_use_skill = false
#攻击方式【近战，远程】
var attack_type = "near"
#球的颜色
var ball_color = "#000000"
#吸血转换率
var suck_blood = 0
#特殊攻击
var special_attack
#角色属性配置
var _config:Dictionary
#无敌状态
var invincible
#额外mp
var extra_mp = 0
#职业
var career
#原有伤害
var origin_attack:int:
	set(v):
		origin_attack = v
		attack = origin_attack
#角色的初始化
func init():
	pass
#暴击判断
var crit_count:float = 0

func judge_crit():
	crit_count=crit
	if randf_range(0.0,1.0)<crit_count:
		crit_count = 0
		return true
	else:
		return false

var debuff_count:float = 0

func judge_debuff(value:float):
	debuff_count=value
	if randf_range(0.0,1.0)<debuff_count:
		crit_count = 0
		return true
	else:
		return false

#最终伤害判定
func finish_damage():
	var damage = attack*(multiplier_power)*(1-weakness)
	if judge_crit():
		return [critical_multiplier*damage,"red"]
	return [damage,"white"]

#技能的使用
func use_skill():
	is_use_skill = false
	current_mp -= 100
	skill_.init(ReadLoad.get_skill_config(skill_id))
	match skill_.config["effect"]["target"]:
		"self_all":
			if skill_.config.has("special_skill"):
				await skill_.special_skill(Manager.player_list,self)
			else:
				await skill_.apply_skill(Manager.player_list,self)
		"self":
			if skill_.config.has("special_skill"):
				await skill_.special_skill([self],self)
			else:
				await skill_.apply_skill([self],self)
		"other":
			if skill_.config.has("special_skill"):
				await skill_.special_skill([Manager.player_list.pick_random()],self)
			else:
				await skill_.apply_skill([Manager.player_list.pick_random()],self)
		"enemy_all":
			if skill_.config.has("special_skill"):
				await skill_.special_skill(Manager.enemy_list,self)
			else:
				await skill_.apply_skill(Manager.enemy_list,self)
		"enemy_one":
			if skill_.config.has("special_skill"):
				await skill_.special_skill([Manager.enemy_list.pick_random()],self)
			else:
				await skill_.apply_skill([Manager.enemy_list.pick_random()],self)
		"self_min":
			var min_hp = INF
			var target_ = Manager.player_list[0]
			for target in Manager.player_list:
				if target.current_hp<min_hp and target.current_hp!=target.max_hp:
					target_ = target
					min_hp = target.current_hp
			if skill_.config.has("special_skill"):
				await skill_.special_skill([target_],self)
			else:
				await skill_.apply_skill([target_],self)
