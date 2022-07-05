extends Control

export(NodePath) onready var _create_session_port = Util.A(get_node(_create_session_port) as LineEdit)
#export(NodePath) onready var _notification_path   = Util.A(get_node(_notification_path) as Control)

func _on_create_session_pressed()->void:
	var port_str: String
	if _create_session_port.text.empty():
		port_str = _create_session_port.placeholder_text
	else:
		port_str = _create_session_port.text

	if port_str.is_valid_integer():
		if Venv.create_session(int(_create_session_port.text)):
			pass # error creating session
	else:
		pass # port is not number


func _on_join_session_pressed()->void:
	pass
