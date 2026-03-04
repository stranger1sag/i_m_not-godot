extends CanvasLayer
@onready var color_rect: ColorRect = $ColorRect
@onready var list: HBoxContainer = $list/HBoxContainer
var card_config_dic:Array
var card_config_dic_list:Array
var card_list:Array
var player_name_list:Array
signal have_choose
var select_count = 0
func _ready() -> void:
	set_child_pause(self)
	color_rect.hide()
	card_config_dic=ReadLoad.card_data
func show_card():
	player_name_list = []
	card_config_dic_list = []
	for i in Manager.player_list:
		player_name_list.append(i.name_)
	for i in range(card_config_dic.size()):
		if card_config_dic[i]["target"] in player_name_list or card_config_dic[i]["target"] =="random":
			card_config_dic_list.append(card_config_dic[i])
	get_tree().paused = true
	color_rect.show()
	for i in range(3):
		var card = preload("res://screen/card.tscn").instantiate()
		card.up.connect(update_down)
		card.select.connect(select)
		card.have_select.connect(hide_alternative)
		list.add_child(card)
		var key = randi_range(0,card_config_dic_list.size()-1)
		card.init_card(card_config_dic_list[key])
		card_list.append(card)
func update_down():
	for card in card_list:
		if card.is_select:
			card.down()
func set_child_pause(node):
	for i in node.get_children():
		i.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		set_child_pause(i)
func select(config:Dictionary):
	for i in Manager.player_list:
		if i.name_ == config["target"]:
			if "update" in config.keys():
				for key in config["up"].keys():
					ReadLoad.skill_data[ReadLoad.role_data[i.name_]["skill_id"]]["effect"]["value"][key]+=config["up"][key]
				continue
			for j in config["value"].keys():
				match j:
					"attack":
						i.origin_attack+=i.basis_attack*config["value"][j]
					"max_hp":
						i.max_hp+=i.basis_hp*config["value"][j]
					"skill":
						ReadLoad.skill_data[i.skill_id]["effect"]["value"] = config["value"][j]
					"random":
						ReadLoad.skill_data[i.skill_id]["effect"]["random"] = config["value"][j]
					_:
						print("none")
func hide_alternative():
	select_count+=1
	for i in list.get_children():
		i.show_again()
	if ((Manager.max_count==3 and select_count==1)or 
	(Manager.max_count==5 and select_count==2)):
		for i in list.get_children():
			card_list.erase(i)
			i.queue_free()
		color_rect.hide()
		get_tree().paused = false
		have_choose.emit()
		select_count=0
