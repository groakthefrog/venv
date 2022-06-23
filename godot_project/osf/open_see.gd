extends Node

# This is based on the Unity example for OpenSeeFace

export var listenAddress: String = "127.0.0.1"
export var listenPort: int = 11573

const N_POINTS: int = 68
const PACKET_FRAME_SIZE: int = 8 + 4 + 2 * 4 + 2 * 4 + 1 + 4 + 3 * 4 + 3 * 4 + 4 * 4 + 4 * N_POINTS + 4 * 2 * N_POINTS + 4 * 3 * (N_POINTS + 2) + 4 * 14

#This is an informational property that tells you how many packets have been received
var receivedPackets: int = 0
#This contains the actual tracking data
var trackingData: Array = [] # Array(OpenSeeData)

var _listening: bool = false setget ,get_listenting
func get_listenting()->bool: return _listening

var maxFit3DError: float = 100.0
var _buffer: PoolByteArray
var _open_see_data_map := {} # Dictionary<int, OpenSeeData>
var peer := PacketPeerUDP.new()
var _stop_reception := false
var _receive_thread := Thread.new()

func get_open_see_data(faceId: int)->OpenSeeData:
	if _open_see_data_map or not _open_see_data_map.has(faceId):
		return null
	return _open_see_data_map[faceId]

func _perform_reception()->void:
	_listening = true
	peer.listen(0, "*", 65535)
	while peer.poll() == OK:
		_buffer = peer.get_packet()
		if _buffer.size() % PACKET_FRAME_SIZE != 0:
			continue
		receivedPackets += 1

		while not _buffer.empty():
			var new_data := OpenSeeData.new()
			var sb := StreamPeerBuffer.new()
			sb.data_array = _buffer
			new_data.read_from_packet(sb)
			_open_see_data_map[new_data.id] = new_data
		trackingData = _open_see_data_map.values()


func _ready()->void:
	if not peer:
		peer.connect_to_host(listenAddress, listenPort)
	_receive_thread.start(self, "_perform_reception")


func _end_receiver()->void:
	if _receive_thread:
		_stop_reception = true
		_receive_thread.Join()
		_stop_reception = false


func OnApplicationQuit()->void:
	_end_receiver()


func OnDestroy()->void:
	_end_receiver()


