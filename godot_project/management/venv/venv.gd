extends Node

# autoload Venv
# Virtual enviornment manager and server

enum {
	STATE_DISCONNECTED
	STATE_STARTING
	STATE_NORMAL
}

const _DEFAULT_VENV_SCENE: PackedScene = preload("res://venv/venv_scene.tscn")

var _local_scene: Node setget, get_local_scene
func get_local_scene()->Node: return _local_scene
var _server_port: int = -1
var _peer: NetworkedMultiplayerENet = null

var _objects := []

mastersync var _state: int = STATE_DISCONNECTED

signal state_changed(new_state)
signal object_added(new_object)

func create_session(port:int, blahblahvenvdata = null)->int:
	if _peer:
		return ERR_ALREADY_EXISTS # peer already created!
	_peer = NetworkedMultiplayerENet.new()
	var err := _peer.create_server(port)
	if err:
		return err
	get_tree().network_peer = _peer
	_change_state(STATE_NORMAL)
	if blahblahvenvdata:
		pass # @todo add session creation data initalization
	else:
		_local_scene = _DEFAULT_VENV_SCENE.instance()
		add_child(_local_scene)
	return OK


func join_session(address:String, port:int)->int:
	if _peer:
		return ERR_ALREADY_EXISTS # peer already created!
	_peer = NetworkedMultiplayerENet.new()
	var err := _peer.create_client(address, port)
	if err:
		return err
	get_tree().network_peer = _peer
	_change_state(STATE_STARTING)
	return OK


func disconnect_session():
	if _peer:
		_peer.close_connection()
		get_tree().network_peer = null
		_change_state(STATE_DISCONNECTED)
		remove_child(_local_scene)
		_local_scene = null


func _add_object()->void:
	#emit_signal()
	pass


func _change_state(new_state:int):
	_state = new_state
	emit_signal("state_changed", new_state)