extends Node

# autoload


enum {
	STATE_DISCONNECTED
	STATE_STARTING
	STATE_NORMAL
}


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

