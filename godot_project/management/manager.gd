extends Node

# autoload Manager
# Sets correct current scene based on venv state

const _LOADING_SCENE: PackedScene = preload("res://scenes/loading_scene/loading_scene.tscn")
const _CONTROL_SCENE: PackedScene = preload("res://scenes/control_scene/control_scene.tscn")
const _VIEWER_SCENE: PackedScene = preload("res://scenes/viewer_scene/viewer_scene.tscn")
const _MAIN_MENU_SCENE: PackedScene = preload("res://scenes/main_scene/main_scene.tscn")

enum {
	WINDOW_TYPE_UNDECIDED
	WINDOW_TYPE_VIEWER
	WINDOW_TYPE_CONTROL
}

var window_type :=  WINDOW_TYPE_CONTROL
func get_window_type()->int: return window_type
var prevent_scene_change := false

func _ready():
	Venv.connect("state_changed", self, "_on_venv_state_changed")
	# start venv and set window type if in debug and manually starting on a specific scene
	if OS.is_debug_build() and SceneManager.get_current_scene().filename != ProjectSettings.get("application/run/main_scene"):
		Manager.prevent_scene_change = true
		Venv.create_session(25565)
		Manager.prevent_scene_change = false
		match SceneManager.get_current_scene().filename:
			_VIEWER_SCENE.resource_path:
				Manager.window_type = Manager.WINDOW_TYPE_CONTROL
			_CONTROL_SCENE.resource_path:
				Manager.window_type = Manager.WINDOW_TYPE_CONTROL


func _on_venv_state_changed(new_state:int)->void:
	if not prevent_scene_change:
		_switch_to_state_scene(new_state)

func _switch_to_state_scene(state:int)->void:
	match state:
		Venv.STATE_DISCONNECTED:
			SceneManager.change_scene_to(_MAIN_MENU_SCENE)
		Venv.STATE_STARTING:
			SceneManager.change_scene_to(_LOADING_SCENE, {cancel_scene = _MAIN_MENU_SCENE})
		Venv.STATE_NORMAL:
			match window_type:
				WINDOW_TYPE_VIEWER:
					SceneManager.change_scene_to(_VIEWER_SCENE)
				WINDOW_TYPE_CONTROL:
					SceneManager.change_scene_to(_CONTROL_SCENE)
				_:
					pass # @todo handle user defined window type

