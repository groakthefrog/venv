extends Node

# autoload

enum {
	STATE_DISCONNECTED
	STATE_VIEWING
	STATE_STARTING
	STATE_NORMAL
}

const _VIEWER_SCENE: PackedScene = preload("res://scenes/main_scene/main_scene.tscn")
#const _LOADING_SCENE: PackedScene = preload("res://scenes/main_scene/main_scene.tscn")


var _server_port: int = -1
var _peer: NetworkedMultiplayerENet = null

mastersync var _state: int = STATE_DISCONNECTED

func create_session(port:int)->int:
	if _peer:
		return ERR_ALREADY_EXISTS # peer already created!
	_peer = NetworkedMultiplayerENet.new()
	var err := _peer.create_server(port)
	if err:
		return err
	get_tree().network_peer = _peer
	return OK

func join_session(address:String, port:int)->int:
	if _peer:
		return ERR_ALREADY_EXISTS # peer already created!
	_peer = NetworkedMultiplayerENet.new()
	var err := _peer.create_client(address, port)
	if err:
		return err
	get_tree().network_peer = _peer
	return OK

func disconnect_session():
	if _peer:
		_peer.close_connection()
		get_tree().network_peer = null

func _on_state_change()->void:
	_switch_to_current_state_scene()

func _switch_to_current_state_scene()->void:
	match _state:
		STATE_DISCONNECTED:
			pass
		STATE_STARTING:
			pass
		STATE_VIEWING:
			SceneManager.change_scene_to(_VIEWER_SCENE)

