extends Control
var is_flip = false
var is_move = false
var is_select = false
var original_pos
signal up
signal select(config)
signal have_select
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var card: Panel = $card
@onready var label: Label = $card/MarginContainer/VBoxContainer/Label
@onready var rich_text_label: RichTextLabel = $card/MarginContainer/VBoxContainer/RichTextLabel
@onready var label_1: Label = $card/MarginContainer/VBoxContainer/HBoxContainer/Label
@onready var label_2: Label = $card/MarginContainer/VBoxContainer/HBoxContainer/Label2
var config
var tween_list:Array
var label_list:Array
func _ready() -> void:
	set_child_pause(self)
	label_list = [label,rich_text_label,label_1,label_2,card]
	process_mode = Node.PROCESS_MODE_ALWAYS
	size_flags_vertical = Control.SIZE_FILL
	var scrollbar =$card/MarginContainer/VBoxContainer/RichTextLabel.get_v_scroll_bar()
	scrollbar.self_modulate.a=0
func init_card(dic) -> void:
	config = dic.duplicate()
	card.self_modulate = Color(dic["quality"])
	label.add_theme_color_override("font_color",Color(dic["quality"]))
	label_2.text = judge_target(dic["target"])
	label.text = dic["name"]
	var descript = dic["descript"]
	if "update" in dic.keys():
		var descript_dic:Dictionary = ReadLoad.get_skill_config(ReadLoad.role_data[dic["target"]]["skill_id"])["effect"]["value"].duplicate()
		for i in descript_dic.keys():
			if i =="duration" or i=="self_duration":
				continue
			else:
				descript_dic[i]*=100
		descript = ReadLoad.get_skill_config(ReadLoad.role_data[dic["target"]]["skill_id"])["descript"].format(descript_dic.values())+"\n"+dic["descript"]+"\n"
		var up_dic:Dictionary = dic["up"].duplicate()
		for i in up_dic.keys():
			if i =="duration" or i=="self_duration":
				continue
			else:
				up_dic[i]*=100
		for i in up_dic.keys():
			up_dic[i]+=descript_dic[i]
		var new_list:Array
		for i in up_dic.keys():
			new_list.append(descript_dic[i])
			new_list.append(up_dic[i])
		descript+=dic["show"].format(new_list)
	rich_text_label.text = descript
func show_again():
	var dic  = config
	card.self_modulate = Color(dic["quality"])
	label.add_theme_color_override("font_color",Color(dic["quality"]))
	label_2.text = judge_target(dic["target"])
	label.text = dic["name"]
	var descript = dic["descript"]
	if "update" in dic.keys():
		var descript_dic:Dictionary = ReadLoad.get_skill_config(ReadLoad.role_data[dic["target"]]["skill_id"])["effect"]["value"].duplicate()
		for i in descript_dic.keys():
			if i =="duration" or i=="self_duration":
				continue
			else:
				descript_dic[i]*=100
		descript = ReadLoad.get_skill_config(ReadLoad.role_data[dic["target"]]["skill_id"])["descript"].format(descript_dic.values())+"\n"+dic["descript"]+"\n"
		var up_dic:Dictionary = dic["up"].duplicate()
		for i in up_dic.keys():
			if i =="duration" or i=="self_duration":
				continue
			else:
				up_dic[i]*=100
		for i in up_dic.keys():
			up_dic[i]+=descript_dic[i]
		var new_list:Array
		for i in up_dic.keys():
			new_list.append(descript_dic[i])
			new_list.append(up_dic[i])
		descript+=dic["show"].format(new_list)
	rich_text_label.text = descript
func _process(delta: float) -> void:
	if get_tree().paused:
		for i in tween_list:
			i.custom_step(delta)
#点击#选择
func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		if not is_flip:
			animation_player.play("flip")
			await animation_player.animation_finished
			is_flip = true
			return
		elif is_move or animation_player.is_playing():
			return
		elif not is_move and is_select:
			get_tree().root.gui_disable_input = true
			var shader= card.material.duplicate()
			for i in label_list:
				i.material = shader
			var tween = new_tween()
			select.emit(config)
			await tween.tween_property(card.material,"shader_parameter/dissolve_threshold",1,1).finished
			gui_input.disconnect(_on_gui_input)
			tween_list.erase(tween)
			get_tree().root.gui_disable_input = false
			have_select.emit()
			return
		is_move = true
		original_pos = position
		up.emit()
		get_tree().root.gui_disable_input = true
		var tween = new_tween()
		await tween.tween_property(self,"position",original_pos+Vector2(0,-50),0.2).finished
		tween_list.erase(tween)
		get_tree().root.gui_disable_input = false
		is_select = true
		is_move = false
	elif event.is_action_released("click_right"):
		if not is_select or is_move or not is_flip:
			return
		is_move = true
		get_tree().root.gui_disable_input = true
		var tween = new_tween()
		await tween.tween_property(self,"position",original_pos,0.2).finished
		tween_list.erase(tween)
		get_tree().root.gui_disable_input = false
		is_select = false
		is_move = false

func down():
	is_move = true
	get_tree().root.gui_disable_input = true
	var tween = new_tween()
	await tween.tween_property(self,"position",original_pos,0.2).finished
	tween_list.erase(tween)
	get_tree().root.gui_disable_input = false
	is_select = false
	is_move = false

func set_child_pause(node):
	for i in node.get_children():
		i.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		set_child_pause(i)
func new_tween():
	var tween = get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	if tween:
		tween_list.append(tween)
		return tween
	else:
		print("false")
func judge_target(targte_str):
	match targte_str:
		"random":
			var target = Manager.player_list.pick_random().name_
			config["target"] = target
			return target
		_:
			return targte_str