class OpenSeeData:
	# The time this tracking data was captured at.
	var time: float
	# This is the id of the tracked face. When tracking multiple faces, they might get reordered due to faces coming and going, but as long as tracking is not lost on a face, its id should stay the same. Face ids depend only on the order of first detection and locations of the faces.
	var id: int
	# This field gives the resolution of the camera or video being tracked.
	var camera_resolution: Vector2
	# This field tells you how likely it is that the right eye is open.
	var right_eye_open: float
	# This field tells you how likely it is that the left eye is open.
	var left_eye_open: float
	# This field contains the rotation of the right eyeball.
	var right_gaze: Quat
	# This field contains the rotation of the left eyeball.
	var left_gaze: Quat
	# This field tells you if 3D points have been successfully estimated from the 2D points. If this is false, do not rely on pose or 3D data.
	var got3d_points: bool
	# This field contains the error for fitting the original 3D points. It shouldn't matter much, but it it is very high, something is probably wrong
	var fit3d_error: float
	# This is the rotation vector for the 3D points to turn into the estimated face pose.
	var rotation: Vector3
	# This is the translation vector for the 3D points to turn into the estimated face pose.
	var translation: Vector3
	# This is the raw rotation quaternion calculated from the OpenCV rotation matrix. It does not match Unity's coordinate system, but it still might be useful.
	var raw_quaternion: Quat
	# This is the raw rotation euler angles calculated by OpenCV from the rotation matrix. It does not match Unity's coordinate system, but it still might be useful.
	var raw_euler: Vector3
	# This field tells you how certain the tracker is.
	var confidence: PoolRealArray
	# These are the detected face landmarks in image coordinates. There are 68 points. The last too points are pupil points from the gaze tracker.
	var points: PoolVector2Array
	# These are 3D points estimated from the 2D points. The should be rotation and translation compensated. There are 70 points with guesses for the eyeball center positions being added at the end of the 68 2D points.
	var points3D: PoolVector3Array
	# This field contains a number of action unit like features.
	var features: OpenSeeFeatures

	class OpenSeeFeatures:
		# This field indicates whether the left eye is opened(0) or closed (-1). A value of 1 means open wider than normal.
		var eye_left: float
		# This field indicates whether the right eye is opened(0) or closed (-1). A value of 1 means open wider than normal.
		var eye_right: float
		# This field indicates how steep the left eyebrow is, compared to the median steepness.
		var eyebrow_steepness_left: float
		# This field indicates how far up or down the left eyebrow is, compared to its median position.
		var eyebrow_up_down_left: float
		# This field indicates how quirked the left eyebrow is, compared to its median quirk.
		var eyebrow_quirk_left: float
		# This field indicates how steep the right eyebrow is, compared to the average steepness.
		var eyebrow_steepness_right: float
		# This field indicates how far up or down the right eyebrow is, compared to its median position.
		var eyebrow_up_down_right: float
		# This field indicates how quirked the right eyebrow is, compared to its median quirk.
		var eyebrow_quirk_right: float
		# This field indicates how far up or down the left mouth corner is, compared to its median position.
		var mouth_corner_up_down_left: float
		# This field indicates how far in or out the left mouth corner is, compared to its median position.
		var mouth_corner_in_out_left: float
		# This field indicates how far up or down the right mouth corner is, compared to its median position.
		var mouth_corner_up_down_right: float
		# This field indicates how far in or out the right mouth corner is, compared to its median position.
		var mouth_corner_in_out_right: float
		# This field indicates how open or closed the mouth is, compared to its median pose.
		var mouth_open: float
		# This field indicates how wide the mouth is, compared to its median pose.
		var mouth_wide: float

	func _init()->void:
		confidence = PoolRealArray()
		confidence.resize(N_POINTS)
		points = PoolVector2Array()
		points.resize(N_POINTS)
		points3D = PoolVector3Array()
		points3D.resize(N_POINTS + 2)

	static func _swapX(v:Vector3)->Vector3:
		v.x = -v.x; return v

	static func _readQuat(b:StreamPeerBuffer)->Quat:
		return Quat(b.get_float(), b.get_float(), b.get_float(), b.get_float())

	static func _read_vector3(b:StreamPeerBuffer)->Vector3:
		return Vector3(b.get_float(), b.get_float(), b.get_float())

	static func _readVector2(b:StreamPeerBuffer)->Vector2:
		return Vector2(b.get_float(), b.get_float())

	func read_from_packet(b:StreamPeerBuffer)->void:
		time = b.get_double()
		id = b.get_32()
		camera_resolution = _readVector2(b)
		right_eye_open = b.get_float()
		left_eye_open = b.get_float()

		got3d_points = false
		if b.get_byte() != 0:
				got3d_points = true

		fit3d_error = b.get_float()
		raw_quaternion = _readQuat(b)
		raw_euler = _read_vector3(b)

		rotation = raw_euler
		rotation.z = fmod(rotation.z - 90, 360)
		rotation.x = -fmod(rotation.x + 180, 360)

		var x := b.get_float()
		var y := b.get_float()
		var z := b.get_float()
		translation = _read_vector3(b)
		translation = Vector3(-y, x, -z)

		for i in N_POINTS:
			confidence[i] = b.get_float()

		for i in N_POINTS:
			points[i] = _readVector2(b)

		for i in N_POINTS + 2:
			points3D[i] = _read_vector3(b)

		var b0 := Basis.IDENTITY
		b0.z = _swapX(points3D[66]) - _swapX(points3D[68])
		var b1 := Quat.IDENTITY
		b1.set_axis_angle(Vector3.RIGHT, 180)
		var b2 := Quat.IDENTITY
		b2.set_axis_angle(Vector3.FORWARD, 180)
		right_gaze = Quat(b0) * b1 * b2

		b0 = Basis.IDENTITY
		b0.z = _swapX(points3D[67]) - _swapX(points3D[69])
		b1 = Quat.IDENTITY
		b1.set_axis_angle(Vector3.RIGHT, 180)
		b2 = Quat.IDENTITY
		b2.set_axis_angle(Vector3.FORWARD, 180)
		left_gaze = Quat(b0) * b1 * b2

		features = OpenSeeFeatures.new()
		features.EyeLeft = b.get_float()
		features.EyeRight = b.get_float()
		features.EyebrowSteepnessLeft = b.get_float()
		features.EyebrowUpDownLeft = b.get_float()
		features.EyebrowQuirkLeft = b.get_float()
		features.EyebrowSteepnessRight = b.get_float()
		features.EyebrowUpDownRight = b.get_float()
		features.EyebrowQuirkRight = b.get_float()
		features.MouthCornerUpDownLeft = b.get_float()
		features.MouthCornerInOutLeft = b.get_float()
		features.MouthCornerUpDownRight = b.get_float()
		features.MouthCornerInOutRight = b.get_float()
		features.MouthOpen = b.get_float()
		features.MouthWide = b.get_float()
