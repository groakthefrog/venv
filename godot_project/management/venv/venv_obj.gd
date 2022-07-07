extends Spatial
class_name VenvObj

func _ready()->void:
	if not Manager.is_viewer():
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

		var ca := Area.new()
		var cs := CollisionShape.new()
		var s := BoxShape.new()
		s.extents = bb.size*0.5
		cs.shape = s
		ca.add_child(cs)
		ca.global_transform.origin = bb.size*0.5 + bb.position
		add_child(ca)
