extends Node

# autoload EventManager

signal events_changed()

export var check_dependencies_time: float = 1.5

var _events := []

func get_events()->Array:
	return _events.duplicate()

func get_event(index:int)->Reference:
	if index < _events.size() and index >= 0:
		return _events[index]
	return null

func add_event(event:Event)->void:
	_events.append(event)
	emit_signal("events_changed")

func remove_event(event:Event)->void:
	_events.erase(event)
	emit_signal("events_changed")

func pause_event(event:Event)->void:
	pass # @todo

func _ready():
	var timer := Timer.new()
	timer.autostart = true
	timer.wait_time = check_dependencies_time
	timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)


func _on_timer_timeout()->void:
	for event in _events:
		event.check_dependencies()

class Event:
	extends Reference

	var name := "New Event"
	var texture: Texture

	var dependencies := []
	var action_queue := []

	func check_dependencies()->bool:
		return false

	func add_dependency(dependency)->void:
		if dependency.has_method("on_add"):
			dependency.call(self)


class Dependency:
	extends Reference
	func is_satisfied()->bool:
		return false

class VenvUniqueObjectDependency:
	extends Dependency
	var obj

	signal status_changed()

	func on_add(event:Event)->void:
		connect("status_changed",event,"check_dependencies")
		UniqueObjectManager.connect("object_registered", self, "_on_unique_object_registered")
		UniqueObjectManager.connect("object_removed", self, "_on_object_removed")

	func _on_unique_object_registered(uid,obj)->void:
		emit_signal("status_changed")

	func _on_object_removed(uid,obj)->void:
		emit_signal("status_changed")

	func is_statisfied()->bool:
		UniqueObjectManager
		return false

class Action:
	extends Reference

	var name := "New Action"
	var texture: Texture

	var _obj: Reference
	var _method: String
	var _args: Array

	func initalize(obj:Reference, method:String, args := [])->bool:
		if obj and method and obj.has_method(method):
			_obj = obj
			_method = method
			_args = args
			return true
		return false

	func activate()->void:
		_obj.callv(_method, _args)

