extends Node

export var python_executable := ""
export(NodePath) onready var _python_executable_edit = get_node(_python_executable_edit) as LineEdit

func _ready()->void:
	if not python_executable:
		match OS.get_name():
			"Windows", "UWP":
				python_executable = "python.exe"
			_:
				python_executable = "python"
	_python_executable_edit.text = python_executable

