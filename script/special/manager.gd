extends Node
signal add_rund
var rund = 1
var player_list:Array[player]
var enemy_list:Array[enemy]
var wave = 1
var layer = 1
var max_count = 3
var debuff_handel_list:Array=[]
var label_str
signal wave_change
func judge_game():
	if player_list.size()==0:
		label_str = "YOU lost"
		await ChangeScene.change_scene("res://screen/end.tscn")
	if enemy_list.size()==0:
		if wave>=7:
			layer+=1
			wave = 0
		wave+=1
		heal_all()
		wave_change.emit()
		await add_enemy()
		if layer>=12:
			label_str = "YOU won"
			await ChangeScene.change_scene("res://screen/end.tscn")
func add_enemy():
	if wave ==7:
		var enemy_1 = preload("res://screen/敌人.tscn").instantiate()
		var config = ReadLoad.enemy_data["Boss"]
		enemy_1.max_hp = config["max_hp"]+config["max_hp_up"]["wave"]*(wave-1)+config["max_hp_up"]["layer"]*(layer-1)
		enemy_1.attack = config["attack"]+config["attack_up"]["wave"]*(wave-1)+config["attack_up"]["layer"]*(layer-1)
		enemy_list.append(enemy_1)
	else:
		var enemy_1 = preload("res://screen/敌人.tscn").instantiate()
		var config = ReadLoad.enemy_data["精英"]
		enemy_1.max_hp = config["max_hp"]+config["max_hp_up"]["wave"]*(wave-1)+config["max_hp_up"]["layer"]*(layer-1)
		enemy_1.attack = config["attack"]+config["attack_up"]["wave"]*(wave-1)+config["attack_up"]["layer"]*(layer-1)
		enemy_list.append(enemy_1)
	for i in range(max_count-1):
		var enemy_2 = preload("res://screen/敌人.tscn").instantiate()
		var config = ReadLoad.enemy_data["普通"]
		enemy_2.max_hp = config["max_hp"]+config["max_hp_up"]["wave"]*(wave-1)+config["max_hp_up"]["layer"]*(layer-1)
		enemy_2.attack = config["attack"]+config["attack_up"]["wave"]*(wave-1)+config["attack_up"]["layer"]*(layer-1)
		enemy_list.append(enemy_2)
func heal_all():
	for i in player_list:
		i.heal(i.max_hp*0.2)
