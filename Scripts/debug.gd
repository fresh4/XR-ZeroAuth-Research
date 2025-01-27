extends Label3D

@export var show_data: bool = false;
@export var pose : HandPose

@onready var pose_label: Label3D = %PoseLabel

const _DIAGNOSTIC_TEXT = \
	"Curl (deg)\n" + \
	"Thumb: {crl_thumb}\n" + \
	"Index: {crl_index}\n" + \
	"Middle: {crl_middle}\n" + \
	"Ring: {crl_ring}\n" + \
	"Pinky: {crl_pinky}\n\n" + \
	"Flex (deg)\n\n" + \
	"Thumb: {flx_thumb}\n" + \
	"Index: {flx_index}\n" + \
	"Middle: {flx_middle}\n" + \
	"Ring: {flx_ring}\n" + \
	"Pinky: {flx_pinky}"

func _ready() -> void:
	visible = show_data;


func _process(_delta: float) -> void:
	if not visible: return;
	debug_tracker();
	debug_pose();

func debug_tracker():
	var tracker = XRServer.get_tracker("/user/hand_tracker/right") as XRHandTracker
	if not tracker:
		return
	var data := HandPoseData.new()
	data.update(tracker)
	var text_data = {
		"flx_thumb" : int(data.flx_thumb),
		"flx_index" : int(data.flx_index),
		"flx_middle" : int(data.flx_middle),
		"flx_ring" : int(data.flx_ring),
		"flx_pinky" : int(data.flx_pinky),
		"crl_thumb"  : int(data.crl_thumb),
		"crl_index"  : int(data.crl_index),
		"crl_middle" : int(data.crl_middle),
		"crl_ring"   : int(data.crl_ring),
		"crl_pinky"  : int(data.crl_pinky),
	}
	text = _DIAGNOSTIC_TEXT.format(text_data)

func debug_pose():
	var tracker = XRServer.get_tracker("/user/hand_tracker/right") as XRHandTracker
	if not tracker:
		return
	var data := HandPoseData.new()
	data.update(tracker)
	var text_data := "%s - %0.2f\n\n" % [pose.pose_name, pose.get_fitness(data)]
	if pose.flexion_thumb:
		text_data += "Flexion Thumb: %0.2f\n" % pose.flexion_thumb.calculate(data.flx_thumb)
	if pose.flexion_index:
		text_data += "Flexion Index: %0.2f\n" % pose.flexion_index.calculate(data.flx_index)
	if pose.flexion_middle:
		text_data += "Flexion Middle: %0.2f\n" % pose.flexion_middle.calculate(data.flx_middle)
	if pose.flexion_ring:
		text_data += "Flexion Ring: %0.2f\n" % pose.flexion_ring.calculate(data.flx_ring)
	if pose.flexion_pinky:
		text_data += "Flexion Pinky: %0.2f\n" % pose.flexion_pinky.calculate(data.flx_pinky)
	if pose.curl_thumb:
		text_data += "Curl Thumb: %0.2f\n" % pose.curl_thumb.calculate(data.crl_thumb)
	if pose.curl_index:
		text_data += "Curl Index: %0.2f\n" % pose.curl_index.calculate(data.crl_index)
	if pose.curl_middle:
		text_data += "Curl Middle: %0.2f\n" % pose.curl_middle.calculate(data.crl_middle)
	if pose.curl_ring:
		text_data += "Curl Ring: %0.2f\n" % pose.curl_ring.calculate(data.crl_ring)
	if pose.curl_pinky:
		text_data += "Curl Pinky: %0.2f\n" % pose.curl_pinky.calculate(data.crl_pinky)
	if pose.abduction_thumb_index:
		text_data += "Abduction Thumb Index: %0.2f\n" % pose.abduction_thumb_index.calculate(data.abd_thumb)
	if pose.abduction_index_middle:
		text_data += "Abduction Index Middle: %0.2f\n" % pose.abduction_index_middle.calculate(data.abd_index)
	if pose.abduction_middle_ring:
		text_data += "Abduction Middle Ring: %0.2f\n" % pose.abduction_middle_ring.calculate(data.abd_middle)
	if pose.abduction_ring_pinky:
		text_data += "Abduction Ring Pinky: %0.2f\n" % pose.abduction_ring_pinky.calculate(data.abd_ring)
	if pose.distance_thumb_index:
		text_data += "Distance Thumb Index: %0.2f\n" % pose.distance_thumb_index.calculate(data.dst_index)
	if pose.distance_thumb_middle:
		text_data += "Distance Thumb Middle: %0.2f\n" % pose.distance_thumb_middle.calculate(data.dst_middle)
	if pose.distance_thumb_ring:
		text_data += "Distance Thumb Ring: %0.2f\n" % pose.distance_thumb_ring.calculate(data.dst_ring)
	if pose.distance_thumb_pinky:
		text_data += "Distance Thumb Pinky: %0.2f\n" % pose.distance_thumb_pinky.calculate(data.dst_pinky)
	pose_label.text = text_data;
