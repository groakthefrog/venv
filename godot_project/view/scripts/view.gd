extends Node

# autoload

var _server_port := 30000

var _peer: NetworkedMultiplayerENet

func get_server_port()->int:
	return _server_port

func _ready():
	_peer = NetworkedMultiplayerENet.new()
	if _peer.create_server(get_server_port()) == OK:
		get_tree().network_peer = _peer
