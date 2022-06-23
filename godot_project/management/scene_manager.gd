extends Node

# autoload

var _current_scene: Node = null

func get_current_scene()->Node:
	return _current_scene

func _ready():
	_current_scene = get_tree().current_scene
	_current_scene.connect("tree_exiting", self, "_on_current_scene_exit_tree")

func change_scene(path:String, init_values:Dictionary = {})->int:
	if path.empty():
		return ERR_INVALID_PARAMETER
	var scene: PackedScene = load(path)
	return change_scene_to(scene, init_values)

func change_scene_to(scene:PackedScene, init_values:Dictionary = {})->int:
	if not scene:
		return ERR_INVALID_PARAMETER
	var inst := scene.instance()
	if inst.has_method("init_scene"):
		inst.call("init_scene", init_values)
	if _current_scene:
		_current_scene.disconnect("tree_exiting", self, "_on_current_scene_exit_tree")
		get_tree().root.remove_child(_current_scene)
		_current_scene.queue_free()
	_current_scene = inst
	get_tree().root.add_child(_current_scene)
	_current_scene.connect("tree_exiting", self, "_on_current_scene_exit_tree")
	return OK

func _on_current_scene_exit_tree()->void:
	_current_scene.disconnect("tree_exiting", self, "_on_current_scene_exit_tree")
	_current_scene = null
