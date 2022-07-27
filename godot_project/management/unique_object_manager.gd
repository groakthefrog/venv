extends Node

# autoload UniqueObjectManager

var _unique_objects := {}

signal object_registered(uid, object)
signal object_removed(uid, object)

func register_object(uid:String, object:Node)->bool:
	if uid and object != null and not _unique_objects.has(uid):
		_unique_objects[uid] = object
		emit_signal("object_registered", uid, object)
		return true
	return false

func remove_object(uid:String)->bool:
	var obj: Node = _unique_objects.get(uid)
	if obj:
		emit_signal("object_removed", self, uid, obj)
		return true
	return false