extends Node2D
@onready var alternative: CanvasLayer = $alternative

var player_list:Array[player]
var enemies_list:Array[enemy]
var circle = preload("res://screen/circle.tscn")
var play = preload("res://screen/角色.tscn")
var enemies = preload("res://screen/敌人.tscn")
var choose_count_list={}
var choose_c={"战士":0.2,"坦克":0.25,"辅助":0.15,"法师":0.17}
func _ready() -> void:
	$alternative.have_choose.connect(add_enemy)
	Manager.wave_change.connect(new_wave)
	Manager.add_enemy()
	player_list=Manager.player_list
	enemies_list = Manager.enemy_list
	for i in range(player_list.size()):
		var play_1 = player_list[i]
		play_1.position = $player.get_child(i).global_position
		play_1.init_role(ReadLoad.role_data[play_1.name_]["image_path"])
		$player.add_child(play_1)
	$Label.text = "波次 "+str(Manager.wave)+"/7"
	player_list=Manager.player_list
	enemies_list = Manager.enemy_list
	for i in range(Manager.max_count):
		var enemy_1 =Manager.enemy_list[i]
		enemy_1.position = $enemies.get_child(i).global_position
		$enemies.add_child(enemy_1)
	#刷新占比
	choose_count_list.clear()
	for playe in Manager.player_list:
		choose_count_list[playe.name_]=1
	await get_tree().create_timer(0.5).timeout
	shuffle_list()
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("click"):
		#var target:enemy = enemies_list.pick_random()
		#var circle_1 = circle.instantiate()
		#add_child(circle_1)
		#circle_1.init(target)
func shuffle_list():
	Manager.player_list.shuffle()
	Manager.enemy_list.shuffle()
	animation_start()
func choose_player():
	if Manager.player_list.size()==1:
		return Manager.player_list[0]
	var prd={}
	for playe in Manager.player_list:
		if playe.modulate.a!=0.5:
			prd[playe.name_] = choose_c[playe.career]*choose_count_list[playe.name_]
	var total_value = 0.0
	for key in prd.keys():
		total_value+=prd[key]
	var random_rate = randf_range(0.0,total_value)
	var value_rate = 0.0
	var play_name
	var count=0
	for key in prd.keys():
		value_rate+=prd[key]
		if random_rate<value_rate and count==0:
			play_name=key
			choose_count_list[key] = 1
			count+=1
		else:
			choose_count_list[key] +=1
	for i in Manager.player_list:
		if i.name_ == play_name:
			return i
#动画逻辑
func animation_start():
	for _player in player_list:
		randomize()
		await _player.attack_enemy(Manager.enemy_list.pick_random())
		await get_tree().create_timer(0.3).timeout
		if Manager.enemy_list.size()==0:
			await Manager.judge_game()
			return
	await get_tree().create_timer(0.5).timeout
	for _enemy in Manager.enemy_list:
		if not _enemy.is_move:
			continue
		randomize()
		await _enemy.attack_player(choose_player())
		await get_tree().create_timer(0.3).timeout
		if Manager.player_list.size()==0:
			await Manager.judge_game()
			return
	new_rund()
#添加敌人
func add_enemy():
	$Label.text = "波次 "+str(Manager.wave)+"/7"
	player_list=Manager.player_list
	enemies_list = Manager.enemy_list
	for i in range(Manager.max_count):
		var enemy_1 =Manager.enemy_list[i]
		enemy_1.position = $enemies.get_child(i).global_position
		$enemies.add_child(enemy_1)
	choose_count_list.clear()
	for playe in Manager.player_list:
		choose_count_list[playe.name_]=1
	new_rund()
#新的一个回合
func new_rund():
	Manager.rund+=1
	Manager.add_rund.emit()
	for i in Manager.debuff_handel_list:
		if i==null:
			Manager.debuff_handel_list.erase(i)
			return
		await i.remove_buff()
	await get_tree().create_timer(0.5).timeout
	shuffle_list()
	

#func total_hp_show():
	#var current_value = 0
	#for enemies in Manager.enemy_list:
		#current_value+=enemies.current_hp
	#$totalhp.value = current_value/(Manager.total_value*1.0)*100
	#$totalhp/Label2.text =str(current_value)+"HP"
func new_wave():
	alternative.show_card()
func _on_button_pressed() -> void:
	print("upgrade")
	#get_tree().paused = true
