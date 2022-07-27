extends Spatial
class_name VenvObj

func _ready()->void:
	add_to_group(Constants.VENV_OBJECT_GROUP_NAME)
	if Manager.window_type == Manager.WINDOW_TYPE_CONTROL:
		# create bounding box for model
		var bb := AABB()
		var nodes := [get_child(0)]
		while nodes:
			var cur: Node = nodes.pop_back()
			if cur is VisualInstance:
				bb = bb.merge(cur.get_transformed_aabb())
			# elif cur is CollisionShape:
			# 	(cur as CollisionShape).shape.get
			nodes.append_array(cur.get_children())

		if bb.size == Vector3.ZERO:
			print("oops") # @todo handle no bb

		var ca := StaticBody.new()
		var cs := CollisionShape.new()
		var s := BoxShape.new()
		ca.connect("ready", self, "_set_collider_transform", [ca, bb.size*0.5 + bb.position])
		s.extents = bb.size*0.5
		cs.shape = s
		ca.add_child(cs)
		add_child(ca)

func _set_collider_transform(ca, pos)->void:
	ca.disconnect("ready", self, "_set_collider_transform")
	ca.global_transform.origin = pos

