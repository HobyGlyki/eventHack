extends Node2D

var start_position = Vector2(2,2)
var is_dragging: bool = false
var move_distance = 522 # Расстояние перемещения
var move_threshold = 10 # Порог для определения направления свайпа
var is_moving: bool = false
var target_position: Vector2
@onready var canvas_layer = get_node("CanvasLayer/SubViewportContainer/Node2D")
var page = 0
var standard = 696
var tween_isrun: bool = false
var data
@onready var http_request = $HTTPRequest

func _ready():
	# Добавляем HTTP-запрос как дочерний узел
	add_child(http_request)
	# Формируем URL для GitHub API

	var url = "https://raw.githubusercontent.com/HobyGlyki/eventHack/main/JSON/events.json"
	var headers = "Content-Type: application/json"
	
	http_request.request(url)
	http_request.connect("request_completed", _on_http_request_request_completed)

func move_elements():
	var page_max = get_tree().get_node_count_in_group("draggable_items") - 1
	if not ((page == 0 and target_position.x/abs(target_position.x) == 1) or (page == page_max and target_position.x/abs(target_position.x) == -1)):
		var tween = get_tree().create_tween()
		tween_isrun = true
		tween.tween_property(canvas_layer, "position:x", canvas_layer.position.x + target_position.x, 0.3)
		tween.connect("finished", on_tween_finished)
	else:
		is_moving = false
		tween_isrun = false

func on_tween_finished():
	page -= target_position.x/abs(target_position.x)
	is_moving = false
	tween_isrun = false

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			start_position = event.position
			is_dragging = true
		else:
			is_dragging = false
			if is_moving and !tween_isrun:
				move_elements()
	elif event is InputEventScreenDrag:
		if is_dragging and tween_isrun == false:
			var delta = start_position.x - event.position.x
			if abs(delta) > move_threshold and is_moving == false:
				is_moving = true
				var direction = -sign(delta)
				target_position = Vector2(direction * move_distance, 0)



func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == OK:
		var json_parser = JSON.new()

		var data = body
		var json_string = json_parser.parse_string(body.get_string_from_utf8())
		data=json_string

		

		if result != null:
			data = json_string
			# Проверяем, есть ли данные
			if data.size() > 0:
				var event_scene = load("res://event.tscn")
				for i in range(data.size()):
					var event_instance = event_scene.instantiate()
					var label = event_instance.get_node("StaticBody2D/Label")
					var label2 = event_instance.get_node("StaticBody2D/Label2")
					var label3 = event_instance.get_node("StaticBody2D/Label3")
					var label4 = event_instance.get_node("StaticBody2D/Label4")
					label.text = data[i].title
					label2.text = data[i].description
					label3.text = data[i].date
					label4.text = data[i].location
					print(canvas_layer.get_parent().get_child_count())
					# Позиционируем события на экране
					event_instance.position = Vector2(0 + i * 522, 0)
					canvas_layer.add_child(event_instance)
					event_instance.add_to_group
