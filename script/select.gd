extends Control
@onready var list: HBoxContainer = $HBoxContainer/MarginContainer2/HScrollBar/list
@onready var button: Button = $HBoxContainer/HBoxContainer/Button
@onready var button_2: Button = $HBoxContainer/HBoxContainer/Button2
@onready var label_2: Label = $HBoxContainer/MarginContainer/Panel/MarginContainer/VBoxContainer/gridContainer/Label2
@onready var label_4: Label = $HBoxContainer/MarginContainer/Panel/MarginContainer/VBoxContainer/gridContainer/Label4
@onready var label_6: Label = $HBoxContainer/MarginContainer/Panel/MarginContainer/VBoxContainer/gridContainer/Label6
@onready var label_8: Label = $HBoxContainer/MarginContainer/Panel/MarginContainer/VBoxContainer/gridContainer/Label8
@onready var label_10: Label = $HBoxContainer/MarginContainer/Panel/MarginContainer/VBoxContainer/gridContainer/Label10
@onready var label_12: Label = $HBoxContainer/MarginContainer/Panel/MarginContainer/VBoxContainer/gridContainer/Label12
@onready var label_14: Label = $HBoxContainer/MarginContainer/Panel/MarginContainer/VBoxContainer/gridContainer/Label14
@onready var label_3: Label = $HBoxContainer/MarginContainer/Panel/MarginContainer/VBoxContainer/GridContainer/Label2
@onready var rich_text_label: RichTextLabel = $HBoxContainer/MarginContainer/Panel/MarginContainer/VBoxContainer/RichTextLabel
@onready var label_: Label = $HBoxContainer/MarginContainer/Panel/MarginContainer/VBoxContainer/GridContainer2/Label2
@onready var rich_text_label_2: RichTextLabel = $HBoxContainer/MarginContainer/Panel/MarginContainer/VBoxContainer/RichTextLabel2
@onready var font: CanvasLayer = $font

var count = 0
var config:Dictionary
var node_
var kuang = preload("res://screen/kuang.tscn").instantiate()
func _ready() -> void:
	var list_name:Array = ReadLoad.role_data.keys()
	list_name.shuffle()
	for i in list_name:
		var image = TextureButton.new()
		image.texture_normal = load(ReadLoad.role_data[i]["image_path"])
		image.connect("button_up",Callable(self,"_on_button_up").bind(image))
		image.set_meta("name",i)
		$HBoxContainer/ScrollContainer/BoxContainer.add_child(image)
	var scrollbar = $HBoxContainer/MarginContainer/Panel/MarginContainer/VBoxContainer/RichTextLabel.get_v_scroll_bar()
	scrollbar.self_modulate.a=0
	var scrollbar_2 = $HBoxContainer/MarginContainer/Panel/MarginContainer/VBoxContainer/RichTextLabel2.get_v_scroll_bar()
	scrollbar_2.self_modulate.a=0
	for i in range(Manager.player_list.size(),Manager.max_count):
		list.add_child(new_panel(i+1))
@onready var h_scroll_bar: ScrollContainer = $HBoxContainer/MarginContainer2/HScrollBar
@onready var animation_player_2: AnimationPlayer = $CanvasLayer2/AnimationPlayer2
@onready var texture_rect_3: TextureRect = $CanvasLayer2/AnimationPlayer2/TextureRect3

func _process(delta: float) -> void:
	if h_scroll_bar.scroll_horizontal >=250:
		jiantou_hide()
	elif h_scroll_bar.scroll_horizontal>=150:
		jiantou_show()
	if h_scroll_bar.scroll_horizontal >0:
		animation_player_2.play("show")
	else:
		animation_player_2.stop()
		texture_rect_3.hide()
@onready var animation_player = $CanvasLayer2/AnimationPlayer
func jiantou_show():
	animation_player.play("show")
@onready var texture = $CanvasLayer2/AnimationPlayer/TextureRect2
func jiantou_hide():
	animation_player.stop()
	texture.hide()
#获知信息
func _on_button_up(node):
	if node_!=null:
		node_.remove_child(kuang)
	node.add_child(kuang)
	node_ = node
	config = ReadLoad.role_data[node.get_meta("name")]
	label_2.text = config["name_"]
	label_4.text = str(config["max_hp"])
	label_6.text = str(config["basis_attack"])
	label_8.text = str(config["crit"]*100)+"%"
	label_10.text = str(config["critical_multiplier"]*100)+"%"
	label_12.text = str(config["multiplier_power"])
	label_14.text =str(config["damage_reduction"]*100)+"%"
	label_3.text = config["skill_id"]
	var descript_dic:Dictionary = ReadLoad.get_skill_config(config["skill_id"])["effect"]["value"].duplicate()
	for i in descript_dic.keys():
		if i =="duration" or i=="self_duration":
			continue
		else:
			descript_dic[i]*=100
	var descript = ReadLoad.get_skill_config(config["skill_id"])["descript"].format(descript_dic.values())
	rich_text_label.text = descript
	$CanvasLayer2/TextureRect.show()
	$CanvasLayer2/TextureRect.texture.region=ReadLoad.position_to_Rect(ReadLoad.buff_data[config["career"]]["position"])
	$CanvasLayer2/TextureRect.tooltip_text = ReadLoad.buff_data[config["career"]]["descript"]
	$CanvasLayer2/TextureRect/Label.text = config["career"]
	if ReadLoad.get_skill_config(config["skill_id"]).has("passive_skill"):
		descript_dic = ReadLoad.get_skill_config(config["skill_id"])["effect"]["passive_value"].duplicate()
		for i in descript_dic.keys():
			if i =="duration":
				continue
			else:
				descript_dic[i]*=100
		descript = ReadLoad.get_skill_config(config["skill_id"])["passive_skill"]["descript"].format(descript_dic.values())
		label_.text = ReadLoad.get_skill_config(config["skill_id"])["passive_skill"]["name"]
		rich_text_label_2.text = descript
	else :
		label_.text =""
		rich_text_label_2.text = ""
	for i in Manager.player_list:
		if i.name_ == config["name_"]:
			button.text = "解约"
			return
	button.text = "契约"
