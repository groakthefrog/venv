extends ViewportContainer

onready var _viewport: Viewport = Util.A($Viewport as Viewport)
onready var _camera: Camera = Util.A($Viewport/Camera as Camera)
onready var _test_obj: MeshInstance = $Viewport/MeshInstance
var _click := false
var _selected_object: Spatial
var _held_object: Spatial
var _mouse_relative: Vector2
var _rotate_view := false
var _zoom: float
var _move_dir: Vector2

func _ready():
	connect("resized", self, "_on_resized")
	connect("gui_input", self, "_on_viewport_gui_input")
	_viewport.size = rect_size
	focus_mode = Control.FOCUS_CLICK

func _on_resized():
	_viewport.size = rect_size

func _unhandled_input(event):
	if has_focus():
		if event is InputEventKey:
			if event.echo:
				return
			if event.pressed:
				match (event as InputEventKey).scancode:
					KEY_W:
						_move_dir.y = 1
					KEY_A:
						_move_dir.x = 1
					KEY_S:
						_move_dir.y = -1
					KEY_D:
						_move_dir.x = -1
			else:
				match (event as InputEventKey).scancode:
					KEY_W:
						if _move_dir.y == 1:
							_move_dir.y = 0
					KEY_A:
						if _move_dir.x == 1:
							_move_dir.x = 0
					KEY_S:
						if _move_dir.y == -1:
							_move_dir.y = 0
					KEY_D:
						if _move_dir.x == -1:
							_move_dir.x = 0

func _on_viewport_gui_input(event:InputEvent)->void:
	if event is InputEventMouseButton:
		match (event as InputEventMouseButton).button_index:
			BUTTON_WHEEL_UP:
				_zoom += event.factor
			BUTTON_WHEEL_DOWN:
				_zoom -= event.factor
			BUTTON_LEFT:
				if event.pressed:
					_click = true
				else:
					_click = false
					_held_object = null
			BUTTON_RIGHT:
				_rotate_view = event.pressed
				if not has_focus():
					grab_focus()



	if event is InputEventMouseMotion:
		_mouse_relative += event.relative
		_new_mouse_pos = event.position

var _new_mouse_pos:Vector2
var _last_hold_world_pos:Vector3
var _last_hold_screen_pos:Vector2

var dist_to_obj:float

func _physics_process(delta:float)->void:
	if _click:
		_click = false
		var ray_origin: Vector3 = _camera.project_ray_origin(_viewport.get_mouse_position())
		var ray_end: Vector3 = _camera.project_position(_viewport.get_mouse_position(), 1000) * 1.1
		var hit := (Venv.get_local_scene() as Spatial).get_world().direct_space_state.intersect_ray(ray_origin, ray_end) # @todo modify collision mask
		if hit:
			_selected_object = hit.collider.get_parent() # @todo search up to first venv object
			_held_object = _selected_object
			dist_to_obj = (_held_object.global_transform.origin-_camera.global_transform.origin).length()
		else:
			_selected_object = null

	if _rotate_view:
		(_camera as Spatial).transform
		_camera.rotate(Vector3.UP, -_mouse_relative.x/100.0)
		_camera.rotate_object_local(Vector3.LEFT, _mouse_relative.y/100.0)

	if _move_dir:
		print(_move_dir)
		_camera.global_translate(Quat(_camera.transform.basis)*Vector3(-_move_dir.x, 0, -_move_dir.y)*delta*20)

	if _held_object:
		var ray_norm := _camera.project_ray_normal(_viewport.get_mouse_position())
		_test_obj.global_transform.origin = _camera.global_transform.origin + ray_norm
		if _zoom:
			# we want to zoom towards the camera origin no matter where the mouse is on the viewport
			# get Quat which represents rotation towards where the mouse is projecting to
			# rotate forward vector to face that way and zoom based on that
			var q := Quat(_camera.transform.basis) * Quat((-_camera.transform.basis.z).cross(ray_norm).normalized(), (-_camera.transform.basis.z).angle_to(ray_norm))
			_held_object.global_translate(q*Vector3(0,0,_zoom/100.0))
			dist_to_obj = (_held_object.global_transform.origin-_camera.global_transform.origin).length()
		if _mouse_relative:
			_held_object.global_transform.origin = _camera.global_transform.origin + (_camera.project_ray_normal(_new_mouse_pos) * dist_to_obj)
		_last_hold_screen_pos = _viewport.get_mouse_position()
		_last_hold_world_pos = _held_object.global_transform.origin
	_mouse_relative = Vector2.ZERO
	_zoom = 0
