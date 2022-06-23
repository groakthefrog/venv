extends Control

export(NodePath) onready var _create_session_port = Util.A(get_node(_create_session_port) as LineEdit)
export(NodePath) onready var _notification_path   = Util.A(get_node(_notification_path) as Control)

func _on_create_session_pressed()->void:
	if _create_session_port.text.is_valid_integer():
		if Manager.create_session(int(_create_session_port.text)):
			pass # error creating session
	else:
		pass # port is not number

func _on_join_session_pressed()->void:
	pass