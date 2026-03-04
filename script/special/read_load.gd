extends Node
var skill_data:Dictionary
var role_data:Dictionary
var buff_data:Dictionary
var enemy_data:Dictionary
var card_data:Array
func _ready() -> void:
	skill_data = load_datas("res://json/skill.json").duplicate()
	role_data = load_datas("res://json/role.json").duplicate()
	buff_data = load_datas("res://json/buff.json").duplicate()
	enemy_data = load_datas("res://json/enemy.json").duplicate()
	card_data = load_datas("res://json/card.json")["card"].duplicate()
func load_datas(file_path:String):
	var file = FileAccess.open(file_path,FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var json_result = JSON.parse_string(json_text)
		file.close()
		if json_result !=null:
			return json_result
		else:
			print("error")
		

func get_skill_config(skill_id:String):
	for skill_key in skill_data.keys():
		if skill_key == skill_id:
			return skill_data[skill_key]
	return {}

func position_to_Rect(rect:Array):
	if rect.size() == 4:
		var x = rect[0]
		var y = rect[1]
		var w = rect[2]
		var h = rect[3]
		return Rect2(x,y,w,h)
	else:
		return Rect2(0,0,0,0)
	
