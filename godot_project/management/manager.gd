extends Node

# autoload Manager
# Sets correct current scene based on venv state

const _LOADING_SCENE: PackedScene = preload("res://scenes/loading_scene/loading_scene.tscn")
const _CONTROL_SCENE: PackedScene = preload("res://scenes/control_scene/control_scene.tscn")
const _VIEWER_SCENE: PackedScene = preload("res://scenes/viewer_scene/viewer_scene.tscn")
const _MAIN_MENU_SCENE: PackedScene = preload("res://scenes/main_scene/main_scene.tscn")

var _is_viewer: bool = false
func is_viewer()->bool: return _is_viewer

func _ready():
	Venv.connect("state_changed", self, "_on_venv_state_changed")

func _on_venv_state_changed(new_state:int)->void:
	_switch_to_state_scene(new_state)

func _switch_to_state_scene(state:int)->void:
	match state:
		Venv.STATE_DISCONNECTED:
			SceneManager.change_scene_to(_MAIN_MENU_SCENE)
		Venv.STATE_STARTING:
			SceneManager.change_scene_to(_LOADING_SCENE, {cancel_scene = _MAIN_MENU_SCENE})
		Venv.STATE_NORMAL:
			if _is_viewer:
				SceneManager.change_scene_to(_VIEWER_SCENE)
			else:
				SceneManager.change_scene_to(_CONTROL_SCENE)

