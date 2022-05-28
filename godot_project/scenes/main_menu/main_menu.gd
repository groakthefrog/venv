extends Control

export(NodePath) onready var create_session_port = Util.A(get_node(notification_path) as LineEdit)
export(NodePath) onready var notification_path   = Util.A(get_node(notification_path) as Control)

func _on_create_session_pressed()->void:
	if create_session_port.text.is_valid_integer():
		Manager.create_session(int(create_session_port.text))
	else:
		pass
