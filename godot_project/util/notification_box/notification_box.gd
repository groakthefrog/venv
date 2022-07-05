extends Control

# export(NodePath) onready var _timer    = Util.A(get_node(_timer)    as Timer)
# export(NodePath) onready var _animator = Util.A(get_node(_animator) as AnimationPlayer)
# var _notifications := []

# func _ready()->void:
# 	pass

# func _on_timer_timeout()->void:
# 	_fade_and_hide(_notifications.pop_back())

# func _fade_and_hide(item:Control)->void:
# 	if item:
# 		(_animator as AnimationPlayer).root_node = item.get_path()