#加入队列
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
func _on_button_pressed() -> void:
	if not config:
		return  
	if button.text == "契约" and count<Manager.max_count :
		audio_stream_player.stream = load("res://assest/voice/制片帮素材_279147_木头敲击声.mp3")
		audio_stream_player.play()
		var player_1 = preload("res://screen/角色.tscn").instantiate()
		for prop in player.new().get_property_list():
			if config.keys().has(prop.get("name")):
				player_1.set(prop.get("name"),config[prop.get("name")])
		player_1._config = config
		Manager.player_list.append(player_1)
		button.text = "解约"
		count+=1
		if node_:
			node_.modulate.a = 0.5
	elif button.text == "解约":
		audio_stream_player.stream = load("res://assest/voice/制片帮素材_279147_木头敲击声.mp3")
		audio_stream_player.play()
		for player_1 in Manager.player_list:
			if player_1.name_ == config["name_"]:
				Manager.player_list.erase(player_1)
				button.text = "契约"
				count-=1
		if node_:
			node_.modulate.a = 1.0
	elif count>=Manager.max_count:
		audio_stream_player.stream = load("res://assest/voice/制片帮素材_92716_错误_168389020.ogg")
		audio_stream_player.play()
	for child in list.get_children():
		for i in child.get_children():
			if i==kuang:
				child.remove_child(kuang)
		child.queue_free()
	new_texturebutton()
	for i in range(Manager.player_list.size(),Manager.max_count):
		list.add_child(new_panel(i+1))
	var name_list=[]
	for j in Manager.player_list:
		name_list.append(j.name_)
	for i in $HBoxContainer/ScrollContainer/BoxContainer.get_children():
		if i.get_meta("name")in name_list:
			i.modulate.a =0.5
		else:
			i.modulate.a =1.0
#开始游戏
func _on_button_2_pressed() -> void:
	if Manager.player_list.size()==0:
		return
	await ChangeScene.change_scene("res://screen/main.tscn")

#切换模式
func _button_pressed() -> void:
	if Manager.max_count==3:
		$CanvasLayer2/Button.text="五\n人\n模\n式"
		jiantou_show()
		Manager.max_count=5
		#var new_label = preload("res://screen/字幕.tscn").instantiate()
		#font.add_child(new_label)
		#new_label.init_label("模式切换成功")
		#await get_tree().create_timer(0.1).timeout
		#new_label = preload("res://screen/字幕.tscn").instantiate()
		#font.add_child(new_label)
		#new_label.init_label("已新增2个契约位")
		for i in range(Manager.max_count-list.get_child_count()):
			list.add_child(new_panel(4+i))
	elif Manager.max_count==5:
		jiantou_hide()
		#var label_text = clamp(Manager.player_list.size()-3,0,9)
		#var new_label = preload("res://screen/字幕.tscn").instantiate()
		#font.add_child(new_label)
		#new_label.init_label("模式切换成功")
		#if label_text!=0:
			#await get_tree().create_timer(0.1).timeout
			#new_label = preload("res://screen/字幕.tscn").instantiate()
			#font.add_child(new_label)
			#new_label.init_label("已解除后"+str(label_text)+"位的契约")
		Manager.max_count=3
		if Manager.player_list.size()>3:
			Manager.player_list=Manager.player_list.slice(0,3)
		count=Manager.player_list.size()
		for child in list.get_children():
			for i in child.get_children():
				if i==kuang:
					child.remove_child(kuang)
			child.queue_free()
		new_texturebutton()
		for i in range(Manager.player_list.size(),Manager.max_count):
			list.add_child(new_panel(i+1))
		var name_list=[]
		for j in Manager.player_list:
			name_list.append(j.name_)
		for i in $HBoxContainer/ScrollContainer/BoxContainer.get_children():
			if i.get_meta("name")in name_list:
				i.modulate.a =0.5
			else:
				i.modulate.a =1.0
		$CanvasLayer2/Button.text="三\n人\n模\n式"
		
func new_panel(number):
	var panel = Panel.new()
	var pan = load("res://tres/cloumn.tres") as StyleBoxTexture
	panel.add_theme_stylebox_override("panel",pan)
	panel.custom_minimum_size = Vector2(128,128)
	panel.add_child(new_label(number))
	return panel
func new_texturebutton():
	for i in Manager.player_list:
		var image = TextureButton.new()
		image.texture_normal = load(ReadLoad.role_data[i.name_]["image_path"])
		image.connect("button_up",Callable(self,"_on_button_up").bind(image))
		image.set_meta("name",i.name_)
		var label = Label.new()
		label.text = i.name_
		#label.set_anchors_preset(Control.PRESET_TOP_WIDE)
		image.add_child(label)
		list.add_child(image)
func new_label(string):
	var label = Label.new()
	label.text = str(string)
	label.add_theme_font_size_override("font_size",24)
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.set_offsets_preset(Control.PRESET_CENTER)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.modulate = Color("#00FF00")
	return label
